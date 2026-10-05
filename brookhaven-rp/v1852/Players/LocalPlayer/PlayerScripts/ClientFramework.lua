local now = os.clock()
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LogService = game:GetService("LogService")
local Framework = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("Shared"):WaitForChild("Framework"):WaitForChild("Framework"))
local packages = ReplicatedStorage:WaitForChild("Packages")
local Promise = require(packages:WaitForChild("Promise"))
local Remotes = require(packages:WaitForChild("Remotes"))
local Stats = game:GetService("Stats")
Promise.new(function(callback, _)
	task.wait(30)
	callback()
end):andThen(function()
	local Players = game:GetService("Players")

	if #Players:GetPlayers() == 0 then
		return
	end

	if Framework.CurrentState ~= Framework.States.Done then
		warn("Framework failed to boot for client!")
		local LogService2 = game:GetService("LogService")
		Remotes.fireServer(
			"ClientFrameworkFailure",
			Framework.CurrentState,
			LogService2:GetLogHistory(),
			Framework.getBootLog(),
			Framework.getModulesHasNotLoadedYet()
		)
	end
end)
local ClientTimingsController = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("Client"):WaitForChild("Telemetry"):WaitForChild("ClientTimingsController"))
ClientTimingsController.StopWithStartTime("FrameworkRequired", now)
local v = {
	["not enough memory"] = true,
	["Failed to translate string with key: InGame.ConnectionError.DisconnectOutOfMemoryKeepPlayingLeave"] = true
}
local lastTime = tick()
LogService.MessageOut:Connect(function(message, _)
	if not v[message] then
		return
	end

	v[message] = nil
	Remotes.fireServer("MemoryReport", {
		message = message,
		totalMemoryMb = Stats:GetTotalMemoryUsageMb(),
		sessionDuration = tick() - lastTime
	})
end)

-- equivalent calls inferred from this helper; original call sites unknown
local function arrayInsert(list, items)
	for _, item in pairs(items) do
		table.insert(list, item)
	end
end

local client = ReplicatedStorage.Modules:WaitForChild("Client")
local components = client:WaitForChild("Components")
local v2 = { client, components }
arrayInsert(v2, Framework.Constants.SharedDirectories) -- equivalent call inferred; original call site unknown
local v3 = { ReplicatedStorage:WaitForChild("Modules"):WaitForChild("Client"):WaitForChild("Components") }
arrayInsert(v3, Framework.Constants.SharedBlacklistDirectories) -- equivalent call inferred; original call site unknown
ClientTimingsController.Start("GameSdkRequired")
local GameSdkClientInitializer = require(client:WaitForChild("GameSdkClientInitializer"))
ClientTimingsController.Stop("GameSdkRequired")
ClientTimingsController.Start("GameSdkInitialized")
GameSdkClientInitializer.Init()
ClientTimingsController.Stop("GameSdkInitialized")
ClientTimingsController.Start("FrameworkPromiseModulesWait")
Framework.promiseWaitForModuleScriptTotals(v2):await()
ClientTimingsController.Stop("FrameworkPromiseModulesWait")
ClientTimingsController.Start("FrameworkBooted")
Framework.boot(v2, v3)
ClientTimingsController.Stop("FrameworkBooted")
ClientTimingsController.Start("ComponentsRequired")

for _, moduleScript in components:GetDescendants() do
	if not moduleScript:IsA("ModuleScript") then
		continue
	end

	local lastTime2 = os.clock()
	require(moduleScript)

	if os.clock() - lastTime2 > 2 then
		warn("[CLIENT FRAMEWORK] Component " .. moduleScript.Name .. " took too long to require!")
	end
end

ClientTimingsController.Stop("ComponentsRequired")
ClientTimingsController.StopWithStartTime("FrameworkCompleted", now)