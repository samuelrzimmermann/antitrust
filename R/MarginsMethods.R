#' @title Methods for Calculating Diagnostics
#' @name Margins-Methods
#' @docType methods
#'
#' @aliases calcMargins
#' calcMargins,ANY-method
#' calcMargins,AIDS-method
#' calcMargins,Bertrand-method
#' calcMargins,VertBargBertLogit-method
#' calcMargins,LogitCap-method
#' calcMargins,Auction2ndLogit-method
#' calcMargins,Cournot-method
#'
#' @description Computes equilibrium product margins assuming that firms are playing a
#' Nash-Bertrand or Cournot game. For "LogitCap", assumes firms are
#' playing a Nash-Bertrand or Cournot game with capacity constraints.
#'
#' @param object An instance of one of the classes listed above.
#' @param preMerger If TRUE, returns pre-merger outcome. If
#' FALSE, returns post-merger outcome.  Default is TRUE.
#' @param exAnte If \sQuote{exAnte} equals TRUE then the
#' \emph{ex ante} expected result for each firm is produced, while FALSE produces the
#' expected result conditional on each firm winning the auction. Default is FALSE.
#'
#' @include CostMethods.R
#' @keywords methods
NULL

setGeneric (
  name= "calcMargins",
  def=function(object,...){standardGeneric("calcMargins")}
)

## compute margins
#'@rdname Margins-Methods
#'@export
setMethod(
  f= "calcMargins",
  signature= "Bertrand",
  definition=function(object,preMerger=TRUE){



    if( preMerger) {

      owner  <- object@ownerPre
      revenue<- calcShares(object,preMerger,revenue=TRUE)

      elast <-  elast(object,preMerger)
      margins <-  -1 * as.vector(MASS::ginv(t(elast)*owner) %*% (revenue * diag(owner))) / revenue


    }

    else{
      prices <- object@pricePost
      mc     <- object@mcPost

      margins <- 1 - mc/prices
    }


    names(margins) <- object@labels

    return(as.vector(margins))
  }

)

#'@rdname Margins-Methods
#'@export
setMethod(
  f= "calcMargins",
  signature= "VertBargBertLogit",
  definition=function(object,preMerger=TRUE){
    
    up <- object@up
    down <- object@down
    alpha <- down@slopes$alpha
    
   
    bargparm <- up@bargpower
    
    if( preMerger) {
      
      ownerUp  <- up@ownerPre
      if(length(up@pricePre) == 0 ){
      priceUp <- up@prices
      }
      else{priceUp <- up@prices}
      
      ownerDown  <- down@ownerPre
      if(length(down@pricePre) == 0 ){
        priceDown <- down@prices
        down@pricePre <- priceDown
      }
      else{priceDown <- down@prices}
      
      down@mcPre <- down@mcPre + priceUp
      marginsDown <- calcMargins(down, preMerger=preMerger )
      
      
      div <- diversion(down,  preMerger=preMerger)
      
      
      
      marginsUp <- (1-bargparm)/bargparm * as.vector(solve(ownerUp * div) %*% (ownerDown * div) %*% (marginsDown*priceDown)) #margins in levels
      marginsUp <- marginsUp/priceUp
     
      
      
    }
    
    else{
      priceUp <- up@pricePost
      mcUp     <- up@mcPost
      priceDown <- down@pricePost
      mcDown     <- down@mcPost + priceUp
      
      marginsUp <- 1 - mcUp/priceUp
      marginsDown <- 1 - mcDown/priceDown
    }
    
    
    
    names(marginsUp) <- up@labels
    names(marginsDown) <- down@labels
    
    return(list(up=as.vector(marginsUp), down = as.vector(marginsDown))
           )
  }
  
)


#'@rdname Margins-Methods
#'@export
setMethod(
  f= "calcMargins",
  signature= "Auction2ndCap",
  definition=function(object,preMerger=TRUE,exAnte=TRUE){

    result <- calcProducerSurplus(object,preMerger=preMerger,exAnte=exAnte)/calcPrices(object,preMerger=preMerger,exAnte=exAnte)
    return(result)
  })

## compute margins
#'@rdname Margins-Methods
#'@export
setMethod(
  f= "calcMargins",
  signature= "Cournot",
  definition=function(object,preMerger=TRUE){


    if(preMerger){
      prices <- object@pricePre
    }
    else{prices <- object@pricePost}

    mc <- calcMC(object,preMerger = preMerger)
    prices <- matrix(prices, ncol=length(prices), nrow=length(mc),byrow=TRUE)



    margin <- 1 - mc/prices


    dimnames(margin) <- object@labels
    return(margin)
  }

)


#'@rdname Margins-Methods
#'@export
setMethod(
  f= "calcMargins",
  signature= "AIDS",
  definition=function(object,preMerger=TRUE){

    priceDelta <- object@priceDelta
    ownerPre   <- object@ownerPre
    shares     <- calcShares(object,TRUE)

    elastPre <-  t(elast(object,TRUE))
    marginPre <-  -1 * as.vector(MASS::ginv(elastPre * ownerPre) %*% (shares * diag(ownerPre))) / shares

    if(preMerger){
      names(marginPre) <- object@labels
      return(marginPre)}

    else{

      marginPost <- 1 - ((1 + object@mcDelta) * (1 - marginPre) / (priceDelta + 1) )
      names(marginPost) <- object@labels
      return(marginPost)
    }

  }
)

## compute margins
#'@rdname Margins-Methods
#'@export
setMethod(
  f= "calcMargins",
  signature= "LogitCap",
  definition=function(object,preMerger=TRUE){

    margins <- object@margins #capacity-constrained margins not identified -- use supplied margins

    if( preMerger) {
      capacities <- object@capacitiesPre

    }
    else{

      capacities <- object@capacitiesPost
    }



    quantities <- calcQuantities(object, preMerger=TRUE)
    constrained <-  abs(capacities - quantities) < 1e-5

    owner  <- object@ownerPre
    revenue<- calcShares(object,preMerger,revenue=TRUE)[!constrained]
    elast <-  elast(object,preMerger)
    margins[!constrained] <-  -1 * as.vector(MASS::ginv(t(elast*owner)[!constrained,!constrained]) %*% revenue) / revenue



    names(margins) <- object@labels

    return(as.vector(margins))
  }

)

## compute margins
#'@rdname Margins-Methods
#'@export
setMethod(
  f= "calcMargins",
  signature= "Auction2ndLogit",
  definition=function(object,preMerger=TRUE,exAnte=FALSE){


    nprods <- length(object@shares)
    subset <- object@subset
   
    margins <- rep(NA,nprods)

    if( preMerger) {
      owner  <- object@ownerPre}
    else{
      owner  <- object@ownerPost}


    owner <- owner[subset,subset]


    alpha <- object@slopes$alpha
    shares <- calcShares(object,preMerger=preMerger,revenue=FALSE)
    shares <- shares[subset]
    firmShares <- drop(owner %*% shares)
    margins[subset] <-  log(1-firmShares)/(alpha * firmShares)

    if(exAnte){ margins <-  margins * shares}

    names(margins) <- object@labels

    return(as.vector(margins))
  }

)
