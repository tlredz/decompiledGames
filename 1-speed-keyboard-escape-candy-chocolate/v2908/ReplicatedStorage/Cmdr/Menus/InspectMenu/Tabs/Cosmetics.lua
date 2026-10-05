local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ServerScriptService = game:GetService("ServerScriptService")
local AdminRemote = require(ReplicatedStorage._FRAMEWORK.Features.Admins.AdminRemote)
local AuraConfig = require(ReplicatedStorage.FeatureConfigs.AuraConfig)
local Config = require(ReplicatedStorage.Config)
require(ReplicatedStorage.CUI)
local EventsConfig = require(ReplicatedStorage.EventsConfig)
local Galaxies = require(ReplicatedStorage.Config.Galaxies)
local ProfileAccess = require(script.Parent.Parent.ProfileAccess)
local Skins = require(ReplicatedStorage.FeatureConfigs.PersonalTreadmill.Skins)
local TrailConfig = require(ReplicatedStorage.FeatureConfigs.TrailConfig)
require(ReplicatedStorage.Cmdr.Menus.InspectMenu.Types)
local AuraManager = RunService:IsServer() and require(ServerScriptService.AuraManager)
local DataManager = RunService:IsServer() and require(ServerScriptService.DataManager)
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
local function GalaxyName(p: number)
	local v3 = Galaxies.get(p)

	if v3 then
		return v3.SHORT_NAME
	end

	return (`Galaxy {p}`)
end

local function SortedGalaxyIndices(items)
	local result = {}

	for k in items do
		table.insert(result, k)
	end

	table.sort(result)
	return result
end

