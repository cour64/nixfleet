{
  flake.modules.homeManager.ssh =
    { pkgs, ... }:
    let
      isDarwin = pkgs.stdenv.hostPlatform.isDarwin;
      identityAgent =
        if isDarwin then
          ''"~/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"''
        else
          "~/.1password/agent.sock";
    in
    {
      programs.ssh = {
        enable = true;
        enableDefaultConfig = false;
        settings."*" = {
          ForwardAgent = false;
          AddKeysToAgent = "no";
          Compression = false;
          ServerAliveInterval = 0;
          ServerAliveCountMax = 3;
          HashKnownHosts = false;
          UserKnownHostsFile = "~/.ssh/known_hosts";
          ControlMaster = "no";
          ControlPath = "~/.ssh/master-%r@%n:%p";
          ControlPersist = "no";
          IdentityAgent = identityAgent;
        };
      };
    };
}
