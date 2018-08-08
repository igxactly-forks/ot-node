/* eslint indent: 0 */
/* eslint-disable max-len, no-undef */
var TracToken = artifacts.require('TracToken');
var OTFingerprintStore = artifacts.require('OTFingerprintStore');

var ContractHub = artifacts.require('ContractHub');

// Variable contracts
var Profile = artifacts.require('Profile');
var Bidding = artifacts.require('Bidding');
var Litigation = artifacts.require('Litigation');
var EscrowHolder = artifacts.require('EscrowHolder');
var Reading = artifacts.require('Reading');

// Storage contracts
var ProfileStorage = artifacts.require('ProfileStorage');
var BiddingStorage = artifacts.require('BiddingStorage');
var EscrowStorage = artifacts.require('EscrowStorage');
var LitigationStorage = artifacts.require('LitigationStorage');
var ReadingStorage = artifacts.require('ReadingStorage');
var TestingUtilities = artifacts.require('TestingUtilities');

let hub;

let profile;
let bidding;
let escrow;
let litigation;
let reading;

let token;
let fingerprint;

let profileStorage;
let biddingStorage;
let escrowStorage;
let litigationStorage;
let readingStorage;

let DC_wallet;
let DH_wallet;

const amountToMint = 5e25;
const amounts = [];
const recepients = [];

