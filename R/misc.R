p <- function(x, i = NULL, row = TRUE) {
  # flexible indexing of vector and matrix type objects
  # Args:
  #   x: an R object typically a vector or matrix
  #   i: optional index; if NULL, x is returned unchanged
  #   row: indicating if rows or cols should be indexed
  #        only relevant if x has two dimensions
  if (!length(i)) {
    x
  } else if (length(dim(x)) == 2L) {
    if (row) {
      x[i, , drop = FALSE]
    } else {
      x[, i, drop = FALSE]
    }
  } else {
    x[i]
  }
}

isNULL <- function(x) {
  # check if an object is NULL
  is.null(x) || ifelse(is.vector(x), all(sapply(x, is.null)), FALSE)
}

rmNULL <- function(x, recursive = TRUE) {
  # recursively removes NULL entries from an object
  x <- Filter(Negate(isNULL), x)
  if (recursive) {
    x <- lapply(x, function(x) if (is.list(x)) rmNULL(x) else x)
  }
  x
}

first_not_null <- function(...) {
  # find the first argument that is not NULL
  dots <- list(...)
  out <- NULL
  i <- 1L
  while(isNULL(out) && i <= length(dots)) {
    if (!isNULL(dots[[i]])) {
      out <- dots[[i]]
    }
    i <- i + 1L
  }
  out
}

isFALSE <- function(x) {
  identical(FALSE, x)
}

isNA <- function(x) {
  identical(NA, x)
}

is_equal <- function(x, y, ...) {
  isTRUE(all.equal(x, y, ...))
}

expand <- function(..., length = NULL) {
  # expand arguments of be of the same length
  # Args:
  #   ...: arguments to expand
  #   length: optional expansion length
  dots <- list(...)
  if (is.null(length)) {
    length <- max(sapply(dots, length))
  }
  lapply(dots, rep, length.out = length)
}

rmNum <- function(x) {
  # remove all numeric elements from an object
  x[sapply(x, Negate(is.numeric))]
}

structure_not_null <- function(.Data, ...) {
  # structure but ignore NULL
  if (!is.null(.Data)) {
    .Data <- structure(.Data, ...)
  }
  .Data
}

rmMatch <- function(x, ...) {
  # remove all elements in x that also appear in ... 
  # while keeping all attributes
  att <- attributes(x)
  keep <- which(!(x %in% c(...)))
  x <- x[keep]
  attributes(x) <- att
  attr(x, "match.length") <- att$match.length[keep] 
  x
}

rm_attr <- function(x, attr) {
  # remove certain attributes
  attributes(x)[attr] <- NULL
  x
}

subset_attr <- function(x, y) {
  # take a subset of vector, list, etc. 
  # while keeping all attributes except for names
  att <- attributes(x)
  x <- x[y]
  att[["names"]] <- names(x)
  attributes(x) <- att
  x
} 

is_wholenumber <- function(x, tol = .Machine$double.eps) {  
  # check if x is a whole number (integer)
  if (!is.numeric(x)) {
    out <- FALSE
  } else {
    out <- abs(x - round(x)) < tol
  }
  out
}

is_symmetric <- function(x, tol = sqrt(.Machine$double.eps)) {
  # helper function to check symmetry of a matrix
  isSymmetric(x, tol = tol, check.attributes = FALSE)
}

ulapply <- function(X, FUN, ...) {
  # short for unlist(lapply(.))
  unlist(lapply(X = X, FUN = FUN, ...))
}

lc <- function(l, ...) {
  # append ... to l
  dots <- list(...)
  c(l, dots)
}

collapse <- function(..., sep = "") {
  # wrapper for paste with collapse = ""
  paste(..., sep = sep, collapse = "")
}

paste_colon <- function(..., collapse = NULL) {
  # wrapper for paste with sep = ":"
  paste(..., sep = ":", collapse = collapse)
}

collapse_comma <- function(...) {
  paste0("'", ..., "'", collapse = ", ")
}

