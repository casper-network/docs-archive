Casper Staking Economics Guide
--------

The Casper network is a Proof-of-Stake blockchain that allows validators to stake the Casper native token CSPR on the network. Validators receive CSPR as an incentive for continuing to maintain and secure the network. CSPR rewards are distributed as blocks are validated into existence and organized into eras.

*Consensus mechanism:* Casper operates using a Proof-of-Stake consensus mechanism per the `Highway Protocol <https://github.com/CasperLabs/highway>`_, which is a specification of Correct-by-Construction Casper (CBC Casper).

*Number of validators:* The Casper Delta testnet supports up to 100 validators on the network. At the mainnet launch, the maximum number of bonded validators will continually increase as a function of a platform parameter. This platform parameter will increase as we improve performance. Validators can stake on the Casper network through a process of permission-less bonding by participating in an auction for the validator slot.
           
*Permission-less bonding:* For validators to begin staking and earning rewards, they must win a staking auction by competing with current and prospective validators to supply one of the forthcoming top stakes for a given era. This process is permission-less, meaning validators can join and leave the auction without restrictions, except for a waiting period to unlock staked tokens.
          
*Unbonding:* To detach from the Casper Delta testnet takes 15 eras for both validators and delegators. Neither validators nor delegators receive rewards during the 15 eras required for unbonding, as they are not actively contributing to the network's security during that time. The unbonding period is likely to change with the mainnet launch.

*Eras and block times:* An era on Casper is roughly thirty minutes. The block time on today's testnet is approximately two minutes. Casper's Highway protocol allows validators to propose blocks as quickly as network conditions allow. We anticipate block times to last between thirty seconds and eight minutes.
           
*Block rewards:* Block time is orthogonal to rewards, so there is no precise reward per-block. The number of rewards is split proportionally among stakes and reduced for failure to participate in the protocol promptly. This strategy encourages network liveness.

*Reward cycle:* Rewards are distributed to validators and delegators once per era.

*Token supply and inflation:* There will be ten billion CSPR on the mainnet at the time of genesis. The actual annual inflation rate is not yet known, but we expect it to be between 2% and 7%. CasperLabs leadership will decide the inflation rate before the mainnet launch and communicated on this page.

*Annual reward %:* Validators on the Casper network earn between 10% and 20% of their staked CSPR in the first year of the mainnet operation. The reward return rate is dependent on the number of validators on the network and the total amount of CSPR staked.
