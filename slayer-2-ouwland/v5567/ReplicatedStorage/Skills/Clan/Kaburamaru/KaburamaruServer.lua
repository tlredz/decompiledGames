local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local CAM = ReplicatedStorage.CAM
local cleanit = require(ReplicatedStorage.Packages.cleanit)
local EffectsEvent = require(ReplicatedStorage.Communication.ServerAndClient.Effects.EffectsEvent)
local Utility = require(CAM.Global.Utility)
local Checker = require(CAM.Global.Checker)
local Combat_Util = require(ServerStorage.SAM.Services.Combat_Util)
local RaycastHelper = require(CAM.Global.RaycastHelper)
local ProjectileModeler = require(CAM.Global.ProjectileModeler)
local Skill_Switch_Adder = require(CAM.Global.Subsets.Gameplay.Skill_Switch_Adder)
local Config = require(script.Parent.Config)
local name = script.Parent.Name

-- equivalent calls inferred from this helper; original call sites unknown
local function hideAccessory(instance)
	return Utility.AddValue(
		Utility.getvaluesfolder(instance),
		"InvisibleItem",
		nil,
		"StringValue",
		Config.ACCESSORY_NAME
	)
end

local hit = script:FindFirstChild("Hit")
local v = {
	Slithering = script:FindFirstChild("Slithering"),
	ClimbOnTarget = hit and hit:FindFirstChild("ClimbOnTarget"),
	IdleOnTarget = hit and hit:FindFirstChild("IdleOnTarget"),
	Bite = hit and hit:FindFirstChild("Bite")
}

local function playClip(instance, p: string, flag: boolean?)
	local v2 = v[p]

	if instance == nil or instance.Parent == nil or v2 == nil then
		return nil
	end

	local animationController = instance:FindFirstChildOfClass("AnimationController") or instance:FindFirstChildOfClass("Humanoid")

	if animationController == nil then
		return nil
	end

	local v3 = animationController:FindFirstChildOfClass("Animator")

	if v3 == nil then
		v3 = Instance.new("Animator")
		v3.Parent = animationController
	end

	local track = v3:LoadAnimation(v2)
	track.Looped = flag == true
	track:Play()
	return track
end

local function spawnSerpent()
	local child = script:FindFirstChild(Config.RIG_NAME)

	if child == nil then
		return nil
	end

	local clone = child:Clone()
	local primaryPart = clone.PrimaryPart or clone:FindFirstChildWhichIsA("BasePart", true)

	if primaryPart == nil then
		clone:Destroy()
		return nil
	end

	clone.PrimaryPart = primaryPart
	primaryPart.Anchored = false
	primaryPart.CanCollide = false
	primaryPart.CanQuery = false
	primaryPart.Massless = true
	local weld = clone:FindFirstChildWhichIsA("Weld", true)
	clone.Parent = workspace.Debree
	return clone, primaryPart, weld
end

local function resolveAim(character, humanoidRootPart, vector2: Vector3?)
	local v2 = humanoidRootPart.Position + humanoidRootPart.CFrame.LookVector * Config.AIM_RANGE

	if vector2 == nil then
		return nil, v2, nil
	end

	local maximizeRayServer, _, _, v3 = RaycastHelper.MaximizeRayServer(
		character,
		humanoidRootPart.Position,
		vector2,
		Config.AIM_RANGE,
		true,
		Config.SPHERECAST_RADIUS,
		Config.DOWNCAST
	)
	local v4 = maximizeRayServer or v2

	if not (v3 ~= nil and Checker.check_victim(script, character, v3) ~= nil) then
		return nil, v4, nil
	end

	local humanoidRootPart2 = v3:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart2 == nil then
		return nil, v4, nil
	end

	if ((humanoidRootPart2.Position - humanoidRootPart.Position) * createVector(1, 0, 1)).Magnitude > Config.SHORT_RANGE then
		return nil, v4, v3
	end

	return v3, v4, v3
end

