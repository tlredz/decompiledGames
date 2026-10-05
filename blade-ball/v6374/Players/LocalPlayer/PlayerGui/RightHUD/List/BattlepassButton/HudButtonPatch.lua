local ReplicatedStorage = game:GetService("ReplicatedStorage")

while not workspace:GetAttribute("ClientModulesLoaded") do
	workspace:GetAttributeChangedSignal("ClientModulesLoaded"):Wait()
end

local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local UserInputService = require(ReplicatedStorage2:WaitForChild("UserInputService"))
local Replion = require(ReplicatedStorage.Packages.Replion)
local ServerInfo = require(ReplicatedStorage.ServerInfo)
local v = Replion.Client:WaitReplion("Data")
local localPlayer = game.Players.LocalPlayer
local module = require("@game/ReplicatedStorage/Shared/InfiniteBattlepass/InfiniteBattlepassData")
local v2 = v:Get("TotalStats.Wins")
v:OnChange("TotalStats.Wins", function()
	v2 = v:Get("TotalStats.Wins")
end)

local function IsPointInArea(pivot, dead)
	local position = dead.Position
	local halfSize = dead.Size / 2

	if pivot.X > position.X - halfSize.X and pivot.X < position.X + halfSize.X and pivot.Y > position.Y - halfSize.Y and pivot.Y < position.Y + halfSize.Y and pivot.Z > position.Z - halfSize.Z and pivot.Z < position.Z + halfSize.Z then
		return true
	end
end

local dead = workspace.MapBounds.Dead
local duelLobbyServer = ServerInfo.isDuelLobbyServer()
local huntPrivateServer = ServerInfo.isHuntPrivateServer()

while true do
	if UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled then
		script.Parent.Position = UDim2.fromScale(0.053, 0.905)
	else
		script.Parent.Position = UDim2.fromScale(0.947, 0.905)
	end

	local character = localPlayer.Character
	local pivot = character and character:GetPivot() or vector.create(0, 0, 0)
	local v3 = duelLobbyServer or IsPointInArea(pivot, dead)
	local enabled = module.isEnabled()
	local parent = script.Parent
	local visible = ReplicatedStorage.FeaturesToggle.Battlepass.Value

	if visible then
		if enabled then
			if v2 > 0 then
				visible = v3 and not huntPrivateServer and workspace.CurrentCamera.CameraType ~= Enum.CameraType.Scriptable
			else
				visible = false
			end
		else
			visible = enabled
		end
	end

	parent.Visible = visible
	task.wait(0.2)
end