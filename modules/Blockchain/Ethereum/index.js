const fs = require('fs');
const Transactions = require('./Transactions');
const Utilities = require('../../Utilities');
const Models = require('../../../models');
const Op = require('sequelize/lib/operators');
const BN = require('bn.js');

class Ethereum {
    /**
     * Initializing Ethereum blockchain connector
     * @param blockchainConfig
     * @param emitter
     * @param web3
     * @param log
     */
    constructor(blockchainConfig, emitter, web3, log) {
        // Loading Web3
        this.emitter = emitter;
        this.web3 = web3;
        this.log = log;

        this.transactions = new Transactions(
            this.web3,
            blockchainConfig.wallet_address,
            blockchainConfig.wallet_private_key,
        );

        this.hubContractAddress = blockchainConfig.hub_contract_address;

        // Hub contract data
        const hubContractAbiFile = fs.readFileSync('./modules/Blockchain/Ethereum/abi/hub.json');
        this.hubContractAbi = JSON.parse(hubContractAbiFile);
        this.hubContract = new this.web3.eth.Contract(
            this.hubContractAbi,
            this.hubContractAddress,
        );

        this.hubContract.events.ContractsChanged()
            .on('data', (event) => {
                // console.log(event); // same results as the optional callback above
                emitter.emit('eth-contracts-changed', event);
            })
            .on('error', this.log.warn);

        // OT contract data
        const otAbiFile = fs.readFileSync('./modules/Blockchain/Ethereum/abi/ot.json');
        this.otContractAbi = JSON.parse(otAbiFile);

        // Token contract data
        const tokenAbiFile = fs.readFileSync('./modules/Blockchain/Ethereum/abi/token.json');
        this.tokenContractAbi = JSON.parse(tokenAbiFile);

        // Profile contract data
        const profileAbiFile = fs.readFileSync('./modules/Blockchain/Ethereum/abi/profile.json');
        this.profileContractAbi = JSON.parse(profileAbiFile);

        // Bidding contract data
        const biddingAbiFile = fs.readFileSync('./modules/Blockchain/Ethereum/abi/bidding.json');
        this.biddingContractAbi = JSON.parse(biddingAbiFile);

        // Escrow contract data
        const escrowAbiFile = fs.readFileSync('./modules/Blockchain/Ethereum/abi/escrow.json');
        this.escrowContractAbi = JSON.parse(escrowAbiFile);

        // Litigation contract data
        const litigationAbiFile = fs.readFileSync('./modules/Blockchain/Ethereum/abi/litigation.json');
        this.litigationContractAbi = JSON.parse(litigationAbiFile);

        // Reading contract data
        const readingAbiFile = fs.readFileSync('./modules/Blockchain/Ethereum/abi/reading.json');
        this.readingContractAbi = JSON.parse(readingAbiFile);

        // Profile storage contract data
        const profileStorageAbiFile = fs.readFileSync('./modules/Blockchain/Ethereum/abi/profile-storage.json');
        this.profileStorageContractAbi = JSON.parse(profileStorageAbiFile);

        // Bidding storage contract data
        const biddingStorageAbiFile = fs.readFileSync('./modules/Blockchain/Ethereum/abi/bidding-storage.json');
        this.biddingStorageContractAbi = JSON.parse(biddingStorageAbiFile);

        // Escrow storage contract data
        const escrowStorageAbiFile = fs.readFileSync('./modules/Blockchain/Ethereum/abi/escrow-storage.json');
        this.escrowStorageContractAbi = JSON.parse(escrowStorageAbiFile);

        // Litigation storage contract data
        const litigationStorageAbiFile = fs.readFileSync('./modules/Blockchain/Ethereum/abi/litigation-storage.json');
        this.litigationStorageContractAbi = JSON.parse(litigationStorageAbiFile);

        // Reading storage contract data
        const readingStorageAbiFile = fs.readFileSync('./modules/Blockchain/Ethereum/abi/reading-storage.json');
        this.readingStorageContractAbi = JSON.parse(readingStorageAbiFile);

        // Storing config data
        this.config = blockchainConfig;

        this.log.info('Selected blockchain: Ethereum');
    }

