#!/usr/bin/env bash
# Admin tool — invocations that require the issuer/admin key to sign.
# Uso: ./admin-tool.sh <init|whitelist|mint|withdraw|pause|unpause|all>
# Replace placeholders (or export env vars) before running on testnet.

set -euo pipefail

NETWORK="${NETWORK:-testnet}"
ADMIN_KEY="${ADMIN_KEY:-alice}"
CONTRACT_ID="${CONTRACT_ID:-C...DEPLOYED_LAUNCHPAD_CONTRACT_ID...}"
PAYMENT_TOKEN="${PAYMENT_TOKEN:-C...INSTRUCTOR_PAYMENT_TOKEN_ID...}"
INVESTOR="${INVESTOR:-G...INVESTOR_PUBLIC_KEY...}"
TREASURY="${TREASURY:-G...TREASURY_PUBLIC_KEY...}"
ADMIN_ADDR="$(stellar keys address "$ADMIN_KEY")"

invoke() {
  stellar contract invoke --id "$CONTRACT_ID" --source "$ADMIN_KEY" --network "$NETWORK" -- "$@"
}

do_init() {
  echo "=== initialize (run once after deploy) ==="
  invoke initialize --admin "$ADMIN_ADDR" \
    --asset '{"name":"RWAToken","total_supply":1000000,"price_per_unit":100,"payment_token":"'"$PAYMENT_TOKEN"'","paused":false}'
}
do_whitelist() {
  echo "=== set_whitelist ==="
  invoke set_whitelist --admin "$ADMIN_ADDR" --investor "$INVESTOR" --approved true
}
do_mint() {
  echo "=== mint (admin-only; optional if using invest) ==="
  invoke mint --admin "$ADMIN_ADDR" --to "$INVESTOR" --amount 100
}
do_withdraw() {
  echo "=== withdraw collected payment tokens ==="
  invoke withdraw --admin "$ADMIN_ADDR" --to "$TREASURY" --amount "${AMOUNT:-500}"
}
do_pause()   { echo "=== pause ===";   invoke pause   --admin "$ADMIN_ADDR"; }
do_unpause() { echo "=== unpause ==="; invoke unpause --admin "$ADMIN_ADDR"; }

case "${1:-}" in
  init)      do_init ;;
  whitelist) do_whitelist ;;
  mint)      do_mint ;;
  withdraw)  do_withdraw ;;
  pause)     do_pause ;;
  unpause)   do_unpause ;;
  all)       do_init; do_whitelist; do_mint; do_withdraw; do_pause; do_unpause ;;
  *) echo "Uso: $0 <init|whitelist|mint|withdraw|pause|unpause|all>"; exit 1 ;;
esac
