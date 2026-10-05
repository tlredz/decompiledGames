local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
game:GetService("TweenService")
local v = require3(ReplicatedStorage2.Packages.Replion)
local v2 = require3(ReplicatedStorage2.Packages.Net)
local v3 = require3(ReplicatedStorage2.Packages.Charm)
local v4 = require3(ReplicatedStorage2.Common.Utils)
local v5 = require3(ReplicatedStorage2.ClientGameModules.GuiHandler)
local v6 = require3(ReplicatedStorage2.ClientGameModules.DeviceListener)
require3(ReplicatedStorage2.Common.MarketplaceService)
local v7 = require3(ReplicatedStorage2.Controllers.UI.HUDController)
local v8 = require3(ReplicatedStorage2.Shared.ThemedQuests.ThemedQuestsData)
local spring = require3(ReplicatedStorage2.Common.Utils).Spring
require3(ReplicatedStorage2.Common.RewardInfo)
local v9 = require3(ReplicatedStorage2.Controllers.HoverInfoController)
local v10 = require3(ReplicatedStorage2.Shared.NewQuests.Quests)
local playerGui = Players.LocalPlayer.PlayerGui
local themedQuests = playerGui.ThemedQuests
local holder = themedQuests.Holder
local alert = playerGui:WaitForChild("HUD"):WaitForChild("LeftFrame"):FindFirstChild("DailyQuestsPage", true):WaitForChild("Alert")
local questArrow = playerGui.HUD.QuestArrow
local v11 = false
local remoteEvent = v2:RemoteEvent("ThemedQuests/Claim")
local remoteEvent2 = v2:RemoteEvent("ThemedQuests/Opened")
local v12 = nil

local function observePath(p, callback)
	-- equivalent calls inferred from this helper; original call sites unknown
	local function callback2()
		callback((v12:Get(p)))
	end

	callback2() -- equivalent call inferred; original call site unknown
	return v12:OnChange(p, callback2)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getQuestInfo(questId: number)
	return v10.ThemedQuests.Limited.Quests[questId]
end

local ThemedQuestsController = {}

function ThemedQuestsController:_updateQuestArrowVisibility()
	local enabled = themedQuests.Enabled
	questArrow.Visible = not enabled and v11 and not v7.Condensed.CurrentState
	themedQuests.Holder.Arrow.Visible = enabled and v11 and not v7.Condensed.CurrentState
end

function ThemedQuestsController:SetToggleEnabled(flag: boolean)
	if v6:IsMobile() then
		flag = false
	end

	v11 = flag
	self:_updateQuestArrowVisibility()
end

function ThemedQuestsController:Close()
	v5:Close("ThemedQuests")
end

