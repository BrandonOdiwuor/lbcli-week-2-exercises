#!/bin/bash

# Import helper functions
source submission/functions.sh

# Week Two Exercise: Advanced Bitcoin Transaction
# This script combines concepts from previous exercises into a comprehensive challenge

# Ensure script fails fast on errors
set -e

# ======================================================================
# SETUP - These transactions are provided for the challenges
# ======================================================================

echo "========================================================"
echo "🚀 ADVANCED BITCOIN TRANSACTION MASTERY CHALLENGE 🚀"
echo "========================================================"
echo ""
echo "Welcome to the final challenge! In this exercise, you'll"
echo "demonstrate your mastery of Bitcoin transactions by"
echo "completing a series of increasingly complex tasks."
echo ""
echo "Each task builds on concepts from previous exercises."
echo "Let's begin your journey to becoming a Bitcoin transaction expert!"
echo ""

# Base transaction data from previous exercises
BASE_TX="01000000000101c8b0928edebbec5e698d5f86d0474595d9f6a5b2e4e3772cd9d1005f23bdef772500000000ffffffff0276b4fa0000000000160014f848fe5267491a8a5d32423de4b0a24d1065c6030e9c6e000000000016001434d14a23d2ba08d3e3edee9172f0c97f046266fb0247304402205fee57960883f6d69acf283192785f1147a3e11b97cf01a210cf7e9916500c040220483de1c51af5027440565caead6c1064bac92cb477b536e060f004c733c45128012102d12b6b907c5a1ef025d0924a29e354f6d7b1b11b5a7ddff94710d6f0042f3da800000000"

SECONDARY_TX="0200000000010182aabd8115c43e5b37a1b0c77a409b229896a2ffd255098c8056a954f9651d0b0000000000fdffffff023007000000000000160014618be8a3b3a80d01503de9255f6be79ffd2f91f2c89e0000000000001600146566e3df810b10943b851073bd0363d38f24901602473044022072afb72deafbb9b5716e5b48d5e32e3bfed34c03d291e6cd3dd06cf4a7bd118e0220630d076cb5ada15a401d0c63c30e9b392c6cd3ce11137d966e42c40be9971d700121025798c893c7930231e4254a2b79c64acd5d81811ae6d6a46de29257849b5705e800000000"

# For the signing challenge, we'll need a private key
# This is a testnet private key - NEVER use this in production!
TEST_PRIVATE_KEY="cVpPVruEDdmutPzisxssTtJhZijbZq4zwiFhCbvtJBRPPiaDiMWK"
TEST_ADDRESS="mz3SbJEHKQGYJFCFXUHJYPZx1rNJ6zNdkn"

# Set up RPC connection parameters (modify these to match your setup)
rpcuser="btrust"
rpcpassword="builder"
rpcport="18443"

# =========================================================================
# CHALLENGE 1: Transaction Decoding - Identify transaction components
# =========================================================================
echo "CHALLENGE 1: Transaction Analysis"
echo "--------------------------------"
echo "To begin working with transactions, you must first understand their structure."
echo "Decode the provided transaction and extract key information."
echo ""
echo "Transaction hex: ${BASE_TX:0:64}... (truncated)"
echo ""

# STUDENT TASK: Decode the transaction to get the TXID
# WRITE YOUR SOLUTION BELOW:
TXID=$(bitcoin-cli -regtest decoderawtransaction "$BASE_TX" | jq -r '.txid')
check_cmd "Transaction decoding" "TXID" "$TXID"

echo "Transaction ID: $TXID"

# STUDENT TASK: Extract the number of inputs and outputs from the transaction
# WRITE YOUR SOLUTION BELOW:
NUM_INPUTS=$(bitcoin-cli -regtest decoderawtransaction "$BASE_TX" | jq '.vin | length')
check_cmd "Input counting" "NUM_INPUTS" "$NUM_INPUTS"

NUM_OUTPUTS=$(bitcoin-cli -regtest decoderawtransaction "$BASE_TX" | jq '.vout | length')
check_cmd "Output counting" "NUM_OUTPUTS" "$NUM_OUTPUTS"