    /**
     * Initializing Ethereum blockchain contracts
     */
    async initialize(emitter) {
        const blockchainModel = await Models.blockchain_data.findOne({
            where: {
                id: 1,
            },
        });
        blockchainModel.ot_contract_address = await this.getFingerprintAddress();
        blockchainModel.token_contract_address = await this.getTokenAddress();
        blockchainModel.profile_contract_address = await this.getProfileAddress();
        blockchainModel.bidding_contract_address = await this.getBiddingAddress();
        blockchainModel.escrow_contract_address = await this.getEscrowAddress();
        blockchainModel.litigation_contract_address = await this.getLitigationAddress();
        blockchainModel.reading_contract_address = await this.getReadingAddress();

        blockchainModel.profile_storage_contract_address = await this.getProfileStorageAddress();
        blockchainModel.bidding_storage_contract_address = await this.getBiddingStorageAddress();
        blockchainModel.escrow_storage_contract_address = await this.getEscrowStorageAddress();
        blockchainModel.litigation_storage_contract_address = await this.getLitigationStorageAddress();
        blockchainModel.reading_storage_contract_address = await this.getReadingStorageAddress();
        await blockchainModel.save({
            fields: [
                'ot_contract_address',
                'token_contract_address',
                'profile_contract_address',
                'bidding_contract_address',
                'escrow_contract_address',
                'litigation_contract_address',
                'reading_contract_address',
                'profile_contract_address',
                'bidding_contract_address',
                'escrow_contract_address',
                'litigation_contract_address',
                'reading_contract_address',
            ],
        });


        try {
            this.log.trace('Getting contracts from contract hub');
            this.otContractAddress = await this.hubContract.methods.fingerprintAddress().call();
            this.otContract = new this.web3.eth.Contract(
                this.otContractAbi,
                this.otContractAddress,
            );

            this.tokenContractAddress = await this.hubContract.methods.tokenAddress().call();
            this.tokenContract = new this.web3.eth.Contract(
                this.tokenContractAbi,
                this.tokenContractAddress,
            );

            this.profileContractAddress = await this.hubContract.methods.profileAddress().call();
            this.profileContract = new this.web3.eth.Contract(
                this.profileContractAbi,
                this.profileContractAddress,
            );

            this.biddingContractAddress = await this.hubContract.methods.biddingAddress().call();
            this.biddingContract = new this.web3.eth.Contract(
                this.biddingContractAbi,
                this.biddingContractAddress,
            );

            this.escrowContractAddress = await this.hubContract.methods.escrowAddress().call();
            this.escrowContract = new this.web3.eth.Contract(
                this.escrowContractAbi,
                this.escrowContractAddress,
            );

            this.litigationContractAddress = await this.hubContract.methods.litigationAddress().call();
            this.litigationContract = new this.web3.eth.Contract(
                this.litigationContractAbi,
                this.litigationContractAddress,
            );

            this.readingContractAddress = await this.hubContract.methods.readingAddress().call();
            this.readingContract = new this.web3.eth.Contract(
                this.readingContractAbi,
                this.readingContractAddress,
            );


            this.profileStorageContractAddress = await this.hubContract.methods.profileStorageAddress().call();
            this.profileStorageContract = new this.web3.eth.Contract(
                this.profileStorageContractAbi,
                this.profileStorageContractAddress,
            );

            this.biddingStorageContractAddress = await this.hubContract.methods.biddingStorageAddress().call();
            this.biddingStorageContract = new this.web3.eth.Contract(
                this.biddingStorageContractAbi,
                this.biddingStorageContractAddress,
            );

            this.escrowStorageContractAddress = await this.hubContract.methods.escrowStorageAddress().call();
            this.escrowStorageContract = new this.web3.eth.Contract(
                this.escrowStorageContractAbi,
                this.escrowStorageContractAddress,
            );

            this.litigationStorageContractAddress = await this.hubContract.methods.litigationStorageAddress().call();
            this.litigationStorageContract = new this.web3.eth.Contract(
                this.litigationStorageContractAbi,
                this.litigationStorageContractAddress,
            );

            this.readingStorageContractAddress = await this.hubContract.methods.readingStorageAddress().call();
            this.readingStorageContract = new this.web3.eth.Contract(
                this.readingStorageContractAbi,
                this.readingStorageContractAddress,
            );

            this.log.info('Contracts initiated');
        } catch (error) {
            this.log.error(error);
            process.exit(1);
        }


        this.contractsByName = {
            HUB_CONTRACT: this.hubContract,

            PROFILE_CONTRACT: this.profileContract,
            BIDDING_CONTRACT: this.biddingContract,
            LITIGATION_CONTRACT: this.litigationContract,
            ESCROW_CONTRACT: this.escrowContract,
            READING_CONTRACT: this.readingContract,

            PROFILE_STORAGE_CONTRACT: this.profileStorageContract,
            BIDDING_STORAGE_CONTRACT: this.biddingStorageContract,
            LITIGATION_STORAGE_CONTRACT: this.litigationStorageContract,
            ESCROW_STORAGE_CONTRACT: this.escrowStorageContract,
            READING_STORAGE_CONTRACT: this.readingStorageContract,
        };

        this.biddingContract.events.OfferCreated()
            .on('data', (event) => {
                // emitter.emit('eth-offer-created', event);
            })
            .on('error', this.log.warn);

        this.biddingContract.events.OfferCanceled()
            .on('data', (event) => {
                // emitter.emit('eth-offer-canceled', event);
            })
            .on('error', this.log.warn);

        this.biddingContract.events.BidTaken()
            .on('data', (event) => {
                // emitter.emit('eth-bid-taken', event);
            })
            .on('error', this.log.warn);

        this.contracsChangedHandle = this.subscribeToEventPermanent(['ContractsChanged']);
    }

    /**
     * Initializing Ethereum blockchain contracts
     */
    async deinitialize(emitter) {
        this.unsubscribeToEventPermanent(this.contracsChangedHandle);
    }

    /**
     * Writes data import root hash on Ethereum blockchain
     * @param importId
     * @param rootHash
     * @returns {Promise}
     */
    writeRootHash(importId, rootHash) {
        const options = {
            gasLimit: this.web3.utils.toHex(this.config.gas_limit),
            gasPrice: this.web3.utils.toHex(this.config.gas_price),
            to: this.otContractAddress,
        };

        const importIdHash = Utilities.sha3(importId);

        this.log.notify(`Writing root hash to blockchain for import ${importId}`);
        return this.transactions.queueTransaction(this.otContractAbi, 'addFingerPrint', [importId, importIdHash, rootHash], options);
    }

