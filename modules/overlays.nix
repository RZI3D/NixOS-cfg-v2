{ self, inputs, lib,  ... }:
{
  flake.overlays.patched-pkgs = final: prev: {
  # Custom LLVM without AVX support (using LLVM 18 to reduce rebuild size)
# llvm-noavx = final.llvmPackages_18.llvm.overrideAttrs (old: {
#   cmakeFlags = (old.cmakeFlags or []) ++ [
#     "-DLLVM_TARGETS_TO_BUILD=X86"
#     "-DLLVM_ENABLE_ASSERTIONS=OFF"
#     "-DLLVM_BUILD_BENCHMARKS=OFF"
#     "-DLLVM_INCLUDE_TESTS=OFF"
#     "-DLLVM_BUILD_TESTS=OFF"
#     "-DPOLLY_BUILD_TESTS=OFF"
#     "-DPOLLY_ENABLE_GTEST=OFF"
#     "-DLLVM_ENABLE_PROJECTS=clang;lld;polly"  # keep only what we need
#   ];
#
#   NIX_CFLAGS_COMPILE = "-march=westmere -mno-avx -mno-avx2 -mno-fma -mno-sse4.1 -mno-sse4.2";
#   NIX_CXXFLAGS_COMPILE = "-march=westmere -mno-avx -mno-avx2 -mno-fma -mno-sse4.1 -mno-sse4.2";
#
#   env = {
#     CMAKE_C_FLAGS = "-march=westmere -mno-avx -mno-avx2 -mno-fma -mno-sse4.1 -mno-sse4.2";
#     CMAKE_CXX_FLAGS = "-march=westmere -mno-avx -mno-avx2 -mno-fma -mno-sse4.1 -mno-sse4.2";
#   };
#
#   # Completely disable check phase
#   doCheck = false;
#   checkPhase = "true";   # ← This skips tests
# });

  zluda-custom = final.rustPlatform.buildRustPackage {
    pname = "zluda";
    version = "git-c901d";
    src = final.fetchFromGitHub {
      owner = "vosen";
      repo = "ZLUDA";
      rev = "996bac542cc553f00b79543d196fb0df93dc901d";
      hash = "sha256-t9y/E50v01jZWcnhgp5Bg+uG5MShjL6T5oCzQ0A0/n8=";
      fetchSubmodules = true;
      fetchLFS = true;
    };
    cargoHash = "sha256-HmvT8RHG8f4Qnj+lfW8f/xkoraZQ100CYLQ/0gN/gcA=";

    buildInputs = [
      final.rocmPackages.clr
      final.rocmPackages.rocm-comgr
      #final.llvm-noavx
    ];

    nativeBuildInputs = (final.zluda.nativeBuildInputs or []);

    doCheck = false;

    RUSTFLAGS = "-C target-cpu=westmere -C target-feature=-avx,-avx2,-fma,-bmi,-bmi2,-sse4.1,-sse4.2";

    env = {
      CARGO_BUILD_TARGET = final.stdenv.hostPlatform.rust.cargoShortTarget;
      CMAKE_BUILD_TYPE = "Release";
      ZLUDA_BUNDLED_LLVM = "1";
      LLVM_DIR = "";  # empty to avoid system one
      #LLVM_DIR = "${final.llvm-noavx}/lib/cmake/llvm";
      CMAKE_C_FLAGS = "-march=westmere -mno-avx -mno-avx2 -mno-fma -mno-sse4.1 -mno-sse4.2";
      CMAKE_CXX_FLAGS = "-march=westmere -mno-avx -mno-avx2 -mno-fma -mno-sse4.1 -mno-sse4.2";
    };

    preConfigure = ''
      rm zluda_inject/tests/inject.rs || true
      export CFLAGS="-march=westmere -mno-avx -mno-avx2 -mno-fma -mno-sse4.1 -mno-sse4.2"
      export CXXFLAGS="$CFLAGS"
    '';

    buildPhase = ''
      runHook preBuild
      cargo xtask --release
      runHook postBuild
    '';

    preInstall = ''
      mkdir -p $out/lib/
      find target/release/ -maxdepth 1 -type l -name '*.so*' -exec \
        cp --recursive --no-clobber --target-directory=$out/lib/ {} +
    '';

    meta = final.zluda.meta or {};
  };


    # openbubbles-app = inputs.openbubbles-app.packages.${final.system}.openbubbles-app;

    freyr-js = inputs.freyr-js.packages.${final.system}.freyr-js;

    colloid-catppuccin =
      let
        paletteSrc = builtins.path {
          path = self + "/pkgs/colloid-catppuccin/_color-palette-catppuccin.scss";
          name = "colloid-catppuccin-palette";
        };
        colloid-patched = prev.colloid-gtk-theme.overrideAttrs (old: {
          postPatch = (old.postPatch or "") + ''
            cp ${paletteSrc} src/sass/_color-palette-catppuccin.scss
          '';
        });
      in
      colloid-patched.override {
        tweaks = [ "catppuccin" ];
        colorVariants = [ "dark" ];
      };

    qt6ct-kde = prev.qt6Packages.qt6ct.overrideAttrs (old: {
      patches = (old.patches or [ ]) ++ [
        (builtins.path {
          path = "${self}/pkgs/qt6ct-kde/qt6ct-kde.patch";
          name = "qt6ct-kde.patch";
        })
      ];
    });
  };
}
