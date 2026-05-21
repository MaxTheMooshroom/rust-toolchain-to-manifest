use clap::Parser;

use std::path::{Path, PathBuf};

/// Generates a manifest-url from either a toolchain's channel-string
/// or a project's `rust-toolchain.toml` file.
///
/// For more information on the toolchain channel, see:
/// https://rust-lang.github.io/rustup/overrides.html#channel
///
#[derive(Parser)]
#[command(version, about)]
enum Cli {
    /// The `toolchain.channel` value of a `rust-toolchain.toml` file.
    String {
        /// The `toolchain.channel` value of a `rust-toolchain.toml` file.
        toolchain_string: String,
    },
    /// A path to a `rust-toolchain.toml` file.
    File {
        /// A path to a `rust-toolchain.toml` file.
        toolchain_file: PathBuf,
    },
}

fn read_manifest_channel(s: &Path) -> String {
    #[derive(serde::Deserialize)]
    pub struct ToolchainToml {
        toolchain: ToolchainSpec,
    }

    #[derive(serde::Deserialize)]
    pub struct ToolchainSpec {
        channel: String,
    }

    let contents = std::fs::read_to_string(s).unwrap();
    let toolchain_file: ToolchainToml =
        toml::from_str(&contents).expect("Failed to parse channel from rust-toolchain.toml");

    toolchain_file.toolchain.channel
}

fn channel_to_manifest_url(channel: &str) -> String {
    use rustup_toolchain_manifest::Toolchain;

    use std::str::FromStr;

    Toolchain::from_str(channel)
        .unwrap_or_else(|_| panic!("Invalid toolchain channel string: {}", channel))
        .manifest_url()
}

fn main() {
    let toolchain_str = match Cli::parse() {
        Cli::String { toolchain_string } => toolchain_string,
        Cli::File { toolchain_file } => read_manifest_channel(&toolchain_file),
    };

    print!("{}", channel_to_manifest_url(&toolchain_str));
}
