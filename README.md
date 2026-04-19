![Work in Progress](https://img.shields.io/badge/Status-WIP-yellow)
![Template](https://img.shields.io/badge/Template-blue)
![Python](https://img.shields.io/badge/Python-3.9%20%7C%203.11-blue)
![uv](https://img.shields.io/badge/uv-Package%20Manager-261230?logo=astral&logoColor=white)

# Python Package Template

A template repository for developing Python packages using [uv](https://docs.astral.sh/uv/) in a VSCode devcontainer. Comes pre-configured with uv and Quarto for package documentation.

## Features

- Devcontainer configuration for VSCode
- [uv](https://docs.astral.sh/uv/) for dependency, virtual environment and Python version management (replaces pip, pipx, pyenv and Poetry)
- Quarto for documentation
- Pre-configured development environment

## Quick Start

**Pre-requisites:** Ensure you have the following installed on your system: [Visual Studio Code (VSCode)](https://code.visualstudio.com/) and [Docker Desktop](https://www.docker.com/products/docker-desktop)

1. Click "Use this template" to create a new repository
2. Clone your new repository
3. Open in VSCode with devcontainer extension
4. VSCode will prompt to reopen in container - accept this (will take a few minutes)

> Alternatively, click 'Use this template' in this repository, then select 'Open in a codespace' to try it out directly in your browser.

## Project Setup

Open a terminal in your container workspace and run the following:

1. Initialize a uv project (creates `pyproject.toml` with PEP 621 metadata and a `.python-version`):
   ```bash
   uv init --lib
   ```

2. Add development-only dependencies (recorded under the `dev` dependency group in `pyproject.toml`, not shipped to end users):
   ```bash
   uv add --dev pytest quartodoc
   ```

   uv also supports arbitrary named groups — for example, docs-only dependencies:
   ```bash
   uv add --group docs quartodoc
   ```

3. Add runtime dependencies your package needs:
   ```bash
   uv add requests
   ```

4. Sync the environment (creates `.venv/` in the project and writes `uv.lock`):
   ```bash
   uv sync
   ```

## Documentation

Documentation is handled through Quarto. To build the documentation:

```bash
uv run quarto render
```

## Example Project

After creating a new repository from this template:

> Alternatively, replace steps 1 and 2 by clicking 'Use this template' in this repository, then select 'Open in a codespace' to try it out directly in your browser.

1. Clone your repository and open in VSCode
   ```bash
   git clone <your-repo-url>
   code <repo-directory>
   ```

2. When prompted, reopen in container (or use Command Palette: "Reopen in Container")

3. Initialize your uv project as a library (update with your details):
   ```bash
   uv init --lib \
       --name hellopy \
       --description "Your package description" \
       --author-from none \
       --python 3.11
   ```
   Then open `pyproject.toml` and set the `authors = [...]` field to your name/email.

4. Replace the auto-generated package contents:
   ```bash
   rm -rf src/hellopy && \
   mkdir -p src/hellopy && \
   touch src/hellopy/__init__.py && \
   touch src/hellopy/hello.py
   ```

5. Populate `hello.py` with the following
   ```python
    def hello():
        """
        Print a greeting message.

        Example usage:
        ```{python}
        from hellopy.hello import hello
        hello()
        ```
        """
        print("Hello!")
   ```

6. Install your package in editable mode and add IPython / Jupyter as dev-only dependencies:
    ```bash
    uv sync && \
    uv add --dev ipython jupyter
    ```

7. Activate the virtual environment
   ```bash
   source .venv/bin/activate
   ```

   Or, skip activation and prefix commands with `uv run`, e.g. `uv run ipython`.

8. Start IPython (or an interactive Jupyter window)
   ```bash
   ipython
   ```

9. In IPython, import `hello()`
    ```python
    from hellopy.hello import hello
    ```

10. Enjoy developing your package!
    ```python
    # Try editing `hello.py` and re-running the `hello()` command
    hello()
    ```

## Poetry → uv cheat sheet

If you're coming from the previous Poetry-based template:

| Task | Poetry | uv |
| --- | --- | --- |
| Create a project | `poetry init` | `uv init` / `uv init --lib` |
| Add a runtime dependency | `poetry add requests` | `uv add requests` |
| Add a dev-only dependency | `poetry add --group dev pytest` | `uv add --dev pytest` |
| Add to a named group | `poetry add --group docs quartodoc` | `uv add --group docs quartodoc` |
| Install all deps from lockfile | `poetry install` | `uv sync` |
| Run a command in the venv | `poetry run pytest` | `uv run pytest` |
| Update the lockfile | `poetry lock` | `uv lock` |
| Build a distribution | `poetry build` | `uv build` |
| Publish | `poetry publish` | `uv publish` |
| Pin a Python version | `poetry env use 3.11` | `uv python pin 3.11` |
