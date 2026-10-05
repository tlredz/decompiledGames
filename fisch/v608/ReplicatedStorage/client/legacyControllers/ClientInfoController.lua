local ReplicatedStorage = game:GetService("ReplicatedStorage")
local packages = ReplicatedStorage.packages
local input = packages.Input
local Net = require(packages.Net)
local module = require(input)
local preferredInput = module.PreferredInput
return {
	Start = function(_)
		local remoteFunction = Net:RemoteFunction("ClientInfo/GetPreferredInput")

		remoteFunction.OnClientInvoke = function()
			return preferredInput.Current
		end
	end
}