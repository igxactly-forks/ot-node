/* eslint indent: 0 */
/* eslint-disable max-len, no-undef */
var TracToken = artifacts.require('TracToken');
var OTFingerprintStore = artifacts.require('OTFingerprintStore');

var ContractHub = artifacts.require('ContractHub');

// Variable contracts
var Profile = artifacts.require('Profile');
var Bidding = artifacts.require('Bidding');
var BiddingTest = artifacts.require('BiddingTest');
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

const giveMeHub = async function giveMeHub() {
    const hub = ContractHub.deployed();
    return hub;
};
const giveMeProfileStorage = async function giveMeProfileStorage() {
    const profileStorage = ProfileStorage.deployed();
    return profileStorage;
};
const giveMeBiddingStorage = async function giveMeBiddingStorage() {
    const biddingStorage = BiddingStorage.deployed();
    return biddingStorage;
};
const giveMeEscrowStorage = async function giveMeEscrowStorage() {
    const escrowStorage = EscrowStorage.deployed();
    return escrowStorage;
};
const giveMeLitigationStorage = async function giveMeLitigationStorage() {
    const litigationStorage = LitigationStorage.deployed();
    return litigationStorage;
};
const giveMeReadingStorage = async function giveMeReadingStorage() {
    const readingStorage = ReadingStorage.deployed();
    return readingStorage;
};

const giveMeProfile = async function giveMeProfile() {
    const profile = Profile.deployed();
    return profile;
};
const giveMeBiddingTest = async function giveMeBiddingTest() {
    const bidding = BiddingTest.deployed();
    return bidding;
};
const giveMeEscrowHolder = async function giveMeEscrowHolder() {
    const escrow = EscrowHolder.deployed();
    return escrow;
};
const giveMeLitigation = async function giveMeLitigation() {
    const litigation = Litigation.deployed();
    return litigation;
};
const giveMeReading = async function giveMeReading() {
    const reading = Reading.deployed();
    return reading;
};

const giveMeTracToken = async function giveMeTracToken() {
    const token = TracToken.deployed();
    return token;
};

const giveMeFingerprint = async function giveMeFingerprint() {
    const fingerprint = OTFingerprintStore.deployed();
    return fingerprint;
};

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

