// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

import { ISemver } from "src/universal/ISemver.sol";

/// @custom:proxied
/// @custom:predeploy 0x4200000000000000000000000000000000000019
/// @title FeeGate
/// @notice The FeeGate control the funding of Gas-Free-Transaction
contract FeeGate is ISemver {
    /// @notice Semantic version.
    /// @custom:semver 0.0.1-beta.1
    string public constant version = "0.0.1-beta.1";

    address internal constant DEPOSITOR_ACCOUNT = 0xDeaDDEaDDeAdDeAdDEAdDEaddeAddEAdDEAd0001;
    mapping(address => uint256) public deposits;  // 存储各合约地址的存款金额
    mapping(address => address) public registeredContracts; // 记录已注册合约的多签地址

    // 修饰器确保只有系统地址可以调用
    modifier onlySystem() {
        require(tx.origin == DEPOSITOR_ACCOUNT, "Unauthorized: caller is not the system");
        _;
    }

    function register(address signAddress) external {
        require(isContract(msg.sender), "Only contracts can register");
        require(signAddress != address(0), "Invalid address");
        require(registeredContracts[msg.sender] == address(0), "Contract already registered");

        registeredContracts[msg.sender] = signAddress;
    }

    function deposit() external payable {
        require(msg.value > 0, "Cannot deposit zero ETH");
        require(isContract(msg.sender), "Deposit must be made by a contract");

        deposits[msg.sender] += msg.value;
    }

    function withdraw(uint256 amount) external {
        require(deposits[msg.sender] >= amount, "Insufficient funds");
        deposits[msg.sender] -= amount;
        payable(msg.sender).transfer(amount);
    }

    function spend(address contractAddress, uint256 amount) public onlySystem {
        require(deposits[contractAddress] >= amount, "Insufficient funds to spend");
        deposits[contractAddress] -= amount;
    }

    function multicall(address[] calldata contractAddresses, uint256[] calldata amounts) external onlySystem {
        require(contractAddresses.length == amounts.length, "Mismatch between addresses and amounts");
        for (uint i = 0; i < contractAddresses.length; i++) {
            spend(contractAddresses[i], amounts[i]);
        }
    }

    function isContract(address addr) internal view returns (bool) {
        return addr.code.length > 0;
    }

    function check(address addr) public view returns (address, uint256) {
        uint256 gaslimit = deposits[addr] / tx.gasprice;
        return (registeredContracts[addr], gaslimit);
    }
}