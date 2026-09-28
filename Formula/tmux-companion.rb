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
      url "https://github.com/lonkar-org/tmux-companion/releases/download/v0.5.2/tmux-companion-v0.5.2-aarch64-apple-darwin.tar.gz"
      sha256 "40c670b54c254bdf9fe282e37ea97d7396cf63688a82ad2def7d74d654c1ef64"
    end
    on_intel do
      url "https://github.com/lonkar-org/tmux-companion/releases/download/v0.5.2/tmux-companion-v0.5.2-x86_64-apple-darwin.tar.gz"
      sha256 "b74d0abddd2476db7e5285610d2d9340566d357540958a6a088a482087cf916b"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/lonkar-org/tmux-companion/releases/download/v0.5.2/tmux-companion-v0.5.2-aarch64-unknown-linux-musl.tar.gz"
      sha256 "d87d8dbf47f7a0b111cc0723cbaff4b75ba7d459c1bc1552fce34fddc0852a12"
    end
    on_intel do
      url "https://github.com/lonkar-org/tmux-companion/releases/download/v0.5.2/tmux-companion-v0.5.2-x86_64-unknown-linux-musl.tar.gz"
      sha256 "f47e8d55a7b5b473eaffc80d9f9b4342c74a108b78ca344098e02574c96a0008"
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
