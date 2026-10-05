local Players = game:GetService("Players")
game:GetService("Lighting")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local localPlayer = Players.LocalPlayer
local playerGui = localPlayer.PlayerGui
local _ = localPlayer.PlayerScripts
local CharacterController = require(ReplicatedStorage.Controllers.CharacterController)
local _ = CharacterController.Controls
local packages = ReplicatedStorage:WaitForChild("Packages")
local Net = require(packages.Net)
local confettiHolder = playerGui:WaitForChild("ToolsScreen").MainFrame.ConfettiHolder
local remoteEvent = Net:RemoteEvent("UseItem")
local confettiSizes = script.ConfettiSizes
local random = Random.new()
local tweenInfo = TweenInfo.new(random:NextNumber(1, 2.5), Enum.EasingStyle.Sine, Enum.EasingDirection.In)
local v = {
	Color3.fromRGB(255, 55, 55),
	Color3.fromRGB(55, 255, 55),
	Color3.fromRGB(255, 225, 0),
	Color3.fromRGB(0, 75, 255),
	Color3.fromRGB(0, 225, 255),
	Color3.fromRGB(255, 200, 0),
	Color3.fromRGB(255, 125, 0),
	Color3.fromRGB(225, 0, 255),
	Color3.fromRGB(55, 255, 125),
	Color3.fromRGB(255, 0, 255),
	Color3.fromRGB(255, 0, 0)
}
remoteEvent.OnClientEvent:Connect(function(p)
	if p ~= "Confetti Launcher" then
		return
	end

	for _ = 1, 500 do
		local clone = confettiSizes[math.random(1, #confettiSizes:GetChildren())]:Clone()
		clone.BackgroundColor3 = v[math.random(1, #v)]
		clone.Position = UDim2.new(random:NextNumber(-0.3, 1.3), 0, -0.2, 0)
		clone.Rotation = random:NextNumber(10, 360)
		clone.Visible = true
		clone.Parent = confettiHolder
		TweenService:Create(clone, tweenInfo, {
			Position = UDim2.fromScale(clone.Position.X.Scale, 1.5)
		}):Play()
		task.wait(0.01)
	end

	task.wait(7)
	confettiHolder:ClearAllChildren()
end)
return {}