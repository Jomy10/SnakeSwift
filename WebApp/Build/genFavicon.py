from PIL import Image

filename = r'Build/AppIcon.png'
img = Image.open(filename)
img.save('../public/favicon.ico')

