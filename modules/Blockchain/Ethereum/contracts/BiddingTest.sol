pragma solidity ^0.4.18;

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

contract EscrowHolder {
	function initiateEscrow(address DC_wallet, address DH_wallet, bytes32 import_id, uint token_amount, uint stake_amount, uint total_time_in_minutes, uint litigation_interval_in_minutes) public;
}

contract ContractHub{
	address public fingerprintAddress;
	address public tokenAddress;
	address public biddingAddress;
	address public escrowAddress;
	address public readingAddress;
}

contract StorageContract {

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
		uint token_amount_per_byte_minute, uint stake_amount_per_byte_minute, uint read_stake_factor,
		uint balance, uint reputation, uint number_of_escrows, uint max_escrow_time_in_minutes, bool active) 
	public;

	function setBalance(address wallet, uint newBalance);

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

	function setOffer(
		bytes32 import_id, address DC_wallet,
		uint max_token_amount_per_DH, uint min_stake_amount_per_DH, uint min_reputation,
		uint total_escrow_time_in_minutes, uint data_size_in_bytes, uint litigation_interval_in_minutes,
		bytes32 data_hash, uint first_bid_index, uint bid_array_length, uint replication_factor,
		uint256 offer_creation_timestamp, bool active, bool finalized)
	public;

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
	mapping(bytes32 => mapping (uint256 => BidDefinition ) ) public bid; // bid[import_id][bid_index]

	function setBid(
		bytes32 import_id, uint256 bid_index,
		address DH_wallet, bytes32 DH_node_id,
		uint token_amount_for_escrow, uint stake_amount_for_escrow,
		uint256 ranking, uint next_bid, bool active, bool chosen)
	public;
}
contract BiddingTest {
	using SafeMath for uint256;

	ContractHub public hub;
	StorageContract public Storage;
	uint256 activated_nodes;

	constructor(address hub_address, address storage_address)
	public{
		require (hub_address != address(0) && storage_address != address(0));
		hub = ContractHub(hub_address);
		Storage = StorageContract(storage_address);
		activated_nodes = 0;
	}

	/*    ----------------------------- EVENTS -----------------------------     */


	event OfferCreated(bytes32 import_id, bytes32 DC_node_id, 
		uint total_escrow_time_in_minutes, uint max_token_amount_per_DH, uint min_stake_amount_per_DH, uint min_reputation, 
		uint data_size_in_bytes, bytes32 data_hash, uint litigation_interval_in_minutes);
	event OfferCanceled(bytes32 import_id);
	event AddedBid(bytes32 import_id, address DH_wallet, bytes32 DH_node_id, uint bid_index);
	event AddedPredeterminedBid(bytes32 import_id, address DH_wallet, bytes32 DH_node_id, uint bid_index, 
		uint total_escrow_time_in_minutes, uint max_token_amount_per_DH, uint min_stake_amount_per_DH,
		uint data_size_in_bytes, uint litigation_interval_in_minutes);
	event FinalizeOfferReady(bytes32 import_id);
	event BidTaken(bytes32 import_id, address DH_wallet);
	event OfferFinalized(bytes32 import_id);

	/*    ----------------------------- OFFERS -----------------------------     */

	function createOffer(
		bytes32 import_id,
		bytes32 DC_node_id,

		uint total_escrow_time_in_minutes, 
		uint max_token_amount_per_DH,
		uint min_stake_amount_per_DH,
		uint min_reputation,

		bytes32 data_hash,
		uint data_size_in_bytes,
		uint litigation_interval_in_minutes,

		address[] predetermined_DH_wallet,
		bytes32[] predetermined_DH_node_id)
	public {
		( , , , , , , , , , , , , bool s_active, ) = Storage.offer(import_id);

		require(s_active == false);
		require(max_token_amount_per_DH > 0 && total_escrow_time_in_minutes > 0 && data_size_in_bytes > 0);

		(, , , uint DC_balance, , , , ) = Storage.profile(msg.sender);
		require(DC_balance >= max_token_amount_per_DH.mul(predetermined_DH_wallet.length.mul(2).add(1)));
		
		DC_balance = DC_balance.sub(max_token_amount_per_DH.mul(predetermined_DH_wallet.length.mul(2).add(1)));
		Storage.setBalance(msg.sender, DC_balance);
		emit BalanceModified(msg.sender, DC_balance);

		// this_offer.DC_wallet = msg.sender;

		// this_offer.total_escrow_time_in_minutes = total_escrow_time_in_minutes;
		// this_offer.max_token_amount_per_DH = max_token_amount_per_DH;
		// this_offer.min_stake_amount_per_DH = min_stake_amount_per_DH;
		// this_offer.min_reputation = min_reputation;

		// this_offer.data_hash = data_hash;
		// this_offer.data_size_in_bytes = data_size_in_bytes;

		// this_offer.replication_factor = predetermined_DH_wallet.length;

		// this_offer.active = true;
		// this_offer.finalized = false;

		// this_offer.first_bid_index = uint(-1);
		// this_offer.offer_creation_timestamp = block.timestamp;

		//Writing the predetermined DC into the bid list
		for(uint256 i = 0; i < predetermined_DH_wallet.length; i = i + 1) {
			Storage.setBid(import_id, i, predetermined_DH_wallet[i], predetermined_DH_node_id[i], 0, 0, 0, 0, false, false);
			// BidDefinition memory bid_def = BidDefinition(predetermined_DH_wallet[this_offer.bid.length], predetermined_DH_node_id[this_offer.bid.length], 0, 0, 0, 0, false, false);
			// this_offer.bid.push(bid_def);
			emit AddedPredeterminedBid(import_id, predetermined_DH_wallet[i], predetermined_DH_node_id[i], i, 
				total_escrow_time_in_minutes, max_token_amount_per_DH, min_stake_amount_per_DH, 
				data_size_in_bytes, litigation_interval_in_minutes);
		}

		Storage.setOffer(import_id, msg.sender, max_token_amount_per_DH, min_stake_amount_per_DH, min_reputation,
			total_escrow_time_in_minutes, data_size_in_bytes, litigation_interval_in_minutes, data_hash, uint(-1),
			predetermined_DH_wallet.length, predetermined_DH_wallet.length, block.timestamp, true, false);

		emit OfferCreated(import_id, DC_node_id, total_escrow_time_in_minutes, 
			max_token_amount_per_DH, min_stake_amount_per_DH, min_reputation,
			data_size_in_bytes, data_hash, litigation_interval_in_minutes);
	}

	function cancelOffer(bytes32 import_id)
	public{
		// OfferDefinition storage this_offer = offer[import_id];
		(address s_DC_wallet, uint s_max_token_amount_per_DH, uint s_min_stake_amount_per_DH, uint s_min_reputation,
			uint s_total_escrow_time_in_minutes, uint s_data_size_in_bytes, uint s_litigation_interval_in_minutes, bytes32 s_data_hash,
			uint s_first_bid_index, uint s_bid_array_length, uint s_replication_factor, uint s_timestamp, bool s_active, bool s_finalized) = Storage.offer(import_id);

		require(s_active && s_DC_wallet == msg.sender && s_finalized == false);
		s_active = false;

		// Returns the alloted token amount back to DC
		uint max_total_token_amount = s_max_token_amount_per_DH.mul(s_replication_factor.mul(2).add(1));
		(, , , uint DC_balance, , , , ) = Storage.profile(msg.sender);
		DC_balance = DC_balance.add(max_total_token_amount);
		Storage.setBalance(msg.sender, DC_balance);

		Storage.setOffer(import_id, s_DC_wallet, s_max_token_amount_per_DH, s_min_stake_amount_per_DH, s_min_reputation,
			s_total_escrow_time_in_minutes, s_data_size_in_bytes, s_litigation_interval_in_minutes, s_data_hash,
			s_first_bid_index, s_bid_array_length, s_replication_factor,s_timestamp, false, s_finalized);
		emit OfferCanceled(import_id);
	}

	function activatePredeterminedBid(bytes32 import_id, bytes32 DH_node_id, uint bid_index)
	public{
		(address s_DC_wallet, uint s_max_token_amount_per_DH, uint s_min_stake_amount_per_DH, uint s_min_reputation,
			uint s_total_escrow_time_in_minutes, uint s_data_size_in_bytes, uint s_litigation_interval_in_minutes, bytes32 s_data_hash,
			uint s_first_bid_index, uint s_bid_array_length, uint s_replication_factor, uint s_timestamp, bool s_active, bool s_finalized) = Storage.offer(import_id);

		require(s_active && !s_finalized);

		(address b_DH_wallet, bytes32 b_DH_node_id, uint b_token_amount_for_escrow, uint b_stake_amount_for_escrow, 
			uint b_ranking, uint b_next_bid, bool b_active, bool b_chosen) = Storage.bid(import_id, bid_index);
		require(b_DH_wallet == msg.sender && b_DH_node_id == DH_node_id);

		(uint p_token_amount_per_byte_minute, uint p_stake_amount_per_byte_minute, uint p_read_stake_factor, 
			uint p_balance, uint p_reputation, uint p_number_of_escrows, uint p_max_escrow_time_in_minutes, bool p_active) = Storage.profile(msg.sender);

		//Check if the the DH meets the filters DC set for the offer
		uint scope = s_data_size_in_bytes * s_total_escrow_time_in_minutes;
		require(s_total_escrow_time_in_minutes <= p_max_escrow_time_in_minutes);
		require(s_max_token_amount_per_DH  >= p_token_amount_per_byte_minute * scope);
		require((s_min_stake_amount_per_DH  <= p_stake_amount_per_byte_minute * scope) && (p_stake_amount_per_byte_minute * scope <= p_balance));

		//Write the required data for the bid
		Storage.setBid(import_id, bid_index, b_DH_wallet, b_DH_node_id, 
			p_token_amount_per_byte_minute.mul(scope), p_stake_amount_per_byte_minute.mul(scope),
			0, 0, true, false);
		// this_bid.token_amount_for_escrow = p_token_amount_per_byte_minute * scope;
		// this_bid.stake_amount_for_escrow = p_stake_amount_per_byte_minute * scope;
		// this_bid.active = true;
	}

	function getDistanceParameters(bytes32 import_id)
	public view returns (bytes32 node_hash, bytes32 data_hash, uint256 ranking, uint256 current_ranking, uint256 required_bid_amount, uint256 activated_nodes_){
		// OfferDefinition storage this_offer = offer[import_id];
		(address s_DC_wallet, uint s_max_token_amount_per_DH, uint s_min_stake_amount_per_DH, uint s_min_reputation,
			uint s_total_escrow_time_in_minutes, uint s_data_size_in_bytes, uint s_litigation_interval_in_minutes, bytes32 s_data_hash,
			uint s_first_bid_index, uint s_bid_array_length, uint s_replication_factor, uint s_timestamp, bool s_active, bool s_finalized) = Storage.offer(import_id);

		node_hash = bytes32(uint128(keccak256(msg.sender)));
		data_hash = bytes32(uint128(s_data_hash));


		ranking = calculateRanking(import_id, msg.sender);
		required_bid_amount = s_replication_factor.mul(2).add(1);
		activated_nodes_ = activated_nodes; // TODO Find a way to remove this

		if(s_first_bid_index == uint(-1)){
			current_ranking = 0;
		}
		else{
			uint256 current_index = s_first_bid_index;
			current_ranking = 0;
			(, , , , uint b_ranking, uint b_next_bid, , ) = Storage.bid(import_id, current_index);
			while(b_next_bid != uint(-1) && b_ranking >= ranking){
				// current_index = this_offer.bid[current_index].next_bid;
				(, , , , b_ranking, b_next_bid, , ) = Storage.bid(import_id, current_index);
				current_ranking++;
			}
		}
	}

	function addBid(bytes32 import_id, bytes32 DH_node_id)
	public returns (uint ranking){
		// OfferDefinition storage this_offer = offer[import_id];
		(address s_DC_wallet, uint s_max_token_amount_per_DH, uint s_min_stake_amount_per_DH, uint s_min_reputation,
			uint s_total_escrow_time_in_minutes, uint s_data_size_in_bytes, uint s_litigation_interval_in_minutes, bytes32 s_data_hash,
			uint s_first_bid_index, uint s_bid_array_length, uint s_replication_factor, uint s_timestamp, bool s_active, bool s_finalized) = Storage.offer(import_id);

		require(s_active && !s_finalized);

		// ProfileDefinition storage this_DH = profile[msg.sender];
		(uint p_token_amount_per_byte_minute, uint p_stake_amount_per_byte_minute, uint p_read_stake_factor, 
			uint p_balance, uint p_reputation, uint p_number_of_escrows, uint p_max_escrow_time_in_minutes, ) = Storage.profile(msg.sender);


		//Check if the the DH meets the filters DC set for the offer
		uint scope = s_data_size_in_bytes * s_total_escrow_time_in_minutes;
		require(s_total_escrow_time_in_minutes <= p_max_escrow_time_in_minutes);
		require(s_max_token_amount_per_DH  >= p_token_amount_per_byte_minute * scope);
		require((s_min_stake_amount_per_DH  <= p_stake_amount_per_byte_minute * scope) && (p_stake_amount_per_byte_minute * scope <= p_balance));
		require(s_min_reputation <= p_reputation);

		//Create new bid in the list
		// uint this_bid_index ;
		// BidDefinition memory new_bid = BidDefinition(msg.sender, DH_node_id, this_DH.token_amount_per_byte_minute * scope, this_DH.stake_amount_per_byte_minute * scope, 0, uint(-1), true, false);
		ranking = calculateRanking(import_id, msg.sender);
		uint this_bid_index = s_bid_array_length;
		uint next_bid_index;

		//Insert the bid in the proper place in the list
		if(s_first_bid_index == uint(-1)){
			s_first_bid_index = this_bid_index;
			Storage.setBid(import_id, this_bid_index, msg.sender, DH_node_id, 
				p_token_amount_per_byte_minute.mul(scope), p_stake_amount_per_byte_minute.mul(scope),
				uint(-1), ranking, true, false);
		}
		else{
			uint256 current_index = s_first_bid_index;
			uint256 previous_index = uint(-1);
			(, , , , uint b_ranking, uint b_next_bid, , ) = Storage.bid(import_id, current_index);
			if(b_ranking < ranking){
				s_first_bid_index = this_bid_index;
				next_bid_index = current_index;
				Storage.setBid(import_id, this_bid_index, msg.sender, DH_node_id, 
					p_token_amount_per_byte_minute.mul(scope), p_stake_amount_per_byte_minute.mul(scope),
					next_bid_index, ranking, true, false);
			}
			else {
				while(current_index != uint(-1) && b_ranking >= ranking){
					previous_index = current_index;
					current_index = b_next_bid;
					(, , , , b_ranking, b_next_bid, , ) = Storage.bid(import_id, current_index);
				}
				if(current_index == uint(-1)){
					// Set the bid[previous_bid_index].next_bid to this_bid_index
					(address t_DH_wallet, bytes32 t_DH_node_id, uint t_token_amount_for_escrow, uint t_stake_amount_for_escrow, 
						uint t_ranking, uint t_next_bid, bool t_active, bool t_chosen) = Storage.bid(import_id, previous_index);
					Storage.setBid(import_id, previous_index, t_DH_wallet, t_DH_node_id,
						t_token_amount_for_escrow, t_stake_amount_for_escrow, 
						t_ranking, this_bid_index, t_active, t_chosen);

					// Add new bid to storage
					Storage.setBid(import_id, this_bid_index, msg.sender, DH_node_id, 
						p_token_amount_per_byte_minute.mul(scope), p_stake_amount_per_byte_minute.mul(scope),
						uint(-1), ranking, true, false);
				}
				else{
					// Set the bid[previous_bid_index].next_bid to this_bid_index
					(t_DH_wallet, t_DH_node_id, t_token_amount_for_escrow, t_stake_amount_for_escrow, 
						t_ranking, t_next_bid, t_active, t_chosen) = Storage.bid(import_id, previous_index);
					Storage.setBid(import_id, previous_index, t_DH_wallet, t_DH_node_id, 
						t_token_amount_for_escrow, t_stake_amount_for_escrow, 
						t_ranking, this_bid_index, t_active, t_chosen);

					next_bid_index = current_index;
					// Add new bid to storage
					Storage.setBid(import_id, this_bid_index, msg.sender, DH_node_id, 
						p_token_amount_per_byte_minute.mul(scope), p_stake_amount_per_byte_minute.mul(scope),
						current_index, ranking, true, false);
				}
			}

		}

		// Update offer
		Storage.setOffer(import_id, s_DC_wallet, s_max_token_amount_per_DH, s_min_stake_amount_per_DH, s_min_reputation,
			s_total_escrow_time_in_minutes, s_data_size_in_bytes, s_litigation_interval_in_minutes, s_data_hash,
			s_first_bid_index, s_bid_array_length.add(1), s_replication_factor,s_timestamp,s_active, s_finalized);
		if(s_bid_array_length >= s_replication_factor.mul(3).add(1)) emit FinalizeOfferReady(import_id);

		emit AddedBid(import_id, msg.sender, DH_node_id, this_bid_index);
		// return this_bid_index;
	}

	function getBidIndex(bytes32 import_id, bytes32 DH_node_id) public view returns(uint256 index){
		// OfferDefinition storage this_offer = offer[import_id];
		( , , , , , , , , , uint s_bid_array_length, , , , ) = Storage.offer(import_id);

		index = 0;
		(address t_DH_wallet, bytes32 t_DH_node_id,  ,  ,  ,  ,  ,  ) = Storage.bid(import_id, index);
		while(index < s_bid_array_length && (t_DH_wallet != msg.sender || t_DH_node_id != DH_node_id)){
			index = index + 1;
			(t_DH_wallet, t_DH_node_id,  ,  ,  ,  ,  ,  ) = Storage.bid(import_id, index);
		}
		if( index == s_bid_array_length) return uint(-1);
	}

	function cancelBid(bytes32 import_id, uint bid_index)
	public{
		(address b_DH_wallet, bytes32 b_DH_node_id, uint b_token_amount_for_escrow, uint b_stake_amount_for_escrow, 
			uint b_ranking, uint b_next_bid, bool b_active, bool b_chosen) = Storage.bid(import_id, bid_index);
		require(b_DH_wallet == msg.sender);
		b_active = false;
		Storage.setBid(import_id, bid_index, b_DH_wallet, b_DH_node_id, b_token_amount_for_escrow, b_stake_amount_for_escrow, 
			b_ranking, b_next_bid, b_active, b_chosen);
	}

	function chooseBids(bytes32 import_id) public returns (uint256[] chosen_data_holders){
		// OfferDefinition storage this_offer = offer[import_id];
		(address s_DC_wallet, uint s_max_token_amount_per_DH, uint s_min_stake_amount_per_DH, uint s_min_reputation,
			uint s_total_escrow_time_in_minutes, uint s_data_size_in_bytes, uint s_litigation_interval_in_minutes, bytes32 s_data_hash,
			uint s_first_bid_index, uint s_bid_array_length, uint s_replication_factor, uint s_timestamp, bool s_active, bool s_finalized) = Storage.offer(import_id);

		require(s_active && !s_finalized);
		require(s_replication_factor.mul(3).add(1) <= s_bid_array_length);
		require(s_timestamp + 5 seconds < block.timestamp); // TODO Vrati ovo na minute
		
		chosen_data_holders = new uint256[](s_replication_factor.mul(2).add(1));

		uint256 i;
		uint256 current_index = 0;

		uint256 token_amount_sent = 0;
		uint256 max_total_token_amount = s_max_token_amount_per_DH.mul(s_replication_factor.mul(2).add(1));

		EscrowHolder escrow = EscrowHolder(hub.escrowAddress());
		
		//Sending escrow requests to predetermined bids
		for(i = 0; i < s_replication_factor; i = i + 1){
			(address b_DH_wallet, bytes32 b_DH_node_id, uint b_token_amount_for_escrow, uint b_stake_amount_for_escrow, 
				uint b_ranking, uint b_next_bid, bool b_active, bool b_chosen) = Storage.bid(import_id, bid_index);

			(uint p_token_amount_per_byte_minute, uint p_stake_amount_per_byte_minute, uint p_read_stake_factor, 
				uint p_balance, uint p_reputation, uint p_number_of_escrows, uint p_max_escrow_time_in_minutes, bool p_active) = Storage.profile(b_DH_wallet);				

			if(p_balance >= b_stake_amount_for_escrow && b_active){
				//Initiating new escrow
				escrow.initiateEscrow(msg.sender, b_DH_wallet, import_id, b_token_amount_for_escrow, b_stake_amount_for_escrow, s_total_escrow_time_in_minutes, s_litigation_interval_in_minutes);

				token_amount_sent = token_amount_sent.add(b_token_amount_for_escrow);


				Storage.setBid(import_id, i, b_DH_wallet, b_DH_node_id, b_token_amount_for_escrow, b_stake_amount_for_escrow, 
					b_ranking, b_next_bid, b_active, true);
				chosen_data_holders[current_index] = i;
				current_index = current_index + 1;

				emit BidTaken(import_id, b_DH_wallet);
			}
		}		

		//Sending escrow requests to network bids
		uint256 bid_index = s_first_bid_index;
		while(current_index < s_replication_factor.mul(2).add(1)) {
			(b_DH_wallet, b_DH_node_id, b_token_amount_for_escrow, b_stake_amount_for_escrow, 
				b_ranking, b_next_bid, b_active, b_chosen) = Storage.bid(import_id, bid_index);

			while(bid_index != uint(-1) && !b_active){
				bid_index = b_next_bid;
				(b_DH_wallet, b_DH_node_id, b_token_amount_for_escrow, b_stake_amount_for_escrow, 
					b_ranking, b_next_bid, b_active, b_chosen) = Storage.bid(import_id, bid_index);
			} 

			if(bid_index == uint(-1)) break;

			(p_token_amount_per_byte_minute, p_stake_amount_per_byte_minute, p_read_stake_factor, 
				p_balance, p_reputation, p_number_of_escrows, p_max_escrow_time_in_minutes, p_active) = Storage.profile(b_DH_wallet);

			if(p_balance >= b_stake_amount_for_escrow){
				//Initiating new escrow
				escrow.initiateEscrow(msg.sender, b_DH_wallet, import_id, b_token_amount_for_escrow, b_stake_amount_for_escrow, s_total_escrow_time_in_minutes, s_litigation_interval_in_minutes);

				token_amount_sent = token_amount_sent.add(b_token_amount_for_escrow);

				// Set bid to chosen
				Storage.setBid(import_id, bid_index, b_DH_wallet, b_DH_node_id, b_token_amount_for_escrow, b_stake_amount_for_escrow, 
					b_ranking, b_next_bid, b_active, true);

				chosen_data_holders[current_index] = bid_index;
				current_index = current_index + 1;
				bid_index = b_next_bid;

				emit BidTaken(import_id, b_DH_wallet);
			}
			else{
				// Set bid to inactive
				Storage.setBid(import_id, bid_index, b_DH_wallet, b_DH_node_id, b_token_amount_for_escrow, b_stake_amount_for_escrow, 
					b_ranking, b_next_bid, false, b_chosen);
			}
		}

		// Update offer (set finalized flag to true)
		Storage.setOffer(import_id, s_DC_wallet, s_max_token_amount_per_DH, s_min_stake_amount_per_DH, s_min_reputation,
			s_total_escrow_time_in_minutes, s_data_size_in_bytes, s_litigation_interval_in_minutes, s_data_hash,
			s_first_bid_index, s_bid_array_length, s_replication_factor,s_timestamp,s_active, true);

		// Return the unused tokens back to DC
		(, , , uint DC_balance, , , , ) = Storage.profile(msg.sender);
		DC_balance = DC_balance.add(max_total_token_amount.sub(token_amount_sent));
		Storage.setBalance(msg.sender, DC_balance);
		emit BalanceModified(msg.sender, DC_balance);
		
		emit OfferFinalized(import_id); 
	}

	/*    ----------------------------- PROFILE -----------------------------    */

	event ProfileCreated(address wallet);
	event BalanceModified(address wallet, uint new_balance);
	event ReputationModified(address wallet, uint new_balance);

	function createProfile(bytes32 node_id, uint price_per_byte_minute, uint stake_per_byte_minute, uint read_stake_factor, uint max_time_in_minutes) public{
		(uint p_token_amount_per_byte_minute, uint p_stake_amount_per_byte_minute, uint p_read_stake_factor, 
			uint p_balance, uint p_reputation, uint p_number_of_escrows, uint p_max_escrow_time_in_minutes, bool p_active) = Storage.profile(msg.sender);

		Storage.setProfile(msg.sender, price_per_byte_minute, stake_per_byte_minute, read_stake_factor, 
			p_balance, p_reputation, p_number_of_escrows, max_time_in_minutes, true);

		activated_nodes = activated_nodes.add(1);

		emit ProfileCreated(msg.sender);
	}

	function setPrice(uint new_price_per_byte_minute) public {
		(uint p_token_amount_per_byte_minute, uint p_stake_amount_per_byte_minute, uint p_read_stake_factor, 
			uint p_balance, uint p_reputation, uint p_number_of_escrows, uint p_max_escrow_time_in_minutes, bool p_active) = Storage.profile(msg.sender);

		Storage.setProfile(msg.sender, new_price_per_byte_minute, p_stake_amount_per_byte_minute, p_read_stake_factor, 
			p_balance, p_reputation, p_number_of_escrows, p_max_escrow_time_in_minutes, true);
	}

	function setStake(uint new_stake_per_byte_minute) public {
		(uint p_token_amount_per_byte_minute, uint p_stake_amount_per_byte_minute, uint p_read_stake_factor, 
			uint p_balance, uint p_reputation, uint p_number_of_escrows, uint p_max_escrow_time_in_minutes, bool p_active) = Storage.profile(msg.sender);

		Storage.setProfile(msg.sender, p_token_amount_per_byte_minute, new_stake_per_byte_minute, p_read_stake_factor, 
			p_balance, p_reputation, p_number_of_escrows, p_max_escrow_time_in_minutes, true);
	}

	function setMaxTime(uint new_max_time_in_minutes) public {
		(uint p_token_amount_per_byte_minute, uint p_stake_amount_per_byte_minute, uint p_read_stake_factor, 
			uint p_balance, uint p_reputation, uint p_number_of_escrows, uint p_max_escrow_time_in_minutes, bool p_active) = Storage.profile(msg.sender);

		Storage.setProfile(msg.sender, p_token_amount_per_byte_minute, p_stake_amount_per_byte_minute, p_read_stake_factor, 
			p_balance, p_reputation, p_number_of_escrows, new_max_time_in_minutes, true);
	}

	function depositToken(uint amount) public {
		require(token.balanceOf(msg.sender) >= amount && token.allowance(msg.sender, this) >= amount);
		uint amount_to_transfer = amount;
		amount = 0;
		if(amount_to_transfer > 0) {
			ERC20 token = ERC20(hub.tokenAddress());
			token.transferFrom(msg.sender, this, amount_to_transfer);
			(, , , uint balance, , , , ) = Storage.profile(msg.sender);
			balance = balance.add(amount_to_transfer);
			Storage.setBalance(msg.sender, balance);
			emit BalanceModified(msg.sender, balance);
		}
	}

	function withdrawToken(uint amount) public {
		uint256 amount_to_transfer;

		(, , , uint balance, , , , ) = Storage.profile(msg.sender);

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
			Storage.setBalance(msg.sender, balance);
			emit BalanceModified(msg.sender, balance);
		} 
	}

	function absoluteDifference(uint256 a, uint256 b) public pure returns (uint256) {
		if (a > b) return a-b;
		else return b-a;
	}

	function log2(uint x) internal pure returns (uint y){
		require(x > 0);
		assembly {
			let arg := x
			x := sub(x,1)
			x := or(x, div(x, 0x02))
			x := or(x, div(x, 0x04))
			x := or(x, div(x, 0x10))
			x := or(x, div(x, 0x100))
			x := or(x, div(x, 0x10000))
			x := or(x, div(x, 0x100000000))
			x := or(x, div(x, 0x10000000000000000))
			x := or(x, div(x, 0x100000000000000000000000000000000))
			x := add(x, 1)
			let m := mload(0x40)
			mstore(m,           0xf8f9cbfae6cc78fbefe7cdc3a1793dfcf4f0e8bbd8cec470b6a28a7a5a3e1efd)
			mstore(add(m,0x20), 0xf5ecf1b3e9debc68e1d9cfabc5997135bfb7a7a3938b7b606b5b4b3f2f1f0ffe)
			mstore(add(m,0x40), 0xf6e4ed9ff2d6b458eadcdf97bd91692de2d4da8fd2d0ac50c6ae9a8272523616)
			mstore(add(m,0x60), 0xc8c0b887b0a8a4489c948c7f847c6125746c645c544c444038302820181008ff)
			mstore(add(m,0x80), 0xf7cae577eec2a03cf3bad76fb589591debb2dd67e0aa9834bea6925f6a4a2e0e)
			mstore(add(m,0xa0), 0xe39ed557db96902cd38ed14fad815115c786af479b7e83247363534337271707)
			mstore(add(m,0xc0), 0xc976c13bb96e881cb166a933a55e490d9d56952b8d4e801485467d2362422606)
			mstore(add(m,0xe0), 0x753a6d1b65325d0c552a4d1345224105391a310b29122104190a110309020100)
			mstore(0x40, add(m, 0x100))
			let magic := 0x818283848586878898a8b8c8d8e8f929395969799a9b9d9e9faaeb6bedeeff
			let shift := 0x100000000000000000000000000000000000000000000000000000000000000
			let a := div(mul(x, magic), shift)
			y := div(mload(add(m,sub(255,a))), shift)
			y := add(y, mul(256, gt(arg, 0x8000000000000000000000000000000000000000000000000000000000000000)))
		}
	}

	
	// corrective_factor = 10^10;
	// DH_stake = 10^20
	// min_stake_amount_per_DH = 10^18
	// data_hash = 1234567890
	// DH_node_id = 123456789011
	// max_token_amount_per_DH = 100000000
	// token_amount = 10000
	// min_reputation = 10
	// reputation = 60
	// hash_difference = abs(data_hash - DH_node_id)
	// hash_f = (data_hash * (2^128)) / (hash_difference + data_hash)
	// price_f = corrective_factor - ((corrective_factor * token_amount) / max_token_amount_per_DH)
	// stake_f = (corrective_factor - ((min_stake_amount_per_DH * corrective_factor) / DH_stake)) * data_hash / (hash_difference + data_hash)
	// rep_f = (corrective_factor - (min_reputation * corrective_factor / reputation))
	// distance = ((hash_f * (corrective_factor + price_f + stake_`f + rep_f)) / 4) / corrective_factor 

	// Constant values used for distance calculation
	uint256 corrective_factor = 10**10;

	function calculateRanking(bytes32 import_id, address DH_wallet)
	public view returns (uint256 ranking) {
		// OfferDefinition storage this_offer = offer[import_id];
		(address s_DC_wallet, uint s_max_token_amount_per_DH, uint s_min_stake_amount_per_DH, uint s_min_reputation,
			uint s_total_escrow_time_in_minutes, uint s_data_size_in_bytes, uint s_litigation_interval_in_minutes, bytes32 s_data_hash,
			uint s_first_bid_index, uint s_bid_array_length, uint s_replication_factor, uint s_timestamp, bool s_active, bool s_finalized) = Storage.offer(import_id);

		// ProfileDefinition storage this_DH = profile[DH_wallet];
		(uint p_token_amount_per_byte_minute, uint p_stake_amount_per_byte_minute, uint p_read_stake_factor, 
			uint p_balance, uint p_reputation, uint p_number_of_escrows, uint p_max_escrow_time_in_minutes, bool p_active) = Storage.profile(msg.sender);


		uint256 stake_amount;
		if (p_stake_amount_per_byte_minute == 0) stake_amount = 1;
		else stake_amount = p_stake_amount_per_byte_minute * s_total_escrow_time_in_minutes.mul(s_data_size_in_bytes);
		uint256 token_amount = p_token_amount_per_byte_minute * s_total_escrow_time_in_minutes.mul(s_data_size_in_bytes);

		uint256 reputation;
		if(p_number_of_escrows == 0 || p_reputation == 0) reputation = 1;
		else reputation = (log2(p_reputation / p_number_of_escrows) * corrective_factor / 115) / (corrective_factor / 100);
		if(reputation == 0) reputation = 1;

		uint256 hash_difference = absoluteDifference(uint256(uint128(s_data_hash)), uint256(uint128(keccak256(DH_wallet))));

		uint256 hash_f = ((uint256(uint128(s_data_hash)) * (2**128)) / (hash_difference + uint256(uint128(s_data_hash))));
		uint256 price_f = corrective_factor - ((corrective_factor * token_amount) / s_max_token_amount_per_DH);
		uint256 stake_f = ((corrective_factor - ((s_min_stake_amount_per_DH * corrective_factor) / stake_amount)) * uint256(uint128(s_data_hash))) / (hash_difference + uint256(uint128(s_data_hash)));
		uint256 rep_f = (corrective_factor - (s_min_reputation * corrective_factor / reputation));
		ranking = ((hash_f * (corrective_factor + price_f + stake_f + rep_f)) / 4) / corrective_factor;
	}
}