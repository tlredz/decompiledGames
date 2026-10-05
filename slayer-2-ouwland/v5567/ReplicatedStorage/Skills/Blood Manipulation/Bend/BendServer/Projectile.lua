local createVector = vector.create
game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("ServerStorage")
game:GetService("RunService")
game:GetService("TweenService")
local Debris = game:GetService("Debris")
local CollectionService = game:GetService("CollectionService")
local EffectsEvent = require(ReplicatedStorage.Communication.ServerAndClient.Effects.EffectsEvent)
local Utility = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Utility"))
local Combat_Util = require(game.ServerStorage:WaitForChild("SAM"):WaitForChild("Services"):WaitForChild("Combat_Util"))
local Checker = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Checker"))
local Combat_presets = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Combat_presets"))
require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Subsets"):WaitForChild("Gameplay"):WaitForChild("ManuelCancel"))
local Character_info_provider = require(ReplicatedStorage.CAM.Global.Character_info_provider)
local Config = require(script.Parent.Parent.Config)
local _ = script.Parent
local Projectile = {
	projectiles = {}
}

local function calculateChildrenMass(folder)
	local descendants = folder:GetDescendants()
	table.insert(descendants, folder)
	local total = 0

	for _, part in descendants do
		if part:IsA("BasePart") then
			total += part:GetMass()
		end
	end

	return total
end

local hit_priority_handler = require(game.ServerStorage:WaitForChild("SAM"):WaitForChild("Game_Play"):WaitForChild("hit_priority_handler"))
local v = hit_priority_handler.new(script)

function Projectile.Expire(_, p, p2, flag: boolean)
	EffectsEvent.ToAllInRange(p, "BloodSickleBend_effs", p, "Expire", p2, flag)
	p2.Name = "_"
	pcall(Projectile.projectiles[p2].CleanupFunction)
	Projectile.projectiles[p2] = nil
	p2.Anchored = true
	Debris:AddItem(p2, 2)
end

function Projectile.GetProjectile(_, p)
	for k, projectile in Projectile.projectiles do
		if projectile.Character == p then
			return k
		end
	end
end

local raycastParams = RaycastParams.new()
raycastParams.FilterDescendantsInstances = { workspace.Map }
raycastParams.FilterType = Enum.RaycastFilterType.Include
raycastParams.IgnoreWater = true
raycastParams.RespectCanCollide = true

local function timedThread(fn, value)
	local thread = coroutine.create(fn)
	task.delay(value or 5, function()
		if coroutine.status(thread) == "running" then
			coroutine.close(thread)
		end
	end)
	local v2, v3 = coroutine.resume(thread)

	if not v2 then
		warn(v3)
	end

	return thread
end

local _ = table.insert
local _ = table.find

