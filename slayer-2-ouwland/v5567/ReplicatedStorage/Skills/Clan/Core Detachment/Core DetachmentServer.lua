local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local Players = game:GetService("Players")
local CAM = ReplicatedStorage.CAM
local EffectsEvent = require(ReplicatedStorage.Communication.ServerAndClient.Effects.EffectsEvent)
local Utility = require(CAM.Global.Utility)
local RaycastHelper = require(CAM.Global.RaycastHelper)
local PartBox = require(CAM.Global.PartBox)
local StatTypes = require(CAM.Global.Types.StatTypes)
local ServerPartyWatcher = require(ServerStorage.SAM.Services.ServerPartyWatcher)
local Config = require(script.Parent.Config)
local CoreDetachmentServer = {
	Id = {}
}

local function grant(instance, p: number?)
	for _, child in instance:GetChildren() do
		if child.Name == Config.OCCUPANT_VALUE then
			child:Destroy()
		end
	end

	local v = Utility.AddValue(instance, Config.OCCUPANT_VALUE, p)
	v:AddTag(StatTypes.ValueStatTag)

	for k, v2 in Config.BUFF_STATS do
		v:SetAttribute(StatTypes.StatToAttribute(k), v2)
	end

	return v
end

local function isAlly(p, p2, character)
	if character == p then
		return true
	end

	local playerFromCharacter = Players:GetPlayerFromCharacter(character)

	if playerFromCharacter == nil then
		return false
	end

	if p2.Team ~= nil and playerFromCharacter.Team == p2.Team then
		return true
	end

	for _, v in ServerPartyWatcher.GetMembers(p2) do
		if v.UserId == playerFromCharacter.UserId then
			return true
		end
	end

	return false
end

local function openZone(player, character, cframe: CFrame)
	local v = PartBox.new({
		Shape = "Cylinder",
		Center = cframe,
		Size = Config.ZONE_SIZE,
		MaxDuration = Config.DURATION,
		Allies = true,
		TouchCooldown = 0,
		caster = character,
		hitDetected = function(p, p2)
			if p2 == nil or not isAlly(character, player, p) then
				return
			end

			grant(p2)
		end
	})

	if v == nil then
		return
	end

	v.Left:Connect(function(_, instance)
		if instance == nil or instance:FindFirstChild(Config.OCCUPANT_VALUE) == nil then
			return
		end

		grant(instance, Config.LINGER)
	end)
end

function CoreDetachmentServer.Hold(player, vector2: Vector3?, _)
	local character = player.Character

	if character == nil then
		return false
	end

	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart == nil then
		return false
	end

	Utility.AddValue(Utility.getvaluesfolder(character), "pause_gameplay", Config.THROW_LOCK)
	local position = humanoidRootPart.Position

	if vector2 ~= nil then
		local v = math.min(Config.AIM_RANGE, (vector2 - humanoidRootPart.Position).Magnitude)
		local maximizeRayServer = RaycastHelper.MaximizeRayServer(
			character,
			humanoidRootPart.Position,
			vector2,
			v,
			false,
			Config.SPHERECAST_RADIUS,
			Config.DOWNCAST,
			nil,
			RaycastHelper.Crater
		)

		if maximizeRayServer ~= nil then
			position = maximizeRayServer
		end
	end

	local cframe = CFrame.new(position)
	EffectsEvent.ToAllInRange(
		humanoidRootPart,
		"CoreDetachmentVFX",
		character,
		"Throw",
		cframe,
		Config.CORE_TRAVEL,
		Config.DURATION
	)
	local v = CoreDetachmentServer.Id[player.UserId]
	task.delay(Config.CORE_TRAVEL, function()
		if not (v == CoreDetachmentServer.Id[player.UserId] and character.Parent ~= nil) then
			return
		end

		openZone(player, character, cframe)
	end)
	return true
end

function CoreDetachmentServer.Cancel(player, _, _)
	local character = player and player.Character
	local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart == nil then
		return
	end

	humanoidRootPart.AssemblyLinearVelocity = createVector(0, 0, 0)
	EffectsEvent.ToAllInRange(humanoidRootPart, "CoreDetachmentVFX", character, "Cancel")
end

return CoreDetachmentServer