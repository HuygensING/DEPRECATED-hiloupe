from PIL import Image
from operator import itemgetter
import sys, os, time, numpy, json

class ImageGenerator(object):
	""" Generate image parts for the Hiloupe zoom tool
	
	Attributes:
		inputFile: the base file to cut up in parts. Can have a dir.
		inputBase: the base dir for the input file. inputBase + inputFile = input image path.
		outputBase: the base dir for the output file. outputBase + inputFile = output image path.
		partSize: the size (lxb) of the image parts.
	"""

	def __init__(self, inputFile, inputBase='', outputBase='generated', partSize=240):

		self.partSize = partSize

		# Add a slash to inputBase if it isn't given.
		if inputBase[-1] != '/':
			inputBase = inputBase + '/'

		# Add a slash to outputBase if it isn't given.
		if outputBase[-1] != '/':
			outputBase = outputBase + '/'

		def imageLoaded():
			start = time.time()

			# Set the output file path and create it if necessary.
			self.baseDir = outputBase+inputFile+"/"
			if not os.path.exists(self.baseDir):
				os.makedirs(self.baseDir)

			print self.baseDir

			baseImages = self.generateBaseImages()

			self.generateCroppedImages(baseImages)

			self.generateMetadata(baseImages)

			print(time.time() - start)

		# Open the image.
		try:
			self.im = Image.open(inputBase + inputFile)
			imageLoaded()
		except IOError:
			print "Image not found: "+inputFile

	def getBoxSizes(self):
		i = 0
		boxSizes = []
		originalBoxSize = max(self.im.size)

		def nextBoxSize():
			boxSize = (self.partSize*i*i) + self.partSize
			boxSizes.append(boxSize)
			return boxSize

		while nextBoxSize() < originalBoxSize:
			i += 1

		boxSizes = boxSizes[:-2]
		boxSizes.append(originalBoxSize)

		return boxSizes

	def generateBaseImages(self):
		baseImages = {}
		for boxSize in self.getBoxSizes():
			size = boxSize, boxSize
			tmp = self.im.copy()
			tmp.thumbnail(size)
			baseImages[boxSize] = tmp

		return baseImages

	def generateCroppedImages(self, baseImages):
		for boxSize, baseImg in baseImages.items():
			boxDir = self.baseDir+str(boxSize)
			if not os.path.exists(boxDir):
				os.makedirs(boxDir)

			columns = xrange(0, baseImg.size[0], self.partSize)
			rows = xrange(0, baseImg.size[1], self.partSize)

			for columnIndex, column in enumerate(columns):
				for rowIndex, row in enumerate(rows):
					box = (column, row, column+self.partSize, row+self.partSize)
					region = baseImg.crop(box)
					region.save(self.baseDir+str(boxSize)+"/"+str(column)+"-"+str(row)+".jpg")

			print("DONE: "+str(boxSize))

	def generateMetadata(self, baseImages):
		metadata = {}
		metadata['partSize'] = self.partSize
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

		jsonFile = open(self.baseDir+"metadata.json", "w")
		jsonFile.write(json.dumps(metadata))
		jsonFile.close()