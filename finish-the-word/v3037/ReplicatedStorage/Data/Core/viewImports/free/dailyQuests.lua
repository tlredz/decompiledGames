local import = _G.import("romodel")
local import2 = _G.import("iterator")
local import3 = _G.import("sync")
local import4 = _G.import("event")
local import5 = _G.import("mathUtil")
local import6 = _G.import("questCollection")
local import7 = _G.import("viewImports")
local basic = import7:get("basic")
local menu = import7:get("menu")
local react = import7:get("react")
local model = import.model(menu.RewardList, react.Reactive)

function model.init(data, list)
	local clone = table.clone(list)
	table.clear(list)
	return {
		Claim = function()
			import3.request("claimQuest", nil, function(p)
				if not p then
					return
				end

				import4.fire("signal", p)
			end)(data.Id)
		end,
		ClaimText = "Wait",
		ContentX = 0.015,
		HideTitle = true,
		Id = data.Id,
		InnerChildren = clone,
		ItemsPositionY = 0.92,
		ItemsSize = UDim2.new(1, 0, 0.54, 0),
		KeyChains = { "DailyQuests." .. data.Id .. ".Claimed", "DailyQuests." .. data.Id .. ".Progress" },
		LayoutOrder = data.LayoutOrder,
		QuestRewards = true,
		Rewards = data.Rewards,
		SavedChanged = function(p, p2)
			local dailyQuest = p2.DailyQuests[data.Id]

			if not dailyQuest then
				return
			end

			p.Inner.ClaimButton.Inner.TextLabel.Text = dailyQuest.Claimed and "Claimed" or dailyQuest.Progress >= data.Goal and "Claim" or "Wait"
		end,
		Size = UDim2.new(0.95, 0, 0.4, 0)
	}
end

local model2 = import.model(basic.EmptyList, react.Reactive, menu.Page)

function model2.getExclamKeyChains()
	return { "DailyQuests" }
end

function model2.exclamItems(_, p)
	return p.DailyQuests:pairs()
end

function model2.itemHasExclam(_, p, p2)
	return not p.DailyQuests[p2].Claimed
end

function model2.init()
	return {
		FillDirection = Enum.FillDirection.Vertical,
		HorizontalAlignment = Enum.HorizontalAlignment.Center,
		KeyChains = { "DailyQuestDay" },
		Padding = UDim.new(0.025, 0),
		SavedChanged = function(object, p)
			object:ClearReactiveChildren()
			local count = 0
			return nil, import2.fromArray(p.DailyQuests:getTable()):map(function(id, _)
				count += 1
				local v = import6:get(id)
				return id, import.make(model, {
					Goal = v.Goal,
					Id = id,
					LayoutOrder = count,
					Rewards = v.Rewards
				}, {
					Description = import.make(basic.EmptyList, {
						Position = UDim2.new(0.015, 0, 0.08, 0),
						Size = UDim2.new(0.98, 0, 0.22, 0),
						FillDirection = Enum.FillDirection.Horizontal,
						Padding = UDim.new(0.02, 0),
						VerticalAlignment = Enum.VerticalAlignment.Center
					}, {
						Label = import.make(basic.TextLabel, {
							AutomaticSize = Enum.AutomaticSize.X,
							Size = UDim2.new(0, 0, 1, 0),
							LayoutOrder = 1,
							StrokeSizingMode = Enum.StrokeSizingMode.ScaledSize,
							StrokeWidth = 0.1,
							Text = v.Label,
							TextXAlignment = Enum.TextXAlignment.Left
						}),
						Progress = import.make(import.wrap(basic.TextLabel, react.LinkedText), {
							AutomaticSize = Enum.AutomaticSize.X,
							Size = UDim2.new(0, 0, 0.75, 0),
							Font = Enum.Font.GothamBlack,
							KeyChains = { "DailyQuests." .. id .. ".Progress" },
							LayoutOrder = 2,
							StrokeSizingMode = Enum.StrokeSizingMode.ScaledSize,
							StrokeWidth = 0.1,
							TextSavedChanged = function(p3, p4)
								local dailyQuest = p4.DailyQuests[id]

								if not dailyQuest then
									return p3.Text
								end

								local progress = dailyQuest.Progress
								return v.Type == "Playtime" and string.format(
									"%s / %s",
									import5.formatTime(progress),
									import5.formatTime(v.Goal)
								) or string.format("%d / %d", progress, v.Goal)
							end,
							TextXAlignment = Enum.TextXAlignment.Left
						})
					})
				})
			end):dict()
		end,
		Size = UDim2.new(1, 0, 1, 0),
		VerticalAlignment = Enum.VerticalAlignment.Center
	}
end

return {
	Page = model2
}