
# MATH.SH
# Math functions for the shell

zmodload zsh/mathfunc

avg()
# Compute average of stream
{
  float D
  float TOTAL=0
  integer N=0
  float -F 3 RESULT
  while read D
  do
    (( TOTAL += D ))
    (( ++ N ))
  done
  (( RESULT = TOTAL / N ))
  printf "%0.4f\n" $RESULT
}

within()
# E, T, V
# E: Epsilon
# T: Target value
# V: Actual value
# Succeeds if abs(T-V) < E .
{
  local E=$1 T=$2 V=$3
  if (( abs(T-V) >= E )) {
       return 1
  }
  return 0
}
