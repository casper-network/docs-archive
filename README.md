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

**IMPORTANT:** Sometimes the Makefile can't capture all the changes in the
files, and builds fail unless started from scratch. If you run into problems,
run `make clean` before building:

```
make clean; make html
```

or

```
make clean; make latexpdf
```

This increases build time. The good news is it shouldn't be necessary if you are
editing a single file.

## Why abandon Gitbook?

We discussed recently how to collaborate on the whitepaper/techspec
It's in gitbook, which changed versions recently:
https://docs.gitbook.com/v2-changes/important-differences
And here are some disconcerting quotes:

> We have moved away from the static site generator model, and no longer use the famous gitbook CLI to build documentation output. This has brought a lot of benefits and simplicity to the new version, such as instant publishing, getting rid of obscure build failures, automatic updates and continuous improvement of features for hosted documentations.
> We are no longer versioning your books as a Git repository. With the new version, we have shifted to a GitBook specific versioning system. Your content is still backed-up, versioned, and always available for export, so it is never locked on our platform. But we no longer offer this feature in the form of a git hosting service.

IMO having a documentation system that supports git is a must. This will be a specialized technical document which requires features like:
1. LaTeX equations (MathJax must be configurable, apparently one needs to type `$$` also for inline equations which @Wojtek and I find stupid)
2. Figures
3. Exporting to both web and PDF
4. other hard to foresee features...

AFAIU gitbook has problems with 1 and 3 already. They removed the CLI build workflow, which makes it hard to see the output locally. This is a headache when writing out equations for example. I'm not sure if it's like that now, but having to commit every time you need to see the output isn't very smart

They removed git, which makes collaboration a headache. *Also, storing document state in places other than the repo isn't very smart.*
