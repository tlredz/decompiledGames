local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local AdminRemote = require(ReplicatedStorage._FRAMEWORK.Features.Admins.AdminRemote)
local AdminAbuseEvent = require(ReplicatedStorage._FRAMEWORK.Features.Admins.AdminAbuseEvent)
local AdminAbuseTreadmill = require(ReplicatedStorage._FRAMEWORK.Features.Admins.AdminAbuseTreadmill)
local eventShops = require(ReplicatedStorage._FRAMEWORK.Features.eventShops)
local Lib = {}

-- equivalent calls inferred from this helper; original call sites unknown
local function Unavailable(detail: string)
	return {
		Available = false,
		Status = "Unavailable",
		Detail = detail,
		UntilTimestamp = nil
	}
end

function Lib.FormatRemaining(value: number?, p: number?)
	if type(value) ~= "number" then
		return "No expiry"
	end

	local v = math.max(0, (math.floor(value - (p or os.time()))))
	return (`{math.floor(v / 60)}m {v % 60}s remaining`)
end

local function GetBindable(childName: string)
	local bindableFunction = ServerScriptService:FindFirstChild(childName)

	if bindableFunction and bindableFunction:IsA("BindableFunction") then
		return bindableFunction
	end

	return nil
end

local function ReadSnapshot()
	local eventCoins = Unavailable("Event coins system is not configured in this place") -- equivalent call inferred; original call site unknown
	local events = ServerScriptService:FindFirstChild("Events")
	local eventCoinsServer = events and events:FindFirstChild("EventCoinsServer")
	local eventCoinsControl = eventCoinsServer and eventCoinsServer:FindFirstChild("EventCoinsControl")

	if eventCoinsControl and eventCoinsControl:IsA("ModuleScript") then
		local success, result = pcall(require, eventCoinsControl)

		if success then
			local activeEvent = result:GetActiveEvent()
			local forcedUntil = result:GetForcedUntil()
			local isForcedActive = result:IsForcedActive()
			eventCoins = {
				Available = true,
				Status = 0,
				Detail = 0,
				UntilTimestamp = 0
			}
			local status

			if activeEvent then
				if isForcedActive then
					status = `{activeEvent} | Storm forced active`
				else
					status = `{activeEvent} | Following schedule`
				end
			else
				status = "No coin event running"
			end

			eventCoins.Status = status
			eventCoins.Detail = not isForcedActive and "No manual override" or Lib.FormatRemaining(forcedUntil)

			if not isForcedActive then
				forcedUntil = nil
			end

			eventCoins.UntilTimestamp = forcedUntil
		end
	end

	local v2 = ServerScriptService:FindFirstChild("ItemsShopAdminRestock") ~= nil
	local shopIds = eventShops.getShopIds()
	local v3 = #shopIds > 0
	local shops = {
		Available = v2 or v3,
		Status = v2 and v3 and "Both APIs ready" or v2 and "Item shop ready" or v3 and "Event shops ready" or "Unavailable",
		Detail = `Item shop: {v2 and "ready" or "missing"} | Event shops: {not v3 and "none" or table.concat(shopIds, ", ")}`,
		UntilTimestamp = nil
	}
	local adminSlots = {
		main = {
			Available = true,
			Status = "Inactive",
			Detail = "Main slot is free",
			UntilTimestamp = nil
		},
		event = {
			Available = true,
			Status = "Inactive",
			Detail = "Event slot is free",
			UntilTimestamp = nil
		},
		overlay = {
			Available = true,
			Status = "Inactive",
			Detail = "Overlay slot is free",
			UntilTimestamp = nil
		}
	}
	local adminModules = {}
	local success, result = pcall(AdminAbuseEvent.getModules)

	if success then
		for _, v7 in result do
			table.insert(adminModules, {
				Name = v7.name,
				DisplayName = v7.displayName,
				Source = v7.source,
				Slot = v7.slot,
				Hidden = v7.hidden,
				LoadError = v7.loadError
			})
		end
	else
		local main = Unavailable(`Admin Abuse feature catalog failed: {tostring(result)}`) -- equivalent call inferred; original call site unknown
		adminSlots.main = main
		adminSlots.event = table.clone(main)
		adminSlots.overlay = table.clone(main)
	end

	local success2, result2 = pcall(AdminAbuseEvent.getActiveStates)

	if success2 then
		for _, v7 in result2 do
			local untilTimestamp

			if v7.durationSeconds then
				untilTimestamp = v7.startedAt + v7.durationSeconds
			end

			local v9 = adminSlots[v7.slot]
			v9.Status = v7.name
			v9.Detail = `{v7.source == "framework" and "Framework" or "Legacy"} | {Lib.FormatRemaining(untilTimestamp)}`
			v9.UntilTimestamp = untilTimestamp
		end
	else
		local main = Unavailable(`Admin Abuse feature state failed: {tostring(result2)}`) -- equivalent call inferred; original call site unknown
		adminSlots.main = main
		adminSlots.event = table.clone(main)
		adminSlots.overlay = table.clone(main)
	end

	local state = AdminAbuseTreadmill.getState()
	local adminAbuseTreadmill = {
		Available = state.available and state.ready,
		Status = not state.ready and "Loading" or state.active and "Active" or state.available and "Inactive" or "Unavailable",
		Detail = 0,
		UntilTimestamp = 0
	}
	local detail

	if state.ready then
		if state.active then
			detail = Lib.FormatRemaining(state.expiresAt)
		else
			detail = state.available and "Ready to start" or "Treadmill model or workspace folder is missing"
		end
	else
		detail = "Waiting for the initial global-state read"
	end

	adminAbuseTreadmill.Detail = detail
	adminAbuseTreadmill.UntilTimestamp = state.expiresAt
	return {
		Ok = true,
		Message = "",
		Timestamp = os.time(),
		EventCoins = eventCoins,
		Shops = shops,
		AdminSlots = adminSlots,
		AdminAbuseTreadmill = adminAbuseTreadmill,
		AdminModules = adminModules
	}
