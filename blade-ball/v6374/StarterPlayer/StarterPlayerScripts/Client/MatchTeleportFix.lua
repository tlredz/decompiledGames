local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

while not workspace:GetAttribute("ClientModulesLoaded") do
	workspace:GetAttributeChangedSignal("ClientModulesLoaded"):Wait()
end

require(ReplicatedStorage.Shared.MapData)
local localPlayer = Players.LocalPlayer
workspace:WaitForChild("MapBounds"):WaitForChild("Alive")

local function IsPointInArea(data, p)
	local position = p.Position
	local halfSize = p.Size / 2

	if data.X > position.X - halfSize.X and data.X < position.X + halfSize.X and data.Y > position.Y - halfSize.Y and data.Y < position.Y + halfSize.Y and data.Z > position.Z - halfSize.Z and data.Z < position.Z + halfSize.Z then
		return true
	end
end

ReplicatedStorage.Remotes.LocalTeleport.OnClientEvent:Connect(function(cframe: CFrame)
	local character = localPlayer.Character

	if not character then
		return
	end

	character:PivotTo(cframe)
end)