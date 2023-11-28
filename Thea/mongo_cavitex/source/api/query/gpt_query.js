import moment from 'moment'

export async function insert_gpt(db,
	location,
	hour,
	popularity
) {
	const data = {
		'location': location,
		'date': moment().format('YYYY-MM-DD'),
		'popular_time': {
			'hour': [hour],
			'popularity': [popularity]
		}
	}

	return await db.collection('gpt')
		.insertOne(data)
		.then(function(res) {
			return res
		})

	// return list
}

export async function get_gpt(db,
	location
) {
	let list = []

	return await db.collection('gpt')
		.find({location: location})
		.forEach(i => list.push(i))
		.then(() => {
			return list
		})
}