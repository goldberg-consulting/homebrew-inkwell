# Homebrew Tap for Inkwell

Inkwell turns markdown into publication-quality PDFs with live preview, Pandoc + LaTeX compilation, runnable code blocks, and journal template management.

## Install

```bash
brew tap goldberg-consulting/inkwell
brew install --cask inkwell
```

This installs:

- The **Inkwell** extension in Cursor or VS Code
- **Pandoc** and **pandoc-crossref**
- **MacTeX** (full TeX distribution with XeLaTeX and pdfLaTeX)

After installation, install Mermaid CLI for diagram support in PDFs:

```bash
npm install -g @mermaid-js/mermaid-cli
```

## Uninstall

```bash
brew uninstall --cask inkwell
```

## Requirements

- macOS 12 (Monterey) or later
- [Homebrew](https://brew.sh)
- [Cursor](https://cursor.com) or [VS Code](https://code.visualstudio.com) with shell command installed (`cursor` or `code` on PATH)

## Links

- [Inkwell extension repository](https://github.com/goldberg-consulting/measured.one.inkwell-extension)
- [Inkwell releases](https://github.com/goldberg-consulting/measured.one.inkwell-extension/releases)
