############################################################################################################################
# Feeling ready: the role of beta oscillations in the prospective feeling of readiness
# Author: Elisabeth Parés-Pujolràs
# Date: 09/11//2021
# Experiment 2 statistical analysis & plots 
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
  require(standardize)
  require(ordinal)
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

# Plotting parameters
colorHot <- c(rgb(0.2, 0, 0), rgb(0.4,0,0),rgb(0.6, 0, 0),rgb(0.8, 0, 0),rgb(1, 0, 0),rgb(1, 0.2, 0),rgb(1, 0.4, 0),rgb(1, 0.6, 0)) 

#Load data			
#Note: load correct file according to channel
mydata <- read.csv(paste(dir.data, 'Exp2_R_burstData_OL_CZ.csv', sep = ''), header = TRUE)


#Preprocess
{
  
  #Remove end timing if no bursts; default value = 250
  mydata[mydata$burstcount == 0 & mydata$startlast == 250 &mydata$endlast != 250,]$burstcount <- 1 #If default start but no default end, trial started with a burst. 
  mydata[mydata$burstcount == 0 & mydata$startlast == 250 &mydata$endlast == 250 & mydata$durlast == 1,]$endlast <- NA # If default start and end, no bursts. 
  

  #transform duration to seconds 
  mydata$tstartlast <- abs(-1.25 + mydata$startlast/200) #-1.5 + mydata$startlast/200 -0.25 start, -0.25 end
  mydata$tendlast <- abs(-1.25 + mydata$endlast/200) #-1.5 + mydata$startlast/200 -0.25 start, -0.25 end
  mydata$burstrate <- mydata$burstcount/1
  
  #beta power 
  mydata$betapower <- mydata$betamean^2
  
  mydata <- mydata %>%
    group_by(id)%>%
    mutate(zrpamp = scale(RPAmp),
           zratings = scale(rating),
           zburstrate = scale(burstrate),
           ztendlast = scale(tendlast),
           zbetamean = scale(betamean),
           zbetapower = scale(betapower)) %>%
    mutate(zratings_order = as.numeric(cut(zratings, breaks = 8))) %>%
    mutate(rating_order = as.numeric(cut(rating, breaks = 3)))
  
  #Dichotomise ratings 
  sumdat <- mydata %>%
    group_by(id) %>%
    summarise(medianRating = median(as.numeric(rating)),
              meanRating = mean(as.numeric(rating)))
  
  mydata <- merge(mydata, sumdat, by = 'id')
  
  mydata$median_dicrat <- NA
  mydata$mean_dicrat <- NA
  mydata$rating <- as.numeric(mydata$rating)
  
  mydata$nrating <- NA
  mydata$nrating <- mydata$rating/mydata$meanRating
  
  mydata[mydata$rating > mydata$meanRating,]$mean_dicrat <- 'High'
  mydata[mydata$rating < mydata$meanRating,]$mean_dicrat <- 'Low'
  
  mydata[mydata$rating > mydata$medianRating,]$median_dicrat <- 'High'
  mydata[mydata$rating <= mydata$medianRating,]$median_dicrat <- 'Low'
  
  mydata$srat_dicrat <- NA
  mydata[mydata$zratings > 0,]$srat_dicrat <- 'High'
  mydata[mydata$zratings < 0,]$srat_dicrat <- 'Low'
  
  #write.csv(mydata, "E3_R_allP_behData_ICA_betaBursts_postR.csv") #Save for plotting power spectra in R 
}


