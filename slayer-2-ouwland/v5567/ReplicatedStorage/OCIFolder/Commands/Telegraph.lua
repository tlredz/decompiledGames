local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local isServer = RunService:IsServer()
local result = {}
local v = {}

if not isServer then
	local v2 = {}

	for _, child in ReplicatedStorage.Skills:GetChildren() do
		for _, folder in child:GetChildren() do
			if not folder:IsA("Folder") then
				continue
			end

			v2[folder.Name] = true

			for _, moduleScript in folder:GetChildren() do
				if not moduleScript:IsA("ModuleScript") or moduleScript.Name == "Config" or moduleScript.Name:find("Server$") then
					continue
				end

				v2[moduleScript.Name] = true
			end
		end
	end

	for k in v2 do
		table.insert(result, k)
	end

	table.sort(result)

	for _, v3 in result do
		table.insert(v, v3:lower())
	end
end

local v2

if isServer then
	local ServerStorage = game:GetService("ServerStorage")
	v2 = require(ServerStorage.SAM.AiThings.NpcNetwork.Tasks.CastTelegraph) or nil
else
	v2 = nil
end

return {
	Clearance = 1,
	Keys = {
		{
			Type = "Players",
			Required = true
		},
		{
			Type = "Skill",
			Name = "Skill",
			Required = true,
			Suggester = function()
				return result, true
			end,
			Completer = function(value: string)
				if value == nil or value == "" then
					return nil
				end

				local index = table.find(v, value:lower())

				if index == nil then
					return value
				end

				return result[index]
			end
		}
	},
	Server = function(_, items, value: string)
		local ServerStorage = game:GetService("ServerStorage")
		local v3 = nil

		for _, moduleScript in ServerStorage.AiSkills.Performers:GetDescendants() do
			if not (moduleScript:IsA("ModuleScript") and moduleScript.Name:lower() == value:lower()) then
				continue
			end

			v3 = moduleScript
			break
		end

		local v5

		if v3 ~= nil then
			local module = require(v3)
			v5 = module or nil
		end

		if v5 == nil or v5.Telegraph == nil then
			error((`No AI performer named "{value}" carries a telegraph`))
		end

		for _, item in items do
			local character = item.Character

			if character ~= nil then
				v2.Begin({
					UniqueName = `{item.Name}-{v3.Name}`,
					Stats = {
						CastTelegraph = 1
					},
					Spawning = {
						Entity = character
					},
					Following = {}
				}, v3.Name, {}, v5, nil)
			end
		end
	end
}