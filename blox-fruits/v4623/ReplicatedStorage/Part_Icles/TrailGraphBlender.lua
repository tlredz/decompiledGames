local Graph = require(script.Parent.Graph)
return {
	CollectStates = function(instance)
		local result = {}
		local result2 = {}
		local result3 = {}

		if not instance then
			return result, result2, result3
		end

		for _, configuration in pairs(instance:GetChildren()) do
			if not configuration:IsA("Configuration") then
				continue
			end

			local time = configuration:GetAttribute("Time")

			if time == nil then
				local v = tonumber(string.match(configuration.Name, "%d+"))
				time = v and v - 1 or 0
			end

			local width = configuration:GetAttribute("Width")

			if width and typeof(width) == "NumberSequence" then
				table.insert(result, {
					Time = time,
					Graph = width
				})
			end

			local transparency = configuration:GetAttribute("Transparency")

			if transparency and typeof(transparency) == "NumberSequence" then
				table.insert(result2, {
					Time = time,
					Graph = transparency
				})
			end

			local color = configuration:GetAttribute("Color")

			if color and typeof(color) == "ColorSequence" then
				table.insert(result3, {
					Time = time,
					Graph = color
				})
			end
		end

		for _, list in ipairs({ result, result2, result3 }) do
			table.sort(list, function(a, b)
				return a.Time < b.Time
			end)

			if not (#list > 1 and list[#list].Time > 1) then
				continue
			end

			local time = list[#list].Time

			if not (time > 0) then
				continue
			end

			for _, v in ipairs(list) do
				v.Time /= time
			end
		end

		return result, result2, result3
	end,
	PrecomputeMergedTimes = Graph.PrecomputeMergedTimes,
	PrecomputeMergedColorTimes = Graph.PrecomputeMergedColorTimes,
	LerpGraphFast = Graph.LerpGraphFast,
	LerpColorGraphFast = Graph.LerpColorGraphFast
}