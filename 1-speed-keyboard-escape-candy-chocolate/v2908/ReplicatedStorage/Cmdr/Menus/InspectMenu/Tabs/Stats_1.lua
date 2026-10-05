local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ServerScriptService = game:GetService("ServerScriptService")
local AdminRemote = require(ReplicatedStorage._FRAMEWORK.Features.Admins.AdminRemote)
require(ReplicatedStorage.CUI)
local EventsConfig = require(ReplicatedStorage.EventsConfig)
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
	"timePlayed",
	"SpeedBoostTier"
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

local v3 = {
	XP = true,
	TotalXP = true,
	Wins = true
}
local v4 = {
	timePlayed = true,
	Multiplier = true,
	StepBonus = true,
	TotalXP = true
}
local clientEvent = AdminRemote.RegisterClientEvent(
	`Inspect_{script.Name}_GetStats`,
	"cui.inspect.stats",
	false,
	function(_, p)
		local v5 = ProfileAccess.Read(p.UserId)
		local values = {}

		for _, v7 in v do
			values[v7] = tonumber(v5.Data and v5.Data[v7]) or 0
		end

		return {
			Ok = v5.Ok,
			Message = v5.Message,
			Editable = v5.Ok and (v5.IsLocal or not v5.IsSessionActive),
			Values = values
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

		if v4[data.Key] then
			return {
				Ok = false,
				Message = `{data.Key} is read-only`
			}
		end

		if data.Value ~= data.Value or data.Value == 1e999 or data.Value == -1e999 then
			return {
				Ok = false,
				Message = "Value must be a finite number"
			}
		end

		local localPlayer = ProfileAccess.GetLocalPlayer(data.UserId)

		if data.Key == "Level" and localPlayer then
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
					Message = "Level can only be changed while the player is in this server"
				}
			end

			local ok, message = ProfileAccess.Write(data.UserId, {
				[data.Key] = data.Value
			})
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

		local v5 = {}
		local editable = false
		local v6 = false
		local v7 = ""

		local function fn() end

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

		local function Refresh()
			if RunService:IsServer() or not clientEvent then
				return
			end

			v6 = true
			clientEvent:Fire({
				UserId = data.UserId
			}):andThen(function(data2)
				editable = data2.Editable

				if not data2.Ok then
					data.NotifyProfileError(data2.Message)
				end

				for k, v8 in v5 do
					v8:SetValue(data2.Values[k] or 0):SetEnabled(editable and not v4[k])
				end

				v6 = false
			end):catch(function(p)
				v6 = false
				Notify(`Failed to load stats: {tostring(p)}`, false)
			end)
		end

		object:AddField(function(object2)
			object2:SetTextVisible(false):SetPlaceholder("search..."):SetOnChangedRaw(function(value)
				v7 = string.lower(value)
				fn()
			end)
		end)
		object:AddList(function(object2)
			object2:SetSizeY(230)

			for _, v8 in v do
				local v9 = v8

				local function ConfigureField(object3)
					object3:SetText(v9):SetNumberFilter():SetEnabled(false):SetEnabledPermission("cui.inspect.stats.write"):SetOnChangedUnfocus(function(p)
						if v6 or not (editable and clientEvent2) then
							return
						end

						clientEvent2:Fire({
							UserId = data.UserId,
							Key = v9,
							Value = p
						}):andThen(function(p2)
							Notify(p2.Message, p2.Ok)
							Refresh()
						end):catch(function(p2)
							Notify(`Failed to update {v9}: {tostring(p2)}`, false)
						end)
					end)
				end

				local v10 = v5
				local v11

				if v3[v8] then
					v11 = object2.Components:AddShortenedNumberField(ConfigureField)
				else
					v11 = object2.Components:AddNumberField(ConfigureField)
				end

				v10[v8] = v11
			end
		end)

		fn = function()
			for k, v8 in v5 do
				v8:SetVisible(v7 == "" or string.find(string.lower(k), v7, 1, true) ~= nil)
			end
		end

		fn()
		object:AddButton(function(object2)
			object2:SetButtonText("Refresh stats"):SetEnabledPermission("cui.inspect.stats"):SetButtonCallback(Refresh)
		end)

		if RunService:IsClient() then
			data.PresenceChanged:Connect(Refresh)
		end

		Refresh()
	end
}