import { MongoClient } from "mongodb"

import dotenv from 'dotenv'
dotenv.config()

let dbConnection

export async function connectToDb(cb) {
    MongoClient.connect('mongodb://' + process.env.HOST + ':' + process.env.PORT + "/" + process.env.DATABASE)
    // MongoClient.connect('mongodb://127.0.0.1:27017/street_parking_db')
    .then((client) => {
        dbConnection = client.db()
        return cb()
    })
    .catch(err => {
        console.log(err)
        return cb(err)
    })
}

export function getDb() {
    return dbConnection
}