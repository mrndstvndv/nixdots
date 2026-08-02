# Patched copy of ProducerGuy/homebrew-tap's thermalforge formula.
#
# Upstream problems fixed here:
# 1. `depends_on xcode: ["15.0", :build]` fails on machines with only
#    Command Line Tools installed. The package is pure Swift and builds
#    fine with the CLT toolchain (swift + SDK), so the requirement is
#    dropped.
# 2. The v0.1.0 git tag is missing Scripts/generate-icon.swift and
#    ThermalForge.icns (added to main after the tag), so the icon
#    generation step fails. We ship the prebuilt icon from main as a
#    brew `resource` instead. (upstream issue #3)
# 3. post_install copies the .app to /Applications, which Homebrew's
#    sandbox blocks (Errno::EPERM). The copy is now best-effort with a
#    manual fallback message. (upstream issue #4)
class Thermalforge < Formula
  desc "Fan control for Apple Silicon MacBooks"
  homepage "https://github.com/ProducerGuy/ThermalForge"
  url "https://github.com/ProducerGuy/ThermalForge.git", tag: "v0.1.0"
  license "MIT"

  # Prebuilt app icon from the main branch (v0.1.0 tag has none).
  resource "thermalforge-icon" do
    url "https://raw.githubusercontent.com/ProducerGuy/ThermalForge/main/ThermalForge.icns"
    sha256 "b02695c1d185f6824e048cc97fcf079f721eeee040e44f1879d9f9114740fd71"
  end

  depends_on macos: :sonoma

  def install
    # Build both CLI and menu bar app
    system "swift", "build", "-c", "release", "--disable-sandbox"

    # Install CLI binary
    bin.install ".build/release/thermalforge"

    # v0.1.0 doesn't ship an icns, so stage the prebuilt one
    resource("thermalforge-icon").stage do
      cp "ThermalForge.icns", buildpath/"ThermalForge.icns"
    end

    # Create .app bundle in prefix
    app_dir = prefix/"ThermalForge.app/Contents"
    (app_dir/"MacOS").mkpath
    (app_dir/"Resources").mkpath

    cp ".build/release/ThermalForgeApp", app_dir/"MacOS/ThermalForgeApp"
    cp "ThermalForge.icns", app_dir/"Resources/AppIcon.icns"

    (app_dir/"Info.plist").write <<~PLIST
      <?xml version="1.0" encoding="UTF-8"?>
      <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN"
        "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
      <plist version="1.0">
      <dict>
          <key>CFBundleName</key>
          <string>ThermalForge</string>
          <key>CFBundleDisplayName</key>
          <string>ThermalForge</string>
          <key>CFBundleIdentifier</key>
          <string>com.thermalforge.app</string>
          <key>CFBundleVersion</key>
          <string>#{version}</string>
          <key>CFBundleShortVersionString</key>
          <string>#{version}</string>
          <key>CFBundleExecutable</key>
          <string>ThermalForgeApp</string>
          <key>CFBundleIconFile</key>
          <string>AppIcon</string>
          <key>CFBundlePackageType</key>
          <string>APPL</string>
          <key>LSMinimumSystemVersion</key>
          <string>14.0</string>
          <key>LSUIElement</key>
          <true/>
          <key>NSHighResolutionCapable</key>
          <true/>
      </dict>
      </plist>
    PLIST
  end

  def post_install
    # Copy .app to /Applications so it shows in Spotlight/Finder.
    # Homebrew's sandbox blocks writes outside the prefix (EPERM), so
    # this is best-effort with a manual fallback.
    app_source = prefix/"ThermalForge.app"
    app_dest = Pathname.new("/Applications/ThermalForge.app")

    if app_source.exist?
      begin
        app_dest.rmtree if app_dest.exist?
        cp_r app_source, app_dest
        system "xattr", "-cr", app_dest
        system "mdimport", app_dest
      rescue => e
        opoo "Could not copy ThermalForge.app to /Applications (#{e.message})"
        opoo "Run this manually once:  sudo cp -R #{app_source} /Applications/"
      end
    end

    ohai ""
    ohai "ThermalForge installed!"
    ohai ""
    ohai "One last step — set up the background daemon (one-time):"
    ohai ""
    ohai "  sudo thermalforge install"
    ohai ""
    ohai "Then you're all set:"
    ohai "  • Open from Spotlight: search 'ThermalForge'"
    ohai "  • Open from Finder: Applications > ThermalForge"
    ohai "  • Or from terminal: open /Applications/ThermalForge.app"
    ohai ""
    ohai "Turn on 'Launch at Login' in the menu bar dropdown and it starts automatically."
  end

  def caveats
    <<~EOS
      To finish setup, run once:

        sudo thermalforge install

      This installs the background daemon so the app can control fans without sudo.
    EOS
  end

  test do
    assert_match "Fan control", shell_output("#{bin}/thermalforge --help")
  end
end
