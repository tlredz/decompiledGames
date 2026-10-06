local Gacha = require(script.Parent.Gacha)
local Progression = require(script.Parent.Progression)
local Upgrade = require(script.Parent.Upgrade)
local Profession = require(script.Parent.Profession)
local Traits = require(script.Parent.Traits)
local Breathings = require(script.Parent.Breathings)
local Stars = require(script.Parent.Stars)
local Perks = require(script.Parent.Perks)
local Gamemodes = require(script.Parent.Gamemodes)
local Prestige = require(script.Parent.Prestige)
local SacredArtefacts = require(script.Parent.SacredArtefacts)
local Quests = require(script.Parent.Quests)
local v = {
	Stars = Stars,
	Gacha = Gacha,
	Progression = Progression,
	Upgrade = Upgrade,
	Profession = Profession,
	Gamemodes = Gamemodes
}
local v2 = {
	Traits = Traits,
	Breathings = Breathings,
	Prestige = Prestige,
	["Sacred Artefacts"] = SacredArtefacts
}
local v3 = {
	Stars = 1,
	Dialog = 2
}
local RemoteSystems = {}

local function GetMainQuest(p: string)
	local main = Quests.List.Main

	if not main then
		return nil
	end

	for _, v4 in main.List do
		if v4.Npc == p then
			return v4
		end
	end

	return nil
end

function RemoteSystems.Get(kind: string, name: string)
	if kind == "Dialog" then
		local main = Quests.List.Main
		local v4

		if main then
			for _, v6 in main.List do
				if v6.Npc ~= name then
					continue
				end

				v4 = v6
				break
			end
		end

		if v4 then
			return {
				Kind = "Dialog",
				Name = name,
				FrameName = "Dialog",
				MapName = v4.Name,
				Icon = "rbxassetid://135055929772122",
				OpenFrame = false
			}
		end

		return nil
	else
		local v4 = v[kind]
		local v5

		if v4 then
			v5 = v4.List[name]
		elseif name == kind then
			v5 = v2[kind]
		end

		if v5 then
			return {
				Kind = kind,
				Name = name,
				FrameName = kind == "Stars" and "Star" or kind,
				MapName = v5.MapName or v5.Map,
				Icon = v5.Icon or kind ~= "Stars" and "" or Perks["Star Open"].Icon,
				OpenFrame = v2[kind] ~= nil
			}
		end

		return nil
	end
end

function RemoteSystems.GetForMap(p: string)
	local result = {}

	for k, v4 in v do
		for k2 in v4.List do
			local v5 = RemoteSystems.Get(k, k2)

			if v5 and v5.MapName == p then
				table.insert(result, v5)
			end
		end
	end

	for k in v2 do
		local v4 = RemoteSystems.Get(k, k)

		if v4 and v4.MapName == p then
			table.insert(result, v4)
		end
	end

	local main = Quests.List.Main
	local v4 = main and main.List[p]

	if v4 and v4.Npc then
		local dialog = RemoteSystems.Get("Dialog", v4.Npc)

		if dialog and dialog.MapName == p then
			table.insert(result, dialog)
		end
	end

	table.sort(result, function(a, b)
		local v5 = v3[a.Kind] or 1e999
		local v6 = v3[b.Kind] or 1e999

		if v5 == v6 then
			return a.Name < b.Name
		end

		return v5 < v6
	end)
	return result
end

return RemoteSystems