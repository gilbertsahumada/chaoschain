// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {LogicModule} from "../base/LogicModule.sol";

/**
 * @title ResolutionMarketLogic
 * @notice LogicModule for ChaosSettler prediction market resolution Studios
 * @dev Worker Agents are AI oracles that investigate and determine outcomes.
 *      CRE DON orchestrates the resolution workflow off-chain, then calls
 *      RewardsDistributor.resolveAndDistribute() to settle on-chain.
 *
 * @author Gilberts Ahumada C.
 */
contract ResolutionMarketLogic is LogicModule {
    // ============ Custom Storage ============
    struct Market {
        string question;
        uint256 rewardPool;
        uint256 deadline;
        address creator;
        bool active;
        bool resolved;
    }

    /// @dev marketId => Market
    mapping(bytes32 => Market) private _markets;

    /// @dev Market count
    uint256 private _marketCount;

    // ============ Events ============
    event MarketCreated(
        bytes32 indexed marketId,
        string question,
        uint256 rewardPool,
        uint256 deadline,
        address indexed creator
    );

    event MarketResolved(bytes32 indexed marketId, bool resolution);

    // ============ Implementation ============

    /// @inheritdoc LogicModule
    function initialize(bytes calldata /* params */) external override {
        // No init needed
    }

    /**
     * @notice Create a new resolution market
     * @param question The question to resolve (e.g., "Will SEC approve Solana ETF by 2026?")
     * @param rewardPool Amount of ETH to allocate as rewards
     * @param duration Duration in seconds until resolution deadline
     * @return marketId The market identifier
     */
    function createMarket(
        string calldata question,
        uint256 rewardPool,
        uint256 duration
    ) external hasEscrow(rewardPool) returns (bytes32 marketId) {
        require(bytes(question).length > 0, "Empty Question");
        require(rewardPool > 0, "Invalid reward pool");
        require(duration > 0 && duration <= 90 days, "Invalid duration"); // no longer than 90 days for now

        marketId = keccak256(
            abi.encodePacked(block.timestamp, msg.sender, _marketCount++)
        );

        _deductEscrow(msg.sender, rewardPool);

        _markets[marketId] = Market({
            question: question,
            rewardPool: rewardPool,
            deadline: block.timestamp + duration,
            creator: msg.sender,
            active: true,
            resolved: false
        });

        emit MarketCreated(
            marketId,
            question,
            rewardPool,
            block.timestamp + duration,
            msg.sender
        );
        emit LogicExecuted("createMarket", msg.sender, abi.encode(marketId));
    }

    function getMarket(
        bytes32 marketId
    ) external view returns (Market memory market) {
        return _markets[marketId];
    }

    function isMarketActive(
        bytes32 marketId
    ) external view returns (bool active) {
        Market storage $ = _markets[marketId];
        return $.active && !$.resolved && block.timestamp < $.deadline;
    }

    function getStudioType()
        external
        pure
        override
        returns (string memory studioStype)
    {
        return "ResolutionMarket";
    }

    function getVersion()
        external
        pure
        override
        returns (string memory version)
    {
        return "1.0.0";
    }

    function getScoringCriteria()
        external
        pure
        override
        returns (string[] memory names, uint16[] memory weights)
    {
        // Total: 5 universal PoA + 3 resolution-specific = 8 dimensions
        names = new string[](8);
        weights = new uint16[](8);

        // Universal PoA dimensions (REQUIRED)
        names[0] = "Initiative";
        names[1] = "Collaboration";
        names[2] = "Reasoning Depth";
        names[3] = "Compliance";
        names[4] = "Efficiency";

        // Resolution market-specific dimensions
        names[5] = "Resolution Quality"; // How thorough was the investigation?
        names[6] = "Source Quality"; // How credible were the sources?
        names[7] = "Reasoning Depth"; // How deep was the analysis?

        // Weights (100 = 1.0x baseline)
        weights[0] = 100; // Initiative: 1.0x
        weights[1] = 100; // Collaboration: 1.0x
        weights[2] = 100; // Reasoning Depth: 1.0x
        weights[3] = 100; // Compliance: 1.0x
        weights[4] = 100; // Efficiency: 1.0x
        weights[5] = 250; // Resolution Quality: 2.5x (MOST CRITICAL)
        weights[6] = 200; // Source Quality: 2.0x
        weights[7] = 150; // Reasoning Depth: 1.5x
    }
}
