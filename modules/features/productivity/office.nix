{ self, inputs, ... }:
{
  flake.nixosModules.office =
    { ... }:
    {
      home.packages = with pkgs; [
        libreoffice-qt6-fresh

        # Required for spellcheck to actually work
        hunspell
        hunspellDicts.en_US

        kdePackages.okular
      ];
    };
}
