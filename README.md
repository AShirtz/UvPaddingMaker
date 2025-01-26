This package applies the "UV Padding" or "UV Margins" effect to the specified texture.
These scripts and shaders have been tested on URP and BRP 2022.3.*, but should work elsewhere as well.
I've included the UvPaddingMaker.unitypackage file in this repo, so you can manually download that if that's easier.

If you are receiving errors or strange results, check the import settings on the input texture, see step 1.a below.


The general process is as follows:

1. Specify the texture to pad
	a. This texture needs to be un-compressed, not sRGB, and not have any mips	
	b. IDK how to enforce this in the script without just listing TextureFormats, sorry...
2. Specify an "inter-island" color
	a. This is whatever color is between the UV islands
	b. I.e., "The color of pixels that will be overwritten."
3. Specify an "inter-island" threshold
	a. Comparing colors ain't exact (afaik), so this is the distance threshold used.
4. Specify the output
	a. In the 'Asset Path' field, write the path where you want the file to be written.
	b. This should start with the "Assets" folder, then wherever you want from there
	c. This will include the filename you want it to save under.
	d. If the "Save To Png" bool is checked, the file extension should be ".png"; otherwise, it should be ".asset"
5. Click "Create Padded Texture"
	a. Watch for any errors and check output.
