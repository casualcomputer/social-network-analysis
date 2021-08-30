###################################################################################
################################ Import packages ################################## 
###################################################################################

    if (!require(stringr)){
      install.packages("stringr")
      library(stringr)
    }
    
    if (!require(rvest)){ #scraping static websites
      install.packages("rvest")
      library(rvest)
    }

    if (!require(igraph)){
      install.packages("igraph")
      library(igraph)
    }

###################################################################################
################################ Build the  dataset################################ 
###################################################################################
    
    
    
    
# This function appends a vetor to a list
## reference: https://stackoverflow.com/questions/9031819/add-named-vector-to-a-list
    lappend <- function (lst, ...){
      lst <- c(lst, list(...))
      return(lst)
    }

    
    
    
# Take in list of hyperlinks& it gets rid of the invalid ones
    fix_links <- function(hyperlinks,taxAdmin){
      
      # This function can be improved by incorporating a url checker (general function)
      if (length(hyperlinks)!=0 &(taxAdmin == "CRA")){
        
        # Fixing CRA hyperlinks 
        
            if(taxAdmin=="CRA"){
              
              # Condition 1: if the url starts with "/en/", then we can fix the link
              
              logical_vector <-grepl("^/en/", hyperlinks)
              
              for (i in 1:length(logical_vector)){
                  if(logical_vector[i]==TRUE) {
                    replacement_link <-paste('https://www.canada.ca',hyperlinks[i]) # the solution is not really general...
                    hyperlinks[i]<-gsub(" ", "", replacement_link, fixed = TRUE) # strip out white spaces
                  }
              }
              
              # Condition 2: we filter out url's that do not contain the keywords "revenue-agency/"
              logical_vector_2 <- grepl("revenue-agency/", hyperlinks) # should we further restrict the urls? (e.g. https://www.canada.ca/en/services/taxes/income-tax.html)
              hyperlinks<-hyperlinks[logical_vector_2]
              
              # Return links that satisfy the above conditions
              return(hyperlinks)
            }
      
        
      } else {
        cat("Wrong Input for \"fix_links\" function!")
        cat("Your hyperlinks are: ", as.character(hyperlinks))
      }
    }




# Open a given hyperlink to find all related hyperlinks
    get_children_links <- function(hyperlink,taxAdmin){
      #  This uses "rvest": https://www.datacamp.com/community/tutorials/r-web-scraping-rvest
      
      #  Input: an input hyperlink, and tax adminstration
      #  Output: a list of hyperlinks in the main body of the webpage of the input hyperlink
      
      if (length(hyperlink)!=0 & (taxAdmin =="CRA")){
        
        hyperlink <- fix_links(hyperlink,taxAdmin)
        # Read the hyperlink to appropriate formats
            hyperlink <- url(hyperlink, "rb") # if the input is invalid, the function will give an error (but this is okay)
        
            if (taxAdmin %in% list("CRA")){
              related_links <-  read_html(hyperlink)  %>% 
                html_nodes("main")  %>% 
                html_nodes("a")  %>% 
                html_attr("href")
          
              # if bad links exist, we fix them; we return only the good ones
                  if(length(fix_links(related_links,taxAdmin))>0){
                    return(fix_links(related_links,taxAdmin))
                  } else {
                    return(character(0))
                  }
        }  else {
            cat("Invalid Inputs!!")
        }
      }
    }

    
    

