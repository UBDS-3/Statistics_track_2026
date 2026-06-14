# UBDS3-2025 Statistics source

This repository contains teaching material for the R statistical course of the Ukrainian Biological Data Science Summer School 2026.

## Contents

* [Setup](labs/00-setup)
* [Exploratory Data Analysis](labs/exploratory)
* [Data and Randomness](labs/randomness)
* [Regression](labs/regression)
* [Omics](labs/omics)
* [Hypothesis testing](labs/testing)
* [Clustering analysis](labs/clustering)
* [Multivariate analysis](labs/multivariate)
* [Machine Learning](labs/ML)


## For faculty members

### Git hook

The repo has `git hook` for automated source rendering and pushing them to the `master` branch once you commit any `*.qmd` files.

To activate the hook, add the the hook to `.git/hooks/` directory:

```bash
# on repo root
cp .githooks/post-commit .git/hooks/
```

### Render.sh script

The script `render.sh` can be used for batch processing multiple sources, it required `quarto-cli` binaries installed and a path to your `R_HOME` (see below). For usage run `./render.sh`.

#### Usage

```bash
./render.sh --type <type|all> [--lab <labs|all>]
```

* `--type`: one or more of `solved` `simplified` `default` (or `all`)
* `--lab`: one or more of `testing` `exploratory` `clustering` `omics` `ML` `regression` `randomness` `multivariate` (or `all`); defaults to all labs if omitted

Examples:

```bash
./render.sh --type solved --lab multivariate     # one type, one lab
./render.sh --type solved simplified --lab ML regression
./render.sh --type all --lab all                 # render everything
```

Rendered output is written next to each `.qmd` (e.g. `labs/multivariate/multivariate.solved.html`). The `exploratory` and `randomness` labs are always rendered as `default` only.

#### Prerequisites

* **bash** — the script runs on stock macOS bash 3.2 as well as newer bash.
* **quarto** — must be installed. If it is not found, install [quarto-cli](https://quarto.org/docs/get-started/) or add it to your `PATH`.
* **R packages** — each lab loads its own packages via `library()`; a missing one fails the render with `there is no package called '<pkg>'`. Install the reported package and re-run, e.g.:

  ```r
  install.packages(c("GGally", "ade4", "factoextra"))
  ```

Hook can automate source rendering with setting env variable, i.e.

```
export RENDER_AUTO=true # use `unset RENDER_AUTO` to disable automatic rendering
```

It is advised to run the `render.sh` script manually before using it in the hook to check whether `quarto` is working properly.

Make sure to have proper `R_HOME` variable, for macOS with RStudio (latest) is `R_HOME=/Library/Frameworks/R.framework/Resources`

## License

The project is licensed under CC0, see `LICENSE` for more information.
