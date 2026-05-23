
# Rust-Toolchain to Manifest

Generates a url for downloading the manifest for a given rust toolchain.
The toolchain can be provided directly or as a project's
`rust-toolchain.toml` file.

For more information on the toolchain channel, see:
https://rust-lang.github.io/rustup/overrides.html#channel

## Quickstart

```
Usage: toolchain-to-manifest <COMMAND> <VALUE>

Commands:
  string  <VALUE> is a `toolchain.channel` value
  file    <VALUE> is the path of a `rust-toolchain.toml` file that has `toolchain.channel`.
```

## Building

### Nix

To have nix build it:
`nix build` -> ./result

To build it yourself:
```
nix develop
cargo run --release -- <COMMAND> <VALUE>
```

### Cargo

`toolchain-to-manifest` requires rust nightly.
```
cargo +nightly build --release
```

