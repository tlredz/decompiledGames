local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
game:GetService("SoundService")
local QuestController = require(ReplicatedStorage.client.legacyControllers.QuestController)
local Quests = require(ReplicatedStorage.shared.modules.Quests)
local Factions = require(ReplicatedStorage.shared.modules.Factions)
local legacyLocalPlayerData = require(ReplicatedStorage.client.modules.legacyLocalPlayerData)
local Net = require(ReplicatedStorage.packages.Net)
local Trove = require(ReplicatedStorage.packages.Trove)
local Monetization = require(ReplicatedStorage.shared.Monetization)
local LocalCurrencies = require(ReplicatedStorage.shared.modules.LocalCurrencies)
require(ReplicatedStorage.shared.utils.CurrencyMigration)
local factions = game.Players.LocalPlayer.PlayerGui.Factions
local fetched = legacyLocalPlayerData.fetch()
local cache = fetched.Cache
local reputationQuests = fetched.ReputationQuests
local refresh = factions.Main.Misc.Refresh
local close = factions.Main.Close
local label = refresh.Label
local refreshTimer = factions.Main.Misc.RefreshTimer
local rank = factions.Main.Misc.Rank
local factionName = factions.Main.Misc.FactionName
local scrollingFrame = factions.Main.List.ScrollingFrame
local template = scrollingFrame.Template
local maid = Trove.new()
local v = ""

local function formatTime(p)
	local v2 = math.floor(p / 3600)
	local v3 = math.floor(p % 3600 / 60)
	local v4 = p % 60
	local v5 = ""

	if v2 > 0 then
		v5 ..= v2 .. "h"
	end

	if v3 > 0 then
		v5 ..= v3 .. "m"
	end

	if v4 > 0 or v5 == "" then
		return v5 .. v4 .. "s"
	end

	return v5
end

local function RichColor(p, color: Color3?)
	if color then
		return (`<font color="#{color:ToHex()}">{p}</font>`)
	end

	return p
end

local ReputationQuestsController = {}

function ReputationQuestsController.OpenUI(_, p: string)
	if factions.Enabled and v == p then
		return
	end

	ReputationQuestsController:Reload(p)
	factions.Enabled = true
end

