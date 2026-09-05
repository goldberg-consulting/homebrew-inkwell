cask "inkwell" do
  version "0.4.0"
  sha256 "b1ca9f781ecb6026a6596d028d0ca89123f073d2cd7581413ff403dec866d52e"

  url "https://github.com/goldberg-consulting/measured.one.inkwell-extension/releases/download/v#{version}/inkwell-#{version}.vsix"
  name "Inkwell"
  container type: :naked
  desc "Markdown to publication-quality PDF with live preview, Pandoc + LaTeX compilation, and runnable code blocks"
  homepage "https://github.com/goldberg-consulting/measured.one.inkwell-extension"

  depends_on formula: "pandoc"
  depends_on formula: "pandoc-crossref"
  depends_on cask: "mactex"

  artifact "inkwell-#{version}.vsix", target: "#{HOMEBREW_PREFIX}/share/inkwell/inkwell-#{version}.vsix"

  postflight do
    cursor_paths = ["/opt/homebrew/bin/cursor", "/usr/local/bin/cursor", "#{Dir.home}/.local/bin/cursor"]
    code_paths = ["/opt/homebrew/bin/code", "/usr/local/bin/code"]
    editor = (cursor_paths.find { |p| File.exist?(p) }) || (code_paths.find { |p| File.exist?(p) })

    if editor
      system_command editor,
                     args: ["--install-extension", "#{staged_path}/inkwell-#{version}.vsix", "--force"],
                     print_stderr: true
    else
      ohai "Neither cursor nor code CLI found on PATH."
      ohai "Install the extension manually: open Cursor/VS Code, Cmd+Shift+P, 'Extensions: Install from VSIX', select #{HOMEBREW_PREFIX}/share/inkwell/inkwell-#{version}.vsix"
    end
  end

  uninstall_postflight do
    cursor_paths = ["/opt/homebrew/bin/cursor", "/usr/local/bin/cursor", "#{Dir.home}/.local/bin/cursor"]
    code_paths = ["/opt/homebrew/bin/code", "/usr/local/bin/code"]
    editor = (cursor_paths.find { |p| File.exist?(p) }) || (code_paths.find { |p| File.exist?(p) })

    if editor
      system_command editor,
                     args: ["--uninstall-extension", "measure-one.inkwell"],
                     print_stderr: true
    end
  end

  caveats <<~EOS
    Inkwell has been installed in Cursor/VS Code.

    To complete setup:
      1. Reload the editor (Cmd+Shift+P > Developer: Reload Window)
      2. Run: Inkwell: Check / Install Toolchain
      3. For Mermaid diagram support in PDFs:
           npm install -g @mermaid-js/mermaid-cli
  EOS
end
