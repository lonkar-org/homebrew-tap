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
      url "https://github.com/lonkar-org/tmux-companion/releases/download/v0.7.0/tmux-companion-v0.7.0-aarch64-apple-darwin.tar.gz"
      sha256 "806d02dbfb532a68352dc40fdc7a61becbb07159d65d88ad7ec64b345b69c301"
    end
    on_intel do
      url "https://github.com/lonkar-org/tmux-companion/releases/download/v0.7.0/tmux-companion-v0.7.0-x86_64-apple-darwin.tar.gz"
      sha256 "112097e1b78ac1c810d858e634d77089254700f914c6fb259d058a279ad9d93e"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/lonkar-org/tmux-companion/releases/download/v0.7.0/tmux-companion-v0.7.0-aarch64-unknown-linux-musl.tar.gz"
      sha256 "1daec1d19debe66d7e661b5f0249c1084803ec23495a412b270e7d81f55e172b"
    end
    on_intel do
      url "https://github.com/lonkar-org/tmux-companion/releases/download/v0.7.0/tmux-companion-v0.7.0-x86_64-unknown-linux-musl.tar.gz"
      sha256 "e5af33bb906263cac3af76776f8fb8757d20eb39db952dcc332c63c6246b5ed3"
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
