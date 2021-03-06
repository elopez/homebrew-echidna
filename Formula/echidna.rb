class Echidna < Formula
  desc "Ethereum smart contract fuzzer"
  homepage "https://github.com/crytic/echidna"
  url "https://github.com/crytic/echidna/archive/refs/tags/v2.0.1.tar.gz"
  sha256 "d7bcebc343073bca64fdb4ac8b8b88ef91132f86dd65464a11ce9ce252db831f"
  license "AGPL-3.0-only"
  head "https://github.com/crytic/echidna.git", branch: "master"

  bottle do
    root_url "https://github.com/elopez/homebrew-echidna/releases/download/echidna-2.0.1"
    sha256 cellar: :any,                 big_sur:      "968efe11e676e7d08c5a625b32e261b5d180341cf1bf970cfcbbfb15fb3c705d"
    sha256 cellar: :any,                 catalina:     "70960d1c14e09570a6f2ed6c51e25f959c934f5b4c2922b3bca78ffa834e64e8"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "51abf70e903f8984776b30c2cde356f5392254b0e6973bac7c9d9e5f1f81ee70"
  end

  depends_on "autoconf" => :build
  depends_on "automake" => :build
  depends_on "cmake" => :build
  depends_on "ghc" => :build
  depends_on "haskell-stack" => :build
  depends_on "libtool" => :build
  depends_on "openssl@1.1" => :build

  depends_on "crytic-compile" => :test
  depends_on "slither-analyzer" => :test
  depends_on "solc-select" => :test
  depends_on "gmp"
  uses_from_macos "ncurses"
  uses_from_macos "zlib"

  resource "secp256k1" do
    url "https://github.com/bitcoin-core/secp256k1/archive/1086fda4c1975d0cad8d3cad96794a64ec12dca4.tar.gz"
    sha256 "ce97b9ff2c7add56ce9d165f05d24517faf73d17bd68a12459a32f84310af04f"
  end

  resource "ff" do
    url "https://github.com/scipr-lab/libff.git",
      tag:      "v0.2.1",
      revision: "5835b8c59d4029249645cf551f417608c48f2770"
  end

  def install
    ENV.cxx11

    resource("secp256k1").stage do
      system "./autogen.sh"
      system "./configure", "--disable-dependency-tracking",
                            "--disable-silent-rules",
                            "--prefix=#{prefix}",
                            "--enable-module-recovery",
                            "--with-bignum=no"
      system "make", "install"
    end

    resource("ff").stage do
      inreplace ["libff/CMakeLists.txt", "depends/CMakeLists.txt"], "STATIC", "SHARED"

      mkdir "build" do
        system "cmake", "-DWITH_PROCPS=OFF", "-DCURVE=ALT_BN128",
                        "-DCMAKE_INSTALL_NAME_DIR=#{lib}",
                        "-DOPENSSL_ROOT_DIR=#{Formula["openssl@1.1"]}.opt_prefix",
                        "..", *std_cmake_args
        system "make", "install"
      end
    end

    # Disable forced static linking for linux
    inreplace "package.yaml", "os(linux)", "false"

    # Let `stack` handle its own parallelization
    jobs = ENV.make_jobs
    ENV.deparallelize

    ghc_args = [
      "--system-ghc",
      "--no-install-ghc",
      "--skip-ghc-check",
      "--extra-include-dirs=#{include}",
      "--extra-lib-dirs=#{lib}",
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

    assert_match(/echidna_true:(\s+)passed!/,
                 shell_output("SOLC_VERSION=0.7.0 #{bin}/echidna-test --format text #{testpath}/test.sol"))
  end
end
