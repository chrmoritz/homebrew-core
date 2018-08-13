class Chromedriver < Formula
  desc "Tool for automated testing of webapps across many browsers"
  homepage "https://sites.google.com/a/chromium.org/chromedriver/"
  url "https://chromium.googlesource.com/chromium/tools/depot_tools.git",
      :revision => "ed0d273bfa5155ffb2a41525210c154ace0662a8"
  version "2.41" # chromedriver's version, not a depot_tools version

  # https://bugs.chromium.org/p/chromium/issues/detail?id=620127
  depends_on :macos => :el_capitan

  # depot_tools/GN require Python 2.7+
  depends_on "python@2" => :build

  needs :cxx11

  def v8_version
    "3521" # https://omahaproxy.appspot.com/ true_branch from dev
  end

  def install
    # Add depot_tools in PATH
    ENV.prepend_path "PATH", buildpath
    # Prevent from updating depot_tools on every call
    # see https://www.chromium.org/developers/how-tos/depottools#TOC-Disabling-auto-update
    ENV["DEPOT_TOOLS_UPDATE"] = "0"

    # Initialize and sync gclient
    system "gclient", "root"
    system "gclient", "config", "--spec", <<~EOS
      solutions = [
        {
          "url": "https://chromium.googlesource.com/chromium/src.git",
          "managed": False,
          "name": "src",
          "deps_file": "DEPS",
          "custom_deps": {},
        },
      ]
      target_os = [ "mac" ]
      target_os_only = True
      cache_dir = "#{HOMEBREW_CACHE}/gclient_cache"
    EOS

    system "gclient", "sync",
      "-j", ENV.make_jobs,
      "--with_branch_heads",
      "--with_tags",
      "--no-history",
      "-vvv"

    # Enter the chromedriver checkout
    cd "src" do
      system "git", "checkout", "branch-heads/#{v8_version}"
      system "gclient", "sync", "--with_branch_heads", "--with_tags"

      gn_args = {
        :is_debug => false,
        :is_component_build => false,
      }

      # Transform to args string
      gn_args_string = gn_args.map { |k, v| "#{k}=#{v}" }.join(" ")

      # Build with gn + ninja
      system "gn",
        "gen",
        "--args=#{gn_args_string}",
        "out.gn/x64.release"

      system "ninja",
        "-j", ENV.make_jobs,
        "-C", "out.gn/x64.release",
        "-v",
        "chromedriver"

      # Install chromedriver
      bin.install "out.gn/x64.release/chromedriver"
    end
  end

  plist_options :manual => "chromedriver"

  def plist; <<~EOS
    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
    <plist version="1.0">
    <dict>
      <key>Label</key>
      <string>homebrew.mxcl.chromedriver</string>
      <key>RunAtLoad</key>
      <true/>
      <key>KeepAlive</key>
      <false/>
      <key>ProgramArguments</key>
      <array>
        <string>#{opt_bin}/chromedriver</string>
      </array>
      <key>ServiceDescription</key>
      <string>Chrome Driver</string>
      <key>StandardErrorPath</key>
      <string>#{var}/log/chromedriver-error.log</string>
      <key>StandardOutPath</key>
      <string>#{var}/log/chromedriver-output.log</string>
    </dict>
    </plist>
  EOS
  end

  test do
    driver = fork do
      exec bin/"chromedriver", "--port=9999", "--log-path=#{testpath}/cd.log"
    end
    sleep 5
    Process.kill("TERM", driver)
    assert_predicate testpath/"cd.log", :exist?
  end
end