-- equivalent calls inferred from this helper; original call sites unknown
local function CurrentGalaxyLoadout(list)
	for _, v3 in list do
		if v3.Index == Config.GALAXY_INDEX then
			return v3
		end
	end

	return list[1]
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
	local galaxyProgress = data2.GalaxyProgress
	local galaxies = {}

	if galaxyProgress and next(galaxyProgress) then
		local v4 = {}

		for k in galaxyProgress do
			table.insert(v4, k)
		end

		table.sort(v4)

		for _, v5 in v4 do
			local v6 = galaxyProgress[v5]
			local name = GalaxyName(v5) -- equivalent call inferred; original call site unknown
			local v7 = {
				Index = v5,
				Name = name,
				EquippedTrail = tostring(v6.EquippedTrail or "None"),
				TrailSkin = tostring(v6.TrailSkin or "None"),
				EquippedAura = tostring(v6.EquippedAura or "None"),
				AuraSkin = tostring(v6.AuraSkin or "None")
			}
			table.insert(galaxies, v7)
		end
	end

	local currentGalaxyLoadout = CurrentGalaxyLoadout(galaxies) -- equivalent call inferred; original call site unknown

	if ok == nil then
		ok = data.Ok
	end

	local v5 = {
		Ok = ok,
		Message = p or data.Message,
		Editable = data.Ok and (data.IsLocal or not data.IsSessionActive),
		OwnedTrails = SortedList(data2.OwnedTrails),
		OwnedAuras = SortedList(data2.OwnedAuras),
		OwnedSkins = SortedList(data2.OwnedTreadmillSkins),
		EquippedTrail = 0,
		EquippedAura = 0,
		EquippedSkin = 0,
		Galaxies = 0
	}
	local equippedTrail

	if currentGalaxyLoadout then
		equippedTrail = currentGalaxyLoadout.EquippedTrail
	else
		equippedTrail = tostring(data2.EquippedTrail or "None")
	end

	v5.EquippedTrail = equippedTrail
	local equippedAura

	if currentGalaxyLoadout then
		equippedAura = currentGalaxyLoadout.EquippedAura
	else
		equippedAura = tostring(data2.EquippedAura or "None")
	end

	v5.EquippedAura = equippedAura
	v5.EquippedSkin = tostring(data2.EquippedTreadmillSkin or "DefaultTreadmill")
	v5.Galaxies = galaxies
	return v5
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
		local v8 = data.Category == "Trails" and "TrailSkin" or data.Category == "Auras" and "AuraSkin" or nil
		local sortedList = SortedList(data2[v6])
		local equippedTreadmillSkin = tostring(data2.EquippedTreadmillSkin or default)

		if data.Action == "Grant" then
			if not table.find(sortedList, data.Key) then
				table.insert(sortedList, data.Key)
			end
		else
			if data.Key == default then
				return (ToResponse(v5, `Cannot revoke {default}`, false))
			end

			local index = table.find(sortedList, data.Key)

			if index then
				table.remove(sortedList, index)
			end

			if equippedTreadmillSkin == data.Key then
				equippedTreadmillSkin = default
			end
		end

		local v10, v11 = ProfileAccess.Apply(data.UserId, function(p)
			p[v6] = sortedList

			if data.Action == "Revoke" then
				if v8 then
					if data.Category == "Trails" then
						TrailManager.UnequipFromAllGalaxies(p, data.Key)
					else
						AuraManager.UnequipFromAllGalaxies(p, data.Key)
					end
				else
					p[v7] = equippedTreadmillSkin
				end
			end
		end)
		local localPlayer = ProfileAccess.GetLocalPlayer(data.UserId)

		if v10 and localPlayer then
			local store = DataManager:GetStore(localPlayer, v6)

			if store then
				store:Set(sortedList)
			end

			local v12 = {
				[v6] = sortedList
			}

			if data.Action == "Revoke" then
				if v8 then
					local store2 = DataManager:GetStore(localPlayer, v7)
					local store3 = DataManager:GetStore(localPlayer, v8)

					if store2 then
						store2:Set(store2:Get(default))
						v12[v7] = store2:Get(default)
					end

					if store3 then
						store3:Set(store3:Get("None"))
						v12[v8] = store3:Get("None")
					end
				else
					local store2 = DataManager:GetStore(localPlayer, v7)

					if store2 then
						store2:Set(equippedTreadmillSkin)
					end

					v12[v7] = equippedTreadmillSkin
				end
			end

			if data.Category == "Trails" then
				TrailManager:ApplyTrailVisual(localPlayer, TrailManager:GetEffectiveVisual(localPlayer))
			end

			if data.Category == "Auras" then
				AuraManager:ApplyAuraVisual(localPlayer, AuraManager:GetEffectiveVisual(localPlayer))
			end

			if data.Category == "Treadmills" then
				PersonalTreadmillManager:EquipSkin(localPlayer, equippedTreadmillSkin)
			end

			local remotes = ReplicatedStorage:FindFirstChild("Remotes")
			local updateUI = remotes and remotes:FindFirstChild("UpdateUI")

			if updateUI then
				updateUI:FireClient(localPlayer, v12)
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

		local function IsEquippedAnywhere(data2, p: string)
			if category == "Treadmills" then
				return data2.EquippedSkin == p
			end

			if #data2.Galaxies == 0 then
				local equipped = GetEquipped(data2) -- equivalent call inferred; original call site unknown
				return equipped == p
			else
				for _, galaxy in data2.Galaxies do
					if category == "Trails" then
						if galaxy.EquippedTrail == p or galaxy.TrailSkin == p then
							return true
						end
					elseif galaxy.EquippedAura == p or galaxy.AuraSkin == p then
						return true
					end
				end

				return false
			end
		end

		local function GalaxyCategoryKeys(data2)
			if category == "Trails" then
				return data2.EquippedTrail, data2.TrailSkin
			end

			return data2.EquippedAura, data2.AuraSkin
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
		local v10 = object:AddList(function(object2)
			object2:SetSizeY(0)
		end)
		local v11 = {
			[Config.GALAXY_INDEX] = true
		}
		object:AddField(function(object2)
			object2:SetTextVisible(false):SetPlaceholder("search..."):SetOnChangedRaw(function(value)
				v5 = string.lower(value)
				fn()
			end)
		end)
		local v12 = object:AddList(function(object2)
			object2:SetSizeY(145)
		end)

		fn = function()
			for _, v13 in v12.Components:GetAll() do
				v13:Destroy()
			end

			for _, v13 in v10.Components:GetAll() do
				v13:Destroy()
			end

			local v13 = v6

			if v13 then
				local owned = GetOwned(v13) -- equivalent call inferred; original call site unknown
				local displayName = GetEquipped(v13) -- equivalent call inferred; original call site unknown
				local v15

				if category == "Treadmills" then
					v15 = false
				else
					v15 = #v13.Galaxies > 0
				end

				local v16 = v8
				local v17 = category
				local v18 = v[v17] and v[v17][displayName]

				if type(v18) == "table" then
					displayName = tostring(v18.displayName or v18.name or displayName)
				end

				v16:SetValue(displayName)
				v9:SetValue((tostring(#owned)))

				if v15 then
					v10:SetSizeY(110)

					for _, galaxy in v13.Galaxies do
						local equippedTrail, trailSkin

						if category == "Trails" then
							equippedTrail = galaxy.EquippedTrail
							trailSkin = galaxy.TrailSkin
						else
							equippedTrail = galaxy.EquippedAura
							trailSkin = galaxy.AuraSkin
						end

						local v19 = galaxy
						v10.Components:AddExpandable(function(object2)
							local v22 = v19.Index == Config.GALAXY_INDEX and "  (this server)" or ""
							object2:SetText((`{v19.Name}{v22}`))
							object2.Components:AddText(function(object3)
								local v24 = category
								local displayName2 = equippedTrail
								local v25 = v[v24] and v[v24][displayName2]

								if type(v25) == "table" then
									displayName2 = tostring(v25.displayName or v25.name or displayName2)
								end

								object3:SetText((`Equipped: {displayName2}`)):SetYSize(20)
							end)
							object2.Components:AddText(function(object3)
								local v24 = category
								local displayName2 = trailSkin
								local v25 = v[v24] and v[v24][displayName2]

								if type(v25) == "table" then
									displayName2 = tostring(v25.displayName or v25.name or displayName2)
								end

								object3:SetText((`Skin: {displayName2}`)):SetYSize(20)
							end)
							object2:BindOnExpanded(function(p, p2)
								if p2 then
									v11[v19.Index] = p
								end
							end)

							if v11[v19.Index] then
								object2:SetExpanded(true, false, true)
							end
						end)
					end
				else
					v10:SetSizeY(0)
				end

				local count = 0

				for _, v19 in owned do
					local displayName2 = GetDisplayName(category, v19) -- equivalent call inferred; original call site unknown
					local details = GetDetails(category, v19)
					local v23 = string.lower((`{displayName2} {v19} {details}`))

					if not (v5 == "" or string.find(v23, v5, 1, true)) then
						continue
					end

					count += 1
					local v25 = details
					local v26 = displayName2
					local equippedAnywhere = IsEquippedAnywhere(v13, v19)
					local v28 = v19
					v12.Components:AddBox(function(object2)
						object2:SetBackgroundTransparency(count % 2 == 0 and 0.95 or 1)
						object2.Components:AddSplit(function(object3)
							object3:SetLeftSizePercent(0.72)
							object3.LeftComponents:AddText(function(object4)
								object4:SetText((`{v26}{equippedAnywhere and "  [Equipped]" or ""}{v25 == "" and "" or `  |  {v25}`}`)):SetYSize(22)
							end)
							object3.RightComponents:AddButton(function(object4)
								object4:SetButtonText("Revoke"):SetYSize(22):SetEnabled(editable and v28 ~= GetDefault(category)):SetEnabledPermission("cui.inspect.cosmetics.write"):DoNeedConfirmation(true):SetButtonCallback(function()
									RunAction("Revoke", v28)
								end)
							end)
						end)
					end)
				end

				if count == 0 then
					v12.Components:AddText(function(object2)
						object2:SetText(#owned ~= 0 and "No cosmetics match this search." or `No owned {string.lower(category)}.`)
					end)
				end

				fn2()
			else
				v8:SetValue("")
				v9:SetValue("")
				v10:SetSizeY(0)
				v12.Components:AddText(function(object2)
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
		local v13 = object:AddButton(function(object2)
			object2:SetButtonText("Grant selected cosmetic"):SetYSize(22):SetEnabled(false):SetEnabledPermission("cui.inspect.cosmetics.write"):DoNeedConfirmation(true):SetButtonCallback(function()
				RunAction("Grant", v4)
			end)
		end)

		fn2 = function()
			v13:SetEnabled(editable and v4 ~= "")
		end

		object:AddButton(function(object2)
			object2:SetButtonText("Refresh cosmetics"):SetYSize(22):SetEnabledPermission("cui.inspect.cosmetics"):SetButtonCallback(Refresh)
		end)
		data.PresenceChanged:Connect(Refresh)
		fn()
		Refresh()
	end
}