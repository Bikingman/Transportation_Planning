 getExtension <- function(input) {
    ex <- strsplit(basename(input), split = "\\.")[[1]]
    return(ex[-1])
}