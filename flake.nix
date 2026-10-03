{
  description = "Brendan's dendritic Nix system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-26.05-darwin";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    nix-darwin.url = "github:LnL7/nix-darwin/nix-darwin-26.05";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";

    home-manager.url = "github:nix-community/home-manager/release-26.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    nix-homebrew.url = "github:zhaofengli/nix-homebrew";

    # Pin the cached branch so Cachix hits; following nixpkgs would miss the cache.
    noctalia.url = "github:noctalia-dev/noctalia/cachix";
    noctalia-greeter.url = "github:noctalia-dev/noctalia-greeter";

    # Herdr is built from upstream's source in modules/herdr.nix rather than
    # via its packages output: its flake pins nixos-unstable, whose crate
    # fetcher hits the crates.io API endpoint that 403s Nix's curl User-Agent
    # (26.05 already fetches from static.crates.io).
    herdr.url = "github:herdrdev/herdr/v0.8.2";
    herdr.inputs.nixpkgs.follows = "nixpkgs";

    # Pins the Rust toolchain herdr's rust-toolchain.toml requests.
    rust-overlay.url = "github:oxalica/rust-overlay";
    rust-overlay.inputs.nixpkgs.follows = "nixpkgs";

    flake-parts.url = "github:hercules-ci/flake-parts";
    flake-parts.inputs.nixpkgs-lib.follows = "nixpkgs";

    import-tree.url = "github:vic/import-tree";
  };

  # So the first rebuild can use Cachix; nix.settings in the NixOS module only
  # lands in nix.conf after that switch. Accept once with --accept-flake-config
  # if Nix asks.
  nixConfig = {
    extra-substituters = [ "https://noctalia.cachix.org" ];
    extra-trusted-public-keys = [
      "noctalia.cachix.org-1:pCOR47nnMEo5thcxNDtzWpOxNFQsBRglJzxWPp3dkU4="
    ];
  };

  outputs = inputs: inputs.flake-parts.lib.mkFlake { inherit inputs; } (inputs.import-tree ./modules);
}
