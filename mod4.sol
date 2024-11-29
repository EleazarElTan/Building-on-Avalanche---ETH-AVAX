// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts@4.9.0/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts@4.9.0/access/Ownable.sol";
import "@openzeppelin/contracts@4.9.0/token/ERC20/extensions/ERC20Burnable.sol";

contract DegenToken is ERC20, ERC20Burnable, Ownable {
    constructor() ERC20("Degen", "DGN") {}
    
    struct Game {
    string name;
    uint256 price;
    }

    mapping(uint256 => Game) public Games;
    uint256 public nextGameId;

    mapping(address => mapping(uint256 => uint256)) public userInventory; // User's inventory

    event GameAdded(uint256 GameId, string name, uint256 price);
    event GamePurchased(address indexed buyer, uint256 GameId, string name, uint256 price);

    function mint(uint256 amount) public onlyOwner {
        _mint(msg.sender, amount);
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        return super.transfer(recipient, amount);
    }

    function burn(uint256 amount) public override {
        super.burn(amount);
    }

    function addGame(string memory _name, uint256 _price) external onlyOwner {
        Games[nextGameId] = Game(_name, _price);
        emit GameAdded(nextGameId, _name, _price);
        nextGameId++;
    }

    function buyGame(uint256 _GameId) external {
        require(_GameId < nextGameId, "Invalid drink ID");
        Game storage game = Games[_GameId];
        require(balanceOf(msg.sender) >= game.price, "Not enough Degen Tokens");

        transfer(owner(), game.price);
        userInventory[msg.sender][_GameId]++;

        emit GamePurchased(msg.sender, _GameId, game.name, game.price);
        burn(game.price);
    }
}