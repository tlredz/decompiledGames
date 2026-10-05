local LogService = game:GetService("LogService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local parentModule = require(script.Parent.Parent)
local Places = require(parentModule.Modules.Places)
local parent = script.Parent.Parent.Parent
local Promise = require(parent.Promise)
require(script.IntegrationTestContext)
local DeviceIntegrationTestContext = require(script.DeviceIntegrationTestContext)
local IntegrationTest = {
	DependsOn = { "Places" },
	_context = nil,
	_remote = nil,
	_actionRemoteFunc = nil,
	_submissionRemote = nil,
	_dataRemoteFunc = nil,
	_cachedTestConfigName = nil,
	_didTryFetchTestConfigName = false,
	_initialized = false
}

-- equivalent calls inferred from this helper; original call sites unknown
local function erroro(p)
	error("[GameSdk - IntegrationTest] " .. p)
end

local function _assertInitialized(flag: boolean, p: string)
	if IntegrationTest._initialized ~= flag then
		erroro(p) -- equivalent call inferred; original call site unknown
	end
end

local function runTest(moduleScript)
	local module = require(moduleScript)
	module.Run(IntegrationTest._context)
end

local function fetchTestConfigName()
	return Promise.new(function(callback, callback2)
		local v = IntegrationTest._dataRemoteFunc:InvokeServer()

		if v == nil then
			callback2("Failed to fetch test config name")
		end

		callback(v)
	end)
end

local function sendResultWithOutput(p: string, value: number?)
	local logHistory = LogService:GetLogHistory()
	local messages = {}

	for i = math.max(1, #logHistory - 1000 + 1), #logHistory do
		table.insert(messages, logHistory[i].message)
	end

	IntegrationTest._submissionRemote:FireServer(p, value or 0, messages)
end

local function onClientEvent(childName: string)
	if not Places.IsIntegrationTest() then
		return
	end

	local integrationTests = ReplicatedStorage:WaitForChild("IntegrationTests", 60)

	if integrationTests == nil then
		sendResultWithOutput("NotFound")
		return
	end

	local child = integrationTests:FindFirstChild(childName, true)

	if child == nil then
		sendResultWithOutput("NotFound")
		return
	end

	local lastTime = os.clock()
	Promise.try(runTest, child):timeout(600):andThen(function()
		task.wait(4)
		sendResultWithOutput("Passed", math.floor((os.clock() - lastTime) * 1000))
	end):catch(function(p)
		print(p, debug.traceback())
		task.wait(4)
		sendResultWithOutput("Failed", math.floor((os.clock() - lastTime) * 1000))
	end)
end

function IntegrationTest.Init()
	if not Places.IsIntegrationTest() then
		IntegrationTest._initialized = true
		return
	end

	IntegrationTest._remote = ReplicatedStorage:WaitForChild("GameSdkIntegrationTestRemoteEvent", 20)

	if IntegrationTest._remote == nil then
		error("[GameSdk - IntegrationTest] Failed to find remote event")
	end

	IntegrationTest._remote.OnClientEvent:Connect(onClientEvent)
	IntegrationTest._actionRemoteFunc = ReplicatedStorage:WaitForChild("GameSdkIntegrationTestActionRemoteFunction", 20)

	if IntegrationTest._actionRemoteFunc == nil then
		error("[GameSdk - IntegrationTest] Failed to find remote function")
	end

	IntegrationTest._context = DeviceIntegrationTestContext.new(IntegrationTest._actionRemoteFunc)
	IntegrationTest._submissionRemote = ReplicatedStorage:WaitForChild(
		"GameSdkIntegrationTestSubmissionRemoteEvent",
		20
	)

	if IntegrationTest._submissionRemote == nil then
		error("[GameSdk - IntegrationTest] Failed to find submission remote event")
	end

	IntegrationTest._dataRemoteFunc = ReplicatedStorage:WaitForChild("GameSdkIntegrationTestDataRemoteFunction", 20)

	if IntegrationTest._dataRemoteFunc == nil then
		error("[GameSdk - IntegrationTest] Failed to find data remote function")
	end

	IntegrationTest._initialized = true
end

function IntegrationTest.GetTestConfigName()
	if IntegrationTest._initialized ~= true then
		error("[GameSdk - IntegrationTest] Tried to get test config name before module is initialized, call initialize first")
	end

	if IntegrationTest._cachedTestConfigName ~= nil or IntegrationTest._didTryFetchTestConfigName then
		return IntegrationTest._cachedTestConfigName
	end

	IntegrationTest._didTryFetchTestConfigName = true

	if RunService:IsStudio() then
		local ephemeralTestConfig = ReplicatedStorage:FindFirstChild("EphemeralTestConfig")

		if ephemeralTestConfig == nil then
			return nil
		end

		local jSONDecode = HttpService:JSONDecode(ephemeralTestConfig.Value)

		if DateTime.now().UnixTimestamp >= jSONDecode.expiration then
			return nil
		else
			IntegrationTest._cachedTestConfigName = jSONDecode.config
		end
	end

	if not Places.IsIntegrationTest() then
		return IntegrationTest._cachedTestConfigName
	end

	local v, cachedTestConfigName = Promise.retryWithDelay(fetchTestConfigName, 3, 1):await()

	if not v then
		return nil
	end

	IntegrationTest._cachedTestConfigName = cachedTestConfigName
	return IntegrationTest._cachedTestConfigName
end

return IntegrationTest