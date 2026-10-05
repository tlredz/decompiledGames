local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local parentModule = require(script.Parent.Parent)
local parent = script.Parent.Parent.Parent
local Promise = require(parent.Promise)
local TableUtil = require(parent.TableUtil)
local FlagsUtil = require(parentModule.Utils.FlagsUtil)
local RemoteConfig = {
	_packages = {},
	_default = nil,
	_computedPathsCache = {},
	_resolvedFlagCache = {},
	_remote = nil,
	_remoteFetch = nil,
	_initialized = false,
	_updated = Instance.new("BindableEvent")
}
RemoteConfig.Changed = RemoteConfig._updated.Event

local function warno(...)
	warn("[GameSdk - RemoteConfig]", ...)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function erroro(p)
	error("[GameSdk - RemoteConfig] " .. p)
end

local function _assertInitialized(flag: boolean, p: string)
	if RemoteConfig._initialized ~= flag then
		erroro(p) -- equivalent call inferred; original call site unknown
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function clearResolvedFlagCache(p: string?)
	if p == nil then
		RemoteConfig._resolvedFlagCache = {}
	else
		RemoteConfig._resolvedFlagCache[p] = nil
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getResolvedFlagCache(p: string, resolvedFlagCacheKey: string)
	local v = RemoteConfig._resolvedFlagCache[p]

	if v == nil then
		return nil
	end

	return v[resolvedFlagCacheKey]
end

-- equivalent calls inferred from this helper; original call sites unknown
local function setResolvedFlagCache(p: string, resolvedFlagCacheKey: string, parsed)
	if RemoteConfig._resolvedFlagCache[p] == nil then
		RemoteConfig._resolvedFlagCache[p] = {}
	end

	RemoteConfig._resolvedFlagCache[p][resolvedFlagCacheKey] = parsed
end

local function fetchAndUpdate()
	local v, default = RemoteConfig._remoteFetch:InvokeServer()

	if v == nil then
		warno("Failed to fetch packages from the server")
		return
	end

	local packages = {}

	for k, v4 in v do
		packages[k] = TableUtil.Lock(v4)
	end

	RemoteConfig._packages = packages
	RemoteConfig._default = default
	RemoteConfig._computedPathsCache = {}
	RemoteConfig._resolvedFlagCache = {}
end

local function onClientEvent(p: string, p2)
	local v = RemoteConfig._packages[p] ~= nil
	RemoteConfig._packages[p] = TableUtil.Lock(p2)
	RemoteConfig._computedPathsCache[p] = nil

	if v then
		RemoteConfig._updated:Fire(p, p2)
	end

	clearResolvedFlagCache(p) -- equivalent call inferred; original call site unknown
end

function RemoteConfig.Init()
	if RemoteConfig._initialized ~= false then
		error("[GameSdk - RemoteConfig] Already initialized")
	end

	RemoteConfig._remote = ReplicatedStorage:WaitForChild("GameSdkRemoteConfigEvent", 20)

	if RemoteConfig._remote == nil then
		error("[GameSdk - RemoteConfig] Failed to find remote for remote config")
	end

	RemoteConfig._remote.OnClientEvent:Connect(onClientEvent)
	RemoteConfig._remoteFetch = ReplicatedStorage:WaitForChild("GameSdkRemoteConfigFunction", 20)

	if RemoteConfig._remoteFetch == nil then
		error("[GameSdk - RemoteConfig] Failed to find fetch remote for remote config")
	end

	task.spawn(fetchAndUpdate)
	RemoteConfig._initialized = true
end

