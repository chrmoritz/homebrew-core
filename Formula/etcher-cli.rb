require "language/node"

class EtcherCli < Formula
  desc "Flash OS images to SD cards & USB drives, safely and easily"
  homepage "https://etcher.io/"
  url "https://github.com/resin-io/etcher/archive/v1.4.4.tar.gz"
  sha256 "02082bc1caac746e1cdcd95c2892c9b41ff8d45a672b52f8467548cad4850f5d"

  depends_on "node@6"
  depends_on "python" => :build
  depends_on "webpack" => :build

  def install
    # use npm@3 from node@6 which is required for using upstreams npm-shrinkwrap.json
    ENV.prepend_path "PATH", Formula["node@6"].bin
    system "npm", "install", "--production", "-ddd", "--build-from-source",
           "--#{Language::Node.npm_cache_config}"
    system "npm", "install", "node-loader@0.6.0", "-ddd", "--build-from-source",
           "--#{Language::Node.npm_cache_config}"

    # let wepback bundle things up to avoid shipping electron only dependencies
    rm "webpack.config.js"
    system "patch", "-p1", "--input=patches/lzma-native-index-static-addon-require.patch"
    # prevent webpack from failing to bundle a dep which is only conditionally required on node 0.10-
    inreplace "node_modules/cross-spawn/index.js", "cpSpawnSync = require('spawn-sync');", ""
    system "webpack", "lib/cli/etcher.js", "--output=etcher.js", "--target=node",
           "--mode=development", "--module-bind='node=node-loader'", "--verbose"
    # prepend a shebang for using our node@6 to the webpacks outfile and install it to libexec
    mkdir_p libexec
    File.open(libexec/"etcher.js", 'w', 0755) do |out|
      out.puts "#!#{Formula["node@6"].opt_bin}/node"
      File.foreach(buildpath/"etcher.js") do |li|
        out.puts li
      end
    end
    # install native addons to libexec
    system buildpath/"scripts/build/dependencies-npm-extract-addons.sh",
           "-d", buildpath/"node_modules", "-o", libexec/"node_modules"

    bin.install_symlink libexec/"etcher.js" => "etcher"
  end

  test do
    assert_equal pipe_output("#{bin}/etcher --version").chomp, "1.4.4"
  end
end
