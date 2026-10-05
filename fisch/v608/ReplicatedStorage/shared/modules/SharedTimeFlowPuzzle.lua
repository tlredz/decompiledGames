local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local packages = ReplicatedStorage.packages
local Net = require(packages.Net)
local v = {
	CollectionServiceTags = {
		TimeShardRender = "TimeShardRender",
		MinecartContainer = "MinecartContainer",
		GemPlacements = "GemPlacements",
		FirstPuzzleDebris = "FirstPuzzleDebris"
	},
	Network = {
		CartStopped = Net:RemoteEvent("TimeFlow/Cut/CartStopped"),
		CollectCutGem = Net:RemoteEvent("TimeFlow/Cut/Collect")
	},
	Functions = {
		GetNearestRoughGeodeBlocker = function(player, value: number?)
			local v2 = value or 1e999
			local character = player.Character

			if not character then
				return
			end

			local primaryPart = character.PrimaryPart

			if not primaryPart then
				return
			end

			local position = primaryPart.Position
			local tagged = CollectionService:GetTagged("FirstPuzzleDebris")

			if #tagged == 0 then
				return
			end

			local children = tagged[1].Blockers:GetChildren()
			local v3 = 1e999
			local v4 = nil
			local UID = nil

			for _, v5 in children do
				local basePart = v5:FindFirstChildWhichIsA("BasePart")

				if not basePart then
					continue
				end

				local magnitude = (position - basePart.Position).Magnitude

				if not (v2 and magnitude < v2 and magnitude < v3) then
					continue
				end

				UID = v5:GetAttribute("UID")
				v4 = v5
				v3 = magnitude
			end

			if v4 and UID then
				return v4, UID
			end

			return nil, nil
		end
	}
}
return table.freeze(v)