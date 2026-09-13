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
          # TS 7 (tsgo) on PATH: omp's LSP picks its typescript-native server
          # (tsc --lsp --stdio) whenever no project-local TypeScript shadows
          # the PATH fallback; TS7-pinned projects resolve it on their own.
          # Unstable renamed typescript-go -> typescript (7.x is the native
          # tsgo build there; 26.05's pkgs.typescript is still 5.9.3).
          unstable.typescript
          # omp's browser prelude resolves, in order: google-chrome-stable,
          # google-chrome, chromium, chromium-browser, chrome.
          google-chrome
          # oxc toolchain: LSP registered in modules/omp/lsp.json
          # (oxlint --lsp, stdio); activates in projects with .oxlintrc.json.
          # Unstable pins a much newer oxlint than 26.05 (1.80.0 vs 1.65.0).
          unstable.oxlint
          # NixOS/nixpkgs/home-manager options MCP for omp
          # (registered in modules/omp/mcp.json).
          mcp-nixos
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
