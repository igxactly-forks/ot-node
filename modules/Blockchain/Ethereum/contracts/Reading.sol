pragma solidity ^0.4.21;

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

contract Bidding{
    function increaseBalance(address wallet, uint amount) public;
    function decreaseBalance(address wallet, uint amount) public;
    function getBalance(address wallet) public view returns (uint256);
    function getReadStakeFactor(address wallet)	public view returns (uint256);
}

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
    function Ownable () public {
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

contract StorageContract{
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

    function setProfile( address wallet, 
        uint token_amount_per_byte_minute, uint stake_amount_per_byte_minute, uint read_stake_factor,
        uint balance, uint reputation, uint number_of_escrows,
        uint max_escrow_time_in_minutes, bool active) public;
    struct PurchasedDataDefinition {
        address DC_wallet;
        bytes32 distribution_root_hash;
        uint256 checksum;
    }
    mapping(bytes32 => mapping(address => PurchasedDataDefinition)) public purchased_data; // purchased_data[import_id][DH_wallet]
    function setPurchasedData( bytes32 import_id, address DH_wallet, address DC_wallet, bytes32 distribution_root_hash, uint256 checksum ) public;

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
    function setPurchase( address DH_wallet, address DV_wallet, bytes32 import_id,
        uint token_amount, uint stake_factor, uint dispute_interval_in_minutes,
        bytes32 commitment, uint256 encrypted_block, uint256 time_of_sending, PurchaseStatus purchase_status) public;
}

contract Reading is Ownable{
    using SafeMath for uint256;

    Bidding bidding;
    address escrow;

    StorageContract public Storage;

    enum Storage.PurchaseStatus {inactive, initiated, commited, confirmed, sent, disputed, cancelled, completed}

    struct PurchaseDefinition{
        uint token_amount;
        uint stake_factor;

        bytes32 commitment;
        uint256 encrypted_block;

        uint256 time_of_sending;

        Storage.PurchaseStatus purchase_status;
    }

    struct PurchasedDataDefinition {
        address DC_wallet;
        bytes32 distribution_root_hash;
        uint256 checksum;
    }

    // mapping(bytes32 => mapping(address => PurchasedDataDefinition)) public purchased_data;
    // mapping(address => mapping(address => mapping(bytes32 => PurchaseDefinition))) public purchase;

    event PurchaseInitiated(bytes32 import_id, address DH_wallet, address DV_wallet);
    event CommitmentSent(bytes32 import_id, address DH_wallet, address DV_wallet);
    event PurchaseConfirmed(bytes32 import_id, address DH_wallet, address DV_wallet);
    event PurchaseCancelled(bytes32 import_id, address DH_wallet, address DV_wallet);
    event EncryptedBlockSent(bytes32 import_id, address DH_wallet, address DV_wallet);
    event PurchaseDisputed(bytes32 import_id, address DH_wallet, address DV_wallet);
    event PurchaseDisputeCompleted(bytes32 import_id, address DH_wallet, address DV_wallet, bool proof_was_correct);

    function Reading(address escrow_address)
    public {
        require(escrow_address != address(0));
        escrow = escrow_address;
    }

    function setBidding(address bidding_address)
    public onlyOwner {
        require(bidding_address != address(0));
        bidding = Bidding(bidding_address);
    }

    function initiatePurchase(bytes32 import_id, address DH_wallet, uint token_amount)
    public {


        // PurchaseDefinition storage this_purchase = purchase[DH_wallet][msg.sender][import_id];
        (s_token_amount,s_stake_factor,s_dispute_interval_in_minutes,s_commitment,encrypted_block,s_time_of_sending,s_purchase_status) = Storage.purchase(DH_wallet,msg.sender,import_id);

        require(s_purchase_status == Storage.PurchaseStatus.inactive
            || 	s_purchase_status == Storage.PurchaseStatus.completed);

        uint256 DH_balance = bidding.getBalance(DH_wallet);
        uint256 DV_balance = bidding.getBalance(msg.sender);
        uint256 stake_factor = bidding.getReadStakeFactor(DH_wallet);
        uint256 stake_amount = token_amount.mul(stake_factor);
        require(DH_balance >= stake_amount && DV_balance >= token_amount.add(stake_amount));

        bidding.decreaseBalance(msg.sender, token_amount.add(stake_amount));

        // s_token_amount = token_amount;
        // s_stake_factor = stake_factor;
        // this_purchase.purchase_status = Storage.PurchaseStatus.initiated;

        Storage.setPurchase(DH_wallet,msg.sender,import_id,token_amount,stake_factor,s_dispute_interval_in_minutes,s_commitment,encrypted_block,s_time_of_sending,Storage.PurchaseStatus.initiated);

        emit PurchaseInitiated(import_id, DH_wallet, msg.sender);
    }

    function sendCommitment(bytes32 import_id, address DV_wallet, bytes32 commitment)
    public {


        // PurchaseDefinition storage this_purchase = purchase[msg.sender][DV_wallet][import_id];
        (s_token_amount,s_stake_factor,s_dispute_interval_in_minutes,s_commitment,encrypted_block,s_time_of_sending,s_purchase_status) = Storage.purchase(msg.sender,DV_wallet,import_id);

        require(s_purchase_status == Storage.PurchaseStatus.initiated);

        uint256 DH_balance = bidding.getBalance(msg.sender);
        require(DH_balance >= s_token_amount.mul(s_stake_factor));
        bidding.decreaseBalance(msg.sender, s_token_amount.mul(s_stake_factor));

        // s_commitment = commitment;
        // s_purchase_status = Storage.PurchaseStatus.commited;

        Storage.setPurchase(msg.sender,DV_wallet,import_id,s_token_amount,s_stake_factor,s_dispute_interval_in_minutes,commitment,s_encrypted_block,s_time_of_sending,Storage.PurchaseStatus.commited);
        emit CommitmentSent(import_id, msg.sender, DV_wallet);
    }

    function confirmPurchase(bytes32 import_id, address DH_wallet)
    public {

        // PurchaseDefinition storage this_purchase = purchase[DH_wallet][msg.sender][import_id];
        (s_token_amount,s_stake_factor,s_dispute_interval_in_minutes,s_commitment,encrypted_block,s_time_of_sending,s_purchase_status) = Storage.purchase(DH_wallet,msg.sender,import_id);
        require(s_purchase_status == Storage.PurchaseStatus.commited);


        // this_purchase.purchase_status = Storage.PurchaseStatus.confirmed;
        Storage.setPurchase(DH_wallet,msg.sender,import_id,s_token_amount,s_stake_factor,s_dispute_interval_in_minutes,s_commitment,s_encrypted_block,s_time_of_sending,Storage.PurchaseStatus.confirmed);
        emit PurchaseConfirmed(import_id, DH_wallet, msg.sender);
    }

    function cancelPurchase(bytes32 import_id, address correspondent_wallet, bool sender_is_DH)
    public {
        address DH_wallet;
        address DV_wallet;

        if (sender_is_DH  == true) {
            DH_wallet = msg.sender;
            DV_wallet = correspondent_wallet;
        }
        else{
            DH_wallet = correspondent_wallet;
            DV_wallet = msg.sender;
        }
        // PurchaseDefinition storage this_purchase = purchase[DH_wallet][DV_wallet][import_id];

        (s_token_amount,s_stake_factor,s_dispute_interval_in_minutes,s_commitment,encrypted_block,s_time_of_sending,s_purchase_status) = Storage.purchase(DH_wallet,DV_wallet,import_id);

        require(s_purchase_status == Storage.PurchaseStatus.initiated
            ||  s_purchase_status == Storage.PurchaseStatus.commited
            ||  s_purchase_status == Storage.PurchaseStatus.confirmed);

        bidding.increaseBalance(DV_wallet, s_token_amount.add(s_token_amount.mul(s_stake_factor)));
        if(s_purchase_status != Storage.PurchaseStatus.initiated){
            bidding.increaseBalance(DH_wallet, s_token_amount.mul(s_stake_factor));
        }

        // this_purchase.purchase_status = Storage.PurchaseStatus.cancelled;

        Storage.setPurchase(DH_wallet,DV_wallet,import_id,s_token_amount,s_stake_factor,s_dispute_interval_in_minutes,s_commitment,s_encrypted_block,s_time_of_sending,Storage.PurchaseStatus.cancelled);
        emit PurchaseCancelled(import_id, DH_wallet, DV_wallet);
    }

    function sendEncryptedBlock(bytes32 import_id, address DV_wallet, uint256 encrypted_block)
    public {
        // PurchaseDefinition storage this_purchase = purchase[msg.sender][DV_wallet][import_id];
        (s_token_amount,s_stake_factor,s_dispute_interval_in_minutes,s_commitment,encrypted_block,s_time_of_sending,s_purchase_status) = Storage.purchase(msg.sender,DV_wallet,import_id);
        require(s_purchase_status == Storage.PurchaseStatus.confirmed);

        // PurchasedDataDefinition storage this_purchased_data = purchased_data[import_id][DV_wallet];

        // PurchasedDataDefinition storage previous_purchase = purchased_data[import_id][msg.sender];
        (ps_DC_wallet,ps_distribution_root_hash,ps_checksum) = Storage.purchased_data(import_id,msg.sender);


        // this_purchase.encrypted_block = encrypted_block;
        // this_purchase.time_of_sending = block.timestamp;
        // this_purchase.purchase_status = Storage.PurchaseStatus.sent;


        // this_purchased_data.DC_wallet = previous_purchase.DC_wallet;
        // this_purchased_data.distribution_root_hash = previous_purchase.distribution_root_hash;
        // this_purchased_data.checksum = previous_purchase.checksum;

        Storage.setPurchase(msg.sender,DV_wallet,import_id,s_token_amount,s_stake_factor,s_dispute_interval_in_minutes,s_commitment,encrypted_block,block.timestamp,Storage.PurchaseStatus.sent);
        Storage.setPurchasedData(import_id,DV_wallet,ps_DC_wallet,ps_distribution_root_hash,ps_checksum);

        emit EncryptedBlockSent(import_id, msg.sender, DV_wallet);
    }

    function payOut(bytes32 import_id, address DV_wallet)
    public {
        (s_token_amount,s_stake_factor,s_dispute_interval_in_minutes,s_commitment,encrypted_block,s_time_of_sending,s_purchase_status) = Storage.purchase(msg.sender,DV_wallet,import_id);
        require(s_purchase_status == Storage.PurchaseStatus.sent);

        require(s_purchase_status == Storage.PurchaseStatus.sent
            &&  s_time_of_sending + s_dispute_interval_in_minutes minutes <= block.timestamp); // TODO check if variables can be converted into minutes

        bidding.increaseBalance(msg.sender, this_purchase.token_amount.mul(this_purchase.stake_factor).add(this_purchase.token_amount));
        bidding.increaseBalance(DV_wallet, this_purchase.token_amount.mul(this_purchase.stake_factor));

        Storage.setPurchase(msg.sender,DV_wallet,import_id,s_token_amount,s_stake_factor,s_dispute_interval_in_minutes,s_commitment,encrypted_block,block.timestamp,Storage.PurchaseStatus.completed);
    }

    function initiateDispute(bytes32 import_id, address DH_wallet)
    public {
        (s_token_amount,s_stake_factor,s_dispute_interval_in_minutes,s_commitment,encrypted_block,s_time_of_sending,s_purchase_status) = Storage.purchase(DH_wallet,msg.sender,import_id);

        require(s_purchase_status == Storage.PurchaseStatus.sent
            &&  s_time_of_sending + s_dispute_interval_in_minutes minutes >= block.timestamp);

        Storage.setPurchase(DH_wallet,msg.sender,import_id,s_token_amount,s_stake_factor,s_dispute_interval_in_minutes,s_commitment,encrypted_block,block.timestamp,Storage.PurchaseStatus.disputed);
        emit PurchaseDisputed(import_id, DH_wallet, msg.sender);
    }

    function sendProofData(bytes32 import_id, address DV_wallet,
        uint256 checksum_left, uint256 checksum_right, bytes32 checksum_hash,
        uint256 random_number_1, uint256 random_number_2,
        uint256 decryption_key, uint256 block_index)
    public {
        (s_token_amount,s_stake_factor,s_dispute_interval_in_minutes,s_commitment,encrypted_block,s_time_of_sending,s_purchase_status) = Storage.purchase(msg.sender,DV_wallet,import_id);

        bool commitment_proof = s_commitment == keccak256(checksum_left, checksum_right, checksum_hash, random_number_1, random_number_2, decryption_key, block_index);
        bool checksum_hash_proof =
        checksum_hash == keccak256(bytes32(checksum_left + uint256(keccak256(uint256(uint256(keccak256(decryption_key ^ s_encrypted_block)) - block_index - 1))) % (2**128) + random_number_1 + checksum_right - random_number_2));

        if(commitment_proof == true && checksum_hash_proof == true) {
            bidding.increaseBalance(msg.sender, this_purchase.token_amount.add(SafeMath.mul(this_purchase.token_amount,this_purchase.stake_factor)));
            emit PurchaseDisputeCompleted(import_id, msg.sender, DV_wallet, true);
        }
        else {
            bidding.increaseBalance(DV_wallet, this_purchase.token_amount.add(SafeMath.mul(this_purchase.token_amount,this_purchase.stake_factor)));
            emit PurchaseDisputeCompleted(import_id, msg.sender, DV_wallet, false);
        }
        Storage.setPurchase(msg.sender,DV_wallet,import_id,s_token_amount,s_stake_factor,s_dispute_interval_in_minutes,s_commitment,encrypted_block,block.timestamp,Storage.PurchaseStatus.completed);
    }
}
