// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC1155/utils/ERC1155Holder.sol";
import "./OZTestGear.sol";

/**
 * @title OZTestCharacter
 * @dev A minimal ERC721 implementation for testing character-gear interactions
 */
contract OZTestCharacter is Ownable, ERC721, ERC1155Holder {
    OZTestGear public gearContract;

    uint public totalSupply = 0;

    // Mapping to track equipped gear for each character
    mapping(uint256 => uint256[]) public equippedGear;

    constructor(string memory name_, string memory symbol_, address gearAddress_) 
        ERC721(name_, symbol_) 
        Ownable()
    {
        gearContract = OZTestGear(gearAddress_);
    }

    /**
     * @dev Mint a new character
     * @param to The address to mint the character to
     * @return The ID of the newly minted character
     */
    function mint(address to) external onlyOwner returns (uint256) {
        uint256 tokenId = ++totalSupply;
        _mint(to, tokenId);
        return tokenId;
    }
    
    /**
     * @dev Get all equipped gear for a character
     * @param characterId The ID of the character
     * @return Array of equipped gear token IDs
     */
    function getEquippedGear(uint256 characterId) external view returns (uint256[] memory) {
        return equippedGear[characterId];
    }
    
    /**
     * @dev Equip gear to a character
     * @param characterId The ID of the character
     * @param gearId The ID of the gear to equip
     */
    function equipGear(uint256 characterId, uint256 gearId) external {
        // Check that the sender owns the character
        require(_isApprovedOrOwner(msg.sender, characterId), "Not character owner");
        
        // Check that the sender owns the gear
        require(gearContract.balanceOf(msg.sender, gearId) > 0, "Not gear owner");
        
        // Transfer the gear from the owner to this contract
        gearContract.safeTransferFrom(msg.sender, address(this), gearId, 1, "");
        
        // Add the gear to the character's equipped gear
        equippedGear[characterId].push(gearId);
    }
    
    /**
     * @dev Unequip gear from a character
     * @param characterId The ID of the character
     * @param gearId The ID of the gear to unequip
     */
    function unequipGear(uint256 characterId, uint256 gearId) external {
        // Check that the sender owns the character
        require(_isApprovedOrOwner(msg.sender, characterId), "Not character owner");
        
        uint256[] storage gearIds = equippedGear[characterId];
        bool found = false;
        uint256 index;
        
        // Find the gear in the equipped array
        for (uint256 i = 0; i < gearIds.length; i++) {
            if (gearIds[i] == gearId) {
                found = true;
                index = i;
                break;
            }
        }
        
        require(found, "Gear not equipped");
        
        // Remove the gear from the equipped array by replacing it with the last item and reducing length
        gearIds[index] = gearIds[gearIds.length - 1];
        gearIds.pop();
        
        // Transfer the gear back to the character owner
        gearContract.safeTransferFrom(address(this), msg.sender, gearId, 1, "");
    }
    
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC721, ERC1155Receiver) returns (bool) {
        return super.supportsInterface(interfaceId);
    }
}