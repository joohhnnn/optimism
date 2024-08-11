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

    modifier onlyOwner() {
        require(msg.sender == owner, "Caller is not the owner");
        _;
    }

    function registerWithFeeGate(address multisigAddress) public onlyOwner {
        feeGate.register(multisigAddress);
    }

    function depositToFeeGate() public payable onlyOwner {
        require(msg.value > 0, "Cannot deposit zero ETH");
        feeGate.deposit{value: msg.value}();
    }

    function withdrawFromFeeGate(uint256 amount) public onlyOwner {
        feeGate.withdraw(amount);
    }

    function increment() public {
        count += 1;
    }


    function gateInteract(bytes calldata signature, bytes calldata data) public onlyOwner returns (bool, bytes memory) {

        (bool success, bytes memory result) = address(this).call(data);
        return (success, result);
    }
}
