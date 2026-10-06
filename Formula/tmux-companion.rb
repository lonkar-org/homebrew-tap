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
      url "https://github.com/lonkar-org/tmux-companion/releases/download/v0.8.0/tmux-companion-v0.8.0-aarch64-apple-darwin.tar.gz"
      sha256 "c484ce7931db0678d24eb1a5d5b68a076e874eb160c5ae5e8c694c498cdbb801"
    end
    on_intel do
      url "https://github.com/lonkar-org/tmux-companion/releases/download/v0.8.0/tmux-companion-v0.8.0-x86_64-apple-darwin.tar.gz"
      sha256 "ebd257d8872bb7b06900affe50d167f8b811c8af94ac923cbf08a95a2212abc3"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/lonkar-org/tmux-companion/releases/download/v0.8.0/tmux-companion-v0.8.0-aarch64-unknown-linux-musl.tar.gz"
      sha256 "e38c09be47db8852e30bef0c80e738fbd5ec36d39bd0685ed2b7c13faa3b01ed"
    end
    on_intel do
      url "https://github.com/lonkar-org/tmux-companion/releases/download/v0.8.0/tmux-companion-v0.8.0-x86_64-unknown-linux-musl.tar.gz"
      sha256 "4f5975a5b93d97cef6c75af10cb1a75bf39a3cb66444beff329fc973a3f1ced4"
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