    /**
     * Gets root hash for import
     * @param dcWallet DC wallet
     * @param dataId   Import ID
     * @return {Promise<any>}
     */
    async getRootHash(dcWallet, importId) {
        const importIdHash = Utilities.sha3(importId.toString());
        this.log.trace(`Fetching root hash for dcWallet ${dcWallet} and importIdHash ${importIdHash}`);
        return this.otContract.methods.getFingerprintByBatchHash(dcWallet, importIdHash).call();
    }

    /**
     * Gets profile by wallet
     * @param wallet
     */
    getProfile(wallet) {
        return new Promise((resolve, reject) => {
            this.log.trace(`Get profile by wallet ${wallet}`);
            this.profileStorageContract.methods.profile(wallet).call({
                from: wallet,
            }).then((res) => {
                resolve(res);
            }).catch((e) => {
                reject(e);
            });
        });
    }

    async getFingerprintAddress() {
        return this.hubContract.methods.fingerprintAddress().call();
    }

    async getTokenAddress() {
        return this.hubContract.methods.tokenAddress().call();
    }

    async getProfileAddress() {
        return this.hubContract.methods.profileAddress().call();
    }

    async getBiddingAddress() {
        return this.hubContract.methods.biddingAddress().call();
    }

    async getEscrowAddress() {
        return this.hubContract.methods.escrowAddress().call();
    }

    async getLitigationAddress() {
        return this.hubContract.methods.litigationAddress().call();
    }

    async getReadingAddress() {
        return this.hubContract.methods.readingAddress().call();
    }

    async getProfileStorageAddress() {
        return this.hubContract.methods.profileStorageAddress().call();
    }

    async getBiddingStorageAddress() {
        return this.hubContract.methods.biddingStorageAddress().call();
    }

    async getEscrowStorageAddress() {
        return this.hubContract.methods.escrowStorageAddress().call();
    }

    async getLitigationStorageAddress() {
        return this.hubContract.methods.litigationStorageAddress().call();
    }

    async getReadingStorageAddress() {
        return this.hubContract.methods.readingStorageAddress().call();
    }


    /**
     * Gets TRAC token wallet
     * @param wallet
     */
    async getAlphaTracTokenBalance() {
        const wallet_address_minus0x = (this.config.wallet_address).substring(2);
        // '0x70a08231' is the contract 'balanceOf()' ERC20 token function in hex.
        // var contractData = (`0x70a08231000000000000000000000000${wallet_address_minus0x}`);
        const result = await this.tokenContract.methods.balanceOf(this.config.wallet_address).call({
            from: this.config.wallet_address,
        });

        const tokensInWei = this.web3.utils.toBN(result).toString();
        const tokensInEther = this.web3.utils.fromWei(tokensInWei, 'ether');
        return (tokensInEther);
    }

    /**
     * Gets profile balance by wallet
     * @param wallet
     * @returns {Promise}
     */
    getProfileBalance(wallet) {
        return new Promise((resolve, reject) => {
            this.log.trace(`Getting profile balance by wallet ${wallet}`);
            this.profileStorageContract.methods.getProfile_balance(wallet).call()
                .then((res) => {
                    resolve(res);
                }).catch((e) => {
                    reject(e);
                });
        });
    }

    /**
     * Get offer by importId
     * @param importId
     * @returns {Promise}
     */
    getOffer(importId) {
        return new Promise((resolve, reject) => {
            this.log.trace(`Get offer by importId ${importId}`);
            this.biddingStorageContract.methods.offer(importId).call().then((res) => {
                resolve(res);
            }).catch((e) => {
                reject(e);
            });
        });
    }

    /**
     * Creates node profile on the Bidding contract
     * @param nodeId        Kademlia node ID
     * @param pricePerByteMinute Price for byte per minute
     * @param stakePerByteMinute Stake for byte per minute
     * @param readStakeFactor Read stake factor
     * @param maxTimeMins   Max time in minutes
     * @return {Promise<any>}
     */
    createProfile(
        nodeId, pricePerByteMinute, stakePerByteMinute,
        readStakeFactor, maxTimeMins,
    ) {
        const options = {
            gasLimit: this.web3.utils.toHex(this.config.gas_limit),
            gasPrice: this.web3.utils.toHex(this.config.gas_price),
            to: this.profileContractAddress,
        };

        this.log.trace(`CreateProfile(${nodeId}, ${pricePerByteMinute} ${stakePerByteMinute}, ${readStakeFactor} ${maxTimeMins})`);
        return this.transactions.queueTransaction(
            this.profileContractAbi, 'createProfile',
            [Utilities.normalizeHex(nodeId), pricePerByteMinute, stakePerByteMinute,
                readStakeFactor, maxTimeMins], options,
        );
    }

    /**
     * Increase token approval for escrow contract on Ethereum blockchain
     * @param {number} tokenAmountIncrease
     * @returns {Promise}
     */
    increaseApproval(tokenAmountIncrease) {
        const options = {
            gasLimit: this.web3.utils.toHex(this.config.gas_limit),
            gasPrice: this.web3.utils.toHex(this.config.gas_price),
            to: this.tokenContractAddress,
        };
        this.log.notify('Increasing approval for escrow');
        return this.transactions.queueTransaction(this.tokenContractAbi, 'increaseApproval', [this.escrowContractAddress, tokenAmountIncrease], options);
    }

