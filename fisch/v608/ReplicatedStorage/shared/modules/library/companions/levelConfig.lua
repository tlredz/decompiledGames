return {
	MAX_LEVEL = 10,
	xpForLevel = function(p: number)
		return (math.floor(1.82 ^ (p - 1) * 107.59))
	end
}