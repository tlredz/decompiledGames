local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local EffectsEvent = require(ReplicatedStorage.Communication.ServerAndClient.Effects.EffectsEvent)
local Utility = require(ReplicatedStorage.CAM.Global.Utility)
local Config = require(script.Parent.Config)
local RiceSpiritServer = {
	Id = {},
	Hold = function(player, _, p)
		p.Started = os.clock()
		local character = player.Character
		EffectsEvent.ToAllInRange(player, "Rice_Spirit_VFX", character, "Init")
	end
}
local Combat_Util = require(ServerStorage.SAM.Services.Combat_Util)
local ImpactSounds = require(ServerStorage.SAM.Utility.ImpactSounds)
local Combat_presets = require(ReplicatedStorage.CAM.Global.Combat_presets)
local CollectionService = game:GetService("CollectionService")
local script2 = script
local Checker = require(ReplicatedStorage.CAM.Global.Checker)
local TweenService = game:GetService("TweenService")
local tweenInfo = TweenInfo.new(Config.TP_DURATION)
local ManuelCancel = require(ReplicatedStorage.CAM.Global.Subsets.Gameplay.ManuelCancel)
local hit_priority_handler = require(ServerStorage.SAM.Game_Play.hit_priority_handler)
local v = hit_priority_handler.new(script)

