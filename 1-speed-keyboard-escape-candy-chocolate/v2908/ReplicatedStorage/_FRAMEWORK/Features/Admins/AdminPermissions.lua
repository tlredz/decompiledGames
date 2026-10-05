local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ServerScriptService = game:GetService("ServerScriptService")
local FeatureManager = require(ReplicatedStorage._FRAMEWORK.Libraries.FeatureManager)
local StringUtils = require(ReplicatedStorage._FRAMEWORK.Libraries.Basics.StringUtils)
local TableUtils = require(ReplicatedStorage._FRAMEWORK.Libraries.Basics.TableUtils)
local Promise = require(ReplicatedStorage.Utilities.Promise)
local Signal = require(ReplicatedStorage.Utilities.Signal)
local remo = require(ReplicatedStorage.Packages.remo)
local t = require(ReplicatedStorage.Packages.t)
local LoggerManager = require(ReplicatedStorage._FRAMEWORK.Libraries.LoggerManager)
local AdminPermissions = {}
local logger = LoggerManager.createLogger(script.Name, {
	feature = script:GetFullName()
})
local v = Signal.new()
AdminPermissions.remotes = remo.createRemotes({
	GetConfig = remo.remote().returns().middleware(remo.throttleMiddleware({
		throttle = 1
	})),
	SetStudioPermissions = remo.remote(t.array(t.string), t.boolean).returns().middleware(remo.throttleMiddleware({
		throttle = 0.25
	}))
})
local AdminConfig

if RunService:IsServer() then
	AdminConfig = require(ServerScriptService.AdminConfig)
else
	AdminConfig = nil
end

local v2 = nil
local v3 = {}
local values = {}
local v4 = {}

local function isValidPermission(value: string)
	if value == "*" then
		return true
	end

	if value == "" or StringUtils.startsWith(value, ".") or StringUtils.endsWith(value, ".") or value:find(
		"..",
		1,
		true
	) then
		return false
	end

	local v5 = value:find("*", 1, true)

	if v5 == nil then
		return true
	elseif v5 == #value then
		return (StringUtils.endsWith(value, ".*"))
	else
		return false
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function declarePermission(value: string)
	local v5 = string.lower(value)

	if not isValidPermission(v5) then
		return false
	end

	v3[v5] = true
	return true
end

local function permissionGrants(value: string, value2: string)
	if value == "*" then
		return true
	end

	local v5 = string.lower(value)
	local v6 = string.lower(value2)

	if not (isValidPermission(v5) and isValidPermission(v6)) then
		return false
	end

	if v5 == v6 then
		return true
	end

	if StringUtils.endsWith(v5, ".*") then
		local v7 = v5:sub(1, -2)

		if StringUtils.startsWith(v6, v7) then
			return true
		end
	end

	return not StringUtils.endsWith(v6, ".*") and StringUtils.startsWith(v5, v6 .. ".")
end

-- equivalent calls inferred from this helper; original call sites unknown
local function permissionListGrants(items, item: string)
	for _, item2 in items do
		if permissionGrants(item2, item) then
			return true
		end
	end

	return false
end

local function normalizePermissions(list)
	if #list > 512 then
		return nil, "A Studio override cannot contain more than 512 permissions."
	end

	local v5 = {}
	local result = {}

	for _, v6 in list do
		local v7 = string.lower(v6)

		if #v7 > 128 or not isValidPermission(v7) then
			return nil, (`Invalid permission: {v6}`)
		end

		if v5[v7] then
			continue
		end

		v5[v7] = true
		table.insert(result, v7)
	end

	table.sort(result)
	return result, nil
end

local function isStudioTestUserId(p: number)
	local isStudio = RunService:IsStudio()

	if isStudio then
		if p < 0 and p == p then
			isStudio = p % 1 == 0
		else
			isStudio = false
		end
	end

	return isStudio
end

local function getRoleByUserId(p, p2: number)
	local isStudio = RunService:IsStudio()

	if isStudio then
		if p2 < 0 and p2 == p2 then
			isStudio = p2 % 1 == 0
		else
			isStudio = false
		end
	end

	if isStudio and p.ROLES.Creator and p.PERMISSIONS.Creator then
		return "Creator"
	end

	if p2 ~= p2 or p2 == 1e999 or p2 == -1e999 or p2 <= 0 or p2 % 1 ~= 0 then
		return nil
	end

	local priority = -1e999
	local v5 = nil

	for k, v6 in p.ROLES do
		if v6.Priority <= priority then
			continue
		end

		for _, userId in v6.UserIds do
			if userId ~= p2 then
				continue
			end

			priority = v6.Priority
			v5 = k
			break
		end
	end

	return v5
end

local function getPermissionsByUserId(p, p2: number)
	local roleByUserId = getRoleByUserId(p, p2)
	local v5

	if not roleByUserId then
		return {}
	end

	v5 = p.PERMISSIONS[roleByUserId]
	return v5 or {}
