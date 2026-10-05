local ReplicatedStorage = game:GetService("ReplicatedStorage")
local MarketplaceService = require(game.ReplicatedStorage.Common.MarketplaceService)
local Players = game:GetService("Players")
local CollectionService = game:GetService("CollectionService")
local TweenService = game:GetService("TweenService")

while not workspace:GetAttribute("ClientStarted") do
	workspace:GetAttributeChangedSignal("ClientStarted"):Wait()
end

require(ReplicatedStorage.Controllers.AnalyticsController)
local Replion = require(ReplicatedStorage.Packages.Replion)
local Signal = require(ReplicatedStorage.Packages.Signal)
local GuiHandler = require(ReplicatedStorage.ClientGameModules.GuiHandler)
local Net = require(ReplicatedStorage.Packages.Net)
local Utils = require(ReplicatedStorage.Common.Utils)
local OwnsGamePass = require(ReplicatedStorage.ClientGameModules.OwnsGamePass)
local CratesContent = require(ReplicatedStorage.Common.CratesContent)
local WeightRandom = require(ReplicatedStorage.Shared.WeightRandom)
local SecretAwakenData = require(ReplicatedStorage.Shared.SecretAwakenData)
local Swords = require(ReplicatedStorage.Shared.ReplicatedInstances.Swords)
local DuoPassData = require(ReplicatedStorage.Shared.DuoPassData)
local localPlayer = Players.LocalPlayer
local v = Replion.Client:WaitReplion("Data")
local openCrate = ReplicatedStorage.Remotes.OpenCrate
local remoteEvent = Net:RemoteEvent("SpinFinished")
local crateFinished = Signal.new()
_G.CrateFinished = crateFinished
local v3 = {
	HalloweenSwordCrate = true,
	ChristmasSwordCrate = true,
	LunarSwordCrate = true,
	DungeonSwordCrate = true
}
return {
	Binder = function(parent)
		local maid = Utils.Maid.new()
		maid.Active = true
		local flag = false
		local v4 = false
		local v5 = false
		local v6 = ReplicatedStorage.Remotes.Store.GetOwnsFastUnbox:InvokeServer()
		ReplicatedStorage.Remotes.ForceFastUnbox.OnClientEvent:Connect(function(fast)
			_G.fast = fast
		end)
		local unboxGui = parent.UnboxGui
		local skip = unboxGui.Skip
		local auto = unboxGui.Auto
		auto.Visible = false
		local scroller = unboxGui.WeaponsClipping.Scroller

		local function createCrateFromAwardInfo(p)
			return function(p2, _)
				local clone = table.clone(p)
				local picker = WeightRandom.getPicker(clone)
				return function(p3, p4, p5)
					local function getItemFromList()
						for k in clone do
							if k.DisplayName == p3 then
								return k
							end
						end
					end

					local v7

					if p3 then
						for k in clone do
							if k.DisplayName ~= p3 then
								continue
							end

							v7 = k
							break
						end
					else
						v7 = picker()
					end

					if (p4 == p5 - 1 or p4 == p5 + 1) and math.random(0, 1) == 0 then
						v7 = WeightRandom.getPicker(clone, 100000)()
					end

					if v7.Icon then
						local clone2 = scroller.Parent.ExplosionTemplate.Any:Clone()
						clone2.Size = UDim2.new(0, scroller.AbsoluteSize.X / p2, 1, 0)
						clone2.Visible = true
						clone2.Name = v7.DisplayName
						clone2.NameOfExplosion.Text = ""
						clone2.NameOfExplosion.TextColor3 = clone2.NameOfExplosion.TextColor3
						clone2.NameOfExplosion.UIGradient.Color = ColorSequence.new(Color3.new(1, 1, 1))
						clone2.NameOfExplosion.TextStrokeColor3 = clone2.NameOfExplosion.TextStrokeColor3
						clone2.SubText.Text = string.upper(v7.DisplayName)
						clone2.SubText.TextColor3 = clone2.SubText.TextColor3
						clone2.SubText.UIGradient.Color = ColorSequence.new(Color3.new(1, 1, 1))
						clone2.SubText.TextStrokeColor3 = clone2.SubText.TextStrokeColor3
						clone2.ImageLabel.Image = v7.Icon
						return clone2
					else
						local swordData = Utils.SwordUtil:GetSwordData(v7.Value)
						local clone2 = scroller.Parent.SwordTemplate.Unique:Clone()
						clone2.Size = UDim2.new(0, scroller.AbsoluteSize.X / p2, 1, 0)
						clone2.Visible = true
						clone2.Transparency = 1
						clone2.BackgroundTransparency = 1
						clone2.NameOfWeapon.Text = v7.DisplayName
						clone2.Name = v7.DisplayName

						if swordData then
							Utils.Icons:SetSwordIconAsViewport(clone2.ViewportFrame, swordData:Clone())
							return clone2
						end

						warn("No icon found for", v7)
						return clone2
					end
				end
			end
		end

		local v7 = {
			Explosion = function(p, p2)
				local children = ReplicatedStorage.Misc.DataExplosions:GetChildren()

				for i = #children, 1, -1 do
					local v8 = children[i]
					local rarity = v8:GetAttribute("Rarity")
					local v9

					if p2 == "SecretExplosionCrate" then
						v9 = rarity == "Secret"
					elseif p2 == "DailyQuestExplosionCrate" then
						v9 = rarity == "Unique"
					else
						v9 = rarity == "Legendary" or rarity == "Rare" or rarity == "Common"
					end

					if v8:GetAttribute("Unobtainable") == true or not v9 or v8.Name == "Explosion Normal" then
						table.remove(children, i)
					end
				end

				if p2 == "DailyQuestExplosionCrate" then
					local dailyQuestExplosionCrate = CratesContent.DailyQuestExplosionCrate
					local v8 = {}

					for _, v9 in children do
						for _, v10 in dailyQuestExplosionCrate do
							if v10.ItemName == v9.Name then
								table.insert(v8, v9)
							end
						end
					end

					children = v8
				end

				local v8 = {}

				for _, v9 in children do
					local rarity = v9:GetAttribute("Rarity") or "Common"

					if v8[rarity] == nil then
						v8[rarity] = {}
					end

					table.insert(v8[rarity], v9)
				end

				local v9

				if p2 == "PremiumExplosionCrate" then
					v9 = {
						Common = 0,
						Rare = 80,
						Legendary = 20
					}
				elseif p2 == "SecretExplosionCrate" then
					v9 = {
						Secret = 100
					}
				elseif p2 == "DailyQuestExplosionCrate" then
					v9 = {
						Unique = 100
					}
				else
					v9 = {
						Common = 65,
						Rare = 25,
						Legendary = 10
					}
				end

				local picker = WeightRandom.getPicker(v9)

				-- equivalent calls inferred from this helper; original call sites unknown
				local function getWeightedRandomItem()
					local v11 = v8[picker()]
					return v11[math.random(#v11)]
				end

				local function setupSecret(p3, p4, p5)
					if p3 and not p4 or p5 then
						return
					end

					if Random.new():NextNumber() <= SecretAwakenData.GetSecretRate(p2) then
						return "Secret2"
					end
				end

				return function(childName, _, _, p3, p4)
					local name

					if childName and p3 then
						name = "Secret2"
					elseif not (childName and not p3 or p4) then
						name = Random.new():NextNumber() <= SecretAwakenData.GetSecretRate(p2) and "Secret2" or nil
					end

					local child = type(childName) == "string" and ReplicatedStorage.Misc.DataExplosions:FindFirstChild(childName)

					if not child then
						child = getWeightedRandomItem()
					end

					local child2 = not name and scroller.Parent.ExplosionTemplate:FindFirstChild(child:GetAttribute("Rarity"))
					local clone = name and scroller.Parent.ExplosionTemplate[name]:Clone() or (child2 or scroller.Parent.ExplosionTemplate.Any):Clone()
					clone.Size = UDim2.new(0, scroller.AbsoluteSize.X / p, 1, 0)
					clone.Visible = true
					clone.Transparency = 1
					clone.BackgroundTransparency = 1

					if name then
						clone.Name = name
						return clone
					end

					if not child then
						warn("No explosion data found for " .. tostring(childName))
						return clone
					end

					clone.Name = child.Name
					clone.NameOfExplosion.Text = child:GetAttribute("TitleText") or clone.NameOfExplosion.Text
					clone.NameOfExplosion.TextColor3 = child:GetAttribute("TitleTextColor") or clone.NameOfExplosion.TextColor3

					if child:FindFirstChild("TitleTextColor") then
						clone.NameOfExplosion.TextColor3 = Color3.new(1, 1, 1)
						clone.NameOfExplosion.UIGradient.Color = child.TitleTextColor.Color
					else
						clone.NameOfExplosion.UIGradient.Color = ColorSequence.new(Color3.new(1, 1, 1))
					end

					clone.NameOfExplosion.TextStrokeColor3 = child:GetAttribute("TitleTextStrokeColor") or clone.NameOfExplosion.TextStrokeColor3
					clone.SubText.Text = child:GetAttribute("SubText") or clone.SubText.SubText
					clone.SubText.TextColor3 = child:GetAttribute("SubTextColor") or clone.SubText.TextColor3

					if child:FindFirstChild("SubTextColor") then
						clone.SubText.TextColor3 = Color3.new(1, 1, 1)
						clone.SubText.UIGradient.Color = child.SubTextColor.Color
					else
						clone.SubText.UIGradient.Color = ColorSequence.new(Color3.new(1, 1, 1))
					end

					clone.SubText.TextStrokeColor3 = child:GetAttribute("SubTextStrokeColor") or clone.SubText.TextStrokeColor3
					clone.ImageLabel.Image = child:GetAttribute("Icon") or Utils.Icons:GetIcon()
					return clone
				end
			end,
			Sword = function(p, p2)
				local swordList = Utils.SwordUtil:GetSwordList(function(data)
					if data.Unobtainable == true or p2 == "PremiumSwordCrate" and not ({
						Rare = true,
						Legendary = true
					})[data.Rarity] then
						return false
					end

					if v3[p2] then
						return data.Crate == p2
					end

					local rarity = data.Rarity
					return rarity ~= "Unique" and rarity ~= "Limited" and rarity ~= "LimitedU"
				end)

				if p2 == "AncientSwordChest" then
					local ancientSwordChest = CratesContent.AncientSwordChest
					swordList = Utils.SwordUtil:GetSwordList(function(p3)
						for _, v8 in ancientSwordChest do
							if p3.Name == v8.Item.Lootbox[1].Item.Swords[1] then
								return true
							end
						end
					end)
				elseif p2 == "SecretSwordCrate" then
					local secretSwordCrate = CratesContent.SecretSwordCrate
					swordList = Utils.SwordUtil:GetSwordList(function(p3)
						for _, v8 in secretSwordCrate do
							if p3.Name == v8.Item.Lootbox[1].Item.Swords[1] then
								return true
							end
						end
					end)
				elseif p2 == "CyberSecretSwordCrate" then
					local cyberSecretSwordCrate = CratesContent.CyberSecretSwordCrate
					swordList = Utils.SwordUtil:GetSwordList(function(p3)
						for _, v8 in cyberSecretSwordCrate do
							if p3.Name == v8.Item.Lootbox[1].Item.Swords[1] then
								return true
							end
						end
					end)
				elseif p2 == "DungeonSecretSwordCrate" then
					local dungeonSecretSwordCrate = CratesContent.DungeonSecretSwordCrate
					swordList = Utils.SwordUtil:GetSwordList(function(p3)
						for _, v8 in dungeonSecretSwordCrate do
							if p3.Name == v8.Item.Lootbox[1].Item.Swords[1] then
								return true
							end
						end
					end)
				elseif p2 == "DailyQuestSwordCrate" then
					local dailyQuestSwordCrate = CratesContent.DailyQuestSwordCrate
					swordList = Utils.SwordUtil:GetSwordList(function(p3)
						for _, v8 in dailyQuestSwordCrate do
							if p3.Name == v8.ItemName then
								return true
							end
						end
					end)
				end

				local v8 = {}

				for _, v9 in swordList do
					local rarity = v9.Rarity

					if v8[rarity] == nil then
						v8[rarity] = {}
					end

					table.insert(v8[rarity], v9)
				end

				local v9

				if p2 == "PremiumSwordCrate" then
					v9 = {
						Normal = 0,
						Rare = 90,
						Legendary = 10
					}
				elseif p2 == "ChristmasSwordCrate" then
					v9 = {
						Unique = 100
					}
				elseif p2 == "SecretSwordCrate" or p2 == "DungeonSecretSwordCrate" or p2 == "CyberSecretSwordCrate" then
					v9 = {
						Secret = 100
					}
				elseif p2 == "DailyQuestSwordCrate" or p2 == "LunarSwordCrate" then
					v9 = {
						Unique = 100
					}
				elseif p2 == "DungeonSwordCrate" then
					v9 = {
						Unique = 99.85,
						Secret = 0.15
					}
				else
					v9 = {
						Normal = 65,
						Rare = 25,
						Legendary = 10
					}
				end

				local picker = WeightRandom.getPicker(v9)

				local function getWeightedRandomItem()
					local v10 = picker()
					local v11 = v8[v10]

					if not v11 then
						task.spawn(error, (`Invalid item pool, {p2} / {v10}`))
					end

					return v11[math.random(#v11)]
				end

				local function setupSecret(p3, p4, p5)
					if p3 and not p4 or p5 then
						return
					end

					if Random.new():NextNumber() <= SecretAwakenData.GetSecretRate(p2) then
						return "Secret2"
					end
				end

				return function(p3, _, _, p4, p5)
					local v10

					if p3 and p4 then
						v10 = "Secret2"
					elseif not (p3 and not p4 or p5) then
						v10 = Random.new():NextNumber() <= SecretAwakenData.GetSecretRate(p2) and "Secret2" or nil
					end

					local sword = p3 and Swords:GetSword(p3)

					if not sword then
						local v11 = picker()
						local v12 = v8[v11]

						if not v12 then
							task.spawn(error, (`Invalid item pool, {p2} / {v11}`))
						end

						sword = v12[math.random(#v12)]
					end

					local clone = v10 and scroller.Parent.SwordTemplate[v10]:Clone() or scroller.Parent.SwordTemplate[sword.Rarity]:Clone()
					clone.Size = UDim2.new(0, scroller.AbsoluteSize.X / p, 1, 0)
					clone.Visible = true
					clone.Transparency = 1
					clone.BackgroundTransparency = 1
					clone.Name = v10 or sword.Name

					if v10 then
						return clone
					end

					clone.NameOfWeapon.Text = sword.Name
					local icon = sword.Icon
					local imageLabel = clone:FindFirstChild("ImageLabel")

					if imageLabel and icon then
						imageLabel.Image = icon
						return clone
					end

					Utils.Icons:SetSwordIconAsViewportByName(clone.ViewportFrame, sword.Name)
					return clone
				end
			end,
			Coins = function(p, p2)
				local v8 = CratesContent[p2]
				return function(name)
					local v9 = v8

					if type(name) == "string" then
						for _, v10 in v8 do
							if v10.Item.Lootbox[1].Item.Coins[1] == name then
								v9 = v10
							end
						end
					else
						v9 = Utils.ValueConvertor:PickFromLootbox(v8)
						name = v9.Item.Lootbox[1].Item.Coins[1]
					end

					local clone = scroller.Parent.CoinsTemplate:Clone()
					clone.Size = UDim2.new(0, scroller.AbsoluteSize.X / p, 1, 0)
					clone.Visible = true
					clone.Transparency = 1
					clone.BackgroundTransparency = 1

					if not v9 then
						warn("No coins data found for " .. tostring(name))
						return clone
					end

					clone.Name = name
					clone.NameOfPack.Text = `{tonumber(tostring(name):match("%d+"))}\nCOINS`
					clone.ImageLabel.Image = v9.Icon or Utils.Icons:GetIcon()
					return clone
				end
			end,
			Emote = function(p, p2)
				local v8 = CratesContent[p2]

				-- equivalent calls inferred from this helper; original call sites unknown
				local function getRandomItem()
					local v9, _ = Utils.ValueConvertor:PickFromLootbox(v8)
					return v9.ItemName
				end

				return function(childName)
					if typeof(childName) ~= "string" or not childName then
						childName = getRandomItem()
					end

					local child = ReplicatedStorage.Misc.Emotes:FindFirstChild(childName)
					local clone = scroller.Parent.CoinsTemplate:Clone()
					clone.Size = UDim2.new(0, scroller.AbsoluteSize.X / p, 1, 0)
					clone.Visible = true
					clone.Transparency = 1
					clone.BackgroundTransparency = 1

					if not child then
						warn("No Emote! data found for " .. tostring(childName))
						return clone
					end

					clone.Name = child:GetAttribute("EmoteName")
					clone.NameOfPack.Text = child:GetAttribute("EmoteName")
					clone.ImageLabel.Image = child:GetAttribute("Icon") or Utils.Icons:GetIcon()
					return clone
				end
			end,
			LiveEvent = function(p, p2)
				local _ = CratesContent[p2]
				local swordList = Utils.SwordUtil:GetSwordList(function(p3)
					return p3.Crate == "LiveEvent"
				end)
				swordList[#swordList + 1] = ReplicatedStorage.Misc.DataExplosions["Viper’s Vengeance"]
				return function(p3)
					local sword

					if p3 then
						sword = Swords:GetSword(p3) or swordList[3]
					else
						sword = swordList[math.random(1, #swordList)]
					end

					local icon

					if type(sword) == "table" then
						icon = sword.Icon
					else
						icon = sword:GetAttribute("Icon")
					end

					if icon then
						local clone = scroller.Parent.ExplosionTemplate:Clone()
						clone.Size = UDim2.new(0, scroller.AbsoluteSize.X / p, 1, 0)
						clone.Visible = true
						clone.Name = sword.Name

						if typeof(sword) == "Instance" then
							clone.NameOfExplosion.Text = sword:GetAttribute("TitleText") or clone.NameOfExplosion.Text
							clone.NameOfExplosion.TextColor3 = sword:GetAttribute("TitleTextColor") or clone.NameOfExplosion.TextColor3

							if sword:FindFirstChild("TitleTextColor") then
								clone.NameOfExplosion.TextColor3 = Color3.new(1, 1, 1)
								clone.NameOfExplosion.UIGradient.Color = sword.TitleTextColor.Color
							else
								clone.NameOfExplosion.UIGradient.Color = ColorSequence.new(Color3.new(1, 1, 1))
							end

							clone.NameOfExplosion.TextStrokeColor3 = sword:GetAttribute("TitleTextStrokeColor") or clone.NameOfExplosion.TextStrokeColor3
							clone.SubText.Text = sword:GetAttribute("SubText") or clone.SubText.SubText
							clone.SubText.TextColor3 = sword:GetAttribute("SubTextColor") or clone.SubText.TextColor3

							if sword:FindFirstChild("SubTextColor") then
								clone.SubText.TextColor3 = Color3.new(1, 1, 1)
								clone.SubText.UIGradient.Color = sword.SubTextColor.Color
							else
								clone.SubText.UIGradient.Color = ColorSequence.new(Color3.new(1, 1, 1))
							end

							clone.SubText.TextStrokeColor3 = sword:GetAttribute("SubTextStrokeColor") or clone.SubText.TextStrokeColor3
						end

						clone.ImageLabel.Image = icon or Utils.Icons:GetIcon()
						return clone
					else
						local clone = scroller.Parent.SwordTemplate.Unique:Clone()
						clone.Size = UDim2.new(0, scroller.AbsoluteSize.X / p, 1, 0)
						clone.Visible = true
						clone.Transparency = 1
						clone.BackgroundTransparency = 1
						clone.NameOfWeapon.Text = sword.Name
						clone.Name = sword.Name
						Utils.Icons:SetSwordIconAsViewportByName(clone.ViewportFrame, sword.Name)
						return clone
					end
				end
			end,
			ClanSword = function(p, p2)
				local _ = CratesContent[p2]
				local swordList = Utils.SwordUtil:GetSwordList(function(p3)
					return p3.Crate == "ClanSword"
				end)
				return function(p3)
					local sword

					if p3 then
						sword = Swords:GetSword(p3) or swordList[3]
					else
						sword = swordList[math.random(1, #swordList)]
					end

					local icon

					if type(sword) == "table" then
						icon = sword.Icon
					else
						icon = sword:GetAttribute("Icon")
					end

					if icon then
						local clone = scroller.Parent.ExplosionTemplate.Any:Clone()
						clone.Size = UDim2.new(0, scroller.AbsoluteSize.X / p, 1, 0)
						clone.Visible = true
						clone.Name = sword.Name

						if typeof(sword) == "Instance" then
							clone.NameOfExplosion.Text = sword:GetAttribute("TitleText") or clone.NameOfExplosion.Text
							clone.NameOfExplosion.TextColor3 = sword:GetAttribute("TitleTextColor") or clone.NameOfExplosion.TextColor3

							if sword:FindFirstChild("TitleTextColor") then
								clone.NameOfExplosion.TextColor3 = Color3.new(1, 1, 1)
								clone.NameOfExplosion.UIGradient.Color = sword.TitleTextColor.Color
							else
								clone.NameOfExplosion.UIGradient.Color = ColorSequence.new(Color3.new(1, 1, 1))
							end

							clone.NameOfExplosion.TextStrokeColor3 = sword:GetAttribute("TitleTextStrokeColor") or clone.NameOfExplosion.TextStrokeColor3
							clone.SubText.Text = sword:GetAttribute("SubText") or clone.SubText.SubText
							clone.SubText.TextColor3 = sword:GetAttribute("SubTextColor") or clone.SubText.TextColor3

							if sword:FindFirstChild("SubTextColor") then
								clone.SubText.TextColor3 = Color3.new(1, 1, 1)
								clone.SubText.UIGradient.Color = sword.SubTextColor.Color
							else
								clone.SubText.UIGradient.Color = ColorSequence.new(Color3.new(1, 1, 1))
							end

							clone.SubText.TextStrokeColor3 = sword:GetAttribute("SubTextStrokeColor") or clone.SubText.TextStrokeColor3
						end

						clone.ImageLabel.Image = icon or Utils.Icons:GetIcon()
						return clone
					else
						local clone = scroller.Parent.SwordTemplate.Unique:Clone()
						clone.Size = UDim2.new(0, scroller.AbsoluteSize.X / p, 1, 0)
						clone.Visible = true
						clone.Transparency = 1
						clone.BackgroundTransparency = 1
						clone.NameOfWeapon.Text = sword.Name
						clone.Name = sword.Name
						Utils.Icons:SetSwordIconAsViewportByName(clone.ViewportFrame, sword.Name)
						return clone
					end
				end
			end,
			ClanMagical = function(p, p2)
				local _ = CratesContent[p2]
				local LootboxData = require(ReplicatedStorage.Shared.LootboxData)
				local v8 = {}

				for _, item in LootboxData.GachaEvents.ClanMagicalCrate.Items do
					table.insert(v8, {
						Type = next(item.SimpleReward),
						DisplayName = item.DisplayName,
						Icon = item.ImageId
					})
				end

				return function(_)
					local v9 = v8[math.random(1, #v8)]
					local clone = scroller.Parent.ExplosionTemplate.Any:Clone()
					clone.Size = UDim2.new(0, scroller.AbsoluteSize.X / p, 1, 0)
					clone.Visible = true
					clone.Name = v9.DisplayName
					clone.NameOfExplosion.Text = v9.DisplayName
					clone.NameOfExplosion.UIGradient.Color = ColorSequence.new(Color3.new(1, 1, 1))
					clone.SubText.Text = v9.Type
					clone.SubText.UIGradient.Color = ColorSequence.new(Color3.new(1, 1, 1))
					clone.ImageLabel.Image = v9.Icon or Utils.Icons:GetIcon()
					return clone
				end
			end,
			SerpentLiveEvent = function(p, p2)
				local v8 = {}

				for _, v9 in CratesContent[p2][1].Item.Lootbox do
					for _, v10 in v9.Item do
						for _, v11 in v10 do
							v8[v11] = true
						end
					end
				end

				local swordList = Utils.SwordUtil:GetSwordList(function(p3)
					return v8[p3.Name] == true
				end)
				table.insert(swordList, ReplicatedStorage.Misc.DataExplosions["Serpent's Rage"])
				table.insert(swordList, ReplicatedStorage.Misc.DataAbilities["Serpent Shadow Clone"])
				table.insert(swordList, ReplicatedStorage.Misc.Emotes.Emote35)
				return function(p3)
					local function getItemFromList()
						for _, v9 in swordList do
							if v9.Name == p3 then
								return v9
							end
						end
					end

					local sword

					if p3 then
						sword = Swords:GetSword(p3)

						if not sword then
							for _, v10 in swordList do
								if v10.Name ~= p3 then
									continue
								end

								sword = v10
								break
							end
						end
					else
						sword = swordList[math.random(1, #swordList)]
					end

					if not p3 and (sword.Name == "Serpent Shadow Clone" and math.random() > 0.5 or sword.Name == "Serpent's Fang" and math.random() > 0.75) then
						sword = swordList[math.random(1, #swordList)]
					end

					local icon

					if type(sword) == "table" then
						icon = sword.Icon
					else
						icon = sword:GetAttribute("Icon")
					end

					if icon then
						local clone = scroller.Parent.ExplosionTemplate:Clone()
						clone.Size = UDim2.new(0, scroller.AbsoluteSize.X / p, 1, 0)
						clone.Visible = true
						local name = sword.Name
						local child = ReplicatedStorage.Misc.Emotes:FindFirstChild(name)

						if child then
							name = child:GetAttribute("EmoteName")
						end

						local text = string.upper(name)
						clone.Name = sword.Name
						clone.NameOfExplosion.Text = ""

						if typeof(sword) == "Instance" then
							clone.NameOfExplosion.TextColor3 = sword:GetAttribute("TitleTextColor") or clone.NameOfExplosion.TextColor3

							if sword:FindFirstChild("TitleTextColor") then
								clone.NameOfExplosion.TextColor3 = Color3.new(1, 1, 1)
								clone.NameOfExplosion.UIGradient.Color = sword.TitleTextColor.Color
							else
								clone.NameOfExplosion.UIGradient.Color = ColorSequence.new(Color3.new(1, 1, 1))
							end

							clone.NameOfExplosion.TextStrokeColor3 = sword:GetAttribute("TitleTextStrokeColor") or clone.NameOfExplosion.TextStrokeColor3
							clone.SubText.Text = text
							clone.SubText.TextColor3 = sword:GetAttribute("SubTextColor") or sword:GetAttribute("TitleTextColor") or clone.SubText.TextColor3

							if sword:FindFirstChild("SubTextColor") then
								clone.SubText.TextColor3 = Color3.new(1, 1, 1)
								clone.SubText.UIGradient.Color = sword.SubTextColor.Color
							else
								clone.SubText.UIGradient.Color = ColorSequence.new(Color3.new(1, 1, 1))
							end

							clone.SubText.TextStrokeColor3 = sword:GetAttribute("SubTextStrokeColor") or sword:GetAttribute("TitleTextStrokeColor") or clone.SubText.TextStrokeColor3
						end

						clone.ImageLabel.Image = icon or Utils.Icons:GetIcon()
						return clone
					else
						local clone = scroller.Parent.SwordTemplate.Unique:Clone()
						clone.Size = UDim2.new(0, scroller.AbsoluteSize.X / p, 1, 0)
						clone.Visible = true
						clone.Transparency = 1
						clone.BackgroundTransparency = 1
						clone.NameOfWeapon.Text = sword.Name
						clone.Name = sword.Name
						Utils.Icons:SetSwordIconAsViewportByName(clone.ViewportFrame, sword.Name)
						return clone
					end
				end
			end,
			DuoPassNormalPresent = 0,
			DuoPassRobuxPresent = 0
		}
		local normalPresent = DuoPassData.NormalPresent

		function v7.DuoPassNormalPresent(p, _)
			local clone = table.clone(normalPresent)
			local picker = WeightRandom.getPicker(clone)
			return function(p2, p3, p4)
				local function getItemFromList()
					for k in clone do
						if k.DisplayName == p2 then
							return k
						end
					end
				end

				local v8

				if p2 then
					for k in clone do
						if k.DisplayName ~= p2 then
							continue
						end

						v8 = k
						break
					end
				else
					v8 = picker()
				end

				if (p3 == p4 - 1 or p3 == p4 + 1) and math.random(0, 1) == 0 then
					v8 = WeightRandom.getPicker(clone, 100000)()
				end

				if v8.Icon then
					local clone2 = scroller.Parent.ExplosionTemplate.Any:Clone()
					clone2.Size = UDim2.new(0, scroller.AbsoluteSize.X / p, 1, 0)
					clone2.Visible = true
					clone2.Name = v8.DisplayName
					clone2.NameOfExplosion.Text = ""
					clone2.NameOfExplosion.TextColor3 = clone2.NameOfExplosion.TextColor3
					clone2.NameOfExplosion.UIGradient.Color = ColorSequence.new(Color3.new(1, 1, 1))
					clone2.NameOfExplosion.TextStrokeColor3 = clone2.NameOfExplosion.TextStrokeColor3
					clone2.SubText.Text = string.upper(v8.DisplayName)
					clone2.SubText.TextColor3 = clone2.SubText.TextColor3
					clone2.SubText.UIGradient.Color = ColorSequence.new(Color3.new(1, 1, 1))
					clone2.SubText.TextStrokeColor3 = clone2.SubText.TextStrokeColor3
					clone2.ImageLabel.Image = v8.Icon
					return clone2
				else
					local swordData = Utils.SwordUtil:GetSwordData(v8.Value)
					local clone2 = scroller.Parent.SwordTemplate.Unique:Clone()
					clone2.Size = UDim2.new(0, scroller.AbsoluteSize.X / p, 1, 0)
					clone2.Visible = true
					clone2.Transparency = 1
					clone2.BackgroundTransparency = 1
					clone2.NameOfWeapon.Text = v8.DisplayName
					clone2.Name = v8.DisplayName

					if swordData then
						Utils.Icons:SetSwordIconAsViewport(clone2.ViewportFrame, swordData:Clone())
						return clone2
					end

					warn("No icon found for", v8)
					return clone2
				end
			end
		end

		local robuxPresent = DuoPassData.RobuxPresent

		function v7.DuoPassRobuxPresent(p, _)
			local clone = table.clone(robuxPresent)
			local picker = WeightRandom.getPicker(clone)
			return function(p2, p3, p4)
				local function getItemFromList()
					for k in clone do
						if k.DisplayName == p2 then
							return k
						end
					end
				end

				local v8

				if p2 then
					for k in clone do
						if k.DisplayName ~= p2 then
							continue
						end

						v8 = k
						break
					end
				else
					v8 = picker()
				end

				if (p3 == p4 - 1 or p3 == p4 + 1) and math.random(0, 1) == 0 then
					v8 = WeightRandom.getPicker(clone, 100000)()
				end

				if v8.Icon then
					local clone2 = scroller.Parent.ExplosionTemplate.Any:Clone()
					clone2.Size = UDim2.new(0, scroller.AbsoluteSize.X / p, 1, 0)
					clone2.Visible = true
					clone2.Name = v8.DisplayName
					clone2.NameOfExplosion.Text = ""
					clone2.NameOfExplosion.TextColor3 = clone2.NameOfExplosion.TextColor3
					clone2.NameOfExplosion.UIGradient.Color = ColorSequence.new(Color3.new(1, 1, 1))
					clone2.NameOfExplosion.TextStrokeColor3 = clone2.NameOfExplosion.TextStrokeColor3
					clone2.SubText.Text = string.upper(v8.DisplayName)
					clone2.SubText.TextColor3 = clone2.SubText.TextColor3
					clone2.SubText.UIGradient.Color = ColorSequence.new(Color3.new(1, 1, 1))
					clone2.SubText.TextStrokeColor3 = clone2.SubText.TextStrokeColor3
					clone2.ImageLabel.Image = v8.Icon
					return clone2
				else
					local swordData = Utils.SwordUtil:GetSwordData(v8.Value)
					local clone2 = scroller.Parent.SwordTemplate.Unique:Clone()
					clone2.Size = UDim2.new(0, scroller.AbsoluteSize.X / p, 1, 0)
					clone2.Visible = true
					clone2.Transparency = 1
					clone2.BackgroundTransparency = 1
					clone2.NameOfWeapon.Text = v8.DisplayName
					clone2.Name = v8.DisplayName

					if swordData then
						Utils.Icons:SetSwordIconAsViewport(clone2.ViewportFrame, swordData:Clone())
						return clone2
					end

					warn("No icon found for", v8)
					return clone2
				end
			end
		end

		v7.CyberSword = v7.Sword
		v7.DungeonSword = v7.Sword
		local maid2 = Utils.Maid.new()
		local v8 = 0
		local thread = nil

		local function AnimateBox(p, emoteName, backgroundColor, p2, p3, p4)
			if flag then
				return
			end

			if thread then
				pcall(coroutine.close, thread)
				thread = nil
			end

			local now = os.clock()
			v8 = now
			thread = task.delay(10, function()
				unboxGui.Visible = false

				if now == v8 then
					thread = nil
				end
			end)
			flag = true
			local v9 = math.random(60, 60)
			local v10 = math.random(6, 6)
			local v11 = not p4 and (v6 or OwnsGamePass.ownsGamePass("FastUnbox") or _G.fast or (v:Get({
				"Boosts",
				"InstantSpin"
			}) or 0) > 0) and 0.5 or v10
			local visible = (v:Get("Credits") or 0) >= 50000
			local v13 = auto

			if v5 or visible then
				visible = false
			end

			v13.Visible = visible
			skip.Visible = not OwnsGamePass.ownsGamePass("FastUnbox") and (v:Get("TotalStats.Wins") or 0) >= 1
			unboxGui.BackgroundColor3 = backgroundColor
			unboxGui.UnboxSecret.ImageTransparency = 1
			unboxGui.UnboxSecret.Size = UDim2.fromScale(2, 2)
			unboxGui.Fade.ImageColor3 = Color3.new(1, 1, 1)
			local uIGradient = unboxGui.Unlocked:FindFirstChild("UIGradient")

			if uIGradient then
				uIGradient.Enabled = true
			else
				warn("Failed to find Unlocked.UIGradient")
			end

			if p4 then
				task.spawn(function()
					TweenService:Create(
						unboxGui.UnboxSecret,
						TweenInfo.new(0.6, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0),
						{
							ImageTransparency = 0,
							Size = UDim2.fromScale(1, 1)
						}
					):Play()
					local lastTime = tick()
					local v14 = 0.8
					local v15 = 9

					while tick() - lastTime < v14 do
						local v16 = v15 * (1 - (tick() - lastTime) / 0.8)
						local number = Random.new():NextNumber(-v16, v16)
						local number2 = Random.new():NextNumber(-v16, v16)
						unboxGui.Position = UDim2.new(0.5, number, 0.5, number2)
						task.wait()
					end

					unboxGui.Position = UDim2.new(0.5, 0, 0.5, 0)
				end)
			end

			maid2:Destroy()
			task.spawn(function()
				ReplicatedStorage.Misc.spinwheel.TimePosition = 2
				ReplicatedStorage.Misc.spinwheel:Play()
				task.wait(v11)
				ReplicatedStorage.Misc.spinwheel:Stop()
				ReplicatedStorage.Misc.reward:Play()
			end)
			Utils.Network:Fire("OpeningCase", true)
			local v14 = math.random(v9 - 14, v9 - 7)
			xpcall(function()
				unboxGui.Marker.BackgroundColor3 = Color3.new(1, 1, 1)
			end, warn)
			scroller.Size = UDim2.new(0, v9 * scroller.AbsoluteSize.Y, 1, 0)
			scroller.Position = UDim2.new(0, 0, 0, 0)
			scroller:ClearAllChildren()
			unboxGui.Visible = true
			local v15 = v7[p](v9, p2)
			local v16 = nil

			for i = 1, v9 do
				local v17

				if i == v14 then
					v17 = p3 or emoteName
				else
					v17 = false
				end

				local v18 = v15(v17, i, v14, p3, p4)
				v18.Position = UDim2.new(0, v18.AbsoluteSize.X * (i - 1), 0, 0)
				v18.Parent = scroller

				if v17 then
					v16 = v18
				end
			end

			if not v16 then
				warn("No awardFrame created", p3, emoteName)
				v16 = v15(true, v9, v14, p3, p4)
				v16.Position = UDim2.new(0, v16.AbsoluteSize.X * v9, 0, 0)
				v16.Parent = scroller
			end

			local v17 = not unboxGui:FindFirstChild("Marker") and 0 or unboxGui.Marker.AbsolutePosition.X
			local v18 = math.random(-v16.AbsoluteSize.X / 2, v16.AbsoluteSize.X / 2)
			local v19 = v16.AbsolutePosition.x + v16.AbsoluteSize.X / 2 - v17
			scroller:TweenPosition(UDim2.new(0, -v19 + v18, 0, 0), Enum.EasingDirection.Out, Enum.EasingStyle.Sine, v11)
			ReplicatedStorage.Remotes.Store.ManualUpdate:Fire()
			local child = ReplicatedStorage.Misc.Emotes:FindFirstChild(emoteName)

			if child then
				emoteName = child:GetAttribute("EmoteName")
			end

			unboxGui.Unlocked.Text = `Rolled {p3 and "Secret" or emoteName}`
			task.delay(v11, function()
				skip.Visible = false
				auto.Visible = false
				xpcall(function()
					unboxGui.Marker.BackgroundColor3 = Color3.new(1, 0, 0.0156863)
				end, warn)

				if p3 then
					local tween = TweenService:Create(
						v16,
						TweenInfo.new(0.12, Enum.EasingStyle.Quart, Enum.EasingDirection.Out, 3, true, 0),
						{
							ImageColor3 = Color3.new(1, 1, 1)
						}
					)
					task.defer(function()
						tween:Play()
					end)
					tween.Completed:Wait()
				end

				if p3 or p4 then
					local clone = v16:Clone()
					local v20 = v16.AbsolutePosition.X + v16.AbsoluteSize.X / 2
					local v21 = v16.AbsolutePosition.Y + v16.AbsoluteSize.Y / 2
					Instance.new("UIAspectRatioConstraint", clone)
					clone.AnchorPoint = Vector2.new(0.5, 0.5)
					clone.Size = UDim2.fromOffset(v16.AbsoluteSize.X, v16.AbsoluteSize.Y)
					clone.Position = UDim2.fromOffset(v20, v21)
					clone.ZIndex = 2
					clone.Parent = parent
					local tween = TweenService:Create(
						clone,
						TweenInfo.new(0.8, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0),
						{
							ImageTransparency = 1,
							Size = UDim2.fromScale(0.4, 0.4)
						}
					)

					if p4 then
						if p == "Explosion" then
							TweenService:Create(
								clone.ImageLabel,
								TweenInfo.new(0.8, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0),
								{
									ImageTransparency = 1,
									Size = UDim2.fromScale(1.6, 1.6)
								}
							):Play()
							TweenService:Create(
								clone.NameOfExplosion,
								TweenInfo.new(0.8, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0),
								{
									TextTransparency = 1
								}
							):Play()
							TweenService:Create(
								clone.SubText,
								TweenInfo.new(0.8, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0),
								{
									TextTransparency = 1
								}
							):Play()
						else
							TweenService:Create(
								clone.ViewportFrame,
								TweenInfo.new(0.8, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0),
								{
									ImageTransparency = 1,
									Size = UDim2.fromScale(1.6, 1.6)
								}
							):Play()
							local imageLabel = clone:FindFirstChild("ImageLabel")

							if imageLabel then
								TweenService:Create(
									imageLabel,
									TweenInfo.new(0.8, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0),
									{
										ImageTransparency = 1,
										Size = UDim2.fromScale(1.6, 1.6)
									}
								):Play()
							end

							TweenService:Create(
								clone.NameOfWeapon,
								TweenInfo.new(0.8, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0),
								{
									TextTransparency = 1
								}
							):Play()
						end
					end

					tween:Play()
					tween.Completed:Connect(function()
						clone:Destroy()
					end)
					unboxGui.Fade.ImageColor3 = Color3.new()
					unboxGui.Unlocked.UIGradient.Enabled = false
				end

				unboxGui.Fade.Visible = true
				unboxGui.Unlocked.Visible = true
				task.wait(p3 and 0.3 or 1.25)
				unboxGui.Fade.Visible = false
				unboxGui.Unlocked.Visible = false
				remoteEvent:FireServer()
				Utils.Network:Fire("OpeningCase", false)
				crateFinished:Fire(p2)

				if not p3 then
					unboxGui.Visible = false
				end

				flag = false
				local v20 = nil

				for _, v21 in CollectionService:GetTagged("CrateBinder") do
					if v21.Name == p2 then
						v20 = v21
					end
				end

				if v4 and v20 then
					local _ = (v20:GetAttribute("Price") or 0) <= (v:Get("Credits") or 0)
					v4 = false
					v5 = false

					if v4 then
						Utils.Network:Invoke("PromptPurchaseCrate", v20)
					else
						auto.Label.Text = (v4 or v5) and "STOP" or "AUTO"
					end
				end
			end)
			return v11 + 1.25
		end

		maid.OpenCrateEvent = openCrate.OnClientEvent:Connect(function(p, p2, p3, p4, p5)
			local _currentGui = GuiHandler._currentGui
			local name

			if _currentGui and _currentGui.Name == "DuoPassMenu" then
				name = _currentGui.Name
				GuiHandler:Close(name)
			end

			local animateBox = AnimateBox(p, p2, Color3.fromRGB(45, 44, 48), p3, p4, p5)

			if type(animateBox) == "number" then
				task.wait(animateBox)
			end

			if name and not GuiHandler._currentGui then
				GuiHandler:Open(name)
			end
		end)
		maid.SkipPrompted = skip.Activated:Connect(function()
			MarketplaceService:PromptGamePassPurchase(localPlayer, 229765926)
		end)
		maid.AutoToggle = auto.Activated:Connect(function()
			v4 = not v4
			v5 = not v5
			auto.Label.Text = (v4 or v5) and "STOP" or "AUTO"
		end)
		maid.OnGamepassChanged = v:OnChange("GamePasses", function()
			skip.Visible = not OwnsGamePass.ownsGamePass("FastUnbox") and (v:Get("TotalStats.Wins") or 0) >= 1
		end)
		maid.OnWinsChanged = v:OnChange("Wins", function()
			skip.Visible = not OwnsGamePass.ownsGamePass("FastUnbox") and (v:Get("TotalStats.Wins") or 0) >= 1
		end)

		local function ToOdds(p)
			return string.format("%.2f", p * 100):gsub("%.?0+$", "")
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function updateOdds(p)
			local text, normalOdds

			if p.Parent.Parent.Parent.Name == "PremiumRates" then
				local premiumOdds = SecretAwakenData.PremiumOdds
				text = `??? - {string.format("%.2f", premiumOdds * 100):gsub("%.?0+$", "")}%`

				if not text then
					normalOdds = SecretAwakenData.NormalOdds
					text = `??? - {string.format("%.2f", normalOdds * 100):gsub("%.?0+$", "")}%`
				end
			else
				normalOdds = SecretAwakenData.NormalOdds
				text = `??? - {string.format("%.2f", normalOdds * 100):gsub("%.?0+$", "")}%`
			end

			p.Text = text
		end

		CollectionService:GetInstanceAddedSignal("SecretOdds_Default"):Connect(updateOdds)

		for _, v9 in CollectionService:GetTagged("SecretOdds_Default") do
			updateOdds(v9) -- equivalent call inferred; original call site unknown
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function updateOddsNEW(instance)
			local text, normalOdds

			if instance:GetAttribute("Premium") then
				local premiumOdds = SecretAwakenData.PremiumOdds
				text = `??? - {string.format("%.2f", premiumOdds * 100):gsub("%.?0+$", "")}%`

				if not text then
					normalOdds = SecretAwakenData.NormalOdds
					text = `??? - {string.format("%.2f", normalOdds * 100):gsub("%.?0+$", "")}%`
				end
			else
				normalOdds = SecretAwakenData.NormalOdds
				text = `??? - {string.format("%.2f", normalOdds * 100):gsub("%.?0+$", "")}%`
			end

			instance.Text = text
			instance.Label.Text = instance.Text
		end

		CollectionService:GetInstanceAddedSignal("SecretOdds_New"):Connect(updateOddsNEW)

		for _, v9 in CollectionService:GetTagged("SecretOdds_New") do
			updateOddsNEW(v9) -- equivalent call inferred; original call site unknown
		end

		return maid
	end
}