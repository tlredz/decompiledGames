local Pets = require(script.Parent.Parent.GameData.Pets)
local PetRideModes = {
	TakeoffLookY = 0.35,
	TakeoffForward = 0.25,
	MinFlightSeconds = 0.75,
	LandingCooldown = 0.4,
	LandingClearance = 2,
	TakeoffLiftSeconds = 0.35,
	TakeoffLiftSpeed = 22
}

local function Positive(p)
	local v = tonumber(p)

	if not v or v ~= v or not (v > 0 and v < 1e999 and v) then
		return nil
	end

	return v
end

function PetRideModes.Speeds(instance)
	local pet = Pets[instance:GetAttribute("PetName") or instance.Name]
	local data = instance:FindFirstChild("Data")

	local function Read(childName)
		local child = data and data:FindFirstChild(childName)
		local value = tonumber(pet and pet[childName])

		if not value or value ~= value or not (value > 0 and value < 1e999 and value) then
			value = nil
		end

		if not value then
			value = tonumber(child and child.Value)

			if not value or value ~= value or not (value > 0 and value < 1e999 and value) then
				value = nil
			end
		end

		return value
	end

	local walkSpeed = data and data:FindFirstChild("WalkSpeed")
	local walkSpeed2 = tonumber(pet and pet.WalkSpeed)

	if not walkSpeed2 or walkSpeed2 ~= walkSpeed2 or not (walkSpeed2 > 0 and walkSpeed2 < 1e999 and walkSpeed2) then
		walkSpeed2 = nil
	end

	if not walkSpeed2 then
		walkSpeed2 = tonumber(walkSpeed and walkSpeed.Value)

		if not walkSpeed2 or walkSpeed2 ~= walkSpeed2 or not (walkSpeed2 > 0 and walkSpeed2 < 1e999 and walkSpeed2) then
			walkSpeed2 = nil
		end
	end

	local flySpeed = data and data:FindFirstChild("FlySpeed")
	local flySpeed2 = tonumber(pet and pet.FlySpeed)

	if not flySpeed2 or flySpeed2 ~= flySpeed2 or not (flySpeed2 > 0 and flySpeed2 < 1e999 and flySpeed2) then
		flySpeed2 = nil
	end

	if not flySpeed2 then
		flySpeed2 = tonumber(flySpeed and flySpeed.Value)

		if not flySpeed2 or flySpeed2 ~= flySpeed2 or not (flySpeed2 > 0 and flySpeed2 < 1e999 and flySpeed2) then
			flySpeed2 = nil
		end
	end

	return walkSpeed2, flySpeed2
end

function PetRideModes.BaseSpeed(instance)
	local speeds, v = PetRideModes.Speeds(instance)

	if speeds and v then
		if instance:GetAttribute("Ridden") == true then
			speeds = (instance:GetAttribute("PredictedRideMode") or instance:GetAttribute("RideMode")) == "Fly" and v or speeds
		end

		return speeds
	else
		local data = instance:FindFirstChild("Data")
		local speed = data and data:FindFirstChild("Speed")
		local pet = Pets[instance:GetAttribute("PetName") or instance.Name]
		local value = tonumber(speed and speed.Value)

		if not value or value ~= value or not (value > 0 and value < 1e999 and value) then
			value = nil
		end

		if value then
			return value
		end

		local speed2 = tonumber(pet and pet.Speed)

		if not speed2 or speed2 ~= speed2 or not (speed2 > 0 and speed2 < 1e999 and speed2) then
			speed2 = nil
		end

		value = speed2 or speeds or v or 0
		return value
	end
end

function PetRideModes.ShouldTakeoff(p, p2, p3, p4)
	return PetRideModes.TakeoffLookY <= p and PetRideModes.TakeoffForward <= p2 and p3 - p4 >= PetRideModes.LandingCooldown
end

function PetRideModes.ShouldLand(p, p2, p3, p4, p5)
	if p then
		if p2 <= PetRideModes.LandingClearance and p3 >= 0.5 then
			p = p4 - p5 >= PetRideModes.MinFlightSeconds
		else
			p = false
		end
	end

	return p
end

return PetRideModes