#!/bin/tcsh

##### Script for shifting particles based on 2D classification averages#####

#Rafael Fernandez Leiro - CNIO - Spain - rfleiro@cnio.es

#Measure the shift in X and Y using the "show original image" option when displaying run_model.star from a 2D classification
#To measure the shift drag with middle mouse button
#Repeat this for every class that you want to shift and save a selection of the particles from every class independently as they have different shifts...

#     (+)
#      ^ 
#      |
#(+) <——> (-)
#      |
#      \/
#     (-)


if ("$1" == "") then
  echo "Usage: EM_shift_particles_2D.csh output.star input.star pixel-ofset-X pixel-ofset-Y"
  echo "Example: EM_shift_particles_2D.csh output.star particles_from_2D.star 20 10"
  exit
endif

if ("$2" == "") then
  echo "Usage: EM_shift_particles_2D.csh output.star input.star pixel-ofset-X pixel-ofset-Y"
  echo "Example: EM_shift_particles_2D.csh particles.star particles_center.star 20 10"
  exit
endif

if ("$3" == "") then
  echo "Usage: EM_shift_particles_2D.csh output.star input.star pixel-ofset-X pixel-ofset-Y"
  echo "Example: EM_shift_particles_2D.csh particles.star particles_center.star 20 10"
  exit
else
  set difX=$3
endif

if ("$4" == "") then
  echo "Usage: EM_shift_particles_2D.csh output.star input.star pixel-ofset-X pixel-ofset-Y"
  echo "Example: EM_shift_particles_2D.csh particles.star particles_center.star 20 10"
  exit
else
  set difY=$4
endif

#Variables
set outfile=$1
set datastar=$2
set mic=`grep _rlnMicrographName $datastar | awk -F"#" '{print $2}' `
set coordX=`grep _rlnCoordinateX $datastar | awk -F"#" '{print $2}' `
set coordY=`grep _rlnCoordinateY $datastar | awk -F"#" '{print $2}' `
set oriX=`grep _rlnOriginX $datastar | awk -F"#" '{print $2}'`
set oriY=`grep _rlnOriginY $datastar | awk -F"#" '{print $2}' `
set psi=`grep "_rlnAnglePsi " $datastar | awk -F"#" '{print $2}' `
set numberOFfield=`grep _rln $datastar | wc -l`

#PARTICLE RECENTERING
#offsetX+((displacementX*-cos)-(displacementY*sin) --> component X from moving the particle in X + component X from moving the particle in Y 
#offsetY+((displacementX*sin)-(displacementY*cos)--> component Y from moving the particle in X + component Y from moving the particle in Y

awk 'NF<3{print}' $datastar | sed ':a;/^[ \n]*$/{$d;N;ba}' | grep -v '_rlnOriginX\|_rlnOriginY' | tr ' ' '@' | tr '\n' '?' | awk '{print $1"_rlnOriginX@?_rlnOriginY@"}' | tr '?' '\n' | tr '@' ' ' > header.rfltmp

grep mrc $datastar | awk -v oX=$oriX -v oY=$oriY 'NF>3{$oX=$oY="";print}' > data.rfltmp

grep mrc $datastar | awk -v oX=$oriX -v oY=$oriY -v psi=$psi -v difX=$difX -v difY=$difY '{print (($oX+(((difX)*(-cos(($psi)*(3.141592/180))))-((difY)*(sin(($psi)*(3.141592/180))))))),(($oY+(((difX)*(sin(($psi)*(3.141592/180))))-((difY)*(cos(($psi)*(3.141592/180)))))))}' > offsets.rfltmp

paste data.rfltmp offsets.rfltmp > all.rfltmp 
cat header.rfltmp all.rfltmp > $outfile

rm -f *.rfltmp

