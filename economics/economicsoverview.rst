Casper Staking Economics Guide
--------

The Casper network is a Proof of Stake blockchain that allows validators to stake CSPR on the network. Validators are rewarded with CSPR as an incentive for continuing to maintain and secure the network. CSPR rewards are distributed regularly as blocks are validated into existence and organized into eras.


*Consensus mechanism:* Casper operates off a Proof of Stake consensus mechanism per the [Highway Protocol](https://github.com/CasperLabs/highway).  
Highway is a specification of CBC Casper.   


*Number of validators:* The Casper Delta testnet supports up to 100 validators on the network. At mainnet launch, the maximum number of bonded validators will continually increase as a function of a platform parameter. This platform parameter is expected to increase as we improve performance. Validators can stake on the Casper network through a process of permissionless bonding by participating in an auction for the validator slot.


           
*Permissionless bonding:* For validators to begin staking and earning rewards, they must win a staking auction by competing with current and prospective validators to supply one of top N prospective stakes for a given era. This process is permissionless, meaning validators can join and leave the auction without restrictions, with the exception of a waiting period to unlock staked tokens.


          
*Unbonding:* Unbonding from the Casper Delta testnet takes 15 eras for both validators and delegators. Neither validators nor delegators receive rewards during the 15 eras required for unbonding, as they are not actively contributing to the security of the network during that time period. The unbonding period is likely to change with mainnet launch.
             
            

*Eras and block times:* An era on Casper is roughly ~30 minutes. The block time on today’s testnet is ~2 minutes, Casper’s Highway protocol allows for blocks to be proposed as quickly as network conditions will allow. We anticipate that block times could be maintained anywhere between 30 seconds and 8 minutes.
           
    

*Block rewards:* Block time is orthogonal to rewards, so there is no precise “per-block” reward. The amount of rewards is split proportionally among stakes and reduced for failure to participate in the protocol in a timely manner to incentivize liveness. 



*Reward cycle:* Rewards are distributed to validators and delegators once per era.    


*Token supply and inflation:* There will be 10 billion CSPR on mainnet at the time of genesis. The precise annual inflation rate is not currently known, but is expected to be between 2-7%. It will be decided on before mainnet launch by CasperLabs leadership and communicated here.
     


*Annual reward %:* Validators on the Casper network are expected to earn between 10-20% of their staked CSPR in rewards in the first year of mainnet launch. The reward return rate is dependent on the number of validators on the network and the amount of CSPR staked.


