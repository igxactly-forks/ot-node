/* eslint-disable max-len */
const {
    describe, beforeEach, afterEach, it,
} = require('mocha');
const { assert } = require('chai');
const models = require('../../../models');
const fs = require('fs');
const sleep = require('sleep-async')().Promise;
const Command = require('../../../modules/command/command');
const Transport = require('../../../modules/network/transport');
const RemoteControl = require('../../../modules/RemoteControl');
const CleanerCommand = require('../../../modules/command/common/cleaner-command');
const DCOfferFinalizedCommand = require('../../../modules/command/dc/dc-offer-finalized-command');
const CommandResolver = require('../../../modules/command/command-resolver');
const CommandExecutor = require('../../../modules/command/command-executor');
const Storage = require('../../../modules/Storage');
const { Database } = require('arangojs');
const awilix = require('awilix');
const rc = require('rc');
const Umzug = require('umzug');
const sequelizeConfig = require('./../../../config/sequelizeConfig').development;
const Utilities = require('../../../modules/Utilities');
const defaultConfig = require('../../../config/config.json').development;
const pjson = require('../../../package.json');

function notifyBugsnag(error, metadata, subsystem) {
    console.log(error);
}

describe.only('Checks command-executor logic', () => {
    let systemDb;
    let container;
    const databaseName = 'command_executor_db';
    let commandExecutor;

    function recreateDatabase() {
        fs.closeSync(fs.openSync(sequelizeConfig.storage, 'w'));

        const migrator = new Umzug({
            storage: 'sequelize',
            storageOptions: {
                sequelize: models.sequelize,
                tableName: 'migrations',
            },
            logging: Utilities.getLogger().debug,
            migrations: {
                params: [models.sequelize.getQueryInterface(), models.Sequelize],
                path: `${__dirname}/../../../migrations`,
                pattern: /^\d+[\w-]+\.js$/,
            },
        });

        const seeder = new Umzug({
            storage: 'sequelize',
            storageOptions: {
                sequelize: models.sequelize,
                tableName: 'seeders',
            },
            logging: Utilities.getLogger().debug,
            migrations: {
                params: [models.sequelize.getQueryInterface(), models.Sequelize],
                path: `${__dirname}/../../../seeders`,
                pattern: /^\d+[\w-]+\.js$/,
            },
        });

        return models.sequelize.authenticate().then(() => migrator.up().then(() => seeder.up()));
    }

    beforeEach('Preconditions', async () => {
        recreateDatabase();

        systemDb = new Database();
        systemDb.useBasicAuth(process.env.DB_USERNAME, process.env.DB_PASSWORD);

        // Drop test database if exist.
        const listOfDatabases = await systemDb.listDatabases();
        if (listOfDatabases.includes(databaseName)) {
            await systemDb.dropDatabase(databaseName);
        }

        await systemDb.createDatabase(
            databaseName,
            [{ username: process.env.DB_USERNAME, passwd: process.env.DB_PASSWORD, active: true }],
        );

        // await models.commands.destroy({
        //     where: {},
        //     truncate: true,
        // });

        // await sleep.sleep(1000);

        container = awilix.createContainer({
            injectionMode: awilix.InjectionMode.PROXY,
        });

        const config = rc(pjson.name, defaultConfig);

        container.register({
            logger: awilix.asValue(Utilities.getLogger()),
            config: awilix.asValue(config),
            command: awilix.asClass(Command),
            cleanerCommand: awilix.asClass(CleanerCommand),
            dcOfferFinalizedCommand: awilix.asClass(DCOfferFinalizedCommand),
            commandResolver: awilix.asClass(CommandResolver).singleton(),
            commandExecutor: awilix.asClass(CommandExecutor).singleton(),
            notifyError: awilix.asFunction(() => notifyBugsnag).transient(),
        });

        commandExecutor = await container.resolve('commandExecutor');
        console.log('Length beforeEach:', commandExecutor.queue.length());
    });

    it('check .init() logic', async () => {
        await commandExecutor.init();
        const allCleanerCommands = await models.commands.findAll({ where: { name: 'cleanerCommand' } });
        assert.equal(allCleanerCommands.length, 1, 'We shoud have only single cleanerCommand');
        console.log('Length after first it:', commandExecutor.queue.length());
    });

    it.skip('check .add() logic', async () => {
        const dcOfferFinalizedCommand = {
            name: 'dcOfferFinalizedCommand',
            delay: 0,
            period: 5000,
            deadline_at: Date.now() + (5 * 60 * 1000),
            transactional: false,
            data: {},
        };

        try {
            await commandExecutor.add(dcOfferFinalizedCommand, 0, true);
        } catch (error) {
            console.log(error);
        }
    });

    afterEach('Drop DB', async () => {
        if (systemDb) {
            const listOfDatabases = await systemDb.listDatabases();
            if (listOfDatabases.includes(databaseName)) {
                await systemDb.dropDatabase(databaseName);
            }
        }
    });
});

