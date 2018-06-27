pragma solidity ^0.4.23;

/**
* @title Ownable
* @dev The Ownable contract has an owner address, and provides basic authorization control
* functions, this simplifies the implementation of "user permissions".
*/
contract Ownable {
	address public owner;

	event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
    * @dev The Ownable constructor sets the original `owner` of the contract to the sender
    * account.
    */
    constructor () public {
    	owner = msg.sender;
    }

    /**
    * @dev Throws if called by any account other than the owner.
    */
    modifier onlyOwner() {
    	require(msg.sender == owner);
    	_;
    }

    /**
    * @dev Allows the current owner to transfer control of the contract to a newOwner.
    * @param newOwner The address to transfer ownership to.
    */
    function transferOwnership(address newOwner) public onlyOwner {
    	require(newOwner != address(0));
    	emit OwnershipTransferred(owner, newOwner);
    	owner = newOwner;
    }
}


contract ContractHub is Ownable {
	address public fingerprintAddress;
	address public tokenAddress;
	address public biddingAddress;
	address public litigationAddress;
	address public escrowAddress;
	address public litigationAddress;
	address public readingAddress;
}

contract ProfileStorage is Ownable{
	ContractHub public hub;
	event ProfileChange(address wallet);

	constructor(address hub_address) public {
		require(hub_address != address(0));
		hub = ContractHub(hub_address);
	}

	modifier onlyContracts() {
		require(
			msg.sender == hub.fingerprintAddress()
			|| msg.sender == hub.tokenAddress()
			|| msg.sender == hub.biddingAddress()
			|| msg.sender == hub.escrowAddress()
			|| msg.sender == hub.litigationAddress()
			|| msg.sender == hub.owner()
			|| msg.sender == hub.readingAddress());
		_;
	}

	struct ProfileDefinition{
		uint token_amount_per_byte_minute;
		uint stake_amount_per_byte_minute;

		uint read_stake_factor;

		uint balance;
		uint reputation;
		uint number_of_escrows;

		uint max_escrow_time_in_minutes;

		bool active;
	}
	mapping(address => ProfileDefinition) public profile; // profile[wallet]

	function getProfile_token_amount_per_byte_minute(address wallet) public view returns(uint) {
		return profile[wallet].token_amount_per_byte_minute;
	}
	function getProfile_stake_amount_per_byte_minute(address wallet) public view returns(uint) {
		return profile[wallet].stake_amount_per_byte_minute;
	}
	function getProfile_read_stake_factor(address wallet) public view returns(uint) {
		return profile[wallet].read_stake_factor;
	}
	function getProfile_balance(address wallet) public view returns(uint) {
		return profile[wallet].balance;
	}
	function getProfile_reputation(address wallet) public view returns(uint) {
		return profile[wallet].reputation;
	}
	function getProfile_number_of_escrows(address wallet) public view returns(uint) {
		return profile[wallet].number_of_escrows;
	}
	function getProfile_max_escrow_time_in_minutes(address wallet) public view returns(uint) {
		return profile[wallet].max_escrow_time_in_minutes;
	}
	function getProfile_active(address wallet) public view returns(bool) {
		return profile[wallet].active;
	}

	function setProfile(
		address wallet,
		uint token_amount_per_byte_minute,
		uint stake_amount_per_byte_minute,
		uint read_stake_factor,
		uint balance,
		uint reputation,
		uint number_of_escrows,
		uint max_escrow_time_in_minutes,
		bool active) 
	public onlyOwner {
		if(profile[wallet].token_amount_per_byte_minute != token_amount_per_byte_minute)
		profile[wallet].token_amount_per_byte_minute = token_amount_per_byte_minute;

		if(profile[wallet].stake_amount_per_byte_minute != stake_amount_per_byte_minute)
		profile[wallet].stake_amount_per_byte_minute = stake_amount_per_byte_minute;

		if(profile[wallet].read_stake_factor != read_stake_factor)
		profile[wallet].read_stake_factor = read_stake_factor;

		if(profile[wallet].read_stake_factor != read_stake_factor)
		profile[wallet].read_stake_factor = read_stake_factor;

		if(profile[wallet].balance != balance)
		profile[wallet].balance = balance;

		if(profile[wallet].reputation != reputation)
		profile[wallet].reputation = reputation;

		if(profile[wallet].number_of_escrows != number_of_escrows)
		profile[wallet].number_of_escrows = number_of_escrows;

		if(profile[wallet].max_escrow_time_in_minutes != max_escrow_time_in_minutes)
		profile[wallet].max_escrow_time_in_minutes = max_escrow_time_in_minutes;

		if(profile[wallet].active != active)
		profile[wallet].active = active;

		emit ProfileChange(wallet);
	}
	function setProfile_token_amount_per_byte_minute(address wallet, uint256 token_amount_per_byte_minute) public onlyOwner {
		if(profile[wallet].token_amount_per_byte_minute != token_amount_per_byte_minute)
		profile[wallet].token_amount_per_byte_minute = token_amount_per_byte_minute;
	}
	function setProfile_stake_amount_per_byte_minute(address wallet, uint256 stake_amount_per_byte_minute) public onlyOwner {
		if(profile[wallet].stake_amount_per_byte_minute != stake_amount_per_byte_minute)
		profile[wallet].stake_amount_per_byte_minute = stake_amount_per_byte_minute;
	}
	function setProfile_read_stake_factor(address wallet, uint256 read_stake_factor) public onlyOwner {
		if(profile[wallet].read_stake_factor != read_stake_factor)
		profile[wallet].read_stake_factor = read_stake_factor;
	}
	function setProfile_balance(address wallet, uint256 balance) public onlyOwner {
		if(profile[wallet].balance != balance)
		profile[wallet].balance = balance;
	}
	function setProfile_reputation(address wallet, uint256 reputation) public onlyOwner {
		if(profile[wallet].reputation != reputation)
		profile[wallet].reputation = reputation;
	}
	function setProfile_number_of_escrows(address wallet, uint256 number_of_escrows) public onlyOwner {
		if(profile[wallet].number_of_escrows != number_of_escrows)
		profile[wallet].number_of_escrows = number_of_escrows;
	}
	function setProfile_max_escrow_time_in_minutes(address wallet, uint256 max_escrow_time_in_minutes) public onlyOwner {
		if(profile[wallet].max_escrow_time_in_minutes != max_escrow_time_in_minutes)
		profile[wallet].max_escrow_time_in_minutes = max_escrow_time_in_minutes;
	}
	function setProfile_active(address wallet, bool active) public onlyOwner {
		if(profile[wallet].active != active)
		profile[wallet].active = active;
	}
}