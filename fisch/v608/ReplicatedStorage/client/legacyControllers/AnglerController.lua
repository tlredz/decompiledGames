local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local packages = ReplicatedStorage.packages
local modules = ReplicatedStorage.shared.modules
local Net = require(packages.Net)
local Trove = require(packages.Trove)
local Signal = require(packages.Signal)
local remoteEvent = Net:RemoteEvent("Angler/SendData")
local remoteFunction = Net:RemoteFunction("Angler/GetNeeded")
local v = Signal.new()
local AnglerController = {
	ActiveAnglers = {}
}

function AnglerController.Start(_)
	local localPlayer = Players.LocalPlayer
	workspace:WaitForChild("world"):WaitForChild("npcs")
	local library = require(modules.library)
	local fish = library.fish
	local rarities = library.rarities.Rarities
	local legacyLocalPlayerData = require(ReplicatedStorage.client.modules.legacyLocalPlayerData)

	local function FindCurrentQuest(_, UID: string)
		local fetched = legacyLocalPlayerData.fetch()

		if not fetched then
			return
		end

		local v2 = nil

		for _, child in fetched:FindFirstChild("Quests"):GetChildren() do
			if not string.find(child.Name, "Angler Quest") then
				continue
			end

			for _, child2 in child:GetChildren() do
				local v4 = fish[child2.Name]

				if v4 and v4.Rarity ~= "Extinct" and v4.From == UID then
					return child, child2
				end
			end

			return child, v2
		end

		return nil, v2
	end

	local now = 0

	local function awaitAngler(UID: string)
		local v2 = now

		for _, v3 in CollectionService:GetTagged("NewNpc") do
			if v3:GetAttribute("NpcType") == "Angler" and v3:GetAttribute("UID") == UID then
				return v3
			end
		end

		while now == v2 do
			local v3, v4 = v:Wait()

			if v3 == UID then
				return v4
			end
		end

		return nil
	end

	local UpdateAngler

	UpdateAngler = function(data)
		local _ = data.npcName
		local UID = data.UID
		local trove = data.trove
		local v2 = awaitAngler(UID)

		if not v2 then
			return
		end

		local fetched = legacyLocalPlayerData.fetch()

		if not fetched then
			return
		end

		local function updateSelf()
			task.spawn(UpdateAngler, data)
		end

		local quests = fetched:FindFirstChild("Quests")
		trove:Clean()
		local v3, v4 = FindCurrentQuest(localPlayer, UID)

		if v3 or v4 then
			local hasQuest = v2:FindFirstChild("HumanoidRootPart"):FindFirstChild("HasQuest")

			if hasQuest then
				hasQuest:Destroy()
			end
		else
			local v6 = fish[remoteFunction:InvokeServer(UID)]

			if v6 then
				local clone = script.HasQuest:Clone()
				clone.Parent = v2:FindFirstChild("HumanoidRootPart")

				if rarities[v6.Rarity].ColorGradient then
					clone.icon.UIGradient.Color = rarities[v6.Rarity].ColorGradient
					clone.icon.UIGradient.Enabled = true
					clone.icon.ImageColor3 = Color3.new(1, 1, 1)
				else
					clone.icon.UIGradient.Enabled = false
					clone.icon.ImageColor3 = rarities[v6.Rarity].Color
				end
			end
		end

		if v4 and v3:FindFirstChild(v4.Name) then
			trove:Add(v3:FindFirstChild(v4.Name):GetPropertyChangedSignal("Value"):Connect(updateSelf))
			return
		end

		trove:Add(quests.ChildAdded:Connect(updateSelf))
		trove:Add(quests.ChildRemoved:Connect(updateSelf))
	end

	remoteEvent.OnClientEvent:Connect(function(items)
		AnglerController.ActiveAnglers = {}
		now = os.time()

		for k, item in items do
			AnglerController.ActiveAnglers[k] = {
				npcName = item.npcName,
				UID = item.UID
			}

			if not AnglerController.ActiveAnglers[k].trove then
				AnglerController.ActiveAnglers[k].trove = Trove.new()
			end

			task.spawn(UpdateAngler, AnglerController.ActiveAnglers[k])
		end
	end)

	-- equivalent calls inferred from this helper; original call sites unknown
	local function onNpcLoaded(instance)
		if instance:GetAttribute("NpcType") == "Angler" and instance:IsDescendantOf(workspace) then
			v:Fire(instance:GetAttribute("UID"), instance)
		end
	end

	CollectionService:GetInstanceAddedSignal("NewNpc"):Connect(onNpcLoaded)

	for _, v2 in CollectionService:GetTagged("NewNpc") do
		onNpcLoaded(v2) -- equivalent call inferred; original call site unknown
	end
end

return AnglerController