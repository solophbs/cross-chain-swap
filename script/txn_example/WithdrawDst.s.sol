// SPDX-License-Identifier: MIT

pragma solidity 0.8.23;

import { Script } from "forge-std/Script.sol";
import { Address } from "solidity-utils/contracts/libraries/AddressLib.sol";

import { IBaseEscrow } from "contracts/interfaces/IBaseEscrow.sol";
import { IResolverExample } from "contracts/interfaces/IResolverExample.sol";
import { Timelocks, TimelocksLib } from "contracts/libraries/TimelocksLib.sol";

contract WithdrawDst is Script {
    function run() external {
        address deployer = vm.envAddress("DEPLOYER_ADDRESS");
        uint256 deployerPK = vm.envUint("DEPLOYER_PRIVATE_KEY");
        address escrow = vm.envAddress("ESCROW_DST");
        address dstToken = address(0); // ETH
        bytes32 orderHash = vm.envBytes32("ORDER_HASH");
        Timelocks timelocks = Timelocks.wrap(vm.envUint("TIMELOCKS"));
        uint256 deployedAt = vm.envUint("DEPLOYED_AT");

        timelocks = TimelocksLib.setDeployedAt(timelocks, deployedAt);
        bytes32 secret = keccak256(abi.encodePacked("secret"));
        bytes32 hashlock = keccak256(abi.encode(secret));
        uint256 dstAmount = 1; // 1 USDC
        uint256 safetyDeposit = 1;

        IBaseEscrow.Immutables memory immutables = IBaseEscrow.Immutables({
            orderHash: orderHash,
            amount: dstAmount,
            maker: Address.wrap(uint160(deployer)),
            taker: Address.wrap(uint160(address(deployer))),
            token: Address.wrap(uint160(dstToken)),
            hashlock: hashlock,
            safetyDeposit: safetyDeposit,
            timelocks: timelocks
        });

        vm.startBroadcast(deployerPK);
        IBaseEscrow(escrow).withdraw(secret, immutables);
        vm.stopBroadcast();
    }
}
