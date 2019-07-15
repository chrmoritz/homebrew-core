class NowCli < Formula
  desc "The command-line interface for Now"
  homepage "https://zeit.co/now"
  url "https://github.com/zeit/now-cli/releases/download/15.8.0/now-macos.gz"
  sha256 "350017e2010017e84a34a459b398f3bed24f0ffd556c78fe25c03c1ac64c3521"

  def install
    bin.install "now-macos"
    mv "#{bin}/now-macos", "#{bin}/now"
  end

  test do
    system "#{bin}/now", "-v"
  end
end
