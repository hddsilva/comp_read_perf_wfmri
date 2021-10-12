library(dplyr); library(tidyr); library(ggplot2); library(data.table)

NHLP_data <- data
names(NHLP_data)[5] <- "Subj"
NHLP_data$Subj <- factor(NHLP_data$Subj)
NHLP_data$childdob <- as.Date(as.character(NHLP_data$childdob),"%Y-%m-%d")
NHLP_data$mri_date <- as.Date(as.character(NHLP_data$mri_date),"%Y-%m-%d")
NHLP_data$entrytestdate <- as.Date(as.character(NHLP_data$entrytestdate),"%Y-%m-%d")
NHLP_data$posttest_date <- as.Date(as.character(NHLP_data$posttest_date),"%Y-%m-%d")
NHLP_data$cogtest_date <- as.Date(as.character(NHLP_data$cogtest_date),"%Y-%m-%d")

#Create enrollment table
Enroll_table <- NHLP_data %>%
  group_by(record_id) %>%
  filter(!is.na(Subj)) %>%
  select(record_id,
         Subj,
         childsex.factor) %>% 
  ungroup()
Enroll_table$Subj <- factor(Enroll_table$Subj)

#Load sheet with usable data columns back
QC_ByTask <- read.csv("../QC_ByTask.csv", header = TRUE) 
QC_ByTask$Subj <- factor(QC_ByTask$Subj)
#Note that date and time formats may need to change so they match original sheet (in case Excel changed this)
QC_ByTask$anat_date <- as.Date(QC_ByTask$anat_date, "%m/%d/%y")
QC_ByTask$fastloc_date <- as.Date(QC_ByTask$fastloc_date, "%m/%d/%y")
QC_ByTask$rest_date <- as.Date(QC_ByTask$rest_date, "%m/%d/%y")
QC_ByTask$dti_date <- as.Date(QC_ByTask$dti_date, "%m/%d/%y")
#Filter by usable fastlocs and select most recent fastloc for kids w/multiple
QC_ByTask <- QC_ByTask %>% 
  left_join(Enroll_table, by = "Subj") %>% 
  filter(!is.na(fastloc_date)) %>% 
  mutate(fastloc_today_gap = abs(difftime(fastloc_date,as.Date("2030-01-01"), units="days"))) %>%  
  group_by(Subj) %>% 
  slice(which.min(fastloc_today_gap)) %>% 
  ungroup()

#Create MRI table  
MRI_table <- NHLP_data %>% 
  filter(grepl("mri",redcap_event_name),
         !is.na(mri_date)) %>% 
  mutate(age_mri = round(as.numeric(((age_mriy*365.25)+(age_mrim*30.42)+age_mrid)/365.25),2)) %>% 
  select(record_id, mri_date, age_mri)

#Create questionnaire table
Quest_table <- NHLP_data %>%
  group_by(record_id) %>%
  filter(grepl("questionnaires",redcap_event_name)) %>%
  mutate(num_gov_assist = sum(pq19c,pq19d,pq19e),
         SES = ifelse(num_gov_assist > 0, 1, 0),
         race = ifelse (pq2 == 0 & pq3___1==1 & pq3___2==0 & pq3___3==0 & pq3___4==0 & pq3___5==0 & pq3___6==0, 1,
                        ifelse (pq2 == 0 & pq3___1==0 & pq3___2==1 & pq3___3==0 & pq3___4==0 & pq3___5==0 & pq3___6==0, 2,
                                ifelse (pq2 == 0 & pq3___1==0 & pq3___2==0 & pq3___3==1 & pq3___4==0 & pq3___5==0 & pq3___6==0, 3,
                                        ifelse (pq2 == 0 & pq3___1==0 & pq3___2==0 & pq3___3==0 & pq3___4==1 & pq3___5==0 & pq3___6==0, 4,
                                                ifelse (pq2 == 0 & pq3___1==0 & pq3___2==0 & pq3___3==0 & pq3___4==0 & pq3___5==1 & pq3___6==0, 5,
                                                        ifelse (sum(pq3___1,pq3___2,pq3___3,pq3___4,pq3___5,pq3___6)>=2, 7, 0))))))) %>% 
  select(record_id, pq7a_1, pq7a_1.factor, SES, pq2, pq3___1,
         pq3___2, pq3___3, pq3___4, pq3___5, pq3___6, pq3spec, race)
names(Quest_table)[2] <- "maternal_ed"
names(Quest_table)[3] <- "maternal_ed.factor"
#Race code:
#1 - African-American
#2 - American Indian / Alaska Native
#3 - Asian
#4 - Caucasian (White)
#5 - Pacific Islander
#6 - Hispanic / Latino
#7 - Mixed race
#8 - Other

