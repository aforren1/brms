% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/priors.R
\name{set_prior}
\alias{set_prior}
\alias{prior}
\alias{prior_}
\alias{prior_string}
\title{Prior Definitions for \pkg{brms} Models}
\usage{
set_prior(prior, class = "b", coef = "", group = "", nlpar = "",
  resp = NULL, lb = NULL, ub = NULL, check = TRUE)

prior(prior, ...)

prior_(prior, ...)

prior_string(prior, ...)
}
\arguments{
\item{prior}{A character string defining a distribution in \pkg{Stan} language}

\item{class}{The parameter class. Defaults to \code{"b"} 
(i.e. population-level effects). 
See 'Details' for other valid parameter classes.}

\item{coef}{Name of the (population- or group-level) parameter.}

\item{group}{Grouping factor of group-level parameters.}

\item{nlpar}{Name of a non-linear / auxiliary parameter. 
Only used in non-linear / distributional models.}

\item{resp}{Name of the response variable / category.
Only used in multivariate and categorical models.
Is internally handled as an alias of \code{nlpar}.}

\item{lb}{Lower bound for parameter restriction. Currently only allowed
for classes \code{"b"}, \code{"ar"}, \code{"ma"}, and \code{"arr"}.
Defaults to \code{NULL}, that is no restriction.}

\item{ub}{Upper bound for parameter restriction. Currently only allowed
for classes \code{"b"}, \code{"ar"}, \code{"ma"}, and \code{"arr"}.
Defaults to \code{NULL}, that is no restriction.}

\item{check}{Logical; Indicates whether priors
should be checked for validity (as far as possible).
Defaults to \code{TRUE}. If \code{FALSE}, \code{prior} is passed
to the Stan code as is, and all other arguments are ignored.}

\item{...}{Arguments passed to \code{set_prior}.}
}
\value{
An object of class \code{brmsprior} to be used in the \code{prior}
  argument of \code{\link[brms:brm]{brm}}.
}
\description{
Define priors for specific parameters or classes of parameters
}
\details{
\code{set_prior} is used to define prior distributions for parameters 
  in \pkg{brms} models. The functions \code{prior}, \code{prior_}, and
  \code{prior_string} are aliases of \code{set_prior} each allowing
  for a differnt kind of argument specification. 
  \code{prior} allows specifying arguments as expression without
  quotation marks using non-standard evaluation. 
  \code{prior_} allows specifying arguments as one-sided formulas
  or wrapped in \code{quote}.
  \code{prior_string} allows specifying arguments as strings just
  as \code{set_prior} itself.
  
  Below, we explain its usage and list some common 
  prior distributions for parameters. 
  A complete overview on possible prior distributions is given 
  in the Stan Reference Manual available at \url{http://mc-stan.org/}.
  
  To combine multiple priors, use \code{c(...)}, 
  e.g., \code{c(set_prior(...), set_prior(...))}.
  \pkg{brms} does not check if the priors are written in correct \pkg{Stan} language. 
  Instead, \pkg{Stan} will check their syntactical correctness when the model 
  is parsed to \code{C++} and returns an error if they are not. 
  This, however, does not imply that priors are always meaningful if they are 
  accepted by \pkg{Stan}. Although \pkg{brms} trys to find common problems 
  (e.g., setting bounded priors on unbounded parameters), there is no guarantee 
  that the defined priors are reasonable for the model.
  Currently, there are seven types of parameters in \pkg{brms} models, 
  for which the user can specify prior distributions. \cr
  
  1. Population-level ('fixed') effects
  
  Every Population-level effect has its own regression parameter 
  represents the name of the corresponding population-level effect. 
  Suppose, for instance, that \code{y} is predicted by \code{x1} and \code{x2} 
  (i.e., \code{y ~ x1 + x2} in formula syntax). 
  Then, \code{x1} and \code{x2} have regression parameters 
  \code{b_x1} and \code{b_x2} respectively. 
  The default prior for population-level effects (including monotonic and 
  category specific effects) is an improper flat prior over the reals. 
  Other common options are normal priors or student-t priors. 
  If we want to have a normal prior with mean 0 and 
  standard deviation 5 for \code{x1}, and a unit student-t prior with 10 
  degrees of freedom for \code{x2}, we can specify this via
  \code{set_prior("normal(0,5)", class = "b", coef = "x1")} and \cr
  \code{set_prior("student_t(10,0,1)", class = "b", coef = "x2")}.
  To put the same prior on all population-level effects at once, 
  we may write as a shortcut \code{set_prior("<prior>", class = "b")}. 
  This also leads to faster sampling, because priors can be vectorized in this case. 
  Both ways of defining priors can be combined using for instance 
  \code{set_prior("normal(0,2)", class = "b")} and \cr
  \code{set_prior("normal(0,10)", class = "b", coef = "x1")}
  at the same time. This will set a \code{normal(0,10)} prior on 
  the effect of \code{x1} and a \code{normal(0,2)} prior 
  on all other population-level effects. 
  However, this will break vectorization and
  may slow down the sampling procedure a bit.
  
  In case of the default intercept parameterization 
  (discussed in the 'Details' section of 
  \code{\link[brms:brmsformula]{brmsformula}}),
  general priors on class \code{"b"} will not affect the intercept.
  Instead, the intercept has its own parameter class 
  named \code{"Intercept"} and priors can thus be 
  specified via \code{set_prior("<prior>", class = "Intercept")}.
  Setting a prior on the intercept will not break vectorization
  of the other population-level effects.
  Note that technially, this prior is set on an intercept that
  results when internally centering all population-level predictors 
  around zero to improve sampling efficiency. On this centered 
  intercept, specifying a prior is actually much easier and 
  intuitive than on the original intercept, since the former 
  represents the expected response value when all predictors 
  are at their means. To treat the intercept as an ordinary 
  population-level effect and avoid the centering parameterization, 
  use \code{0 + intercept} on the right-hand side of the model formula.
  
  A special shrinkage prior to be applied on population-level effects 
  is the horseshoe prior (Carvalho et al., 2009).
  It is symmetric around zero with fat tails and an infinitely large spike
  at zero. This makes it ideal for sparse models that have 
  many regression coefficients, although only a minority of them is non-zero. 
  The horseshoe prior can be applied on all population-level effects at once 
  (excluding the intercept) by using \code{set_prior("horseshoe(1)")}.
  The \code{1} implies that the student-t prior of the local shrinkage 
  parameters has 1 degrees of freedom. This may, however, lead to an 
  increased number of divergent transition in \pkg{Stan}.
  Accordingly, increasing the degrees of freedom to slightly higher values 
  (e.g., \code{3}) may often be a better option, although the prior 
  no longer resembles a horseshoe in this case. 
  Further, the scale of the global shrinkage parameter plays an important role
  in amount of shrinkage applied. It defaults to \code{1},
  but this may result in too few shrinkage (Piironen & Vehtari, 2016).
  It is thus possible to change the scale using argument \code{scale_global}
  of the horseshoe prior, for instance \code{horseshoe(1, scale_global = 0.5)}.
  In linear models, \code{scale_global} will internally be multiplied by the 
  residual standard deviation parameter \code{sigma}. See Piironen and 
  Vehtari (2016) for recommendations how to properly set the global scale.
  The degrees of freedom of the global shrinkage prior may also be 
  adjusted via argument \code{df_global}. 
  To make sure that shrinkage can equally affect all coefficients, 
  predictors should be one the same scale. 
  Generally, models with horseshoe priors a more likely than other models
  to have divergent transitions so that increasing \code{adapt_delta} 
  from \code{0.8} to values closer to \code{1} will often be necessary.
  See the documentation of \code{\link[brms:brm]{brm}} for instructions
  on how to increase \code{adapt_delta}. \cr
  
  Another shrinkage prior is the so-called \emph{lasso} prior.
  It is the Bayesian equivalent to the LASSO method for performing
  variable selection (Park & Casella, 2008).
  With this prior, independent Laplace (i.e. double exponential) priors 
  are placed on the population-level effects. 
  The scale of the Laplace priors depends on a tuning parameter
  that controls the amount of shrinkage. In \pkg{brms}, the inverse
  of the tuning parameter is used so that smaller values imply
  more shrinkage. The inverse tuning parameter has a chi-square distribution
  and with degrees of freedom controlled via argument \code{df}
  of function \code{lasso} (defaults to \code{1}). For instance,
  one can specify a lasso prior using \code{set_prior("lasso(1)")}.
  To make sure that shrinkage can equally affect all coefficients, 
  predictors should be one the same scale.
  If you do not want to standarized all variables,
  you can adjust the general scale of the lasso prior via argument
  \code{scale}, for instance, \code{lasso(1, scale = 10)}.
  
  In non-linear models, population-level effects are defined separately 
  for each non-linear parameter. Accordingly, it is necessary to specify
  the non-linear parameter in \code{set_prior} so that priors
  we can be assigned correctly. 
  If, for instance, \code{alpha} is the parameter and \code{x} the predictor
  for which we want to define the prior, we can write
  \code{set_prior("<prior>", coef = "x", nlpar = "alpha")}. 
  As a shortcut we can use \code{set_prior("<prior>", nlpar = "alpha")}
  to set the same prior on all population-level effects of \code{alpha} at once.
  
  If desired, population-level effects can be restricted to fall only 
  within a certain interval using the \code{lb} and \code{ub} arguments
  of \code{set_prior}. This is often required when defining priors
  that are not defined everywhere on the real line, such as uniform
  or gamma priors. When defining a \code{uniform(2,4)} prior, 
  you should write \code{set_prior("uniform(2,4)", lb = 2, ub = 4)}. 
  When using a prior that is defined on the postive reals only 
  (such as a gamma prior) set \code{lb = 0}. 
  In most situations, it is not useful to restrict population-level
  parameters through bounded priors 
  (non-linear models are an important exception), 
  but if you really want to this is the way to go.
  
  2. Standard deviations of group-level ('random') effects
  
  Each group-level effect of each grouping factor has a standard deviation named
  \code{sd_<group>_<coef>}. Consider, for instance, the formula 
  \code{y ~ x1 + x2 + (1 + x1 | g)}.
  We see that the intercept as well as \code{x1} are group-level effects
  nested in the grouping factor \code{g}. 
  The corresponding standard deviation parameters are named as 
  \code{sd_g_Intercept} and \code{sd_g_x1} respectively. 
  These parameters are restriced to be non-negative and, by default, 
  have a half student-t prior with 3 degrees of freedom and a 
  scale parameter that depends on the standard deviation of the response 
  after applying the link function. Minimally, the scale parameter is 10. 
  This prior is used (a) to be only very weakly informative in order to influence
  results as few as possible, while (b) providing at least some regularization
  to considerably improve convergence and sampling efficiency.
  To define a prior distribution only for standard deviations 
  of a specific grouping factor,
  use \cr \code{set_prior("<prior>", class = "sd", group = "<group>")}. 
  To define a prior distribution only for a specific standard deviation 
  of a specific grouping factor, you may write \cr
  \code{set_prior("<prior>", class = "sd", group = "<group>", coef = "<coef>")}. 
  Recommendations on useful prior distributions for 
  standard deviations are given in Gelman (2006), but note that he
  is no longer recommending uniform priors, anymore. \cr
  
  When defining priors on group-level parameters in non-linear models, 
  please make sure to specify the corresponding non-linear parameter 
  through the \code{nlpar} argument in the same way as 
  for population-level effects.
  
  3. Correlations of group-level ('random') effects 
  
  If there is more than one group-level effect per grouping factor, 
  the correlations between those effects have to be estimated. 
  The prior \code{"lkj_corr_cholesky(eta)"} or in short 
  \code{"lkj(eta)"} with \code{eta > 0} 
  is essentially the only prior for (Cholesky factors) of correlation matrices. 
  If \code{eta = 1} (the default) all correlations matrices 
  are equally likely a priori. If \code{eta > 1}, extreme correlations 
  become less likely, whereas \code{0 < eta < 1} results in 
  higher probabilities for extreme correlations. 
  Correlation matrix parameters in \code{brms} models are named as 
  \code{cor_<group>}, (e.g., \code{cor_g} if \code{g} is the grouping factor).
  To set the same prior on every correlation matrix, 
  use for instance \code{set_prior("lkj(2)", class = "cor")}.
  Internally, the priors are transformed to be put on the Cholesky factors
  of the correlation matrices to improve efficiency and numerical stability.
  The corresponding parameter class of the Cholesky factors is \code{L},
  but it is not recommended to specify priors for this parameter class directly.
  
  4. Standard deviations of smoothing terms
  
  GAMMs are implemented in \pkg{brms} using the 'random effects' 
  formulation of smoothing terms (for details see 
  \code{\link[mgcv:gamm]{gamm}}). Thus, each smoothing term
  has its corresponding standard deviation modeling
  the variability within this term. In \pkg{brms}, this 
  parameter class is called \code{sds} and priors can
  be specified via \code{set_prior("<prior>", class = "sds", 
  coef = "<term label>")}. The default prior is the same as
  for standard deviations of group-level effects.
  
  5. Autocorrelation parameters
  
  The autocorrelation parameters currently implemented are named 
  \code{ar} (autoregression), \code{ma} (moving average),
  and \code{arr} (autoregression of the response).
  
  Priors can be defined by \code{set_prior("<prior>", class = "ar")} 
  for \code{ar} and similar for \code{ma} and \code{arr} effects.
  By default, \code{ar} and \code{ma} are bounded between \code{-1} 
  and \code{1} and \code{arr} is unbounded (you may change this 
  by using the arguments \code{lb} and \code{ub}). The default
  prior is flat over the definition area.
  
  6. Distance parameters of monotonic effects
  
  As explained in the details section of \code{\link[brms:brm]{brm}},
  monotonic effects make use of a special parameter vector to
  estimate the 'normalized distances' between consecutive predictor 
  categories. This is realized in \pkg{Stan} using the \code{simplex}
  parameter type and thus this class is also named \code{"simplex"} in
  \pkg{brms}. The only valid prior for simplex parameters is the
  dirichlet prior, which accepts a vector of length \code{K - 1}
  (K = number of predictor categories) as input defining the
  'concentration' of the distribution. Explaining the dirichlet prior 
  is beyond the scope of this documentation, but we want to describe
  how to define this prior syntactically correct.
  If a predictor \code{x} with \code{K} categories is modeled as monotonic, 
  we can define a prior on its corresponding simplex via \cr
  \code{set_prior("dirichlet(<vector>)", class = "simplex", coef = "x")}.
  For \code{<vector>}, we can put in any \code{R} expression
  defining a vector of length \code{K - 1}. The default is a uniform 
  prior (i.e. \code{<vector> = rep(1, K-1)}) over all simplexes
  of the respective dimension.   
  
  7. Parameters for specific families 
  
  Some families need additional parameters to be estimated. 
  Families \code{gaussian}, \code{student}, and \code{cauchy} 
  need the parameter \code{sigma} 
  to account for the residual standard deviation.
  By default, \code{sigma} has a half student-t prior that scales 
  in the same way as the group-level standard deviations.
  Furthermore, family \code{student} needs the parameter 
  \code{nu} representing the degrees of freedom of students-t distribution. 
  By default, \code{nu} has prior \code{"gamma(2,0.1)"}
  and a fixed lower bound of \code{0}.
  Families \code{gamma}, \code{weibull}, \code{inverse.gaussian}, and
  \code{negbinomial} need a \code{shape} parameter that has a 
  \code{"gamma(0.01,0.01)"} prior by default. 
  For families \code{cumulative}, \code{cratio}, \code{sratio}, 
  and \code{acat}, and only if \code{threshold = "equidistant"}, 
  the parameter \code{delta} is used to model the distance between 
  two adjacent thresholds. 
  By default, \code{delta} has an improper flat prior over the reals.
  The \code{von_mises} family needs the parameter \code{kappa}, representing
  the concentration parameter. By default, \code{kappa} has prior 
  \code{"gamma(2, 0.01)"}. \cr
  Every family specific parameter has its own prior class, so that
  \code{set_prior("<prior>", class = "<parameter>")} is the right way to go.
  All of these priors are chosen to be weakly informative,
  having only minimal influence on the estimations,
  while improving convergence and sampling efficiency.

  Often, it may not be immediately clear, 
  which parameters are present in the model.
  To get a full list of parameters and parameter classes for which 
  priors can be specified (depending on the model) 
  use function \code{\link[brms:get_prior]{get_prior}}.
}
\section{Functions}{
\itemize{
\item \code{prior}: Alias of \code{set_prior} allowing to 
specify arguments as expressions without quotation marks.

\item \code{prior_}: Alias of \code{set_prior} allowing to specify 
arguments as as one-sided formulas or wrapped in \code{quote}.

\item \code{prior_string}: Alias of \code{set_prior} allowing to
specify arguments as strings.
}}

\examples{
## use alias functions
(prior1 <- prior(cauchy(0, 1), class = sd))
(prior2 <- prior_(~cauchy(0, 1), class = ~sd))
(prior3 <- prior_string("cauchy(0, 1)", class = "sd"))
identical(prior1, prior2)
identical(prior1, prior3)

## check which parameters can have priors
get_prior(rating ~ treat + period + carry + (1|subject),
          data = inhaler, family = cumulative())
         
## define some priors          
prior <- c(prior_string("normal(0,10)", class = "b"),
           prior(normal(1,2), class = b, coef = treat),
           prior_(~cauchy(0,2), class = ~sd, 
                  group = ~subject, coef = ~Intercept))
              
## verify that the priors indeed found their way into Stan's model code
make_stancode(rating ~ treat + period + carry + (1|subject),
              data = inhaler, family = cumulative(),
              prior = prior)
              
## use the horseshoe prior to model sparsity in population-level effects
make_stancode(count ~ log_Age_c + log_Base4_c * Trt_c,
              data = epilepsy, family = poisson(),
              prior = set_prior("horseshoe(3)"))
              
## alternatively use the lasso prior
make_stancode(count ~ log_Age_c + log_Base4_c * Trt_c,
              data = epilepsy, family = poisson(),
              prior = set_prior("lasso(1)"))

## pass priors to Stan without checking
prior <- prior_string("target += normal_lpdf(b[1] | 0, 1)", check = FALSE)
make_stancode(count ~ Trt_c, data = epilepsy, prior = prior)

}
\references{
Carvalho, C. M., Polson, N. G., & Scott, J. G. (2009). 
  Handling sparsity via the horseshoe. 
  In International Conference on Artificial Intelligence and Statistics (pp. 73-80).

Gelman A. (2006). Prior distributions for variance parameters in hierarchical models.
   Bayesian analysis, 1(3), 515 -- 534.
   
Park, T., & Casella, G. (2008). The Bayesian Lasso. Journal of the American 
   Statistical Association, 103(482), 681-686.
   
Piironen J. & Vehtari A. (2016). On the Hyperprior Choice for the Global 
   Shrinkage Parameter in the Horseshoe Prior. 
   \url{https://arxiv.org/pdf/1610.05559v1.pdf}
}
\seealso{
\code{\link[brms:get_prior]{get_prior}}
}
