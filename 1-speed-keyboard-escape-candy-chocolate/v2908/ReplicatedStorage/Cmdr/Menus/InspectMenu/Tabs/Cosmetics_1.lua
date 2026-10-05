local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ServerScriptService = game:GetService("ServerScriptService")
local AdminRemote = require(ReplicatedStorage._FRAMEWORK.Features.Admins.AdminRemote)
local AuraConfig = require(ReplicatedStorage.FeatureConfigs.AuraConfig)
require(ReplicatedStorage.CUI)
local EventsConfig = require(ReplicatedStorage.EventsConfig)
local ProfileAccess = require(script.Parent.Parent.ProfileAccess)
local Skins = require(ReplicatedStorage.FeatureConfigs.PersonalTreadmill.Skins)
local TrailConfig = require(ReplicatedStorage.FeatureConfigs.TrailConfig)
require(ReplicatedStorage.Cmdr.Menus.InspectMenu.Types)
local AuraManager = RunService:IsServer() and require(ServerScriptService.AuraManager)
local PersonalTreadmillManager = RunService:IsServer() and require(ServerScriptService.PersonalTreadmillManager)
local TrailManager = RunService:IsServer() and require(ServerScriptService.TrailManager)
local v = {
	Trails = table.clone(TrailConfig.TRAILS),
	Auras = AuraConfig.AURAS,
	Treadmills = Skins.SKINS
}

for _, v2 in EventsConfig.Trails or {} do
	v.Trails[v2.Key] = v2
end

local v2 = {}

for k, v3 in v do
	local v4 = {}

	for k2 in v3 do
		table.insert(v4, k2)
	end

	table.sort(v4)
	v2[k] = v4
end

local function SortedList(items)
	local result = {}

	if type(items) == "table" then
		for _, item in items do
			if type(item) == "string" then
				table.insert(result, item)
			end
		end
	end

	table.sort(result)
	return result
end

-- equivalent calls inferred from this helper; original call sites unknown
local function GetDefault(category: string)
	if category == "Treadmills" then
		return "DefaultTreadmill"
	end

	return "None"
end

-- equivalent calls inferred from this helper; original call sites unknown
local function GetDisplayName(p: string, p2: string)
	local v3 = v[p] and v[p][p2]

	if type(v3) == "table" then
		return (tostring(v3.displayName or v3.name or p2))
	end

	return p2
end

local function GetDetails(p: string, p2: string)
	local v3 = v[p] and v[p][p2]

	if type(v3) ~= "table" then
		return ""
	end

	local v4 = {}
	local multiplier = v3.Multiplier or v3.multiplier

	if type(multiplier) == "number" then
		table.insert(v4, (`{multiplier}x`))
	end

	if type(v3.category) == "string" then
		table.insert(v4, v3.category)
	end

	return table.concat(v4, "  |  ")
end

local function ToResponse(data, p: string?, ok: boolean?)
	local data2 = data.Data or {}

	if ok == nil then
		ok = data.Ok
	end

	return {
		Ok = ok,
		Message = p or data.Message,
		Editable = data.Ok and (data.IsLocal or not data.IsSessionActive),
		OwnedTrails = SortedList(data2.OwnedTrails),
		OwnedAuras = SortedList(data2.OwnedAuras),
		OwnedSkins = SortedList(data2.OwnedTreadmillSkins),
		EquippedTrail = tostring(data2.EquippedTrail or "None"),
		EquippedAura = tostring(data2.EquippedAura or "None"),
		EquippedSkin = tostring(data2.EquippedTreadmillSkin or "DefaultTreadmill")
	}
end

