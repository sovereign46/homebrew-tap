# frozen_string_literal: true

require "minitest/autorun"

class FormulaTest < Minitest::Test
  def setup
    @formula = File.read(File.expand_path("../Formula/s46.rb", __dir__))
  end

  def test_formula_points_at_sovereign46_release_artifacts
    assert_match(/class S46 < Formula/, @formula)
    assert_match(%r{homepage "https://sovereign46\.com"}, @formula)
    assert_match(%r{github\.com/sovereign46/cli/releases/download/v\d+\.\d+\.\d+/}, @formula)
    assert_match(/sha256 "[a-f0-9]{64}"/, @formula)
  end

  def test_formula_installs_binary_and_smoke_tests_help
    assert_match(/bin\.install "s46"/, @formula)
    assert_match(/generate_completions_from_executable\(bin\/"s46", "completion"\)/, @formula)
    assert_match(/system "#\{bin\}\/s46", "--help"/, @formula)
  end
end
