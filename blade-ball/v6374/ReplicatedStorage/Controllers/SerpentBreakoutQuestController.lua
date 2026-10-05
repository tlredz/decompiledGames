local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local Players = game:GetService("Players")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
require3(ReplicatedStorage2.Packages.Net)
local v = require3(ReplicatedStorage2.Shared.NewQuests.QuestUtility)
require3(ReplicatedStorage2.Shared.NewQuests.Quests)
local v2 = require3(ReplicatedStorage2.Packages.Replion)
local v3 = require3(ReplicatedStorage2.ClientGameModules.GuiHandler)
local v4 = { "Scale Scout", "Venom Collector", "Ancient Serpent Relics" }
local v5 = {
	MainSeperator = true,
	MainSeparator = true,
	Seperator = true,
	Separator = true
}
local v6 = {
	ROBLOXSeparator = true,
	ROBLOXSeperator = true
}
local v7 = {
	["Roblox Anniversary"] = "ROBLOX <font color=\"#FF8080\">20TH</font> ANNIVERSARY"
}
local v8 = {
	["Roblox Anniversary"] = 0,
	["Scale Scout"] = 1,
	["Venom Collector"] = 2,
	["Ancient Serpent Relics"] = 3
}
return {
	Start = function(_)
		local serpentBreakout = Players.LocalPlayer.PlayerGui:WaitForChild("SerpentBreakout", 10)

		if not serpentBreakout then
			return
		end

		local frame = serpentBreakout:WaitForChild("Main"):WaitForChild("Frame")
		local quests = frame:WaitForChild("Quests")
		local mainTemplate = script:WaitForChild("MainTemplate", 5)
		local rOBLOXTemplate = script:FindFirstChild("ROBLOXTemplate")

		if not mainTemplate then
			warn("[SerpentBreakoutQuestController] MainTemplate is missing from the controller")
			return
		end

		if not rOBLOXTemplate then
			warn("[SerpentBreakoutQuestController] ROBLOXTemplate is missing, using MainTemplate for Roblox Anniversary")
		end

		local v9 = nil
		local v10 = nil

		for _, guiObject in quests:GetChildren() do
			if not guiObject:IsA("GuiObject") then
				continue
			end

			if v6[guiObject.Name] then
				v9 = v9 or guiObject:Clone()
				guiObject:Destroy()
			elseif v5[guiObject.Name] then
				v10 = v10 or guiObject:Clone()
				guiObject:Destroy()
			elseif guiObject.Name == "Template" then
				guiObject:Destroy()
			end
		end

		if not v10 then
			warn("[SerpentBreakoutQuestController] Tier header template is missing")
			return
		end

		v10.Visible = false

		if v9 then
			v9.Visible = false
		else
			warn("[SerpentBreakoutQuestController] ROBLOXSeparator missing, using the main header for Roblox Anniversary")
		end

		local v11 = v2.Client:WaitReplion("Data")
		local v12 = {}
		local clones = {}

		local function ensureCategoryHeader(text: string, p: number)
			if clones[text] then
				return
			end

			local v13

			if text == "Roblox Anniversary" and v9 then
				v13 = v9
			else
				v13 = v10
			end

			local clone = v13:Clone()
			clone.Name = `Category_{p}`
			clone.LayoutOrder = p * 100
			local label = clone.Frame.Label
			local text2 = v7[text]

			if text2 then
				label.RichText = true
				label.Text = text2
			else
				label.Text = text
			end

			clone.Visible = true
			clone.Parent = quests
			clones[text] = clone
		end

		local function updateQuestTile(quest)
			local questData = v:GetQuestData("SerpentBreakout", "Limited", quest.QuestId)

			if not questData then
				return
			end

			local value = questData.Arguments.value

			if typeof(value) == "function" then
				value = value(v11)
			end

			if typeof(value) ~= "number" or value <= 0 then
				return
			end

			local difficulty = questData.Difficulty or 1
			local category = questData.Category or v4[difficulty]

			if category then
				difficulty = v8[category] or difficulty
			end

			if category and not clones[category] then
				local v13

				if category == "Roblox Anniversary" and v9 then
					v13 = v9
				else
					v13 = v10
				end

				local clone = v13:Clone()
				clone.Name = `Category_{difficulty}`
				clone.LayoutOrder = difficulty * 100
				local label = clone.Frame.Label
				local text = v7[category]

				if text then
					label.RichText = true
					label.Text = text
				else
					label.Text = category
				end

				clone.Visible = true
				clone.Parent = quests
				clones[category] = clone
			end

			local formatted = `Limited_{quest.QuestId}`
			local clone = v12[formatted]

			if not clone then
				local v13

				if category == "Roblox Anniversary" and rOBLOXTemplate then
					v13 = rOBLOXTemplate
				else
					v13 = mainTemplate
				end

				clone = v13:Clone()
				clone.Name = formatted
				clone.Visible = false
				clone.LayoutOrder = difficulty * 100 + quest.QuestId
				clone.Parent = quests
				v12[formatted] = clone
				clone.Claim.Activated:Connect(function()
					v.RedeemQuestsType:InvokeServer("SerpentBreakout", "Limited", quest.QuestId)
				end)
			end

			local v13 = math.clamp(quest.Progress, 0, value)
			local v14 = v13 / value
			local visible

			if value <= v13 then
				visible = not quest.Redeemed
			else
				visible = false
			end

			clone.Title.Text = questData.DisplayName
			local xp = clone.Xp
			local text2

			if typeof(questData.Reward) == "number" then
				text2 = `+{questData.Reward} XP`
			else
				text2 = questData.SecondReward == nil and "Reward" or "2 Rewards"
			end

			xp.Text = text2
			clone.Xp.Visible = true
			clone.ProgressBar.Amount.Text = `{math.floor(v13)}/{value}`
			clone.ProgressBar.Amount.Visible = true
			clone.ProgressBar.Fill.Size = UDim2.fromScale(v14, 1)
			clone.ProgressBar.Fill.Visible = v14 > 0
			clone.Claim.Visible = visible
			clone.Claimed.Visible = quest.Redeemed
			clone.Visible = true
		end

		local function renderQuests()
			local serpentBreakout2 = v11:Get("SerpentBreakout")
			local limited = serpentBreakout2 and serpentBreakout2.Limited

			if not limited then
				return
			end

			local v13 = {}
			local count = 0

			for _, quest in limited.Quests do
				v13[`Limited_{quest.QuestId}`] = true

				if quest.Redeemed then
					count += 1
				end

				updateQuestTile(quest)
			end

			for k, v14 in v12 do
				if v13[k] then
					continue
				end

				v14:Destroy()
				v12[k] = nil
			end

			frame.CurrentXP.Text = `Your XP: {math.floor(serpentBreakout2.XP or 0)}`
			frame.CurrentXP.Visible = true
			frame.ClaimedQuestsText.Text = `{count}/{#limited.Quests} Quests Claimed`
			frame.ClaimedQuestsText.Visible = true
		end

		v11:OnChange("SerpentBreakout.Limited.Quests", renderQuests)
		v11:OnChange("SerpentBreakout.Limited", renderQuests)
		v11:OnChange("SerpentBreakout.XP", renderQuests)
		renderQuests()
		frame.Close.Activated:Connect(function()
			v3:Close(serpentBreakout.Name)
		end)
	end
}