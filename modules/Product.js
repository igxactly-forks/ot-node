const Utilities = require('./Utilities');
const ZK = require('./ZK');
const Models = require('../models');
const Encryption = require('./Encryption');


/**
 * Encapsulates product related operations
 */
class Product {
    constructor(ctx) {
        this.graphStorage = ctx.graphStorage;
        this.ctx = ctx;
    }

    /**
     * Get vertex
     * @param queryObject
     * @returns {Promise}
     */
    getVertices(queryObject) {
        return new Promise((resolve, reject) => {
            this.graphStorage.findImportIds(queryObject).then((vertices) => {
                resolve(vertices);
            }).catch((err) => {
                reject(err);
            });
        });
    }

    /**
     * Returns given import's vertices and edges and decrypt them if needed.
     *
     * Method will return object in following format { vertices: [], edges: [] }.
     * @param importId ID of import.
     * @returns {Promise<*>}
     */
    async getVerticesForImport(importId) {
        // Check if import came from DH replication or reading replication.
        const holdingData = await Models.holding_data.find({ where: { id: importId } });

        if (holdingData) {
            const verticesPromise = this.graphStorage.findVerticesByImportId(importId);
            const edgesPromise = this.graphStorage.findEdgesByImportId(importId);

            const values = await Promise.all([verticesPromise, edgesPromise]);

            const encodedVertices = values[0];
            const edges = values[1];
            const decryptKey = holdingData.data_public_key;
            const vertices = [];

            encodedVertices.forEach((encodedVertex) => {
                const decryptedVertex = Utilities.copyObject(encodedVertex);
                if (decryptedVertex.vertex_type !== 'CLASS') {
                    decryptedVertex.data =
                        Encryption.decryptObject(
                            encodedVertex.data,
                            decryptKey,
                        );
                }
                vertices.push(decryptedVertex);
            });

            return { vertices, edges };
        }

        // Check if import came from DC side.
        const dataInfo = await Models.data_info.find({ where: { import_id: importId } });

        if (dataInfo) {
            const verticesPromise = this.graphStorage.findVerticesByImportId(importId);
            const edgesPromise = this.graphStorage.findEdgesByImportId(importId);

            const values = await Promise.all([verticesPromise, edgesPromise]);

            return { vertices: values[0], edges: values[1] };
        }

        throw Error(`Cannot find vertices for import ID ${importId}.`);
    }

    /**
     * Gets trail based on query parameter map
     * @param queryObject   Query parameter map
     * @returns {Promise}
     */
    getTrail(queryObject) {
        return new Promise((resolve, reject) => {
            if (queryObject.restricted !== undefined) {
                delete queryObject.restricted;
            }

            this.graphStorage.findVertices(queryObject).then((vertices) => {
                if (vertices.length === 0) {
                    resolve([]);
                    return;
                }

                const start_vertex = vertices[0];
                const depth = this.graphStorage.getDatabaseInfo().max_path_length;
                this.graphStorage.findTraversalPath(start_vertex, depth)
                    .then((virtualGraph) => {
                        virtualGraph = this.consensusCheck(virtualGraph);
                        virtualGraph = this.zeroKnowledge(virtualGraph);
                        resolve(virtualGraph.data);
                    }).catch((err) => {
                        reject(err);
                    });
            }).catch((error) => {
                reject(error);
            });
        });
    }

    /**
     * Go through the virtual graph and calculate consensus check
     * @param virtualGraph
     */
    consensusCheck(virtualGraph) {
        const graph = virtualGraph.data;
        for (const key in graph) {
            const vertex = graph[key];
            if (vertex.vertex_type === 'EVENT') {
                for (const neighbourEdge of vertex.outbound) {
                    if (neighbourEdge.edge_type === 'EVENT_CONNECTION') {
                        const neighbour = graph[neighbourEdge.to];
                        const distance = Utilities.objectDistance(vertex.data, neighbour.data, ['quantities', 'bizStep']);
                        if (!vertex.consensus) {
                            vertex.consensus = distance;
                        }
                    }
                }
            }
        }
        return virtualGraph;
    }

    /**
     * Go through the virtual graph and check zero knowledge proof
     * @param virtualGraph
     */
    zeroKnowledge(virtualGraph) {
        const graph = virtualGraph.data;
        const zk = new ZK(this.ctx);

        for (const key in graph) {
            const vertex = graph[key];
            if (vertex.vertex_type === 'EVENT') {
                vertex.zk_status = this._calculateZeroKnowledge(
                    zk,
                    vertex.data.quantities.inputs,
                    vertex.data.quantities.outputs,
                    vertex.data.quantities.e,
                    vertex.data.quantities.a,
                    vertex.data.quantities.zp,
                );
            }
        }
        return virtualGraph;
    }

    /**
     * Calculate ZK proof
     */
    _calculateZeroKnowledge(zk, inputQuantities, outputQuantities, e, a, zp) {
        const inQuantities = inputQuantities.map(o => o.public.enc).sort();
        const outQuantities = outputQuantities.map(o => o.public.enc).sort();

        const z = zk.calculateZero(inQuantities, outQuantities);

        const valid = zk.V(
            e, a, z,
            zp,
        );
        if (!valid) {
            return 'FAILED';
        }
        return 'PASSED';
    }

    /**
     * Gets trail based on every query parameter
     * @param queryObject
     * @returns {Promise}
     */
    getTrailByQuery(queryObject) {
        return new Promise((resolve, reject) => {
            this.getTrail(queryObject).then((res) => {
                resolve(res);
            }).catch((err) => {
                reject(err);
            });
        });
    }

    getImports(inputQuery) {
        return this.graphStorage.findImportIds(inputQuery);
    }
}

module.exports = Product;