function ReputationQuestsController:Reload(text: string)
	if not Factions[text] then
		warn((`Invalid faction: {text}`))
		return
	end

	maid:Clean()
	v = text
	local child = cache:FindFirstChild((`ReputationQuestsRefreshTime_{text}`))
	local v2 = math.max(0, (child and child.Value or 0) - os.time())
	local v3 = Net:RemoteFunction("ReputationService/GetRank"):InvokeServer(text)

	if v3 then
		rank.Text = "Rank: " .. v3
	else
		warn((`No rank returned for faction: {text}`))
		rank.Text = "Rank: Unknown"
	end

	if v2 > 0 then
		maid:Add(task.spawn(function()
			for i = v2, 0, -1 do
				local v4 = refreshTimer
				local v6 = math.floor(i / 3600)
				local v7 = math.floor(i % 3600 / 60)
				local v8 = i % 60
				local v9 = ""

				if v6 > 0 then
					v9 ..= v6 .. "h"
				end

				if v7 > 0 then
					v9 ..= v7 .. "m"
				end

				if v8 > 0 or v9 == "" then
					v9 ..= v8 .. "s"
				end

				v4.Text = `Refreshes In: {v9}`
				task.wait(1)
			end

			Net:RemoteEvent("ReputationQuests/AskToRefreshQuests"):FireServer(text)
		end))
	else
		Net:RemoteEvent("ReputationQuests/AskToRefreshQuests"):FireServer(text)
	end

	factionName.Text = text
	factionName.TextColor3 = Factions[text].FactionColor
	task.spawn(function()
		local robuxPrice = Monetization:GetRobuxPrice(Monetization.products.Others.RefreshReputationQuests[text])

		if robuxPrice then
			label.Text = `{robuxPrice}`
		end
	end)
	maid:Add(task.spawn(function()
		for i, child2 in reputationQuests[text]:GetChildren() do
			local quest = Quests[child2.Name]

			if quest then
				local clone = template:Clone()
				clone.Main.Title.Text = quest.FactionsPanelDisplayTitle
				clone.Main.Subtitle.Text = quest.FactionsPanelDisplayDescription

				for _, reward in quest.Rewards do
					if reward[1] == "Reputation" then
						clone.Main.Rewards.Rep.Text = `+ {reward[3]} Reputation`
					elseif reward[1] == "Currency" then
						clone.Main.Rewards["D$"].Text = `+ {reward[3]} C$`
					elseif reward[1] == "LocalCurrency" then
						clone.Main.Rewards["D$"].Text = `+ {reward[3]} {LocalCurrencies[reward[2]].DisplayName}`
					end
				end

				if fetched.QuestFinished:FindFirstChild(child2.Name) then
					clone.Main.Finished.Visible = true
					clone.Main.Claim.Visible = false
					clone.Main.InProgress.Visible = false
					clone.Visible = true
				elseif QuestController.Completed[child2.Name] then
					clone.Main.Finished.Visible = false
					clone.Main.Claim.Visible = true
					clone.Main.Claim.ClaimButton.Visible = true
					clone.Main.InProgress.Visible = false
					clone.Visible = true
				elseif fetched.QuestActive:FindFirstChild(child2.Name) then
					clone.Main.Finished.Visible = false
					clone.Main.Claim.Visible = true
					clone.Main.Claim.CancelButton.Visible = true
					clone.Main.InProgress.Visible = false
					clone.Visible = true
				end

				local v4 = child2
				maid:Add(fetched.QuestFinished.ChildAdded:Connect(function(child3)
					if child3.Name == v4.Name then
						clone.Main.Finished.Visible = true
						clone.Main.Claim.Visible = false
						clone.Main.InProgress.Visible = false
						clone.Visible = true
					end
				end))
				local v6 = child2
				local v7 = clone
				maid:Add(fetched.QuestActive.ChildAdded:Connect(function(child3)
					if child3.Name == v6.Name then
						v7.Main.Finished.Visible = false
						v7.Main.Claim.Visible = true
						v7.Main.Claim.CancelButton.Visible = true
						v7.Main.InProgress.Visible = false
						v7.Visible = true
					end
				end))
				local v8 = child2
				local v9 = clone
				maid:Add(fetched.QuestActive.ChildRemoved:Connect(function(child3)
					if child3.Name == v8.Name then
						v9.Main.Finished.Visible = false
						v9.Main.Claim.Visible = false
						v9.Main.InProgress.Visible = false
						v9.Visible = true
					end
				end))
				local v10 = child2
				local v11 = clone
				maid:Add(QuestController.CompletedSignal:Connect(function(p)
					if p == v10.Name then
						if QuestController.Completed[v10.Name] then
							v11.Main.Finished.Visible = false
							v11.Main.Claim.Visible = true
							v11.Main.Claim.ClaimButton.Visible = true
							v11.Main.InProgress.Visible = false
							v11.Visible = true
						elseif fetched.QuestActive:FindFirstChild(v10.Name) then
							v11.Main.Finished.Visible = false
							v11.Main.Claim.Visible = true
							v11.Main.Claim.CancelButton.Visible = true
							v11.Main.InProgress.Visible = false
							v11.Visible = true
						end
					end
				end))
				local v12 = child2
				maid:Add(clone.Main.MouseButton1Click:Connect(function()
					Net:RemoteEvent("ReputationQuests/SelectQuest"):FireServer(text, v12.Name)
				end))
				local v13 = child2
				maid:Add(clone.Main.Claim.ClaimButton.MouseButton1Click:Connect(function()
					Net:RemoteEvent("ReputationQuests/ClaimQuest"):FireServer(text, v13.Name)
				end))
				local v14 = child2
				maid:Add(clone.Main.Claim.CancelButton.MouseButton1Click:Connect(function()
					Net:RemoteEvent("ReputationQuests/CancelQuest"):FireServer(text, v14.Name)
				end))
				clone.Name = child2.Name

				if not clone.Main.InProgress.Visible then
					clone.Visible = true
				end

				clone.Parent = scrollingFrame
				local tweenInfo = TweenInfo.new(0.1, Enum.EasingStyle.Quart, Enum.EasingDirection.Out, 0, false, 0)
				local tweenInfo2 = TweenInfo.new(0.1, Enum.EasingStyle.Quart, Enum.EasingDirection.InOut, 0, false, 0)
				local size = clone.Size
				local size2 = clone.Main.Size
				local v15 = clone
				maid:Add(clone.Main.MouseEnter:Connect(function()
					TweenService:Create(v15, tweenInfo, {
						Size = size + UDim2.fromScale(0.2, 0.2)
					}):Play()
					TweenService:Create(v15.Main, tweenInfo, {
						Rotation = 2
					}):Play()
				end))
				local v18 = clone
				local v19 = tweenInfo
				local size3 = size
				maid:Add(clone.Main.MouseLeave:Connect(function()
					TweenService:Create(v18, v19, {
						Size = size3
					}):Play()
					TweenService:Create(v18.Main, v19, {
						Rotation = 0
					}):Play()
					TweenService:Create(v18.Main, tweenInfo2, {
						Size = size2
					}):Play()
				end))
				local v23 = clone
				local v24 = tweenInfo2
				local size4 = size2
				maid:Add(clone.Main.MouseButton1Down:Connect(function()
					TweenService:Create(v23.Main, v24, {
						Size = size4 - UDim2.fromScale(0.05, 0.05)
					}):Play()
					ReplicatedStorage.resources.sounds.sfx.ui.click1:Play()
				end))
				local v26 = clone
				local v27 = tweenInfo2
				local size5 = size2
				maid:Add(clone.Main.MouseButton1Up:Connect(function()
					TweenService:Create(v26.Main, v27, {
						Size = size5
					}):Play()
				end))
				TweenService:Create(
					clone.Main,
					TweenInfo.new(0.3 * i, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
					{
						Position = UDim2.fromScale(0.5, 0.5),
						Rotation = 0
					}
				):Play()
				maid:Add(clone)
			else
				warn((`Quest data not found for quest called {child2.Name}`))
			end
		end
	end))
end

function ReputationQuestsController.init(_)
	close.MouseButton1Click:Connect(function()
		factions.Enabled = false
		ReplicatedStorage.resources.sounds.sfx.ui.click1:Play()
	end)
	Net:RemoteEvent("ReputationQuests/Reload").OnClientEvent:Connect(function(p)
		if v == p then
			ReputationQuestsController:Reload(p)
		end
	end)
	refresh.MouseButton1Click:Connect(function()
		Monetization.BuyProduct:FireServer(Monetization.products.Others.RefreshReputationQuests[v])
	end)
end

return ReputationQuestsController