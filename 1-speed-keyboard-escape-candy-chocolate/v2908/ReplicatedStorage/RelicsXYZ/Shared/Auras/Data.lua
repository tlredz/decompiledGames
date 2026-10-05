local parent = script.Parent.Parent
local Players = game:GetService("Players")
local Attachments = require(parent.Attachments)
local Marketplace = require(parent.Marketplace)
local GamePasses = require(parent.GamePasses)
local RunContext = require(parent.RunContext)
local PlayerData = require(parent.PlayerData)
local Migration = require(parent.Migration)
local Ownership = require(parent.Ownership)
local Signal = require(parent.Signal)
local Trove = require(parent.Trove)
local Tags = require(parent.Tags)
local v = {}
local v2 = {}
local v3 = {}
local auraAdded = Signal.new()
local auraRemoved = Signal.new()

local function getAuras()
	return table.clone(v)
end

local function findAura(value: string)
	return v2[value:lower()]
end

Tags.BindWithMaid("RelicsAura", function(instance, maid)
	if not (instance:IsA("Folder") or instance:IsA("Model")) then
		return
	end

	task.wait()

	if type(instance:GetAttribute("LimitedInfo")) ~= "string" then
		return
	end

	local name = instance.Name
	local auraId = instance:GetAttribute("AuraId")

	if auraId then
		instance.Name = tostring(auraId)
		name = instance.Name
	end

	if v[name] then
		local limitedInfo = instance:GetAttribute("LimitedInfo")
		local gamePass = tonumber(instance:GetAttribute("GamePass"))

		if type(limitedInfo) == "string" and type(gamePass) == "number" and gamePass > 0 then
			local v6 = v[name]

			if v6.GamePass ~= gamePass then
				v6.GamePass = gamePass
				v6.LimitedInfo = limitedInfo
				v6.Changed:Fire("GamePass")
			end
		end

		warn("Aura with name", name, "already exists.")
	else
		local function setupAura(part)
			if not part:IsA("BasePart") then
				warn("Aura with name", name, "has an Aura child but it's not a BasePart, it's a", part.ClassName)
				return
			end

			local chance = tonumber(instance:GetAttribute("Chance")) or 0
			local gamePass = tonumber(instance:GetAttribute("GamePass"))
			local assetId = tonumber(instance:GetAttribute("AssetId"))
			local productType = instance:GetAttribute("ProductType") or instance:GetAttribute("InfoType")
			local productId = tonumber(instance:GetAttribute("ProductId"))
			local zoomScale = tonumber(instance:GetAttribute("ZoomScale")) or 1
			local effectImage = instance:GetAttribute("EffectImage")
			local limitedInfo = instance:GetAttribute("LimitedInfo")
			local image = instance:GetAttribute("Image")
			local image2 = image == nil and "" or tostring(image)
			local headerImage = instance:GetAttribute("HeaderImage")
			local titleColor = instance:GetAttribute("TitleColor")
			local legacyIds = instance:GetAttribute("LegacyIds")

			if not productId then
				if assetId then
					productType = Enum.InfoType.Asset
					productId = assetId
				elseif gamePass then
					productType = Enum.InfoType.GamePass
					productId = gamePass
				end
			end

			local legacyIds3 = nil
			local changed = Signal.new()
			local lower = name:lower()

			if type(legacyIds) == "string" or type(legacyIds) == "number" then
				local legacyIds2 = Migration.ParseLegacyIds(legacyIds)

				if #legacyIds2 > 0 then
					legacyIds3 = legacyIds2
				end
			end

			if Attachments.FindFirstCharacterAttachment(part) == nil then
				local attachment = Instance.new("Attachment")
				attachment.Name = "RootAttachment"
				attachment.Parent = part
			end

			local v9 = {
				Name = name,
				Chance = chance,
				ProductId = productId or 0,
				ProductType = 0,
				AssetId = 0,
				GamePass = 0,
				LegacyIds = 0,
				Image = 0,
				TitleColor = 0,
				EffectImage = 0,
				HeaderImage = 0,
				LimitedInfo = 0,
				ZoomScale = 0,
				Effect = 0,
				Changed = 0
			}

			if typeof(productType) ~= "EnumItem" or not productType:IsA("InfoType") then
				productType = Enum.InfoType.GamePass
			end

			v9.ProductType = productType
			v9.AssetId = assetId
			v9.GamePass = gamePass
			v9.LegacyIds = legacyIds3
			v9.Image = image2

			if typeof(titleColor) ~= "Color3" then
				titleColor = Color3.fromHex("#ffffff")
			end

			v9.TitleColor = titleColor

			if type(effectImage) ~= "string" then
				effectImage = nil
			end

			v9.EffectImage = effectImage

			if type(headerImage) ~= "string" then
				headerImage = nil
			end

			v9.HeaderImage = headerImage

			if type(limitedInfo) ~= "string" then
				limitedInfo = nil
			end

			v9.LimitedInfo = limitedInfo
			v9.ZoomScale = zoomScale
			v9.Effect = part
			v9.Changed = changed
			maid:Connect(instance.AttributeChanged, function(attributeName)
				local attribute = instance:GetAttribute(attributeName)

				if typeof(attribute) == typeof(v9[attributeName]) then
					v9[attributeName] = attribute
					changed:Fire(attributeName)
				elseif attribute == nil and (attributeName == "EffectImage" or attributeName == "HeaderImage") then
					v9[attributeName] = nil
					changed:Fire(attributeName)
				end
			end)
			maid:Add(function()
				auraRemoved:Fire(name, v9)
				changed:DisconnectAll()
				v2[lower] = nil
				v[name] = nil
			end)
			v[name] = v9
			v2[lower] = v9
			auraAdded:Fire(name, v9)
		end

		local basePart = instance:FindFirstChildWhichIsA("BasePart")

		if basePart then
			setupAura(basePart)
		else
			local connection = nil
			connection = maid:Connect(instance.ChildAdded, function(part)
				if part:IsA("BasePart") then
					if connection then
						connection:Disconnect()
					end

					setupAura(part)
				end
			end)
		end
	end
end)

