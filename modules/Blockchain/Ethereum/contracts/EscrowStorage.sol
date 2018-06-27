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

contract EscrowStorage is Ownable{
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

	event EscrowChange(bytes32 import_id, address DH_wallet);
	event LitigationChange(bytes32 import_id, address DH_wallet);

	enum EscrowStatus {inactive, initiated, confirmed, active, completed}
	struct EscrowDefinition{
		address DC_wallet;

		uint token_amount;
		uint tokens_sent;

		uint stake_amount;

		uint last_confirmation_time;
		uint end_time;
		uint total_time_in_seconds;
		uint litigation_interval_in_minutes;

		bytes32 litigation_root_hash;
		bytes32 distribution_root_hash;
		uint256 checksum;

		EscrowStatus escrow_status;
	}
	mapping(bytes32 => mapping(address => EscrowDefinition)) public escrow; // escrow[import_id][DH_wallet]
	function getEscrow_DC_wallet(bytes32 import_id, address DH_wallet) public view returns(address){
		return escrow[import_id][DH_wallet].DC_wallet;
	}
	function getEscrow_token_amount(bytes32 import_id, address DH_wallet) public view returns(uint){
		return escrow[import_id][DH_wallet].token_amount;
	}
	function getEscrow_tokens_sent(bytes32 import_id, address DH_wallet) public view returns(uint){
		return escrow[import_id][DH_wallet].tokens_sent;
	}
	function getEscrow_stake_amount(bytes32 import_id, address DH_wallet) public view returns(uint){
		return escrow[import_id][DH_wallet].stake_amount;
	}
	function getEscrow_last_confirmation_time(bytes32 import_id, address DH_wallet) public view returns(uint){
		return escrow[import_id][DH_wallet].last_confirmation_time;
	}
	function getEscrow_end_time(bytes32 import_id, address DH_wallet) public view returns(uint){
		return escrow[import_id][DH_wallet].end_time;
	}
	function getEscrow_total_time_in_seconds(bytes32 import_id, address DH_wallet) public view returns(uint){
		return escrow[import_id][DH_wallet].total_time_in_seconds;
	}
	function getEscrow_litigation_interval_in_minutes(bytes32 import_id, address DH_wallet) public view returns(uint){
		return escrow[import_id][DH_wallet].litigation_interval_in_minutes;
	}
	function getEscrow_litigation_root_hash(bytes32 import_id, address DH_wallet) public view returns(bytes32){
		return escrow[import_id][DH_wallet].litigation_root_hash;
	}
	function getEscrow_distribution_root_hash(bytes32 import_id, address DH_wallet) public view returns(bytes32){
		return escrow[import_id][DH_wallet].distribution_root_hash;
	}
	function getEscrow_checksum(bytes32 import_id, address DH_wallet) public view returns(uint){
		return escrow[import_id][DH_wallet].checksum;
	}
	function getEscrow_escrow_status(bytes32 import_id, address DH_wallet) public view returns(EscrowStatus){
		return escrow[import_id][DH_wallet].escrow_status;
	}
	function setEscrow(
		bytes32 import_id,
		address DH_wallet,
		address DC_wallet,
		uint token_amount,
		uint tokens_sent,
		uint stake_amount,
		uint last_confirmation_time,
		uint end_time,
		uint total_time_in_seconds,
		uint litigation_interval_in_minutes,
		bytes32 litigation_root_hash,
		bytes32 distribution_root_hash,
		uint256 checksum )
	public onlyContracts{
		if(escrow[import_id][DH_wallet].DC_wallet != DC_wallet)
		escrow[import_id][DH_wallet].DC_wallet = DC_wallet;

		if(escrow[import_id][DH_wallet].token_amount != token_amount)
		escrow[import_id][DH_wallet].token_amount = token_amount;

		if(escrow[import_id][DH_wallet].tokens_sent != tokens_sent)
		escrow[import_id][DH_wallet].tokens_sent = tokens_sent;

		if(escrow[import_id][DH_wallet].stake_amount != stake_amount)
		escrow[import_id][DH_wallet].stake_amount = stake_amount;

		if(escrow[import_id][DH_wallet].last_confirmation_time != last_confirmation_time)
		escrow[import_id][DH_wallet].last_confirmation_time = last_confirmation_time;

		if(escrow[import_id][DH_wallet].end_time != end_time)
		escrow[import_id][DH_wallet].end_time = end_time;

		if(escrow[import_id][DH_wallet].total_time_in_seconds != total_time_in_seconds)
		escrow[import_id][DH_wallet].total_time_in_seconds = total_time_in_seconds;

		if(escrow[import_id][DH_wallet].litigation_interval_in_minutes != litigation_interval_in_minutes)
		escrow[import_id][DH_wallet].litigation_interval_in_minutes = litigation_interval_in_minutes;

		if(escrow[import_id][DH_wallet].litigation_root_hash != litigation_root_hash)
		escrow[import_id][DH_wallet].litigation_root_hash = litigation_root_hash;

		if(escrow[import_id][DH_wallet].distribution_root_hash != distribution_root_hash)
		escrow[import_id][DH_wallet].distribution_root_hash = distribution_root_hash;

		if(escrow[import_id][DH_wallet].checksum != checksum)
		escrow[import_id][DH_wallet].checksum = checksum;

		emit EscrowChange(import_id, DH_wallet);
	}
	function setEscrow_DC_wallet(bytes32 import_id, address DH_wallet, address DC_wallet) public onlyContracts{
		if(escrow[import_id][DH_wallet].DC_wallet != DC_wallet)
		escrow[import_id][DH_wallet].DC_wallet = DC_wallet;
	}
	function setEscrow_token_amount(bytes32 import_id, address DH_wallet, uint token_amount) public onlyContracts{
		if(escrow[import_id][DH_wallet].token_amount != token_amount)
		escrow[import_id][DH_wallet].token_amount = token_amount;
	}
	function setEscrow_tokens_sent(bytes32 import_id, address DH_wallet, uint tokens_sent) public onlyContracts{
		if(escrow[import_id][DH_wallet].tokens_sent != tokens_sent)
		escrow[import_id][DH_wallet].tokens_sent = tokens_sent;
	}
	function setEscrow_stake_amount(bytes32 import_id, address DH_wallet, uint stake_amount) public onlyContracts{
		if(escrow[import_id][DH_wallet].stake_amount != stake_amount)
		escrow[import_id][DH_wallet].stake_amount = stake_amount;
	}
	function setEscrow_last_confirmation_time(bytes32 import_id, address DH_wallet, uint last_confirmation_time) public onlyContracts{
		if(escrow[import_id][DH_wallet].last_confirmation_time != last_confirmation_time)
		escrow[import_id][DH_wallet].last_confirmation_time = last_confirmation_time;
	}
	function setEscrow_end_time(bytes32 import_id, address DH_wallet, uint end_time) public onlyContracts{
		if(escrow[import_id][DH_wallet].end_time != end_time)
		escrow[import_id][DH_wallet].end_time = end_time;
	}
	function setEscrow_total_time_in_seconds(bytes32 import_id, address DH_wallet, uint256 total_time_in_seconds) public onlyContracts{
		if(escrow[import_id][DH_wallet].total_time_in_seconds != total_time_in_seconds)
		escrow[import_id][DH_wallet].total_time_in_seconds = total_time_in_seconds;
	}
	function setEscrow_litigation_interval_in_minutes(bytes32 import_id, address DH_wallet, uint256 litigation_interval_in_minutes) public onlyContracts{
		if(escrow[import_id][DH_wallet].litigation_interval_in_minutes != litigation_interval_in_minutes)
		escrow[import_id][DH_wallet].litigation_interval_in_minutes = litigation_interval_in_minutes;
	}
	function setEscrow_litigation_root_hash(bytes32 import_id, address DH_wallet, bytes32 litigation_root_hash) public onlyContracts{
		if(escrow[import_id][DH_wallet].litigation_root_hash != litigation_root_hash)
		escrow[import_id][DH_wallet].litigation_root_hash = litigation_root_hash;
	}
	function setEscrow_distribution_root_hash(bytes32 import_id, address DH_wallet, bytes32 distribution_root_hash) public onlyContracts{
		if(escrow[import_id][DH_wallet].distribution_root_hash != distribution_root_hash)
		escrow[import_id][DH_wallet].distribution_root_hash = distribution_root_hash;
	}
	function setEscrow_checksum(bytes32 import_id, address DH_wallet, uint256 checksum) public onlyContracts{
		if(escrow[import_id][DH_wallet].checksum != checksum)
		escrow[import_id][DH_wallet].checksum = checksum;
	}
	function setEscrow_escrow_status(bytes32 import_id, address DH_wallet, EscrowStatus escrow_status) public onlyContracts{
		if(escrow[import_id][DH_wallet].escrow_status != escrow_status)
		escrow[import_id][DH_wallet].escrow_status = escrow_status;
	}

	
	enum LitigationStatus {inactive, initiated, answered, timed_out, completed}
	struct LitigationDefinition{
		uint requested_data_index;
		bytes32 requested_data;
		bytes32[] hash_array;
		uint litigation_start_time;
		uint answer_timestamp;
		LitigationStatus litigation_status;
	}
	mapping(bytes32 => mapping ( address => LitigationDefinition)) public litigation; // litigation[import_id][DH_wallet]
	function getLitigation_requested_data_index(bytes32 import_id, address DH_wallet) public view returns(uint){
		return litigation[import_id][DH_wallet].requested_data_index;
	}
	function getLitigation_requested_data(bytes32 import_id, address DH_wallet) public view returns(bytes32){
		return litigation[import_id][DH_wallet].requested_data;
	}
	function getLitigation_hash_array(bytes32 import_id, address DH_wallet) public view returns(bytes32[]){
		return litigation[import_id][DH_wallet].hash_array;
	}
	function getLitigation_litigation_start_time(bytes32 import_id, address DH_wallet) public view returns(uint){
		return litigation[import_id][DH_wallet].litigation_start_time;
	}
	function getLitigation_answer_timestamp(bytes32 import_id, address DH_wallet) public view returns(uint){
		return litigation[import_id][DH_wallet].answer_timestamp;
	}
	function getLitigation_litigation_status(bytes32 import_id, address DH_wallet) public view returns(LitigationStatus){
		return litigation[import_id][DH_wallet].litigation_status;
	}

	function setLitigation_requested_data_index(bytes32 import_id, address DH_wallet, uint requested_data_index) public onlyContracts{
		if(litigation[import_id][DH_wallet].requested_data_index != requested_data_index)
		litigation[import_id][DH_wallet].requested_data_index = requested_data_index;
	} 	
	function setLitigation_requested_data(bytes32 import_id, address DH_wallet, bytes32 requested_data) public onlyContracts{
		if(litigation[import_id][DH_wallet].requested_data != requested_data)
		litigation[import_id][DH_wallet].requested_data = requested_data;
	}
	function setLitigation_hash_array(bytes32 import_id, address DH_wallet, bytes32[] hash_array) public onlyContracts{
		// if(litigation[import_id][DH_wallet].hash_array != hash_array)
		litigation[import_id][DH_wallet].hash_array = hash_array;
	}
	function setLitigation_litigation_start_time(bytes32 import_id, address DH_wallet, uint litigation_start_time) public onlyContracts{
		if(litigation[import_id][DH_wallet].litigation_start_time != litigation_start_time)
		litigation[import_id][DH_wallet].litigation_start_time = litigation_start_time;
	}
	function setLitigation_answer_timestamp(bytes32 import_id, address DH_wallet, uint answer_timestamp) public onlyContracts{
		if(litigation[import_id][DH_wallet].answer_timestamp != answer_timestamp)
		litigation[import_id][DH_wallet].answer_timestamp = answer_timestamp;
	}
	function setLitigation_litigation_status(bytes32 import_id, address DH_wallet, LitigationStatus litigation_status) public onlyContracts{
		if(litigation[import_id][DH_wallet].litigation_status != litigation_status)
		litigation[import_id][DH_wallet].litigation_status = litigation_status;
	}
}