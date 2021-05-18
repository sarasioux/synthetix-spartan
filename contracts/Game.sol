// SPDX-License-Identifier: MIT
pragma solidity >=0.8.2 <0.9.0;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@chainlink/contracts/src/v0.8/dev/VRFConsumerBase.sol";
import 'synthetix/contracts/interfaces/IAddressResolver.sol';
import 'synthetix/contracts/interfaces/IERC20.sol';

contract Game is ERC721URIStorage, VRFConsumerBase {
    using Counters for Counters.Counter;
    using SafeMath for uint256;

    Counters.Counter private _tokenIds;

    // Game settings
    uint256 public constant duration = 10 minutes;
    uint256 public constant prize = 10;  // amount of SNX the user is gifted when they win
    uint256 public end;

    // SNX token interfaces
    IAddressResolver public synthetixResolver;
    address private synthAddress;

    // Fighters and players
    struct Fighter {
        uint256 strength;
        uint256 stamina;
        uint256 speed;
    }
    uint256 public playerCount;
    address[300] public players;
    uint256 public battleRound;

    // Random requests
    bytes32 public endRequestId;
    uint256 public endRandomness;
    bytes32 public lastRequestId;
    mapping (bytes32 => address) public playerRequestId;
    bytes32 internal keyHash;
    uint256 internal fee;

    // Internals
    mapping (address => bool) public currentPlayers;
    mapping (address => bool) public pendingPlayers;
    mapping (address => uint256) public currentPlayerId;
    mapping (address => Fighter) public fighterByPlayer;
    mapping (uint256 => Fighter) public nfts;
    mapping (uint256 => uint256) public prizeByNFT;

    // Events
    event RoundFought(address indexed player, Fighter hero, Fighter opponent, bool result);
    event PlayerWon(address indexed player, Fighter hero);
    event PlayerJoined(address indexed player);
    event FighterJoined(address indexed player, Fighter hero);
    event FighterBoosted(address indexed player, Fighter hero);
    event BattleContinued(uint256 battleCount);

    /**
     * An epic battle to the death for a last man standing to win an NFT of their fighter and some SNX.
     */
    constructor( address _vrfCoordinator, address _linkToken, address _resolver, bytes32 _keyHash) payable
    ERC721("Spartan", "SPARTAN")
    VRFConsumerBase(_vrfCoordinator, _linkToken) {
        // Manage SNX
        synthetixResolver = IAddressResolver(_resolver);
        // @todo get the correct lookup name for SNX instead of sUSD
        synthAddress = synthetixResolver.getAddress('ProxyERC20sUSD');
        require(synthAddress != address(0), 'SNX is missing from Synthetix resolver');

        // Manage randomness
        keyHash = _keyHash;
        fee = 0.1 * 10 ** 18;

        // Start the game
        end = block.timestamp + duration;
    }

    /**
     * Join the game by requesting a new random number to generate my fighter.
     */
    function joinGame() external {
        require(end>block.timestamp, "Game has already ended.");
        require(playerCount<300, "Only 300 fighters allowed per game.");
        require(currentPlayers[msg.sender] == false, "You can only join once per game.");
        bytes32 requestId = requestRandomness();
        playerRequestId[requestId] = msg.sender;
        lastRequestId = requestId;
        pendingPlayers[msg.sender] = true;
        emit PlayerJoined(msg.sender);
    }

    /**
     * Return a list of players in the current game.
     */
    function getPlayers() external view returns(address[300] memory) {
        return players;
    }

    /**
     * Picks one player randomly and attempts to boost one of their stats.
     */
    function rebalanceFighters(uint256 randomness) private {
        uint256 i;
        uint256 strength;
        uint256 stamina;
        uint256 speed;
        uint256 random;
        uint256 playerId;
        // Pick one random player
        if(playerCount > 1) {
            playerId = randomness.mod(playerCount);
        }
        Fighter memory fighter = fighterByPlayer[players[playerId]];
        speed = uint256(keccak256(abi.encode(randomness, 4))).mod(80);
        // Speed
        if(speed > fighter.speed) {
            fighter.speed = speed;
            emit FighterBoosted(players[playerId], fighter);
        } else {
            // Stamina
            stamina = uint256(keccak256(abi.encode(randomness, 5))).mod(80);
            if(stamina > fighter.stamina) {
                fighter.stamina = stamina;
                emit FighterBoosted(players[playerId], fighter);
            } else {
                // Strength
                strength = uint256(keccak256(abi.encode(randomness, 6))).mod(80);
                if(strength > fighter.strength) {
                    fighter.strength = strength;
                    emit FighterBoosted(players[playerId], fighter);
                }
            }
        }
        fighterByPlayer[players[playerId]] = fighter;
    }

    /**
     * Generates a fighter and adds them into battle trackers.
     */
    function createFighter(bytes32 requestId, uint256 randomness) private {
        address player = playerRequestId[requestId];
        Fighter memory fighter = Fighter(
            randomness.mod(99).add(1),
            uint256(keccak256(abi.encode(randomness, 1))).mod(99).add(1),
            uint256(keccak256(abi.encode(randomness, 2))).mod(99).add(1)
        );
        if(playerCount > 0) {
            rebalanceFighters(randomness);
        }
        uint256 playerId;
        if(currentPlayerId[player] > 0) {
            playerId = currentPlayerId[player];
        } else {
            playerId = playerCount;
            playerCount++;
        }
        players[playerId] = player;
        currentPlayers[player] = true;
        pendingPlayers[player] = false;
        fighterByPlayer[player] = fighter;
        emit FighterJoined(player, fighter);
    }

    /**
     * Generates a fighter and guarantees each stat will be >= 30.
     */
    function generateOpponent(uint256 randomness, uint256 counter, uint256 battleId) private returns (Fighter memory fighter) {
        fighter = Fighter(
            uint256(keccak256(abi.encode(randomness, counter + 300))).mod(70).add(30).add(battleId),
            uint256(keccak256(abi.encode(randomness, counter + 400))).mod(70).add(30).add(battleId),
            uint256(keccak256(abi.encode(randomness, counter + 500))).mod(70).add(30).add(battleId)
        );
        return fighter;
    }

    /**
     * End the game (if we haven't already.)  Can be called from public to reset the game.
     */
    function endGame() public {
        require(end<block.timestamp, "Game must expire first.");
        require(endRequestId == 0, "Game end has already been requested.");
        endRequestId = requestRandomness();
    }

    /**
     * Request randomness from VRF coordinator.
     */
    function requestRandomness() private returns(bytes32 requestId) {
        require(LINK.balanceOf(address(this)) >= fee, "Not enough LINK - fill contract with faucet");
        return requestRandomness(keyHash, fee, block.timestamp);
    }

    /**
     * Fulfills requests for individual player generation or to end the final battle.
     */
    function fulfillRandomness(bytes32 requestId, uint256 randomness) internal override {
        if(requestId == endRequestId) {
            endRandomness = randomness;
        } else {
            require(playerRequestId[requestId] != address(0), "Request ID does not exist.");
            createFighter(requestId, randomness);
            playerRequestId[requestId] = address(0);
        }
    }

    function fightWar() public {
        require(end<block.timestamp, "Game must expire first.");
        require(endRandomness > 0, "Randomness must be generated.");
        endRequestId = 0;
        fightBattle(endRandomness);
        endRandomness = 0;
    }

    /**
     * Battle manager for every player.  If there is only one winner at the end, the battle is over.
     * If there are no winners at the end, the battle is over, and the last user to die wins.  If there
     * are more than one winner, losers are removed and winners go again with a fresh random number.
     */
    function fightBattle(uint256 randomness) private returns (bool) {
        require(end<block.timestamp, "Game must expire first.");

        if(playerCount == 0) {
            end = block.timestamp + duration;
            return true;
        }
        battleRound++;

        uint256 i;
        Fighter memory opponent;
        Fighter memory hero;
        address player;
        bool result;
        for(i=0; i<players.length; i++) {
            player = players[i];
            if(player != address(0)) {
                // Generate an opponent for our hero and fight the match
                hero = fighterByPlayer[player];
                opponent = generateOpponent(randomness, i, battleRound);
                result = fightMatch(hero, opponent);

                // Eliminate the loser
                if(!result && playerCount > 1) {
                    playerCount--;
                    currentPlayers[player] = false;
                    players[i] = address(0);
                }
                emit RoundFought(player, hero, opponent, result);
            }
        }

        if(playerCount == 1) {
            // Find and erase the player
            for(i=0; i<players.length; i++) {
                if(players[i] != address(0)) {
                    player = players[i];
                    players[i] = address(0);
                }
            }

            // Reward the player
            currentPlayers[player] = false;
            rewardPlayer(player, fighterByPlayer[player]);
            emit PlayerWon(player, fighterByPlayer[player]);

            // Reset the game
            playerCount = 0;
            battleRound = 0;
            end = block.timestamp + duration;
        } else {
            endGame();
            emit BattleContinued(battleRound);
        }

        return true;
    }

    /**
     * Battle between one hero and one opponent.
     */
    function fightMatch(Fighter memory hero, Fighter memory opponent) private returns (bool) {
        uint256 opponentPoints;
        uint256 heroPoints;

        // Strength
        if(opponent.strength > hero.strength) {
            opponentPoints += opponent.strength - hero.strength;
        } else {
            heroPoints += hero.strength - opponent.strength;
        }

        // Stamina
        if(opponent.stamina > hero.stamina) {
            opponentPoints += opponent.stamina - hero.stamina;
        } else {
            heroPoints += hero.stamina - opponent.stamina;
        }

        // Speed
        if(opponent.speed > hero.speed) {
            opponentPoints += opponent.speed - hero.speed;
        } else {
            heroPoints += hero.speed - opponent.speed;
        }
        return (heroPoints > opponentPoints);
    }

    /**
     * Mint the NFT for the winning player.
     * Transfer some SNX to them as well (I think).
     */
    function rewardPlayer(address player, Fighter memory fighter) public {
        _tokenIds.increment();
        uint256 tokenId = _tokenIds.current();
        _safeMint(player, tokenId);
        nfts[tokenId] = fighter;
        prizeByNFT[tokenId] += prize;
    }


    /**
     * Claim my prizes. Once it's claimed we no longer have a record of the prize.
     */
    function claimMyPrizes() external {
        uint256 tokenCount = balanceOf(msg.sender);
        require(tokenCount>0,"You do not own any tickets.");
        uint256 amount;
        uint256 tokenId = _tokenIds.current();
        for (uint256 t = 1; t <= tokenId; t++) {
            if (_exists(t) && ownerOf(t) == msg.sender) {
                amount += prizeByNFT[t];
                prizeByNFT[t] = 0;
            }
        }

        // Transfer money
        //IERC20(snxAddress).transfer(msg.sender, amount);
    }

    /**
     * Get my tokens helper function for front-end usability.
     * Concept borrowed from CryptoKitties.
     */
    function getMyTokens() view public returns(uint256[] memory) {
        uint256 tokenCount = balanceOf(msg.sender);
        if (tokenCount == 0) {
            return new uint256[](0);
        } else {
            uint256[] memory result = new uint256[](tokenCount);
            uint256 totalTokens = _tokenIds.current();
            uint256 resultIndex = 0;
            for (uint256 t = 1; t <= totalTokens; t++) {
                if (_exists(t) && ownerOf(t) == msg.sender) {
                    result[resultIndex] = t;
                    resultIndex++;
                }
            }
            return result;
        }
    }
}



