NETWORK="standalone"
SOROBAN_RPC_HOST="http://stellar:8000"
SOROBAN_RPC_URL="$SOROBAN_RPC_HOST/soroban/rpc"
FRIENDBOT_URL="$SOROBAN_RPC_HOST/friendbot"
SOROBAN_NETWORK_PASSPHRASE="Standalone Network ; February 2017"

echo Adding network
soroban config network add "$NETWORK" \
  --rpc-url "$SOROBAN_RPC_URL" \
  --network-passphrase "$SOROBAN_NETWORK_PASSPHRASE"
echo ---

soroban config identity generate my-account
MY_ACCOUNT_ADDRESS="$(soroban config identity address my-account)"
curl  --silent -X POST "$FRIENDBOT_URL?addr=$MY_ACCOUNT_ADDRESS" > /dev/null
ARGS="--network standalone --source-account my-account"

echo Wrapping token
TOKEN_ADDRESS=$(soroban lab token wrap $ARGS --asset native)
echo Wrapped with address result: $TOKEN_ADDRESS
echo ---

echo Wrapping might fail if it was done before, so we are also getting the address:
TOKEN_ADDRESS="$(soroban lab token id --asset native --network standalone)"
echo Native token address: $TOKEN_ADDRESS
echo ---

echo Creating my-account identity
soroban config identity generate my-account
MY_ACCOUNT_ADDRESS="$(soroban config identity address my-account)"
curl  --silent -X POST "$FRIENDBOT_URL?addr=$MY_ACCOUNT_ADDRESS" > /dev/null
echo my-account was created: $MY_ACCOUNT_ADDRESS
echo ---

echo Creating donor identity
soroban config identity generate donor
DONOR="$(soroban config identity address donor)"
curl  --silent -X POST "$FRIENDBOT_URL?addr=$DONOR" > /dev/null
echo donor was created: $DONOR
echo ---

echo Creating recipient identity
soroban config identity generate recipient
RECIPIENT="$(soroban config identity address recipient)"
curl  --silent -X POST "$FRIENDBOT_URL?addr=$RECIPIENT" > /dev/null
echo recipient was created: $RECIPIENT
echo ---
echo ---

###########
echo Deploy the donations contract:
cd /workspace/contracts/donations
make build
WASM=/workspace/contracts/donations/target/wasm32-unknown-unknown/release/donations.wasm
DONATIONS_ID="$(
    soroban contract deploy $ARGS \
    --wasm $WASM
)"
echo Contract was deployed with address: $DONATIONS_ID
echo ---

echo Initialize the donations contract with native token address: $TOKEN_ADDRESS
soroban contract invoke $ARGS --wasm $WASM --id $DONATIONS_ID \
        -- initialize \
        --recipient $RECIPIENT \
        --token $TOKEN_ADDRESS
echo Contract initialized
echo ---

# ANSI color codes
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color


echo Lets check the accepted token in contract
    RESULT=$(soroban contract invoke $ARGS --wasm $WASM --id $DONATIONS_ID -- token)
    bash /workspace/compare.sh \"$TOKEN_ADDRESS\" $RESULT
echo "---"


echo Lets check the recipient of the donations
    RESULT=$(soroban contract invoke $ARGS --wasm $WASM --id $DONATIONS_ID -- recipient)
    bash /workspace/compare.sh \"$RECIPIENT\" $RESULT
echo "---"

echo Just as a workaround, the donor needs more XML in order to have the minimum XML to pay for the fees. Otherwise it wont be able to send
echo MY-ACCOUNT will send 1000000000 stroops to DONOR
soroban contract invoke   --network standalone --source-account my-account  --id "$TOKEN_ADDRESS"   --   transfer   --from $MY_ACCOUNT_ADDRESS   --to $DONOR  --amount 1000000000

echo Checking initial balance of donor
soroban contract invoke   --network standalone --source-account my-account  --id "$TOKEN_ADDRESS"   --   balance   --id $DONOR
node /workspace/getInfoXLM.js $DONOR
echo "---"

echo Checking initial balance of recipient
soroban contract invoke   --network standalone --source-account my-account  --id "$TOKEN_ADDRESS"   --   balance   --id $RECIPIENT
node /workspace/getInfoXLM.js $RECIPIENT
echo "---"

echo Checking initial balance of the donations contract
soroban contract invoke   --network standalone --source-account my-account  --id "$TOKEN_ADDRESS"   --   balance   --id $DONATIONS_ID
# node /workspace/getInfoXLM.js $DONATIONS_ID
echo "---"
echo "---"
echo "---"
echo "---"
echo THE FIRST CALL TO THE CONTRACT WILL FAIL... WHY????
echo Donor donates 5 stroops to the contract
soroban contract invoke   --network standalone \
        --source-account donor  --id "$DONATIONS_ID" --fee 1000000 \
        --   donate   --donor $DONOR   --amount 5
echo "---"
echo "---"
echo "---"
echo "---"

echo Donor donates 5 stroops to the contract
soroban contract invoke   --network standalone \
        --source-account donor  --id "$DONATIONS_ID" --fee 1000000 \
        --   donate   --donor $DONOR   --amount 5

echo Checking new balance of the donations contract ... should be 5 ...
soroban contract invoke   --network standalone --source-account my-account  --id "$TOKEN_ADDRESS"   --   balance   --id $DONATIONS_ID
echo "---"


echo Donor donates 7 stroops to the contract
soroban contract invoke   --network standalone \
        --source-account donor  --id "$DONATIONS_ID" --fee 1000000 \
        --   donate   --donor $DONOR   --amount 7

echo Checking new balance of the donations contract ... should be 12 ...
soroban contract invoke   --network standalone --source-account my-account  --id "$TOKEN_ADDRESS"   --   balance   --id $DONATIONS_ID
echo "---"

echo Recipient withdraw the total balance inside the donations contract
soroban contract invoke   --network standalone \
        --source-account donor  --id "$DONATIONS_ID" \
        --   withdraw

echo Checking new balance of recipient ... should be 100000000012 ...
soroban contract invoke   --network standalone --source-account my-account  --id "$TOKEN_ADDRESS"   --   balance   --id $RECIPIENT
node /workspace/getInfoXLM.js $RECIPIENT
echo "---"

echo Checking final balance of donations contract ... should be 0 ...
soroban contract invoke   --network standalone --source-account my-account  --id "$TOKEN_ADDRESS"   --   balance   --id $DONATIONS_ID
echo "---"
