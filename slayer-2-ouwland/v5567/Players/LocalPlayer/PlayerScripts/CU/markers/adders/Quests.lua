local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local MarkerHandler = require(ReplicatedStorage.CAM.Client.Modules.MarkerHandler)
local BunchaIcons = require(ReplicatedStorage.CAM.Global.BunchaIcons)
local Quests = require(ReplicatedStorage.CAM.Global.Subsets.Gameplay.Quests)
local Regions = require(ReplicatedStorage.Regions)

local function resolveNpcTop(npc: string)
	local debree = workspace:FindFirstChild("Debree")
	local regions

	if debree ~= nil then
		regions = debree:FindFirstChild("Regions") or nil
	end

	if regions ~= nil then
		for _, child in regions:GetChildren() do
			local stationaryNpcs = child:FindFirstChild("StationaryNpcs")
			local child2

			if stationaryNpcs == nil then
				child2 = false
			else
				child2 = stationaryNpcs:FindFirstChild(npc)
			end

			if child2 then
				return child2:GetAttribute("Top") or child2:GetPivot().Position
			end
		end
	end

	local npcSpawn = Regions.GetNpcSpawn(npc)

	if npcSpawn == nil then
		return nil
	end

	return npcSpawn + createVector(0, 5, 0)
end

local color = Color3.fromRGB(255, 60, 60)
local color2 = Color3.new(1, 1, 1)
local v = {
	Combat = color,
	BossHunt = color
}

-- equivalent calls inferred from this helper; original call sites unknown
local function onMapToo(p, p2: string)
	local clone = table.clone(p)
	clone.onMap = true
	clone.ping = v[Quests.GetQuestCategory(p2)] or color2
	return clone
end

return function(_, instance)
	local function taskMarkerKey(p: string, p2: string)
		return p .. " - " .. p2
	end

	local v2 = {}
	local v3 = {}

	local function questAdded(child)
		local name = child.Name
		local questString = child:FindFirstChild("QuestString")
		local value

		if questString == nil then
			value = name
		else
			value = questString.Value or name
		end

		local v4 = Quests.Holder[value]

		if v4 == nil then
			return
		end

		local markerData = v4.MarkerData
		local clone = markerData == nil and v4.Position ~= nil and {
			position = v4.Position,
			img = BunchaIcons[v4.Category] or BunchaIcons.Combat,
			minDistance = 35,
			margin = 10
		} or markerData

		if clone ~= nil then
			if clone.position == nil then
				local npc = clone.Npc

				if not npc then
					if clone.useName == nil then
						npc = nil
					else
						npc = string.match(clone.useName, "^(.+)%-AddedByAreaLocator$") or nil
					end
				end

				local position

				if npc ~= nil then
					position = resolveNpcTop(npc) or nil
				end

				if position ~= nil then
					clone = table.clone(clone)
					clone.position = position
				end
			end

			if clone.position ~= nil then
				MarkerHandler.addMarker(name, onMapToo(clone, value))
			end
		end

		local connections = {}
		v2[name] = connections
		local v5 = {}
		v3[name] = v5

		for _, child2 in ipairs(child.Tasks:GetChildren()) do
			local taskMarker = Quests.GetTaskMarker(v4, child2)
			local useName = nil
			local position

			if taskMarker == nil then
				position = nil
			else
				position = taskMarker.Position

				if taskMarker.Npc ~= nil then
					position = position or resolveNpcTop(taskMarker.Npc)
					useName = taskMarker.Npc .. "-AddedByAreaLocator"
				end
			end

			if not (taskMarker ~= nil and position ~= nil) then
				continue
			end

			local value2 = child2.Value
			local max = child2.Max
			local v7 = name .. " - " .. child2.Name
			table.insert(v5, v7)
			local children = {}

			if taskMarker.After ~= nil then
				for _, childName in ipairs(taskMarker.After) do
					local child3 = child.Tasks:FindFirstChild(childName)

					if child3 ~= nil then
						table.insert(children, child3)
					end
				end
			end

			local need = child2:FindFirstChild("Need")
			local child3

			if need ~= nil then
				child3 = child.Tasks:FindFirstChild(need.Value) or nil
			end

			if child3 ~= nil and table.find(children, child3) == nil then
				table.insert(children, child3)
			end

			local v8 = false
			local v13 = taskMarker

			local function sync()
				local v14 = value2.Value < max.Value

				if v14 then
					for i, v16 in ipairs(children) do
						if not (v16.Value.Value < v16.Max.Value) then
							continue
						end

						v14 = false
						break
					end
				end

				if v14 and not v8 then
					v8 = true
					MarkerHandler.addMarker(v7, onMapToo({
						position = position,
						img = v13.Icon ~= nil and v13.Icon ~= "" and v13.Icon or v13.Npc ~= nil and Regions.GetNpcIcon(v13.Npc) or BunchaIcons[v4.Category] or BunchaIcons.Combat,
						useName = useName,
						minDistance = 35,
						margin = 10
					}, value))
				elseif not v14 and v8 then
					v8 = false
					MarkerHandler.removeMarker(v7)
				end
			end

			table.insert(connections, value2.Changed:Connect(sync))

			for _, v14 in ipairs(children) do
				table.insert(connections, v14.Value.Changed:Connect(sync))
			end

			sync()
		end
	end

	local function questRemoved(p)
		local name = p.Name
		MarkerHandler.removeMarker(name)
		local v4 = v2[name]

		if v4 ~= nil then
			for _, connection in ipairs(v4) do
				connection:Disconnect()
			end

			v2[name] = nil
		end

		local v5 = v3[name]

		if v5 ~= nil then
			for _, v6 in ipairs(v5) do
				MarkerHandler.removeMarker(v6)
			end

			v3[name] = nil
		end
	end

	local holder = instance:WaitForChild("Quests"):WaitForChild("Holder")

	for _, child in ipairs(holder:GetChildren()) do
		questAdded(child)
	end

	holder.ChildAdded:Connect(function(child)
		child:WaitForChild("QuestString")
		questAdded(child)
	end)
	holder.ChildRemoved:Connect(questRemoved)
end