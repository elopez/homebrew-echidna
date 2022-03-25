class SolcSelect < Formula
  include Language::Python::Virtualenv

  desc "Manage multiple Solidity compiler versions"
  homepage "https://github.com/crytic/solc-select"
  url "https://files.pythonhosted.org/packages/48/d6/35f72b61b89c087e7b886ff6511deb6d3193db2ffacdcf03827373e5e312/solc-select-0.2.1.tar.gz"
  sha256 "e956b04dc7df2209d1fb3b82e2bb62f8e730bb554c4d7f958a14ff2fb2f37212"
  license "AGPL-3.0-only"
  head "https://github.com/crytic/solc-select.git", branch: "dev"

  depends_on "python"

  def install
    virtualenv_install_with_resources
  end

  test do
    system "solc-select", "--help"
  end
end
