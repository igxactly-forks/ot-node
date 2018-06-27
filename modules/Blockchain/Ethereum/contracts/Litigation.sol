pragma solidity ^0.4.18;

library SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a * b;
        assert(a == 0 || c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a / b;
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
    function getProfile_balance(address wallet) public view returns(uint);
    function setProfile_balance(address wallet, uint256 balance) public;
}

contract EscrowStorage{
    enum EscrowStatus {inactive, initiated, confirmed, active, completed}

    function getEscrow_DC_wallet(bytes32 import_id, address DH_wallet) public view returns(address);
    function getEscrow_token_amount(bytes32 import_id, address DH_wallet) public view returns(uint);
    function getEscrow_tokens_sent(bytes32 import_id, address DH_wallet) public view returns(uint);
    function getEscrow_stake_amount(bytes32 import_id, address DH_wallet) public view returns(uint);
    function getEscrow_end_time(bytes32 import_id, address DH_wallet) public view returns(uint);
    function getEscrow_total_time_in_seconds(bytes32 import_id, address DH_wallet) public view returns(uint);
    function getEscrow_litigation_interval_in_minutes(bytes32 import_id, address DH_wallet) public view returns(uint);
    function getEscrow_litigation_root_hash(bytes32 import_id, address DH_wallet) public view returns(bytes32);
    function getEscrow_escrow_status(bytes32 import_id, address DH_wallet) public view returns(EscrowStatus);

    function setEscrow_tokens_sent(bytes32 import_id, address DH_wallet, uint tokens_sent) public;
    function setEscrow_stake_amount(bytes32 import_id, address DH_wallet, uint stake_amount) public;
    function setEscrow_escrow_status(bytes32 import_id, address DH_wallet, EscrowStatus escrow_status) public;
}

contract LitigationStorage{
    enum LitigationStatus {inactive, initiated, answered, timed_out, completed}

    function getLitigation_requested_data_index(bytes32 import_id, address DH_wallet) public view returns(uint);
    function getLitigation_requested_data(bytes32 import_id, address DH_wallet) public view returns(bytes32);
    function getLitigation_hash_array(bytes32 import_id, address DH_wallet) public view returns(bytes32[]);
    function getLitigation_litigation_start_time(bytes32 import_id, address DH_wallet) public view returns(uint);
    function getLitigation_answer_timestamp(bytes32 import_id, address DH_wallet) public view returns(uint);
    function getLitigation_litigation_status(bytes32 import_id, address DH_wallet) public view returns(LitigationStatus);

    function setLitigation_requested_data_index(bytes32 import_id, address DH_wallet, uint requested_data_index) public;
    function setLitigation_requested_data(bytes32 import_id, address DH_wallet, bytes32 requested_data) public;
    function setLitigation_hash_array(bytes32 import_id, address DH_wallet, bytes32[] hash_array) public;
    function setLitigation_litigation_start_time(bytes32 import_id, address DH_wallet, uint litigation_start_time) public;
    function setLitigation_answer_timestamp(bytes32 import_id, address DH_wallet, uint answer_timestamp) public;
    function setLitigation_litigation_status(bytes32 import_id, address DH_wallet, LitigationStatus litigation_status) public;
}

contract ReadingStorage {
    function setPurchasedData( bytes32 import_id, address DH_wallet, address DC_wallet, bytes32 distribution_root_hash, uint256 checksum ) public;
}

contract ContractHub{
    address public profileStorageAddress;
    address public escrowStorageAddress;
    address public litigationStorageAddress;
    address public readingStorageAddress;
}

