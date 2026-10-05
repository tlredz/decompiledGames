local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local CAM = ReplicatedStorage.CAM
local SAM = ServerStorage.SAM
local EffectsEvent = require(ReplicatedStorage.Communication.ServerAndClient.Effects.EffectsEvent)
local ManuelCancel = require(CAM.Global.Subsets.Gameplay.ManuelCancel)
local Checker = require(CAM.Global.Checker)
local Utility = require(CAM.Global.Utility)
local Combat_Util = require(SAM.Services.Combat_Util)
local hit_priority_handler = require(SAM.Game_Play.hit_priority_handler)
local v = hit_priority_handler.new(script)
local cleanit = require(ReplicatedStorage.Packages.cleanit)
local Config = require(script.Parent.Config)
local ServerStorage2 = game:GetService("ServerStorage")
local Server_Mouse_Pos = require(ServerStorage2.SAM.Services.Server_Mouse_Pos)
local ShadeBreakerServer = {
	Id = {}
}
local name = script.Parent.Name

function ShadeBreakerServer.Hold(_, _: Vector3?, p)
	local cleanIt = p.CleanIt or cleanit.new()
	p.CleanIt = cleanIt
	cleanIt:Clean()
end

function ShadeBreakerServer.UnHold(player, _: Vector3?, p)
	local cleanIt = p.CleanIt or cleanit.new()
	p.CleanIt = cleanIt
	cleanIt:Clean()
	local character = player.Character
	local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart == nil then
		return
	end

	local getvaluesfolder = Utility.getvaluesfolder(character)
	cleanIt:Add(Utility.AddValue(getvaluesfolder, "pause_gameplay", Config.FLIGHT_LOCK))
	cleanIt:Add(Utility.AddValue(getvaluesfolder, "iframe", Config.FLIGHT_LOCK))
	EffectsEvent.ToAllInRange(humanoidRootPart, "Shade Breaker VFX", character, "Jump", humanoidRootPart.CFrame)
end

function ShadeBreakerServer.UnHoldAfterClient(player, _: Vector3?, _, p, p2)
	local cleanIt = p2.CleanIt or cleanit.new()
	p2.CleanIt = cleanIt
	cleanIt:Clean()
	local v2 = ShadeBreakerServer.Id[player.UserId]
	local character = player.Character
	local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart == nil then
		return
	end

	if typeof(p) ~= "CFrame" then
		ShadeBreakerServer.Cancel(player, nil, p2)
		return
	end

	local clamped = Server_Mouse_Pos.Clamp(character, p.Position, Config.AIM_RANGE + 15)

	if clamped == nil then
		ShadeBreakerServer.Cancel(player, nil, p2)
		return
	end

	local v3 = p.Rotation + clamped
	local getvaluesfolder = Utility.getvaluesfolder(character)
	local v4, v5 = ManuelCancel.new(player, Config.RECOVERY + 0.5)
	v4:Connect(function()
		ShadeBreakerServer.Id[player.UserId] = -1
		ShadeBreakerServer.Cancel(player, nil, p2)
	end)
	cleanIt:Add(v5)
	cleanIt:Add(Utility.AddValue(getvaluesfolder, "pause_gameplay", Config.RECOVERY))
	EffectsEvent.ToAllInRange(
		humanoidRootPart,
		"Shade Breaker VFX",
		character,
		"Explosion",
		humanoidRootPart.CFrame,
		v3
	)
	Utility.CreateHitbox({
		caster = character,
		hitboxCFrame = v3 * Config.EXPLOSION_HITBOX_OFFSET,
		hitboxSize = Config.EXPLOSION_HITBOX_SIZE,
		checker = Checker,
		hitPriorityHandler = {
			callback = v.Exists,
			data = "Choosing_1"
		},
		hitDetected = function(instance, p3, p4)
			local humanoid = instance:FindFirstChild("Humanoid")
			local humanoidRootPart2 = instance:FindFirstChild("HumanoidRootPart")

			if humanoid == nil or humanoidRootPart2 == nil then
				return
			end

			if p4 == "Perfect" then
				Combat_Util.Perfect(script, character, instance)
			elseif p4 == "Blocking" then
				Combat_Util.Block(script, character, instance, Config.EXPLOSION_BLOCK_BREAK)
			elseif p4 == true then
				local unit = ((humanoidRootPart2.Position - v3.Position) * createVector(1, 0, 1)).Unit
				Combat_Util.Damage(script, character, instance, {
					Base = Config.EXPLOSION_DAMAGE,
					Skill = name
				})
				Combat_Util.AddStun(script, character, p3, Config.EXPLOSION_STUN)
				Combat_Util.RagDoll(script, character, p3, Config.EXPLOSION_STUN)
				Combat_Util.Knockback(
					script,
					character,
					humanoidRootPart2,
					unit * Config.EXPLOSION_KNOCKBACK + Vector3.new(0, Config.EXPLOSION_UPWARD, 0),
					0.25
				)
			end
		end
	})
	task.wait(Config.RECOVERY)

	if ShadeBreakerServer.Id[player.UserId] ~= v2 or humanoidRootPart.Parent == nil then
		return
	end

	cleanIt:Clean()
end

function ShadeBreakerServer.Cancel(player, _: Vector3?, p)
	local cleanIt = p.CleanIt or cleanit.new()
	p.CleanIt = cleanIt
	local character = player.Character
	local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart and character then
		EffectsEvent.ToAllInRange(humanoidRootPart, "Shade Breaker VFX", character, "Cancel")
	end

	cleanIt:Clean()
end

return ShadeBreakerServer