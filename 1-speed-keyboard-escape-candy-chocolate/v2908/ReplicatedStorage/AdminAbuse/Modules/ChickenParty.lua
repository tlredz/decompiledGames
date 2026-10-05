local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PartyEvent = require(script.Parent.Parent.PartyEvent)
local SharedSyncedEvent = require(script.Parent.Parent.SharedSyncedEvent)
local CCPulse = require(ReplicatedStorage.Utilities.Events.CCPulse)
local DanceSpawner = require(ReplicatedStorage.Utilities.Events.DanceSpawner)
local EventsConfig = require(ReplicatedStorage:WaitForChild("EventsConfig"))
local chickenParty = EventsConfig.ChickenParty
local v = CCPulse.new({
	name = "ChickenParty"
})
local v2 = DanceSpawner.new({
	spinSpeed = 10,
	jumpFreq = 5,
	jumpHeight = 2
})
local v3 = PartyEvent.new({
	Sounds = { "rbxassetid://125594614959452" }
})

function v3.OnStart(_, p, _, _, _)
	v:setup(p.janitor)
	local chickens = ReplicatedStorage.Assets.Events:FindFirstChild("Chickens")
	local models = {}

	if chickens then
		for _, model in chickens:GetChildren() do
			if model:IsA("Model") then
				table.insert(models, model)
			end
		end
	end

	if #models == 0 then
		warn("[ChickenParty] Folder \"Chickens\" introuvable ou vide dans ReplicatedStorage")
		return
	end

	local v4 = SharedSyncedEvent.new(chickenParty.SyncChannelName)
	p.janitor:Add(v4, "destroy")
	local v5 = false

	local function trySpawn(list)
		if v5 or type(list) ~= "table" or #list == 0 then
			return
		end

		v5 = true
		v2:setupAtPositions(p.janitor, list, models)
	end

	v4:onChange("Positions", trySpawn)
	local positions = v4:get("Positions")

	if not v5 and type(positions) == "table" and #positions ~= 0 then
		v5 = true
		v2:setupAtPositions(p.janitor, positions, models)
	end
end

function v3.OnRender(_, _, p, _, _, _)
	v:update(p)
	v2:update(p)
end

function v3.OnStop(_, _) end

return v3