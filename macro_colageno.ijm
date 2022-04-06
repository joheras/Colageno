batchMode=true;
outputFolder="_Output";

setBatchMode(batchMode);
directory = getDirectory("Choose folder with the images"); 
dirParent = File.getParent(directory);
dirName = File.getName(directory);
dirOutput = dirParent+File.separator+dirName+outputFolder;
if (File.exists(dirOutput)==false) {
  	File.makeDirectory(dirOutput); // new output folder
}
files=getFileList(directory);


for (i=0; i<files.length; i++) {

	if(endsWith(files[i],"fluo.tif"))
	{
		print(files[i]);
		open(directory+File.separator+files[i]);
		title1=getTitle();
		run("8-bit");

		open(directory+File.separator+files[i].replace("fluo.tif",".tif"));
		title2=getTitle();
		
		run("Duplicate...", " ");
		rename("dup_"+title2);
		selectWindow("dup_"+title2);
		run("8-bit");

		imageCalculator("Subtract create", "dup_"+title2,title1);
		selectWindow("Result of "+"dup_"+title2);
		run("Duplicate...", " ");
		rename("dup_"+"Result of "+"dup_"+title2);
		
		setAutoThreshold("Default no-reset");
		setOption("BlackBackground", false);
		run("Convert to Mask");

		run("Analyze Particles...", "size=0.1-Infinity exclude add");

		n = roiManager('count');

		if(n==0){
			selectWindow("Result of "+"dup_"+title2);

			setAutoThreshold("Li no-reset");
			setOption("BlackBackground", false);
			run("Convert to Mask");
	
			run("Analyze Particles...", "size=0.1-Infinity exclude add");
			selectWindow("Result of "+"dup_"+title2);
			close();
		}

		roiManager("Select", 0);
		roiManager("Rename", "all");
		

		selectWindow("dup_"+"Result of "+"dup_"+title2);
		close();
		selectWindow(title1);
		close();
		selectWindow("dup_"+title2);
		close();
		
		selectWindow(title2);
		run("Duplicate...", " ");
		rename("dup_"+title2);
		selectWindow("dup_"+title2);
		
		run("8-bit");
		run("Enhance Contrast...", "saturated=0.3");
		setAutoThreshold("Default no-reset");
		setOption("BlackBackground", false);
		run("Convert to Mask");
		run("Dilate");
		run("Fill Holes");
		//run("Erode");
		run("Analyze Particles...", "size=0.1-Infinity exclude add");
		selectWindow("dup_"+title2);
		close();
		roiManager("Deselect");




		selectWindow(title2);
		run("Duplicate...", " ");
		rename("dup_"+title2);
		selectWindow("dup_"+title2);
		roiManager("Select", 0);
		run("Enlarge...", "enlarge=100 pixel");
		roiManager("Add");

		n = roiManager('count');
		roiManager("Select", newArray(0,n-1));
		roiManager("XOR");
		run("Find Maxima...", "prominence=15 strict light output=[Point Selection]");
		roiManager("Deselect");
		roiManager("Add");
		
		
		n = roiManager('count');
		roiManager("Select", n-2);
		roiManager("Delete");
		
		n = roiManager('count');
		roiManager("Select", n-1);
		roiManager("Rename", "points");

		
		roiManager("Select", 0);
		setForegroundColor(0, 0, 255);
		roiManager("Draw");
		n = roiManager('count');
		if(n==3){
			roiManager("Select", 1);
			roiManager("Rename", "center");
			setForegroundColor(255, 0, 0);
			roiManager("Draw");
			
		}
		
		roiManager("Select", n-1);
		setForegroundColor(0, 255, 0);
		roiManager("Draw");
		
		saveAs("Tiff",dirOutput+File.separator+title2);
		roiManager("Save", dirOutput+File.separator+title2+".zip");

		
		
		
		roiManager("reset");
		close();

		
		
	}
}

print("Done!");