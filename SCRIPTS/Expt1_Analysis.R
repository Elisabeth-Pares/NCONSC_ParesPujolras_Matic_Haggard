############################################################################################################################
# Feeling ready: neural bases of prospective motor readiness judgements
# Author: Elisabeth Parés-Pujolràs
# Date: 09/11//2021
# Experiment 1 statistical analysis & plots 
############################################################################################################################


############################################################################################################################
# Load required packages
{
require(tidyr)
require(lme4)
require(ggplot2)
require(cowplot)
require(MCMCglmm)
require(lme4)
require(emmeans)
  require(dplyr)
  require(here)
  require(readr)
}
############################################################################################################################


#Define data folder and create output directories
{
  dir <-dirname(rstudioapi::getSourceEditorContext()$path) #Get current directory
  dir.data <- paste(dir,'/DATA/', sep = '')
  dir.stats <- paste(dir,'/STATS/', sep = '')
  dir.create(dir.stats)
  dir.figures <- paste(dir,'/FIGURES/', sep = '')
  dir.create(dir.figures)
}

mydata <- read.csv(paste(dir.data,'Exp1_R_burstData_orangeLetter_Cz.csv', sep = ''), header = TRUE)

#Count trials/condition/participant
trialcounts <- mydata %>%
  group_by(id,cond)%>%
  tally()

#Preprocessing
{
  #Load and preprocess behavioural data 
  sub_id <- c(1:23)[-c(10,11,13,14)] # Load all participants except for excluded subjects
  
  # Load long-format data for all subjects
  d_raw <- read_csv(paste(dir.data, '/BehaviouralData/K1_P1_rOL.csv', sep = ""), show_col_types = F)
  for (sub in sub_id[-1]) {
    sub_d <- read_csv(paste(dir.data, '/BehaviouralData/K1_P', sub, '_rOL.csv', sep = ""), show_col_types = F)
    d_raw <- rbind(d_raw, sub_d) }
  
  # Subset: experiment trials only, drop unnecessary columns
  behdat <- select(d_raw, 
                   -c(sex, task, letterStr, letterStrTmp, orangeIdx)) #%>%
  
  write.csv(behdat,paste(dir.data, 'BehaviouralData/K1_allData_behaviouralData.csv', sep = '')) 
  
  #Correct burst count & timing for 1-burst trials
  mydata[mydata$burstcount == 0 & mydata$endlast != 449,]$burstcount <- 1 #Trials with a burst at trial onset
  mydata[mydata$burstcount == 0 & mydata$endlast == 449,]$endlast <- NA #Trials with no bursts
  
  #transform duration to seconds 
  mydata$tendlast <- -2+ mydata$endlast/200
  mydata$burstrate <- mydata$burstcount/1.75

  mydata$ocond <- NA
  mydata[mydata$cond == 1,]$ocond <- 3 # AW a lot of preparation
  mydata[mydata$cond == 2,]$ocond <- 1 # NR no preparation
  mydata[mydata$cond == 3,]$ocond <- 2 # SP some preparation
  
  mydata[mydata$cond == 1,]$cond <- 'AW'
  mydata[mydata$cond == 2,]$cond <- 'NR'
  mydata[mydata$cond == 3,]$cond <- 'SP'

  mydata$binmov = NA
  mydata[mydata$cond == 'AW',]$binmov <- 1
  mydata[mydata$cond == 'SP',]$binmov <- 1
  mydata[mydata$cond == 'NR',]$binmov <- 0

  mydata <- mydata %>%
   group_by(id)%>%
    mutate(zburstrate = scale(burstrate),
           ztendlast = scale(tendlast),
           zbetamean = scale(betamean))

}

# Prepare plotting parameters 
{
  colorAll <- c('gray20', 'blue3',rgb(1, 0.5, 0.25)) 
  colorBin <- c('cornflowerblue', rgb(1, 0.5, 0.25)) 
  orderedLabs <- c('NoMov', 'Unaware', 'Aware')
  names(orderedLabs) <- c('1','2','3')
  
  binLabs <- c('SP', 'Aw')
  names(binLabs) <- c('0','1')
  
  theme_elis <- function(){
    theme_classic(base_size=9) + 
      theme(strip.background = element_rect(colour="white", fill="white"),
            plot.title = element_text(hjust = 0.5, size = 10)) 
  }
}

#Get percentage of reSPonses after orange letters
gadata <- mydata %>%
  group_by(id,cond)%>%
  tally()

gadata <- gadata%>%
  spread(cond, n)%>%
  mutate(perc_aw = AW/(AW+SP+NR)*100,
         perc_SP = SP/(AW+SP+NR)*100,
         perc_nr = NR/(AW+SP+NR)*100)


