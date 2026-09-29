#!/usr/bin/env bash
# User tool — invocations signed by the investor / token holder.
# Uso: ./user-tool.sh invest <monto> | balance | transfer <monto>
# Replace placeholders (or export env vars) before running on testnet.

set -euo pipefail

NETWORK="${NETWORK:-testnet}"
USER_KEY="${USER_KEY:-bob}"
CONTRACT_ID="${CONTRACT_ID:-C...DEPLOYED_LAUNCHPAD_CONTRACT_ID...}"
RECIPIENT="${RECIPIENT:-G...RECIPIENT_PUBLIC_KEY...}"
USER_ADDR="$(stellar keys address "$USER_KEY")"

invoke() {
  stellar contract invoke --id "$CONTRACT_ID" --source "$USER_KEY" --network "$NETWORK" "$@"
}

case "${1:-}" in
  invest)
    echo "=== invest ${2:-500} ==="
    invoke -- invest --investor "$USER_ADDR" --payment_amount "${2:-500}" ;;
  balance)
    echo "=== balance ==="
    invoke -- balance --id "$USER_ADDR" ;;
  transfer)
    echo "=== transfer RWA tokens ==="
    invoke -- transfer --from "$USER_ADDR" --to "$RECIPIENT" --amount "${2:-1}" ;;
  *) echo "Uso: $0 invest <monto> | balance | transfer <monto>"; exit 1 ;;
esac