module.exports =  async (deployer, network, accounts) => {
    switch (network) {
    case 'ganache':
        await deployer.deploy(ContractHub).then(result => hub = result);
        console.log(hub.address);

        await deployer.deploy(ProfileStorage, hub.address, { gas: 9000000, from: accounts[0] })
        .then(result => profileStorage = result);
        // console.log(profileStorage.address);
        await hub.setProfileStorageAddress(profileStorage.address);

        await deployer.deploy(BiddingStorage, hub.address, { gas: 9000000, from: accounts[0] });
        biddingStorage = await giveMeBiddingStorage();
        // console.log(biddingStorage.address);
        await hub.setBiddingStorageAddress(biddingStorage.address);

        await deployer.deploy(EscrowStorage, hub.address, { gas: 9000000, from: accounts[0] });
        escrowStorage = await giveMeEscrowStorage();
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

        await deployer.deploy(BiddingTest, hub.address, { gas: 10000000, from: accounts[0] })
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
        
        var amounts = [];
        var recepients = [];
        for (let i = 0; i < 10; i += 1) {
            amounts.push(amountToMint);
            recepients.push(accounts[i]);
        }
        await token.mintMany(recepients, amounts, { from: accounts[0] });
        await token.finishMinting({ from: accounts[0] });

        break;
    case 'test':
        deployer.deploy(ContractHub, { gas: 8000000, from: accounts[0] })
        .then(() => giveMeHub())
        .then(async (result) => {
            hub = result;
            await deployer.deploy(StorageContract, hub.address, { gas: 90000000, from: accounts[0] })
        .then(() => giveMeStorage())
        .then(async (result) => {
            storage = result;
            await deployer.deploy(TracToken, accounts[0], accounts[1], accounts[2])
        .then(() => giveMeTracToken())
        .then(async (result) => {
            token = result;
            hub.setToken(token.address);
            await deployer.deploy(
                EscrowHolder,
                hub.address,
                storage.address,
                { gas: 8000000, from: accounts[0] },
            )
        .then(() => giveMeEscrowHolder())
        .then(async (result) => {
            escrow = result;
            hub.setEscrow(escrow.address);
            await deployer.deploy(Reading, storage.address, { gas: 8000000, from: accounts[0] })
        .then(() => giveMeReading())
        .then(async (result) => {
            reading = result;
            hub.setReading(reading.address);
            await deployer.deploy(BiddingTest, hub.address, storage.address)
        .then(() => giveMeBiddingTest())
        .then(async (result) => {
            bidding = result;
            hub.setBidding(bidding.address);
            await deployer.deploy(StorageContracts, hub.address)
        .then(async () => {
            await deployer.deploy(TestingUtilities);
            var amounts = [];
            var recepients = [];
            for (let i = 0; i < 10; i += 1) {
                amounts.push(amountToMint);
                recepients.push(accounts[i]);
            }
            await token.mintMany(recepients, amounts, { from: accounts[0] })
        .then(async () => {
            await token.finishMinting({ from: accounts[0] })
        .then(async () => {
            console.log('\n\n \t Contract adressess on ganache (for testing):');
            console.log(`\t Hub contract address: \t ${hub.address}`);
            console.log(`\t Token contract address: \t ${token.address}`);
            console.log(`\t Escrow contract address: \t ${escrow.address}`);
            console.log(`\t Bidding contract address: \t ${bidding.address}`);
            console.log(`\t Reading contract address: \t ${reading.address}`);
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
        Hub.at('0xaf810f20e36de6dd64eb8fa2e8fac51d085c1de3')
        .then(async (result) => {
            const tokenAddress = await hub.tokenAddress.call();
            const fingerprintAddress = await hub.fingerprintAddress.call();
            token = await TracToken.at(tokenAddress);
            fingerprint = await OTFingerprintStore.at(fingerprintAddress);
            deployer.deploy(EscrowHolder, token.address, { gas: 6000000 })
        .then(() => giveMeEscrowHolder())
        .then(async (result) => {
            escrow = result;
            await deployer.deploy(Reading, escrow.address, { gas: 6000000 })
        .then(() => giveMeReading())
        .then(async (result) => {
            reading = result;
            await deployer.deploy(
                BiddingTest,
                tokenAddress,
                escrow.address,
                reading.address,
                { gas: 6000000 },
            )
        .then(() => giveMeBiddingTest())
        .then(async (result) => {
            bidding = result;
            console.log('Setting bidding address in escrow...');
            await escrow.setBidding(bidding.address)
        .then(async () => {
            console.log('Setting reading address in escrow...');
            await escrow.setReading(reading.address)
        .then(async () => {
            console.log('Setting bidding address in reading...');
            await reading.setBidding(bidding.address)
        .then(async () => {
            console.log('Transfering reading ownership to escrow...');
            await reading.transferOwnership(escrow.address)
        .then(async () => {
            console.log('Transfering escrow ownership to bidding...');
            await escrow.transferOwnership(bidding.address)
        .then(async () => {
            await deployer.deploy(
                Hub,
                fingerprintAddress,
                tokenAddress,
                bidding.address,
                escrow.address,
                reading.address,
            )
        .then(() => giveMeHub())
        .then(async (result) => {
            hub = result;
            console.log('\n\n \t Contract adressess on ganache:');
            console.log(`\t Hub contract address: \t ${hub.result} (unchanged)`);
            console.log(`\t OT-fingerprint contract address: \t ${fingerprintAddress} (unchanged)`);
            console.log(`\t Token contract address: \t ${tokenAddress} (unchanged)`);
            console.log(`\t Escrow contract address: \t ${escrow.address}`);
            console.log(`\t Bidding contract address: \t ${bidding.address}`);
            console.log(`\t Reading contract address: \t ${reading.address}`);
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
    default:
        console.warn('Please use one of the following network identifiers: ganache, test, or rinkeby');
        break;
    }
};

