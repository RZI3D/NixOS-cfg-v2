{ lib, pkgs, ... }:

pkgs.rustPlatform.buildRustPackage (finalAttrs: {
  pname = "iloader";
  version = "2.3.3";

  src = pkgs.fetchFromGitHub {
    owner = "nab138";
    repo = "iloader";
    rev = "v${finalAttrs.version}";
    hash = "sha256-FpWX9m5WtTYTXueKX41RP1Zhyf5UuuhrSIYITq+g+Ew=";
  };

  nodeModules = pkgs.stdenv.mkDerivation {
    pname = "${finalAttrs.pname}-node_modules";
    inherit (finalAttrs) src version;

    nativeBuildInputs = with pkgs; [
      bun
      writableTmpDirAsHomeHook
    ];

    dontConfigure = true;

    buildPhase = ''
      runHook preBuild
      bun install \
        --cpu="*" \
        --frozen-lockfile \
        --ignore-scripts \
        --no-progress \
        --os="*"
      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall
      mkdir -p $out
      cp -r node_modules $out/node_modules
      runHook postInstall
    '';

    outputHash = "sha256-UTNnOm1BRVuz7x8Vrxv/WL7N6Cyi8VxYusAXFpCIako=";
    outputHashAlgo = "sha256";
    outputHashMode = "recursive";
  };

  cargoRoot = "src-tauri";
  buildAndTestSubdir = "src-tauri";
  cargoHash = "sha256-te7XB/pkM9s94fUJadCtoOvcB/kEN/U1BwQMWcKPglM=";

  doCheck = false;

  postPatch = ''
    cp -r ${finalAttrs.nodeModules}/node_modules .
    chmod -R +w node_modules
    patchShebangs --build node_modules
  '';

  nativeBuildInputs =
    with pkgs;
    [
      bun
      cargo-tauri.hook
      nodejs
      pkg-config
    ]
    ++ lib.optionals pkgs.stdenv.hostPlatform.isLinux [ pkgs.wrapGAppsHook3 ]
    ++ lib.optionals pkgs.stdenv.hostPlatform.isDarwin [ pkgs.makeWrapper ];

  buildInputs = lib.optionals pkgs.stdenv.hostPlatform.isLinux (
    with pkgs;
    [
      gst_all_1.gstreamer
      gst_all_1.gst-plugins-base
      webkitgtk_4_1
      glib
      glib-networking
      openssl
    ]
  );

  tauriBuildFlags = [
    "--config"
    "ci.conf.json"
    "--no-sign"
  ];

  postInstall = lib.optionalString pkgs.stdenv.hostPlatform.isDarwin ''
    mkdir -p $out/bin
    makeWrapper $out/Applications/iloader.app/Contents/MacOS/iloader $out/bin/iloader
  '';

  meta = with lib; {
    description = "User friendly sideloader";
    homepage = "https://github.com/nab138/iloader";
    license = licenses.mit;
    mainProgram = "iloader";
    platforms = [
      "aarch64-linux"
      "x86_64-linux"
      "aarch64-darwin"
    ];
  };
})
