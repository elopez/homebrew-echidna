class Libff < Formula
  desc "C++ library for Finite Fields and Elliptic Curves"
  homepage "https://github.com/scipr-lab/libff"
  # pull from git tag to get submodules
  url "https://github.com/scipr-lab/libff.git",
      tag:      "v0.2.1",
      revision: "5835b8c59d4029249645cf551f417608c48f2770"
  license "MIT"

  bottle do
    root_url "https://github.com/elopez/homebrew-echidna/releases/download/libff-0.2.1"
    sha256 cellar: :any,                 monterey:     "246a33f32ea07c7399f1874ad7aa1a7565fd50000a7a11e3dbd8cf31c8d1c009"
    sha256 cellar: :any,                 big_sur:      "f8c75e42e64ec079c9303e937f35370fe2ecf8c92314c9c688c96ca58072dbe0"
    sha256 cellar: :any,                 catalina:     "f609dca27228fe3cc686ef61167d9a5055cd2a86b79e54bfcd208d2087be6aa5"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "e6a7efa6f802daf90fb7cbc6cf8f6d80798726f8de21b7d4eb182af2f29fd82c"
  end

  depends_on "cmake" => :build
  depends_on "openssl@1.1" => :build

  depends_on "gmp"

  def install
    # bn128 is somewhat faster, but requires an x86_64 CPU
    curve = Hardware::CPU.intel? ? "BN128" : "ALT_BN128"

    # build libff dynamically. The project only builds statically by default
    inreplace "libff/CMakeLists.txt", "STATIC", "SHARED"

    system "cmake", "-S", ".", "-B", "build",
                    "-DWITH_PROCPS=OFF",
                    "-DCURVE=#{curve}",
                    "-DOPENSSL_ROOT_DIR=#{Formula["openssl@1.1"].opt_prefix}",
                    "-DCMAKE_POSITION_INDEPENDENT_CODE=ON",
                    *std_cmake_args
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"
  end

  test do
    (testpath/"test.cpp").write <<~EOS
      #include <libff/algebra/curves/edwards/edwards_pp.hpp>

      using namespace libff;

      int main(int argc, char *argv[]) {
        edwards_pp::init_public_params();
        return 0;
      }
    EOS

    system ENV.cxx, "-std=c++11", "test.cpp", "-I#{include}", "-L#{lib}", "-lff", "-o", "test"
    system "./test"
  end
end