mean(gadata$perc_aw)
mean(gadata$perc_SP)
mean(gadata$perc_nr)

sd(gadata$perc_aw)
sd(gadata$perc_SP)
sd(gadata$perc_nr)


#########################################################################################
# 1. Behavioural analysis - RT
#########################################################################################

allData <- read.csv(paste(dir.data, 'Exp1_RTData.csv', sep = '')) # merged data with RTs corresponding to EEG trials only 
allData[allData$cond == 1,]$cond = 'AW'
allData[allData$cond == 2,]$cond = 'NR'
allData[allData$cond == 3,]$cond = 'SP'

behData <- allData %>%
  group_by(id)%>%
  mutate(bins = cut(rt, breaks = c(seq(from = 0,to = 2,by = 0.1))))

ga_rts  <- behData %>%
  filter(!is.na(rt))%>%
  group_by(id,cond,bins)%>%
  #filter(RecodingOL12 == 'orangeResponse_AWkey' | RecodingOL12 == 'orangeResponse_SPkey')%>%
  tally()


Fig2a_left = ggplot(ga_rts, aes(x = as.factor(bins), y = n, fill = as.factor(cond)))+
  geom_bar(stat="summary", position = position_dodge(), alpha=1, width = 0.75, show.legend = T) +
  stat_summary(fun.data = mean_se, geom = "errorbar", alpha=1, width = 0.2, position = position_dodge(0.75), inherit.aes = TRUE)+
  ggtitle('RTs sorted by awareness condition')+
  scale_x_discrete(name = 'RT (s)', labels = c(seq(from = 0,to = 2,by = 0.1)))+
  scale_y_continuous(name = 'Trial count') +
  scale_fill_manual(values = rev(colorAll), name = '')+
  scale_color_manual(values = 'k')+
  theme_elis()
Fig2a_left

ga_rts  <- allData%>%
  group_by(id,cond)%>%
  summarise(meanrt = mean(rt))

Fig2a_right = ggplot(ga_rts[ga_rts$cond != 'NR',], aes(x = cond, y = meanrt, fill = factor(cond)))+
  geom_bar(stat="summary", position = position_dodge(), alpha=1, width = 0.75, show.legend = F) +
  geom_point(position=position_dodge(0.75), color = 'grey50', size=0.75, show.legend = legend) +  
  stat_summary(fun.data = mean_se, geom = "errorbar", alpha=1, width = 0.2, position = position_dodge(0.75), inherit.aes = TRUE)+
  #ggtitle('RTs sorted by awareness condition')+
  scale_x_discrete(labels = c('Aw', 'Unaw'), name = '')+
  scale_y_continuous(name = 'RT (s)') +
  scale_fill_manual(values = rev(colorAll), name = '')+
  scale_color_manual(values = 'k')+
  theme_elis()
Fig2a_right

ga_rts  <- allData%>%
  group_by(id,cond)%>%
  filter(cond != 'NR')%>%
  summarise(meanrt = mean(rt)) %>%
  spread(cond, meanrt)

t.test(ga_rts$SP, ga_rts$AW, paired = TRUE)

require(cowplot)
Fig2a <- plot_grid(Fig2a_left,Fig2a_right, 
                   ncol = 2, nrow = 1, rel_widths = c(3,1))

ggsave(paste(dir.figures, 'Figure2a.tiff'), Fig2a, 
       width = 16, height = 5, units = "cm", dpi = 600)

# Single-subject - Supplementary figure

Fig_S1 <- ggplot(allData[allData$cond != 'NR',], aes(x = rt, fill = cond))+
  geom_histogram(bins = 20)+
  ggtitle('RT sorted by awareness condition')+
  scale_x_continuous(name = 'RT (s)', limits = c(0,2))+
  scale_y_continuous(name = 'Trial count')+
  scale_fill_manual(values = rev(colorAll), name = '')+
  theme_elis()+
  facet_wrap(id~.)
Fig_S1

ggsave(paste(dir.figures, 'Fig_S1.tiff', sep = ''), Fig_S1, 
       width = 16, height = 16, units = "cm", dpi = 600)

## Test skewness of RT distributions in Fig S1
library(e1071)      
sk <- as.integer()
for (i in unique(allData$id)){
  thiSPart <- filter(allData, id == i)
  rts <- thiSPart$rt
  sk[i] <- skewness(rts, na.rm = T)
  rts <- c()
}
sk

#########################################################################################
# 2. Readiness potential analysis
# Note: this is including only 18 participants (1 did not show an identifiable RP)
#########################################################################################

#Load RP dataset
rpdata <- read.csv(paste(dir.data, 'K1_RPamp_12_forR.csv', sep = ''), header = FALSE)

colnames(rpdata) <- c('id', 'cond', 'rpAmp')