module.exports = async (deployer, network, accounts) => {
    switch (network) {
    case 'ganache':
        await deployer.deploy(ContractHub).then(result => hub = result);
        console.log(hub.address);

        await deployer.deploy(ProfileStorage, hub.address, { gas: 9000000, from: accounts[0] })
        .then(result => profileStorage = result);
        // console.log(profileStorage.address);
        await hub.setProfileStorageAddress(profileStorage.address);

        await deployer.deploy(BiddingStorage, hub.address, { gas: 9000000, from: accounts[0] })
        .then(result => biddingStorage = result);
        // console.log(biddingStorage.address);
        await hub.setBiddingStorageAddress(biddingStorage.address);

        await deployer.deploy(EscrowStorage, hub.address, { gas: 9000000, from: accounts[0] })
        .then(result => escrowStorage = result);
        // console.log(escrowStorage.address)
        await hub.setEscrowStorageAddress(escrowStorage.address);

        await deployer.deploy(LitigationStorage, hub.address, { gas: 9000000, from: accounts[0] })
        .then(result => litigationStorage = result);
        // console.log(litigationStorage.address);
        await hub.setLitigationStorageAddress(litigationStorage.address);

        await deployer.deploy(ReadingStorage, hub.address, { gas: 9000000, from: accounts[0] })
        .then(result => readingStorage = result);
        // console.log(readingStorage.address);
        await hub.setReadingStorageAddress(readingStorage.address, { from: accounts[0] });


        await deployer.deploy(TracToken, accounts[0], accounts[1], accounts[2])
        .then(result => token = result);
        await hub.setTokenAddress(token.address);

        await deployer.deploy(OTFingerprintStore)
        .then(result => fingerprint = result);
        await hub.setFingerprintAddress(fingerprint.address);

        await deployer.deploy(Profile, hub.address, { gas: 9000000, from: accounts[0] })
        .then(result => profile = result);
        await hub.setProfileAddress(profile.address);

        await deployer.deploy(BiddingTest, hub.address, { gas: 9000000, from: accounts[0] })
        .then(result => bidding = result);
        await hub.setBiddingAddress(bidding.address);

        await deployer.deploy(EscrowHolder, hub.address, { gas: 9000000, from: accounts[0] })
        .then(result => escrow = result);
        await hub.setEscrowAddress(escrow.address);

        await deployer.deploy(Litigation, hub.address, { gas: 9000000, from: accounts[0] })
        .then(result => litigation = result);
        await hub.setLitigationAddress(litigation.address);

        await deployer.deploy(Reading, hub.address, { gas: 9000000, from: accounts[0] })
        .then(result => reading = result);
        await hub.setReadingAddress(reading.address);

        await bidding.initiate();
        await escrow.initiate();
        await litigation.initiate();

        for (let i = 0; i < 10; i += 1) {
            amounts.push(amountToMint);
            recepients.push(accounts[i]);
        }
        await token.mintMany(recepients, amounts, { from: accounts[0] });
        await token.finishMinting({ from: accounts[0] });

        break;
    case 'test':
            deployer.deploy(TestingUtilities);
            deployer.deploy(ContractHub).then((result) => {
            hub = result;
            deployer.deploy(ProfileStorage, hub.address, { gas: 9000000, from: accounts[0] })
        .then((result) => {
            profileStorage = result;
            // console.log(profileStorage.address);
            hub.setProfileStorageAddress(profileStorage.address)
        .then(() => {
            deployer.deploy(BiddingStorage, hub.address, { gas: 9000000, from: accounts[0] })
        .then((result) => {
            biddingStorage = result;
            // console.log(biddingStorage.address);
            hub.setBiddingStorageAddress(biddingStorage.address)
        .then(() => {
            deployer.deploy(EscrowStorage, hub.address, { gas: 9000000, from: accounts[0] })
        .then((result) => {
            escrowStorage = result;
            // console.log(escrowStorage.address)
            hub.setEscrowStorageAddress(escrowStorage.address)
        .then(() => {
            deployer.deploy(LitigationStorage, hub.address, { gas: 9000000, from: accounts[0] })
        .then((result) => {
            litigationStorage = result;
            // console.log(litigationStorage.address);
            hub.setLitigationStorageAddress(litigationStorage.address)
        .then(() => {
            deployer.deploy(ReadingStorage, hub.address, { gas: 9000000, from: accounts[0] })
        .then((result) => {
            readingStorage = result;
            // console.log(readingStorage.address);
            hub.setReadingStorageAddress(readingStorage.address, { from: accounts[0] })
        .then(() => {
            deployer.deploy(TracToken, accounts[0], accounts[1], accounts[2])
        .then((result) => {
            token = result;
            hub.setTokenAddress(token.address)
        .then(() => {
            deployer.deploy(OTFingerprintStore)
        .then((result) => {
            fingerprint = result;
            hub.setFingerprintAddress(fingerprint.address)
        .then(() => {
            deployer.deploy(Profile, hub.address, { gas: 9000000, from: accounts[0] })
        .then((result) => {
            profile = result;
            hub.setProfileAddress(profile.address)
        .then(() => {
            deployer.deploy(Bidding, hub.address, { gas: 10000000, from: accounts[0] })
        .then((result) => {
            bidding = result;
            hub.setBiddingAddress(bidding.address)
        .then(() => {
            deployer.deploy(EscrowHolder, hub.address, { gas: 9000000, from: accounts[0] })
        .then((result) => {
            escrow = result;
            hub.setEscrowAddress(escrow.address)
        .then(() => {
            deployer.deploy(Litigation, hub.address, { gas: 9000000, from: accounts[0] })
        .then((result) => {
            litigation = result;
            hub.setLitigationAddress(litigation.address)
        .then(() => {
            deployer.deploy(Reading, hub.address, { gas: 9000000, from: accounts[0] })
        .then((result) => {
            reading = result;
            hub.setReadingAddress(reading.address)
        .then(() => {
            bidding.initiate()
        .then(() => {
            escrow.initiate()
        .then(() => {
            litigation.initiate()
        .then(() => {
            for (let i = 0; i < 10; i += 1) {
                amounts.push(amountToMint);
                recepients.push(accounts[i]);
            }
            token.mintMany(recepients, amounts, { from: accounts[0] })
        .then(() => {
            token.finishMinting({ from: accounts[0] })
        .then(() => console.log("Finished migrations"))
        });
        });
        });
        });
        });
        });
        });
        });
        });
        });
        });
        });
        });
        });
        });
        });
        });
        });
        });
        });
        });
        });
        });
        });
        });
        });
        });
        });
        });
        break;
    case 'rinkeby':
        await Hub.at('0xaf810f20e36de6dd64eb8fa2e8fac51d085c1de3');

        await deployer.deploy(Profile, hub.address, { gas: 9000000, from: accounts[0] })
        .then(result => profile = result);
        await hub.setProfileAddress(profile.address);

        await deployer.deploy(Bidding, hub.address, { gas: 9000000, from: accounts[0] })
        .then(result => bidding = result);
        await hub.setBiddingAddress(bidding.address);

        await deployer.deploy(EscrowHolder, hub.address, { gas: 9000000, from: accounts[0] })
        .then(result => escrow = result);
        await hub.setEscrowAddress(escrow.address);

        await deployer.deploy(Litigation, hub.address, { gas: 9000000, from: accounts[0] })
        .then(result => litigation = result);
        await hub.setLitigationAddress(litigation.address);

        await deployer.deploy(Reading, hub.address, { gas: 9000000, from: accounts[0] })
        .then(result => reading = result);
        await hub.setReadingAddress(reading.address);

        await bidding.initiate();
        await escrow.initiate();
        await litigation.initiate();

        break;
    default:
        console.warn('Please use one of the following network identifiers: ganache, test, or rinkeby');
        break;
    }
};