local clientEvent = AdminRemote.RegisterClientEvent(
	`Inspect_{script.Name}_GetCosmetics`,
	"cui.inspect.cosmetics",
	false,
	function(_, p)
		return (ToResponse(ProfileAccess.Read(p.UserId)))
	end
)
local clientEvent2 = AdminRemote.RegisterClientEvent(
	`Inspect_{script.Name}_ChangeCosmetic`,
	"cui.inspect.cosmetics.write",
	true,
	function(_, data)
		if data.Action ~= "Grant" and data.Action ~= "Revoke" then
			return (ToResponse({
				Ok = false,
				Data = nil,
				IsOnlineElsewhere = false,
				Message = "Unknown cosmetic action"
			}))
		end

		local v3 = v[data.Category]
		local default = GetDefault(data.Category) -- equivalent call inferred; original call site unknown

		if not (v3 and v3[data.Key]) then
			return (ToResponse({
				Ok = false,
				Data = nil,
				IsOnlineElsewhere = false,
				Message = "Unknown cosmetic"
			}))
		end

		local v5 = ProfileAccess.Read(data.UserId)

		if not v5.Ok or not v5.Data or v5.IsSessionActive and not v5.IsLocal then
			return (ToResponse(v5))
		end

		local data2 = v5.Data
		local v6 = data.Category == "Trails" and "OwnedTrails" or data.Category == "Auras" and "OwnedAuras" or "OwnedTreadmillSkins"
		local v7 = data.Category == "Trails" and "EquippedTrail" or data.Category == "Auras" and "EquippedAura" or "EquippedTreadmillSkin"
		local sortedList = SortedList(data2[v6])
		local v9 = tostring(data2[v7] or default)

		if data.Action == "Grant" then
			if not table.find(sortedList, data.Key) then
				table.insert(sortedList, data.Key)
			end
		elseif data.Action == "Revoke" then
			if data.Key == default then
				return (ToResponse(v5, `Cannot revoke {default}`, false))
			end

			local index = table.find(sortedList, data.Key)

			if index then
				table.remove(sortedList, index)
			end

			if v9 == data.Key then
				v9 = default
			end
		end

		local v10, v11 = ProfileAccess.Write(data.UserId, {
			[v6] = sortedList,
			[v7] = v9
		})
		local localPlayer = ProfileAccess.GetLocalPlayer(data.UserId)

		if v10 and localPlayer then
			if data.Category == "Trails" then
				TrailManager:ApplyTrailVisual(localPlayer, TrailManager:GetEffectiveVisual(localPlayer))
			end

			if data.Category == "Auras" then
				AuraManager:ApplyAuraVisual(localPlayer, AuraManager:GetEffectiveVisual(localPlayer))
			end

			if data.Category == "Treadmills" then
				PersonalTreadmillManager:EquipSkin(localPlayer, v9)
			end

			local remotes = ReplicatedStorage:FindFirstChild("Remotes")
			local updateUI = remotes and remotes:FindFirstChild("UpdateUI")

			if updateUI then
				updateUI:FireClient(localPlayer, {
					[v6] = sortedList,
					[v7] = v9
				})
			end
		end

		local v12

		if data.Action == "Grant" then
			v12 = `Granted {data.Key}`
		else
			v12 = `Revoked {data.Key}`
		end

		local v14 = ProfileAccess.Read(data.UserId)

		if v10 then
			v11 = v12
		end

		return (ToResponse(v14, v11, v10))
	end
)
return {
	DisplayName = "Cosmetics",
	Permission = "cui.inspect.cosmetics",
	Order = 40,
	Setup = function(object, data)
		local NotificationSystem

		if RunService:IsClient() then
			NotificationSystem = require(ReplicatedStorage.NotificationSystem)
		else
			NotificationSystem = nil
		end

		local category = "Trails"
		local v4 = v2[category][1] or ""
		local v5 = ""
		local editable = false
		local v6 = nil
		local v7 = nil

		local function fn() end

		local function fn2() end

		local function Notify(p: string, flag: boolean)
			if not NotificationSystem or p == "" then
				return
			end

			local v8

			if flag then
				v8 = Color3.fromRGB(100, 255, 100)
			else
				v8 = Color3.fromRGB(255, 100, 100)
			end

			NotificationSystem:ShowGeneralNotification(p, v8, 4)
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function GetOwned(data2)
			if category == "Trails" then
				return data2.OwnedTrails
			elseif category == "Auras" then
				return data2.OwnedAuras
			end

			return data2.OwnedSkins
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function GetEquipped(data2)
			if category == "Trails" then
				return data2.EquippedTrail
			elseif category == "Auras" then
				return data2.EquippedAura
			end

			return data2.EquippedSkin
		end

		local function ApplyResponse(data2, flag: boolean?)
			editable = data2.Editable
			v6 = data2

			if flag == true then
				Notify(data2.Message, data2.Ok)
			elseif not data2.Ok then
				data.NotifyProfileError(data2.Message)
			end

			fn()
		end

		local function Refresh()
			if RunService:IsServer() or not clientEvent then
				return
			end

			clientEvent:Fire({
				UserId = data.UserId
			}):andThen(ApplyResponse):catch(function(p)
				Notify(`Failed to load cosmetics: {tostring(p)}`, false)
			end)
		end

		local function RunAction(action: string, p2: string)
			if editable and clientEvent2 then
				clientEvent2:Fire({
					UserId = data.UserId,
					Category = category,
					Key = p2,
					Action = action
				}):andThen(function(data2)
					editable = data2.Editable
					v6 = data2
					Notify(data2.Message, data2.Ok)
					fn()
				end):catch(function(p3)
					Notify(`Failed to change cosmetic: {tostring(p3)}`, false)
				end)
			end
		end

		object:AddTitle(function(object2)
			object2:SetTitle("Owned cosmetics")
		end)
		object:AddDropdown(function(object2)
			object2:SetText("Category"):SetChoiceList({ "Trails", "Auras", "Treadmills" }):SetSelected(category):SetOnChanged(function(p)
				category = p
				v4 = v2[category][1] or ""
				v7:SetChoiceList(v2[category]):SetSelected(v4)
				fn()
			end)
		end)
		local v8 = nil
		local v9 = nil
		object:AddSplit(function(p)
			p.LeftComponents:AddField(function(object2)
				v8 = object2
				object2:SetText("Equipped"):SetValue(""):SetEnabled(false)
			end)
			p.RightComponents:AddField(function(object2)
				v9 = object2
				object2:SetText("Owned"):SetValue(""):SetEnabled(false)
			end)
		end)
		object:AddField(function(object2)
			object2:SetTextVisible(false):SetPlaceholder("search..."):SetOnChangedRaw(function(value)
				v5 = string.lower(value)
				fn()
			end)
		end)
		local v10 = object:AddList(function(object2)
			object2:SetSizeY(145)
		end)

		fn = function()
			for _, v11 in v10.Components:GetAll() do
				v11:Destroy()
			end

			local v11 = v6

			if v11 then
				local owned = GetOwned(v11) -- equivalent call inferred; original call site unknown
				local equipped = GetEquipped(v11) -- equivalent call inferred; original call site unknown
				local v14 = v8
				local displayName = GetDisplayName(category, equipped) -- equivalent call inferred; original call site unknown
				v14:SetValue(displayName)
				v9:SetValue((tostring(#owned)))
				local count = 0

				for _, v17 in owned do
					local displayName2 = GetDisplayName(category, v17) -- equivalent call inferred; original call site unknown
					local details = GetDetails(category, v17)
					local v21 = string.lower((`{displayName2} {v17} {details}`))

					if not (v5 == "" or string.find(v21, v5, 1, true)) then
						continue
					end

					count += 1
					local v23 = details
					local v24 = displayName2
					local v25 = v17 == equipped
					local v26 = v17
					v10.Components:AddBox(function(object2)
						object2:SetBackgroundTransparency(count % 2 == 0 and 0.95 or 1)
						object2.Components:AddSplit(function(object3)
							object3:SetLeftSizePercent(0.72)
							object3.LeftComponents:AddText(function(object4)
								object4:SetText((`{v24}{v25 and "  [Equipped]" or ""}{v23 == "" and "" or `  |  {v23}`}`)):SetYSize(22)
							end)
							object3.RightComponents:AddButton(function(object4)
								object4:SetButtonText("Revoke"):SetYSize(22):SetEnabled(editable and v26 ~= GetDefault(category)):SetEnabledPermission("cui.inspect.cosmetics.write"):DoNeedConfirmation(true):SetButtonCallback(function()
									RunAction("Revoke", v26)
								end)
							end)
						end)
					end)
				end

				if count == 0 then
					v10.Components:AddText(function(object2)
						object2:SetText(#owned ~= 0 and "No cosmetics match this search." or `No owned {string.lower(category)}.`)
					end)
				end

				fn2()
			else
				v8:SetValue("")
				v9:SetValue("")
				v10.Components:AddText(function(object2)
					object2:SetText("Loading cosmetics...")
				end)
			end
		end

		object:AddTitle(function(object2)
			object2:SetTitle("Grant cosmetic")
		end)
		v7 = object:AddDropdown(function(object2)
			object2:SetText("Cosmetic"):SetChoiceList(v2[category]):SetSelected(v4):SetOnChanged(function(p)
				v4 = p
			end)
		end)
		local v11 = object:AddButton(function(object2)
			object2:SetButtonText("Grant selected cosmetic"):SetYSize(22):SetEnabled(false):SetEnabledPermission("cui.inspect.cosmetics.write"):DoNeedConfirmation(true):SetButtonCallback(function()
				RunAction("Grant", v4)
			end)
		end)

		fn2 = function()
			v11:SetEnabled(editable and v4 ~= "")
		end

		object:AddButton(function(object2)
			object2:SetButtonText("Refresh cosmetics"):SetYSize(22):SetEnabledPermission("cui.inspect.cosmetics"):SetButtonCallback(Refresh)
		end)
		data.PresenceChanged:Connect(Refresh)
		fn()
		Refresh()
	end
}