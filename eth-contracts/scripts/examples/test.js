const { toChecksumAddress } = require("./address");
const {log} = console;
const ethers = require('ethers')

const main = async () => {
  log(toChecksumAddress("0xc2f2d954bb6296b923bc938c32c4c30a8e39015f"))
  log(ethers.utils.getAddress("0xc2f2d954bb6296b923bc938c32c4c30a8e39015f"))
};

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
