cask "inkwell" do
  version "0.5.3"
  sha256 "e9121d2d3a4797b283442efbdc82ef19dc992c5ee4c2d92fa412d64b4c3e7baa"

  url "https://github.com/goldberg-consulting/measured.one.inkwell-extension/releases/download/v#{version}/inkwell-#{version}.vsix"
  name "Inkwell"
  desc "Markdown editor extension with live preview, runnable code, and PDF publishing"
  homepage "https://github.com/goldberg-consulting/measured.one.inkwell-extension"

  depends_on formula: "node"
  depends_on formula: "pandoc"
  depends_on formula: "pandoc-crossref"
  container type: :naked

  installer script: {
    executable: "/bin/bash",
    args:       ["-c", <<~SH, "--", staged_path.to_s, version.to_s, "#{HOMEBREW_PREFIX}/bin/node"],
      set -euo pipefail
      /usr/bin/unzip -q -o "$1/inkwell-$2.vsix" -d "$1/payload"
      exec "$3" "$1/payload/extension/out/install-cli.js" \
        "--vsix=$1/inkwell-$2.vsix" "--version=$2" --editor=auto --profile=full --yes
    SH
    sudo:       false,
  }

  uninstall script: {
    executable:   "#{HOMEBREW_PREFIX}/bin/node",
    args:         ["#{staged_path}/payload/extension/out/install-cli.js",
                   "--vsix=#{staged_path}/inkwell-#{version}.vsix", "--version=#{version}",
                   "--editor=all", "--uninstall"],
    sudo:         false,
    must_succeed: true,
  }

  caveats <<~EOS
    Reload Cursor or VS Code, then run Inkwell: New Project.
    Setup preserves an existing working TeX installation and installs MacTeX when needed.
    Uninstall removes this extension version and keeps your projects and documents.
  EOS
end
