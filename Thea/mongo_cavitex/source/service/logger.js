import chalk from "chalk"
import moment from "moment"

const logger = {}

function logTime(){
	return moment().format('YYYY-MM-DD HH:mm:ss')
}

logger.info = (args) => {
	console.log(logTime(), chalk.bold.green('[INFO]'), args)
}

logger.error = (args) => {
	console.log(logTime(), chalk.bold.red('[ERROR]'), args)
}

logger.warning = (args) => {
	console.log(logTime(), chalk.bold.yellow('[WARNING]'), args)
}

logger.debug = (args) => {
	console.log(logTime(), chalk.bold.blue('[DEBUG]'), args)
}

// module.exports = logger
export default logger