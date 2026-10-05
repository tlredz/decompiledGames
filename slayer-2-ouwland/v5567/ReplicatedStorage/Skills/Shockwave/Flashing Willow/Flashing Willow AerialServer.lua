local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local TweenService = game:GetService("TweenService")
local CAM = ReplicatedStorage.CAM
local SAM = ServerStorage.SAM
local DebrisModule = require(CAM.DebrisModule)
local EffectsEvent = require(ReplicatedStorage.Communication.ServerAndClient.Effects.EffectsEvent)
local RaycastHelper = require(CAM.Global.RaycastHelper)
local Checker = require(CAM.Global.Checker)
local Utility = require(CAM.Global.Utility)
local Combat_Util = require(SAM.Services.Combat_Util)
local hit_priority_handler = require(ServerStorage.SAM.Game_Play.hit_priority_handler)
local v = hit_priority_handler.new(script)
local ManuelCancel = require(CAM.Global.Subsets.Gameplay.ManuelCancel)
local cleanit = require(ReplicatedStorage.Packages.cleanit)
local Config = require(script.Parent.Config)
local FlashingWillowAerialServer = {
	Id = {}
}
local flashingWillowAirVariantVictimStartup = script.FlashingWillowAirVariantVictimStartup
local flashingWillowAirVariantVictimLoop = script.FlashingWillowAirVariantVictimLoop
local flashingWillowAirVariantUserStartup = script.FlashingWillowAirVariantUserStartup
local flashingWillowAirVariantUserLoop = script.FlashingWillowAirVariantUserLoop
local flashingWillowAirVariantUserRelease = script.FlashingWillowAirVariantUserRelease

function FlashingWillowAerialServer.Hold(_, _: Vector3?, p)
	local cleanIt = p.CleanIt or cleanit.new()
	p.CleanIt = cleanIt
	cleanIt:Clean()
end

