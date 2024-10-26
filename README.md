# Chiikawa

#  Details

### Stats

- nSLOC: 201


# About

Prepare to accept the mission!
Users mint a Chiikawa NFT,
train and gain experience (staking),
and conquest against other NFTs to earn rewards.

## RequestQuest .sol

The Chiikawa NFT.

Users mint a chiikawa that begins with all the flaws and cowardly we all experience.
NFT Mints with the following properties:

- `smallFeet` - True
- `weapon` - True
- `miniBag` - True
- `calmandReady` - False
- `battlesWon` - 0

The only way to improve these stats is by staking in the `Training.sol`:

## Training.sol

Experience on training will earn you Compensation and remove your chiikawa's fear.

- Staked Chiikawa NFTs will earn 1 Compensation ERC20/day staked up to 4 maximum
- Each day staked a Chiikawa will have properties change that will help them in their next Conquests.

## Conquests.sol

Users can put their Compensation on weeding and battle their Chiikawa. A base skill of 50 is applied to all chiikawa in battle, and this is modified by the properties the rapper holds.

- SmallFeet - False = +5
- Weapon - False = +5
- MiniBag - False = +5
- CalmAndReady - True = +10

Each chiikawa's skill is then used to weight their likelihood of randomly winning the battle!

- Winner is given the total of both bets

## CompensationToken.sol

ERC20 token that represents a Chiikawa's credibility and time on the training. The primary currency at risk in a conquest.

## Roles

User - Should be able to mint a chiikawa, stake and unstake their chiikawa and go weeding/battle


# Getting Started

## Requirements

- [git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git)
  - You'll know you did it right if you can run `git --version` and you see a response like `git version x.x.x`
- [foundry](https://getfoundry.sh/)
  - You'll know you did it right if you can run `forge --version` and you see a response like `forge 0.2.0 (816e00b 2023-03-16T00:05:26.396218Z)`

# Usage

## Testing

```
forge test
```

### Test Coverage

```
forge coverage
```

and for coverage based testing:

```
forge coverage --report debug
```



# Audit Scope Details

- In Scope:

```
├── src
│   ├── CompensationToken.sol
│   ├── RequestQuest.sol
│   ├── Conquest.sol
│   ├── Training.sol
```

## Compatibilities

- Solc Version: `^0.8.20`
- Chain(s) to deploy contract to:
  - Ethereum
  - Arbitrum
 


# Known Issues

None


