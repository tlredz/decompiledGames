local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GeneralUtils = require(ReplicatedStorage:WaitForChild("shared"):WaitForChild("utils"):WaitForChild("GeneralUtils"))
return {
	ConfigName = "PatchModulePaths",
	ApplyEnvironment = "Both",
	Apply = function(items)
		if typeof(items) ~= "table" then
			return
		end

		for k, item in items do
			local v = k
			local v2 = item
			task.spawn(function()
				local game2 = game

				for k2, childName in v:split(".") do
					game2 = game2:FindFirstChild(childName)

					if not game2 then
						return
					end
				end

				if game2 and game2:IsA("ModuleScript") then
					local module = require(game2)
					GeneralUtils.applyTable(module, v2, true)
				end
			end)
		end
	end
}