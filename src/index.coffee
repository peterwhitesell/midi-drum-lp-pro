{ Controller } = require './controller'
{ drumKit } = require './kit'
{ padLayout, kitLayout } = require './layouts'
{
  TempoPrinter
  PadPrinter
  PadLayoutPrinter
} = require './printer'

controller = new Controller {
  padLayout
  kitLayout
  kit: drumKit
  printer: new PadLayoutPrinter()
}

controller.init()
  .then -> console.log 'initialized'
  .catch (err) ->
    console.error "initialization error", err, err.stack
    return controller.close()
