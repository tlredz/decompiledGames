local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Menum = require(ReplicatedStorage.CAM.Global.Menum)
local LiveConfig = require(ReplicatedStorage.CAM.Global.LiveConfig)

local function tableIcon(p: string)
	local npcDataTable = LiveConfig.get("NpcDataTable")
	local v

	if typeof(npcDataTable) == "table" then
		v = npcDataTable[p]
	end

	local icon

	if typeof(v) == "table" then
		icon = v.Icon
	end

	if typeof(icon) == "string" and icon ~= "" then
		return icon
	end

	return nil
end

local simplesignal = require(ReplicatedStorage.Packages.simplesignal)
local WorldBosses = {
	Updated = simplesignal.new()
}
local v = nil
local v2 = {}

local function gather()
	local Regions = require(ReplicatedStorage.Regions)
	local result = {}

	for _, region in Regions.Regions do
		for _, v3 in region.Npcs or {} do
			local sendOver = v3.SendOver

			if not (v3.Type == Menum.npcType.Active and sendOver ~= nil and sendOver.Boss ~= nil) then
				continue
			end

			local spawning = sendOver.Spawning
			local center

			if spawning ~= nil then
				center = spawning.Center or spawning.Locations and spawning.Locations[1]
			end

			if center == nil then
				continue
			end

			if typeof(center) == "CFrame" then
				center = center.Position
			end

			local settings = sendOver.Settings
			local npcCode = settings ~= nil and settings.NpcCode or v3.Name
			local v4 = {
				Code = npcCode,
				Name = v3.Name,
				Icon = 0,
				Position = 0
			}
			local icon

			if typeof(v3.Icon) == "string" and v3.Icon ~= "" then
				icon = v3.Icon
			else
				local npcDataTable = LiveConfig.get("NpcDataTable")
				local v5

				if typeof(npcDataTable) == "table" then
					v5 = npcDataTable[npcCode]
				end

				if typeof(v5) == "table" then
					icon = v5.Icon
				end

				if typeof(icon) ~= "string" or icon == "" then
					icon = nil
				end
			end

			v4.Icon = icon
			v4.Position = center
			table.insert(result, v4)
			v2[v4.Code] = v4
		end
	end

	table.sort(result, function(a, b)
		return a.Name < b.Name
	end)
	return result
end

function WorldBosses.Get()
	if v == nil then
		v = gather()
	end

	return v
end

function WorldBosses.ByCode(p: string)
	WorldBosses.Get()
	local v3 = v2[p]

	if v3 == nil or v3.Icon ~= nil then
		return v3
	end

	local npcDataTable = LiveConfig.get("NpcDataTable")
	local v4

	if typeof(npcDataTable) == "table" then
		v4 = npcDataTable[p]
	end

	local icon

	if typeof(v4) == "table" then
		icon = v4.Icon
	end

	if typeof(icon) ~= "string" or icon == "" then
		icon = nil
	end

	v3.Icon = icon
	return v3
end

LiveConfig.listen("NpcDataTable", function()
	if v ~= nil then
		for _, v3 in v do
			if v3.Icon ~= nil then
				continue
			end

			local code = v3.Code
			local npcDataTable = LiveConfig.get("NpcDataTable")
			local v4

			if typeof(npcDataTable) == "table" then
				v4 = npcDataTable[code]
			end

			local icon

			if typeof(v4) == "table" then
				icon = v4.Icon
			end

			if typeof(icon) ~= "string" or icon == "" then
				icon = nil
			end

			v3.Icon = icon
		end
	end

	WorldBosses.Updated:Fire()
end)
return WorldBosses