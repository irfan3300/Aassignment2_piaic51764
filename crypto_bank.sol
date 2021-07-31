// SPDX-License-Identifier: MIT 
pragma solidity ^0.8.4;
contract Bank {
    address BankOwner; //Address of Owner of Bank
    mapping( address => uint) bankAccountBalance; // Bank total balance including initial amount, accounts balance and deduction of any bonus
    mapping( address => uint) AcHolderBalances; //Account holders balance
    mapping( address => AccountHolderCnrl) AccountHolderCnrlMap; // Control on Accounts
    address[] bonus;
    struct AccountHolderCnrl { bool newAccountHolder; bool accountHolderAct; bool bankOpen; }
    constructor() {
        BankOwner = msg.sender;
    }
    //Only contract owner create bank with minimum 50 ethers and only one bank can be opened.
    function open_Bank () public payable {
        require(msg.sender == BankOwner, "you are not owner of the bank");
        require(msg.value >= 50 ether, "The Opening Banking balance is low");
        require(!AccountHolderCnrlMap[msg.sender].bankOpen,"The Bank alreay exsists");
        bankAccountBalance[address(this)] += msg.value;
        AccountHolderCnrlMap[msg.sender].bankOpen = true;
    }
    //only owner can close bank
    function close_Bank() public payable{
        require(msg.sender == BankOwner, "Only Bank Owner can close the bank");
        selfdestruct(payable(BankOwner));
    }
    //One address has only one account, first 5 unique address will get 1 ether as bouns. Bouns will be paid by bank
    function acc_NewOpen() public payable {
        require(!AccountHolderCnrlMap[msg.sender].newAccountHolder, "You have already Account");
        if (bonus.length <= 4) {
            AcHolderBalances[msg.sender] = msg.value + 1 ether;
            bankAccountBalance[address(this)] += msg.value -1 ether;
            bonus.push(msg.sender);
        } else {
            AcHolderBalances[msg.sender] = msg.value;
            bankAccountBalance[address(this)] += msg.value;
        }
        AccountHolderCnrlMap[msg.sender].newAccountHolder = true;
    }
    //only active accounts can deposit
    function acc_Deposit() public payable {
        require(!AccountHolderCnrlMap[msg.sender].accountHolderAct, "Your Account is deactivated");
        AcHolderBalances[msg.sender] += msg.value;
        bankAccountBalance[address(this)] += msg.value;
    }
    //only active accounts can withdraw if deposit balance is more than withdraw balance
    function acc_Wdraw(address _to, uint _ether) public payable {
        require(_ether <= AcHolderBalances[msg.sender], "Account has no sufficient Ethers");
        require(!AccountHolderCnrlMap[msg.sender].accountHolderAct, "Your Account is deactivated");
        payable(_to).transfer(_ether);
        AcHolderBalances[msg.sender] -= _ether;
        bankAccountBalance[address(this)] -= _ether;
    }
    //Bank Balance
    function bank_Bal() public view returns(uint){
        return bankAccountBalance[address(this)];
    }
    //individula account Balance
    function acc_Bal(address _add) public view returns(uint){
        require(!AccountHolderCnrlMap[msg.sender].accountHolderAct, "Your Account is deactivated");
        return AcHolderBalances[_add];
    }
    //Only Bankowner can close the account
    function acc_Close(address _add) public {
        require(msg.sender == BankOwner);
        AccountHolderCnrlMap[_add].accountHolderAct = true;
        
    }
    receive() external payable{
    }
}
