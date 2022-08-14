const fs = require('fs');
const { Client } = require('pg');
const client = new Client({ connectionString: process.env.DB_URI, ssl: { rejectUnauthorized: false } });
const seedFile = fs.readFileSync('vManage-create-insert.sql').toString();

exports.connectDB = async () => {
    try {
        await client.connect();
        console.log("DB Connected")
    } catch (error) {
        console.error(error);
    }
}

exports.query = (query, values) => {
    return new Promise((resolve, reject) => {
        client.query(query, values)
            .then((result) => {
                resolve(result.rows);
            })
            .catch((error) => {
                console.log("Query:", query);
                if (values) {
                    console.log("Values:", values);
                }
                reject(error);
            });
    });
}

exports.runSeed = () => {
    return client.query(seedFile).then(() => console.log("Done Running Seed File")).catch(error => console.log(error));
}