#Create reading assessment table
Read_table <- NHLP_data %>%
  group_by(record_id) %>% 
  filter(grepl("t1|t2|t3|t4|t5|p1|p2|p3|p4|p5",redcap_event_name)) %>% 
  mutate(read_datecombine = as.Date(as.numeric(ifelse(!is.na(entrytestdate),as.Date(entrytestdate, format = "%Y-%m-%d"),
                                                      ifelse(!is.na(posttest_date),as.Date(posttest_date, format = "%Y-%m-%d"),NA))), origin = "1970-01-01")) %>% 
  select(record_id,
         wjiiilwrs,
         wjiiilwss,
         read_datecombine)
#Find reading assessment closest to usable fastloc
Fastloc_read <- Read_table %>% 
  left_join(QC_ByTask, by = "record_id")  %>% 
  mutate(fastloc_read_gap = abs(difftime(fastloc_date,read_datecombine, units="days"))) %>% 
  group_by(record_id) %>% 
  slice(which.min(fastloc_read_gap)) %>% 
  select(record_id,
         read_datecombine,
         wjiiilwrs,
         wjiiilwss,
         fastloc_read_gap)
names(Fastloc_read)[2] <- "readtest_date"

#Create cognitive assessment table
Cog_table <- NHLP_data %>%
  group_by(record_id) %>% 
  filter(grepl("cog",redcap_event_name)) %>% 
  select(record_id,
         cogtest_date,
         wasimrrs,
         wasimrss)
#Find cognitive assessment closest to usable fastloc
Fastloc_cog <- Cog_table %>% 
  left_join(QC_ByTask, by = "record_id") %>% 
  mutate(fastloc_cog_gap = abs(difftime(fastloc_date,cogtest_date, units="days"))) %>% 
  group_by(record_id) %>% 
  slice(which.min(fastloc_cog_gap)) %>% 
  select(record_id,
         cogtest_date,
         wasimrrs,
         wasimrss,
         fastloc_cog_gap)

#Read in FastLoc driver summary to get average motion per TR
#This table is generated by running the following code:
#gen_ss_review_table.py  \
#-infiles $STORAGE/nhlp/processed/pb????/pb????.fastloc/out.ss_review* \
#-tablefile $STORAGE/nhlp/processed/qc/FastLoc_Driver_Summary.txt
#Resulting table must have () and spaces removed from column names using Excel's find and replace
FastLoc_Driver_Summary <- read.delim("../driver_summaries/FastLoc_Driver_Summary_20180926.txt", header = TRUE) %>%
  filter(grepl('pb', subject_ID)) %>% 
  select(subject_ID, average_motion_per_TR)

#Read in language categories
Lang_categories <- read.csv("../nhlp_language_categories.csv", header = TRUE) 
Lang_categories$Subj <- factor(Lang_categories$Subj)
#ML = monolingual
#BE = bilingual English
#BB = balanced bilingual
#BS = bilingual Spanish
#alt_language = bilingualism is in a language other than Spanish. For example, a Russian-speaker may be labeled
#as BB, alt_lang = 1

#Combine the above dataframes
comb_dataframes <- QC_ByTask %>% 
  inner_join(MRI_table, by = c("record_id", "fastloc_date"="mri_date")) %>% 
  left_join(Quest_table, by = "record_id") %>% 
  left_join(Fastloc_read, by = "record_id") %>% 
  left_join(Fastloc_cog, by = "record_id") %>% 
  left_join(FastLoc_Driver_Summary, by = c("mrrc_id" = "subject_ID")) %>% 
  left_join(Lang_categories, by = "Subj")

#Write out dataframe for manual coding of race
write.table(comb_dataframes, "~/Desktop/comb_dataframes.txt", sep="\t", row.names = FALSE)

#Select only the variables of interest
comp_read_perf_w_fMRI <- comb_dataframes %>% 
  select(record_id,
         Subj,
         mrrc_id,
         childsex.factor,
         age_mri,
         lang_category,
         alt_language,
         maternal_ed,
         maternal_ed.factor,
         SES,
         wjiiilwrs,
         wjiiilwss,
         wasimrrs,
         wasimrss,
         fastloc_read_gap,
         fastloc_cog_gap,
         average_motion_per_TR)


write.table(comp_read_perf_w_fMRI, "comp_read_perf_w_fMRI.txt", sep="\t", row.names = FALSE)

