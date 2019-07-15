require "language/node"

class NowCli < Formula
  desc "The command-line interface for Now"
  homepage "https://zeit.co/now"
  url "https://github.com/zeit/now-cli/archive/15.8.0.tar.gz"
  sha256 "a0ac758dfe87e67cbfded18d44d8eca657f4ec1767f44ee3b4380738859e836c"

  depends_on "node" => :build

  def install
    inreplace "package.json" do |s|
      s.gsub! /^.*"postinstall".*$/, "" # don't run postinstall
    end

    system "npm", "install", *Language::Node.local_npm_install_args
    system "npm", "run", "build"

    # Read the target node version from package.json
    target = IO.read("package.json").match(/\"(node\d+(\.\d+){2})-[^"]+\"/)[1]

    # This packages now-cli together with a patched version of node
    pkg_args = %W[
      --c=package.json
      --o=now
      --options=no-warnings
      --targets=#{target}
    ]
    system "node_modules/.bin/pkg", "bin/now.js", *pkg_args

    bin.install "now"
  end

  test do
    system "#{bin}/now", "init", "bash"
    system "bash", "bash/index.sh"
    system "rm", "-rf", "bash"
  end
end
