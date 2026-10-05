local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PartyEvent = require(script.Parent.Parent.PartyEvent)
local SharedSyncedEvent = require(script.Parent.Parent.SharedSyncedEvent)
local CCPulse = require(ReplicatedStorage.Utilities.Events.CCPulse)
local DanceSpawner = require(ReplicatedStorage.Utilities.Events.DanceSpawner)
local EventsConfig = require(ReplicatedStorage:WaitForChild("EventsConfig"))
local miguelParty = EventsConfig.MiguelParty
local v = CCPulse.new({
	name = "MiguelParty"
})
local v2 = DanceSpawner.new({
	spinSpeed = 10,
	jumpFreq = 5,
	jumpHeight = 2
})
local v3 = PartyEvent.new({
	Sounds = { "rbxassetid://85271194133590" }
})

function v3.OnStart(_, p, _, _, _)
	v:setup(p.janitor)
	local miguel = ReplicatedStorage.Assets.Events:FindFirstChild("Miguel")

	if not miguel then
		warn("[MiguelParty] Modèle \"Miguel\" introuvable dans ReplicatedStorage")
		return
	end

	local v4 = { miguel }
	local v5 = SharedSyncedEvent.new(miguelParty.SyncChannelName)
	p.janitor:Add(v5, "destroy")
	local v6 = false

	local function trySpawn(list)
		if v6 or type(list) ~= "table" or #list == 0 then
			return
		end

		v6 = true
		v2:setupAtPositions(p.janitor, list, v4)
	end

	v5:onChange("Positions", trySpawn)
	local positions = v5:get("Positions")

	if not v6 and type(positions) == "table" and #positions ~= 0 then
		v6 = true
		v2:setupAtPositions(p.janitor, positions, v4)
	end
end

function v3.OnRender(_, _, p, _, _, _)
	v:update(p)
	v2:update(p)
end

function v3.OnStop(_, _) end

return v3