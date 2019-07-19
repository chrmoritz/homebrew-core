require "language/node"
require "json"

class NowCli < Formula
  desc "The command-line interface for Now"
  homepage "https://zeit.co/now"
  url "https://github.com/zeit/now-cli/archive/15.8.4.tar.gz"
  sha256 "554e6a54b410000ee8ec9a9d9bec662059460d51021a6fccafa095610cc91b33"

  depends_on "node"

  def install
    pkg_json = JSON.parse(IO.read("package.json"))
    pkg_json["scripts"].delete "postinstall"  # don't run postinstall
    IO.write("package.json", JSON.pretty_generate(pkg_json))

    system "npm", "install", *Language::Node.local_npm_install_args
    system "npm", "run", "build", "--", "--dev" # Don't minify the release bundle

    # create release package.json (set main entry point, install only the release bundle)
    pkg_json["bin"]["now"] = "index.js"
    pkg_json.delete("dependencies")
    pkg_json.delete("files")
    IO.write("dist/package.json", JSON.pretty_generate(pkg_json))

    # add shebang + change update notification
    inreplace "dist/index.js" do |s|
      s.gsub! "require('./sourcemap-register.js');", "#!/usr/bin/env node\n\nrequire('./sourcemap-register.js');"
      s.gsub! "exports.getUpgradeCommand = getUpgradeCommand;",
              "exports.getUpgradeCommand = async () => 'Please run `brew upgrade now-cli` to update Now CLI.';"
    end

    cd "dist" do
      system "npm", "install", *Language::Node.std_npm_install_args(libexec)
      bin.install_symlink Dir["#{libexec}/bin/*"]
    end
  end

  test do
    system "#{bin}/now", "init", "jekyll"
    assert_predicate testpath/"jekyll/Gemfile", :exist?, "Gemfile must exist"
    assert_predicate testpath/"jekyll/index.md", :exist?, "index.md must exist"
    assert_predicate testpath/"jekyll/package.json", :exist?, "package.json must exist"
  end
end