rename <- function(x, symbols = NULL, subs = NULL, 
                   fixed = TRUE, check_dup = FALSE) {
  # rename certain symbols in a character vector
  # Args:
  #   x: a character vector to be renamed
  #   symbols: the regular expressions in x to be replaced
  #   subs: the replacements
  #   fixed: same as for sub, grepl etc
  #   check_dup: logical; check for duplications in x after renaming
  # Returns: 
  #   renamed character vector of the same length as x
  symbols <- as.character(symbols)
  subs <- as.character(subs)
  if (!length(symbols)) {
    symbols <- c(" ", "(", ")", "[", "]", ",", "\"", "'", 
                 "+", "-", "*", "/", "^", "=", "!=")
  }
  if (!length(subs)) {
    subs <- c(rep("", 8), "P", "M", "MU", "D", "E", "EQ", "NEQ")
  }
  if (length(subs) == 1L) {
    subs <- rep(subs, length(symbols))
  }
  stopifnot(length(symbols) == length(subs))
  # avoid zero-length pattern error
  has_chars <- nzchar(symbols)
  symbols <- symbols[has_chars]
  subs <- subs[has_chars]
  out <- x
  for (i in seq_along(symbols)) {
    out <- gsub(symbols[i], subs[i], out, fixed = fixed)
  }
  dup <- duplicated(out)
  if (check_dup && any(dup)) {
    dup <- x[out %in% out[dup]]
    stop2("Internal renaming led to duplicated names. \n",
          "Occured for: ", collapse_comma(dup))
  }
  out
}

collapse_lists <- function(ls) {
  # collapse strings having the same name in different lists
  # Args:
  #  ls: a list of named lists
  # Returns:
  #  a named list containg the collapsed strings
  elements <- unique(unlist(lapply(ls, names)))
  out <- do.call(mapply, 
    c(FUN = collapse, lapply(ls, "[", elements), SIMPLIFY = FALSE))
  names(out) <- elements
  out
}

nlist <- function(...) {
  # create a named list using object names
  m <- match.call()
  dots <- list(...)
  no_names <- is.null(names(dots))
  has_name <- if (no_names) FALSE 
              else nzchar(names(dots))
  if (all(has_name)) return(dots)
  nms <- as.character(m)[-1]
  if (no_names) {
    names(dots) <- nms
  } else {
    names(dots)[!has_name] <- nms[!has_name]
  }
  dots
}

named_list <- function(names, values = NULL) {
  # initialize a named list
  # Args:
  #   names: names of the elements
  #   values: values of the elements
  if (!is.null(values)) {
    if (length(values) <= 1L) {
      values <- replicate(length(names), values)
    }
    values <- as.list(values)
    stopifnot(length(values) == length(names))
  } else {
    values <- vector("list", length(names))
  }
  setNames(values, names)
} 

deparse_no_string <- function(x) {
  # deparse x if it is no string
  if (!is.character(x)) {
    x <- deparse(x)
  } 
  x
}

eval2 <- function(text, ...) {
  # evaluate a string
  eval(parse(text = text), ...)
}

eval_smooth <- function(x) {
  eval2(paste0("mgcv::", x))
}

stop2 <- function(...) {
  stop(..., call. = FALSE)
}

warning2 <- function(...) {
  warning(..., call. = FALSE)
}

get_arg <- function(x, ...) {
  # find first occurrence of x in ... objects
  # Args:
  #  x: The name of the required element
  #  ...: R objects that may contain x
  dots <- list(...)
  i <- 1
  out <- NULL
  while(i <= length(dots) && is.null(out)) {
    if (!is.null(dots[[i]][[x]])) {
      out <- dots[[i]][[x]]
    } else {
      i <- i + 1
    }
  }
  out
}

SW <- function(expr) {
  # just a short form for suppressWarnings
  base::suppressWarnings(expr)
}

get_matches <- function(pattern, text, simplify = TRUE, ...) {
  # get pattern matches in text as vector
  x <- regmatches(text, gregexpr(pattern, text, ...))
  if (simplify) {
    x <- unlist(x)
  }
  x
}

get_matches_expr <- function(pattern, expr, ...) {
  # loop over the parse tree of 'expr '
  # and find matches of 'pattern'
  if (is.character(expr)) {
    expr <- parse(text = expr)
  }
  out <- NULL
  for (i in seq_along(expr)) {
    sexpr <- try(expr[[i]], silent = TRUE)
    if (!is(sexpr, "try-error")) {
      sexpr_char <- deparse(sexpr)
      out <- c(out, get_matches(pattern, sexpr_char, ...))
    }
    if (is.call(sexpr) || is.expression(sexpr)) {
      out <- c(out, get_matches_expr(pattern, sexpr, ...))
    }
  }
  unique(out)
}

