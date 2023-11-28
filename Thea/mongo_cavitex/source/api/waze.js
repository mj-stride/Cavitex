'use strict'

import { insert_alert, get_alert } from './query/waze_query.js'

const api = (db, app) => {
    const asyncMiddleware = fn => (req, res, next) => {
        Promise.resolve(fn(req, res, next))
            .catch(next)
    }

    app.post('/waze/insert_alert', asyncMiddleware(async(req, res, next) => {
        console.log('----- WAZE: INSERT ALERT -----')

        try {
            const result = await insert_alert(db,
                req.body.alert
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

    // app.post('/waze/insert_alert', asyncMiddleware(async(req, res, next) => {
    //     console.log('----- WAZE: INSERT ALERT -----')

    //     try {
    //         const result = await insert_alert(db,
    //             req.body.country,
    //             req.body.city,
    //             req.body.report_rating,
    //             req.body.report_municipality,
    //             req.body.confidence,
    //             req.body.reliability,
    //             req.body.type,
    //             req.body.uuid,
    //             req.body.road_type,
    //             req.body.magvar,
    //             req.body.subtype,
    //             req.body.street,
    //             req.body.report_description,
    //             req.body.lng,
    //             req.body.lat,
    //             req.body.pub_millis
    //         )

    //         if (result.acknowledged === true) {
    //             res.send({status: 200})
    //         } else {
    //             res.send({status: 500})
    //         }
    //     } catch(err) {
    //         console.log(err)
    //         res.send(err)
    //     }
    // }))

    app.post('/waze/get_alert', asyncMiddleware(async(req, res, next) => {
        console.log('----- WAZE: GET ALERT -----')

        try {
            const result = await get_alert(db)

            if (result.length > 0) {
                res.send({status: 200, alert: result})
            } else {
                res.send({status: 500})
            }
        } catch(err) {
            res.send(err)
        }
    }))

    /*app.post('/', asyncMiddleware(async(req, res, next) => {
        console.log('-----  -----')

        try {
            await (db,
                req.body.
            )
        } catch(err) {
            res.send(err)
        }
    }))*/
}

export default api