// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import {Training} from "./Training.sol";

contract Compensationibility is ERC20, Ownable {
    Training private _training;

    constructor() ERC20("Compensationibility", "Compensation") Ownable(msg.sender) {}

    function setTraining(address training) public onlyOwner {
        _training = Training(training);
    }

    modifier onlyTrainingContract() {
        require(msg.sender == address(_training), "Not the training contract");
        _;
    }

    function mint(address to, uint256 amount) public onlyTrainingContract {
        _mint(to, amount);
    }
}
