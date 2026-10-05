local createVector = vector.create
local LightHandler = {}
local localPlayer = game.Players.LocalPlayer
local Client = require(localPlayer.PlayerScripts.Client)
local RunService = game:GetService("RunService")
local v = nil
local v2 = {}

function UpdatePlayerNearMainFire()
	task.spawn(function()
		local mainFire = workspace:WaitForChild("Map"):WaitForChild("Campground"):WaitForChild("MainFire")
		local position = mainFire:GetPivot().Position
		local outerTouchZone = mainFire:WaitForChild("OuterTouchZone")
		RunService:BindToRenderStep("UpdateNearMainFire", Enum.RenderPriority.Last.Value, function()
			local humanoidRootPart = Client.PlayerHandler.HumanoidRootPart
			local magnitude = humanoidRootPart and (humanoidRootPart.Position - position).Magnitude
			local v3 = humanoidRootPart and mainFire:GetAttribute("FuelRemaining") > 0 and magnitude and magnitude <= outerTouchZone.Size.X / 2 and true or false
			local v4 = humanoidRootPart and humanoidRootPart.Position.Y < -50 and true or v3
			Client.CampfireEffectModule.SetEnabled(v4)
		end)
	end)
end

function IsPlayerInLight()
	local head = localPlayer.Character and localPlayer.Character:FindFirstChild("Head")

	if not head then
		return
	end

	local position = head.Position

	if isInSunlight(position) then
		return true
	end

	for _, v3 in pairs(v2) do
		if not (v3.Enabled and v3.Parent) then
			continue
		end

		local range = v3.Range

		if v3.Parent.Parent.Name == "MainFire" then
			range = v3.Parent.Parent.OuterTouchZone.Size.X / 2
		end

		if (position - v3.Parent.Position).Magnitude <= range then
			return true
		end
	end

	return false
end

function UpdatePlayerInLight()
	local v3 = IsPlayerInLight()

	if v3 ~= v then
		v = v3
	end
end

function isInSunlight(p)
	return not workspace:Raycast(p, getSunDirection() * 1000, Client.CollisionUtility.DefaultParams)
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

function LightHandler.Init()
	RunService:BindToRenderStep("UpdatePlayerInLight", Enum.RenderPriority.Character.Value, UpdatePlayerInLight)
	UpdatePlayerNearMainFire()
	Client.Utility.ForAllTagged("LightSource", LightSourceAdded, LightSourceRemoved)
end

return LightHandler