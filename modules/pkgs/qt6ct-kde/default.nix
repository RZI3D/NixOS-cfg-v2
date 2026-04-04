{ pkgs }:

pkgs.qt6Packages.qt6ct.overrideAttrs (old: {
  patches = (old.patches or [ ]) ++ [ ./qt6ct-kde.patch ];
})
