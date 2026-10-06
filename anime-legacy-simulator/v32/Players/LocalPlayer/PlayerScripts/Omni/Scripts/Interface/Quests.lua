local module = require("@game/ReplicatedStorage/Omni")
local fusion = module.Libs.Fusion
local scope = fusion.scoped(fusion)
local Controller = require(script.Controller)
local quests = module.Interface:WaitForChild("Frames"):WaitForChild("Quests")
local main = quests:WaitForChild("AutoClaim"):WaitForChild("Main")
local color = Color3.fromRGB(120, 120, 120)
local color2 = Color3.fromRGB(255, 255, 255)
local color3 = Color3.fromRGB(255, 255, 255)
local color4 = Color3.fromRGB(0, 255, 149)
local v = {}
local value = scope:Value(color3)
local spring = scope:Spring(value, 10, 1)
local v2 = {}
local innerScopes = {}
local innerScopes2 = {}
local innerScopes3 = {}
local scopes = {
	Category = require(script.Scopes.Category),
	Quest = require(script.Scopes.Quest),
	Mission = require(script.Scopes.Mission),
	Reward = require(script.Scopes.Reward)
}
local Quests = {
	UpdateAuto = function()
		local autoQuests = module.Data.Settings["Auto Quests"] == true
		value:set(autoQuests and color4 or color3)
	end,
	ClearCategories = function()
		for _, v4 in innerScopes3 do
			v4.Instance:Destroy()
			v4:doCleanup()
		end

		table.clear(innerScopes3)
	end,
	ClearQuests = function()
		for _, v4 in v2 do
			v4.Instance:Destroy()
			v4:doCleanup()
		end

		table.clear(v2)
	end,
	ClearMissions = function()
		for _, v4 in innerScopes do
			v4.Instance:Destroy()
			v4:doCleanup()
		end

		table.clear(innerScopes)
	end,
	ClearRewards = function()
		for _, v4 in innerScopes2 do
			v4.Instance:Destroy()
			v4:doCleanup()
		end

		table.clear(innerScopes2)
	end
}

function Quests.ClearAll()
	Quests.ClearQuests()
	Quests.ClearMissions()
	Quests.ClearRewards()
	Quests.ClearCategories()
end

function Quests.IsCurrentQuestClaimed()
	local v4 = module.Data.Quests.List[Controller.CurrentCategory]

	if not v4 then
		return false
	end

	local v5 = v4.List[Controller.CurrentQuest]
	return v5 ~= nil and v5.Claimed == true
end

function Quests.UpdateClaimButton()
	local isCurrentQuestClaimed = Quests.IsCurrentQuestClaimed()
	quests.Claim.Visible = Controller.CurrentQuest ~= nil
	quests.Claim.Main.Title.Text = isCurrentQuestClaimed and "Claimed" or "Claim"
	quests.Claim.Main.Title.UIGradient.Enabled = not isCurrentQuestClaimed
	quests.Claim.Main.UIGradient.Enabled = not isCurrentQuestClaimed
	quests.Claim.Main.ImageColor3 = isCurrentQuestClaimed and color or color2
end

