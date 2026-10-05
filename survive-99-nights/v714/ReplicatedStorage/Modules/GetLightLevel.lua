local createVector = vector.create
local RunService = game:GetService("RunService")
local isServer = RunService:IsServer()
local Client = not isServer and require(game.Players.LocalPlayer.PlayerScripts.Client)
local Server = isServer and require(game.ServerScriptService.Server)
local v = Client or Server
local v2 = {}

function IsNearLightSource(p)
	for _, v3 in pairs(v2) do
		if not (v3.Enabled and v3.Parent and v3:IsDescendantOf(workspace)) then
			continue
		end

		local range = v3.Range

		if v3.Parent.Parent.Name == "MainFire" then
			range = v3.Parent.Parent.OuterTouchZone.Size.X / 2
		end

		if (p - v3.Parent.Position).Magnitude <= range then
			return true
		end
	end
end

function isInSunlight(p)
	return not workspace:Raycast(p, getSunDirection() * 1000, v.CollisionUtility.DefaultParams)
end

function getSunDirection()
	local minutesAfterMidnight = game.Lighting:GetMinutesAfterMidnight()
	local geographicLatitude = game.Lighting.GeographicLatitude
	local v3 = minutesAfterMidnight / 1440
	local v4 = 6.283185307179586 * v3
	local vector2 = Vector3.new(math.sin(v4), -math.cos(v4), 0)
	local v5 = math.rad(geographicLatitude)
	local v6 = math.cos(3.141592653589793 * (v3 - 182.6282) / 182.6282) * -0.41015237421866746 - v5
	return CFrame.fromAxisAngle((createVector(0, 0, 1)):Cross(vector2), v6) * vector2
end

function LightSourceAdded(p)
	if not table.find(v2, p) then
		table.insert(v2, p)
	end
end

function LightSourceRemoved(p)
	local index = table.find(v2, p)

	if index then
		table.remove(v2, index)
	end
end

task.spawn(function()
	v.Utility.ForAllTagged("LightSource", LightSourceAdded, LightSourceRemoved)
end)
return {
	GetLightLevel = function(player)
		if not player.Character then
			return
		end

		local position = player.Character and player.Character:GetPivot().Position

		if IsNearLightSource(position) then
			return "Light"
		end

		if workspace:GetAttribute("State") == "Night" then
			return "Dark"
		end

		local v4 = not isInSunlight(position) and "Shadow" or "Light"
		return v.ZoneModule.GetZone(position) == "HedgeMaze" and "Dark" or v4
	end
}