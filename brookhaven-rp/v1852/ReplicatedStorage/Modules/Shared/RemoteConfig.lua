local RemoteConfig = {}
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local packages = ReplicatedStorage:WaitForChild("Packages")
require(packages.t)
local Promise = require(packages.Promise)
local Logger = require(packages.Logger)
local GameSdkShared = require(packages.GameSdkShared)
local RemoteConfig2 = require(GameSdkShared.Modules.RemoteConfig)
RemoteConfig.Packages = {
	LiveOps = "brookhaven"
}
RemoteConfig.PackagesData = {
	[RemoteConfig.Packages.LiveOps] = {
		UrlName = "brookhaven"
	}
}

function RemoteConfig.assertPackage(p: string)
	if not RemoteConfig.PackagesData[p] then
		Logger.error((`Invalid package name {p}`))
	end
end

function RemoteConfig.getLiveOpsPath(p: string?, callback)
	return RemoteConfig2.Get(p, RemoteConfig.Packages.LiveOps):andThen(function(p2)
		return Promise.new(function(callback2, callback3)
			if callback then
				local v2, v3 = callback(p2)

				if not v2 then
					callback3(("Path %q failed interface check: %s"):format(p, v3))
					return
				end
			end

			callback2(p2)
		end)
	end)
end

function RemoteConfig.onRemoteConfigChanged(onChanged)
	if RunService:IsClient() then
		Logger.error("RemoteConfig.onRemoteConfigChanged is not supported on the client currently")
	end

	return RemoteConfig2.Changed:Connect(onChanged)
end

return RemoteConfig