local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage:WaitForChild("Types"):WaitForChild("EventType"))
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local activeEvents = ReplicatedStorage2:WaitForChild("ActiveEvents")
local v = {}
local ActiveEventService = {
	EventAdded = Instance.new("BindableEvent"),
	EventChanged = Instance.new("BindableEvent"),
	EventUpdated = Instance.new("RemoteEvent"),
	GetMainEvent = function(_)
		for _, v2 in v do
			if v2.Priority == "Main" then
				return v2
			end
		end

		return nil
	end,
	GetActiveEvents = function(_)
		return v
	end
}

function ActiveEventService.BindClient(_)
	ActiveEventService.EventUpdated.OnClientEvent:Connect(function(p: string, p2)
		v[p] = p2
		ActiveEventService.EventChanged:Fire(p)
	end)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function onEventAdded(moduleScript)
	local name = moduleScript.Name
	local v2 = v
	local module = require(moduleScript)
	v2[name] = module
	ActiveEventService.EventAdded:Fire(name)
	ActiveEventService.EventChanged:Fire(name)
end

local function onInitialize()
	for _, child in activeEvents:GetChildren() do
		onEventAdded(child) -- equivalent call inferred; original call site unknown
	end

	activeEvents.ChildAdded:Connect(function(moduleScript)
		if not moduleScript:IsA("ModuleScript") then
			return
		end

		onEventAdded(moduleScript) -- equivalent call inferred; original call site unknown
	end)
end

onInitialize()
return ActiveEventService