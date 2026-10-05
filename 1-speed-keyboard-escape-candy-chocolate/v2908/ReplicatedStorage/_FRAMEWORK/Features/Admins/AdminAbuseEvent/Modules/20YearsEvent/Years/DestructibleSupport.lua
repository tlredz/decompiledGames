local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DefaultYearMap = require(script.Parent.DefaultYearMap)
local destructibleBuilds = require(ReplicatedStorage._FRAMEWORK.Libraries.destructibleBuilds)
require(script.Parent.Parent.Types)

-- equivalent calls inferred from this helper; original call sites unknown
local function findContainer(instance)
	local scriptables = instance:FindFirstChild("Scriptables")

	if scriptables then
		return (scriptables:FindFirstChild("Destructibles"))
	end

	return nil
end

local function attachClient(instance)
	local v = nil

	-- equivalent calls inferred from this helper; original call sites unknown
	local function tryStart()
		local container = findContainer(instance) -- equivalent call inferred; original call site unknown

		if container and not v then
			v = destructibleBuilds.startClient(container)
		end
	end

	local descendantAddedConnection = instance.DescendantAdded:Connect(function(descendant)
		if descendant.Name == "Destructibles" then
			tryStart() -- equivalent call inferred; original call site unknown
		end
	end)
	tryStart() -- equivalent call inferred; original call site unknown
	return function()
		descendantAddedConnection:Disconnect()

		if v then
			v()
			v = nil
		end
	end
end

local DestructibleSupport = {}

function DestructibleSupport.start(instance)
	local container = findContainer(instance) -- equivalent call inferred; original call site unknown

	if container then
		destructibleBuilds.prepareServer(container)
	end
end

function DestructibleSupport.startClient(p, p2: number)
	return DefaultYearMap.watchMap(p, p2, attachClient)
end

return DestructibleSupport