function FlashingWillowAerialServer.UnHold(player, vector2: Vector3?, p)
	local cleanIt = p.CleanIt or cleanit.new()
	p.CleanIt = cleanIt
	local v2 = FlashingWillowAerialServer.Id[player.UserId]
	local character = player.Character
	local humanoid = character:FindFirstChild("Humanoid")
	local rootPart = humanoid.RootPart
	local animator = humanoid:FindFirstChild("Animator")
	local getvaluesfolder = Utility.getvaluesfolder(character)
	local v3 = Config.AERIAL_DROP_RAY_DISTANCE / Config.AERIAL_DROP_SPEED
	local v4 = Config.AERIAL_STARTUP_TIME + Config.AERIAL_LOOP_BEFORE_DROP + v3
	local v5, v6 = ManuelCancel.new(player, v4)
	cleanIt:Add(v5:Connect(function()
		FlashingWillowAerialServer.Id[player.UserId] = -1
		FlashingWillowAerialServer.Cancel(player, vector2, p)
	end))
	local track = animator:LoadAnimation(flashingWillowAirVariantUserStartup)
	cleanIt:Add(track)
	track:Play()
	track.TimePosition = Config.AERIAL_FREEZE_MARK
	local v7 = {}
	Utility.CreateHitbox({
		caster = character,
		hitboxCFrame = rootPart.CFrame * Config.AERIAL_HITBOX_OFFSET,
		hitboxSize = Config.AERIAL_HITBOX_SIZE,
		checker = Checker,
		hitPriorityHandler = {
			callback = v.Exists,
			data = "Choosing_1"
		},
		hitDetected = function(instance, values, p3)
			local humanoid2 = instance:FindFirstChild("Humanoid")
			local rootPart2 = humanoid2 and humanoid2.RootPart

			if p3 == "Perfect" then
				Combat_Util.Perfect(script, character, instance)
				return
			end

			if p3 == "Blocking" and not Combat_Util.Block(script, character, instance, Config.AERIAL_BLOCK_BREAK) then
				return
			end

			if rootPart2:FindFirstChild("air_combo_bp") == nil and humanoid2.FloorMaterial ~= Enum.Material.Air and humanoid2.FloorMaterial ~= nil then
				return
			end

			table.insert(v7, {
				model = instance,
				values = values,
				root = rootPart2,
				humanoid = humanoid2
			})
		end
	})

	if #v7 == 0 then
		task.wait(0.15)
		FlashingWillowAerialServer.Cancel(player, vector2, p)
	else
		v6()
		cleanIt:Add(Utility.AddValue(getvaluesfolder, "pause_gameplay", v4))
		cleanIt:Add(Utility.AddValue(getvaluesfolder, "NR", v4))
		cleanIt:Add(Utility.AddValue(getvaluesfolder, "skill_stand_still", v4))
		local part = Instance.new("Part")
		part.Name = `{player.Name} Flashing Willow Anchor`
		part.Size = createVector(1, 1, 1)
		part.Transparency = 1
		part.Anchored = true
		part.CanCollide = false
		part.CanTouch = false
		part.CanQuery = false
		part.CFrame = rootPart.CFrame
		part.Parent = workspace.Debree
		cleanIt:Add(part)
		DebrisModule:AddItem(part, v4)
		EffectsEvent.ToAllInRange(rootPart, "Flashing Willow Aerial VFX", character, "AerialStart", part.CFrame)
		cleanIt:Add(Utility.CreateOuwWeld(part, rootPart, nil, v4))

		for _, v8 in v7 do
			cleanIt:Add(Utility.AddValue(v8.values, "pause_gameplay", v4))
			cleanIt:Add(Utility.AddValue(v8.values, "NR", v4))
			cleanIt:Add(Utility.AddValue(v8.values, "skill_stand_still", v4))
			Combat_Util.Remove_air_combo_bp(v8.root)
			cleanIt:Add(Utility.CreateOuwWeld(part, v8.root, nil, v4))
			local track2 = v8.humanoid:LoadAnimation(flashingWillowAirVariantVictimStartup)
			cleanIt:Add(track2)
			track2:Play()
			track2.TimePosition = Config.AERIAL_FREEZE_MARK
		end

		task.wait(0.35)

		if FlashingWillowAerialServer.Id[player.UserId] ~= v2 then
			return
		end

		local position = part.Position + createVector(0, 1, 0) * -Config.AERIAL_DROP_RAY_DISTANCE
		local raycastResult = workspace:Raycast(
			part.Position,
			createVector(0, 1, 0) * -Config.AERIAL_DROP_RAY_DISTANCE,
			RaycastHelper.Crater
		)
		local v8

		if raycastResult then
			position = raycastResult.Position
			v8 = position + Vector3.new(0, humanoid.HipHeight + rootPart.Size.Y / 2, 0)
		else
			v8 = position
		end

		EffectsEvent.ToAllInRange(
			rootPart,
			"Flashing Willow Aerial VFX",
			character,
			"AerialRelease",
			part.CFrame,
			position
		)
		task.wait(0.68)

		if FlashingWillowAerialServer.Id[player.UserId] ~= v2 then
			return
		end

		local track2 = animator:LoadAnimation(flashingWillowAirVariantUserLoop)
		cleanIt:Add(track2)
		track2:Play()

		for _, v9 in v7 do
			local track3 = v9.humanoid:LoadAnimation(flashingWillowAirVariantVictimLoop)
			cleanIt:Add(track3)
			track3:Play()
		end

		local tween = TweenService:Create(part, TweenInfo.new(v3, Enum.EasingStyle.Linear), {
			CFrame = CFrame.new(v8)
		})
		cleanIt:Add(tween)
		tween:Play()
		local cFrame = rootPart.CFrame
		task.wait(v3)

		if FlashingWillowAerialServer.Id[player.UserId] ~= v2 then
			return
		end

		cleanIt:Clean()
		task.wait()

		if FlashingWillowAerialServer.Id[player.UserId] ~= v2 then
			return
		end

		EffectsEvent.ToAllInRange(rootPart, "Flashing Willow Aerial VFX", character, "AerialImpact", position)
		Utility.CreateHitbox({
			caster = character,
			hitboxCFrame = CFrame.new(position),
			hitboxSize = Config.AERIAL_EXPLOSION_HITBOX_SIZE,
			checker = Checker,
			hitPriorityHandler = {
				callback = v.Exists,
				data = "Choosing_1"
			},
			hitDetected = function(p2, p3, p4)
				if p4 == "Perfect" then
					Combat_Util.Perfect(script, character, p2)
					return
				end

				if p4 == "Blocking" and not Combat_Util.Block(script, character, p2, Config.AERIAL_BLOCK_BREAK) then
					return
				end

				Combat_Util.Damage(script, character, p2, {
					Base = Config.AERIAL_DAMAGE,
					Skill = script.Parent.Name
				})
				Combat_Util.AddStun(script, character, p3, Config.AERIAL_STUN)
				Combat_Util.Air_combo_slam(
					character,
					p2,
					cFrame,
					CFrame.new(0, -Config.AERIAL_DROP_RAY_DISTANCE, 0),
					true
				)
			end
		})
		local track3 = animator:LoadAnimation(flashingWillowAirVariantUserRelease)
		cleanIt:Add(track3)
		track3:Play()
		task.wait(0.67)

		if FlashingWillowAerialServer.Id[player.UserId] ~= v2 then
			return
		end

		cleanIt:Clean()
	end
end

function FlashingWillowAerialServer.Cancel(player, _: Vector3?, p)
	local cleanIt = p.CleanIt or cleanit.new()
	p.CleanIt = cleanIt
	EffectsEvent.ToAllInRange(player, "Flashing Willow Aerial VFX", player.Character, "Cancel")
	cleanIt:Clean()
end

return FlashingWillowAerialServer