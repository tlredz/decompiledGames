local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")
local CreateGui = require(script.Parent.CreateGui)
return function(registry)
	local cmdrClient = nil

	-- equivalent calls inferred from this helper; original call sites unknown
	local function Create(className, name, p)
		local instance = Instance.new(className)
		instance.Name = name
		instance.Parent = p or cmdrClient
		return instance
	end

	cmdrClient = script.Parent.CmdrClient
	cmdrClient.Parent = ReplicatedStorage
	local remoteFunction = Create("RemoteFunction", "CmdrFunction") -- equivalent call inferred; original call site unknown
	local remoteEvent = Create("RemoteEvent", "CmdrEvent") -- equivalent call inferred; original call site unknown
	Create("Folder", "Commands") -- equivalent call inferred; original call site unknown
	Create("Folder", "Types") -- equivalent call inferred; original call site unknown
	script.Parent.Shared.Parent = cmdrClient
	registry.ReplicatedRoot = cmdrClient
	registry.RemoteFunction = remoteFunction
	registry.RemoteEvent = remoteEvent
	registry:RegisterTypesIn(script.Parent.BuiltInTypes)
	script.Parent.BuiltInTypes:Destroy()
	script.Parent.BuiltInCommands.Name = "Server commands"

	if StarterGui:FindFirstChild("Cmdr") == nil then
		CreateGui()
	end
end