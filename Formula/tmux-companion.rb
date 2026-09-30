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
      url "https://github.com/lonkar-org/tmux-companion/releases/download/v0.6.0/tmux-companion-v0.6.0-aarch64-apple-darwin.tar.gz"
      sha256 "1e82046438171fedeef9284270b0220518d5c7884f1ea77f1ffd3da05a0398c9"
    end
    on_intel do
      url "https://github.com/lonkar-org/tmux-companion/releases/download/v0.6.0/tmux-companion-v0.6.0-x86_64-apple-darwin.tar.gz"
      sha256 "1e3015ea65c1a17d758b7e3f17a4da2e7bce642b5f10365c6d45b24e56cdf087"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/lonkar-org/tmux-companion/releases/download/v0.6.0/tmux-companion-v0.6.0-aarch64-unknown-linux-musl.tar.gz"
      sha256 "ed6b21e5bd8887a27527c3cab2dbbe1b6fdde3ee47e878b92467cd4ac9ea7cb6"
    end
    on_intel do
      url "https://github.com/lonkar-org/tmux-companion/releases/download/v0.6.0/tmux-companion-v0.6.0-x86_64-unknown-linux-musl.tar.gz"
      sha256 "3c6ced40e1a497c532825af129e365329da5e6f4e2b75ae79b767af73e723156"
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