if RunContext.IsServer or RunContext.IsEdit then
	local _relicsAuraContentMaid = shared._relicsAuraContentMaid

	if _relicsAuraContentMaid then
		_relicsAuraContentMaid:Clean()
	end

	shared._relicsAuraContentMaid = Tags.BindWithMaid(GamePasses.ContentTag, function(part, object)
		local gamePass = GamePasses.FindGamePassFromContent(part)

		if not gamePass or gamePass.RelicsAssetType ~= "AURA" then
			return
		end

		local name = gamePass.Name:gsub(" [Aa][Uu][Rr][Aa]", "")

		if part:IsA("BasePart") then
			local folder = Instance.new("Folder")
			folder.Name = name
			folder:SetAttribute("Chance", 0)
			folder:SetAttribute("TitleColor", part.Color)
			folder:SetAttribute("EffectImage", gamePass.ItemImageAssetId)
			folder:SetAttribute("Image", gamePass.BackgroundImageAssetId)
			folder:SetAttribute("HeaderImage", gamePass.BrandImageAssetId)
			folder:SetAttribute("ProductType", gamePass.ProductType)
			folder:SetAttribute("ProductId", gamePass.ProductId)
			folder:SetAttribute("LimitedInfo", gamePass.Id)

			if gamePass.LegacyIds and #gamePass.LegacyIds > 0 then
				local v7 = {}

				for _, legacyId in gamePass.LegacyIds do
					table.insert(v7, (`{legacyId.Id}:{legacyId.InfoType.Name}`))
				end

				folder:SetAttribute("LegacyIds", table.concat(v7, ","))
			end

			local parent2 = part.Parent
			part.Name = "Aura"
			part.Parent = folder
			folder.Parent = parent2
			folder:AddTag("RelicsAura")
			object:Add(folder)
		elseif part:FindFirstChildWhichIsA("BasePart") then
			part.Name = name
			part:SetAttribute("LimitedInfo", gamePass.Id)
			part:SetAttribute("ProductId", gamePass.ProductId)
			part:SetAttribute("ProductType", gamePass.ProductType)

			if gamePass.LegacyIds and #gamePass.LegacyIds > 0 then
				local v7 = {}

				for _, legacyId in gamePass.LegacyIds do
					table.insert(v7, (`{legacyId.Id}:{legacyId.InfoType.Name}`))
				end

				part:SetAttribute("LegacyIds", table.concat(v7, ","))
			else
				part:SetAttribute("LegacyIds", nil)
			end

			if gamePass.BrandImageAssetId then
				part:SetAttribute("BrandImage", gamePass.BrandImageAssetId)
			end

			if gamePass.ItemImageAssetId then
				part:SetAttribute("EffectImage", gamePass.ItemImageAssetId)
			end

			if gamePass.BackgroundImageAssetId then
				part:SetAttribute("HeaderImage", gamePass.BackgroundImageAssetId)
			end

			part:AddTag("RelicsAura")
		end
	end)

	local function onPlayerAdded(p)
		local userId = p.UserId
		local v6 = Trove.new()
		v3[p] = v6

		local function checkAuraOwnership(p2: string, p3, object, _: number?)
			local playerByUserId = Players:GetPlayerByUserId(userId)

			if not playerByUserId then
				return
			end

			local v7 = Ownership.Get(p3)

			if #v7 == 0 then
				return
			end

			Marketplace.BulkResolveOwnership(playerByUserId, v7):andThen(function(list)
				local currentData = object.CurrentData
				local v8 = false

				for _, v10 in ipairs(list) do
					if not v10 then
						continue
					end

					v8 = true
					break
				end

				if currentData.Auras.Aura ~= p2 and not v8 then
					return
				end

				if not currentData.Auras.Unlocks[p2] then
					object:Patch(function(p4)
						p4.Auras.Unlocks[p2] = true
					end)
				end
			end)
		end

		PlayerData.Load(userId):andThen(function(p2)
			if not Players:GetPlayerByUserId(userId) then
				return
			end

			local function onAuraAdded(p3: string, p4)
				checkAuraOwnership(p3, p4, p2)
				v6:Connect(p4.Changed, function(p5)
					if p5 ~= "GamePass" then
						return
					end

					checkAuraOwnership(p3, p4, p2)
				end)
			end

			for k, v7 in v do
				task.spawn(onAuraAdded, k, v7)
			end

			v6:Connect(auraAdded, onAuraAdded)
		end)
	end

	Players.PlayerRemoving:Connect(function(player)
		local v6 = v3[player]

		if v6 then
			v6:Clean()
			v3[player] = nil
		end
	end)
	Marketplace.PromptPurchaseFinished:Connect(function(p, p2: number, p3)
		local v6 = PlayerData.Get(p.UserId)

		if not v6.IsLoaded then
			return
		end

		for k, v7 in v do
			local flag = false

			for _, v9 in Ownership.Get(v7) do
				if not (v9.Id == p2 and v9.InfoType == p3) then
					continue
				end

				flag = true
				break
			end

			if not flag then
				continue
			end

			local v9 = k
			v6:Patch(function(p4)
				p4.Auras.Unlocks[v9] = true
			end)
		end
	end)

	for _, v6 in Players:GetPlayers() do
		task.spawn(onPlayerAdded, v6)
	end

	Players.PlayerAdded:Connect(onPlayerAdded)
end

return table.freeze({
	FindAura = findAura,
	GetAuras = getAuras,
	AuraAdded = auraAdded,
	AuraRemoved = auraRemoved
})