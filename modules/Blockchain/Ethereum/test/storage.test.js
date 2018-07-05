/* eslint-disable max-len, no-undef */

const { assert, expect } = require('chai');
const { before } = require('mocha');

var TestingUtilities = artifacts.require('./TestingUtilities.sol');
var TracToken = artifacts.require('./TracToken.sol');
var EscrowHolder = artifacts.require('./EscrowHolder.sol');
var Bidding = artifacts.require('./BiddingTest.sol');
var Reading = artifacts.require('./Reading.sol');
var StorageContract = artifacts.require('./Storage.sol');

var Web3 = require('web3');

// Global values
var DC_wallet;
const amount_to_mint = 5e25;

// Offer variables
var import_id = 0;
const data_size = 1;
const total_escrow_time = 1;
const max_token_amount = 1000e18;
const min_stake_amount = 10e12;
const min_reputation = 0;
const predestined_first_bid_index = 9;

// Profile variables
var chosen_bids = [];
var node_id = [];
var DH_balance = [];
var DH_credit = [];
var DH_price = [];
var DH_stake = [];
var DH_read_factor = [];

// eslint-disable-next-line no-undef
contract('Storage testing', async (accounts) => {
    // eslint-disable-next-line no-undef

    before(async () => {


    });
    // createProfile(bytes32 node_id, uint price, uint stake, uint max_time, uint max_size)
    // 0: uint256: token_amount
    // 1: uint256: stake_amount
    // 2: uint256: read_stake_factor
    // 3: uint256: balance
    // 4: uint256: reputation
    // 5: uint256: max_escrow_time
    // 6: uint256: size_available
    // eslint - disable - next - line no - undef
    // it('Should initiatePurchase', async () => {
    //     // Get instances of contracts used in the test
    //     const bidding = await Bidding.deployed();

    //     var promises = [];
    //     for (var i = 0; i < 10; i += 1) {
    //         // console.log(`\t Creating profile ${node_id[i]}`);
    //         DH_balance[i] = 5e25;
    //         DH_price[i] = Math.round(Math.random() * 1000) * 1e15;
    //         DH_stake[i] = (Math.round(Math.random() * 1000) + 10) * 1e15;
    //         DH_read_factor[i] = (Math.round(Math.random() * 5));
    //         promises[i] = bidding.createProfile(
    //             node_id[i],
    //             DH_price[i],
    //             DH_stake[i],
    //             DH_read_factor[i],
    //             1000,
    //             { from: accounts[i] },
    //         );
    //     }
    //     await Promise.all(promises);

    //     for (i = 0; i < DH_price.length; i += 1) {
    //         // eslint-disable-next-line no-await-in-loop
    //         var response = await bidding.profile.call(accounts[i]);

    //         console.log(`\t account[${i}] price: ${response[0].toNumber() / 1e18} \t stake: ${response[1].toNumber() / 1e18}`);

    //         assert.equal(response[0].toNumber(), DH_price[i], 'Price not matching');
    //         assert.equal(response[1].toNumber(), DH_stake[i], 'Stake not matching');
    //     }
    // });
});
