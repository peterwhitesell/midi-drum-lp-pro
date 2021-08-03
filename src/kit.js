const { hexByte } = require('./hex')
const { Color } = require('./color')
const reduce = require('lodash/reduce')

class Piece {
  constructor({ id, name, color, note }) {
    this.id = id
    this.name = name
    this.color = color
    this.note = note
  }
}

class Kit {
  constructor({ pieces }) {
    this.pieces = pieces
    this.idMap = pieces.reduce((acc, p) => {
      acc[p.id] = p
      return acc
    }, {})
  }
  init({ padLayout, kitLayout }) {
    this.padMap = padLayout.reduce((map, r, rid) => {
      const rowMap = r.forEach((note, cid) => {
        map[note] = this.getById(kitLayout[rid][cid])
      })
      return map
    }, {})
    this.pieceToPadsMap = reduce(this.padMap, (map, piece, pad) => {
      if (!piece) return map
      const pads = map[piece.id] || []
      if (pads.includes(pad)) return map
      pads.push(parseInt(pad, 16))
      map[piece.id] = pads
      return map
    }, {})
  }
  getById(id) {
    return this.idMap[id]
  }
  getByPad(pad) {
    if (typeof pad == 'number') {
      pad = hexByte(pad)
    }
    return this.padMap[pad]
  }
  getPads(piece) {
    return this.pieceToPadsMap[piece.id]
  }
}

const drumKit = exports.drumKit = new Kit({ pieces: [
  new Piece({
    id: 'bas',
    name: 'base',
    color: new Color('#ff0000'),
    note:  0x00,
  }),
  new Piece({
    id: 'lts',
    name: 'low-tom-soft',
    color: new Color('#ff2d00'),
    note:  0x10,
  }),
  new Piece({
    id: 'lth',
    name: 'low-tom-hard',
    color: new Color('#ff340a'),
    note:  0x11,
  }),
  new Piece({
    id: 'mts',
    name: 'mid-tom-soft',
    color: new Color('#ff4f00'),
    note:  0x12,
  }),
  new Piece({
    id: 'mth',
    name: 'mid-tom-hard',
    color: new Color('#ff580d'),
    note:  0x13,
  }),
  new Piece({
    id: 'hts',
    name: 'hi-tom-soft',
    color: new Color('#ff7c00'),
    note:  0x14,
  }),
  new Piece({
    id: 'hth',
    name: 'hi-tom-hard',
    color: new Color('#ff8008'),
    note:  0x15,
  }),
  new Piece({
    id: 'snr',
    name: 'snare-rim',
    color: new Color('#ffbf1f'),
    note:  0x22,
  }),
  new Piece({
    id: 'snc',
    name: 'snare-close',
    color: new Color('#e6ac1c'),
    note:  0x21,
  }),
  new Piece({
    id: 'sno',
    name: 'snare-open',
    color: new Color('#cc9918'),
    note:  0x20,
  }),
  new Piece({
    id: 'sns',
    name: 'snare-side',
    color: new Color('#e6b63e'),
    note:  0x23,
  }),
  new Piece({
    id: 'hh1',
    name: 'hihat-tip-1',
    color: new Color('#ffffff').darken(.6),
    note:  0x30,
  }),
  new Piece({
    id: 'hh2',
    name: 'hihat-tip-2',
    color: new Color('#ffffff').darken(.5),
    note:  0x31,
  }),
  new Piece({
    id: 'hho',
    name: 'hihat-open',
    color: new Color('#ffffff'),
    note:  0x32,
  }),
  new Piece({
    id: 'hhf',
    name: 'hihat-foot',
    color: new Color('#ffffff').darken(.25),
    note:  0x33,
  }),
  new Piece({
    id: 'rdb',
    name: 'ride-bell',
    color: new Color('#55d3ca'),
    note:  0x40,
  }),
  new Piece({
    id: 'rdt',
    name: 'ride-tip',
    color: new Color('#55d3ca').darken(.5),
    note:  0x41,
  }),
  new Piece({
    id: 'rd_',
    name: 'ride-choke',
    color: new Color('#55d3ca').darken(.07),
    note:  0x42,
  }),
  new Piece({
    id: 'sy1',
    name: 'sym-1',
    color: new Color('#ff00f3'),
    note:  0x50,
  }),
  new Piece({
    id: 's1_',
    name: 'sym-1-choke',
    color: new Color('#ff00f3').darken(.07),
    note:  0x51,
  }),
  new Piece({
    id: 'sy2',
    name: 'sym-2',
    color: new Color('#d600ff'),
    note:  0x52,
  }),
  new Piece({
    id: 's2_',
    name: 'sym-2-choke',
    color: new Color('#d600ff').darken(.07),
    note:  0x53,
  }),
  new Piece({
    id: 'cl1',
    name: 'clap-1',
    color: new Color('#bcff00'),
    note: 0x60,
  }),
  new Piece({
    id: 'wbl',
    name: 'wood-block',
    color: new Color('#be7d2f'),
    note: 0x61,
  }),
  new Piece({
    id: 'cow',
    name: 'cow-bell',
    color: new Color('#8800ff'),
    note: 0x62,
  }),
]})
