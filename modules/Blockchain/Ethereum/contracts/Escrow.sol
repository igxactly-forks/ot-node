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

contract StorageContract {
     enum EscrowStatus {inactive, initiated, confirmed, active, completed}

     function getProfile_balance(address wallet) public view returns(uint);
     function getProfile_reputation(address wallet) public view returns(uint);
     function getProfile_number_of_escrows(address wallet) public view returns(uint);
     
     function setProfile_balance(address wallet, uint256 balance) public;
     function setProfile_reputation(address wallet, uint256 reputation) public;
     function setProfile_number_of_escrows(address wallet, uint256 number_of_escrows) public;
     

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
     function getEscrow_DC_wallet(bytes32 import_id, address DH_wallet) public view returns(address);
     function getEscrow_token_amount(bytes32 import_id, address DH_wallet) public view returns(uint);
     function getEscrow_tokens_sent(bytes32 import_id, address DH_wallet) public view returns(uint);
     function getEscrow_stake_amount(bytes32 import_id, address DH_wallet) public view returns(uint);
     function getEscrow_last_confirmation_time(bytes32 import_id, address DH_wallet) public view returns(uint);
     function getEscrow_end_time(bytes32 import_id, address DH_wallet) public view returns(uint);
     function getEscrow_total_time_in_seconds(bytes32 import_id, address DH_wallet) public view returns(uint);
     function getEscrow_litigation_interval_in_minutes(bytes32 import_id, address DH_wallet) public view returns(uint);
     function getEscrow_litigation_root_hash(bytes32 import_id, address DH_wallet) public view returns(bytes32);
     function getEscrow_distribution_root_hash(bytes32 import_id, address DH_wallet) public view returns(bytes32);
     function getEscrow_checksum(bytes32 import_id, address DH_wallet) public view returns(uint);
     function getEscrow_escrow_status(bytes32 import_id, address DH_wallet) public view returns(EscrowStatus);
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
     public;
     function setEscrow_DC_wallet(bytes32 import_id, address DH_wallet, address DC_wallet) public;
     function setEscrow_token_amount(bytes32 import_id, address DH_wallet, uint token_amount) public;
     function setEscrow_tokens_sent(bytes32 import_id, address DH_wallet, uint tokens_sent) public;
     function setEscrow_stake_amount(bytes32 import_id, address DH_wallet, uint stake_amount) public;
     function setEscrow_last_confirmation_time(bytes32 import_id, address DH_wallet, uint last_confirmation_time) public;
     function setEscrow_end_time(bytes32 import_id, address DH_wallet, uint end_time) public;
     function setEscrow_total_time_in_seconds(bytes32 import_id, address DH_wallet, uint256 total_time_in_seconds) public;
     function setEscrow_litigation_interval_in_minutes(bytes32 import_id, address DH_wallet, uint256 litigation_interval_in_minutes) public;
     function setEscrow_litigation_root_hash(bytes32 import_id, address DH_wallet, bytes32 litigation_root_hash) public;
     function setEscrow_distribution_root_hash(bytes32 import_id, address DH_wallet, bytes32 distribution_root_hash) public;
     function setEscrow_checksum(bytes32 import_id, address DH_wallet, uint256 checksum) public;
     function setEscrow_escrow_status(bytes32 import_id, address DH_wallet, EscrowStatus escrow_status) public;


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

     function setPurchasedData( bytes32 import_id, address DH_wallet, address DC_wallet, bytes32 distribution_root_hash, uint256 checksum ) public;
}

