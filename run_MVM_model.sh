#!/bin/bash
#This is a MVM script for the NHLP FastLoc.

module load R/3.4.1-foss-2016b
module load Python/2.7.13-foss-2016b

base_path=$STORAGE/nhlp/projects/group_FastLoc/MVM

3dMVM \
-prefix ${base_path}/VisCondbyTypeInt_age_Nov2018+tlrc \
-jobs 20 \
-mask ${base_path}/TT_N27_mask_2mm+tlrc \
-bsVars "age_mri+wjiiilwrs" \
-wsVars "CondLabel*TrialType" \
-qVars "age_mri,wjiiilwrs" \
-num_glt 20 \
-gltLabel 1 Visual_Std -gltCode 1 'CondLabel : 1*VIS_UNREL 1*FALSE_FONT TrialType : 1*Standard' \
-gltLabel 2 Visual_Odd -gltCode 2 'CondLabel : 1*VIS_UNREL 1*FALSE_FONT TrialType : 1*Oddball' \
-gltLabel 3 Words-FF_Std -gltCode 3 'CondLabel : 1*VIS_UNREL -1*FALSE_FONT TrialType : 1*Standard' \
-gltLabel 4 Words-FF_Odd -gltCode 4 'CondLabel : 1*VIS_UNREL -1*FALSE_FONT TrialType : 1*Oddball' \
-gltLabel 5 Odd-Std_Words -gltCode 5 'CondLabel : 1*VIS_UNREL TrialType : -1*Standard 1*Oddball' \
-gltLabel 6 Odd-Std_FF -gltCode 6 'CondLabel : 1*FALSE_FONT TrialType : -1*Standard 1*Oddball' \
-gltLabel 7 Reading_Visual_Std -gltCode 7 'CondLabel : 1*VIS_UNREL 1*FALSE_FONT TrialType : 1*Standard wjiiilwrs :' \
-gltLabel 8 Reading_Visual_Odd -gltCode 8 'CondLabel : 1*VIS_UNREL 1*FALSE_FONT TrialType : 1*Oddball wjiiilwrs :' \
-gltLabel 9 Reading_Words-FF_Std -gltCode 9 'CondLabel : 1*VIS_UNREL -1*FALSE_FONT TrialType : 1*Standard wjiiilwrs :' \
-gltLabel 10 Reading_Words-FF_Odd -gltCode 10 'CondLabel : 1*VIS_UNREL -1*FALSE_FONT TrialType : 1*Oddball wjiiilwrs :' \
-gltLabel 11 Reading_Odd-Std_Words -gltCode 11 'CondLabel : 1*VIS_UNREL TrialType : -1*Standard 1*Oddball wjiiilwrs :' \
-gltLabel 12 Reading_Odd-Std_FF -gltCode 12 'CondLabel : 1*FALSE_FONT TrialType : -1*Standard 1*Oddball wjiiilwrs :' \
-gltLabel 13 Words_Std -gltCode 13 'CondLabel : 1*VIS_UNREL TrialType : 1*Standard' \
-gltLabel 14 FF_Std -gltCode 14 'CondLabel : 1*FALSE_FONT TrialType : 1*Standard' \
-gltLabel 15 Words_Odd -gltCode 15 'CondLabel : 1*VIS_UNREL TrialType : 1*Oddball' \
-gltLabel 16 FF_Odd -gltCode 16 'CondLabel : 1*FALSE_FONT TrialType : 1*Oddball' \
-gltLabel 17 Reading_Words_Std -gltCode 17 'CondLabel : 1*VIS_UNREL TrialType : 1*Standard wjiiilwrs :' \
-gltLabel 18 Reading_FF_Std -gltCode 18 'CondLabel : 1*FALSE_FONT TrialType : 1*Standard wjiiilwrs :' \
-gltLabel 19 Reading_Words_Odd -gltCode 19 'CondLabel : 1*VIS_UNREL TrialType : 1*Oddball wjiiilwrs :' \
-gltLabel 20 Reading_FF_Odd -gltCode 20 'CondLabel : 1*FALSE_FONT TrialType : 1*Oddball wjiiilwrs :' \
-dataTable @MVM_DataTable_NHLP_VisOnly.txt
