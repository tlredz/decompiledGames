local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
game:GetService("CollectionService")
local EffectsEvent = require(ReplicatedStorage2.Communication.ServerAndClient.Effects.EffectsEvent)
local CAM = ReplicatedStorage.CAM
local SAM = ServerStorage.SAM
local Checker = require(CAM.Global.Checker)
local Utility = require(CAM.Global.Utility)
require(CAM.Global.Combat_presets)
local DebrisModule = require(CAM.DebrisModule)
require(CAM.Global.Subsets.Gameplay.ManuelCancel)
require(SAM.Utility.SkillStorage)
local Combat_Util = require(SAM.Services.Combat_Util)
local hit_priority_handler = require(SAM.Game_Play.hit_priority_handler)
local v = hit_priority_handler.new(script)
local Cutscene_camera_handler = require(SAM.Game_Play.Cutscene_camera_handler)
local Config = require(script.Parent.Config)
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

local BloodRuptureServer = {
	Id = {},
	Hold = function(player, _: Vector3, state)
		state.stage = "Hold"
		local character = player.Character
		local rootPart = character:FindFirstChild("Humanoid").RootPart
		EffectsEvent.ToAllInRange(character, "Blood Rupture VFX", character, "Start")
		task.wait(Config.STARTUP_DUR)

		if state.stage ~= "Hold" then
			return
		end

		EffectsEvent.ToAllInRange(character, "Blood Rupture VFX", character, "Movement")
		local v2 = false

		local function fn(p, p2, p3)
			v2 = true

			if p3 == "Perfect" then
				Combat_Util.Perfect(script2, character, p)
				return
			elseif p3 == "Blocking" then
				Combat_Util.Block(script2, character, p, Config.DASH_BLOCK_BREAK)
				return
			end

			if state.targetData == nil then
				state.targetData = {}
			end

			table.insert(state.targetData, { p, p2, p3 })
		end

		while state.stage == "Hold" do
			Utility.CreateHitbox({
				caster = character,
				hitboxCFrame = rootPart.CFrame * Config.DASH_HITBOX_OFFSET,
				hitboxSize = Config.DASH_HITBOX_SIZE,
				checker = Checker,
				hitPriorityHandler = {
					callback = v.Exists,
					data = "Choosing_1"
				},
				hitDetected = fn
			})

			if v2 == true then
				EffectsEvent.ToClient(player, "force_skill_actions_server", script.Parent.Name, "UnHold", nil, true)
				break
			else
				task.wait(0.06666666666666667)
			end
		end
	end
}
local raycastParams = RaycastParams.new()
raycastParams.FilterDescendantsInstances = { workspace.Map }
raycastParams.FilterType = Enum.RaycastFilterType.Include
local CharGrabPosCorrector = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Subsets"):WaitForChild("Gameplay"):WaitForChild("CharGrabPosCorrector"))

