return {
	Start = function(self)
		local components = script:FindFirstChild("Components")

		if components then
			for _, moduleScript in components:GetDescendants() do
				if moduleScript:IsA("ModuleScript") then
					task.spawn(require, moduleScript)
				end
			end
		end

		for _, child in script.Controllers:GetChildren() do
			local v = child
			task.spawn(function()
				local module = require(v)
				module:Start()
			end)
		end

		for _, child in script.Layers:GetChildren() do
			for _, moduleScript in child:GetChildren() do
				if not moduleScript:IsA("ModuleScript") then
					continue
				end

				local success, result = pcall(require, moduleScript)

				if success then
					if typeof(result) == "table" and result.Start then
						task.spawn(result.Start, result)
					end
				else
					warn("[WrathOfOlympusController]", result)
				end
			end
		end
	end
}