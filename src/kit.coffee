{ hexByte } = require './hex'
{ Color } = require './color'
reduce = require 'lodash/reduce'
forEach = require 'lodash/forEach'
chalk = require 'chalk'

class Pad
  constructor: ({ @piece, @hit }) ->
    @aftertouch = @hit?.aftertouch
    @aftertouch ?= @piece?.aftertouch
    @id = @piece.id
    @name = @piece.name
    @id = "#{@id}.#{@hit.id}" if @hit
    @name = "#{@name} (#{@hit.name})" if @hit
    @color = @piece.color
    @color = @color.darken @hit.darken if @hit?.darken
    @color = @color.desaturate @hit.desaturate if @hit?.desaturate
  getNote: ->
    note = @piece.note
    note += @hit.index if @hit
    note
  printerName: ->
    msg = " #{@name} "
    chalk.hex('#000000').bgHex(@color.hex).bold(msg)
  printerIcon: ->
    chalk.hex('#000000').bgHex(@color.hex).bold(' ')
  setPosition: ({ @row, @column }) ->

class Hit
  constructor: ({ @id, @name, @darken, @desaturate, @aftertouch }) ->
    @index = 0
    @
  setIndex: (i) -> @index = i

class Piece
  constructor: ({ @id, @name, @color, @note, @hits, @aftertouch }) ->
    @aftertouch ?= false
    forEach @hits, (hit, idx) -> hit.setIndex idx
    @

class Kit
  constructor: ({ @pieces }) ->
    @idMap = @pieces.reduce (acc, piece) ->
      if piece.hits
        forEach piece.hits, (hit) ->
          pad = new Pad { piece, hit }
          acc[pad.id] = pad
      else
        pad = new Pad { piece }
        acc[pad.id] = pad
      acc
    , {}
  init: ({ padLayout, kitLayout }) ->
    @padMap = padLayout.reduce (map, r, rid) =>
      rowMap = r.forEach (note, cid) =>
        pad = @getById kitLayout[rid][cid]
        return unless pad
        pad = new Pad pad
        pad.setPosition
          row: rid
          column: cid
        map[note] = pad
      map
    , {}
    @pieceToPadsMap = reduce @padMap, (map, pad, note) ->
      return map unless pad
      notes = map[pad.piece.id] or []
      note = parseInt(note, 16)
      return map if notes.includes note
      notes.push note
      map[pad.piece.id] = notes
      map
    , {}
    @hitToPadsMap = reduce @padMap, (map, pad, note) ->
      return map unless pad
      notes = map[pad.id] or []
      note = parseInt(note, 16)
      return map if notes.includes note
      notes.push note
      map[pad.id] = notes
      map
    , {}
  getById: (id) -> @idMap[id]
  getByPad: (note) ->
    if typeof note == 'number'
      note = hexByte note
    @padMap[note]
  getPads: (pad) -> @hitToPadsMap[pad?.id]
  getPiecePads: (pad) -> @pieceToPadsMap[pad?.piece?.id]
  eachPad: (fn) ->
    forEach @idMap, (pad) -> fn(pad)

exports.drumKit = new Kit
  pieces: [
    new Piece
      id: 'base'
      name: 'base'
      color: new Color '#ff0000'
      note:  0x00
    new Piece
      id: 'lt'
      name: 'low-tom'
      color: new Color '#ff2d00'
      note:  0x04
      hits: [
        new Hit { id: 'o', name: 'open' }
        new Hit { id: 'r', name: 'rim', desaturate: .95 }
      ]
    new Piece
      id: 'mt'
      name: 'mid-tom'
      color: new Color '#ff4f00'
      note:  0x08
      hits: [
        new Hit { id: 'o', name: 'open' }
        new Hit { id: 'r', name: 'rim', desaturate: .95 }
      ]
    new Piece
      id: 'ht'
      name: 'hi-tom'
      color: new Color '#ff7c00'
      note:  0x0c
      hits: [
        new Hit { id: 'o', name: 'open' }
        new Hit { id: 'r', name: 'rim', desaturate: .95 }
      ]
    new Piece
      id: 'sn'
      name: 'snare'
      color: new Color '#ffbf1f'
      note:  0x10
      hits: [
        new Hit { id: 's', name: 'side', desaturate: .9 }
        new Hit { id: 'r', name: 'rim', desaturate: .9, darken: 0.8  }
        new Hit { id: 'c', name: 'close', desaturate: .9, darken: 0.75  }
        new Hit { id: 'o', name: 'open', desaturate: .9, darken: 0.7  }
      ]
    new Piece
      id: 'hh'
      name: 'hihat'
      color: new Color '#ffffff'
      note:  0x14
      aftertouch: true
      hits: [
        new Hit { id: 'o', name: 'open' }
        new Hit { id: 't', name: 'tip', darken: 0.5  }
        new Hit { id: 'f', name: 'foot', darken: 0.4  }
      ]
    new Piece
      id: 'rd'
      name: 'ride'
      color: new Color '#55d3ca'
      note:  0x18
      hits: [
        new Hit { id: 'b', name: 'bell' }
        new Hit { id: 't', name: 'tip', darken: 0.5  }
        new Hit { id: '_', name: 'choke', darken: 0.07  }
      ]
    new Piece
      id: 's1'
      name: 'symbol 1'
      color: new Color '#ff00f3'
      note:  0x1c
      hits: [
        new Hit { id: 't', name: 'tip' }
        new Hit { id: '_', name: 'choke', darken: 0.07  }
      ]
    new Piece
      id: 's2'
      name: 'symbol 2'
      color: new Color '#d600ff'
      note:  0x20
      hits: [
        new Hit { id: 't', name: 'tip' }
        new Hit { id: '_', name: 'choke', darken: 0.07  }
      ]
    new Piece
      id: 'clap'
      name: 'clap'
      color: new Color '#bcff00'
      note: 0x24
    new Piece
      id: 'wblk'
      name: 'wood-block'
      color: new Color '#be7d2f'
      note: 0x28
    new Piece
      id: 'cowb'
      name: 'cow-bell'
      color: new Color '#8800ff'
      note: 0x2c
  ]
