# frozen_string_literal: true

require "minitest/autorun"

class FormulaTest < Minitest::Test
  EXPECTED_VERSION = "0.2.5"
  EXPECTED_ARTIFACTS = [
    [
      "https://github.com/sovereign46/cli/releases/download/v0.2.5/s46_0.2.5_darwin_amd64.tar.gz",
      "61da6bc60cc4c4ec79b40866b8d037557e1a83222873fb57d6f2cf30df70983f",
    ],
    [
      "https://github.com/sovereign46/cli/releases/download/v0.2.5/s46_0.2.5_darwin_arm64.tar.gz",
      "af36ab4a32c4842b480642345631b4638fbeb883c47619cc595ffba25b55aa38",
    ],
    [
      "https://github.com/sovereign46/cli/releases/download/v0.2.5/s46_0.2.5_linux_amd64.tar.gz",
      "2f651c84154c83a86b5920bbec61cc8fb7641d73687a65f934bc030e5e62c43a",
    ],
    [
      "https://github.com/sovereign46/cli/releases/download/v0.2.5/s46_0.2.5_linux_arm64.tar.gz",
      "27ddef437ffa8d4cd0d940a70da8283f02ba37d93165a48687816b14a79c1909",
    ],
  ].freeze

  def setup
    @formula = File.read(File.expand_path("../Formula/s46.rb", __dir__))
  end

  def test_formula_points_at_sovereign46_release_artifacts
    assert_match(/class S46 < Formula/, @formula)
    assert_match(%r{homepage "https://sovereign46\.com"}, @formula)
    assert_equal [EXPECTED_VERSION], @formula.scan(/^\s*version "([^"]+)"$/).flatten

    expected_declarations = EXPECTED_ARTIFACTS.flat_map do |url, digest|
      [["url", url], ["sha256", digest]]
    end
    actual_declarations = @formula.scan(/^\s*(url|sha256) "([^"]+)"$/)

    assert_equal expected_declarations, actual_declarations
  end

  def test_formula_installs_binary_and_smoke_tests_help
    assert_match(/bin\.install "s46"/, @formula)
    assert_match(/generate_completions_from_executable\(bin\/"s46", "completion"\)/, @formula)
    assert_match(/system "#\{bin\}\/s46", "--help"/, @formula)
  end
end
