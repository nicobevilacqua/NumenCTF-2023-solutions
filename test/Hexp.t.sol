// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "forge-std/console.sol";

import {Hexp} from "../src/Hexp.sol";

contract HexpTest is Test {
    address internal constant TARGET_ADDRESS =
        0x4Bbd602243AF385df26A8B74cb3Cf6a58c87384b;

    Hexp internal target;

    function setUp() public {
        target = new Hexp();
    }

    function test_hack() public {
        target.f00000000_bvvvdlt();
        assertEq(target.isSolved(), true);
    }

    function test_remote() public {
        (uint256 a, uint256 b) = values();
        console.log(a, b, "values");
        console.log(isValid(), "is valid");

        console.log(getGasPrice(), "gasprice");
        Hexp remoteTarget = Hexp(TARGET_ADDRESS);
        remoteTarget.f00000000_bvvvdlt();
        assertEq(remoteTarget.isSolved(), true);
    }

    function getGasPrice() public view returns (uint256) {
        uint256 gasPrice;
        assembly {
            gasPrice := gasprice()
        }
        return gasPrice;
    }

    function isValid() public returns (bool valid) {
        assembly {
            valid := eq(
                and(blockhash(sub(number(), 0x0a)), 0xffffff),
                and(gasprice(), 0xffffff)
            )
        }
    }

    function values() public returns (uint256 a, uint256 b) {
        assembly {
            a := and(blockhash(sub(number(), 0x0a)), 0xffffff)
            b := and(gasprice(), 0xffffff)
        }
    }

    // cast block ((cast block-number --rpc-url $RPC_URL) - 10) --rpc-url $RPC_URL hash

    // cast block 1372 --rpc-url $RPC_URL hash

    // function isValid() {
    //     ((blockHash(blockNumber-0x0a) & 0xffffff) == (gasPrice & 0xffffff))
    // }

    // --with-gas-price
}
