local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
require3(script.Parent.ValueGroup)
local v = require3(ReplicatedStorage2.Packages.Signal)
local events = {}
local v3 = {}
local Events = {
	Events = events
}

events["On join"] = function(p)
	p.Player = p.Player:extend({ "Joiner" })
end

events["On leave"] = function(p)
	p.Player = p.Player:extend({ "Leaver" })
end

events["On death"] = function(p)
	p.Player = p.Player:extend({ "Dead" })
end

events["On killed"] = function(p)
	p.Player = p.Player:extend({ "Killed", "Killer" })
end

events["On parried"] = function(p)
	p.Player = p.Player:extend({ "Parrier", "Parrier target" })
end

events["On ability use"] = function(p)
	p.Player = p.Player:extend({ "User" })
end

events["On targeted ability use"] = function(p)
	p.Player = p.Player:extend({ "Ability user", "Ability target" })
end

events["On ball spawn"] = nil

function Events:_updateCache()
	for k in next, events, nil do
		if not v3[k] then
			v3[k] = {}
		end
	end
end

Events:_updateCache()

function Events.getSignalFor(_, p: string)
	if not events[p] then
		events[p] = v.new()
	end

	return events[p]
end

function Events.adjustScopeFor(_, p: string, p2)
	local v4 = v3[p][tostring(p2)]

	if v4 then
		return v4
	end

	local v5 = events[p]

	if not v5 then
		return p2
	end

	local clone = table.clone(p2)
	v5(clone)
	table.freeze(clone)
	v3[p][tostring(p2)] = clone
	return clone
end

return Events