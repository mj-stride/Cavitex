import dotenv from 'dotenv'
dotenv.config()

import express from 'express'
const app = express()

import bodyParser from 'body-parser'

import location from './location.js'
import gpt from './gpt.js'
import waze from './waze.js'

const application = (mode, db) => {
    app.disable('x-powered-by')
	app.set('trust proxy', 1)
	app.use(bodyParser.json({ limit:'50mb', type: 'application/*+json' }))
	app.use(bodyParser.urlencoded({extended: true}))
	app.use(bodyParser.urlencoded({limit:'50mb', extended:false, parameterLimit:50000}))
	app.use(bodyParser.raw({ type: 'application/vnd.custom-type' }))
	app.use(bodyParser.text({ type: 'text/html' }))
	app.all('*', function(req, res, next) {
		res.header("Access-Control-Allow-Origin", "*")
		res.header("Access-Control-Allow-Headers", "X-Requested-With")
		next()
	})

	app.get('/', function(req, res, next) {  
		res.render('index', {})
	})

	location(db, app)
	gpt(db, app)
	waze(db, app)

    app.listen(process.env.DEV_PORT, () => {
        logger.info(`API Running on port ${process.env.DEV_PORT}`)
    })

    app.use((error, req, res, next) => {
        if (error) {
            logger.error({status: 500, msg: JSON.stringify(error)})
            res.send({status: 500, msg: JSON.stringify(error)})
        } else {
            next()
        }
    })
}

export default application