pragma solidity ^0.6.6;
//import {EaglesongLib} from "../libraries/EaglesongLib.sol";
import {EaglesongLibV2} from "../libraries/EaglesongLibV2.sol";

contract TestEaglesong {
    function ckbEaglesongV2(bytes memory data) public returns(bytes32) {
        return EaglesongLibV2.EaglesongHash(data);
    }

//    function testInjection(uint256 index) public returns(uint32) {
//        return Injections.getInjection(index);
//    }
}
