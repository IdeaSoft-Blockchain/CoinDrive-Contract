pragma solidity ^0.4.11;

import './StandardToken.sol';
import './Ownable.sol';

contract CDR is StandardToken, Ownable {

  string public name = "DriveCoin";
  string public symbol = "CDR";
  uint public decimals = 18;

  using SafeMath for uint256;

  /**
  timestamps for steps in sale bonuses
   */
  uint public startFirst;
  uint public endFirst;
  uint public starSecond;
  uint public endSecond;

  /**
  walled for collecting funds
   */
  address public wallet;

  /**
  token currency
   */
  uint256 public currency;

  /**
  minimum transacion amount
   */
  uint256 public minTransactionAmount;

  uint256 public raisedForEther = 0;


  modifier inActivePeriod() {
      require((startFirst < now && now <= endFirst) || (starSecond < now && now <= endSecond));
      _;
  }

  function CDR(address _wallet, uint _startF, uint _endF, uint _startS, uint _endS) {
      require(_wallet != 0x0);
      require(_startF < _endF);
      require(_startS < _endS);

      /**
      wallet accumulation
       */
      wallet = _wallet;

      /**
      1 ETH = 242 DriveCoin ~ 1USD
       */
      currency = 242;

      /**
       minimal invest amount
       */
      minTransactionAmount = 0.01 ether;

      startFirst = _startF;
      endFirst = _endF;
      starSecond = _startS;
      endSecond = _endS;

  }

  function setupPeriodForFirst(uint _start, uint _end) onlyOwner {
      require(_start < _end);
      startFirst = _start;
      endFirst = _end;
  }

  function setupPeriodForSecond(uint _start, uint _end) onlyOwner {
      require(_start < _end);
      starSecond = _start;
      endSecond = _end;
  }

  /**
  fallback function for buing tokens
  */
  function () inActivePeriod payable {
      buyTokens(msg.sender);
  }

  /**
  basic level token purchase function
  */
  function buyTokens(address _sender) inActivePeriod payable {
      require(_sender != 0x0);
      require(msg.value >= minTransactionAmount);

      uint256 weiAmount = msg.value;

      raisedForEther = raisedForEther.add(weiAmount);

      // calculate token amount
      uint256 tokens = weiAmount.mul(currency);
      tokens += getBonus(tokens);
      tokens += getBonusamount(tokens);

      tokenReserve(_sender, tokens);

      forwardFunds();
  }

  /**
  send ether to the fund collection wallet
  override to create custom fund forwarding mechanisms
  */
  function forwardFunds() internal {
      wallet.transfer(msg.value);
  }

  /**
  time steps bonuses mechanism
  */
  function getBonus(uint256 _tokens) constant returns (uint256 bonus) {
      require(_tokens != 0);
      if (1 == getCurrentPeriod()) {
          if (startFirst <= now && now < startFirst + 1 days) {
              return _tokens.div(5);
          } else if (startFirst + 1 days <= now && now < startFirst + 2 days ) {
              return _tokens.div(20);
          } else if (startFirst + 2 days <= now && now < startFirst + 3 days ) {
              return _tokens.div(20);
          }
      }

      return 0;
  }

  /**
  token sale amount bonuses mechanism
  */
  function getBonusamount(uint256 _tokens) constant returns (uint256 bonusamount) {
      require(_tokens != 0);
      if (weiAmount > 500 ) {
          if (2 <= weiAmount < 4) {
              return _tokens.div(100);
          }
          else if (4 <= weiAmount < 6) {
              return _tokens.mul(1.5).div(100);
          }
          else if (6 <= weiAmount < 8) {
              return _tokens.mul(2).div(100);
          }
          else if (8 <= weiAmount < 10) {
              return _tokens.mul(2.5).div(100);
          }
          else if (10 <= weiAmount < 12) {
              return _tokens.mul(3).div(100);
          }
          else if (12 <= weiAmount < 14) {
              return _tokens.mul(3.5).div(100);
          }
          else if (14 <= weiAmount < 20) {
              return _tokens.mul(4).div(100);
          }
          else if (20 <= weiAmount < 40) {
              return _tokens.div(20);
          }
          else if (40 <= weiAmount < 60) {
              return _tokens.div(10);
          }
          else if (60 <= weiAmount) {
              return _tokens.mul(15).div(100);
          }
      }

      return 0;
  }

  function getCurrentPeriod() inActivePeriod constant returns (uint){
      if ((startFirst < now && now <= endFirst)) {
          return 1;
      } else if ((starSecond < now && now <= endSecond)) {
          return 2;
      } else {
          return 0;
      }
  }

  function tokenReserve(address _to, uint256 _value) internal returns (bool) {
      balances[_to] = balances[_to].add(_value);
      Transfer(msg.sender, _to, _value);
      return true;
  }

}
