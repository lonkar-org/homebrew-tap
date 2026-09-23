# lonkar-org/tap

Homebrew formulae for the tools in this org. One of them so far. The repository
is called `homebrew-tap` because that is the name brew expands `lonkar-org/tap`
into, and a repository called `tap` would give you a clone failure with no hint
in it.

```sh
brew tap lonkar-org/tap
brew install tmux-companion
```

That downloads the release archive for your machine, checks it against the
sha256 in the formula, puts `tmux-companion` on PATH and installs the manual
where `man tmux-companion` finds it. Nothing compiles, so it costs the download
and little else.

[tmux-companion](https://github.com/lonkar-org/tmux-companion) is one daemon
behind the tmux status bar, the pickers and the session switcher, so the bar
costs one process spawn per refresh instead of five. It binds no keys and sets
no tmux options on install, so nothing in your config changes until you put a
line there yourself.

**No release is published yet**, and until the first tag the formula carries a
placeholder version and four sha256 lines of sixty-four zeros, so `brew install
tmux-companion` will fail on the checksum. That's the failure I'd rather
have than a formula that installs something nobody verified.

## Upgrading and removing

```sh
brew update && brew upgrade tmux-companion
brew uninstall tmux-companion   # and `brew untap lonkar-org/tap`
```

Saved layouts in `~/.local/state/tmux-companion` and the config in
`~/.config/tmux-companion` stay behind, since brew doesn't own them.

## How the formula stays current

tmux-companion's release workflow has a job that runs after the release is
published: it checks this repository out, downloads `checksums.txt` from the
release, runs `scripts/update-formula.sh`, and commits the new version and the
four sha256 values to `main`. Four archives, one per target, macOS on Apple
silicon and on Intel and Linux on ARM and on x86_64, with the two Linux builds
static against musl so one binary runs on any distribution.

By hand, for a release that predates the automation or one where the job
failed:

```sh
gh release download v0.1.0 --repo lonkar-org/tmux-companion --pattern checksums.txt
./scripts/update-formula.sh v0.1.0 checksums.txt
brew style Formula/tmux-companion.rb
git commit -am "tmux-companion 0.1.0"
```

The script refuses to write anything unless all four archives are listed in
`checksums.txt`, because a half-uploaded release would otherwise leave two real
checksums and two rows of zeros in the formula.

## The token the automation needs

The job authenticates with a secret named `TAP_TOKEN`, set on the
**tmux-companion** repository, not on this one. A workflow's own `GITHUB_TOKEN`
is scoped to the repository it runs in and cannot push here, which is the whole
reason the secret exists.

Make it a fine-grained personal access token, with this repository as its
only resource and `Contents: read and write` as its only permission, then:

```sh
gh secret set TAP_TOKEN --repo lonkar-org/tmux-companion
```

Without it the release still publishes and the formula stays on the previous
version, so the failure is a stale tap rather than a broken release.
