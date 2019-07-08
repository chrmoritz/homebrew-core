class Deno < Formula
  desc "Command-line JavaScript / TypeScript engine"
  homepage "https://deno.land/"
  url "https://github.com/denoland/deno.git",
    :branch   => "cargo_gn2",
    :revision => "1b7b5b26108d409f3bacbbe3cd308ffd6ea1219e"
  version "0.15.42"

  bottle do
    cellar :any_skip_relocation
    sha256 "fec7d5b48dbbc065b0e1a0bbc9a41a6e63a006262462f0798953af73cd024443" => :mojave
    sha256 "101e16751809e367218b66feea68c6764eb46341b351a5a212b190132d2a8362" => :high_sierra
    sha256 "d03f433bc569a326e1f7e2d7a3d992cb62723dde955e846c3060e7e49be2c566" => :sierra
  end

  depends_on "llvm" => :build
  depends_on "ninja" => :build
  depends_on "node" => :build
  depends_on "rust" => :build

  # https://bugs.chromium.org/p/chromium/issues/detail?id=620127
  depends_on :macos => :el_capitan

  resource "gn" do
    url "https://gn.googlesource.com/gn.git",
      :revision => "81ee1967d3fcbc829bac1c005c3da59739c88df9"
  end

  def install
    # Build gn from source (used as a build tool here)
    (buildpath/"gn").install resource("gn")
    cd "gn" do
      system "python", "build/gen.py"
      system "ninja", "-C", "out/", "gn"
    end

    # env args for building a release build with our clang, ninja and gn
    ENV["DENO_NO_BINARY_DOWNLOAD"] = "1"
    ENV["DENO_BUILD_ARGS"] = %W[
      clang_base_path="#{Formula["llvm"].prefix}"
      clang_use_chrome_plugins=false
      mac_deployment_target="#{MacOS.version}"
    ].join(" ")
    ENV["NINJA"] = Formula["ninja"].bin/"ninja"
    ENV["GN"] = buildpath/"gn/out/gn"

    cd "cli" do
      system "cargo", "install", "-v", "--root", prefix, "--path", "."
    end

    # Install bash and zsh completion
    output = Utils.popen_read("#{bin}/deno completions bash")
    (bash_completion/"deno").write output
    output = Utils.popen_read("#{bin}/deno completions zsh")
    (zsh_completion/"_deno").write output
  end

  test do
    (testpath/"hello.ts").write <<~EOS
      console.log("hello", "deno");
    EOS
    hello = shell_output("#{bin}/deno run hello.ts")
    assert_includes hello, "hello deno"
  end
end
