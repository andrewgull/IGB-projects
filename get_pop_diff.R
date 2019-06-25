get_pop_diff <- function(filename, print_tree = FALSE){
  # filename - genalex format file name
  # a function to calculate pairwise Gst (by Hedrick) and D (Jost)
  # and make an unrooted NJ tree
  # both measures are useful to assess population differentiation 
  # using SSR markers with high mutation rates
  library(poppr)
  library(ape)
  #library(phangorn)
  library(mmod)
  
  # calculate differentiation measures
  obj <- read.genalex(filename)
  pw.D <- pairwise_D(obj)
  pw.G <- pairwise_Gst_Hedrick(obj)
  pw.GN <- pairwise_Gst_Nei(obj)
  
  pw.D.df <- as.data.frame(as.matrix(pw.D))
  pw.G.df <- as.data.frame(as.matrix(pw.G))
  pw.GN.df <- as.data.frame(as.matrix(pw.GN))
  
  pw.D.df$measure <- rep("Jost's D", nrow(pw.D.df))
  pw.G.df$measure <- rep("Hedrick's Gst", nrow(pw.G.df))
  pw.GN.df$measure <- rep("Nei's Gst", nrow(pw.GN.df))
  
  out.df <- rbind(pw.G.df, rep('', ncol(pw.G.df)), pw.GN.df, rep('', ncol(pw.GN.df)), pw.D.df)
  write.table(out.df, 'pop_diff_table.csv', sep = '\t', row.names = T)
  
  # make and write trees
  if (length(as.vector(pw.D)) > 1){
    pw.D.tree <- nj(pw.D)
    write.tree(pw.D.tree, 'jost_D_tree.nwk')
    
    pw.G.tree <- nj(pw.G)
    write.tree(pw.G.tree, 'hedrick_G_tree.nwk')
    
    pw.GN.tree <- nj(pw.GN)
    write.tree(pw.GN.tree, 'nei_G_tree.nwk')
    
    # write figures
    if (print_tree){
      png(filename = 'jost_D_tree.png', width = 850, height = 640)
      plot(pw.D.tree)
      dev.off()
      
      png(filename = 'hedrick_G_tree.png', width = 850, height = 640)
      plot(pw.G.tree)
      dev.off()
      
      png(filename = 'nei_G_tree.png', width = 850, height = 640)
      plot(pw.GN.tree)
      dev.off()
    }
    
  } else {
    print('No trees were built: cannot build an unrooted tree with less than 3 observations')
  }
}