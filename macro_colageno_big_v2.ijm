batchMode=true;
outputFolder="_Output";
errorFolder="_Error";

setBatchMode(batchMode);
directory = getDirectory("Choose folder with the images"); 
dirParent = File.getParent(directory);
dirName = File.getName(directory);
dirOutput = dirParent+File.separator+dirName+outputFolder;
dirError = dirParent+File.separator+dirName+errorFolder;
if (File.exists(dirOutput)==false) {
  	File.makeDirectory(dirOutput); // new output folder
}
if (File.exists(dirError)==false) {
  	File.makeDirectory(dirError); // new output folder
}


files=getFileList(directory);



function detectMainPart(title2,method){
	selectWindow(title2);
	run("Duplicate...", " ");
	rename("dup_"+title2);
	run("8-bit");

	
	//run("Sharpen");
	run("Variance...", "radius=5");
	setAutoThreshold(method+" dark no-reset");
	setOption("BlackBackground", false);
	run("Convert to Mask");
	//run("Dilate");
	run("Fill Holes");
	//run("Erode");



	if(endsWith(files[i],"fluo.tif")){
		run("Analyze Particles...", "size=5-Infinity circularity=0.05-1.00 exclude add");
	}else{
		run("Analyze Particles...", "size=50000-Infinity circularity=0.05-1.00 exclude add");
	}
		
	
	
	close();
	
}


function detectCenter(title2){
	selectWindow(title2);

	run("Duplicate...", " ");
	rename("dup_"+title2);
	run("8-bit");
	roiManager("Select", 0);
	setAutoThreshold("Huang no-reset");
	run("Convert to Mask");
	roiManager("Select", 0);
	run("Clear Outside");
	if(endsWith(files[i],"fluo.tif")){
		run("Analyze Particles...", "size=1-Infinity circularity=0.00-1.00 add");
	}else{
		run("Analyze Particles...", "size=10000-Infinity circularity=0.00-1.00 add");
	}

	close();	

}




for (i=0; i<files.length; i++) {

	if((endsWith(files[i],"fluo.tif")) || (endsWith(files[i],"fluo.png")))
	{

		if(endsWith(files[i],"fluo.tif")){
			open(directory+File.separator+files[i].replace("fluo.tif",".tif"));
		
		}else{
			open(directory+File.separator+files[i].replace("fluo.png",".png"));
		}

		print(files[i]);
		title2=getTitle();
		detectMainPart(title2,"Otsu");
		n = roiManager('count');
		if(n==0){
			detectMainPart(title2,"Minimum");
		}
		n = roiManager('count');
		if(n==0){
			detectMainPart(title2,"MaxEntropy");
		}
		
		
		n = roiManager('count');
		if(n>0){
			
			detectCenter(title2);
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
		}else{
			selectWindow(title2);
			saveAs("Tiff",dirError+File.separator+title2);

			print("error");
		}
		close();



	}

}





print("Done!");