local function bite(p, target, base: number, p3: number, p4, noScaling: boolean?)
	if target.Parent == nil or Checker.check_victim(script, p, target) == nil then
		return
	end

	EffectsEvent.ToAllInRange(p, "KaburamaruVFX", p, "Bite", target)
	playClip(p4, "Bite")
	Combat_Util.Aggro(script, p, target)
	Combat_Util.Damage(script, p, target, {
		Base = base,
		Skill = name,
		NoScaling = noScaling
	})
	local getvaluesfolder = Utility.getvaluesfolder(target)

	if getvaluesfolder == nil then
		return
	end

	if p3 > 0 then
		Combat_Util.AddStun(script, p, getvaluesfolder, p3)
	end

	local v2 = Utility.AddValue(getvaluesfolder, Config.VENOM_VALUE, Config.BITE_VENOM_DURATION, "ObjectValue", p)
	v2:SetAttribute("Skill", name)
	v2:SetAttribute("PercentHealth", Config.VENOM_MAX_HEALTH_RATIO)
end

local function latch(p, instance, target, p2, p3: string)
	local part = target:FindFirstChild(Config.LATCH_PART) or target:FindFirstChild("HumanoidRootPart")

	if part == nil then
		return
	end

	local serpent, v4, v5 = spawnSerpent()

	if serpent == nil then
		return
	end

	if v5 == nil then
		v5 = Instance.new("Weld")
		v5.Parent = v4
	end

	v5.Part0 = part

	if v5.Part1 == nil then
		v5.Part1 = v4
	end

	local v6 = playClip(serpent, "ClimbOnTarget")

	if v6 == nil then
		playClip(serpent, "IdleOnTarget", true)
	else
		v6.Stopped:Once(function()
			playClip(serpent, "IdleOnTarget", true)
		end)
	end

	local maid = cleanit.new()
	p2.CleanIt = maid
	p2.target = target
	p2.serpent = serpent
	maid:Add(serpent)
	maid:Add(hideAccessory(instance))
	EffectsEvent.ToAllInRange(instance, "KaburamaruVFX", instance, "Captured", target)
	task.spawn(function()
		while true do
			task.wait(Config.LEASH_TICK)

			if p2.released then
				break
			end

			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")
			local humanoidRootPart2 = target:FindFirstChild("HumanoidRootPart")

			if not (humanoidRootPart == nil or humanoidRootPart2 == nil or (humanoidRootPart.Position - humanoidRootPart2.Position).Magnitude > Config.LEASH_RANGE) then
				continue
			end

			p2.released = true
			maid:Destroy()
			break
		end
	end)

	if p3 == "Far" then
		maid:Add(task.spawn(function()
			for _ = 1, math.floor(Config.FAR_DURATION / Config.FAR_BITE_INTERVAL) do
				task.wait(Config.FAR_BITE_INTERVAL)

				if p2.released or target.Parent == nil then
					break
				else
					bite(
						instance,
						target,
						Combat_Util.PercentHealthDamage(target, Config.FAR_BITE_RATIO),
						0,
						serpent,
						true
					)
				end
			end
		end))
		task.delay(Config.FAR_DURATION, function()
			if p2.released then
				return
			end

			p2.released = true
			maid:Destroy()
		end)
	else
		maid:Add(Skill_Switch_Adder.Add(p, name, Config.LATCH_DURATION))
		task.delay(Config.LATCH_DURATION, function()
			if p2.released then
				return
			end

			p2.released = true
			maid:Destroy()
		end)
	end
end

