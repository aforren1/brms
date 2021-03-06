% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/formula-helpers.R
\name{gp}
\alias{gp}
\title{Set up Gaussian process terms in \pkg{brms}}
\usage{
gp(..., cov = "exp_quad", scale = TRUE)
}
\arguments{
\item{...}{One or more predictors for the Gaussian process.}

\item{cov}{Name of the covariance kernel. By default, 
the exponentiated-quadratic kernel \code{"exp_quad"} is used.}

\item{scale}{Logical; If \code{TRUE} (the default), predictors are
scaled so that the maximum Euclidean distance between two points
is 1. Since the default prior on \code{lscale} expects scaled
predictors, it is recommended to manually specify priors
on \code{lscale}, if \code{scale} is set to \code{FALSE}.}
}
\value{
An object of class \code{'gpterm'}, which is a list 
  of arguments to be interpreted by the formula 
  parsing functions of \code{brms}.
}
\description{
Function used to set up a Gaussian process term in \pkg{brms}.
The function does not evaluate its arguments --
it exists purely to help set up a model with Gaussian process terms.
}
\details{
A Gaussian process is a stochastic process, whichs
 describes the relation between one or more predictors 
 \eqn{x = (x_1, ..., x_d)} and a response \eqn{f(x)}, where 
 \eqn{d} is the number of predictors. A Gaussian process is the
 generalization of the multivariate normal distribution
 to an infinite number of dimensions. Thus, it can be
 interpreted as a prior over functions. Any finite sample 
 realized from this stochastic process is jointly multivariate 
 normal, with a covariance matrix defined by the covariance
 kernel \eqn{k_p(x)}, where \eqn{p} is the vector of parameters
 of the Gaussian process:
 \deqn{f(x) ~ MVN(0, k_p(x))}
 The smoothness and general behavior of the function \eqn{f} 
 depends only on the choice of covariance kernel. 
 For a more detailed introduction to Gaussian processes,
 see \url{https://en.wikipedia.org/wiki/Gaussian_process}.
 
 Below, we describe the currently supported covariance kernels:
 \itemize{
   \item{"exp_quad": }{The exponentiated-quadratic kernel is defined as
   \eqn{k(x_i, x_j) = sdgp^2 exp(- || x_i - x_j || / (2 lscale^2)},
   where \eqn{|| . ||} is the Euclidean norm, \eqn{sdgp} is a 
   standard deviation parameter, and \eqn{lscale} is characteristic 
   length-scale parameter. The latter practically measures how close two 
   points \eqn{x_i} and \eqn{x_j} have to be to influence each other 
   substantially.}
 }

 In the current implementation, only a single predictor can be 
 passed, and \code{"exp_quad"} is the only supported 
 covariance kernel. More options will follow in the future.
}
\examples{
\dontrun{
# simulate data using the mgcv package
dat <- mgcv::gamSim(1, n = 30, scale = 2)

# fit a simple gaussian process model
fit1 <- brm(y ~ gp(x2), dat)
summary(fit1)
me1 <- marginal_effects(fit1, nsamples = 200, spaghetti = TRUE)
plot(me1, ask = FALSE, points = TRUE)

# fit a more complicated gaussian process model
fit2 <- brm(y ~ gp(x0) + x1 + gp(x2) + x3, dat)
summary(fit2)
me2 <- marginal_effects(fit2, nsamples = 200, spaghetti = TRUE)
plot(me2, ask = FALSE points = TRUE)

# compare model fit
LOO(fit1, fit2)
}

}
\seealso{
\code{\link[brms:brmsformula]{brmsformula}}
}
