pragma solidity ^0.5.10;

import "./CKBChain.sol";

contract NewCKBChain {

    struct HeaderInfo {
        uint64 submitHeight;
        address submitter;
    }
    
    struct TinyHeader {
        uint64  number;
        uint256 difficulty;
        bytes32 blockHash;
        bytes32 transactionsRoot;
        bytes32 parentHash;
    }
    
    struct FullHeader {
        // origin `ckb chain` Header
        bytes headerData;
        
        // ...
    }
        
    // 在以太坊上的 ckb light client, 从 `Pending` 到成为 `Confirmed` 需要等待的 ethereum block 数量
    uint PENDING_WINDOW = 100;

    // ckb light client 中, 当前已经经过 PENDING_WINDOW 个以太坊区块, 同时在 CanonicalChain 上的最高 ckb Header 高度
    // tipConfirmedNumber 以及之前都是 `Confirmed` 区域
    uint tipConfirmedNumber;

    // ckb light client 中, 当前所有区块的最高 ckb Header 高度
    // tipConfirmedNumber + 1 ~ tipNumber 都是 `Pending` 区域
    uint tipNumber;

    // 在 pending 区域, 第一个产生分叉的 ckb Header 高度的前一个高度, firstBranchNumber 这个高度本身没有分叉, firstBranchNumber + 1 有多个分叉区块
    uint firstBranchNumber;

    // 当前数据结构含义完全一致, 需要注意的是 canonicalChain 只代表当前最高难度链, 这其中 blockNumber <= tipConfirmedNumber 是不可回滚的已确认区块
    //  canonicalChain 中  blockNumber > tipConfirmedNumber 的, 是 Pending 区域的主链, 存在被分叉掉的可能
    mapping(uint64 => bytes32) canonicalBlockHashes;
    mapping(bytes32 => bytes32) canonicalTransactionsRoots;
    mapping(uint64 => bytes32[]) allHeaderHashes;
    mapping(bytes32 => TinyHeader) tinyHeaders;
    mapping(bytes32 => FullHeader) fullHeaders;
    mapping(bytes32 => uint256) totalDifficulty;

    // 用于查询区块的 submitter 以及其上链时候的 以太坊区块高度 
    mapping(bytes32 => HeaderInfo) infos;

    // 根据当前以太坊区块高度, 刷新 tipConfirmedNumber, GC 过旧的区块以及无用的分叉
    function refreshTipConfirmedNumber() {
        // 从 tipConfirmedNumber 往后面扫描, 只要 canonicalChain 上的区块的 submitHeight <= block.number - PENDING_WINDOW 就更新 tipConfirmedNumber
        // 同时删除无用的分叉
        // GC 过旧的区块
    }


    function addTinyHeaders() external {
        refreshTipConfirmedNumber();

        // 提交的 headers 必须连续高度的
        // 1. 直接存储在 tinyHeaders 中,  同时存储到 allHeaderHashes
        // 2. 如果当前 CKBChain 没有分叉, 那么直接更新 canonicalBlockHashes, canonicalTransactionsRoots
        // 3. 如果当前 CKBChain 存在分叉, 那么不能被当做 canonicalChain, 但是如果其 parentHash 日后成为了 Confirmed CanonicalChain, 那么这些 tinyHeaders 自动放到 CanonicalChain 里

    }

    function addFullHeaders() external {
        refreshTipConfirmedNumber();

        // 提交的 headers 必须连续高度的
        // 检查区块合法性
        // 1. 计算 FullHeader 的 blake2b hash
        // 2. 计算 eaglesong 对应的 difficulty >= 当前区块的 target difficulty
        // 3. 校验 parentHash 的 number + 1 == FullHeader.number

        //  通过 parentHash 计算出当前 FullHeader 的 totalDifficulty, 存储下来
        //  如果 totalDifficulty 大于当前 canonicalChain 的 totalDifficulty, 那么更新 canonicalChain
    }

}