#######################################################################################################
# RP analysis 
#######################################################################################################
{
mydata$rating <- as.factor(mydata$rating)
#Analyse including ALL subjects
modelrp_clmm <- clmm(rating ~ 1 + zrpamp + (1|id), 
                     data = mydata)
summary(modelrp_clmm)
RVAideMemoire::Anova.clmm(modelrp_clmm, type = "II")


# Control analysi sremoving participants who did not show an RP
# indices (from 1:17) is: participant 8 (original ID = 12)

rpData <- filter(mydata, (id != 12))

ga_rpamp <- ggplot(mydata, aes(y = zrpamp, x = factor(rating), fill = factor(rating))) + 
  #geom_boxplot(size = .75) +
  geom_bar(stat = 'summary', fun = 'mean', show.legend = FALSE) + 
  geom_hline(yintercept = c(0))+
  coord_cartesian(ylim = c(-0.35,0.35))+
  stat_summary(fun.data = mean_se, geom = "errorbar", alpha=1, width = 0.2, inherit.aes = TRUE, show.legend = FALSE)+
  labs(x = 'Rating', title = 'RP amplitude', y = 'Z') + 
  scale_fill_manual(values = colorHot) + 
  theme_classic(base_size = 10)

#Analyse excluding participant w/o RP
rpData$rating <- as.factor(rpData$rating)
modelrp_clmm <- clmm(rating ~ 1 + zrpamp + (1|id), 
                     data = rpData)
summary(modelrp_clmm)
RVAideMemoire::Anova.clmm(modelrp_clmm, type = "II")
}

#Figure 3b
{
ga_rpamp <- ggplot(mydata, aes(y = zrpamp, x = factor(rating), fill = factor(rating))) + 
  #geom_boxplot(size = .75) +
  geom_bar(stat = 'summary', fun = 'mean', show.legend = FALSE) + 
  geom_hline(yintercept = c(0))+
  coord_cartesian(ylim = c(-0.35,0.35))+
  stat_summary(fun.data = mean_se, geom = "errorbar", alpha=1, width = 0.2, inherit.aes = TRUE, show.legend = FALSE)+
  labs(x = 'Rating', title = 'RP amplitude', y = 'Z') + 
  scale_fill_manual(values = colorHot) + 
  theme_classic(base_size = 10)
  
  ggsave(paste(dir.figures, 'Fig3_b.tiff', sep = ''), Fig3_cde, 
         width = 5, height = 5, units = "cm", dpi = 600)
}


#######################################################################################################
# Beta band analysis 
#######################################################################################################
# Following Little et al. 2019, compare 3 models to predict performance 
# Because the ratings are on a likert scale, we need to use a different distribution 
# Using the clmm package because p values are interpretable here (not so in the alternative MCMC package)
{
  
# Using a non-bayesian package 
mydata$rating <- as.factor(mydata$rating)

model1_clmm <- clmm(rating ~ 1 + zburstrate + (1|id), 
                    data = mydata)
m1sum <-summary(model1_clmm)
RVAideMemoire::Anova.clmm(model1_clmm, type = "II")


model2_clmm <- clmm(rating ~ 1 + zbetamean + (1|id), 
                    data = mydata)
m2sum <-summary(model2_clmm)
RVAideMemoire::Anova.clmm(model2_clmm, type = "II")

model3_clmm <- clmm(rating ~ 1 + ztendlast + (1|id), 
                    data = mydata[mydata$burstcount != 0,]) #Exclude trials with no bursts
m3sum <-summary(model3_clmm)
RVAideMemoire::Anova.clmm(model3_clmm, type = "II")

#FDR adjust
p.adjust(c(m1sum$coefficients[,"Pr(>|z|)"][8],m2sum$coefficients[,"Pr(>|z|)"][8],m3sum$coefficients[,"Pr(>|z|)"][8]), method = 'fdr')
}

