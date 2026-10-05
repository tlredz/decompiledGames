local lastTime = os.time()
return function()
	local v = os.time() - lastTime
	return ("%dd %dh %dm %ds"):format(
		math.floor(v / 86400),
		math.floor(v / 3600) % 24,
		math.floor(v / 60) % 60,
		math.floor(v) % 60
	)
end