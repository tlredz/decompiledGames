local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
game:GetService("RunService")
game:GetService("TweenService")
game:GetService("CollectionService")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local CAM = ReplicatedStorage:WaitForChild("CAM")
local SAM = ServerStorage:WaitForChild("SAM")
local global = CAM:WaitForChild("Global")
local services = SAM:WaitForChild("Services")
local EffectsEvent = require(ReplicatedStorage2.Communication.ServerAndClient.Effects.EffectsEvent)
local Utility = require(global.Utility)
local Checker = require(global.Checker)
local Combat_Util = require(services.Combat_Util)
require(CAM.Global.Combat_presets)
local hit_priority_handler = require(SAM.Game_Play.hit_priority_handler)
local v = hit_priority_handler.new(script)
local ManuelCancel = require(global.Subsets.Gameplay.ManuelCancel)
local StatTypes = require(CAM.Global.Types.StatTypes)
require(CAM.Client.Modules.Effects.vfxUtility)
local DebrisModule = require(CAM:FindFirstChild("DebrisModule"))
local Cutscene_camera_handler = require(SAM:FindFirstChild("Game_Play"):FindFirstChild("Cutscene_camera_handler"))
local CharGrabPosCorrector = require(global.Subsets.Gameplay.CharGrabPosCorrector)
local Config = require(script.Parent.Config)
local ServerStorage2 = game:GetService("ServerStorage")
local Server_Mouse_Pos = require(ServerStorage2.SAM.Services.Server_Mouse_Pos)
local new = Vector3.new
local _ = tick
local FlutteringStingServer = {
	Id = {},
	Hold = function(player, _, _)
		if not player then
			return
		end

		local character = player.Character

		if not character then
			return
		end

		EffectsEvent.ToAllInRange(player, "Fluterring_Sting_VFX", character, "Hold")
	end
}

