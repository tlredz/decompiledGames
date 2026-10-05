local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local GuiService = game:GetService("GuiService")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local v = require3(ReplicatedStorage2:WaitForChild("UserInputService"))
local ReplicatedStorage3 = game:GetService("ReplicatedStorage")
game:GetService("StarterGui")
local Players = game:GetService("Players")
local v2 = require3(ReplicatedStorage3.Packages.Signal)
local v3 = require3(ReplicatedStorage3.Common.Utils.Utilities.ValueConvertor)
local v4 = require3(ReplicatedStorage3.ClientGameModules.CoreCall)
local v5 = require3(ReplicatedStorage3.ServerInfo)
v2.new()
local playerGui = Players.LocalPlayer.PlayerGui
local v6 = nil
local count = 0
local serverType = playerGui:WaitForChild("ServerType")
local parryCounter = playerGui:WaitForChild("ParryCounter")
local v7 = {
	Pro = {
		Text = "THIS IS A PRO SERVER. <font color=\"rgb(254, 200, 42)\">+1.5X COINS</font>",
		StrokeColor = Color3.fromRGB(0, 0, 0),
		StrokeThickness = 2,
		Gradient = ColorSequence.new(Color3.fromRGB(255, 255))
	},
	RankedLobby = {
		Text = "EARN <font color=\"rgb(254, 200, 42)\">+1.5X COINS</font> IN RANKED",
		StrokeColor = Color3.fromRGB(0, 0, 0),
		StrokeThickness = 2,
		Gradient = ColorSequence.new(Color3.fromRGB(255, 255, 255))
	},
	Training = {
		Text = "THIS IS A TRAINING SERVER.",
		StrokeColor = Color3.fromRGB(108, 108, 108),
		StrokeThickness = 1,
		Gradient = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(121, 215, 255)),
			ColorSequenceKeypoint.new(0.462, Color3.fromRGB(101, 214, 255)),
			ColorSequenceKeypoint.new(0.796, Color3.fromRGB(1, 157, 230)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(1, 135, 172))
		})
	}
}
local ServerTypeController = {
	Init = function(_)
		v4(Enum.CoreGuiType.Health, false)
	end,
	Start = function(_)
		if v5.isProServer() then
			setServerType("Pro")
		elseif v5.isTrainingServer() then
			updateParryCounter()
			setServerType("Training")
		end

		ReplicatedStorage3.Remotes.ParrySuccess.OnClientEvent:Connect(function()
			count += 1
			updateParryCounter()
		end)
		ReplicatedStorage3.Remotes.RoundEnded.OnClientEvent:Connect(function()
			count = 0
			updateParryCounter()
		end)
		task.defer(updateFormFactor)
		workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(updateFormFactor)
	end
}

function updateFormFactor()
	if GuiService:IsTenFootInterface() then
		parryCounter.BG.Position = UDim2.new(0, 12, 0, 12)
		parryCounter.BG.AnchorPoint = Vector2.zero
	elseif v.TouchEnabled or workspace.CurrentCamera.ViewportSize.Y <= 500 then
		parryCounter.BG.Position = UDim2.new(1, 0, 0.2, 0)
		parryCounter.BG.AnchorPoint = Vector2.new(1, 0)
	else
		parryCounter.BG.Position = UDim2.new(0.5, 0, 0, 12)
		parryCounter.BG.AnchorPoint = Vector2.new(0.5, 0)
	end
end

function updateParryCounter()
	parryCounter.BG.CounterLabel.Text = v3:AddCommas(count)
end

function setServerType(p: string)
	v6 = p
	local v8 = v7[p]

	if v8 then
		serverType.Tip.Text = v8.Text
		serverType.Tip.UIGradient.Color = v8.Gradient
		serverType.Tip.UIStroke.Color = v8.StrokeColor
		serverType.Tip.UIStroke.Thickness = v8.StrokeThickness
		serverType.Enabled = true
	else
		serverType.Enabled = false
	end

	parryCounter.Enabled = v6 == "Training"
end

return ServerTypeController