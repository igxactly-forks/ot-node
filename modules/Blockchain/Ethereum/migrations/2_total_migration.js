/* eslint indent: 0 */
var ContractHub = artifacts.require('ContractHub'); // eslint-disable-line no-undef

var TracToken = artifacts.require('TracToken'); // eslint-disable-line no-undef
var OTFingerprintStore = artifacts.require('OTFingerprintStore'); // eslint-disable-line no-undef
var StorageContract = artifacts.require('StorageContract'); // eslint-disable-line no-undef
var EscrowHolder = artifacts.require('EscrowHolder'); // eslint-disable-line no-undef
var BiddingTest = artifacts.require('BiddingTest'); // eslint-disable-line no-undef
var Bidding = artifacts.require('Bidding'); // eslint-disable-line no-undef
var Reading = artifacts.require('Reading'); // eslint-disable-line no-undef

var TestingUtilities = artifacts.require('TestingUtilities'); // eslint-disable-line no-undef

const giveMeHub = async function giveMeHub() {
    const hub = ContractHub.deployed();
    return hub;
};

const giveMeTracToken = async function giveMeTracToken() {
    const token = TracToken.deployed();
    return token;
};
const giveMeFingerprint = function giveMeFingerprint() {
    const fingerprint = OTFingerprintStore.deployed();
    return fingerprint;
};

const giveMeEscrowHolder = async function giveMeEscrowHolder() {
    const escrow = EscrowHolder.deployed();
    return escrow;
};
const giveMeBidding = async function giveMeBidding() {
    const bidding = Bidding.deployed();
    return bidding;
};
const giveMeBiddingTest = async function giveMeBiddingTest() {
    const bidding = BiddingTest.deployed();
    return bidding;
};
const giveMeReading = async function givemere() {
    const reading = Reading.deployed();
    return reading;
};

var hub;

var token;
var escrow;
var bidding;
var fingerprint;
var reading;

var DC_wallet;
var DH_wallet;

const amountToMint = 5e25;

module.exports = (deployer, network, accounts) => {
    switch (network) {
    case 'ganache':
        DC_wallet = accounts[0]; // eslint-disable-line prefer-destructuring
        DH_wallet = accounts[1]; // eslint-disable-line prefer-destructuring
        deployer.deploy(TracToken, accounts[0], accounts[1], accounts[2])
        .then(() => giveMeTracToken())
        .then(async (result) => {
            token = result;
            await deployer.deploy(EscrowHolder, token.address, { gas: 8000000, from: accounts[0] })
        .then(() => giveMeEscrowHolder())
        .then(async (result) => {
            escrow = result;
            await deployer.deploy(Reading, escrow.address, { gas: 8000000, from: accounts[0] })
        .then(() => giveMeReading())
        .then(async (result) => {
            reading = result;
            await deployer.deploy(BiddingTest, token.address, escrow.address, reading.address)
        .then(() => giveMeBiddingTest())
        .then(async (result) => {
            bidding = result;
            await deployer.deploy(OTFingerprintStore)
        .then(() => giveMeFingerprint())
        .then(async (result) => {
            fingerprint = result;
            await escrow.setBidding(bidding.address, { from: accounts[0] })
        .then(async () => {
            await escrow.setReading(reading.address, { from: accounts[0] })
        .then(async () => {
            await reading.setBidding(bidding.address, { from: accounts[0] })
        .then(async () => {
            await reading.transferOwnership(escrow.address, { from: accounts[0] })
        .then(async () => {
            await escrow.transferOwnership(bidding.address, { from: accounts[0] })
        .then(async () => {
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
            await deployer.deploy(
                Hub,
                fingerprint.address,
                token.address,
                bidding.address,
                escrow.address,
                reading.address,
            )
        .then(() => giveMeHub())
        .then(async (result) => {
            hub = result;
            console.log('\n\n \t Contract adressess on ganache:');
            console.log(`\t Hub contract address: \t ${hub.address}`); // eslint-disable-line
            console.log(`\t OT-fingerprint contract address: \t ${fingerprint.address}`); // eslint-disable-line
            console.log(`\t Token contract address: \t ${token.address}`); // eslint-disable-line
            console.log(`\t Escrow contract address: \t ${escrow.address}`); // eslint-disable-line
            console.log(`\t Bidding contract address: \t ${bidding.address}`); // eslint-disable-line
            console.log(`\t Reading contract address: \t ${reading.address}`); // eslint-disable-line
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
            await deployer.deploy(TestingUtilities)
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
    // eslint-disable-next-line
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

