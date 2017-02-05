# BacteriaPlot
Plotting software for Rentzepis Lab bacteria data

## Installation:
1. Go to the releases tab
2. Download the latest release and run the *setup.exe
3. The setup will automatically download the MATLAB Compiler Runtime (about ~700 MB).

## File Naming:

###For files labeled according to irradiation time:
 <pre><b>x</b>min_<b>s</b>.txt</pre>
  where
  
  a. **x**: a number between 0 and 100 in intervals of 0.5
  
  b. **s**: a number between 1 and 5. This is selected by the "set" control on the GUI.
          If the current experiment has one data set, *s* won't be used.
          
  **Example**: `0.5min_1.txt`,`62min.txt`
  
###For files labeled according to concentration:
 <pre><b>x</b>ngperml_<b>s</b>.txt</pre>
  where
  
  a. **x**: a number between 1 and 1000 in intervals of 1
  
  b. **s**: a number between 1 and 5. This is selected by the "set" control on the GUI.
          If the current experiment has one data set, *s* won't be used.
          
  **Example**: `1ngperml_1.txt`,`50ngperml.txt`
  
  ## Operation:
 
  1. Put all your files from the data set under investigation in one folder.
  
  2. Click the select folder button and select the folder with all the files.
  
  3. Set "start lambda" and "end lambda", i.e. the averaging window.
  
  4. Set "avg. window". This is the number of points left and right of the peak in which the program looks for points to average over.
  
  5. Set "avg. points". This is the number of points used for averaging. *N* points closest to the fit are picking for averaging.
  
  6. Click the run button.
  
  7. The left plot shows peak intensity vs 'X' (Irradiation time or concentration).
  
  8. The right plot shows the individual fits of each experiment. Pressing previous or next switches between experiments.
  
  9. The table shows X, average peak, and Gaussian peak. Select the data, press Ctrl+C and then paste it directly into excel.
  
  10. Click the "Export Data" button to save the data in *.csv, *.mat or *.txt format. The file looks as follows:
  
  ```
  0  v1  v2  v3  v4  ...
  l1 I11 I12 I13 I14 ...
  l2 I21 I22 I23 I24 ...
  l3 I31 I32 I33 I34 ...
  l4 I41 I42 I43 I44 ...
  .   .   .   .   .  ...
  .   .   .   .   .  ...
  .   .   .   .   .  ...
  ```
  
  where the first column represents the wavelengths, the second column the first experiment (with `v1` its concentration or irrad. time), etc.
  
  11. Enter values into the text boxes below each plot to adjust the x-axis limits. Click the update button to update the plot with the new limits. If you want automatic limits (i.e. default), enter `a` or `auto` into either of the boxes.
  
  12. Use the toolbar buttons to interact with the plots: zoom in and out, pan and rotate (in casse 3D plots are added in the future).
  
  13. Click the **U** button next to either plot to "undock" it. This pops out the figure allowing for saving. Editing in this mode will be added soon.
  
  
