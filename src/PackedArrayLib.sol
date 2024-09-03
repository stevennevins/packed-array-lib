// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

library PackedUint16Array {
    uint256 private constant CAPACITY = 16;
    uint256 private constant MASK = 0xFFFF;

    struct Array {
        uint256[] data;
        uint256 length;
    }

    function push(Array storage self, uint16 value) internal {
        uint256 slot = self.length / CAPACITY;
        uint256 offset = (self.length % CAPACITY) * 16;

        if (offset == 0) {
            self.data.push(uint256(value));
        } else {
            self.data[slot] |= uint256(value) << offset;
        }
        self.length++;
    }

    function pop(
        Array storage self
    ) internal returns (uint16) {
        require(self.length > 0, "Array is empty");
        self.length--;

        uint256 slot = self.length / CAPACITY;
        uint256 offset = (self.length % CAPACITY) * 16;

        uint16 value = uint16(self.data[slot] >> offset);
        self.data[slot] &= ~(MASK << offset);

        if (offset == 0 && slot > 0) {
            self.data.pop();
        }
        return value;
    }

    function get(Array storage self, uint256 index) internal view returns (uint16) {
        require(index < self.length, "Index out of bounds");
        uint256 slot = index / CAPACITY;
        uint256 offset = (index % CAPACITY) * 16;
        return uint16(self.data[slot] >> offset);
    }

    function set(Array storage self, uint256 index, uint16 value) internal {
        require(index < self.length, "Index out of bounds");
        uint256 slot = index / CAPACITY;
        uint256 offset = (index % CAPACITY) * 16;
        self.data[slot] = (self.data[slot] & ~(MASK << offset)) | (uint256(value) << offset);
    }

    function length(
        Array storage self
    ) internal view returns (uint256) {
        return self.length;
    }

    function clear(
        Array storage self
    ) internal {
        delete self.data;
        self.length = 0;
    }
}