#Make MVM data tables
DataTable <- comp_read_perf_w_fMRI %>% 
  select(mrrc_id,childsex.factor,age_mri,maternal_ed,SES:average_motion_per_TR) %>% 
  filter(!is.na(age_mri)) %>% 
  filter(!is.na(wjiiilwss)) %>% 
  filter(!is.na(wasimrss)) %>% 
  filter(!is.na(maternal_ed)) %>% 
  filter(!is.na(SES))
names(DataTable)[1] <- "Subj"
DataTable_Rep <- DataTable[rep(seq_len(nrow(DataTable)),4), ]
DataTable_Rep$CondLabel <- gl(2,nrow(DataTable),4*nrow(DataTable),labels=c("VIS_UNREL","FALSE_FONT"))
DataTable_Rep$TrialLabel <- gl(2,2*nrow(DataTable),4*nrow(DataTable),labels = c("no","yes"))
DataTable_Rep$TrialType <- gl(2,2*nrow(DataTable),4*nrow(DataTable),labels = c("Standard","Oddball"))
DataTable_MVM_VisOnly <- DataTable_Rep %>% 
  mutate(`InputFile\ \\`=paste0("'/SAY/standard/Neonatology-726014-MYSM/nhlp/processed/",Subj,"/",Subj,".fastloc/stats.",Subj,"_REML+tlrc[",CondLabel,"_",TrialLabel,"#0_Coef]'\ \\",sep=""))
write.table(DataTable_MVM_VisOnly,"DataTables/MVM_DataTable_NHLP_VisOnly.txt",row.names = F,col.names = T,quote = F)
#remember to delete slash at end of last line of output text file

#Plot ROI correlations
comp_read_perf_w_fMRI <- read.table("comp_read_perf_w_fMRI.txt", header = T)
DataTable <- comp_read_perf_w_fMRI %>% 
  select(mrrc_id,Subj,childsex.factor,age_mri,maternal_ed,SES:average_motion_per_TR) %>% 
  filter(!is.na(age_mri)) %>% 
  filter(!is.na(wjiiilwss))

LITG_Words <- read.table("WordsFF_q001_LITG_Beta_WordsStd.txt", header = F)
names(LITG_Words) <- c("mrrc_id","LITG_Words")
LITG_FalseFont <- read.table("WordsFF_q001_LITG_Beta_FFStd.txt", header = F)
names(LITG_FalseFont) <- c("mrrc_id","LITG_FalseFont")
LIFG_Words <- read.table("WordsFF_q001_LIFG_Beta_WordsStd.txt", header = F)
names(LIFG_Words) <- c("mrrc_id","LIFG_Words")
LIFG_FalseFont <- read.table("WordsFF_q001_LIFG_Beta_FFStd.txt", header = F)
names(LIFG_FalseFont) <- c("mrrc_id","LIFG_FalseFont")
LMTG_Words <- read.table("WordsFF_q001_LMTG_Beta_WordsStd.txt", header = F)
names(LMTG_Words) <- c("mrrc_id","LMTG_Words")
LMTG_FalseFont <- read.table("WordsFF_q001_LMTG_Beta_FFStd.txt", header = F)
names(LMTG_FalseFont) <- c("mrrc_id","LMTG_FalseFont")

DataTable_wROIs <- DataTable %>% 
  left_join(LITG_Words, by = "mrrc_id") %>% 
  left_join(LITG_FalseFont, by = "mrrc_id") %>% 
  left_join(LIFG_Words, by = "mrrc_id") %>% 
  left_join(LIFG_FalseFont, by = "mrrc_id") %>% 
  left_join(LMTG_Words, by = "mrrc_id") %>% 
  left_join(LMTG_FalseFont, by = "mrrc_id") %>% 
  mutate(LITG_WordsvFF = LITG_Words-LITG_FalseFont,
         LIFG_WordsvFF = LIFG_Words-LIFG_FalseFont,
         LMTG_WordsvFF = LMTG_Words-LMTG_FalseFont) %>% 
  filter(!is.na(LITG_FalseFont))

cor.test(DataTable_wROIs$wjiiilwss,DataTable_wROIs$LITG_WordsvFF)
m.lwid <- lm(data=DataTable_wROIs,LITG_WordsvFF~wjiiilwss)
summary(m.lwid)
car::outlierTest(m.lwid)

ggplot(DataTable_wROIs, aes(wjiiilwss,LITG_WordsvFF))+
  geom_point()+
  geom_smooth(method="lm",color="red")+
  labs(x="WJ-III Letter Word ID\nStandard Score", y="Activation for\nWords - False Font")+
  coord_cartesian(xlim=c(80,130))+
  theme_bw(25)
ggsave("LITG_Reading_scatterplot.pdf",width=6,height=6,useDingbats=F)  
