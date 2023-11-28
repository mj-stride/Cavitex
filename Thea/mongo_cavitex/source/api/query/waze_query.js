'use strict'

import moment from 'moment-timezone'

export async function insert_alert(db,
	alert
) {

	return await db.collection('waze_alerts')
		.insertOne({
			'date': moment().format('YYYY-MM-DD'),
			'time': moment.tz("Asia/Manila").format('HH:mm:ss'),
			'alert': JSON.parse(alert)
		},
		{
			raw: true
		},
		(err, data) => {
			console.log(data)
		})
}

// export async function insert_alert(db,
// 	_country,
// 	_city,
// 	report_rating,
// 	report_municipality,
// 	_confidence,
// 	_reliability,
// 	_type,
// 	_uuid,
// 	road_type,
// 	_magvar,
// 	_subtype,
// 	_street,
// 	report_description,
// 	_lng,
// 	_lat,
// 	pub_millis,
// ) {
// 	const data = {
// 			'country': _country,
// 			'city': _city,
// 			'reportRating': report_rating,
// 			'reportByMunicipalityUser': report_municipality,
// 			'confidence': _confidence,
// 			'reliability': _reliability,
// 			'type': _type,
// 			'uuid': _uuid,
// 			'roadType': road_type,
// 			'magvar': _magvar,
// 			'subtype': _subtype,
// 			'street': _street,
// 			'reportDescription': report_description,
// 			'location': {
// 				'x': _lng,
// 				'y': _lat
// 			},
// 			'pubMillis': pub_millis,
// 			'date': moment().format('YYYY-MM-DD'),
// 			'time': moment.tz("Asia/Manila").format('HH:mm:ss')
// 		}

// 	return await db.collection('waze_alerts')
// 		.insertOne(data)
// 		.then(function(res) {
// 			return res
// 		})
// }

export async function get_alert(db) {
	let list = []

	return await db.collection('waze_alerts')
		.find()
		.forEach(i => list.push(i))
		.then(() => {
			return list
		})
}