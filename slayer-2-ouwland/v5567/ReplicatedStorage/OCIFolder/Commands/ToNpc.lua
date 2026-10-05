local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Menum = require(ReplicatedStorage.CAM.Global.Menum)
local v = nil

local function catalog()
	if v ~= nil then
		return v
	end

	local success, regions = pcall(require, ReplicatedStorage:FindFirstChild("Regions"))

	if not success then
		return {}
	end

	local positionsByName = {}

	for _, region in regions.Regions do
		for _, v2 in region.Npcs or {} do
			local locations = nil

			if v2.Type == Menum.npcType.Active then
				local spawning = v2.SendOver and v2.SendOver.Spawning
				locations = spawning and spawning.Locations
			elseif v2.Type == Menum.npcType.Stationary or v2.Type == Menum.npcType.Idle then
				locations = v2.Spawns

				if locations and locations.Multiple == true then
					locations = locations[1]
				end
			end

			local position = locations and locations[1]

			if not (v2.Name and position and positionsByName[v2.Name] == nil) then
				continue
			end

			local name = v2.Name

			if typeof(position) == "CFrame" then
				position = position.Position
			end

			positionsByName[name] = position
		end
	end

	v = positionsByName
	return positionsByName
end

local function liveRoot(p: string)
	for _, v2 in { workspace.Debree, workspace.Humanoids } do
		local regions = v2:FindFirstChild("Regions")

		if regions == nil then
			continue
		end

		for _, v3 in regions:QueryDescendants("Model") do
			if v3.Name ~= p then
				continue
			end

			local humanoidRootPart = v3:FindFirstChild("HumanoidRootPart")

			if humanoidRootPart ~= nil then
				return humanoidRootPart
			end
		end
	end

	return nil
end

return {
	Clearance = 1,
	Keys = {
		{
			Type = "Players",
			Required = true
		},
		{
			Type = "String",
			Name = "Npc",
			Required = true,
			Suggester = function()
				local result = {}

				for k in catalog() do
					table.insert(result, k)
				end

				table.sort(result)
				return result, true
			end,
			Completer = function(value: string)
				if value == nil or value == "" then
					return nil
				end

				local lower = value:lower()

				for k in catalog() do
					if k:lower() == lower then
						return k
					end
				end

				return value
			end
		}
	},
	Server = function(_, items, p: string)
		local v2 = liveRoot(p)
		local position = v2 ~= nil and v2.Position or catalog()[p]

		if position == nil then
			error((`ToNpc: no NPC named "{p}" in this place`))
		end

		local names = {}

		for _, item in items do
			local character = item.Character

			if character == nil then
				continue
			end

			local v3 = position + Vector3.new(#names * 4, 0, 6)
			character:PivotTo(CFrame.lookAt(v3, position))
			character:MoveTo(v3)
			table.insert(names, item.Name)
		end

		if #names == 0 then
			error("ToNpc: no targeted player has a character to move")
		end

		return {
			Content = `Sent {table.concat(names, ", ")} to {p} ({v2 == nil and "authored spawn, nothing up" or "live rig"})`,
			BgColor = Color3.fromRGB(32, 143, 70),
			FgColor = Color3.new(1, 1, 1)
		}
	end
}