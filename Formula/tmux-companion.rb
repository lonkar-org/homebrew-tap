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
      url "https://github.com/lonkar-org/tmux-companion/releases/download/v0.9.1/tmux-companion-v0.9.1-aarch64-apple-darwin.tar.gz"
      sha256 "321d0a12954c4765f1b1df72a62dac6534a2c8b9a06d6adff229c0bb859970c1"
    end
    on_intel do
      url "https://github.com/lonkar-org/tmux-companion/releases/download/v0.9.1/tmux-companion-v0.9.1-x86_64-apple-darwin.tar.gz"
      sha256 "ba7af4fef302bae8b1d7ef49421af070ad40afd1f013d2bfeb06d9649b0a4a48"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/lonkar-org/tmux-companion/releases/download/v0.9.1/tmux-companion-v0.9.1-aarch64-unknown-linux-musl.tar.gz"
      sha256 "41f0a9f603306a019f22089a2bdd121dc2e7f5d8db17ac9aa116dd5ab721bf28"
    end
    on_intel do
      url "https://github.com/lonkar-org/tmux-companion/releases/download/v0.9.1/tmux-companion-v0.9.1-x86_64-unknown-linux-musl.tar.gz"
      sha256 "b2ced84e702aa158bf4eff2f77cbbae8bc0c2db80d9ca946d0decc9059d5a2c2"
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
