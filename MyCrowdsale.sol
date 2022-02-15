// SPDX-License-Identifier: MIT OR Apache-2.0
pragma solidity ^0.8.0;

import "./Crowdsale.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v4.5.0-rc.0/contracts/token/ERC20/IERC20.sol";
import "./SafeMath.sol";

contract MyCrowdsale is Crowdsale {
    using SafeMath for uint256;

    uint public phase = 1;
    uint public preSaleQty = 30000000*10**9;
    uint public seedSaleQty = 50000000*10**9;
    uint public finalSaleQty = 100000000*10**9 - (preSaleQty + seedSaleQty);
    uint public tokensSold = 0;
    uint public tokensLeft = 100000000*10**9;
    uint private DENOMINATOR = 10**5;

    constructor(address payable wallet,IERC20 token) Crowdsale(wallet, token) public {}
    
    function _preValidatePurchase(address _beneficiary, uint256 _weiAmount) pure internal override {
        require(_beneficiary != address(0));
        require(_weiAmount >= 10**4,"Amount of wei entered should be greater than or equals to 10**4");
    }

    function _getTokenAmount(uint256 _weiAmount) internal override view returns (uint256) {
        return _weiAmount.mul(getRate()) / DENOMINATOR;
    }

    function getRate() private view returns(uint) {
        if(phase == 1) {
            return 28;
        }else if(phase == 2) {
            return 14;
        }else {
            return 7;
        }
    }

    function _processPurchase(address _beneficiary, uint256 _tokenAmount) internal override {
        uint tokens = tokensSold + _tokenAmount;
        require(phase == 1 && tokens <= preSaleQty || phase == 2 && tokens <= preSaleQty + seedSaleQty || phase == 3 && tokens <= 100000000*10**9);
        

        _deliverTokens(_beneficiary, _tokenAmount);

        tokensSold += _tokenAmount;
        tokensLeft -= _tokenAmount;

        if(phase == 1 && preSaleQty - tokensSold == 0){
            phase++;
        }else if(phase == 2 && (preSaleQty + seedSaleQty) - tokensSold == 0){
            phase++;
        }
    }
}