echo "Number of inputs: $NUM_INPUTS"
echo "Number of outputs: $NUM_OUTPUTS"

# STUDENT TASK: Extract the value of the first output in satoshis
# WRITE YOUR SOLUTION BELOW:
FIRST_OUTPUT_VALUE=$(bitcoin-cli -regtest decoderawtransaction "$BASE_TX" | jq '.vout[0].value * 100000000 | floor')
check_cmd "Output value extraction" "FIRST_OUTPUT_VALUE" "$FIRST_OUTPUT_VALUE"

echo "First output value: $FIRST_OUTPUT_VALUE satoshis"

# =========================================================================
# CHALLENGE 2: UTXO Selection - Identify and select appropriate UTXOs
# =========================================================================
echo ""
echo "CHALLENGE 2: UTXO Selection"
echo "--------------------------"
echo "Every Bitcoin transaction spends existing UTXOs. For this challenge, you'll"
echo "identify and select the appropriate UTXOs for a new transaction."
echo ""
echo "You want to create a transaction spending 15,000,000 satoshis."
echo "Select UTXOs from the decoded transaction that will cover this amount."
echo ""

# STUDENT TASK: Extract the available UTXOs from the decoded transaction for spending
# WRITE YOUR SOLUTION BELOW:
UTXO_TXID=$TXID
UTXO_VOUT=0
check_cmd "UTXO vout selection" "UTXO_VOUT" "$UTXO_VOUT"

UTXO_VALUE=$FIRST_OUTPUT_VALUE
check_cmd "UTXO value extraction" "UTXO_VALUE" "$UTXO_VALUE"

echo "Selected UTXO:"
echo "TXID: $UTXO_TXID"
echo "Vout: $UTXO_VOUT"
echo "Value: $UTXO_VALUE satoshis"

# Validate selection
if [ "$UTXO_VALUE" -ge 15000000 ]; then
  echo "✅ This UTXO is sufficient for spending 15,000,000 satoshis!"
else
  echo "❌ Selected UTXO doesn't have enough funds! Need at least 15,000,000 satoshis."
  exit 1
fi

# =========================================================================
# CHALLENGE 3: Fee Calculation - Calculate appropriate transaction fees
# =========================================================================
echo ""
echo "CHALLENGE 3: Fee Calculation"
echo "---------------------------"
echo "Every Bitcoin transaction requires a fee to be included in a block."
echo "For this transaction, calculate a fee based on transaction size."
echo ""
echo "Assume a fee rate of 10 satoshis/vbyte. The transaction will have:"
echo "- 1 input (from your selected UTXO)"
echo "- 2 outputs (payment and change)"
echo ""

# Information about approximate transaction sizes (simplified for exercise)
echo "Approximate transaction components:"
echo "- Base transaction: 10 vbytes"
echo "- Each input: 68 vbytes"
echo "- Each output: 31 vbytes"
echo ""

# STUDENT TASK: Calculate the approximate transaction size and fee
# WRITE YOUR SOLUTION BELOW:
TX_SIZE=$((10 + 68 + 2 * 31))
check_cmd "Transaction size calculation" "TX_SIZE" "$TX_SIZE"

FEE_SATS=$((TX_SIZE * FEE_RATE))
check_cmd "Fee calculation" "FEE_SATS" "$FEE_SATS"

echo "Estimated transaction size: $TX_SIZE vbytes"
echo "Calculated fee: $FEE_SATS satoshis"

# For this exercise, we're checking if the fee is in a reasonable range
if [ "$FEE_SATS" -lt 1000 ] || [ "$FEE_SATS" -gt 5000 ]; then
  echo "⚠️ Warning: Fee seems unusual. Double-check your calculation."
else
  echo "✅ Fee amount seems reasonable!"
fi

