local ProximityPromptService = game:GetService("ProximityPromptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Utils = require(ReplicatedStorage.Common.Utils)
local MarketplaceService = require(ReplicatedStorage.Common.MarketplaceService)
local SecretAwakenData = require(ReplicatedStorage.Shared.SecretAwakenData)
local CratesContent = require(ReplicatedStorage.Common.CratesContent)
local Replion = require(ReplicatedStorage.Packages.Replion)
local Inventory = require(ReplicatedStorage.Shared.Inventory)
local client = Inventory.Client
local Policy = require(ReplicatedStorage.Shared.Policy)
local AutoDeleteItemController = require(ReplicatedStorage.Controllers.AutoDeleteItemController)
local AutoDeleteContainers = require(ReplicatedStorage.Shared.AutoDeleteContainers)
local GenericCrateData = require(ReplicatedStorage.Shared.GenericCrateData)
local GenericCrateAnimationController = require(ReplicatedStorage.Controllers.GenericCrateAnimationController)
local NotificationController = require(ReplicatedStorage.Controllers.NotificationController)
local ItemInfo = require(ReplicatedStorage.Shared.ItemInfo)
local CrateBinder = {}
local crateOdds = assert(Players.LocalPlayer).PlayerGui.CrateOdds
local items = crateOdds.Holder.Odds.Items
local template = items.UIGridLayout.Template
template.Visible = false
local v = {
	Swords = "Sword",
	Explosions = "Explosion",
	Emotes = "Emote",
	Abilities = "Ability"
}

local function FormatOddsChance(chance: number)
	if chance >= 10 then
		return string.format("%d%%", (math.floor(chance + 0.5)))
	end

	if chance >= 1 then
		return string.format("%.1f%%", chance)
	end

	if chance >= 0.01 then
		return string.format("%.2f%%", chance)
	end

	return string.format("%.3f%%", chance)
end

local function GetOddsDisplay(k: string, p: string, icon: string?)
	local v2 = v[k]
	local v3 = v2 and ItemInfo[v2] and ItemInfo[v2][p]

	if v3 then
		return v3.DisplayName or p, v3.Icon or icon or Utils.Icons:GetIcon("DEFAULT_MISSING")
	end

	if k == "Swords" then
		return p, icon or Utils.Icons:GetSwordIcon(p)
	elseif k == "Explosions" then
		return p, icon or Utils.Icons:GetExplosionIcon(p)
	elseif k == "Emotes" then
		return p, icon or Utils.Icons:GetEmoteIcon(p)
	elseif k == "Abilities" then
		return p, icon or Utils.Icons:GetAbilityIcon(p)
	end

	return p, icon or Utils.Icons:GetIcon("DEFAULT_MISSING")
end

local v2 = {
	NormalSwordCrate = "SecretSwordCrate",
	PremiumSwordCrate = "SecretSwordCrate",
	CyberSwordCrate = "CyberSecretSwordCrate",
	DungeonSwordCrate = "DungeonSecretSwordCrate",
	NormalExplosionCrate = "SecretExplosionCrate",
	PremiumExplosionCrate = "SecretExplosionCrate"
}

-- equivalent calls inferred from this helper; original call sites unknown
local function SortOddsEntries(list)
	table.sort(list, function(a, b)
		if a.Chance == b.Chance then
			return a.DisplayName < b.DisplayName
		end

		return a.Chance > b.Chance
	end)
end

local function BuildCrateOddsEntries(items2, value: number?)
	local result = {}
	local lootboxMaxChance = Utils.ValueConvertor:GetLootboxMaxChance(items2)

	if lootboxMaxChance <= 0 then
		return result
	end

	local v3 = value or 1

	for _, item in items2 do
		local lootbox = item.Item and item.Item.Lootbox

		if not lootbox then
			continue
		end

		local lootboxMaxChance2 = Utils.ValueConvertor:GetLootboxMaxChance(lootbox)

		if lootboxMaxChance2 <= 0 then
			continue
		end

		local v4 = (item.Chance or 0) / lootboxMaxChance

		for _, v5 in lootbox do
			if not v5.Item or not v5.Chance or v5.Chance <= 0 then
				continue
			end

			local chance = v4 * (v5.Chance / lootboxMaxChance2) * 100 * v3

			for k, v7 in v5.Item do
				for _, name in v7 do
					local displayName, icon = GetOddsDisplay(k, name, item.Icon)
					table.insert(result, {
						Name = name,
						DisplayName = displayName,
						Icon = icon,
						Chance = chance
					})
				end
			end
		end
	end

	return result
end

local function BuildOddsEntriesForCrate(name: string)
	local v3 = CratesContent[name]

	if not v3 then
		return nil
	end

	local v4 = v2[name]
	local v5 = v4 and CratesContent[v4]
	local v6 = not v5 and 0 or SecretAwakenData.GetSecretRate(name)
	local result = BuildCrateOddsEntries(v3, 1 - v6)

	if v5 and v6 > 0 then
		for _, v7 in BuildCrateOddsEntries(v5, v6) do
			table.insert(result, v7)
		end
	end

	SortOddsEntries(result) -- equivalent call inferred; original call site unknown
	return result
end

local function BuildGenericCrateOddsEntries()
	local total = 0
	local result = {}

	for _, reward in GenericCrateData.Rewards do
		total += reward.Chance
	end

	if total <= 0 then
		return result
	end

	for _, reward in GenericCrateData.Rewards do
		table.insert(result, {
			Name = reward.Reward.Value,
			DisplayName = reward.Reward.DisplayName or tostring(reward.Reward.Value),
			Icon = reward.Reward.Icon or Utils.Icons:GetIcon("DEFAULT_MISSING"),
			Chance = reward.Chance / total * 100
		})
	end

	table.sort(result, function(a, b)
		return a.Chance > b.Chance
	end)
	return result
end

local function GetPooledOddsFrames()
	local images = {}

	for _, image in items:GetChildren() do
		if image:IsA("ImageLabel") then
			table.insert(images, image)
		end
	end

	return images
end

local function PopulateOddsFrames(list)
	local pooledOddsFrames = GetPooledOddsFrames()

	for k, v4 in list do
		local clone = pooledOddsFrames[k]

		if not clone then
			clone = template:Clone()
			clone.Parent = items
		end

		clone.Name = v4.Name
		clone.Visible = true
		clone.Vector.Image = v4.Icon
		local itemName = clone:FindFirstChild("ItemName")
		local percent = clone:FindFirstChild("Percent")

		if itemName and itemName:IsA("TextLabel") then
			itemName.Text = v4.DisplayName
		end

		if percent and percent:IsA("TextLabel") then
			percent.Text = FormatOddsChance(v4.Chance)
		end
	end

	for i = #list + 1, #pooledOddsFrames do
		pooledOddsFrames[i]:Destroy()
	end
end

local v3 = {
	NormalExplosionCrate = "Explosion",
	PremiumExplosionCrate = "PremiumExplosion",
	NormalSwordCrate = "Sword",
	PremiumSwordCrate = "PremiumSword",
	HalloweenSwordCrate = "Sword",
	LunarSwordCrate = "Sword",
	DungeonSwordCrate = "DungeonSword"
}

function CountItems(items2, _, p)
	local total = 0
	local count = 0

	for _, item in items2 do
		for _, v4 in item.Item.Lootbox do
			if not (v4.Item and v4.Chance > 0) then
				continue
			end

			for _, v5 in v4.Item do
				total += #v5

				for _, v6 in v5 do
					local v7 = SecretAwakenData[v6]

					if v7 then
						if #client:FindItems(p, v7.Awakened.Value) > 0 then
							count += 1
						end
					elseif #client:FindItems(p, v6) > 0 then
						count += 1
					end
				end
			end
		end
	end

	return count, total
end

function CrateBinder.Binder(instance)
	local maid = Utils.Maid.new()
	Replion.Client:AwaitReplion("Data", function(object)
		local crateKeys = instance:WaitForChild("CrateKeys", 5)

		if not crateKeys then
			warn("Failed to load Crate", instance:GetFullName())
			return
		end

		local v4 = v3[instance.Name]
		local v5 = { "CrateKeys", v4 }
		crateKeys.TextLabel.Visible = false
		crateKeys.Adornee = instance.PrimaryPart
		crateKeys.Size = UDim2.fromScale(10, 1)
		crateKeys.Enabled = true
		local clone = script.ItemsOwned:Clone()
		local clone2 = script.KeysAvailable:Clone()
		clone.Parent = crateKeys
		clone2.Parent = crateKeys

		local function UpdateObtained()
			local v6 = CratesContent[instance.Name]

			if v6 then
				local clone3 = table.clone(v6)
				local v7 = v2[instance.Name]

				if v7 then
					local v8 = CratesContent[v7]

					if v8 then
						for _, v9 in v8 do
							table.insert(clone3, v9)
						end
					end
				end

				local function Update(p)
					local text, v9 = CountItems(clone3, object, p)
					local _ = v9 <= text
					clone.Visible = math.ceil(v9 * 0.1) <= text
					clone.Text = `/{v9} OWNED`
					clone.ItemsOwned.Text = text
					local v10 = clone
					local textColor

					if v9 <= text then
						textColor = Color3.new(0, 1, 0)
					else
						textColor = Color3.new(1, 1, 1)
					end

					v10.TextColor3 = textColor
				end

				if string.find(instance.Name, "Sword") then
					Update("Sword")
				elseif string.find(instance.Name, "Explosion") then
					Update("Explosion")
				end
			elseif instance:GetAttribute("CrateType") == "GenericCrate" then
				local count = #GenericCrateData.Rewards
				local count2 = 0

				for _, reward in GenericCrateData.Rewards do
					if reward.Reward.Type == "Title" and object:Get({ "Titles", reward.Reward.Value }) then
						count2 += 1
					elseif #client:FindItems(reward.Reward.Type, reward.Reward.Value) > 0 then
						count2 += 1
					end
				end

				local _ = count <= count2
				clone.Visible = GenericCrateData.ShowLegacyExistCounts and math.ceil(count * 0.1) <= count2
				clone.Text = `/{count} OWNED`
				clone.ItemsOwned.Text = count2
				local v7 = clone
				local textColor

				if count <= count2 then
					textColor = Color3.new(0, 1, 0)
				else
					textColor = Color3.new(1, 1, 1)
				end

				v7.TextColor3 = textColor
			end
		end

		local function UpdateKeys(p)
			if v4 and p and p > 0 then
				crateKeys.Enabled = true
				crateKeys.TextLabel.Text = "OPEN " .. p .. " FREE!"
				clone2.Text = `OPEN {p}`
				clone2.Visible = true

				if clone.Visible then
					clone.Position = script.ItemsOwned.Position
					clone.AnchorPoint = script.ItemsOwned.AnchorPoint
					clone2.Position = UDim2.new(0, 0, 0, 0)
					clone2.AnchorPoint = Vector2.new(0, 0)
				else
					clone2.Position = UDim2.new(0.5, 0, 0, 0)
					clone2.AnchorPoint = Vector2.new(0.5, 0)
				end
			else
				crateKeys.Enabled = false
				clone2.Visible = false
				clone.Position = UDim2.new(0.5, 0, 0, 0)
				clone.AnchorPoint = Vector2.new(0.5, 0)
			end
		end

		maid.OnSwordUnlockedChanged = client:OnChange("Sword", UpdateObtained)
		maid.OnExplosionUnlockedChanged = client:OnChange("Explosion", UpdateObtained)
		maid.OnTitlesUnlockedChanged = object:OnChange("Titles", UpdateObtained)
		maid.OnKeysChanged = object:OnChange(v5, UpdateKeys)
		UpdateObtained()
		UpdateKeys(object:Get(v5))
		local proximityPromptSyncObject = Utils.Streamer:Sync(instance, "Lock", "ProximityPrompt")
		maid.ProximityPromptSyncObject = proximityPromptSyncObject
		maid.ProximityPromptSyncObjectLoaded = proximityPromptSyncObject.Loaded:Connect(function(instance2)
			local function UpdatePrice()
				local price = instance:GetAttribute("Price")

				if price then
					local currencyIcon = instance:GetAttribute("CurrencyIcon")

					if currencyIcon then
						instance2:SetAttribute("CurrencyIcon", currencyIcon)
					end

					instance2.ActionText = `Purchase {price}`
				else
					local productId = instance:GetAttribute("ProductId")

					if not productId then
						return
					end

					maid.UpdatePrice = Utils.Thread.Every(300, function()
						pcall(function()
							instance2.ActionText = ("Purchase %d"):format(MarketplaceService:GetProductInfo(
								productId,
								Enum.InfoType.Product
							).PriceInRobux)
						end)
					end)
				end
			end

			UpdatePrice()
			maid.OnPriceChanged = instance:GetAttributeChangedSignal("Price"):Connect(UpdatePrice)
			maid.OnProductIdChanged = instance:GetAttributeChangedSignal("ProductId"):Connect(UpdatePrice)
			maid.PromptPurchase = instance2.Triggered:Connect(function(_)
				local v7 = object:Get(v5) or 0
				local policyInfo = Policy:GetPolicyInfo()

				if policyInfo and policyInfo.ArePaidRandomItemsRestricted and typeof(v7) == "number" and v7 <= 0 then
					Utils.Sounds:Play("error")
					NotificationController:SendNotification("Unavailable in your region")
				else
					if instance2:GetAttribute("Disabled") then
						return
					end

					if instance:GetAttribute("CrateType") == "GenericCrate" then
						ProximityPromptService.Enabled = false
						xpcall(function()
							GenericCrateAnimationController:Open()
						end, warn)
						ProximityPromptService.Enabled = true
					else
						ProximityPromptService.Enabled = false
						local v8 = Utils.Network:Invoke("PromptPurchaseCrate", instance)

						if v8 and v8.state then
							local total = 0

							if not instance:GetAttribute("ProductId") then
								if Replion.Client:WaitReplion("Data"):Find("GamePasses", "FastUnbox") ~= nil then
									total += 1.8
								else
									total += 6.2
								end
							end

							if v8 and v8.isSecret then
								total += 7.5
							end

							task.delay(total, function()
								ProximityPromptService.Enabled = true
							end)
						else
							ProximityPromptService.Enabled = true
							Utils.Sounds:Play("error")
						end
					end
				end
			end)

			if not AutoDeleteContainers[instance.Name] then
				return
			end

			local v7 = true
			maid:GiveTask(function()
				v7 = false
			end)
			local autoDelete = instance:WaitForChild("Lock"):WaitForChild("AutoDelete")

			if not v7 then
				return
			end

			maid:GiveTask(autoDelete.Triggered:Connect(function(_)
				AutoDeleteItemController:Prompt(instance.Name)
			end))

			-- equivalent calls inferred from this helper; original call sites unknown
			local function UpdateAutoDeletePrompt()
				autoDelete.Enabled = instance2.Enabled and not instance2:GetAttribute("Disabled") and object:Get("AutoDelete.Unlocked")
			end

			maid:GiveTask(instance2:GetPropertyChangedSignal("Enabled"):Connect(UpdateAutoDeletePrompt))
			maid:GiveTask(instance2:GetAttributeChangedSignal("Disabled"):Connect(UpdateAutoDeletePrompt))
			maid:GiveTask(object:OnChange("AutoDelete.Unlocked", UpdateAutoDeletePrompt))
			UpdateAutoDeletePrompt() -- equivalent call inferred; original call site unknown
		end)
		local oddsPromptSyncObject = Utils.Streamer:Sync(instance, "Lock", "OddsPrompt")
		maid.OddsPromptSyncObject = oddsPromptSyncObject
		maid.OddsPromptSyncObjectLoaded = oddsPromptSyncObject.Loaded:Connect(function(p)
			local function CloseOdds()
				if crateOdds:GetAttribute("__showing") ~= instance.Name then
					return
				end

				maid.CloseOdds = nil
				crateOdds.Enabled = false
			end

			maid.HideOdds = p.PromptHidden:Connect(CloseOdds)
			maid.PromptOdds = p.Triggered:Connect(function()
				local v8 = crateOdds:GetAttribute("__showing") ~= instance.Name
				crateOdds.Enabled = true
				maid.CloseOdds = crateOdds.Holder.CloseButton.Activated:Connect(CloseOdds)

				if not v8 then
					return
				end

				crateOdds:SetAttribute("__showing", instance.Name)
				local v9

				if instance:GetAttribute("CrateType") == "GenericCrate" then
					v9 = BuildGenericCrateOddsEntries()
				else
					v9 = BuildOddsEntriesForCrate(instance.Name)

					if not v9 then
						warn("Failed to load crate odds for", instance.Name)
						return
					end
				end

				PopulateOddsFrames(v9)
			end)
		end)
	end)
	return maid
end

return CrateBinder