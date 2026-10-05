local GuiService = game:GetService("GuiService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = require(ReplicatedStorage:WaitForChild("UserInputService"))
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local ScriptContext = game:GetService("ScriptContext")
return {
	initClient = function()
		local Postie = require(script.Parent.GameAnalytics.Postie)
		ScriptContext.Error:Connect(function(p, p2, instance)
			if not instance then
				return
			end

			local fullName = nil
			local success, _ = pcall(function()
				fullName = instance:GetFullName()
			end)

			if not success then
				return
			end

			ReplicatedStorage2.GameAnalyticsError:FireServer(p, p2, fullName)
		end)

		local function getPlatform()
			if GuiService:IsTenFootInterface() then
				return "Console"
			end

			if UserInputService.TouchEnabled and not UserInputService.MouseEnabled then
				return "Mobile"
			end

			return "Desktop"
		end

		Postie.setCallback("getPlatform", getPlatform)
	end
}