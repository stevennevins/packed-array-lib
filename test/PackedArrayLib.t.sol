// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {PackedUint16Array} from "../src/PackedArrayLib.sol";

contract PackedUint16ArrayTest is Test {
    using PackedUint16Array for PackedUint16Array.Array;

    PackedUint16Array.Array private array;

    function setUp() public {}

    function testPush() public {
        array.push(1);
        assertEq(PackedUint16Array.length(array), 1);
        assertEq(PackedUint16Array.length(array), 1);
        assertEq(array.get(0), 1);
    }

    function testMultiplePush() public {
        for (uint16 i = 0; i < 20; i++) {
            array.push(i);
        }
        assertEq(PackedUint16Array.length(array), 20);
        for (uint16 i = 0; i < 20; i++) {
            assertEq(array.get(i), i);
        }
    }

    function testGet() public {
        array.push(5);
        assertEq(array.get(0), 5);
    }

    function testGetOutOfBounds() public {
        vm.expectRevert("Index out of bounds");
        array.get(0);
    }

    function testPop() public {
        array.push(10);
        uint16 popped = array.pop();
        assertEq(popped, 10);
        assertEq(PackedUint16Array.length(array), 0);
    }

    function testPopEmpty() public {
        vm.expectRevert("Array is empty");
        array.pop();
    }

    function testSet() public {
        array.push(1);
        array.set(0, 20);
        assertEq(array.get(0), 20);
    }

    function testSetOutOfBounds() public {
        vm.expectRevert("Index out of bounds");
        array.set(0, 20);
    }

    function testClear() public {
        for (uint16 i = 0; i < 20; i++) {
            array.push(i);
        }
        array.clear();
        assertEq(PackedUint16Array.length(array), 0);
        vm.expectRevert("Index out of bounds");
        array.get(0);
    }

    function testFuzz_PushAndGet(
        uint16 value
    ) public {
        array.push(value);
        assertEq(array.get(PackedUint16Array.length(array) - 1), value);
    }

    function testPushAndGetIntermediate() public {
        uint16 intermediateIndex = 7;
        uint16 intermediateValue = 42;

        // so we can verify an element in the packed portion of the array
        for (uint16 i = 0; i < 32; i++) {
            if (i == intermediateIndex) {
                array.push(intermediateValue);
            } else {
                array.push(i);
            }
        }

        assertEq(PackedUint16Array.length(array), 32);

        uint16 retrievedValue = array.get(intermediateIndex);
        assertEq(retrievedValue, intermediateValue);

        assertEq(array.get(intermediateIndex - 1), intermediateIndex - 1);
        assertEq(array.get(intermediateIndex + 1), intermediateIndex + 1);
    }

    function testFuzz_SetAndGet(uint8 index, uint16 value) public {
        index = uint8(bound(uint256(index), 0, 15));

        for (uint8 i = 0; i < 16; i++) {
            array.push(0);
        }

        array.set(index, value);
        assertEq(array.get(index), value);
    }

    function testFuzz_PushPopMultiple(
        uint8 pushCount
    ) public {
        pushCount = uint8(bound(uint256(pushCount), 1, 100));

        for (uint8 i = 0; i < pushCount; i++) {
            array.push(i);
        }
        assertEq(PackedUint16Array.length(array), pushCount);

        for (uint8 i = 0; i < pushCount; i++) {
            array.pop();
        }

        assertEq(PackedUint16Array.length(array), 0);
    }

    function testGas_Fill32Elements() public {
        uint256 gasStart = gasleft();

        for (uint16 i = 0; i < 32; i++) {
            array.push(i);
        }

        uint256 gasUsed = gasStart - gasleft();
        emit log_named_uint("Gas used to fill 32 elements", gasUsed);
    }

    function testGas_Read32Elements() public {
        // First, fill the array
        for (uint16 i = 0; i < 32; i++) {
            array.push(i);
        }

        uint256 gasStart = gasleft();

        for (uint16 i = 0; i < 32; i++) {
            array.get(i);
        }

        uint256 gasUsed = gasStart - gasleft();
        emit log_named_uint("Gas used to read 32 elements", gasUsed);
    }
}
