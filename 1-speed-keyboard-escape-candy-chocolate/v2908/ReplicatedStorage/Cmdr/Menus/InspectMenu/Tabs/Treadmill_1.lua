local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ServerScriptService = game:GetService("ServerScriptService")
local AdminRemote = require(ReplicatedStorage._FRAMEWORK.Features.Admins.AdminRemote)
require(ReplicatedStorage.CUI)
local ProfileAccess = require(script.Parent.Parent.ProfileAccess)
require(ReplicatedStorage.Cmdr.Menus.InspectMenu.Types)
local BoostsManager = RunService:IsServer() and require(ServerScriptService.BoostsManager)
local WebhookLogger = RunService:IsServer() and require(ServerScriptService.WebhookLogger)
local v = {
	"Gold",
	"Diamond",
	"Candy",
	"Admin"
}
local v2 = {
	Gold = {
		Label = "Gold Treadmill",
		PermanentKey = "ManualGoldAccess",
		Activate = function(p)
			BoostsManager.SessionGoldAccess[p.UserId] = true
		end,
		Deactivate = function(p)
			BoostsManager.SessionGoldAccess[p.UserId] = nil
			BoostsManager.ActiveGoldTreadmill[p.UserId] = nil
		end,
		Refresh = function(p)
			BoostsManager:RefreshGoldStatus(p)
		end
	},
	Diamond = {
		Label = "Diamond Treadmill",
		PermanentKey = "ManualDiamondAccess",
		Activate = function(p)
			BoostsManager:ActivateDiamondTreadmill(p)
		end,
		Deactivate = function(p)
			BoostsManager.ActiveDiamondTreadmill[p.UserId] = nil
		end,
		Refresh = function(p)
			BoostsManager:RefreshDiamondStatus(p)
		end
	},
	Candy = {
		Label = "Candy Treadmill",
		PermanentKey = "ManualCandyAccess",
		Activate = function(p)
			BoostsManager:ActivateCandyTreadmill(p)
		end,
		Deactivate = function(p)
			BoostsManager.ActiveCandyTreadmill[p.UserId] = nil
		end,
		Refresh = function(p)
			BoostsManager:RefreshCandyStatus(p)
		end
	},
	Admin = {
		Label = "Admin Treadmill",
		PermanentKey = "ManualAdminAccess",
		Activate = function(p)
			BoostsManager:ActivateAdminTreadmill(p)
		end,
		Deactivate = function(p)
			BoostsManager.ActiveAdminTreadmill[p.UserId] = nil
		end,
		Refresh = function(p)
			BoostsManager:RefreshAdminStatus(p)
		end
	}
}
local v3 = {}

-- equivalent calls inferred from this helper; original call sites unknown
local function SetSessionGrant(userId: number, treadmill: string, flag: boolean)
	local v4 = v3[userId]

	if flag then
		if not v4 then
			v4 = {}
			v3[userId] = v4
		end

		v4[treadmill] = true
	elseif v4 then
		v4[treadmill] = nil

		if next(v4) == nil then
			v3[userId] = nil
		end
	end
end

local function GetTargetReference(userId: number)
	local localPlayer = ProfileAccess.GetLocalPlayer(userId)
	local name

	if localPlayer then
		name = localPlayer.Name
	else
		name = tostring(userId)
	end

	if not localPlayer then
		pcall(function()
			name = Players:GetNameFromUserIdAsync(userId)
		end)
	end

	return {
		Name = name,
		UserId = userId
	}
end

local function BuildResponse(userId: number, p: string?, ok: boolean?)
	local v4 = ProfileAccess.Read(userId)
	local states = {}

	for _, v6 in v do
		local v7 = v2[v6]
		states[v6] = {
			Session = v3[userId] and v3[userId][v6] == true and true or false,
			Forever = v4.Data and v4.Data[v7.PermanentKey] == true and true or false
		}
	end

	if ok == nil then
		ok = v4.Ok
	end

	return {
		Ok = ok,
		Message = p or v4.Message,
		Editable = v4.Ok and (v4.IsLocal or not v4.IsSessionActive),
		Online = ProfileAccess.GetLocalPlayer(userId) ~= nil,
		States = states
	}
end