    /**
     * Increase token approval for Bidding contract on Ethereum blockchain
     * @param {number} tokenAmountIncrease
     * @returns {Promise}
     */
    increaseBiddingApproval(tokenAmountIncrease) {
        const options = {
            gasLimit: this.web3.utils.toHex(this.config.gas_limit),
            gasPrice: this.web3.utils.toHex(this.config.gas_price),
            to: this.tokenContractAddress,
        };
        this.log.notify('Increasing bidding approval');
        return this.transactions.queueTransaction(this.tokenContractAbi, 'increaseApproval', [this.profileContractAddress, tokenAmountIncrease], options);
    }

    /**
     * Verify escrow contract contract data and start data holding process on Ethereum blockchain
     * @param importId
     * @param dhWallet
     * @returns {Promise}
     */
    verifyEscrow(importId, dhWallet) {
        const options = {
            gasLimit: this.web3.utils.toHex(this.config.gas_limit),
            gasPrice: this.web3.utils.toHex(this.config.gas_price),
            to: this.escrowContractAddress,
        };

        this.log.notify(`Verify escrow for import ${importId} and DH ${dhWallet}`);
        return this.transactions.queueTransaction(
            this.escrowContractAbi,
            'verifyEscrow',
            [
                importId,
                dhWallet,
            ],
            options,
        );
    }

    /**
     * DC initiates litigation on DH wrong challenge answer
     * @param importId
     * @param dhWallet
     * @param blockId
     * @param merkleProof
     * @return {Promise<any>}
     */
    initiateLitigation(importId, dhWallet, blockId, merkleProof) {
        const options = {
            gasLimit: this.web3.utils.toHex(this.config.gas_limit),
            gasPrice: this.web3.utils.toHex(this.config.gas_price),
            to: this.litigationContractAddress,
        };
        this.log.important(`Initiates litigation for import ${importId} and DH ${dhWallet}`);
        return this.transactions.queueTransaction(
            this.litigationContractAbi,
            'initiateLitigation',
            [
                importId,
                dhWallet,
                blockId,
                merkleProof,
            ],
            options,
        );
    }
    /**
     * Answers litigation from DH side
     * @param importId
     * @param requestedData
     * @return {Promise<any>}
     */
    answerLitigation(importId, requestedData) {
        const options = {
            gasLimit: this.web3.utils.toHex(this.config.gas_limit),
            gasPrice: this.web3.utils.toHex(this.config.gas_price),
            to: this.litigationContractAddress,
        };
        this.log.important(`Answer litigation for import ${importId}`);
        return this.transactions.queueTransaction(
            this.litigationContractAbi,
            'answerLitigation',
            [
                importId,
                requestedData,
            ],
            options,
        );
    }

    /**
     * Prooves litigation for particular DH
     * @param importId
     * @param dhWallet
     * @param proofData
     * @return {Promise<any>}
     */
    proveLitigation(importId, dhWallet, proofData) {
        const options = {
            gasLimit: this.web3.utils.toHex(this.config.gas_limit),
            gasPrice: this.web3.utils.toHex(this.config.gas_price),
            to: this.litigationContractAddress,
        };
        this.log.important(`Prove litigation for import ${importId} and DH ${dhWallet}`);
        return this.transactions.queueTransaction(
            this.litigationContractAbi,
            'proveLitigaiton',
            [
                importId,
                dhWallet,
                proofData,
            ],
            options,
        );
    }
    /**
     * Cancel data holding escrow process on Ethereum blockchain
     * @param {string} - dhWallet
     * @param {number} - importId
     * @returns {Promise}
     */
    cancelEscrow(dhWallet, importId, dhIsSender) {
        const options = {
            gasLimit: this.web3.utils.toHex(this.config.gas_limit),
            gasPrice: this.web3.utils.toHex(this.config.gas_price),
            to: this.escrowContractAddress,
        };

        this.log.notify('Initiating escrow');
        return this.transactions.queueTransaction(
            this.escrowContractAbi,
            'cancelEscrow',
            [
                importId,
                dhWallet,
                dhIsSender,
            ],
            options,
        );
    }

    /**
     * Pay out tokens from escrow on Ethereum blockchain
     * @param {string} - dcWallet
     * @param {number} - importId
     * @returns {Promise}
     */
    payOut(importId) {
        const options = {
            gasLimit: this.web3.utils.toHex(this.config.gas_limit),
            gasPrice: this.web3.utils.toHex(this.config.gas_price),
            to: this.escrowContractAddress,
        };

        this.log.notify('Initiating escrow - payOut');
        return this.transactions.queueTransaction(this.escrowContractAbi, 'payOut', [importId], options);
    }

    /**
     * Creates offer for the data storing on the Ethereum blockchain.
     * @param importId Import ID of the offer.
     * @param nodeId KADemlia node ID of offer creator
     * @param totalEscrowTime Total time of the escrow in milliseconds
     * @param maxTokenAmount Maximum price per DH
     * @param MinStakeAmount Minimum stake in tokens
     * @param minReputation Minimum required reputation
     * @param dataHash Hash of the data put to the offer
     * @param dataSize Size of the data for storing in bytes
     * @param predeterminedDhWallets Array of predetermined DH wallets to be used in offer
     * @param predeterminedDhNodeIds Array of predetermined node IDs to be used in offer
     * @returns {Promise<any>} Return choose start-time.
     */
    createOffer(
        importId, nodeId,
        totalEscrowTime,
        maxTokenAmount,
        MinStakeAmount,
        minReputation,
        dataHash,
        dataSize,
        litigationInterval,
        predeterminedDhWallets,
        predeterminedDhNodeIds,
    ) {
        const options = {
            gasLimit: this.web3.utils.toHex(this.config.gas_limit),
            gasPrice: this.web3.utils.toHex(this.config.gas_price),
            to: this.biddingContractAddress,
        };
        this.log.trace(`createOffer (${importId}, ${nodeId}, ${totalEscrowTime}, ${maxTokenAmount}, ${MinStakeAmount}, ${minReputation}, ${dataHash}, ${dataSize}, ${litigationInterval}, ${JSON.stringify(predeterminedDhWallets)}, ${JSON.stringify(predeterminedDhNodeIds)})`);

        return this.transactions.queueTransaction(
            this.biddingContractAbi, 'createOffer',
            [
                importId,
                Utilities.normalizeHex(nodeId),
                Math.round(totalEscrowTime),
                maxTokenAmount,
                MinStakeAmount,
                minReputation,
                dataHash,
                dataSize,
                litigationInterval,
                predeterminedDhWallets,
                predeterminedDhNodeIds.map(id => Utilities.normalizeHex(id)),
            ],
            options,
        );
    }

