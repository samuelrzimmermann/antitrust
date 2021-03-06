% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/BargainingClasses.R
\docType{class}
\name{Bargaining-Class}
\alias{Bargaining-Class}
\title{\dQuote{Bargaining} Classes}
\description{
The \dQuote{Bargaining} class is a building block used to create other classes
in this package. As such, it is most likely to be useful for developers
who wish to code their own calibration/simulation routines.

Let k denote the number of products produced by all firms below.
}
\section{Slots}{

\describe{
\item{\code{bargpowerPre}}{A length k vector of pre-merger bargaining power parameters.}

\item{\code{bargpowerPre}}{A length k vector of post-merger bargaining power parameters.}

\item{\code{prices}}{A length k vector of of observes prices.}

\item{\code{margins}}{A length k vector of of observes margins.}
}}

\section{Objects from the Class}{

Objects can be created by calls of the form \code{new("Bargaining", ...)}.
}