function BloodRuptureServer.UnHold(player, vector: Vector3, state)
	state.stage = "Release"
	local character = player.Character
	local getvaluesfolder = Utility.getvaluesfolder(character)
	local humanoid = character:FindFirstChild("Humanoid")
	local rootPart = humanoid.RootPart
	local animator = humanoid:FindFirstChild("Animator")
	local targetData = state.targetData
	local v2 = {}
	local v3 = false
	local v4 = false
	local v5 = false

	if targetData then
		local cFrame = rootPart.CFrame
		local clone = nil

		for _, v6 in pairs(targetData) do
			local v7 = v6[1]
			local v8 = v6[2]
			local _ = v6[3]
			local humanoid2 = v7:FindFirstChild("Humanoid")

			if humanoid2 == nil then
				continue
			end

			local rootPart2 = humanoid2.RootPart

			if rootPart2 == nil or (rootPart2.Position - (cFrame * Config.DASH_HITBOX_OFFSET).Position).Magnitude > Config.DASH_HITBOX_SIZE.Magnitude / 2 + 50 then
				continue
			end

			table.insert(v2, v7)
			local animator2 = humanoid2.Animator
			local CUTSCENE_LOCK_DUR = Config.CUTSCENE_LOCK_DUR
			rootPart2:PivotTo(cFrame)
			local clone2 = nil

			if not clone2 then
				clone2 = script.LOCK:Clone()
				clone2.Name = "LOCK"
				clone2.Parent = workspace.Debree
				clone2.Transparency = 1
			end

			clone2:PivotTo(cFrame)

			if CUTSCENE_LOCK_DUR then
				DebrisModule:AddItem(clone2, CUTSCENE_LOCK_DUR)
			end

			local weld = clone2.Weld
			weld.Part0 = clone2
			weld.Part1 = rootPart2
			Utility.AddValue(v8, "NR", Config.CUTSCENE_VALUES_DUR)
			Utility.AddValue(v8, "skill_stand_still", Config.CUTSCENE_VALUES_DUR)
			Utility.AddValue(v8, "noragdoll", Config.CUTSCENE_VALUES_DUR)
			Utility.AddValue(v8, "pause_gameplay", Config.CUTSCENE_VALUES_DUR)
			Combat_Util.AddStun(script2, character, v8, Config.CUTSCENE_STUN)
			local track = animator2:LoadAnimation(script.Victim)
			track:Play()
			CharGrabPosCorrector.Do(v7, track, Config.CUTSCENE_CORRECTOR_DUR, character)

			if clone == nil then
				clone = script.CameraRig:Clone()
				clone.Name = character.Name .. "_BloodRuptureCam"
				clone.Parent = workspace.Debree
				clone:PivotTo(cFrame * CFrame.new(0.03887939453125, 1.9782161712646484, -0.0771484375))
				clone.RootPart.RootPart.Part0 = rootPart
				DebrisModule:AddItem(clone, Config.CUTSCENE_LOCK_DUR)
				clone.AnimationController.Animator:LoadAnimation(script.Camera):Play()
				Cutscene_camera_handler.Regular(player, clone.Bone)
			end

			local playerFromCharacter = game.Players:GetPlayerFromCharacter(v7)

			if playerFromCharacter then
				Cutscene_camera_handler.Regular(playerFromCharacter, clone.Bone)
			end

			local v9 = v7
			task.delay(Config.CUTSCENE_INITIAL_HIT_AT, function()
				if state.stage ~= "Cancel" and character ~= nil and v9 ~= nil and Checker.check_victim(
					script2,
					character,
					v9
				) ~= nil then
					Combat_Util.Damage(script2, character, v9, {
						Base = Config.CUTSCENE_INITIAL_DAMAGE,
						Skill = script.Parent.Name
					})

					if v4 == false then
						v4 = true
						EffectsEvent.ToAllInRange(character, "Blood Rupture VFX", character, "Initial", v9)
						EffectsEvent.ToAllInRange(character, "Blood Rupture VFX", character, "MovementStop")
					end
				end
			end)

			if v5 == false then
				EffectsEvent.ToAllInRange(character, "Blood Rupture VFX", character, "Slashes")
				v5 = true
			end

			local v10 = v7
			task.spawn(function()
				for k, duration in Config.CUTSCENE_SLASH_DELAYS do
					task.wait(duration)

					if not (state.stage ~= "Cancel" and character ~= nil and v10 ~= nil and Checker.check_victim(
						script2,
						character,
						v10
					) ~= nil) then
						continue
					end

					Combat_Util.Damage(script2, character, v10, {
						Base = Config.CUTSCENE_SLASH_DAMAGE,
						Skill = script.Parent.Name
					})
				end
			end)
			local v11 = v7
			local v12 = v8
			task.delay(Config.CUTSCENE_STOMP_AT, function()
				if state.stage == "Cancel" or character == nil or v11 == nil or Checker.check_victim(
					script2,
					character,
					v11
				) == nil then
					return
				end

				if v3 == false then
					v3 = true
					EffectsEvent.ToAllInRange(character, "Blood Rupture VFX", character, "Stomp")
				end

				Combat_Util.Damage(script2, character, v11, {
					Base = Config.CUTSCENE_STOMP_DAMAGE,
					Skill = script.Parent.Name
				})
				Combat_Util.Add_Strict_Stun(script2, character, v12, Config.CUTSCENE_STOMP_STUN)
				state.targetData = nil
			end)
		end

		local CUTSCENE_LOCK_DUR = Config.CUTSCENE_LOCK_DUR
		rootPart:PivotTo(cFrame)
		local clone2 = nil

		if not clone2 then
			clone2 = script.LOCK:Clone()
			clone2.Name = "LOCK"
			clone2.Parent = workspace.Debree
			clone2.Transparency = 1
		end

		clone2:PivotTo(cFrame)

		if CUTSCENE_LOCK_DUR then
			DebrisModule:AddItem(clone2, CUTSCENE_LOCK_DUR)
		end

		local weld = clone2.Weld
		weld.Part0 = clone2
		weld.Part1 = rootPart
		Utility.AddValue(getvaluesfolder, "iframe", Config.CUTSCENE_IFRAME_DUR)
		Utility.AddValue(getvaluesfolder, "NR", Config.CUTSCENE_VALUES_DUR)
		Utility.AddValue(getvaluesfolder, "skill_stand_still", Config.CUTSCENE_VALUES_DUR)
		Utility.AddValue(getvaluesfolder, "noragdoll", Config.CUTSCENE_VALUES_DUR)
		Utility.AddValue(getvaluesfolder, "pause_gameplay", Config.CUTSCENE_VALUES_DUR)
		local clone3 = script.Success:Clone()
		clone3.Parent = character.UpperTorso
		clone3:Play()
		DebrisModule:AddItem(clone3, 10)
		EffectsEvent.ToAllInRange(character, "Blood Rupture VFX", character, "Hit")

		if clone then
			local clone4 = table.clone(v2)
			table.insert(clone4, character)
			EffectsEvent.ToAllInRange(rootPart, "Blood Rupture VFX", character, "UltimateCamera", clone4, clone)
		end

		local track = animator:LoadAnimation(script.User)
		track:Play()
		CharGrabPosCorrector.Do(character, track, Config.CUTSCENE_CORRECTOR_DUR, character)
	else
		EffectsEvent.ToAllInRange(character, "Blood Rupture VFX", player.Character, "MovementStop")
		BloodRuptureServer.Cancel(player, vector, state)
	end
end

function BloodRuptureServer.Cancel(player, _: Vector3, p)
	p.stage = "Cancel"
	EffectsEvent.ToAllInRange(player, "Blood Rupture VFX", player.Character, "Cancel")
end

return BloodRuptureServer