    /**
     * Cancel offer for data storing on Ethereum blockchain.
     * @param importId Data if of the offer.
     */
    cancelOffer(importId) {
        const options = {
            gasLimit: this.web3.utils.toHex(this.config.gas_limit),
            gasPrice: this.web3.utils.toHex(this.config.gas_price),
            to: this.biddingContractAddress,
        };

        this.log.notify('Initiating escrow to cancel offer');
        return this.transactions.queueTransaction(
            this.biddingContractAbi, 'cancelOffer',
            [importId], options,
        );
    }

    async getStakedAmount(importId) {
        const events = await this.contractsByName.ESCROW_CONTRACT.getPastEvents('allEvents', {
            fromBlock: 0,
            toBlock: 'latest',
        });
        let totalStake = new BN(0);
        const initiated = {};
        for (const event of events) {
            const { import_id } = event.returnValues;
            if (event.event === 'EscrowInitated'
                && event.returnValues.import_id === importId
                && event.returnValues.DH_wallet === this.config.wallet_address) {
                initiated[import_id] = new BN(event.returnValues.stake_amount, 10);
            }
            if (event.event === 'EscrowVerified'
                && event.returnValues.import_id === importId
                && event.returnValues.DH_wallet === this.config.wallet_address) {
                totalStake = totalStake.add(initiated[import_id]);
            }
            if (event.event === 'EscrowCompleted'
                && event.returnValues.import_id === importId
                && event.returnValues.DH_wallet === this.config.wallet_address) {
                totalStake = totalStake.sub(initiated[import_id]);
            }
        }
        return totalStake.toString();
    }

    async getHoldingIncome(importId) {
        const events = await this.contractsByName.ESCROW_CONTRACT.getPastEvents('allEvents', {
            fromBlock: 0,
            toBlock: 'latest',
        });
        let totalAmount = new BN(0);
        for (const event of events) {
            if (event.event === 'Payment'
                && event.returnValues.import_id === importId
                && event.returnValues.DH_wallet === this.config.wallet_address) {
                totalAmount = totalAmount.add(new BN(event.returnValues.amount));
            }
        }
        return totalAmount.toString();
    }

    async getPurchaseIncome(importId, dvWallet) {
        const events = await this.contractsByName.READING_CONTRACT.getPastEvents('allEvents', {
            fromBlock: 0,
            toBlock: 'latest',
        });
        let totalAmount = new BN(0);
        for (const event of events) {
            if (event.event === 'PurchasePayment'
                && event.returnValues.import_id === importId
                && event.returnValues.DV_wallet === dvWallet
                && event.returnValues.DH_wallet === this.config.wallet_address) {
                totalAmount = totalAmount.add(new BN(event.returnValues.amount));
            }
        }
        return totalAmount.toString();
    }

    async getTotalStakedAmount() {
        const events = await this.contractsByName.ESCROW_CONTRACT.getPastEvents('allEvents', {
            fromBlock: 0,
            toBlock: 'latest',
        });
        let totalStake = new BN(0);
        const initiated = {};
        for (const event of events) {
            const { import_id } = event.returnValues;
            if (event.event === 'EscrowInitated' && event.returnValues.DH_wallet === this.config.wallet_address) {
                initiated[import_id] = new BN(event.returnValues.stake_amount, 10);
            }
            if (event.event === 'EscrowVerified' && event.returnValues.DH_wallet === this.config.wallet_address) {
                totalStake = totalStake.add(initiated[import_id]);
            }
            if (event.event === 'EscrowCompleted' && event.returnValues.DH_wallet === this.config.wallet_address) {
                totalStake = totalStake.sub(initiated[import_id]);
            }
        }
        return totalStake.toString();
    }

    async getTotalIncome() {
        let events = await this.contractsByName.ESCROW_CONTRACT.getPastEvents('allEvents', {
            fromBlock: 0,
            toBlock: 'latest',
        });
        let totalAmount = new BN(0);
        for (const event of events) {
            if (event.event === 'Payment' && event.returnValues.DH_wallet === this.config.wallet_address) {
                totalAmount = totalAmount.add(new BN(event.returnValues.amount));
            }
        }
        events = await this.contractsByName.READING_CONTRACT.getPastEvents('allEvents', {
            fromBlock: 0,
            toBlock: 'latest',
        });
        for (const event of events) {
            if (event.event === 'PurchasePayment' && event.returnValues.DH_wallet === this.config.wallet_address) {
                totalAmount = totalAmount.add(new BN(event.returnValues.amount));
            }
        }
        return totalAmount.toString();
    }

