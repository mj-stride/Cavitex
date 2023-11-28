'use strict'

import { get_location, get_address } from './query/location_query.js'

const api = (db, app) => {
    const asyncMiddleware = fn => (req, res, next) => {
        Promise.resolve(fn(req, res, next))
            .catch(next)
    }

    app.post('/location', asyncMiddleware(async(req, res, next) => {
        console.log('----- LOCATION -----')

        try {
            const result = await get_location(db)

            if (result.length > 0) {
                res.send({status: 200, location: result})
            } else {
                res.send({status: 500, msg: `No fetched location`})
            }
            
        } catch(err) {
            res.send(err)
        }
    }))

    app.post('/location/address', asyncMiddleware(async(req, res, next) => {
        console.log('----- LOCATION ADDRESS -----')

        try {
            console.log(req.body.location)

            const result = await get_address(db,
                req.body.location
            )

            if (result.length > 0) {
                res.send({status: 200, coordinates: result})
            } else {
                res.send({status: 500, msg: `Invalid location.`})
            }
        } catch(err) {
            res.send(err)
        }
    }))

    /*app.post('/', asyncMiddleware(async(req, res, next) => {
        console.log('-----  -----')

        try {
            const result = await (db,
                req.body.
            )


            if (result.length > 0) {
                res.send({status: 200})
            } else {
                res.send({status: 500})
            }
        } catch(err) {
            res.send(err)
        }
    }))*/
}

export default api