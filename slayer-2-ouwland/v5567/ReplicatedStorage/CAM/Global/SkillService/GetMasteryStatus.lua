local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Breathings = require(ReplicatedStorage.CAM.Global.Powers.Breathings)
local DemonArts = require(ReplicatedStorage.CAM.Global.Powers.DemonArts)
local FightingStyles = require(ReplicatedStorage.CAM.Global.Powers.FightingStyles)
local Items = require(ReplicatedStorage.CAM.Global.Collectibles.Items)
local MovesetsIcons = require(script.Parent.MovesetsIcons)
local simplesignal = require(ReplicatedStorage.Packages.simplesignal)
local curPower = game.ReplicatedStorage.CAM.Client.Controllers.Skills_Provider:FindFirstChild("CurPower")
local GetMasteryStatus = {
	Changed = simplesignal.new()
}

local function getIcon(p, p2)
	return MovesetsIcons[p] or p2 and p2.Icon or nil
end

local function getMasteryName(p, value)
	if type(value) == "string" then
		return value
	end

	if type(value) == "table" then
		return value.Value or p
	end

	return p
end

function GetMasteryStatus.GetMasteries()
	local value = curPower.Value

	if not (#value > 0) then
		return nil
	end

	local v = string.split(value, ",")
	local result = {}

	for _, value2 in ipairs(v) do
		local v2 = Breathings[value2] or DemonArts[value2] or FightingStyles[value2]

		if v2 then
			local mastery = v2.Mastery

			if mastery ~= false then
				if type(mastery) == "string" then
					value2 = mastery
				elseif type(mastery) == "table" then
					value2 = mastery.Value or value2
				end

				table.insert(result, {
					Name = value2,
					Icon = MovesetsIcons[value2] or v2 and v2.Icon or nil,
					Mastery = mastery or nil
				})
			end
		else
			local item = Items[value2]

			if item then
				local mastery = item.Mastery

				if mastery ~= false then
					if type(mastery) == "string" then
						value2 = mastery
					elseif type(mastery) == "table" then
						value2 = mastery.Value or value2
					end

					table.insert(result, {
						Name = value2,
						Icon = MovesetsIcons[value2] or item and item.Icon or nil,
						Mastery = mastery or nil
					})
				end
			end
		end
	end

	return result
end

function updateMasteries()
	GetMasteryStatus.Changed:Fire(GetMasteryStatus.GetMasteries())
end

curPower.Changed:Connect(updateMasteries)
return GetMasteryStatus