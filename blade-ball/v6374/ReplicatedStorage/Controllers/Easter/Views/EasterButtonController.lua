local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local RunService = game:GetService("RunService")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local playerGui = Players.LocalPlayer.PlayerGui
local v = require3(ReplicatedStorage2.Shared.Time)
local v2 = require3(ReplicatedStorage2.Common.Utils.Utilities.Thread)
local v3 = require3(ReplicatedStorage2.Common.Utils.Utilities.ValueConvertor)
local v4 = require3(ReplicatedStorage2.ClientGameModules.GuiHandler)
local v5 = require3(ReplicatedStorage2.Shared.Easter.EggHunt)
local v6 = require3(ReplicatedStorage2.Controllers.Easter.EasterPageController)
local v7 = {
	[true] = {
		Image = "rbxassetid://16886905650",
		Hover = "rbxassetid://16887017780",
		Color = Color3.fromRGB(0, 28, 130)
	},
	[false] = {
		Image = "rbxassetid://16886898341",
		Hover = "rbxassetid://16887016113",
		Color = Color3.fromRGB(0, 111, 165)
	}
}
local buttons = {}
local overview = playerGui:WaitForChild("EasterEvent"):WaitForChild("Overview")
local EasterButtonController = {}

function EasterButtonController.Init(_)
	for _, button in ipairs(overview.LeftButtons:GetChildren()) do
		if button:IsA("ImageButton") then
			table.insert(buttons, button)
		end
	end

	for _, v8 in ipairs(buttons) do
		local name = v8.Name
		v8.MouseButton1Click:Connect(function()
			if v6:IsOpen(name) then
				return
			end

			EasterButtonController:UpdateButtons(name)
			v6:OpenPage(name)
		end)
	end

	overview.Close.MouseButton1Click:Connect(function()
		v4:Close("EasterEvent")
	end)
	UpdateTimerText()
	v2.Every(1, function()
		if v4:IsOpen("EasterEvent") then
			UpdateTimerText()
		end
	end)
	local connection = nil
	connection = v4:OnGuiOpen("EasterEvent", function()
		EasterButtonController:UpdateButtons("HatchEgg")
		v6:OpenPage("HatchEgg")
		connection:Disconnect()
	end)

	if RunService:IsStudio() then
		local ReplicatedStorage3 = game:GetService("ReplicatedStorage")
		require3(ReplicatedStorage3:WaitForChild("UserInputService")).InputBegan:Connect(function(input, gameProcessed: boolean)
			if gameProcessed then
				return
			end

			if input.KeyCode == Enum.KeyCode.X then
				if v4:IsOpen("EasterEvent") then
					v4:Close("EasterEvent")
				else
					v4:Open("EasterEvent")
				end
			end
		end)
	end
end

function EasterButtonController:UpdateButtons(p: string?)
	for _, v8 in ipairs(buttons) do
		local v9 = v7[v8.Name == p]
		v8.Image = v9.Image
		v8.HoverImage = v9.Hover
		local uIStroke = v8:FindFirstChildWhichIsA("UIStroke", true)

		if uIStroke then
			uIStroke.Color = v9.Color
		end
	end
end

function UpdateTimerText()
	local time = v:GetTime()
	local v8 = math.max(v5.EventEndTime - time, 0)
	overview.ClockIcon.Timer.Text = v3:FormatTimeWithDaysFull(v8)
end

return EasterButtonController