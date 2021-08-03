const {
  Controller
} = require('./controller')
const { drumKit } = require('./kit')
const {
  padLayout,
  kitLayout
} = require('./layouts')

const controller = new Controller({
  padLayout,
  kitLayout,
  kit: drumKit
})

controller.init().then(() => {
  console.log('initialized')
})
.catch(err => {
  console.error(err)
  return controller.close()
})