function Projectile:Chainsaw(instance, instance2)
	if not Projectile.projectiles[instance2].Active then
		return false
	end

	local cFrame = instance2.CFrame
	local _ = instance2.Size
	instance2.Name = "_"
	pcall(Projectile.projectiles[instance2].CleanupFunction)
	Projectile.projectiles[instance2] = nil
	local raycastResult = workspace:Raycast(cFrame.Position, createVector(-0, -9, -0), raycastParams)

	if raycastResult then
		local lookVector = cFrame.LookVector
		local _ = cFrame.RightVector
		local normal = raycastResult.Normal
		local unit = (lookVector - lookVector:Dot(normal) * normal).Unit
		local cross = normal:Cross(unit)
		cFrame = CFrame.fromMatrix(raycastResult.Position, cross, normal, unit) * Config.CHAINSAW_GROUND_OFFSET
	end

	instance2.Anchored = true
	Debris:AddItem(instance2, 2)
	EffectsEvent.ToAllInRange(instance, "BloodSickleBend_effs", instance, "Chainsaw", instance2, cFrame)
	local CHAINSAW_HITBOX_SIZE = Config.CHAINSAW_HITBOX_SIZE
	timedThread(function()
		local getvaluesfolder = Utility.getvaluesfolder(instance)
		local now = os.clock()

		while now + Config.CHAINSAW_DURATION > os.clock() do
			local modelInRegion = Utility.GetModelInRegion(cFrame, CHAINSAW_HITBOX_SIZE, nil, nil)

			for _, v2 in pairs(modelInRegion) do
				if not (v2 ~= instance and v2:FindFirstChild("Humanoid") ~= nil) then
					continue
				end

				local humanoidRootPart = v2:FindFirstChild("HumanoidRootPart")
				local humanoid = v2:FindFirstChild("Humanoid")
				local check_victim, _ = Checker.check_victim(script, instance, v2)
				local getvaluesfolder2 = Utility.getvaluesfolder(v2)

				if v.Both(getvaluesfolder2, {
					pv = getvaluesfolder,
					name = "Choosing_1"
				}) == true then
					continue
				end

				local humanoidRootPart2 = instance:FindFirstChild("HumanoidRootPart")

				if not (humanoidRootPart ~= nil and humanoid ~= nil and humanoidRootPart2 ~= nil) then
					continue
				end

				if check_victim == "Blocking" or check_victim == "Perfect" then
					Combat_Util.Block(script, instance, v2, Config.CHAINSAW_BLOCK_BREAK)
				elseif check_victim == true then
					Combat_Util.AddStun(script, instance, getvaluesfolder2, Config.CHAINSAW_STUN)
					Combat_Util.Damage(script, instance, v2, {
						Base = Config.CHAINSAW_DAMAGE,
						Skill = script.Parent.Parent.Name
					})
					Combat_presets.stop_extra_anims(humanoid)
					local v3 = math.random(1, 5)
					local v4 = v3 == 5 and 6 or v3
					local track = humanoid.Animator:LoadAnimation(Character_info_provider.get_core_anim(
						instance,
						"React_" .. v4
					))
					track:AdjustSpeed(2.25)
					track:Play()
					Combat_Util.Knockback(script, instance, humanoidRootPart, createVector(0, 0.01, 0), 0.125)
				end
			end

			task.wait(Config.CHAINSAW_TICK_INTERVAL)
		end
	end, 2)
end

function Projectile.Shoot(_, player, instance)
	local clone = script:WaitForChild("Projectile"):Clone()
	clone.CFrame = instance.PrimaryPart.CFrame * Config.PROJECTILE_SPAWN_OFFSET
	local alignOrientation = clone:FindFirstChild("AlignOrientation")
	alignOrientation.CFrame = clone.CFrame
	clone.Name = "BendProjectile" .. instance.Name
	clone.Parent = workspace.Debree.Projectiles
	local v2 = calculateChildrenMass(clone)
	local bodyForce = Instance.new("BodyForce")
	bodyForce.Force = Vector3.new(0, v2 * workspace.Gravity, 0)
	bodyForce.Parent = clone
	task.delay(0.001, function()
		EffectsEvent.ToAllInRange(player, "BloodSickleBend_effs", instance, "Startup", clone)
	end)

	if typeof(player) == "Instance" and player:IsA("Player") then
		clone:SetNetworkOwner(player)
	end

	Projectile.projectiles[clone] = {
		Active = true,
		Character = instance,
		Rig = clone,
		Connection = nil,
		CleanupFunction = nil,
		Hits = {},
		StartAt = os.clock(),
		Launch = clone.Position
	}

	local function fn()
		if Projectile.projectiles[clone] ~= nil and Projectile.projectiles[clone].Connection and Projectile.projectiles[clone].Connection.Connected then
			Projectile.projectiles[clone].Connection:Disconnect()
		end
	end

	Projectile.projectiles[clone].CleanupFunction = fn
	Projectile.projectiles[clone].Connection = clone.Touched:Connect(function(otherPart)
		if Projectile.projectiles[clone] == nil then
			return
		end

		local v3 = os.clock() - Projectile.projectiles[clone].StartAt

		if v3 < Config.PROJECTILE_ARM_TIME or (clone.Position - Projectile.projectiles[clone].Launch).Magnitude > Config.FLIGHT_SPEED * v3 + 25 then
			return
		end

		if otherPart:IsDescendantOf(workspace.Map) then
			return Projectile:Chainsaw(instance, clone)
		end

		local model = otherPart:FindFirstAncestorWhichIsA("Model")

		if not (model and CollectionService:HasTag(model, "Humanoids") and model ~= instance) then
			return
		end

		Projectile:Chainsaw(instance, clone)
	end)
	task.delay(Config.PROJECTILE_LIFETIME, fn)
	Debris:AddItem(clone, Config.PROJECTILE_LIFETIME)
	return clone
end

return Projectile