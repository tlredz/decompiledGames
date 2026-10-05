local import = _G.import("romodel")
local import2 = _G.import("iterator")
local import3 = _G.import("viewImports")
local menu = import3:get("menu")
local react = import3:get("react")
local import4 = _G.import("rewardListData")
local model = import.model(menu.RewardPage, react.Reactive)

function model.init()
	return {
		CanvasHeight = 3.6,
		Rewards = import2.gen(7, function(p)
			return p, "Day" .. p
		end),
		KeyChains = { "LoginStreak", "RewardListsClaimed" },
		SavedChanged = function(p, p2)
			for _, guiObject in pairs(p.RewardScroll.Inner._Children) do
				if not guiObject:IsA("GuiObject") then
					continue
				end

				local v = import4[guiObject.Id]
				local v2 = p2.RewardListsClaimed[guiObject.Id]
				guiObject.Inner.ClaimButton.Inner.TextLabel.Text = v2 and "Claimed" or v.StreakRequired <= p2.LoginStreak and "Claim" or "Wait"
			end
		end
	}
end

function model.prespawn(p)
	for _, guiObject in pairs(p.RewardScroll.Inner._Children) do
		if not guiObject:IsA("GuiObject") then
			continue
		end

		local v = import4[guiObject.Id]
		guiObject.TitleLabel.Text = "Day " .. v.StreakRequired
	end
end

return {
	Page = model
}