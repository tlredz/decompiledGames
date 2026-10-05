local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
game:GetService("CollectionService")
local _ = ReplicatedStorage.Communication
local EffectsEvent = require(ReplicatedStorage2.Communication.ServerAndClient.Effects.EffectsEvent)
local CAM = ReplicatedStorage.CAM
local SAM = ServerStorage.SAM
local Checker = require(CAM.Global.Checker)
local Utility = require(CAM.Global.Utility)
require(CAM.Global.Combat_presets)
local DebrisModule = require(CAM.DebrisModule)
local ManuelCancel = require(CAM.Global.Subsets.Gameplay.ManuelCancel)
local ProjectileModeler = require(ReplicatedStorage2.CAM.Global.ProjectileModeler)
require(SAM.Utility.SkillStorage)
local Combat_Util = require(SAM.Services.Combat_Util)
local CharGrabPosCorrector = require(ReplicatedStorage2.CAM.Global.Subsets.Gameplay.CharGrabPosCorrector)
local hit_priority_handler = require(SAM.Game_Play.hit_priority_handler)
hit_priority_handler.new(script)
local Cutscene_camera_handler = require(SAM.Game_Play.Cutscene_camera_handler)
local Config = require(script.Parent.Config)
CFrame.new(0, 0, 0)
local script2 = script

local function lock(part, cframe: CFrame, p: number?, childName: string?)
	part:PivotTo(cframe)
	local clone = childName and workspace.Debree:FindFirstChild(childName)

	if not clone then
		clone = script.LOCK:Clone()
		clone.Name = childName or "LOCK"
		clone.Parent = workspace.Debree
		clone.Transparency = 1
	end

	clone:PivotTo(cframe)

	if p then
		DebrisModule:AddItem(clone, p)
	end

	local weld = clone.Weld
	weld.Part0 = clone
	weld.Part1 = part
	return clone
end

local KoketsuArrowServer = {
	Id = {}
}
local v = {
	"Impact1",
	"ArrowStorm",
	"Impact2",
	"Impact3",
	"Impact4",
	"Impact5",
	"FinalAct"
}

