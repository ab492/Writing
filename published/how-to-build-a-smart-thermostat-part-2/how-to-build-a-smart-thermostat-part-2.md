---
title: How to Build a Smart Thermostat Part 2
date: 2025-07-03
layout: post.njk
tags: post
---

### Introduction

In the [first post of this series](/posts/published/how-to-build-a-smart-thermostat-part-1) I explained how to control a boiler with a Raspberry Pi. But that’s only half the functionality of a thermostat. To know when to adjust the boiler, the thermostat needs to know the current and desired temperatures.

In this post we'll cover choosing a temperature sensor, how it works, wiring it up, and writing the code to parse the temperature.

### How does a sensor fetch the temperature?

Let’s take a brief detour into the inner workings of an electrical circuit. Electricity is the movement of charged particles around a circuit, often electrons in metal wires. Voltage is what drives this motion. The classic metaphor is water in a pipe, where voltage is compared to the pressure that pushes water through the pipe.

There is an electrical component called a diode which allows current to flow in one direction only. A diode contains a small junction that electrons must push through and a helpful side effect of this is that when the electrons move through the diode, there is a small reduction in voltage, known as voltage drop.

The key to temperature sensing is that this voltage drop varies predictably based on the current temperature. So, if you know what the various voltage drops are at different temperatures, you can measure the current voltage drop and work backwards to find the temperature. This is what the temperature sensor does. 

The beauty of this sensor -- I'm using [DS18B20](https://thepihut.com/products/waterproof-ds18b20-digital-temperature-sensor-extras?variant=27740417873) -- is that the analog data (that is, the voltage drop information) is internally converted to digital data and transmitted to the Raspberry Pi. 

### Getting the temperature to the Raspberry Pi

Now we have a sensor that knows the temperature, how do we get that data to the Raspberry Pi? The sensor has three cables: one for 3V (power), one for ground, and one for data. I used a breadboard connected to the Raspberry Pi via a ribbon cable to make it easier to access the header pins. 3V and ground were self explanatory, and the data cable went into one of the data ports, which for me was #4 (as labelled in the diagram). 

The sensor also comes with a pull-up resistor. But what is that for?

The data cable transmits information by sending 1s -- corresponding to high (3V) voltages -- and 0s -- corresponding to low (0V) voltages -- on the line. 

In its idle state, the sensor is not sending anything. However, this means the data pin into the breadboard can pick up random noise from other electronic components, meaning the signal can fluctuate unpredictably -- known as "floating" -- leading to unreliable readings. 

What's needed is a way to ensure the data line is only ever high or low, even when idle. The pull-up resistor solves this by connecting the data line to the 3V line, providing a weak but steady connection to power. It gently supplies 3V to the data line, keeping it high when nothing else is connected. But because the connection is weak -- thanks to the high resistance -- the sensor can easily override it and pull the line down to 0V when it needs to transmit a 0.

Without the resistor, the data line would be stuck at 3V, and the sensor wouldn’t be able to bring it down to 0V.

Putting that together, we're left with something that looks like this:

![A circuit diagram of power, ground, data and a pull up resistor connected to a Raspberry Pi.](001.png)

![A photograph of the circuit showing the temperature sensor connected to the Raspberry Pi.](002.jpeg)

How do we know the difference between the sensor sending a high value and the idle state of high? It's not just the high or low value that matter, the timing between the transitions matter too. When the device is ready to communicate, it pulls the line down to low to signal activity. After that, the data transfer of high and low correspond to precise timing patterns defined by [data transfer protocols](https://cdn.shopify.com/s/files/1/0176/3274/files/DS18B20_8250021c-fcd0-4fb2-90e9-05d6c39d7d76.pdf?v=1676904940#page=15).

Now we have the sensor wired up, how do we actually read the temperature?

### Writing the code 

To interface with the sensor, there's a lot of boilerplate that I borrowed from other tutorials. I've added the whole file here, with comments to guide you through.

To remain compatible with `HomeKit` integration, I've used async-await. This guarantees we won't block any other code execution happening elsewhere.