local clientEvent = AdminRemote.RegisterClientEvent(
	`Inspect_{script.Name}_GetTreadmills`,
	"cui.inspect.treadmill",
	false,
	function(_, p)
		return (BuildResponse(p.UserId))
	end
)
local clientEvent2 = AdminRemote.RegisterClientEvent(
	`Inspect_{script.Name}_SetTreadmill`,
	"cui.inspect.treadmill.write",
	true,
	function(p, data)
		local v4 = v2[data.Treadmill]

		if not v4 then
			return (BuildResponse(data.UserId, "Unknown treadmill", false))
		end

		if data.Mode ~= "Session" and data.Mode ~= "Forever" then
			return (BuildResponse(data.UserId, "Unknown treadmill mode", false))
		end

		local localPlayer = ProfileAccess.GetLocalPlayer(data.UserId)

		if data.Mode == "Session" then
			if not localPlayer then
				return (BuildResponse(data.UserId, "Session access requires the player to be in this server", false))
			end

			if data.Value then
				local v6, v7 = ProfileAccess.Write(data.UserId, {
					[v4.PermanentKey] = false
				})

				if not v6 then
					return (BuildResponse(data.UserId, v7, false))
				end

				v4.Deactivate(localPlayer)
				local userId2 = data.UserId
				local treadmill = data.Treadmill
				local v8 = v3[userId2]

				if not v8 then
					v8 = {}
					v3[userId2] = v8
				end

				v8[treadmill] = true
				v4.Activate(localPlayer)
				v4.Refresh(localPlayer)
				WebhookLogger:LogTreadmill(p, localPlayer, v4.Label, "Session")
				return (BuildResponse(data.UserId, `{v4.Label} enabled for this session`, true))
			else
				SetSessionGrant(data.UserId, data.Treadmill, false) -- equivalent call inferred; original call site unknown
				v4.Deactivate(localPlayer)
				v4.Refresh(localPlayer)
				WebhookLogger:LogTreadmill(p, localPlayer, v4.Label, "Remove session")
				return (BuildResponse(data.UserId, `{v4.Label} session access removed`, true))
			end
		else
			local v6, v7 = ProfileAccess.Write(data.UserId, {
				[v4.PermanentKey] = data.Value
			})

			if not v6 then
				return (BuildResponse(data.UserId, v7, false))
			end

			SetSessionGrant(data.UserId, data.Treadmill, false) -- equivalent call inferred; original call site unknown

			if localPlayer then
				v4.Deactivate(localPlayer)
				v4.Refresh(localPlayer)
			end

			WebhookLogger:LogTreadmill(
				p,
				localPlayer or GetTargetReference(data.UserId),
				v4.Label,
				data.Value and "Perm" or "Remove"
			)
			local userId3 = data.UserId
			local v9

			if data.Value then
				v9 = `{v4.Label} enabled forever`
			else
				v9 = `{v4.Label} access removed`
			end

			return (BuildResponse(userId3, v9, true))
		end
	end
)

if RunService:IsServer() then
	Players.PlayerRemoving:Connect(function(player)
		v3[player.UserId] = nil
	end)
end

return {
	DisplayName = "Treadmill",
	Permission = "cui.inspect.treadmill",
	Order = 30,
	Setup = function(object, data)
		local NotificationSystem

		if RunService:IsClient() then
			NotificationSystem = require(ReplicatedStorage.NotificationSystem)
		else
			NotificationSystem = nil
		end

		local v4 = {}
		local v5 = {}
		local v6 = false
		local editable = false
		local online = false

		local function Notify(p: string, flag: boolean)
			if not NotificationSystem or p == "" then
				return
			end

			local v7

			if flag then
				v7 = Color3.fromRGB(100, 255, 100)
			else
				v7 = Color3.fromRGB(255, 100, 100)
			end

			NotificationSystem:ShowGeneralNotification(p, v7, 4)
		end

		local function ApplyResponse(data2, flag: boolean?)
			v6 = true
			editable = data2.Editable
			online = data2.Online

			for _, v7 in v do
				local v8 = data2.States[v7] or {
					Session = false,
					Forever = false
				}
				v4[v7]:SetValue(v8.Session):SetEnabled(editable and online)
				v5[v7]:SetValue(v8.Forever):SetEnabled(editable)
			end

			v6 = false

			if flag == true then
				Notify(data2.Message, data2.Ok)
			elseif not data2.Ok then
				data.NotifyProfileError(data2.Message)
			end
		end

		local function Refresh()
			if RunService:IsServer() or not clientEvent then
				return
			end

			clientEvent:Fire({
				UserId = data.UserId
			}):andThen(ApplyResponse):catch(function(p)
				Notify(`Failed to load treadmill access: {tostring(p)}`, false)
			end)
		end

		local function Change(treadmill: string, mode: string, flag: boolean)
			if v6 or not (editable and clientEvent2) or mode == "Session" and not online then
				return
			end

			clientEvent2:Fire({
				UserId = data.UserId,
				Treadmill = treadmill,
				Mode = mode,
				Value = flag
			}):andThen(function(p3)
				ApplyResponse(p3, true)
			end):catch(function(p3)
				Notify(`Failed to change treadmill access: {tostring(p3)}`, false)
				Refresh()
			end)
		end

		for k, v7 in v do
			local v9 = k
			local v10 = v2[v7]
			local v11 = v7
			object:AddBox(function(object2)
				object2:SetBackgroundTransparency(v9 % 2 == 0 and 0.95 or 1)
				object2.Components:AddTitle(function(object3)
					object3:SetTitle(v10.Label)
				end)
				object2.Components:AddSplit(function(p)
					v4[v11] = p.LeftComponents:AddCheckbox(function(object3)
						object3:SetText("Session"):SetEnabled(false):SetEnabledPermission("cui.inspect.treadmill.write"):SetOnChanged(function(p2)
							Change(v11, "Session", p2)
						end)
					end)
					v5[v11] = p.RightComponents:AddCheckbox(function(object3)
						object3:SetText("Forever"):SetEnabled(false):SetEnabledPermission("cui.inspect.treadmill.write"):SetOnChanged(function(p2)
							Change(v11, "Forever", p2)
						end)
					end)
				end)
			end)
		end

		object:AddButton(function(object2)
			object2:SetButtonText("Refresh treadmills"):SetYSize(22):SetEnabledPermission("cui.inspect.treadmill"):SetButtonCallback(Refresh)
		end)

		if RunService:IsClient() then
			data.PresenceChanged:Connect(Refresh)
		end

		Refresh()
	end
}