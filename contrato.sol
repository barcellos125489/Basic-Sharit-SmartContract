//SPDX-License-Identifier: MIT 
// OpenZeppelin Contracts (last updated v4.8.0) (token/ERC20/ERC20.sol)

pragma solidity ^0.8.0;
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";

contract sharity is  Ownable, Pausable {
    mapping(address => bool) public allowedRecipient;
    mapping(address => bool) public allowedCampaign;
    uint256 balanceDonated;
    address payable payableOwner;

    event Donate(
        address indexed _from,
        uint256 _value
    );
    event Pay(
        address indexed _recipient,
        uint256 _amount
    );
    event Fee(
        address indexed _from,
        uint256 _value
    );

    constructor() Ownable(){
        payableOwner = payable(msg.sender);
    }
    function transfer(address payable to, uint256 amount) public virtual whenNotPaused returns (bool) {
        require(allowedRecipient[to], "Recipient not allowed");
        require(allowedCampaign[msg.sender], "Sender not allowed");
        require(address(this).balance>=amount, "Not enough balance");
        to.transfer(amount);
        emit Pay(to,amount);
        balanceDonated-=amount;
        return true;
    }

    function donate() payable public whenNotPaused{
        require(msg.value > 0, "Must send Ether");
        balanceDonated = msg.value - sendFee(msg.value);
        emit Donate(msg.sender,balanceDonated);
    }

    function addAllowedRecipient(address recipient) public whenNotPaused onlyOwner() {
        allowedRecipient[recipient]=true;
    }

    function addAllowedCampaign(address campaign) public whenNotPaused onlyOwner() {
        allowedCampaign[campaign]=true;
    }

    function seeBalance() public view returns (uint256){
        return address(this).balance;
    }

    function seeDonatedBalance() public view returns (uint256){
        return balanceDonated;
    }

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

    function sendFee(uint256 amount) private returns (uint256 _feeAmount)  {
        uint256 feeAmount = amount/100;
        emit Fee(msg.sender, feeAmount);
        payableOwner.transfer(feeAmount);
        return feeAmount;
    }

    fallback() external {
        require(false, "Please use the donate function to send donations");
    }
}