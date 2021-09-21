pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract WETH is ERC20, ReentrancyGuard {
    using SafeMath for uint256;

    uint256 private constant FEE = 1; // 0.01%
    uint256 private constant PERCENT = 10000; // 100%
    uint256 private totalFeeAmount;

    constructor() public ERC20("Wrapped Ether", "WETH") {}

    function mint() public payable nonReentrant {
        uint256 amount = msg.value;

        uint256 feeAmount = amount.mul(FEE).div(PERCENT);
        uint256 amountToMint = amount.sub(feeAmount);
        totalFeeAmount = totalFeeAmount.add(feeAmount);

        _mint(msg.sender, amountToMint);
    }

    function burn(uint256 amount) external nonReentrant {
        _burn(msg.sender, amount);
        (bool success, ) = msg.sender.call{value: amount}("");
        require(success);
    }

    function getReward() external payable nonReentrant {
        require(
            totalFeeAmount > 0 && balanceOf(msg.sender) > 0,
            "Cannot withdraw 0"
        );

        uint256 amountToReturn = totalFeeAmount.mul(balanceOf(msg.sender)).div(
            totalSupply()
        );
        totalFeeAmount = totalFeeAmount.sub(amountToReturn);
        (bool success, ) = msg.sender.call{value: amountToReturn}("");
        require(success);
    }

    fallback() external payable {
        mint();
    }
}
