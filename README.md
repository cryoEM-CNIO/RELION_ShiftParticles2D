# EM\_shift\_particles\_2D\_auto

Script for shifting particles based on 2D classification averages center of mass#####  
Rafael Fernandez Leiro - CNIO - Spain - rfleiro@cnio.es

1.  Save your classes **WITHOUT SHIFTING TO CENTER OF MASS!!!**
2.  Run the script as **external** **job** in relion providing "EM\_shift\_particles\_2D\_auto" as executable and a "particle.star" from a subset selection as particle input. Extra x/y translations are added to origin-shifts in the particle.star
3.  After running the script you should probably **re-extract** particles (with re-centering set to YES)
