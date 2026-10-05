local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local EffectsEvent = require(ReplicatedStorage.Communication.ServerAndClient.Effects.EffectsEvent)
local ServerNpcUtil = require(ServerStorage.SAM.Services.ServerNpcUtil)
return function(p, _)
	local entity = p.Spawning.Entity
	local humanoidRootPart

	if entity ~= nil then
		humanoidRootPart = entity:FindFirstChild("HumanoidRootPart") or nil
	end

	local chosenSpawnLocation = p.Spawning.ChosenSpawnLocation

	if humanoidRootPart == nil or chosenSpawnLocation == nil then
		return
	end

	local cache = p.Spawning.Cache
	local now = os.clock()

	if cache.LastWaterReturn ~= nil and now - cache.LastWaterReturn < 1 then
		return
	end

	cache.LastWaterReturn = now
	local PerformSkill = require(ServerStorage.SAM.AiThings.NpcNetwork.Tasks.PerformSkill)
	PerformSkill.CancelAll(p)

	if humanoidRootPart:CanSetNetworkOwnership() then
		humanoidRootPart:SetNetworkOwner(nil)
	end

	EffectsEvent.ToAllInRange(humanoidRootPart, "NpcOutOfBounds", humanoidRootPart.CFrame)

	if p.Following.CapturedEnemy ~= nil then
		p.Following.Set(p, nil)
	end

	humanoidRootPart.AssemblyLinearVelocity = createVector(0, 0, 0)
	ServerNpcUtil.PlaceRig(entity, chosenSpawnLocation)
end