Unbonding
=========

If a validator is ready to reduce their bond, the process to do this is via the auction contract. The process is essentially the same as bonding,
but uses a different contract, `withdraw_bid.wasm`.

## Unbonding Request
To unbond, compile the contract & submit a deploy:
```bash
casper-client put-deploy --chain-name <CHAIN_NAME> --node-address http://<HOST>:<PORT> --secret-key <VALIDATOR_SECRET_KEY>.pem --session-path  withdraw_bid.wasm  --payment-amount 10000000  --session-arg=public_key:public_key=<VALIDATOR_PUBLIC_KEY_HEX> --session-arg=amount:u512=<AMOUNT_TO_UNBOND> --session-arg=unbond_purse:opt_uref=null
```
Similar to bonding (bidding) - check the auction contract for updates to the bond amount.  

## Unbonding Wait Period
In order to prevent 'long range attacks', requests to unbond must go through a mandatory wait period. This wait period is presently set to 15 eras.   