# Control model including time of last keypress 
{
mydata$rating <- as.factor(mydata$rating)
model11_clmm <- clmm(rating ~ 1 + zburstrate*lastKeypress + (1|id), 
                     data = mydata)
m11sum <- summary(model11_clmm)
RVAideMemoire::Anova.clmm(model11_clmm, type = "II")

model22_clmm <- clmm(rating ~ 1 + zbetamean*lastKeypress + (1|id), 
                     data = mydata)
m22sum <-summary(model22_clmm)
RVAideMemoire::Anova.clmm(model22_clmm, type = "II")

model33_clmm <- clmm(rating ~ 1 + ztendlast*lastKeypress + (1|id), 
                     data = mydata[mydata$burstcount != 0,])
m33sum <- summary(model33_clmm)
RVAideMemoire::Anova.clmm(model33_clmm, type = "II")

#FDR adjust of beta band values
p.adjust(c(m11sum$coefficients[,"Pr(>|z|)"][8],m22sum$coefficients[,"Pr(>|z|)"][8],m33sum$coefficients[,"Pr(>|z|)"][8],
           m11sum$coefficients[,"Pr(>|z|)"][9],m22sum$coefficients[,"Pr(>|z|)"][9],m33sum$coefficients[,"Pr(>|z|)"][9]), method = 'fdr')

ga <- mydata %>%
  group_by(id,rating) %>%
  summarise(ga_kptime = mean(lastKeypress))

kptime <- ggplot(ga, aes(y = ga_kptime, x = factor(rating), fill = factor(rating))) + 
  geom_bar(stat = 'summary', fun = 'mean', show.legend = FALSE) + 
  geom_hline(yintercept = c(0))+
  stat_summary(fun.data = mean_se, geom = "errorbar", alpha=1, width = 0.2, inherit.aes = TRUE, show.legend = FALSE)+
  labs(x = 'Rating', title = 'KPtime', y = 'Z') + 
  scale_fill_manual(values = colorHot) + 
  theme_classic(base_size = 10)

kptime
}

############################################################################################################################
#Is there an RP - beta amp correlation?
############################################################################################################################

#BY PARTICIPANT 
#Pearson correlation 
allStats <- c()
j = 0
for (i in unique(mydata$ur_id)){
  j = j+1
  thisData <- filter(mydata, ur_id == i)
  stats = cor.test(thisData$RPAmp, thisData$betamean)
  allStats[j] <- unname(stats$estimate)
}

t.test(allStats, paired = FALSE, mu = 0)

