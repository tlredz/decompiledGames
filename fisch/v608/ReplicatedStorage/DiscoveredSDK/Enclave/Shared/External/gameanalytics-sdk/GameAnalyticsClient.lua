local GameAnalyticsClient = {}
local GuiService = game:GetService("GuiService")
local UserInputService = game:GetService("UserInputService")
game:GetService("ReplicatedStorage")
game:GetService("ScriptContext")
game:GetService("LogService")

function GameAnalyticsClient.initClient()
	local Postie = require(script.Parent.GameAnalytics.Postie)

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

return GameAnalyticsClient