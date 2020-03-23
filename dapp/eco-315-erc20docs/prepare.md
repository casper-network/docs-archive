# Preparation

Before we start development of an ERC20 contract, we'll first prepare the repository. The code will be organized into 3 separate crates: `logic`, `contract` and `tests`.

We'll then start with generating a new project and applying a few changes as follows:

1. Generate a new project using [cargo-casperLabs](setup-of-rust-contract-sdk.html#cargo-casperlabs).

```bash
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
```

Note: We highly recommend working within one [Cargo Workspace](https://doc.rust-lang.org/book/ch14-03-cargo-workspaces.html), rather than separated crates. This is until and unless we are creating multiple implementations of an ERC20, in which case, each implementation should have it's own workspace.

1. Create a new file `Cargo.toml` in the root directory:

```toml
# Cargo.toml

[workspace]

members = [
    "contract",
    "tests"
]
```

The project will have only one `target` directory placed in the root, so `tests/build.rs` has to be adjusted as follows:

1. Change 

```rust
const ORIGINAL_WASM_DIR: &str = "../contract/target/wasm32-unknown-unknown/release";
```
to
```rust
const ORIGINAL_WASM_DIR: &str = "../target/wasm32-unknown-unknown/release";
```

When building the WASM file we only want to build the `contract`, not all the crates:

1. Change

```rust
const BUILD_ARGS: [&str; 2] = ["build", "--release"];
```
to
```rust
const BUILD_ARGS: [&str; 4] = ["build", "--release", "-p", "contract"];
```

1. Remove `rust-toolchain` files from `contract` and `tests` crates, and make just one crate in the root directory:

```bash
$ rm contract/rust-toolchain
$ mv tests/rust-toolchain .
```

1. Then, test the changes by compiling `contract` crate, and then running the test on `tests` crate.

```bash
$ cargo build --release -p contract 
$ cargo test -p tests
```

TODO: fix required `--target wasm32-unknown-unknown`