    /**
     * Gets all past events for the contract
     * @param contractName
     */
    async getAllPastEvents(contractName) {
        try {
            const currentBlock = Utilities.hexToNumber(await this.web3.eth.getBlockNumber());

            let fromBlock = 0;

            // Find last queried block if any.
            const lastEvent = await Models.events.findOne({
                where: {
                    contract: contractName,
                },
                order: [
                    ['block', 'DESC'],
                ],
            });

            if (lastEvent) {
                fromBlock = lastEvent.block + 1;
            } else {
                fromBlock = Math.max(currentBlock - 100, 0);
            }

            const events = await this.contractsByName[contractName].getPastEvents('allEvents', {
                fromBlock,
                toBlock: 'latest',
            });
            for (let i = 0; i < events.length; i += 1) {
                const event = events[i];
                const timestamp = Date.now();
                /* eslint-disable-next-line */
                await Models.events.create({
                    id: event.id,
                    contract: contractName,
                    event: event.event,
                    data: JSON.stringify(event.returnValues),
                    import_id: event.returnValues.import_id,
                    block: event.blockNumber,
                    timestamp,
                    finished: 0,
                });
            }

            const twoWeeksAgo = new Date();
            twoWeeksAgo.setDate(twoWeeksAgo.getDate() - 14);
            // Delete old events
            await Models.events.destroy({
                where: {
                    timestamp: {
                        [Op.lt]: twoWeeksAgo.getTime(),
                    },
                    finished: 1,
                },
            });
        } catch (error) {
            if (error.msg && error.msg.includes('Invalid JSON RPC response')) {
                this.log.warn('Node failed to communicate with blockchain provider. Check internet connection');
            } else {
                this.log.trace(`Failed to get all passed events. ${error}.`);
            }
        }
    }

    /**
    * Subscribes to blockchain events
    * @param event
    * @param importId
    * @param filterFn
    * @param endMs
    * @param endCallback
    */
    subscribeToEvent(event, importId, endMs = 5 * 60 * 1000, endCallback, filterFn) {
        return new Promise((resolve, reject) => {
            let clearToken;
            const token = setInterval(() => {
                const where = {
                    event,
                    finished: 0,
                };
                if (importId) {
                    where.import_id = importId;
                }
                Models.events.findAll({
                    where,
                }).then((events) => {
                    for (const eventData of events) {
                        const parsedData = JSON.parse(eventData.dataValues.data);

                        let ok = true;
                        if (filterFn) {
                            ok = filterFn(parsedData);
                        }
                        if (!ok) {
                            // eslint-disable-next-line
                            continue;
                        }
                        eventData.finished = true;
                        // eslint-disable-next-line no-loop-func
                        eventData.save().then(() => {
                            clearTimeout(clearToken);
                            clearInterval(token);
                            resolve(parsedData);
                        }).catch((err) => {
                            this.log.error(`Failed to update event ${event}. ${err}`);
                            reject(err);
                        });
                        break;
                    }
                });
            }, 2000);
            clearToken = setTimeout(() => {
                if (endCallback) {
                    endCallback();
                }
                clearInterval(token);
                resolve(null);
            }, endMs);
        });
    }

    /**
     * Subscribes to Blockchain event
     *
     * Calling this method will subscribe to Blockchain's event which will be
     * emitted globally using globalEmitter.
     * @param event Event to listen to
     * @returns {number | Object} Event handle
     */
    subscribeToEventPermanent(event) {
        const handle = setInterval(async () => {
            const startBlockNumber = parseInt(await Utilities.getBlockNumberFromWeb3(), 16);

            const where = {
                [Op.or]: event.map(e => ({ event: e })),
                block: { [Op.gte]: startBlockNumber },
                finished: 0,
            };

            const eventData = await Models.events.findAll({ where });
            if (eventData) {
                eventData.forEach(async (data) => {
                    this.emitter.emit(`eth-${data.event}`, JSON.parse(data.dataValues.data));
                    data.finished = true;
                    await data.save();
                });
            }
        }, 2000);

        return handle;
    }

    unsubscribeToEventPermanent(eventHandle) {
        clearInterval(eventHandle);
    }

    /**
     * Checks if the node would rank in the top n + 1 network bids.
     * @param importId Offer import id
     * @returns {Promisse<any>} boolean whether node would rank in the top n + 1
     */
    getDistanceParameters(importId) {
        return new Promise((resolve, reject) => {
            this.log.trace('Check if close enough ... ');
            this.storageContract.methods.getProfile_balance(importId).call({
                from: this.config.wallet_address,
            }).then((res) => {
                resolve(res);
            }).catch((e) => {
                reject(e);
            });
        });
    }


    /**
     * Adds bid to the offer on Ethereum blockchain
     * @param importId Hash of the offer
     * @param dhNodeId KADemlia ID of the DH node that wants to add bid
     * @returns {Promise<any>} Index of the bid.
     */
    addBid(importId, dhNodeId) {
        const options = {
            gasLimit: this.web3.utils.toHex(this.config.gas_limit),
            gasPrice: this.web3.utils.toHex(this.config.gas_price),
            to: this.biddingContractAddress,
        };

        this.log.notify(`Adding bid for import ID ${importId}.`);
        this.log.trace(`addBid(${importId}, ${dhNodeId})`);
        return this.transactions.queueTransaction(
            this.biddingContractAbi, 'addBid',
            [importId, Utilities.normalizeHex(dhNodeId)], options,
        );
    }

