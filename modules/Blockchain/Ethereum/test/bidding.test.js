/* eslint-disable max-len, no-undef */
const { assert, expect } = require('chai');
const BN = require('bn.js');

// Functional contracts
var ContractHub = artifacts.require('./ContractHub.sol');
var TracToken = artifacts.require('./TracToken.sol');
var Profile = artifacts.require('./Profile.sol');
var Bidding = artifacts.require('./Bidding.sol');
var Litigation = artifacts.require('./Litigation.sol');
var EscrowHolder = artifacts.require('./EscrowHolder.sol');
var Reading = artifacts.require('./Reading.sol');

// Storage contracts
var ProfileStorage = artifacts.require('./ProfileStorage.sol');
var BiddingStorage = artifacts.require('./BiddingStorage.sol');
var EscrowStorage = artifacts.require('./EscrowStorage.sol');
var LitigationStorage = artifacts.require('./LitigationStorage.sol');
var ReadingStorage = artifacts.require('./ReadingStorage.sol');
var TestingUtilities = artifacts.require('./TestingUtilities.sol');

var Web3 = require('web3');

// Global values
var DC_wallet;
const amount_to_mint = (new BN(5)).mul((new BN(10)).pow(new BN(25)));


// Offer variables
var import_id = 0;
const data_size = new BN(1);
const total_escrow_time = new BN(1);
const max_token_amount = (new BN(10)).pow(new BN(18));
const min_stake_amount = (new BN(10)).pow(new BN(12));
const min_reputation = new BN(0);
const predestined_first_bid_index = new BN(9);
const litigation_interval_in_minutes = new BN(1);

// Profile variables
var chosen_bids = [];
var node_id = [];
var DH_balance = [];
var DH_credit = [];
var DH_price = [];
var DH_stake = [];
var DH_read_factor = [];


