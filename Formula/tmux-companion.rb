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
      url "https://github.com/lonkar-org/tmux-companion/releases/download/v0.1.0/tmux-companion-v0.1.0-aarch64-apple-darwin.tar.gz"
      sha256 "10442208c4d5daf3fa22bec88a3051d0655d32c5e869891569428af5a334704a"
    end
    on_intel do
      url "https://github.com/lonkar-org/tmux-companion/releases/download/v0.1.0/tmux-companion-v0.1.0-x86_64-apple-darwin.tar.gz"
      sha256 "9465149e7aa221f30d38c4efec5471e2561bebab1fb83990d1a8821db4eb2936"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/lonkar-org/tmux-companion/releases/download/v0.1.0/tmux-companion-v0.1.0-aarch64-unknown-linux-musl.tar.gz"
      sha256 "8bb49bb6d21ffb58af2a1d75eac8cebedafec068809a9ae7ffe50cf5ddae13e8"
    end
    on_intel do
      url "https://github.com/lonkar-org/tmux-companion/releases/download/v0.1.0/tmux-companion-v0.1.0-x86_64-unknown-linux-musl.tar.gz"
      sha256 "a7232961f094e72ad518fed4ac6906e03258a4d30adc78b7624da1a5710a1b5b"
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
