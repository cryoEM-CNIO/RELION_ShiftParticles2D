#!/bin/sh

##### Script for shifting particles manually #####

#Rafael Fernandez Leiro - CNIO - Spain - rfleiro@cnio.es

#     (+)
#      ^ 
#      |
#(+) <——> (-)
#      |
#      \/
#     (-)

echo EM_shift_particles_2D_manual.sh output.star input.star shiftX-px shiftY-px


difX=$3
difY=$4
outfile=$1
datastar=$2
mic=`grep _rlnMicrographName $datastar | awk -F"#" '{print $2}' `
coordX=`grep _rlnCoordinateX $datastar | awk -F"#" '{print $2}' `
coordY=`grep _rlnCoordinateY $datastar | awk -F"#" '{print $2}' `
oriX=`grep _rlnOriginX $datastar | awk -F"#" '{print $2}'`
oriY=`grep _rlnOriginY $datastar | awk -F"#" '{print $2}' `
psi=`grep "_rlnAnglePsi " $datastar | awk -F"#" '{print $2}' `
numberOFfield=`grep _rln -n bla.star | awk -F":" 'END{print $1+1}'`
pxsize=`relion_star_printtable $datastar data_optics _rlnImagePixelSize`

echo "all set..."

#PARTICLE RECENTERING
#offsetX+((displacementX*-cos)-(displacementY*sin) --> component X from moving the particle in X + component X from moving the particle in Y 
#offsetY+((displacementX*sin)-(displacementY*cos)--> component Y from moving the particle in X + component Y from moving the particle in Y

echo "shifting..."

awk -vlinenum=$numberOFfield 'NR<linenum{print}' $datastar | sed ':a;/^[ \n]*$/{$d;N;ba}' | grep -v '_rlnOriginX\|_rlnOriginY' | tr ' ' '@' | tr '\n' '?' | awk '{print $1"_rlnOriginX@?_rlnOriginY@"}' | tr '?' '\n' | tr '@' ' ' > header.tmp

awk -v oX=$oriX -v oY=$oriY -vlinenum=$numberOFfield 'NR>linenum-1{$oX=$oY="";print}' $datastar > data.tmp

grep mrc $datastar | awk -voX=$oriX -voY=$oriY -vpsi=$psi -vdifX=$difX -vdifY=$difY -vpxsize=$pxsize '{print $0,(($oX+(((difX*pxsize)*(-cos(($psi)*(3.141592/180))))-((difY*pxsize)*(sin(($psi)*(3.141592/180))))))),(($oY+(((difX*pxsize)*(sin(($psi)*(3.141592/180))))-((difY*pxsize)*(cos(($psi)*(3.141592/180)))))))}' > offsets.tmp

paste data.tmp offsets.tmp > all.tmp 
cat header.tmp all.tmp > $outfile

echo "done"

rm -rf *tmp

echo "all done"