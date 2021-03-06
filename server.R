library(shiny)

shinyServer(function(input, output) {
  
  data <- reactive({      
    if (input$dist=="rpois") {
      vals <-  do.call(input$dist, list(n=input$n, lambda=1))
    }
    else {
      vals <-  do.call(input$dist, list(n=input$n))
    }
    return (list(fun=input$dist, vals=vals))
  })
  
  output$plot <- renderPlot({
    distname <- switch(input$dist,
                       rexp = "Exponential distribution", # (n = ",
                       rnorm = "Normal distribution", # (n = ",
                       rlnorm = "Log-normal distribution", # (n = ",
                       runif = "Uniform distribution", # (n = ",
                       rpois = "Poisson distribution",
                       rcauchy = "Cauchy distribution") # (n = ")
    
    n <- input$n
    k <- input$k
    pdist <- data()$vals

    if (input$dist=="rpois") {
      x <- replicate(k, do.call(input$dist, list(n=n, lambda=1)))
    }
    else {
      x <- replicate(k, do.call(input$dist, list(n=n)))
    }
    ndist <- rowMeans(x)
    expect <- switch(input$dist,
                     rexp = c(1^-1, 1^-2),
                     rnorm = c(0, 1),
                     rlnorm = c(exp(0+(1/2)*1^2), exp(0 + 1^2)*(exp(1^2)-1)),
                     runif = c(0.5, (1/12)*1),
                     rpois =c(1, 1),
                     rcauchy = rep(NA, 2))
    obs <- data.frame(pdist=c(mean(pdist), var(pdist)), ndist=c(mean(ndist), 
                                                                var(ndist)))
                      
    par(mfrow=c(2,1))
    pdens=density(pdist)
    phist=hist(pdist, freq=FALSE, plot=FALSE)
    hist(pdist, main=paste(n, " observations from ", distname, sep=""), 
         xlab="Values", freq=FALSE, ylim=c(0, max(pdens$y, phist$density)))
    lines(pdens, col="red", lwd=2)
    abline(v=obs$pdist[1], col="blue", lwd=2, lty=2)
    abline(v=expect[1], col="red", lwd=2, lty=2)
    legend(x="topright", col=c("blue", "red"), lwd=2, lty=2, 
           legend=c("Observed", "Expected"))
    box()

    ndens=density(ndist)
    nhist=hist(ndist, freq=FALSE, plot=FALSE)
    hist(ndist, main=paste("Distribution of mean values from ", k, 
                           " random variables each\nconsisting of ", n, 
                           " observations from ", distname, sep=""), 
         xlab="Values", freq=FALSE, ylim=c(0, max(ndens$y, nhist$density)))
    lines(ndens, col="red", lwd=2)
    abline(v=obs$ndist[1], col="blue", lwd=2, lty=2)
    abline(v=expect[1], col="red",  lwd=2, lty=2)
    legend(x="topright", col=c("blue", "red"), lwd=2, lty=2, 
           legend=c("Observed", "Expected"))
    box()
  
  })
})
