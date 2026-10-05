local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ServerScriptService = game:GetService("ServerScriptService")
local AdminRemote = require(ReplicatedStorage._FRAMEWORK.Features.Admins.AdminRemote)
require(ReplicatedStorage.CUI)
local Items = require(ReplicatedStorage.FeatureConfigs.Items)
local ProfileAccess = require(script.Parent.Parent.ProfileAccess)
require(ReplicatedStorage.Cmdr.Menus.InspectMenu.Types)
local DataManager = RunService:IsServer() and require(ServerScriptService.DataManager)
local LimitedItems = RunService:IsServer() and require(ServerScriptService._FRAMEWORK.ServerFeatures.LimitedItems)
local v = {}
local v2 = {}

for k, v3 in Items.ITEMS do
	local v4

	if Items.IsLimitedKey(k) then
		v4 = `{k} [LIMITED: {v3.limited}]`
	else
		v4 = k
	end

	table.insert(v, v4)
	v2[v4] = k
end

table.sort(v)

local function StackEntries(items, equippedItems)
	local v3 = {}

	local function AddEntries(p, flag: boolean)
		for _, v4 in Items.Normalize(p) do
			local limitedNumber = Items.LimitedNumberOf(v4)
			local maxLimited = Items.MaxLimitedOf(v4)
			local signature = Items.SignatureOf(v4)
			local v5 = signature or "unsigned"
			local formatted = ("%*\0%*\0%*"):format(v4.Key, v4.Tier, v5)

			if Items.IsLimitedKey(v4.Key) then
				formatted = ("%*\0%*\0%*\0%*"):format(v4.Key, v4.Tier, limitedNumber or "unserialized", v5)
			end

			local v6 = v3[formatted]

			if not v6 then
				local v7 = Items.ITEMS[v4.Key]
				v6 = {
					ItemKey = v4.Key,
					DisplayName = v7 and v7.name or v4.Key,
					Tier = v4.Tier,
					Amount = 0,
					EquippedAmount = 0,
					Limited = limitedNumber,
					MaxLimited = maxLimited,
					Signature = signature
				}
				v3[formatted] = v6
			end

			v6.Amount += 1

			if flag then
				v6.EquippedAmount += 1
			end
		end
	end

	AddEntries(items, false)
	AddEntries(equippedItems, true)
	local result = {}

	for _, v4 in v3 do
		table.insert(result, v4)
	end

	table.sort(result, function(a, b)
		if a.DisplayName ~= b.DisplayName then
			return a.DisplayName < b.DisplayName
		end

		if a.Tier ~= b.Tier then
			return a.Tier < b.Tier
		end

		if a.Limited == b.Limited then
			return (a.Signature or 1e999) < (b.Signature or 1e999)
		end

		return (a.Limited or 1e999) < (b.Limited or 1e999)
	end)
	return result
end

local function RemoveEntries(normalized, itemKey: string, p: number, p2: number, limited: number?, signature: number?)
	local normalized2 = Items.Normalize(normalized)
	local count = 0

	for i = #normalized2, 1, -1 do
		local v3 = normalized2[i]
		local v4 = not Items.IsLimitedKey(itemKey) or Items.LimitedNumberOf(v3) == limited
		local v5 = Items.SignatureOf(v3) == signature

		if not (count < p2 and v3.Key == itemKey and v3.Tier == p and v4) then
			continue
		end

		if not v5 then
			continue
		end

		table.remove(normalized2, i)
		count += 1
	end

	return normalized2, count
end

local function BuildResponse(data, p: string?, ok: boolean?)
	local data2 = data.Data or {}

	if ok == nil then
		ok = data.Ok
	end

	return {
		Ok = ok,
		Message = p or data.Message,
		Editable = data.Ok and (data.IsLocal or not data.IsSessionActive),
		Entries = StackEntries(data2.Items or {}, data2.EquippedItems or {})
	}
end