    /**
     * Activates predetermined bid in the offer on Ethereum blockchain
     * @param importId Hash of the offer
     * @param dhNodeId KADemlia ID of the DH node that wants to activate bid
     * @param bidIndex index of the bid in the array
     * @returns {Promise<any>} Index of the bid.
     */
    activatePredeterminedBid(importId, dhNodeId, bidIndex) {
        const options = {
            gasLimit: this.web3.utils.toHex(this.config.gas_limit),
            gasPrice: this.web3.utils.toHex(this.config.gas_price),
            to: this.biddingContractAddress,
        };

        this.log.notify('Initiating escrow to activate predetermined bid');
        return this.transactions.queueTransaction(
            this.biddingContractAbi, 'activatePredeterminedBid',
            [importId, Utilities.normalizeHex(dhNodeId), bidIndex], options,
        );
    }

    /**
     * Cancel the bid on Ethereum blockchain
     * @param dcWallet Wallet of the bidder
     * @param importId ID of the data of the bid
     * @param bidIndex Index of the bid
     * @returns {Promise<any>}
     */
    cancelBid(dcWallet, importId, bidIndex) {
        const options = {
            gasLimit: this.web3.utils.toHex(this.config.gas_limit),
            gasPrice: this.web3.utils.toHex(this.config.gas_price),
            to: this.escrowContractAddress,
        };

        this.log.notify('Initiating escrow to cancel bid');
        return this.transactions.queueTransaction(
            this.biddingContractAbi, 'cancelBid',
            [dcWallet, importId, bidIndex], options,
        );
    }

    /**
     * Starts choosing bids from contract escrow on Ethereum blockchain
     * @param importId Import ID
     * @returns {Promise<any>}
     */
    chooseBids(importId) {
        const options = {
            gasLimit: this.web3.utils.toHex(this.config.gas_limit),
            gasPrice: this.web3.utils.toHex(this.config.gas_price),
            to: this.biddingContractAddress,
        };

        this.log.notify('Initiating escrow to choose bid');
        return this.transactions.queueTransaction(
            this.biddingContractAbi, 'chooseBids',
            [importId], options,
        );
    }

    /**
     *
     * @param dcWallet
     * @param importId
     * @param bidIndex
     * @returns {Promise<any>}
     */
    getBid(dcWallet, importId, bidIndex) {
        const options = {
            gasLimit: this.web3.utils.toHex(this.config.gas_limit),
            gasPrice: this.web3.utils.toHex(this.config.gas_price),
            to: this.biddingContractAddress,
        };

        this.log.notify('Initiating escrow to get bid');
        return this.transactions.queueTransaction(
            this.biddingContractAbi, 'getBid',
            [dcWallet, importId, bidIndex], options,
        );
    }

    /**
    * Gets status of the offer
    * @param importId
    * @return {Promise<any>}
    */
    getOfferStatus(importId) {
        return new Promise((resolve, reject) => {
            this.log.trace(`Asking for ${importId} offer status`);
            this.storageContract.methods.getOfferStatus(importId).call()
                .then((res) => {
                    resolve(res);
                }).catch((e) => {
                    reject(e);
                });
        });
    }

    getDcWalletFromOffer(importId) {
        return new Promise((resolve, reject) => {
            this.log.trace(`Asking for offer's (${importId}) DC wallet.`);
            this.storageContract.methods.offer(importId).call()
                .then((res) => {
                    resolve(res[0]);
                }).catch((e) => {
                    reject(e);
                });
        });
    }

    /**
     * Deposit tokens to profile
     * @param {number} - amount
     * @returns {Promise<any>}
     */
    async depositToken(amount) {
        const options = {
            gasLimit: this.web3.utils.toHex(this.config.gas_limit),
            gasPrice: this.web3.utils.toHex(this.config.gas_price),
            to: this.profileContractAddress,
        };

        this.log.trace(`Calling - depositToken(${amount.toString()})`);
        return this.transactions.queueTransaction(
            this.profileContractAbi, 'depositToken',
            [amount], options,
        );
    }

    /**
     * Withdraw tokens from profile to wallet
     * @param {number} - amount
     * @returns {Promise<any>}
     */
    async withdrawToken(amount) {
        const options = {
            gasLimit: this.web3.utils.toHex(this.config.gas_limit),
            gasPrice: this.web3.utils.toHex(this.config.gas_price),
            to: this.profileContractAddress,
        };

        this.log.trace(`Calling - withdrawToken(${amount.toString()})`);
        return this.transactions.queueTransaction(
            this.profileContractAbi, 'withdrawToken',
            [amount], options,
        );
    }
    async addRootHashAndChecksum(importId, litigationHash, distributionHash, checksum) {
        const options = {
            gasLimit: this.web3.utils.toHex(this.config.gas_limit),
            gasPrice: this.web3.utils.toHex(this.config.gas_price),
            to: this.escrowContractAddress,
        };

        checksum = Utilities.normalizeHex(checksum);
        this.log.trace(`addRootHashAndChecksum (${importId}, ${litigationHash}, ${distributionHash}, ${checksum})`);
        return this.transactions.queueTransaction(
            this.escrowContractAbi, 'addRootHashAndChecksum',
            [importId, litigationHash, distributionHash, checksum], options,
        );
    }

    /**
     * Gets Escrow
     * @param dhWallet
     * @param importId
     * @return {Promise<any>}
     */
    async getEscrow(importId, dhWallet) {
        this.log.trace(`Asking escrow for import ${importId} and dh ${dhWallet}.`);
        return this.escrowStorageContract.methods.escrow(importId, dhWallet).call();
    }

