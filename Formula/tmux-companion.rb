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
      url "https://github.com/lonkar-org/tmux-companion/releases/download/v0.4.0/tmux-companion-v0.4.0-aarch64-apple-darwin.tar.gz"
      sha256 "8f5c4ef32519fa391eaad7d62daec3e9f71eb032296ba6bff39eec9a3920eadb"
    end
    on_intel do
      url "https://github.com/lonkar-org/tmux-companion/releases/download/v0.4.0/tmux-companion-v0.4.0-x86_64-apple-darwin.tar.gz"
      sha256 "80ba6d68b389070171dcb6b686b4452b6aee4c4618ef70f17a48338bd6b94c3b"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/lonkar-org/tmux-companion/releases/download/v0.4.0/tmux-companion-v0.4.0-aarch64-unknown-linux-musl.tar.gz"
      sha256 "d62e725715e62dc6a990e8bdc7dc3830695442db2f54565a63611a6b41c11cf9"
    end
    on_intel do
      url "https://github.com/lonkar-org/tmux-companion/releases/download/v0.4.0/tmux-companion-v0.4.0-x86_64-unknown-linux-musl.tar.gz"
      sha256 "b7cf1b92ec47420c59f8df650ea52619a350bb1a1e153bd32e0c466378c4e7ce"
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
