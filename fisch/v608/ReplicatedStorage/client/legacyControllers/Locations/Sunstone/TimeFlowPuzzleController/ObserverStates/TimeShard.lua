local ReplicatedStorage = game:GetService("ReplicatedStorage")
local packages = ReplicatedStorage.packages
local State = require(packages.State)
local Trove = require(packages.Trove)
local modules = ReplicatedStorage.shared.modules
local SharedTimeFlowPuzzle = require(modules.SharedTimeFlowPuzzle)
require("../Types")
local completionStateObjects = {
	Collected = State.new(false)
}

local function observerCallback(folder)
	local maid = Trove.new()
	folder:AddTag("FloatingObject")
	maid:Add(completionStateObjects.Collected:observe(function(flag: boolean)
		if flag and folder:HasTag("FloatingObject") then
			folder:RemoveTag("FloatingObject")
			local proximityPrompt = folder:FindFirstChildWhichIsA("ProximityPrompt", true)

			if proximityPrompt then
				proximityPrompt.Enabled = false
			end

			for _, part in folder:GetDescendants() do
				if not part:IsA("BasePart") then
					continue
				end

				part.CanCollide = false
				part.Transparency = 1
			end
		end
	end, true))
	return function()
		folder:RemoveTag("FloatingObject")
		maid:Destroy()
	end
end

return {
	ObserverCallback = observerCallback,
	CompletionStateObjects = completionStateObjects,
	Tag = SharedTimeFlowPuzzle.CollectionServiceTags.TimeShardRender
}