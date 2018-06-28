pragma solidity ^0.4.23;

library SafeMath {
	function mul(uint256 a, uint256 b) internal pure returns (uint256) {
		uint256 c = a * b;
		assert(a == 0 || c / a == b);
		return c;
	}

	function div(uint256 a, uint256 b) internal pure returns (uint256) {
		// assert(b > 0); // Solidity automatically throws when dividing by 0
		uint256 c = a / b;
		// assert(a == b * c + a % b); // There is no case in which this doesn't hold
		return c;
	}

	function sub(uint256 a, uint256 b) internal pure returns (uint256) {
		assert(b <= a);
		return a - b;
	}

	function add(uint256 a, uint256 b) internal pure returns (uint256) {
		uint256 c = a + b;
		assert(c >= a);
		return c;
	}
}

contract ERC20Basic {
	uint256 public totalSupply;
	function balanceOf(address who) public constant returns (uint256);
	function transfer(address to, uint256 value) public returns (bool);
	event Transfer(address indexed from, address indexed to, uint256 value);
}

contract ERC20 is ERC20Basic {
	function allowance(address owner, address spender) public constant returns (uint256);
	function transferFrom(address from, address to, uint256 value) public returns (bool);
	function approve(address spender, uint256 value) public returns (bool);
	event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract ProfileStorage {

	function getProfile_token_amount_per_byte_minute(address wallet) public view returns(uint);
	function getProfile_stake_amount_per_byte_minute(address wallet) public view returns(uint);
	function getProfile_balance(address wallet) public view returns(uint);
	function getProfile_reputation(address wallet) public view returns(uint);
	function getProfile_number_of_escrows(address wallet) public view returns(uint);
	function getProfile_max_escrow_time_in_minutes(address wallet) public view returns(uint);
	function getProfile_active(address wallet) public view returns(bool);

	function setProfile_token_amount_per_byte_minute(address wallet, uint token_amount_per_byte_minute) public;
	function setProfile_stake_amount_per_byte_minute(address wallet, uint stake_amount_per_byte_minute) public;
	function setProfile_read_stake_factor(address wallet, uint read_stake_factor) public;
	function setProfile_balance(address wallet, uint balance) public;
	function setProfile_reputation(address wallet, uint reputation) public;
	function setProfile_number_of_escrows(address wallet, uint number_of_escrows) public;
	function setProfile_max_escrow_time_in_minutes(address wallet, uint max_escrow_time_in_minutes) public;
	function setProfile_active(address wallet, bool active) public;
}


contract ContractHub{
	address public tokenAddress;
	address public profileStorageAddress;
}

contract Profile {
	using SafeMath for uint256;

	ContractHub public hub;

	ProfileStorage public profileStorage;

	uint256 activated_nodes;

	constructor(address hub_address)
	public{
		require (hub_address != address(0));
		hub = ContractHub(hub_address);
		profileStorage = ProfileStorage(hub.profileStorageAddress()); // TODO Maybe move this line to initialize
		activated_nodes = 0;
	}

	/*    ----------------------------- PROFILE -----------------------------    */

	event ProfileCreated(address wallet);
	event BalanceModified(address wallet, uint new_balance);
	event ReputationModified(address wallet, uint new_balance);

	function createProfile(uint price_per_byte_minute, uint stake_per_byte_minute, uint read_stake_factor, uint max_time_in_minutes) public{
		bool active = profileStorage.getProfile_active(msg.sender);
		if(!active) {
			activated_nodes = activated_nodes.add(1);
			profileStorage.setProfile_active(msg.sender, true);
		}

		profileStorage.setProfile_token_amount_per_byte_minute(msg.sender, price_per_byte_minute);
		profileStorage.setProfile_stake_amount_per_byte_minute(msg.sender, stake_per_byte_minute);
		profileStorage.setProfile_read_stake_factor(msg.sender, read_stake_factor);
		profileStorage.setProfile_max_escrow_time_in_minutes(msg.sender, max_time_in_minutes);

		emit ProfileCreated(msg.sender);
	}

	function setPrice(uint new_price_per_byte_minute) public {
		profileStorage.setProfile_token_amount_per_byte_minute(msg.sender, new_price_per_byte_minute);
	}

	function setStake(uint new_stake_per_byte_minute) public {
		profileStorage.setProfile_stake_amount_per_byte_minute(msg.sender, new_stake_per_byte_minute);
	}

	function setMaxTime(uint new_max_time_in_minutes) public {
		profileStorage.setProfile_max_escrow_time_in_minutes(msg.sender, new_max_time_in_minutes);
	}

	function depositToken(uint amount) public {
		require(token.balanceOf(msg.sender) >= amount && token.allowance(msg.sender, this) >= amount);
		uint amount_to_transfer = amount;
		amount = 0;
		if(amount_to_transfer > 0) {
			ERC20 token = ERC20(hub.tokenAddress());
			token.transferFrom(msg.sender, this, amount_to_transfer);
			uint balance = profileStorage.getProfile_balance(msg.sender);

			balance = balance.add(amount_to_transfer);
			profileStorage.setProfile_balance(msg.sender, balance);
			emit BalanceModified(msg.sender, balance);
		}
	}

	function withdrawToken(uint amount) public {
		uint256 amount_to_transfer;
		uint balance = profileStorage.getProfile_balance(msg.sender);

		if(balance >= amount){
			amount_to_transfer = amount;
			balance = balance.sub(amount);
		}
		else{ 
			amount_to_transfer = balance;
			balance = 0;
		}
		amount = 0;
		if(amount_to_transfer > 0){
			ERC20 token = ERC20(hub.tokenAddress());
			token.transfer(msg.sender, amount_to_transfer);
			profileStorage.setProfile_balance(msg.sender, balance);
			emit BalanceModified(msg.sender, balance);
		} 
	}

}