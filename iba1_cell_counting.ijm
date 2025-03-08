// Iba1+ Cell Counting Macro
//
// Define image analysis function, 'iba1_counts'

function cell_counts(
	input, output1, output2, output3, output4, output5, filename
	) {

	// Open and duplicate image
	open(input + filename);

	// Separate the Iba1 stain from the hematoxylin stain
	run("Colour Deconvolution2", "vectors=[H DAB] output=8bit_Transmittance simulated cross hide");
	
	// Close the original image
	selectImage(filename);
	close(filename);
	
	// Close the blank image
	selectImage(filename + "-(Colour_3)");
	close(filename + "-(Colour_3)");
	
	// Process the hemotoxylin image and save in "02-hema-thresholds"
	selectWindow(filename + "-(Colour_1)");
	run("Bandpass Filter...", "filter_large=40 filter_small=3 suppress=None tolerance=5 autoscale saturate");
	run("Unsharp Mask...", "radius=3 mask=0.60");
	run("Despeckle");
	setAutoThreshold("Default no-reset");
	setOption("BlackBackground", true);
	run("Convert to Mask");
	run("Despeckle");
	run("Remove Outliers...", "radius=9 threshold=50 which=Bright");
	saveAs("Tiff", output2 + getTitle());
	
	// Count hematoxylin cells and save the ROIs in "03-hema-counts"
	run("Set Measurements...", "  redirect=None decimal=3");
	run("Analyze Particles...", "summarize add");
	roiManager("Save", output3 + filename + ".zip");
	
	// Close Hematoxylin Image
	close(filename + "-(Colour_1)");
	
	// Clear the ROI manager
	roiManager("Delete");
	
	// Process iba1 image for counting and save in "04-iba1-thresholds"
	selectWindow(filename + "-(Colour_2)");
	run("Bandpass Filter...", "filter_large=40 filter_small=3 suppress=None tolerance=5 autoscale saturate");
	run("Unsharp Mask...", "radius=3 mask=0.60");
	run("Despeckle");
	setAutoThreshold("Default no-reset");
	setOption("BlackBackground", true);
	run("Convert to Mask");
	run("Despeckle");
	run("Remove Outliers...", "radius=9 threshold=50 which=Bright");
	saveAs("Tiff", output4 + getTitle());
	
	// Count iba1 cells and save the ROIs in "05-iba1-counts"
	run("Set Measurements...", "  redirect=None decimal=3");
	run("Analyze Particles...", "summarize add");
	roiManager("Save", output5 + filename + ".zip");
	
	// Close iba1 image
	close(filename + "-(Colour_2)");
	
	// Clear the ROI manager
	roiManager("Delete");
}

// Get filepath to desired folder
input = getDirectory("Choose a Directory");
if (input=="")
	exit("Not a valid directory");

// Create output folders
output1 = input + "01-data" + File.separator;
File.makeDirectory(output1);
output2 = input + "02-hema-thresholds" + File.separator;
File.makeDirectory(output2);
output3 = input + "03-hema-counts" + File.separator;
File.makeDirectory(output3);
output4 = input + "04-iba1-thresholds" + File.separator;
File.makeDirectory(output4);
output5 = input + "05-iba1-counts" + File.separator;
File.makeDirectory(output5);

// Iterate 'cell_counts' through all images in the folder
setBatchMode(true);
count = 0;
list = getFileList(input);
for (i = 0; i < list.length; i++){
		if (endsWith(list[i], ".tif")) {
			cell_counts(
				input, output1, output2, output3, output4, output5, list[i]
				);
			count++;
		}
}

// Save the counts data and let the user know the macro is finished
selectWindow("Summary");
run("Input/Output...", "jpeg=85 gif=-1 file=.csv use_file save_column");
saveAs("Results", output1 + "cell-counts.csv");
print(count + " images processed");
print("The cell counts are located in " + output1);
print("The hematoxylin thresholds are located in " + output2);
print("The hematoxylin ROIs are located in " + output3);
print("The iba1 thresholds located in " + output4);
print("The iba1 ROIs located in " + output5);
setBatchMode(false);
