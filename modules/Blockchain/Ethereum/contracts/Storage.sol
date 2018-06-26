pragma solidity ^0.4.22;

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


contract StorageContract {


	event ProfileChange(address wallet);
	event OfferChange(bytes32 offer_import_id);
	event BidChange(bytes32 offer_import_id,uint index);
	event EscrowChange(bytes32 import_id, address DH_wallet);
	event PurchasedDataChange(bytes32 import_id, address DH_wallet);
	event PurchaseChange(address DH_wallet, address DV_wallet, bytes32 import_id);

	ContractHub public hub;

	constructor(address hubAddress) public {
		require(hubAddress != address(0));
		hub = ContractHub(hubAddress);
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
	public onlyContracts {
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
	function setProfile_token_amount_per_byte_minute(address wallet, uint256 token_amount_per_byte_minute) public onlyContracts {
 		if(profile[wallet].token_amount_per_byte_minute != token_amount_per_byte_minute)
		profile[wallet].token_amount_per_byte_minute = token_amount_per_byte_minute;
 	}
 	function setProfile_stake_amount_per_byte_minute(address wallet, uint256 stake_amount_per_byte_minute) public onlyContracts {
 		if(profile[wallet].stake_amount_per_byte_minute != stake_amount_per_byte_minute)
		profile[wallet].stake_amount_per_byte_minute = stake_amount_per_byte_minute;
 	}
 	function setProfile_read_stake_factor(address wallet, uint256 read_stake_factor) public onlyContracts {
 		if(profile[wallet].read_stake_factor != read_stake_factor)
		profile[wallet].read_stake_factor = read_stake_factor;
 	}
 	function setProfile_balance(address wallet, uint256 balance) public onlyContracts {
 		if(profile[wallet].balance != balance)
		profile[wallet].balance = balance;
 	}
 	function setProfile_reputation(address wallet, uint256 reputation) public onlyContracts {
 		if(profile[wallet].reputation != reputation)
		profile[wallet].reputation = reputation;
 	}
 	function setProfile_number_of_escrows(address wallet, uint256 number_of_escrows) public onlyContracts {
 		if(profile[wallet].number_of_escrows != number_of_escrows)
		profile[wallet].number_of_escrows = number_of_escrows;
 	}
 	function setProfile_max_escrow_time_in_minutes(address wallet, uint256 max_escrow_time_in_minutes) public onlyContracts {
 		if(profile[wallet].max_escrow_time_in_minutes != max_escrow_time_in_minutes)
		profile[wallet].max_escrow_time_in_minutes = max_escrow_time_in_minutes;
 	}
 	function setProfile_active(address wallet, bool active) public onlyContracts {
 		if(profile[wallet].active != active)
		profile[wallet].active = active;
 	}

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