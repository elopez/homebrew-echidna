class SolcSelect < Formula
  include Language::Python::Virtualenv

  desc "Manage multiple Solidity compiler versions"
  homepage "https://github.com/crytic/solc-select"
  url "https://files.pythonhosted.org/packages/48/d6/35f72b61b89c087e7b886ff6511deb6d3193db2ffacdcf03827373e5e312/solc-select-0.2.1.tar.gz"
  sha256 "e956b04dc7df2209d1fb3b82e2bb62f8e730bb554c4d7f958a14ff2fb2f37212"
  license "AGPL-3.0-only"
  head "https://github.com/crytic/solc-select.git", branch: "dev"

  bottle do
    root_url "https://github.com/elopez/homebrew-echidna/releases/download/solc-select-0.2.1"
    sha256 cellar: :any_skip_relocation, big_sur:      "2db9f8a323ecab57f58c4606229247434a1e3501b7a5289ba03e7e7d7f9f85f4"
    sha256 cellar: :any_skip_relocation, catalina:     "8541aceee98ac0ee743134cf3a91003f4bc80947a48f2347022bef6d326cc545"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "03f3ec3a1e11b46c8b8d1188d3a59006a5ee80d8e67bd17043d2f7655397c145"
  end

  depends_on "python"

  def install
    virtualenv_install_with_resources
  end

  test do
    system "solc-select", "--help"
  end
end
