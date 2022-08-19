class Echidna < Formula
  desc "Ethereum smart contract fuzzer"
  homepage "https://github.com/crytic/echidna"
  url "https://github.com/crytic/echidna/archive/refs/tags/v2.0.2.tar.gz"
  sha256 "169f1086e6276f3f932bd2f9e062f203c22e8829ef07788f7f74c989ed8327e3"
  license "AGPL-3.0-only"
  head "https://github.com/crytic/echidna.git", branch: "master"

  bottle do
    root_url "https://github.com/elopez/homebrew-echidna/releases/download/echidna-2.0.2"
    sha256 cellar: :any,                 monterey:     "19204c4d78e8550f9dda32d0b3bdfddaf669d7cbe1fe5109993a81918355cf44"
    sha256 cellar: :any,                 big_sur:      "37c459a0314b26ca5a106f40e83b26619f1ca94690dd6859dbe33e3aa24b838d"
    sha256 cellar: :any,                 catalina:     "9b2bad65434fdf3684fc91b364a17f5e24d543410ed62927f959c9625f3e490f"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "18f66a104f262ae836683cab74a2e63027effe07be8ca0263f711cffe2ff2cf8"
  end

  depends_on "autoconf" => :build
  depends_on "automake" => :build
  depends_on "ghc" => :build
  depends_on "haskell-stack" => :build
  depends_on "libtool" => :build

  depends_on "crytic-compile"
  depends_on "libff"
  depends_on "slither-analyzer"
  uses_from_macos "ncurses"
  uses_from_macos "zlib"

  resource "secp256k1" do
    # this is the revision used to build upstream, see echidna/.github/scripts/install-libsecp256k1.sh
    url "https://github.com/bitcoin-core/secp256k1/archive/1086fda4c1975d0cad8d3cad96794a64ec12dca4.tar.gz"
    sha256 "ce97b9ff2c7add56ce9d165f05d24517faf73d17bd68a12459a32f84310af04f"
  end

  def install
    ENV.cxx11

    resource("secp256k1").stage do
      system "./autogen.sh"
      system "./configure", *std_configure_args,
                            "--disable-silent-rules",
                            "--prefix=#{libexec}",
                            "--libdir=#{libexec}/lib",
                            "--enable-module-recovery",
                            "--with-bignum=no",
                            "--with-pic"
      system "make", "install"
    end

    # Let `stack` handle its own parallelization
    jobs = ENV.make_jobs
    ENV.deparallelize

    ghc_args = [
      "--system-ghc",
      "--no-install-ghc",
      "--skip-ghc-check",
      "--extra-include-dirs=#{Formula["libff"].include}",
      "--extra-lib-dirs=#{Formula["libff"].lib}",
      "--extra-include-dirs=#{libexec}/include",
      "--extra-lib-dirs=#{libexec}/lib",
      "--ghc-options=-optl-Wl,-rpath,#{libexec}/lib",
      "--flag=echidna:-static",
    ]

    system "stack", "-j#{jobs}", "build", *ghc_args
    system "stack", "-j#{jobs}", "--local-bin-path=#{bin}", "install", *ghc_args
  end

  test do
    system "solc-select", "install", "0.7.0"

    (testpath/"test.sol").write <<~EOS
      contract True {
        function f() public returns (bool) {
          return(false);
        }
        function echidna_true() public returns (bool) {
          return(true);
        }
      }
    EOS

    with_env(SOLC_VERSION: "0.7.0") do
      assert_match(/echidna_true:(\s+)passed!/,
                   shell_output("#{bin}/echidna-test --format text #{testpath}/test.sol"))
    end
  end
end
