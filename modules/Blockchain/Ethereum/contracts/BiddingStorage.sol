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

contract BidStorage is Ownable{
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

	event OfferChange(bytes32 import_id);
	event BidChange(bytes32 import_id, uint bid_index);
	
	struct OfferDefinition{
		address DC_wallet;

		//Parameters for DH filtering
		uint max_token_amount_per_DH;
		uint min_stake_amount_per_DH; 
		uint min_reputation;

		//Data holding parameters
		uint total_escrow_time_in_minutes;
		uint data_size_in_bytes;
		uint litigation_interval_in_minutes;

		//Parameters for the bidding ranking
		bytes32 data_hash;
		uint first_bid_index;
		uint bid_array_length;

		uint replication_factor;
		
		uint256 offer_creation_timestamp;
		bool active;
		bool finalized;
	}
	mapping(bytes32 => OfferDefinition) public offer; // offer[import_id]

	function getOffer_DC_wallet(bytes32 import_id) public view returns(address) {
		return offer[import_id].DC_wallet;
	}
	function getOffer_max_token_amount_per_DH(bytes32 import_id) public view returns(uint) {
		return offer[import_id].max_token_amount_per_DH;
	}
	function getOffer_min_stake_amount_per_DH(bytes32 import_id) public view returns(uint) {
		return offer[import_id].min_stake_amount_per_DH;
	}
	function getOffer_min_reputation(bytes32 import_id) public view returns(uint) {
		return offer[import_id].min_reputation;
	}
	function getOffer_total_escrow_time_in_minutes(bytes32 import_id) public view returns(uint) {
		return offer[import_id].total_escrow_time_in_minutes;
	}
	function getOffer_data_size_in_bytes(bytes32 import_id) public view returns(uint) {
		return offer[import_id].data_size_in_bytes;
	}
	function getOffer_litigation_interval_in_minutes(bytes32 import_id) public view returns(uint) {
		return offer[import_id].litigation_interval_in_minutes;
	}
	function getOffer_data_hash(bytes32 import_id) public view returns(bytes32) {
		return offer[import_id].data_hash;
	}
	function getOffer_first_bid_index(bytes32 import_id) public view returns(uint) {
		return offer[import_id].first_bid_index;
	}
	function getOffer_bid_array_length(bytes32 import_id) public view returns(uint) {
		return offer[import_id].bid_array_length;
	}
	function getOffer_replication_factor(bytes32 import_id) public view returns(uint) {
		return offer[import_id].replication_factor;
	}
	function getOffer_offer_creation_timestamp(bytes32 import_id) public view returns(uint) {
		return offer[import_id].offer_creation_timestamp;
	}
	function getOffer_active(bytes32 import_id) public view returns(bool) {
		return offer[import_id].active;
	}
	function getOffer_finalized(bytes32 import_id) public view returns(bool) {
		return offer[import_id].finalized;
	}
	
	
	function setOffer_DC_wallet(bytes32 import_id, address DC_wallet) 
	public onlyContracts{
		if(offer[import_id].DC_wallet != DC_wallet)
		offer[import_id].DC_wallet = DC_wallet;

		emit OfferChange(import_id);
	}
	function setOffer_max_token_amount_per_DH(bytes32 import_id, uint max_token_amount_per_DH) 
	public onlyContracts{
		if(offer[import_id].max_token_amount_per_DH != max_token_amount_per_DH)
		offer[import_id].max_token_amount_per_DH = max_token_amount_per_DH;

		emit OfferChange(import_id);
	}
	function setOffer_min_stake_amount_per_DH(bytes32 import_id, uint min_stake_amount_per_DH) 
	public onlyContracts{
		if(offer[import_id].min_stake_amount_per_DH != min_stake_amount_per_DH)
		offer[import_id].min_stake_amount_per_DH = min_stake_amount_per_DH;

		emit OfferChange(import_id);
	}
	function setOffer_min_reputation(bytes32 import_id, uint min_reputation) 
	public onlyContracts{
		if(offer[import_id].min_reputation != min_reputation)
		offer[import_id].min_reputation = min_reputation;

		emit OfferChange(import_id);
	}
	function setOffer_total_escrow_time_in_minutes(bytes32 import_id, uint total_escrow_time_in_minutes) 
	public onlyContracts{
		if(offer[import_id].total_escrow_time_in_minutes != total_escrow_time_in_minutes)
		offer[import_id].total_escrow_time_in_minutes = total_escrow_time_in_minutes;

		emit OfferChange(import_id);
	}
	function setOffer_data_size_in_bytes(bytes32 import_id, uint data_size_in_bytes) 
	public onlyContracts{
		if(offer[import_id].data_size_in_bytes != data_size_in_bytes)
		offer[import_id].data_size_in_bytes = data_size_in_bytes;

		emit OfferChange(import_id);
	}
	function setOffer_litigation_interval_in_minutes(bytes32 import_id, uint litigation_interval_in_minutes) 
	public onlyContracts{
		if(offer[import_id].litigation_interval_in_minutes != litigation_interval_in_minutes)
		offer[import_id].litigation_interval_in_minutes = litigation_interval_in_minutes;

		emit OfferChange(import_id);
	}
	function setOffer_data_hash(bytes32 import_id, bytes32 data_hash) 
	public onlyContracts{
		if(offer[import_id].data_hash != data_hash)
		offer[import_id].data_hash = data_hash;

		emit OfferChange(import_id);
	}
	function setOffer_first_bid_index(bytes32 import_id, uint first_bid_index) 
	public onlyContracts{
		if(offer[import_id].first_bid_index != first_bid_index)
		offer[import_id].first_bid_index = first_bid_index;

		emit OfferChange(import_id);
	}
	function setOffer_bid_array_length(bytes32 import_id, uint bid_array_length) 
	public onlyContracts{
		if(offer[import_id].bid_array_length != bid_array_length)
		offer[import_id].bid_array_length = bid_array_length;

		emit OfferChange(import_id);
	}
	function setOffer_replication_factor(bytes32 import_id, uint replication_factor) 
	public onlyContracts{
		if(offer[import_id].replication_factor != replication_factor)
		offer[import_id].replication_factor = replication_factor;

		emit OfferChange(import_id);
	}
	function setOffer_offer_creation_timestamp(bytes32 import_id, uint offer_creation_timestamp) 
	public onlyContracts{
		if(offer[import_id].offer_creation_timestamp != offer_creation_timestamp)
		offer[import_id].offer_creation_timestamp = offer_creation_timestamp;

		emit OfferChange(import_id);
	}
	function setOffer_active(bytes32 import_id, bool active) 
	public onlyContracts{
		if(offer[import_id].active != active)
		offer[import_id].active = active;

		emit OfferChange(import_id);
	}
	function setOffer_finalized(bytes32 import_id, bool finalized) 
	public onlyContracts{
		if(offer[import_id].finalized != finalized)
		offer[import_id].finalized = finalized;

		emit OfferChange(import_id);
	}


	struct BidDefinition{
		address DH_wallet;
		bytes32 DH_node_id;

		uint token_amount_for_escrow;
		uint stake_amount_for_escrow;

		uint256 ranking;

		uint next_bid_index;

		bool active;
		bool chosen;
	}
	mapping(bytes32 => mapping (uint256 => BidDefinition ) ) public bid; // bid[import_id][bid_index]

	function getBid_DH_wallet(bytes32 import_id, uint bid_index) public view returns (address){
		return bid[import_id][bid_index].DH_wallet;
	}
	function getBid_DH_node_id(bytes32 import_id, uint bid_index) public view returns (bytes32){
		return bid[import_id][bid_index].DH_node_id;
	}
	function getBid_token_amount_for_escrow(bytes32 import_id, uint bid_index) public view returns (uint){
		return bid[import_id][bid_index].token_amount_for_escrow;
	}
	function getBid_stake_amount_for_escrow(bytes32 import_id, uint bid_index) public view returns (uint){
		return bid[import_id][bid_index].stake_amount_for_escrow;
	}
	function getBid_ranking(bytes32 import_id, uint bid_index) public view returns (uint){
		return bid[import_id][bid_index].ranking;
	}
	function getBid_next_bid_index(bytes32 import_id, uint bid_index) public view returns (uint){
		return bid[import_id][bid_index].next_bid_index;
	}
	function getBid_active(bytes32 import_id, uint bid_index) public view returns (bool){
		return bid[import_id][bid_index].active;
	}
	function getBid_chosen(bytes32 import_id, uint bid_index) public view returns (bool){
		return bid[import_id][bid_index].chosen;
	}

	function setBid(
		bytes32 import_id,
		uint256 bid_index,
		address DH_wallet,
		bytes32 DH_node_id,
		uint token_amount_for_escrow,
		uint stake_amount_for_escrow,
		uint256 ranking,
		uint next_bid_index,
		bool active,
		bool chosen )
	public onlyContracts{
		if(bid[import_id][bid_index].DH_wallet != DH_wallet)
		bid[import_id][bid_index].DH_wallet = DH_wallet;

		if(bid[import_id][bid_index].DH_node_id != DH_node_id)
		bid[import_id][bid_index].DH_node_id = DH_node_id;

		if(bid[import_id][bid_index].token_amount_for_escrow != token_amount_for_escrow)
		bid[import_id][bid_index].token_amount_for_escrow = token_amount_for_escrow;

		if(bid[import_id][bid_index].stake_amount_for_escrow != stake_amount_for_escrow)
		bid[import_id][bid_index].stake_amount_for_escrow = stake_amount_for_escrow;

		if(bid[import_id][bid_index].ranking != ranking)
		bid[import_id][bid_index].ranking = ranking;

		if(bid[import_id][bid_index].next_bid_index != next_bid_index)
		bid[import_id][bid_index].next_bid_index = next_bid_index;

		if(bid[import_id][bid_index].active != active)
		bid[import_id][bid_index].active = active;

		if(bid[import_id][bid_index].chosen != chosen)
		bid[import_id][bid_index].chosen = chosen;

		emit BidChange(import_id,bid_index);
	}
	function setBid_DH_wallet(bytes32 import_id, uint index, address DH_wallet) public onlyContracts{
		if(bid[import_id][index].DH_wallet != DH_wallet)
		bid[import_id][index].DH_wallet = DH_wallet;
	}
	function setBid_DH_node_id(bytes32 import_id, uint index, bytes32 DH_node_id) public onlyContracts{
		if(bid[import_id][index].DH_node_id != DH_node_id)
		bid[import_id][index].DH_node_id = DH_node_id;
	}
	function setBid_token_amount_for_escrow(bytes32 import_id, uint index, uint token_amount_for_escrow) public onlyContracts{
		if(bid[import_id][index].token_amount_for_escrow != token_amount_for_escrow)
		bid[import_id][index].token_amount_for_escrow = token_amount_for_escrow;
	}
	function setBid_stake_amount_for_escrow(bytes32 import_id, uint index, uint stake_amount_for_escrow) public onlyContracts{
		if(bid[import_id][index].stake_amount_for_escrow != stake_amount_for_escrow)
		bid[import_id][index].stake_amount_for_escrow = stake_amount_for_escrow;
	}
	function setBid_ranking(bytes32 import_id, uint index, uint ranking) public onlyContracts{
		if(bid[import_id][index].ranking != ranking)
		bid[import_id][index].ranking = ranking;
	}
	function setBid_next_bid_index(bytes32 import_id, uint index, uint next_bid_index) public onlyContracts{
		if(bid[import_id][index].next_bid_index != next_bid_index)
		bid[import_id][index].next_bid_index = next_bid_index;
	}
	function setBid_active(bytes32 import_id, uint index, bool active) public onlyContracts{
		if(bid[import_id][index].active != active)
		bid[import_id][index].active = active;
	}
	function setBid_chosen(bytes32 import_id, uint index, bool chosen) public onlyContracts{
		if(bid[import_id][index].chosen != chosen)
		bid[import_id][index].chosen = chosen;
	}

	function setBidNextBidIndex(bytes32 import_id, uint index, uint next_bid_index)
	public onlyContracts{
		if(bid[import_id][index].next_bid_index != next_bid_index)
		bid[import_id][index].next_bid_index = next_bid_index;

		emit BidChange(import_id, index);
	}  
}