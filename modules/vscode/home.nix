{ pkgs, ... }:
{
  home.packages = with pkgs; [
    nixd
    nixfmt-rfc-style
  ];

  programs.neovim.enable = true;
  programs.vscode = {
    enable = true;
    package = pkgs.vscode;
    profiles = {
      default = {
        extensions = with pkgs.vscode-marketplace; [
          enkia.tokyo-night
          pkief.material-icon-theme
          jnoortheen.nix-ide
          oderwat.indent-rainbow
          ms-vscode-remote.remote-containers
          ms-azuretools.vscode-docker
          docker.docker
          asvetliakov.vscode-neovim
          naumovs.color-highlight
          ms-python.python
          charliermarsh.ruff
          ms-pyright.pyright
          editorconfig.editorconfig
        ];
        userSettings = {
          # Editor
          "editor.formatOnSave" = true;
          "editor.lineNumbers" = "relative";
          "editor.tabSize" = 2;
          "editor.fontSize" = 14;
          "editor.fontFamily" = "'Monaspace Neon', monospace";
          "editor.inlineSuggest.fontFamily" = "'Monaspace Krypton', monospace";
          "editor.fontLigatures" = true;
          "editor.fontVariations" = true;
          "editor.minimap.enabled" = false;
          "editor.stickyScroll.enabled" = true;
          "editor.bracketPairColorization.independentColorPoolPerBracketType" = true;
          "editor.inlayHints.enabled" = "offUnlessPressed";

          # Misc
          "workbench.iconTheme" = "material-icon-theme";
          "workbench.colorTheme" = "Tokyo Night";
          "workbench.sideBar.location" = "right";
          "telemetry.telemetryLevel" = "off";
          "diffEditor.renderSideBySide" = false;
          "diffEditor.ignoreTrimWhitespace" = false;

          # Terminal
          "terminal.integrated.fontFamily" = "'Monaspace Neon', monospace";
          "terminal.integrated.defaultProfile.osx" = "zsh";
          "terminal.external.osxExec" = "ghostty";

          # Indent Rainbox
          "indentRainbow.indicatorStyle" = "light";
          "indentRainbow.lightIndicatorStyleLineWidth" = 3;

          # Javascript
          "javascript.inlayHints.functionLikeReturnTypes.enabled" = true;
          "javascript.inlayHints.enumMemberValues.enabled" = true;
          "javascript.inlayHints.parameterNames.enabled" = "all";
          "javascript.inlayHints.variableTypes.enabled" = true;
          "javascript.inlayHints.propertyDeclarationTypes.enabled" = true;
          "javascript.inlayHints.parameterTypes.enabled" = true;

          # Typescript
          "typescript.check.npmIsInstalled" = false;
          "typescript.disableAutomaticTypeAcquisition" = true;
          "typescript.locale" = "en";
          "typescript.preferences.importModuleSpecifierEnding" = "js";
          "typescript.preferences.preferTypeOnlyAutoImports" = true;
          "typescript.preferences.importModuleSpecifier" = "relative";
          "typescript.tsserver.maxTsServerMemory" = 4096;
          "typescript.updateImportsOnFileMove.enabled" = "always";
          "typescript.inlayHints.parameterNames.enabled" = "all";
          "typescript.inlayHints.parameterTypes.enabled" = true;
          "typescript.inlayHints.variableTypes.enabled" = true;
          "typescript.inlayHints.parameterNames.suppressWhenArgumentMatchesName" = false;
          "typescript.inlayHints.enumMemberValues.enabled" = true;

          # Gitlens
          "gitlens.views.scm.grouped.views" = {
            "commits" = true;
            "branches" = true;
            "remotes" = true;
            "stashes" = false;
            "tags" = true;
            "worktrees" = true;
            "contributors" = true;
            "repositories" = false;
            "searchAndCompare" = false;
            "launchpad" = false;
          };

          # Neovim
          "extensions.experimental.affinity" = {
            "asvetliakov.vscode-neovim" = 1;
          };
        };
      };
    };
  };
}
