local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ServerScriptService = game:GetService("ServerScriptService")
local AdminRemote = require(ReplicatedStorage._FRAMEWORK.Features.Admins.AdminRemote)
require(ReplicatedStorage.CUI)
local Items = require(ReplicatedStorage.FeatureConfigs.Items)
local ProfileAccess = require(script.Parent.Parent.ProfileAccess)
require(ReplicatedStorage.Cmdr.Menus.InspectMenu.Types)
local DataManager = RunService:IsServer() and require(ServerScriptService.DataManager)
local v = {}

for k in Items.ITEMS do
	table.insert(v, k)
end

table.sort(v)

local function StackEntries(items, equippedItems)
	local v2 = {}

	local function AddEntries(p, flag: boolean)
		for _, v3 in Items.Normalize(p) do
			local formatted = ("%*\0%*"):format(v3.Key, v3.Tier)
			local v4 = v2[formatted]

			if not v4 then
				local v5 = Items.ITEMS[v3.Key]
				v4 = {
					ItemKey = v3.Key,
					DisplayName = v5 and v5.name or v3.Key,
					Tier = v3.Tier,
					Amount = 0,
					EquippedAmount = 0
				}
				v2[formatted] = v4
			end

			v4.Amount += 1

			if flag then
				v4.EquippedAmount += 1
			end
		end
	end

	AddEntries(items, false)
	AddEntries(equippedItems, true)
	local result = {}

	for _, v3 in v2 do
		table.insert(result, v3)
	end

	table.sort(result, function(a, b)
		if a.DisplayName == b.DisplayName then
			return a.Tier < b.Tier
		end

		return a.DisplayName < b.DisplayName
	end)
	return result
end

