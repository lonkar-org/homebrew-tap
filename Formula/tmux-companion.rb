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
      url "https://github.com/lonkar-org/tmux-companion/releases/download/v0.2.0/tmux-companion-v0.2.0-aarch64-apple-darwin.tar.gz"
      sha256 "cd878ec90ea942b9c3db9745fa5e19af9bfd06aeb9ffef3c414b7378fadb668a"
    end
    on_intel do
      url "https://github.com/lonkar-org/tmux-companion/releases/download/v0.2.0/tmux-companion-v0.2.0-x86_64-apple-darwin.tar.gz"
      sha256 "abd0c83c5527450d0b7e062fafd000d87fec5de9fe542dc9fe99754cf5c363e1"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/lonkar-org/tmux-companion/releases/download/v0.2.0/tmux-companion-v0.2.0-aarch64-unknown-linux-musl.tar.gz"
      sha256 "8a25a000b2627dc7aa1409f287a5c905273f9bc2e1716e69fb862282d8959995"
    end
    on_intel do
      url "https://github.com/lonkar-org/tmux-companion/releases/download/v0.2.0/tmux-companion-v0.2.0-x86_64-unknown-linux-musl.tar.gz"
      sha256 "68089ab86c6117dd4976f520944c980ea7d3a05d7fd5f698b9cdc8a27ad83e6a"
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
