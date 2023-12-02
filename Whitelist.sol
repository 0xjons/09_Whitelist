// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract Whitelist is Ownable, ReentrancyGuard {
    IERC20 public token;
    uint256 public minimumBalance;
    mapping(address => bool) public whitelist;
    mapping(address => bool) private banned;
    bool public isWhitelistActive = true;

    event AddedToWhitelist(address indexed user);
    event RemovedFromWhitelist(address indexed user);
    event BannedFromWhitelist(address indexed user);
    event WhitelistStatusChanged(bool status);
    event MinimumBalanceUpdated(uint256 newMinimumBalance); // Evento para actualizar el saldo mínimo

    modifier onlyWhenWhitelistActive() {
        require(isWhitelistActive, "Whitelist is not active");
        _;
    }

    modifier notBanned() {
        require(!banned[msg.sender], "Sender is banned from the whitelist");
        _;
    }

    constructor(address _token, uint256 _minimumBalance) Ownable(msg.sender) {
        token = IERC20(_token);
        minimumBalance = _minimumBalance; // 10000 * (10**18);  Asumiendo 18 decimales / 10000000000000000000000
    }

    function addToWhitelist(address[] calldata users) external onlyOwner {
        uint256 length = users.length;
        for (uint256 i = 0; i < length; i++) {
            whitelist[users[i]] = true;
            emit AddedToWhitelist(users[i]);
        }
    }

    function removeFromWhitelist(address user) external onlyOwner {
        whitelist[user] = false;
        emit RemovedFromWhitelist(user);
    }

    function banFromWhitelist(address user) external onlyOwner {
        banned[user] = true;
        whitelist[user] = false;
        emit BannedFromWhitelist(user);
    }

    function toggleWhitelistStatus() external onlyOwner {
        isWhitelistActive = !isWhitelistActive;
        emit WhitelistStatusChanged(isWhitelistActive);
    }

    function selfAddToWhitelist()
        external
        payable
        onlyWhenWhitelistActive
        notBanned
        nonReentrant
    {
        require(msg.value == 0.01 ether, "Incorrect fee");
        require(
            token.balanceOf(msg.sender) >= minimumBalance,
            "Insufficient token balance"
        );
        whitelist[msg.sender] = true;
        emit AddedToWhitelist(msg.sender);
    }

    function selfRemoveFromWhitelis() external {
        require(whitelist[msg.sender], "You are not on the whitelist");
        whitelist[msg.sender] = false;
        emit RemovedFromWhitelist(msg.sender);
    }

    function setMinimumBalance(uint256 _newMinimumBalance) external onlyOwner {
        minimumBalance = _newMinimumBalance;
        emit MinimumBalanceUpdated(_newMinimumBalance);
    }

    function isUserBanned(address user) external view returns (bool) {
        return banned[user];
    }

    function isUserWhitelisted(address user) external view returns (bool) {
        return whitelist[user] && !banned[user];
    }

    function withdraw(address payable recipient)
        external
        onlyOwner
        nonReentrant
    {
        uint256 balance = address(this).balance;
        require(balance > 0, "No funds available");
        recipient.transfer(balance);
    }
}
