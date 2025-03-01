// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import "./SavePiggy.sol";
contract SavePiggyFactory {
    address public developerAddress;
    address[] public list_of_savepiggy;

    mapping(address => address[]) public userDeployContract;
   
    constructor(address _developer) {
        developerAddress = _developer;
    }
    function createSavePiggy(string memory _savePurpose, uint256 _unlockedTime) external returns (address) {
        SavePiggy savepiggy = new SavePiggy(_savePurpose, _unlockedTime, developerAddress);

        list_of_savepiggy.push(address(savepiggy));
        userDeployContract[msg.sender].push(address(savepiggy));
        
        return address(savepiggy);
    }
    function getUserDeployedContracts(address user) external view returns (address[] memory) {
    return userDeployContract[user];
}


}