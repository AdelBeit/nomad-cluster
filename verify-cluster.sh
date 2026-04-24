#!/bin/bash
set -e

LOG_FILE="/tmp/verify-cluster.log"
exec > >(tee -a "$LOG_FILE")
exec 2>&1

echo "[$(date '+%Y-%m-%d %H:%M:%S')] === Cluster verification started ==="

section() {
  echo ""
  echo "════════════════════════════════════════"
  echo "$1"
  echo "════════════════════════════════════════"
}

check_file() {
  if [ -f "$1" ]; then
    echo "✓ $1 exists"
    return 0
  else
    echo "✗ $1 NOT FOUND"
    return 1
  fi
}

section "Provisioning checkpoint files"
check_file /tmp/node-install-complete || echo "⚠ Node installation may have failed"
check_file /tmp/server-launch-complete || echo "⚠ Server launch may have failed"
check_file /tmp/client-launch-complete || echo "⚠ Client launch may have failed"

section "Provisioning log files"
[ -f /tmp/provision.log ] && echo "✓ provision.log ($(wc -l < /tmp/provision.log) lines)" || echo "✗ provision.log NOT FOUND"
[ -f /tmp/launch-server.log ] && echo "✓ launch-server.log ($(wc -l < /tmp/launch-server.log) lines)" || echo "✗ launch-server.log NOT FOUND"
[ -f /tmp/launch-client.log ] && echo "✓ launch-client.log ($(wc -l < /tmp/launch-client.log) lines)" || echo "✗ launch-client.log NOT FOUND"

section "Binaries installed"
which nomad && echo "✓ nomad: $(nomad version | head -1)" || echo "✗ nomad NOT FOUND"
which consul && echo "✓ consul: $(consul version | head -1)" || echo "✗ consul NOT FOUND"
which docker && echo "✓ docker: $(docker --version)" || echo "✗ docker NOT FOUND"

section "Systemd service status"
echo "--- Consul status ---"
systemctl status consul 2>&1 | grep -E "Active|loaded" || echo "⚠ Consul service issue"

echo ""
echo "--- Nomad status ---"
systemctl status nomad 2>&1 | grep -E "Active|loaded" || echo "⚠ Nomad service issue"

echo ""
echo "--- Docker status ---"
systemctl status docker 2>&1 | grep -E "Active|loaded" || echo "⚠ Docker service issue"

section "Cluster membership"
echo "--- Nomad server members ---"
nomad server members 2>&1 || echo "✗ Failed to get Nomad server members"

echo ""
echo "--- Nomad node status ---"
nomad node status 2>&1 || echo "✗ Failed to get Nomad node status"

echo ""
echo "--- Consul members ---"
consul members 2>&1 || echo "✗ Failed to get Consul members"

section "Configuration files"
echo "--- Consul server config ---"
[ -f /etc/consul.d/consul.hcl ] && echo "✓ Found" || echo "✗ NOT FOUND"

echo ""
echo "--- Nomad server config ---"
[ -f /etc/nomad.d/nomad.hcl ] && echo "✓ Found" || echo "✗ NOT FOUND"

section "Network connectivity"
echo "--- Local interface (eth1) ---"
ip addr show eth1 2>&1 | grep -E "inet " || echo "⚠ eth1 not configured"

echo ""
echo "--- Network routes ---"
ip route 2>&1 | head -5

section "Recent service logs (last 10 lines)"
echo "--- Consul logs ---"
journalctl -u consul -n 10 --no-pager 2>&1 || echo "⚠ Could not retrieve Consul logs"

echo ""
echo "--- Nomad logs ---"
journalctl -u nomad -n 10 --no-pager 2>&1 || echo "⚠ Could not retrieve Nomad logs"

echo ""
echo "[$(date '+%Y-%m-%d %H:%M:%S')] === Verification complete ==="
echo "Full logs available at:"
echo "  $LOG_FILE"
echo "  /tmp/provision.log"
echo "  /tmp/launch-server.log"
echo "  /tmp/launch-client.log"
