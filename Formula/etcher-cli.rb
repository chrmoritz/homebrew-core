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
    # Patch package.json the generate cli build instead of electron build
    pkg_json = JSON.parse(IO.read("package.json"))
    pkg_json["bin"] = { :etcher => "./bin/etcher" } # bin entry point
    pkg_json["dependencies"].each do |dep, _| # ignore some electron releated dependencies
      ignore = %w[@fortawesome @types angular react electron bootstrap roboto-fontface winusb] +
               %w[rendition prop-types node-ipc inactivity-timer flexboxgrid styled resin-corvus]
      pkg_json["dependencies"].delete(dep) if dep.start_with?(*ignore)
    end
    pkg_json["dependencies"]["lzma-native"] = "^4.0.1" # upgrading lzma-native for Node 10 support
    pkg_json["dependencies"]["usb"] = "github:tessel/node-usb#1.3.2" # upgrading node-usb for Node 10 support
    pkg_json.delete("devDependencies")
    pkg_json["files"] = %w[bin build lib/cli lib/sdk lib/shared binding.gyp] # ignore electron related source files
    IO.write("package.json", JSON.pretty_generate(pkg_json))
    rm "npm-shrinkwrap.json" # remove shrinkwrap because it would override our patched package.json

    system "npm", "install", *Language::Node.std_npm_install_args(libexec)

    bin.install_symlink libexec/"bin/etcher"
  end

  test do
    assert_equal pipe_output("#{bin}/etcher --version").chomp, "1.4.4"
  end
end