function RemoteConfig.Get(value: string?, _default: string?)
	if RemoteConfig._initialized ~= true then
		error("[GameSdk - RemoteConfig] Tried to get config before module is initialized, call initialize first")
	end

	local v = value or ""

	if v:len() > 0 and string.sub(v, 1, 1) ~= "/" then
		v = "/" .. v
	end

	local v2 = string.gsub(v, "%s+", "-")
	local v3 = string.split(v2, "/")
	table.remove(v3, 1)
	return Promise.new(function(callback, callback2)
		if _default == nil then
			while RemoteConfig._default == nil do
				task.wait()
			end

			_default = RemoteConfig._default
		end

		local v4 = RemoteConfig._computedPathsCache[_default]

		if v4 == nil then
			RemoteConfig._computedPathsCache[_default] = {}
			v4 = RemoteConfig._computedPathsCache[_default]
		end

		if v4[v2] ~= nil then
			return callback(table.unpack(v4[v2]))
		end

		while RemoteConfig._packages[_default] == nil do
			task.wait()
		end

		local _package = RemoteConfig._packages[_default]

		if _package == nil then
			callback2(string.format("Failed to find tree for package %s", _default))
			return
		end

		local v5 = "/"

		for _, v6 in v3 do
			if v6 == "" then
				continue
			end

			local v7 = false

			for k, v8 in _package do
				local v9 = string.gsub(k, "%s+", "-")

				if not (string.upper(v9) == string.upper(v6) and type(v8) == "table") then
					continue
				end

				v5 ..= "/" .. k
				_package = v8
				v7 = true
			end

			if v7 then
				continue
			end

			callback2(string.format("Failed to find path %s in package %s", v2, _default))
			return
		end

		v4[v2] = { _package, v5 }
		callback(_package, v5)
	end)
end

function RemoteConfig.GetFlag(value: string, p: string?)
	if RemoteConfig._initialized ~= true then
		error("[GameSdk - RemoteConfig] Tried to get flag before module is initialized, call initialize first")
	end

	if type(value) == "string" and value ~= "" then
		return RemoteConfig.Get(FlagsUtil.getFlagsPath(), p):andThen(function(p2)
			local v = p or RemoteConfig._default

			if v == nil then
				return Promise.reject("Failed to resolve remote config package")
			end

			local flagDefinition = FlagsUtil.findFlagDefinition(p2, value)

			if flagDefinition == nil then
				return Promise.reject(string.format("Flag \"%s\" was not found", value))
			end

			local definition, v2 = FlagsUtil.parseDefinition(value, flagDefinition)

			if definition == nil then
				warno(v2)
				return Promise.reject(v2)
			end

			local GLOBAL_ROLLOUT_IDENTIFIER

			if FlagsUtil.isFullRollout(definition) then
				GLOBAL_ROLLOUT_IDENTIFIER = FlagsUtil.GLOBAL_ROLLOUT_IDENTIFIER
			elseif definition.rolloutScope == "server" then
				GLOBAL_ROLLOUT_IDENTIFIER = game.JobId
			else
				local localPlayer = Players.LocalPlayer

				if localPlayer == nil then
					warno("LocalPlayer is not available for player-based flag", value)
					return definition.default
				else
					GLOBAL_ROLLOUT_IDENTIFIER = tostring(localPlayer.UserId)
				end
			end

			local resolvedFlagCacheKey = FlagsUtil.getResolvedFlagCacheKey(value, GLOBAL_ROLLOUT_IDENTIFIER)
			local resolvedFlagCache = getResolvedFlagCache(v, resolvedFlagCacheKey) -- equivalent call inferred; original call site unknown

			if resolvedFlagCache ~= nil then
				return resolvedFlagCache
			end

			local parsed = FlagsUtil.resolveParsed(value, definition, GLOBAL_ROLLOUT_IDENTIFIER)

			if parsed == nil then
				return Promise.reject(string.format("Flag \"%s\" has an invalid definition", value))
			end

			setResolvedFlagCache(v, resolvedFlagCacheKey, parsed) -- equivalent call inferred; original call site unknown
			return parsed
		end)
	end

	return Promise.reject("Flag name must be a non-empty string")
end

return RemoteConfig