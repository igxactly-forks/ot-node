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
			msg.sender == ContractHub.fingerprintAddress
			|| msg.sender == ContractHub.tokenAddress
			|| msg.sender == ContractHub.biddingAddress
			|| msg.sender == ContractHub.escrowAddress
			|| msg.sender == ContractHub.readingAddress);
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

	function setMyProfile(uint token_amount_per_byte_minute, uint stake_amount_per_byte_minute, 
		uint read_stake_factor, uint max_escrow_time_in_minutes) public {
		if(profile[msg.sender].token_amount_per_byte_minute != token_amount_per_byte_minute)
		profile[msg.sender].token_amount_per_byte_minute = token_amount_per_byte_minute;
		profile[msg.sender].stake_amount_per_byte_minute = stake_amount_per_byte_minute;
		profile[msg.sender].read_stake_factor = read_stake_factor;
		profile[msg.sender].max_escrow_time_in_minutes = max_escrow_time_in_minutes;
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
		profile[wallet] = ProfileDefinition(
		if(profile[wallet].token_amount_per_byte_minute != token_amount_per_byte_minute)
			profile[wallet].token_amount_per_byte_minute = token_amount_per_byte_minute;

			token_amount_per_byte_minute,
			stake_amount_per_byte_minute,
			read_stake_factor,
			balance,
			reputation,
			number_of_escrows,
			max_escrow_time_in_minutes,
			active
			);
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
		// uint litigation_interval_in_minutes;

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

	struct BidDefinition{
		address DH_wallet;
		bytes32 DH_node_id;

		uint token_amount_for_escrow;
		uint stake_amount_for_escrow;

		uint256 distance;

		uint next_bid;

		bool active;
		bool chosen;
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
		// uint litigation_interval_in_minutes;

		bytes32 litigation_root_hash;
		bytes32 distribution_root_hash;
		uint256 checksum;

		EscrowStatus escrow_status;
	}
	mapping(bytes32 => mapping(address => EscrowDefinition)) public escrow; // escrow[import_id][DH_wallet]


	struct PurchasedDataDefinition {
		address DC_wallet;
		bytes32 distribution_root_hash;
		uint256 checksum;
	}
	mapping(bytes32 => mapping(address => PurchasedDataDefinition)) public purchased_data; // purchased_data[import_id][DH_wallet]

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


	
}