class Bluepill < Formula
  desc "Headless zero-Electron macOS iMessage, SMS & RCS relay daemon + Cloud Relay + Web UI for BluePill"
  homepage "https://bluepill.nertwork.com"
  url "https://github.com/nertwork/bluepill/archive/refs/tags/v1.2.5.tar.gz"
  sha256 "62ea3a6578892ce8a9e089a9d1d96c72c79f6f3d5e6978ed058fc89790f896c2"
  version "1.2.5"
  license "MIT"
  head "https://github.com/nertwork/bluepill.git", branch: "main"

  bottle do
    root_url "https://github.com/nertwork/bluepill/releases/download/v1.2.5"
    sha256 cellar: :any_skip_relocation, all: "a93a15dcc63d5996371ea95833d781e306a0261d6078b9a1baa94dd214475ccb"
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
    assert_match "bluepill-server 1.2.5", shell_output("#{bin}/bluepill-server --version")
    help_out = shell_output("#{bin}/bluepill-server --help")
    if help_out.include?("preflight")
      assert_match "\"status\":", shell_output("#{bin}/bluepill-server preflight --no-fix")
    else
      system bin/"bluepill-server", "--selftest"
    end
  end
end
