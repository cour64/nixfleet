let
  packages =
    { pkgs, ... }:
    {
      environment.systemPackages = with pkgs; [
        coreutils
        ffmpeg
      ];
    };
in
{
  flake.modules.darwin.packages = packages;
  flake.modules.nixos.packages = packages;

  flake.modules.homeManager.packages =
    { pkgs, lib, ... }:
    {
      home.packages =
        with pkgs;
        [
          tree
          wget
          curl
          jq
          _7zz
          # Not backported to 26.05; merged into unstable on 2026-08-25.
          unstable.tuicr
          # TS 7 (tsgo) on PATH: provides a typescript-native LSP server
          # (tsc --lsp --stdio) as a PATH fallback; TS7-pinned projects
          # resolve it on their own.
          # Unstable renamed typescript-go -> typescript (7.x is the native
          # tsgo build there; 26.05's pkgs.typescript is still 5.9.3).
          unstable.typescript
          google-chrome
          # oxc toolchain: oxlint language server (oxlint --lsp, stdio).
          # Unstable pins a much newer oxlint than 26.05 (1.80.0 vs 1.65.0).
          unstable.oxlint
          # NixOS/nixpkgs/home-manager/darwin options search MCP.
          mcp-nixos
          # pi-lens nix LSP server (edit tooling in nixfleet modules).
          nixd
        ]
        ++ lib.optionals pkgs.stdenv.hostPlatform.isDarwin [
          gum
          hostctl
        ];

      # Stable nixpkgs lags upstream; take gh and its extensions from unstable.
      programs.gh = {
        enable = true;
        package = pkgs.unstable.gh;
        extensions = [ pkgs.unstable.gh-stack ];
      };
    };
}