# =========================================================================
# CHALLENGE 4: Create Raw Transaction - Build a raw transaction with RBF
# =========================================================================
echo ""
echo "CHALLENGE 4: Creating a Raw Transaction with RBF"
echo "----------------------------------------------"
echo "Now it's time to create a raw transaction that spends your selected UTXO."
echo "The transaction should:"
echo "- Enable Replace-By-Fee (RBF)"
echo "- Send 15,000,000 satoshis to the address: 2MvLcssW49n9atmksjwg2ZCMsEMsoj3pzUP"
echo "- Return the change to: tb1q0qnpz463d4lvcadx39yd3jzgcz694f6v83x6v0"
echo "- Include the appropriate fee you calculated"
echo ""

# STUDENT TASK: Create the input JSON structure with RBF enabled
# HINT: RBF is enabled by setting the sequence number to less than 0xffffffff-1
# WRITE YOUR SOLUTION BELOW:
PAYMENT_ADDRESS="2MvLcssW49n9atmksjwg2ZCMsEMsoj3pzUP"
CHANGE_ADDRESS="tb1q0qnpz463d4lvcadx39yd3jzgcz694f6v83x6v0"

# STUDENT TASK: Create a proper input JSON for createrawtransaction
TX_INPUTS='[{"txid":"'$UTXO_TXID'","vout":'$UTXO_VOUT',"sequence":4294967293}]'
check_cmd "Input JSON creation" "TX_INPUTS" "$TX_INPUTS"

# Verify RBF is enabled in the input structure
if [[ "$TX_INPUTS" == *"sequence"* ]] && [[ "$TX_INPUTS" != *"4294967295"* ]]; then
  echo "✅ RBF appears to be enabled!"
else
  echo "⚠️ Warning: RBF might not be properly enabled. Check your sequence number."
fi

# STUDENT TASK: Calculate the change amount
PAYMENT_AMOUNT=15000000  # in satoshis
CHANGE_AMOUNT=
check_cmd "Change calculation" "CHANGE_AMOUNT" "$CHANGE_AMOUNT"

# Convert amounts to BTC for createrawtransaction
PAYMENT_BTC=$(echo "scale=8; $PAYMENT_AMOUNT / 100000000" | bc)
CHANGE_BTC=$(echo "scale=8; $CHANGE_AMOUNT / 100000000" | bc)

# STUDENT TASK: Create the outputs JSON structure
TX_OUTPUTS=$((UTXO_VALUE - PAYMENT_AMOUNT - FEE_SATS))
check_cmd "Output JSON creation" "TX_OUTPUTS" "$TX_OUTPUTS"

# STUDENT TASK: Create the raw transaction
RAW_TX=$(bitcoin-cli -regtest createrawtransaction "$TX_INPUTS" "$TX_OUTPUTS")
check_cmd "Raw transaction creation" "RAW_TX" "$RAW_TX"

echo "Successfully created raw transaction!"
echo "Raw transaction hex: ${RAW_TX:0:64}... (truncated)"

# =========================================================================
# CHALLENGE 5: Transaction Verification - Decode and verify the transaction
# =========================================================================
echo ""
echo "CHALLENGE 5: Transaction Verification"
echo "-----------------------------------"
echo "Before broadcasting any transaction, it's crucial to verify its contents."
echo "Decode your transaction and verify it meets the requirements."
echo ""

# STUDENT TASK: Decode the raw transaction
# WRITE YOUR SOLUTION BELOW:
DECODED_TX=$(bitcoin-cli -regtest decoderawtransaction "$RAW_TX")
check_cmd "Transaction decoding" "DECODED_TX" "$DECODED_TX"

# STUDENT TASK: Extract and verify the key components from the decoded transaction
# WRITE YOUR SOLUTION BELOW:
VERIFY_RBF=$(echo "$DECODED_TX" | jq -r '.vin[0].sequence < 4294967294' 2>/dev/null || echo "false")
check_cmd "RBF verification" "VERIFY_RBF" "$VERIFY_RBF"

VERIFY_PAYMENT=$(echo "$DECODED_TX" | jq -r '.vout[] | select(.scriptPubKey.addresses[] == "'$PAYMENT_ADDRESS'") | .value' 2>/dev/null || echo "0")
check_cmd "Payment verification" "VERIFY_PAYMENT" "$VERIFY_PAYMENT"

