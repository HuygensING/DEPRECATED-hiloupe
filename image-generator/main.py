from facsimile_paths import facsimilePaths
from image_generator import ImageGenerator


for fp in facsimilePaths:
	ImageGenerator(fp, inputBase="/home/gijs/Projects/annefrank-poc/static/images/", outputBase="/home/gijs/Projects/annefrank-poc/static/hiloupe-images/")