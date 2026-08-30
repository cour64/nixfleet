{ inputs, ... }:
{
  flake.modules.homeManager.herdr =
    { pkgs, ... }:
    let
      # Built from upstream's source against our nixpkgs instead of using the
      # input's packages output, which targets herdr's pinned nixpkgs (see
      # flake.nix). rust-overlay is scoped to this package only, and the Rust
      # toolchain stays pinned via rust-toolchain.toml.
      pkgs' = pkgs.extend inputs.rust-overlay.overlays.default;
      rustToolchain = pkgs'.rust-bin.fromRustupToolchainFile (inputs.herdr + "/rust-toolchain.toml");
      herdr = pkgs'.callPackage (inputs.herdr + "/nix/package.nix") {
        rustPlatform = pkgs'.makeRustPlatform {
          cargo = rustToolchain;
          rustc = rustToolchain;
        };
      };
    in
    {
      home.packages = [ herdr ];

      # herdr is Nix-managed, so updates come from `nix flake update herdr` +
      # rebuild; do not use `herdr update`. config.toml is left unmanaged on
      # purpose: herdr writes to it (onboarding flag, settings UI), which a
      # store-backed symlink would block.
    };
}
