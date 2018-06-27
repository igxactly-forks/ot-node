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

contract LitigationStorage is Ownable{
	ContractHub public hub;
	event LitigationChange(bytes32 import_id, address DH_wallet);

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