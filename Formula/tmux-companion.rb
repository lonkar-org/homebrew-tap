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
      url "https://github.com/lonkar-org/tmux-companion/releases/download/v0.10.1/tmux-companion-v0.10.1-aarch64-apple-darwin.tar.gz"
      sha256 "253962e48e6bc49152ce001065121eb2416a32197a186d0c878e18cb6b47fa03"
    end
    on_intel do
      url "https://github.com/lonkar-org/tmux-companion/releases/download/v0.10.1/tmux-companion-v0.10.1-x86_64-apple-darwin.tar.gz"
      sha256 "af70302fe5ae36b28d5e15288bda60005db579bb116492ab5d07f0a6b95f2201"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/lonkar-org/tmux-companion/releases/download/v0.10.1/tmux-companion-v0.10.1-aarch64-unknown-linux-musl.tar.gz"
      sha256 "fa45e2c041737c86812241b73fc176f13b3a5371714a59c3e86bb13548e3d922"
    end
    on_intel do
      url "https://github.com/lonkar-org/tmux-companion/releases/download/v0.10.1/tmux-companion-v0.10.1-x86_64-unknown-linux-musl.tar.gz"
      sha256 "9c862f06806add8f10206e01ae4549229ebf63155a63810b39958994b44c92d1"
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
