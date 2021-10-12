#!/bin/bash

IDs=$STORAGE/nhlp/scripts/subjectIDs
subjects=$STORAGE/nhlp/processed
results=$STORAGE/nhlp/projects/group_FastLoc

#Define ROIs
3dclust -1Dformat -nosum -1dindex 16 -1tindex 17 -2thresh -4.653 4.653 \
 -dxyz=1 -savemask ${results}/masks/WordsFF_q001+tlrc 1.01 20 \
 ${results}/MVM/VisCondbyTypeInt_age_Nov2018+tlrc.HEAD > ${results}/masks/WordsFF_q001_table.1D
 
3dcalc -prefix ${results}/masks/WordsFF_q001_LMTG+tlrc \
 -a ${results}/masks/WordsFF_q001+tlrc \
 -expr 'within(a,1.9,2.1)'

3dcalc -prefix ${results}/masks/WordsFF_q001_LIFG+tlrc \
 -a ${results}/masks/WordsFF_q001+tlrc \
 -expr 'within(a,3.9,4.1)'
 
3dcalc -prefix ${results}/masks/WordsFF_q001_LITG+tlrc \
 -a ${results}/masks/WordsFF_q001+tlrc \
 -expr 'within(a,4.9,5.1)'
 

#Extract values
# for aSub in $(cat ${IDs}/nhlp_subjects_usablefastloc_20181112.txt)
# do
# 
# echo "Calculating Betas for ${aSub}"
# 
# 	for aMask in WordsFF_q001_LMTG WordsFF_q001_LIFG WordsFF_q001_LITG
# 	do
#  	echo "Calculating Betas for ${aMask}"
#   	
#  		Beta_WordsStd=$(3dROIstats -quiet -mask ${results}/masks/${aMask}+tlrc ${subjects}/${aSub}/${aSub}.fastloc/stats.${aSub}_REML+tlrc'[VIS_UNREL_no#0_Coef]')
# 		echo $aSub $Beta_WordsStd >> ${results}/masks/${aMask}_Beta_WordsStd.txt
# 		
# 		Beta_FFStd=$(3dROIstats -quiet -mask ${results}/masks/${aMask}+tlrc ${subjects}/${aSub}/${aSub}.fastloc/stats.${aSub}_REML+tlrc'[FALSE_FONT_no#0_Coef]')
# 		echo $aSub $Beta_FFStd >> ${results}/masks/${aMask}_Beta_FFStd.txt
# 
# 	done
# done
