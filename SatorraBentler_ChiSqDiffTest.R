# Perform a Satorra-Bentler chi-square difference test

# the degrees of freedom, scaling factor, and chisquare for the nested model
d0 <- 20
c0 <- 3.1662
T0 <- 253.506

# the degrees of freedom, scaling factor, and chisquare for the comparison model
d1 <- 19
c1 <- 3.1011
T1 <- 189.890
  
cd <- (d0 * c0 - d1*c1)/(d0-d1)

TRd <- (T0*c0 - T1*c1)/cd

pval <- pchisq(TRd, df = 1, lower.tail = F)

print(TRd)
print(pval)
