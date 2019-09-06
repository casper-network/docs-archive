# CasperLabs Tech Spec - Sphinx


## Installing Sphinx and Libraries

Install the following Python packages using pip:

```
sudo pip install sphinx sphinx-rtd-theme recommonmark
```

## Building

Run `make` to see the many output options.

To generate the website, run

```
make html
```

To generate the PDF (LaTeX), run

```
make latexpdf
```

Files will be generated under `_build/`.
