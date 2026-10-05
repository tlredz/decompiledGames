local HttpService = game:GetService("HttpService")
local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ServerScriptService = game:GetService("ServerScriptService")
local AdminRemote = require(ReplicatedStorage._FRAMEWORK.Features.Admins.AdminRemote)
local CUI = require(ReplicatedStorage.CUI)
local GiftConfig = require(ReplicatedStorage.FeatureConfigs.GiftConfig)
local Items = require(ReplicatedStorage.FeatureConfigs.Items)
local KnownUsers = require(ReplicatedStorage.Cmdr.Menus.AdminMenu.KnownUsers)
local ProfileAccess = require(script.Parent.Parent.ProfileAccess)
require(ReplicatedStorage.Cmdr.Menus.InspectMenu.Types)
local DataManager = RunService:IsServer() and require(ServerScriptService.DataManager)
local v = {
	"Treadmill",
	"Trail",
	"Aura",
	"Item",
	"Skin",
	"SkinBundle"
}
local v2 = {}
local v3 = {}
local v4 = {}

for _, v5 in v do
	v2[v5] = {}
	v3[v5] = {}
end

for k, v5 in GiftConfig.ALL_GIFTS do
	local category = tostring(v5.Category or "Treadmill")

	if not v2[category] then
		continue
	end

	local name = tostring(v5.Name or k)
	local v6

	if name == k then
		v6 = k
	else
		v6 = `{name} ({k})`
	end

	table.insert(v2[category], v6)
	v3[category][v6] = k
end

for _, list in v2 do
	table.sort(list)
end

local function FormatUnknown(value)
	if type(value) == "string" then
		return value
	end

	local success, result = pcall(HttpService.JSONEncode, HttpService, value)

	if success then
		return result
	end

	return (tostring(value))
end

local function NormalizePurchases(purchaseHistory)
	local result = {}

	if type(purchaseHistory) ~= "table" then
		return result
	end

	for _, item in purchaseHistory do
		local result2

		if type(item) == "string" then
			result2 = item
		else
			local success
			success, result2 = pcall(HttpService.JSONEncode, HttpService, item)

			if not success then
				result2 = tostring(item)
			end
		end

		table.insert(result, result2)
	end

	return result
end

local function NormalizeGifts(items, flag: boolean)
	local result = {}

	if type(items) ~= "table" then
		return result
	end

	for _, item in items do
		if type(item) == "table" then
			local v5 = {
				GiftType = tostring(item.Gift or "Unknown"),
				GiftName = tostring(item.GiftName or item.Gift or "Unknown gift"),
				OtherUserId = 0,
				OtherName = 0,
				Timestamp = 0,
				Claimed = 0,
				ItemTier = 0
			}
			local v6

			if flag then
				v6 = item.TargetUserId
			else
				v6 = item.SenderUserId
			end

			v5.OtherUserId = tonumber(v6) or 0
			local v7

			if flag then
				v7 = item.TargetName
			else
				v7 = item.SenderName
			end

			v5.OtherName = tostring(v7 or "Unknown player")
			v5.Timestamp = tonumber(item.Timestamp) or 0
			local claimed

			if not flag then
				claimed = item.Claimed == true
			end

			v5.Claimed = claimed
			v5.ItemTier = tonumber(item.ItemTier)
			table.insert(result, v5)
		else
			local result2

			if type(item) == "string" then
				result2 = item
			else
				local success
				success, result2 = pcall(HttpService.JSONEncode, HttpService, item)

				if not success then
					result2 = tostring(item)
				end
			end

			table.insert(result, {
				GiftType = "Legacy",
				GiftName = result2,
				OtherUserId = 0,
				OtherName = "Unknown player",
				Timestamp = 0,
				Claimed = nil,
				ItemTier = nil
			})
		end
	end

	return result
end

local function GetGamepassInfo(p: number)
	if v4[p] then
		return v4[p]
	end

	local v5 = {
		Kind = "Gifted gamepass",
		Id = tostring(p),
		Name = `Gamepass {p}`,
		Price = nil
	}
	local success, productInfoAsync = pcall(
		MarketplaceService.GetProductInfoAsync,
		MarketplaceService,
		p,
		Enum.InfoType.GamePass
	)

	if success and type(productInfoAsync) == "table" then
		v5.Name = tostring(productInfoAsync.Name or v5.Name)
		v5.Price = tonumber(productInfoAsync.PriceInRobux)
	end

	v4[p] = v5
	return v5
end

