{
  flake.modules.homeManager.git =
    { pkgs, ... }:
    let
      isDarwin = pkgs.stdenv.hostPlatform.isDarwin;
      opSshSign =
        if isDarwin then
          # Where the nix-darwin programs._1password-gui module places the
          # bundle, and the path 1Password documents for macOS. The signing
          # helper has to be the one belonging to the running app, so pointing
          # at the store copy instead risks the agent refusing the request.
          "/Applications/1Password.app/Contents/MacOS/op-ssh-sign"
        else
          "${pkgs._1password-gui}/bin/op-ssh-sign";
    in
    {
      programs.git = {
        enable = true;
        settings = {
          user = {
            name = "Brendan de la Cour";
            email = "brendan.delacour@se.com";
            signingKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPJa3S25gbOWCPHrB22QO1W4GrAMfqTGY3al6Y4q7JZP";
          };
          aliases = {
            prettylog = "log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(r) %C(bold blue)<%an>%Creset' --abbrev-commit --date=relative";
          };
          branch.autosetuprebase = "always";
          color.ui = true;
          core.askPass = "";
          github.user = "cour64";
          push.default = "tracking";
          init.defaultBranch = "main";
          gpg.format = "ssh";
          "gpg \"ssh\"".program = opSshSign;
          commit.gpgsign = true;
        };
      };
    };
}
