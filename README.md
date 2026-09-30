# Choose AI CLI

Choose AI in your terminal: a coding agent that works in the folder you start it in. It reads your project, proposes changes as diffs, and only writes them with your yes. Replies stream as they're written.

## Install

```sh
curl -fsSL https://raw.githubusercontent.com/markisthebest1234567-ctrl/Choose-AI-CLI/main/install.sh | bash
```

This needs macOS 13 or later, on Apple silicon or Intel. It installs `choose-ai` into `/usr/local/bin`, asking for your password only if that folder needs it. The installer checks each download against the release's SHA-256 checksums and refuses anything that doesn't match.

Options: `CHOOSEAI_VERSION=v1.0.0` installs a specific release, and `CHOOSEAI_INSTALL_DIR=~/bin` installs somewhere else.

## Start

```sh
cd your-project
choose-ai
```

Then type `/login` to sign in with Google in your browser. The terminal unlocks with a paid Choose AI plan.

- **Ask for things:** type what you want done in plain words.
- **Commands:** `/help` lists all of them, including `/model`, `/effort`, `/review`, `/code-review`, `/undo` and `/usage`.
- **Attach files:** `@path/to/file` sends that file with your prompt.
- **Stop or leave:** Ctrl-C stops a reply, and `/exit` leaves.

## Update and uninstall

- **Update:** run the install command again.
- **Uninstall:** `rm /usr/local/bin/choose-ai`. To also delete your settings, sign-in and saved conversations: `rm -rf ~/.chooseai`.

## Help

Type `/doctor` inside the app to check your setup, and `/bug` to write a report you can send. Email: supportartificialironstudios@gmail.com