function KoketsuArrowServer.Hold(player, vector: Vector3, p)
	p.Stage = 1
	local character = player.Character
	local humanoid = character:FindFirstChild("Humanoid")
	local rootPart = humanoid.RootPart
	local getvaluesfolder = Utility.getvaluesfolder(character)
	local animator = humanoid:FindFirstChild("Animator")
	local v2 = nil
	local v3, _ = ManuelCancel.new(player, Config.CANCEL_WINDOW)
	v3:Connect(function()
		KoketsuArrowServer.Cancel(player, vector, p)

		if v2.IsActive then
			v2:Destroy()
		end
	end)
	local v4 = false
	local clone = nil
	local v5 = {}

	local function fn(instance, getvaluesfolder2, check_victim)
		if check_victim == "Blocking" or check_victim == "Perfect" then
			Combat_Util.Block(script2, character, instance, Config.BLOCK_BREAK)
			return
		end

		local humanoid2 = instance:FindFirstChild("Humanoid")
		local rootPart2 = humanoid2.RootPart
		local animator2 = humanoid2:FindFirstChild("Animator")
		local cFrame = rootPart.CFrame
		local v6 = cFrame * Config.VICTIM_LOCK_OFFSET
		local CUTSCENE_DUR = Config.CUTSCENE_DUR
		rootPart2:PivotTo(v6)
		local clone2 = nil

		if not clone2 then
			clone2 = script.LOCK:Clone()
			clone2.Name = "LOCK"
			clone2.Parent = workspace.Debree
			clone2.Transparency = 1
		end

		clone2:PivotTo(v6)

		if CUTSCENE_DUR then
			DebrisModule:AddItem(clone2, CUTSCENE_DUR)
		end

		local weld = clone2.Weld
		weld.Part0 = clone2
		weld.Part1 = rootPart2

		if not v4 then
			v4 = true
			local part = rootPart
			local CUTSCENE_DUR2 = Config.CUTSCENE_DUR
			part:PivotTo(cFrame)
			local clone3 = nil

			if not clone3 then
				clone3 = script.LOCK:Clone()
				clone3.Name = "LOCK"
				clone3.Parent = workspace.Debree
				clone3.Transparency = 1
			end

			clone3:PivotTo(cFrame)

			if CUTSCENE_DUR2 then
				DebrisModule:AddItem(clone3, CUTSCENE_DUR2)
			end

			local weld2 = clone3.Weld
			weld2.Part0 = clone3
			weld2.Part1 = part
			local clone4 = script.PS2arrowULT:Clone()
			clone4.Parent = rootPart
			clone4:Play()
			DebrisModule:AddItem(clone4, clone4.TimeLength)
			EffectsEvent.ToAllInRange(player, "Koketsu Arrow VFX", character, "Start", instance)
			local track = animator:LoadAnimation(script.User)
			track:Play()
			CharGrabPosCorrector.Do(character, track, nil, character)

			for _, v8 in ipairs({
				"iframe",
				"NR",
				"skill_stand_still",
				"noragdoll",
				"pause_gameplay"
			}) do
				Utility.AddValue(getvaluesfolder, v8, Config.CASTER_LOCK_DUR)
			end

			task.spawn(function()
				for i = 1, #Config.EFFECT_INTERVALS do
					local v8 = i == 1 and 0 or Config.EFFECT_INTERVALS[i - 1]
					task.wait(Config.EFFECT_INTERVALS[i] - v8)
					EffectsEvent.ToAllInRange(player, "Koketsu Arrow VFX", character, v[i], instance)
				end
			end)
			clone = script.CameraRig:Clone()
			clone.Parent = workspace.Debree
			clone:PivotTo(cFrame * CFrame.new(0.03887939453125, 1.9782161712646484, -0.0771484375))
			clone.RootPart.RootPart.Part0 = rootPart
			DebrisModule:AddItem(clone, Config.CUTSCENE_DUR)
			clone.AnimationController.Animator:LoadAnimation(script.Camera):Play()
			Cutscene_camera_handler.Regular(player, clone.Bone)

			if clone then
				local clone5 = table.clone(v5)
				table.insert(v5, character)
				table.insert(v5, instance)
				EffectsEvent.ToAllInRange(
					rootPart,
					"Koketsu Arrow VFX",
					character,
					"UltimateCamera",
					clone5,
					nil,
					clone
				)
			end
		end

		local track = animator2:LoadAnimation(script.Victim)
		track:Play()
		CharGrabPosCorrector.Do(instance, track, Config.DAMAGE_INTERVALS[5].Time - 0.01, character)
		local playerFromCharacter = game.Players:GetPlayerFromCharacter(instance)

		if playerFromCharacter then
			Cutscene_camera_handler.Regular(playerFromCharacter, clone.Bone)
		end

		task.spawn(function()
			for i = 1, #Config.DAMAGE_INTERVALS do
				local v7 = i == 1 and 0 or Config.DAMAGE_INTERVALS[i - 1].Time
				task.wait(Config.DAMAGE_INTERVALS[i].Time - v7)

				if not (p.stage ~= "Cancel" and character ~= nil and instance ~= nil and Checker.check_victim(
					script2,
					character,
					instance
				) ~= nil) then
					continue
				end

				Combat_Util.Damage(script2, character, instance, {
					Base = Config.DAMAGE_INTERVALS[i].Damage,
					Skill = script.Parent.Name
				})

				if not Config.DAMAGE_INTERVALS[i].Final then
					continue
				end

				if clone2 ~= nil then
					clone2:Destroy()
					clone2 = nil
				end

				Combat_Util.AddStun(script2, character, getvaluesfolder2, Config.FINAL_STUN)
				Combat_Util.RagDoll(script2, character, getvaluesfolder2, Config.FINAL_RAGDOLL)
			end
		end)

		for _, v7 in {
			"iframe",
			"skill_stand_still",
			"noragdoll",
			"pause_gameplay"
		} do
			local v8 = Utility.AddValue(
				getvaluesfolder2,
				v7,
				Config.VICTIM_VALUES_DUR,
				v7 == "iframe" and "StringValue" or nil
			)

			if v7 == "iframe" then
				v8.Value = player.Name
			end
		end
	end

	local function touchedfunc(_, _, p2)
		if p2 == nil then
			return true
		end

		local find_character_from_descendant = Utility.find_character_from_descendant(p2)

		if find_character_from_descendant == nil then
			return true
		end

		local getvaluesfolder2 = Utility.getvaluesfolder(find_character_from_descendant)
		local check_victim = Checker.check_victim(script2, character, find_character_from_descendant)

		if check_victim ~= nil then
			fn(find_character_from_descendant, getvaluesfolder2, check_victim)
		end

		return true
	end

	v2 = ProjectileModeler.new({
		Name = `{player.Name} - {script.Parent.Name}`,
		Size = Config.PROJECTILE_SIZE,
		CFrame = rootPart.CFrame * Config.PROJECTILE_SPAWN_OFFSET,
		Mover = {
			MaxForce = 1000000000
		},
		Rotator = {
			Responsiveness = 60
		},
		Speed = Config.PROJECTILE_SPEED
	}, touchedfunc, Config.PROJECTILE_LIFETIME, ProjectileModeler.WhitelistType.Humanoids, character)
	v2.Instance:SetNetworkOwner(player)
	EffectsEvent.ToAllInRange(player, "Koketsu Arrow VFX", character, "Startup", v2.Instance)
end

function KoketsuArrowServer.UnHold(_, _: Vector3, p)
	p.Stage = 2
end

function KoketsuArrowServer.Cancel(player, _: Vector3, _)
	local _ = {
		Stage = 3
	}
	EffectsEvent.ToAllInRange(player, "Koketsu Arrow VFX", player.Character, "Cancel")
end

return KoketsuArrowServer