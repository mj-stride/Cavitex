'use strict'

import { insert_gpt, get_gpt } from './query/gpt_query.js'

const api = (db, app) => {
    const asyncMiddleware = fn => (req, res, next) => {
        Promise.resolve(fn(req, res, next))
            .catch(next)
    }

    app.post('/insert_gpt', asyncMiddleware(async(req, res, next) => {
        console.log('----- INSERT GOOGLE POPULAR TIMES -----')

        try {
            const result = await insert_gpt(db,
                req.body.location,
                req.body.hour,
                req.body.popularity
            )

            if (result.acknowledged === true) {
                res.send({status: 200})
            } else {
                res.send({status: 500})
            }
        } catch(err) {
            console.log(err)
            res.send(err)
        }
    }))

    app.post('/get_gpt', asyncMiddleware(async(req, res, next) => {
        console.log('----- GET GOOGLE POPULAR TIMES -----')

        try {
            const result = await get_gpt(db,
                req.body.location
            )

            if (result.length > 0) {
                res.send({status: 200, gpt: result})
            } else {
                res.send({status: 500})
            }
        } catch(err) {
            console.log(err)
            res.send(err)
        }
    }))
}

export default api