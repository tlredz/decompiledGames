local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local CAM = ReplicatedStorage.CAM
local SAM = ServerStorage.SAM
local Combat_presets = require(ReplicatedStorage.CAM.Global.Combat_presets)
local EffectsEvent = require(ReplicatedStorage.Communication.ServerAndClient.Effects.EffectsEvent)
local Server_Mouse_Pos = require(SAM.Services.Server_Mouse_Pos)
local Checker = require(CAM.Global.Checker)
local Utility = require(CAM.Global.Utility)
local Combat_Util = require(SAM.Services.Combat_Util)
local hit_priority_handler = require(SAM.Game_Play.hit_priority_handler)
local v = hit_priority_handler.new(script)
local cleanit = require(ReplicatedStorage.Packages.cleanit)
local RaycastHelper = require(CAM.Global.RaycastHelper)
local Config = require(script.Parent.Config)
local MeteorServer = {
	Id = {}
}

local function fireImpactHitbox(character, _, position: Vector3, THROW_DAMAGE: number, THROW_STUN: number)
	local raycastResult = workspace:Raycast(
		position + Vector3.new(0, Config.FLOOR_PROBE_UP, 0),
		createVector(0, 1, 0) * -(Config.FLOOR_PROBE_UP + Config.FLOOR_PROBE_DOWN),
		RaycastHelper.Map
	)

	if raycastResult then
		position = raycastResult.Position or position
	end

	local cframe = CFrame.new(position + Vector3.new(0, Config.HITBOX_HEIGHT_OFFSET, 0))
	Utility.CreateHitbox({
		caster = character,
		hitboxCFrame = cframe,
		hitboxSize = Config.HITBOX_SIZE,
		checker = Checker,
		hitPriorityHandler = {
			callback = v.Exists,
			data = "Choosing_1"
		},
		hitDetected = function(instance, p, p2)
			if p2 == "Perfect" then
				Combat_Util.Perfect(script, character, instance)
				return
			end

			if p2 == "Blocking" and not Combat_Util.Block(script, character, instance, Config.THROW_BLOCK_BREAK) then
				return
			end

			Combat_Util.Damage(script, character, instance, {
				Base = THROW_DAMAGE,
				Skill = script.Parent.Name
			})
			Combat_Util.AddStun(script, character, p, THROW_STUN)
			Combat_presets.PlayReactAnim(instance:FindFirstChild("Humanoid"))
		end
	})
end

function MeteorServer.Hold(player, vector2: Vector3?, p)
	local maid = cleanit.new()
	p.CleanIt = maid
	maid:Clean()
	local character = player.Character
	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	local getvaluesfolder = Utility.getvaluesfolder(character)
	local v2 = MeteorServer.Id[player.UserId]
	maid:Add(Utility.AddValue(getvaluesfolder, "pause_gameplay", Config.MAX_HOLD_DURATION))
	EffectsEvent.ToAllInRange(humanoidRootPart, "Meteor VFX", character, "Start")
	Server_Mouse_Pos.Create_Pos_Part(character, script.Parent.Name, Config.MAX_HOLD_DURATION + 2)
	maid:Add(function()
		Server_Mouse_Pos.Delete_Pos_Part(character, script.Parent.Name)
	end)
	task.wait(0.25)

	if MeteorServer.Id[player.UserId] ~= v2 then
		return
	end

	local lastTime = os.clock()
	local count = 0

	while MeteorServer.Id[player.UserId] == v2 and os.clock() - lastTime < Config.MAX_HOLD_DURATION do
		count += 1
		local v3 = count % 2 == 1 and "RightHand" or "LeftHand"
		EffectsEvent.ToAllInRange(humanoidRootPart, "Meteor VFX", character, v3)
		task.wait(Config.THROW_INTERVAL)

		if MeteorServer.Id[player.UserId] ~= v2 then
			break
		end

		local v4 = Server_Mouse_Pos.Find(character, script.Parent.Name)
		local position

		if v4 then
			local defaultPos = v4:GetAttribute("DefaultPos")

			if defaultPos == nil or (v4.Position - defaultPos).Magnitude > 1 then
				position = v4.Position
			else
				position = vector2 or v4.Position
			end
		else
			position = vector2 or humanoidRootPart.Position + humanoidRootPart.CFrame.LookVector * 20
		end

		local clamped = Server_Mouse_Pos.Clamp(character, position, Config.AIM_RANGE) or humanoidRootPart.Position + humanoidRootPart.CFrame.LookVector * 20
		EffectsEvent.ToAllInRange(humanoidRootPart, "Meteor VFX", character, "Descend", clamped)
		task.delay(Config.METEOR_TRAVEL_TIME, function()
			if MeteorServer.Id[player.UserId] ~= v2 then
				return
			end

			fireImpactHitbox(character, humanoidRootPart, clamped, Config.THROW_DAMAGE, Config.THROW_STUN)
		end)
	end
end

function MeteorServer.UnHold(_, _: Vector3?, p)
	local cleanIt = p.CleanIt or cleanit.new()
	p.CleanIt = cleanIt
	cleanIt:Clean()
end

function MeteorServer.Cancel(player, _: Vector3?, p)
	local character = player.Character
	local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart and character then
		EffectsEvent.ToAllInRange(humanoidRootPart, "Meteor VFX", character, "Cancel")
	end

	local cleanIt = p.CleanIt or cleanit.new()
	p.CleanIt = cleanIt
	cleanIt:Clean()
end

return MeteorServer