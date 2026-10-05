local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ServerScriptService = game:GetService("ServerScriptService")
local AdminRemote = require(ReplicatedStorage._FRAMEWORK.Features.Admins.AdminRemote)
local Config = require(ReplicatedStorage.Config)
require(ReplicatedStorage.CUI)
local EventsConfig = require(ReplicatedStorage.EventsConfig)
local Galaxies = require(ReplicatedStorage.Config.Galaxies)
local GalaxyProgressSchema = require(ReplicatedStorage.Config.Shared.GalaxyProgressSchema)
local ProfileAccess = require(script.Parent.Parent.ProfileAccess)
require(ReplicatedStorage.Cmdr.Menus.InspectMenu.Types)
local DataManager = RunService:IsServer() and require(ServerScriptService.DataManager)
local v = {
	"Level",
	"XP",
	"TotalXP",
	"Wins",
	"Rebirths",
	"Multiplier",
	"StepBonus",
	"Checkpoint",
	"timePlayed",
	"SpeedBoostTier",
	"ExtraSpeedBoostTier"
}
local v2 = {}

for _, v3 in v do
	v2[v3] = true
end

for _, currency in EventsConfig.Currencies do
	if v2[currency.Key] then
		continue
	end

	table.insert(v, currency.Key)
	v2[currency.Key] = true
end

local keys = {}
local keys2 = {}

for _, v5 in v do
	local v6

	if GalaxyProgressSchema.keySet[v5] then
		v6 = keys
	else
		v6 = keys2
	end

	table.insert(v6, v5)
end

local v5 = {
	XP = true,
	TotalXP = true,
	Wins = true
}
local v6 = {
	timePlayed = true,
	Multiplier = true,
	StepBonus = true,
	TotalXP = true,
	Checkpoint = true
}

-- equivalent calls inferred from this helper; original call sites unknown
local function GalaxyName(p: number)
	local v7 = Galaxies.get(p)

	if v7 then
		return v7.SHORT_NAME
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

