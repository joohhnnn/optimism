// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

interface IFeeGate {
    function register(address signAddress) external;
    function deposit() external payable;
    function withdraw(uint256 amount) external;
}

contract ExampleContract {
    IFeeGate feeGate;
    address private owner;
    uint256 public count;

    constructor(address _feeGateAddress) {
        feeGate = IFeeGate(_feeGateAddress);
        owner = msg.sender;
    }

    // 用于验证函数调用者是否是所有者的修饰器
    modifier onlyOwner() {
        require(msg.sender == owner, "Caller is not the owner");
        _;
    }

    // 注册到 FeeGate 合约
    function registerWithFeeGate(address multisigAddress) public onlyOwner {
        feeGate.register(multisigAddress);
    }

    // 向 FeeGate 存款
    function depositToFeeGate() public payable onlyOwner {
        require(msg.value > 0, "Cannot deposit zero ETH");
        feeGate.deposit{value: msg.value}();
    }

    // 从 FeeGate 提取资金
    function withdrawFromFeeGate(uint256 amount) public onlyOwner {
        feeGate.withdraw(amount);
    }

    // 内部增加函数，演示合约自身的功能
    function increment() public {
        count += 1;
    }


    function gateInteract(bytes calldata signature, bytes calldata data) public onlyOwner returns (bool, bytes memory) {

        // 执行调用并返回结果
        (bool success, bytes memory result) = address(this).call(data);
        return (success, result);
    }
}
