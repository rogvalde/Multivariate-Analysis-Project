#What is inside:
#The function receives cleaned data and compute PCA. The result are plots:
# PC1 and 2 , PC1 and 3, the map.


PCA <- function(data_input=NULL) {

#Copy the dataset
data2 <- cleaned

## FROM PCA excluded are: pop_total, murder_pp, armed_pp, urban_pop_tot, investment_per_of_GDP
#it is because they spoil correlation between variables and as such more PC would be needed to explain
#the relation.

#Select interesting columns
data2 <- select(data2,'continent', 'country',
                'phones_p100','children_p_woman','life_exp_yrs',
                'suicide_pp',
                'sex_ratio_p100',
                'corruption_CPI','internet_%of_pop','child_mort_p1000','income_per_person'
                ,'gini'
                )

#Change colnames
colnames(data2)[which(colnames(data2) %in% c(
  "phones_p100", "children_p_woman","life_exp_yrs","suicide_pp","sex_ratio_p100",
  "corruption_CPI","internet_%of_pop","child_mort_p1000","income_per_person",
  "gini") )] <- c("PHONES","CHILDREN","LIFE EXP.","SUICIDE","SEX RATIO","LESS CORRUPTION", 
                  "INTERNET","CHILD MORT.","INCOME","INEQUALITY")

## Scale only column 3 to 10 (exclude columns with names)
data2[,c(3:10)] <- lapply(data2[,c(3:10)], function(x) c(scale(x)))

# Put column 'countries' as rownames
row.names(data2) <- data2$country

#Perform PCA
pca <- princomp(data2[,c(-1,-2)], cor=T)
summary(pca, loadings=T)

#Plot PCA (before check if you need 'ggibiplot')
#library(devtools)
#install_github("vqv/ggbiplot")
#library(ggbiplot)
plot.pca <- prcomp(data2[,c(-1,-2)], scale. = TRUE)
plot.pca2 <- plot.pca

PCA_plot_12 %<a-% ggbiplot(plot.pca, obs.scale = 1, var.scale = 1,varname.size = 3,
         groups = data2$continent, ellipse = TRUE) +
  scale_color_discrete(name = 'Continents:') +
  theme(legend.direction = 'horizontal', legend.position = 'bottom') + 
  theme(legend.text=element_text(size=10)) 

PCA_plot_13 %<a-% ggbiplot(plot.pca, choices = c(1,3), obs.scale = 1, var.scale = 1,varname.size = 3,
                        groups = data2$continent, ellipse = TRUE) +
  scale_color_discrete(name = 'Continents:') +
  theme(legend.direction = 'horizontal', legend.position = 'bottom') + 
  theme(legend.text=element_text(size=10)) 

## PCA MEANING:
# PC1: Developed countries, HIGH: phones, life exp., less corrup., internet income
# PC2: sex ratio is high, suicide low
# PC3: inequality is high

#Source of biplot:
#https://github.com/vqv/ggbiplot

####### ####### ####### ####### ####### ####### 
####### Print results of PCA on the map ####### 
####### ####### ####### ####### ####### ####### 

#Select what countries are in which PCA

#PC1 the highest
pc1 <- tail(sort(pca$scores[,1]),15) %>% as.data.frame()
pc1$country <- rownames(pc1)
pc1 <- as.vector(unlist(pc1[,2]))

#PC2 the highest
pc2 <- tail(sort(pca$scores[,2]),15) %>% as.data.frame()
pc2$country <- rownames(pc2)
pc2 <- as.vector(unlist(pc2[,2]))

#PC3 the highest
pc3 <- tail(sort(pca$scores[,3]),15) %>% as.data.frame()
pc3$country <- rownames(pc3)
pc3 <- as.vector(unlist(pc3[,2]))

# Creating map
data(wrld_simpl)
#Specify Columns per group
country_colors <- setNames(rep(gray(.80), length(wrld_simpl@data$NAME)), wrld_simpl@data$NAME)
country_colors[wrld_simpl@data$NAME %in% pc1] <-       "#91cf60" #green DEVELOPD ->PC1
country_colors[wrld_simpl@data$NAME %in% pc2] <-       "#fc8d59" #Sex ration & inequality ->PC2 
country_colors[wrld_simpl@data$NAME %in% pc3] <-    "#fee08b" #yellow- inequality is high ->PC3

#Plot the map
PC_plot_map <-   plot(wrld_simpl, col = country_colors) 
PC_plot_map <-  title(main=paste("Top 15 Countries For Each Principal Component"),cex=15) 
PC_plot_map <-  legend(x=-180,y=15, inset=.09, title="",
                                             c("PC1: Developed","PC2: High Sex Ratio", "PC3: High Inequality ","Not in Top 15"), 
                                             fill=c("#91cf60","#fc8d59","#fee08b", gray(.80)), 
                                             horiz=FALSE, cex=1.5, bg="transparent",bty = "n")


ret <- list(PCA_plot_12, PCA_plot_13,PC_plot_map)
return(ret)
}