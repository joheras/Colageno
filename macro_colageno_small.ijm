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
	if((endsWith(files[i],"fluo.tif")) || (endsWith(files[i],"fluo.png")))
	{

		if(endsWith(files[i],"fluo.tif")){
			open(directory+File.separator+files[i].replace("fluo.tif",".tif"));
		
		}else{
			open(directory+File.separator+files[i].replace("fluo.png",".png"));
		}
		title2=getTitle();
		print(files[i]);
		open(directory+File.separator+files[i]);
		title1=getTitle();
		run("8-bit");

		run("Median...", "radius=5");
		run("Maximum...", "radius=5");
		//run("Variance...", "radius=5");
		run("Find Edges");
		setAutoThreshold("MinError dark no-reset");
		setOption("BlackBackground", false);
		run("Convert to Mask");
		run("Erode"); //v2
		run("Dilate"); //v2		
		run("Dilate");
		run("Fill Holes");
		run("Erode");
		run("Erode");

		if(endsWith(files[i],"fluo.tif")){
			run("Analyze Particles...", "size=2-Infinity exclude add");
		}else{
			run("Analyze Particles...", "size=20000-Infinity exclude add");
		}
		
		close();
		selectWindow(title2);



		
		n = roiManager('count');
		if(n>0){
			
			
			run("Duplicate...", " ");
			rename("dup_"+title2);
			run("8-bit");
			roiManager("Select", 0);
			setAutoThreshold("Huang no-reset");
			run("Convert to Mask");
			roiManager("Select", 0);
			run("Clear Outside");
			if(endsWith(files[i],"fluo.tif")){
				run("Analyze Particles...", "size=1-Infinity circularity=0.00-1.00 exclude add");
			}else{
				run("Analyze Particles...", "size=10000-Infinity circularity=0.00-1.00 exclude add");
			}

			close();
			selectWindow(title2);








			n = roiManager('count');
			roiManager("Select", 0);
			roiManager("Rename", "all");
			setForegroundColor(0, 0, 255);
			roiManager("Draw");
			if(n>1){
				roiManager("Select", 1);
				roiManager("Rename", "centre");
				setForegroundColor(0, 255, 0);
				roiManager("Draw");
			}

			saveAs("Tiff",dirOutput+File.separator+title2);
			roiManager("Save", dirOutput+File.separator+title2+".zip");
			roiManager("reset");



	}

}
}
print("Done!");