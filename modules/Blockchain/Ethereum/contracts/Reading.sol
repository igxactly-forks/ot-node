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

contract ProfileStorage{
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
    function getProfile_token_amount_per_byte_minute(address wallet) public view returns(uint);
    function getProfile_stake_amount_per_byte_minute(address wallet) public view returns(uint);
    function getProfile_read_stake_factor(address wallet) public view returns(uint);
    function getProfile_balance(address wallet) public view returns(uint);
    function getProfile_reputation(address wallet) public view returns(uint);
    function getProfile_number_of_escrows(address wallet) public view returns(uint);
    function getProfile_max_escrow_time_in_minutes(address wallet) public view returns(uint);
    function getProfile_active(address wallet) public view returns(bool);
    function setProfile( address wallet,
        uint token_amount_per_byte_minute, uint stake_amount_per_byte_minute, uint read_stake_factor,
        uint balance, uint reputation, uint number_of_escrows,
        uint max_escrow_time_in_minutes, bool active) public;
    function setProfile_balance(address wallet, uint newBalance) public;
}
contract ReadingStorage{
    struct PurchasedDataDefinition {
        address DC_wallet;
        bytes32 distribution_root_hash;
        uint256 checksum;
    }
    mapping(bytes32 => mapping(address => PurchasedDataDefinition)) public purchased_data; // purchased_data[import_id][DH_wallet]
    function getPuchasedData_DC_wallet(bytes32 import_id, address DH_wallet) public view returns(address);
    function getPuchasedData_distribution_root_hash(bytes32 import_id, address DH_wallet) public view returns(bytes32);
    function getPuchasedData_checksum(bytes32 import_id, address DH_wallet) public view returns(uint);
    function setPurchasedData(
        bytes32 import_id,
        address DH_wallet,
        address DC_wallet,
        bytes32 distribution_root_hash,
        uint256 checksum ) 
    public;

    enum PurchaseStatus {inactive, initiated, commited, confirmed, sent, disputed, cancelled, completed}
    function setPurchase_token_amount(address DH_wallet, address DV_wallet, bytes32 import_id, uint token_amount) public;
    function setPurchase_stake_factor(address DH_wallet, address DV_wallet, bytes32 import_id, uint stake_factor) public;
    function setPurchase_dispute_interval_in_minutes(address DH_wallet, address DV_wallet, bytes32 import_id, uint dispute_interval_in_minutes) public;
    function setPurchase_commitment(address DH_wallet, address DV_wallet, bytes32 import_id, bytes32 commitment) public;
    function setPurchase_encrypted_block(address DH_wallet, address DV_wallet, bytes32 import_id, uint encrypted_block) public;
    function setPurchase_time_of_sending(address DH_wallet, address DV_wallet, bytes32 import_id, uint time_of_sending) public;
    function setPurchase_purchase_status(address DH_wallet, address DV_wallet, bytes32 import_id, PurchaseStatus purchase_status) public;
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
    public;
    function getPurchase_token_amount(address DH_wallet, address DV_wallet, bytes32 import_id) public view returns(uint);
    function getPurchase_stake_factor(address DH_wallet, address DV_wallet, bytes32 import_id) public view returns(uint);
    function getPurchase_dispute_interval_in_minutes(address DH_wallet, address DV_wallet, bytes32 import_id) public view returns(uint);
    function getPurchase_commitment(address DH_wallet, address DV_wallet, bytes32 import_id) public view returns(bytes32);
    function getPurchase_encrypted_block(address DH_wallet, address DV_wallet, bytes32 import_id) public view returns(uint);
    function getPurchase_time_of_sending(address DH_wallet, address DV_wallet, bytes32 import_id) public view returns(uint);
    function getPurchase_purchase_status(address DH_wallet, address DV_wallet, bytes32 import_id) public view returns(PurchaseStatus);

}

contract ContractHub{
    address public tokenAddress;
    address public profileStorageAddress;
    address public readingStorageAddress;
}

