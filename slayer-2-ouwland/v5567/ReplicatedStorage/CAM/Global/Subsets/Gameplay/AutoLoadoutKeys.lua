local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HudGrid = require(ReplicatedStorage.CAM.HudGrid)
local Worlds = require(ReplicatedStorage.CAM.Worlds)
local AutoLoadoutKeys = {
	Scope = "Slot",
	Action = "AutoLoadout",
	Default = "",
	Worlds = {}
}

for k, gate in Worlds.Grid do
	if not gate.Ignore then
		table.insert(AutoLoadoutKeys.Worlds, {
			Key = tostring(gate.Id),
			Label = k,
			Gate = gate
		})
	end
end

table.sort(AutoLoadoutKeys.Worlds, function(a, b)
	return a.Label < b.Label
end)
AutoLoadoutKeys.Modes = {}

for _, gate in HudGrid.Grid do
	if not gate.Ignore then
		table.insert(AutoLoadoutKeys.Modes, {
			Key = gate.Name,
			Label = gate.Title or gate.Name,
			Gate = gate
		})
	end
end

table.sort(AutoLoadoutKeys.Modes, function(a, b)
	return a.Gate.Order < b.Gate.Order
end)
AutoLoadoutKeys.ByKey = {}

for _, v in { AutoLoadoutKeys.Worlds, AutoLoadoutKeys.Modes } do
	for _, v2 in v do
		AutoLoadoutKeys.ByKey[v2.Key] = v2
	end
end

function AutoLoadoutKeys.Path(p: string)
	return (`Misc/AutoLoadout/{p}`)
end

return AutoLoadoutKeys