#To match with beta, for correlation
betaData <- filter(mydata, (id != 6)) #Exclude ID = 6 (no RP)

mergedData <- cbind(betaData, rpdata)
mergedData <- mergedData[-c(1)]

rpdata$condition <- NA
rpdata[rpdata$cond == 3,]$condition = 'AW'
rpdata[rpdata$cond == 2,]$condition = 'SP'
rpdata[rpdata$cond == 1,]$condition = 'NR'

rpdata <- rpdata %>%
  group_by(id)%>%
  mutate(zrpamp = scale(rpAmp))

ga <- rpdata %>%
  group_by(id,cond) %>%
  summarise(ga_zrpamp = mean(zrpamp))

rpamp= ggplot(ga, aes(x = factor(cond), y = ga_zrpamp, fill = factor(cond)))+
  #geom_bar(size = 0.5, show.legend = FALSE) +
  #stat_summary(fun.data = mean_se, geom = "errorbar", alpha=1, width = 0.2, position = position_dodge(0.75), inherit.aes = TRUE)+
  geom_bar(stat = "summary", fun.y = "mean",size = 0.5,position = position_dodge(), alpha=1, width = 0.75, show.legend = FALSE)+
  stat_summary(fun.data = mean_se, geom = "errorbar", alpha=1, width = 0.2, position = position_dodge(0.75), inherit.aes = TRUE)+
  scale_fill_manual(values = colorAll)+
  scale_x_discrete(name = '', labels = c('NoMov', 'Unaware', 'Aware'))+
  scale_y_continuous(name = 'z-RP amplitude')+
  coord_cartesian(ylim = c(-0.3,0.3)) +
  theme_classic()
rpamp

ggsave(paste(dir.figures, 'Figure3b_rp.tiff'), rpamp, 
       width = 5.33, height = 5, units = "cm", dpi = 600)

############################################################################################################################
# 3. Beta band analysis
############################################################################################################################

rate <- lmer(burstrate ~ 1 + cond + (1|id), 
             data = mydata)

amp <- lmer(betamean ~ 1 + cond + (1|id), 
            data = mydata)

time <- lmer(tendlast ~ 1 + cond + (1|id), 
             data = mydata[mydata$burstcount != 0,])

m1 <-car::Anova(rate, type = c(2), test = 'Chisq')
m2 <-car::Anova(amp, type = c(2), test = 'Chisq')
m3<-car::Anova(time, type = c(2), test = 'Chisq')

#FDR adjust
p.adjust(c(m1$Pr,m2$Pr,m3$Pr), method = 'fdr')

# Amp follow up 
lsmeans(amp, pairwise~cond, adjust="tukey", pbkrtest.limit = 3082 )
lsmeans(rate, pairwise~cond, adjust="tukey", pbkrtest.limit = 3082 )

#NOTE: for post-hoc tests, different methods are available. 
#lsmeans seems best for "small" sample sizes, because it doesn't use infinite degress of freedom. 
#see: https://stats.stackexchange.com/questions/204741/which-multiple-comparison-method-to-use-for-a-lmer-model-lsmeans-or-glht

############################################################################################################################
#Is there an RP - beta amp correlation?
############################################################################################################################
#Pearson correlation 
allStats <- c()
j = 0
for (i in unique(mergedData$id...16)){
  j = j+1
  thisData <- filter(mergedData, id...16 == i)
  stats = cor.test(thisData$rpAmp, thisData$betamean)
  allStats[j] <- unname(stats$estimate)
}

t.test(allStats, paired = FALSE, mu = 0)


#Figure 2cde
# Plot z-scored beta parameters 
ga <- mydata %>%
  group_by(id,ocond) %>%
  summarise(ga_zburstrate = mean(zburstrate),
            ga_zbetamean = mean(zbetamean),
            ga_ztendlast = mean(ztendlast, na.rm = T))


burstrate= ggplot(ga, aes(x = factor(ocond), y = ga_zburstrate, fill = factor(ocond)))+
  geom_bar(stat = "summary", fun.y = "mean",size = 0.5,position = position_dodge(), alpha=1, width = 0.75, show.legend = FALSE)+
  stat_summary(fun.data = mean_se, geom = "errorbar", alpha=1, width = 0.2, position = position_dodge(0.75), inherit.aes = TRUE)+
  scale_fill_manual(values = colorAll)+
  scale_x_discrete(labels = orderedLabs, name = '')+
  scale_y_continuous(name = 'z-burst rate')+
  coord_cartesian(ylim = c(-0.3,0.3)) +
  theme_classic()

