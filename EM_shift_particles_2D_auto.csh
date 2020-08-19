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
  echo "Usage: EM_shift_particles_2D_auto.csh selec_job_folder pixelsize"
  echo "Usage: EM_shift_particles_2D_auto.csh Select/jobXXX 1.45"
  exit
endif

if ("$2" == "") then
  echo "Usage: EM_shift_particles_2D_auto.csh selec_job_folder pixelsize"
  echo "Usage: EM_shift_particles_2D_auto.csh Select/jobXXX 1.45"
  exit
endif

#Variables
set classstar=$1"/class_averages.star"
set datastar=$1"/particles.star"
set outfile=$1"/particles_shifted.star"
set pxsize=$2

set out1=$1"/class.tmp"
set out2=$1"/shifts1.tmp"
set out3=$1"/shifts2.tmp"
set out4=$1"/shifts3.tmp"
set out5=$1"/header.tmp"
set out6=$1"/data.tmp"
set out7=$1"/data_lap.tmp"
set out8=$1"/data_shifted.tmp"


set classdata=`grep _rlnClassNumber $datastar | awk -F"#" '{print $2}' `
set classclass=`grep _rlnClassNumber $classstar | awk -F"#" '{print $2}' `
set refimage=`grep _rlnReferenceImage $classstar | awk -F"#" '{print $2}' `
set mic=`grep _rlnMicrographName $datastar | awk -F"#" '{print $2}' `
set coordX=`grep _rlnCoordinateX $datastar | awk -F"#" '{print $2}' `
set coordY=`grep _rlnCoordinateY $datastar | awk -F"#" '{print $2}' `
set oriX=`grep _rlnOriginXAngst $datastar | awk -F"#" '{print $2}'`
set oriY=`grep _rlnOriginYAngst $datastar | awk -F"#" '{print $2}' `
set psi=`grep "_rlnAnglePsi " $datastar | awk -F"#" '{print $2}' `
set numberOFfield=`grep _rln $datastar | wc -l`

#GETTING SHIFTS
sed 's#ReferenceImage#ImageName#' $classstar > $out1 | relion_image_handler --i $out1 --o tmp --shift_com | grep Center | awk -F":" '{print $2}' | awk '{print $2, $4}' > $out2
grep mrcs $classstar | awk '{print $1, $10}' > $out3
paste $out3 $out2 > $out4

#PARTICLE RECENTERING
#offsetX+((displacementX*-cos)-(displacementY*sin) --> component X from moving the particle in X + component X from moving the particle in Y 
#offsetY+((displacementX*sin)-(displacementY*cos)--> component Y from moving the particle in X + component Y from moving the particle in Y

awk 'NF<15{print}' $datastar | sed ':a;/^[ \n]*$/{$d;N;ba}' | grep -v '_rlnOriginXAngst\|_rlnOriginYAngst' | tr ' ' '@' | tr '\n' '?' | awk '{print $1"_rlnOriginXAngst@?_rlnOriginYAngst@"}' | tr '?' '\n' | tr '@' ' ' > $out5
grep mrc $datastar | awk 'NF>15{print $0}' > $out6

for line in $out4; do
  set difX=`awk '{print $3}'`
  set difY=`awk '{print $4}'`
  set classn=`awk '{print $2}'`
  awk -v cln=$classn -v clf=$classdata '{if($classdata==cln) print}' $out6 | awk -v oX=$oriX -v oY=$oriY -v psi=$psi -v difX=$difX -v difY=$difY -v pxsize=$pxsize '{print (($oX+(((difX*pxsize)*(-cos(($psi)*(3.141592/180))))-((difY*pxsize)*(sin(($psi)*(3.141592/180))))))),(($oY+(((difX*pxsize)*(sin(($psi)*(3.141592/180))))-((difY*pxsize)*(cos(($psi)*(3.141592/180)))))))}' >> $out7
done

awk -v oX=$oriX -v oY=$oriY 'NF>15{$oX=$oY="";print}' $out7 > $out8 
cat $out5 $out8 > $outfile

#rm -f *.tmp