contract Reading{
    using SafeMath for uint256;

    ContractHub public Hub;
    ProfileStorage public profileStorage;
    ReadingStorage public readingStorage;

    event PurchaseInitiated(bytes32 import_id, address DH_wallet, address DV_wallet);
    event CommitmentSent(bytes32 import_id, address DH_wallet, address DV_wallet);
    event PurchaseConfirmed(bytes32 import_id, address DH_wallet, address DV_wallet);
    event PurchaseCancelled(bytes32 import_id, address DH_wallet, address DV_wallet);
    event EncryptedBlockSent(bytes32 import_id, address DH_wallet, address DV_wallet);
    event PurchaseDisputed(bytes32 import_id, address DH_wallet, address DV_wallet);
    event PurchaseDisputeCompleted(bytes32 import_id, address DH_wallet, address DV_wallet, bool proof_was_correct);

    constructor(address hub_address)
    public {
        require(hub_address != address(0));
        Hub = ContractHub(hub_address);
        profileStorage = ProfileStorage(Hub.profileStorageAddress());
        readingStorage = ReadingStorage(Hub.readingStorageAddress());
    }

    function initiatePurchase(bytes32 import_id, address DH_wallet, uint token_amount, uint dispute_interval_in_minutes) // TODO dodaj dispute time
    public {
        // PurchaseDefinition storage this_purchase = purchase[DH_wallet][msg.sender][import_id];

        require(readingStorage.getPurchase_purchase_status(DH_wallet, msg.sender, import_id) == ReadingStorage.PurchaseStatus.inactive
            ||     readingStorage.getPurchase_purchase_status(DH_wallet, msg.sender, import_id) == ReadingStorage.PurchaseStatus.completed);


        uint DH_stake_factor = profileStorage.getProfile_read_stake_factor(DH_wallet);
        uint DH_balance = profileStorage.getProfile_balance(DH_wallet);
        uint DV_balance = profileStorage.getProfile_balance(msg.sender);

        uint256 stake_amount = token_amount.mul(DH_stake_factor);

        require(DH_balance >= stake_amount && DV_balance >= token_amount.add(stake_amount));

        DV_balance = DV_balance.sub(token_amount).sub(stake_amount);
        profileStorage.setProfile_balance(msg.sender, DV_balance);

        readingStorage.setPurchase(DH_wallet,msg.sender,import_id,token_amount,DH_stake_factor, dispute_interval_in_minutes,0,0,0,ReadingStorage.PurchaseStatus.initiated);

        emit PurchaseInitiated(import_id, DH_wallet, msg.sender);
    }

    function sendCommitment(bytes32 import_id, address DV_wallet, bytes32 commitment)
    public {

        require(readingStorage.getPurchase_purchase_status(msg.sender, DV_wallet, import_id) == ReadingStorage.PurchaseStatus.initiated);

        uint DH_balance = profileStorage.getProfile_balance(msg.sender);
        uint token_amount = readingStorage.getPurchase_token_amount(msg.sender,DV_wallet, import_id);
        uint stake_factor = readingStorage.getPurchase_stake_factor(msg.sender,DV_wallet, import_id);
        uint256 stake_amount = token_amount.mul(stake_factor);
        require(DH_balance >= stake_amount);

        // Allocate stake amount from DH and update his new balance
        DH_balance = DH_balance.sub(stake_amount);
        profileStorage.setProfile_balance(msg.sender, DH_balance);

        readingStorage.setPurchase_commitment(msg.sender, DV_wallet, import_id, commitment);
        readingStorage.setPurchase_purchase_status(msg.sender, DV_wallet, import_id, ReadingStorage.PurchaseStatus.commited);

        emit CommitmentSent(import_id, msg.sender, DV_wallet);
    }

    function confirmPurchase(bytes32 import_id, address DH_wallet)
    public {
        require(readingStorage.getPurchase_purchase_status(DH_wallet, msg.sender, import_id) == ReadingStorage.PurchaseStatus.commited);

        readingStorage.setPurchase_purchase_status(DH_wallet, msg.sender, import_id, ReadingStorage.PurchaseStatus.confirmed);

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
        require(readingStorage.getPurchase_purchase_status(DH_wallet, DV_wallet, import_id) == ReadingStorage.PurchaseStatus.initiated
            ||  readingStorage.getPurchase_purchase_status(DH_wallet, DV_wallet, import_id) == ReadingStorage.PurchaseStatus.commited
            ||  readingStorage.getPurchase_purchase_status(DH_wallet, DV_wallet, import_id) == ReadingStorage.PurchaseStatus.confirmed);

        uint256 stake_amount = readingStorage.getPurchase_token_amount(DH_wallet, DV_wallet, import_id).mul(readingStorage.getPurchase_stake_factor(DH_wallet, DV_wallet, import_id));

        // Returns reading price and stake to DV
        uint DV_balance = profileStorage.getProfile_balance(DV_wallet);
        DV_balance = DV_balance.add(readingStorage.getPurchase_token_amount(DH_wallet, DV_wallet, import_id).add(stake_amount));
        profileStorage.setProfile_balance(DV_wallet, DV_balance);

        // If DH sent stake, returns it to his balance
        if(readingStorage.getPurchase_purchase_status(DH_wallet, DV_wallet, import_id)  != ReadingStorage.PurchaseStatus.initiated){
            uint DH_balance = profileStorage.getProfile_balance(DH_wallet);
            DH_balance = DH_balance.add(stake_amount);
            profileStorage.setProfile_balance(DH_wallet, DH_balance);
        }

        // Sets purchase status to completed
        readingStorage.setPurchase_purchase_status(DH_wallet, DV_wallet, import_id, ReadingStorage.PurchaseStatus.completed);
        emit PurchaseCancelled(import_id, DH_wallet, DV_wallet);
    }

    function sendEncryptedBlock(bytes32 import_id, address DV_wallet, uint256 encrypted_block)
    public {
        require(readingStorage.getPurchase_purchase_status(msg.sender, DV_wallet, import_id) == ReadingStorage.PurchaseStatus.confirmed);

        address ps_DC_wallet;
        bytes32 ps_distribution_root_hash;
        uint ps_checksum;
        (ps_DC_wallet, ps_distribution_root_hash, ps_checksum) = readingStorage.purchased_data(import_id,msg.sender);


        readingStorage.setPurchase_encrypted_block(msg.sender, DV_wallet, import_id, encrypted_block);
        readingStorage.setPurchase_time_of_sending(msg.sender, DV_wallet, import_id, block.timestamp);
        readingStorage.setPurchase_purchase_status(msg.sender, DV_wallet, import_id, ReadingStorage.PurchaseStatus.sent);

        readingStorage.setPurchasedData(import_id,DV_wallet,ps_DC_wallet,ps_distribution_root_hash,ps_checksum);

        emit EncryptedBlockSent(import_id, msg.sender, DV_wallet);
    }

    function payOut(bytes32 import_id, address DV_wallet)
    public {
        require(readingStorage.getPurchase_purchase_status(msg.sender, DV_wallet, import_id) == ReadingStorage.PurchaseStatus.sent);

        require(readingStorage.getPurchase_time_of_sending(msg.sender, DV_wallet, import_id) + 
            readingStorage.getPurchase_dispute_interval_in_minutes(msg.sender, DV_wallet, import_id).mul(60) <= block.timestamp);

        uint token_amount = readingStorage.getPurchase_token_amount(msg.sender,DV_wallet, import_id);
        uint stake_factor = readingStorage.getPurchase_stake_factor(msg.sender,DV_wallet, import_id);
        uint256 stake_amount = token_amount.mul(stake_factor);
        
        // Returns reading stake to DV
        uint DV_balance = profileStorage.getProfile_balance(DV_wallet);
        DV_balance = DV_balance.add(stake_amount);
        profileStorage.setProfile_balance(DV_wallet, DV_balance);
        //      bidding.increaseBalance(msg.sender, this_purchase.token_amount.mul(s_stake_factor).add(s_token_amount));
        //      bidding.increaseBalance(DV_wallet, this_purchase.token_amount.mul(s_stake_factor));

        //  bidding.increaseReputation(msg.sender, this_purchase.token_amount.mul(this_purchase.stake_factor));
        //  bidding.increaseReputation(DV_wallet, this_purchase.token_amount.mul(this_purchase.stake_factor));

        // Returns reading stake to DH and sends tokens
        uint DH_balance = profileStorage.getProfile_balance(msg.sender);
        DH_balance = DH_balance.add(stake_amount).add(token_amount);
        profileStorage.setProfile_balance(msg.sender, DH_balance);

        readingStorage.setPurchase_purchase_status(msg.sender, DV_wallet, import_id, ReadingStorage.PurchaseStatus.completed);
    }

    function initiateDispute(bytes32 import_id, address DH_wallet)
    public {
        require(readingStorage.getPurchase_purchase_status(DH_wallet, msg.sender, import_id) == ReadingStorage.PurchaseStatus.sent);
        require(readingStorage.getPurchase_time_of_sending(DH_wallet, msg.sender, import_id) + 
            readingStorage.getPurchase_dispute_interval_in_minutes(DH_wallet, msg.sender, import_id).mul(60) <= block.timestamp);

        readingStorage.setPurchase_purchase_status(DH_wallet, msg.sender, import_id, ReadingStorage.PurchaseStatus.disputed);
    }

    function sendProofData(bytes32 import_id, address DV_wallet,
        uint256 checksum_left, uint256 checksum_right, bytes32 checksum_hash,
        uint256 random_number_1, uint256 random_number_2,
        uint256 decryption_key, uint256 block_index)
    public { 
        uint256[] memory parameters;
        parameters[0] = uint256(readingStorage.getPurchase_commitment(msg.sender, DV_wallet, import_id)); //commitment
        parameters[1] = readingStorage.getPurchase_encrypted_block(msg.sender, DV_wallet, import_id); // encrypted_block
        // bytes32 commitment = readingStorage.getPurchase_commitment(msg.sender, DV_wallet, import_id);
        // uint256 encrypted_block = readingStorage.getPurchase_encrypted_block(msg.sender, DV_wallet, import_id);

        bool commitment_proof = bytes32(parameters[0]) == keccak256(abi.encodePacked(checksum_left, checksum_right, checksum_hash, random_number_1, random_number_2, decryption_key, block_index));
        bool checksum_hash_proof = 
        checksum_hash == keccak256(abi.encodePacked(bytes32(checksum_left + uint256(keccak256(abi.encodePacked(uint256(keccak256(abi.encodePacked(decryption_key ^ parameters[1]))) - block_index - 1))) % (2**128) + random_number_1 + checksum_right - random_number_2)));

        parameters[2] = readingStorage.getPurchase_token_amount(msg.sender, DV_wallet, import_id); // token amount
        parameters[3] = readingStorage.getPurchase_stake_factor(msg.sender, DV_wallet, import_id); // stake_factor
        parameters[4] = parameters[2].mul(parameters[3]); // stake_amount

        if(commitment_proof == true && checksum_hash_proof == true) {
            // Returns reading stake to DH and sends tokens and stake
            parameters[5] = profileStorage.getProfile_balance(msg.sender);
            parameters[5] = parameters[5].add(parameters[4]);
            parameters[5] = parameters[5].add(parameters[4]);
            parameters[5] = parameters[5].add(parameters[2]);
            profileStorage.setProfile_balance(msg.sender, parameters[5]);
            // bidding.increaseBalance(msg.sender, this_purchase.token_amount.add(SafeMath.mul(this_purchase.token_amount,this_purchase.stake_factor)));
            emit PurchaseDisputeCompleted(import_id, msg.sender, DV_wallet, true);
        }
        else {
            // Returns reading stake to DH and sends tokens and stake
            parameters[6] = profileStorage.getProfile_balance(DV_wallet);
            parameters[6] = parameters[6].add(parameters[4]);
            parameters[6] = parameters[6].add(parameters[4]);
            parameters[6] = parameters[6].add(parameters[2]);
            profileStorage.setProfile_balance(DV_wallet, parameters[6]);
            // bidding.increaseBalance(DV_wallet, this_purchase.token_amount.add(SafeMath.mul(this_purchase.token_amount,this_purchase.stake_factor)));
            emit PurchaseDisputeCompleted(import_id, msg.sender, DV_wallet, false);
        }
        readingStorage.setPurchase_purchase_status(msg.sender, DV_wallet, import_id, ReadingStorage.PurchaseStatus.completed);
    }
}
