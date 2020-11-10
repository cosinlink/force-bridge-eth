pragma solidity ^0.6.6;
//import {EaglesongLib} from "../libraries/EaglesongLib.sol";
import {EaglesongLibV2} from "../libraries/EaglesongLibV2.sol";
import {EaglesongLibV3} from "../libraries/EaglesongLibV3.sol";

contract TestEaglesong {
    function ckbEaglesongV2(bytes memory data) public returns(bytes32) {
        return EaglesongLibV2.EaglesongHash(data);
    }

    function ckbEaglesongV3() public returns(bytes32) {
        return EaglesongLibV3.EaglesongHash();
    }
}
