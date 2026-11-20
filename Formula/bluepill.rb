class Bluepill < Formula
  desc "Headless zero-Electron macOS iMessage, SMS & RCS relay daemon + Cloud Relay + Web UI for BluePill"
  homepage "https://bluepill.nertwork.com"
  url "https://github.com/nertwork/bluepill/archive/refs/tags/v1.2.7.tar.gz"
  sha256 "3beeb0b1386f6cc5183106c25a9e72dca3b1c0a5c9c5cd23"
  version "1.2.7"
  license "MIT"
  head "https://github.com/nertwork/bluepill.git", branch: "main"

  bottle do
    root_url "https://github.com/nertwork/bluepill/releases/download/v1.2.7"
    sha256 cellar: :any_skip_relocation, all: "19a9e06a9f2382063c179b39ddaf69d3a7e944f75ab5bb0e0132b4ecad2d1570"
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
    assert_match "bluepill-server 1.2.7", shell_output("#{bin}/bluepill-server --version")
    help_out = shell_output("#{bin}/bluepill-server --help")
    if help_out.include?("preflight")
      assert_match "\"status\":", shell_output("#{bin}/bluepill-server preflight --no-fix")
    else
      system bin/"bluepill-server", "--selftest"
    end
  end
end
