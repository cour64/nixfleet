{
  flake.modules.nixos.nvidia =
    { lib, pkgs, ... }:
    {
      # AMD iGPU drives the internal panel; NVIDIA is used on demand via offload.
      boot.kernelModules = [ "amdgpu" ];
      services.xserver.videoDrivers = [ "nvidia" ];

      hardware.graphics = {
        enable = true;
        extraPackages = [ pkgs.nvidia-vaapi-driver ];
      };

      hardware.nvidia = {
        modesetting.enable = true;
        # Ampere (RTX 30) supports the open kernel module.
        open = true;
        nvidiaSettings = true;
        dynamicBoost.enable = true;
        # Saves VRAM across suspend; needed for Hyprland to wake the panel.
        powerManagement.enable = true;

        prime = {
          offload.enable = true;
          offload.enableOffloadCmd = true;
          nvidiaBusId = "PCI:1:0:0";
          # Common on Legion AMD hybrids. Extra NVMe drives often move the iGPU
          # to PCI:6:0:0 — override on the host after `lspci -d ::03xx`.
          amdgpuBusId = lib.mkDefault "PCI:5:0:0";
        };
      };
    };
}
