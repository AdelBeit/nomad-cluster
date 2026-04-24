#!/bin/bash
# Helper script to retrieve logs from Vagrant VMs for debugging

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOGS_DIR="$SCRIPT_DIR/logs"
mkdir -p "$LOGS_DIR"

echo "Retrieving logs from Vagrant VMs..."
echo "Logs will be saved to: $LOGS_DIR"
echo ""

# Function to get logs from a specific VM
get_vm_logs() {
  local vm_name=$1
  local vm_logs_dir="$LOGS_DIR/$vm_name"
  mkdir -p "$vm_logs_dir"

  echo "Retrieving logs from $vm_name..."

  # Files to retrieve
  local files=(
    "/tmp/provision.log"
    "/tmp/launch-server.log"
    "/tmp/launch-client.log"
    "/tmp/verify-cluster.log"
  )

  for file in "${files[@]}"; do
    local filename=$(basename "$file")
    if vagrant ssh "$vm_name" -- [ -f "$file" ] 2>/dev/null; then
      vagrant ssh "$vm_name" -- cat "$file" > "$vm_logs_dir/$filename" 2>/dev/null || true
      echo "  ✓ Retrieved $filename"
    fi
  done

  # Get systemd journal
  echo "  Retrieving systemd journals..."
  vagrant ssh "$vm_name" -- sudo journalctl -u consul -n 100 --no-pager > "$vm_logs_dir/consul.journal" 2>/dev/null || true
  vagrant ssh "$vm_name" -- sudo journalctl -u nomad -n 100 --no-pager > "$vm_logs_dir/nomad.journal" 2>/dev/null || true
  vagrant ssh "$vm_name" -- sudo journalctl -u docker -n 50 --no-pager > "$vm_logs_dir/docker.journal" 2>/dev/null || true

  echo "  ✓ Journals saved"
  echo ""
}

# Get logs from all VMs
cd "$SCRIPT_DIR"
vagrant global-status --prune | grep "nomad-cluster" | awk '{print $2}' | while read -r vm_name; do
  if [ ! -z "$vm_name" ]; then
    get_vm_logs "$vm_name"
  fi
done

echo "Log retrieval complete!"
echo ""
echo "Logs available at:"
find "$LOGS_DIR" -type f -exec echo "  {}" \;