end

local function getEffectivePermissionsByUserId(p, p2: number)
	local v5

	if RunService:IsStudio() then
		v5 = v4[p2]
	end

	return v5 or getPermissionsByUserId(p, p2)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getServerAdminConfig()
	assert(RunService:IsServer() and AdminConfig ~= nil, "AdminPermissions server config is unavailable")
	return AdminConfig
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getAvailableConfig()
	if RunService:IsServer() then
		return AdminConfig
	end

	return v2
end

local function createConfigSnapshot(data)
	local v5 = {}
	local v6 = {}

	-- equivalent calls inferred from this helper; original call sites unknown
	local function addPermission(value: string)
		local v7 = string.lower(value)

		if v5[v7] then
			return
		end

		v5[v7] = true
		table.insert(v6, v7)
	end

	for k in v3 do
		addPermission(k) -- equivalent call inferred; original call site unknown
	end

	for _, v7 in data.PERMISSIONS do
		for _, v8 in v7 do
			addPermission(v8) -- equivalent call inferred; original call site unknown
		end
	end

	table.sort(v6)
	return (TableUtils.Lock(TableUtils.Copy({
		ROLES = data.ROLES,
		PERMISSIONS = data.PERMISSIONS,
		GIVE_LIMITS = data.GIVE_LIMITS,
		ALL_PERMISSIONS = v6
	}, true)))
end

function AdminPermissions.permissionGrants(p: string, p2: string)
	return (permissionGrants(p, p2))
end

function AdminPermissions.permissionListGrants(items, p: string)
	for _, item in items do
		if permissionGrants(item, p) then
			return true
		end
	end

	return false
end

function AdminPermissions.getConfig()
	return v2
end

function AdminPermissions.registerPermission(value: string)
	local v5 = string.lower(value)

	if not isValidPermission(v5) then
		return false
	end

	v3[v5] = true
	return true
end

function AdminPermissions.linkCommandToPermission(value: string, value2: string)
	local v5 = string.lower(value)
	local v6 = string.lower(value2)
	assert(v5 ~= "", "Cmdr command name cannot be empty")
	assert(values[v5] == nil, (`Cmdr command {value} is already linked to {values[v5]}`))
	local v7 = declarePermission(v6) -- equivalent call inferred; original call site unknown
	assert(v7, (`Invalid permission {value2} for Cmdr command {value}`))
	values[v5] = v6
end

function AdminPermissions.getPermissionForCommand(value: string)
	return values[string.lower(value)]
end

function AdminPermissions.fillPermissionToNonLinkedCommands(items)
	for _, item in items do
		local v5 = string.lower(item)

		if values[v5] ~= nil then
			continue
		end

		local formatted = `cmdr.command.{v5}`
		local v6 = declarePermission(formatted) -- equivalent call inferred; original call site unknown
		assert(v6, (`Could not generate a permission for Cmdr command {item}`))
		values[v5] = formatted
	end
end

function AdminPermissions.getAllPermissions()
	local availableConfig = getAvailableConfig() -- equivalent call inferred; original call site unknown

	if not availableConfig then
		return {}
	end

	local v5 = {}
	local v6 = {}

	-- equivalent calls inferred from this helper; original call sites unknown
	local function addPermission(value: string)
		local v7 = string.lower(value)

		if v5[v7] then
			return
		end

		v5[v7] = true
		table.insert(v6, v7)
	end

	if availableConfig.ALL_PERMISSIONS then
		for _, v7 in availableConfig.ALL_PERMISSIONS do
			addPermission(v7) -- equivalent call inferred; original call site unknown
		end
	else
		for _, v7 in availableConfig.PERMISSIONS do
			for _, v8 in v7 do
				addPermission(v8) -- equivalent call inferred; original call site unknown
			end
		end
	end

	for k in v3 do
		addPermission(k) -- equivalent call inferred; original call site unknown
	end

	table.sort(v6)
	return v6
end

function AdminPermissions.getRole(p: number)
	local availableConfig = getAvailableConfig() -- equivalent call inferred; original call site unknown

	if availableConfig then
		return (getRoleByUserId(availableConfig, p))
	end

	return nil
end

function AdminPermissions.getRank(p: number)
	local availableConfig = getAvailableConfig() -- equivalent call inferred; original call site unknown

	if not availableConfig then
		return 0
	end

	local roleByUserId = getRoleByUserId(availableConfig, p)

	if roleByUserId then
		return availableConfig.ROLES[roleByUserId].Priority
	end

	return 0
end

function AdminPermissions.getPermissions(p: number)
	local availableConfig = getAvailableConfig() -- equivalent call inferred; original call site unknown

	if not availableConfig then
		return {}
	end

	local v5

	if RunService:IsStudio() then
		v5 = v4[p]
	end

	return table.clone(v5 or getPermissionsByUserId(availableConfig, p))