    async getPurchase(dhWallet, dvWallet, importId) {
        this.log.trace(`Asking purchase for import (purchase[${dhWallet}][${dvWallet}][${importId}].`);
        return this.readingStorageContract.methods.purchase(dhWallet, dvWallet, importId).call();
    }

    async getPurchasedData(importId, wallet) {
        this.log.trace(`Asking purchased data for import ${importId} and wallet ${wallet}.`);
        return this.readingStorageContract.methods.purchased_data(importId, wallet).call();
    }

    initiatePurchase(importId, dhWallet, tokenAmount, stakeFactor) {
        const options = {
            gasLimit: this.web3.utils.toHex(this.config.gas_limit),
            gasPrice: this.web3.utils.toHex(this.config.gas_price),
            to: this.readingContractAddress,
        };

        this.log.trace(`initiatePurchase (${importId}, ${dhWallet}, ${tokenAmount}, ${stakeFactor})`);
        return this.transactions.queueTransaction(
            this.readingContractAbi, 'initiatePurchase',
            [importId, dhWallet, tokenAmount, stakeFactor], options,
        );
    }

    sendCommitment(importId, dvWallet, commitment) {
        const options = {
            gasLimit: this.web3.utils.toHex(this.config.gas_limit),
            gasPrice: this.web3.utils.toHex(this.config.gas_price),
            to: this.readingContractAddress,
        };

        this.log.trace(`sendCommitment (${importId}, ${dvWallet}, ${commitment})`);
        return this.transactions.queueTransaction(
            this.readingContractAbi, 'sendCommitment',
            [importId, dvWallet, commitment], options,
        );
    }

    initiateDispute(importId, dhWallet) {
        const options = {
            gasLimit: this.web3.utils.toHex(this.config.gas_limit),
            gasPrice: this.web3.utils.toHex(this.config.gas_price),
            to: this.readingContractAddress,
        };

        this.log.trace(`initiateDispute (${importId}, ${dhWallet})`);
        return this.transactions.queueTransaction(
            this.readingContractAbi, 'initiateDispute',
            [importId, dhWallet], options,
        );
    }

    confirmPurchase(importId, dhWallet) {
        const options = {
            gasLimit: this.web3.utils.toHex(this.config.gas_limit),
            gasPrice: this.web3.utils.toHex(this.config.gas_price),
            to: this.readingContractAddress,
        };

        this.log.trace(`confirmPurchase (${importId}, ${dhWallet})`);
        return this.transactions.queueTransaction(
            this.readingContractAbi, 'confirmPurchase',
            [importId, dhWallet], options,
        );
    }

    cancelPurchase(importId, correspondentWallet, senderIsDh) {
        const options = {
            gasLimit: this.web3.utils.toHex(this.config.gas_limit),
            gasPrice: this.web3.utils.toHex(this.config.gas_price),
            to: this.readingContractAddress,
        };

        this.log.trace(`confirmPurchase (${importId}, ${correspondentWallet}, ${senderIsDh})`);
        return this.transactions.queueTransaction(
            this.readingContractAbi, 'confirmPurchase',
            [importId, correspondentWallet, senderIsDh], options,
        );
    }

    sendProofData(
        importId, dvWallet, checksumLeft, checksumRight, checksumHash,
        randomNumber1, randomNumber2, decryptionKey, blockIndex,
    ) {
        const options = {
            gasLimit: this.web3.utils.toHex(this.config.gas_limit),
            gasPrice: this.web3.utils.toHex(this.config.gas_price),
            to: this.readingContractAddress,
        };

        this.log.trace(`sendProofData (${importId} ${dvWallet} ${checksumLeft} ${checksumRight} ${checksumHash}, ${randomNumber1}, ${randomNumber2} ${decryptionKey} ${blockIndex})`);
        return this.transactions.queueTransaction(
            this.readingContractAbi, 'sendProofData',
            [
                importId, dvWallet, checksumLeft, checksumRight, checksumHash,
                randomNumber1, randomNumber2, decryptionKey, blockIndex,
            ], options,
        );
    }

    async sendEncryptedBlock(importId, dvWallet, encryptedBlock) {
        const options = {
            gasLimit: this.web3.utils.toHex(this.config.gas_limit),
            gasPrice: this.web3.utils.toHex(this.config.gas_price),
            to: this.readingContractAddress,
        };

        this.log.trace(`sendEncryptedBlock (${importId}, ${dvWallet}, ${encryptedBlock})`);
        return this.transactions.queueTransaction(
            this.readingContractAbi, 'sendEncryptedBlock',
            [importId, dvWallet, encryptedBlock], options,
        );
    }

    payOutForReading(importId, dvWallet) {
        const options = {
            gasLimit: this.web3.utils.toHex(this.config.gas_limit),
            gasPrice: this.web3.utils.toHex(this.config.gas_price),
            to: this.readingContractAddress,
        };

        this.log.trace(`payOutForReading (${importId}, ${dvWallet})`);
        return this.transactions.queueTransaction(
            this.readingContractAbi, 'payOut',
            [importId, dvWallet], options,
        );
    }

    /**
     * Get replication modifier
     */
    async getReplicationModifier() {
        this.log.trace('get replication modifier from blockchain');
        return this.biddingContract.methods.replication_modifier().call({
            from: this.config.wallet_address,
        });
    }
}

module.exports = Ethereum;
