local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local spinWheel = ReplicatedStorage2.Shared.SpinWheel
local RunService = game:GetService("RunService")
local v = require3(ReplicatedStorage2.Packages.Replion)
require3(ReplicatedStorage2.Shared.Summer.SummerEvent)

-- equivalent calls inferred from this helper; original call sites unknown
local function getPlayerReplion(p)
	if RunService:IsClient() then
		return v.Client:GetReplion("Data")
	end

	return v.Server:GetReplionFor(p, "Data")
end

local events = {
	Mech = {
		END = DateTime.fromUniversalTime(2025, 4, 5, 16).UnixTimestamp + 1209600
	}
}
local SpinWheelRewards = {}
SpinWheelRewards._Events = events

function SpinWheelRewards:GetActiveEvent(p)
	local now = os.time()
	local v3 = "Default"
	local v4 = nil

	for k, v5 in pairs(events) do
		if not (v5.END and (not v5.START or v5.START <= now) and now <= v5.END) then
			continue
		end

		v4 = v5
		v3 = k
	end

	local playerReplion = getPlayerReplion(p) -- equivalent call inferred; original call site unknown

	if not playerReplion then
		return
	end

	if v3 == "Default" or v4 and v4.HasInstantSpin then
		local gamePasses = playerReplion:Get("GamePasses") or {}

		if table.find(gamePasses, "FastUnbox") then
			return v3 .. "/WithoutInstantSpin", v4 and v4.END
		end
	end

	return v3, v4 and v4.END
end

function SpinWheelRewards:GetSpinWheel(p)
	local activeEvent = self:GetActiveEvent(p)

	if not activeEvent then
		return require3(spinWheel.Default), "Default"
	end

	local match = activeEvent:match("^(%w+)/?")
	local v3 = activeEvent:match("^%w+(.*)") or ""

	if match == "Easter" then
		local playerReplion = getPlayerReplion(p) -- equivalent call inferred; original call site unknown

		if playerReplion and playerReplion:Get({ "SpinWheelObtained", "Easter Fan" }) then
			activeEvent = `{"Easter"}/Dual{v3}`
		end
	elseif match == "GoodvsEvil" then
		local playerReplion = getPlayerReplion(p) -- equivalent call inferred; original call site unknown

		if playerReplion then
			if playerReplion:Get({ "SpinWheelObtained", "Dual Good Fans" }) then
				activeEvent = `{"GoodvsEvil"}/DualEvil{v3}`
			elseif playerReplion:Get({ "SpinWheelObtained", "Good Fan" }) then
				activeEvent = `{"GoodvsEvil"}/Dual{v3}`
			end
		end
	elseif match == "ROCL" then
		local playerReplion = getPlayerReplion(p) -- equivalent call inferred; original call site unknown

		if playerReplion then
			if playerReplion:Get({ "SpinWheelObtained", "Dual Green Energy Sword" }) then
				activeEvent = `{"ROCL"}/DualChroma{v3}`
			elseif playerReplion:Get({ "SpinWheelObtained", "Green Energy Sword" }) then
				activeEvent = `{"ROCL"}/Dual{v3}`
			end
		end
	elseif match == "Summer" then
		local playerReplion = getPlayerReplion(p) -- equivalent call inferred; original call site unknown

		if playerReplion then
			if playerReplion:Get({ "SpinWheelObtained", "Summer Fan" }) then
				activeEvent = `{"Summer"}/DualFans{v3}`
			elseif playerReplion:Get({ "SpinWheelObtained", "Kraken's Shard" }) then
				activeEvent = `{"Summer"}/Fan{v3}`
			end
		end
	elseif match == "Cyber" then
		local playerReplion = getPlayerReplion(p) -- equivalent call inferred; original call site unknown

		if playerReplion then
			if playerReplion:Get({ "SpinWheelObtained", "Neon Viper" }) then
				activeEvent = `{"Cyber"}/DualVipers{v3}`
			elseif playerReplion:Get({ "SpinWheelObtained", "Techblade" }) then
				activeEvent = `{"Cyber"}/Viper{v3}`
			end
		end
	elseif match == "Halloween" then
		local playerReplion = getPlayerReplion(p) -- equivalent call inferred; original call site unknown

		if playerReplion then
			if playerReplion:Get({ "SpinWheelObtained", "Dual Pumpkin Fan" }) then
				activeEvent = `{"Halloween"}/3rdSword{v3}`
			elseif playerReplion:Get({ "SpinWheelObtained", "Pumpkin Fan" }) then
				activeEvent = `{"Halloween"}/2ndSword{v3}`
			end
		end
	elseif match == "Christmas" then
		local playerReplion = getPlayerReplion(p) -- equivalent call inferred; original call site unknown

		if playerReplion then
			if playerReplion:Get({ "SpinWheelObtained", "Jolly Fan" }) then
				activeEvent = `{"Christmas"}/3rdSword{v3}`
			elseif playerReplion:Get({ "SpinWheelObtained", "Christmas Staff" }) then
				activeEvent = `{"Christmas"}/2ndSword{v3}`
			end
		end
	elseif match == "NewYears" then
		local playerReplion = getPlayerReplion(p) -- equivalent call inferred; original call site unknown

		if playerReplion then
			if playerReplion:Get({ "SpinWheelObtained", "New Years Fan" }) then
				activeEvent = `{"NewYears"}/3rdSword{v3}`
			elseif playerReplion:Get({ "SpinWheelObtained", "New Years Staff" }) then
				activeEvent = `{"NewYears"}/2ndSword{v3}`
			end
		end
	elseif match == "Lunar" then
		local playerReplion = getPlayerReplion(p) -- equivalent call inferred; original call site unknown

		if playerReplion then
			if playerReplion:Get({ "SpinWheelObtained", "Serpents Fan" }) then
				activeEvent = `{"Lunar"}/3rdSword{v3}`
			elseif playerReplion:Get({ "SpinWheelObtained", "Serpents Staff" }) then
				activeEvent = `{"Lunar"}/2ndSword{v3}`
			end
		end
	elseif match == "Mech" then
		local playerReplion = getPlayerReplion(p) -- equivalent call inferred; original call site unknown

		if playerReplion then
			if playerReplion:Get({ "SpinWheelObtained", "Holo Fan" }) then
				activeEvent = `{"Mech"}/3rdSword{v3}`
			elseif playerReplion:Get({ "SpinWheelObtained", "Mech Staff" }) then
				activeEvent = `{"Mech"}/2ndSword{v3}`
			end
		end
	elseif match == "Default" then
		local playerReplion = getPlayerReplion(p) -- equivalent call inferred; original call site unknown

		if playerReplion then
			if playerReplion:Get({ "SpinWheelObtained", "Nebula Staff" }) then
				activeEvent = `{"Default"}/DualStaff{v3}`
			elseif playerReplion:Get({ "SpinWheelObtained", "Nebula Shard" }) then
				activeEvent = `{"Default"}/Staff{v3}`
			end
		end
	end

	local child = activeEvent and spinWheel:FindFirstChild(activeEvent)

	if child then
		return require3(child), activeEvent
	end

	return require3(spinWheel.Default), "Default"
end

return SpinWheelRewards