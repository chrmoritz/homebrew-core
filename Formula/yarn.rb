class Yarn < Formula
  desc "JavaScript package manager"
  homepage "https://yarnpkg.com/"
  url "https://yarnpkg.com/downloads/1.5.1/yarn-v1.5.1.tar.gz"
  sha256 "cd31657232cf48d57fdbff55f38bfa058d2fb4950450bd34af72dac796af4de1"

  bottle :unneeded

  depends_on "node" => :recommended

  conflicts_with "hadoop", :because => "both install `yarn` binaries"

  def install
    libexec.install Dir["*"]
    (bin/"yarn").write_env_script "#{libexec}/bin/yarn.js",
      :PREFIX => HOMEBREW_PREFIX,
      :NPM_CONFIG_PYTHON => Formula["python@2"].opt_bin/"python2"
    (bin/"yarnpkg").write_env_script "#{libexec}/bin/yarn.js",
      :PREFIX => HOMEBREW_PREFIX,
      :NPM_CONFIG_PYTHON => Formula["python@2"].opt_bin/"python2"
    inreplace "#{libexec}/package.json", '"installationMethod": "tar"', '"installationMethod": "homebrew"'
  end

  test do
    (testpath/"package.json").write('{"name": "test"}')
    system bin/"yarn", "add", "jquery"
  end
end
