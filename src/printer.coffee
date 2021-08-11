fill = require 'lodash/fill'
{ terminal } = require 'terminal-kit'

exports.TempoPrinter = class TempoPrinter
  constructor: ({ @tempo, @subdivision, @measureLength } = {}) ->
    @subdivision ?= 4
    @tempo ?= 60
    @measureLength ?= 4
    @beat = 0
    @sub = 0
    @pads = []
    @interval = setInterval =>
      beatSymbol = '.'
      beatSymbol = '|' if @sub is 0
      msgArr = fill new Array(4), ' '
      @pads[0...3].forEach (p, i) ->
        msgArr[i] = p.printerIcon()
      msgArr.unshift beatSymbol
      msg = msgArr.join ''
      process.stdout.write msg
      @sub = (@sub + 1) % 4
      @beat = (@beat + 1) % 4 if @sub is 0
      @pads = []
      if @sub is 0 and @beat is 0
        process.stdout.write '\n'
    , 60 * 1000 / @tempo / @subdivision
  setPad: ({ pad }) -> @pads.push pad
  unsetPad: ->

exports.PadPrinter = class PadPrinter
  constructor: ->
  setPad: ({ pad }) ->
    console.log pad?.printerName()
  unsetPad: ->

exports.PadLayoutPrinter = class PadLayoutPrinter
  constructor: ->
    terminal.clear()
    @padWidth = Math.floor terminal.width / 8
    @padHeight = Math.floor terminal.height / 8
  setPad: ({ pad }) ->
    return unless pad
    for i in [0...@padHeight]
      terminal.moveTo pad.column * @padWidth, pad.row * @padHeight + i
      for j in [0...@padWidth]
        terminal pad.printerIcon()
    terminal.moveTo 0, 0
  unsetPad: ({ pad }) ->
    return unless pad
    setTimeout =>
      for i in [0...@padHeight]
        terminal.moveTo pad.column * @padWidth, pad.row * @padHeight + i
        for j in [0...@padWidth]
          terminal " "
      terminal.moveTo 0, 0
    , 100
