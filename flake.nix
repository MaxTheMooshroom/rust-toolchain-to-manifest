{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/26.05";

    flake-parts.url = "github:hercules-ci/flake-parts";
    flake-parts.inputs.nixpkgs-lib.follows = "nixpkgs";

    mlib.url = "github:MaxTheMooshroom/mlib.nix";
    mlib.inputs.flake-parts.follows = "flake-parts";

    rust-overlay.url  = "github:oxalica/rust-overlay/a6cb2224d975e16b5e67de688c6ad306f7203425";
  };

  outputs =
    { ... }@inputs:
    inputs.mlib.lib.mkFlake
      { inherit inputs; }
      (
        { lib, mlib, ... }:
        {
          systems = lib.systems.flakeExposed;

          imports = [ inputs.mlib.flakeModules.perSystem-packageSets ];

          perSystem =
            { self', pkgs, dependencies, rust-bins, rustPlatform, ... }:
            {
              _module.args =
                {
                  inherit (self'.packageSets) dependencies;
                  inherit (self'.packageSets.dependencies)
                    rust-bins
                    rustPlatform
                    ;
                };

              packageSets =
                {
                  dependencies =
                    mlib.callPackageSetWith
                      pkgs
                        (
                          finalAttrs: {}:
                          {
                            rust-bins =
                              (inputs.rust-overlay.lib.mkRustBin {} pkgs)
                              .fromRustupToolchainFile ./rust-toolchain.toml;

                            rustPlatform =
                              pkgs.makeRustPlatform
                                {
                                  rustc = finalAttrs.rust-bins;
                                  cargo = finalAttrs.rust-bins;
                                };

                            cargoVendored =
                              finalAttrs.rustPlatform.importCargoLock
                                {
                                  lockFile = ./Cargo.lock;
                                };
                          }
                        );
                };

              packages =
                {
                  default = self'.packages.toolchain2manifest;

                  toolchain2manifest =
                    rustPlatform.buildRustPackage
                      (
                        self':
                        {
                          pname = "toolchain-to-manifest";
                          version = "0.2.0";

                          src = ./.;
                          cargoDeps = dependencies.cargoVendored;

                          meta =
                            {
                              mainProgram = self'.pname;
                              license = lib.licenses.mit;
                            };
                        }
                      );
                };

              devShells.default =
                pkgs.mkShell
                  {
                    packages = [ rust-bins ];
                  };

              checks =
                {
                  default = self'.checks.toolchain2manifest;

                  toolchain2manifest =
                    pkgs.stdenvNoCC.mkDerivation
                      {
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
        }
      );
}
