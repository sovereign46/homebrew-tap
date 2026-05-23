class S46 < Formula
  desc "Sovereign46 CLI control plane for coding-agent harnesses"
  homepage "https://sovereign46.com"
  version "0.2.0"
  license "BUSL-1.1"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/sovereign46/cli/releases/download/v0.2.0/s46_0.2.0_darwin_arm64.tar.gz"
      sha256 "5079712c62d654edc086c96a9546ba6b801234a9bcd1d0a5408edb7f48923950"
    else
      url "https://github.com/sovereign46/cli/releases/download/v0.2.0/s46_0.2.0_darwin_amd64.tar.gz"
      sha256 "bb36b75a1769e495cfcaa4ef9e808cbd05da7c30cd5d4fdd8e9ca2205821a518"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/sovereign46/cli/releases/download/v0.2.0/s46_0.2.0_linux_arm64.tar.gz"
      sha256 "007794874481b5da72ff52631f59642c04c8eb6ac6bb98d0be2f9851b8c269b9"
    else
      url "https://github.com/sovereign46/cli/releases/download/v0.2.0/s46_0.2.0_linux_amd64.tar.gz"
      sha256 "7ff2f83eea11ac97f07f970ae6f133cdbe07ec7fe1566cdb5669b5eaa5f9c6b6"
    end
  end

  def install
    bin.install "s46"
    generate_completions_from_executable(bin/"s46", "completion")
  end

  test do
    assert_match "Sovereign46 CLI", shell_output("#{bin}/s46 --help")
  end
end
