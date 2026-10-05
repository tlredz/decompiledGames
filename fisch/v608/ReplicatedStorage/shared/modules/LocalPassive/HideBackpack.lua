local Players = game:GetService("Players")
local module = require("./PassiveHandler")
local HideBackpack = {
	MorphSpear = true,
	Morph = function(_, _, object)
		task.spawn(function()
			object:WaitUntilReady()
			local backpack = Players.LocalPlayer:WaitForChild("PlayerGui"):FindFirstChild("backpack")

			if backpack and backpack:IsA("ScreenGui") then
				backpack.Enabled = false
			end
		end)
		object.OnMinigameEnd:Once(function()
			local backpack = Players.LocalPlayer:WaitForChild("PlayerGui"):FindFirstChild("backpack")

			if backpack and backpack:IsA("ScreenGui") then
				backpack.Enabled = true
			end
		end)
	end
}
setmetatable(HideBackpack, module)
return HideBackpack