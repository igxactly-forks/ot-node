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
	address public escrowAddress;
	address public readingAddress;
}

contract ReadingStorage is Ownable{
	ContractHub public hub;

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
			|| msg.sender == hub.owner()
			|| msg.sender == hub.readingAddress());
		_;
	}

	event PurchasedDataChange(bytes32 import_id, address DH_wallet);
	event PurchaseChange(address DH_wallet, address DV_wallet, bytes32 import_id);
	

	struct PurchasedDataDefinition {
		address DC_wallet;
		bytes32 distribution_root_hash;
		uint256 checksum;
	}
	mapping(bytes32 => mapping(address => PurchasedDataDefinition)) public purchased_data; // purchased_data[import_id][DH_wallet]
	function getPuchasedData_DC_wallet(bytes32 import_id, address DH_wallet) public view returns(address){
		return purchased_data[import_id][DH_wallet].DC_wallet;
	}
	function getPuchasedData_distribution_root_hash(bytes32 import_id, address DH_wallet) public view returns(bytes32){
		return purchased_data[import_id][DH_wallet].distribution_root_hash;
	}
	function getPuchasedData_checksum(bytes32 import_id, address DH_wallet) public view returns(uint){
		return purchased_data[import_id][DH_wallet].checksum;
	}
	function setPurchasedData(
		bytes32 import_id,
		address DH_wallet,
		address DC_wallet,
		bytes32 distribution_root_hash,
		uint256 checksum ) 
	public onlyContracts{
		if(purchased_data[import_id][DH_wallet].DC_wallet != DC_wallet)
		purchased_data[import_id][DH_wallet].DC_wallet = DC_wallet;

		if(purchased_data[import_id][DH_wallet].distribution_root_hash != distribution_root_hash)
		purchased_data[import_id][DH_wallet].distribution_root_hash = distribution_root_hash;

		if(purchased_data[import_id][DH_wallet].checksum != checksum)
		purchased_data[import_id][DH_wallet].checksum = checksum;
		emit PurchasedDataChange(import_id, DH_wallet);
	}

	enum PurchaseStatus {inactive, initiated, commited, confirmed, sent, disputed, cancelled, completed}
	struct PurchaseDefinition{
		uint token_amount;
		uint stake_factor;
		uint dispute_interval_in_minutes;

		bytes32 commitment;
		uint256 encrypted_block;

		uint256 time_of_sending;

		PurchaseStatus purchase_status;
	}
	mapping(address => mapping(address => mapping(bytes32 => PurchaseDefinition))) public purchase; // purchase[DH_wallet][DV_wallet][import_id]
	function setPurchase_token_amount(address DH_wallet, address DV_wallet, bytes32 import_id, uint token_amount) public onlyContracts{
		if(purchase[DH_wallet][DV_wallet][import_id].token_amount != token_amount)
		purchase[DH_wallet][DV_wallet][import_id].token_amount = token_amount;
	}
	function setPurchase_stake_factor(address DH_wallet, address DV_wallet, bytes32 import_id, uint stake_factor) public onlyContracts{
		if(purchase[DH_wallet][DV_wallet][import_id].stake_factor != stake_factor)
		purchase[DH_wallet][DV_wallet][import_id].stake_factor = stake_factor;
	}
	function setPurchase_dispute_interval_in_minutes(address DH_wallet, address DV_wallet, bytes32 import_id, uint dispute_interval_in_minutes) public onlyContracts{
		if(purchase[DH_wallet][DV_wallet][import_id].dispute_interval_in_minutes != dispute_interval_in_minutes)
		purchase[DH_wallet][DV_wallet][import_id].dispute_interval_in_minutes = dispute_interval_in_minutes;
	}
	function setPurchase_commitment(address DH_wallet, address DV_wallet, bytes32 import_id, bytes32 commitment) public onlyContracts{
		if(purchase[DH_wallet][DV_wallet][import_id].commitment != commitment)
		purchase[DH_wallet][DV_wallet][import_id].commitment = commitment;
	}
	function setPurchase_encrypted_block(address DH_wallet, address DV_wallet, bytes32 import_id, uint encrypted_block) public onlyContracts{
		if(purchase[DH_wallet][DV_wallet][import_id].encrypted_block != encrypted_block)
		purchase[DH_wallet][DV_wallet][import_id].encrypted_block = encrypted_block;
	}
	function setPurchase_time_of_sending(address DH_wallet, address DV_wallet, bytes32 import_id, uint time_of_sending) public onlyContracts{
		if(purchase[DH_wallet][DV_wallet][import_id].time_of_sending != time_of_sending)
		purchase[DH_wallet][DV_wallet][import_id].time_of_sending = time_of_sending;
	}
	function setPurchase_purchase_status(address DH_wallet, address DV_wallet, bytes32 import_id, PurchaseStatus purchase_status) public onlyContracts{
		if(purchase[DH_wallet][DV_wallet][import_id].purchase_status != purchase_status)
		purchase[DH_wallet][DV_wallet][import_id].purchase_status = purchase_status;
	}
	function setPurchase(
		address DH_wallet,
		address DV_wallet,
		bytes32 import_id,
		uint token_amount,
		uint stake_factor,
		uint dispute_interval_in_minutes,
		bytes32 commitment,
		uint256 encrypted_block,
		uint256 time_of_sending,
		PurchaseStatus purchase_status )
	public onlyContracts{
		if(purchase[DH_wallet][DV_wallet][import_id].token_amount != token_amount)
		purchase[DH_wallet][DV_wallet][import_id].token_amount = token_amount;

		if(purchase[DH_wallet][DV_wallet][import_id].stake_factor != stake_factor)
		purchase[DH_wallet][DV_wallet][import_id].stake_factor = stake_factor;

		if(purchase[DH_wallet][DV_wallet][import_id].dispute_interval_in_minutes != dispute_interval_in_minutes)
		purchase[DH_wallet][DV_wallet][import_id].dispute_interval_in_minutes = dispute_interval_in_minutes;

		if(purchase[DH_wallet][DV_wallet][import_id].commitment != commitment)
		purchase[DH_wallet][DV_wallet][import_id].commitment = commitment;

		if(purchase[DH_wallet][DV_wallet][import_id].encrypted_block != encrypted_block)
		purchase[DH_wallet][DV_wallet][import_id].encrypted_block = encrypted_block;

		if(purchase[DH_wallet][DV_wallet][import_id].time_of_sending != time_of_sending)
		purchase[DH_wallet][DV_wallet][import_id].time_of_sending = time_of_sending;

		if(purchase[DH_wallet][DV_wallet][import_id].purchase_status != purchase_status)
		purchase[DH_wallet][DV_wallet][import_id].purchase_status = purchase_status;
		emit PurchaseChange(DH_wallet, DV_wallet, import_id);
	}

	function getPurchase_token_amount(address DH_wallet, address DV_wallet, bytes32 import_id) public view returns(uint){
		return purchase[DH_wallet][DV_wallet][import_id].token_amount;
	}
	function getPurchase_stake_factor(address DH_wallet, address DV_wallet, bytes32 import_id) public view returns(uint){
		return purchase[DH_wallet][DV_wallet][import_id].stake_factor;
	}
	function getPurchase_dispute_interval_in_minutes(address DH_wallet, address DV_wallet, bytes32 import_id) public view returns(uint){
		return purchase[DH_wallet][DV_wallet][import_id].dispute_interval_in_minutes;
	}
	function getPurchase_commitment(address DH_wallet, address DV_wallet, bytes32 import_id) public view returns(bytes32){
		return purchase[DH_wallet][DV_wallet][import_id].commitment;
	}
	function getPurchase_encrypted_block(address DH_wallet, address DV_wallet, bytes32 import_id) public view returns(uint){
		return purchase[DH_wallet][DV_wallet][import_id].encrypted_block;
	}
	function getPurchase_time_of_sending(address DH_wallet, address DV_wallet, bytes32 import_id) public view returns(uint){
		return purchase[DH_wallet][DV_wallet][import_id].time_of_sending;
	}
	function getPurchase_purchase_status(address DH_wallet, address DV_wallet, bytes32 import_id) public view returns(PurchaseStatus){
		return purchase[DH_wallet][DV_wallet][import_id].purchase_status;
	}

}