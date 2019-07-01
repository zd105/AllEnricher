
if(require("RCurl")){
    cat("Package RCurl loading successed...\n")
} else {
    cat("Package RCurl has not been installed, trying installing...")
    install.packages("RCurl")
    if(require("RCurl")){
        cat("Package RCurl installing succssed!")
    } else {
        cat("Package RCurl installation failed!")
    }
}

if(require("XML")){
    cat("Package XML loading successed...\n")
} else {
    cat("Package XML has not been installed, trying installing...")
    install.packages("XML")
    if(require("XML")){
        cat("Package XML installing succssed!")
    } else {
        stop("Package XML installation failed!")
    }
}

if(require("ggplot2")){
    cat("Package ggplot2 loading successed...\n")
} else {
    cat("Package ggplot2 has not been installed, trying installing...")
    install.packages("ggplot2")
    if(require("ggplot2")){
        cat("Package ggplot2 installing succssed!")
    } else {
        stop("Package ggplot2 installation failed!")
    }   
}

