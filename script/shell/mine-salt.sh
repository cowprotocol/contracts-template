#!/usr/bin/env bash
set -euo pipefail

# Utility for mining CREATE2 salts for a compiled contract.
# Supports optional address prefix/suffix filters and arbitrary constructor arguments.
# 
# It would ideally be used with https://github.com/Arachnid/deterministic-deployment-proxy 
#
# Examples:
#
#   # Mine an address starting with 0x0000 for a no-arg contract
#   ./script/shell/mine-salt.sh \
#       --deployer 0x4e59b44847b379578588920cA78FbF26c0B4956C \
#       --contract src/MyContract.sol:MyContract \
#       --starts-with 0000
#
#   # Mine an address ending in 0xdead with a constructor that takes (address, uint256)
#   ./script/shell/mine-salt.sh \
#       --deployer 0x4e59b44847b379578588920cA78FbF26c0B4956C \
#       --contract MyContract \
#       --ends-with dead \
#       --ctor-signature "constructor(address,uint256)" \
#       --ctor-arg 0x1111111111111111111111111111111111111111 \
#       --ctor-arg 42
#
#   # Same as above, but pass all constructor args after --ctor-args (must be last)
#   ./script/shell/mine-salt.sh \
#       --deployer 0x4e59b44847b379578588920cA78FbF26c0B4956C \
#       --contract MyContract \
#       --starts-with beef --ends-with cafe \
#       --ctor-signature "constructor(address,uint256)" \
#       --ctor-args 0x1111111111111111111111111111111111111111 42

DEPLOYER=""
CONTRACT=""
STARTS_WITH=""
ENDS_WITH=""
CTOR_SIG=""
CTOR_ARGS=()

usage() {
    cat <<EOF
Usage:
  $0 --deployer ADDRESS --contract CONTRACT [options]

Options:
  --deployer ADDRESS              CREATE2 deployer address
  --contract CONTRACT             Forge contract identifier/path
  --starts-with HEX               Optional address prefix filter
  --ends-with HEX                 Optional address suffix filter
  --ctor-signature SIGNATURE      Constructor ABI signature, e.g. "constructor(address,uint256)"
  --ctor-arg VALUE                Constructor argument; may be repeated
  --ctor-args VALUE...            Constructor arguments; consumes the remaining CLI args
EOF
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        --deployer)
            DEPLOYER="$2"
            shift 2
            ;;
        --contract)
            CONTRACT="$2"
            shift 2
            ;;
        --starts-with)
            STARTS_WITH="$2"
            shift 2
            ;;
        --ends-with)
            ENDS_WITH="$2"
            shift 2
            ;;
        --ctor-signature)
            CTOR_SIG="$2"
            shift 2
            ;;
        --ctor-arg)
            CTOR_ARGS+=("$2")
            shift 2
            ;;
        --ctor-args)
            shift
            CTOR_ARGS+=("$@")
            break
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        *)
            echo "Unknown parameter: $1"
            usage
            exit 1
            ;;
    esac
done

[[ -z "$DEPLOYER" ]] && { echo "Error: --deployer is required"; exit 1; }
[[ -z "$CONTRACT" ]] && { echo "Error: --contract is required"; exit 1; }

if [[ ${#CTOR_ARGS[@]} -gt 0 && -z "$CTOR_SIG" ]]; then
    echo "Error: --ctor-signature is required when constructor args are provided"
    exit 1
fi

RAW_BYTECODE=$(forge inspect "$CONTRACT" bytecode)

if [[ -n "$CTOR_SIG" ]]; then
    ENCODED_ARGS=$(cast abi-encode "$CTOR_SIG" "${CTOR_ARGS[@]}")
    INIT_CODE="${RAW_BYTECODE}${ENCODED_ARGS:2}"
else
    INIT_CODE="$RAW_BYTECODE"
fi

INIT_CODE_HASH=$(cast keccak "$INIT_CODE")

echo
echo ">>> Running CREATE2 address miner..."
echo "Deployer:        $DEPLOYER"
echo "Contract:        $CONTRACT"
echo "Starts with:     ${STARTS_WITH:-<none>}"
echo "Ends with:       ${ENDS_WITH:-<none>}"
if [[ -n "$CTOR_SIG" ]]; then
    echo "Constructor:     '$CTOR_SIG'"
    echo "Arguments:       ${CTOR_ARGS[*]:-<none>}"
fi
echo "Init code hash:  $INIT_CODE_HASH"
echo

CMD=(cast create2 --deployer "$DEPLOYER" --init-code-hash "$INIT_CODE_HASH")

[[ -n "$STARTS_WITH" ]] && CMD+=(--starts-with "$STARTS_WITH")
[[ -n "$ENDS_WITH" ]] && CMD+=(--ends-with "$ENDS_WITH")

"${CMD[@]}" | awk '/Successfully found contract address/,0'
echo