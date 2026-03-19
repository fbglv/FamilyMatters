# CLAUDE.md

This repository is managed with **Claude Code** – a framework for running and
testing small, self‑contained projects inside a Git repo.

## ⚙️  Features

- **CLI scripts** are available under the repository root.
- **Unit tests** (if any) are located in `tests/`.
- **Continuous integration** runs on GitHub Actions (see `.github/workflows/`).
- **`claude-code` hooks** are defined in `claude-code-hooks.json`.

## 🚀  Getting Started

```bash
# 1️⃣  Install the prerequisites
#    * Node 20+ (or bun)
#    * exiftool (for `fmmt.sh`)

# 2️⃣  Add the helper script to your shell profile
#    (you can also just run it from the repo root)
#    echo 'export PATH=$PATH:$PWD' >> ~/.bashrc
#    source ~/.bashrc

# 3️⃣  Run the script
fmmt --raw_dir=~/Downloads/raw_photos --proc_dir=~/Pictures/Family
```

## 📦  Development

```bash
# Install dependencies
npm install

# Run tests
npm test

# Lint & format
npm run lint
npm run format
```

## 📄  Contribution Guidelines

1. **Create a new branch** from `master`.
2. Make your changes and run the test suite locally.
3. Push your branch and open a PR.
4. The CI will automatically run the tests and lint checks.

## 📜  License

MIT © [Your Name]
