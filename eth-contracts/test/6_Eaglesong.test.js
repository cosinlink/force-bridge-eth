const { expect } = require("chai");
const { log, waitingForReceipt } = require("./utils");
const vectors = require("./data/testSpv.json");

contract("TestEaglesong", () => {
  let contract;
  let provider;

  before(async function () {
    // disable timeout
    this.timeout(0);
    let factory = await ethers.getContractFactory(
      "contracts/test/TestEaglesong.sol:TestEaglesong"
    );
    contract = await factory.deploy();
    await contract.deployed();
    provider = contract.provider;
  });

  describe("TestEaglesongV2 correct case", async function () {
    // disable timeout
    this.timeout(0);
    it("Should TestEaglesongV2 correct", async () => {
      // calc Eaglesong
      let res = await contract.callStatic.ckbEaglesongV2(
          "0xcbecbaf6a2deee59b2eab3bbae5388128ce9f30183336526c9081419f163fc6076030000312b000000000000216033d2"
      );
      assert(
          res ===
          "0x000000000000053ee598839a89638a5b37a7cf98ecf0ce6d02d3d9287f008b84",
          `${res} !== 0x000000000000053ee598839a89638a5b37a7cf98ecf0ce6d02d3d9287f008b84`
      );


      // calc gas
      res = await contract.ckbEaglesongV2(
          "0xcbecbaf6a2deee59b2eab3bbae5388128ce9f30183336526c9081419f163fc6076030000312b000000000000216033d2"
      );
      const txReceipt = await waitingForReceipt(provider, res);
      console.log("gasUsed: ", txReceipt.gasUsed.toString());
    });
  });

  describe("TestEaglesongV3 test min gas ", async function () {
    // disable timeout
    this.timeout(0);
    it("Should give theoretical minimum for gas", async () => {
      // calc gas
      let res = await contract.ckbEaglesongV3();
      const txReceipt = await waitingForReceipt(provider, res);
      console.log("gasUsed: ", txReceipt.gasUsed.toString());
    });

  });
});
