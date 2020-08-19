#EM_shift_particles_2D_auto

Script for shifting particles based on 2D classification averages center of mass#####
Rafael Fernandez Leiro - CNIO - Spain - rfleiro@cnio.es

     (+)
      ^ 
      |
(+) <——> (-)
      |
      \/
     (-)

First save your classes WITHOUT SHIFTING TO CENTER OF MASS!!! then run the script as external job in relion providing "EM_shift_particles_2D_auto" as executable and a "particle.star" from a subset selection as particle input
Extra x/y translations are added to origing shifts in the particle.star
After running the script you should probably re-extract particles (with re-centering set to YES)