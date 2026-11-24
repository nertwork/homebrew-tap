class Bluepill < Formula
  desc "Headless zero-Electron macOS iMessage, SMS & RCS relay daemon + Cloud Relay + Web UI for BluePill"
  homepage "https://bluepill.nertwork.com"
  url "https://github.com/nertwork/bluepill/archive/refs/tags/v1.2.13.tar.gz"
  sha256 "b5ef27eb73e6b7a07cb5c9c305b10f3ebb6b3fb154691e5b24aafb74e4b8b1d9"
  version "1.2.13"
  license "MIT"
  head "https://github.com/nertwork/bluepill.git", branch: "main"

  bottle do
    root_url "https://github.com/nertwork/bluepill/releases/download/v1.2.13"
    sha256 cellar: :any_skip_relocation, all: "f3f887dec14fa445ce69e0ce31cd67a200ac44bd8acc060a58b8ed6dd17dc0d0"
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
      BluePill Cloud Setup (Default — Zero Port-Forwarding):
        1. bluepill-server login
           (Opens https://bluepill.nertwork.com/portal to link your Mac to BluePill Cloud)
        2. brew services start bluepill
        3. Grant macOS Permissions (System Settings -> Privacy & Security):
           - Full Disk Access: allow Terminal / Homebrew Python (reads chat.db, Notes, Calendar, Photos)
           - Automation -> Messages: allow Python / bluepill-server to control Messages.app (required for sending)
        4. Verify everything is green:
           bluepill-server doctor

      Cloud Managed Updates (BluePill Cloud Perk):
        When linked to BluePill Cloud, background stable update checks run
        automatically and require explicit confirmation in the UI or via:
          bluepill-server update-status
          bluepill-server update --confirm

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
    assert_match "bluepill-server 1.2.13", shell_output("#{bin}/bluepill-server --version")
    help_out = shell_output("#{bin}/bluepill-server --help")
    if help_out.include?("preflight")
      assert_match "\"status\":", shell_output("#{bin}/bluepill-server preflight --no-fix")
    else
      system bin/"bluepill-server", "--selftest"
    end
  end
end
