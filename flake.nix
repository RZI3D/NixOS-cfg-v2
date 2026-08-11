{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    import-tree.url = "github:vic/import-tree";

    wrapper-modules.url = "github:BirdeeHub/nix-wrapper-modules";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix4vscode = {
      url = "github:nix-community/nix4vscode";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    catppuccin = {
      url = "github:catppuccin/nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
#     quickshell = {
#       url = "git+https://git.outfoxxed.me/outfoxxed/quickshell";
#       inputs.nixpkgs.follows = "nixpkgs";
#     };

    noctalia.url = "github:noctalia-dev/noctalia/cachix";

    sops-nix.url = "github:Mic92/sops-nix";

    nix-cachyos-kernel.url = "github:xddxdd/nix-cachyos-kernel/release";
    dolphin-overlay.url = "github:RZI3D/dolphin-overlay";
    rzi-shell.url = "github:rzi3d/rzi-shell";
    freyr-js.url = "path:./pkgs/freyr-js";
    spicetify-nix.url = "github:Gerg-L/spicetify-nix";
    nix-minecraft.url = "github:Infinidoge/nix-minecraft";
    nixgl.url = "github:nix-community/nixGL";
    helium-flake.url = "github:oxcl/nix-flake-helium-browser";
    helium-flake.inputs.nixpkgs.follows = "nixpkgs";
    rzi-plotter.url = "path:pkgs/rzi-inkscape-plotter-tools";
    nix-podman-stacks.url = "github:Tarow/nix-podman-stacks";
    playit-nixos-module.url = "github:pedorich-n/playit-nixos-module";
    nix-flatpak.url = "github:gmodena/nix-flatpak/?ref=latest";

  };

  outputs = inputs: inputs.flake-parts.lib.mkFlake { inherit inputs; } (inputs.import-tree ./modules);
}
