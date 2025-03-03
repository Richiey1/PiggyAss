// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol"; 

contract SavePiggy is Ownable {
    uint256 public unlockedTime;
    uint256 constant penaltyFee = 15;
    string public savePurpose;
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
    mapping(Token => bool) public hasWithdrawnToken;

    event Saved(address indexed saver, uint256 amount);
    event Withdrawn(address indexed owner, uint256 amount);
    event EmergencyWithdrawn(address indexed owner, uint256 amount, uint256 penaltyAmount);
    event TokenAddressUpdated(Token indexed tokenId, address oldAddress, address newAddress);
    event UnlockedTimeUpdated(uint256 oldTime, uint256 newTime);


    constructor(
        string memory _savePurpose,
        uint256 _unlockedTime,
        address _developerAddress
    ) Ownable(msg.sender) {
        require(_developerAddress != address(0), "Invalid developer address");
        require(_unlockedTime > block.timestamp, "Invalid unlocked time");

        savePurpose = _savePurpose;
        unlockedTime = _unlockedTime;
        developerAddress = _developerAddress;

        tokenDetails[Token.DAI] = TokenDetails(0x6B175474E89094C44Da98b954EedeAC495271d0F, 0);
        tokenDetails[Token.USDC] = TokenDetails(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48, 0);
        tokenDetails[Token.USDT] = TokenDetails(0xdAC17F958D2ee523a2206206994597C13D831ec7, 0);
    }

    modifier isNotWithdrawnToken(Token _tokenId) {
        require(!hasWithdrawnToken[_tokenId], "Token already withdrawn");
        _;
    }

    function save(Token _tokenId, uint256 _amount) external returns (bool) {
        require(tokenDetails[_tokenId].tokenAddress != address(0), "Invalid token");
        require(_amount > 0, "Amount must be greater than 0");

        IERC20(tokenDetails[_tokenId].tokenAddress).transferFrom(msg.sender, address(this), _amount);
        tokenDetails[_tokenId].balance += _amount;

        emit Saved(msg.sender, _amount);
        return true;
    }

    function withdraw(Token _tokenId) external onlyOwner isNotWithdrawnToken(_tokenId) returns (bool) {
        address _tokenAddress = tokenDetails[_tokenId].tokenAddress;
        uint256 _amount = tokenDetails[_tokenId].balance;

        require(block.timestamp >= unlockedTime, "Funds are locked");
        require(_tokenAddress != address(0), "Invalid token");
        require(_amount > 0, "No funds available");

        tokenDetails[_tokenId].balance = 0;
        hasWithdrawnToken[_tokenId] = true; // Mark specific token as withdrawn

        IERC20(_tokenAddress).transfer(msg.sender, _amount);

        emit Withdrawn(msg.sender, _amount);
        return true;
    }

    function emergencyWithdraw(Token _tokenId) external onlyOwner isNotWithdrawnToken(_tokenId) returns (bool) {
        require(block.timestamp < unlockedTime, "Funds are already unlocked");

        address _tokenAddress = tokenDetails[_tokenId].tokenAddress;
        uint256 _amount = tokenDetails[_tokenId].balance;

        require(_tokenAddress != address(0), "Invalid token");
        require(_amount > 0, "No funds available");

        uint256 penaltyAmount = (_amount * penaltyFee) / 100;
        uint256 finalAmount = _amount - penaltyAmount;

        tokenDetails[_tokenId].balance = 0;
        hasWithdrawnToken[_tokenId] = true; // Mark specific token as withdrawn

        IERC20(_tokenAddress).transfer(developerAddress, penaltyAmount);
        IERC20(_tokenAddress).transfer(msg.sender, finalAmount);

        emit EmergencyWithdrawn(msg.sender, finalAmount, penaltyAmount);
        return true;
    }
    function updateTokenAddress(Token _tokenId, address _newAddress) external onlyOwner {
        require(_newAddress != address(0), "Invalid token address");
        address oldAddress = tokenDetails[_tokenId].tokenAddress;
        tokenDetails[_tokenId].tokenAddress = _newAddress;

        emit TokenAddressUpdated(_tokenId, oldAddress, _newAddress);
    }

    function updateUnlockedTime(uint256 _newUnlockedTime) external onlyOwner {
        require(_newUnlockedTime > block.timestamp, "Invalid new unlocked time");
        uint256 oldTime = unlockedTime;
        unlockedTime = _newUnlockedTime;
        emit UnlockedTimeUpdated(oldTime, _newUnlockedTime);
    }

    function getBalance(Token _tokenId) external view returns (uint256) {
        return tokenDetails[_tokenId].balance;
    }
    function getTotalBalance() external view returns (uint256[] memory) {
        uint256[] memory balances = new uint256[](3);
        balances[0] = tokenDetails[Token.DAI].balance;
        balances[1] = tokenDetails[Token.USDC].balance;
        balances[2] = tokenDetails[Token.USDT].balance;
        return balances;
    }
}