#################################
# Figure 3 cde
{
  ga <- mydata %>%
    group_by(id,mean_dicrat) %>%
    summarise(ga_zrpamp = mean(zrpamp),
              ga_zburstrate = mean(zburstrate),
              ga_zbetamean = mean(zbetamean),
              ga_ztendlast = mean(ztendlast, na.rm = T)) 
  
  #Burst rate & ratings - BOXPLOTS
  zburstrate = ggplot(ga, aes(y = ga_zburstrate , x = reorder(mean_dicrat,desc(mean_dicrat)), fill = mean_dicrat)) + 
    geom_boxplot(size = 0.5, show.legend = FALSE) +
    scale_fill_manual(values = c(colorHot[7], colorHot[2]))+
    coord_cartesian(ylim = c(-0.35,0.35))+
    geom_path(mapping=aes(group=id), alpha = .25, show.legend = FALSE) +
    labs(x = 'Rating', title = '', y = 'z-burst rate') + 
    geom_point(show.legend = FALSE) +
    theme_classic(base_size = 10)+
    theme(plot.title = element_text(hjust=0.5))
  
  
  zbetamean = ggplot(ga, aes(y = ga_zbetamean, x = reorder(mean_dicrat,desc(mean_dicrat)), fill = mean_dicrat)) + 
    geom_boxplot(size = 0.5, show.legend = FALSE) +
    geom_path(mapping=aes(group=id), alpha = .25, show.legend = FALSE) +
    coord_cartesian(ylim = c(-0.35,0.35))+
    scale_fill_manual(values = c(colorHot[7], colorHot[2]))+
    labs(x = 'Rating', title = '', y = 'z-beta amp') + 
    geom_point(show.legend = FALSE) +
    theme_classic(base_size = 10)+
    theme(plot.title = element_text(hjust=0.5))
  
  
  ztendlast = ggplot(ga, aes(y = ga_ztendlast, x = reorder(mean_dicrat,desc(mean_dicrat)),, fill = mean_dicrat)) + 
    geom_boxplot(size = 0.5, show.legend = FALSE) +
    geom_path(mapping=aes(group=id), alpha = .25, show.legend = FALSE) +
    coord_cartesian(ylim = c(-0.35,0.35))+
    labs(x = 'Rating', title = '', y = 'z-last burst time') + 
    scale_fill_manual(values = c(colorHot[7], colorHot[2]))+
    geom_point(show.legend = FALSE) +
    theme_classic(base_size = 10)+
    theme(plot.title = element_text(hjust=0.5))
  

  #Burst rate & ratings - BAR GRAPHS
  require(ggplot2)
  ga_burstrate <- ggplot(mydata, aes(y = zburstrate, x = factor(rating), fill = factor(rating))) + 
    geom_bar(stat = 'summary', fun = 'mean', show.legend = FALSE) + 
    geom_hline(yintercept = c(0))+
    coord_cartesian(ylim = c(-0.35,0.35))+
    stat_summary(fun.data = mean_se, geom = "errorbar", alpha=1, width = 0.2, inherit.aes = TRUE, show.legend = FALSE)+
    labs(x = 'Rating', title = 'Burst rate', y = 'z-burst rate') + 
    scale_fill_manual(values = colorHot) + 
    theme_classic(base_size = 10)
  
  ga_betamean <- ggplot(mydata, aes(y = zbetamean, x = factor(rating), fill = factor(rating))) + 
    geom_bar(stat = 'summary', fun = 'mean', show.legend = FALSE) + 
    geom_hline(yintercept = c(0))+
    coord_cartesian(ylim = c(-0.35,0.35))+
    stat_summary(fun.data = mean_se, geom = "errorbar", alpha=1, width = 0.2, inherit.aes = TRUE, show.legend = FALSE)+
    labs(x = 'Rating', title = 'Beta amplitude', y = 'z-beta amp') + 
    scale_fill_manual(values = colorHot) + 
    theme_classic(base_size = 10)
  
  ga_timelast <- ggplot(mydata[mydata$burstcount != 0,], aes(y = ztendlast, x = factor(rating), fill = factor(rating))) + 
    coord_cartesian(ylim = c(-0.30,0.30))+
    geom_bar(stat = 'summary', fun = 'mean', show.legend = FALSE) + 
    geom_hline(yintercept = c(0))+
    stat_summary(fun.data = mean_se, geom = "errorbar", alpha=1, width = 0.2, inherit.aes = TRUE, show.legend = FALSE)+
    labs(x = 'Rating', title = 'Burst time', y = 'z-last burst time') + 
    scale_fill_manual(values = colorHot) + 
    theme_classic(base_size = 10)
  
  
  require(cowplot)
  rate <- plot_grid(ga_burstrate,zburstrate,
                    nrow = 2, 
                    rel_heights = c(1,1), 
                    labels = c('c.'), label_size = 16,
                    align = 'v')
  
  mean <- plot_grid(ga_betamean,zbetamean,  
                    nrow = 2, 
                    rel_heights = c(1,1), 
                    labels = c('d.'), label_size = 16,
                    align = 'v')
  
  time <- plot_grid(ga_timelast, ztendlast,   
                    nrow = 2, 
                    rel_heights = c(1,1), 
                    labels = c('e.'), label_size = 16,
                    align = 'v')
  
  Fig3_cde <- plot_grid(rate,mean,time,
                        ncol = 3,
                        rel_widths= c(1), 
                        align = 'h')
  
  ggsave(paste(dir.figures, 'Fig3_cde_CZ.tiff', sep = ''), Fig3_cde, 
         width = 16, height = 10, units = "cm", dpi = 600)
  
}