contract ContractHub is Ownable{
     address public fingerprintAddress;
     address public tokenAddress;
     address public biddingAddress;
     address public escrowAddress;
     address public readingAddress;

}

 contract EscrowHolder is Ownable{
     using SafeMath for uint256;

    StorageContract public Storage;
    ContractHub public Hub;
     constructor(address storage_address, address hub_address)
     public{
          require ( storage_address != address(0) && hub_address != address(0));
          Storage = StorageContract(storage_address);
          Hub = ContractHub(hub_address);
     }

     /*    ----------------------------- ESCROW -----------------------------     */

     event EscrowInitated(bytes32 import_id, address DH_wallet, uint token_amount, uint stake_amount,  uint total_time_in_seconds);
     event EscrowConfirmed(bytes32 import_id, address DH_wallet);
     event EscrowVerified(bytes32 import_id, address DH_wallet);
     event EscrowCanceled(bytes32 import_id, address DH_wallet);
     event EscrowCompleted(bytes32 import_id, address DH_wallet);

     function initiateEscrow(address DC_wallet, address DH_wallet, bytes32 import_id, uint token_amount, uint stake_amount, uint total_time_in_minutes, uint litigation_interval_in_minutes)
     public {
          require(msg.sender == Hub.biddingAddress());
          require(Storage.getEscrow_escrow_status(import_id, DH_wallet) == StorageContract.EscrowStatus.completed
               ||   Storage.getEscrow_escrow_status(import_id, DH_wallet) == StorageContract.EscrowStatus.inactive);

          require(total_time_in_minutes > 0);
          Storage.setEscrow_DC_wallet(import_id, DH_wallet, DC_wallet);
          Storage.setEscrow_token_amount(import_id, DH_wallet, token_amount);
          Storage.setEscrow_tokens_sent(import_id, DH_wallet, 0);
          Storage.setEscrow_stake_amount(import_id, DH_wallet, stake_amount);
          Storage.setEscrow_last_confirmation_time(import_id, DH_wallet, 0);
          Storage.setEscrow_end_time(import_id, DH_wallet, 0);
          Storage.setEscrow_total_time_in_seconds(import_id, DH_wallet, total_time_in_minutes.mul(60));
          Storage.setEscrow_litigation_interval_in_minutes(import_id, DH_wallet, litigation_interval_in_minutes);
          Storage.setEscrow_escrow_status(import_id, DH_wallet, StorageContract.EscrowStatus.initiated);

          emit EscrowInitated(import_id, DH_wallet, token_amount, stake_amount, total_time_in_minutes);
     }

     function addRootHashAndChecksum(bytes32 import_id, bytes32 litigation_root_hash, bytes32 distribution_root_hash, uint256 checksum)
     public {
          // EscrowDefinition storage this_escrow = escrow[import_id][msg.sender];

          require(Storage.getEscrow_escrow_status(import_id, msg.sender) == StorageContract.EscrowStatus.initiated);

          Storage.setEscrow_litigation_root_hash(import_id, msg.sender, litigation_root_hash);
          Storage.setEscrow_distribution_root_hash(import_id, msg.sender, distribution_root_hash);
          Storage.setEscrow_checksum(import_id, msg.sender, checksum);

          //Transfer the stake_amount to the escrow
          uint balance = Storage.getProfile_balance(msg.sender);
          require(balance >= Storage.getEscrow_stake_amount(import_id, msg.sender));
          balance.sub(Storage.getEscrow_stake_amount(import_id, msg.sender));
          Storage.setProfile_balance(msg.sender, balance);

          Storage.setEscrow_escrow_status(import_id, msg.sender, StorageContract.EscrowStatus.confirmed);
          emit EscrowConfirmed(import_id, msg.sender);
     }

     function verifyEscrow(bytes32 import_id, address DH_wallet)
     public {
          require(Storage.getEscrow_DC_wallet(import_id, DH_wallet) == msg.sender
               && Storage.getEscrow_escrow_status(import_id, DH_wallet) == StorageContract.EscrowStatus.confirmed);

          Storage.setProfile_number_of_escrows(msg.sender, Storage.getProfile_number_of_escrows(msg.sender).add(1));
          Storage.setProfile_number_of_escrows(DH_wallet, Storage.getProfile_number_of_escrows(DH_wallet).add(1));

          Storage.setEscrow_last_confirmation_time(import_id, DH_wallet, block.timestamp);
          Storage.setEscrow_end_time(import_id, DH_wallet, block.timestamp.add(Storage.getEscrow_total_time_in_seconds(import_id, DH_wallet)));
          // this_escrow.last_confirmation_time = block.timestamp;
          // this_escrow.end_time = SafeMath.add(block.timestamp, this_escrow.total_time_in_seconds);

          // reading.addReadData(import_id, DH_wallet, msg.sender, this_escrow.distribution_root_hash, this_escrow.checksum);
          Storage.setPurchasedData(import_id, DH_wallet, msg.sender, Storage.getEscrow_distribution_root_hash(import_id, DH_wallet), Storage.getEscrow_checksum(import_id, DH_wallet));

          Storage.setEscrow_escrow_status(import_id, DH_wallet, StorageContract.EscrowStatus.active);
          emit EscrowVerified(import_id, DH_wallet);
     }

     function payOut(bytes32 import_id)
     public{
          // EscrowDefinition storage this_escrow = escrow[import_id][msg.sender];
          // LitigationDefinition storage this_litigation = litigation[import_id][msg.sender];

          require(Storage.getEscrow_escrow_status(import_id, msg.sender) == StorageContract.EscrowStatus.active);
          require(Storage.getLitigation_litigation_status(import_id, msg.sender) == StorageContract.LitigationStatus.inactive
               ||  Storage.getLitigation_litigation_status(import_id, msg.sender) == StorageContract.LitigationStatus.completed);

          uint256 amount_to_send;

          uint current_time = block.timestamp;
          if(current_time > Storage.getEscrow_end_time(import_id, msg.sender)){
               uint stake_to_send = Storage.getEscrow_stake_amount(import_id, msg.sender);
               Storage.setEscrow_stake_amount(import_id, msg.sender, 0);
               if(stake_to_send > 0) {
                    uint value = Storage.getProfile_balance(msg.sender);
                    value.add(stake_to_send);
                    Storage.setProfile_balance(msg.sender, value);

                     value = Storage.getProfile_reputation(msg.sender);
                    value.add(stake_to_send);
                    Storage.setProfile_reputation(msg.sender, value);
                     value = Storage.getProfile_reputation(Storage.getEscrow_DC_wallet(import_id, msg.sender));
                    value.add(stake_to_send);
                    Storage.setProfile_reputation(Storage.getEscrow_DC_wallet(import_id, msg.sender), value);
               }
               amount_to_send = SafeMath.sub(Storage.getEscrow_token_amount(import_id, msg.sender), Storage.getEscrow_tokens_sent(import_id, msg.sender));
               Storage.setEscrow_escrow_status(import_id, msg.sender, StorageContract.EscrowStatus.completed);
               emit EscrowCompleted(import_id, msg.sender);
          }
          else{
               amount_to_send = current_time.sub(Storage.getEscrow_last_confirmation_time(import_id, msg.sender));
               amount_to_send = amount_to_send.mul(Storage.getEscrow_token_amount(import_id, msg.sender));
               amount_to_send = amount_to_send / Storage.getEscrow_total_time_in_seconds(import_id, msg.sender);
               // SafeMath.mul(this_escrow.token_amount,SafeMath.sub(current_time,this_escrow.last_confirmation_time)) / this_escrow.total_time_in_seconds;
               assert(amount_to_send.add(Storage.getEscrow_tokens_sent(import_id, msg.sender)) <= Storage.getEscrow_token_amount(import_id, msg.sender));
               Storage.setEscrow_last_confirmation_time(import_id, msg.sender, current_time);
          }
          
          if(amount_to_send > 0) {
               // this_escrow.tokens_sent = this_escrow.tokens_sent.add(amount_to_send);

                value = Storage.getEscrow_tokens_sent(import_id, msg.sender);
                    value.add(amount_to_send);
                    Storage.setEscrow_tokens_sent(import_id, msg.sender, value);

                value = Storage.getProfile_balance(msg.sender);
                    value.add(amount_to_send);
                    Storage.setProfile_balance(msg.sender, value);
               //bidding.increaseBalance(msg.sender, amount_to_send);
          }
     }

     function cancelEscrow(bytes32 import_id, address correspondent_wallet, bool sender_is_DH)
     public {
          address DH_wallet;
          address DC_wallet;

          if (sender_is_DH == true) {
               DH_wallet = msg.sender;
               DC_wallet = correspondent_wallet;
          }
          else{
               DH_wallet = correspondent_wallet;
               DC_wallet = msg.sender;
          }

         // EscrowDefinition storage this_escrow = escrow[import_id][DH_wallet];

          require(DC_wallet == Storage.getEscrow_DC_wallet(import_id, DH_wallet));

          require(Storage.getEscrow_escrow_status(import_id, msg.sender) == StorageContract.EscrowStatus.initiated
               || Storage.getEscrow_escrow_status(import_id, msg.sender) == StorageContract.EscrowStatus.confirmed);

          uint256 amount_to_send = Storage.getEscrow_token_amount(import_id, msg.sender);
          Storage.setEscrow_token_amount(import_id, msg.sender, 0);
          if(amount_to_send > 0) {
              // bidding.increaseBalance(DC_wallet, amount_to_send);
              uint value = Storage.getProfile_balance(DC_wallet);
                    value.add(amount_to_send);
                    Storage.setProfile_balance(DC_wallet, value);
          }
          if(Storage.getEscrow_escrow_status(import_id, msg.sender) == StorageContract.EscrowStatus.confirmed){
               amount_to_send = Storage.getEscrow_stake_amount(import_id, msg.sender);
               Storage.setEscrow_stake_amount(import_id, msg.sender, 0);
               if(amount_to_send > 0) {
                    // bidding.increaseBalance(DH_wallet, amount_to_send);
                    value = Storage.getProfile_balance(DH_wallet);
                    value.add(amount_to_send);
                    Storage.setProfile_balance(DH_wallet, value);
               }
          }

          Storage.setEscrow_escrow_status(import_id, msg.sender, StorageContract.EscrowStatus.completed);
          emit EscrowCanceled(import_id, DH_wallet);
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
          // LitigationDefinition storage this_litigation = litigation[import_id][DH_wallet];
         // EscrowDefinition storage this_escrow = escrow[import_id][DH_wallet];

          require(Storage.getEscrow_DC_wallet(import_id, DH_wallet) == msg.sender && Storage.getEscrow_escrow_status(import_id, DH_wallet) == StorageContract.EscrowStatus.active);
          require(Storage.getLitigation_litigation_status(import_id, DH_wallet) == StorageContract.LitigationStatus.inactive 
               || Storage.getLitigation_litigation_status(import_id, DH_wallet) == StorageContract.LitigationStatus.completed);
          require(block.timestamp < Storage.getEscrow_end_time(import_id, DH_wallet));

          Storage.setLitigation_requested_data_index(import_id, DH_wallet, requested_data_index);
          Storage.setLitigation_hash_array(import_id, DH_wallet, hash_array);
          Storage.setLitigation_litigation_start_time(import_id, DH_wallet, block.timestamp);
          Storage.setLitigation_litigation_status(import_id, DH_wallet, StorageContract.LitigationStatus.initiated);

          emit LitigationInitiated(import_id, DH_wallet, requested_data_index);
          return true;
     }

     function answerLitigation(bytes32 import_id, bytes32 requested_data)
     public returns (bool answer_accepted){
          // LitigationDefinition storage this_litigation = litigation[import_id][msg.sender];
          // EscrowDefinition storage this_escrow = escrow[import_id][msg.sender];

          require(Storage.getLitigation_litigation_status(import_id, msg.sender) == StorageContract.LitigationStatus.initiated);

          if(block.timestamp > Storage.getLitigation_litigation_start_time(import_id, msg.sender) + Storage.getEscrow_litigation_interval_in_minutes(import_id, msg.sender).mul(60)){
               uint256 amount_to_send;

               uint time = Storage.getLitigation_litigation_start_time(import_id, msg.sender);
               time = Storage.getEscrow_end_time(import_id, msg.sender).sub(time);
               amount_to_send = Storage.getEscrow_token_amount(import_id, msg.sender).mul(time) / Storage.getEscrow_total_time_in_seconds(import_id, msg.sender);

               //Transfer the amount_to_send to DC
               if(amount_to_send > 0) {
                    // Increase tokens sent
                    //this_escrow.tokens_sent = this_escrow.tokens_sent.add(amount_to_send);
                    uint value = Storage.getEscrow_tokens_sent(import_id, msg.sender);
                    value.add(amount_to_send);
                    Storage.setEscrow_tokens_sent(import_id, msg.sender, value);

                    // Send tokens back to DC
                    //bidding.increaseBalance(this_escrow.DC_wallet, amount_to_send);
                    value = Storage.getProfile_balance(Storage.getEscrow_DC_wallet(import_id, msg.sender));
                    value.add(amount_to_send);
                    Storage.setProfile_balance(Storage.getEscrow_DC_wallet(import_id, msg.sender), value);
               }
               //Calculate the amount to send back to DH and transfer the money back
               amount_to_send = SafeMath.sub(Storage.getEscrow_token_amount(import_id, msg.sender), Storage.getEscrow_tokens_sent(import_id, msg.sender));
               if(amount_to_send > 0) {
                    value = Storage.getEscrow_tokens_sent(import_id, msg.sender);
                    value.add(amount_to_send);
                    Storage.setEscrow_tokens_sent(import_id, msg.sender, value);

                    value = Storage.getProfile_balance(Storage.getEscrow_DC_wallet(import_id, msg.sender));
                    value.add(amount_to_send);
                    Storage.setProfile_balance(Storage.getEscrow_DC_wallet(import_id, msg.sender), value);
               }

               amount_to_send = Storage.getEscrow_stake_amount(import_id, msg.sender);
               Storage.setEscrow_stake_amount(import_id, msg.sender, 0);
               if(amount_to_send > 0) {
                    value = Storage.getProfile_balance(Storage.getEscrow_DC_wallet(import_id, msg.sender));
                    value.add(amount_to_send);
                    Storage.setProfile_balance(Storage.getEscrow_DC_wallet(import_id, msg.sender), value);
               }


               Storage.setEscrow_escrow_status(import_id, msg.sender, StorageContract.EscrowStatus.inactive);
               Storage.setLitigation_litigation_status(import_id, msg.sender, StorageContract.LitigationStatus.completed);
             
               Storage.setPurchasedData(import_id, msg.sender, address(0), bytes32(0), 0);

               emit LitigationTimedOut(import_id, msg.sender);
               return false;
          }
          else {
               Storage.setLitigation_requested_data(import_id, msg.sender, keccak256(abi.encodePacked(requested_data, Storage.getLitigation_requested_data_index(import_id, msg.sender))));
               Storage.setLitigation_answer_timestamp(import_id, msg.sender, block.timestamp);
               Storage.setLitigation_litigation_status(import_id, msg.sender, StorageContract.LitigationStatus.answered);
               // this_litigation.requested_data = keccak256(requested_data, this_litigation.requested_data_index);

               emit LitigationAnswered(import_id, msg.sender);
               return true;
          }
     }

     /**
     * @dev Allows the DH to mark a litigation as completed in order to call payOut. 
     * Used only when DC is inactive after DH sent litigation answer.
     */
     function cancelInactiveLitigation(bytes32 import_id)
     public {
          require(Storage.getLitigation_litigation_status(import_id, msg.sender) == StorageContract.LitigationStatus.answered
               &&   Storage.getLitigation_answer_timestamp(import_id, msg.sender) + Storage.getEscrow_litigation_interval_in_minutes(import_id, msg.sender).mul(60) <= block.timestamp);

          Storage.setLitigation_litigation_status(import_id, msg.sender, StorageContract.LitigationStatus.completed);

          emit LitigationCompleted(import_id, msg.sender, false);

     }

     function proveLitigaiton(bytes32 import_id, address DH_wallet, bytes32 proof_data)
     public returns (bool DH_was_penalized){

          require(Storage.getEscrow_DC_wallet(import_id, DH_wallet) == msg.sender && 
               (Storage.getLitigation_litigation_status(import_id, DH_wallet) == StorageContract.LitigationStatus.initiated 
             || Storage.getLitigation_litigation_status(import_id, DH_wallet) == StorageContract.LitigationStatus.answered));

          if (Storage.getLitigation_litigation_status(import_id, DH_wallet) == StorageContract.LitigationStatus.initiated){
               require(Storage.getLitigation_litigation_start_time(import_id, DH_wallet) + Storage.getEscrow_litigation_interval_in_minutes(import_id, DH_wallet).mul(60) <= block.timestamp);

               uint256 amount_to_send;

               uint time = Storage.getLitigation_litigation_start_time(import_id, DH_wallet);
               time = Storage.getEscrow_end_time(import_id, DH_wallet).sub(time);
               amount_to_send = Storage.getEscrow_token_amount(import_id, DH_wallet).mul(time) / Storage.getEscrow_total_time_in_seconds(import_id, DH_wallet);

               //Transfer the amount_to_send to DC 
               if(amount_to_send > 0) {
                    uint value = Storage.getEscrow_tokens_sent(import_id, DH_wallet);
                    value.add(amount_to_send);
                    Storage.setEscrow_tokens_sent(import_id, DH_wallet, value);

                    // Send tokens back to DC
                    //bidding.increaseBalance(this_escrow.DC_wallet, amount_to_send);
                    value = Storage.getProfile_balance(msg.sender);
                    value.add(amount_to_send);
                    Storage.setProfile_balance(msg.sender, value);
               }
               //Calculate the amount to send back to DH and transfer the money back
               amount_to_send = SafeMath.sub(Storage.getEscrow_token_amount(import_id, DH_wallet), Storage.getEscrow_tokens_sent(import_id, DH_wallet));
               if(amount_to_send > 0) {
                    value = Storage.getEscrow_tokens_sent(import_id, DH_wallet);
                    value.add(amount_to_send);
                    Storage.setEscrow_tokens_sent(import_id, DH_wallet, value);

                    value = Storage.getProfile_balance(msg.sender);
                    value.add(amount_to_send);
                    Storage.setProfile_balance(msg.sender, value);
               }

               amount_to_send = Storage.getEscrow_stake_amount(import_id, DH_wallet);
               Storage.setEscrow_stake_amount(import_id, DH_wallet, 0);
               if(amount_to_send > 0) {
                    value = Storage.getProfile_balance(msg.sender);
                    value.add(amount_to_send);
                    Storage.setProfile_balance(msg.sender, value);
               }

               // this_litigation.litigation_status = LitigationStatus.completed;
               // this_escrow.escrow_status = EscrowStatus.completed;
               
               Storage.setEscrow_escrow_status(import_id, DH_wallet, StorageContract.EscrowStatus.inactive);
               Storage.setLitigation_litigation_status(import_id, DH_wallet, StorageContract.LitigationStatus.completed);
             
               Storage.setPurchasedData(import_id, DH_wallet, address(0), bytes32(0), 0);

               emit LitigationTimedOut(import_id, DH_wallet);
               return true;
          }

          

          if(isDHokay(import_id, DH_wallet, proof_data)){
               // DH has the requested data -> Set litigation as completed, no transfer of tokens
               Storage.setLitigation_litigation_status(import_id, DH_wallet, StorageContract.LitigationStatus.completed);
               // this_litigation.litigation_status = LitigationStatus.completed;
               emit LitigationCompleted(import_id, DH_wallet, false);
               return false;
          }
          else {
               // DH didn't have the requested data, and the litigation was valid
               //        -> Distribute tokens and send stake to DC

               //Transfer the amount_to_send to DC 
               if(amount_to_send > 0) {
                    value = Storage.getEscrow_tokens_sent(import_id, DH_wallet);
                    value.add(amount_to_send);
                    Storage.setEscrow_tokens_sent(import_id, DH_wallet, value);

                    // Send tokens back to DC
                    //bidding.increaseBalance(this_escrow.DC_wallet, amount_to_send);
                    value = Storage.getProfile_balance(msg.sender);
                    value.add(amount_to_send);
                    Storage.setProfile_balance(msg.sender, value);
               }
               //Calculate the amount to send back to DH and transfer the money back
               amount_to_send = SafeMath.sub(Storage.getEscrow_token_amount(import_id, DH_wallet), Storage.getEscrow_tokens_sent(import_id, DH_wallet));
               if(amount_to_send > 0) {
                    value = Storage.getEscrow_tokens_sent(import_id, DH_wallet);
                    value.add(amount_to_send);
                    Storage.setEscrow_tokens_sent(import_id, DH_wallet, value);

                    value = Storage.getProfile_balance(msg.sender);
                    value.add(amount_to_send);
                    Storage.setProfile_balance(msg.sender, value);
               }

               amount_to_send = Storage.getEscrow_stake_amount(import_id, DH_wallet);
               Storage.setEscrow_stake_amount(import_id, DH_wallet, 0);
               if(amount_to_send > 0) {
                    value = Storage.getProfile_balance(msg.sender);
                    value.add(amount_to_send);
                    Storage.setProfile_balance(msg.sender, value);
               }

               // this_litigation.litigation_status = LitigationStatus.completed;
               // this_escrow.escrow_status = EscrowStatus.completed;
               
               Storage.setEscrow_escrow_status(import_id, DH_wallet, StorageContract.EscrowStatus.inactive);
               Storage.setLitigation_litigation_status(import_id, DH_wallet, StorageContract.LitigationStatus.completed);
             
               Storage.setPurchasedData(import_id, DH_wallet, address(0), bytes32(0), 0);
               emit LitigationCompleted(import_id, DH_wallet, true);
               return true;
          }
     }

     function isDHokay(bytes32 import_id, address DH_wallet, bytes32 proof_data) internal view returns(bool DH_is_okay){
          uint256 i = 0;
          uint256 one = 1;
          bytes32 proof_hash = keccak256(abi.encodePacked(proof_data, Storage.getLitigation_requested_data_index(import_id, DH_wallet)));    
          // bytes32 proof_hash = keccak256(abi.encodePacked(proof_data, this_litigation.requested_data_index));   
          bytes32 answer_hash = Storage.getLitigation_requested_data(import_id, DH_wallet);
          bytes32[] memory hash_array = Storage.getLitigation_hash_array(import_id,DH_wallet);
          // ako je bit 1 on je levo
          while (i < hash_array.length){

               if( ((one << i) & Storage.getLitigation_requested_data_index(import_id, DH_wallet)) != 0 ){
                    proof_hash = keccak256(abi.encodePacked(hash_array[i], proof_hash));
                    answer_hash = keccak256(abi.encodePacked(hash_array[i], answer_hash));
               }
               else {
                    proof_hash = keccak256(abi.encodePacked(proof_hash, hash_array[i]));
                    answer_hash = keccak256(abi.encodePacked(answer_hash, hash_array[i]));
               }
               i++;
          }

          if(answer_hash == Storage.getEscrow_litigation_root_hash(import_id, DH_wallet)) return true;
          else {
               if(proof_hash == Storage.getEscrow_litigation_root_hash(import_id, DH_wallet)) return false;
               else return true;
          }
     }


 }