function ThemedQuestsController:Start()
	local v13 = v.Client:WaitReplion("LimitedStockItems")
	v12 = v.Client:WaitReplion("Data")
	local atom = v3.atom(nil)
	local v14 = "ThemedQuests"

	local function callback()
		atom((v12:Get(v14)))
	end

	atom((v12:Get("ThemedQuests")))
	v12:OnChange("ThemedQuests", callback)
	local atom2 = v3.atom(0)
	local atom3 = v3.atom(0)
	local atom4 = v3.atom(false)
	local atom5 = v3.atom(workspace:GetServerTimeNow() < v8.EndTimestamp)
	local clones = {}
	local v15 = false
	v3.effect(function()
		if atom5() then
			local v16 = atom()

			if not v16 then
				return
			end

			local count = 0
			local count2 = 0
			local count3 = 0

			for k, quest in v16.Quests.Limited.Quests do
				count += 1
				local questInfo = getQuestInfo(quest.QuestId) -- equivalent call inferred; original call site unknown
				local clone = clones[k]

				if not clone then
					clone = holder.Quests.UIListLayout.Template:Clone()
					clone.BG.QuestTitle.Text = questInfo.DisplayName
					local v17 = quest
					clone.Intermediate.Activated:Connect(function()
						remoteEvent:FireServer(v17.QuestId)
					end)
					clone.Parent = holder.Quests
					clones[k] = clone
				end

				if quest.Redeemed then
					count2 += 1
				end

				clone.CompletedOverlay.Visible = quest.Redeemed == true
				clone.Intermediate.Visible = not quest.Redeemed
				local value = questInfo.Arguments.value

				if quest.Redeemed or not (value <= quest.Progress) then
					clone.Intermediate.Active = false
					clone.Intermediate.ImageColor3 = Color3.fromRGB(157, 157, 157)
				else
					clone.Intermediate.Active = true
					clone.Intermediate.ImageColor3 = Color3.fromRGB(255, 255, 255)
					count3 += 1
				end

				clone.BG.Bar.ProgressValue.Text = `{math.min(quest.Progress, value)}/{value}`
				spring.target(clone.BG.Bar.Fill, 0.85, 2.5, {
					Size = UDim2.fromScale(math.min(quest.Progress, value) / value, 1)
				})
			end

			local visible = count == count2
			holder.Quests.BigReward.CompletedOverlay.Visible = visible
			alert.Visible = count3 > 0 or (visible or not v16.Opened)
			atom4(visible)
			atom3(count2)
			atom2(count3)
		else
			if not v15 then
				alert.Visible = false
			end

			v15 = true
		end
	end)
	v3.effect(function()
		if atom5() then
			return
		end

		self:Close()
	end)
	v3.effect(function()
		if not atom5() then
			return
		end

		local v16 = atom3()

		for _, frame in holder.Quests.BigReward.BG.Checks:GetChildren() do
			if frame:IsA("Frame") then
				frame.Check.Visible = frame.LayoutOrder <= v16
			end
		end
	end)
	v5:OnGuiOpen("ThemedQuests", function()
		self:_updateQuestArrowVisibility()
		local untracked = v3.untracked(atom)

		if untracked and not untracked.Opened then
			remoteEvent2:FireServer()
		end
	end)
	local v16 = false
	local reward = v8.Rewards[3]
	local v17 = v13:Get({ "InitialStock", reward.reward.Value }) or 0

	local function updateBigReward()
		if not v13:Get({ "Loaded" }) then
			return
		end

		local v18 = v13:Get({ "Stock", reward.reward.Value }) or 0
		math.clamp(math.ceil(v18), 0, v17)
		local v19

		if reward.replacement then
			v19 = v18 <= 0 or v12:Get("ThemedQuestsReceivedHonkaiReward") == true
		else
			v19 = false
		end

		local replacement

		if v19 then
			replacement = reward.replacement
		else
			replacement = reward.reward
		end

		if v19 ~= v16 then
			v16 = v19
			v9:Remove(holder.Quests.BigReward.Crate)
			v9:AddFromRewardInfo(holder.Quests.BigReward.Crate, replacement)
		end

		holder.Quests.BigReward.Crate.Image = replacement.Icon or v4.Icons:GetIcon("DEFAULT_MISSING")
	end

	v13:OnChange({ "Stock", reward.reward.Value }, updateBigReward)
	v13:OnChange({ "Loaded" }, updateBigReward)
	updateBigReward()
	v5:OnGuiClose("ThemedQuests", function()
		self:_updateQuestArrowVisibility()
	end)
	holder.CloseButton.Activated:Connect(function()
		self:Close()
	end)
	v7.Condensed.StateChanged:Connect(function()
		self:_updateQuestArrowVisibility()
	end)
	v6.OnChange:Connect(function()
		if v6:IsMobile() then
			self:SetToggleEnabled(false)
		end
	end)
	task.spawn(function()
		while not (workspace:GetServerTimeNow() > v8.EndTimestamp or v3.untracked(atom4)) do
			task.wait(1)
		end

		atom5(false)
	end)
end

return ThemedQuestsController