local clientEvent = AdminRemote.RegisterClientEvent(
	`Inspect_{script.Name}_GetInventory`,
	"cui.inspect.items",
	false,
	function(_, p)
		return (BuildResponse(ProfileAccess.Read(p.UserId)))
	end
)
local clientEvent2 = AdminRemote.RegisterClientEvent(
	`Inspect_{script.Name}_ChangeInventory`,
	"cui.inspect.items.write",
	true,
	function(_, data)
		if not Items.ITEMS[data.ItemKey] then
			return {
				Ok = false,
				Message = "Unknown item",
				Editable = false,
				Entries = {}
			}
		end

		if data.Action ~= "Give" and data.Action ~= "RemoveOne" and data.Action ~= "RemoveAll" then
			return {
				Ok = false,
				Message = "Unknown inventory action",
				Editable = false,
				Entries = {}
			}
		end

		local limited = data.Limited

		if limited ~= nil and (type(limited) ~= "number" or limited ~= limited or math.abs(limited) == 1e999 or limited < 1 or limited % 1 ~= 0) then
			return {
				Ok = false,
				Message = "Invalid limited serial",
				Editable = false,
				Entries = {}
			}
		end

		local signature = data.Signature

		if signature ~= nil and (type(signature) ~= "number" or signature ~= signature or math.abs(signature) == 1e999 or signature == 0 or signature % 1 ~= 0) then
			return {
				Ok = false,
				Message = "Invalid signature",
				Editable = false,
				Entries = {}
			}
		end

		local v3 = ProfileAccess.Read(data.UserId)

		if not v3.Ok or not v3.Data or v3.IsSessionActive and not v3.IsLocal then
			return (BuildResponse(v3))
		end

		local localPlayer = ProfileAccess.GetLocalPlayer(data.UserId)
		local data2 = v3.Data
		local normalized = Items.Normalize(data2.Items)
		local normalized2 = Items.Normalize(data2.EquippedItems)
		local v4 = math.clamp(math.floor(data.Tier), 0, Items.MAX_TIER)
		local v5

		if data.Action == "Give" then
			local v6 = math.clamp(math.floor(data.Amount or 1), 1, 100)

			if localPlayer then
				local v7, v8 = DataManager:GrantItem(localPlayer, data.ItemKey, v4, v6)

				if v7 then
					DataManager:Save(localPlayer)
				end

				local v10 = ProfileAccess.Read(data.UserId)
				local v11

				if v7 then
					v11 = `Granted {data.ItemKey} [Tier {v4}] x{v6}`
				else
					v11 = `Grant failed: {tostring(v8)}`
				end

				return (BuildResponse(v10, v11, v7))
			else
				if Items.IsLimitedKey(data.ItemKey) then
					local entries, v7 = LimitedItems.allocateEntries(data.ItemKey, v4, v6, false)

					if not entries then
						return (BuildResponse(v3, `Grant failed: {tostring(v7)}`, false))
					end

					for _, entry in entries do
						table.insert(normalized, (Items.CopyEntry(entry)))
					end
				else
					for _ = 1, v6 do
						table.insert(normalized, (Items.Entry(data.ItemKey, v4)))
					end
				end

				v5 = `Granted {data.ItemKey} [Tier {v4}] x{v6}`
			end
		else
			local v6 = data.Action == "RemoveOne" and 1 or 1e999
			local v7
			normalized, v7 = RemoveEntries(normalized, data.ItemKey, v4, v6, data.Limited, data.Signature)

			if v7 < v6 then
				local v8
				normalized2, v8 = RemoveEntries(normalized2, data.ItemKey, v4, v6 - v7, data.Limited, data.Signature)
				v7 += v8
			end

			v5 = `Removed {data.ItemKey} [Tier {v4}] x{v7}`
		end

		local v6, v7

		if localPlayer then
			local store = DataManager:GetStore(localPlayer, "Items")
			local store2 = DataManager:GetStore(localPlayer, "EquippedItems")

			if store and store2 then
				store:Set(normalized)
				store2:Set(normalized2)
				DataManager:Save(localPlayer)
				v6 = true
				v7 = "Saved to the live profile"
			else
				v6 = false
				v7 = "Profile is still loading"
			end
		else
			v6, v7 = ProfileAccess.Write(data.UserId, {
				Items = normalized,
				EquippedItems = normalized2
			})
		end

		if v6 and localPlayer then
			local remotes = ReplicatedStorage:FindFirstChild("Remotes")
			local itemAction = remotes and remotes:FindFirstChild("ItemAction")

			if itemAction then
				itemAction:FireClient(localPlayer, "Update", {
					Items = normalized,
					EquippedItems = normalized2
				})
			end
		end

		local v8 = ProfileAccess.Read(data.UserId)

		if v6 then
			v7 = v5
		end

		return (BuildResponse(v8, v7, v6))
	end
)
return {
	DisplayName = "Items",
	Permission = "cui.inspect.items",
	Order = 20,
	Setup = function(object, data)
		local NotificationSystem

		if RunService:IsClient() then
			NotificationSystem = require(ReplicatedStorage.NotificationSystem)
		else
			NotificationSystem = nil
		end

		local v3 = v[1] or ""
		local itemKey = v2[v3] or ""
		local tier = 0
		local amount = 1
		local v7 = ""
		local editable = false
		local entries = {}

		local function fn() end

		object:AddTitle(function(object2)
			object2:SetTitle("Current inventory")
		end)
		object:AddField(function(object2)
			object2:SetTextVisible(false):SetPlaceholder("search..."):SetOnChangedRaw(function(value)
				v7 = string.lower(value)
				fn()
			end)
		end)
		local v8 = object:AddList(function(object2)
			object2:SetSizeY(190)
		end)

		local function Notify(message: string, ok: boolean)
			if not NotificationSystem or message == "" then
				return
			end

			local v9

			if ok then
				v9 = Color3.fromRGB(100, 255, 100)
			else
				v9 = Color3.fromRGB(255, 100, 100)
			end

			NotificationSystem:ShowGeneralNotification(message, v9, 4)
		end

		local function ApplyResponse(data2, flag: boolean?)
			if data2 then
				editable = data2.Editable
				entries = data2.Entries

				if flag == true then
					Notify(data2.Message, data2.Ok)
				elseif not data2.Ok then
					data.NotifyProfileError(data2.Message)
				end

				fn()
			else
				editable = false
				entries = {}
				fn()

				if flag == true then
					if NotificationSystem then
						NotificationSystem:ShowGeneralNotification(
							"Inventory data is unavailable",
							Color3.fromRGB(255, 100, 100),
							4
						)
					end
				else
					data.NotifyProfileError("Inventory data is unavailable")
				end
			end
		end

		local function RemoveStack(data2, action: string)
			if editable and clientEvent2 then
				clientEvent2:Fire({
					UserId = data.UserId,
					Action = action,
					ItemKey = data2.ItemKey,
					Tier = data2.Tier,
					Limited = data2.Limited,
					Signature = data2.Signature
				}):andThen(function(data3)
					if data3 then
						editable = data3.Editable
						entries = data3.Entries
						Notify(data3.Message, data3.Ok)
						fn()
					else
						editable = false
						entries = {}
						fn()

						if NotificationSystem then
							NotificationSystem:ShowGeneralNotification(
								"Inventory data is unavailable",
								Color3.fromRGB(255, 100, 100),
								4
							)
						end
					end
				end):catch(function()
					editable = false
					entries = {}
					fn()

					if NotificationSystem then
						NotificationSystem:ShowGeneralNotification(
							"Inventory data is unavailable",
							Color3.fromRGB(255, 100, 100),
							4
						)
					end
				end)
			end
		end

		fn = function()
			for _, v9 in v8.Components:GetAll() do
				v9:Destroy()
			end

			local count = 0

			for k, entry in entries do
				local v9 = not entry.Limited and "" or ` limited serial {entry.Limited} max {entry.MaxLimited or "?"}`
				local v10 = not entry.Signature and "" or ` signed {entry.Signature}`
				local v11 = string.lower((`{entry.DisplayName} {entry.ItemKey} tier {entry.Tier}{v9}{v10}`))

				if not (v7 == "" or string.find(v11, v7, 1, true)) then
					continue
				end

				count += 1
				local v12 = k
				local v13 = entry
				v8.Components:AddBox(function(object2)
					object2:SetBackgroundTransparency(v12 % 2 == 0 and 0.95 or 1)
					object2.Components:AddSplit(function(object3)
						object3:SetLeftSizePercent(0.58)
						object3.LeftComponents:AddText(function(object4)
							local v14 = not (v13.EquippedAmount > 0) and "" or ` ({v13.EquippedAmount} equipped)`
							local v15

							if v13.Limited then
								v15 = ` #{v13.Limited}/{v13.MaxLimited or "?"}`
							elseif Items.IsLimitedKey(v13.ItemKey) then
								v15 = ` [unserialized] x{v13.Amount}`
							else
								v15 = ` x{v13.Amount}`
							end

							if v13.Signature then
								v15 ..= ` [S: {v13.Signature}]`
							end

							object4:SetText((`{v13.DisplayName} [Tier {v13.Tier}]{v15}{v14}`)):SetYSize(22)
						end)
						object3.RightComponents:AddSplit(function(p)
							p.LeftComponents:AddButton(function(object4)
								object4:SetButtonText("Remove 1"):SetYSize(22):SetEnabled(editable):SetEnabledPermission("cui.inspect.items.write"):DoNeedConfirmation(true):SetButtonCallback(function()
									RemoveStack(v13, "RemoveOne")
								end)
							end)
							p.RightComponents:AddButton(function(object4)
								object4:SetButtonText("Remove all"):SetYSize(22):SetEnabled(editable):SetEnabledPermission("cui.inspect.items.write"):DoNeedConfirmation(true):SetButtonCallback(function()
									RemoveStack(v13, "RemoveAll")
								end)
							end)
						end)
					end)
				end)
			end

			if count == 0 then
				v8.Components:AddText(function(object2)
					object2:SetText(#entries == 0 and "Inventory is empty." or "No items match this search.")
				end)
			end
		end

		object:AddTitle(function(object2)
			object2:SetTitle("Give item")
		end)
		object:AddDropdown(function(object2)
			object2:SetText("Item"):SetChoiceList(v):SetSelected(v3):SetOnChanged(function(p)
				v3 = p
				itemKey = v2[p] or ""
			end)
		end)
		object:AddSplit(function(p)
			p.LeftComponents:AddDropdown(function(object2)
				object2:SetText("Tier"):SetChoiceList({
					"0",
					"1",
					"2",
					"3",
					"4",
					"5"
				}):SetSelected("0"):SetOnChanged(function(p2)
					tier = tonumber(p2) or 0
				end)
			end)
			p.RightComponents:AddField(function(object2)
				object2:SetText("Amount"):SetNumberFilter(1, 100):SetValue("1"):SetOnChangedUnfocus(function(p2)
					amount = tonumber(p2) or 1
				end)
			end)
		end)
		object:AddButton(function(object2)
			object2:SetButtonText("Give"):SetYSize(22):SetEnabledPermission("cui.inspect.items.write"):DoNeedConfirmation(true):SetButtonCallback(function()
				if editable and clientEvent2 then
					clientEvent2:Fire({
						UserId = data.UserId,
						Action = "Give",
						ItemKey = itemKey,
						Tier = tier,
						Amount = amount
					}):andThen(function(data2)
						if data2 then
							editable = data2.Editable
							entries = data2.Entries
							Notify(data2.Message, data2.Ok)
							fn()
						else
							editable = false
							entries = {}
							fn()

							if NotificationSystem then
								NotificationSystem:ShowGeneralNotification(
									"Inventory data is unavailable",
									Color3.fromRGB(255, 100, 100),
									4
								)
							end
						end
					end):catch(function()
						editable = false
						entries = {}
						fn()

						if NotificationSystem then
							NotificationSystem:ShowGeneralNotification(
								"Inventory data is unavailable",
								Color3.fromRGB(255, 100, 100),
								4
							)
						end
					end)
				end
			end)
		end)

		local function Refresh()
			if RunService:IsServer() or not clientEvent then
				return
			end

			clientEvent:Fire({
				UserId = data.UserId
			}):andThen(ApplyResponse):catch(function()
				editable = false
				entries = {}
				fn()
				data.NotifyProfileError("Inventory data is unavailable")
			end)
		end

		object:AddButton(function(object2)
			object2:SetButtonText("Refresh inventory"):SetYSize(22):SetEnabledPermission("cui.inspect.items"):SetButtonCallback(Refresh)
		end)
		data.PresenceChanged:Connect(Refresh)
		Refresh()
	end
}