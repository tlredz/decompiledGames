local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ThumbnailGenerator = require(ReplicatedStorage.Modules.ThumbnailGenerator)
local PlayerStates = require(ReplicatedStorage.Modules.PlayerStates)
local parent = script.Parent
local v = { parent.Circle_1, parent.Circle_2, parent.Circle_3 }
local size = v[1].Size
parent.ProfilePicture_Local.ProfilePicture.Image = ThumbnailGenerator(
	"AvatarHeadShot",
	Players.LocalPlayer.UserId,
	Vector2.new(150, 150)
)
parent.LocalName.Text = Players.LocalPlayer.DisplayName
Players.LocalPlayer:GetAttributeChangedSignal("State"):Connect(function()
	parent.Visible = Players.LocalPlayer:GetAttribute("State") == PlayerStates.Queued
end)
RunService.RenderStepped:Connect(function()
	local v2 = tick() * 2

	for k, v3 in v do
		local v4 = math.max(0.25, (math.abs((math.sin(v2 - k)))))
		local v5 = Vector2.new(size.X.Scale, size.Y.Scale) * v4
		v3.Size = UDim2.fromScale(v5.X, v5.Y)
	end
end)