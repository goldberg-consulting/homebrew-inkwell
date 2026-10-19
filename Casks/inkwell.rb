cask "inkwell" do
  version "0.5.3"
  sha256 "68f180c0e5368521bc3452e5278b797266914c407bc3fedc60a37eb3034e2aac"

  url "https://github.com/goldberg-consulting/measured.one.inkwell-extension/releases/download/v#{version}/inkwell-#{version}.vsix"
  name "Inkwell"
  container type: :naked
  desc "Markdown to publication-quality PDF with live preview, Pandoc + LaTeX compilation, and runnable code blocks"
  homepage "https://github.com/goldberg-consulting/measured.one.inkwell-extension"

  depends_on formula: "pandoc"
  depends_on formula: "pandoc-crossref"
  depends_on formula: "node"

  installer script: {
    executable: "/bin/bash",
    args:       ["-c", <<~SH, "--", "#{staged_path}", version.to_s, "#{HOMEBREW_PREFIX}/bin/node"],
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