function Quests.UpdateAll()
	Quests.UpdateClaimButton()
	quests.RightFrame.Visible = Controller.CurrentQuest ~= nil

	for k, v4 in module.Shared.Quests.List do
		local v5 = innerScopes3[k]

		if v5 then
			v5:Update()
		else
			local innerScope = scopes.Category:innerScope()
			innerScope.Name = k
			innerScope.Index = v4.Index

			if innerScope:Build((v4.Index - 1) * 0.05) then
				innerScopes3[k] = innerScope
			else
				innerScope:doCleanup()
			end
		end
	end

	local v4 = module.Shared.Quests.List[Controller.CurrentCategory]
	local v5 = module.Data.Quests.List[Controller.CurrentCategory]

	if v4 and v5 then
		local v6 = {}
		local v7 = {}

		for k, v8 in v5.List do
			if not v8.Available then
				continue
			end

			local questProgress = module.Shared.Quests.GetQuestProgress(k, Controller.CurrentCategory, module.Data)
			table.insert(v6, {
				Name = k,
				Claimed = v8.Claimed,
				Progress = questProgress * 100
			})
		end

		table.sort(v6, function(a, b)
			return a.Progress - (a.Claimed and 999 or 0) > b.Progress - (b.Claimed and 999 or 0)
		end)

		for k, v8 in v6 do
			v7[v8.Name] = k
		end

		if Controller.CurrentQuest and not v7[Controller.CurrentQuest] then
			Controller.CurrentQuest = nil
			Quests.ClearMissions()
			Quests.ClearRewards()
			quests.RightFrame.Visible = false
			Quests.UpdateClaimButton()
		end

		for k, v8 in v7 do
			local v9 = v4.List[k]

			if not v9 then
				continue
			end

			local v10 = v5.List[k]

			if not v10 then
				continue
			end

			local v11 = v2[k]

			if v11 then
				v11.Index = v8
				v11.Claimed = v10.Claimed
				v11:Update()
			else
				local innerScope = scopes.Quest:innerScope()
				innerScope.Name = k
				innerScope.Description = v9.Description
				innerScope.Class = Controller.CurrentCategory
				innerScope.Index = v8
				innerScope.Claimed = v10.Claimed

				if innerScope:Build((v8 - 1) * 0.05) then
					v2[k] = innerScope
				else
					innerScope:doCleanup()
				end
			end
		end

		for k, v8 in v2 do
			if v7[k] then
				continue
			end

			v8.Instance:Destroy()
			v8:doCleanup()
			v2[k] = nil
		end

		local v8 = v4.List[Controller.CurrentQuest]
		local v9 = v5.List[Controller.CurrentQuest]

		if v8 and v9 then
			local v10 = {}

			for k, mission in v8.Missions do
				local amount = v9.Missions[k] or 0
				local v12 = Controller.CurrentQuest .. k
				local v13 = innerScopes[v12]

				if v13 then
					v13.Amount = amount
					v13:Update()
				else
					local innerScope = scopes.Mission:innerScope()
					innerScope.Info = mission
					innerScope.Amount = amount
					innerScope.Index = k

					if innerScope:Build((k - 1) * 0.05) then
						innerScopes[v12] = innerScope
					else
						innerScope:doCleanup()
					end
				end
			end

			for k, perk in v8.Perks do
				local perk2 = module.Shared.Perks[k]

				if perk2 then
					table.insert(v10, {
						Type = "Perk",
						Name = k,
						Text = module.Utils.Multipliers.ToStringSingle({
							Name = k,
							RemoveName = true,
							ShowPercentage = not perk2.NumericOnly,
							MultiplierArray = { perk }
						}),
						Icon = perk2.Icon,
						Rarity = perk2.Rarity
					})
				end
			end

			for _, reward in v8.Rewards do
				local v11 = module.Utils.Info:Get(reward.Type, reward.Name)

				if v11 then
					table.insert(v10, {
						Type = reward.Type,
						Name = reward.Name,
						Text = reward.Amount == 1 and reward.Type or reward.Amount .. "x",
						Icon = reward.Icon or v11.Icon,
						Rarity = reward.Rarity or v11.Rarity
					})
				end
			end

			for k, info in v10 do
				local v12 = Controller.CurrentQuest .. k

				if innerScopes2[v12] then
					continue
				end

				local innerScope = scopes.Reward:innerScope()
				innerScope.Info = info
				innerScope.Hover = module.Libs.NeoHover.GetByPseudoIdentifier(info.Type)

				if not innerScope.Hover then
					innerScope.Tooltip = true
					innerScope.Hover = module.Libs.NeoHover.GetByIdentifier("Tooltip")
				end

				if innerScope:Build((k - 1) * 0.05) then
					innerScopes2[v12] = innerScope
				else
					innerScope:doCleanup()
				end
			end
		end

		if v4.ChangeQuestsOnUpdate and v4.UpdateInterval then
			local v10 = workspace:GetServerTimeNow() - (v5.LastUpdate or 0)
			local v11 = v4.UpdateInterval - v10
			quests.Timer.Title.Text = "Refreshing in " .. module.Utils.Number:Time2(v11)
			quests.Timer.Visible = true
		else
			quests.Timer.Visible = false
		end
	end
end

function Quests.Stop()
	for _, connection in v do
		connection:Disconnect()
	end

	table.clear(v)
	Quests.ClearAll()
end

function Quests.Start()
	v.Data = module:OnDataChangedDeferred({ "Quests" }, Quests.UpdateAll)
	v.Category = Controller.CategoryChanged:Connect(function()
		Quests.ClearQuests()
		Quests.ClearMissions()
		Quests.ClearRewards()
		Quests.UpdateAll()
	end)
	v.Quest = Controller.QuestChanged:Connect(function()
		Quests.ClearMissions()
		Quests.ClearRewards()
		Quests.UpdateAll()
	end)
	Quests.UpdateAll()
end

function Quests.Init()
	module.Button:Create(quests.Claim.Main, "Small"):BindFunction("Click", function()
		if Quests.IsCurrentQuestClaimed() then
			return
		end

		module.Signal:Fire("General", "Quests", "Claim", Controller.CurrentCategory, Controller.CurrentQuest)
	end)
	module.Button:Create(quests.ClaimAll.Main, "Small"):BindFunction("Click", function()
		module.Signal:Fire("General", "Quests", "ClaimAll")
	end)
	module.Button:Create(main, "Small"):BindFunction("Click", function()
		local autoQuests = module.Data.Settings["Auto Quests"] == true
		module.Signal:Fire("General", "Settings", "Set", "Auto Quests", not autoQuests)
	end)
	scope:Hydrate(main.Icon)({
		ImageColor3 = spring
	})
	module.Frame:OnFrameClosed(quests, Quests.Stop)
	module.Frame:OnFrameOpened(quests, Quests.Start)
	module:OnDataChanged({ "Settings", "Auto Quests" }, Quests.UpdateAuto)
	Quests.UpdateAuto()
end

return Quests