local function RemoveEntries(normalized, itemKey: string, p: number, p2: number)
	local normalized2 = Items.Normalize(normalized)
	local count = 0

	for i = #normalized2, 1, -1 do
		local v2 = normalized2[i]

		if not (count < p2 and v2.Key == itemKey and v2.Tier == p) then
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

		local v2 = ProfileAccess.Read(data.UserId)

		if not v2.Ok or not v2.Data or v2.IsSessionActive and not v2.IsLocal then
			return (BuildResponse(v2))
		end

		local localPlayer = ProfileAccess.GetLocalPlayer(data.UserId)
		local data2 = v2.Data
		local normalized = Items.Normalize(data2.Items)
		local normalized2 = Items.Normalize(data2.EquippedItems)
		local v3 = math.clamp(math.floor(data.Tier), 0, Items.MAX_TIER)
		local v4

		if data.Action == "Give" then
			local v5 = math.clamp(math.floor(data.Amount or 1), 1, 100)

			if localPlayer then
				local v6, v7 = DataManager:GrantItem(localPlayer, data.ItemKey, v3, "Both", v5)

				if v6 then
					DataManager:Save(localPlayer)
				end

				local v9 = ProfileAccess.Read(data.UserId)
				local v10

				if v6 then
					v10 = `Granted {data.ItemKey} [Tier {v3}] x{v5}`
				else
					v10 = `Grant failed: {tostring(v7)}`
				end

				return (BuildResponse(v9, v10, v6))
			else
				for _ = 1, v5 do
					table.insert(normalized, Items.Entry(data.ItemKey, v3))
				end

				v4 = `Granted {data.ItemKey} [Tier {v3}] x{v5}`
			end
		else
			local v5 = data.Action == "RemoveOne" and 1 or 1e999
			local v6
			normalized, v6 = RemoveEntries(normalized, data.ItemKey, v3, v5)

			if v6 < v5 then
				local v7
				normalized2, v7 = RemoveEntries(normalized2, data.ItemKey, v3, v5 - v6)
				v6 += v7
			end

			v4 = `Removed {data.ItemKey} [Tier {v3}] x{v6}`
		end

		local v5, v6

		if localPlayer then
			local store = DataManager:GetStore(localPlayer, "Items")
			local store2 = DataManager:GetStore(localPlayer, "EquippedItems")

			if store and store2 then
				store:Set(normalized)
				store2:Set(normalized2)
				DataManager:Save(localPlayer)
				v5 = true
				v6 = "Saved to the live profile"
			else
				v5 = false
				v6 = "Profile is still loading"
			end
		else
			v5, v6 = ProfileAccess.Write(data.UserId, {
				Items = normalized,
				EquippedItems = normalized2
			})
		end

		if v5 and localPlayer then
			local remotes = ReplicatedStorage:FindFirstChild("Remotes")
			local itemAction = remotes and remotes:FindFirstChild("ItemAction")

			if itemAction then
				itemAction:FireClient(localPlayer, "Update", {
					Items = normalized,
					EquippedItems = normalized2
				})
			end
		end

		local v7 = ProfileAccess.Read(data.UserId)

		if v5 then
			v6 = v4
		end

		return (BuildResponse(v7, v6, v5))
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

		local itemKey = v[1] or ""
		local tier = 0
		local amount = 1
		local v5 = ""
		local editable = false
		local entries = {}

		local function fn() end

		object:AddTitle(function(object2)
			object2:SetTitle("Current inventory")
		end)
		object:AddField(function(object2)
			object2:SetTextVisible(false):SetPlaceholder("search..."):SetOnChangedRaw(function(value)
				v5 = string.lower(value)
				fn()
			end)
		end)
		local v6 = object:AddList(function(object2)
			object2:SetSizeY(190)
		end)

		local function Notify(message: string, ok: boolean)
			if not NotificationSystem or message == "" then
				return
			end

			local v7

			if ok then
				v7 = Color3.fromRGB(100, 255, 100)
			else
				v7 = Color3.fromRGB(255, 100, 100)
			end

			NotificationSystem:ShowGeneralNotification(message, v7, 4)
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

		local function RemoveStack(p, action: string)
			if editable and clientEvent2 then
				clientEvent2:Fire({
					UserId = data.UserId,
					Action = action,
					ItemKey = p.ItemKey,
					Tier = p.Tier
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
		end

		fn = function()
			for _, v7 in v6.Components:GetAll() do
				v7:Destroy()
			end

			local count = 0

			for k, entry in entries do
				local v7 = string.lower((`{entry.DisplayName} {entry.ItemKey} tier {entry.Tier}`))

				if not (v5 == "" or string.find(v7, v5, 1, true)) then
					continue
				end

				count += 1
				local v8 = k
				local v9 = entry
				v6.Components:AddBox(function(object2)
					object2:SetBackgroundTransparency(v8 % 2 == 0 and 0.95 or 1)
					object2.Components:AddSplit(function(object3)
						object3:SetLeftSizePercent(0.58)
						object3.LeftComponents:AddText(function(object4)
							local v10 = not (v9.EquippedAmount > 0) and "" or ` ({v9.EquippedAmount} equipped)`
							object4:SetText((`{v9.DisplayName} [Tier {v9.Tier}] x{v9.Amount}{v10}`)):SetYSize(22)
						end)
						object3.RightComponents:AddSplit(function(p)
							p.LeftComponents:AddButton(function(object4)
								object4:SetButtonText("Remove 1"):SetYSize(22):SetEnabled(editable):SetEnabledPermission("cui.inspect.items.write"):DoNeedConfirmation(true):SetButtonCallback(function()
									RemoveStack(v9, "RemoveOne")
								end)
							end)
							p.RightComponents:AddButton(function(object4)
								object4:SetButtonText("Remove all"):SetYSize(22):SetEnabled(editable):SetEnabledPermission("cui.inspect.items.write"):DoNeedConfirmation(true):SetButtonCallback(function()
									RemoveStack(v9, "RemoveAll")
								end)
							end)
						end)
					end)
				end)
			end

			if count == 0 then
				v6.Components:AddText(function(object2)
					object2:SetText(#entries == 0 and "Inventory is empty." or "No items match this search.")
				end)
			end
		end

		object:AddTitle(function(object2)
			object2:SetTitle("Give item")
		end)
		object:AddDropdown(function(object2)
			object2:SetText("Item"):SetChoiceList(v):SetSelected(itemKey):SetOnChanged(function(p)
				itemKey = p
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