# from facsimile_paths import facsimilePaths
from image_generator import ImageGenerator
from glob import glob
import getopt, sys, os

try:
	opts, args = getopt.getopt(sys.argv[1:], "hi:o:")
except getopt.GetoptError:
	print('hiloupe-generate.py -i <inputdir> -o <outputdir>')
	sys.exit(2)

inputDir = None
outputDir = None
for opt, arg in opts:
	if opt == '-h':
		print('hiloupe-generate.py -i <inputdir> -o <outputdir>')
		sys.exit()
	elif opt == '-i':
		inputDir = os.path.abspath(arg)
	elif opt == '-o':
		outputDir = os.path.abspath(arg)
		
if inputDir is None:
	print("Please specify an input dir!")

if outputDir is None:
	print("Please specify an output dir!")

if inputDir == None or outputDir == None:
	sys.exit()

for imgPath in glob(inputDir+'/*.jpg'):
	ImageGenerator(imgPath, outputDir=outputDir)

