# EM\_shift\_particles\_2D\_auto

Script for shifting particles based on 2D classification averages center of mass#####  
Rafael Fernandez Leiro - CNIO - Spain - rfleiro@cnio.es

1.  Put the script in your scripts directory or add its location to your PATH
2.  Save your classes **WITHOUT SHIFTING TO CENTER OF MASS!!!**
3.  Run the script as **external** **job** in relion providing "EM\_shift\_particles\_2D\_auto" as executable and a "particle.star" from a subset selection as particle input. Extra x/y translations are added to origin-shifts in the particle.star
4.  After running the script you should probably **re-extract** particles (with re-centering set to YES)
