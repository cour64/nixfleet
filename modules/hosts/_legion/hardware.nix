{
  config,
  lib,
  modulesPath,
  ...
}:
{
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

  boot.initrd.availableKernelModules = [
    "nvme"
    "xhci_pci"
    "thunderbolt"
    "usbhid"
    "usb_storage"
    "sd_mod"
  ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-amd" ];
  boot.extraModulePackages = [ ];

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/a69a620e-df5e-4171-87b4-dd0f64f00977";
    fsType = "ext4";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/F055-D958";
    fsType = "vfat";
    options = [
      "fmask=0077"
      "dmask=0077"
    ];
  };

  swapDevices = [ ];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

  # linux-firmware 20260910 ships a broken yellow_carp_dmcub.bin (0x0400004A):
  # PSP rejects it at boot -> "failed to load ucode DMCUB" + endless
  # "DMCUB error - collecting diagnostic data" spam on this Rembrandt iGPU.
  # Pin the previous release whose blob (0x0400004C) loads cleanly.
  # Remove once nixpkgs ships linux-firmware with the yellow_carp_dmcub revert.
  nixpkgs.overlays = [
    (final: prev: {
      linux-firmware = prev.linux-firmware.overrideAttrs (o: {
        version = "20260810";
        src = prev.fetchurl {
          url = "https://gitlab.com/api/v4/projects/kernel-firmware%2Flinux-firmware/repository/archive.tar.gz?sha=refs%2Ftags%2F20260810";
          hash = "sha256-E5HOo4xgBtFe3dL2AkSKnKFDP+9kTO7p8+vHFbkRNmM=";
        };
      });
    })
  ];
}
