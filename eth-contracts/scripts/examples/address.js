const createKeccakHash = require("keccak");
const ethers = require('ethers')
const { log } = console;


// @notice      fmt eth account address to standard address
// @refer       https://github.com/ethereum/EIPs/blob/master/EIPS/eip-55.md
// @refer       https://docs.ethers.io/v5/api/utils/
// @param       address only includes lowercase letter/ address only includes lowercase letter
// @return      standard eth address mixed uppercase and lowercase
// @dev         `toChecksumAddressOrigin(addr)` === `ethers.utils.getAddress(addr)`
const toChecksumAddress = ethers.utils.getAddress
const toChecksumAddressOrigin = (address) => {
  address = address.toLowerCase().replace("0x", "");
  const hash = createKeccakHash("keccak256").update(address).digest("hex");
  let ret = "0x";

  for (let i = 0; i < address.length; i++) {
    if (parseInt(hash[i], 16) >= 8) {
      ret += address[i].toUpperCase();
    } else {
      ret += address[i];
    }
  }
  return ret;
}

module.exports = {
  toChecksumAddress,
};
