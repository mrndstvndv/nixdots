{ lib, stdenvNoCC, fetchurl }:
let
  sources = {
    aarch64-darwin = {
      url = "https://dl.google.com/android/cli/latest/darwin_arm64/android";
      hash = "sha256-Af0vUXVs8/+0iXOfg8uCsubm/6mo64/mzrISJOm6eYk=";
    };

    x86_64-linux = {
      url = "https://dl.google.com/android/cli/latest/linux_x86_64/android";
      hash = "sha256-YGTY6Vgol5i1A0ggFbRyUx0I4oXxftslkS7Pa+pyg7w=";
    };
  };

  hostSystem = stdenvNoCC.hostPlatform.system;
  source = sources.${hostSystem} or (throw "android-cli is unsupported on ${hostSystem}");
in
stdenvNoCC.mkDerivation {
  pname = "android-cli";
  version = "unstable-2026-04-19";

  src = fetchurl source;
  dontUnpack = true;

  installPhase = ''
    runHook preInstall
    install -Dm755 "$src" "$out/bin/android"
    runHook postInstall
  '';

  meta = with lib; {
    description = "Google Android CLI binary";
    homepage = "https://developer.android.com/";
    license = licenses.unfree;
    mainProgram = "android";
    platforms = builtins.attrNames sources;
    sourceProvenance = [ sourceTypes.binaryNativeCode ];
  };
}