function FlutteringStingServer.UnHoldAfterClient(player, p, _, p2, p3)
	if not player then
		return
	end

	local character = player.Character

	if not (character and typeof(p2) == "CFrame") then
		return
	end

	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

	if not humanoidRootPart then
		return
	end

	local clamped = Server_Mouse_Pos.Clamp(character, p2.Position, Config.RANGE + 15)

	if clamped == nil then
		return
	end

	local v2 = p2.Rotation + clamped
	local v3 = false
	local humanoid = character:WaitForChild("Humanoid")
	p3.Value_Table = {}
	local position = v2.Position
	EffectsEvent.ToAllInRange(player, "Fluterring_Sting_VFX", character, "Landing")
	local getvaluesfolder = Utility.getvaluesfolder(character)
	local v4 = FlutteringStingServer.Id[player.UserId]
	local v5, v6 = ManuelCancel.new(player)
	v5:Connect(function()
		if player and player.Parent == game.Players then
			FlutteringStingServer.Id[player.UserId] = 0
			FlutteringStingServer.Cancel(player, p, p3)
			v6()
		end
	end)
	local v7 = CFrame.new(position - createVector(0, 0.45, 0)) * Utility.SafeLookAt(
		new(humanoidRootPart.Position.X, 0, humanoidRootPart.Position.Z),
		new(position.X, 0, position.Z),
		humanoidRootPart.CFrame
	).Rotation
	local v8 = false
	local clone = nil
	local playerFromCharacters = {}

	local function fn(instance, parent, p4, _)
		if instance then
			local humanoid2 = instance:FindFirstChild("Humanoid")
			local rootPart = humanoid2.RootPart

			if p4 == "Blocking" or p4 == "Perfect" then
				Combat_Util.Block(script, character, instance, Config.IMPACT_BLOCK_BREAK)
			elseif p4 == true then
				local name = script.Parent.Name .. " Skill Hitlist"

				if character:FindFirstChild(name) then
					character:FindFirstChild(name):Destroy()
				end

				local folder = Instance.new("Folder", character)
				folder.Name = name
				DebrisModule:AddItem(folder, Config.ANIM_DURATION)
				table.insert(p3.Value_Table, folder)
				local objectValue = Instance.new("ObjectValue")
				objectValue.Name = instance.Name
				objectValue.Value = instance
				objectValue.Parent = folder
				local part = Instance.new("Part")
				part.Anchored = true
				part.Transparency = 1
				part.Massless = true
				part.CFrame = v7
				part.CanCollide = false
				part.Parent = workspace.Debree
				table.insert(p3.Value_Table, part)
				DebrisModule:AddItem(part, Config.ANIM_DURATION)

				if v3 == false then
					v3 = true
				end

				local name2 = script.Parent.Name .. character.Name .. "Camera"

				if clone == nil then
					local numberValue = Instance.new("NumberValue")
					numberValue.Value = Config.CUTSCENE_FOV
					numberValue.Name = "FOV"
					numberValue.Parent = parent
					DebrisModule:AddItem(numberValue, Config.ANIM_DURATION - 0.2)
					table.insert(p3.Value_Table, numberValue)
					local numberValue2 = Instance.new("NumberValue")
					numberValue2.Value = Config.CUTSCENE_FOV
					numberValue2.Name = "FOV"
					numberValue2.Parent = getvaluesfolder
					DebrisModule:AddItem(numberValue2, Config.ANIM_DURATION - 0.2)
					table.insert(p3.Value_Table, numberValue2)
					clone = script.CameraRig:Clone()
					clone.Name = name2
					clone.PrimaryPart.CFrame = part.CFrame * CFrame.new(0, 1.75, 0) * CFrame.fromEulerAnglesYXZ(
						-0,
						-1.0639230652031983e-7,
						-6.088167893002899e-16
					)
					clone.Parent = workspace.Debree
					DebrisModule:AddItem(clone, Config.ANIM_DURATION - 0.2)
					table.insert(p3.Value_Table, clone)
					local track = clone.AnimationController:LoadAnimation(script.Camera)
					track:Play()
					track:AdjustSpeed(Config.ANIM_SPEED)
					Cutscene_camera_handler.Regular(player, clone.Bone)
				end

				local playerFromCharacter = clone ~= nil and game.Players:GetPlayerFromCharacter(instance)

				if playerFromCharacter then
					Cutscene_camera_handler.Regular(playerFromCharacter, clone.Bone)
				end

				local boolValue = Instance.new("BoolValue")
				boolValue.Name = "pause_gameplay"
				boolValue.Parent = parent
				DebrisModule:AddItem(boolValue, Config.ANIM_DURATION)
				table.insert(p3.Value_Table, boolValue)
				local stringValue = Instance.new("StringValue")
				stringValue.Name = "iframe"
				stringValue.Value = getvaluesfolder.Name
				stringValue.Parent = parent
				DebrisModule:AddItem(stringValue, Config.ANIM_DURATION)
				table.insert(p3.Value_Table, stringValue)
				local boolValue2 = Instance.new("BoolValue")
				boolValue2.Name = "noragdoll"
				boolValue2.Parent = parent
				DebrisModule:AddItem(boolValue2, Config.ANIM_DURATION)
				table.insert(p3.Value_Table, boolValue2)

				if game.Players:GetPlayerFromCharacter(instance) then
					table.insert(playerFromCharacters, game.Players:GetPlayerFromCharacter(instance))
				end

				local weld = Instance.new("Weld")
				weld.Part0 = part
				weld.Part1 = rootPart
				weld.Parent = part
				table.insert(p3.Value_Table, weld)
				local track = humanoid2.Animator:LoadAnimation(script.Victim)
				track:Play()
				track:AdjustSpeed(Config.ANIM_SPEED)
				table.insert(p3.Value_Table, track)
				Combat_Util.AddStun(script, character, parent, Config.IMPACT_STUN)

				if v8 == false then
					v8 = true
					EffectsEvent.ToAllInRange(
						player,
						"Fluterring_Sting_VFX",
						character,
						"Cutscene",
						{ name2, Config.ANIM_DURATION, folder }
					)
				end

				task.delay(Config.THRUST_DAMAGE_AT, function()
					if FlutteringStingServer.Id[player.UserId] ~= v4 then
						return
					end

					if FlutteringStingServer.Id[player.UserId] == v4 and character and Checker.check_victim(
						script,
						character,
						instance
					) ~= nil then
						Combat_Util.Damage(script, character, instance, {
							Base = Config.THRUST_DAMAGE,
							Skill = script.Parent.Name
						})
					end

					task.wait(Config.EXPLOSION_DELAY)

					if FlutteringStingServer.Id[player.UserId] == v4 and character and Checker.check_victim(
						script,
						character,
						instance
					) ~= nil then
						Combat_Util.AddStun(script, character, parent, Config.EXPLOSION_STUN)
						Combat_Util.Damage(script, character, instance, {
							Base = Config.EXPLOSION_DAMAGE,
							Skill = script.Parent.Name
						})
						local v11 = Utility.AddValue(parent, Config.SLOW_VALUE, Config.SLOW_DURATION)
						v11:AddTag(StatTypes.ValueStatTag)
						v11:SetAttribute(StatTypes.StatToAttribute("Movement Speed Factor"), Config.SLOW_FACTOR)
					end
				end)
				task.delay(Config.ANIM_DURATION, function()
					if FlutteringStingServer.Id[player.UserId] ~= v4 then
						return
					end

					if p3.Value_Table then
						for _, animationTrack in p3.Value_Table do
							if animationTrack:IsA("AnimationTrack") then
								animationTrack:Stop()
							end

							animationTrack:Destroy()
						end
					end
				end)
			end
		end
	end

	Utility.CreateHitbox({
		caster = character,
		hitboxCFrame = v7,
		hitboxSize = Config.IMPACT_HITBOX_SIZE,
		checker = Checker,
		hitPriorityHandler = {
			callback = v.Exists,
			data = "Choosing_1"
		},
		hitDetected = fn
	})

	if v3 == true then
		local boolValue = Instance.new("BoolValue")
		boolValue.Name = "NOMouvementlines"
		boolValue.Parent = getvaluesfolder
		DebrisModule:AddItem(boolValue, Config.ANIM_DURATION)
		table.insert(p3.Value_Table, boolValue)
		local boolValue2 = Instance.new("BoolValue")
		boolValue2.Name = "pause_gameplay"
		boolValue2.Parent = getvaluesfolder
		DebrisModule:AddItem(boolValue2, Config.ANIM_DURATION)
		table.insert(p3.Value_Table, boolValue2)
		local boolValue3 = Instance.new("BoolValue")
		boolValue3.Name = "iframe"
		boolValue3.Parent = getvaluesfolder
		DebrisModule:AddItem(boolValue3, Config.ANIM_DURATION)
		table.insert(p3.Value_Table, boolValue3)
		local boolValue4 = Instance.new("BoolValue")
		boolValue4.Name = "noragdoll"
		boolValue4.Parent = getvaluesfolder
		DebrisModule:AddItem(boolValue4, Config.ANIM_DURATION)
		table.insert(p3.Value_Table, boolValue4)
		local part = Instance.new("Part")
		part.Anchored = true
		part.Massless = true
		part.Transparency = 1
		part.CFrame = v7
		part.CanCollide = false
		part.Parent = workspace.Debree
		table.insert(p3.Value_Table, part)
		DebrisModule:AddItem(part, Config.ANIM_DURATION)
		local weld = Instance.new("Weld")
		weld.Part0 = part
		weld.Part1 = humanoidRootPart
		weld.Parent = part
		DebrisModule:AddItem(weld, Config.ANIM_DURATION)
		table.insert(p3.Value_Table, weld)
		local track = humanoid:LoadAnimation(script.User)
		track:Play()
		track:AdjustSpeed(Config.ANIM_SPEED)
		track.Priority = Enum.AnimationPriority.Action3
		table.insert(p3.Value_Table, track)
		CharGrabPosCorrector.Do(character, track, Config.ANIM_DURATION, character)
	else
		EffectsEvent.ToAllInRange(player, "Fluterring_Sting_VFX", character, "Missed")
	end

	playerFromCharacters = nil
end

function FlutteringStingServer.UnHold(player, _, _)
	if not player then
		return
	end

	local character = player.Character

	if not (character and character:FindFirstChild("HumanoidRootPart") and character:FindFirstChild("Animator", true)) then
		return
	end

	EffectsEvent.ToAllInRange(player, "Fluterring_Sting_VFX", character, "Jump")
end

function FlutteringStingServer.Cancel(player, _, p)
	if not player then
		return
	end

	local character = player.Character

	if not (character and character:FindFirstChild("HumanoidRootPart")) then
		return
	end

	EffectsEvent.ToAllInRange(player, "Fluterring_Sting_VFX", character, "Cancel")

	if p.Value_Table then
		for _, animationTrack in p.Value_Table do
			if animationTrack:IsA("AnimationTrack") then
				animationTrack:Stop()
			end

			animationTrack:Destroy()
		end
	end
end

return FlutteringStingServer