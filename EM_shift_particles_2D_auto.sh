#!/bin/sh

##### Script for shifting particles based on 2D classification averages center of mass#####

#Rafael Fernandez Leiro - CNIO - Spain - rfleiro@cnio.es

#     (+)
#      ^ 
#      |
#(+) <——> (-)
#      |
#      \/
#     (-)

echo "save your classes WITHOUT SHIFTING TO CENTER OF MASS!!! then run the script as follows"
echo "run RELION External job type with EM_shift_particles_2D_auto as executable and the particle.star from selection as input"

#Variables

echo "getting variables" #this has to improve... very poor
outfolder=$2
datastar=$4

classstar=`echo $datastar | sed 's#particles.star#class_averages.star#'`
outfile1=$outfolder"particles_shifted.star"
outfile2=$outfolder"RELION_OUTPUT_NODES.star"
outfile3=$outfolder"RELION_JOB_EXIT_SUCCESS"

out1=$outfolder"class.star"
out2=$outfolder"shifts1.tmp"
out3=$outfolder"shifts2.tmp"
out4=$outfolder"shifts3.tmp"
out5=$outfolder"header.tmp"
out6=$outfolder"data.tmp"
out7=$outfolder"data_lap.tmp"
out8=$outfolder"data_shifted.tmp"

classdata=`grep _rlnClassNumber $datastar | awk -F"#" '{print $2}' `
classclass=`grep _rlnClassNumber $classstar | awk -F"#" '{print $2}' `
refimage=`grep _rlnReferenceImage $classstar | awk -F"#" '{print $2}' `
mic=`grep _rlnMicrographName $datastar | awk -F"#" '{print $2}' `
coordX=`grep _rlnCoordinateX $datastar | awk -F"#" '{print $2}' `
coordY=`grep _rlnCoordinateY $datastar | awk -F"#" '{print $2}' `
oriX=`grep _rlnOriginXAngst $datastar | awk -F"#" '{print $2}'`
oriY=`grep _rlnOriginYAngst $datastar | awk -F"#" '{print $2}' `
psi=`grep "_rlnAnglePsi " $datastar | awk -F"#" '{print $2}' `
numberOFfield=`grep _rln $datastar | wc -l`
pxsize=`relion_star_printtable $datastar data_optics _rlnImagePixelSize`

echo "all set..."

#GETTING SHIFTS
echo "getting shifts"

sed 's#ReferenceImage#ImageName#' $classstar > $out1
relion_image_handler --i $out1 --o tmp --shift_com | grep Center | awk -F":" '{print $2}' | awk '{print $2, $4}' > $out2
grep mrcs $classstar | awk -vref=$refimage -vcnum=$classclass  '{print $ref, $cnum}' > $outpaste $out3 $out2 > $out4
echo "shifts ready"
cat $out4

#PARTICLE RECENTERING
#offsetX+((displacementX*-cos)-(displacementY*sin) --> component X from moving the particle in X + component X from moving the particle in Y 
#offsetY+((displacementX*sin)-(displacementY*cos)--> component Y from moving the particle in X + component Y from moving the particle in Y

echo "shifting..."

awk 'NF<15{print}' $datastar | sed ':a;/^[ \n]*$/{$d;N;ba}' | grep -v '_rlnOriginXAngst\|_rlnOriginYAngst' | tr ' ' '@' | tr '\n' '?' | awk '{print $1"_rlnOriginXAngst@?_rlnOriginYAngst@"}' | tr '?' '\n' | tr '@' ' ' > $out5
grep mrc $datastar | awk 'NF>15{print $0}' > $out6

for line in $(awk '{print $3,$4,$2}' OFS="_" $out4); do
  difX=`echo $line | awk '{print $1}' FS="_"`
  difY=`echo $line | awk '{print $2}' FS="_"`
  classn=`echo $line | awk '{print $3}' FS="_"`
  echo "shifting particles for class "$classn
  awk -vcln=$classn -vclf=$classdata '{if($clf=cln) print}' $out6 | awk -voX=$oriX -voY=$oriY -vpsi=$psi -vdifX=$difX -vdifY=$difY -vpxsize=$pxsize '{print $0,(($oX+(((difX*pxsize)*(-cos(($psi)*(3.141592/180))))-((difY*pxsize)*(sin(($psi)*(3.141592/180))))))),(($oY+(((difX*pxsize)*(sin(($psi)*(3.141592/180))))-((difY*pxsize)*(cos(($psi)*(3.141592/180)))))))}' >> $out7
done

awk -voX=$oriX -voY=$oriY 'NF>15{$oX=$oY="";print}' $out7 > $out8 
cat $out5 $out8 > $outfile1

echo "done"

rm -rf $outfolder/*tmp
rm -rf $outfolder/class.star
rm -rf $outfolder/class_tmp.star

#Finishing up

echo "data_output_nodes\nloop_\n_rlnPipeLineNodeName #1\n_rlnPipeLineNodeType #2\n"$outfile1" 3" > $outfile2
touch $outfile3

echo "all done"