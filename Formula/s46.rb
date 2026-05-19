class S46 < Formula
  desc "Sovereign46 CLI control plane for coding-agent harnesses"
  homepage "https://sovereign46.com"
  version "0.1.1"
  license "BUSL-1.1"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/sovereign46/cli/releases/download/v0.1.1/s46_0.1.1_darwin_arm64.tar.gz"
      sha256 "810ab5a07a872335c4d2810329053e8ba92467455f39caacf4458a63ed55b5cf"
    else
      url "https://github.com/sovereign46/cli/releases/download/v0.1.1/s46_0.1.1_darwin_amd64.tar.gz"
      sha256 "c275aba6f0d928c60b0b65de84f962adbb6b406ee76b5441619a23d841e374ac"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/sovereign46/cli/releases/download/v0.1.1/s46_0.1.1_linux_arm64.tar.gz"
      sha256 "da93d109ba16117d9f5c01bf0bafbe26a115cdfbdc5fd2418ec2542deb588887"
    else
      url "https://github.com/sovereign46/cli/releases/download/v0.1.1/s46_0.1.1_linux_amd64.tar.gz"
      sha256 "516ec98ca810fd7456990f49033bfc864f9e01c54fa751a12db33385dc115e93"
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
