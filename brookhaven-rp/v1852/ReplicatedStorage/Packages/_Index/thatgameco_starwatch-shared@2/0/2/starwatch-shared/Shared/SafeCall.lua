return function(callback)
	return function(...)
		local success, result = pcall(callback, ...)

		if not success then
			warn("[Starwatch] Runtime error:", result)
		end

		return result
	end
end