betamean = ggplot(ga, aes(x = factor(ocond), y = ga_zbetamean, fill = factor(ocond)))+
   geom_bar(stat = "summary", fun.y = "mean",size = 0.5,position = position_dodge(), alpha=1, width = 0.75, show.legend = FALSE)+
  stat_summary(fun.data = mean_se, geom = "errorbar", alpha=1, width = 0.2, position = position_dodge(0.75), inherit.aes = TRUE)+
  scale_fill_manual(values = colorAll)+
  scale_x_discrete(labels = orderedLabs, name = '')+
  scale_y_continuous(name = 'z-beta amp ')+
  coord_cartesian(ylim = c(-0.3,0.3)) +
  theme_classic()

timeburst = ggplot(ga, aes(x = factor(ocond), y = ga_ztendlast, fill = factor(ocond)))+
  geom_bar(stat = "summary", fun.y = "mean",size = 0.5,position = position_dodge(), alpha=1, width = 0.75, show.legend = FALSE)+
  stat_summary(fun.data = mean_se, geom = "errorbar", alpha=1, width = 0.2, position = position_dodge(0.75), inherit.aes = TRUE)+
  scale_fill_manual(values = colorAll)+
  scale_x_discrete(labels = orderedLabs, name = '')+
  scale_y_continuous(name = 'z-last burst time')+
  coord_cartesian(ylim = c(-0.3,0.3)) +
  theme_classic() 

figure2cde <- plot_grid(burstrate, betamean, timeburst,
                     ncol = 3)
figure2cde

ggsave(paste(dir.figures, 'Figure2cde.tiff'), figure2cde, 
       width = 16, height = 5, units = "cm", dpi = 600)

############################################################################################################################
#Subjective decision times (Supplementary note 1, Figure S7)
############################################################################################################################
############################################################################################################
# Find W times for SP and AW actions
############################################################################################################

behdat <- filter(behdat, (ID != 0))
behdat <- filter(behdat, !is.na(ID))
behdat$timew <- NA

idxrec <- which(behdat$wTime != 'na')

for (i in idxrec){
  widx <- last(which((behdat[1:i,]$letter == behdat[i,]$w))) #Find next RT idx
  wt <- behdat[widx,]$timeStamp #Get time of w report
  wtime <- behdat[i,]$timeAction - wt
  behdat[i,]$timew <- wtime #Add to data matrix
  wtime <- c(); wt <- c(); widx <- c();
}

# Calculate % of trials with two keypresses after orange letter 
bothPress <- behdat %>%
  filter(!is.na(RecodingOL12) & (RecodingOL12 != 'orangePracticeRound')) %>%
  group_by(ID,RecodingOL12) %>%
  tally() %>%
  group_by(ID) %>%
  mutate(ntrials = sum(n))%>%
  mutate(percTrials = n/ntrials*100) %>%
  filter(RecodingOL12 == 'orangeResponse_both')
#Note: need to include a 0 for P6, who did not have any double keypresses. 
percRej <- bothPress$percTrials
percRej = c(percRej, 0)

mean(percRej); sd(percRej);

# Calculate W time
wsubset <- filter(behdat, wTime != 'NaN' & wTime != 'na' & RecodingSP12 != 'SP_PracticeRound' & RecodingSP12 != 'SP_orange')

# Remove times >2s
cwtime = filter(wsubset, timew < 2)

ga_w <- cwtime %>%
  group_by(ID,RecodingSP12)%>%
  summarise(meanw = mean(timew, na.rm = TRUE)) 

Fig_S7_ss_aw = ggplot(ga_w, aes(x = RecodingSP12, y = meanw, fill = RecodingSP12))+
  geom_bar(stat = "summary", fun.y = "mean",size = 0.5,position = position_dodge(), alpha=1, width = 0.75, show.legend = FALSE)+
  stat_summary(fun.data = mean_se, geom = "errorbar", alpha=1, width = 0.2, position = position_dodge(0.75), inherit.aes = TRUE)+
  geom_point(show.legend = FALSE) +
  #ggtitle('AW time sorted by awareness condition')+
  scale_x_discrete(name = 'RT (s)', labels = c('Awareness reports', 'Self-paced actions'))+
  scale_y_continuous(name = 'W-time before action')+
  scale_fill_manual(values = rev(colorAll), name = '')+
  theme_elis()
Fig_S7_ss_aw

ggsave(paste(dir.figures, 'FigureS7.tiff'), Fig_S7_ss_aw, 
       width = 8, height = 8, units = "cm", dpi = 600)

ga_w <- ga_w %>%
  spread(RecodingSP12, meanw)

mean(ga_w$AW_orange); sd(ga_w$AW_orange);
mean(ga_w$SP_keypress); sd(ga_w$SP_keypress);

t.test(ga_w$AW_orange, ga_w$SP_keypress, paired = TRUE)
