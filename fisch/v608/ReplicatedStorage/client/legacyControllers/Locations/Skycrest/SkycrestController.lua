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
	end
}