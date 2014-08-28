express = require 'express'
bodyParser = require 'body-parser'
_ = require 'underscore'
gm = require 'gm'
fs = require 'fs'
path = require 'path'
Generator = require './generator'

app = express()
app.use bodyParser()

SIZES = [240, 480, 720, 960]

getClosestSize = (sizes, width, height, originRatio) ->
  i = 0

  min = Math.min width, height
  while sizes[i] / originRatio < min
    i = i + 1

  sizes[i] ? sizes[sizes.length - 1]

createMatrix = (id, boxSize, width, height, partSize) ->
  console.log id, boxSize, width, height, partSize
  rows = Math.ceil(width/partSize)
  columns = Math.ceil(height/partSize)

  matrix = []
  
  for column in [0...columns]
    matrix[column] = []

    for row in [0...rows]
      x = row*partSize
      y = column*partSize

      url = "/images/generated/#{id}/#{boxSize}/#{x}-#{y}.jpg"

      matrix[column][row] = url

  matrix

app.post '/init', (req, res) ->
  {containerWidth, containerHeight, level, imgPath} = req.body

  id = path.basename(imgPath, path.extname(imgPath))

  gm("../compiled/images/facsimiles/#{imgPath}")
    .options(imageMagick: true)
    .size (err, originDim) ->
      return console.log err if err?

      generator = new Generator()
      boxSizes = generator.getSizes(originDim.width, originDim.height)
      lowestBoxSize = getClosestSize boxSizes, containerWidth, containerHeight, originDim.width/originDim.height
      lowestBoxDim = generator.boxSizeDimensions lowestBoxSize, originDim.width, originDim.height

      matrices = []

      for i in [boxSizes.indexOf(lowestBoxSize)...boxSizes.length]
        boxSize = boxSizes[i]
        boxDim = generator.boxSizeDimensions boxSize, originDim.width, originDim.height

        data =
          sources: createMatrix id, boxSize, boxDim.width, boxDim.height, generator.partSize
          width: boxDim.width
          height: boxDim.height

        matrices.push data

      res.send 
        data: matrices

app.listen 3000
console.log 'Staging server listening on 3000'