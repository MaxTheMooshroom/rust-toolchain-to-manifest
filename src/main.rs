use clap::Parser;

/// Generates a manifest-url from either a toolchain's channel-string
/// or a project's `rust-toolchain.toml` file.
///
/// For more information on the toolchain channel, see:
///
/// https://rust-lang.github.io/rustup/overrides.html#channel
///
#[derive(Parser)]
#[command(version, about)]
struct Cli {
    /// The `toolchain.channel` value of a `rust-toolchain.toml` file.
    toolchain: String,
}

fn channel_to_manifest_url(channel: &str) -> String {
    use rustup_toolchain_manifest::Toolchain;

    use std::str::FromStr;

    Toolchain::from_str(channel)
        .unwrap_or_else(|_| panic!("Invalid toolchain channel string: {channel}"))
        .manifest_url()
}

fn main() {
    let Cli { toolchain } = Cli::parse();
    let url: String = channel_to_manifest_url(&toolchain);

    print!("{url}");
}