contract Litigation{
    using SafeMath for uint256;

    ProfileStorage public profileStorage;
    EscrowStorage public escrowStorage;
    LitigationStorage public litigationStorage;
    ReadingStorage public readingStorage;

    ContractHub public Hub;
    constructor(address hub_address)
    public{
        require ( hub_address != address(0));
        Hub = ContractHub(hub_address);
    }

    function initiate() public {
        profileStorage = ProfileStorage(Hub.profileStorageAddress());
        escrowStorage  = EscrowStorage(Hub.escrowStorageAddress());
        litigationStorage  = LitigationStorage(Hub.litigationStorageAddress());
        readingStorage = ReadingStorage(Hub.readingStorageAddress());
    }

    /*    ----------------------------- LITIGATION -----------------------------     */

    // Litigation protocol:
    //   1. DC creates a litigation for a specific DH over a specific offer_hash
    //        DC sends an array of hashes and the order number of the requested data
    //   2. DH sends the requested data -> answer
    //        The answer is stored in the SC, and it will be checked once the DH sends their answer and starts the proof
    //   3. DC sends the correct data -> proof. It and the answer get checked if they are correct
    //        a. If the answer is correct, or the proof is incorrect, escrow continues as if nothing happened
    //        b. If the answer is incorrect, and proof is correct DC receives a proportional amount of token to the DH stake commited

    // Answer/Proof verifiation:
    //   1. The data sent gets hashed with the block index
    //   2. The hash is hashed with the first hash in the array which DC sent. (Ordering of the hashes is determined by the index of the requested data)
    //   3. For the entire hash array the next item gets hashed together with the result of the previous iteration (with the ordering determined by the proper bit in the requested data index)
    //   4. At the end the result should be equal to the root hash of the merkle tree of the entire data, hence it gets compared to the litigation_root_hash defined in the escrow
    //   5. If the hashes are equal the Answer/Proof is correct. Otherwise, it fails.

    event LitigationInitiated(bytes32 import_id, address DH_wallet, uint requested_data_index);
    event LitigationAnswered(bytes32 import_id, address DH_wallet);
    event LitigationTimedOut(bytes32 import_id, address DH_wallet);
    event LitigationCompleted(bytes32 import_id, address DH_wallet, bool DH_was_penalized);

    function initiateLitigation(bytes32 import_id, address DH_wallet, uint requested_data_index, bytes32[] hash_array)
    public returns (bool newLitigationInitiated){
        require(escrowStorage.getEscrow_DC_wallet(import_id, DH_wallet) == msg.sender && escrowStorage.getEscrow_escrow_status(import_id, DH_wallet) == EscrowStorage.EscrowStatus.active);
        require(litigationStorage.getLitigation_litigation_status(import_id, DH_wallet) == LitigationStorage.LitigationStatus.inactive 
            || litigationStorage.getLitigation_litigation_status(import_id, DH_wallet) == LitigationStorage.LitigationStatus.completed);
        require(block.timestamp < escrowStorage.getEscrow_end_time(import_id, DH_wallet));

        litigationStorage.setLitigation_requested_data_index(import_id, DH_wallet, requested_data_index);
        litigationStorage.setLitigation_hash_array(import_id, DH_wallet, hash_array);
        litigationStorage.setLitigation_litigation_start_time(import_id, DH_wallet, block.timestamp);
        litigationStorage.setLitigation_litigation_status(import_id, DH_wallet, LitigationStorage.LitigationStatus.initiated);

        emit LitigationInitiated(import_id, DH_wallet, requested_data_index);
        return true;
    }

    function answerLitigation(bytes32 import_id, bytes32 requested_data)
    public returns (bool answer_accepted){
        require(litigationStorage.getLitigation_litigation_status(import_id, msg.sender) == LitigationStorage.LitigationStatus.initiated);

        if(block.timestamp > litigationStorage.getLitigation_litigation_start_time(import_id, msg.sender) + escrowStorage.getEscrow_litigation_interval_in_minutes(import_id, msg.sender).mul(60)){
            uint256 amount_to_send;

            uint time = litigationStorage.getLitigation_litigation_start_time(import_id, msg.sender);
            time = escrowStorage.getEscrow_end_time(import_id, msg.sender).sub(time);
            amount_to_send = escrowStorage.getEscrow_token_amount(import_id, msg.sender).mul(time) / escrowStorage.getEscrow_total_time_in_seconds(import_id, msg.sender);

            //Transfer the amount_to_send to DC
            if(amount_to_send > 0) {
                // Increase tokens sent
                uint value = escrowStorage.getEscrow_tokens_sent(import_id, msg.sender);
                value.add(amount_to_send);
                escrowStorage.setEscrow_tokens_sent(import_id, msg.sender, value);

                // Send tokens back to DC
                value = profileStorage.getProfile_balance(escrowStorage.getEscrow_DC_wallet(import_id, msg.sender));
                value.add(amount_to_send);
                profileStorage.setProfile_balance(escrowStorage.getEscrow_DC_wallet(import_id, msg.sender), value);
            }
            //Calculate the amount to send back to DH and transfer the money back
            amount_to_send = SafeMath.sub(escrowStorage.getEscrow_token_amount(import_id, msg.sender), escrowStorage.getEscrow_tokens_sent(import_id, msg.sender));
            if(amount_to_send > 0) {
                value = escrowStorage.getEscrow_tokens_sent(import_id, msg.sender);
                value.add(amount_to_send);
                escrowStorage.setEscrow_tokens_sent(import_id, msg.sender, value);

                value = profileStorage.getProfile_balance(escrowStorage.getEscrow_DC_wallet(import_id, msg.sender));
                value.add(amount_to_send);
                profileStorage.setProfile_balance(escrowStorage.getEscrow_DC_wallet(import_id, msg.sender), value);
            }

            amount_to_send = escrowStorage.getEscrow_stake_amount(import_id, msg.sender);
            escrowStorage.setEscrow_stake_amount(import_id, msg.sender, 0);
            if(amount_to_send > 0) {
                value = profileStorage.getProfile_balance(escrowStorage.getEscrow_DC_wallet(import_id, msg.sender));
                value.add(amount_to_send);
                profileStorage.setProfile_balance(escrowStorage.getEscrow_DC_wallet(import_id, msg.sender), value);
            }

            escrowStorage.setEscrow_escrow_status(import_id, msg.sender, EscrowStorage.EscrowStatus.inactive);
            litigationStorage.setLitigation_litigation_status(import_id, msg.sender, LitigationStorage.LitigationStatus.completed);

            readingStorage.setPurchasedData(import_id, msg.sender, address(0), bytes32(0), 0);

            emit LitigationTimedOut(import_id, msg.sender);
            return false;
        }
        else {
            litigationStorage.setLitigation_requested_data(import_id, msg.sender, keccak256(abi.encodePacked(requested_data, litigationStorage.getLitigation_requested_data_index(import_id, msg.sender))));
            litigationStorage.setLitigation_answer_timestamp(import_id, msg.sender, block.timestamp);
            litigationStorage.setLitigation_litigation_status(import_id, msg.sender, LitigationStorage.LitigationStatus.answered);

            emit LitigationAnswered(import_id, msg.sender);
            return true;
        }
    }


    function cancelInactiveLitigation(bytes32 import_id)
    public {
        require(litigationStorage.getLitigation_litigation_status(import_id, msg.sender) == LitigationStorage.LitigationStatus.answered
            &&   litigationStorage.getLitigation_answer_timestamp(import_id, msg.sender) + escrowStorage.getEscrow_litigation_interval_in_minutes(import_id, msg.sender).mul(60) <= block.timestamp);

        litigationStorage.setLitigation_litigation_status(import_id, msg.sender, LitigationStorage.LitigationStatus.completed);

        emit LitigationCompleted(import_id, msg.sender, false);

    }

    function proveLitigaiton(bytes32 import_id, address DH_wallet, bytes32 proof_data)
    public returns (bool DH_was_penalized){

        require(escrowStorage.getEscrow_DC_wallet(import_id, DH_wallet) == msg.sender && 
            (litigationStorage.getLitigation_litigation_status(import_id, DH_wallet) == LitigationStorage.LitigationStatus.initiated 
                || litigationStorage.getLitigation_litigation_status(import_id, DH_wallet) == LitigationStorage.LitigationStatus.answered));

        if (litigationStorage.getLitigation_litigation_status(import_id, DH_wallet) == LitigationStorage.LitigationStatus.initiated){
            require(litigationStorage.getLitigation_litigation_start_time(import_id, DH_wallet) + escrowStorage.getEscrow_litigation_interval_in_minutes(import_id, DH_wallet).mul(60) <= block.timestamp);

            uint256 amount_to_send;

            uint time = litigationStorage.getLitigation_litigation_start_time(import_id, DH_wallet);
            time = escrowStorage.getEscrow_end_time(import_id, DH_wallet).sub(time);
            amount_to_send = escrowStorage.getEscrow_token_amount(import_id, DH_wallet).mul(time) / escrowStorage.getEscrow_total_time_in_seconds(import_id, DH_wallet);

            //Transfer the amount_to_send to DC 
            if(amount_to_send > 0) {
                uint value = escrowStorage.getEscrow_tokens_sent(import_id, DH_wallet);
                value.add(amount_to_send);
                escrowStorage.setEscrow_tokens_sent(import_id, DH_wallet, value);

                // Send tokens back to DC
                value = profileStorage.getProfile_balance(msg.sender);
                value.add(amount_to_send);
                profileStorage.setProfile_balance(msg.sender, value);
            }
            //Calculate the amount to send back to DH and transfer the money back
            amount_to_send = SafeMath.sub(escrowStorage.getEscrow_token_amount(import_id, DH_wallet), escrowStorage.getEscrow_tokens_sent(import_id, DH_wallet));
            if(amount_to_send > 0) {
                value = escrowStorage.getEscrow_tokens_sent(import_id, DH_wallet);
                value.add(amount_to_send);
                escrowStorage.setEscrow_tokens_sent(import_id, DH_wallet, value);

                value = profileStorage.getProfile_balance(msg.sender);
                value.add(amount_to_send);
                profileStorage.setProfile_balance(msg.sender, value);
            }

            amount_to_send = escrowStorage.getEscrow_stake_amount(import_id, DH_wallet);
            escrowStorage.setEscrow_stake_amount(import_id, DH_wallet, 0);
            if(amount_to_send > 0) {
                value = profileStorage.getProfile_balance(msg.sender);
                value.add(amount_to_send);
                profileStorage.setProfile_balance(msg.sender, value);
            }

            escrowStorage.setEscrow_escrow_status(import_id, DH_wallet, EscrowStorage.EscrowStatus.inactive);
            litigationStorage.setLitigation_litigation_status(import_id, DH_wallet, LitigationStorage.LitigationStatus.completed);

            readingStorage.setPurchasedData(import_id, DH_wallet, address(0), bytes32(0), 0);

            emit LitigationTimedOut(import_id, DH_wallet);
            return true;
        }



        if(isDHokay(import_id, DH_wallet, proof_data)){
            // DH has the requested data -> Set litigation as completed, no transfer of tokens
            litigationStorage.setLitigation_litigation_status(import_id, DH_wallet, LitigationStorage.LitigationStatus.completed);
            emit LitigationCompleted(import_id, DH_wallet, false);
            return false;
        }
        else {
            // DH didn't have the requested data, and the litigation was valid
            //        -> Distribute tokens and send stake to DC

            //Transfer the amount_to_send to DC 
            if(amount_to_send > 0) {
                value = escrowStorage.getEscrow_tokens_sent(import_id, DH_wallet);
                value.add(amount_to_send);
                escrowStorage.setEscrow_tokens_sent(import_id, DH_wallet, value);

                // Send tokens back to DC
                value = profileStorage.getProfile_balance(msg.sender);
                value.add(amount_to_send);
                profileStorage.setProfile_balance(msg.sender, value);
            }
            //Calculate the amount to send back to DH and transfer the money back
            amount_to_send = SafeMath.sub(escrowStorage.getEscrow_token_amount(import_id, DH_wallet), escrowStorage.getEscrow_tokens_sent(import_id, DH_wallet));
            if(amount_to_send > 0) {
                value = escrowStorage.getEscrow_tokens_sent(import_id, DH_wallet);
                value.add(amount_to_send);
                escrowStorage.setEscrow_tokens_sent(import_id, DH_wallet, value);

                value = profileStorage.getProfile_balance(msg.sender);
                value.add(amount_to_send);
                profileStorage.setProfile_balance(msg.sender, value);
            }

            amount_to_send = escrowStorage.getEscrow_stake_amount(import_id, DH_wallet);
            escrowStorage.setEscrow_stake_amount(import_id, DH_wallet, 0);
            if(amount_to_send > 0) {
                value = profileStorage.getProfile_balance(msg.sender);
                value.add(amount_to_send);
                profileStorage.setProfile_balance(msg.sender, value);
            }

            escrowStorage.setEscrow_escrow_status(import_id, DH_wallet, EscrowStorage.EscrowStatus.inactive);
            litigationStorage.setLitigation_litigation_status(import_id, DH_wallet, LitigationStorage.LitigationStatus.completed);

            readingStorage.setPurchasedData(import_id, DH_wallet, address(0), bytes32(0), 0);
            emit LitigationCompleted(import_id, DH_wallet, true);
            return true;
        }
    }

    function isDHokay(bytes32 import_id, address DH_wallet, bytes32 proof_data) internal view returns(bool DH_is_okay){
        uint256 i = 0;
        uint256 one = 1;
        bytes32 proof_hash = keccak256(abi.encodePacked(proof_data, litigationStorage.getLitigation_requested_data_index(import_id, DH_wallet)));    
        // bytes32 proof_hash = keccak256(abi.encodePacked(proof_data, this_litigation.requested_data_index));   
        bytes32 answer_hash = litigationStorage.getLitigation_requested_data(import_id, DH_wallet);
        bytes32[] memory hash_array = litigationStorage.getLitigation_hash_array(import_id,DH_wallet);
        while (i < hash_array.length){
            // If the current bit in the requested_data_index is 1, the hashes should be the right argument during hashing
            if( ((one << i) & litigationStorage.getLitigation_requested_data_index(import_id, DH_wallet)) != 0 ){
                proof_hash = keccak256(abi.encodePacked(hash_array[i], proof_hash));
                answer_hash = keccak256(abi.encodePacked(hash_array[i], answer_hash));
            }
            else {
                proof_hash = keccak256(abi.encodePacked(proof_hash, hash_array[i]));
                answer_hash = keccak256(abi.encodePacked(answer_hash, hash_array[i]));
            }
            i++;
        }

        if(answer_hash == escrowStorage.getEscrow_litigation_root_hash(import_id, DH_wallet)) return true;
        else {
            if(proof_hash == escrowStorage.getEscrow_litigation_root_hash(import_id, DH_wallet)) return false;
            else return true;
        }
    }

}