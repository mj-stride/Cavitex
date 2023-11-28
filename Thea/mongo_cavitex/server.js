'use strict'

import dotenv from 'dotenv'
dotenv.config()

import { connectToDb, getDb } from './source/connection/db.js'
import api from './source/api/api.js'
import logger from './source/service/logger.js'
global.logger = logger


// api(process.env.MODE, db)

connectToDb((err) => {
    if (!err) {
        let db = getDb()
        api(process.env.MODE, db)
    }
})

process.stdin.resume()

function exitHandler(options, err)
{
	if(options.cleanup)
	{
		console.log('Cleaned')
	}
	
	if(err)
	{
		console.log(err)
	}

	if(options.exit)
	{
		console.log('Exit')
		process.exit()
	}
}

process.on('exit', exitHandler.bind(null, {cleanup: true}))

process.on('SIGINT', exitHandler.bind(null, {exit: true}))

process.on('uncaughtException', exitHandler.bind(null, {exit: true}))

process.on('unhandledRejection', exitHandler.bind(null, {exit: true}))