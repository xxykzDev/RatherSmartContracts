const { ethers } = require("hardhat");

async function main() {
  const initialSupply = ethers.utils.parseEther("1000000");
  const cap = ethers.utils.parseEther("10000000");
  const initialTokenAmount = 10;
  const MAX_MEMBERS = 1000;
  const daoTokenAmount = ethers.BigNumber.from(initialTokenAmount * MAX_MEMBERS);

  const CustomERC20 = await ethers.getContractFactory("CustomERC20");
  const [deployer] = await ethers.getSigners();
  const deployerAddress = deployer.address;

  const customERC20 = await CustomERC20.deploy(initialSupply, cap, deployerAddress);

  await customERC20.deployed();

  console.log(`CustomERC20 token deployed to ${customERC20.address}`);

  const DAO = await ethers.getContractFactory("DAO");
  const dao = await DAO.deploy(customERC20.address, deployerAddress);

  await dao.deployed();

  console.log(`DAO contract deployed to ${dao.address}`);

  await customERC20.setDao(dao.address);
  await customERC20.setDaoTokenAmount(daoTokenAmount);

  console.log(`DAO address and token amount set in CustomERC20`);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
