int.mcrq <- function(y, x, tau = 0.5, lb, ub) {

  n <- dim(x)[1]  ;  p <- dim(x)[2]
  R <- diag(p)  ;  R <- rbind(R, -R)
  d <- dim(y)[2]
  len <- length(tau)

  if ( length(lb) == 1 )  lb <- rep(lb, p)
  if ( length(ub) == 1 )  ub <- rep(ub, p)
  r <- c(lb, -ub)

  if ( len == 1 ) {

    mae <- numeric(d)
    be <- matrix(nrow = p, ncol = d)

    for ( j in 1:d ) {
      mod <- quantreg::rq(y[, j] ~ x - 1, data = data.frame(y = y, x = x), tau = tau,
                          method = "fnc", R = R, r = r)
      mae[j] <- sum( abs (y[, j] - x %*% mod$coefficients) ) / n
      be[, j] <- mod$coefficients
    }

    colnames(be) <- paste("Y", 1:d, sep = "")
    rownames(be) <- colnames(x)

  } else {

    mae <- numeric(len)
    names <- paste("Y", 1:d, sep = "")
    res <- sapply(names, function(x) NULL)

    for ( j in 1:d ) {
      mod <- quantreg::rq(y[, j] ~ x - 1, data = data.frame(y = y, x = x), tau = tau,
                          method = "fnc", R = R, r = r)
      be <- mod$coefficients
      mae <- Rfast::colmeans( abs (y[, j] - x %*% be) )
      names(mae) <- colnames(be)
      res[[ j ]]$be <- be
      res[[ j ]]$mae <- mae
    }
  }

  list(be = be, mae = mae)
}
