// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

/**
 * @title OZTestGear
 * @dev A minimal ERC1155 implementation for testing character-gear interactions
 */
contract OZTestGear is ERC1155, Ownable {
    using Strings for uint256;
    
    string public baseURI;
    address public characterContract;
    
    constructor(string memory _baseURI) 
        ERC1155(_baseURI)
        Ownable()
    {
        baseURI = _baseURI;
    }
    
    /**
     * @dev Set the character contract address
     * @param _characterContract The address of the character contract
     */
    function setCharacterContract(address _characterContract) external onlyOwner {
        characterContract = _characterContract;
    }
    
    /**
     * @dev Mint new gear tokens
     * @param to The address to mint the tokens to
     * @param id The gear ID to mint
     * @param amount The amount of tokens to mint
     */
    function mint(address to, uint256 id, uint256 amount) external onlyOwner {
        _mint(to, id, amount, "");
    }
    
    /**
     * @dev Override isApprovedForAll to auto-approve the character contract
     * @param account The token owner
     * @param operator The operator address
     * @return bool Whether the operator is approved
     */
    function isApprovedForAll(address account, address operator) public view virtual override returns (bool) {
        // Always approve the character contract to transfer tokens
        if (operator == characterContract) {
            return true;
        }
        return super.isApprovedForAll(account, operator);
    }
    
    /**
     * @dev Get the token URI
     * @param tokenId The token ID
     * @return string The token URI
     */
    function uri(uint256 tokenId) public view virtual override returns (string memory) {
        return string(abi.encodePacked(baseURI, tokenId.toString()));
    }
}