grepl_expr <- function(pattern, expr, ...) {
  # like base::grepl but handles (parse trees of) expressions 
  as.logical(ulapply(expr, function(e) 
    length(get_matches_expr(pattern, e, ...)) > 0L))
}

usc <- function(x, pos = c("prefix", "suffix")) {
  # add an underscore to non-empty character strings
  # Args:
  #   x: a character vector
  #   pos: position of the underscore
  pos <- match.arg(pos)
  x <- as.character(x)
  if (pos == "prefix") {
    x <- ifelse(nzchar(x), paste0("_", x), "")
  } else {
    x <- ifelse(nzchar(x), paste0(x, "_"), "")
  }
  x
}

logit <- function(p) {
  # logit link
  log(p / (1 - p))
}

inv_logit <- function(x) { 
  # inverse of logit link
  1 / (1 + exp(-x))
}

cloglog <- function(x) {
  # cloglog link
  log(-log(1-x))
}

inv_cloglog <- function(x) {
  # inverse of the cloglog link
  1 - exp(-exp(x))
}

Phi <- function(x) {
  pnorm(x)
}

incgamma <- function(x, a) {
  # incomplete gamma funcion
  pgamma(x, shape = a) * gamma(a)
}

square <- function(x) {
  x^2
}

cbrt <- function(x) {
  x^(1/3)
}

exp2 <- function(x) {
  2^x
}

pow <- function(x, y) {
  x^y
}

inv <- function(x) {
  1/x
}

inv_sqrt <- function(x) {
  1/sqrt(x)
}

inv_square <- function(x) {
  1/x^2
}

hypot <- function(x, y) {
  stopifnot(all(x >= 0))
  stopifnot(all(y >= 0))
  sqrt(x^2 + y^2)
}

log1m <- function(x) {
  log(1 - x)
}

#' Logarithm with a minus one offset.
#' 
#' Computes \code{log(x - 1)}.
#' 
#' @param x A numeric or complex vector.
#' @param base A positive or complex number: the base with respect to which
#'   logarithms are computed. Defaults to \emph{e} = \code{exp(1)}.
#'     
#' @export
logm1 <- function(x, base = exp(1)) {
  log(x - 1, base = base)
}

#' Exponential function plus one.
#' 
#' Computes \code{exp(x) + 1}.
#' 
#' @param x A numeric or complex vector.
#' 
#' @export
expp1 <- function(x) {
  exp(x) + 1
}

#' Scaled logit-link
#' 
#' Computes \code{logit((x - lb) / (ub - lb))}
#' 
#' @param x A numeric or complex vector.
#' @param lb Lower bound defaulting to \code{0}.
#' @param ub Upper bound defaulting to \code{1}.
#' 
#' @return A numeric or complex vector.
#' 
#' @export
logit_scaled <- function(x, lb = 0, ub = 1) {
  logit((x - lb) / (ub - lb))
}

#' Scaled inverse logit-link
#' 
#' Computes \code{inv_logit(x) * (ub - lb) + lb}
#' 
#' @param x A numeric or complex vector.
#' @param lb Lower bound defaulting to \code{0}.
#' @param ub Upper bound defaulting to \code{1}.
#' 
#' @return A numeric or complex vector between \code{lb} and \code{ub}.
#' 
#' @export
inv_logit_scaled <- function(x, lb = 0, ub = 1) {
  inv_logit(x) * (ub - lb) + lb
}

multiply_log <- function(x, y) {
  ifelse(x == y & x == 0, 0, x * log(y))
}

log1p_exp <- function(x) {
  log(1 + exp(x))
}

log1m_exp <- function(x) {
  ifelse(x < 0, log(1 - exp(x)), NaN)
}

log_diff_exp <- function(x, y) {
  stopifnot(length(x) == length(y))
  ifelse(x > y, log(exp(x) - exp(y)), NaN)
}

log_sum_exp <- function(x, y) {
  max <- max(x, y)
  max + log(exp(x - max) + exp(y - max))
}

