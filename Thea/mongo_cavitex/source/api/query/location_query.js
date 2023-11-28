'use strict'

export async function get_location(db) {
	let list = []

	return await db.collection('location')
		.find()
		.project({name: 1})
		.forEach(i => list.push(i))
		.then(() => {
			return list
		})
}

export async function get_address(db,
	location
) {
	let list = []

	return await db.collection('location')
		.find({name: location})
		.project({address: 1, lat: 1, lng: 1})
		.forEach(i => list.push(i))
		.then(() => {
			return list
		})
}