local function strike(player, character, humanoidRootPart, vector2: Vector3, instance, p)
	local v2 = (character:FindFirstChild(Config.SPAWN_PART) or humanoidRootPart).CFrame * Config.SPAWN_OFFSET
	local v3 = vector2 - v2.Position
	local unit

	if v3.Magnitude > 1 then
		unit = v3.Unit
	else
		unit = humanoidRootPart.CFrame.LookVector
	end

	local cframe = CFrame.lookAt(v2.Position, v2.Position + unit)
	local hidden = hideAccessory(character) -- equivalent call inferred; original call site unknown
	p.hidden = hidden
	EffectsEvent.ToAllInRange(character, "KaburamaruVFX", character, "Fire")
	local projectile = ProjectileModeler.new({
		Name = "KaburamaruSerpent",
		Size = Config.PROJECTILE_SIZE,
		Massless = true,
		CanCollide = false,
		Transparency = Config.PROJECTILE_TRANSPARENCY,
		CFrame = cframe,
		Mover = {
			MaxForce = Config.PROJECTILE_FORCE,
			VectorVelocity = unit * Config.PROJECTILE_SPEED
		},
		Rotator = {
			CFrame = cframe
		}
	}, function(_: Vector3?, _, p2)
		if p2 == nil then
			hidden:Destroy()
			return false
		end

		local find_character_from_descendant = Utility.find_character_from_descendant(p2)

		if find_character_from_descendant == nil or find_character_from_descendant == character then
			return false
		end

		latch(player, character, find_character_from_descendant, p, "Far")
		hidden:Destroy()
		return true
	end, Config.PROJECTILE_LIFETIME, ProjectileModeler.WhitelistType.Humanoids, character, nil, true)
	p.projectile = projectile
	local instance2 = projectile.Instance

	if instance2 ~= nil then
		local flying, v7, v8 = spawnSerpent()

		if flying ~= nil then
			if v8 ~= nil then
				v8:Destroy()
			end

			local weld = Instance.new("Weld")
			weld.Name = "SerpentWeld"
			weld.Part0 = instance2
			weld.Part1 = v7
			weld.C0 = Config.FLIGHT_ROTATION
			weld.Parent = v7
			playClip(flying, "Slithering", true)
			p.flying = flying
			instance2.Destroying:Connect(function()
				flying:Destroy()
			end)
		end
	end

	task.spawn(function()
		while projectile.IsActive do
			local instance3 = projectile.Instance

			if instance3 == nil or instance3.Parent == nil then
				break
			end

			local humanoidRootPart2 = character:FindFirstChild("HumanoidRootPart")

			if humanoidRootPart2 == nil or (humanoidRootPart2.Position - instance3.Position).Magnitude > Config.LEASH_RANGE then
				projectile:Destroy()
				hidden:Destroy()
				break
			else
				local humanoidRootPart3

				if instance ~= nil then
					humanoidRootPart3 = instance:FindFirstChild("HumanoidRootPart")
				end

				if humanoidRootPart3 ~= nil then
					local v6 = humanoidRootPart3.Position - instance3.Position

					if v6.Magnitude > 0.1 then
						if projectile.Mover ~= nil then
							projectile.Mover.VectorVelocity = v6.Unit * Config.PROJECTILE_SPEED
						end

						if projectile.Rotator ~= nil then
							projectile.Rotator.CFrame = Utility.SafeLookAt(
								instance3.Position,
								humanoidRootPart3.Position,
								instance3.CFrame
							)
						end
					end
				end

				task.wait(Config.TRACK_TICK)
			end
		end
	end)
end

local KaburamaruServer = {}
KaburamaruServer.Id = {}

function KaburamaruServer.Hold(player, _: Vector3?, _)
	local character = player.Character

	if character == nil then
		return
	end

	if character:FindFirstChild("HumanoidRootPart") == nil then
	end
end

function KaburamaruServer.UnHold(player, vector2: Vector3?, p)
	local character = player.Character

	if character == nil then
		return false
	end

	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart == nil then
		return false
	end

	local getvaluesfolder = Utility.getvaluesfolder(character)
	Utility.AddValue(getvaluesfolder, "pause_gameplay", Config.ENDLAG)
	local aim, v2, v3 = resolveAim(character, humanoidRootPart, vector2)

	if aim == nil then
		strike(player, character, humanoidRootPart, v2, v3, p)
		return false
	else
		latch(player, character, aim, p, "Close")
	end
end

function KaburamaruServer.Switch(player, _: Vector3?, state)
	local character = player.Character
	local target = state.target

	if character == nil or target == nil or state.released then
		return
	end

	bite(character, target, Config.BITE_DAMAGE, Config.BITE_STUN, state.serpent)
	state.released = true

	if state.CleanIt then
		state.CleanIt:Destroy()
	end
end

function KaburamaruServer.Cancel(_, _, state)
	if state == nil then
		return
	end

	state.released = true

	if state.CleanIt then
		state.CleanIt:Destroy()
	end

	if state.projectile and state.projectile.IsActive then
		state.projectile:Destroy()
	end

	if state.hidden then
		state.hidden:Destroy()
	end

	if state.flying then
		state.flying:Destroy()
	end
end

return KaburamaruServer