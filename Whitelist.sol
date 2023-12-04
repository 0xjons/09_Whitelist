// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract Whitelist is Ownable, ReentrancyGuard {
    IERC20 public token;
    uint8 public maxWhitelistedUsers;
    uint8 public numberOfUsers;
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

    constructor(
        address _token,
        uint8 _maxWhitelisted,
        uint256 _minimumBalance
    ) Ownable(msg.sender) {
        token = IERC20(_token);
        maxWhitelistedUsers = _maxWhitelisted;
        minimumBalance = _minimumBalance; // 10000 * (10**18);  Asumiendo 18 decimales / 10000000000000000000000
    }

    function addToWhitelist(address[] calldata users) external onlyOwner {
        require(
            numberOfUsers + users.length <= maxWhitelistedUsers,
            "Maximum number of users reached"
        );
        uint256 length = users.length;
        for (uint256 i = 0; i < length; i++) {
            require(!whitelist[users[i]], "Address already whitelisted"); // Verifica si la dirección ya está en la whitelist
            whitelist[users[i]] = true;
            numberOfUsers += 1;
            emit AddedToWhitelist(users[i]);
        }
    }

    function removeFromWhitelist(address[] calldata users) external onlyOwner {
        uint256 length = users.length;
        for (uint256 i = 0; i < length; i++) {
            whitelist[users[i]] = false;
            numberOfUsers -= 1;
            emit RemovedFromWhitelist(users[i]);
        }
    }

    function banFromWhitelist(address[] calldata users) external onlyOwner {
        uint256 length = users.length;
        for (uint256 i = 0; i < length; i++) {
            banned[users[i]] = true;
            whitelist[users[i]] = false;
            numberOfUsers -= 1;
            emit BannedFromWhitelist(users[i]);
        }
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
        numberOfUsers += 1;
        emit AddedToWhitelist(msg.sender);
    }

    function selfRemoveFromWhitelis() external {
        require(whitelist[msg.sender], "You are not on the whitelist");
        whitelist[msg.sender] = false;
        numberOfUsers -= 1;
        emit RemovedFromWhitelist(msg.sender);
    }

    function getMaxWhitelistedUsers() external view returns (uint256) {
        return maxWhitelistedUsers;
    }

    function getTotalWhitelistedUsers() external view returns (uint256) {
        return numberOfUsers;
    }

    function isUserBanned(address user) external view returns (bool) {
        return banned[user];
    }

    function isUserWhitelisted(address user) external view returns (bool) {
        return whitelist[user] && !banned[user];
    }

    function setMinimumBalance(uint256 _newMinimumBalance) external onlyOwner {
        minimumBalance = _newMinimumBalance;
        emit MinimumBalanceUpdated(_newMinimumBalance);
    }

    function setMaxWhitelistedUsers(uint8 _maxWhitelisted) external onlyOwner {
        maxWhitelistedUsers = _maxWhitelisted;
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

    receive() external payable{}
}