local function NormalizeEntitlements(data)
	local result = {}
	local gamepassReceived = data.GamepassReceived

	if type(gamepassReceived) == "table" then
		for k, v5 in gamepassReceived do
			local v6 = tonumber(k)

			if v5 == true and v6 then
				table.insert(result, (GetGamepassInfo(v6)))
			end
		end
	end

	local giftedCosmetics = data.GiftedCosmetics

	if type(giftedCosmetics) == "table" then
		for k, giftedCosmetic in giftedCosmetics do
			if giftedCosmetic == true then
				table.insert(result, {
					Kind = "Gifted cosmetic",
					Id = tostring(k),
					Name = tostring(k),
					Price = nil
				})
			end
		end
	end

	table.sort(result, function(a, b)
		if a.Kind == b.Kind then
			return a.Name < b.Name
		end

		return a.Kind < b.Kind
	end)
	return result
end

local DestroyComponents

DestroyComponents = function(components)
	for _, v5 in components:GetAll() do
		if CUI.IsComponentType(v5, "Expandable") then
			DestroyComponents(v5.Components)
		end

		v5:Destroy()
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function AddEmpty(object, value: string?)
	object:AddText(function(object2)
		object2:SetText(value or "None recorded")
		object2:SetTextColor(Color3.fromRGB(160, 160, 160))
		object2:SetYSize(22)
	end)
end

local function Matches(p: string, items)
	if p == "" then
		return true
	end

	local v5 = ""

	for _, item in items do
		v5 ..= ` {tostring(item)}`
	end

	return string.find(string.lower(v5), p, 1, true) ~= nil
end

local function AddSearchable(components, fn)
	local v5 = ""

	local function fn2() end

	components:AddField(function(object)
		object:SetTextVisible(false):SetPlaceholder("search..."):SetOnChangedRaw(function(value)
			v5 = string.lower(value)
			fn2()
		end)
	end)
	local v6 = components:AddBox(function(object)
		object:SetBackgroundTransparency(1)
	end)

	fn2 = function()
		DestroyComponents(v6.Components)
		fn(v6.Components, v5)
	end

	fn2()
end

-- equivalent calls inferred from this helper; original call sites unknown
local function AddGift(object, data, flag: boolean, count: number)
	object:AddBox(function(object2)
		object2:SetBackgroundTransparency(count % 2 == 0 and 0.95 or 1)
		object2.Components:AddTitle(function(object3)
			object3:SetTitle(data.GiftName)
		end)
		local v5 = { function(object3)
				object3:AddField(function(object4)
					object4:SetText("Type"):SetValue(data.GiftType):SetEnabled(false)
				end)
			end, function(object3)
				object3:AddField(function(object4)
					object4:SetText(flag and "Recipient" or "Sender"):SetValue(data.OtherName):SetEnabled(false)
				end)
			end, function(object3)
				object3:AddNumberField(function(object4)
					object4:SetText("UserId"):SetValue(data.OtherUserId):SetEnabled(false)
				end)
			end }

		if data.Timestamp > 0 then
			table.insert(v5, function(object3)
				object3:AddTime(function(object4)
					object4:SetText(flag and "Sent at" or "Received at"):SetTime(data.Timestamp):SetEnabled(false)
				end)
			end)
		end

		if data.Claimed ~= nil then
			table.insert(v5, function(object3)
				object3:AddCheckbox(function(object4)
					object4:SetText("Claimed"):SetValue(data.Claimed == true):SetEnabled(false)
				end)
			end)
		end

		if data.ItemTier ~= nil then
			table.insert(v5, function(object3)
				object3:AddNumberField(function(object4)
					object4:SetText("Item tier"):SetValue(data.ItemTier):SetEnabled(false)
				end)
			end)
		end

		for i = 1, #v5, 2 do
			local v6 = v5[i]
			local v7 = v5[i + 1]

			if v7 then
				local v8 = v6
				local v9 = v7
				object2.Components:AddSplit(function(p)
					v8(p.LeftComponents)
					v9(p.RightComponents)
				end)
			else
				v6(object2.Components)
			end
		end
	end)
end