end

local function RunAction(data)
	if data.System == "EventCoins" then
		local eventCoinsAdmin = ServerScriptService:FindFirstChild("EventCoinsAdmin")

		if not (eventCoinsAdmin and eventCoinsAdmin:IsA("BindableFunction")) then
			eventCoinsAdmin = nil
		end

		if not eventCoinsAdmin then
			return false, "Event coins API is unavailable"
		end

		local v = data.Action == "start" and "startstorm" or data.Action == "stop" and "stopstorm" or nil

		if not v then
			return false, "Unsupported event coins action"
		end

		local success, result, v2 = pcall(eventCoinsAdmin.Invoke, eventCoinsAdmin, v, data.DurationSeconds)
		local v3 = success and result == true

		if success then
			return v3, (tostring(v2 or v))
		end

		return v3, (tostring(result))
	elseif data.System == "ItemShop" then
		local itemsShopAdminRestock = ServerScriptService:FindFirstChild("ItemsShopAdminRestock")

		if itemsShopAdminRestock and itemsShopAdminRestock:IsA("BindableEvent") then
			itemsShopAdminRestock:Fire(data.Mode or "normal", string.lower(data.Scope or "Server"))
			return true, "Item shop restocked"
		else
			return false, "Item shop API is unavailable"
		end
	elseif data.System == "EventShop" then
		if type(data.Shop) == "string" then
			return eventShops.runAdminAction(data.Shop, {
				kind = "restock"
			})
		end

		return false, "Select an event shop"
	else
		if data.System == "AdminAbuse" then
			if data.Action == "start" then
				if type(data.Module) ~= "string" or data.Module == "" then
					return false, "Select a module"
				end

				local isGlobal = data.isGlobal ~= false
				local v

				if isGlobal then
					v = AdminAbuseEvent.startGlobally
				else
					v = AdminAbuseEvent.start
				end

				local success, result, v2 = pcall(v, data.Module, data.DurationSeconds)

				if not success then
					return false, (tostring(result))
				end

				local v3 = isGlobal and "globally" or "on this server"

				if result then
					return result, (`Started {data.Module} {v3}`)
				end

				return result, v2 or "The module could not be started"
			elseif data.Action == "stopModule" then
				if type(data.Module) ~= "string" or data.Module == "" then
					return false, "Select a module"
				end

				local success, result, v = pcall(AdminAbuseEvent.stopModule, data.Module, "manual")

				if not success then
					return false, (tostring(result))
				end

				if result then
					return result, (`Stopped {data.Module}`)
				end

				return result, v or `Could not stop {data.Module}`
			elseif data.Action == "stopAll" then
				local success, result, v = pcall(AdminAbuseEvent.stopAllGlobally, "manual")

				if not success then
					return false, (tostring(result))
				end

				if result then
					return result, "Emergency stop broadcast to all Admin Abuse slots"
				end

				return result, v or "Emergency stop failed"
			end
		elseif data.System == "AdminAbuseTreadmill" then
			if data.Action == "start" then
				return AdminAbuseTreadmill.start(data.DurationSeconds)
			end

			if data.Action == "forceStop" then
				return AdminAbuseTreadmill.stop()
			end

			return false, "Unsupported Admin Abuse treadmill action"
		end

		return false, "Unknown LiveOps action"
	end
end

Lib.GetSnapshot = AdminRemote.RegisterClientEvent("AdminMenu_LiveOps_Get", "cui.liveops", false, function()
	return (ReadSnapshot())
end)
Lib.ExecuteAction = AdminRemote.RegisterClientEvent(
	"AdminMenu_LiveOps_Action",
	"cui.liveops.manage",
	true,
	function(_, p)
		local success, result, v = pcall(RunAction, p)
		local ok = success and result == true
		local message

		if success then
			message = tostring(v or "")
		else
			message = tostring(result or "")
		end

		if message == "" then
			ok = false
			message = "An error occured, check console."
		end

		if not ok then
			warn((`[LiveOpsMenu] {p.System}/{p.Action} failed: {message}`))
		end

		return {
			Ok = ok,
			Message = message,
			Snapshot = ReadSnapshot()
		}
	end
)
Lib.SeekAdminAbuseTimeline = AdminRemote.RegisterClientEvent(
	"AdminMenu_LiveOps_SeekAdminAbuseTimeline",
	"cui.liveops.adminAbuse.timeline",
	false,
	function(_, p)
		if type(p) ~= "table" or type(p.ElapsedSeconds) ~= "number" then
			return {
				Ok = false,
				Message = "ElapsedSeconds must be a number"
			}
		end

		local success, result, v = pcall(AdminAbuseEvent.seekMainEvent, p.ElapsedSeconds)

		if not success then
			warn((`[LiveOpsMenu] Admin Abuse timeline seek failed: {tostring(result)}`))
			return {
				Ok = false,
				Message = tostring(result)
			}
		end

		if result then
			return {
				Ok = true,
				Message = ""
			}
		end

		return {
			Ok = false,
			Message = v or "The Admin Abuse timeline could not be moved"
		}
	end
)
return Lib