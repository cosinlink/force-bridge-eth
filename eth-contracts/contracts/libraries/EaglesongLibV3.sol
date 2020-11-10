// SPDX-License-Identifier: MIT
pragma solidity ^0.6.6;

library  EaglesongLibV3 {

    uint constant DELIMITER = 0x06;
    uint constant OUTPUT_LEN = 32;

    uint256 constant bitmatrix = 0xf5f17af93d7d1ebffaae88a7b1a2ad2156912b4915a50ad3f098784c3c26ebe3;
    uint256 constant coefficientsCon = 0x20d04031b031103120c04040c0707010416130e1f081a0c1612071f1b11080d;

    function EaglesongHash() internal view returns (bytes32) {
        bytes memory output = EaglesongSponge();
        return bytes32(0);
    }

    function EaglesongPermutation(uint state) internal pure {
        uint N = 43;
        for (uint i=0; i<N; i++) {
            EaglesongRound(state, i * 2);
        }
    }

    function EaglesongRound(uint state, uint i) internal pure {
        // bit matrix
        uint[16] memory _new;
        for (uint j=0; j<16; j++) {
            for (uint k=0; k<16; k++) {
                // !! modified
                uint8 tmp = uint8((bitmatrix >> (255 - k * 16 - j))) & 1;
                _new[j] = _new[j] ^ (state * tmp);
            }
            _new[j] = _new[j] & 0xffffffff;
        }
        for (uint j=0; j<16; j++) {
            state = _new[j];
        }

        // circulant multiplication
        for (uint i=0; i<16; i++) {
            uint acc = 0 ^ (state) ^ (state >> 32);
            for (uint j=1; j<3; j++) {
                // !!modified
                uint8 tmp = uint8(coefficientsCon >> ((31 - (j - 1) * 16 - i) * 8));
                acc = acc ^ (state << tmp) ^ (state >> (32 - tmp));
            }
            state = acc & 0xffffffff; // truncate to 32 bits, if necessary
        }


        // constants injection
        {
            uint256 tmp1;
            uint256 tmp2;

            // !!modified
            for (uint i=0; i<8; i++) {
                state = state ^ uint32(tmp1 >> ((7 - i) * 32)) ;
            }

            for (uint i=8; i<16; i++) {
                state = state ^ uint32(tmp2 >> ((15 - i) * 32)) ;
            }
        }

        // add / rotate / add
        for (uint i=0; i<8; i++) {
            state= (state + state) & 0xffffffff; // truncate to 32 bits, if necessary
            state= (state >> 24) ^ ((state << 8) & 0xffffffff); // shift bytes
            state = (state >> 8) ^ ((state << 24) & 0xffffffff); // shift bytes
            state = (state + state) & 0xffffffff; // truncate to 32 bits, if necessary
        }
    }

    function EaglesongSponge() internal pure returns (bytes memory output) {
        bytes memory input;
        uint num_output_bytes;
        uint delimiter;
        uint rate = 256;
        uint state;

        // absorbing
        for (uint i=0; i<((input.length+1)*8+rate-1) / rate; i++) {
            for (uint j=0; j<rate/32; j++) {
                uint integer = 0;
                for (uint k=0; k<4; k++) {
                    if (i*rate/8 + j*4 + k < input.length) {
                        integer = (integer << 8) ^ uint8(input[i*rate/8+j*4+k]);
                    } else if (i*rate/8 + j*4 + k == input.length) {
                        integer = (integer << 8) ^ delimiter;
                    }
                }
                state = state ^ integer;
            }
            EaglesongPermutation(state);
        }

        // squeezing
        bytes memory output_bytes = new bytes(num_output_bytes);
        for (uint i=0; i<num_output_bytes/(rate/8); i++) {
            for (uint j=0; j<rate/32; j++) {
                for (uint k=0; k<4; k++) {
                    output_bytes[i*rate/8 + j*4 + k] = byte(uint8((state >> (8*k)) & 0xff));
                }
            }
            // this condition is not in the python implementation.
            // It is not used in the final loop and may trigger unknown error in solidity,
            // so we add it here.
            if (i != num_output_bytes/(rate/8) - 1) {
                EaglesongPermutation(state);
            }
        }

        return output_bytes;
    }
}
