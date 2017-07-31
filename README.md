Vulnerability Indices R Shiny App

Disclaimer: R or RStudio must be installed in order to run this app.

This project can currently be run by downloading a zipped file or running a command
directly from the console of R. After downloading the zipped file, please extract
the folder to a directory that is not within the downloads folder
(i.e. move to my documents).

From zipped:
Please then open the app.r file from within the unzipped folder and without any 
R sessions open in order to obtain the correct working directory. Failure to
open from within the folder or having another r session open will fail to set 
the working directory to the folder from which the file was opened.

From the newly active R session, promptly copy and paste the following section 
of code into the console followed by pressing "Enter" to activate the pasted 
code.
```
if (!require(shiny))
  install.packages("shiny")
runApp()
```

From R:
All that is nessecary is to copy and paste the following section of code into the 
console and run it.
```
if (!require(shiny))
  install.packages("shiny")
runGitHub("jfhelgeson/BIVI")
```

Data compiled from open-source data sets from: Center for Disease Control and
Prevention, U.S. Census Bureau, Federal Communications Commission, and Bureau
of Transportation.
