// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;
import "./SavePiggy.sol";

contract SavePiggyFactory is Ownable {
    address public developerAddress;
    address[] public list_of_savepiggy;
    
    mapping(address => address[]) public userDeployContract;
    
    event SavePiggyCreated(address indexed owner, address savePiggyAddress);
    event DeveloperAddressUpdated(address oldAddress, address newAddress);
    
    constructor(address _developer) Ownable(msg.sender) {
        require(_developer != address(0), "Invalid developer address");
        developerAddress = _developer;
    }
    
    function createSavePiggy(string memory _savePurpose, uint256 _unlockedTime) external returns (address) {
        require(_unlockedTime > block.timestamp, "Invalid unlocked time");
        
        SavePiggy savepiggy = new SavePiggy(_savePurpose, _unlockedTime, developerAddress);
        
        list_of_savepiggy.push(address(savepiggy));
        userDeployContract[msg.sender].push(address(savepiggy));
        
        // Transfer ownership to the user who created it
        savepiggy.transferOwnership(msg.sender);
        
        emit SavePiggyCreated(msg.sender, address(savepiggy));
        return address(savepiggy);
    }
    
    function updateDeveloperAddress(address _newDeveloper) external onlyOwner {
        require(_newDeveloper != address(0), "Invalid developer address");
        address oldAddress = developerAddress;
        developerAddress = _newDeveloper;
        emit DeveloperAddressUpdated(oldAddress, _newDeveloper);
    }
    
    function getUserDeployedContracts(address user) external view returns (address[] memory) {
        return userDeployContract[user];
    }
    
    function getTotalDeployedContracts() external view returns (uint256) {
        return list_of_savepiggy.length;
    }
}