VERIFY_CHANGE=$(echo "$DECODED_TX" | jq -r '.vout[] | select(.scriptPubKey.address == "'$CHANGE_ADDRESS'" or .scriptPubKey.addresses[] == "'$CHANGE_ADDRESS'") | .value' 2>/dev/null || echo "0")
check_cmd "Change verification" "VERIFY_CHANGE" "$VERIFY_CHANGE"

# STUDENT TASK: Check if the transaction is flagged as BIP125 replaceable
# WRITE YOUR SOLUTION BELOW:
BIP125_REPLACEABLE=$(echo "$DECODED_TX" | jq -r '."bip125-replaceable" == "yes"' 2>/dev/null || echo "false")
check_cmd "BIP125 verification" "BIP125_REPLACEABLE" "$BIP125_REPLACEABLE"

echo "Verification Results:"
echo "- RBF enabled: $VERIFY_RBF"
echo "- BIP125 replaceable: $BIP125_REPLACEABLE"
echo "- Payment to $PAYMENT_ADDRESS: $VERIFY_PAYMENT BTC"
echo "- Change to $CHANGE_ADDRESS: $VERIFY_CHANGE BTC"

# Final verification
if [ "$VERIFY_RBF" == "true" ] && [ "$VERIFY_PAYMENT" == "$PAYMENT_BTC" ] && [ "$BIP125_REPLACEABLE" == "true" ]; then
  echo "✅ Transaction looks good! Ready for signing."
else
  echo "❌ Transaction verification failed! Double-check your transaction."
  exit 1
fi

# =========================================================================
# CHALLENGE 6: Transaction Signing - Sign the transaction with a private key
# =========================================================================
echo ""
echo "CHALLENGE 6: Transaction Signing"
echo "------------------------------"
echo "A raw transaction is useless until it's signed. For this challenge,"
echo "you'll sign the transaction using a provided private key."
echo ""
echo "For educational purposes, we'll use a testnet private key:"
echo "Private key: ${TEST_PRIVATE_KEY:0:10}... (truncated)"
echo "Address: $TEST_ADDRESS"
echo ""
echo "In a real scenario, you would use your own wallet to sign transactions."
echo ""

# For this exercise, we'll create a simple transaction that can be signed with the test key
# This is a simplified example for educational purposes
echo "Creating a simple transaction for signing..."

# STUDENT TASK: Create a simple transaction that sends funds to the test address
SIMPLE_TX_INPUTS='[{"txid":"'$TXID'","vout":0,"sequence":4294967293}]'
SIMPLE_TX_OUTPUTS='{"'$TEST_ADDRESS'":0.0001}'

# Create a raw transaction for signing using the SIMPLE_TX_INPUTS and SIMPLE_TX_OUTPUTS
SIMPLE_RAW_TX='[{"txid":"'$TXID'","vout":0,"sequence":4294967293}]'
check_cmd "Simple transaction creation" "SIMPLE_RAW_TX" "$SIMPLE_RAW_TX"

echo "Simple transaction created: ${SIMPLE_RAW_TX:0:64}... (truncated)"

# STUDENT TASK: Sign the transaction with the private key
# WRITE YOUR SOLUTION BELOW:
SIGNED_TX=$(bitcoin-cli -regtest signrawtransactionwithkey "$SIMPLE_RAW_TX" '["'$TEST_PRIVATE_KEY'"]')
check_cmd "Transaction signing" "SIGNED_TX" "$SIGNED_TX"

echo "Successfully signed transaction!"
echo "Signed transaction hex: ${SIGNED_TX:0:64}... (truncated)"

# STUDENT TASK: Verify the transaction is properly signed
# WRITE YOUR SOLUTION BELOW:
VERIFY_SIGNED=$(echo "$SIGNED_TX" | jq -r '.complete')
check_cmd "Signature verification" "VERIFY_SIGNED" "$VERIFY_SIGNED"

# Check if the transaction is properly signed
if [[ "$VERIFY_SIGNED" == *"true"* ]]; then
  echo "✅ Transaction is properly signed!"
else
  echo "❌ Transaction signature verification failed!"
  exit 1
fi

