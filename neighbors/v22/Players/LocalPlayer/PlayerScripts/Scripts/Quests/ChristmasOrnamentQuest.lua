local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local christmasOrnaments = ReplicatedStorage.Assets.QuestAssets.ChristmasOrnaments
local prefabs = ReplicatedStorage:FindFirstChild("Prefabs") or workspace:FindFirstChild("Prefabs")
local Network = require(ReplicatedStorage.Modules.Network)
local v = 6
local v2 = {}
local flag = false

local function getCurrentSkin()
	local currentInternalMap = localPlayer:GetAttribute("CurrentInternalMap")

	if not currentInternalMap then
		return
	end

	local child = workspace.Places:FindFirstChild(currentInternalMap)

	if child then
		return child:GetAttribute("SkinName")
	end

	return "Default"
end

local function getCurrentPrefab()
	local currentInternalMap = localPlayer:GetAttribute("CurrentInternalMap")
	local v3

	if currentInternalMap then
		local child = workspace.Places:FindFirstChild(currentInternalMap)
		v3 = not child and "Default" or child:GetAttribute("SkinName")
	end

	if not v3 then
		return
	end

	return (prefabs:FindFirstChild((`{v3}Prefab`)))
end

local function getPrefabOrnamentPositions()
	local currentInternalMap = localPlayer:GetAttribute("CurrentInternalMap")
	local v3

	if currentInternalMap then
		local child = workspace.Places:FindFirstChild(currentInternalMap)
		v3 = not child and "Default" or child:GetAttribute("SkinName")
	end

	local child

	if v3 then
		child = prefabs:FindFirstChild((`{v3}Prefab`))
	end

	if not child then
		return
	end

	local prefab = child:FindFirstChild("Prefab")

	if not prefab then
		return
	end

	local ornamentQuestPositions = prefab:FindFirstChild("OrnamentQuestPositions")

	if ornamentQuestPositions then
		return ornamentQuestPositions, prefab
	end

	local currentInternalMap2 = localPlayer:GetAttribute("CurrentInternalMap")
	local v5

	if currentInternalMap2 then
		local child2 = workspace.Places:FindFirstChild(currentInternalMap2)
		v5 = not child2 and "Default" or child2:GetAttribute("SkinName")
	end

	warn((`Skin {v5} has no ornament quest positions!`))
end

local function startQuest(p)
	flag = true
	v = p
	local children = christmasOrnaments:GetChildren()
	local v3 = #children
	local prefabOrnamentPositions, parent = getPrefabOrnamentPositions()

	if not (prefabOrnamentPositions and parent) then
		return
	end

	local tagged = CollectionService:GetTagged("OrnamentQuestTreeOrnament")

	for k, folder in pairs(tagged) do
		if 6 - v < k then
			break
		end

		if not (folder:GetAttribute("OrnamentIndex") == k and folder:IsDescendantOf(parent)) then
			continue
		end

		for _, part in pairs(folder:GetDescendants()) do
			if part:IsA("BasePart") then
				part.Transparency = 0
			end
		end
	end

	local children2 = prefabOrnamentPositions:GetChildren()

	for i = 1, v do
		local v5 = children2[i]
		local v6 = children[math.random(v3)]

		if not (v5 and v6) then
			break
		end

		local clone = v6:Clone()
		clone:PivotTo(v5.CFrame)
		local clickDetector = Instance.new("ClickDetector")
		clickDetector.Parent = clone
		local v8 = i
		clickDetector.MouseClick:Connect(function()
			if not Network:invoke("ProgressChristmasQuest") then
				return
			end

			clone:Destroy()
			local currentInternalMap = localPlayer:GetAttribute("CurrentInternalMap")
			local v9

			if currentInternalMap then
				local child = workspace.Places:FindFirstChild(currentInternalMap)
				v9 = not child and "Default" or child:GetAttribute("SkinName")
			end

			local child

			if v9 then
				child = prefabs:FindFirstChild((`{v9}Prefab`))
			end

			if not child then
				return
			end

			local tagged2 = CollectionService:GetTagged("OrnamentQuestTreeOrnament")

			for k, folder in pairs(tagged2) do
				if not (folder:GetAttribute("OrnamentIndex") == v8 and folder:IsDescendantOf(child)) then
					continue
				end

				for i2, part in pairs(folder:GetDescendants()) do
					if part:IsA("BasePart") then
						part.Transparency = 0
					end
				end
			end
		end)
		clone.Parent = parent
		table.insert(v2, clone)
	end
end

Network:listen("StartChristmasQuestNew", function(p)
	startQuest(p)
end)
Network:listen("EndChristmasQuestNew", function()
	for k, v3 in pairs(v2) do
		v3:Destroy()
		v2[k] = nil
	end

	flag = false
end)
localPlayer:GetAttributeChangedSignal("CurrentInternalMap"):Connect(function()
	if #v2 > 0 then
		local prefabOrnamentPositions, parent = getPrefabOrnamentPositions()

		if not prefabOrnamentPositions then
			return
		end

		local children = prefabOrnamentPositions:GetChildren()

		for k, v4 in pairs(v2) do
			local v5 = children[k]

			if not v5 then
				return
			end

			v4:PivotTo(v5.CFrame)
			v4.Parent = parent
		end
	elseif flag then
		startQuest(v)
	end
end)