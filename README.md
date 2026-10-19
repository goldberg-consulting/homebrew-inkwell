# Homebrew Tap for Inkwell

Inkwell brings Markdown, live previews, runnable analysis, citations, and PDF templates to Cursor and VS Code.

## Install

```sh
brew install --cask goldberg-consulting/inkwell/inkwell
```

The cask installs the same verified VSIX available from [GitHub Releases](https://github.com/goldberg-consulting/measured.one.inkwell-extension/releases). It uses Inkwell's shared installer to select an installed editor, check the PDF toolchain, and compile a verification PDF. If both editors are installed, Cursor is selected by default.

Setup preserves a working TeX installation and installs MacTeX when no TeX installation exists. It installs missing PDF tools and Mermaid support as needed. A first setup may ask for the administrator password when system packages are required.

Reload the editor and choose **Inkwell: New Project** to begin.

## Upgrade

```sh
brew update
brew upgrade --cask goldberg-consulting/inkwell/inkwell
```

## Uninstall

```sh
brew uninstall --cask goldberg-consulting/inkwell/inkwell
```

Removal uses Inkwell's version-aware editor uninstaller. Projects, documents, bibliographies, scripts, history, PDFs, and shared PDF tools are preserved.

## Requirements

- macOS and [Homebrew](https://brew.sh)
- [Cursor](https://cursor.com) or [VS Code](https://code.visualstudio.com)

## Maintainer checks

```sh
node --test tests/lifecycle.test.cjs
brew style --cask goldberg-consulting/inkwell/inkwell
brew audit --cask goldberg-consulting/inkwell/inkwell
```

The lifecycle tests execute the cask's actual commands with a fixture VSIX and mocked shared installer. They check argument handling, error propagation, and that the cask wrapper does not remove user files. Release validation must also exercise the real packaged installer and a clean editor profile.
