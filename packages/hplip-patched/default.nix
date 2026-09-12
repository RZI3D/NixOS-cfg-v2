{ pkgs, ... }:
pkgs.hplip.override {
  withPlugin = true;
  withQt5 = false;
  python3Packages = pkgs.python312Packages;
}
