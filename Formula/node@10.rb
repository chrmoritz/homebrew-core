class NodeAT10 < Formula
  desc "Platform built on V8 to build network applications"
  homepage "https://nodejs.org/"
  url "https://nodejs.org/dist/v10.17.0/node-v10.17.0.tar.gz"
  sha256 "5204249d135176b547737d3eed2ca8a9d7f731fef6e545f741129cfa21f90573"

  bottle do
    cellar :any
    sha256 "40dd8d0a63109a7382bb82b8acce2a59dec5e287aa16076a53bef58a69505298" => :catalina
    sha256 "b8065c647630356ba9d8cb1aa08a91084fd2c31068fc26b74641a982b5c6d21b" => :mojave
    sha256 "4d7052b587498a1cda140e1190a274a3e4002e1967dfe5dbc29e1cc286a48733" => :high_sierra
  end

  keg_only :versioned_formula

  depends_on "pkg-config" => :build
  depends_on "python" => :build # does not support Python 3
  depends_on "icu4c"

  # Fixes detecting Apple clang 11.
  patch do
    url "https://github.com/nodejs/node/commit/1f143b8625c2985b4317a40f279232f562417077.patch?full_index=1"
    sha256 "12d8af6647e9a5d81f68f610ad0ed17075bf14718f4d484788baac37a0d3f842"
  end

  # apply upstream Python 3 compatibility patches
  patch do # gyp: pull Python 3 changes from node/node-gyp
    url "https://github.com/nodejs/node/commit/b1db810d501079f767579a241c3f613e8a204294.patch?full_index=1"
    sha256 "cb1d581c5de37b3b21a9f8332a9574a9687f49cfc618bb4e5c34381b210c57e1"
  end

  patch do # gyp: cherrypick more Python3 changes from node-gyp
    url "https://github.com/nodejs/node/commit/d630cc0ec5cac7d31d1fd9fa9f4661a53e51a590.patch?full_index=1"
    sha256 ""
  end

  patch do # port Python 3 compat patches from node-gyp to gyp
    url "https://github.com/nodejs/node/commit/41430bea3c4f3164133d5d7b57a403670d0dfa43.patch?full_index=1"
    sha256 ""
  end

  patch do # fix Python 3 syntax error in mac_tool.py
    url "https://github.com/nodejs/node/commit/b6546736a02eb0b52cb4f9a4f5f0383f4b584bfe.patch?full_index=1"
    sha256 ""
  end

  patch do # pull xcode_emulation.py from node-gyp
    url "https://github.com/nodejs/node/commit/b9fd18f9fbed13cd2538f46e0072c923cbfd95cd.patch?full_index=1"
    sha256 ""
  end

  patch do # build: support py3 for configure.py
    url "https://github.com/nodejs/node/commit/0a63e2d9ff13e2a1935c04bbd7d57d39c36c3884.patch?full_index=1"
    sha256 ""
  end

  patch do # python3 support for configure
    url "https://github.com/nodejs/node/commit/0415dd7cb3f43849f9d6f1f8d271b39c4649c3de.patch?full_index=1"
    sha256 ""
  end

  def install
    # make sure subprocesses spawned by make are using our Python 3
    ENV["PYTHON"] = Formula["python"].opt_bin/"python3"

    system "python3", "configure.py", "--prefix=#{prefix}", "--with-intl=system-icu"
    system "make", "install"
  end

  def post_install
    (lib/"node_modules/npm/npmrc").atomic_write("prefix = #{HOMEBREW_PREFIX}\n")
  end

  test do
    path = testpath/"test.js"
    path.write "console.log('hello');"

    output = shell_output("#{bin}/node #{path}").strip
    assert_equal "hello", output
    output = shell_output("#{bin}/node -e 'console.log(new Intl.NumberFormat(\"en-EN\").format(1234.56))'").strip
    assert_equal "1,234.56", output

    output = shell_output("#{bin}/node -e 'console.log(new Intl.NumberFormat(\"de-DE\").format(1234.56))'").strip
    assert_equal "1.234,56", output

    # make sure npm can find node
    ENV.prepend_path "PATH", opt_bin
    ENV.delete "NVM_NODEJS_ORG_MIRROR"
    assert_equal which("node"), opt_bin/"node"
    assert_predicate bin/"npm", :exist?, "npm must exist"
    assert_predicate bin/"npm", :executable?, "npm must be executable"
    npm_args = ["-ddd", "--cache=#{HOMEBREW_CACHE}/npm_cache", "--build-from-source"]
    system "#{bin}/npm", *npm_args, "install", "npm@latest"
    system "#{bin}/npm", *npm_args, "install", "bignum"
    assert_predicate bin/"npx", :exist?, "npx must exist"
    assert_predicate bin/"npx", :executable?, "npx must be executable"
    assert_match "< hello >", shell_output("#{bin}/npx cowsay hello")
  end
end