contract('Bidding testing', async (accounts) => {

    // before('Should wait for end of contract migration', async () => {
    //     await new Promise((resolve) => {
    //         setTimeout(resolve, 10000);
    //         console.log("Finished waiting");
    //     });
    // });

    it('Should get ContractHub contract', async () => {
        const res = await ContractHub.deployed();
        console.log(`\t ContractHub address: ${res.address}`);
    });

    it('Should get Token contract', async () => {
        const hub = await ContractHub.deployed();
        const res = await hub.tokenAddress.call();
        console.log(`\t Token address: ${res}`);
    });

    it('Should get Escrow contract', async () => {
        const hub = await ContractHub.deployed();
        const res = await hub.escrowAddress.call();
        console.log(`\t Escrow address: ${res}`);
    });

    it('Should get Bidding contract', async () => {
        const hub = await ContractHub.deployed();
        const res = await hub.biddingAddress.call();
        console.log(`\t Bidding address: ${res}`);
    });

    it('Should get Reading contract', async () => {
        const hub = await ContractHub.deployed();
        const res = await hub.readingAddress.call();
        console.log(`\t Reading address: ${res}`);
    });

    it('Should get TestingUtilities contract', async () => {
        const util = await TestingUtilities.deployed();
        console.log(`\t TestingUtilities address: ${util.address}`);
    });

    DC_wallet = accounts[0]; // eslint-disable-line prefer-destructuring


    it('Should make node_id for every profile (as keccak256(wallet_address))', async () => {
        // Get instances of contracts used in the test
        const util = await TestingUtilities.deployed();

        for (var i = 0; i < 10; i += 1) {
            // eslint-disable-next-line no-await-in-loop
            const response = await util.keccakSender.call({ from: accounts[i] });
            node_id.push(response);
        }
    });

    // createProfile(bytes32 node_id, uint price, uint stake, uint max_time, uint max_size)
    // 0: uint256: token_amount
    // 1: uint256: stake_amount
    // 2: uint256: read_stake_factor
    // 3: uint256: balance
    // 4: uint256: reputation
    // 5: uint256: max_escrow_time
    // 6: uint256: size_available

    it('Should create 10 profiles', async () => {
        // Get instances of contracts used in the test
        const hub = await ContractHub.deployed();
        const profileAddress = await hub.profileAddress.call();
        const profileStorageAddress = await hub.profileStorageAddress.call();
        const profile = await Profile.at(profileAddress);
        const profileStorage = await ProfileStorage.at(profileStorageAddress);

        var promises = [];
        for (var i = 0; i < 10; i += 1) {
            // console.log(`\t Creating profile ${node_id[i]}`);
            DH_balance[i] = amount_to_mint; // 5e25
            DH_price[i] = (new BN(Math.round(Math.random() * 1000) + 10)).mul((new BN(10)).pow(new BN(15)));
            DH_stake[i] = (new BN(Math.round(Math.random() * 1000) + 10)).mul((new BN(10)).pow(new BN(15)));
            DH_read_factor[i] = new BN(Math.round(Math.random() * 5));
            promises[i] = profile.createProfile(
                DH_price[i],
                DH_stake[i],
                DH_read_factor[i],
                1000,
                { from: accounts[i] },
            );
        }
        await Promise.all(promises);
        for (i = 0; i < DH_price.length; i += 1) {
            // eslint-disable-next-line no-await-in-loop
            var response = await profileStorage.profile.call(accounts[i]);

            let actual_price = response[0];
            let actual_stake = response[1];

            assert(actual_price.eq(DH_price[i]), 'Price not matching');
            assert(actual_stake.eq(DH_stake[i]), 'Stake not matching');


            console.log(`\t account[${i}] \t price: ${response[0].div((new BN(10)).pow(new BN(15)))} \t stake: ${response[1].div((new BN(10)).pow(new BN(15)))}`);
        }
    });

    it('Should increase node-bidding approval before depositing', async () => {
        // Get instances of contracts used in the test
        const hub = await ContractHub.deployed();
        const profileAddress = await hub.profileAddress.call();
        const tokenAddress = await hub.tokenAddress.call();
        const profile = await Profile.at(profileAddress);
        const token = await TracToken.at(tokenAddress);

        var promises = [];
        for (var i = 0; i < 10; i += 1) {
            promises[i] = token.increaseApproval(
                profileAddress, DH_balance[i],
                { from: accounts[i] },
            );
        }
        await Promise.all(promises);

        for (i = 0; i < DH_balance.length; i += 1) {
            // eslint-disable-next-line no-await-in-loop
            var allowance = await token.allowance.call(accounts[i], profileAddress);
            assert(allowance.eq(DH_balance[i]), 'The proper amount was not allowed');
        }
    });

    it('Should deposit tokens from every node to bidding', async () => {
        // Get instances of contracts used in the test
        const hub = await ContractHub.deployed();
        const profileAddress = await hub.profileAddress.call();
        const profile = await Profile.at(profileAddress);
        const profileStorageAddress = await hub.profileStorageAddress.call();
        const profileStorage = await ProfileStorage.at(profileStorageAddress);

        var promises = [];
        for (var i = 0; i < 10; i += 1) {
            promises[i] = profile.depositToken(DH_balance[i], { from: accounts[i] });
        }
        await Promise.all(promises);


        for (i = 0; i < DH_balance.length; i += 1) {
            // eslint-disable-next-line no-await-in-loop
            var response = await profileStorage.profile.call(accounts[i]);
            var actual_balance = response[3];
            assert(actual_balance.eq(DH_balance[i]), 'The proper amount was not deposited');
            DH_balance[i] = 0;
            DH_credit[i] = actual_balance.clone();
        }
    });

    it('Should create escrow offer, with acc[1] and [2] as predetermined', async () => {
        // Get instances of contracts used in the test
        const hub = await ContractHub.deployed();
        const profileAddress = await hub.profileAddress.call();
        const profile = await Profile.at(profileAddress);
        const profileStorageAddress = await hub.profileStorageAddress.call();
        const profileStorage = await ProfileStorage.at(profileStorageAddress);
        const biddingAddress = await hub.biddingAddress.call();
        const bidding = await Bidding.at(biddingAddress);
        const biddingStorageAddress = await hub.biddingStorageAddress.call();
        const biddingStorage = await BiddingStorage.at(biddingStorageAddress);
        const util = await TestingUtilities.deployed();

        const predetermined_wallet = [];
        predetermined_wallet.push(accounts[1]);
        predetermined_wallet.push(accounts[2]);
        const predetermined_node_id = [];
        predetermined_node_id.push(node_id[1]);
        predetermined_node_id.push(node_id[2]);

        // Data holding parameters
        const data_hash = await util.keccakSender.call({ from: accounts[predestined_first_bid_index] });
        import_id = await util.keccakString.call("import");
        console.log(`\t Data hash: ${data_hash}`);
        console.log(`\t Import ID: ${import_id}`);

        await bidding.createOffer(
            import_id,
            node_id[0],

            total_escrow_time,
            max_token_amount,
            min_stake_amount,
            min_reputation,

            data_hash,
            data_size,
            litigation_interval_in_minutes,

            predetermined_wallet,
            predetermined_node_id,
            { from: DC_wallet },
        );

        const response = await biddingStorage.offer.call(import_id);

        const actual_DC_wallet = response[0];
        console.log(`\t DC_wallet: ${actual_DC_wallet}`);

        let actual_max_token = response[1];
        console.log(`\t actual_max_token: ${actual_max_token.toString()}`);

        let actual_min_stake = response[2];
        console.log(`\t actual_min_stake: ${actual_min_stake.toString()}`);

        let actual_min_reputation = response[3];
        console.log(`\t actual_min_reputation: ${actual_min_reputation.toString()}`);

        let actual_escrow_time = response[4];
        console.log(`\t actual_escrow_time: ${actual_escrow_time.toString()}`);

        let actual_data_size = response[5];
        console.log(`\t actual_data_size: ${actual_data_size.toString()}`);

        let replication_factor = response[10];
        console.log(`\t replication_factor: ${replication_factor.toString()}`);

        assert.equal(actual_DC_wallet, DC_wallet, 'DC_wallet not matching');
        assert(actual_max_token.eq(max_token_amount), 'max_token_amount not matching');
        assert(actual_min_stake.eq(min_stake_amount), 'min_stake_amount not matching');
        assert(actual_min_reputation.eq(min_reputation), 'min_reputation not matching');
        assert(actual_data_size.eq(data_size), 'data_size not matching');
        assert(actual_escrow_time.eq(total_escrow_time), 'total_escrow_time not matching');
        assert(replication_factor.eq(new BN(predetermined_wallet.length)), 'replication_factor not matching');
    });

    it('Should activate predetermined bid for acc[2]', async () => {
        // Get instances of contracts used in the test
        const hub = await ContractHub.deployed();
        const biddingAddress = await hub.biddingAddress.call();
        const bidding = await Bidding.at(biddingAddress);
        const biddingStorageAddress = await hub.biddingStorageAddress.call();
        const biddingStorage = await BiddingStorage.at(biddingStorageAddress);

        await bidding.activatePredeterminedBid(import_id, node_id[2], new BN(1), { from: accounts[2] });

        const response = await biddingStorage.getBid_active.call(import_id, 1);
        assert.equal(response, true, 'Predetermined bid not activated!');
    });

    it('Should add 7 more bids', async () => {
        // Get instances of contracts used in the test
        const hub = await ContractHub.deployed();
        const biddingAddress = await hub.biddingAddress.call();
        const bidding = await Bidding.at(biddingAddress);
        const biddingStorageAddress = await hub.biddingStorageAddress.call();
        const biddingStorage = await BiddingStorage.at(biddingStorageAddress);
        const util = await TestingUtilities.deployed();

        for (var i = 3; i < 10; i += 1) {
            // eslint-disable-next-line no-await-in-loop
            var response = await bidding.calculateRanking.call(import_id, accounts[i], data_size.mul(total_escrow_time));
            console.log(`\t Ranking for profile[${i}] = ${response.toString()}`);
        }

        var first_bid_index;
        for (i = 3; i < 10; i += 1) {
            // eslint-disable-next-line no-await-in-loop
            await bidding.addBid(import_id, node_id[i], { from: accounts[i] });
            // eslint-disable-next-line no-await-in-loop
            response = await biddingStorage.getOffer_first_bid_index.call(import_id);
            first_bid_index = response.clone();
            console.log(`\t Current first bid index: ${first_bid_index.toString()} (profile[${first_bid_index.add(new BN(1)).toString()}])`);
        }

        // TODO Figure out why is ranking going haywire
        // assert(first_bid_index.eq(predestined_first_bid_index.sub(new BN(1))), 'First bid index not matching');
    });

    // // EscrowDefinition
    // // 0: uint token_amount
    // // 1: uint tokens_sent
    // // 2: uint stake_amount
    // // 3: uint last_confirmation_time
    // // 4: uint end_time
    // // 5: uint total_time

    it('Should choose bids', async () => {
        // Get instances of contracts used in the test
        const hub = await ContractHub.deployed();
        const biddingAddress = await hub.biddingAddress.call();
        const bidding = await Bidding.at(biddingAddress);
        const util = await TestingUtilities.deployed();


        chosen_bids = await bidding.chooseBids.call(import_id, { from: DC_wallet, gas: 6000000});
        console.log(`\t chosen DH indexes: ${JSON.stringify(chosen_bids)}`);


        for (var i = 0; i < chosen_bids.length; i += 1) {
            chosen_bids[i] = chosen_bids[i].add(new BN(1));
        }

        const receipt = await bidding.chooseBids(import_id);

        // await util.error();

        const gasUsed = receipt.receipt.gasUsed;
        console.log(`\t GasUsed: ${receipt.receipt.gasUsed}`);
    });

    // Merkle tree structure
    //         / \
    //        /   \
    //       /     \
    //      /       \
    //     /         \
    //    / \       / \
    //   /   \     /   \
    //  /\   /\   /\   /\
    // A  B C  D E  F G  H

    var requested_data_index = new BN(5);
    var requested_data = [];
    var hashes = [];
    var hash_AB;
    var hash_CD;
    var hash_EF;
    var hash_GH;
    var hash_ABCD;
    var hash_EFGH;
    var root_hash;

    const checksum = new BN(0);

    it('Should calculate and add all root hashes and checksums', async () => {
        // Get instances of contracts used in the test
        const hub = await ContractHub.deployed();
        const biddingAddress = await hub.biddingAddress.call();
        const bidding = await Bidding.at(biddingAddress);
        const escrowAddress = await hub.escrowAddress.call();
        const escrow = await EscrowHolder.at(escrowAddress);
        const escrowStorageAddress = await hub.escrowStorageAddress.call();
        const escrowStorage = await EscrowStorage.at(escrowStorageAddress);
        const util = await TestingUtilities.deployed();

        // Creating merkle tree
        for (var i = 0; i < 8; i += 1) {
            // eslint-disable-next-line no-await-in-loop
            requested_data[i] = await util.keccakString.call('A');
            // eslint-disable-next-line no-await-in-loop
            hashes[i] = await util.keccakIndex.call(requested_data[i], i);
        }
        hash_AB = await util.keccak2hashes.call(hashes[0], hashes[1]);
        hash_CD = await util.keccak2hashes.call(hashes[2], hashes[3]);
        hash_EF = await util.keccak2hashes.call(hashes[4], hashes[5]);
        hash_GH = await util.keccak2hashes.call(hashes[6], hashes[7]);
        hash_ABCD = await util.keccak2hashes.call(hash_AB, hash_CD);
        hash_EFGH = await util.keccak2hashes.call(hash_EF, hash_GH);
        root_hash = await util.keccak2hashes.call(hash_ABCD, hash_EFGH);

        var promises = [];
        for (i = 0; i < chosen_bids.length; i += 1) {
            promises[i] = escrow.addRootHashAndChecksum(
                import_id,
                root_hash,
                root_hash,
                checksum,
                { from: accounts[chosen_bids[i]] },
            );
        }
        await Promise.all(promises);
    });

    it('Should verify all escrows', async () => {
        // Get instances of contracts used in the test
        const hub = await ContractHub.deployed();
        const escrowAddress = await hub.escrowAddress.call();
        const escrow = await EscrowHolder.at(escrowAddress);
        const escrowStorageAddress = await hub.escrowStorageAddress.call();
        const escrowStorage = await EscrowStorage.at(escrowStorageAddress);
        const profileStorageAddress = await hub.profileStorageAddress.call();
        const profileStorage = await ProfileStorage.at(profileStorageAddress);
        const util = await TestingUtilities.deployed();


        var promises = [];
        for (var i = 0; i < chosen_bids.length; i += 1) {
            promises[i] = escrow.verifyEscrow(
                import_id,
                accounts[chosen_bids[i]],
                { from: DC_wallet },
            );
        }
        await Promise.all(promises);

        // Get block timestamp
        var response = await util.getBlockTimestamp.call();
        response = response.toNumber();
        console.log(`\t Escrow start time: ${response}, Escrow end time: ${response + (60 * total_escrow_time)}`);

        for (i = 1; i < 10; i += 1) {
            // eslint-disable-next-line no-await-in-loop
            response = await escrowStorage.escrow.call(import_id, accounts[i]);
            let status = response[11];
            status = status.toNumber();
            switch (status) {
            case 0:
                status = 'inactive';
                break;
            case 1:
                status = 'initiated';
                break;
            case 2:
                status = 'confirmed';
                break;
            case 3:
                status = 'active';
                break;
            case 4:
                status = 'completed';
                break;
            default:
                status = 'err';
                break;
            }
            console.log(`\t EscrowStatus for account[${i}]: ${status}`);
            if (chosen_bids.includes(i)) {
                assert.equal(status, 'active', "Escrow wasn't verified");
            }
        }
    });

    var litigators = [];

    it('Should create 2 litigations about data no 6', async () => {
        // Get instances of contracts used in the test
        const hub = await ContractHub.deployed();
        const litigationAddress = await hub.litigationAddress.call();
        const litigation = await Litigation.at(litigationAddress);
        const litigationStorageAddress = await hub.litigationStorageAddress.call();
        const litigationStorage = await LitigationStorage.at(litigationStorageAddress);
        const util = await TestingUtilities.deployed();

        // TODO Find a way not to hard code this test
        requested_data_index = new BN(5);
        var hash_array = [];
        hash_array.push(hashes[4]);
        hash_array.push(hash_GH);
        hash_array.push(hash_ABCD);

        litigators.push(chosen_bids[0]);
        litigators.push(chosen_bids[1]);

        await litigation.initiateLitigation(
            import_id,
            accounts[litigators[0]],
            requested_data_index,
            hash_array,
            { from: DC_wallet },
        );
        await litigation.initiateLitigation(
            import_id,
            accounts[litigators[1]],
            requested_data_index,
            hash_array,
            { from: DC_wallet },
        );
    });

    it('Should answer litigations, one correctly, one incorrectly', async () => {
        // Get instances of contracts used in the test
        const hub = await ContractHub.deployed();
        const litigationAddress = await hub.litigationAddress.call();
        const litigation = await Litigation.at(litigationAddress);
        const litigationStorageAddress = await hub.litigationStorageAddress.call();
        const litigationStorage = await LitigationStorage.at(litigationStorageAddress);
        const util = await TestingUtilities.deployed();


        await litigation.answerLitigation(
            import_id,
            requested_data[requested_data_index],
            { from: accounts[litigators[0]] },
        );

        const incorrect_answer = await util.keccakSender.call();

        await litigation.answerLitigation(
            import_id,
            incorrect_answer,
            { from: accounts[litigators[1]] },
        );
    });

    it('Should prove litigations, both correctly', async () => {
        // Get instances of contracts used in the test
        const hub = await ContractHub.deployed();
        const litigationAddress = await hub.litigationAddress.call();
        const litigation = await Litigation.at(litigationAddress);
        const litigationStorageAddress = await hub.litigationStorageAddress.call();
        const litigationStorage = await LitigationStorage.at(litigationStorageAddress);
        const escrowStorageAddress = await hub.escrowStorageAddress.call();
        const escrowStorage = await EscrowStorage.at(escrowStorageAddress);
        const util = await TestingUtilities.deployed();

        var promises = [];
        for (var i = 0; i < litigators.length; i += 1) {
            promises[i] = litigation.proveLitigaiton(
                import_id,
                accounts[litigators[i]],
                requested_data[requested_data_index],
                { from: DC_wallet },
            );
        }
        await Promise.all(promises);
    });

    it('Should wait 30 seconds, then pay all DHs', async () => {
        // Get instances of contracts used in the test
        const hub = await ContractHub.deployed();
        const profileStorageAddress = await hub.profileStorageAddress.call();
        const profileStorage = await ProfileStorage.at(profileStorageAddress);
        const escrowAddress = await hub.escrowAddress.call();
        const escrow = await EscrowHolder.at(escrowAddress);
        const escrowStorageAddress = await hub.escrowStorageAddress.call();
        const escrowStorage = await EscrowStorage.at(escrowStorageAddress);
        const util = await TestingUtilities.deployed();

        await new Promise(resolve => setTimeout(resolve, 30000));

        var response = await util.getBlockTimestamp.call();
        console.log(`\t Current block time: ${response.toString()}`);

        var promises = [];
        for (var i = 0; i < chosen_bids.length; i += 1) {
            if (chosen_bids[i] !== litigators[1]) {
                promises[i] = escrow.payOut(
                    import_id,
                    { from: accounts[chosen_bids[i]], gas: 1000000 },
                );
            }
        }
        await Promise.all(promises);

        for (i = 0; i < chosen_bids.length; i += 1) {
            // eslint-disable-next-line no-await-in-loop
            response = await profileStorage.getProfile_balance.call(accounts[chosen_bids[i]]);
            console.log(`\t Balance of profile[${chosen_bids[i]}]: ${response.toString()}`);
        }
    });

    it('Should wait another 30 seconds, then pay out all DH_s', async () => {
        // Get instances of contracts used in the test
        const hub = await ContractHub.deployed();
        const profileStorageAddress = await hub.profileStorageAddress.call();
        const profileStorage = await ProfileStorage.at(profileStorageAddress);
        const escrowAddress = await hub.escrowAddress.call();
        const escrow = await EscrowHolder.at(escrowAddress);
        const escrowStorageAddress = await hub.escrowStorageAddress.call();
        const escrowStorage = await EscrowStorage.at(escrowStorageAddress);
        const util = await TestingUtilities.deployed();

        // Await for 35 seconds, just to be on the safe side
        await new Promise(resolve => setTimeout(resolve, 40000));

        var response = await util.getBlockTimestamp.call();
        response = response.toNumber();
        console.log(`\t Escrow finish time: ${response}`);

        var promises = [];
        for (var i = 0; i < chosen_bids.length; i += 1) {
            if (chosen_bids[i] !== litigators[1]) {
                promises[i] = escrow.payOut(
                    import_id,
                    { from: accounts[chosen_bids[i]], gas: 1000000 },
                );
            }
        }
        await Promise.all(promises);

        for (i = 0; i < chosen_bids.length; i += 1) {
            // eslint-disable-next-line no-await-in-loop
            response = await escrowStorage.getEscrow_escrow_status.call(import_id, accounts[chosen_bids[i]]);
            let status = response;
            if(status.eq(new BN(0))) status = 'inactive';
            else if(status.eq(new BN(1))) status = 'initiated';
            else if(status.eq(new BN(2))) status = 'confirmed';
            else if(status.eq(new BN(3))) status = 'active';
            else if(status.eq(new BN(4))) status = 'completed';
            else status = 'err';

            console.log(`\t EscrowStatus for account[${chosen_bids[i]}]: ${status}`);
            assert.equal(status, 'completed', "Escrow wasn't completed");
        }

        for (i = 0; i < chosen_bids.length; i = i + 1) {
            // eslint-disable-next-line
            var balance = await profileStorage.getProfile_balance.call(accounts[chosen_bids[i]]);
            console.log(`\t Final balance for profile[${chosen_bids[i]}]: ${balance.toString()}`);

            if(chosen_bids[i] != litigators[1])
                assert(balance.eq(DH_credit[chosen_bids[i]].add(DH_price[chosen_bids[i]])), "Ending DH balance not correct");
            else
                assert(balance.eq(DH_credit[chosen_bids[i]].sub(DH_stake[chosen_bids[i]])), "Ending DH balance not correct");
            DH_credit[chosen_bids[i]] = balance.clone();
        }
    });


    var read_token_amount = (new BN(10)).pow(new BN(10));
    var dispute_interval_in_minutes = new BN(1);

    it('Should initiate reading between acc[2] and acc[1]', async () => {
        // Get instances of contracts used in the test
        const hub = await ContractHub.deployed();
        const readingAddress = await hub.readingAddress.call();
        const reading = await Reading.at(readingAddress);
        const readingStorageAddress = await hub.readingStorageAddress.call();
        const readingStorage = await ReadingStorage.at(readingStorageAddress);

        const read_stake_factor = DH_read_factor[chosen_bids[0]];


        var response = await readingStorage.purchased_data.call(import_id, accounts[chosen_bids[0]]);

        var actual_DC_wallet = response[0];
        var actual_distribution_root_hash = response[1];
        var actual_checksum = response[2];

        assert.equal(actual_DC_wallet, DC_wallet, 'Purchased data - DC wallet not matching');
        assert.equal(
            actual_distribution_root_hash,
            root_hash,
            'Purchased data - distribution root hash not matching',
        );
        assert(
            actual_checksum.eq(checksum),
            'Purchased data - checksum not matching',
        );

        await reading.initiatePurchase(
            import_id,
            accounts[chosen_bids[0]],
            read_token_amount,
            dispute_interval_in_minutes,
            { from: accounts[2] },
        );

        response = await readingStorage.purchase.call(accounts[chosen_bids[0]], accounts[2], import_id);
        var actual_token_amount = response[0];
        var actual_stake_factor = response[1];
        var actual_status = response[6];

        assert(
            actual_token_amount.eq(read_token_amount),
            'Read token amount not matching',
        );
        assert(
            actual_stake_factor.eq(read_stake_factor),
            'Read stake factor not matching',
        );
        assert(
            actual_status.eq(new BN(1)),
            'Read status not initiated',
        );
    });
});
