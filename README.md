# CasperLabs TechSpec

## tl;dr on how to work and contribute

- The whole document is written in a plaintext format called reStructuredText,
  and compiled into HTML and PDF by a documentation generator called
  [Sphinx](https://www.sphinx-doc.org/).
- The recommended way of working on this doc is with the static HTML output with
  live reload.
  - Open up a terminal, go to the project directory and run `make livehtml`.
  - Choose a page to work on. Open up that page in your text editor. Also
    navigate to that page in your browser. Set the browser window and editor
    side-by-side on your screen.
  - Make changes in your editor. When you save, Sphinx Autobuild will
    automatically refresh any browser tabs that has the document opened up.
- The documents are hosted on the paid version of [Read the Docs](https://readthedocs.com/).
  The CI workflow is described as follows:
  - Contributors must create their own branch, commit, and create a pull request
    on GitHub.
  - The pull request must be reviewed by another member of the team before it
    can be merged.
  - When the branch is merged to `master`, Read the Docs automatically
    recompiles all output, served on
    [techspec.casperlabs.io](https://techspec.casperlabs.io).


## Installing Sphinx and Other Modules

Install the following Python packages using pip:

On Mac/Linux:

```
sudo pip3 install sphinx sphinx-rtd-theme recommonmark sphinx-autobuild
```

On Windows:

Start `cmd` in Admin mode. Make sure Python binaries are in your $PATH and run

```
pip3 install sphinx sphinx-rtd-theme recommonmark sphinx-autobuild
```

## Installing a TeX Distribution

Sphinx generates the LaTeX files, but the program that generates the PDF by
compiling those files, `pdflatex`, is not included in Sphinx. The LaTeX compiler
comes from a TeX distribution, e.g. [TeX Live](https://www.tug.org/texlive/)
(Linux), [MacTeX](https://www.tug.org/mactex/) (Mac) or
[MiKTex](https://miktex.org) (Windows).

Note: If you don't want to deal with installing a TeX distribution, you can
upload the generated files under `_build/latex/` to an online service like
[Overleaf](https://overleaf.com). The downside is that you would have to upload
from scratch every time you need to compile, so this is only a workaround for when you
can't get it to compile due to some weird reason.

If you are installing TeX Live on a Debian based distro, make sure that you have
all the packages from TeX Live installed. Otherwise, you may run into issues due
to missing LaTeX packages.

```
sudo apt-get install texlive*
```

If you are still running into problems, you may solve them using
[TeX Live's own distribution](https://www.tug.org/texlive/acquire-netinstall.html)
instead of the packages from the native package manager.

## Building

Run `make` to see the many output options.

Note: You don't need to be on Linux to work on the TechSpec. You can work on any
OS of your choice as (e.g. Mac, Windows) long as Python and Sphinx are installed, and relevant
binaries are in your $PATH. Windows doesn't come with `make`, so it might be a
good idea to use
[Windows Subsystem for Linux](https://docs.microsoft.com/en-us/windows/wsl/about).
The other option is to invoke `sphinx-build` directly, e.g.

```
$ sphinx-build -M html "." "_build"
```

### Static HTML

To generate the website, run

```
make html
```

This generates the website under `_build/html/`. To view it, open the file
`_build/html/index.html` in your browser.

### Static HTML with live reload

It's too tedious to type in `make html` every time one needs a preview.
[Sphinx Autobuild](https://pypi.org/project/sphinx-autobuild/) is an external
module built to remedy this issue. Files are tracked in real time and the
website is built from scratch every time a change is detected.

To use it, run

```
make livehtml
```

This starts a server which serves the live content on `http://localhost:8000/`.


### PDF through LaTeX

To generate the PDF (LaTeX), run

```
make latexpdf
```

This generates the PDF `_build/latex/CasperLabsTechSpec.pdf`.


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

## Editing

This section outlines a recommended way of editing reStructuredText files.
I chose [VS Code](https://code.visualstudio.com) as an example, but you could
reproduce the same configuration with your own text editor. Editing will not
require a lot of features or IDEs. The only requirement is the 80-character hard
wrap setting. On the other hand, good-to-haves are syntax highlighting,
and keybindings to insert frequently used rst directives such as ``:math:`...` ``.


### Setting up VS Code

1. Install VS Code.
2. Go to the extensions sidebar (`Ctrl+X`) and install the extensions
[reStructuredText](https://marketplace.visualstudio.com/items?itemName=lextudio.restructuredtext)
and [Rewrap](https://marketplace.visualstudio.com/items?itemName=stkb.rewrap).
3. Go to settings with `Ctrl+,`.
   - Change the setting `Editor: Word Wrap` to `off`.
   - Make sure `Rewrap: Auto Wrap` is `Enabled`.


### Structuring your content

1. Setup your file structure in no more than 2 levels
2. Format your content with no more than 3 heading levels
Note: Setex is recommended, but ATX is also acceptable
3. To reference content within the guide, use :ref: (e.g., see :ref:`Execution Semantics <execution-semantics-urefs>` for
for more information)
4. To reference content to GIT source, link to master branch (e.g. https://github.com/CasperLabs/CasperLabs/tree/master/execution-engine/contracts/examples)
5. To cross-reference content of CasperLabs tools and references like SDKs, APIs... link to the newest published GIT sources and versions   (e.g., cargo-casperlabs CLI tool -- https://crates.io/crates/cargo-casperlabs or https://github.com/CasperLabs/CasperLabs/tree/master/execution-engine/cargo-casperlabs (those two links have equivalent information - it's the README from the crate's root) )

## Why move away from Gitbook?

We discussed recently how to collaborate on the whitepaper/techspec
It's in gitbook, which changed versions recently:
https://docs.gitbook.com/v2-changes/important-differences

And here are some of their disconcerting quotes:

> We have moved away from the static site generator model, and no longer use the famous gitbook CLI to build documentation output. This has brought a lot of benefits and simplicity to the new version, such as instant publishing, getting rid of obscure build failures, automatic updates and continuous improvement of features for hosted documentations.
> We are no longer versioning your books as a Git repository. With the new version, we have shifted to a GitBook specific versioning system. Your content is still backed-up, versioned, and always available for export, so it is never locked on our platform. But we no longer offer this feature in the form of a git hosting service.

IMO having a documentation system that supports git is a must. This will be a
specialized technical document which requires features like:
1. LaTeX equations (MathJax must be configurable, apparently one needs to type `$$` also for inline equations which @Wojtek and I find stupid)
2. Figures
3. Exporting to both web and PDF
4. other hard to foresee features...

AFAIU gitbook has problems with 1 and 3 already. They removed the CLI build
workflow, which makes it hard to see the output locally. This is a headache when writing out equations for example. I'm not sure if it's like that now, but having to commit every time you need to see the output isn't very smart

GITbook removed git, which makes collaboration a headache. *Also, storing document state in places other than the repo isn't very smart.*
