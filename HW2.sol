// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract Crowdsale is Ownable {
    uint startTime;
    uint endTime;
    uint256 public exrate = 10000; 
    uint256 public hardCap = 0.1 ether; // task2
    uint256 public totalSold; // task2

    address payable public _owner;
    address payable public teamAddress; // task2

    IERC20 public token;

    mapping(address => uint256) public balanceOf;

    constructor(address _token, address _teamAddress) Ownable(msg.sender) {
        _owner = payable(msg.sender);
        teamAddress = payable(_teamAddress); // task2
        token = IERC20(_token);
        startTime = block.timestamp;
        endTime = startTime + 28 days;
        totalSold = 0;
    }

    receive() external payable {
        require(block.timestamp >= startTime && block.timestamp <= endTime);
        require(msg.value <= hardCap); // task2
        uint amount = msg.value * exrate; 
        require(token.balanceOf(address(this)) >= amount);
        token.transfer(msg.sender, amount);
        _owner.transfer(msg.value);
        totalSold += amount; // task2
        balanceOf[msg.sender] += amount;
    }

    function changeCourse(uint256 _newExrate) external onlyOwner {
        exrate = _newExrate;
    }

    function finalize() external onlyOwner {
        require(block.timestamp > endTime);
        uint256 teamT = (totalSold * 10) / 100;  // task2
        require(token.balanceOf(address(this)) >= teamT); // task2
        token.transfer(teamAddress, teamT); // task2
        uint256 remainingTokens = token.balanceOf(address(this));
        if (remainingTokens > 0) {
            token.transfer(_owner, remainingTokens);
        }
    }
}