# this function builds a representation of the hyperlink tree as a data.frame
    buildTree <- function(start, taxAdmin){
        
        toVisit <- list() #hyperlinks to visit
        results <- as.data.frame(matrix(nrow =0, ncol=3)) # a list of vectors, where each element vector is an observation
        names(results) =  c("from","to", "depth")
        visited <- list(start) # keep track nodes that have been visited 
        toVisit <-lappend(toVisit,list(start, 0)) # keep track of which nodes to visit
        counter <- 0
        
        while (length(toVisit) > 0){
          
          counter <- counter+1 # count the number of updates for the list toVisit
          toVisit_tuple <- toVisit[[1]]
          toVisit <- toVisit[-1]
          depth <- as.numeric(toVisit_tuple[[2]])
          currentDepth <- depth + 1
          
          current_link <- toVisit_tuple[[1]]
          depth <- as.numeric(toVisit_tuple[[2]])
      
          t <- try(get_children_links(current_link,taxAdmin))
          
          if("try-error" %in% class(t)) {
            print('Bad URL!!')
            #do we have to update children?
          } else {
            children <- get_children_links(current_link,taxAdmin)
          }
          
          if (length(children)>0){
            
            ## an empty list called "temp" will be used to update the list "toVisit"
                temp <- list()
            
            ## If the current_hyperlink has any children, we update the list "toVisit" accordingly. 
            ## Else, we remove the toVisit_tuple (that contains the current_hyperlink) from the list "toVisit"
            
                for (child in children){
                  if (!(child%in% visited)){
                      # build a table with three columns: "from", "to", "CurrentDepth"
                      observation <-data.frame(from=current_link, to=child, depth=currentDepth)
                      results <-rbind(results, observation)
                      temp <- lappend(temp, c(child, currentDepth))
                      
                      print(paste('Counter: ', counter))
                      print(paste("Observation: ", observation))
                      print(paste("Number of visited ", length(visited)))
                      print(paste("Percentage finished: ",round(counter/length(visited),2)*100,"%..."))
                      cat('\n')  
                      
                      # if (counter==10){ # this line is used for debugging
                      #   return(results)
                      #   quit()
                      # }
                    
                  }
                  visited <-unique(lappend(visited,child))
                }
                
                ## Update toVisit (replace the currrent_link by its children, from left to right)
                if(length(temp)>0){
                    for (element in toVisit){temp<-lappend(temp,element)}
                    toVisit <- temp
                }
            
          } else {
            #if the current_hyperlink has no children, remove the toVisit_tuple that contains it from the list "toVisit" 
            toVisit <- toVisit[-1]
          }
        }
        print("Program Finished!")
        return(results)
    }

    
    

# Set working directory
    file_path <- # FILL IN THE BLANK HERE! 
    setwd(file_path) # Set the current working directory

# Scrape and save data
    start_url <- "https://www.canada.ca/en/revenue-agency/services/tax/businesses/small-businesses-self-employed-income/checklist-small-businesses.html"
    output_data <- buildTree(start_url, "CRA")

# Rename output file 
    out_file_name <- paste("hyperlinkTraversal",".csv")
    out_file_name<-  gsub(" ", "", out_file_name, fixed = TRUE) 
    write.csv(output_data, out_file_name, row.names = FALSE)

    
    
    
###################################################################################
################################ Load and Visualize ###############################
###################################################################################

# Load dataset (from| to| depth)
    dat_edges <- read.csv("hyperlinkTraversal.csv")
    
# Visualize dataset as a graph
    
    edges_df= dat_edges
    edges_df$from <- as.character(edges_df$from)
    edges_df$to <- as.character(edges_df$to)
    edges_df$depth <- as.numeric(edges_df$depth)
    edges_df_lvl5 <- edges_df[edges_df$depth<10,] # visualize up to level 30
    
    # links_CTP_lvl5$from=="https://www.canada.ca/en/revenue-agency/services/tax/businesses/small-businesses-self-employed-income/checklist-small-businesses.html"
    # links_CTP_lvl5$to=="https://www.canada.ca/en/revenue-agency/services/tax/businesses/small-businesses-self-employed-income/checklist-small-businesses.html"
    # links_CTP_lvl5$from[logi]
    
    output <- edges_df_lvl5[c("from","to")]
    edge_list<- as.matrix(output,matrix.type = "edgelist")
    
    igraph <- graph_from_edgelist(el=edge_list, directed = TRUE) # converts edgelist (matrix) nito igraph object
    V(igraph)$value <- c(1,rep(0,length(V(igraph))-1)) #assign root node value 1, else 0 
    rolecat <- as.factor(get.vertex.attribute(igraph,"value"))
    
    # https://igraph.org/r/doc/plot.common.html
    # https://rstudio-pubs-static.s3.amazonaws.com/337696_c6b008e0766e46bebf1401bea67f7b10.html
    # plot(igraph,
    #      layout=layout_with_kk,
    #      vertex.label=NA,
    #      vertex.size=3,
    #      edge.arrow.size=0.1
    #      )
    
    plot(igraph,
         layout=layout_with_kk, 
         #layout= layout_with_fr, 
         #layout= layout_with_lgl,
         #layout= layout_in_circle,
         vertex.label=NA,
         vertex.size=3,
         edge.arrow.size=0.2,
         vertex.color=c("red",rep("orange",length(V(igraph))-1))
    )
    
    
    