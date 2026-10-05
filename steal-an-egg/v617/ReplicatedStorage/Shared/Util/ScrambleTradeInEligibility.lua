local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local GuardEscapeRequirement = require(ReplicatedStorage.Shared.Modules.GuardAreas.GuardEscapeRequirement)
local ScrambleTradeInFlags = require(ReplicatedStorage.Shared.Flags.ScrambleTradeInFlags)
local Signal = require(ReplicatedStorage.Packages.Signal)
local v = {
	Changed = Signal.new()
}

local function cosmicArea()
	local world = Workspace:FindFirstChild("World")
	local areas = world and world:FindFirstChild("Areas")
	local guardAreas = areas and areas:FindFirstChild("GuardAreas")
	local cosmic = guardAreas and guardAreas:FindFirstChild("Cosmic")

	if cosmic and cosmic:IsA("Model") then
		return cosmic
	end

	return nil
end

function v.RequiredSpeedPower()
	local v2 = cosmicArea()
	local attribute = v2 and v2:GetAttribute(GuardEscapeRequirement.SIGN_SPEEDS_ATTRIBUTE)

	if typeof(attribute) == "Vector2" and not (attribute.X <= 0) and not (attribute.X >= 1e999) and attribute.X == attribute.X then
		return (math.max(attribute.X, ScrambleTradeInFlags.SpeedPowerRequirement:Get()))
	end

	return nil
end

function v.IsEligible(p: number)
	local requiredSpeedPower = v.RequiredSpeedPower()
	return requiredSpeedPower ~= nil and requiredSpeedPower <= p
end

task.spawn(function()
	local guardAreas = Workspace:WaitForChild("World"):WaitForChild("Areas"):WaitForChild("GuardAreas")
	local v2 = nil
	local connection = nil

	local function bind()
		local v3 = cosmicArea()

		if v3 == v2 then
			return
		end

		if connection then
			connection:Disconnect()
			connection = nil
		end

		v2 = v3

		if v3 then
			connection = v3:GetAttributeChangedSignal(GuardEscapeRequirement.SIGN_SPEEDS_ATTRIBUTE):Connect(function()
				v.Changed:Fire()
			end)
		end

		v.Changed:Fire()
	end

	guardAreas.ChildAdded:Connect(function(child)
		if child.Name == "Cosmic" then
			bind()
		end
	end)
	guardAreas.ChildRemoved:Connect(function(child)
		if child.Name == "Cosmic" then
			bind()
		end
	end)
	bind()
end)
return table.freeze(v)