{
  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";
    nixpkgs.url = "github:NixOS/nixpkgs/25.11";
    mlib.url = "github:MaxTheMooshroom/mlib.nix";

    rust-overlay.url  = "github:oxalica/rust-overlay/a6cb2224d975e16b5e67de688c6ad306f7203425";

    toolchain = { flake = false; url = ./rust-toolchain.toml; };
  };

  outputs = { self, flake-parts, ... }@inputs:
    flake-parts.lib.mkFlake { inherit inputs; } ({ lib, ... }: {
      systems = lib.systems.flakeExposed;

      imports = [(inputs.mlib.flakeModules.perSystem-packageSets)];

      perSystem = { system, self', pkgs, dependencies, rust-bins, rustPlatform, ... }: {
        _module.args = {
          inherit (self'.packageSets) dependencies;
          inherit (self'.packageSets.dependencies)
            rust-bins
            rustPlatform
            ;
        };

        packageSets = {
          dependencies = inputs.mlib.lib.callPackageSetWith pkgs (
            finalAttrs: {}: {
              rust-bins =
                (inputs.rust-overlay.lib.mkRustBin {} pkgs)
                .fromRustupToolchainFile inputs.toolchain;

              rustPlatform = pkgs.makeRustPlatform {
                rustc = finalAttrs.rust-bins;
                cargo = finalAttrs.rust-bins;
              };

              cargoVendored = finalAttrs.rustPlatform.importCargoLock {
                lockFile = ./Cargo.lock;
              };
            }
          );
        };

        packages = {
          default = self'.packages.toolchain2manifest;

          toolchain2manifest = rustPlatform.buildRustPackage (self': {
            pname = "toolchain-to-manifest";
            version = "0.2.0";

            src = ./.;
            cargoDeps = dependencies.cargoVendored;

            meta = {
              mainProgram = self'.pname;
              license = lib.licenses.mit;
            };
          });
        };

        devShells.default = pkgs.mkShell {
          packages = [ rust-bins ];
        };

        checks = {
          default = self'.checks.toolchain2manifest;

          toolchain2manifest = pkgs.stdenvNoCC.mkDerivation {
            name = "toolchain2manifest-check";
            src = ./.;
            nativeBuildInputs = [ rust-bins ];
            buildPhase = ''
              runHook preBuild

              cargo \
                  --config 'source.crates-io.replace-with="vendored-sources"' \
                  --config 'source.vendored-sources.directory="${
                    dependencies.cargoVendored
                  }"' \
                  check --frozen --profile release

              runHook postBuild
            '';
            installPhase = "touch $out";
            doCheck = false;
          };
        };
      };
    });
}
