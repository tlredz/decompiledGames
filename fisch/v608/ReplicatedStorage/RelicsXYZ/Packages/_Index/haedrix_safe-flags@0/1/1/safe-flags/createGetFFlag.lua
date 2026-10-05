local function createGetFFlag(value: string, flag: boolean?)
	local success, result = pcall(function()
		local game2 = game
		local v2

		if flag then
			v2 = flag
		else
			v2 = false
		end

		game2:DefineFastFlag(value, v2)
	end)

	if success or not result:match("The current thread cannot call") then
		return function()
			return game:GetFastFlag(value)
		end
	end

	return function()
		return value:match("^Debug") == nil
	end
end

return createGetFFlag