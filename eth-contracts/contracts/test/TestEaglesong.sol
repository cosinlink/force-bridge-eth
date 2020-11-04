pragma solidity ^0.5.10;
import {EaglesongLib} from "../libraries/EaglesongLib.sol";

contract TestEaglesong {
    function ckbEaglesong(bytes memory data) public returns(bytes32) {
        return EaglesongLib.EaglesongHash(data);
    }
}