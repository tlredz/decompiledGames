local Breathings = require(script.Parent.Breathings)
local DemonArts = require(script.Parent.DemonArts)
local FightingStyles = require(script.Parent.FightingStyles)
local Resolve = {
	Resolve = function(value)
		if type(value) ~= "string" then
			return nil
		end

		if Breathings[value] ~= nil then
			return "Breathing", Breathings[value]
		end

		if DemonArts[value] ~= nil then
			return "DemonArt", DemonArts[value]
		end

		if FightingStyles[value] == nil then
			return nil
		end

		return "FightingStyle", FightingStyles[value]
	end
}

function Resolve.Icon(p)
	local _, v = Resolve.Resolve(p)
	return v ~= nil and v.Icon or nil
end

function Resolve.DisplayName(p)
	local resolved = Resolve.Resolve(p)

	if resolved == nil then
		return nil
	elseif resolved == "Breathing" then
		return (`{p} Breathing`)
	end

	return p
end

function Resolve.NameOf(p)
	if type(p) == "table" then
		return p.Name
	end

	return p
end

function Resolve.LaneCarries(value: string, value2: string)
	local v = string.lower(value)
	local v2 = string.lower(value2)
	return (string.find(v, "all", 1, true) ~= nil or string.find(v, v2, 1, true) ~= nil) and string.find(
		v,
		"except" .. v2,
		1,
		true
	) == nil
end

return Resolve