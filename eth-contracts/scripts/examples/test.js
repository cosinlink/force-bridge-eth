const { toChecksumAddress } = require("./address");
const {log} = console;
const ethers = require('ethers')

const main = async () => {
  log(toChecksumAddress("0x8dd7eb1a1c0dd600a686ae20226db3180b134d47"))
  log(ethers.utils.getAddress("0x8dd7eb1a1c0dd600a686ae20226db3180b134d47"))
  log(ethers.utils.getAddress("0xff560C424C34ACb0e59b2dB1a29463cA8a861eB5"))
};

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
