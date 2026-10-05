local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local packages = ReplicatedStorage.packages
local Signal = require(packages.Signal)
local Net = require(packages.Net)
local State = require(packages.State)
local sharedPersonalAquarium = ReplicatedStorage.shared.modules.SharedPersonalAquarium
require(sharedPersonalAquarium.SharedTypes)
require("@self/Types")
local module = require("@self/Data")
local module2 = require("@self/Network")
local remoteFunction = Net:RemoteFunction("PersonalAquarium/WaitForRootPart")
local remoteEvent = Net:RemoteEvent("UpdateVisitorState")
local active = Workspace:WaitForChild("active")

local function togglePOIs(p)
	if not active then
		return
	end

	for _, billboardGui in active:GetDescendants() do
		if billboardGui.Name == "POIHeader" and billboardGui:IsA("BillboardGui") then
			billboardGui.AlwaysOnTop = not p
		end
	end
end

local PersonalAquariumController = {}

function PersonalAquariumController.Start(_)
	PersonalAquariumController.LocalPlayerInAquarium = State.new(false)
	module.Hitch(function(cache)
		PersonalAquariumController.Cache = cache
		PersonalAquariumController.ProfileCacheChangedSignal:Fire(cache)
	end)
	remoteFunction.OnClientInvoke = module2.waitForModelAsync
	remoteEvent.OnClientEvent:Connect(function(p)
		PersonalAquariumController.LocalPlayerInAquarium:set(p)
	end)
	PersonalAquariumController.LocalPlayerInAquarium:observe(togglePOIs)
end

PersonalAquariumController.ProfileCacheChangedSignal = Signal.new()
return PersonalAquariumController