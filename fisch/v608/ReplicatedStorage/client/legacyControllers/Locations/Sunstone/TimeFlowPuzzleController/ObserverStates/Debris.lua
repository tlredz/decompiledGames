local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local packages = ReplicatedStorage.packages
local State = require(packages.State)
local Trove = require(packages.Trove)
local Net = require(packages.Net)
local modules = ReplicatedStorage.shared.modules
local SharedTimeFlowPuzzle = require(modules.SharedTimeFlowPuzzle)
require("../Types")
local completionStateObjects = {
	CollectedReward = State.new(false),
	ClearedDebrisUIDs = State.new({})
}
local remoteEvent = Net:RemoteEvent("TimeFlowPuzzle/GeodeCollect")

local function observerCallback(p)
	local maid = Trove.new()
	local blockers = p.Blockers
	local geode = p.Geode
	local v2 = {}

	local function onAttributeReceived(sessionGeode)
		local v3 = nil

		for _, child in blockers:GetChildren() do
			if child:GetAttribute("UID") ~= sessionGeode then
				continue
			end

			v3 = child
			break
		end

		if v3 then
			geode:PivotTo(v3:GetPivot() * CFrame.new(0, 0.55, 0))

			if table.find(v2, sessionGeode) then
				local proximityPrompt = geode:WaitForChild("ProximityPrompt")
				proximityPrompt.Enabled = true
			end
		end
	end

	local sessionGeode = Players.LocalPlayer:GetAttribute("SessionGeode")

	if sessionGeode then
		onAttributeReceived(sessionGeode)
	end

	maid:Add(Players.LocalPlayer:GetAttributeChangedSignal("SessionGeode"):Connect(function()
		onAttributeReceived(Players.LocalPlayer:GetAttribute("SessionGeode"))
	end))

	local function completeUid(UID, part)
		-- equivalent calls inferred from this helper; original call sites unknown
		local function forBasePart(p2)
			p2.CanCollide = false
			p2.Transparency = 1
		end

		if part:IsA("BasePart") then
			forBasePart(part) -- equivalent call inferred; original call site unknown
		end

		for _, descendant in part:GetDescendants() do
			forBasePart(descendant) -- equivalent call inferred; original call site unknown
		end

		if not table.find(v2, UID) then
			completionStateObjects.ClearedDebrisUIDs:get()
			table.insert(v2, UID)
		end

		if Players.LocalPlayer:GetAttribute("SessionGeode") == UID then
			local proximityPrompt = geode:WaitForChild("ProximityPrompt")
			proximityPrompt.Enabled = true
		end
	end

	maid:Add(completionStateObjects.CollectedReward:observe(function(flag: boolean)
		if flag then
			geode.Parent = nil
		end
	end, true))
	maid:Add(completionStateObjects.ClearedDebrisUIDs:observe(function(list)
		for _, child in blockers:GetChildren() do
			local UID = child:GetAttribute("UID")

			if table.find(list, UID) then
				completeUid(UID, child)
			end
		end
	end))
	maid:Add(geode:WaitForChild("ProximityPrompt").Triggered:Connect(function()
		remoteEvent:FireServer()
	end))
	return function()
		maid:Destroy()
	end
end

return {
	ObserverCallback = observerCallback,
	CompletionStateObjects = completionStateObjects,
	Tag = SharedTimeFlowPuzzle.CollectionServiceTags.FirstPuzzleDebris
}