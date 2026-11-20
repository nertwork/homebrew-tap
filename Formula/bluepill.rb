class Bluepill < Formula
  desc "Headless zero-Electron macOS iMessage, SMS & RCS relay daemon + Cloud Relay + Web UI for BluePill"
  homepage "https://bluepill.nertwork.com"
  url "https://github.com/nertwork/bluepill/archive/refs/tags/v1.2.4.tar.gz"
  sha256 "67f2489b3bf295acc6bd83ccc62083bc8dc716974ec3a67412e86983d3ff2eed"
  version "1.2.4"
  license "MIT"
  head "https://github.com/nertwork/bluepill.git", branch: "main"

  bottle do
    root_url "https://github.com/nertwork/bluepill/releases/download/v1.2.4"
    sha256 cellar: :any_skip_relocation, all: "bcf5207484a843ed433c625ffd7a5705286d6c49f2300f45cfd921c1bab183b8"
  end

  def install
    bin.install "server/bluepill_server.py" => "bluepill-server"
    bin.install_symlink "bluepill-server" => "imsgd"
  end

  def post_install
    help_out = Utils.safe_popen_read(bin/"bluepill-server", "--help")
    if help_out.include?("preflight")
      system bin/"bluepill-server", "preflight", "--no-fix"
    else
      system bin/"bluepill-server", "--selftest"
    end
  rescue StandardError
    nil
  end

  def caveats
    <<~EOS
      BluePill Cloud Relay (Zero Port-Forwarding — Recommended):
        1. Claim your free beta relay endpoint & tunnel token:
           https://bluepill.nertwork.com/signup
        2. Pair this Mac and start the background relay + Cloud Relay tunnel:
           bluepill-server relay-setup --token <YOUR_TUNNEL_TOKEN>
           brew services start bluepill

      Local-Only / iCloud Hub Preflight:
        Verify Full Disk Access for Messages, Notes, Calendar, and Photos:
          bluepill-server preflight
        Check Cloud Relay status at any time:
          bluepill-server relay-status

      All three iCloud Hub modules (Notes, Calendar, Photos) are enabled by default
      and configured in ~/.config/bluepill/server.json (relay config in ~/.config/bluepill/relay.json).
      Run local-only without Cloud Relay using: bluepill-server serve --no-relay
    EOS
  end

  service do
    run [opt_bin/"bluepill-server", "serve", "--port", "1235"]
    keep_alive true
    working_dir var
    log_path var/"log/bluepill-server.log"
    error_log_path var/"log/bluepill-server.err.log"
  end

  test do
    assert_match "bluepill-server 1.2.4", shell_output("#{bin}/bluepill-server --version")
    help_out = shell_output("#{bin}/bluepill-server --help")
    if help_out.include?("preflight")
      assert_match "\"status\":", shell_output("#{bin}/bluepill-server preflight --no-fix")
    else
      system bin/"bluepill-server", "--selftest"
    end
  end
end
