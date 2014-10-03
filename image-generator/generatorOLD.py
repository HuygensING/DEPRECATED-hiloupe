from PIL import Image
from operator import itemgetter
import sys, os, time, numpy, json

start = time.time()

inputFile = "SK-C-5.jpg"
im = Image.open(inputFile)

baseDir = "generated/"+inputFile+"/"
if not os.path.exists(baseDir):
	os.makedirs(baseDir)

partSize = 240

def getBoxSizes():
	i = 0
	boxSizes = []
	originalBoxSize = max(im.size)

	def nextBoxSize():
		boxSize = (partSize*i*i) + partSize
		boxSizes.append(boxSize)
		return boxSize

	while nextBoxSize() < originalBoxSize:
		i += 1

	boxSizes = boxSizes[:-2]
	boxSizes.append(originalBoxSize)

	return boxSizes

def generateBaseImages():
	baseImages = {}
	for boxSize in getBoxSizes():
		size = boxSize, boxSize
		tmp = im.copy()
		tmp.thumbnail(size)
		baseImages[boxSize] = tmp

	return baseImages

def generateCroppedImages(baseImages):
	for boxSize, baseImg in baseImages.items():
		boxDir = baseDir+str(boxSize)
		if not os.path.exists(boxDir):
			os.makedirs(boxDir)

		columns = xrange(0, baseImg.size[0], partSize)
		rows = xrange(0, baseImg.size[1], partSize)

		for columnIndex, column in enumerate(columns):
			for rowIndex, row in enumerate(rows):
				box = (column, row, column+partSize, row+partSize)
				region = baseImg.crop(box)
				region.save(baseDir+str(boxSize)+"/"+str(column)+"-"+str(row)+".jpg")

		print("DONE: "+str(boxSize))

def generateMetadata(baseImages):
	metadata = {}
	metadata['partSize'] = partSize
	metadata['levels'] = []

	for boxSize, baseImg in baseImages.items():
		data = {}
		data['width'] = baseImg.size[0]
		data['height'] = baseImg.size[1]

		metadata['levels'].append(data)

	# Set orientation to landscape or portrait.
	# metadata['orientation'] = 'landscape' if data['width'] > data['height'] else 'portrait'

	# Levels are created from (unsorted) dict, so it is sorted by width here,
	# so the index equals the level.
	metadata['levels'] = sorted(metadata['levels'], key=itemgetter('width'))

	jsonFile = open(baseDir+"metadata.json", "w")
	jsonFile.write(json.dumps(metadata))
	jsonFile.close()

baseImages = generateBaseImages()

generateCroppedImages(baseImages)

generateMetadata(baseImages)

print(time.time() - start)