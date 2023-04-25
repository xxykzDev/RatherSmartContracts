// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Capped.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";

contract CustomERC20 is ERC20Capped, ERC20Burnable {
    address public dao;
    uint256 public daoTokenAmount;

    uint8 private _customDecimals;

    constructor(uint256 initialSupply, uint256 cap, address initialOwner)
        ERC20("CustomToken", "CTK")
        ERC20Capped(cap)
    {
        _mint(initialOwner, initialSupply);
        _customDecimals = 18;
    }

    modifier onlyTokenOwner() {
    require(msg.sender != dao, "Only the token owner can call this function");
    _;
    }

    function decimals() public view virtual override returns (uint8) {
        return _customDecimals;
    }

    function _mint(address account, uint256 amount) internal virtual override(ERC20, ERC20Capped) {
        super._mint(account, amount);
    }

    function setDao(address _dao) public {
        require(dao == address(0), "DAO address is already set");
        dao = _dao;
    }

    function setDaoTokenAmount(uint256 _daoTokenAmount) public {
        require(daoTokenAmount == 0, "DAO token amount is already set");
        daoTokenAmount = _daoTokenAmount;
    }

    function mintTo(address to, uint256 amount) public {
        require(msg.sender == dao, "Only the DAO contract can mint tokens");
        _mint(to, amount);
    }

    function internalApprove(address owner, address spender, uint256 value) public {
    require(msg.sender == dao, "Only the DAO contract can call this function");
    _approve(owner, spender, value);
    }
}