log_inv_logit <- function(x) {
  log(inv_logit(x))
}

log1m_inv_logit <- function(x) {
  log(1 - inv_logit(x))
}

cov_exp_quad <- function(x, x_new = NULL, sdgp = 1, lscale = 1) {
  .cov_exp_quad <- function(x1, x2) {
    sdgp^2 * exp(-(x1 - x2)^2 / (2 * lscale^2))
  }
  if (is.null(x_new)) {
    x_new <- x
  } 
  outer(x, x_new, .cov_exp_quad)
}

scale_unit <- function(x, lb = min(x), ub = max(x)) {
  (x - lb) / (ub - lb)
}

scale_distance <- function(x, d) {
  # scale x according to d
  # Args:
  #   x: A numeric vector or array
  #   d: The (inverse of the) scaling factor
  #      If NULL, use the maximum Euclidean distance
  # Return:
  #   A numeric vector or array of the same dimension as x
  if (isTRUE(dim(x) > 1L)) {
    stop("Only one dimensional input is currently supported.")
  }
  if (missing(d)) {
    d <- max(x) - min(x)
  }
  x / d
}

fabs <- function(x) {
  abs(x)
}

softmax <- function(x) {
  if (!is.matrix(x)) {
    x <- matrix(x, nrow = 1)
  }
  x <- exp(x) 
  x / rowSums(x)
}

wsp <- function(x, nsp = 1) {
  # add leading and trailing whitespaces
  # Args:
  #   x: object accepted by paste
  #   nsp: number of whitespaces to add
  sp <- collapse(rep(" ", nsp))
  if (length(x)) {
    paste0(sp, x, sp)
  } else {
    NULL
  } 
}

limit_chars <- function(x, chars = NULL, lsuffix = 4) {
  # limit the number of characters of a vector
  # Args:
  #   x: a character vector
  #   chars: maximum number of characters to show
  #   lsuffix: number of characters to keep 
  #            at the end of the strings
  stopifnot(is.character(x))
  if (!is.null(chars)) {
    chars_x <- nchar(x) - lsuffix
    suffix <- substr(x, chars_x + 1, chars_x + lsuffix)
    x <- substr(x, 1, chars_x)
    x <- ifelse(chars_x <= chars, x, paste0(substr(x, 1, chars - 3), "..."))
    x <- paste0(x, suffix)
  }
  x
}

use_alias <- function(arg, alias = NULL, default = NULL,
                      warn = TRUE) {
  # ensure that deprecated arguments still work
  # Args:
  #   arg: input to the new argument
  #   alias: input to the deprecated argument
  #   default: the default value of alias
  #   warn: should a warning be printed if alias is specified?
  arg_name <- Reduce(paste, deparse(substitute(arg)))
  alias_name <- Reduce(paste, deparse(substitute(alias)))
  if (!is_equal(alias, default)) {
    arg <- alias
    if (grepl("^dots\\$", alias_name)) {
      alias_name <- gsub("^dots\\$", "", alias_name)
    } else if (grepl("^dots\\[\\[", alias_name)) {
      alias_name <- gsub("^dots\\[\\[\"|\"\\]\\]$", "", alias_name)
    }
    if (warn) {
      warning2("Argument '", alias_name, "' is deprecated. ", 
               "Please use argument '", arg_name, "' instead.")
    }
  }
  arg
}

warn_deprecated <- function(new, old = as.character(sys.call(sys.parent()))[1]) {
  msg <- paste0("Function '", old, "' is deprecated.")
  if (!missing(new)) {
    msg <- paste0(msg, " Please use '", new, "' instead.")
  }
  warning2(msg)
  invisible(NULL)
}

expect_match2 <- function(object, regexp, ..., all = TRUE) {
  # just testthat::expect_match with fixed = TRUE
  testthat::expect_match(object, regexp, fixed = TRUE, ..., all = all)
}

.onAttach <- function(libname, pkgname) {
  # startup messages for brms
  packageStartupMessage(paste0(
    "Loading 'brms' package (version ", utils::packageVersion("brms"), "). ",
    "Useful instructions \n", 
    "can be found by typing help('brms'). A more detailed introduction \n", 
    "to the package is available through vignette('brms_overview')."))
}