end

function AdminPermissions.setStudioPermissions(p)
	assert(RunService:IsClient(), "AdminPermissions.setStudioPermissions can only be called on the client")
	assert(RunService:IsStudio(), "AdminPermissions.setStudioPermissions is only available in Studio")
	local localPlayer = Players.LocalPlayer
	assert(localPlayer ~= nil, "AdminPermissions.setStudioPermissions requires a local player")
	local v5

	if p == nil then
		v5 = {}
	else
		local v6
		v5, v6 = normalizePermissions(p)

		if v5 == nil then
			return Promise.resolve(false, v6)
		end
	end

	local v6 = p == nil
	return (AdminPermissions.remotes.SetStudioPermissions:request(v5, v6):andThen(function(p2, p3)
		if not p2 then
			return p2, p3
		end

		local v7 = v4
		local userId = localPlayer.UserId
		local v8

		if not v6 then
			v8 = v5
		end

		v7[userId] = v8
		local v9 = v

		if v9 then
			v9:FireImmediate(localPlayer.UserId)
		end

		return p2, p3
	end))
end

function AdminPermissions.subscribeToPermissionChanges(callback)
	assert(RunService:IsClient(), "AdminPermissions.subscribeToPermissionChanges can only be called on the client")
	local connection = assert(v, "AdminPermissions has not initialized"):Connect(callback)
	return function()
		connection:Disconnect()
	end
end

function AdminPermissions.hasPermission(p: number, value: string)
	local v5 = string.lower(value)

	if isValidPermission(v5) then
		v3[v5] = true
	end

	local availableConfig = getAvailableConfig() -- equivalent call inferred; original call site unknown

	if not availableConfig then
		return false
	end

	local v6

	if RunService:IsStudio() then
		v6 = v4[p]
	end

	for _, v7 in v6 or getPermissionsByUserId(availableConfig, p) do
		if permissionGrants(v7, value) then
			return true
		end
	end

	return false
end

function AdminPermissions.hasAnyPermission(p: number, items)
	for _, item in items do
		local v5 = string.lower(item)

		if isValidPermission(v5) then
			v3[v5] = true
		end
	end

	local availableConfig = getAvailableConfig() -- equivalent call inferred; original call site unknown

	if not availableConfig then
		return false
	end

	local v5

	if RunService:IsStudio() then
		v5 = v4[p]
	end

	local v6 = v5 or getPermissionsByUserId(availableConfig, p)

	for _, item in items do
		-- equivalent call inferred; original call site unknown
		if permissionListGrants(v6, item) then
			return true
		end
	end

	return false
end

function AdminPermissions.hasAllPermissions(p: number, items)
	for _, item in items do
		local v5 = string.lower(item)

		if isValidPermission(v5) then
			v3[v5] = true
		end
	end

	local availableConfig = getAvailableConfig() -- equivalent call inferred; original call site unknown

	if not availableConfig then
		return false
	end

	local v5

	if RunService:IsStudio() then
		v5 = v4[p]
	end

	local v6 = v5 or getPermissionsByUserId(availableConfig, p)

	for _, item in items do
		-- equivalent call inferred; original call site unknown
		if not permissionListGrants(v6, item) then
			return false
		end
	end

	return true
end

FeatureManager.RegisterFeature(script.Name, {
	Priority = -960,
	OnInit = function()
		if not RunService:IsServer() then
			AdminPermissions.remotes.GetConfig:request():andThen(function(p)
				if p == nil then
					return
				end

				v2 = TableUtils.Lock(p)
				local localPlayer = Players.LocalPlayer

				if localPlayer then
					v:FireImmediate(localPlayer.UserId)
				end
			end)
			return
		end

		assert(ReplicatedStorage:GetAttribute("CMDR_Ready") == true, "Cmdr must initialize before AdminPermissions")
		v2 = createConfigSnapshot(getServerAdminConfig())
		AdminPermissions.remotes.GetConfig:onRequest(function(p)
			if #getPermissionsByUserId(getServerAdminConfig(), p.UserId) > 0 then
				logger:print("Gave permissions to", p.Name)
				return v2
			else
				return nil
			end
		end)
		AdminPermissions.remotes.SetStudioPermissions:onRequest(function(p, p2, flag: boolean)
			if not RunService:IsStudio() then
				return false, "Studio permission overrides are disabled."
			end

			if flag then
				v4[p.UserId] = nil
				return true, nil
			end

			local permissions, v6 = normalizePermissions(p2)

			if permissions == nil then
				return false, v6
			end

			v4[p.UserId] = permissions
			return true, nil
		end)
		Players.PlayerRemoving:Connect(function(player)
			v4[player.UserId] = nil
		end)
	end
})
return AdminPermissions