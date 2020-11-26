const ethers = require('ethers');
const {log} = console

const unitsTransform = () => {

    // 1. eth amount -> wei amount
    let wei = ethers.utils.parseEther('4000');
    log(wei.toString())

    // 1. eth amount -> wei amount
    wei = ethers.utils.parseEther('487.2332');
    log(wei.toString())

    // 2. wei amount -> eth amount
    let eth = ethers.utils.formatEther(String(1802952 * 30 * 1e9))
    log(eth)

    eth = ethers.utils.formatEther(String(1e18 * 5))
    log(eth)

    // 3. gwei/gas amount -> wei amount
    wei = ethers.utils.parseUnits(`${1802952}`, 'gwei')
    log(wei.toString())

    // 4. wei amount -> gwei/gas amount
    let gasAmount = ethers.utils.formatUnits(ethers.BigNumber.from(1802952 * 1e9), 'gwei')
    log(gasAmount)
}

unitsTransform()
