
async function main() {
    // get abi, bytecode, provider
    const hreFactory = await ethers.getContractFactory("contracts/test/TestGcGas.sol:TestGcGas");
    let provider = await ethers.getDefaultProvider(process.env.ROPSTEN_API);
    let wallet = new ethers.Wallet(process.env.ROPSTEN_DEPLOYER_PRIVATE_KEY, provider)

    let factory = new ethers.ContractFactory(hreFactory.interface, hreFactory.bytecode, wallet)
    const contract = await factory.deploy();
    await contract.deployed();
    const contractAddr = contract.address;
    console.log("contract deployed to:", contractAddr);

}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
    .then(() => process.exit(0))
    .catch(error => {
        console.error(error);
        process.exit(1);
    });
