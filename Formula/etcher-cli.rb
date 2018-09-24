require "language/node"
require "json"

class EtcherCli < Formula
  desc "Flash OS images to SD cards & USB drives, safely and easily"
  homepage "https://etcher.io/"
  url "https://github.com/resin-io/etcher/archive/v1.4.4.tar.gz"
  sha256 "02082bc1caac746e1cdcd95c2892c9b41ff8d45a672b52f8467548cad4850f5d"

  depends_on "python" => :build
  depends_on "node"

  def install
    pkg_json = JSON.parse(IO.read("package.json"))
    pkg_json["dependencies"]["lzma-native"] = "^4.0.1" # upgrading lzma-native for Node 10 support
    pkg_json["dependencies"].delete("usb") # delete node-usb (no node 10 support and not needed for cli)
    IO.write("package.json", JSON.pretty_generate(pkg_json))
    rm "npm-shrinkwrap.json"

    system "npm", "install", "--production", "--ignore-scripts", *Language::Node.local_npm_install_args
    system "npm", "install", "pkg@4.3.0", "--prefix=#{buildpath}/pkg", *Language::Node.local_npm_install_args

    cd "pkg" do
      # get list of for the CLI required dependencies using pkg's AST tree walker
      (buildpath/"pkg/get-cli-deps.js").write <<~EOS
        const walker = require("pkg/lib-es5/walker.js").default;
        const cli_entrypoint = "../lib/cli/etcher.js";
        // get the list of file paths required by the cli entrypoint by running the ast walker on it
        var walk_ast = walker({config: {}, base: "../lib/cli", configPath: cli_entrypoint}, cli_entrypoint);
        walk_ast.then(ast_walker_results => {
          let required_paths = Object.keys(ast_walker_results.records);
          // run regex on the required paths to find out the top level dependencies they belong to
          let required_deps = required_paths.map(path => /\\/node_modules\\/([^\\/]*)\\//.exec(path));
          // filter out non matches (direct source files) and only use the actual parenthesized match
          required_deps = required_deps.filter(r => r !== null).map(r => r[1]);
          // dedupte results using a Set (we currently have one match for every source file used)
          let unique_deps = new Set(required_deps);
          // log unique deps to console seperatey by a new line
          console.log(Array.from(unique_deps).join("\\n"));
        });
      EOS
      cli_deps = Utils.popen_read("node get-cli-deps.js").chomp.split("\n")

      # Patch package.json the generate cli build instead of electron build
      pkg_json = JSON.parse(IO.read("../package.json"))
      pkg_json["bin"] = { :etcher => "./bin/etcher" } # set bin entry point
      pkg_json["dependencies"].each do |dep, _| # ignore all electron releated dependencies
        pkg_json["dependencies"].delete(dep) unless cli_deps.include? dep
      end
      # bundle the already installed depedencies and ignore electron related source files
      pkg_json["bundledDependencies"] = pkg_json["dependencies"].keys
      pkg_json["files"] = %w[bin build lib/cli lib/sdk lib/shared binding.gyp]
      IO.write("../package.json", JSON.pretty_generate(pkg_json))
    end

    # patch out unconditional sudo requirement
    inreplace "lib/cli/etcher.js", "permissions.isElevated().then", "Promise.resolve(true).then"

    system "npm", "install", "--production", *Language::Node.std_npm_install_args(libexec)

    bin.install_symlink libexec/"bin/etcher"
  end

  test do
    # Writing a functionality test would require write permissions to /dev/disk*,
    # which is not possible within brews sandbox. Manual test with::
    # $ curl -o /tmp/mini.iso http://archive.ubuntu.com/ubuntu/dists/xenial/main/installer-i386/current/images/netboot/mini.iso
    # $ hdiutil create -size 100m -fs HFS+ -volname Test /tmp/test.dmg
    # $ hdiutil attach -imagekey diskimage-class=CRawDiskImage -nomount /tmp/test.dmg
    # $ etcher -d /dev/<disk> -cu /tmp/mini.iso
    # $ hdiutil detach /dev/<disk> && rm /tmp/{mini.iso,test.dmg}
    # (replace <disk> with the assigned disk name from hdiutil attach)
    assert_equal pipe_output("#{bin}/etcher --version").chomp, version
  end
end
