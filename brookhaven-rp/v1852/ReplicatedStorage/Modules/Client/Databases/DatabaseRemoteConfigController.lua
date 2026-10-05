local DatabaseRemoteConfigController = {}
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local RemoteConfig = require(ReplicatedStorage.Modules.Shared.RemoteConfig)
local Logger = require(ReplicatedStorage.Packages.Logger)
local Signal = require(ReplicatedStorage.Packages.Signal)
local TableUtil = require(ReplicatedStorage.Packages.TableUtil)
local Remotes = require(ReplicatedStorage.Packages.Remotes)
local ClientTimingsController = require(ReplicatedStorage.Modules.Client.Telemetry.ClientTimingsController)
local flag = false
DatabaseRemoteConfigController.OnLoaded = Signal.new()
local v = {}

local function buildPublicModulesList()
	v = {}

	for _, moduleScript in ReplicatedStorage.Modules.Shared.DB:GetDescendants() do
		if not moduleScript:IsA("ModuleScript") then
			continue
		end

		local success, result = pcall(require, moduleScript)

		if success and typeof(result) == "table" and result.isPublic then
			table.insert(v, {
				script = moduleScript,
				mod = result
			})
		end
	end
end

local function checkAllDatabasesLoaded()
	if flag then
		return
	end

	if #v == 0 then
		buildPublicModulesList()
	end

	for _, v2 in v do
		if not v2.mod.isLoaded then
			return
		end
	end

	flag = true
	ClientTimingsController.Stop("DatabasesLoaded")
	DatabaseRemoteConfigController.OnLoaded:Fire()
end

function DatabaseRemoteConfigController.IsLoaded()
	return flag
end

function DatabaseRemoteConfigController.LoadDatabase(moduleScript)
	local module = require(moduleScript)
	local remoteConfigDirectory = module.remoteConfigDirectory
	RemoteConfig.getLiveOpsPath(remoteConfigDirectory):andThen(function(copy)
		if module.middlewares then
			if module.makeCopy then
				copy = TableUtil.Copy(copy, true)
			end

			for _, middleware in pairs(module.middlewares) do
				copy = middleware(copy)
			end
		end

		module.cache = copy
		module.isLoaded = true
		checkAllDatabasesLoaded()
	end):catch(function(p)
		if not RunService:IsStudio() then
			Logger.warn("Failed to load remote config path", remoteConfigDirectory, p)
		end

		task.wait(1)
		DatabaseRemoteConfigController.LoadDatabase(moduleScript)
	end)
end

function DatabaseRemoteConfigController.refreshDatabase()
	buildPublicModulesList()

	for _, v2 in v do
		v2.mod.isLoaded = false
	end

	for _, v2 in v do
		DatabaseRemoteConfigController.LoadDatabase(v2.script)
	end
end

function DatabaseRemoteConfigController.FrameworkStart()
	ClientTimingsController.Start("DatabasesLoaded")
	buildPublicModulesList()
	DatabaseRemoteConfigController.refreshDatabase()
	Remotes.connect("RefreshDatabase", function()
		flag = false
		ClientTimingsController.Start("DatabasesLoaded")
		DatabaseRemoteConfigController.refreshDatabase()
	end)
end

return DatabaseRemoteConfigController