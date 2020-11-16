const ethers = require('ethers');
const {log} = console
const unitsTransform = () => {

    // 1.5ETH -> 1.5 * 1e18 wei
    let wei = ethers.utils.parseEther('1.5');
    log(wei.toString())

    let eth = ethers.utils.formatEther(String(1802952 * 30 * 1e9))
    log(eth)

    eth = ethers.utils.formatEther(String(1e18 * 5))
    log(eth)
}
