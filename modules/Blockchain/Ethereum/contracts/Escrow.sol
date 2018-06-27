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
     function getProfile_reputation(address wallet) public view returns(uint);
     function getProfile_number_of_escrows(address wallet) public view returns(uint);

     function setProfile_balance(address wallet, uint256 balance) public;
     function setProfile_reputation(address wallet, uint256 reputation) public;
     function setProfile_number_of_escrows(address wallet, uint256 number_of_escrows) public;
}

contract EscrowStorage{
     enum EscrowStatus {inactive, initiated, confirmed, active, completed}

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
}

contract LitigationStorage{
     enum LitigationStatus {inactive, initiated, answered, timed_out, completed}
     function getLitigation_litigation_status(bytes32 import_id, address DH_wallet) public view returns(LitigationStatus);
}

contract ReadingStorage {
     function setPurchasedData( bytes32 import_id, address DH_wallet, address DC_wallet, bytes32 distribution_root_hash, uint256 checksum ) public;
}

contract ContractHub{
     address public biddingAddress;

     address public profileStorageAddress;
     address public escrowStorageAddress;
     address public litigationStorageAddress;
     address public readingStorageAddress;
}

contract EscrowHolder{
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
     // TODO Check if these functions didn't pass because Hub wasn't deployed
     function initiate() public {
          profileStorage = ProfileStorage(Hub.profileStorageAddress());
          escrowStorage  = EscrowStorage(Hub.escrowStorageAddress());
          litigationStorage = LitigationStorage(Hub.litigationStorageAddress());
          readingStorage = ReadingStorage(Hub.readingStorageAddress());
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
          require(escrowStorage.getEscrow_escrow_status(import_id, DH_wallet) == EscrowStorage.EscrowStatus.completed
               ||   escrowStorage.getEscrow_escrow_status(import_id, DH_wallet) == EscrowStorage.EscrowStatus.inactive);

          require(total_time_in_minutes > 0);
          escrowStorage.setEscrow_DC_wallet(import_id, DH_wallet, DC_wallet);
          escrowStorage.setEscrow_token_amount(import_id, DH_wallet, token_amount);
          escrowStorage.setEscrow_tokens_sent(import_id, DH_wallet, 0);
          escrowStorage.setEscrow_stake_amount(import_id, DH_wallet, stake_amount);
          escrowStorage.setEscrow_last_confirmation_time(import_id, DH_wallet, 0);
          escrowStorage.setEscrow_end_time(import_id, DH_wallet, 0);
          escrowStorage.setEscrow_total_time_in_seconds(import_id, DH_wallet, total_time_in_minutes.mul(60));
          escrowStorage.setEscrow_litigation_interval_in_minutes(import_id, DH_wallet, litigation_interval_in_minutes);
          escrowStorage.setEscrow_escrow_status(import_id, DH_wallet, EscrowStorage.EscrowStatus.initiated);

          emit EscrowInitated(import_id, DH_wallet, token_amount, stake_amount, total_time_in_minutes);
     }

     function addRootHashAndChecksum(bytes32 import_id, bytes32 litigation_root_hash, bytes32 distribution_root_hash, uint256 checksum)
     public {
          require(escrowStorage.getEscrow_escrow_status(import_id, msg.sender) == EscrowStorage.EscrowStatus.initiated);

          escrowStorage.setEscrow_litigation_root_hash(import_id, msg.sender, litigation_root_hash);
          escrowStorage.setEscrow_distribution_root_hash(import_id, msg.sender, distribution_root_hash);
          escrowStorage.setEscrow_checksum(import_id, msg.sender, checksum);

          //Transfer the stake_amount to the escrow
          uint balance = profileStorage.getProfile_balance(msg.sender);
          require(balance >= escrowStorage.getEscrow_stake_amount(import_id, msg.sender));
          balance.sub(escrowStorage.getEscrow_stake_amount(import_id, msg.sender));
          profileStorage.setProfile_balance(msg.sender, balance);

          escrowStorage.setEscrow_escrow_status(import_id, msg.sender, EscrowStorage.EscrowStatus.confirmed);
          emit EscrowConfirmed(import_id, msg.sender);
     }

     function verifyEscrow(bytes32 import_id, address DH_wallet)
     public {
          require(escrowStorage.getEscrow_DC_wallet(import_id, DH_wallet) == msg.sender
               && escrowStorage.getEscrow_escrow_status(import_id, DH_wallet) == EscrowStorage.EscrowStatus.confirmed);

          profileStorage.setProfile_number_of_escrows(msg.sender, profileStorage.getProfile_number_of_escrows(msg.sender).add(1));
          profileStorage.setProfile_number_of_escrows(DH_wallet, profileStorage.getProfile_number_of_escrows(DH_wallet).add(1));

          escrowStorage.setEscrow_last_confirmation_time(import_id, DH_wallet, block.timestamp);
          escrowStorage.setEscrow_end_time(import_id, DH_wallet, block.timestamp.add(escrowStorage.getEscrow_total_time_in_seconds(import_id, DH_wallet)));

          readingStorage.setPurchasedData(import_id, DH_wallet, msg.sender, escrowStorage.getEscrow_distribution_root_hash(import_id, DH_wallet), escrowStorage.getEscrow_checksum(import_id, DH_wallet));

          escrowStorage.setEscrow_escrow_status(import_id, DH_wallet, EscrowStorage.EscrowStatus.active);
          emit EscrowVerified(import_id, DH_wallet);
     }

     function payOut(bytes32 import_id)
     public{

          require(escrowStorage.getEscrow_escrow_status(import_id, msg.sender) == EscrowStorage.EscrowStatus.active);
          require(litigationStorage.getLitigation_litigation_status(import_id, msg.sender) == LitigationStorage.LitigationStatus.inactive
               ||  litigationStorage.getLitigation_litigation_status(import_id, msg.sender) == LitigationStorage.LitigationStatus.completed);

          uint256 amount_to_send;

          uint current_time = block.timestamp;
          if(current_time > escrowStorage.getEscrow_end_time(import_id, msg.sender)){
               uint stake_to_send = escrowStorage.getEscrow_stake_amount(import_id, msg.sender);
               escrowStorage.setEscrow_stake_amount(import_id, msg.sender, 0);
               if(stake_to_send > 0) {
                    uint value = profileStorage.getProfile_balance(msg.sender);
                    value.add(stake_to_send);
                    profileStorage.setProfile_balance(msg.sender, value);

                    value = profileStorage.getProfile_reputation(msg.sender);
                    value.add(stake_to_send);
                    profileStorage.setProfile_reputation(msg.sender, value);
                    value = profileStorage.getProfile_reputation(escrowStorage.getEscrow_DC_wallet(import_id, msg.sender));
                    value.add(stake_to_send);
                    profileStorage.setProfile_reputation(escrowStorage.getEscrow_DC_wallet(import_id, msg.sender), value);
               }
               amount_to_send = SafeMath.sub(escrowStorage.getEscrow_token_amount(import_id, msg.sender), escrowStorage.getEscrow_tokens_sent(import_id, msg.sender));
               escrowStorage.setEscrow_escrow_status(import_id, msg.sender, EscrowStorage.EscrowStatus.completed);
               emit EscrowCompleted(import_id, msg.sender);
          }
          else{
               amount_to_send = current_time.sub(escrowStorage.getEscrow_last_confirmation_time(import_id, msg.sender));
               amount_to_send = amount_to_send.mul(escrowStorage.getEscrow_token_amount(import_id, msg.sender));
               amount_to_send = amount_to_send / escrowStorage.getEscrow_total_time_in_seconds(import_id, msg.sender);
               assert(amount_to_send.add(escrowStorage.getEscrow_tokens_sent(import_id, msg.sender)) <= escrowStorage.getEscrow_token_amount(import_id, msg.sender));
               escrowStorage.setEscrow_last_confirmation_time(import_id, msg.sender, current_time);
          }

          if(amount_to_send > 0) {
               value = escrowStorage.getEscrow_tokens_sent(import_id, msg.sender);
               value.add(amount_to_send);
               escrowStorage.setEscrow_tokens_sent(import_id, msg.sender, value);

               value = profileStorage.getProfile_balance(msg.sender);
               value.add(amount_to_send);
               profileStorage.setProfile_balance(msg.sender, value);
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

          require(DC_wallet == escrowStorage.getEscrow_DC_wallet(import_id, DH_wallet));

          require(escrowStorage.getEscrow_escrow_status(import_id, msg.sender) == EscrowStorage.EscrowStatus.initiated
               || escrowStorage.getEscrow_escrow_status(import_id, msg.sender) == EscrowStorage.EscrowStatus.confirmed);

          uint256 amount_to_send = escrowStorage.getEscrow_token_amount(import_id, msg.sender);
          escrowStorage.setEscrow_token_amount(import_id, msg.sender, 0);
          if(amount_to_send > 0) {
               uint value = profileStorage.getProfile_balance(DC_wallet);
               value.add(amount_to_send);
               profileStorage.setProfile_balance(DC_wallet, value);
          }
          if(escrowStorage.getEscrow_escrow_status(import_id, msg.sender) == EscrowStorage.EscrowStatus.confirmed){
               amount_to_send = escrowStorage.getEscrow_stake_amount(import_id, msg.sender);
               escrowStorage.setEscrow_stake_amount(import_id, msg.sender, 0);
               if(amount_to_send > 0) {
                    value = profileStorage.getProfile_balance(DH_wallet);
                    value.add(amount_to_send);
                    profileStorage.setProfile_balance(DH_wallet, value);
               }
          }

          escrowStorage.setEscrow_escrow_status(import_id, msg.sender, EscrowStorage.EscrowStatus.completed);
          emit EscrowCanceled(import_id, DH_wallet);
     }


}
