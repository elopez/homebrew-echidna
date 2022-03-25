class CryticCompile < Formula
  include Language::Python::Virtualenv

  desc "Abstraction layer for smart contract build systems"
  homepage "https://github.com/crytic/crytic-compile"
  url "https://files.pythonhosted.org/packages/26/44/d2ee4195db00661f7e81cd82ffa927530a8c18e09b55d65d4aedc18afe1e/crytic-compile-0.2.2.tar.gz"
  sha256 "708fd968a9d8856982838e5c56e1c7ff8e3f14d1d7eac971065395a28af4a60f"
  license "AGPL-3.0-only"
  head "https://github.com/crytic/crytic-compile.git", branch: "master"

  depends_on "python"
  depends_on "solc-select"

  resource "pysha3" do
    url "https://files.pythonhosted.org/packages/73/bf/978d424ac6c9076d73b8fdc8ab8ad46f98af0c34669d736b1d83c758afee/pysha3-1.0.2.tar.gz"
    sha256 "fe988e73f2ce6d947220624f04d467faf05f1bbdbc64b0a201296bb3af92739e"
  end

  def install
    virtualenv_install_with_resources
  end

  test do
    system "crytic-compile", "--version"
  end
end
