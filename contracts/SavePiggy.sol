// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract SavePiggy {
    string public savePurpose;
    uint256 public immutable unlockedTime;
    uint256 public constant penaltyFee = 15;
    address public developerAddress;
    
    struct TokenDetails {
        address tokenAddress;
        uint256 balance; 
    }

    enum Token {
        DAI,
        USDC,
        USDT
    }

    mapping(Token => TokenDetails) public tokenDetails;

    event Saved(address indexed,  uint256 amount);
    event Withdrawn(address indexed,  uint256 amount);
    event EmergencyWithdrawn(address indexed,  uint256 amount, uint256 penaltyAmount);

    constructor(string memory _savePurpose, uint256 _unlockedTime, address _developer) {
        require(_unlockedTime > block.timestamp, "Invalid unlocked time");
        savePurpose = _savePurpose;
        unlockedTime = _unlockedTime;
        developerAddress = _developer;
        
        tokenDetails[Token.DAI] = TokenDetails(0x6B175474E89094C44Da98b954EedeAC495271d0F, 0);
        tokenDetails[Token.USDC] = TokenDetails(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48, 0);
        tokenDetails[Token.USDT] = TokenDetails(0xdAC17F958D2ee523a2206206994597C13D831ec7, 0);
    }

    function save(Token _tokenId, uint256 _amount) external returns (bool) {
        require(tokenDetails[_tokenId].tokenAddress != address(0), "Invalid token");
        require(_amount > 0, "Amount must be greater than 0");

        IERC20(tokenDetails[_tokenId].tokenAddress).transferFrom(msg.sender, address(this), _amount);
        tokenDetails[_tokenId].balance += _amount;
        
        return true;
    }

    function withdraw(Token _tokenId) external returns (bool) {
        address _tokenAddress = tokenDetails[_tokenId].tokenAddress;
        uint256 _amount = tokenDetails[_tokenId].balance;
        require(block.timestamp >= unlockedTime, "Funds are locked");
        require(_tokenAddress != address(0), "Invalid token");
        require(_amount > 0, "Insufficient balance");

        tokenDetails[_tokenId].balance = 0;

        IERC20(_tokenAddress).transfer(msg.sender, _amount);

        return true;
    }

    function emergencyWithdraw(Token _tokenId) external returns (bool) {
        require(block.timestamp < unlockedTime, "Funds are already unlocked");

        address _tokenAddress = tokenDetails[_tokenId].tokenAddress;
        uint256 _amount = tokenDetails[_tokenId].balance;

        require(_tokenAddress != address(0), "Invalid token");
        require(_amount > 0, "Insufficient balance");

        uint256 penaltyAmount = (_amount * penaltyFee) / 100;
        uint256 finalAmount = _amount - penaltyAmount;

        tokenDetails[_tokenId].balance = 0;

        IERC20(_tokenAddress).transfer(developerAddress, penaltyAmount);
        IERC20(_tokenAddress).transfer(msg.sender, finalAmount);

        return true;
    }

    function getBalance(Token _tokenId) external view returns (uint256) {
        return tokenDetails[_tokenId].balance;
    }
}
