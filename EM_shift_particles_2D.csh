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
  echo "Usage: EM_shift_particles_2D.csh output.star input.star pixel-ofset-X pixel-ofset-Y angpix"
  echo "Example: EM_shift_particles_2D.csh particles.star particles_center.star 20 10 2.567"
  exit
endif

if ("$2" == "") then
  echo "Usage: EM_shift_particles_2D.csh output.star input.star pixel-ofset-X pixel-ofset-Y angpix"
  echo "Example: EM_shift_particles_2D.csh particles.star particles_center.star 20 10 2.567"
  exit
endif

if ("$3" == "") then
  echo "Usage: EM_shift_particles_2D.csh output.star input.star pixel-ofset-X pixel-ofset-Y angpix"
  echo "Example: EM_shift_particles_2D.csh particles.star particles_center.star 20 10 2.567"
  exit
else
  set difX=$3
endif

if ("$4" == "") then
  echo "Usage: EM_shift_particles_2D.csh output.star input.star pixel-ofset-X pixel-ofset-Y angpix"
  echo "Example: EM_shift_particles_2D.csh particles.star particles_center.star 20 10 2.567"
  exit
else
  set difY=$4
endif

if ("$5" == "") then
  echo "Usage: EM_shift_particles_2D.csh output.star input.star pixel-ofset-X pixel-ofset-Y angpix"
  echo "Example: EM_shift_particles_2D.csh particles.star particles_center.star 20 10 2.567"
  exit
else
  set pxsize=$5
endif

#Variables
set outfile=$1
set datastar=$2
set mic=`grep _rlnMicrographName $datastar | awk -F"#" '{print $2}' `
set coordX=`grep _rlnCoordinateX $datastar | awk -F"#" '{print $2}' `
set coordY=`grep _rlnCoordinateY $datastar | awk -F"#" '{print $2}' `
set oriX=`grep _rlnOriginXAngst $datastar | awk -F"#" '{print $2}'`
set oriY=`grep _rlnOriginYAngst $datastar | awk -F"#" '{print $2}' `
set psi=`grep "_rlnAnglePsi " $datastar | awk -F"#" '{print $2}' `
set numberOFfield=`grep _rln $datastar | wc -l`

#PARTICLE RECENTERING
#offsetX+((displacementX*-cos)-(displacementY*sin) --> component X from moving the particle in X + component X from moving the particle in Y 
#offsetY+((displacementX*sin)-(displacementY*cos)--> component Y from moving the particle in X + component Y from moving the particle in Y

awk 'NF<15{print}' $datastar | sed ':a;/^[ \n]*$/{$d;N;ba}' | grep -v '_rlnOriginXAngst\|_rlnOriginYAngst' | tr ' ' '@' | tr '\n' '?' | awk '{print $1"_rlnOriginXAngst@?_rlnOriginYAngst@"}' | tr '?' '\n' | tr '@' ' ' > header.tmp

grep mrc $datastar | awk -v oX=$oriX -v oY=$oriY 'NF>15{$oX=$oY="";print}' > data.tmp

grep mrc $datastar | awk -v oX=$oriX -v oY=$oriY -v psi=$psi -v difX=$difX -v difY=$difY v pxsize=$pxsize '{print (($oX+(((difX*pxsize)*(-cos(($psi)*(3.141592/180))))-((difY*pxsize)*(sin(($psi)*(3.141592/180))))))),(($oY+(((difX*pxsize)*(sin(($psi)*(3.141592/180))))-((difY*pxsize)*(cos(($psi)*(3.141592/180)))))))}' > offsets.tmp

paste data.tmp offsets.tmp > all.tmp 
cat header.tmp all.tmp > $outfile

rm -f *.tmp

