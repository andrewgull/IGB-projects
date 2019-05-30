make_standard_table <- function(filename, outfilename){
  library(poppr)
  library(ape)
  #library(hierfstat)
  #library(data.table)
  library(dplyr)
  library(tidyr)
  
  liz <- read.genalex(filename)
  pop.sub.sum <- lapply(unique(liz$pop), function(x){summary(popsub(liz, x))})
  names(pop.sub.sum) <- unique(liz$pop)
  
  # allelic richness
  liz2 <- read.csv(filename, skip = 2)
  liz2 <- liz2[,c(2:ncol(liz2))]
  
  # reformatting for Allelic richness computation
  ar.unite <- function(raw.table){
    # function to unite columns
    raw.table.list <- lapply(seq(2, ncol(raw.table), 2), function(i){as.integer(paste(raw.table[,i], raw.table[,i+1], sep=''))})
    names(raw.table.list) <- names(raw.table)[seq(2, ncol(raw.table), 2)]
    raw.table.list$pop <- raw.table[,1]
    raw.table.unite <- as.data.frame(raw.table.list)
    raw.table.unite <- raw.table.unite[,c(ncol(raw.table.unite), c(1:(ncol(raw.table.unite)-1)))]
    return(raw.table.unite)
  }
  
  ar.reformat <- function(ar.object, raw.table){
    # function to make pretty AR table
    ar.object <- ar.object$Ar
    colnames(ar.object) <- unique(raw.table$Pop)
    ar.object <- as.data.frame(ar.object)
    ar.object$locus <- rownames(ar.object)
    ar.object <- ar.object[,c(ncol(ar.object),c(1:(ncol(ar.object)-1)))]
    ar.object <- gather(ar.object, 'pop', 'AR', 2:ncol(ar.object))
    return(ar.object)
  }
  
  # unite columns using my function
  liz2unite <- ar.unite(liz2)
  
  # compute raw allelic richness
  all.rich <- hierfstat::allelic.richness(liz2unite)
  
  # refromat it properly
  all.rich <- ar.reformat(all.rich, liz2)
  
  # DEAl WITH TOTAL AR
  liz2.total <- liz2
  liz2.total$Pop <- rep('total', nrow(liz2.total))
  # unite columns
  liz2.total.unite <- ar.unite(liz2.total)
  # compute raw AR
  all.rich.total <- hierfstat::allelic.richness(liz2.total.unite)
  # make proper table
  all.rich.total <- ar.reformat(all.rich.total, liz2.total)
  
  # GET THE REST OF DATA FOR 'TOTAL' ROW
  tot.sum <- summary(liz)
  tot.out <- data.frame('N.alleles'=tot.sum$loc.n.all, 'H.exp'=tot.sum$Hexp, 'Hobs'=tot.sum$Hobs)
  tot.out$pop <-  rep('total', nrow(tot.out))
  tot.out$locus <- rownames(tot.out)
  # JOIN WITH AR
  tot.out <- full_join(tot.out, all.rich.total, by=c('locus', 'pop'))
  tot.out <- tot.out[,c(5,4,1,2,3,6)]
  
  # MAKE FINAL TABLE for each population
  out.df.list <- lapply(c(1:length(pop.sub.sum)), function(i){
    f <- data.frame('N.alleles'=pop.sub.sum[[i]]$loc.n.all, 'H.exp'=pop.sub.sum[[i]]$Hexp, 'Hobs'=pop.sub.sum[[i]]$Hobs)
    f$pop <-  rep(names(pop.sub.sum)[i], nrow(f))
    f$locus <- rownames(f)
    return(f)
  })
  
  out.df <- data.table::rbindlist(out.df.list)
  out.df <- as.data.frame(out.df)[,c(ncol(out.df), ncol(out.df)-1, c(1:(ncol(out.df)-2)))]
  
  # ADD Allelic richness
  out.df <- full_join(out.df, all.rich, by=c('locus', 'pop'))
  
  # ADD MEANS AND SE, AND TOTAL
  # SE = SD/SQRT(n)
  out.df.list <- split.data.frame(out.df, out.df$locus)
  tot.out.list <- split.data.frame(tot.out, f = tot.out$locus)
  lst.names <- c(1:length(tot.out.list))
  
  # JOIN ROWS WITh MEAN, SE and TOTAL
  final.out.list <- lapply(lst.names, function(x){
    means <- apply(out.df.list[[x]][,3:length(out.df.list[[x]])], 2, function(z){mean(z)})
    errors <- apply(out.df.list[[x]][,3:length(out.df.list[[x]])], 2, function(z){sd(z)/sqrt(nrow(out.df.list[[x]]))})
    out.df.list[[x]] <- rbind(out.df.list[[x]], c('mean', NA, means))
    out.df.list[[x]] <- rbind(out.df.list[[x]], c('SE', NA, errors))
    out.df.list[[x]] <- rbind(out.df.list[[x]], tot.out.list[[x]])
    # add empty rows
    out.df.list[[x]] <- rbind(out.df.list[[x]], rep('', ncol(out.df.list[[x]])))
    return(out.df.list[[x]])
  })
  
  final.out <- data.table::rbindlist(final.out.list)
  
  write.table(final.out, outfilename, row.names = F, na='')
  
}
