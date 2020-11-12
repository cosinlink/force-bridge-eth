// SPDX-License-Identifier: MIT

/*
The Times 11/Nov/2020 Hamster on brink of bailout for CKB Eaglesong Hash function.
*/
pragma solidity =0.7.4;

contract EaglesongHamster {
    bytes32 constant DELIMITER = 0x0000000000000000000000000000000000000000000000000000000000000006;

    //0x858a7ea48900c468bfadb33366d01cd6b1c27bb719aaccda300cbdba515cbec3 == keccak256("HashResult(bytes32)"
    event HashResult(bytes32 res);

    //0x2e36a7093f25f22bd4cbdeb6040174c3ba4c5fe8f1abc04e7c3c48f26c7413e0
    event Error(uint256 code);

    //0x44616297960603a3d5b0d25266152f32526078f52ebfdf296f21f709cb373712
    event CheckPoint(uint256 code);

    fallback () external {}
    receive () external payable {}

    /*
    for test
    0xaa6d7de4 + 0x112233445566778899001122334455667788990011223344556677889900112233445566778899001122334455667788
    0xaa6d7de4112233445566778899001122334455667788990011223344556677889900112233445566778899001122334455667788

    */

    // 0xaa6d7de41a0dc955b8e437537648c58dfcacab2c94987b995d4b6fd469da237c == abi = keccak256("Hash()")
    // 0xaa6d7de4
    function Hash() external {
        assembly{
        // force take over the memory management
            mstore(0x40, 0x80)

        // reject not ckbinput
            if eq(eq(calldatasize(), 52),0){

            //revert (0, 0)
                let size := calldatasize()

                mstore(0x0200,0x00000000000000000000000000000000000000000000000000000000000001)
                log1(0x0200,0x20,0x2e36a7093f25f22bd4cbdeb6040174c3ba4c5fe8f1abc04e7c3c48f26c7413e0)
                return(0x80,0x00)
            }

        // copy calldata to memory since the compiler already filtered selector

            calldatacopy(0x80, 4, 48)


        // set the 48th byte to DELIMITER
        // 0x80 + 48 =
            mstore8(0xB0, DELIMITER)

        // update memory pointer in case of forget
        // 0x80 + 49 = 0xB1 -> align to 0xC0

        // additionally we reserve 512 bits = 64 = 0x40 bytes
        // 0xC0 + 0x40 = 0x0100
            mstore(0x40, 0x0100)

        // e.g. memory from 0x80 to 0xB1(0xBF)

        // 0x80 0x11223344556677889900112233445566
        // 0x90 0x77889900112233445566778899001122

        // 0xA0 0x33445566778899001122334455667788
        // 0xB0 0x06000000000000000000000000000000

        // stack ->  high || low
        // stack uses 2 slot for 256*2 = 512 bits
        // high/r || low/c = state_vector

            let low := byte(0x20, 0x00)
            let high := byte(0x20, 0x00)

        // these are for intermediate computation
            let new_low := byte(0x20, 0x00)
            let new_high := byte(0x20, 0x00)


        // start 2 times for 2 chunks


        //=================================================ABSORB_CHUNK_0===========================================================
            /*
                chunk 0
            */
            //mstore(0x0200,100)
            //log1(0x0200,0x20,0x44616297960603a3d5b0d25266152f32526078f52ebfdf296f21f709cb373712)

            high := xor(high, mload(0x80))

        // here Permutation begins

        // one permutation has independent 43 round
            for {let round := 0} lt(round, 43) {round := add(round, 1)}{

                /*
                    chunk 0-round
                */
                //let checkpoint := add(round, 101)
                //mstore(0x0200,checkpoint)
                //log1(0x0200,0x20,0x44616297960603a3d5b0d25266152f32526078f52ebfdf296f21f709cb373712)

                {//bit_matrix
                    new_low := byte(0x20, 0x00)
                    new_high := byte(0x20, 0x00)

                /*bit_matrix = [
                         0 1 2 3 4 5 6 7|8 9 a b c d e f
                    0	[1 1 1 1 0 1 0 1 1 1 1 1 0 0 0 1]
                    1   [0 1 1 1 1 0 1 0 1 1 1 1 1 0 0 1]
                    2   [0 0 1 1 1 1 0 1 0 1 1 1 1 1 0 1]
                    3   [0 0 0 1 1 1 1 0 1 0 1 1 1 1 1 1]
                    4   [1 1 1 1 1 0 1 0 1 0 1 0 1 1 1 0]
                    5   [1 0 0 0 1 0 0 0 1 0 1 0 0 1 1 1]
                    6   [1 0 1 1 0 0 0 1 1 0 1 0 0 0 1 0]
                    7   [1 0 1 0 1 1 0 1 0 0 1 0 0 0 0 1]
                    8   [0 1 0 1 0 1 1 0 1 0 0 1 0 0 0 1]
                    9   [0 0 1 0 1 0 1 1 0 1 0 0 1 0 0 1]
                    a   [0 0 0 1 0 1 0 1 1 0 1 0 0 1 0 1]
                    b   [0 0 0 0 1 0 1 0 1 1 0 1 0 0 1 1]
                    c   [1 1 1 1 0 0 0 0 1 0 0 1 1 0 0 0]
                    d   [0 1 1 1 1 0 0 0 0 1 0 0 1 1 0 0]
                    e   [0 0 1 1 1 1 0 0 0 0 1 0 0 1 1 0]
                    f   [1 1 1 0 1 0 1 1 1 1 1 0 0 0 1 1]
                ]*/



                // alloc a item for temp usage of 32 bits
                // we use the lowest 32 bits of 256 bits
                    let stack_temp := byte(0x20, 0x00)// for output_vector[j]
                    let temp := byte(0x20, 0x00)// for dup of original state_vector

                // row 0,1 1 1 1 0 1 0 1 1 1 1 1 0 0 0

                // column 0
                    temp := high
                    stack_temp := xor(stack_temp, shr(temp, 0xE0))

                // column 1
                    temp := high
                    stack_temp := xor(stack_temp, shr(and(temp, 0x00000000ffffffff000000000000000000000000000000000000000000000000), 0xC0))

                // column 2
                    temp := high
                    stack_temp := xor(stack_temp, shr(and(temp, 0x0000000000000000ffffffff0000000000000000000000000000000000000000), 0xA0))

                // column 3
                    temp := high
                    stack_temp := xor(stack_temp, shr(and(temp, 0x000000000000000000000000ffffffff00000000000000000000000000000000), 0x80))

                // column 4
                /*temp := high
                stack_temp := xor(stack_temp,shr(and(temp,0x00000000000000000000000000000000ffffffff000000000000000000000000),0x60))*/

                // column 5
                    temp := high
                    stack_temp := xor(stack_temp, shr(and(temp, 0x0000000000000000000000000000000000000000ffffffff0000000000000000), 0x40))

                // column 6
                /*temp := high
                stack_temp := xor(stack_temp,shr(and(temp,0x000000000000000000000000000000000000000000000000ffffffff00000000),0x20))*/

                // column 7
                    temp := high
                    stack_temp := xor(stack_temp, and(temp, 0x00000000000000000000000000000000000000000000000000000000ffffffff))

                // column 8
                    temp := low
                    stack_temp := xor(stack_temp, shr(temp, 0xE0))

                // column 9
                    temp := low
                    stack_temp := xor(stack_temp, shr(and(temp, 0x00000000ffffffff000000000000000000000000000000000000000000000000), 0xC0))

                // column a
                    temp := low
                    stack_temp := xor(stack_temp, shr(and(temp, 0x0000000000000000ffffffff0000000000000000000000000000000000000000), 0xA0))

                // column b
                    temp := low
                    stack_temp := xor(stack_temp, shr(and(temp, 0x000000000000000000000000ffffffff00000000000000000000000000000000), 0x80))

                // column c
                /*temp := low
                stack_temp := xor(stack_temp,shr(and(temp,0x00000000000000000000000000000000ffffffff000000000000000000000000),0x60))*/

                // column d
                /*temp := low
                stack_temp := xor(stack_temp,shr(and(temp,0x0000000000000000000000000000000000000000ffffffff0000000000000000),0x40))*/

                // column e
                /*temp := low
                stack_temp := xor(stack_temp,shr(and(temp,0x000000000000000000000000000000000000000000000000ffffffff00000000),0x20))*/

                // column f
                    temp := low
                    stack_temp := xor(stack_temp, and(temp, 0x00000000000000000000000000000000000000000000000000000000ffffffff))

                    new_high := or(new_high, shl(stack_temp, 0xE0))

                // row 1,0 1 1 1 1 0 1 0 1 1 1 1 1 0 0 1
                    stack_temp := byte(0x20, 0x00)
                // column 0
                /*temp := high
                stack_temp := xor(stack_temp, shr(temp, 0xE0))*/

                // column 1
                    temp := high
                    stack_temp := xor(stack_temp, shr(and(temp, 0x00000000ffffffff000000000000000000000000000000000000000000000000), 0xC0))

                // column 2
                    temp := high
                    stack_temp := xor(stack_temp, shr(and(temp, 0x0000000000000000ffffffff0000000000000000000000000000000000000000), 0xA0))

                // column 3
                    temp := high
                    stack_temp := xor(stack_temp, shr(and(temp, 0x000000000000000000000000ffffffff00000000000000000000000000000000), 0x80))

                // column 4
                    temp := high
                    stack_temp := xor(stack_temp, shr(and(temp, 0x00000000000000000000000000000000ffffffff000000000000000000000000), 0x60))

                // column 5
                /* temp := high
                 stack_temp := xor(stack_temp, shr(and(temp, 0x0000000000000000000000000000000000000000ffffffff0000000000000000), 0x40))*/

                // column 6
                    temp := high
                    stack_temp := xor(stack_temp, shr(and(temp, 0x000000000000000000000000000000000000000000000000ffffffff00000000), 0x20))

                // column 7
                /*temp := high
                stack_temp := xor(stack_temp, and(temp, 0x00000000000000000000000000000000000000000000000000000000ffffffff))*/

                // column 8
                    temp := low
                    stack_temp := xor(stack_temp, shr(temp, 0xE0))

                // column 9
                    temp := low
                    stack_temp := xor(stack_temp, shr(and(temp, 0x00000000ffffffff000000000000000000000000000000000000000000000000), 0xC0))

                // column a
                    temp := low
                    stack_temp := xor(stack_temp, shr(and(temp, 0x0000000000000000ffffffff0000000000000000000000000000000000000000), 0xA0))

                // column b
                    temp := low
                    stack_temp := xor(stack_temp, shr(and(temp, 0x000000000000000000000000ffffffff00000000000000000000000000000000), 0x80))

                // column c
                    temp := low
                    stack_temp := xor(stack_temp, shr(and(temp, 0x00000000000000000000000000000000ffffffff000000000000000000000000), 0x60))

                // column d
                /*temp := low
                stack_temp := xor(stack_temp, shr(and(temp, 0x0000000000000000000000000000000000000000ffffffff0000000000000000), 0x40))*/

                // column e
                /*temp := low
                stack_temp := xor(stack_temp, shr(and(temp, 0x000000000000000000000000000000000000000000000000ffffffff00000000), 0x20))*/

                // column f
                    temp := low
                    stack_temp := xor(stack_temp, and(temp, 0x00000000000000000000000000000000000000000000000000000000ffffffff))

                    new_high := or(new_high, shl(stack_temp, 0xC0))

                // row 2,0 0 1 1 1 1 0 1 0 1 1 1 1 1 0 1
                    stack_temp := byte(0x20, 0x00)
                // column 0
                /*temp := high
                stack_temp := xor(stack_temp, shr(temp, 0xE0))*/

                // column 1
                /*temp := high
                stack_temp := xor(stack_temp, shr(and(temp, 0x00000000ffffffff000000000000000000000000000000000000000000000000), 0xC0))*/

                // column 2
                    temp := high
                    stack_temp := xor(stack_temp, shr(and(temp, 0x0000000000000000ffffffff0000000000000000000000000000000000000000), 0xA0))

                // column 3
                    temp := high
                    stack_temp := xor(stack_temp, shr(and(temp, 0x000000000000000000000000ffffffff00000000000000000000000000000000), 0x80))

                // column 4
                    temp := high
                    stack_temp := xor(stack_temp, shr(and(temp, 0x00000000000000000000000000000000ffffffff000000000000000000000000), 0x60))

                // column 5
                    temp := high
                    stack_temp := xor(stack_temp, shr(and(temp, 0x0000000000000000000000000000000000000000ffffffff0000000000000000), 0x40))

                // column 6
                /* temp := high
                 stack_temp := xor(stack_temp, shr(and(temp, 0x000000000000000000000000000000000000000000000000ffffffff00000000), 0x20))*/

                // column 7
                    temp := high
                    stack_temp := xor(stack_temp, and(temp, 0x00000000000000000000000000000000000000000000000000000000ffffffff))

                // column 8
                /*temp := low
                stack_temp := xor(stack_temp, shr(temp, 0xE0))*/

                // column 9
                    temp := low
                    stack_temp := xor(stack_temp, shr(and(temp, 0x00000000ffffffff000000000000000000000000000000000000000000000000), 0xC0))

                // column a
                    temp := low
                    stack_temp := xor(stack_temp, shr(and(temp, 0x0000000000000000ffffffff0000000000000000000000000000000000000000), 0xA0))

                // column b
                    temp := low
                    stack_temp := xor(stack_temp, shr(and(temp, 0x000000000000000000000000ffffffff00000000000000000000000000000000), 0x80))

                // column c
                    temp := low
                    stack_temp := xor(stack_temp, shr(and(temp, 0x00000000000000000000000000000000ffffffff000000000000000000000000), 0x60))

                // column d
                    temp := low
                    stack_temp := xor(stack_temp, shr(and(temp, 0x0000000000000000000000000000000000000000ffffffff0000000000000000), 0x40))

                // column e
                /*temp := low
                stack_temp := xor(stack_temp, shr(and(temp, 0x000000000000000000000000000000000000000000000000ffffffff00000000), 0x20))*/

                // column f
                    temp := low
                    stack_temp := xor(stack_temp, and(temp, 0x00000000000000000000000000000000000000000000000000000000ffffffff))

                    new_high := or(new_high, shl(stack_temp, 0xA0))

                // row 3,0 0 0 1 1 1 1 0 1 0 1 1 1 1 1 1
                    stack_temp := byte(0x20, 0x00)
                // column 0
                /*temp := high
                stack_temp := xor(stack_temp, shr(temp, 0xE0))*/

                // column 1
                /*temp := high
                stack_temp := xor(stack_temp, shr(and(temp, 0x00000000ffffffff000000000000000000000000000000000000000000000000), 0xC0))*/

                // column 2
                /*temp := high
                stack_temp := xor(stack_temp, shr(and(temp, 0x0000000000000000ffffffff0000000000000000000000000000000000000000), 0xA0))*/

                // column 3
                    temp := high
                    stack_temp := xor(stack_temp, shr(and(temp, 0x000000000000000000000000ffffffff00000000000000000000000000000000), 0x80))

                // column 4
                    temp := high
                    stack_temp := xor(stack_temp, shr(and(temp, 0x00000000000000000000000000000000ffffffff000000000000000000000000), 0x60))

                // column 5
                    temp := high
                    stack_temp := xor(stack_temp, shr(and(temp, 0x0000000000000000000000000000000000000000ffffffff0000000000000000), 0x40))

                // column 6
                    temp := high
                    stack_temp := xor(stack_temp, shr(and(temp, 0x000000000000000000000000000000000000000000000000ffffffff00000000), 0x20))

                // column 7
                /*temp := high
                stack_temp := xor(stack_temp, and(temp, 0x00000000000000000000000000000000000000000000000000000000ffffffff))*/

                // column 8
                    temp := low
                    stack_temp := xor(stack_temp, shr(temp, 0xE0))

                // column 9
                /*temp := low
                stack_temp := xor(stack_temp, shr(and(temp, 0x00000000ffffffff000000000000000000000000000000000000000000000000), 0xC0))*/

                // column a
                    temp := low
                    stack_temp := xor(stack_temp, shr(and(temp, 0x0000000000000000ffffffff0000000000000000000000000000000000000000), 0xA0))

                // column b
                    temp := low
                    stack_temp := xor(stack_temp, shr(and(temp, 0x000000000000000000000000ffffffff00000000000000000000000000000000), 0x80))

                // column c
                    temp := low
                    stack_temp := xor(stack_temp, shr(and(temp, 0x00000000000000000000000000000000ffffffff000000000000000000000000), 0x60))

                // column d
                    temp := low
                    stack_temp := xor(stack_temp, shr(and(temp, 0x0000000000000000000000000000000000000000ffffffff0000000000000000), 0x40))

                // column e
                    temp := low
                    stack_temp := xor(stack_temp, shr(and(temp, 0x000000000000000000000000000000000000000000000000ffffffff00000000), 0x20))

                // column f
                    temp := low
                    stack_temp := xor(stack_temp, and(temp, 0x00000000000000000000000000000000000000000000000000000000ffffffff))

                    new_high := or(new_high, shl(stack_temp, 0x80))

                // row 4,1 1 1 1 1 0 1 0 1 0 1 0 1 1 1 0
                    stack_temp := byte(0x20, 0x00)
                // column 0
                    temp := high
                    stack_temp := xor(stack_temp, shr(temp, 0xE0))

                // column 1
                    temp := high
                    stack_temp := xor(stack_temp, shr(and(temp, 0x00000000ffffffff000000000000000000000000000000000000000000000000), 0xC0))

                // column 2
                    temp := high
                    stack_temp := xor(stack_temp, shr(and(temp, 0x0000000000000000ffffffff0000000000000000000000000000000000000000), 0xA0))

                // column 3
                    temp := high
                    stack_temp := xor(stack_temp, shr(and(temp, 0x000000000000000000000000ffffffff00000000000000000000000000000000), 0x80))

                // column 4
                    temp := high
                    stack_temp := xor(stack_temp, shr(and(temp, 0x00000000000000000000000000000000ffffffff000000000000000000000000), 0x60))

                // column 5
                /*temp := high
                stack_temp := xor(stack_temp, shr(and(temp, 0x0000000000000000000000000000000000000000ffffffff0000000000000000), 0x40))*/

                // column 6
                    temp := high
                    stack_temp := xor(stack_temp, shr(and(temp, 0x000000000000000000000000000000000000000000000000ffffffff00000000), 0x20))

                // column 7
                /*temp := high
                stack_temp := xor(stack_temp, and(temp, 0x00000000000000000000000000000000000000000000000000000000ffffffff))*/

                // column 8
                    temp := low
                    stack_temp := xor(stack_temp, shr(temp, 0xE0))

                // column 9
                /*temp := low
                stack_temp := xor(stack_temp, shr(and(temp, 0x00000000ffffffff000000000000000000000000000000000000000000000000), 0xC0))*/

                // column a
                    temp := low
                    stack_temp := xor(stack_temp, shr(and(temp, 0x0000000000000000ffffffff0000000000000000000000000000000000000000), 0xA0))

                // column b
                /*temp := low
                stack_temp := xor(stack_temp, shr(and(temp, 0x000000000000000000000000ffffffff00000000000000000000000000000000), 0x80))*/

                // column c
                    temp := low
                    stack_temp := xor(stack_temp, shr(and(temp, 0x00000000000000000000000000000000ffffffff000000000000000000000000), 0x60))

                // column d
                    temp := low
                    stack_temp := xor(stack_temp, shr(and(temp, 0x0000000000000000000000000000000000000000ffffffff0000000000000000), 0x40))

                // column e
                    temp := low
                    stack_temp := xor(stack_temp, shr(and(temp, 0x000000000000000000000000000000000000000000000000ffffffff00000000), 0x20))

                // column f
                /*temp := low
                stack_temp := xor(stack_temp, and(temp, 0x00000000000000000000000000000000000000000000000000000000ffffffff))*/

                    new_high := or(new_high, shl(stack_temp, 0x60))

                // row 5,1 0 0 0 1 0 0 0 1 0 1 0 0 1 1 1
                    stack_temp := byte(0x20, 0x00)
                // column 0
                    temp := high
                    stack_temp := xor(stack_temp, shr(temp, 0xE0))

                // column 1
                /*temp := high
                stack_temp := xor(stack_temp, shr(and(temp, 0x00000000ffffffff000000000000000000000000000000000000000000000000), 0xC0))*/

                // column 2
                /*temp := high
                stack_temp := xor(stack_temp, shr(and(temp, 0x0000000000000000ffffffff0000000000000000000000000000000000000000), 0xA0))*/

                // column 3
                /*temp := high
                stack_temp := xor(stack_temp, shr(and(temp, 0x000000000000000000000000ffffffff00000000000000000000000000000000), 0x80))*/

                // column 4
                    temp := high
                    stack_temp := xor(stack_temp, shr(and(temp, 0x00000000000000000000000000000000ffffffff000000000000000000000000), 0x60))

                // column 5
                /*temp := high
                stack_temp := xor(stack_temp, shr(and(temp, 0x0000000000000000000000000000000000000000ffffffff0000000000000000), 0x40))*/

                // column 6
                /*temp := high
                stack_temp := xor(stack_temp, shr(and(temp, 0x000000000000000000000000000000000000000000000000ffffffff00000000), 0x20))*/

                // column 7
                /*temp := high
                stack_temp := xor(stack_temp, and(temp, 0x00000000000000000000000000000000000000000000000000000000ffffffff))*/

                // column 8
                    temp := low
                    stack_temp := xor(stack_temp, shr(temp, 0xE0))

                // column 9
                /*temp := low
                stack_temp := xor(stack_temp, shr(and(temp, 0x00000000ffffffff000000000000000000000000000000000000000000000000), 0xC0))*/

                // column a
                    temp := low
                    stack_temp := xor(stack_temp, shr(and(temp, 0x0000000000000000ffffffff0000000000000000000000000000000000000000), 0xA0))

                // column b
                /*temp := low
                stack_temp := xor(stack_temp, shr(and(temp, 0x000000000000000000000000ffffffff00000000000000000000000000000000), 0x80))*/

                // column c
                /*temp := low
                stack_temp := xor(stack_temp, shr(and(temp, 0x00000000000000000000000000000000ffffffff000000000000000000000000), 0x60))*/

                // column d
                    temp := low
                    stack_temp := xor(stack_temp, shr(and(temp, 0x0000000000000000000000000000000000000000ffffffff0000000000000000), 0x40))

                // column e
                    temp := low
                    stack_temp := xor(stack_temp, shr(and(temp, 0x000000000000000000000000000000000000000000000000ffffffff00000000), 0x20))

                // column f
                    temp := low
                    stack_temp := xor(stack_temp, and(temp, 0x00000000000000000000000000000000000000000000000000000000ffffffff))

                    new_high := or(new_high, shl(stack_temp, 0x40))

                // row 6,1 0 1 1 0 0 0 1 1 0 1 0 0 0 1 0
                    stack_temp := byte(0x20, 0x00)
                // column 0
                    temp := high
                    stack_temp := xor(stack_temp, shr(temp, 0xE0))

                // column 1
                /*temp := high
                stack_temp := xor(stack_temp, shr(and(temp, 0x00000000ffffffff000000000000000000000000000000000000000000000000), 0xC0))*/

                // column 2
                    temp := high
                    stack_temp := xor(stack_temp, shr(and(temp, 0x0000000000000000ffffffff0000000000000000000000000000000000000000), 0xA0))

                // column 3
                    temp := high
                    stack_temp := xor(stack_temp, shr(and(temp, 0x000000000000000000000000ffffffff00000000000000000000000000000000), 0x80))

                // column 4
                /*temp := high
                stack_temp := xor(stack_temp, shr(and(temp, 0x00000000000000000000000000000000ffffffff000000000000000000000000), 0x60))*/

                // column 5
                /*temp := high
                stack_temp := xor(stack_temp, shr(and(temp, 0x0000000000000000000000000000000000000000ffffffff0000000000000000), 0x40))*/

                // column 6
                /*temp := high
                stack_temp := xor(stack_temp, shr(and(temp, 0x000000000000000000000000000000000000000000000000ffffffff00000000), 0x20))*/

                // column 7
                    temp := high
                    stack_temp := xor(stack_temp, and(temp, 0x00000000000000000000000000000000000000000000000000000000ffffffff))

                // column 8
                    temp := low
                    stack_temp := xor(stack_temp, shr(temp, 0xE0))

                // column 9
                /*temp := low
                stack_temp := xor(stack_temp, shr(and(temp, 0x00000000ffffffff000000000000000000000000000000000000000000000000), 0xC0))*/

                // column a
                    temp := low
                    stack_temp := xor(stack_temp, shr(and(temp, 0x0000000000000000ffffffff0000000000000000000000000000000000000000), 0xA0))

                // column b
                /*temp := low
                stack_temp := xor(stack_temp, shr(and(temp, 0x000000000000000000000000ffffffff00000000000000000000000000000000), 0x80))*/

                // column c
                /*temp := low
                stack_temp := xor(stack_temp, shr(and(temp, 0x00000000000000000000000000000000ffffffff000000000000000000000000), 0x60))*/

                // column d
                /*temp := low
                stack_temp := xor(stack_temp, shr(and(temp, 0x0000000000000000000000000000000000000000ffffffff0000000000000000), 0x40))*/

                // column e
                    temp := low
                    stack_temp := xor(stack_temp, shr(and(temp, 0x000000000000000000000000000000000000000000000000ffffffff00000000), 0x20))

                // column f
                /*temp := low
                stack_temp := xor(stack_temp, and(temp, 0x00000000000000000000000000000000000000000000000000000000ffffffff))*/

                    new_high := or(new_high, shl(stack_temp, 0x20))

                // row 7,1 0 1 0 1 1 0 1 0 0 1 0 0 0 0 1
                    stack_temp := byte(0x20, 0x00)
                // column 0
                    temp := high
                    stack_temp := xor(stack_temp, shr(temp, 0xE0))

                // column 1
                /*temp := high
                stack_temp := xor(stack_temp, shr(and(temp, 0x00000000ffffffff000000000000000000000000000000000000000000000000), 0xC0))*/

                // column 2
                    temp := high
                    stack_temp := xor(stack_temp, shr(and(temp, 0x0000000000000000ffffffff0000000000000000000000000000000000000000), 0xA0))

                // column 3
                /*temp := high
                stack_temp := xor(stack_temp, shr(and(temp, 0x000000000000000000000000ffffffff00000000000000000000000000000000), 0x80))*/

                // column 4
                    temp := high
                    stack_temp := xor(stack_temp, shr(and(temp, 0x00000000000000000000000000000000ffffffff000000000000000000000000), 0x60))

                // column 5
                    temp := high
                    stack_temp := xor(stack_temp, shr(and(temp, 0x0000000000000000000000000000000000000000ffffffff0000000000000000), 0x40))

                // column 6
                /*temp := high
                stack_temp := xor(stack_temp, shr(and(temp, 0x000000000000000000000000000000000000000000000000ffffffff00000000), 0x20))*/

                // column 7
                    temp := high
                    stack_temp := xor(stack_temp, and(temp, 0x00000000000000000000000000000000000000000000000000000000ffffffff))

                // column 8
                /*temp := low
                stack_temp := xor(stack_temp, shr(temp, 0xE0))*/

                // column 9
                /*temp := low
                stack_temp := xor(stack_temp, shr(and(temp, 0x00000000ffffffff000000000000000000000000000000000000000000000000), 0xC0))*/

                // column a
                    temp := low
                    stack_temp := xor(stack_temp, shr(and(temp, 0x0000000000000000ffffffff0000000000000000000000000000000000000000), 0xA0))

                // column b
                /*temp := low
                stack_temp := xor(stack_temp, shr(and(temp, 0x000000000000000000000000ffffffff00000000000000000000000000000000), 0x80))*/

                // column c
                /*temp := low
                stack_temp := xor(stack_temp, shr(and(temp, 0x00000000000000000000000000000000ffffffff000000000000000000000000), 0x60))*/

                // column d
                /*temp := low
                stack_temp := xor(stack_temp, shr(and(temp, 0x0000000000000000000000000000000000000000ffffffff0000000000000000), 0x40))*/

                // column e
                /*temp := low
                stack_temp := xor(stack_temp, shr(and(temp, 0x000000000000000000000000000000000000000000000000ffffffff00000000), 0x20))*/

                // column f
                    temp := low
                    stack_temp := xor(stack_temp, and(temp, 0x00000000000000000000000000000000000000000000000000000000ffffffff))

                    new_high := or(new_high, stack_temp)

                // row 8,0 1 0 1 0 1 1 0 1 0 0 1 0 0 0 1
                    stack_temp := byte(0x20, 0x00)
                // column 0
                /*temp := high
                stack_temp := xor(stack_temp, shr(temp, 0xE0))*/

                // column 1
                    temp := high
                    stack_temp := xor(stack_temp, shr(and(temp, 0x00000000ffffffff000000000000000000000000000000000000000000000000), 0xC0))

                // column 2
                /*temp := high
                stack_temp := xor(stack_temp, shr(and(temp, 0x0000000000000000ffffffff0000000000000000000000000000000000000000), 0xA0))*/

                // column 3
                    temp := high
                    stack_temp := xor(stack_temp, shr(and(temp, 0x000000000000000000000000ffffffff00000000000000000000000000000000), 0x80))

                // column 4
                /*temp := high
                stack_temp := xor(stack_temp, shr(and(temp, 0x00000000000000000000000000000000ffffffff000000000000000000000000), 0x60))*/

                // column 5
                    temp := high
                    stack_temp := xor(stack_temp, shr(and(temp, 0x0000000000000000000000000000000000000000ffffffff0000000000000000), 0x40))

                // column 6
                    temp := high
                    stack_temp := xor(stack_temp, shr(and(temp, 0x000000000000000000000000000000000000000000000000ffffffff00000000), 0x20))

                // column 7
                /*temp := high
                stack_temp := xor(stack_temp, and(temp, 0x00000000000000000000000000000000000000000000000000000000ffffffff))*/

                // column 8
                    temp := low
                    stack_temp := xor(stack_temp, shr(temp, 0xE0))

                // column 9
                /*temp := low
                stack_temp := xor(stack_temp, shr(and(temp, 0x00000000ffffffff000000000000000000000000000000000000000000000000), 0xC0))*/

                // column a
                /*temp := low
                stack_temp := xor(stack_temp, shr(and(temp, 0x0000000000000000ffffffff0000000000000000000000000000000000000000), 0xA0))*/

                // column b
                    temp := low
                    stack_temp := xor(stack_temp, shr(and(temp, 0x000000000000000000000000ffffffff00000000000000000000000000000000), 0x80))

                // column c
                /*temp := low
                stack_temp := xor(stack_temp, shr(and(temp, 0x00000000000000000000000000000000ffffffff000000000000000000000000), 0x60))*/

                // column d
                /*temp := low
                stack_temp := xor(stack_temp, shr(and(temp, 0x0000000000000000000000000000000000000000ffffffff0000000000000000), 0x40))*/

                // column e
                /*temp := low
                stack_temp := xor(stack_temp, shr(and(temp, 0x000000000000000000000000000000000000000000000000ffffffff00000000), 0x20))*/

                // column f
                    temp := low
                    stack_temp := xor(stack_temp, and(temp, 0x00000000000000000000000000000000000000000000000000000000ffffffff))

                    new_low := or(new_low, shl(stack_temp, 0xE0))

                // row 9,0 0 1 0 1 0 1 1 0 1 0 0 1 0 0 1
                    stack_temp := byte(0x20, 0x00)
                // column 0
                /*temp := high
                stack_temp := xor(stack_temp, shr(temp, 0xE0))*/

                // column 1
                /*temp := high
                stack_temp := xor(stack_temp, shr(and(temp, 0x00000000ffffffff000000000000000000000000000000000000000000000000), 0xC0))*/

                // column 2
                    temp := high
                    stack_temp := xor(stack_temp, shr(and(temp, 0x0000000000000000ffffffff0000000000000000000000000000000000000000), 0xA0))

                // column 3
                /*temp := high
                stack_temp := xor(stack_temp, shr(and(temp, 0x000000000000000000000000ffffffff00000000000000000000000000000000), 0x80))*/

                // column 4
                    temp := high
                    stack_temp := xor(stack_temp, shr(and(temp, 0x00000000000000000000000000000000ffffffff000000000000000000000000), 0x60))

                // column 5
                /*temp := high
                stack_temp := xor(stack_temp, shr(and(temp, 0x0000000000000000000000000000000000000000ffffffff0000000000000000), 0x40))*/

                // column 6
                    temp := high
                    stack_temp := xor(stack_temp, shr(and(temp, 0x000000000000000000000000000000000000000000000000ffffffff00000000), 0x20))

                // column 7
                    temp := high
                    stack_temp := xor(stack_temp, and(temp, 0x00000000000000000000000000000000000000000000000000000000ffffffff))

                // column 8
                /*temp := low
                stack_temp := xor(stack_temp, shr(temp, 0xE0))*/

                // column 9
                    temp := low
                    stack_temp := xor(stack_temp, shr(and(temp, 0x00000000ffffffff000000000000000000000000000000000000000000000000), 0xC0))

                // column a
                /*temp := low
                stack_temp := xor(stack_temp, shr(and(temp, 0x0000000000000000ffffffff0000000000000000000000000000000000000000), 0xA0))*/

                // column b
                /*temp := low
                stack_temp := xor(stack_temp, shr(and(temp, 0x000000000000000000000000ffffffff00000000000000000000000000000000), 0x80))*/

                // column c
                    temp := low
                    stack_temp := xor(stack_temp, shr(and(temp, 0x00000000000000000000000000000000ffffffff000000000000000000000000), 0x60))

                // column d
                /*temp := low
                stack_temp := xor(stack_temp, shr(and(temp, 0x0000000000000000000000000000000000000000ffffffff0000000000000000), 0x40))*/

                // column e
                /*temp := low
                stack_temp := xor(stack_temp, shr(and(temp, 0x000000000000000000000000000000000000000000000000ffffffff00000000), 0x20))*/

                // column f
                    temp := low
                    stack_temp := xor(stack_temp, and(temp, 0x00000000000000000000000000000000000000000000000000000000ffffffff))

                    new_low := or(new_low, shl(stack_temp, 0xC0))

                // row a,0 0 0 1 0 1 0 1 1 0 1 0 0 1 0 1
                    stack_temp := byte(0x20, 0x00)
                // column 0
                /*temp := high
                stack_temp := xor(stack_temp, shr(temp, 0xE0))*/

                // column 1
                /*temp := high
                stack_temp := xor(stack_temp, shr(and(temp, 0x00000000ffffffff000000000000000000000000000000000000000000000000), 0xC0))*/

                // column 2
                /*temp := high
                stack_temp := xor(stack_temp, shr(and(temp, 0x0000000000000000ffffffff0000000000000000000000000000000000000000), 0xA0))*/

                // column 3
                    temp := high
                    stack_temp := xor(stack_temp, shr(and(temp, 0x000000000000000000000000ffffffff00000000000000000000000000000000), 0x80))

                // column 4
                /*temp := high
                stack_temp := xor(stack_temp, shr(and(temp, 0x00000000000000000000000000000000ffffffff000000000000000000000000), 0x60))*/

                // column 5
                    temp := high
                    stack_temp := xor(stack_temp, shr(and(temp, 0x0000000000000000000000000000000000000000ffffffff0000000000000000), 0x40))

                // column 6
                /*temp := high
                stack_temp := xor(stack_temp, shr(and(temp, 0x000000000000000000000000000000000000000000000000ffffffff00000000), 0x20))*/

                // column 7
                    temp := high
                    stack_temp := xor(stack_temp, and(temp, 0x00000000000000000000000000000000000000000000000000000000ffffffff))

                // column 8
                    temp := low
                    stack_temp := xor(stack_temp, shr(temp, 0xE0))

                // column 9
                /*temp := low
                stack_temp := xor(stack_temp, shr(and(temp, 0x00000000ffffffff000000000000000000000000000000000000000000000000), 0xC0))*/

                // column a
                    temp := low
                    stack_temp := xor(stack_temp, shr(and(temp, 0x0000000000000000ffffffff0000000000000000000000000000000000000000), 0xA0))

                // column b
                /*temp := low
                stack_temp := xor(stack_temp, shr(and(temp, 0x000000000000000000000000ffffffff00000000000000000000000000000000), 0x80))*/

                // column c
                /*temp := low
                stack_temp := xor(stack_temp, shr(and(temp, 0x00000000000000000000000000000000ffffffff000000000000000000000000), 0x60))*/

                // column d
                    temp := low
                    stack_temp := xor(stack_temp, shr(and(temp, 0x0000000000000000000000000000000000000000ffffffff0000000000000000), 0x40))

                // column e
                /*temp := low
                stack_temp := xor(stack_temp, shr(and(temp, 0x000000000000000000000000000000000000000000000000ffffffff00000000), 0x20))*/

                // column f
                    temp := low
                    stack_temp := xor(stack_temp, and(temp, 0x00000000000000000000000000000000000000000000000000000000ffffffff))

                    new_low := or(new_low, shl(stack_temp, 0xA0))


                // row b,0 0 0 0 1 0 1 0 1 1 0 1 0 0 1 1
                    stack_temp := byte(0x20, 0x00)
                // column 0
                /*temp := high
                stack_temp := xor(stack_temp, shr(temp, 0xE0))*/

                // column 1
                /*temp := high
                stack_temp := xor(stack_temp, shr(and(temp, 0x00000000ffffffff000000000000000000000000000000000000000000000000), 0xC0))*/

                // column 2
                /*temp := high
                stack_temp := xor(stack_temp, shr(and(temp, 0x0000000000000000ffffffff0000000000000000000000000000000000000000), 0xA0))*/

                // column 3
                /*temp := high
                stack_temp := xor(stack_temp, shr(and(temp, 0x000000000000000000000000ffffffff00000000000000000000000000000000), 0x80))*/

                // column 4
                    temp := high
                    stack_temp := xor(stack_temp, shr(and(temp, 0x00000000000000000000000000000000ffffffff000000000000000000000000), 0x60))

                // column 5
                /*temp := high
                stack_temp := xor(stack_temp, shr(and(temp, 0x0000000000000000000000000000000000000000ffffffff0000000000000000), 0x40))*/

                // column 6
                    temp := high
                    stack_temp := xor(stack_temp, shr(and(temp, 0x000000000000000000000000000000000000000000000000ffffffff00000000), 0x20))

                // column 7
                /*temp := high
                stack_temp := xor(stack_temp, and(temp, 0x00000000000000000000000000000000000000000000000000000000ffffffff))*/

                // column 8
                    temp := low
                    stack_temp := xor(stack_temp, shr(temp, 0xE0))

                // column 9
                    temp := low
                    stack_temp := xor(stack_temp, shr(and(temp, 0x00000000ffffffff000000000000000000000000000000000000000000000000), 0xC0))

                // column a
                /*temp := low
                stack_temp := xor(stack_temp, shr(and(temp, 0x0000000000000000ffffffff0000000000000000000000000000000000000000), 0xA0))*/

                // column b
                    temp := low
                    stack_temp := xor(stack_temp, shr(and(temp, 0x000000000000000000000000ffffffff00000000000000000000000000000000), 0x80))

                // column c
                /*temp := low
                stack_temp := xor(stack_temp, shr(and(temp, 0x00000000000000000000000000000000ffffffff000000000000000000000000), 0x60))*/

                // column d
                /*temp := low
                stack_temp := xor(stack_temp, shr(and(temp, 0x0000000000000000000000000000000000000000ffffffff0000000000000000), 0x40))*/

                // column e
                    temp := low
                    stack_temp := xor(stack_temp, shr(and(temp, 0x000000000000000000000000000000000000000000000000ffffffff00000000), 0x20))

                // column f
                    temp := low
                    stack_temp := xor(stack_temp, and(temp, 0x00000000000000000000000000000000000000000000000000000000ffffffff))

                    new_low := or(new_low, shl(stack_temp, 0x80))

                // row c,1 1 1 1 0 0 0 0 1 0 0 1 1 0 0 0
                    stack_temp := byte(0x20, 0x00)
                // column 0
                    temp := high
                    stack_temp := xor(stack_temp, shr(temp, 0xE0))

                // column 1
                    temp := high
                    stack_temp := xor(stack_temp, shr(and(temp, 0x00000000ffffffff000000000000000000000000000000000000000000000000), 0xC0))

                // column 2
                    temp := high
                    stack_temp := xor(stack_temp, shr(and(temp, 0x0000000000000000ffffffff0000000000000000000000000000000000000000), 0xA0))

                // column 3
                    temp := high
                    stack_temp := xor(stack_temp, shr(and(temp, 0x000000000000000000000000ffffffff00000000000000000000000000000000), 0x80))

                // column 4
                /*temp := high
                stack_temp := xor(stack_temp, shr(and(temp, 0x00000000000000000000000000000000ffffffff000000000000000000000000), 0x60))*/

                // column 5
                /*temp := high
                stack_temp := xor(stack_temp, shr(and(temp, 0x0000000000000000000000000000000000000000ffffffff0000000000000000), 0x40))*/

                // column 6
                /*temp := high
                stack_temp := xor(stack_temp, shr(and(temp, 0x000000000000000000000000000000000000000000000000ffffffff00000000), 0x20))*/

                // column 7
                /*temp := high
                stack_temp := xor(stack_temp, and(temp, 0x00000000000000000000000000000000000000000000000000000000ffffffff))*/

                // column 8
                    temp := low
                    stack_temp := xor(stack_temp, shr(temp, 0xE0))

                // column 9
                /*temp := low
                stack_temp := xor(stack_temp, shr(and(temp, 0x00000000ffffffff000000000000000000000000000000000000000000000000), 0xC0))*/

                // column a
                /*temp := low
                stack_temp := xor(stack_temp, shr(and(temp, 0x0000000000000000ffffffff0000000000000000000000000000000000000000), 0xA0))*/

                // column b
                    temp := low
                    stack_temp := xor(stack_temp, shr(and(temp, 0x000000000000000000000000ffffffff00000000000000000000000000000000), 0x80))

                // column c
                    temp := low
                    stack_temp := xor(stack_temp, shr(and(temp, 0x00000000000000000000000000000000ffffffff000000000000000000000000), 0x60))

                // column d
                /*temp := low
                stack_temp := xor(stack_temp, shr(and(temp, 0x0000000000000000000000000000000000000000ffffffff0000000000000000), 0x40))*/

                // column e
                /*temp := low
                stack_temp := xor(stack_temp, shr(and(temp, 0x000000000000000000000000000000000000000000000000ffffffff00000000), 0x20))*/

                // column f
                /*temp := low
                stack_temp := xor(stack_temp, and(temp, 0x00000000000000000000000000000000000000000000000000000000ffffffff))*/

                    new_low := or(new_low, shl(stack_temp, 0x60))

                // row d,0 1 1 1 1 0 0 0 0 1 0 0 1 1 0 0
                    stack_temp := byte(0x20, 0x00)
                // column 0
                /*temp := high
                stack_temp := xor(stack_temp, shr(temp, 0xE0))*/

                // column 1
                    temp := high
                    stack_temp := xor(stack_temp, shr(and(temp, 0x00000000ffffffff000000000000000000000000000000000000000000000000), 0xC0))

                // column 2
                    temp := high
                    stack_temp := xor(stack_temp, shr(and(temp, 0x0000000000000000ffffffff0000000000000000000000000000000000000000), 0xA0))

                // column 3
                    temp := high
                    stack_temp := xor(stack_temp, shr(and(temp, 0x000000000000000000000000ffffffff00000000000000000000000000000000), 0x80))

                // column 4
                    temp := high
                    stack_temp := xor(stack_temp, shr(and(temp, 0x00000000000000000000000000000000ffffffff000000000000000000000000), 0x60))

                // column 5
                /*temp := high
                stack_temp := xor(stack_temp, shr(and(temp, 0x0000000000000000000000000000000000000000ffffffff0000000000000000), 0x40))*/

                // column 6
                /*temp := high
                stack_temp := xor(stack_temp, shr(and(temp, 0x000000000000000000000000000000000000000000000000ffffffff00000000), 0x20))*/

                // column 7
                /*temp := high
                stack_temp := xor(stack_temp, and(temp, 0x00000000000000000000000000000000000000000000000000000000ffffffff))*/

                // column 8
                /*temp := low
                stack_temp := xor(stack_temp, shr(temp, 0xE0))*/

                // column 9
                    temp := low
                    stack_temp := xor(stack_temp, shr(and(temp, 0x00000000ffffffff000000000000000000000000000000000000000000000000), 0xC0))

                // column a
                /*temp := low
                stack_temp := xor(stack_temp, shr(and(temp, 0x0000000000000000ffffffff0000000000000000000000000000000000000000), 0xA0))*/

                // column b
                /*temp := low
                stack_temp := xor(stack_temp, shr(and(temp, 0x000000000000000000000000ffffffff00000000000000000000000000000000), 0x80))*/

                // column c
                    temp := low
                    stack_temp := xor(stack_temp, shr(and(temp, 0x00000000000000000000000000000000ffffffff000000000000000000000000), 0x60))

                // column d
                    temp := low
                    stack_temp := xor(stack_temp, shr(and(temp, 0x0000000000000000000000000000000000000000ffffffff0000000000000000), 0x40))

                // column e
                /*temp := low
                stack_temp := xor(stack_temp, shr(and(temp, 0x000000000000000000000000000000000000000000000000ffffffff00000000), 0x20))*/

                // column f
                /*temp := low
                stack_temp := xor(stack_temp, and(temp, 0x00000000000000000000000000000000000000000000000000000000ffffffff))*/

                    new_low := or(new_low, shl(stack_temp, 0x40))

                // row e,0 0 1 1 1 1 0 0 0 0 1 0 0 1 1 0
                    stack_temp := byte(0x20, 0x00)
                // column 0
                /*temp := high
                stack_temp := xor(stack_temp, shr(temp, 0xE0))*/

                // column 1
                /*temp := high
                stack_temp := xor(stack_temp, shr(and(temp, 0x00000000ffffffff000000000000000000000000000000000000000000000000), 0xC0))*/

                // column 2
                    temp := high
                    stack_temp := xor(stack_temp, shr(and(temp, 0x0000000000000000ffffffff0000000000000000000000000000000000000000), 0xA0))

                // column 3
                    temp := high
                    stack_temp := xor(stack_temp, shr(and(temp, 0x000000000000000000000000ffffffff00000000000000000000000000000000), 0x80))

                // column 4
                    temp := high
                    stack_temp := xor(stack_temp, shr(and(temp, 0x00000000000000000000000000000000ffffffff000000000000000000000000), 0x60))

                // column 5
                    temp := high
                    stack_temp := xor(stack_temp, shr(and(temp, 0x0000000000000000000000000000000000000000ffffffff0000000000000000), 0x40))

                // column 6
                /*temp := high
                stack_temp := xor(stack_temp, shr(and(temp, 0x000000000000000000000000000000000000000000000000ffffffff00000000), 0x20))*/

                // column 7
                /*temp := high
                stack_temp := xor(stack_temp, and(temp, 0x00000000000000000000000000000000000000000000000000000000ffffffff))*/

                // column 8
                /*temp := low
                stack_temp := xor(stack_temp, shr(temp, 0xE0))*/

                // column 9
                /*temp := low
                stack_temp := xor(stack_temp, shr(and(temp, 0x00000000ffffffff000000000000000000000000000000000000000000000000), 0xC0))*/

                // column a
                    temp := low
                    stack_temp := xor(stack_temp, shr(and(temp, 0x0000000000000000ffffffff0000000000000000000000000000000000000000), 0xA0))

                // column b
                /*temp := low
                stack_temp := xor(stack_temp, shr(and(temp, 0x000000000000000000000000ffffffff00000000000000000000000000000000), 0x80))*/

                // column c
                /*temp := low
                stack_temp := xor(stack_temp, shr(and(temp, 0x00000000000000000000000000000000ffffffff000000000000000000000000), 0x60))*/

                // column d
                    temp := low
                    stack_temp := xor(stack_temp, shr(and(temp, 0x0000000000000000000000000000000000000000ffffffff0000000000000000), 0x40))

                // column e
                    temp := low
                    stack_temp := xor(stack_temp, shr(and(temp, 0x000000000000000000000000000000000000000000000000ffffffff00000000), 0x20))

                // column f
                /*temp := low
                stack_temp := xor(stack_temp, and(temp, 0x00000000000000000000000000000000000000000000000000000000ffffffff))*/

                    new_low := or(new_low, shl(stack_temp, 0x20))

                // row f,1 1 1 0 1 0 1 1 1 1 1 0 0 0 1 1
                    stack_temp := byte(0x20, 0x00)
                // column 0
                    temp := high
                    stack_temp := xor(stack_temp, shr(temp, 0xE0))

                // column 1
                    temp := high
                    stack_temp := xor(stack_temp, shr(and(temp, 0x00000000ffffffff000000000000000000000000000000000000000000000000), 0xC0))

                // column 2
                    temp := high
                    stack_temp := xor(stack_temp, shr(and(temp, 0x0000000000000000ffffffff0000000000000000000000000000000000000000), 0xA0))

                // column 3
                /*temp := high
                stack_temp := xor(stack_temp, shr(and(temp, 0x000000000000000000000000ffffffff00000000000000000000000000000000), 0x80))*/

                // column 4
                    temp := high
                    stack_temp := xor(stack_temp, shr(and(temp, 0x00000000000000000000000000000000ffffffff000000000000000000000000), 0x60))

                // column 5
                /*temp := high
                stack_temp := xor(stack_temp, shr(and(temp, 0x0000000000000000000000000000000000000000ffffffff0000000000000000), 0x40))*/

                // column 6
                    temp := high
                    stack_temp := xor(stack_temp, shr(and(temp, 0x000000000000000000000000000000000000000000000000ffffffff00000000), 0x20))

                // column 7
                    temp := high
                    stack_temp := xor(stack_temp, and(temp, 0x00000000000000000000000000000000000000000000000000000000ffffffff))

                // column 8
                    temp := low
                    stack_temp := xor(stack_temp, shr(temp, 0xE0))

                // column 9
                    temp := low
                    stack_temp := xor(stack_temp, shr(and(temp, 0x00000000ffffffff000000000000000000000000000000000000000000000000), 0xC0))

                // column a
                    temp := low
                    stack_temp := xor(stack_temp, shr(and(temp, 0x0000000000000000ffffffff0000000000000000000000000000000000000000), 0xA0))

                // column b
                /*temp := low
                stack_temp := xor(stack_temp, shr(and(temp, 0x000000000000000000000000ffffffff00000000000000000000000000000000), 0x80))*/

                // column c
                /*temp := low
                stack_temp := xor(stack_temp, shr(and(temp, 0x00000000000000000000000000000000ffffffff000000000000000000000000), 0x60))*/

                // column d
                /*temp := low
                stack_temp := xor(stack_temp, shr(and(temp, 0x0000000000000000000000000000000000000000ffffffff0000000000000000), 0x40))*/

                // column e
                    temp := low
                    stack_temp := xor(stack_temp, shr(and(temp, 0x000000000000000000000000000000000000000000000000ffffffff00000000), 0x20))

                // column f
                    temp := low
                    stack_temp := xor(stack_temp, and(temp, 0x00000000000000000000000000000000000000000000000000000000ffffffff))

                    new_low := or(new_low, stack_temp)


                    low := new_low
                    high := new_high

                // bit matrix
                }

                {// circulant multiplication
                    new_low := byte(0x20, 0x00)
                    new_high := byte(0x20, 0x00)

                /*coefficients = [
                    [0, 2, 4],
                    [0, 13, 22],
                    [0, 4, 19],
                    [0, 3, 14],
                    [0, 27, 31],
                    [0, 3, 8],
                    [0, 17, 26],
                    [0, 3, 12],
                    [0, 18, 22],
                    [0, 12, 18],
                    [0, 4, 7],
                    [0, 4, 31],
                    [0, 12, 27],
                    [0, 7, 17],
                    [0, 7, 8],
                    [0, 1, 13]
                ];*/



                // alloc a item for temp usage of 32 bits
                // we use the lowest 32 bits of 256 bits
                    let stack_temp := byte(0x20, 0x00)// for output_vector[j]
                    let temp_high := byte(0x20, 0x00)
                    let temp_low := byte(0x20, 0x00)
                    let state_vector := byte(0x20, 0x00)
                    let temp1 := byte(0x20, 0x00)// for dup of original state_vector
                    let temp2 := byte(0x20, 0x00)// for dup of original state_vector

                // row 0,0, 2, 4
                    temp_high := high
                    state_vector := shr(temp_high, 0xE0)

                    stack_temp := state_vector

                    temp1 := state_vector
                    temp2 := state_vector

                    stack_temp := xor(stack_temp,or(
                    and(shl(temp1,2),0x00000000000000000000000000000000000000000000000000000000ffffffff),
                    shr(temp2,30)
                    ))

                    temp1 := state_vector
                    temp1 := state_vector

                    stack_temp := xor(stack_temp,or(
                    and(shl(temp1,4),0x00000000000000000000000000000000000000000000000000000000ffffffff),
                    shr(temp2,28)
                    ))

                    new_high := or(new_high, shl(stack_temp, 0xE0))

                // row 1,0, 13, 22

                    temp_high := high
                    state_vector := shr(and(temp_high, 0x00000000ffffffff000000000000000000000000000000000000000000000000), 0xC0)

                    stack_temp := state_vector

                    temp1 := state_vector
                    temp2 := state_vector

                    stack_temp := xor(stack_temp,or(
                    and(shl(temp1,13),0x00000000000000000000000000000000000000000000000000000000ffffffff),
                    shr(temp2,17)
                    ))

                    temp1 := state_vector
                    temp2 := state_vector

                    stack_temp := xor(stack_temp,or(
                    and(shl(temp1,22),0x00000000000000000000000000000000000000000000000000000000ffffffff),
                    shr(temp2,10)
                    ))

                    new_high := or(new_high, shl(stack_temp, 0xC0))

                // row 2,0, 4, 19

                    temp_high := high
                    state_vector := shr(and(temp_high, 0x0000000000000000ffffffff0000000000000000000000000000000000000000), 0xA0)

                    stack_temp := state_vector

                    temp1 := state_vector
                    temp2 := state_vector

                    stack_temp := xor(stack_temp,or(
                    and(shl(temp1,4),0x00000000000000000000000000000000000000000000000000000000ffffffff),
                    shr(temp2,28)
                    ))

                    temp1 := state_vector
                    temp2 := state_vector

                    stack_temp := xor(stack_temp,or(
                    and(shl(temp1,19),0x00000000000000000000000000000000000000000000000000000000ffffffff),
                    shr(temp2,13)
                    ))

                    new_high := or(new_high, shl(stack_temp, 0xA0))

                // row 3,0, 3, 14

                    temp_high := high
                    state_vector := shr(and(temp_high, 0x000000000000000000000000ffffffff00000000000000000000000000000000), 0x80)

                    stack_temp := state_vector

                    temp1 := state_vector
                    temp2 := state_vector

                    stack_temp := xor(stack_temp,or(
                    and(shl(temp1,3),0x00000000000000000000000000000000000000000000000000000000ffffffff),
                    shr(temp2,29)
                    ))

                    temp1 := state_vector
                    temp2 := state_vector

                    stack_temp := xor(stack_temp,or(
                    and(shl(temp1,14),0x00000000000000000000000000000000000000000000000000000000ffffffff),
                    shr(temp2,18)
                    ))

                    new_high := or(new_high, shl(stack_temp, 0x80))

                // row 4,0, 27, 31

                    temp_high := high
                    state_vector := shr(and(temp_high, 0x00000000000000000000000000000000ffffffff000000000000000000000000), 0x60)

                    stack_temp := state_vector

                    temp1 := state_vector
                    temp2 := state_vector

                    stack_temp := xor(stack_temp,or(
                    and(shl(temp1,27),0x00000000000000000000000000000000000000000000000000000000ffffffff),
                    shr(temp2,5)
                    ))

                    temp1 := state_vector
                    temp2 := state_vector

                    stack_temp := xor(stack_temp,or(
                    and(shl(temp1,31),0x00000000000000000000000000000000000000000000000000000000ffffffff),
                    shr(temp2,1)
                    ))

                    new_high := or(new_high, shl(stack_temp, 0x60))

                // row 5,0, 3, 8

                    temp_high := high
                    state_vector := shr(and(temp_high, 0x0000000000000000000000000000000000000000ffffffff0000000000000000), 0x40)

                    stack_temp := state_vector

                    temp1 := state_vector
                    temp2 := state_vector

                    stack_temp := xor(stack_temp,or(
                    and(shl(temp1,3),0x00000000000000000000000000000000000000000000000000000000ffffffff),
                    shr(temp2,29)
                    ))

                    temp1 := state_vector
                    temp2 := state_vector

                    stack_temp := xor(stack_temp,or(
                    and(shl(temp1,8),0x00000000000000000000000000000000000000000000000000000000ffffffff),
                    shr(temp2,24)
                    ))

                    new_high := or(new_high, shl(stack_temp, 0x40))

                // row 6,0, 17, 26

                    temp_high := high
                    state_vector := shr(and(temp_high, 0x000000000000000000000000000000000000000000000000ffffffff00000000), 0x20)

                    stack_temp := state_vector

                    temp1 := state_vector
                    temp2 := state_vector

                    stack_temp := xor(stack_temp,or(
                    and(shl(temp1,17),0x00000000000000000000000000000000000000000000000000000000ffffffff),
                    shr(temp2,15)
                    ))

                    temp1 := state_vector
                    temp2 := state_vector

                    stack_temp := xor(stack_temp,or(
                    and(shl(temp1,26),0x00000000000000000000000000000000000000000000000000000000ffffffff),
                    shr(temp2,6)
                    ))

                    new_high := or(new_high, shl(stack_temp, 0x20))

                // row 7,0, 3, 12

                    temp_high := high
                    state_vector := and(temp_high, 0x00000000000000000000000000000000000000000000000000000000ffffffff)

                    stack_temp := state_vector

                    temp1 := state_vector
                    temp2 := state_vector

                    stack_temp := xor(stack_temp,or(
                    and(shl(temp1,3),0x00000000000000000000000000000000000000000000000000000000ffffffff),
                    shr(temp2,29)
                    ))

                    temp1 := state_vector
                    temp2 := state_vector

                    stack_temp := xor(stack_temp,or(
                    and(shl(temp1,12),0x00000000000000000000000000000000000000000000000000000000ffffffff),
                    shr(temp2,20)
                    ))

                    new_high := or(new_high, stack_temp)

                // row 8,0, 18, 22

                    temp_low := low
                    state_vector := shr(temp_low, 0xE0)

                    stack_temp := state_vector

                    temp1 := state_vector
                    temp2 := state_vector

                    stack_temp := xor(stack_temp,or(
                    and(shl(temp1,18),0x00000000000000000000000000000000000000000000000000000000ffffffff),
                    shr(temp2,14)
                    ))

                    temp1 := state_vector
                    temp2 := state_vector

                    stack_temp := xor(stack_temp,or(
                    and(shl(temp1,22),0x00000000000000000000000000000000000000000000000000000000ffffffff),
                    shr(temp2,10)
                    ))

                    new_low := or(new_low, shl(stack_temp, 0xE0))

                // row 9,0, 12, 18

                    temp_low := low
                    state_vector := shr(and(temp_low, 0x00000000ffffffff000000000000000000000000000000000000000000000000), 0xC0)

                    stack_temp := state_vector

                    temp1 := state_vector
                    temp2 := state_vector

                    stack_temp := xor(stack_temp,or(
                    and(shl(temp1,12),0x00000000000000000000000000000000000000000000000000000000ffffffff),
                    shr(temp2,20)
                    ))

                    temp1 := state_vector
                    temp2 := state_vector

                    stack_temp := xor(stack_temp,or(
                    and(shl(temp1,18),0x00000000000000000000000000000000000000000000000000000000ffffffff),
                    shr(temp2,14)
                    ))

                    new_low := or(new_low, shl(stack_temp, 0xC0))

                // row a,0, 4, 7

                    temp_low := low
                    state_vector := shr(and(temp_low, 0x0000000000000000ffffffff0000000000000000000000000000000000000000), 0xA0)

                    stack_temp := state_vector

                    temp1 := state_vector
                    temp2 := state_vector

                    stack_temp := xor(stack_temp,or(
                    and(shl(temp1,4),0x00000000000000000000000000000000000000000000000000000000ffffffff),
                    shr(temp2,28)
                    ))

                    temp1 := state_vector
                    temp2 := state_vector

                    stack_temp := xor(stack_temp,or(
                    and(shl(temp1,7),0x00000000000000000000000000000000000000000000000000000000ffffffff),
                    shr(temp2,25)
                    ))

                    new_low := or(new_low, shl(stack_temp, 0xA0))

                // row b,0, 4, 31

                    temp_low := low
                    state_vector := shr(and(temp_low, 0x000000000000000000000000ffffffff00000000000000000000000000000000), 0x80)

                    stack_temp := state_vector

                    temp1 := state_vector
                    temp2 := state_vector

                    stack_temp := xor(stack_temp,or(
                    and(shl(temp1,4),0x00000000000000000000000000000000000000000000000000000000ffffffff),
                    shr(temp2,28)
                    ))

                    temp1 := state_vector
                    temp2 := state_vector

                    stack_temp := xor(stack_temp,or(
                    and(shl(temp1,31),0x00000000000000000000000000000000000000000000000000000000ffffffff),
                    shr(temp2,1)
                    ))

                    new_low := or(new_low, shl(stack_temp, 0x80))

                // row c,0, 12, 27

                    temp_low := low
                    state_vector := shr(and(temp_low, 0x00000000000000000000000000000000ffffffff000000000000000000000000), 0x60)

                    stack_temp := state_vector

                    temp1 := state_vector
                    temp2 := state_vector

                    stack_temp := xor(stack_temp,or(
                    and(shl(temp1,12),0x00000000000000000000000000000000000000000000000000000000ffffffff),
                    shr(temp2,20)
                    ))

                    temp1 := state_vector
                    temp2 := state_vector

                    stack_temp := xor(stack_temp,or(
                    and(shl(temp1,27),0x00000000000000000000000000000000000000000000000000000000ffffffff),
                    shr(temp2,5)
                    ))

                    new_low := or(new_low, shl(stack_temp, 0x60))

                // row d,0, 7, 17

                    temp_low := low
                    state_vector := shr(and(temp_low, 0x0000000000000000000000000000000000000000ffffffff0000000000000000), 0x40)

                    stack_temp := state_vector

                    temp1 := state_vector
                    temp2 := state_vector

                    stack_temp := xor(stack_temp,or(
                    and(shl(temp1,7),0x00000000000000000000000000000000000000000000000000000000ffffffff),
                    shr(temp2,25)
                    ))

                    temp1 := state_vector
                    temp2 := state_vector

                    stack_temp := xor(stack_temp,or(
                    and(shl(temp1,17),0x00000000000000000000000000000000000000000000000000000000ffffffff),
                    shr(temp2,15)
                    ))

                    new_low := or(new_low, shl(stack_temp, 0x40))

                // row e,0, 7, 8

                    temp_low := low
                    state_vector := shr(and(temp_low, 0x000000000000000000000000000000000000000000000000ffffffff00000000), 0x20)

                    stack_temp := state_vector

                    temp1 := state_vector
                    temp2 := state_vector

                    stack_temp := xor(stack_temp,or(
                    and(shl(temp1,7),0x00000000000000000000000000000000000000000000000000000000ffffffff),
                    shr(temp2,25)
                    ))

                    temp1 := state_vector
                    temp2 := state_vector

                    stack_temp := xor(stack_temp,or(
                    and(shl(temp1,8),0x00000000000000000000000000000000000000000000000000000000ffffffff),
                    shr(temp2,24)
                    ))

                    new_low := or(new_low, shl(stack_temp, 0x20))

                // row f,0, 1, 13

                    temp_low := low
                    state_vector := and(temp_low, 0x00000000000000000000000000000000000000000000000000000000ffffffff)

                    stack_temp := state_vector

                    temp1 := state_vector
                    temp2 := state_vector

                    stack_temp := xor(stack_temp,or(
                    and(shl(temp1,1),0x00000000000000000000000000000000000000000000000000000000ffffffff),
                    shr(temp2,31)
                    ))

                    temp1 := state_vector
                    temp2 := state_vector

                    stack_temp := xor(stack_temp,or(
                    and(shl(temp1,13),0x00000000000000000000000000000000000000000000000000000000ffffffff),
                    shr(temp2,19)
                    ))

                    new_low := or(new_low,stack_temp)

                // finish
                    low := new_low
                    high := new_high

                // circulant multiplication
                }


                {//Injection of Constants

                    switch round

                    case 0{
                        high := xor(high,0x6e9e40ae71927c029a13d3b1daec32ad3d8951cfe1c9fe9ab806b54cacbbf417)
                        low := xor(low,0x6e9e40ae71927c029a13d3b1daec32ad3d8951cfe1c9fe9ab806b54cacbbf417)
                    }
                    case 1{
                        high := xor(high,0x6e9e40ae71927c029a13d3b1daec32ad3d8951cfe1c9fe9ab806b54cacbbf417)
                        low := xor(low,0x6e9e40ae71927c029a13d3b1daec32ad3d8951cfe1c9fe9ab806b54cacbbf417)
                    }
                    case 2{
                        high := xor(high,0x6e9e40ae71927c029a13d3b1daec32ad3d8951cfe1c9fe9ab806b54cacbbf417)
                        low := xor(low,0x6e9e40ae71927c029a13d3b1daec32ad3d8951cfe1c9fe9ab806b54cacbbf417)
                    }
                    case 3{
                        high := xor(high,0x6e9e40ae71927c029a13d3b1daec32ad3d8951cfe1c9fe9ab806b54cacbbf417)
                        low := xor(low,0x6e9e40ae71927c029a13d3b1daec32ad3d8951cfe1c9fe9ab806b54cacbbf417)
                    }
                    case 4{
                        high := xor(high,0x6e9e40ae71927c029a13d3b1daec32ad3d8951cfe1c9fe9ab806b54cacbbf417)
                        low := xor(low,0x6e9e40ae71927c029a13d3b1daec32ad3d8951cfe1c9fe9ab806b54cacbbf417)
                    }
                    case 5{
                        high := xor(high,0x6e9e40ae71927c029a13d3b1daec32ad3d8951cfe1c9fe9ab806b54cacbbf417)
                        low := xor(low,0x6e9e40ae71927c029a13d3b1daec32ad3d8951cfe1c9fe9ab806b54cacbbf417)
                    }
                    case 6{
                        high := xor(high,0x6e9e40ae71927c029a13d3b1daec32ad3d8951cfe1c9fe9ab806b54cacbbf417)
                        low := xor(low,0x6e9e40ae71927c029a13d3b1daec32ad3d8951cfe1c9fe9ab806b54cacbbf417)
                    }
                    case 7{
                        high := xor(high,0x6e9e40ae71927c029a13d3b1daec32ad3d8951cfe1c9fe9ab806b54cacbbf417)
                        low := xor(low,0x6e9e40ae71927c029a13d3b1daec32ad3d8951cfe1c9fe9ab806b54cacbbf417)
                    }
                    case 8{
                        high := xor(high,0x6e9e40ae71927c029a13d3b1daec32ad3d8951cfe1c9fe9ab806b54cacbbf417)
                        low := xor(low,0x6e9e40ae71927c029a13d3b1daec32ad3d8951cfe1c9fe9ab806b54cacbbf417)
                    }
                    case 9{
                        high := xor(high,0x6e9e40ae71927c029a13d3b1daec32ad3d8951cfe1c9fe9ab806b54cacbbf417)
                        low := xor(low,0x6e9e40ae71927c029a13d3b1daec32ad3d8951cfe1c9fe9ab806b54cacbbf417)
                    }
                    case 10{
                        high := xor(high,0x6e9e40ae71927c029a13d3b1daec32ad3d8951cfe1c9fe9ab806b54cacbbf417)
                        low := xor(low,0x6e9e40ae71927c029a13d3b1daec32ad3d8951cfe1c9fe9ab806b54cacbbf417)
                    }
                    case 11{
                        high := xor(high,0x6e9e40ae71927c029a13d3b1daec32ad3d8951cfe1c9fe9ab806b54cacbbf417)
                        low := xor(low,0x6e9e40ae71927c029a13d3b1daec32ad3d8951cfe1c9fe9ab806b54cacbbf417)
                    }
                    case 12{
                        high := xor(high,0x6e9e40ae71927c029a13d3b1daec32ad3d8951cfe1c9fe9ab806b54cacbbf417)
                        low := xor(low,0x6e9e40ae71927c029a13d3b1daec32ad3d8951cfe1c9fe9ab806b54cacbbf417)
                    }
                    case 13{
                        high := xor(high,0x6e9e40ae71927c029a13d3b1daec32ad3d8951cfe1c9fe9ab806b54cacbbf417)
                        low := xor(low,0x6e9e40ae71927c029a13d3b1daec32ad3d8951cfe1c9fe9ab806b54cacbbf417)
                    }
                    case 14{
                        high := xor(high,0x6e9e40ae71927c029a13d3b1daec32ad3d8951cfe1c9fe9ab806b54cacbbf417)
                        low := xor(low,0x6e9e40ae71927c029a13d3b1daec32ad3d8951cfe1c9fe9ab806b54cacbbf417)
                    }
                    case 15{
                        high := xor(high,0x6e9e40ae71927c029a13d3b1daec32ad3d8951cfe1c9fe9ab806b54cacbbf417)
                        low := xor(low,0x6e9e40ae71927c029a13d3b1daec32ad3d8951cfe1c9fe9ab806b54cacbbf417)
                    }
                    case 16{
                        high := xor(high,0x6e9e40ae71927c029a13d3b1daec32ad3d8951cfe1c9fe9ab806b54cacbbf417)
                        low := xor(low,0x6e9e40ae71927c029a13d3b1daec32ad3d8951cfe1c9fe9ab806b54cacbbf417)
                    }
                    case 17{
                        high := xor(high,0x6e9e40ae71927c029a13d3b1daec32ad3d8951cfe1c9fe9ab806b54cacbbf417)
                        low := xor(low,0x6e9e40ae71927c029a13d3b1daec32ad3d8951cfe1c9fe9ab806b54cacbbf417)
                    }
                    case 18{
                        high := xor(high,0x6e9e40ae71927c029a13d3b1daec32ad3d8951cfe1c9fe9ab806b54cacbbf417)
                        low := xor(low,0x6e9e40ae71927c029a13d3b1daec32ad3d8951cfe1c9fe9ab806b54cacbbf417)
                    }
                    case 19{
                        high := xor(high,0x6e9e40ae71927c029a13d3b1daec32ad3d8951cfe1c9fe9ab806b54cacbbf417)
                        low := xor(low,0x6e9e40ae71927c029a13d3b1daec32ad3d8951cfe1c9fe9ab806b54cacbbf417)
                    }
                    case 20{
                        high := xor(high,0x6e9e40ae71927c029a13d3b1daec32ad3d8951cfe1c9fe9ab806b54cacbbf417)
                        low := xor(low,0x6e9e40ae71927c029a13d3b1daec32ad3d8951cfe1c9fe9ab806b54cacbbf417)
                    }
                    case 21{
                        high := xor(high,0x6e9e40ae71927c029a13d3b1daec32ad3d8951cfe1c9fe9ab806b54cacbbf417)
                        low := xor(low,0x6e9e40ae71927c029a13d3b1daec32ad3d8951cfe1c9fe9ab806b54cacbbf417)
                    }
                    case 22{
                        high := xor(high,0x6e9e40ae71927c029a13d3b1daec32ad3d8951cfe1c9fe9ab806b54cacbbf417)
                        low := xor(low,0x6e9e40ae71927c029a13d3b1daec32ad3d8951cfe1c9fe9ab806b54cacbbf417)
                    }
                    case 23{
                        high := xor(high,0x6e9e40ae71927c029a13d3b1daec32ad3d8951cfe1c9fe9ab806b54cacbbf417)
                        low := xor(low,0x6e9e40ae71927c029a13d3b1daec32ad3d8951cfe1c9fe9ab806b54cacbbf417)
                    }
                    case 24{
                        high := xor(high,0x6e9e40ae71927c029a13d3b1daec32ad3d8951cfe1c9fe9ab806b54cacbbf417)
                        low := xor(low,0x6e9e40ae71927c029a13d3b1daec32ad3d8951cfe1c9fe9ab806b54cacbbf417)
                    }
                    case 25{
                        high := xor(high,0x6e9e40ae71927c029a13d3b1daec32ad3d8951cfe1c9fe9ab806b54cacbbf417)
                        low := xor(low,0x6e9e40ae71927c029a13d3b1daec32ad3d8951cfe1c9fe9ab806b54cacbbf417)
                    }
                    case 26{
                        high := xor(high,0x6e9e40ae71927c029a13d3b1daec32ad3d8951cfe1c9fe9ab806b54cacbbf417)
                        low := xor(low,0x6e9e40ae71927c029a13d3b1daec32ad3d8951cfe1c9fe9ab806b54cacbbf417)
                    }
                    case 27{
                        high := xor(high,0x6e9e40ae71927c029a13d3b1daec32ad3d8951cfe1c9fe9ab806b54cacbbf417)
                        low := xor(low,0x6e9e40ae71927c029a13d3b1daec32ad3d8951cfe1c9fe9ab806b54cacbbf417)
                    }
                    case 28{
                        high := xor(high,0x6e9e40ae71927c029a13d3b1daec32ad3d8951cfe1c9fe9ab806b54cacbbf417)
                        low := xor(low,0x6e9e40ae71927c029a13d3b1daec32ad3d8951cfe1c9fe9ab806b54cacbbf417)
                    }
                    case 29{
                        high := xor(high,0x6e9e40ae71927c029a13d3b1daec32ad3d8951cfe1c9fe9ab806b54cacbbf417)
                        low := xor(low,0x6e9e40ae71927c029a13d3b1daec32ad3d8951cfe1c9fe9ab806b54cacbbf417)
                    }
                    case 30{
                        high := xor(high,0x6e9e40ae71927c029a13d3b1daec32ad3d8951cfe1c9fe9ab806b54cacbbf417)
                        low := xor(low,0x6e9e40ae71927c029a13d3b1daec32ad3d8951cfe1c9fe9ab806b54cacbbf417)
                    }
                    case 31{
                        high := xor(high,0x6e9e40ae71927c029a13d3b1daec32ad3d8951cfe1c9fe9ab806b54cacbbf417)
                        low := xor(low,0x6e9e40ae71927c029a13d3b1daec32ad3d8951cfe1c9fe9ab806b54cacbbf417)
                    }
                    case 32{
                        high := xor(high,0x6e9e40ae71927c029a13d3b1daec32ad3d8951cfe1c9fe9ab806b54cacbbf417)
                        low := xor(low,0x6e9e40ae71927c029a13d3b1daec32ad3d8951cfe1c9fe9ab806b54cacbbf417)
                    }
                    case 33{
                        high := xor(high,0x6e9e40ae71927c029a13d3b1daec32ad3d8951cfe1c9fe9ab806b54cacbbf417)
                        low := xor(low,0x6e9e40ae71927c029a13d3b1daec32ad3d8951cfe1c9fe9ab806b54cacbbf417)
                    }
                    case 34{
                        high := xor(high,0x6e9e40ae71927c029a13d3b1daec32ad3d8951cfe1c9fe9ab806b54cacbbf417)
                        low := xor(low,0x6e9e40ae71927c029a13d3b1daec32ad3d8951cfe1c9fe9ab806b54cacbbf417)
                    }
                    case 35{
                        high := xor(high,0x6e9e40ae71927c029a13d3b1daec32ad3d8951cfe1c9fe9ab806b54cacbbf417)
                        low := xor(low,0x6e9e40ae71927c029a13d3b1daec32ad3d8951cfe1c9fe9ab806b54cacbbf417)
                    }
                    case 36{
                        high := xor(high,0x6e9e40ae71927c029a13d3b1daec32ad3d8951cfe1c9fe9ab806b54cacbbf417)
                        low := xor(low,0x6e9e40ae71927c029a13d3b1daec32ad3d8951cfe1c9fe9ab806b54cacbbf417)
                    }
                    case 37{
                        high := xor(high,0x6e9e40ae71927c029a13d3b1daec32ad3d8951cfe1c9fe9ab806b54cacbbf417)
                        low := xor(low,0x6e9e40ae71927c029a13d3b1daec32ad3d8951cfe1c9fe9ab806b54cacbbf417)
                    }
                    case 38{
                        high := xor(high,0x6e9e40ae71927c029a13d3b1daec32ad3d8951cfe1c9fe9ab806b54cacbbf417)
                        low := xor(low,0x6e9e40ae71927c029a13d3b1daec32ad3d8951cfe1c9fe9ab806b54cacbbf417)
                    }
                    case 39{
                        high := xor(high,0x6e9e40ae71927c029a13d3b1daec32ad3d8951cfe1c9fe9ab806b54cacbbf417)
                        low := xor(low,0x6e9e40ae71927c029a13d3b1daec32ad3d8951cfe1c9fe9ab806b54cacbbf417)
                    }
                    case 40{
                        high := xor(high,0x6e9e40ae71927c029a13d3b1daec32ad3d8951cfe1c9fe9ab806b54cacbbf417)
                        low := xor(low,0x6e9e40ae71927c029a13d3b1daec32ad3d8951cfe1c9fe9ab806b54cacbbf417)
                    }
                    case 41{
                        high := xor(high,0x6e9e40ae71927c029a13d3b1daec32ad3d8951cfe1c9fe9ab806b54cacbbf417)
                        low := xor(low,0x6e9e40ae71927c029a13d3b1daec32ad3d8951cfe1c9fe9ab806b54cacbbf417)
                    }
                    case 42{
                        high := xor(high,0x6e9e40ae71927c029a13d3b1daec32ad3d8951cfe1c9fe9ab806b54cacbbf417)
                        low := xor(low,0x6e9e40ae71927c029a13d3b1daec32ad3d8951cfe1c9fe9ab806b54cacbbf417)
                    }

                    default{
                    //revert(0,0)

                        mstore(0x0200,0x00000000000000000000000000000000000000000000000000000000000002)
                        log1(0x0200,0x20,0x2e36a7093f25f22bd4cbdeb6040174c3ba4c5fe8f1abc04e7c3c48f26c7413e0)
                        return(0x80,0x00)

                    }
                //Injection of Constants
                }

                {//Addition-Rotation-Addition, a.k.a. ARA
                    new_low := byte(0x20, 0x00)
                    new_high := byte(0x20, 0x00)

                //0,1
                    let state_vector_head := byte(0x20, 0x00)
                    let state_vector_head_2 := byte(0x20, 0x00)
                    let state_vector_tail := byte(0x20, 0x00)
                    let state_vector_tail_2 := byte(0x20, 0x00)
                    let output_head := byte(0x20, 0x00)
                    let output_head_2 := byte(0x20, 0x00)
                    let output_tail := byte(0x20, 0x00)

                // output_vector[2*i] = state_vector[2*i] + state_vector[2*i + 1]
                    state_vector_head := high

                    state_vector_head := shr(state_vector_head,0xe0)

                    state_vector_tail := high

                    state_vector_tail := shr(and(state_vector_head,0x00000000ffffffff000000000000000000000000000000000000000000000000),0xC0)

                    state_vector_tail_2 := state_vector_tail

                    output_head := and(add(state_vector_head,state_vector_tail),0x00000000000000000000000000000000000000000000000000000000ffffffff)

                // output_vector[2*i] = output_vector[2*i] <<< 8
                    output_head_2 := output_head

                    output_head := or(
                    and(shl(output_head,8),0x00000000000000000000000000000000000000000000000000000000ffffffff),
                    shr(output_head_2,24)
                    )

                // output_vector[2*i + 1] = state_vector[2*i + 1] <<< 24
                    state_vector_tail := state_vector_tail_2
                    output_tail := or(
                    and(shl(state_vector_tail,24),0x00000000000000000000000000000000000000000000000000000000ffffffff),
                    shr(state_vector_tail_2,8)
                    )

                // output_vector[2*i + 1] = output_vector[2*i + 1] + output_vector[2*i]
                    output_head_2 := output_head
                    output_tail := add(output_tail,output_head_2)

                // save output back to state
                    new_high := or(new_high,shl(output_head,0xE0))
                    new_high := or(new_high,shl(output_tail,0xC0))


                //2,3
                    state_vector_head := byte(0x20, 0x00)
                    state_vector_head_2 := byte(0x20, 0x00)
                    state_vector_tail := byte(0x20, 0x00)
                    state_vector_tail_2 := byte(0x20, 0x00)
                    output_head := byte(0x20, 0x00)
                    output_head_2 := byte(0x20, 0x00)
                    output_tail := byte(0x20, 0x00)

                // output_vector[2*i] = state_vector[2*i] + state_vector[2*i + 1]
                    state_vector_head := high

                    state_vector_head := shr(and(state_vector_head,0x0000000000000000ffffffff0000000000000000000000000000000000000000),0xA0)

                    state_vector_tail := high

                    state_vector_tail := shr(and(state_vector_head,0x000000000000000000000000ffffffff00000000000000000000000000000000),0x80)

                    state_vector_tail_2 := state_vector_tail

                    output_head := and(add(state_vector_head,state_vector_tail),0x00000000000000000000000000000000000000000000000000000000ffffffff)

                // output_vector[2*i] = output_vector[2*i] <<< 8
                    output_head_2 := output_head

                    output_head := or(
                    and(shl(output_head,8),0x00000000000000000000000000000000000000000000000000000000ffffffff),
                    shr(output_head_2,24)
                    )

                // output_vector[2*i + 1] = state_vector[2*i + 1] <<< 24
                    state_vector_tail := state_vector_tail_2
                    output_tail := or(
                    and(shl(state_vector_tail,24),0x00000000000000000000000000000000000000000000000000000000ffffffff),
                    shr(state_vector_tail_2,8)
                    )

                // output_vector[2*i + 1] = output_vector[2*i + 1] + output_vector[2*i]
                    output_head_2 := output_head
                    output_tail := add(output_tail,output_head_2)

                // save output back to state
                    new_high := or(new_high,shl(output_head,0xA0))
                    new_high := or(new_high,shl(output_tail,0x80))

                //4,5
                    state_vector_head := byte(0x20, 0x00)
                    state_vector_head_2 := byte(0x20, 0x00)
                    state_vector_tail := byte(0x20, 0x00)
                    state_vector_tail_2 := byte(0x20, 0x00)
                    output_head := byte(0x20, 0x00)
                    output_head_2 := byte(0x20, 0x00)
                    output_tail := byte(0x20, 0x00)

                // output_vector[2*i] = state_vector[2*i] + state_vector[2*i + 1]
                    state_vector_head := high

                    state_vector_head := shr(and(state_vector_head,0x00000000000000000000000000000000ffffffff000000000000000000000000),0x60)

                    state_vector_tail := high

                    state_vector_tail := shr(and(state_vector_head,0x0000000000000000000000000000000000000000ffffffff0000000000000000),0x40)

                    state_vector_tail_2 := state_vector_tail

                    output_head := and(add(state_vector_head,state_vector_tail),0x00000000000000000000000000000000000000000000000000000000ffffffff)

                // output_vector[2*i] = output_vector[2*i] <<< 8
                    output_head_2 := output_head

                    output_head := or(
                    and(shl(output_head,8),0x00000000000000000000000000000000000000000000000000000000ffffffff),
                    shr(output_head_2,24)
                    )

                // output_vector[2*i + 1] = state_vector[2*i + 1] <<< 24
                    state_vector_tail := state_vector_tail_2
                    output_tail := or(
                    and(shl(state_vector_tail,24),0x00000000000000000000000000000000000000000000000000000000ffffffff),
                    shr(state_vector_tail_2,8)
                    )

                // output_vector[2*i + 1] = output_vector[2*i + 1] + output_vector[2*i]
                    output_head_2 := output_head
                    output_tail := add(output_tail,output_head_2)

                // save output back to state
                    new_high := or(new_high,shl(output_head,0x60))
                    new_high := or(new_high,shl(output_tail,0x40))


                //6,7
                    state_vector_head := byte(0x20, 0x00)
                    state_vector_head_2 := byte(0x20, 0x00)
                    state_vector_tail := byte(0x20, 0x00)
                    state_vector_tail_2 := byte(0x20, 0x00)
                    output_head := byte(0x20, 0x00)
                    output_head_2 := byte(0x20, 0x00)
                    output_tail := byte(0x20, 0x00)

                // output_vector[2*i] = state_vector[2*i] + state_vector[2*i + 1]
                    state_vector_head := high

                    state_vector_head := shr(and(state_vector_head,0x000000000000000000000000000000000000000000000000ffffffff00000000),0x20)

                    state_vector_tail := high

                    state_vector_tail := and(state_vector_head,0x00000000000000000000000000000000000000000000000000000000ffffffff)

                    state_vector_tail_2 := state_vector_tail

                    output_head := and(add(state_vector_head,state_vector_tail),0x00000000000000000000000000000000000000000000000000000000ffffffff)

                // output_vector[2*i] = output_vector[2*i] <<< 8
                    output_head_2 := output_head

                    output_head := or(
                    and(shl(output_head,8),0x00000000000000000000000000000000000000000000000000000000ffffffff),
                    shr(output_head_2,24)
                    )

                // output_vector[2*i + 1] = state_vector[2*i + 1] <<< 24
                    state_vector_tail := state_vector_tail_2
                    output_tail := or(
                    and(shl(state_vector_tail,24),0x00000000000000000000000000000000000000000000000000000000ffffffff),
                    shr(state_vector_tail_2,8)
                    )

                // output_vector[2*i + 1] = output_vector[2*i + 1] + output_vector[2*i]
                    output_head_2 := output_head
                    output_tail := add(output_tail,output_head_2)

                // save output back to state
                    new_high := or(new_high,shl(output_head,0x20))
                    new_high := or(new_high,output_tail)

                //8,9
                    state_vector_head := byte(0x20, 0x00)
                    state_vector_head_2 := byte(0x20, 0x00)
                    state_vector_tail := byte(0x20, 0x00)
                    state_vector_tail_2 := byte(0x20, 0x00)
                    output_head := byte(0x20, 0x00)
                    output_head_2 := byte(0x20, 0x00)
                    output_tail := byte(0x20, 0x00)

                // output_vector[2*i] = state_vector[2*i] + state_vector[2*i + 1]
                    state_vector_head := low

                    state_vector_head := shr(state_vector_head,0xe0)

                    state_vector_tail := low

                    state_vector_tail := shr(and(state_vector_head,0x00000000ffffffff000000000000000000000000000000000000000000000000),0xC0)

                    state_vector_tail_2 := state_vector_tail

                    output_head := and(add(state_vector_head,state_vector_tail),0x00000000000000000000000000000000000000000000000000000000ffffffff)

                // output_vector[2*i] = output_vector[2*i] <<< 8
                    output_head_2 := output_head

                    output_head := or(
                    and(shl(output_head,8),0x00000000000000000000000000000000000000000000000000000000ffffffff),
                    shr(output_head_2,24)
                    )

                // output_vector[2*i + 1] = state_vector[2*i + 1] <<< 24
                    state_vector_tail := state_vector_tail_2
                    output_tail := or(
                    and(shl(state_vector_tail,24),0x00000000000000000000000000000000000000000000000000000000ffffffff),
                    shr(state_vector_tail_2,8)
                    )

                // output_vector[2*i + 1] = output_vector[2*i + 1] + output_vector[2*i]
                    output_head_2 := output_head
                    output_tail := add(output_tail,output_head_2)

                // save output back to state
                    new_low := or(new_low,shl(output_head,0xE0))
                    new_low := or(new_low,shl(output_tail,0xC0))


                //a,b
                    state_vector_head := byte(0x20, 0x00)
                    state_vector_head_2 := byte(0x20, 0x00)
                    state_vector_tail := byte(0x20, 0x00)
                    state_vector_tail_2 := byte(0x20, 0x00)
                    output_head := byte(0x20, 0x00)
                    output_head_2 := byte(0x20, 0x00)
                    output_tail := byte(0x20, 0x00)

                // output_vector[2*i] = state_vector[2*i] + state_vector[2*i + 1]
                    state_vector_head := low

                    state_vector_head := shr(and(state_vector_head,0x0000000000000000ffffffff0000000000000000000000000000000000000000),0xA0)

                    state_vector_tail := low

                    state_vector_tail := shr(and(state_vector_head,0x000000000000000000000000ffffffff00000000000000000000000000000000),0x80)

                    state_vector_tail_2 := state_vector_tail

                    output_head := and(add(state_vector_head,state_vector_tail),0x00000000000000000000000000000000000000000000000000000000ffffffff)

                // output_vector[2*i] = output_vector[2*i] <<< 8
                    output_head_2 := output_head

                    output_head := or(
                    and(shl(output_head,8),0x00000000000000000000000000000000000000000000000000000000ffffffff),
                    shr(output_head_2,24)
                    )

                // output_vector[2*i + 1] = state_vector[2*i + 1] <<< 24
                    state_vector_tail := state_vector_tail_2
                    output_tail := or(
                    and(shl(state_vector_tail,24),0x00000000000000000000000000000000000000000000000000000000ffffffff),
                    shr(state_vector_tail_2,8)
                    )

                // output_vector[2*i + 1] = output_vector[2*i + 1] + output_vector[2*i]
                    output_head_2 := output_head
                    output_tail := add(output_tail,output_head_2)

                // save output back to state
                    new_low := or(new_low,shl(output_head,0xA0))
                    new_low := or(new_low,shl(output_tail,0x80))

                //c,d
                    state_vector_head := byte(0x20, 0x00)
                    state_vector_head_2 := byte(0x20, 0x00)
                    state_vector_tail := byte(0x20, 0x00)
                    state_vector_tail_2 := byte(0x20, 0x00)
                    output_head := byte(0x20, 0x00)
                    output_head_2 := byte(0x20, 0x00)
                    output_tail := byte(0x20, 0x00)

                // output_vector[2*i] = state_vector[2*i] + state_vector[2*i + 1]
                    state_vector_head := low

                    state_vector_head := shr(and(state_vector_head,0x00000000000000000000000000000000ffffffff000000000000000000000000),0x60)

                    state_vector_tail := low

                    state_vector_tail := shr(and(state_vector_head,0x0000000000000000000000000000000000000000ffffffff0000000000000000),0x40)

                    state_vector_tail_2 := state_vector_tail

                    output_head := and(add(state_vector_head,state_vector_tail),0x00000000000000000000000000000000000000000000000000000000ffffffff)

                // output_vector[2*i] = output_vector[2*i] <<< 8
                    output_head_2 := output_head

                    output_head := or(
                    and(shl(output_head,8),0x00000000000000000000000000000000000000000000000000000000ffffffff),
                    shr(output_head_2,24)
                    )

                // output_vector[2*i + 1] = state_vector[2*i + 1] <<< 24
                    state_vector_tail := state_vector_tail_2
                    output_tail := or(
                    and(shl(state_vector_tail,24),0x00000000000000000000000000000000000000000000000000000000ffffffff),
                    shr(state_vector_tail_2,8)
                    )

                // output_vector[2*i + 1] = output_vector[2*i + 1] + output_vector[2*i]
                    output_head_2 := output_head
                    output_tail := add(output_tail,output_head_2)

                // save output back to state
                    new_low := or(new_low,shl(output_head,0x60))
                    new_low := or(new_low,shl(output_tail,0x40))


                //e,f
                    state_vector_head := byte(0x20, 0x00)
                    state_vector_head_2 := byte(0x20, 0x00)
                    state_vector_tail := byte(0x20, 0x00)
                    state_vector_tail_2 := byte(0x20, 0x00)
                    output_head := byte(0x20, 0x00)
                    output_head_2 := byte(0x20, 0x00)
                    output_tail := byte(0x20, 0x00)

                // output_vector[2*i] = state_vector[2*i] + state_vector[2*i + 1]
                    state_vector_head := low

                    state_vector_head := shr(and(state_vector_head,0x000000000000000000000000000000000000000000000000ffffffff00000000),0x20)

                    state_vector_tail := low

                    state_vector_tail := and(state_vector_head,0x00000000000000000000000000000000000000000000000000000000ffffffff)

                    state_vector_tail_2 := state_vector_tail

                    output_head := and(add(state_vector_head,state_vector_tail),0x00000000000000000000000000000000000000000000000000000000ffffffff)

                // output_vector[2*i] = output_vector[2*i] <<< 8
                    output_head_2 := output_head

                    output_head := or(
                    and(shl(output_head,8),0x00000000000000000000000000000000000000000000000000000000ffffffff),
                    shr(output_head_2,24)
                    )

                // output_vector[2*i + 1] = state_vector[2*i + 1] <<< 24
                    state_vector_tail := state_vector_tail_2
                    output_tail := or(
                    and(shl(state_vector_tail,24),0x00000000000000000000000000000000000000000000000000000000ffffffff),
                    shr(state_vector_tail_2,8)
                    )

                // output_vector[2*i + 1] = output_vector[2*i + 1] + output_vector[2*i]
                    output_head_2 := output_head
                    output_tail := add(output_tail,output_head_2)

                // save output back to state
                    new_low := or(new_low,shl(output_head,0x20))
                    new_low := or(new_low,output_tail)

                    high := new_high
                    low := new_low
                }

            // round 43 :)
            }



        //=================================================ABSORB_CHUNK_1===========================================================

            /*
                chunk 1
            */
            //mstore(0x0200,200)
            //log1(0x0200,0x20,0x44616297960603a3d5b0d25266152f32526078f52ebfdf296f21f709cb373712)

        // chunk 1

            high := xor(high, mload(0xa0))

        // here Permutation begins

        // one permutation has independent 43 round
            for {let round := 0} lt(round, 43) {round := add(round, 1)}{

                /*
                chunk 1-round
                */
                //let checkpoint := add(round, 201)
                //mstore(0x0200,checkpoint)
                //log1(0x0200,0x20,0x44616297960603a3d5b0d25266152f32526078f52ebfdf296f21f709cb373712)

                {//bit_matrix
                    new_low := byte(0x20, 0x00)
                    new_high := byte(0x20, 0x00)

                /*bit_matrix = [
                         0 1 2 3 4 5 6 7|8 9 a b c d e f
                    0	[1 1 1 1 0 1 0 1 1 1 1 1 0 0 0 1]
                    1   [0 1 1 1 1 0 1 0 1 1 1 1 1 0 0 1]
                    2   [0 0 1 1 1 1 0 1 0 1 1 1 1 1 0 1]
                    3   [0 0 0 1 1 1 1 0 1 0 1 1 1 1 1 1]
                    4   [1 1 1 1 1 0 1 0 1 0 1 0 1 1 1 0]
                    5   [1 0 0 0 1 0 0 0 1 0 1 0 0 1 1 1]
                    6   [1 0 1 1 0 0 0 1 1 0 1 0 0 0 1 0]
                    7   [1 0 1 0 1 1 0 1 0 0 1 0 0 0 0 1]
                    8   [0 1 0 1 0 1 1 0 1 0 0 1 0 0 0 1]
                    9   [0 0 1 0 1 0 1 1 0 1 0 0 1 0 0 1]
                    a   [0 0 0 1 0 1 0 1 1 0 1 0 0 1 0 1]
                    b   [0 0 0 0 1 0 1 0 1 1 0 1 0 0 1 1]
                    c   [1 1 1 1 0 0 0 0 1 0 0 1 1 0 0 0]
                    d   [0 1 1 1 1 0 0 0 0 1 0 0 1 1 0 0]
                    e   [0 0 1 1 1 1 0 0 0 0 1 0 0 1 1 0]
                    f   [1 1 1 0 1 0 1 1 1 1 1 0 0 0 1 1]
                ]*/



                // alloc a item for temp usage of 32 bits
                // we use the lowest 32 bits of 256 bits
                    let stack_temp := byte(0x20, 0x00)// for output_vector[j]
                    let temp := byte(0x20, 0x00)// for dup of original state_vector

                // row 0,1 1 1 1 0 1 0 1 1 1 1 1 0 0 0

                // column 0
                    temp := high
                    stack_temp := xor(stack_temp, shr(temp, 0xE0))

                // column 1
                    temp := high
                    stack_temp := xor(stack_temp, shr(and(temp, 0x00000000ffffffff000000000000000000000000000000000000000000000000), 0xC0))

                // column 2
                    temp := high
                    stack_temp := xor(stack_temp, shr(and(temp, 0x0000000000000000ffffffff0000000000000000000000000000000000000000), 0xA0))

                // column 3
                    temp := high
                    stack_temp := xor(stack_temp, shr(and(temp, 0x000000000000000000000000ffffffff00000000000000000000000000000000), 0x80))

                // column 4
                /*temp := high
                stack_temp := xor(stack_temp,shr(and(temp,0x00000000000000000000000000000000ffffffff000000000000000000000000),0x60))*/

                // column 5
                    temp := high
                    stack_temp := xor(stack_temp, shr(and(temp, 0x0000000000000000000000000000000000000000ffffffff0000000000000000), 0x40))

                // column 6
                /*temp := high
                stack_temp := xor(stack_temp,shr(and(temp,0x000000000000000000000000000000000000000000000000ffffffff00000000),0x20))*/

                // column 7
                    temp := high
                    stack_temp := xor(stack_temp, and(temp, 0x00000000000000000000000000000000000000000000000000000000ffffffff))

                // column 8
                    temp := low
                    stack_temp := xor(stack_temp, shr(temp, 0xE0))

                // column 9
                    temp := low
                    stack_temp := xor(stack_temp, shr(and(temp, 0x00000000ffffffff000000000000000000000000000000000000000000000000), 0xC0))

                // column a
                    temp := low
                    stack_temp := xor(stack_temp, shr(and(temp, 0x0000000000000000ffffffff0000000000000000000000000000000000000000), 0xA0))

                // column b
                    temp := low
                    stack_temp := xor(stack_temp, shr(and(temp, 0x000000000000000000000000ffffffff00000000000000000000000000000000), 0x80))

                // column c
                /*temp := low
                stack_temp := xor(stack_temp,shr(and(temp,0x00000000000000000000000000000000ffffffff000000000000000000000000),0x60))*/

                // column d
                /*temp := low
                stack_temp := xor(stack_temp,shr(and(temp,0x0000000000000000000000000000000000000000ffffffff0000000000000000),0x40))*/

                // column e
                /*temp := low
                stack_temp := xor(stack_temp,shr(and(temp,0x000000000000000000000000000000000000000000000000ffffffff00000000),0x20))*/

                // column f
                    temp := low
                    stack_temp := xor(stack_temp, and(temp, 0x00000000000000000000000000000000000000000000000000000000ffffffff))

                    new_high := or(new_high, shl(stack_temp, 0xE0))

                // row 1,0 1 1 1 1 0 1 0 1 1 1 1 1 0 0 1
                    stack_temp := byte(0x20, 0x00)
                // column 0
                /*temp := high
                stack_temp := xor(stack_temp, shr(temp, 0xE0))*/

                // column 1
                    temp := high
                    stack_temp := xor(stack_temp, shr(and(temp, 0x00000000ffffffff000000000000000000000000000000000000000000000000), 0xC0))

                // column 2
                    temp := high
                    stack_temp := xor(stack_temp, shr(and(temp, 0x0000000000000000ffffffff0000000000000000000000000000000000000000), 0xA0))

                // column 3
                    temp := high
                    stack_temp := xor(stack_temp, shr(and(temp, 0x000000000000000000000000ffffffff00000000000000000000000000000000), 0x80))

                // column 4
                    temp := high
                    stack_temp := xor(stack_temp, shr(and(temp, 0x00000000000000000000000000000000ffffffff000000000000000000000000), 0x60))

                // column 5
                /* temp := high
                 stack_temp := xor(stack_temp, shr(and(temp, 0x0000000000000000000000000000000000000000ffffffff0000000000000000), 0x40))*/

                // column 6
                    temp := high
                    stack_temp := xor(stack_temp, shr(and(temp, 0x000000000000000000000000000000000000000000000000ffffffff00000000), 0x20))

                // column 7
                /*temp := high
                stack_temp := xor(stack_temp, and(temp, 0x00000000000000000000000000000000000000000000000000000000ffffffff))*/

                // column 8
                    temp := low
                    stack_temp := xor(stack_temp, shr(temp, 0xE0))

                // column 9
                    temp := low
                    stack_temp := xor(stack_temp, shr(and(temp, 0x00000000ffffffff000000000000000000000000000000000000000000000000), 0xC0))

                // column a
                    temp := low
                    stack_temp := xor(stack_temp, shr(and(temp, 0x0000000000000000ffffffff0000000000000000000000000000000000000000), 0xA0))

                // column b
                    temp := low
                    stack_temp := xor(stack_temp, shr(and(temp, 0x000000000000000000000000ffffffff00000000000000000000000000000000), 0x80))

                // column c
                    temp := low
                    stack_temp := xor(stack_temp, shr(and(temp, 0x00000000000000000000000000000000ffffffff000000000000000000000000), 0x60))

                // column d
                /*temp := low
                stack_temp := xor(stack_temp, shr(and(temp, 0x0000000000000000000000000000000000000000ffffffff0000000000000000), 0x40))*/

                // column e
                /*temp := low
                stack_temp := xor(stack_temp, shr(and(temp, 0x000000000000000000000000000000000000000000000000ffffffff00000000), 0x20))*/

                // column f
                    temp := low
                    stack_temp := xor(stack_temp, and(temp, 0x00000000000000000000000000000000000000000000000000000000ffffffff))

                    new_high := or(new_high, shl(stack_temp, 0xC0))

                // row 2,0 0 1 1 1 1 0 1 0 1 1 1 1 1 0 1
                    stack_temp := byte(0x20, 0x00)
                // column 0
                /*temp := high
                stack_temp := xor(stack_temp, shr(temp, 0xE0))*/

                // column 1
                /*temp := high
                stack_temp := xor(stack_temp, shr(and(temp, 0x00000000ffffffff000000000000000000000000000000000000000000000000), 0xC0))*/

                // column 2
                    temp := high
                    stack_temp := xor(stack_temp, shr(and(temp, 0x0000000000000000ffffffff0000000000000000000000000000000000000000), 0xA0))

                // column 3
                    temp := high
                    stack_temp := xor(stack_temp, shr(and(temp, 0x000000000000000000000000ffffffff00000000000000000000000000000000), 0x80))

                // column 4
                    temp := high
                    stack_temp := xor(stack_temp, shr(and(temp, 0x00000000000000000000000000000000ffffffff000000000000000000000000), 0x60))

                // column 5
                    temp := high
                    stack_temp := xor(stack_temp, shr(and(temp, 0x0000000000000000000000000000000000000000ffffffff0000000000000000), 0x40))

                // column 6
                /* temp := high
                 stack_temp := xor(stack_temp, shr(and(temp, 0x000000000000000000000000000000000000000000000000ffffffff00000000), 0x20))*/

                // column 7
                    temp := high
                    stack_temp := xor(stack_temp, and(temp, 0x00000000000000000000000000000000000000000000000000000000ffffffff))

                // column 8
                /*temp := low
                stack_temp := xor(stack_temp, shr(temp, 0xE0))*/

                // column 9
                    temp := low
                    stack_temp := xor(stack_temp, shr(and(temp, 0x00000000ffffffff000000000000000000000000000000000000000000000000), 0xC0))

                // column a
                    temp := low
                    stack_temp := xor(stack_temp, shr(and(temp, 0x0000000000000000ffffffff0000000000000000000000000000000000000000), 0xA0))

                // column b
                    temp := low
                    stack_temp := xor(stack_temp, shr(and(temp, 0x000000000000000000000000ffffffff00000000000000000000000000000000), 0x80))

                // column c
                    temp := low
                    stack_temp := xor(stack_temp, shr(and(temp, 0x00000000000000000000000000000000ffffffff000000000000000000000000), 0x60))

                // column d
                    temp := low
                    stack_temp := xor(stack_temp, shr(and(temp, 0x0000000000000000000000000000000000000000ffffffff0000000000000000), 0x40))

                // column e
                /*temp := low
                stack_temp := xor(stack_temp, shr(and(temp, 0x000000000000000000000000000000000000000000000000ffffffff00000000), 0x20))*/

                // column f
                    temp := low
                    stack_temp := xor(stack_temp, and(temp, 0x00000000000000000000000000000000000000000000000000000000ffffffff))

                    new_high := or(new_high, shl(stack_temp, 0xA0))

                // row 3,0 0 0 1 1 1 1 0 1 0 1 1 1 1 1 1
                    stack_temp := byte(0x20, 0x00)
                // column 0
                /*temp := high
                stack_temp := xor(stack_temp, shr(temp, 0xE0))*/

                // column 1
                /*temp := high
                stack_temp := xor(stack_temp, shr(and(temp, 0x00000000ffffffff000000000000000000000000000000000000000000000000), 0xC0))*/

                // column 2
                /*temp := high
                stack_temp := xor(stack_temp, shr(and(temp, 0x0000000000000000ffffffff0000000000000000000000000000000000000000), 0xA0))*/

                // column 3
                    temp := high
                    stack_temp := xor(stack_temp, shr(and(temp, 0x000000000000000000000000ffffffff00000000000000000000000000000000), 0x80))

                // column 4
                    temp := high
                    stack_temp := xor(stack_temp, shr(and(temp, 0x00000000000000000000000000000000ffffffff000000000000000000000000), 0x60))

                // column 5
                    temp := high
                    stack_temp := xor(stack_temp, shr(and(temp, 0x0000000000000000000000000000000000000000ffffffff0000000000000000), 0x40))

                // column 6
                    temp := high
                    stack_temp := xor(stack_temp, shr(and(temp, 0x000000000000000000000000000000000000000000000000ffffffff00000000), 0x20))

                // column 7
                /*temp := high
                stack_temp := xor(stack_temp, and(temp, 0x00000000000000000000000000000000000000000000000000000000ffffffff))*/

                // column 8
                    temp := low
                    stack_temp := xor(stack_temp, shr(temp, 0xE0))

                // column 9
                /*temp := low
                stack_temp := xor(stack_temp, shr(and(temp, 0x00000000ffffffff000000000000000000000000000000000000000000000000), 0xC0))*/

                // column a
                    temp := low
                    stack_temp := xor(stack_temp, shr(and(temp, 0x0000000000000000ffffffff0000000000000000000000000000000000000000), 0xA0))

                // column b
                    temp := low
                    stack_temp := xor(stack_temp, shr(and(temp, 0x000000000000000000000000ffffffff00000000000000000000000000000000), 0x80))

                // column c
                    temp := low
                    stack_temp := xor(stack_temp, shr(and(temp, 0x00000000000000000000000000000000ffffffff000000000000000000000000), 0x60))

                // column d
                    temp := low
                    stack_temp := xor(stack_temp, shr(and(temp, 0x0000000000000000000000000000000000000000ffffffff0000000000000000), 0x40))

                // column e
                    temp := low
                    stack_temp := xor(stack_temp, shr(and(temp, 0x000000000000000000000000000000000000000000000000ffffffff00000000), 0x20))

                // column f
                    temp := low
                    stack_temp := xor(stack_temp, and(temp, 0x00000000000000000000000000000000000000000000000000000000ffffffff))

                    new_high := or(new_high, shl(stack_temp, 0x80))

                // row 4,1 1 1 1 1 0 1 0 1 0 1 0 1 1 1 0
                    stack_temp := byte(0x20, 0x00)
                // column 0
                    temp := high
                    stack_temp := xor(stack_temp, shr(temp, 0xE0))

                // column 1
                    temp := high
                    stack_temp := xor(stack_temp, shr(and(temp, 0x00000000ffffffff000000000000000000000000000000000000000000000000), 0xC0))

                // column 2
                    temp := high
                    stack_temp := xor(stack_temp, shr(and(temp, 0x0000000000000000ffffffff0000000000000000000000000000000000000000), 0xA0))

                // column 3
                    temp := high
                    stack_temp := xor(stack_temp, shr(and(temp, 0x000000000000000000000000ffffffff00000000000000000000000000000000), 0x80))

                // column 4
                    temp := high
                    stack_temp := xor(stack_temp, shr(and(temp, 0x00000000000000000000000000000000ffffffff000000000000000000000000), 0x60))

                // column 5
                /*temp := high
                stack_temp := xor(stack_temp, shr(and(temp, 0x0000000000000000000000000000000000000000ffffffff0000000000000000), 0x40))*/

                // column 6
                    temp := high
                    stack_temp := xor(stack_temp, shr(and(temp, 0x000000000000000000000000000000000000000000000000ffffffff00000000), 0x20))

                // column 7
                /*temp := high
                stack_temp := xor(stack_temp, and(temp, 0x00000000000000000000000000000000000000000000000000000000ffffffff))*/

                // column 8
                    temp := low
                    stack_temp := xor(stack_temp, shr(temp, 0xE0))

                // column 9
                /*temp := low
                stack_temp := xor(stack_temp, shr(and(temp, 0x00000000ffffffff000000000000000000000000000000000000000000000000), 0xC0))*/

                // column a
                    temp := low
                    stack_temp := xor(stack_temp, shr(and(temp, 0x0000000000000000ffffffff0000000000000000000000000000000000000000), 0xA0))

                // column b
                /*temp := low
                stack_temp := xor(stack_temp, shr(and(temp, 0x000000000000000000000000ffffffff00000000000000000000000000000000), 0x80))*/

                // column c
                    temp := low
                    stack_temp := xor(stack_temp, shr(and(temp, 0x00000000000000000000000000000000ffffffff000000000000000000000000), 0x60))

                // column d
                    temp := low
                    stack_temp := xor(stack_temp, shr(and(temp, 0x0000000000000000000000000000000000000000ffffffff0000000000000000), 0x40))

                // column e
                    temp := low
                    stack_temp := xor(stack_temp, shr(and(temp, 0x000000000000000000000000000000000000000000000000ffffffff00000000), 0x20))

                // column f
                /*temp := low
                stack_temp := xor(stack_temp, and(temp, 0x00000000000000000000000000000000000000000000000000000000ffffffff))*/

                    new_high := or(new_high, shl(stack_temp, 0x60))

                // row 5,1 0 0 0 1 0 0 0 1 0 1 0 0 1 1 1
                    stack_temp := byte(0x20, 0x00)
                // column 0
                    temp := high
                    stack_temp := xor(stack_temp, shr(temp, 0xE0))

                // column 1
                /*temp := high
                stack_temp := xor(stack_temp, shr(and(temp, 0x00000000ffffffff000000000000000000000000000000000000000000000000), 0xC0))*/

                // column 2
                /*temp := high
                stack_temp := xor(stack_temp, shr(and(temp, 0x0000000000000000ffffffff0000000000000000000000000000000000000000), 0xA0))*/

                // column 3
                /*temp := high
                stack_temp := xor(stack_temp, shr(and(temp, 0x000000000000000000000000ffffffff00000000000000000000000000000000), 0x80))*/

                // column 4
                    temp := high
                    stack_temp := xor(stack_temp, shr(and(temp, 0x00000000000000000000000000000000ffffffff000000000000000000000000), 0x60))

                // column 5
                /*temp := high
                stack_temp := xor(stack_temp, shr(and(temp, 0x0000000000000000000000000000000000000000ffffffff0000000000000000), 0x40))*/

                // column 6
                /*temp := high
                stack_temp := xor(stack_temp, shr(and(temp, 0x000000000000000000000000000000000000000000000000ffffffff00000000), 0x20))*/

                // column 7
                /*temp := high
                stack_temp := xor(stack_temp, and(temp, 0x00000000000000000000000000000000000000000000000000000000ffffffff))*/

                // column 8
                    temp := low
                    stack_temp := xor(stack_temp, shr(temp, 0xE0))

                // column 9
                /*temp := low
                stack_temp := xor(stack_temp, shr(and(temp, 0x00000000ffffffff000000000000000000000000000000000000000000000000), 0xC0))*/

                // column a
                    temp := low
                    stack_temp := xor(stack_temp, shr(and(temp, 0x0000000000000000ffffffff0000000000000000000000000000000000000000), 0xA0))

                // column b
                /*temp := low
                stack_temp := xor(stack_temp, shr(and(temp, 0x000000000000000000000000ffffffff00000000000000000000000000000000), 0x80))*/

                // column c
                /*temp := low
                stack_temp := xor(stack_temp, shr(and(temp, 0x00000000000000000000000000000000ffffffff000000000000000000000000), 0x60))*/

                // column d
                    temp := low
                    stack_temp := xor(stack_temp, shr(and(temp, 0x0000000000000000000000000000000000000000ffffffff0000000000000000), 0x40))

                // column e
                    temp := low
                    stack_temp := xor(stack_temp, shr(and(temp, 0x000000000000000000000000000000000000000000000000ffffffff00000000), 0x20))

                // column f
                    temp := low
                    stack_temp := xor(stack_temp, and(temp, 0x00000000000000000000000000000000000000000000000000000000ffffffff))

                    new_high := or(new_high, shl(stack_temp, 0x40))

                // row 6,1 0 1 1 0 0 0 1 1 0 1 0 0 0 1 0
                    stack_temp := byte(0x20, 0x00)
                // column 0
                    temp := high
                    stack_temp := xor(stack_temp, shr(temp, 0xE0))

                // column 1
                /*temp := high
                stack_temp := xor(stack_temp, shr(and(temp, 0x00000000ffffffff000000000000000000000000000000000000000000000000), 0xC0))*/

                // column 2
                    temp := high
                    stack_temp := xor(stack_temp, shr(and(temp, 0x0000000000000000ffffffff0000000000000000000000000000000000000000), 0xA0))

                // column 3
                    temp := high
                    stack_temp := xor(stack_temp, shr(and(temp, 0x000000000000000000000000ffffffff00000000000000000000000000000000), 0x80))

                // column 4
                /*temp := high
                stack_temp := xor(stack_temp, shr(and(temp, 0x00000000000000000000000000000000ffffffff000000000000000000000000), 0x60))*/

                // column 5
                /*temp := high
                stack_temp := xor(stack_temp, shr(and(temp, 0x0000000000000000000000000000000000000000ffffffff0000000000000000), 0x40))*/

                // column 6
                /*temp := high
                stack_temp := xor(stack_temp, shr(and(temp, 0x000000000000000000000000000000000000000000000000ffffffff00000000), 0x20))*/

                // column 7
                    temp := high
                    stack_temp := xor(stack_temp, and(temp, 0x00000000000000000000000000000000000000000000000000000000ffffffff))

                // column 8
                    temp := low
                    stack_temp := xor(stack_temp, shr(temp, 0xE0))

                // column 9
                /*temp := low
                stack_temp := xor(stack_temp, shr(and(temp, 0x00000000ffffffff000000000000000000000000000000000000000000000000), 0xC0))*/

                // column a
                    temp := low
                    stack_temp := xor(stack_temp, shr(and(temp, 0x0000000000000000ffffffff0000000000000000000000000000000000000000), 0xA0))

                // column b
                /*temp := low
                stack_temp := xor(stack_temp, shr(and(temp, 0x000000000000000000000000ffffffff00000000000000000000000000000000), 0x80))*/

                // column c
                /*temp := low
                stack_temp := xor(stack_temp, shr(and(temp, 0x00000000000000000000000000000000ffffffff000000000000000000000000), 0x60))*/

                // column d
                /*temp := low
                stack_temp := xor(stack_temp, shr(and(temp, 0x0000000000000000000000000000000000000000ffffffff0000000000000000), 0x40))*/

                // column e
                    temp := low
                    stack_temp := xor(stack_temp, shr(and(temp, 0x000000000000000000000000000000000000000000000000ffffffff00000000), 0x20))

                // column f
                /*temp := low
                stack_temp := xor(stack_temp, and(temp, 0x00000000000000000000000000000000000000000000000000000000ffffffff))*/

                    new_high := or(new_high, shl(stack_temp, 0x20))

                // row 7,1 0 1 0 1 1 0 1 0 0 1 0 0 0 0 1
                    stack_temp := byte(0x20, 0x00)
                // column 0
                    temp := high
                    stack_temp := xor(stack_temp, shr(temp, 0xE0))

                // column 1
                /*temp := high
                stack_temp := xor(stack_temp, shr(and(temp, 0x00000000ffffffff000000000000000000000000000000000000000000000000), 0xC0))*/

                // column 2
                    temp := high
                    stack_temp := xor(stack_temp, shr(and(temp, 0x0000000000000000ffffffff0000000000000000000000000000000000000000), 0xA0))

                // column 3
                /*temp := high
                stack_temp := xor(stack_temp, shr(and(temp, 0x000000000000000000000000ffffffff00000000000000000000000000000000), 0x80))*/

                // column 4
                    temp := high
                    stack_temp := xor(stack_temp, shr(and(temp, 0x00000000000000000000000000000000ffffffff000000000000000000000000), 0x60))

                // column 5
                    temp := high
                    stack_temp := xor(stack_temp, shr(and(temp, 0x0000000000000000000000000000000000000000ffffffff0000000000000000), 0x40))

                // column 6
                /*temp := high
                stack_temp := xor(stack_temp, shr(and(temp, 0x000000000000000000000000000000000000000000000000ffffffff00000000), 0x20))*/

                // column 7
                    temp := high
                    stack_temp := xor(stack_temp, and(temp, 0x00000000000000000000000000000000000000000000000000000000ffffffff))

                // column 8
                /*temp := low
                stack_temp := xor(stack_temp, shr(temp, 0xE0))*/

                // column 9
                /*temp := low
                stack_temp := xor(stack_temp, shr(and(temp, 0x00000000ffffffff000000000000000000000000000000000000000000000000), 0xC0))*/

                // column a
                    temp := low
                    stack_temp := xor(stack_temp, shr(and(temp, 0x0000000000000000ffffffff0000000000000000000000000000000000000000), 0xA0))

                // column b
                /*temp := low
                stack_temp := xor(stack_temp, shr(and(temp, 0x000000000000000000000000ffffffff00000000000000000000000000000000), 0x80))*/

                // column c
                /*temp := low
                stack_temp := xor(stack_temp, shr(and(temp, 0x00000000000000000000000000000000ffffffff000000000000000000000000), 0x60))*/

                // column d
                /*temp := low
                stack_temp := xor(stack_temp, shr(and(temp, 0x0000000000000000000000000000000000000000ffffffff0000000000000000), 0x40))*/

                // column e
                /*temp := low
                stack_temp := xor(stack_temp, shr(and(temp, 0x000000000000000000000000000000000000000000000000ffffffff00000000), 0x20))*/

                // column f
                    temp := low
                    stack_temp := xor(stack_temp, and(temp, 0x00000000000000000000000000000000000000000000000000000000ffffffff))

                    new_high := or(new_high, stack_temp)

                // row 8,0 1 0 1 0 1 1 0 1 0 0 1 0 0 0 1
                    stack_temp := byte(0x20, 0x00)
                // column 0
                /*temp := high
                stack_temp := xor(stack_temp, shr(temp, 0xE0))*/

                // column 1
                    temp := high
                    stack_temp := xor(stack_temp, shr(and(temp, 0x00000000ffffffff000000000000000000000000000000000000000000000000), 0xC0))

                // column 2
                /*temp := high
                stack_temp := xor(stack_temp, shr(and(temp, 0x0000000000000000ffffffff0000000000000000000000000000000000000000), 0xA0))*/

                // column 3
                    temp := high
                    stack_temp := xor(stack_temp, shr(and(temp, 0x000000000000000000000000ffffffff00000000000000000000000000000000), 0x80))

                // column 4
                /*temp := high
                stack_temp := xor(stack_temp, shr(and(temp, 0x00000000000000000000000000000000ffffffff000000000000000000000000), 0x60))*/

                // column 5
                    temp := high
                    stack_temp := xor(stack_temp, shr(and(temp, 0x0000000000000000000000000000000000000000ffffffff0000000000000000), 0x40))

                // column 6
                    temp := high
                    stack_temp := xor(stack_temp, shr(and(temp, 0x000000000000000000000000000000000000000000000000ffffffff00000000), 0x20))

                // column 7
                /*temp := high
                stack_temp := xor(stack_temp, and(temp, 0x00000000000000000000000000000000000000000000000000000000ffffffff))*/

                // column 8
                    temp := low
                    stack_temp := xor(stack_temp, shr(temp, 0xE0))

                // column 9
                /*temp := low
                stack_temp := xor(stack_temp, shr(and(temp, 0x00000000ffffffff000000000000000000000000000000000000000000000000), 0xC0))*/

                // column a
                /*temp := low
                stack_temp := xor(stack_temp, shr(and(temp, 0x0000000000000000ffffffff0000000000000000000000000000000000000000), 0xA0))*/

                // column b
                    temp := low
                    stack_temp := xor(stack_temp, shr(and(temp, 0x000000000000000000000000ffffffff00000000000000000000000000000000), 0x80))

                // column c
                /*temp := low
                stack_temp := xor(stack_temp, shr(and(temp, 0x00000000000000000000000000000000ffffffff000000000000000000000000), 0x60))*/

                // column d
                /*temp := low
                stack_temp := xor(stack_temp, shr(and(temp, 0x0000000000000000000000000000000000000000ffffffff0000000000000000), 0x40))*/

                // column e
                /*temp := low
                stack_temp := xor(stack_temp, shr(and(temp, 0x000000000000000000000000000000000000000000000000ffffffff00000000), 0x20))*/

                // column f
                    temp := low
                    stack_temp := xor(stack_temp, and(temp, 0x00000000000000000000000000000000000000000000000000000000ffffffff))

                    new_low := or(new_low, shl(stack_temp, 0xE0))

                // row 9,0 0 1 0 1 0 1 1 0 1 0 0 1 0 0 1
                    stack_temp := byte(0x20, 0x00)
                // column 0
                /*temp := high
                stack_temp := xor(stack_temp, shr(temp, 0xE0))*/

                // column 1
                /*temp := high
                stack_temp := xor(stack_temp, shr(and(temp, 0x00000000ffffffff000000000000000000000000000000000000000000000000), 0xC0))*/

                // column 2
                    temp := high
                    stack_temp := xor(stack_temp, shr(and(temp, 0x0000000000000000ffffffff0000000000000000000000000000000000000000), 0xA0))

                // column 3
                /*temp := high
                stack_temp := xor(stack_temp, shr(and(temp, 0x000000000000000000000000ffffffff00000000000000000000000000000000), 0x80))*/

                // column 4
                    temp := high
                    stack_temp := xor(stack_temp, shr(and(temp, 0x00000000000000000000000000000000ffffffff000000000000000000000000), 0x60))

                // column 5
                /*temp := high
                stack_temp := xor(stack_temp, shr(and(temp, 0x0000000000000000000000000000000000000000ffffffff0000000000000000), 0x40))*/

                // column 6
                    temp := high
                    stack_temp := xor(stack_temp, shr(and(temp, 0x000000000000000000000000000000000000000000000000ffffffff00000000), 0x20))

                // column 7
                    temp := high
                    stack_temp := xor(stack_temp, and(temp, 0x00000000000000000000000000000000000000000000000000000000ffffffff))

                // column 8
                /*temp := low
                stack_temp := xor(stack_temp, shr(temp, 0xE0))*/

                // column 9
                    temp := low
                    stack_temp := xor(stack_temp, shr(and(temp, 0x00000000ffffffff000000000000000000000000000000000000000000000000), 0xC0))

                // column a
                /*temp := low
                stack_temp := xor(stack_temp, shr(and(temp, 0x0000000000000000ffffffff0000000000000000000000000000000000000000), 0xA0))*/

                // column b
                /*temp := low
                stack_temp := xor(stack_temp, shr(and(temp, 0x000000000000000000000000ffffffff00000000000000000000000000000000), 0x80))*/

                // column c
                    temp := low
                    stack_temp := xor(stack_temp, shr(and(temp, 0x00000000000000000000000000000000ffffffff000000000000000000000000), 0x60))

                // column d
                /*temp := low
                stack_temp := xor(stack_temp, shr(and(temp, 0x0000000000000000000000000000000000000000ffffffff0000000000000000), 0x40))*/

                // column e
                /*temp := low
                stack_temp := xor(stack_temp, shr(and(temp, 0x000000000000000000000000000000000000000000000000ffffffff00000000), 0x20))*/

                // column f
                    temp := low
                    stack_temp := xor(stack_temp, and(temp, 0x00000000000000000000000000000000000000000000000000000000ffffffff))

                    new_low := or(new_low, shl(stack_temp, 0xC0))

                // row a,0 0 0 1 0 1 0 1 1 0 1 0 0 1 0 1
                    stack_temp := byte(0x20, 0x00)
                // column 0
                /*temp := high
                stack_temp := xor(stack_temp, shr(temp, 0xE0))*/

                // column 1
                /*temp := high
                stack_temp := xor(stack_temp, shr(and(temp, 0x00000000ffffffff000000000000000000000000000000000000000000000000), 0xC0))*/

                // column 2
                /*temp := high
                stack_temp := xor(stack_temp, shr(and(temp, 0x0000000000000000ffffffff0000000000000000000000000000000000000000), 0xA0))*/

                // column 3
                    temp := high
                    stack_temp := xor(stack_temp, shr(and(temp, 0x000000000000000000000000ffffffff00000000000000000000000000000000), 0x80))

                // column 4
                /*temp := high
                stack_temp := xor(stack_temp, shr(and(temp, 0x00000000000000000000000000000000ffffffff000000000000000000000000), 0x60))*/

                // column 5
                    temp := high
                    stack_temp := xor(stack_temp, shr(and(temp, 0x0000000000000000000000000000000000000000ffffffff0000000000000000), 0x40))

                // column 6
                /*temp := high
                stack_temp := xor(stack_temp, shr(and(temp, 0x000000000000000000000000000000000000000000000000ffffffff00000000), 0x20))*/

                // column 7
                    temp := high
                    stack_temp := xor(stack_temp, and(temp, 0x00000000000000000000000000000000000000000000000000000000ffffffff))

                // column 8
                    temp := low
                    stack_temp := xor(stack_temp, shr(temp, 0xE0))

                // column 9
                /*temp := low
                stack_temp := xor(stack_temp, shr(and(temp, 0x00000000ffffffff000000000000000000000000000000000000000000000000), 0xC0))*/

                // column a
                    temp := low
                    stack_temp := xor(stack_temp, shr(and(temp, 0x0000000000000000ffffffff0000000000000000000000000000000000000000), 0xA0))

                // column b
                /*temp := low
                stack_temp := xor(stack_temp, shr(and(temp, 0x000000000000000000000000ffffffff00000000000000000000000000000000), 0x80))*/

                // column c
                /*temp := low
                stack_temp := xor(stack_temp, shr(and(temp, 0x00000000000000000000000000000000ffffffff000000000000000000000000), 0x60))*/

                // column d
                    temp := low
                    stack_temp := xor(stack_temp, shr(and(temp, 0x0000000000000000000000000000000000000000ffffffff0000000000000000), 0x40))

                // column e
                /*temp := low
                stack_temp := xor(stack_temp, shr(and(temp, 0x000000000000000000000000000000000000000000000000ffffffff00000000), 0x20))*/

                // column f
                    temp := low
                    stack_temp := xor(stack_temp, and(temp, 0x00000000000000000000000000000000000000000000000000000000ffffffff))

                    new_low := or(new_low, shl(stack_temp, 0xA0))


                // row b,0 0 0 0 1 0 1 0 1 1 0 1 0 0 1 1
                    stack_temp := byte(0x20, 0x00)
                // column 0
                /*temp := high
                stack_temp := xor(stack_temp, shr(temp, 0xE0))*/

                // column 1
                /*temp := high
                stack_temp := xor(stack_temp, shr(and(temp, 0x00000000ffffffff000000000000000000000000000000000000000000000000), 0xC0))*/

                // column 2
                /*temp := high
                stack_temp := xor(stack_temp, shr(and(temp, 0x0000000000000000ffffffff0000000000000000000000000000000000000000), 0xA0))*/

                // column 3
                /*temp := high
                stack_temp := xor(stack_temp, shr(and(temp, 0x000000000000000000000000ffffffff00000000000000000000000000000000), 0x80))*/

                // column 4
                    temp := high
                    stack_temp := xor(stack_temp, shr(and(temp, 0x00000000000000000000000000000000ffffffff000000000000000000000000), 0x60))

                // column 5
                /*temp := high
                stack_temp := xor(stack_temp, shr(and(temp, 0x0000000000000000000000000000000000000000ffffffff0000000000000000), 0x40))*/

                // column 6
                    temp := high
                    stack_temp := xor(stack_temp, shr(and(temp, 0x000000000000000000000000000000000000000000000000ffffffff00000000), 0x20))

                // column 7
                /*temp := high
                stack_temp := xor(stack_temp, and(temp, 0x00000000000000000000000000000000000000000000000000000000ffffffff))*/

                // column 8
                    temp := low
                    stack_temp := xor(stack_temp, shr(temp, 0xE0))

                // column 9
                    temp := low
                    stack_temp := xor(stack_temp, shr(and(temp, 0x00000000ffffffff000000000000000000000000000000000000000000000000), 0xC0))

                // column a
                /*temp := low
                stack_temp := xor(stack_temp, shr(and(temp, 0x0000000000000000ffffffff0000000000000000000000000000000000000000), 0xA0))*/

                // column b
                    temp := low
                    stack_temp := xor(stack_temp, shr(and(temp, 0x000000000000000000000000ffffffff00000000000000000000000000000000), 0x80))

                // column c
                /*temp := low
                stack_temp := xor(stack_temp, shr(and(temp, 0x00000000000000000000000000000000ffffffff000000000000000000000000), 0x60))*/

                // column d
                /*temp := low
                stack_temp := xor(stack_temp, shr(and(temp, 0x0000000000000000000000000000000000000000ffffffff0000000000000000), 0x40))*/

                // column e
                    temp := low
                    stack_temp := xor(stack_temp, shr(and(temp, 0x000000000000000000000000000000000000000000000000ffffffff00000000), 0x20))

                // column f
                    temp := low
                    stack_temp := xor(stack_temp, and(temp, 0x00000000000000000000000000000000000000000000000000000000ffffffff))

                    new_low := or(new_low, shl(stack_temp, 0x80))

                // row c,1 1 1 1 0 0 0 0 1 0 0 1 1 0 0 0
                    stack_temp := byte(0x20, 0x00)
                // column 0
                    temp := high
                    stack_temp := xor(stack_temp, shr(temp, 0xE0))

                // column 1
                    temp := high
                    stack_temp := xor(stack_temp, shr(and(temp, 0x00000000ffffffff000000000000000000000000000000000000000000000000), 0xC0))

                // column 2
                    temp := high
                    stack_temp := xor(stack_temp, shr(and(temp, 0x0000000000000000ffffffff0000000000000000000000000000000000000000), 0xA0))

                // column 3
                    temp := high
                    stack_temp := xor(stack_temp, shr(and(temp, 0x000000000000000000000000ffffffff00000000000000000000000000000000), 0x80))

                // column 4
                /*temp := high
                stack_temp := xor(stack_temp, shr(and(temp, 0x00000000000000000000000000000000ffffffff000000000000000000000000), 0x60))*/

                // column 5
                /*temp := high
                stack_temp := xor(stack_temp, shr(and(temp, 0x0000000000000000000000000000000000000000ffffffff0000000000000000), 0x40))*/

                // column 6
                /*temp := high
                stack_temp := xor(stack_temp, shr(and(temp, 0x000000000000000000000000000000000000000000000000ffffffff00000000), 0x20))*/

                // column 7
                /*temp := high
                stack_temp := xor(stack_temp, and(temp, 0x00000000000000000000000000000000000000000000000000000000ffffffff))*/

                // column 8
                    temp := low
                    stack_temp := xor(stack_temp, shr(temp, 0xE0))

                // column 9
                /*temp := low
                stack_temp := xor(stack_temp, shr(and(temp, 0x00000000ffffffff000000000000000000000000000000000000000000000000), 0xC0))*/

                // column a
                /*temp := low
                stack_temp := xor(stack_temp, shr(and(temp, 0x0000000000000000ffffffff0000000000000000000000000000000000000000), 0xA0))*/

                // column b
                    temp := low
                    stack_temp := xor(stack_temp, shr(and(temp, 0x000000000000000000000000ffffffff00000000000000000000000000000000), 0x80))

                // column c
                    temp := low
                    stack_temp := xor(stack_temp, shr(and(temp, 0x00000000000000000000000000000000ffffffff000000000000000000000000), 0x60))

                // column d
                /*temp := low
                stack_temp := xor(stack_temp, shr(and(temp, 0x0000000000000000000000000000000000000000ffffffff0000000000000000), 0x40))*/

                // column e
                /*temp := low
                stack_temp := xor(stack_temp, shr(and(temp, 0x000000000000000000000000000000000000000000000000ffffffff00000000), 0x20))*/

                // column f
                /*temp := low
                stack_temp := xor(stack_temp, and(temp, 0x00000000000000000000000000000000000000000000000000000000ffffffff))*/

                    new_low := or(new_low, shl(stack_temp, 0x60))

                // row d,0 1 1 1 1 0 0 0 0 1 0 0 1 1 0 0
                    stack_temp := byte(0x20, 0x00)
                // column 0
                /*temp := high
                stack_temp := xor(stack_temp, shr(temp, 0xE0))*/

                // column 1
                    temp := high
                    stack_temp := xor(stack_temp, shr(and(temp, 0x00000000ffffffff000000000000000000000000000000000000000000000000), 0xC0))

                // column 2
                    temp := high
                    stack_temp := xor(stack_temp, shr(and(temp, 0x0000000000000000ffffffff0000000000000000000000000000000000000000), 0xA0))

                // column 3
                    temp := high
                    stack_temp := xor(stack_temp, shr(and(temp, 0x000000000000000000000000ffffffff00000000000000000000000000000000), 0x80))

                // column 4
                    temp := high
                    stack_temp := xor(stack_temp, shr(and(temp, 0x00000000000000000000000000000000ffffffff000000000000000000000000), 0x60))

                // column 5
                /*temp := high
                stack_temp := xor(stack_temp, shr(and(temp, 0x0000000000000000000000000000000000000000ffffffff0000000000000000), 0x40))*/

                // column 6
                /*temp := high
                stack_temp := xor(stack_temp, shr(and(temp, 0x000000000000000000000000000000000000000000000000ffffffff00000000), 0x20))*/

                // column 7
                /*temp := high
                stack_temp := xor(stack_temp, and(temp, 0x00000000000000000000000000000000000000000000000000000000ffffffff))*/

                // column 8
                /*temp := low
                stack_temp := xor(stack_temp, shr(temp, 0xE0))*/

                // column 9
                    temp := low
                    stack_temp := xor(stack_temp, shr(and(temp, 0x00000000ffffffff000000000000000000000000000000000000000000000000), 0xC0))

                // column a
                /*temp := low
                stack_temp := xor(stack_temp, shr(and(temp, 0x0000000000000000ffffffff0000000000000000000000000000000000000000), 0xA0))*/

                // column b
                /*temp := low
                stack_temp := xor(stack_temp, shr(and(temp, 0x000000000000000000000000ffffffff00000000000000000000000000000000), 0x80))*/

                // column c
                    temp := low
                    stack_temp := xor(stack_temp, shr(and(temp, 0x00000000000000000000000000000000ffffffff000000000000000000000000), 0x60))

                // column d
                    temp := low
                    stack_temp := xor(stack_temp, shr(and(temp, 0x0000000000000000000000000000000000000000ffffffff0000000000000000), 0x40))

                // column e
                /*temp := low
                stack_temp := xor(stack_temp, shr(and(temp, 0x000000000000000000000000000000000000000000000000ffffffff00000000), 0x20))*/

                // column f
                /*temp := low
                stack_temp := xor(stack_temp, and(temp, 0x00000000000000000000000000000000000000000000000000000000ffffffff))*/

                    new_low := or(new_low, shl(stack_temp, 0x40))

                // row e,0 0 1 1 1 1 0 0 0 0 1 0 0 1 1 0
                    stack_temp := byte(0x20, 0x00)
                // column 0
                /*temp := high
                stack_temp := xor(stack_temp, shr(temp, 0xE0))*/

                // column 1
                /*temp := high
                stack_temp := xor(stack_temp, shr(and(temp, 0x00000000ffffffff000000000000000000000000000000000000000000000000), 0xC0))*/

                // column 2
                    temp := high
                    stack_temp := xor(stack_temp, shr(and(temp, 0x0000000000000000ffffffff0000000000000000000000000000000000000000), 0xA0))

                // column 3
                    temp := high
                    stack_temp := xor(stack_temp, shr(and(temp, 0x000000000000000000000000ffffffff00000000000000000000000000000000), 0x80))

                // column 4
                    temp := high
                    stack_temp := xor(stack_temp, shr(and(temp, 0x00000000000000000000000000000000ffffffff000000000000000000000000), 0x60))

                // column 5
                    temp := high
                    stack_temp := xor(stack_temp, shr(and(temp, 0x0000000000000000000000000000000000000000ffffffff0000000000000000), 0x40))

                // column 6
                /*temp := high
                stack_temp := xor(stack_temp, shr(and(temp, 0x000000000000000000000000000000000000000000000000ffffffff00000000), 0x20))*/

                // column 7
                /*temp := high
                stack_temp := xor(stack_temp, and(temp, 0x00000000000000000000000000000000000000000000000000000000ffffffff))*/

                // column 8
                /*temp := low
                stack_temp := xor(stack_temp, shr(temp, 0xE0))*/

                // column 9
                /*temp := low
                stack_temp := xor(stack_temp, shr(and(temp, 0x00000000ffffffff000000000000000000000000000000000000000000000000), 0xC0))*/

                // column a
                    temp := low
                    stack_temp := xor(stack_temp, shr(and(temp, 0x0000000000000000ffffffff0000000000000000000000000000000000000000), 0xA0))

                // column b
                /*temp := low
                stack_temp := xor(stack_temp, shr(and(temp, 0x000000000000000000000000ffffffff00000000000000000000000000000000), 0x80))*/

                // column c
                /*temp := low
                stack_temp := xor(stack_temp, shr(and(temp, 0x00000000000000000000000000000000ffffffff000000000000000000000000), 0x60))*/

                // column d
                    temp := low
                    stack_temp := xor(stack_temp, shr(and(temp, 0x0000000000000000000000000000000000000000ffffffff0000000000000000), 0x40))

                // column e
                    temp := low
                    stack_temp := xor(stack_temp, shr(and(temp, 0x000000000000000000000000000000000000000000000000ffffffff00000000), 0x20))

                // column f
                /*temp := low
                stack_temp := xor(stack_temp, and(temp, 0x00000000000000000000000000000000000000000000000000000000ffffffff))*/

                    new_low := or(new_low, shl(stack_temp, 0x20))

                // row f,1 1 1 0 1 0 1 1 1 1 1 0 0 0 1 1
                    stack_temp := byte(0x20, 0x00)
                // column 0
                    temp := high
                    stack_temp := xor(stack_temp, shr(temp, 0xE0))

                // column 1
                    temp := high
                    stack_temp := xor(stack_temp, shr(and(temp, 0x00000000ffffffff000000000000000000000000000000000000000000000000), 0xC0))

                // column 2
                    temp := high
                    stack_temp := xor(stack_temp, shr(and(temp, 0x0000000000000000ffffffff0000000000000000000000000000000000000000), 0xA0))

                // column 3
                /*temp := high
                stack_temp := xor(stack_temp, shr(and(temp, 0x000000000000000000000000ffffffff00000000000000000000000000000000), 0x80))*/

                // column 4
                    temp := high
                    stack_temp := xor(stack_temp, shr(and(temp, 0x00000000000000000000000000000000ffffffff000000000000000000000000), 0x60))

                // column 5
                /*temp := high
                stack_temp := xor(stack_temp, shr(and(temp, 0x0000000000000000000000000000000000000000ffffffff0000000000000000), 0x40))*/

                // column 6
                    temp := high
                    stack_temp := xor(stack_temp, shr(and(temp, 0x000000000000000000000000000000000000000000000000ffffffff00000000), 0x20))

                // column 7
                    temp := high
                    stack_temp := xor(stack_temp, and(temp, 0x00000000000000000000000000000000000000000000000000000000ffffffff))

                // column 8
                    temp := low
                    stack_temp := xor(stack_temp, shr(temp, 0xE0))

                // column 9
                    temp := low
                    stack_temp := xor(stack_temp, shr(and(temp, 0x00000000ffffffff000000000000000000000000000000000000000000000000), 0xC0))

                // column a
                    temp := low
                    stack_temp := xor(stack_temp, shr(and(temp, 0x0000000000000000ffffffff0000000000000000000000000000000000000000), 0xA0))

                // column b
                /*temp := low
                stack_temp := xor(stack_temp, shr(and(temp, 0x000000000000000000000000ffffffff00000000000000000000000000000000), 0x80))*/

                // column c
                /*temp := low
                stack_temp := xor(stack_temp, shr(and(temp, 0x00000000000000000000000000000000ffffffff000000000000000000000000), 0x60))*/

                // column d
                /*temp := low
                stack_temp := xor(stack_temp, shr(and(temp, 0x0000000000000000000000000000000000000000ffffffff0000000000000000), 0x40))*/

                // column e
                    temp := low
                    stack_temp := xor(stack_temp, shr(and(temp, 0x000000000000000000000000000000000000000000000000ffffffff00000000), 0x20))

                // column f
                    temp := low
                    stack_temp := xor(stack_temp, and(temp, 0x00000000000000000000000000000000000000000000000000000000ffffffff))

                    new_low := or(new_low, stack_temp)


                    low := new_low
                    high := new_high

                // bit matrix
                }

                {// circulant multiplication
                    new_low := byte(0x20, 0x00)
                    new_high := byte(0x20, 0x00)

                /*coefficients = [
                    [0, 2, 4],
                    [0, 13, 22],
                    [0, 4, 19],
                    [0, 3, 14],
                    [0, 27, 31],
                    [0, 3, 8],
                    [0, 17, 26],
                    [0, 3, 12],
                    [0, 18, 22],
                    [0, 12, 18],
                    [0, 4, 7],
                    [0, 4, 31],
                    [0, 12, 27],
                    [0, 7, 17],
                    [0, 7, 8],
                    [0, 1, 13]
                ];*/



                // alloc a item for temp usage of 32 bits
                // we use the lowest 32 bits of 256 bits
                    let stack_temp := byte(0x20, 0x00)// for output_vector[j]
                    let temp_high := byte(0x20, 0x00)
                    let temp_low := byte(0x20, 0x00)
                    let state_vector := byte(0x20, 0x00)
                    let temp1 := byte(0x20, 0x00)// for dup of original state_vector
                    let temp2 := byte(0x20, 0x00)// for dup of original state_vector

                // row 0,0, 2, 4
                    temp_high := high
                    state_vector := shr(temp_high, 0xE0)

                    stack_temp := state_vector

                    temp1 := state_vector
                    temp2 := state_vector

                    stack_temp := xor(stack_temp,or(
                    and(shl(temp1,2),0x00000000000000000000000000000000000000000000000000000000ffffffff),
                    shr(temp2,30)
                    ))

                    temp1 := state_vector
                    temp1 := state_vector

                    stack_temp := xor(stack_temp,or(
                    and(shl(temp1,4),0x00000000000000000000000000000000000000000000000000000000ffffffff),
                    shr(temp2,28)
                    ))

                    new_high := or(new_high, shl(stack_temp, 0xE0))

                // row 1,0, 13, 22

                    temp_high := high
                    state_vector := shr(and(temp_high, 0x00000000ffffffff000000000000000000000000000000000000000000000000), 0xC0)

                    stack_temp := state_vector

                    temp1 := state_vector
                    temp2 := state_vector

                    stack_temp := xor(stack_temp,or(
                    and(shl(temp1,13),0x00000000000000000000000000000000000000000000000000000000ffffffff),
                    shr(temp2,17)
                    ))

                    temp1 := state_vector
                    temp2 := state_vector

                    stack_temp := xor(stack_temp,or(
                    and(shl(temp1,22),0x00000000000000000000000000000000000000000000000000000000ffffffff),
                    shr(temp2,10)
                    ))

                    new_high := or(new_high, shl(stack_temp, 0xC0))

                // row 2,0, 4, 19

                    temp_high := high
                    state_vector := shr(and(temp_high, 0x0000000000000000ffffffff0000000000000000000000000000000000000000), 0xA0)

                    stack_temp := state_vector

                    temp1 := state_vector
                    temp2 := state_vector

                    stack_temp := xor(stack_temp,or(
                    and(shl(temp1,4),0x00000000000000000000000000000000000000000000000000000000ffffffff),
                    shr(temp2,28)
                    ))

                    temp1 := state_vector
                    temp2 := state_vector

                    stack_temp := xor(stack_temp,or(
                    and(shl(temp1,19),0x00000000000000000000000000000000000000000000000000000000ffffffff),
                    shr(temp2,13)
                    ))

                    new_high := or(new_high, shl(stack_temp, 0xA0))

                // row 3,0, 3, 14

                    temp_high := high
                    state_vector := shr(and(temp_high, 0x000000000000000000000000ffffffff00000000000000000000000000000000), 0x80)

                    stack_temp := state_vector

                    temp1 := state_vector
                    temp2 := state_vector

                    stack_temp := xor(stack_temp,or(
                    and(shl(temp1,3),0x00000000000000000000000000000000000000000000000000000000ffffffff),
                    shr(temp2,29)
                    ))

                    temp1 := state_vector
                    temp2 := state_vector

                    stack_temp := xor(stack_temp,or(
                    and(shl(temp1,14),0x00000000000000000000000000000000000000000000000000000000ffffffff),
                    shr(temp2,18)
                    ))

                    new_high := or(new_high, shl(stack_temp, 0x80))

                // row 4,0, 27, 31

                    temp_high := high
                    state_vector := shr(and(temp_high, 0x00000000000000000000000000000000ffffffff000000000000000000000000), 0x60)

                    stack_temp := state_vector

                    temp1 := state_vector
                    temp2 := state_vector

                    stack_temp := xor(stack_temp,or(
                    and(shl(temp1,27),0x00000000000000000000000000000000000000000000000000000000ffffffff),
                    shr(temp2,5)
                    ))

                    temp1 := state_vector
                    temp2 := state_vector

                    stack_temp := xor(stack_temp,or(
                    and(shl(temp1,31),0x00000000000000000000000000000000000000000000000000000000ffffffff),
                    shr(temp2,1)
                    ))

                    new_high := or(new_high, shl(stack_temp, 0x60))

                // row 5,0, 3, 8

                    temp_high := high
                    state_vector := shr(and(temp_high, 0x0000000000000000000000000000000000000000ffffffff0000000000000000), 0x40)

                    stack_temp := state_vector

                    temp1 := state_vector
                    temp2 := state_vector

                    stack_temp := xor(stack_temp,or(
                    and(shl(temp1,3),0x00000000000000000000000000000000000000000000000000000000ffffffff),
                    shr(temp2,29)
                    ))

                    temp1 := state_vector
                    temp2 := state_vector

                    stack_temp := xor(stack_temp,or(
                    and(shl(temp1,8),0x00000000000000000000000000000000000000000000000000000000ffffffff),
                    shr(temp2,24)
                    ))

                    new_high := or(new_high, shl(stack_temp, 0x40))

                // row 6,0, 17, 26

                    temp_high := high
                    state_vector := shr(and(temp_high, 0x000000000000000000000000000000000000000000000000ffffffff00000000), 0x20)

                    stack_temp := state_vector

                    temp1 := state_vector
                    temp2 := state_vector

                    stack_temp := xor(stack_temp,or(
                    and(shl(temp1,17),0x00000000000000000000000000000000000000000000000000000000ffffffff),
                    shr(temp2,15)
                    ))

                    temp1 := state_vector
                    temp2 := state_vector

                    stack_temp := xor(stack_temp,or(
                    and(shl(temp1,26),0x00000000000000000000000000000000000000000000000000000000ffffffff),
                    shr(temp2,6)
                    ))

                    new_high := or(new_high, shl(stack_temp, 0x20))

                // row 7,0, 3, 12

                    temp_high := high
                    state_vector := and(temp_high, 0x00000000000000000000000000000000000000000000000000000000ffffffff)

                    stack_temp := state_vector

                    temp1 := state_vector
                    temp2 := state_vector

                    stack_temp := xor(stack_temp,or(
                    and(shl(temp1,3),0x00000000000000000000000000000000000000000000000000000000ffffffff),
                    shr(temp2,29)
                    ))

                    temp1 := state_vector
                    temp2 := state_vector

                    stack_temp := xor(stack_temp,or(
                    and(shl(temp1,12),0x00000000000000000000000000000000000000000000000000000000ffffffff),
                    shr(temp2,20)
                    ))

                    new_high := or(new_high, stack_temp)

                // row 8,0, 18, 22

                    temp_low := low
                    state_vector := shr(temp_low, 0xE0)

                    stack_temp := state_vector

                    temp1 := state_vector
                    temp2 := state_vector

                    stack_temp := xor(stack_temp,or(
                    and(shl(temp1,18),0x00000000000000000000000000000000000000000000000000000000ffffffff),
                    shr(temp2,14)
                    ))

                    temp1 := state_vector
                    temp2 := state_vector

                    stack_temp := xor(stack_temp,or(
                    and(shl(temp1,22),0x00000000000000000000000000000000000000000000000000000000ffffffff),
                    shr(temp2,10)
                    ))

                    new_low := or(new_low, shl(stack_temp, 0xE0))

                // row 9,0, 12, 18

                    temp_low := low
                    state_vector := shr(and(temp_low, 0x00000000ffffffff000000000000000000000000000000000000000000000000), 0xC0)

                    stack_temp := state_vector

                    temp1 := state_vector
                    temp2 := state_vector

                    stack_temp := xor(stack_temp,or(
                    and(shl(temp1,12),0x00000000000000000000000000000000000000000000000000000000ffffffff),
                    shr(temp2,20)
                    ))

                    temp1 := state_vector
                    temp2 := state_vector

                    stack_temp := xor(stack_temp,or(
                    and(shl(temp1,18),0x00000000000000000000000000000000000000000000000000000000ffffffff),
                    shr(temp2,14)
                    ))

                    new_low := or(new_low, shl(stack_temp, 0xC0))

                // row a,0, 4, 7

                    temp_low := low
                    state_vector := shr(and(temp_low, 0x0000000000000000ffffffff0000000000000000000000000000000000000000), 0xA0)

                    stack_temp := state_vector

                    temp1 := state_vector
                    temp2 := state_vector

                    stack_temp := xor(stack_temp,or(
                    and(shl(temp1,4),0x00000000000000000000000000000000000000000000000000000000ffffffff),
                    shr(temp2,28)
                    ))

                    temp1 := state_vector
                    temp2 := state_vector

                    stack_temp := xor(stack_temp,or(
                    and(shl(temp1,7),0x00000000000000000000000000000000000000000000000000000000ffffffff),
                    shr(temp2,25)
                    ))

                    new_low := or(new_low, shl(stack_temp, 0xA0))

                // row b,0, 4, 31

                    temp_low := low
                    state_vector := shr(and(temp_low, 0x000000000000000000000000ffffffff00000000000000000000000000000000), 0x80)

                    stack_temp := state_vector

                    temp1 := state_vector
                    temp2 := state_vector

                    stack_temp := xor(stack_temp,or(
                    and(shl(temp1,4),0x00000000000000000000000000000000000000000000000000000000ffffffff),
                    shr(temp2,28)
                    ))

                    temp1 := state_vector
                    temp2 := state_vector

                    stack_temp := xor(stack_temp,or(
                    and(shl(temp1,31),0x00000000000000000000000000000000000000000000000000000000ffffffff),
                    shr(temp2,1)
                    ))

                    new_low := or(new_low, shl(stack_temp, 0x80))

                // row c,0, 12, 27

                    temp_low := low
                    state_vector := shr(and(temp_low, 0x00000000000000000000000000000000ffffffff000000000000000000000000), 0x60)

                    stack_temp := state_vector

                    temp1 := state_vector
                    temp2 := state_vector

                    stack_temp := xor(stack_temp,or(
                    and(shl(temp1,12),0x00000000000000000000000000000000000000000000000000000000ffffffff),
                    shr(temp2,20)
                    ))

                    temp1 := state_vector
                    temp2 := state_vector

                    stack_temp := xor(stack_temp,or(
                    and(shl(temp1,27),0x00000000000000000000000000000000000000000000000000000000ffffffff),
                    shr(temp2,5)
                    ))

                    new_low := or(new_low, shl(stack_temp, 0x60))

                // row d,0, 7, 17

                    temp_low := low
                    state_vector := shr(and(temp_low, 0x0000000000000000000000000000000000000000ffffffff0000000000000000), 0x40)

                    stack_temp := state_vector

                    temp1 := state_vector
                    temp2 := state_vector

                    stack_temp := xor(stack_temp,or(
                    and(shl(temp1,7),0x00000000000000000000000000000000000000000000000000000000ffffffff),
                    shr(temp2,25)
                    ))

                    temp1 := state_vector
                    temp2 := state_vector

                    stack_temp := xor(stack_temp,or(
                    and(shl(temp1,17),0x00000000000000000000000000000000000000000000000000000000ffffffff),
                    shr(temp2,15)
                    ))

                    new_low := or(new_low, shl(stack_temp, 0x40))

                // row e,0, 7, 8

                    temp_low := low
                    state_vector := shr(and(temp_low, 0x000000000000000000000000000000000000000000000000ffffffff00000000), 0x20)

                    stack_temp := state_vector

                    temp1 := state_vector
                    temp2 := state_vector

                    stack_temp := xor(stack_temp,or(
                    and(shl(temp1,7),0x00000000000000000000000000000000000000000000000000000000ffffffff),
                    shr(temp2,25)
                    ))

                    temp1 := state_vector
                    temp2 := state_vector

                    stack_temp := xor(stack_temp,or(
                    and(shl(temp1,8),0x00000000000000000000000000000000000000000000000000000000ffffffff),
                    shr(temp2,24)
                    ))

                    new_low := or(new_low, shl(stack_temp, 0x20))

                // row f,0, 1, 13

                    temp_low := low
                    state_vector := and(temp_low, 0x00000000000000000000000000000000000000000000000000000000ffffffff)

                    stack_temp := state_vector

                    temp1 := state_vector
                    temp2 := state_vector

                    stack_temp := xor(stack_temp,or(
                    and(shl(temp1,1),0x00000000000000000000000000000000000000000000000000000000ffffffff),
                    shr(temp2,31)
                    ))

                    temp1 := state_vector
                    temp2 := state_vector

                    stack_temp := xor(stack_temp,or(
                    and(shl(temp1,13),0x00000000000000000000000000000000000000000000000000000000ffffffff),
                    shr(temp2,19)
                    ))

                    new_low := or(new_low,stack_temp)

                // finish
                    low := new_low
                    high := new_high

                // circulant multiplication
                }


                {//Injection of Constants

                    switch round

                    case 0{
                        high := xor(high,0x6e9e40ae71927c029a13d3b1daec32ad3d8951cfe1c9fe9ab806b54cacbbf417)
                        low := xor(low,0x6e9e40ae71927c029a13d3b1daec32ad3d8951cfe1c9fe9ab806b54cacbbf417)
                    }
                    case 1{
                        high := xor(high,0x6e9e40ae71927c029a13d3b1daec32ad3d8951cfe1c9fe9ab806b54cacbbf417)
                        low := xor(low,0x6e9e40ae71927c029a13d3b1daec32ad3d8951cfe1c9fe9ab806b54cacbbf417)
                    }
                    case 2{
                        high := xor(high,0x6e9e40ae71927c029a13d3b1daec32ad3d8951cfe1c9fe9ab806b54cacbbf417)
                        low := xor(low,0x6e9e40ae71927c029a13d3b1daec32ad3d8951cfe1c9fe9ab806b54cacbbf417)
                    }
                    case 3{
                        high := xor(high,0x6e9e40ae71927c029a13d3b1daec32ad3d8951cfe1c9fe9ab806b54cacbbf417)
                        low := xor(low,0x6e9e40ae71927c029a13d3b1daec32ad3d8951cfe1c9fe9ab806b54cacbbf417)
                    }
                    case 4{
                        high := xor(high,0x6e9e40ae71927c029a13d3b1daec32ad3d8951cfe1c9fe9ab806b54cacbbf417)
                        low := xor(low,0x6e9e40ae71927c029a13d3b1daec32ad3d8951cfe1c9fe9ab806b54cacbbf417)
                    }
                    case 5{
                        high := xor(high,0x6e9e40ae71927c029a13d3b1daec32ad3d8951cfe1c9fe9ab806b54cacbbf417)
                        low := xor(low,0x6e9e40ae71927c029a13d3b1daec32ad3d8951cfe1c9fe9ab806b54cacbbf417)
                    }
                    case 6{
                        high := xor(high,0x6e9e40ae71927c029a13d3b1daec32ad3d8951cfe1c9fe9ab806b54cacbbf417)
                        low := xor(low,0x6e9e40ae71927c029a13d3b1daec32ad3d8951cfe1c9fe9ab806b54cacbbf417)
                    }
                    case 7{
                        high := xor(high,0x6e9e40ae71927c029a13d3b1daec32ad3d8951cfe1c9fe9ab806b54cacbbf417)
                        low := xor(low,0x6e9e40ae71927c029a13d3b1daec32ad3d8951cfe1c9fe9ab806b54cacbbf417)
                    }
                    case 8{
                        high := xor(high,0x6e9e40ae71927c029a13d3b1daec32ad3d8951cfe1c9fe9ab806b54cacbbf417)
                        low := xor(low,0x6e9e40ae71927c029a13d3b1daec32ad3d8951cfe1c9fe9ab806b54cacbbf417)
                    }
                    case 9{
                        high := xor(high,0x6e9e40ae71927c029a13d3b1daec32ad3d8951cfe1c9fe9ab806b54cacbbf417)
                        low := xor(low,0x6e9e40ae71927c029a13d3b1daec32ad3d8951cfe1c9fe9ab806b54cacbbf417)
                    }
                    case 10{
                        high := xor(high,0x6e9e40ae71927c029a13d3b1daec32ad3d8951cfe1c9fe9ab806b54cacbbf417)
                        low := xor(low,0x6e9e40ae71927c029a13d3b1daec32ad3d8951cfe1c9fe9ab806b54cacbbf417)
                    }
                    case 11{
                        high := xor(high,0x6e9e40ae71927c029a13d3b1daec32ad3d8951cfe1c9fe9ab806b54cacbbf417)
                        low := xor(low,0x6e9e40ae71927c029a13d3b1daec32ad3d8951cfe1c9fe9ab806b54cacbbf417)
                    }
                    case 12{
                        high := xor(high,0x6e9e40ae71927c029a13d3b1daec32ad3d8951cfe1c9fe9ab806b54cacbbf417)
                        low := xor(low,0x6e9e40ae71927c029a13d3b1daec32ad3d8951cfe1c9fe9ab806b54cacbbf417)
                    }
                    case 13{
                        high := xor(high,0x6e9e40ae71927c029a13d3b1daec32ad3d8951cfe1c9fe9ab806b54cacbbf417)
                        low := xor(low,0x6e9e40ae71927c029a13d3b1daec32ad3d8951cfe1c9fe9ab806b54cacbbf417)
                    }
                    case 14{
                        high := xor(high,0x6e9e40ae71927c029a13d3b1daec32ad3d8951cfe1c9fe9ab806b54cacbbf417)
                        low := xor(low,0x6e9e40ae71927c029a13d3b1daec32ad3d8951cfe1c9fe9ab806b54cacbbf417)
                    }
                    case 15{
                        high := xor(high,0x6e9e40ae71927c029a13d3b1daec32ad3d8951cfe1c9fe9ab806b54cacbbf417)
                        low := xor(low,0x6e9e40ae71927c029a13d3b1daec32ad3d8951cfe1c9fe9ab806b54cacbbf417)
                    }
                    case 16{
                        high := xor(high,0x6e9e40ae71927c029a13d3b1daec32ad3d8951cfe1c9fe9ab806b54cacbbf417)
                        low := xor(low,0x6e9e40ae71927c029a13d3b1daec32ad3d8951cfe1c9fe9ab806b54cacbbf417)
                    }
                    case 17{
                        high := xor(high,0x6e9e40ae71927c029a13d3b1daec32ad3d8951cfe1c9fe9ab806b54cacbbf417)
                        low := xor(low,0x6e9e40ae71927c029a13d3b1daec32ad3d8951cfe1c9fe9ab806b54cacbbf417)
                    }
                    case 18{
                        high := xor(high,0x6e9e40ae71927c029a13d3b1daec32ad3d8951cfe1c9fe9ab806b54cacbbf417)
                        low := xor(low,0x6e9e40ae71927c029a13d3b1daec32ad3d8951cfe1c9fe9ab806b54cacbbf417)
                    }
                    case 19{
                        high := xor(high,0x6e9e40ae71927c029a13d3b1daec32ad3d8951cfe1c9fe9ab806b54cacbbf417)
                        low := xor(low,0x6e9e40ae71927c029a13d3b1daec32ad3d8951cfe1c9fe9ab806b54cacbbf417)
                    }
                    case 20{
                        high := xor(high,0x6e9e40ae71927c029a13d3b1daec32ad3d8951cfe1c9fe9ab806b54cacbbf417)
                        low := xor(low,0x6e9e40ae71927c029a13d3b1daec32ad3d8951cfe1c9fe9ab806b54cacbbf417)
                    }
                    case 21{
                        high := xor(high,0x6e9e40ae71927c029a13d3b1daec32ad3d8951cfe1c9fe9ab806b54cacbbf417)
                        low := xor(low,0x6e9e40ae71927c029a13d3b1daec32ad3d8951cfe1c9fe9ab806b54cacbbf417)
                    }
                    case 22{
                        high := xor(high,0x6e9e40ae71927c029a13d3b1daec32ad3d8951cfe1c9fe9ab806b54cacbbf417)
                        low := xor(low,0x6e9e40ae71927c029a13d3b1daec32ad3d8951cfe1c9fe9ab806b54cacbbf417)
                    }
                    case 23{
                        high := xor(high,0x6e9e40ae71927c029a13d3b1daec32ad3d8951cfe1c9fe9ab806b54cacbbf417)
                        low := xor(low,0x6e9e40ae71927c029a13d3b1daec32ad3d8951cfe1c9fe9ab806b54cacbbf417)
                    }
                    case 24{
                        high := xor(high,0x6e9e40ae71927c029a13d3b1daec32ad3d8951cfe1c9fe9ab806b54cacbbf417)
                        low := xor(low,0x6e9e40ae71927c029a13d3b1daec32ad3d8951cfe1c9fe9ab806b54cacbbf417)
                    }
                    case 25{
                        high := xor(high,0x6e9e40ae71927c029a13d3b1daec32ad3d8951cfe1c9fe9ab806b54cacbbf417)
                        low := xor(low,0x6e9e40ae71927c029a13d3b1daec32ad3d8951cfe1c9fe9ab806b54cacbbf417)
                    }
                    case 26{
                        high := xor(high,0x6e9e40ae71927c029a13d3b1daec32ad3d8951cfe1c9fe9ab806b54cacbbf417)
                        low := xor(low,0x6e9e40ae71927c029a13d3b1daec32ad3d8951cfe1c9fe9ab806b54cacbbf417)
                    }
                    case 27{
                        high := xor(high,0x6e9e40ae71927c029a13d3b1daec32ad3d8951cfe1c9fe9ab806b54cacbbf417)
                        low := xor(low,0x6e9e40ae71927c029a13d3b1daec32ad3d8951cfe1c9fe9ab806b54cacbbf417)
                    }
                    case 28{
                        high := xor(high,0x6e9e40ae71927c029a13d3b1daec32ad3d8951cfe1c9fe9ab806b54cacbbf417)
                        low := xor(low,0x6e9e40ae71927c029a13d3b1daec32ad3d8951cfe1c9fe9ab806b54cacbbf417)
                    }
                    case 29{
                        high := xor(high,0x6e9e40ae71927c029a13d3b1daec32ad3d8951cfe1c9fe9ab806b54cacbbf417)
                        low := xor(low,0x6e9e40ae71927c029a13d3b1daec32ad3d8951cfe1c9fe9ab806b54cacbbf417)
                    }
                    case 30{
                        high := xor(high,0x6e9e40ae71927c029a13d3b1daec32ad3d8951cfe1c9fe9ab806b54cacbbf417)
                        low := xor(low,0x6e9e40ae71927c029a13d3b1daec32ad3d8951cfe1c9fe9ab806b54cacbbf417)
                    }
                    case 31{
                        high := xor(high,0x6e9e40ae71927c029a13d3b1daec32ad3d8951cfe1c9fe9ab806b54cacbbf417)
                        low := xor(low,0x6e9e40ae71927c029a13d3b1daec32ad3d8951cfe1c9fe9ab806b54cacbbf417)
                    }
                    case 32{
                        high := xor(high,0x6e9e40ae71927c029a13d3b1daec32ad3d8951cfe1c9fe9ab806b54cacbbf417)
                        low := xor(low,0x6e9e40ae71927c029a13d3b1daec32ad3d8951cfe1c9fe9ab806b54cacbbf417)
                    }
                    case 33{
                        high := xor(high,0x6e9e40ae71927c029a13d3b1daec32ad3d8951cfe1c9fe9ab806b54cacbbf417)
                        low := xor(low,0x6e9e40ae71927c029a13d3b1daec32ad3d8951cfe1c9fe9ab806b54cacbbf417)
                    }
                    case 34{
                        high := xor(high,0x6e9e40ae71927c029a13d3b1daec32ad3d8951cfe1c9fe9ab806b54cacbbf417)
                        low := xor(low,0x6e9e40ae71927c029a13d3b1daec32ad3d8951cfe1c9fe9ab806b54cacbbf417)
                    }
                    case 35{
                        high := xor(high,0x6e9e40ae71927c029a13d3b1daec32ad3d8951cfe1c9fe9ab806b54cacbbf417)
                        low := xor(low,0x6e9e40ae71927c029a13d3b1daec32ad3d8951cfe1c9fe9ab806b54cacbbf417)
                    }
                    case 36{
                        high := xor(high,0x6e9e40ae71927c029a13d3b1daec32ad3d8951cfe1c9fe9ab806b54cacbbf417)
                        low := xor(low,0x6e9e40ae71927c029a13d3b1daec32ad3d8951cfe1c9fe9ab806b54cacbbf417)
                    }
                    case 37{
                        high := xor(high,0x6e9e40ae71927c029a13d3b1daec32ad3d8951cfe1c9fe9ab806b54cacbbf417)
                        low := xor(low,0x6e9e40ae71927c029a13d3b1daec32ad3d8951cfe1c9fe9ab806b54cacbbf417)
                    }
                    case 38{
                        high := xor(high,0x6e9e40ae71927c029a13d3b1daec32ad3d8951cfe1c9fe9ab806b54cacbbf417)
                        low := xor(low,0x6e9e40ae71927c029a13d3b1daec32ad3d8951cfe1c9fe9ab806b54cacbbf417)
                    }
                    case 39{
                        high := xor(high,0x6e9e40ae71927c029a13d3b1daec32ad3d8951cfe1c9fe9ab806b54cacbbf417)
                        low := xor(low,0x6e9e40ae71927c029a13d3b1daec32ad3d8951cfe1c9fe9ab806b54cacbbf417)
                    }
                    case 40{
                        high := xor(high,0x6e9e40ae71927c029a13d3b1daec32ad3d8951cfe1c9fe9ab806b54cacbbf417)
                        low := xor(low,0x6e9e40ae71927c029a13d3b1daec32ad3d8951cfe1c9fe9ab806b54cacbbf417)
                    }
                    case 41{
                        high := xor(high,0x6e9e40ae71927c029a13d3b1daec32ad3d8951cfe1c9fe9ab806b54cacbbf417)
                        low := xor(low,0x6e9e40ae71927c029a13d3b1daec32ad3d8951cfe1c9fe9ab806b54cacbbf417)
                    }
                    case 42{
                        high := xor(high,0x6e9e40ae71927c029a13d3b1daec32ad3d8951cfe1c9fe9ab806b54cacbbf417)
                        low := xor(low,0x6e9e40ae71927c029a13d3b1daec32ad3d8951cfe1c9fe9ab806b54cacbbf417)
                    }

                    default{
                    //revert(0,0)
                        mstore(0x0200,0x00000000000000000000000000000000000000000000000000000000000003)
                        log1(0x0200,0x20,0x2e36a7093f25f22bd4cbdeb6040174c3ba4c5fe8f1abc04e7c3c48f26c7413e0)
                        return(0x80,0x00)

                    }
                //Injection of Constants
                }

                {//Addition-Rotation-Addition, a.k.a. ARA
                    new_low := byte(0x20, 0x00)
                    new_high := byte(0x20, 0x00)

                //0,1
                    let state_vector_head := byte(0x20, 0x00)
                    let state_vector_head_2 := byte(0x20, 0x00)
                    let state_vector_tail := byte(0x20, 0x00)
                    let state_vector_tail_2 := byte(0x20, 0x00)
                    let output_head := byte(0x20, 0x00)
                    let output_head_2 := byte(0x20, 0x00)
                    let output_tail := byte(0x20, 0x00)

                // output_vector[2*i] = state_vector[2*i] + state_vector[2*i + 1]
                    state_vector_head := high

                    state_vector_head := shr(state_vector_head,0xe0)

                    state_vector_tail := high

                    state_vector_tail := shr(and(state_vector_head,0x00000000ffffffff000000000000000000000000000000000000000000000000),0xC0)

                    state_vector_tail_2 := state_vector_tail

                    output_head := and(add(state_vector_head,state_vector_tail),0x00000000000000000000000000000000000000000000000000000000ffffffff)

                // output_vector[2*i] = output_vector[2*i] <<< 8
                    output_head_2 := output_head

                    output_head := or(
                    and(shl(output_head,8),0x00000000000000000000000000000000000000000000000000000000ffffffff),
                    shr(output_head_2,24)
                    )

                // output_vector[2*i + 1] = state_vector[2*i + 1] <<< 24
                    state_vector_tail := state_vector_tail_2
                    output_tail := or(
                    and(shl(state_vector_tail,24),0x00000000000000000000000000000000000000000000000000000000ffffffff),
                    shr(state_vector_tail_2,8)
                    )

                // output_vector[2*i + 1] = output_vector[2*i + 1] + output_vector[2*i]
                    output_head_2 := output_head
                    output_tail := add(output_tail,output_head_2)

                // save output back to state
                    new_high := or(new_high,shl(output_head,0xE0))
                    new_high := or(new_high,shl(output_tail,0xC0))


                //2,3
                    state_vector_head := byte(0x20, 0x00)
                    state_vector_head_2 := byte(0x20, 0x00)
                    state_vector_tail := byte(0x20, 0x00)
                    state_vector_tail_2 := byte(0x20, 0x00)
                    output_head := byte(0x20, 0x00)
                    output_head_2 := byte(0x20, 0x00)
                    output_tail := byte(0x20, 0x00)

                // output_vector[2*i] = state_vector[2*i] + state_vector[2*i + 1]
                    state_vector_head := high

                    state_vector_head := shr(and(state_vector_head,0x0000000000000000ffffffff0000000000000000000000000000000000000000),0xA0)

                    state_vector_tail := high

                    state_vector_tail := shr(and(state_vector_head,0x000000000000000000000000ffffffff00000000000000000000000000000000),0x80)

                    state_vector_tail_2 := state_vector_tail

                    output_head := and(add(state_vector_head,state_vector_tail),0x00000000000000000000000000000000000000000000000000000000ffffffff)

                // output_vector[2*i] = output_vector[2*i] <<< 8
                    output_head_2 := output_head

                    output_head := or(
                    and(shl(output_head,8),0x00000000000000000000000000000000000000000000000000000000ffffffff),
                    shr(output_head_2,24)
                    )

                // output_vector[2*i + 1] = state_vector[2*i + 1] <<< 24
                    state_vector_tail := state_vector_tail_2
                    output_tail := or(
                    and(shl(state_vector_tail,24),0x00000000000000000000000000000000000000000000000000000000ffffffff),
                    shr(state_vector_tail_2,8)
                    )

                // output_vector[2*i + 1] = output_vector[2*i + 1] + output_vector[2*i]
                    output_head_2 := output_head
                    output_tail := add(output_tail,output_head_2)

                // save output back to state
                    new_high := or(new_high,shl(output_head,0xA0))
                    new_high := or(new_high,shl(output_tail,0x80))

                //4,5
                    state_vector_head := byte(0x20, 0x00)
                    state_vector_head_2 := byte(0x20, 0x00)
                    state_vector_tail := byte(0x20, 0x00)
                    state_vector_tail_2 := byte(0x20, 0x00)
                    output_head := byte(0x20, 0x00)
                    output_head_2 := byte(0x20, 0x00)
                    output_tail := byte(0x20, 0x00)

                // output_vector[2*i] = state_vector[2*i] + state_vector[2*i + 1]
                    state_vector_head := high

                    state_vector_head := shr(and(state_vector_head,0x00000000000000000000000000000000ffffffff000000000000000000000000),0x60)

                    state_vector_tail := high

                    state_vector_tail := shr(and(state_vector_head,0x0000000000000000000000000000000000000000ffffffff0000000000000000),0x40)

                    state_vector_tail_2 := state_vector_tail

                    output_head := and(add(state_vector_head,state_vector_tail),0x00000000000000000000000000000000000000000000000000000000ffffffff)

                // output_vector[2*i] = output_vector[2*i] <<< 8
                    output_head_2 := output_head

                    output_head := or(
                    and(shl(output_head,8),0x00000000000000000000000000000000000000000000000000000000ffffffff),
                    shr(output_head_2,24)
                    )

                // output_vector[2*i + 1] = state_vector[2*i + 1] <<< 24
                    state_vector_tail := state_vector_tail_2
                    output_tail := or(
                    and(shl(state_vector_tail,24),0x00000000000000000000000000000000000000000000000000000000ffffffff),
                    shr(state_vector_tail_2,8)
                    )

                // output_vector[2*i + 1] = output_vector[2*i + 1] + output_vector[2*i]
                    output_head_2 := output_head
                    output_tail := add(output_tail,output_head_2)

                // save output back to state
                    new_high := or(new_high,shl(output_head,0x60))
                    new_high := or(new_high,shl(output_tail,0x40))


                //6,7
                    state_vector_head := byte(0x20, 0x00)
                    state_vector_head_2 := byte(0x20, 0x00)
                    state_vector_tail := byte(0x20, 0x00)
                    state_vector_tail_2 := byte(0x20, 0x00)
                    output_head := byte(0x20, 0x00)
                    output_head_2 := byte(0x20, 0x00)
                    output_tail := byte(0x20, 0x00)

                // output_vector[2*i] = state_vector[2*i] + state_vector[2*i + 1]
                    state_vector_head := high

                    state_vector_head := shr(and(state_vector_head,0x000000000000000000000000000000000000000000000000ffffffff00000000),0x20)

                    state_vector_tail := high

                    state_vector_tail := and(state_vector_head,0x00000000000000000000000000000000000000000000000000000000ffffffff)

                    state_vector_tail_2 := state_vector_tail

                    output_head := and(add(state_vector_head,state_vector_tail),0x00000000000000000000000000000000000000000000000000000000ffffffff)

                // output_vector[2*i] = output_vector[2*i] <<< 8
                    output_head_2 := output_head

                    output_head := or(
                    and(shl(output_head,8),0x00000000000000000000000000000000000000000000000000000000ffffffff),
                    shr(output_head_2,24)
                    )

                // output_vector[2*i + 1] = state_vector[2*i + 1] <<< 24
                    state_vector_tail := state_vector_tail_2
                    output_tail := or(
                    and(shl(state_vector_tail,24),0x00000000000000000000000000000000000000000000000000000000ffffffff),
                    shr(state_vector_tail_2,8)
                    )

                // output_vector[2*i + 1] = output_vector[2*i + 1] + output_vector[2*i]
                    output_head_2 := output_head
                    output_tail := add(output_tail,output_head_2)

                // save output back to state
                    new_high := or(new_high,shl(output_head,0x20))
                    new_high := or(new_high,output_tail)

                //8,9
                    state_vector_head := byte(0x20, 0x00)
                    state_vector_head_2 := byte(0x20, 0x00)
                    state_vector_tail := byte(0x20, 0x00)
                    state_vector_tail_2 := byte(0x20, 0x00)
                    output_head := byte(0x20, 0x00)
                    output_head_2 := byte(0x20, 0x00)
                    output_tail := byte(0x20, 0x00)

                // output_vector[2*i] = state_vector[2*i] + state_vector[2*i + 1]
                    state_vector_head := low

                    state_vector_head := shr(state_vector_head,0xe0)

                    state_vector_tail := low

                    state_vector_tail := shr(and(state_vector_head,0x00000000ffffffff000000000000000000000000000000000000000000000000),0xC0)

                    state_vector_tail_2 := state_vector_tail

                    output_head := and(add(state_vector_head,state_vector_tail),0x00000000000000000000000000000000000000000000000000000000ffffffff)

                // output_vector[2*i] = output_vector[2*i] <<< 8
                    output_head_2 := output_head

                    output_head := or(
                    and(shl(output_head,8),0x00000000000000000000000000000000000000000000000000000000ffffffff),
                    shr(output_head_2,24)
                    )

                // output_vector[2*i + 1] = state_vector[2*i + 1] <<< 24
                    state_vector_tail := state_vector_tail_2
                    output_tail := or(
                    and(shl(state_vector_tail,24),0x00000000000000000000000000000000000000000000000000000000ffffffff),
                    shr(state_vector_tail_2,8)
                    )

                // output_vector[2*i + 1] = output_vector[2*i + 1] + output_vector[2*i]
                    output_head_2 := output_head
                    output_tail := add(output_tail,output_head_2)

                // save output back to state
                    new_low := or(new_low,shl(output_head,0xE0))
                    new_low := or(new_low,shl(output_tail,0xC0))


                //a,b
                    state_vector_head := byte(0x20, 0x00)
                    state_vector_head_2 := byte(0x20, 0x00)
                    state_vector_tail := byte(0x20, 0x00)
                    state_vector_tail_2 := byte(0x20, 0x00)
                    output_head := byte(0x20, 0x00)
                    output_head_2 := byte(0x20, 0x00)
                    output_tail := byte(0x20, 0x00)

                // output_vector[2*i] = state_vector[2*i] + state_vector[2*i + 1]
                    state_vector_head := low

                    state_vector_head := shr(and(state_vector_head,0x0000000000000000ffffffff0000000000000000000000000000000000000000),0xA0)

                    state_vector_tail := low

                    state_vector_tail := shr(and(state_vector_head,0x000000000000000000000000ffffffff00000000000000000000000000000000),0x80)

                    state_vector_tail_2 := state_vector_tail

                    output_head := and(add(state_vector_head,state_vector_tail),0x00000000000000000000000000000000000000000000000000000000ffffffff)

                // output_vector[2*i] = output_vector[2*i] <<< 8
                    output_head_2 := output_head

                    output_head := or(
                    and(shl(output_head,8),0x00000000000000000000000000000000000000000000000000000000ffffffff),
                    shr(output_head_2,24)
                    )

                // output_vector[2*i + 1] = state_vector[2*i + 1] <<< 24
                    state_vector_tail := state_vector_tail_2
                    output_tail := or(
                    and(shl(state_vector_tail,24),0x00000000000000000000000000000000000000000000000000000000ffffffff),
                    shr(state_vector_tail_2,8)
                    )

                // output_vector[2*i + 1] = output_vector[2*i + 1] + output_vector[2*i]
                    output_head_2 := output_head
                    output_tail := add(output_tail,output_head_2)

                // save output back to state
                    new_low := or(new_low,shl(output_head,0xA0))
                    new_low := or(new_low,shl(output_tail,0x80))

                //c,d
                    state_vector_head := byte(0x20, 0x00)
                    state_vector_head_2 := byte(0x20, 0x00)
                    state_vector_tail := byte(0x20, 0x00)
                    state_vector_tail_2 := byte(0x20, 0x00)
                    output_head := byte(0x20, 0x00)
                    output_head_2 := byte(0x20, 0x00)
                    output_tail := byte(0x20, 0x00)

                // output_vector[2*i] = state_vector[2*i] + state_vector[2*i + 1]
                    state_vector_head := low

                    state_vector_head := shr(and(state_vector_head,0x00000000000000000000000000000000ffffffff000000000000000000000000),0x60)

                    state_vector_tail := low

                    state_vector_tail := shr(and(state_vector_head,0x0000000000000000000000000000000000000000ffffffff0000000000000000),0x40)

                    state_vector_tail_2 := state_vector_tail

                    output_head := and(add(state_vector_head,state_vector_tail),0x00000000000000000000000000000000000000000000000000000000ffffffff)

                // output_vector[2*i] = output_vector[2*i] <<< 8
                    output_head_2 := output_head

                    output_head := or(
                    and(shl(output_head,8),0x00000000000000000000000000000000000000000000000000000000ffffffff),
                    shr(output_head_2,24)
                    )

                // output_vector[2*i + 1] = state_vector[2*i + 1] <<< 24
                    state_vector_tail := state_vector_tail_2
                    output_tail := or(
                    and(shl(state_vector_tail,24),0x00000000000000000000000000000000000000000000000000000000ffffffff),
                    shr(state_vector_tail_2,8)
                    )

                // output_vector[2*i + 1] = output_vector[2*i + 1] + output_vector[2*i]
                    output_head_2 := output_head
                    output_tail := add(output_tail,output_head_2)

                // save output back to state
                    new_low := or(new_low,shl(output_head,0x60))
                    new_low := or(new_low,shl(output_tail,0x40))


                //e,f
                    state_vector_head := byte(0x20, 0x00)
                    state_vector_head_2 := byte(0x20, 0x00)
                    state_vector_tail := byte(0x20, 0x00)
                    state_vector_tail_2 := byte(0x20, 0x00)
                    output_head := byte(0x20, 0x00)
                    output_head_2 := byte(0x20, 0x00)
                    output_tail := byte(0x20, 0x00)

                // output_vector[2*i] = state_vector[2*i] + state_vector[2*i + 1]
                    state_vector_head := low

                    state_vector_head := shr(and(state_vector_head,0x000000000000000000000000000000000000000000000000ffffffff00000000),0x20)

                    state_vector_tail := low

                    state_vector_tail := and(state_vector_head,0x00000000000000000000000000000000000000000000000000000000ffffffff)

                    state_vector_tail_2 := state_vector_tail

                    output_head := and(add(state_vector_head,state_vector_tail),0x00000000000000000000000000000000000000000000000000000000ffffffff)

                // output_vector[2*i] = output_vector[2*i] <<< 8
                    output_head_2 := output_head

                    output_head := or(
                    and(shl(output_head,8),0x00000000000000000000000000000000000000000000000000000000ffffffff),
                    shr(output_head_2,24)
                    )

                // output_vector[2*i + 1] = state_vector[2*i + 1] <<< 24
                    state_vector_tail := state_vector_tail_2
                    output_tail := or(
                    and(shl(state_vector_tail,24),0x00000000000000000000000000000000000000000000000000000000ffffffff),
                    shr(state_vector_tail_2,8)
                    )

                // output_vector[2*i + 1] = output_vector[2*i + 1] + output_vector[2*i]
                    output_head_2 := output_head
                    output_tail := add(output_tail,output_head_2)

                // save output back to state
                    new_low := or(new_low,shl(output_head,0x20))
                    new_low := or(new_low,output_tail)

                    high := new_high
                    low := new_low
                }

            // round 43 :)
            }


        //=================================================squeeze===========================================================
            {
            // due to r =256 bit and OUTPUT_LEN = 256 bit, we doesn't need F()
            // thus, just return 'high'
            // the memory is still frozen in 0x80:0xB0 and we just re-use it, saving gas of clean and update

                mstore(0x80,high)

            // print to log
                log1(0x80,0x20,0x858a7ea48900c468bfadb33366d01cd6b1c27bb719aaccda300cbdba515cbec3)

            }
        // assembly
        }


    }
}
