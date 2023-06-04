const { expect } = require('chai');
const { ethers } = require('hardhat');

describe('HolidayToken', function () {
  let HolidayToken, holidayToken, admin, addr1, addr2;

  beforeEach(async () => {
    HolidayToken = await ethers.getContractFactory('HolidayToken');
    [admin, addr1, addr2, _] = await ethers.getSigners();
    holidayToken = await HolidayToken.deploy();
    await holidayToken.deployed();
    await holidayToken.initialize(); // Initialize the contract
  });

  describe('Deployment', function () {
    it('Should set the right roles to the admin', async function () {
      expect(await holidayToken.hasRole(await holidayToken.MINTER_ROLE(), admin.address)).to.equal(true);
      expect(await holidayToken.hasRole(await holidayToken.PAUSER_ROLE(), admin.address)).to.equal(true);
    });

    it('Should assign the total supply of tokens to the admin', async function () {
      const adminBalance = await holidayToken.balanceOf(admin.address);
      expect(await holidayToken.totalSupply()).to.equal(adminBalance);
    });
  });

  describe('Transactions', function () {
    it('Should transfer tokens between accounts', async function () {
      await holidayToken.transfer(addr1.address, 50);
      const addr1Balance = await holidayToken.balanceOf(addr1.address);
      expect(addr1Balance).to.equal(50);

      await holidayToken.connect(addr1).transfer(addr2.address, 50);
      const addr2Balance = await holidayToken.balanceOf(addr2.address);
      expect(addr2Balance).to.equal(50);
    });

    it('Should fail if sender does not have enough tokens', async function () {
      await expect(
        holidayToken.connect(addr1).transfer(admin.address, 1)
      ).to.be.revertedWith('ERC20: transfer amount exceeds balance');
    });
  });

  describe('Blacklist', function() {
    it('Should blacklist and unblacklist an address', async function() {
      await holidayToken.blacklist(addr1.address);
      expect(await holidayToken.isBlacklisted(addr1.address)).to.equal(true);

      await holidayToken.unBlacklist(addr1.address);
      expect(await holidayToken.isBlacklisted(addr1.address)).to.equal(false);
    });
  });

  describe('Pausing', function() {
    it('Should pause and unpause the contract', async function() {
      await holidayToken.pause();
      await expect(holidayToken.transfer(addr1.address, 50)).to.be.revertedWith('Pausable: paused');

      await holidayToken.unpause();
      await holidayToken.transfer(addr1.address, 50);
      const addr1Balance = await holidayToken.balanceOf(addr1.address);
      expect(addr1Balance).to.equal(50);
    });
  });
});
