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
      url "https://github.com/lonkar-org/tmux-companion/releases/download/v0.3.0/tmux-companion-v0.3.0-aarch64-apple-darwin.tar.gz"
      sha256 "6091b50c606ae11203bbc2f2087563befa649deb10abea804652b7040575d65c"
    end
    on_intel do
      url "https://github.com/lonkar-org/tmux-companion/releases/download/v0.3.0/tmux-companion-v0.3.0-x86_64-apple-darwin.tar.gz"
      sha256 "5f5b4d30ba6afeb19b7f038840bfbc1f64f826ae2f05b001946e137a5269fa5b"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/lonkar-org/tmux-companion/releases/download/v0.3.0/tmux-companion-v0.3.0-aarch64-unknown-linux-musl.tar.gz"
      sha256 "ca8a45ec34bb2afb42519e6189bf601ab90a8d9de865f0824a3f79dcf46d9a28"
    end
    on_intel do
      url "https://github.com/lonkar-org/tmux-companion/releases/download/v0.3.0/tmux-companion-v0.3.0-x86_64-unknown-linux-musl.tar.gz"
      sha256 "472f9e4cbc80d4c6a8023046f67cd3feda068dab284ef84ade6b62a725525a13"
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