function RiceSpiritServer.UnHold(player, _, p)
	local character = player.Character
	EffectsEvent.ToAllInRange(player, "Rice_Spirit_VFX", character, "Cancel")
	local primaryPart = character.PrimaryPart
	local humanoid = character:FindFirstChild("Humanoid")

	if primaryPart == nil or humanoid == nil then
		return
	end

	local getvaluesfolder = Utility.getvaluesfolder(player)
	local v2 = (os.clock() - p.Started) / Config.RADIUS_GROWTH_INTERVAL + Config.DEFAULT_RADIUS
	local v3 = {}

	for _, v4 in CollectionService:GetTagged("Humanoids") do
		if not (v4 ~= nil and v4.ClassName == "Model" and v4.PrimaryPart ~= nil and v4 ~= character) then
			continue
		end

		if not (vector.magnitude(v4.PrimaryPart.Position - primaryPart.Position) < v2 / 2 and Checker.check_victim(
			script2,
			character,
			v4
		) ~= nil) then
			continue
		end

		table.insert(v3, v4)
	end

	local flag = false
	local v4, v5 = ManuelCancel.new(player, Config.SEQUENCE_MAX_DUR)
	v4:Connect(function()
		flag = true
	end)
	local invs = Utility.AddValue(getvaluesfolder, "Transparent", Config.SEQUENCE_MAX_DUR)
	p.Invs = invs
	local v7 = Utility.AddValue(getvaluesfolder, "iframe", Config.SEQUENCE_MAX_DUR)
	local v8 = Utility.AddValue(getvaluesfolder, "pause_gameplay", Config.SEQUENCE_MAX_DUR)
	local v9 = Utility.AddValue(getvaluesfolder, "NR", Config.SEQUENCE_MAX_DUR)
	local cFrame = primaryPart.CFrame
	local part = Instance.new("Part")
	part.Anchored = true
	part.CanTouch = false
	part.CanCollide = false
	part.CFrame = cFrame
	part.Transparency = 1
	part.Parent = workspace.Debree
	local weld = Instance.new("Weld", part)
	weld.Part0 = part
	weld.Part1 = primaryPart
	EffectsEvent.ToAllInRange(player, "Rice_Spirit_VFX", character, "Disappear")
	task.wait(Config.TP_DURATION)
	local v10 = cFrame
	local targets = {}

	for _, v12 in v3 do
		local check_victim = Checker.check_victim(script2, character, v12)

		if check_victim == nil then
			continue
		end

		local humanoid2 = v12:FindFirstChild("Humanoid")
		local primaryPart2 = v12.PrimaryPart
		local getvaluesfolder2 = Utility.getvaluesfolder(v12)
		local cFrame2 = primaryPart2.CFrame
		TweenService:Create(part, tweenInfo, {
			CFrame = cFrame2
		}):Play()
		EffectsEvent.ToAllInRange(player, "Rice_Spirit_VFX", character, "TP", v10, cFrame2, primaryPart2)

		if check_victim == true then
			table.insert(targets, v12)
			Combat_presets.PlayReactAnim(humanoid2, nil, 0.5)
			Utility.AddValue(getvaluesfolder2, "iframe", Config.TP_VICTIM_IFRAME, "StringValue", character.Name)
			Combat_Util.Add_Strict_Stun(script, character, getvaluesfolder2, Config.TP_STUN)
			Combat_Util.Damage(script, character, v12, {
				Base = Config.TP_DAMAGE,
				Skill = script.Parent.Name
			})
			ImpactSounds.Play(character, script.Parent.Name, v12)
			Combat_Util.Knockback(
				script,
				character,
				primaryPart2,
				vector.create(0, Config.TP_KNOCKUP, 0),
				Config.TP_KNOCKBACK_DUR
			)
		elseif check_victim == "Perfect" then
			Combat_Util.Perfect(script, character, v12)
			flag = true
		elseif check_victim == "Blocking" then
			Combat_Util.Block(script, character, v12, Config.TP_BLOCK_BREAK)
		end

		task.wait(Config.TP_DURATION)

		if flag then
			break
		else
			v10 = cFrame2
		end
	end

	if #v3 > 0 then
		TweenService:Create(part, tweenInfo, {
			CFrame = cFrame
		}):Play()
		task.wait(Config.TP_DURATION)
		part.CFrame = cFrame
		EffectsEvent.ToAllInRange(player, "Rice_Spirit_VFX", character, "ReAppear")
	end

	if #v3 == 0 or flag then
		EffectsEvent.ToAllInRange(player, "Rice_Spirit_VFX", character, "Cancel")
	end

	invs:Destroy()

	if #v3 > 0 and not flag then
		local track = humanoid.Animator:LoadAnimation(script.EndAnim)
		track:Play()
		track:AdjustSpeed(Config.FINAL_ANIM_SPEED)
		task.wait(Config.FINAL_HIT_DELAY)
		Utility.CreateHitbox({
			caster = character,
			hitboxCFrame = primaryPart.CFrame,
			hitboxSize = Config.FINAL_HITBOX_SIZE,
			checker = Checker,
			hitPriorityHandler = {
				callback = v.Exists,
				data = "Choosing_1"
			},
			TreeDestruction = true,
			hitDetected = function(instance, p2, p3)
				if instance then
					local rootPart = instance:FindFirstChild("Humanoid").RootPart

					if p3 == "Perfect" then
						Combat_Util.Perfect(script, character, instance)
					elseif p3 == "Blocking" then
						Combat_Util.Block(script, character, instance, Config.FINAL_BLOCK_BREAK)
					elseif p3 == true then
						Combat_Util.Damage(script, character, instance, {
							Base = Config.FINAL_DAMAGE,
							Skill = script.Parent.Name
						})
						Combat_Util.RagDoll(script, character, p2, Config.FINAL_RAGDOLL)
						Combat_Util.Add_Strict_Stun(script, character, p2, Config.FINAL_STUN)
						Combat_Util.Knockback(
							script,
							character,
							rootPart,
							vector.normalize(rootPart.Position - primaryPart.Position) * Config.FINAL_KNOCKBACK + vector.create(
								0,
								Config.FINAL_KNOCKUP,
								0
							),
							Config.FINAL_KNOCKBACK_DUR
						)
					end
				end
			end,
			targets = targets,
			After = function(p2, list)
				if p2 then
					ImpactSounds.Play(character, script.Parent.Name, list[1])
				end
			end
		})
		EffectsEvent.ToAllInRange(player, "Rice_Spirit_VFX", character, "FinalHit", v3)
	end

	v5()

	if not flag then
		task.wait(0.5)
	end

	part:Destroy()
	v7:Destroy()
	v8:Destroy()
	v9:Destroy()
end

function RiceSpiritServer.Cancel(player, _, p)
	local character = player.Character
	EffectsEvent.ToAllInRange(player, "Rice_Spirit_VFX", character, "Cancel")

	if p ~= nil and p.Invs ~= nil then
		p.Invs:Destroy()
		p.Invs = nil
	end
end

return RiceSpiritServer