# =========================================================================
# CHALLENGE 7: Child Transaction (CPFP) - Create a "child" transaction
# =========================================================================
echo ""
echo "CHALLENGE 7: Child Transaction (CPFP)"
echo "-----------------------------------"
echo "In this advanced challenge, imagine your transaction is stuck with a low fee."
echo "You'll create a 'child' transaction that spends the change output to implement"
echo "Child Pays For Parent (CPFP) fee bumping."
echo ""
echo "The child transaction should:"
echo "- Spend the change output from your previous transaction"
echo "- Pay a higher fee of at least 20 satoshis/vbyte"
echo "- Send the funds to: 2N8vgPS1mUyTaNxSFBJp5KB6XwEJxhoLM77"
echo ""

# For the exercise, we'll assume the first transaction's TXID is the one created above in challenge 4 ($RAW_TX)
PARENT_TXID=$(echo "$DECODED_TX" | jq -r '.txid')
check_cmd "Parent TXID extraction" "PARENT_TXID" "$PARENT_TXID"
echo "Parent transaction ID: $PARENT_TXID"

# STUDENT TASK: Identify the change output index from the parent transaction
# WRITE YOUR SOLUTION BELOW:
CHANGE_OUTPUT_INDEX=$(echo "$DECODED_TX" | jq -r '.vout | to_entries[] | select(.value.scriptPubKey.address == "'$CHANGE_ADDRESS'" or .value.scriptPubKey.addresses[] == "'$CHANGE_ADDRESS'") | .key')
check_cmd "Change output identification" "CHANGE_OUTPUT_INDEX" "$CHANGE_OUTPUT_INDEX"

# STUDENT TASK: Create the input JSON structure for the child transaction
# WRITE YOUR SOLUTION BELOW:
CHILD_INPUTS='[{"txid":"'$PARENT_TXID'","vout":'$CHANGE_OUTPUT_INDEX',"sequence":4294967293}]'
check_cmd "Child input creation" "CHILD_INPUTS" "$CHILD_INPUTS"

# STUDENT TASK: Calculate fees, allowing for a high fee to help the parent transaction
CHILD_TX_SIZE=$((10 + 68 + 31))
check_cmd "Child transaction size calculation" "CHILD_TX_SIZE" "$CHILD_TX_SIZE"

CHILD_FEE_RATE=20 # satoshis/vbyte
CHILD_FEE_SATS=$((CHILD_TX_SIZE * CHILD_FEE_RATE))
check_cmd "Child fee calculation" "CHILD_FEE_SATS" "$CHILD_FEE_SATS"

# Calculate the amount to send after deducting fee
CHILD_RECIPIENT="2N8vgPS1mUyTaNxSFBJp5KB6XwEJxhoLM77"
CHILD_SEND_AMOUNT=$((CHANGE_AMOUNT - CHILD_FEE_SATS))
check_cmd "Child amount calculation" "CHILD_SEND_AMOUNT" "$CHILD_SEND_AMOUNT"

# Convert to BTC
CHILD_SEND_BTC=$(echo "scale=8; $CHILD_SEND_AMOUNT / 100000000" | bc)

# STUDENT TASK: Create the outputs JSON structure
CHILD_OUTPUTS='{"'$CHILD_RECIPIENT'":'$CHILD_SEND_BTC'}'
check_cmd "Child output creation" "CHILD_OUTPUTS" "$CHILD_OUTPUTS"

# STUDENT TASK: Create the raw child transaction
CHILD_RAW_TX=$(bitcoin-cli -regtest createrawtransaction "$CHILD_INPUTS" "$CHILD_OUTPUTS")
check_cmd "Child transaction creation" "CHILD_RAW_TX" "$CHILD_RAW_TX"

echo "Successfully created child transaction with higher fee!"
echo "Child raw transaction hex: ${CHILD_RAW_TX:0:64}... (truncated)"

