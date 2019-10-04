class Emscripten < Formula
  desc "LLVM bytecode to JavaScript compiler"
  homepage "https://kripken.github.io/emscripten-site/"

  stable do
    url "https://github.com/emscripten-core/emscripten/archive/1.38.47.tar.gz"
    sha256 "3412740c703432274f35a08e00cafa500a2f2effcc455484faee9e786b917b12"

    resource "llvm" do
      url "https://github.com/llvm/llvm-project.git",
        :revision => "12e915b3fcc55b8394dce3105a24c009e516d153"
    end

    resource "binaryen" do
      url "https://github.com/WebAssembly/binaryen.git",
        :revision => "fc6d2df4eedfef53a0a29fed1ff3ce4707556700"
    end
  end

  bottle do
    cellar :any
    sha256 "4f8be86a67d0f1fc87c01c92dd0fe8112f1cd6c5b1ae210ac0528ce02ad36b8a" => :mojave
    sha256 "3abedeaff354db116142227d55d93232210b073549ab26c33b7f8c97fe8e897b" => :high_sierra
    sha256 "36d6ea5dd8eaff5b9f8adf9388bfc9bcab2d22b8b738a164378601e174cc9bca" => :sierra
  end

  head do
    url "https://github.com/emscripten-core/emscripten.git", :branch => "incoming"

    resource "llvm" do
      url "https://github.com/llvm/llvm-project.git"
    end

    resource "binaryen" do
      url "https://github.com/WebAssembly/binaryen.git"
    end
  end

  depends_on "cmake" => :build
  depends_on :xcode => :build
  depends_on "libffi"
  depends_on "swig"
  depends_on "node"
  depends_on "python"
  depends_on "yuicompressor"

  def install
    ENV.cxx11
    ENV.permit_arch_flags
    cmake_args = std_cmake_args.reject { |s| s["CMAKE_INSTALL_PREFIX"] }

    # All files from the repository are required as emscripten is a collection
    # of scripts which need to be installed in the same layout as in the Git
    # repository.
    libexec.install Dir["*"]

    (buildpath/"llvm").install resource("llvm")

    # TODO: check for unneeded stuff (which is still turned on)
    args = cmake_args + %W[
      -DCMAKE_INSTALL_PREFIX=#{libexec}/llvm
      -DLIBOMP_ARCH=x86_64
      -DLLVM_BUILD_EXTERNAL_COMPILER_RT=ON
      -DLLVM_BUILD_LLVM_DYLIB=ON
      -DLLVM_ENABLE_FFI=ON
      -DLLVM_ENABLE_LIBCXX=ON
      -DLLVM_INCLUDE_DOCS=OFF
      -DLLVM_OPTIMIZED_TABLEGEN=ON
      -DFFI_INCLUDE_DIR=#{Formula["libffi"].opt_lib}/libffi-#{Formula["libffi"].version}/include
      -DFFI_LIBRARY_DIR=#{Formula["libffi"].opt_lib}
      -DLLDB_USE_SYSTEM_DEBUGSERVER=ON
      -DLLDB_DISABLE_PYTHON=1
      -DLIBOMP_INSTALL_ALIASES=OFF
      -DLLVM_ENABLE_PROJECTS='lld;clang'
      -DLLVM_TARGETS_TO_BUILD='host;WebAssembly'
      -DLLVM_INSTALL_TOOLCHAIN_ONLY=ON
      -DLLVM_INCLUDE_EXAMPLES=OFF
      -DLLVM_INCLUDE_TESTS=OFF
    ]

    mkdir "build" do
      system "cmake", "-G", "Unix Makefiles", "../llvm/llvm", *args
      system "make"
      system "make", "install"
    end

    (buildpath/"binaryen").install resource("binaryen")

    cd "binaryen" do
      args = cmake_args + ["-DCMAKE_INSTALL_PREFIX=#{libexec}/binaryen"]
      system "cmake", ".", *args
      system "make", "install"
    end

    inreplace libexec/"tools/settings_template_readonly.py" do |s|
      s.gsub! "{{{ EMSCRIPTEN_ROOT }}}", opt_libexec
      s.gsub! "{{{ LLVM_ROOT }}}", opt_libexec/"llvm/bin"
      s.gsub! "'BINARYEN', ''", "'BINARYEN', '#{opt_libexec/"binaryen/bin"}'"
      s.gsub! "{{{ NODE }}}", Formula["node"].opt_bin
    end

    %w[em++ em-config emar emcc emcmake emconfigure emlink.py emmake
       emranlib emrun emscons].each do |emscript|
      bin.install_symlink libexec/emscript
    end
  end

  def caveats; <<~EOS
    Manually set LLVM_ROOT to
      #{opt_libexec}/llvm/bin
    and comment out BINARYEN_ROOT
    in ~/.emscripten after running `emcc` for the first time.
  EOS
  end

  test do
    system bin/"emcc"
    assert_predicate testpath/".emscripten", :exist?, "Failed to create sample config"
  end
end
