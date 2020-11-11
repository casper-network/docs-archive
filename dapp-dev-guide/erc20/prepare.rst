
Prepare
=======

Before we start the development, let's prepare the repository first.

The code will be divided into 3 crates: ``logic``\ , ``contract`` and ``tests``. Let's start with generating a new project and applying a few changes.

Generate a new project using `Cargo CasperLabs <../setup-of-rust-contract-sdk#cargo-casperlabs>`_.

.. code-block:: bash

   $ cargo casperlabs erc20-tutorial
   $ cd erc20-tutorial
   $ tree
   .
   ├── contract
   │   ├── Cargo.toml
   │   ├── rust-toolchain
   │   └── src
   │       └── lib.rs
   └── tests
       ├── build.rs
       ├── Cargo.toml
       ├── rust-toolchain
       ├── src
       │   └── integration_tests.rs
       └── wasm
           ├── mint_install.wasm
           ├── pos_install.wasm
           └── standard_payment.wasm

   5 directories, 10 files

It's better to have one `Cargo Workspace <https://doc.rust-lang.org/book/ch14-03-cargo-workspaces.html>`_ rather than separated crates. Create a new file ``Cargo.toml`` in the root directory.

.. code-block:: toml

   # Cargo.toml

   [workspace]

   members = [
       "contract",
       "tests"
   ]

   [profile.release]
   lto = true

Now the project will have only one ``target`` directory placed in the root directory, so ``tests/build.rs`` must be adjusted. Change

.. code-block::

   const ORIGINAL_WASM_DIR: &str = "../contract/target/wasm32-unknown-unknown/release";

to

.. code-block::

   const ORIGINAL_WASM_DIR: &str = "../target/wasm32-unknown-unknown/release";

When building WASM file we don't want to build all crates, but only the ``contract`` one. Change

.. code-block::

   const BUILD_ARGS: [&str; 2] = ["build", "--release"];

to

.. code-block::

   const BUILD_ARGS: [&str; 4] = ["build", "--release", "-p", "contract"];

Finally remove ``rust-toolchain`` files from ``contract`` and ``tests`` crates and make just one in the root directory.

.. code-block:: bash

   $ rm contract/rust-toolchain
   $ mv tests/rust-toolchain .

Test the changes by compiling ``contract`` crate and executing ``cargo test`` on ``tests`` crate.

.. code-block:: bash

   $ cargo build --release -p contract 
   $ cargo test -p tests