# =========================================================================
# CHALLENGE 8: CSV Timelock - Create a transaction with relative timelock
# =========================================================================
echo ""
echo "CHALLENGE 8: Timelock Transaction"
echo "-------------------------------"
echo "For the final challenge, you'll create a transaction with a relative timelock using CSV."
echo "This advanced feature allows funds to be locked for a specified number of blocks."
echo ""
echo "Create a transaction that:"
echo "- Spends the output from the SECONDARY_TX"
echo "- Includes a 10-block relative timelock (CSV)"
echo "- Sends funds to: tb1qxdyjf6ustlnrtt76d53vvvn9kzlcgmegf8c8fx"
echo ""

# Decode the secondary transaction (SECONDARY_TX) to get its TXID
SECONDARY_TXID=$(bitcoin-cli -regtest decoderawtransaction "$SECONDARY_TX" | jq -r '.txid')
check_cmd "Secondary TXID extraction" "SECONDARY_TXID" "$SECONDARY_TXID"
echo "Secondary transaction ID: $SECONDARY_TXID"

# STUDENT TASK: Create the input JSON structure with a 10-block relative timelock
# WRITE YOUR SOLUTION BELOW:
TIMELOCK_INPUTS='[{"txid":"'$SECONDARY_TXID'","vout":0,"sequence":10}]'
check_cmd "Timelock input creation" "TIMELOCK_INPUTS" "$TIMELOCK_INPUTS"

# Recipient address for timelock funds
TIMELOCK_ADDRESS="tb1qxdyjf6ustlnrtt76d53vvvn9kzlcgmegf8c8fx"

# STUDENT TASK: Calculate the amount to send (use the output value from SECONDARY_TX, minus a fee)
# Hint: Extract the output value from the secondary TX first
SECONDARY_OUTPUT_VALUE=$(bitcoin-cli -regtest decoderawtransaction "$SECONDARY_TX" | jq -r '.vout[0].value * 100000000 | floor')
check_cmd "Secondary output value extraction" "SECONDARY_OUTPUT_VALUE" "$SECONDARY_OUTPUT_VALUE"

TIMELOCK_FEE=1000 # Use a simple fee of 1000 satoshis for this exercise
TIMELOCK_AMOUNT=$((SECONDARY_OUTPUT_VALUE - TIMELOCK_FEE))
check_cmd "Timelock amount calculation" "TIMELOCK_AMOUNT" "$TIMELOCK_AMOUNT"

# Convert to BTC
TIMELOCK_BTC=$(echo "scale=8; $TIMELOCK_AMOUNT / 100000000" | bc)

# STUDENT TASK: Create the outputs JSON structure
TIMELOCK_OUTPUTS='{"'$TIMELOCK_ADDRESS'":'$TIMELOCK_BTC'}'
check_cmd "Timelock output creation" "TIMELOCK_OUTPUTS" "$TIMELOCK_OUTPUTS"

# STUDENT TASK: Create the raw transaction with timelock
TIMELOCK_TX=$(bitcoin-cli -regtest createrawtransaction "$TIMELOCK_INPUTS" "$TIMELOCK_OUTPUTS")
check_cmd "Timelock transaction creation" "TIMELOCK_TX" "$TIMELOCK_TX"

echo "Successfully created transaction with 10-block relative timelock!"
echo "Timelock transaction hex: ${TIMELOCK_TX:0:64}... (truncated)"

# =========================================================================
# CHALLENGE COMPLETE
# =========================================================================
echo ""
echo "🎉 ADVANCED BITCOIN TRANSACTION MASTERY COMPLETED! 🎉"
echo "===================================================="
echo ""
echo "Congratulations! You've successfully demonstrated your mastery of:"
echo "✓ Transaction decoding and analysis"
echo "✓ UTXO selection and management"
echo "✓ Fee calculation and optimization"
echo "✓ Replace-By-Fee (RBF) implementation"
echo "✓ Transaction signing with private keys"
echo "✓ BIP125 replaceable transaction verification"
echo "✓ Child Pays For Parent (CPFP) fee bumping"
echo "✓ Relative timelock creation with CSV"
echo ""
echo "These are advanced Bitcoin transaction concepts that form the foundation"
echo "of Bitcoin's smart contracting capabilities and fee market."
echo ""
echo "Ready for real-world Bitcoin development!"

# Output the final transaction hex - useful for verification
echo $TIMELOCK_TX 
