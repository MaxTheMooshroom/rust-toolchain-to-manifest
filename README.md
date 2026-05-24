
# Rust-Toolchain to Manifest

![Static Badge](https://img.shields.io/badge/FlakeHub-030712?style=for-the-badge&logo=NixOS&logoColor=75b1d9)

Generates a url for downloading the rustup manifest for a given rust
toolchain. The toolchain is provided directly, as it would appear in
a project's `rust-toolchain.toml` file.

For more information on the toolchain channel, see:
https://rust-lang.github.io/rustup/overrides.html#channel

## Quickstart

```
Usage: toolchain-to-manifest <TOOLCHAIN>

Arguments:
  <TOOLCHAIN>
          The `toolchain.channel` value of a `rust-toolchain.toml` file
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