```python
import os
import glob
import asyncio
from typing import NamedTuple

"""
This script allows you to read temperature data from a DS18B20 temperature sensor connected to a Raspberry Pi; temperature is returned in celsius and fahrenheit.

Prerequisites:
- A Raspberry Pi with Raspbian OS installed.
- A DS18B20 temperature sensor properly connected to the GPIO (General Purpose Input/Output) pins of the Raspberry Pi (see references).
- The 1-Wire interface enabled on the Raspberry Pi.

Configuration:
Before running the script, ensure the Raspberry Pi is configured to interface with the DS18B20 sensor:
1. Add the line 'dtoverlay=w1-gpio' to /boot/config.txt. This enables the 1-Wire interface on the GPIO pin used by the sensor.
2. Add 'w1-gpio' and 'w1-therm' to /etc/modules. This ensures that the necessary modules are loaded when the Raspberry Pi boots up.

References:
For more information on setting up and using the DS18B20 temperature sensor with a Raspberry Pi, visit:
- https://thepihut.com/blogs/raspberry-pi-tutorials/ds18b20-one-wire-digital-temperature-sensor-and-the-raspberry-pi
- https://pimylifeup.com/raspberry-pi-temperature-sensor/

"""
class TemperatureInfo(NamedTuple):
    celsius: float
    fahrenheit: float
  
# This path is where 1-wire devices are mounted in the filesystem of a Linux-based system.
base_dir = '/sys/bus/w1/devices/'

# The '28' prefix is common for DS18B20 temperature sensors. Since we only have 1 sensor, we just grab the first.
try:
    device_folder = glob.glob(base_dir + '28*')[0]
except IndexError:
    raise FileNotFoundError("No temperature sensor found; is it wired correctly?")

# The 'w1_slave' is provided by 'w1-therm' module and contains the raw temperature data from the sensor.
device_file = device_folder + '/w1_slave'

async def _read_temp_raw():
    try:
        # Open is not natively async, so we use 'asyncio' to run it in a threadpool
        with await asyncio.to_thread(open, device_file, 'r') as raw_data:
            lines = await asyncio.to_thread(raw_data.readlines)
        return lines
    except Exception as e:
        raise IOError(f"Failed to read device file; is the temperature sensor wired correctly? Error: {e}")

async def read_temp() -> TemperatureInfo:
    # The raw temperature comes over two lines in the following format:
    # 54 01 4b 46 7f ff 0c 10 fd : crc=fd YES
    # 54 01 4b 46 7f ff 0c 10 fd t=21250
    lines = await _read_temp_raw()

    max_attempts = 10
    attempts = 0
    
    # The first line is a checksum to indicate if the measurement is valid. 
    # If the line ends in 'YES', we can proceed. If 'NO', the sensor is not ready so we wait 0.2 seconds.
    while True:
        try:
            if lines[0].strip()[-3:] == 'YES':
                break  # Exit loop if the condition is met
            elif attempts >= max_attempts:
                raise TimeoutError("Sensor read attempt exceeded maximum retries.")
        except IndexError:
            raise IndexError("Unexpected data format from sensor; is the temperature sensor wired correctly?")

        await asyncio.sleep(0.2)
        lines = await _read_temp_raw()
        attempts += 1

    # Now we find the actual raw data by finding 't='.
    equals_pos = lines[1].find('t=')

    # If `equals_pos` is not -1, it means 't=' has been located.
    if equals_pos != -1:
        temp_string = lines[1][equals_pos+2:]
        temp_c = float(temp_string) / 1000.0
        temp_f = temp_c * 9.0 / 5.0 + 32.0
        return TemperatureInfo(celsius=temp_c, fahrenheit=temp_f)
    
async def main():
    try:
        temperature_info = await read_temp()
        print(f"Temperature: {temperature_info.celsius}°C, {temperature_info.fahrenheit}°F")
    except Exception as e:
        print(f"Error reading temperature: {e}")

if __name__ == "__main__":
    # asyncio.run() is used to run the main function, which handles the async call to read_temp
    asyncio.run(main())
```


### Conclusion

That's the second piece of the puzzle solved. This, along with the work covered in the [first post](/posts/published/how-to-build-a-smart-thermostat-part-1) means we have two independent parts of a thermostat: the ability to control a boiler and the ability to fetch the temperature.

In the final post, we'll tie these together to make a functioning system and add smart home integration.

### Notes
- [Potentially useful information about the DS18B20 internal workings](https://electronics.stackexchange.com/questions/722882/how-does-ds18b20-temperature-sensor-get-the-temperature), although way above my electronics understanding.
- [Excellent blog post](https://opensource.com/article/21/3/thermostat-raspberry-pi) about someone who built a similar thermostat. This was the inspiration for me to start this project.