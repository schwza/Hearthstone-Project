
# Building a very simple classifier, based solely on historical proportions.

library(data.table)

games <- read.csv("wog_games.csv", stringsAsFactors = FALSE)

games <- as.data.table(games)

# Make a table of likelihoods, not conditional on anything.
HeroLikelihood <- games[, .N, by = hero]

HeroLikelihood[, proportion := N / sum(N)]

# Obviously the sum of proportion should be 1...
sum(HeroLikelihood$proportion)   # ... and it is 1.

# Set the key of HeroLikelihood and games so that we can easily pull the
# proportion variable from one to the other.
setkey(HeroLikelihood, "hero")
setkey(games, "hero")

# Each proportion is our guess for the likelihood of seeing that proportion in
# the data.
games[HeroLikelihood, HeroGuess := proportion]

# The sume of the natural log of all of our guesses is a measure of how well
# this estimator has done. If we can't beat this score, we've accomplished 
# very little.
games[, sum(log(HeroGuess))]
