local ReplicatedStorage = game:GetService("ReplicatedStorage")
local EventInfoService = require(ReplicatedStorage:WaitForChild("SharedServices"):WaitForChild("EventInfoService"))
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local remotes = ReplicatedStorage2:WaitForChild("Remotes")
local ReplicatedStorage3 = game:GetService("ReplicatedStorage")
local Sync = require(ReplicatedStorage3:WaitForChild("Database"):WaitForChild("Sync"))
local ReplicatedStorage4 = game:GetService("ReplicatedStorage")
require(ReplicatedStorage4:WaitForChild("Types"):WaitForChild("EventType"))
local events = remotes:WaitForChild("Events")

local function didEventStart(p)
	return p.Status == "Started"
end

local function didEventEnd(p)
	return p.Status == "Ended"
end

local function StartEvent(p: string)
	local event = EventInfoService:GetEvent(p)
	local eventStartInfo = event.EventStartInfo

	if eventStartInfo then
		if eventStartInfo.Items then
			for k, item in eventStartInfo.Items do
				for k2, v in item do
					Sync[k][k2] = v
				end
			end
		end

		if eventStartInfo.ShopData then
			for k, v in eventStartInfo.ShopData do
				Sync.NewShop[k] = v
			end
		end
	end

	EventInfoService:_StartEvent(event)
end

local function EndEvent(p: string, p2)
	local event = EventInfoService:GetEvent(p)
	local shopData = event.EventStartInfo and event.EventStartInfo.ShopData
	local shopData2 = p2.EventStartInfo and p2.EventStartInfo.ShopData

	if shopData then
		for k in shopData do
			local newShop = Sync.NewShop
			local v

			if shopData2 then
				v = shopData2[k] or nil
			end

			newShop[k] = v
		end
	end

	EventInfoService:RegisterEvent(p, p2)
	EventInfoService:_EndEvent(p2)
end

local function UpdateEvent(k: string, p)
	local event = EventInfoService:GetEvent(k)

	if event then
		if event.Status == "NotStarted" and p.Status == "Started" then
			EventInfoService:RegisterEvent(k, p)
			StartEvent(k)
		else
			if event.Status == "Ended" or p.Status ~= "Ended" then
				return
			end

			EndEvent(k, p)
		end
	else
		EventInfoService:RegisterEvent(k, p)

		if p.Status == "Started" then
			StartEvent(k)
		elseif p.Status == "Ended" then
			StartEvent(k)
			EndEvent(k, p)
		end
	end
end

local function onInitialize()
	local v = events:WaitForChild("GetEvents"):InvokeServer()

	for k, v2 in v do
		UpdateEvent(k, v2)
	end

	events:WaitForChild("EventChanged").OnClientEvent:Connect(UpdateEvent)
	EventInfoService.Initialized = true
end

onInitialize()