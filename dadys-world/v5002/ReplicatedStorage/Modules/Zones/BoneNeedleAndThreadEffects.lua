local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HighlightController = require(ReplicatedStorage.SharedUtils.HighlightController)
local CollectionService = game:GetService("CollectionService")

local function getCollectionPieceTarget()
	local success, holidayCollectionHunting = pcall(require, ReplicatedStorage.SharedUtils.HolidayCollectionHunting)
	local v = success and holidayCollectionHunting.GetCollection()

	if v and v.PieceTag then
		return v.PieceTag, string.upper(v.PromptObjectText or "Decoration")
	end

	return nil
end

local function collectNearby(tag, label, p2, list)
	for _, pVInstance in ipairs(CollectionService:GetTagged(tag)) do
		if not (pVInstance:IsDescendantOf(workspace) and (not pVInstance:IsA("PVInstance") or (pVInstance:GetPivot().Position - p2).Magnitude <= 120)) then
			continue
		end

		table.insert(list, {
			item = pVInstance,
			label = label
		})
	end
end

return {
	ClientAbility = function(_, instance)
		while instance and instance.Parent do
			if workspace:FindFirstChild("CurrentRoom") then
				local model = workspace.CurrentRoom:FindFirstChildWhichIsA("Model")
				local position = instance:GetPivot().Position

				if model and workspace.Info.FloorActive.Value then
					local position2 = position
					local success, result = pcall(function()
						local v2 = {}
						collectNearby("HolidayCollectibleItem", "PUMPKIN", position2, v2)
						local success2, holidayCollectionHunting = pcall(
							require,
							ReplicatedStorage.SharedUtils.HolidayCollectionHunting
						)
						local v3 = success2 and holidayCollectionHunting.GetCollection()
						local pieceTag, promptObjectText

						if v3 and v3.PieceTag then
							pieceTag = v3.PieceTag
							promptObjectText = string.upper(v3.PromptObjectText or "Decoration")
						end

						if pieceTag then
							collectNearby(pieceTag, promptObjectText, position2, v2)
						end

						return v2
					end)

					if success then
						for _, v2 in ipairs(result) do
							local item = v2.item

							if not (item:IsDescendantOf(workspace) and (item:IsA("BasePart") or item:IsA("Model") and item.PrimaryPart)) then
								continue
							end

							HighlightController:PlayHighlight(item, "Item", {
								FillColor = Color3.fromRGB(255, 255, 255),
								FillTransparency = 1,
								OutlineColor = Color3.fromRGB(255, 255, 255),
								OutlineTransparency = 0,
								Priority = HighlightController.Priority.TRINKET,
								Decay = 3,
								Billboard = {
									Label = v2.label,
									Template = "HolidayWarningIcon",
									Size = UDim2.new(12, 0, 12, 0),
									StudsOffset = createVector(0, 5, 0)
								}
							})
						end
					else
						warn("[BoneNeedleAndThread] highlight scan failed:", result)
					end

					task.wait(10)
				else
					task.wait(1)
				end
			else
				task.wait(1)
			end
		end
	end
}