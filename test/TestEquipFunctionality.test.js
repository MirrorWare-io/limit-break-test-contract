const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("LimitBreak Character Gear Equip Test", function () {
	let testGear;
	let testCharacter;
	let owner;
	let user;
	const BASE_URI = "https://example.com/gear/";

	beforeEach(async function () {
		[owner, user] = await ethers.getSigners();

		// Deploy the TestGear contract
		const TestGear = await ethers.getContractFactory("TestGear");
		testGear = await TestGear.deploy(BASE_URI);
		await testGear.waitForDeployment(); // Wait for deployment in ethers v6

		// Get the gear contract address
		const gearAddress = await testGear.getAddress(); // Use getAddress() in ethers v6

		// Deploy the TestCharacter contract
		const TestCharacter = await ethers.getContractFactory("TestCharacter");
		testCharacter = await TestCharacter.deploy("TestCharacter", "TCHAR", gearAddress);
		await testCharacter.waitForDeployment(); // Wait for deployment in ethers v6

		// Get the character contract address
		const characterAddress = await testCharacter.getAddress(); // Use getAddress() in ethers v6

		// Set the character contract in the gear contract
		await testGear.setCharacterContract(characterAddress);

		// Mint a character to the user
		await testCharacter.mint(user.address);

		// Mint some gear to the user
		await testGear.mint(user.address, 1, 1); // Gear ID 1
		await testGear.mint(user.address, 2, 1); // Gear ID 2
	});

	it("Should equip gear to a character", async function () {
		// User equips gear ID 1 to their character
		await testCharacter.connect(user).equipGear(1, 1);

		// Check that the gear is now equipped
		const equippedGear = await testCharacter.getEquippedGear(1);
		expect(equippedGear.length).to.equal(1);
		expect(equippedGear[0]).to.equal(1n); // Use BigInt notation in ethers v6

		// Verify the gear is now owned by the character contract
		const characterAddress = await testCharacter.getAddress();
		const gearBalance = await testGear.balanceOf(characterAddress, 1);
		expect(gearBalance).to.equal(1n); // Use BigInt notation in ethers v6
	});

	it("Should unequip gear from a character", async function () {
		// User equips gear ID 1 to their character
		await testCharacter.connect(user).equipGear(1, 1);

		// User unequips the gear
		await testCharacter.connect(user).unequipGear(1, 1);

		// Check that the gear is no longer equipped
		const equippedGear = await testCharacter.getEquippedGear(1);
		expect(equippedGear.length).to.equal(0);

		// Verify the gear is returned to the user
		const gearBalance = await testGear.balanceOf(user.address, 1);
		expect(gearBalance).to.equal(1n); // Use BigInt notation in ethers v6
	});

	it("Should handle multiple gear items", async function () {
		// User equips gear ID 1 and 2 to their character
		await testCharacter.connect(user).equipGear(1, 1);
		await testCharacter.connect(user).equipGear(1, 2);

		// Check that both gear items are equipped
		const equippedGear = await testCharacter.getEquippedGear(1);
		expect(equippedGear.length).to.equal(2);
		expect(equippedGear[0]).to.equal(1n); // Use BigInt notation in ethers v6
		expect(equippedGear[1]).to.equal(2n); // Use BigInt notation in ethers v6

		// Unequip gear ID 1
		await testCharacter.connect(user).unequipGear(1, 1);

		// Check that only gear ID 2 remains equipped
		const remainingGear = await testCharacter.getEquippedGear(1);
		expect(remainingGear.length).to.equal(1);
		expect(remainingGear[0]).to.equal(2n); // Use BigInt notation in ethers v6
	});

	it("Should prevent unauthorized equip/unequip operations", async function () {
		// Mint a character for owner
		await testCharacter.mint(owner.address);

		// Owner should not be able to equip gear to user's character
		await expect(testCharacter.connect(owner).equipGear(1, 2)).to.be.revertedWith("Not character owner");

		// First equip gear to user's character
		await testCharacter.connect(user).equipGear(1, 1);

		// Owner should not be able to unequip gear from user's character
		await expect(testCharacter.connect(owner).unequipGear(1, 1)).to.be.revertedWith("Not character owner");
	});
});
