# The four url lines and the four sha256 lines below are rewritten by
# scripts/update-formula.sh, which tmux-companion's release workflow runs after
# it publishes a release. Sixty-four zeros in a sha256 line mean no release has
# filled that line in yet, so `brew install` fails the checksum rather than
# installing something nobody verified. The version comes from the url, which is
# what `brew audit` wants: a `version` line beside these urls is redundant with
# the tag in them.
class TmuxCompanion < Formula
  desc "One daemon behind the tmux status bar, the pickers and the sessions"
  homepage "https://github.com/lonkar-org/tmux-companion"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/lonkar-org/tmux-companion/releases/download/v0.10.0/tmux-companion-v0.10.0-aarch64-apple-darwin.tar.gz"
      sha256 "0ef6e5a28b93fb43d43861453a0ee95f8249b86acb3aa20956053cd088af2671"
    end
    on_intel do
      url "https://github.com/lonkar-org/tmux-companion/releases/download/v0.10.0/tmux-companion-v0.10.0-x86_64-apple-darwin.tar.gz"
      sha256 "b0722d6c3a941587e5f3fbc1d1dc6c6723f8e92fd27f8c285d19e5b6642387af"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/lonkar-org/tmux-companion/releases/download/v0.10.0/tmux-companion-v0.10.0-aarch64-unknown-linux-musl.tar.gz"
      sha256 "af9749a1bd3891da56724cd7750836f1b518a5c9698c35e5c9a01af647318cd5"
    end
    on_intel do
      url "https://github.com/lonkar-org/tmux-companion/releases/download/v0.10.0/tmux-companion-v0.10.0-x86_64-unknown-linux-musl.tar.gz"
      sha256 "526ebe90885eb1a0de3898d0791ecc190aad0da73deaeafdfa71c306144ea78c"
    end
  end

  def install
    bin.install "tmux-companion"
    # The archive ships the manual beside the binary, so `man tmux-companion`
    # works on a machine that never saw the repository.
    man1.install "tmux-companion.1"
  end

  def caveats
    <<~EOS
      The binary binds no keys and sets no tmux options. For the status bar:

        set -g status-right "#(tmux-companion status-right --branch-max-len 40 \#{pane_current_path})"

      `tmux-companion doctor` prints what a bug report needs.
    EOS
  end

  test do
    # --version prints "tmux-companion <version>+<build stamp>", so the name and
    # the version are both checked and the stamp is ignored.
    assert_match "tmux-companion #{version}", shell_output("#{bin}/tmux-companion --version")

    # The daemon needs a socket and nothing else, and a client that cannot reach
    # one still has to answer for itself rather than hanging.
    assert_match "tmux-companion", shell_output("#{bin}/tmux-companion --help")
  end
end
