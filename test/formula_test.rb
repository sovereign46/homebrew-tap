# frozen_string_literal: true

require "minitest/autorun"

class FormulaTest < Minitest::Test
  EXPECTED_VERSION = "0.2.5"
  EXPECTED_ARTIFACTS = {
    ["darwin", "amd64"] => [
      "https://github.com/sovereign46/cli/releases/download/v0.2.5/s46_0.2.5_darwin_amd64.tar.gz",
      "61da6bc60cc4c4ec79b40866b8d037557e1a83222873fb57d6f2cf30df70983f",
    ],
    ["darwin", "arm64"] => [
      "https://github.com/sovereign46/cli/releases/download/v0.2.5/s46_0.2.5_darwin_arm64.tar.gz",
      "af36ab4a32c4842b480642345631b4638fbeb883c47619cc595ffba25b55aa38",
    ],
    ["linux", "amd64"] => [
      "https://github.com/sovereign46/cli/releases/download/v0.2.5/s46_0.2.5_linux_amd64.tar.gz",
      "2f651c84154c83a86b5920bbec61cc8fb7641d73687a65f934bc030e5e62c43a",
    ],
    ["linux", "arm64"] => [
      "https://github.com/sovereign46/cli/releases/download/v0.2.5/s46_0.2.5_linux_arm64.tar.gz",
      "27ddef437ffa8d4cd0d940a70da8283f02ba37d93165a48687816b14a79c1909",
    ],
  }.freeze

  def setup
    @formula = File.read(File.expand_path("../Formula/s46.rb", __dir__))
  end

  def test_formula_points_at_sovereign46_release_artifacts
    assert_match(/class S46 < Formula/, @formula)
    assert_match(%r{homepage "https://sovereign46\.com"}, @formula)
    assert_equal expected_matrix, artifact_matrix(@formula)
  end

  def test_matrix_rejects_parenthesized_artifact_overrides
    {
      version: "9.9.9",
      url: "https://example.invalid/payload.tar.gz",
      sha256: "a" * 64,
    }.each do |setter, value|
      overridden = @formula.sub(/\nend\s*\z/, "\n  #{setter}(#{value.inspect})\nend\n")
      refute_equal expected_matrix, artifact_matrix(overridden), "Missed #{setter} override"
    end
  end

  def test_matrix_rejects_swapped_platform_guards
    [
      { "on_macos" => "on_linux", "on_linux" => "on_macos" },
      { "Hardware::CPU.intel?" => "Hardware::CPU.arm?", "Hardware::CPU.arm?" => "Hardware::CPU.intel?" },
    ].each do |swaps|
      swapped = @formula.gsub(Regexp.union(swaps.keys), swaps)
      refute_equal expected_matrix, artifact_matrix(swapped), "Missed swapped guards: #{swaps.keys}"
    end
  end

  def test_formula_installs_binary_and_smoke_tests_help
    assert_match(/bin\.install "s46"/, @formula)
    assert_match(/generate_completions_from_executable\(bin\/"s46", "completion"\)/, @formula)
    assert_match(/system "#\{bin\}\/s46", "--help"/, @formula)
  end

  private

  def expected_matrix
    EXPECTED_ARTIFACTS.transform_values do |url, digest|
      { version: EXPECTED_VERSION, url: url, sha256: digest }
    end
  end

  def artifact_matrix(source)
    EXPECTED_ARTIFACTS.keys.to_h do |os, arch|
      [[os, arch], evaluate_artifact(source, os, arch)]
    end
  end

  def evaluate_artifact(source, os, arch)
    artifact = {}
    formula = Class.new
    [:version, :url, :sha256].each do |setter|
      formula.define_singleton_method(setter) { |value| artifact[setter] = value }
    end
    [:desc, :homepage, :license].each do |setter|
      formula.define_singleton_method(setter) { |_value| }
    end
    formula.define_singleton_method(:test) { |&_block| }
    formula.define_singleton_method(:on_macos) { |&block| class_exec(&block) if os == "darwin" }
    formula.define_singleton_method(:on_linux) { |&block| class_exec(&block) if os == "linux" }

    cpu = Module.new
    cpu.define_singleton_method(:intel?) { arch == "amd64" }
    cpu.define_singleton_method(:arm?) { arch == "arm64" }
    cpu.define_singleton_method(:is_64_bit?) { true }
    hardware = Module.new
    hardware.const_set(:CPU, cpu)

    # Each evaluation gets its own constants; no Homebrew installation is needed.
    namespace = Module.new
    namespace.const_set(:Formula, formula)
    namespace.const_set(:Hardware, hardware)
    namespace.module_eval(source, "Formula/s46.rb", 1)
    artifact
  end
end
