## How to Setup

1. Setup a virtual environemnt:

```bash
python3 -m venv venv
```

2. Activate the virtual environment:
```bash
source venv/bin/activate
```

3. Install pip-tools. Instead of manually managing a messy requirements.txt full of sub-dependencies, we use [pip tools](https://github.com/jazzband/pip-tools).

This lets us define top-level dependencies in requirements.in, and compile them into a fully pinned requirements.txt.

```bash
pip install pip-tools
```

4. Generate `requirements.txt` from specified packages in `requirements.in`:

```bash
pip-compile requirements.in
```

5. Install project dependencies from the compiled requirements.txt:

```bash
pip install -r requirements.txt
```

6. Set your venv Python kernal so that Jupyter can use it:

```bash
python -m ipykernel install --user --name=venv --display-name "Python (venv)"
```

7. Launch Jupyter:

```bash
jupyter lab
```

## How to Update Dependencies

1. Add package to `requirements.in`:

```bash
echo "jupyterlab" > requirements.in
```

2. Compile requirements.txt from requirements.in:

```bash
pip-compile requirements.in
```

3. Install packages from requirements.txt:

```bash
pip install -r requirements.txt
```

## (TBD Legacy) How to install package locally (for use in Jupyter Notebooks)
1. Run `scripts/setup.sh` from the main directory.

## TODO
- Look into best way to manage Python environment with specific packages (i.e. Jupyter).
- Learn about variance.
- Learn about overflow issue with large numbers.
- Learn about precision in Python.

