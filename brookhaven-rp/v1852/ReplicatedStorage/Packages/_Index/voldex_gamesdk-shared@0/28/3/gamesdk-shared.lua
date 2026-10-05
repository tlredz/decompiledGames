local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Loader = require(script:WaitForChild("Loader"))
local isServer = RunService:IsServer()
local isClient = RunService:IsClient()
local class = {}
class.__index = class
class.Instance = script
class._initialized = false
class._configuration = nil

-- equivalent calls inferred from this helper; original call sites unknown
local function erroro(p)
	error("[GameSdk - Init] " .. p)
end

local function _assertInitialized(flag: boolean, flag2: boolean, p: string)
	if flag ~= flag2 then
		erroro(p) -- equivalent call inferred; original call site unknown
	end
end

local function getModules()
	if isServer then
		local serverPackages = game.ServerStorage:FindFirstChild("ServerPackages") or game.ServerStorage:FindFirstChild("Packages")

		if serverPackages == nil then
			return nil
		end

		local GameSdk = require(serverPackages:FindFirstChild("GameSdk"))
		return GameSdk:FindFirstChild("Modules")
	elseif isClient then
		return script:FindFirstChild("Modules")
	end
end

function class:Configuration(configuration)
	self._configuration = configuration
	return self
end

function class:Init()
	if self._initialized ~= false then
		error("[GameSdk - Init] Already initialized")
	end

	if isServer and self._configuration == nil then
		error("[GameSdk - Init] Missing server configuration")
	end

	if isServer and self._configuration ~= nil and not self._configuration._isServer then
		error("[GameSdk - Init] Configuration must be of type server")
	end

	if isClient and self._configuration ~= nil and not self._configuration._isClient then
		error("[GameSdk - Init] Configuration must be of type client")
	end

	if self._configuration ~= nil then
		self._configuration:Validate()
	end

	if isClient and not self:WaitForServerLoad() then
		error("[GameSdk - Init] Server game sdk failed to load, was it initialized or errored?")
	end

	local modules = getModules()

	if modules == nil then
		error("[GameSdk - Init] Failed to find modules folder")
	end

	self._initialized = true

	if not Loader.Boot({ modules }) or Loader.GetState() ~= Loader.States.Done then
		erroro("Failed to boot, last known state: " .. Loader.GetState()) -- equivalent call inferred; original call site unknown
	end

	local name = isServer and ".SdkLoaded" or ".ClientSdkLoaded"
	local v2 = ReplicatedStorage:FindFirstChild(name) or Instance.new("BoolValue", ReplicatedStorage)
	v2.Name = name
	v2.Value = true
	v2.Parent = ReplicatedStorage

	if isServer then
		print("[GameSdk - Server] Initialized! v0.28.3")
		return self
	end

	print("[GameSdk - Client] Initialized! v0.28.3")
	return self
end

function class:GetConfiguration()
	if self._initialized ~= true then
		error("[GameSdk - Init] Tried to get configuration but sdk is not initialized, call initialize first")
	end

	return self._configuration
end

function class:IsDebug()
	if self._initialized ~= true then
		error("[GameSdk - Init] Tried to get debug value but sdk is not initialized, call initialize first")
	end

	local configuration = self:GetConfiguration()

	if configuration == nil then
		return false
	end

	return configuration:IsDebug()
end

function class:WaitForLoad(p: number?)
	local v = p == nil and 30 or p

	if isServer then
		return self:WaitForServerLoad(v)
	end

	return ReplicatedStorage:WaitForChild(".ClientSdkLoaded", v) ~= nil
end

function class:WaitForServerLoad(p: number?)
	return ReplicatedStorage:WaitForChild(".SdkLoaded", p == nil and 30 or p) ~= nil
end

local object = setmetatable({}, class)

for _, child in script:GetChildren() do
	object[child.Name] = child
end

object.Modules = getModules()
return object