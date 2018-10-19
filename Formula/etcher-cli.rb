require "language/node"
require "json"

class EtcherCli < Formula
  desc "Flash OS images to SD cards & USB drives, safely and easily"
  homepage "https://etcher.io/"
  url "https://github.com/resin-io/etcher/archive/v1.4.5.tar.gz"
  sha256 "82122253333b3bf5dc6f8909a5877a3218a2e677aff09159e5a4819be9e0edb9"

  depends_on "python" => :build
  depends_on "node"

  resource "mini.iso" do
    url "http://archive.ubuntu.com/ubuntu/dists/xenial/main/installer-i386/current/images/netboot/mini.iso"
    sha256 "fd0d98e5e2c0765c4f597f36f46abd2579e3887388728427ac63b8aa1c4a3f38"
  end

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
    assert_equal pipe_output("#{bin}/etcher --version").chomp, version

    resource("mini.iso").stage testpath
    system "dd", "if=/dev/zero", "of=test.dmg", "bs=1024", "count=50000"
    drive = Utils.popen_read("hdiutil attach -imagekey diskimage-class=CRawDiskImage -nomount test.dmg").strip
    if $CHILD_STATUS.exitstatus.zero? && %r{\/dev\/disk\d+} =~ drive
      begin
        # This will still fail within brews sandbox because of missing write permissions :(
        system bin/"etcher", "--drive=#{drive}", "--yes", "--check", testpath/"mini.iso"
      ensure
        system "hdiutil", "detach", drive
      end
    else
      assert false, "failed to attach test image"
    end
  end
end
