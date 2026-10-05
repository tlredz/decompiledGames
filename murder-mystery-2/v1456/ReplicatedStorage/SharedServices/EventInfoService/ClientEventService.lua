local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage:WaitForChild("Types"):WaitForChild("EventType"))
local v = {}
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local ReplicatedStorage3 = game:GetService("ReplicatedStorage")
local Sync = require(ReplicatedStorage3:WaitForChild("Database"):WaitForChild("Sync"))
local events = ReplicatedStorage2:WaitForChild("Remotes"):WaitForChild("Events")
local v2 = false
local ClientEventService = {
	GetEvents = function(_)
		return v
	end
}
local callbacks = {}

function ClientEventService.GetMainEvent(_)
	for _, v3 in v do
		if v3.EventStartInfo and v3.Priority == "Main" then
			return v3
		end
	end
end

function ClientEventService.OnEventStarted(_, callback)
	while not v2 do
		task.wait()
	end

	for _, v3 in v do
		if v3.EventStartInfo then
			callback(v3)
		end
	end

	table.insert(callbacks, callback)
end

local function StartEvent(p)
	local eventStartInfo = p.EventStartInfo

	if eventStartInfo then
		if eventStartInfo.Items then
			for k, item in eventStartInfo.Items do
				for k2, v3 in item do
					Sync[k][k2] = v3
				end
			end
		end

		if eventStartInfo.ShopData then
			for k, v3 in eventStartInfo.ShopData do
				Sync.NewShop[k] = v3
			end
		end
	end

	for _, v3 in callbacks do
		v3(p)
	end
end

local function onInitialize()
	v = events:WaitForChild("GetEvents"):InvokeServer()

	for _, v3 in v do
		if v3.EventStartInfo then
			StartEvent(v3)
		end
	end

	events:WaitForChild("EventChanged").OnClientEvent:Connect(function(p, p2)
		local v3 = v[p] and not v[p].EventStartInfo and p2.EventStartInfo and true or false
		v[p] = p2

		if v3 then
			StartEvent(p2)
		end
	end)
	v2 = true
	print("Events", v)
end

onInitialize()
return ClientEventService