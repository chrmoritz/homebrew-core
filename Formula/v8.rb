class V8 < Formula
  desc "Google's JavaScript engine"
  homepage "https://github.com/v8/v8/wiki"
  url "https://github.com/v8/v8/archive/6.8.275.24.tar.gz"
  sha256 "74b1c62f3790cab55f41f5b221637745dc00f26123c2e25e2d1d37a133555fc1"

  bottle do
    cellar :any
    sha256 "179a8442510eb0a022ea6823cd6a76044c14c4fe18415710cac3d746d432020e" => :high_sierra
    sha256 "8106efc14371982af11a66d8db533dc0589bc240950e0e445467cf6ce8871393" => :sierra
    sha256 "487f2ca72096ee27d13533a6dad2d472a92ba40ef518a45226f19e94d4a79242" => :el_capitan
    sha256 "dc9af3e08eda8a4acd1ff3c6b47a4c5170a92dbab7d2d79958a14d8aa42eefac" => :yosemite
    sha256 "7bcd1bbd66c11305eeea0c36ca472de8a639f511abe0909c8815b1208dbce7b6" => :mavericks
  end

  # https://bugs.chromium.org/p/chromium/issues/detail?id=620127
  depends_on :macos => :el_capitan

  # depot_tools/GN require Python 2.7+
  depends_on "python@2" => :build

  needs :cxx11

  resource "v8__third_party__icu" do
    url "https://chromium.googlesource.com/chromium/deps/icu.git",
      :revision => "f61e46dbee9d539a32551493e3bcc1dea92f83ec"
  end

  resource "third_party__libc++__trunk" do
    url "https://chromium.googlesource.com/chromium/llvm-project/libcxx.git",
      :revision => "85a7702b4cc5d69402791fe685f151cf3076be71"
  end

  resource "v8__build" do
    url "https://chromium.googlesource.com/chromium/src/build.git",
      :revision => "b5df2518f091eea3d358f30757dec3e33db56156"
  end

  resource "v8__tools__swarming_client" do
    url "https://chromium.googlesource.com/infra/luci/client-py.git",
      :revision => "833f5ebf894be1e3e6d13678d5de8479bf12ff28"
  end

  resource "v8__third_party__googletest__src" do
    url "https://chromium.googlesource.com/external/github.com/google/googletest.git",
      :revision => "08d5b1f33af8c18785fb8ca02792b5fac81e248f"
  end

  resource "v8__base__trace_event__common" do
    url "https://chromium.googlesource.com/chromium/src/base/trace_event/common.git",
      :revision => "211b3ed9d0481b4caddbee1322321b86a483ca1f"
  end

  resource "v8__third_party__instrumented_libraries" do
    url "https://chromium.googlesource.com/chromium/src/third_party/instrumented_libraries.git",
      :revision => "323cf32193caecbf074d1a0cb5b02b905f163e0f"
  end

  resource "v8__tools__gyp" do
    url "https://chromium.googlesource.com/external/gyp.git",
      :revision => "d61a9397e668fa9843c4aa7da9e79460fe590bfb"
  end

  resource "v8__tools__clang" do
    url "https://chromium.googlesource.com/chromium/src/tools/clang.git",
      :revision => "c893c7eec4706f8c7fc244ee254b1dadd8f8d158"
  end

  resource "v8__test__mozilla__data" do
    url "https://chromium.googlesource.com/v8/deps/third_party/mozilla-tests.git",
      :revision => "f6c578a10ea707b1a8ab0b88943fe5115ce2b9be"
  end

  resource "v8__test__test262__harness" do
    url "https://chromium.googlesource.com/external/github.com/test262-utils/test262-harness-py.git",
      :revision => "0f2acdd882c84cff43b9d60df7574a1901e2cdcd"
  end

  resource "v8__buildtools" do
    url "https://chromium.googlesource.com/chromium/buildtools.git",
      :revision => "94288c26d2ffe3aec9848c147839afee597acefd"
  end

  resource "v8__third_party__depot_tools" do
    url "https://chromium.googlesource.com/chromium/tools/depot_tools.git",
      :revision => "083eb25f9acbe034db94a1bd5c1659125b6ebf98"
  end

  resource "v8__third_party__markupsafe" do
    url "https://chromium.googlesource.com/chromium/src/third_party/markupsafe.git",
      :revision => "8f45f5cfa0009d2a70589bcda0349b8cb2b72783"
  end

  resource "v8__third_party__jinja2" do
    url "https://chromium.googlesource.com/chromium/src/third_party/jinja2.git",
      :revision => "45571de473282bd1d8b63a8dfcb1fd268d0635d2"
  end

  resource "v8__test__wasm-js" do
    url "https://chromium.googlesource.com/external/github.com/WebAssembly/spec.git",
      :revision => "27d63f22e72395248d314520b3ad5b1e0943fc10"
  end

  resource "v8__test__benchmarks__data" do
    url "https://chromium.googlesource.com/v8/deps/third_party/benchmarks.git",
      :revision => "05d7188267b4560491ff9155c5ee13e207ecd65f"
  end

  resource "v8__tools__luci-go" do
    url "https://chromium.googlesource.com/chromium/src/tools/luci-go.git",
      :revision => "ff0709d4283b1f233dcf0c9fec1672c6ecaed2f1"
  end

  resource "clang_format__script" do
    url "https://chromium.googlesource.com/chromium/llvm-project/cfe/tools/clang-format.git",
      :revision => "0653eee0c81ea04715c635dd0885e8096ff6ba6d"
  end

  resource "v8__test__test262__data" do
    url "https://chromium.googlesource.com/external/github.com/tc39/test262.git",
      :revision => "0192e0d70e2295fb590f14865da42f0f9dfa64bd"
  end

  resource "third_party__libunwind__trunk" do
    url "https://chromium.googlesource.com/external/llvm.org/libunwind.git",
      :revision => "1e1c6b739595098ba5c466bfe9d58b993e646b48"
  end

  resource "third_party__libc++abi__trunk" do
    url "https://chromium.googlesource.com/chromium/llvm-project/libcxxabi.git",
      :revision => "05a73941f3fb177c4a891d4ff2a4ed5785e3b80c"
  end

  def install
    (buildpath/"v8").install Dir.glob("*", File::FNM_DOTMATCH) - %w[. .. .brew_home]

    # autogenerated installing resources to paths according to DEPS file
    (buildpath/"v8/third_party/icu").install resource("v8__third_party__icu")
    (buildpath/"third_party/libc++/trunk").install resource("third_party__libc++__trunk")
    (buildpath/"v8/build").install resource("v8__build")
    (buildpath/"v8/tools/swarming_client").install resource("v8__tools__swarming_client")
    (buildpath/"v8/third_party/googletest/src").install resource("v8__third_party__googletest__src")
    (buildpath/"v8/base/trace_event/common").install resource("v8__base__trace_event__common")
    (buildpath/"v8/third_party/instrumented_libraries").install resource("v8__third_party__instrumented_libraries")
    (buildpath/"v8/tools/gyp").install resource("v8__tools__gyp")
    (buildpath/"v8/tools/clang").install resource("v8__tools__clang")
    (buildpath/"v8/test/mozilla/data").install resource("v8__test__mozilla__data")
    (buildpath/"v8/test/test262/harness").install resource("v8__test__test262__harness")
    (buildpath/"v8/buildtools").install resource("v8__buildtools")
    (buildpath/"v8/third_party/depot_tools").install resource("v8__third_party__depot_tools")
    (buildpath/"v8/third_party/markupsafe").install resource("v8__third_party__markupsafe")
    (buildpath/"v8/third_party/jinja2").install resource("v8__third_party__jinja2")
    (buildpath/"v8/test/wasm-js").install resource("v8__test__wasm-js")
    (buildpath/"v8/test/benchmarks/data").install resource("v8__test__benchmarks__data")
    (buildpath/"v8/tools/luci-go").install resource("v8__tools__luci-go")
    (buildpath/"clang_format/script").install resource("clang_format__script")
    (buildpath/"v8/test/test262/data").install resource("v8__test__test262__data")
    (buildpath/"third_party/libunwind/trunk").install resource("third_party__libunwind__trunk")
    (buildpath/"third_party/libc++abi/trunk").install resource("third_party__libc++abi__trunk")

    # add depot_tools to PATH (for download_from_google_storage tool)
    ENV.prepend_path "PATH", buildpath/"v8/third_party/depot_tools"

    # autogenerated system calls for hooks in DEPS file
    system "python", "v8/third_party/depot_tools/update_depot_tools_toggle.py", "--disable"
    system "python", "v8/build/landmines.py", "--landmine-scripts", "v8/tools/get_landmines.py"
    system "download_from_google_storage", "--no_resume", "--platform=darwin", "--no_auth", "--bucket", "chromium-clang-format", "-s", "v8/buildtools/mac/clang-format.sha1"
    system "download_from_google_storage", "--no_resume", "--platform=darwin", "--no_auth", "--bucket", "chromium-luci", "-d", "v8/tools/luci-go/mac64"
    system "download_from_google_storage", "--no_resume", "--platform=darwin", "--no_auth", "--bucket", "chromium-gn", "-s", "v8/buildtools/mac/gn.sha1"
    system "download_from_google_storage", "--no_resume", "--no_auth", "-u", "--bucket", "v8-wasm-spec-tests", "-s", "v8/test/wasm-spec-tests/tests.tar.gz.sha1"
    system "download_from_google_storage", "--no_resume", "--no_auth", "-u", "--bucket", "chromium-v8-closure-compiler", "-s", "v8/src/inspector/build/closure-compiler.tar.gz.sha1"
    system "python", "v8/tools/clang/scripts/update.py"

    cd "v8" do
      output_path = "out.gn/x64.release"

      gn_args = {
        :is_debug => false,
        :is_component_build => true,
        :v8_use_external_startup_data => false,
        :v8_enable_i18n_support => true,
      }

      # Transform to args string
      gn_args_string = gn_args.map { |k, v| "#{k}=#{v}" }.join(" ")

      # Build with gn + ninja
      system "gn",
        "gen",
        "--args=#{gn_args_string}",
        output_path

      system "ninja",
        "-j", ENV.make_jobs,
        "-C", output_path,
        "-v",
        "d8"

      # Install all the things
      include.install Dir["include/*"]

      cd output_path do
        lib.install Dir["lib*.dylib"]

        # Install d8 and icudtl.dat in libexec and symlink
        # because they need to be in the same directory.
        libexec.install Dir["d8", "icudt*.dat"]
        (bin/"d8").write <<~EOS
          #!/bin/bash
          exec "#{libexec}/d8" --icu-data-file="#{libexec}/icudtl.dat" "$@"
        EOS
      end
    end
  end

  test do
    assert_equal "Hello World!", shell_output("#{bin}/d8 -e 'print(\"Hello World!\");'").chomp
    assert_match %r{12/\d{2}/2012}, shell_output("#{bin}/d8 -e 'print(new Intl.DateTimeFormat(\"en-US\").format(new Date(Date.UTC(2012, 11, 20, 3, 0, 0))));'").chomp
  end
end
