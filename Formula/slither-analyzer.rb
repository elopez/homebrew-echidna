class SlitherAnalyzer < Formula
  include Language::Python::Virtualenv

  desc "Solidity static analysis framework written in Python 3"
  homepage "https://github.com/crytic/slither"
  url "https://files.pythonhosted.org/packages/66/be/85781090ccdc1eac499b867870873733a63ff7232048585ef4bad31afd8e/slither-analyzer-0.8.2.tar.gz"
  sha256 "efbd38e5e07b2af1c16f48fad6acf8cc94ed129ae0e3f687e8cacf950635c223"
  license "AGPL-3.0-only"
  head "https://github.com/crytic/slither.git", branch: "master"

  depends_on "python"

  resource "crytic-compile" do
    url "https://files.pythonhosted.org/packages/26/44/d2ee4195db00661f7e81cd82ffa927530a8c18e09b55d65d4aedc18afe1e/crytic-compile-0.2.2.tar.gz"
    sha256 "708fd968a9d8856982838e5c56e1c7ff8e3f14d1d7eac971065395a28af4a60f"
  end

  resource "prettytable" do
    url "https://files.pythonhosted.org/packages/cb/7d/7e6bc4bd4abc49e9f4f5c4773bb43d1615e4b476d108d1b527318b9c6521/prettytable-3.2.0.tar.gz"
    sha256 "ae7d96c64100543dc61662b40a28f3b03c0f94a503ed121c6fca2782c5816f81"
  end

  resource "pysha3" do
    url "https://files.pythonhosted.org/packages/73/bf/978d424ac6c9076d73b8fdc8ab8ad46f98af0c34669d736b1d83c758afee/pysha3-1.0.2.tar.gz"
    sha256 "fe988e73f2ce6d947220624f04d467faf05f1bbdbc64b0a201296bb3af92739e"
  end

  resource "wcwidth" do
    url "https://files.pythonhosted.org/packages/89/38/459b727c381504f361832b9e5ace19966de1a235d73cdbdea91c771a1155/wcwidth-0.2.5.tar.gz"
    sha256 "c4d647b99872929fdb7bdcaa4fbe7f01413ed3d98077df798530e5b04f116c83"
  end

  def install
    virtualenv_install_with_resources
  end

  test do
    system "slither", "--version"
  end
end
