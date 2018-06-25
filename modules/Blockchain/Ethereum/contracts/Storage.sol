pragma solidity ^0.4.22;

contract ContractHub {
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

	function setBalance(address wallet, uint newBalance) public onlyContracts {
		if(profile[wallet].balance != newBalance) profile[wallet].balance = newBalance;
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

		uint replication_factor;

		bool active;
		bool finalized;

		// uint256 offer_creation_timestamp;

		BidDefinition[] bid;
	}
	mapping(bytes32 => OfferDefinition) public offer; // offer[import_id]

	function setOffer(
		bytes32 import_id,
		address DC_wallet,
		uint max_token_amount_per_DH,
		uint min_stake_amount_per_DH,
		uint min_reputation,
		uint total_escrow_time_in_minutes,
		uint data_size_in_bytes,
		uint litigation_interval_in_minutes,
		bytes32 data_hash,
		uint first_bid_index,
		uint replication_factor,
		bool active,
		bool finalized )
	// uint256 offer_creation_timestamp)
	public onlyContracts {
		if(offer[import_id].DC_wallet != DC_wallet)
		offer[import_id].DC_wallet = DC_wallet;

		if(offer[import_id].max_token_amount_per_DH != max_token_amount_per_DH)
		offer[import_id].max_token_amount_per_DH = max_token_amount_per_DH;


		if(offer[import_id].min_stake_amount_per_DH != min_stake_amount_per_DH)
		offer[import_id].min_stake_amount_per_DH = min_stake_amount_per_DH;


		if(offer[import_id].min_reputation != min_reputation)
		offer[import_id].min_reputation = min_reputation;


		if(offer[import_id].total_escrow_time_in_minutes != total_escrow_time_in_minutes)
		offer[import_id].total_escrow_time_in_minutes = total_escrow_time_in_minutes;


		if(offer[import_id].data_size_in_bytes != data_size_in_bytes)
		offer[import_id].data_size_in_bytes = data_size_in_bytes;


		if(offer[import_id].litigation_interval_in_minutes != litigation_interval_in_minutes)
		offer[import_id].litigation_interval_in_minutes = litigation_interval_in_minutes;


		if(offer[import_id].data_hash != data_hash)
		offer[import_id].data_hash = data_hash;


		if(offer[import_id].first_bid_index != first_bid_index)
		offer[import_id].first_bid_index = first_bid_index;

		if(offer[import_id].replication_factor != replication_factor)
		offer[import_id].replication_factor = replication_factor;

		if(offer[import_id].active != active)
		offer[import_id].active = active;

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

		uint next_bid;

		bool active;
		bool chosen;
	}

	function setBid(
		bytes32 import_id,
		uint256 bid_index,
		address DH_wallet,
		bytes32 DH_node_id,
		uint token_amount_for_escrow,
		uint stake_amount_for_escrow,
		uint256 ranking,
		uint next_bid,
		bool active,
		bool chosen )
	public onlyContracts{
		if(offer[import_id].bid[bid_index].DH_wallet != DH_wallet)
		offer[import_id].bid[bid_index].DH_wallet = DH_wallet;

		if(offer[import_id].bid[bid_index].DH_node_id != DH_node_id)
		offer[import_id].bid[bid_index].DH_node_id = DH_node_id;

		if(offer[import_id].bid[bid_index].token_amount_for_escrow != token_amount_for_escrow)
		offer[import_id].bid[bid_index].token_amount_for_escrow = token_amount_for_escrow;

		if(offer[import_id].bid[bid_index].stake_amount_for_escrow != stake_amount_for_escrow)
		offer[import_id].bid[bid_index].stake_amount_for_escrow = stake_amount_for_escrow;

		if(offer[import_id].bid[bid_index].ranking != ranking)
		offer[import_id].bid[bid_index].ranking = ranking;

		if(offer[import_id].bid[bid_index].next_bid != next_bid)
		offer[import_id].bid[bid_index].next_bid = next_bid;

		if(offer[import_id].bid[bid_index].active != active)
		offer[import_id].bid[bid_index].active = active;

		if(offer[import_id].bid[bid_index].chosen != chosen)
		offer[import_id].bid[bid_index].chosen = chosen;

		emit BidChange(import_id,bid_index);
	}

	function addBid(
		bytes32 import_id,
		address DH_wallet,
		bytes32 DH_node_id,
		uint token_amount_for_escrow,
		uint stake_amount_for_escrow,
		uint256 ranking,
		uint next_bid,
		bool active,
		bool chosen)
	public onlyContracts {
		offer[import_id].bid.push(new Bid(DH_wallet, DH_node_id, token_amount_for_escrow, stake_amount_for_escrow, ranking, next_bid, active, chosen))
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


	
}