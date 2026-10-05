local localPlayer = game.Players.LocalPlayer
local import = _G.import("global")
local import2 = _G.import("romodel")
local menu = _G.import("viewImports"):get("menu")
local import3 = _G.import("timeUtil")
local import4 = _G.import("rewardListData")
local model = import2.model(menu.RewardPage)

function model.init()
	return {
		Rewards = {
			"Mins10",
			"Mins20",
			"Mins30",
			"Mins40"
		},
		CanvasHeight = 2
	}
end

function model:prespawn()
	local playerSave = import.get("playerSave", localPlayer)
	self.Loop = true
	task.spawn(function()
		if plugin then
			return
		end

		while self.Loop do
			for _, guiObject in pairs(self.RewardScroll.Inner._Children) do
				if not guiObject:IsA("GuiObject") then
					continue
				end

				local v = import4[guiObject.Id]
				local v2 = playerSave.Playtime + time()
				local v3 = v.TimeRequired - v2
				local v4 = v3 <= 0
				local v5 = playerSave.RewardListsClaimed[guiObject.Id]
				guiObject.TitleLabel.Text = v4 and "Complete" or import3.formatTimeRemaining(v3)
				guiObject.Inner.ClaimButton.Inner.TextLabel.Text = v5 and "Claimed" or v4 and "Claim" or "Wait"
			end

			task.wait(1)
		end
	end)
end

function model:despawn()
	self.Loop = false
end

return {
	Page = model
}