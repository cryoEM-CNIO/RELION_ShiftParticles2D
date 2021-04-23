# EM\_shift\_particles\_2D\_auto

_Rafael Fernandez Leiro - CNIO - Spain - rfleiro@cnio.es_

Script for shifting particles to the center box after 2D classification. Per-2D-Class shifts are calculated based on the center of mass of 2D average images.

1.  Put the script in your scripts directory or add its location to your PATH
2.  Save your classes **WITHOUT SHIFTING TO CENTER OF MASS!!!**
3.  Run the script as an **external** **job** in relion providing "EM\_shift\_particles\_2D\_auto.sh" as executable and a "particle.star" from a subset selection as particle input. Extra x/y translations are added to origin-shifts in the particle.star
4.  After running the script you should probably **re-extract** particles (with re-centering set to YES)
