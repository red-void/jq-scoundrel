# Randomizing primitives

# Swap
# Returns array with swapped elements with given indexes.
def swap($index_1; $index_2; $array): [foreach $array[] as $item (-1; . + 1; (if . == $index_1 then $array[$index_2] elif . == $index_2 then $array[$index_1] else $item end))];

# Random number generator seed
# Returns kind of random number (from 0 to 'limit') based on current time. Let's say it's random enough for a single use :D
def rng_seed($limit):
	now as $x 
	| ($x - ($x | round)) as $frac
	| (if $frac > 0 then ($frac * $limit) else (($frac + 1) * $limit) end)
	| round;

# Linear congruential random number generator. 
# 'a', 'c', 'm' are the LCG constants, 'seed' is the initial random number.
# Returns 'n' numbers since start. 
def rng_n($seed; $n; $a; $c; $m): [foreach range(0, $n) as $prev ($seed; ($a * . + $c) % $m; .)];

# Fisher-Yates shuffle
# Returns shuffled array based on 'array' and 'a', 'c', 'm' LCG constants.
def fisher_yates_shuffle($array; $a; $c; $m):
	[foreach (rng_n(rng_seed($m); ($array | length); $a; $c; $m))[] as $item (0; . + 1; [.-1, $item % .])] as $permutations
	| reduce $permutations[] as $permutation ($array ; swap($permutation[0]; $permutation[1]; .));

