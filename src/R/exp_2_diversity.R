files <- list.files(path=path, pattern = "*.csv")
file_list <- sort(files)

for(i in file_list){
  a<-read.csv(paste(path, i, sep="/"))
  a1<-a%>%
    group_by(treatment_nr., SVt,BBt,Dt, simulation_nr,censusyear)%>%
    summarize(D_shannon=diversity(N_present, index = "shannon"),
              D_simpson=diversity(N_present, index = "simpson"))%>%
    mutate(H_shannon=exp(D_shannon), H_simpson=1/(1-D_simpson))
  a2<-a%>%
    group_by(treatment_nr., SVt,BBt,Dt, simulation_nr,censusyear)%>%
    filter(N_present>0)%>%
    summarize(H_species_richness=length(unique(species)))
  a1$D_species_richness=a2$H_species_richness
  filename=paste("divest", gsub(".csv","",i), ".csv", sep="")
  pathout="/Users/Armand/Desktop/BCI\ for\ distribution_new/Figure2I_J"
  write.csv(a1, file.path(pathout, filename), row.names=FALSE)
  print(i)
}
