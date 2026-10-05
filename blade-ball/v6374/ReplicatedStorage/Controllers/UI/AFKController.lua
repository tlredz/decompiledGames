local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local Debris = game:GetService("Debris")
game:GetService("HttpService")
local SocialService = game:GetService("SocialService")
local ReplicatedStorage3 = game:GetService("ReplicatedStorage")
local v = require3(ReplicatedStorage3:WaitForChild("UserInputService"))
local RunService = game:GetService("RunService")
local localPlayer = Players.LocalPlayer
local playerGui = localPlayer.PlayerGui
local v2 = require3(ReplicatedStorage2.Packages.Net)
require3(ReplicatedStorage2.Packages.Signal)
local v3 = require3(ReplicatedStorage2.Packages.Replion)
local v4 = require3(ReplicatedStorage2.Common.MarketplaceService)
local v5 = require3(ReplicatedStorage2.ClientGameModules.FFlagClient)
local v6 = require3(ReplicatedStorage2.Packages.Trove)
local v7 = require3(ReplicatedStorage2.Common.Utils)
local v8 = require3(ReplicatedStorage2.Shared.RNG.Emotes)
local v9 = require3(ReplicatedStorage2.Shared.RNG.PlaytimeLuck)
local v10 = require3(ReplicatedStorage2.ServerInfo)
local v11 = require3(ReplicatedStorage2.ClientGameModules.GuiHandler)
local v12 = require3(ReplicatedStorage2.ClientGameModules.CreatePriceLabel)
local v13 = require3(ReplicatedStorage2.Controllers.ShowRoomController)
local v14 = require3(ReplicatedStorage2.ClientGameModules.Icon)
local v15 = require3(ReplicatedStorage2.Controllers.UI.InviteRewardsController)
local v16 = require3(ReplicatedStorage2.Shared.PlayerUtility)
local client = require3(ReplicatedStorage2.Shared.Inventory).Client
local v17 = require3(ReplicatedStorage2.Controllers.Trading.TradeTokensController)
local v18 = require3("@game/ReplicatedStorage/Shared/InfiniteBattlepass/InfiniteBattlepassData")
local remoteEvent = v2:RemoteEvent("TimeIncremented")
local remoteEvent2 = v2:RemoteEvent("SpinAnimation")
local remoteEvent3 = v2:RemoteEvent("SetSpinHistory")
local remoteEvent4 = v2:RemoteEvent("PlayerSpawned")
local remoteEvent5 = v2:RemoteEvent("PlaceTeleport")
local aFKWorld = playerGui:WaitForChild("AFKWorld")
local aFKInvite = playerGui:WaitForChild("AFKInvite")
local holder = playerGui:WaitForChild("RNG"):WaitForChild("Holder")
local main = aFKInvite.Main
local effects = script.Effects
local v19 = {
	{
		Effect = require3(effects["Tier5.story"]),
		Chance = 1000000
	},
	{
		Effect = require3(effects["Tier4.story"]),
		Chance = 100000
	},
	{
		Effect = require3(effects["Tier3.story"]),
		Chance = 10000
	},
	{
		Effect = require3(effects["Tier2.story"]),
		Chance = 1000
	},
	{
		Effect = require3(effects["Tier1.story"]),
		Chance = 0
	}
}
local v20 = {
	9047104336,
	9046862941,
	9046863235,
	9039768700,
	1848354536,
	9042666762,
	9047104571,
	9047105584,
	9039770426,
	9047106878,
	9042666614,
	9046865270,
	9046864509,
	9047107124,
	9046863579,
	9047104919,
	9039769814,
	9039769451,
	9039771113
}
local coinsEarned = aFKWorld.Left.Main.CoinsEarned
local starsEarned = aFKWorld.Left.Main.StarsEarned
local progressBar = coinsEarned.ProgressBar
local progressBar2 = starsEarned.ProgressBar
local progressBar3 = aFKWorld.Center.Main.ProgressBar
local progressBar4 = aFKWorld.Center.Main.Bottom.ProgressBar
local textLabel = aFKWorld.Center.Main.Bottom.Note.TextLabel
local premiumRewards = aFKWorld.Left.Main.PremiumRewards
local backToGame = aFKWorld.Left.Main.BackToGame
local extraLuck = aFKWorld.Right.Main.ExtraLuck
local friendBoost = aFKWorld.Left.Main.FriendBoost
local sound = Instance.new("Sound")
sound.SoundId = "rbxassetid://16759110468"
sound.Parent = workspace
local sound2 = Instance.new("Sound")
sound2.SoundId = "rbxassetid://16759476678"
sound2.Parent = workspace
local emoteName = aFKWorld.Center.Main.Bottom.EmoteName
emoteName.Parent = nil
local template = aFKWorld.Right.Main.ScrollList.ScrollingFrame.Template
template.Parent = nil
local template2 = aFKWorld.Right.Main.BestFinds.ScrollList.ScrollingFrame.Template
template2.Parent = nil
local _ = workspace.CurrentCamera
local v21 = nil
local humanoid = nil
local lastTime = os.clock()
local remoteEvent6 = v2:RemoteEvent("AFKRejoin")
local membershipTypeChangedConnection = nil
local v22 = nil
local v23 = nil
local v24 = nil
local AFKController = {
	_idleTrove = v6.new(),
	earnedCredits = 0,
	earnedStars = 0,
	_trackIdle = function(p)
		p._idleTrove:Clean()

		local function charAdded(instance)
			v21 = instance
			humanoid = instance:WaitForChild("Humanoid")
		end

		p._idleTrove:Add(localPlayer.CharacterAdded:Connect(charAdded))

		if localPlayer.Character then
			task.spawn(charAdded, localPlayer.Character)
		end

		local isHost = localPlayer:GetAttribute("IsHost")
		local maid = p._idleTrove:Extend()

		-- equivalent calls inferred from this helper; original call sites unknown
		local function idle()
			if not isHost then
				return
			end

			maid:Clean()
			maid:Add(RunService.Heartbeat:Connect(function()
				if os.clock() - lastTime > 960 then
					remoteEvent6:FireServer()
				end
			end))
		end

		p._idleTrove:Add(v.WindowFocusReleased:Connect(idle))
		p._idleTrove:Add(v.InputBegan:Connect(function()
			lastTime = os.clock()
		end))
		p._idleTrove:Add(v.InputEnded:Connect(function(_)
			if #v:GetKeysPressed() == 0 then
				idle() -- equivalent call inferred; original call site unknown
			end
		end))
		p._idleTrove:Add(localPlayer.Idled:Connect(function(p2: number)
			if p2 > 960 and isHost then
				remoteEvent6:FireServer()
			end

			if humanoid then
				humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
			end
		end))
	end,
	MusicHandler = function(self)
		local sound3 = Instance.new("Sound")
		sound3.Parent = game.Workspace
		sound3.Volume = 0.1
		local v25 = nil

		while task.wait(1) do
			sound3.TimePosition = 0
			local v26 = v20[math.random(1, #v20)]

			if v26 == v25 then
				continue
			end

			sound3.SoundId = "rbxassetid://" .. tostring(v26)
			sound3.PlaybackSpeed = 1
			sound3:Play()
			sound3.Ended:Wait()
			v25 = v26
		end
	end
}

function AFKController:Start()
	if v10.isAFKServer() then
		local AFK = v13:Get("AFK")

		if not AFK then
			return
		end

		local v25 = v3.Client:WaitReplion("Data")
		aFKWorld.Center.Label.Text = `Earn Coins & {v18.SeasonData.Currency.Name}\n Roll for Emotes`
		task.spawn(function()
			if v5:GetKey("AFKBackgroundMusic") then
				AFKController:MusicHandler()
			end
		end)

		if not localPlayer.Character then
			localPlayer.CharacterAdded:Wait()
		end

		task.spawn(function()
			v14.setTopbarEnabled(false)

			function v14.setTopbarEnabled() end

			holder.Parent.Enabled = true
		end)
		task.spawn(function()
			if workspace:GetServerTimeNow() < (v5:GetKey("AFKWorldLuckEndTime") or 0) then
				textLabel.Text = "🍀 Note: Global 2x luck boost is currently active! 🍀"
				textLabel.TextColor3 = Color3.fromRGB(255, 174, 11)
			else
				local v26 = {
					"All luck boost multipliers stack together!",
					"You will automatically rejoin, no need for a macro!",
					"Buy Premium to get better rewards!"
				}

				while task.wait(2) do
					textLabel.Text = "Note: " .. v26[math.random(1, #v26)]
					textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
				end
			end
		end)
		v13:Open("AFKWorld", "AFK", true)
		v11._currentGui = nil
		v11:Unlock("AFKWorld", true)
		v11:OnOpen(function(p)
			if p.Name ~= "AFKWorld" and p.Name ~= "InviteRewards" then
				v13:Open("AFKWorld", "AFK", true)
				v11._currentGui = nil
				v11:Unlock("AFKWorld", true)
			end
		end)
		starsEarned.Label.Text = `{v18.SeasonData.Currency.Name} Earned: `
		premiumRewards.List.Stars.Amount.Text = `2x {v18.SeasonData.Currency.Name}`

		for _, screenGui in playerGui:GetChildren() do
			if screenGui:IsA("ScreenGui") and screenGui.Name ~= "AFKWorld" and screenGui.Name ~= "TeleportUI" and screenGui.Name ~= "InviteRewards" and screenGui.Name ~= "PopUpTokensBuy" then
				local v26 = screenGui
				screenGui:GetPropertyChangedSignal("Enabled"):Connect(function()
					if v26.Enabled then
						v26.Enabled = false
					end
				end)
			elseif screenGui.Name == "InviteRewards" then
				screenGui.DisplayOrder = aFKWorld.DisplayOrder + 1
			end
		end

		updateMembershipUI()
		local v26 = {}

		local function addToHistory(emote)
			local v27 = v8.RarityColors[emote.Rarity] or emote.Color
			local strokeColor = emote.StrokeColor or emote.Rarity == "Secret" and Color3.new(1, 1, 1) or Color3.new(
				0,
				0,
				0
			)
			local clone = template:Clone()
			clone.Name = emote.Emote.Name
			clone.TextLabel.Text = `<stroke color="#{strokeColor:ToHex()}" joins="round" thickness="2"><font color="#{v27:ToHex()}">{emote.Emote:GetAttribute("EmoteName") or emote.Emote.Name}</font><font color="#{v27:ToHex()}">(1 in {v7.ValueConvertor:AddCommas(emote and emote.Chance or v8.NothingChance)})</font></stroke>`
			clone.Parent = aFKWorld.Right.Main.ScrollList.ScrollingFrame
			table.insert(v26, 1, {
				Frame = clone,
				Emote = emote
			})

			if #v26 > 100 then
				local v28 = v26[#v26]

				if v28 then
					v28.Frame:Destroy()
				end

				table.remove(v26, #v26)
			end

			for k, v28 in v26 do
				v28.Frame.LayoutOrder = k
			end
		end

		local function updateOwned()
			local count = 0

			for _, v27 in v8.List do
				if #client:FindItems("Emote", v27.Emote.Name) > 0 then
					count += 1
				end
			end

			aFKWorld.Right.Main.Owned.Text = `{count}/{#v8.List} OWNED (<font color="rgb(44, 239, 41)">{math.floor(count / #v8.List * 100)}%</font>)`
		end

		local function updateBestFinds()
			local bestFinds = v25:Get("BestFinds") or {}
			local v27 = {}

			for _, v28 in v8.List do
				if bestFinds[v28.Emote.Name] then
					table.insert(v27, v28)
				end
			end

			if #v27 == 0 then
				aFKWorld.Right.Main.ScrollList.Position = UDim2.fromScale(0.503, 0.379)
				aFKWorld.Right.Main.ScrollList.Size = UDim2.fromScale(0.981, 0.756)
				aFKWorld.Right.Main.BestFinds.Visible = false
				aFKWorld.Right.Main.BestFinds.Title.Visible = false
			else
				aFKWorld.Right.Main.ScrollList.Position = UDim2.fromScale(0.503, 0.229)
				aFKWorld.Right.Main.ScrollList.Size = UDim2.fromScale(0.981, 0.439)
				aFKWorld.Right.Main.BestFinds.Visible = true
				aFKWorld.Right.Main.BestFinds.Title.Visible = true
				aFKWorld.Right.Main.BestFinds.Title.Text = "<stroke color=\"#22377f\" joins=\"round\" thickness=\"2.5\"><font color=\"#ff3838\">Best</font><font color=\"#ffffff\"> Finds</font></stroke>"

				for _, child in pairs(aFKWorld.Right.Main.BestFinds.ScrollList.ScrollingFrame:GetChildren()) do
					if child:isA("Frame") and child.Visible then
						child:Destroy()
					end
				end

				table.sort(v27, function(a, b)
					return a.Chance > b.Chance
				end)

				if #v27 > 5 then
					for _ = #v27, 6, -1 do
						table.remove(v27, #v27)
					end
				end

				for _, v28 in pairs(v27) do
					local clone = template2:Clone()
					clone.Name = v28.Emote.Name
					clone.Parent = aFKWorld.Right.Main.BestFinds.ScrollList.ScrollingFrame
					local v29 = v8.RarityColors[v28.Rarity] or v28.Color
					local strokeColor = v28.StrokeColor or v28.Rarity == "Secret" and Color3.new(1, 1, 1) or Color3.new(
						0,
						0,
						0
					)
					clone.TextLabel.Text = `<stroke color="#{strokeColor:ToHex()}" joins="round" thickness="2"><font color="#{v29:ToHex()}">{v28.Emote:GetAttribute("EmoteName") or v28.Emote.Name}</font><font color="#{v29:ToHex()}">(1 in {v7.ValueConvertor:AddCommas(v28 and v28.Chance or v8.NothingChance)})</font></stroke>`
					clone.LayoutOrder = -v28.Chance
				end
			end
		end

		local function findEmote(p)
			if p then
				for _, v28 in v8.List do
					if v28.Emote.Name == p then
						return v28
					end
				end
			end

			return nil
		end

		local function showEquippedEmote(name)
			for _, child in pairs(aFKWorld.Right.Main.ScrollList.ScrollingFrame:GetChildren()) do
				if child.Name == name or not child:GetAttribute("Equipped") then
					if child.Name == name and not child:GetAttribute("Equipped") then
						child.Try.Label.TextColor3 = Color3.fromRGB(0, 255, 127)
						child:SetAttribute("Equipped", true)
					end
				else
					child:SetAttribute("Equipped", false)
					child.Try.Label.TextColor3 = Color3.fromRGB(255, 255, 255)
				end
			end

			for _, child in pairs(aFKWorld.Right.Main.BestFinds.ScrollList.ScrollingFrame:GetChildren()) do
				if child.Name == name or not child:GetAttribute("Equipped") then
					if child.Name == name and not child:GetAttribute("Equipped") then
						child.Try.Label.TextColor3 = Color3.fromRGB(0, 255, 127)
						child:SetAttribute("Equipped", true)
					end
				else
					child:SetAttribute("Equipped", false)
					child.Try.Label.TextColor3 = Color3.fromRGB(255, 255, 255)
				end
			end
		end

		task.spawn(function()
			aFKWorld.Right.Main.ScrollList.ScrollingFrame.ChildAdded:Connect(function(child)
				local try = child:WaitForChild("Try")
				showEquippedEmote(child.Name)
				try.Activated:Connect(function()
					local setEmote = AFK.Info.SetEmote
					local name = child.Name
					local v27 = nil

					if name then
						for _, v29 in v8.List do
							if v29.Emote.Name ~= name then
								continue
							end

							v27 = v29
							break
						end
					end

					setEmote(v27)
					showEquippedEmote(child.Name)
				end)
			end)
			aFKWorld.Right.Main.BestFinds.ScrollList.ScrollingFrame.ChildAdded:Connect(function(child)
				child:WaitForChild("Try").Activated:Connect(function()
					local setEmote = AFK.Info.SetEmote
					local name = child.Name
					local v27 = nil

					if name then
						for _, v29 in v8.List do
							if v29.Emote.Name ~= name then
								continue
							end

							v27 = v29
							break
						end
					end

					setEmote(v27)
					showEquippedEmote(child.Name)
				end)
			end)
		end)
		v25:OnChange("Emotes.Unlocked", updateOwned)
		task.spawn(updateOwned)
		v25:OnChange("BestFinds", updateBestFinds)
		task.spawn(updateBestFinds)
		local v27 = -1
		local v28 = -1
		local v29 = -1
		progressBar.Fill.Size = UDim2.fromScale(0, 1)
		progressBar2.Fill.Size = UDim2.fromScale(0, 1)
		remoteEvent3.OnClientEvent:Connect(function(list)
			for _, v30 in list do
				local v31 = nil

				for _, v33 in v8.List do
					if v33.Emote.Name ~= v30 then
						continue
					end

					v31 = v33
					break
				end

				if v31 then
					addToHistory(v31)
				end
			end

			if #list > 0 then
				AFK.Info.SetEmote(list[1].Emote)
			end
		end)
		remoteEvent2.OnClientEvent:Connect(function(p: string?, p2)
			local v30 = nil

			if p then
				for _, v32 in v8.List do
					if v32.Emote.Name ~= p then
						continue
					end

					v30 = v32
					break
				end
			end

			if p2 > 0 then
				aFKWorld.Center.LuckRoll.Visible = true
			end

			local function renderText(data, p3: number)
				local clone = emoteName:Clone()
				clone.Position = UDim2.fromScale(0.5, -0.75)
				clone.Text = not data and "Nothing" or data.Emote:GetAttribute("EmoteName") or data.Emote.Name or "Nothing"
				clone.TextColor3 = data and data.Color or Color3.new(1, 1, 1)
				local strokeColor = data and data.StrokeColor or Color3.new(0, 0, 0)
				clone.UIStroke.Color = strokeColor
				clone.Chance.Text = `<stroke color="rgb(0,0,0)" joins="round" thickness="2"><font color="rgb(44, 239, 41)">1</font> in <font color="rgb(44, 239, 41)">{v7.ValueConvertor:AddCommas(data and data.Chance or v8.NothingChance)}</font></stroke>`
				TweenService:Create(
					clone,
					TweenInfo.new(math.max(0.15, p3 * 1.5), Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
					{
						Position = UDim2.fromScale(0.5, -0.6)
					}
				):Play()
				clone.Parent = aFKWorld.Center.Main.Bottom
				return clone
			end

			local total = 0
			local v31 = nil

			for i = 1, 10 do
				if i == 10 and v30 and (v30.Rarity == "Legendary" or v30.Rarity == "Secret") then
					break
				end

				local v32

				if i == 10 then
					v32 = v30
				else
					v32 = v8.List[v8.getPicker(localPlayer, p2)()]
				end

				sound:Play()
				v31 = renderText(v32, total)
				total += 0.03

				if i ~= 10 then
					Debris:AddItem(v31, total)
				end

				task.wait(total)
			end

			task.delay(1, function()
				if v31 then
					v31:Destroy()
				end
			end)

			if v30 then
				local effect = v19[1].Effect

				for _, v32 in v19 do
					if v32.Chance >= v30.Chance then
						effect = v32.Effect
					end
				end

				task.delay(0.5, function()
					addToHistory(v30)
					AFK.Info.SetEmote(v30)
				end)
				effect(holder)

				if v30.Rarity == "Legendary" or v30.Rarity == "Secret" then
					Debris:AddItem(renderText(v30, 0.3), 2.5)
				end
			else
				sound2:Play()
			end

			if p2 > 0 then
				aFKWorld.Center.LuckRoll.Visible = false
			end
		end)
		remoteEvent.OnClientEvent:Connect(function(p: number, p2: number, p3: number)
			local aFKCoinDuration = workspace:GetAttribute("AFKCoinDuration")
			local aFKStarDuration = workspace:GetAttribute("AFKStarDuration")
			local aFKSpinDuration = workspace:GetAttribute("AFKSpinDuration")
			local v30 = math.floor(p % 3600) / 60
			math.floor(p % 60)
			local v31 = math.floor(p2 % 3600) / 60
			local v32 = math.floor(p2 % 60)
			local v33 = math.floor(p3 % 3600) / 60
			local v34 = math.floor(p3 % 60)
			progressBar.Label.Text = ("%02d:%02d to next reward"):format(v30, v32)
			progressBar2.Label.Text = ("%02d:%02d to next reward"):format(v31, v32)
			progressBar3.Label.Text = ("%02d:%02d to next reward"):format(v33, v34)

			if v23 then
				v23:Cancel()
				v23:Destroy()
			end

			if v22 then
				v22:Cancel()
				v22:Destroy()
			end

			if v24 then
				v24:Cancel()
				v24:Destroy()
			end

			local v35 = v27 == 0 and 0.5 or 1
			local v36 = v28 == 0 and 0.5 or 1
			local v37 = v29 == 0 and 0.5 or 1
			local tween = TweenService:Create(progressBar.Fill, TweenInfo.new(v35, Enum.EasingStyle.Linear), {
				Size = UDim2.fromScale(math.clamp(1 - p / aFKCoinDuration, 0, 1), 1)
			})
			tween:Play()
			v22 = tween
			local tween2 = TweenService:Create(progressBar2.Fill, TweenInfo.new(v36, Enum.EasingStyle.Linear), {
				Size = UDim2.fromScale(math.clamp(1 - p2 / aFKStarDuration, 0, 1), 1)
			})
			tween2:Play()
			v23 = tween2
			local tween3 = TweenService:Create(progressBar3.Fill, TweenInfo.new(v37, Enum.EasingStyle.Linear), {
				Size = UDim2.fromScale(math.clamp(1 - p3 / aFKSpinDuration, 0, 1), 1)
			})
			tween3:Play()
			v24 = tween3
			v27 = p
			v28 = p2
			v29 = p3
			local joinTime = localPlayer:GetAttribute("JoinTime")

			if joinTime then
				local v38 = workspace:GetServerTimeNow() - joinTime
				local total = 0
				local total2 = 0
				local v39 = 0

				for _, v41 in v9 do
					if v41.Time <= v38 then
						total += v41.Time
						total2 += v41.Position
					else
						v39 = total2 + (v38 - total) / v41.Time * (v41.Position - total2)
						break
					end
				end

				progressBar4.Fill.Size = UDim2.fromScale(math.clamp(v39, 0, 1), 1)
			end
		end)
		localPlayer:GetAttributeChangedSignal("AFKCoinsEarned"):Connect(function(...)
			local aFKCoinsEarned = localPlayer:GetAttribute("AFKCoinsEarned")

			if not aFKCoinsEarned then
				return
			end

			local earnedCredits = self.earnedCredits or 0
			self.earnedCredits = aFKCoinsEarned

			for i = earnedCredits, aFKCoinsEarned do
				coinsEarned.List.Desc1.Text = v7.ValueConvertor:AddCommas(i)
				task.wait(0.05)
			end
		end)
		localPlayer:GetAttributeChangedSignal("AFKStarsEarned"):Connect(function(...)
			local aFKStarsEarned = localPlayer:GetAttribute("AFKStarsEarned")

			if not aFKStarsEarned then
				return
			end

			local earnedStars = self.earnedStars or 0
			self.earnedStars = aFKStarsEarned

			for i = earnedStars, aFKStarsEarned do
				starsEarned.List.Desc1.Text = v7.ValueConvertor:AddCommas(i)
				task.wait(0.05)
			end
		end)
		premiumRewards.Buy.Activated:Connect(function()
			pcall(function()
				v4:PromptPremiumPurchase(localPlayer)
			end)
		end)

		local function updateLuckTime()
			local rNGLuckTime = v25:Get("RNGLuckTime") or 0

			if rNGLuckTime > 0 then
				extraLuck.Left.Text = `Ends In: {v7.ValueConvertor:FormatTimeWithDays(rNGLuckTime)}`
			else
				extraLuck.Left.Text = ""
			end
		end

		v25:OnChange("RNGLuckTime", updateLuckTime)
		task.spawn(updateLuckTime)
		v12(extraLuck.BuyList.Buy1.Label, 1774773766, "DevProduct", "%s")
		extraLuck.BuyList.Buy1.Activated:Connect(function()
			v17:PromptPurchase(1774773766, Enum.InfoType.Product)
		end)
		v12(extraLuck.BuyList.Buy3.Label, 1774773767, "DevProduct", "%s")
		extraLuck.BuyList.Buy3.Activated:Connect(function()
			v17:PromptPurchase(1774773767, Enum.InfoType.Product)
		end)
		v12(extraLuck.BuyList.Buy10.Label, 1774773765, "DevProduct", "%s")
		extraLuck.BuyList.Buy10.Activated:Connect(function()
			v17:PromptPurchase(1774773765, Enum.InfoType.Product)
		end)
		backToGame.Activated:Connect(function()
			remoteEvent5:FireServer("Default")
		end)
		membershipTypeChangedConnection = localPlayer:GetPropertyChangedSignal("MembershipType"):Connect(updateMembershipUI)
		task.spawn(function()
			local success, result = pcall(function()
				return SocialService:CanSendGameInviteAsync(localPlayer)
			end)

			if not (success and result and v15:CanInvite()) then
				friendBoost.Visible = false
				return
			end

			-- equivalent calls inferred from this helper; original call sites unknown
			local function updateFriendLuck()
				local v30 = math.min(math.max(0, (#Players:GetPlayers() - 1) * 0.1), 0.5)
				friendBoost.Label.Text = string.format("+%d%%", v30 * 100)
			end

			Players.PlayerAdded:Connect(updateFriendLuck)
			Players.PlayerRemoving:Connect(updateFriendLuck)
			updateFriendLuck() -- equivalent call inferred; original call site unknown
			friendBoost.Invite.Activated:Connect(function()
				v15:PromptFriendInvite({
					Type = "AFK"
				})
			end)
		end)
		remoteEvent4:FireServer()
	else
		local remoteEvent7 = v2:RemoteEvent("PromptAFKInvite")
		local v25 = nil

		-- equivalent calls inferred from this helper; original call sites unknown
		local function processInvite()
			aFKInvite.Enabled = v25 ~= nil
			main.Visible = v25 ~= nil

			if v25 then
				main.Invite.Text = "@[Loading] Invited You to AFK World!"
				v16:GetUsername(v25):andThen(function(p)
					if not v25 then
						return
					end

					main.Invite.Text = `@{p} Invited You to AFK World!`
				end)
			end
		end

		main.ReadyButton.Activated:Connect(function()
			if v25 then
				remoteEvent7:FireServer(true)
				v25 = nil
				processInvite() -- equivalent call inferred; original call site unknown
			end
		end)
		main.DeclineButton.Activated:Connect(function()
			if v25 then
				remoteEvent7:FireServer(false)
				v25 = nil
				processInvite() -- equivalent call inferred; original call site unknown
			end
		end)
		remoteEvent7.OnClientEvent:Connect(function(p: number)
			v25 = p
			processInvite() -- equivalent call inferred; original call site unknown
		end)
	end
end

function isPremium()
	return localPlayer.MembershipType == Enum.MembershipType.Premium
end

function updateMembershipUI()
	if isPremium() then
		coinsEarned.PerMinute.Amount.Text = "+2"
		starsEarned.PerMinute.Amount.Text = "+4"
	else
		coinsEarned.PerMinute.Amount.Text = "+1"
		starsEarned.PerMinute.Amount.Text = "+2"
	end

	premiumRewards.Buy.Visible = not isPremium()
	premiumRewards.PremiumSupporter.Visible = isPremium()
end

return AFKController