local clientEvent = AdminRemote.RegisterClientEvent(
	`Inspect_{script.Name}_GetStats`,
	"cui.inspect.stats",
	false,
	function(_, p)
		local v7 = ProfileAccess.Read(p.UserId)
		local data = v7.Data
		local values = {}

		for _, v9 in keys2 do
			values[v9] = tonumber(data and data[v9]) or 0
		end

		local galaxyProgress = data and data.GalaxyProgress
		local galaxies = {}

		if galaxyProgress and next(galaxyProgress) then
			local v10 = {}

			for k in galaxyProgress do
				table.insert(v10, k)
			end

			table.sort(v10)

			for _, v11 in v10 do
				local v12 = galaxyProgress[v11]
				local values2 = {}

				for _, v14 in keys do
					values2[v14] = tonumber(v12[v14]) or 0
				end

				local name = GalaxyName(v11) -- equivalent call inferred; original call site unknown
				table.insert(galaxies, {
					Index = v11,
					Name = name,
					Values = values2
				})
			end
		else
			for _, v10 in keys do
				values[v10] = tonumber(data and data[v10]) or 0
			end
		end

		return {
			Ok = v7.Ok,
			Message = v7.Message,
			Editable = v7.Ok and (v7.IsLocal or not v7.IsSessionActive),
			IsLocal = v7.IsLocal,
			Values = values,
			Galaxies = galaxies
		}
	end
)
local clientEvent2 = AdminRemote.RegisterClientEvent(
	`Inspect_{script.Name}_SetStat`,
	"cui.inspect.stats.write",
	true,
	function(_, data)
		if not v2[data.Key] then
			return {
				Ok = false,
				Message = "Unknown numeric stat"
			}
		end

		if v6[data.Key] then
			return {
				Ok = false,
				Message = `{data.Key} is read-only`
			}
		end

		if data.Galaxy ~= nil and not GalaxyProgressSchema.keySet[data.Key] then
			return {
				Ok = false,
				Message = `{data.Key} is account-wide, not per-galaxy`
			}
		end

		if data.Value ~= data.Value or data.Value == 1e999 or data.Value == -1e999 then
			return {
				Ok = false,
				Message = "Value must be a finite number"
			}
		end

		local localPlayer = ProfileAccess.GetLocalPlayer(data.UserId)

		if data.Key == "Level" and localPlayer and data.Galaxy == Config.GALAXY_INDEX then
			DataManager:SetLevel(localPlayer, data.Value)
			DataManager:Save(localPlayer)
			return {
				Ok = true,
				Message = "Level, XP and TotalXP were updated together"
			}
		else
			if data.Key == "Level" then
				return {
					Ok = false,
					Message = "Level can only be changed for this server's galaxy, while the player is here"
				}
			end

			local ok, message = ProfileAccess.Write(data.UserId, {
				[data.Key] = data.Value
			}, data.Galaxy)
			return {
				Ok = ok,
				Message = message
			}
		end
	end
)
return {
	DisplayName = "Stats",
	Permission = "cui.inspect.stats",
	Order = 10,
	Setup = function(object, data)
		local NotificationSystem

		if RunService:IsClient() then
			NotificationSystem = require(ReplicatedStorage.NotificationSystem)
		else
			NotificationSystem = nil
		end

		local v7 = nil
		local v8 = {}
		local v9 = {}
		local v10 = {
			[Config.GALAXY_INDEX] = true
		}
		local v11 = false
		local editable = false
		local isLocal = false
		local v12 = false
		local v13 = ""

		local function onPresenceChanged() end

		local function fn() end

		local function Notify(p: string, flag: boolean)
			if not NotificationSystem or p == "" then
				return
			end

			local v14

			if flag then
				v14 = Color3.fromRGB(100, 255, 100)
			else
				v14 = Color3.fromRGB(255, 100, 100)
			end

			NotificationSystem:ShowGeneralNotification(p, v14, 4)
		end

		local function AddStatField(components, p: string, galaxy: number?, p3: number)
			local v14

			if p == "Level" then
				v14 = not isLocal or galaxy ~= Config.GALAXY_INDEX
			else
				v14 = false
			end

			local function ConfigureField(object2)
				object2:SetText(p):SetNumberFilter():SetValue(p3):SetOnChangedUnfocus(function(p4)
					if v12 or not (editable and clientEvent2) then
						return
					end

					clientEvent2:Fire({
						UserId = data.UserId,
						Key = p,
						Value = p4,
						Galaxy = galaxy
					}):andThen(function(p5)
						Notify(p5.Message, p5.Ok)
						onPresenceChanged()
					end):catch(function(p5)
						Notify(`Failed to update {p}: {tostring(p5)}`, false)
					end)
				end)
				object2:SetEnabled(editable and not (v6[p] or v14)):SetEnabledPermission("cui.inspect.stats.write")
			end

			local v15 = v8
			local v16 = {
				Key = p,
				Field = 0
			}
			local field

			if v5[p] then
				field = components:AddShortenedNumberField(ConfigureField)
			else
				field = components:AddNumberField(ConfigureField)
			end

			v16.Field = field
			table.insert(v15, v16)
		end

		local function Render(data2)
			v12 = true
			local scroll = v7:GetScroll()

			for _, v14 in v7.Components:GetAll() do
				v14:Destroy()
			end

			v8 = {}
			v9 = {}

			for _, galaxy in data2.Galaxies do
				local v14 = galaxy
				v7.Components:AddExpandable(function(object2)
					local v15 = v14.Index == Config.GALAXY_INDEX and "  (this server)" or ""
					object2:SetText((`{v14.Name}{v15}`))

					for k, v16 in keys do
						AddStatField(object2.Components, v16, v14.Index, v14.Values[v16])
					end

					object2:BindOnExpanded(function(p, p2)
						if p2 then
							v10[v14.Index] = p
						end
					end)

					if v10[v14.Index] then
						object2:SetExpanded(true, false, true)
					end

					table.insert(v9, {
						Name = v14.Name,
						Keys = keys,
						Component = object2
					})
				end)
			end

			if #data2.Galaxies == 0 then
				for _, v14 in keys do
					AddStatField(v7.Components, v14, nil, data2.Values[v14])
				end
			end

			if #keys2 > 0 then
				v7.Components:AddExpandable(function(object2)
					object2:SetText("Account-wide")

					for _, v14 in keys2 do
						AddStatField(object2.Components, v14, nil, data2.Values[v14])
					end

					object2:BindOnExpanded(function(p, p2)
						if p2 then
							v11 = p
						end
					end)

					if v11 then
						object2:SetExpanded(true, false, true)
					end

					table.insert(v9, {
						Name = "Account-wide",
						Keys = keys2,
						Component = object2
					})
				end)
			end

			v7:SetScroll(scroll)
			v12 = false
			fn()
		end

		onPresenceChanged = function()
			if RunService:IsServer() or not clientEvent then
				return
			end

			clientEvent:Fire({
				UserId = data.UserId
			}):andThen(function(data2)
				editable = data2.Editable
				isLocal = data2.IsLocal

				if not data2.Ok then
					data.NotifyProfileError(data2.Message)
				end

				Render(data2)
			end):catch(function(p)
				Notify(`Failed to load stats: {tostring(p)}`, false)
			end)
		end

		object:AddField(function(object2)
			object2:SetTextVisible(false):SetPlaceholder("search..."):SetOnChangedRaw(function(value)
				v13 = string.lower(value)
				fn()
			end)
		end)
		v7 = object:AddList(function(object2)
			object2:SetSizeY(230)
		end)

		fn = function()
			-- equivalent calls inferred from this helper; original call sites unknown
			local function Matches(value: string)
				return v13 == "" or string.find(string.lower(value), v13, 1, true) ~= nil
			end

			for _, v14 in v8 do
				v14.Field:SetVisible(Matches(v14.Key))
			end

			for _, v14 in v9 do
				local v15 = false

				for _, key in v14.Keys do
					v15 = v15 or Matches(key)
				end

				local component = v14.Component

				if not v15 then
					v15 = Matches(v14.Name)
				end

				component:SetVisible(v15)
			end
		end

		object:AddButton(function(object2)
			object2:SetButtonText("Refresh stats"):SetButtonCallback(onPresenceChanged):SetEnabledPermission("cui.inspect.stats")
		end)

		if RunService:IsClient() then
			data.PresenceChanged:Connect(onPresenceChanged)
		end

		onPresenceChanged()
	end
}