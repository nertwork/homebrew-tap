# 🍺 Nertwork Homebrew Tap (`nertwork/tap`)

Official Homebrew formulas for Nertwork open-source tools on macOS (Apple Silicon `arm64` & Intel `x86_64`).

## Available Formulas

| Formula | Version | Description |
| :--- | :--- | :--- |
| **[`bluepill`](https://github.com/nertwork/bluepill)** | `1.1.0` | Headless zero-Electron macOS `chat.db` relay daemon (`bluepill-server`) + built-in Web UI (`http://localhost:1235/web`) + Direct SSH JSON-RPC (`stdio`) for **[BluePill](https://github.com/nertwork/bluepill)** |

## Quick Start

```bash
brew tap nertwork/tap
brew install nertwork/tap/bluepill

# Verify installation & Full Disk Access
bluepill-server --selftest
bluepill-server doctor
bluepill-server status --json

# Start as a persistent background LaunchAgent on port 1235
brew services start nertwork/tap/bluepill
```