local clientEvent = AdminRemote.RegisterClientEvent(
	`Inspect_{script.Name}_GetMarketplace`,
	"cui.inspect.marketplace",
	false,
	function(_, p)
		local v5 = ProfileAccess.Read(p.UserId)
		local data = v5.Data or {}
		return {
			Ok = v5.Ok,
			Message = v5.Message,
			Purchases = NormalizePurchases(data.PurchaseHistory),
			GiftsSent = NormalizeGifts(data.GiftSent, true),
			GiftsReceived = NormalizeGifts(data.GiftReceived, false),
			Entitlements = NormalizeEntitlements(data)
		}
	end
)
local clientEvent2 = AdminRemote.RegisterClientEvent(
	`Inspect_{script.Name}_SendAdminGift`,
	"cui.inspect.marketplace.gift",
	true,
	function(p, data)
		local v5 = GiftConfig.ALL_GIFTS[data.GiftKey]

		if type(v5) ~= "table" then
			return {
				Ok = false,
				Message = "Unknown gift"
			}
		end

		local category = tostring(v5.Category or "Treadmill")
		local itemTier

		if category == "Item" then
			itemTier = math.clamp(math.floor(tonumber(data.ItemTier) or 0), 0, Items.MAX_TIER)
		else
			itemTier = nil
		end

		local name = tostring(v5.Name or data.GiftKey)
		local localPlayer = ProfileAccess.GetLocalPlayer(data.UserId)
		local name2

		if localPlayer then
			name2 = localPlayer.Name
		else
			name2 = tostring(data.UserId)
		end

		if not localPlayer then
			pcall(function()
				name2 = Players:GetNameFromUserIdAsync(data.UserId)
			end)
		end

		local userId = p.UserId
		local nameFromUserIdAsync = p.Name

		if data.SenderUserId ~= nil then
			if data.SenderUserId <= 0 or data.SenderUserId % 1 ~= 0 then
				return {
					Ok = false,
					Message = "Custom sender UserId is invalid"
				}
			end

			local success
			success, nameFromUserIdAsync = pcall(Players.GetNameFromUserIdAsync, Players, data.SenderUserId)

			if not success then
				return {
					Ok = false,
					Message = "Could not resolve the custom sender UserId"
				}
			end

			userId = data.SenderUserId
		end

		local success, result = pcall(function()
			return DataManager.PlayerStore:MessageAsync(tostring(data.UserId), {
				type = "Gift",
				GiftType = data.GiftKey,
				GiftName = name,
				Category = category,
				GamepassId = v5.GamepassId,
				ItemTier = itemTier,
				SenderUserId = userId,
				SenderName = nameFromUserIdAsync
			})
		end)

		if not success then
			return {
				Ok = false,
				Message = `Gift delivery failed: {tostring(result)}`
			}
		end

		if result ~= true then
			return {
				Ok = false,
				Message = "ProfileStore did not accept the gift"
			}
		end

		local store = DataManager:GetStore(p, "GiftSent")

		if store then
			local v7 = store:Get({})
			local v8 = type(v7) ~= "table" and {} or table.clone(v7)
			table.insert(v8, {
				Gift = data.GiftKey,
				GiftName = name,
				TargetUserId = data.UserId,
				TargetName = name2,
				Timestamp = os.time(),
				ItemTier = itemTier
			})

			if #v8 > 100 then
				table.remove(v8, 1)
			end

			store:Set(v8)
			DataManager:Save(p)
		end

		return {
			Ok = true,
			Message = `Sent {name}{itemTier == nil and "" or ` [Tier {itemTier}]`} to {name2} as {nameFromUserIdAsync}`
		}
	end
)
return {
	DisplayName = "Marketplace",
	Permission = "cui.inspect.marketplace",
	Order = 65,
	Setup = function(object, data)
		local NotificationSystem

		if RunService:IsClient() then
			NotificationSystem = require(ReplicatedStorage.NotificationSystem)
		else
			NotificationSystem = nil
		end

		local v5 = v[1]
		local v6 = v2[v5][1] or ""
		local giftKey = v3[v5][v6] or ""
		local itemTier = 0
		local v9 = false
		local v10 = ""
		local v11 = nil
		local v12 = nil
		local v13 = nil
		local v14 = nil
		object:AddSplit(function(p)
			v11 = p.LeftComponents:AddNumberField(function(object2)
				object2:SetText("Purchases"):SetValue(0):SetEnabled(false)
			end)
			v12 = p.RightComponents:AddNumberField(function(object2)
				object2:SetText("Gifts sent"):SetValue(0):SetEnabled(false)
			end)
		end)
		object:AddSplit(function(p)
			v13 = p.LeftComponents:AddNumberField(function(object2)
				object2:SetText("Gifts received"):SetValue(0):SetEnabled(false)
			end)
			v14 = p.RightComponents:AddNumberField(function(object2)
				object2:SetText("Gifted access"):SetValue(0):SetEnabled(false)
			end)
		end)
		local v15 = nil
		local v16 = nil
		local v17 = nil
		local v18 = nil
		object:AddTab(function(object2)
			object2:SetTabs({
				"Purchases",
				"Sent",
				"Received",
				"Entitlements"
			})
			v15 = object2:GetComponentCtn("Purchases"):AddList(function(object3)
				object3:SetSizeY(240)
			end)
			v16 = object2:GetComponentCtn("Sent"):AddList(function(object3)
				object3:SetSizeY(240)
			end)
			v17 = object2:GetComponentCtn("Received"):AddList(function(object3)
				object3:SetSizeY(240)
			end)
			v18 = object2:GetComponentCtn("Entitlements"):AddList(function(object3)
				object3:SetSizeY(240)
			end)
		end)

		local function Notify(p: string, flag: boolean?)
			if not NotificationSystem or p == "" then
				return
			end

			local v19

			if flag == true then
				v19 = Color3.fromRGB(100, 255, 100)
			else
				v19 = Color3.fromRGB(255, 100, 100)
			end

			NotificationSystem:ShowGeneralNotification(p, v19, 4)
		end

		local function Render(data2)
			DestroyComponents(v15.Components)
			DestroyComponents(v16.Components)
			DestroyComponents(v17.Components)
			DestroyComponents(v18.Components)
			v11:SetValue(#data2.Purchases)
			v12:SetValue(#data2.GiftsSent)
			v13:SetValue(#data2.GiftsReceived)
			v14:SetValue(#data2.Entitlements)
			AddSearchable(v15.Components, function(object2, p)
				local count = 0

				for k, purchas in data2.Purchases do
					if not Matches(p, { purchas }) then
						continue
					end

					count += 1
					local v19 = k
					local v20 = purchas
					object2:AddText(function(object3)
						object3:SetText((`{v19}. {v20}`)):SetYSize(22)
					end)
				end

				if count == 0 then
					AddEmpty(object2, #data2.Purchases == 0 and "None recorded" or "No matches") -- equivalent call inferred; original call site unknown
				end
			end)
			AddSearchable(v16.Components, function(object2, p)
				local count = 0

				for i = #data2.GiftsSent, 1, -1 do
					local v19 = data2.GiftsSent[i]

					if not Matches(p, {
						v19.GiftName,
						v19.GiftType,
						v19.OtherName,
						v19.OtherUserId,
						v19.Timestamp,
						v19.ItemTier
					}) then
						continue
					end

					count += 1
					AddGift(object2, v19, true, count) -- equivalent call inferred; original call site unknown
				end

				if count == 0 then
					AddEmpty(object2, #data2.GiftsSent == 0 and "None recorded" or "No matches") -- equivalent call inferred; original call site unknown
				end
			end)
			AddSearchable(v17.Components, function(object2, p)
				local count = 0

				for i = #data2.GiftsReceived, 1, -1 do
					local v19 = data2.GiftsReceived[i]

					if not Matches(p, {
						v19.GiftName,
						v19.GiftType,
						v19.OtherName,
						v19.OtherUserId,
						v19.Timestamp,
						v19.Claimed,
						v19.ItemTier
					}) then
						continue
					end

					count += 1
					AddGift(object2, v19, false, count) -- equivalent call inferred; original call site unknown
				end

				if count == 0 then
					AddEmpty(object2, #data2.GiftsReceived == 0 and "None recorded" or "No matches") -- equivalent call inferred; original call site unknown
				end
			end)
			AddSearchable(v18.Components, function(object2, p)
				local count = 0

				for _, entitlement in data2.Entitlements do
					if not Matches(p, {
						entitlement.Name,
						entitlement.Kind,
						entitlement.Id,
						entitlement.Price
					}) then
						continue
					end

					count += 1
					local v19 = entitlement
					object2:AddExpandable(function(object3)
						object3:SetText(v19.Name)
						object3.Components:AddSplit(function(p2)
							p2.LeftComponents:AddField(function(object4)
								object4:SetText("Kind"):SetValue(v19.Kind):SetEnabled(false)
							end)
							p2.RightComponents:AddField(function(object4)
								object4:SetText("Key / ID"):SetValue(v19.Id):SetEnabled(false)
							end)
						end)

						if v19.Price then
							object3.Components:AddNumberField(function(object4)
								object4:SetText("Current price (Robux)"):SetValue(v19.Price):SetEnabled(false)
							end)
						end
					end)
				end

				if count == 0 then
					AddEmpty(object2, #data2.Entitlements == 0 and "None recorded" or "No matches") -- equivalent call inferred; original call site unknown
				end
			end)
		end

		local function Refresh()
			if RunService:IsServer() or not clientEvent then
				return
			end

			clientEvent:Fire({
				UserId = data.UserId
			}):andThen(function(p)
				if not p.Ok then
					data.NotifyProfileError(p.Message)
				end

				Render(p)
			end):catch(function(p)
				Notify(`Failed to load marketplace data: {tostring(p)}`, false)
			end)
		end

		object:AddTitle(function(object2)
			object2:SetTitle("Send administrative gift")
		end)
		local v19 = nil
		local v20 = nil
		object:AddSplit(function(object2)
			object2:SetLeftSizeAbsolute(22)
			object2.LeftComponents:AddCheckbox(function(object3)
				object3:ShowCheckboxOnly():SetYSize(22):SetValue(false):SetOnChanged(function(p)
					v9 = p
					v19:SetEnabled(p)
					v20:SetEnabled(p)
				end)
			end)
			object2.RightComponents:AddSplit(function(object3)
				object3:SetLeftSizePercent(0.5)
				v19 = object3.LeftComponents:AddDropdown(function(object4)
					object4:SetTextVisible(false):SetChoiceList({ "Loading..." }):SetSelected("Loading..."):SetEnabled(false):SetOnChanged(function(p)
						local knownUser = KnownUsers[p]

						if not knownUser then
							return
						end

						v10 = tostring(knownUser)
						v20:SetValue(v10)
					end)
				end)
				v20 = object3.RightComponents:AddField(function(object4)
					object4:SetTextVisible(false):SetPlaceholder("UserId..."):SetValue(""):SetEnabled(false):SetOnChangedRaw(function(p)
						v10 = p
					end)
				end)
			end)
		end)
		local v21 = nil
		local v22 = nil
		object:AddDropdown(function(object2)
			object2:SetText("Category"):SetChoiceList(v):SetSelected(v5):SetOnChanged(function(p)
				v5 = p
				v6 = v2[p][1] or ""
				giftKey = v3[p][v6] or ""
				v21:SetChoiceList(v2[p]):SetSelected(v6)
				v22:SetVisible(p == "Item")
			end)
		end)
		v21 = object:AddDropdown(function(object2)
			object2:SetText("Gift"):SetChoiceList(v2[v5]):SetSelected(v6):SetOnChanged(function(p)
				v6 = p
				giftKey = v3[v5][p] or ""
			end)
		end)
		v22 = object:AddDropdown(function(object2)
			object2:SetText("Item tier"):SetChoiceList({
				"0",
				"1",
				"2",
				"3",
				"4",
				"5"
			}):SetSelected("0"):SetVisible(false):SetOnChanged(function(p)
				itemTier = tonumber(p) or 0
			end)
		end)
		object:AddButton(function(object2)
			object2:SetButtonText("Send gift without purchase"):SetYSize(22):SetEnabledPermission("cui.inspect.marketplace.gift"):DoNeedConfirmation(true):SetButtonCallback(function()
				if not clientEvent2 or giftKey == "" then
					return
				end

				local senderUserId

				if v9 then
					senderUserId = tonumber(v10)

					if not senderUserId or senderUserId <= 0 or senderUserId % 1 ~= 0 then
						if NotificationSystem then
							NotificationSystem:ShowGeneralNotification(
								"Custom sender UserId is invalid",
								Color3.fromRGB(255, 100, 100),
								4
							)
						end

						return
					end
				end

				clientEvent2:Fire({
					UserId = data.UserId,
					GiftKey = giftKey,
					ItemTier = itemTier,
					SenderUserId = senderUserId
				}):andThen(function(p)
					Notify(p.Message, p.Ok)

					if p.Ok then
						task.defer(Refresh)
					end
				end):catch(function(p)
					Notify(`Failed to send gift: {tostring(p)}`, false)
				end)
			end)
		end)
		local v23 = {}

		for k in KnownUsers do
			table.insert(v23, k)
		end

		table.sort(v23)
		local v24 = v23[1]
		v19:SetChoiceList(v23):SetSelected(v24)
		v10 = tostring(KnownUsers[v24])
		v20:SetValue(v10)
		object:AddButton(function(object2)
			object2:SetButtonText("Refresh marketplace"):SetYSize(22):SetEnabledPermission("cui.inspect.marketplace"):SetButtonCallback(Refresh)
		end)
		data.PresenceChanged:Connect(Refresh)
		Refresh()
	end
}