local createVector = vector.create
game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
require(game.ReplicatedStorage.Modules.AnimationUtil)
local WeaponData = require(game.ReplicatedStorage.Modules.WeaponData)
local Flags = require(game.ReplicatedStorage.Modules.Flags)
local Net = require(game.ReplicatedStorage.Modules.Net)
local GetBoundingBoxCustom = require(game.ReplicatedStorage.Modules.Part.GetBoundingBoxCustom)
local GetCornersOfPart = require(game.ReplicatedStorage.Modules.Part.GetCornersOfPart)
local CombatUtil = {}
local localPlayer = game.Players.LocalPlayer
local enemies = workspace.Enemies
local characters = workspace.Characters
local WrapHighlight = require(game.ReplicatedStorage.Util.WrapHighlight)
local HighlightAdornee = require(game.ReplicatedStorage.Util.HighlightAdornee)
local isServer = RunService:IsServer()
local v = {}
local object = setmetatable({}, {
	__mode = "k"
})
local v2 = nil
local v3 = nil
task.defer(function()
	local Util = require(game.ReplicatedStorage.Util)
	v2 = Util
	local Particle = require(script.Particle)
	v3 = Particle
	v.RegisterHitEvent = Net:RemoteEvent("RegisterHit", true)
	v.ReceivedHit = Net:RemoteEvent("ReceivedHit")
end)

function CombatUtil:GetPureWeaponName(value)
	return string.lower(string.gsub(value, "%s", ""))
end

function CombatUtil.GetComboPaddingTime(_)
	return 0.3
end

function CombatUtil:GetDefaultAOEDelay()
	return 0.35
end

function CombatUtil.GetAttackCancelMultiplier(_)
	return 0.8
end

local IsTransformed = require(game.ReplicatedStorage.Util.IsTransformed)

function CombatUtil:HasRigEquipped(instance)
	if instance:FindFirstChild("HumanoidRootPart") and instance.HumanoidRootPart:FindFirstChild("Buddha") or instance:FindFirstChild("DogHouseForm") then
		return false
	end

	return IsTransformed(instance, false, false)
end

function CombatUtil.CanAttack(_, instance, p)
	local Global = require(game.ReplicatedStorage.Global)

	if (Global.tapCooldown or 0) > os.clock() then
		return
	end

	local humanoid = instance and instance:FindFirstChildWhichIsA("Humanoid")

	if not humanoid or humanoid.Health <= 0 then
		return
	end

	local stun = instance:FindFirstChild("Stun")
	local busy = instance:FindFirstChild("Busy")

	if humanoid.Sit and (p == "Sword" or p == "Melee" or p == "Gun") or (stun and stun.Value > 0 or busy and busy.Value) then
		return
	end

	if CombatUtil:HasRigEquipped(instance) then
		return
	else
		return true
	end
end

function CombatUtil:IsVulnerable(instance)
	if not instance then
		return
	end

	local v4 = (instance and instance:FindFirstChildWhichIsA("Humanoid")).Health > 0

	if not RunService:IsServer() then
		return v4
	end

	local Global = require(game.ReplicatedStorage.Global)
	local wrappedPlayer = Global.getWrappedPlayer(Players:GetPlayerFromCharacter(instance))
	return not (wrappedPlayer and wrappedPlayer:dodging()) and v4
end

function CombatUtil:GetRigOfHitPart(instance)
	local tool = instance:FindFirstAncestorWhichIsA("Tool")

	if tool then
		return tool.Parent
	end

	for _, v4 in { enemies, characters } do
		for _, ancestor in v4:GetChildren() do
			if instance:IsDescendantOf(ancestor) then
				return ancestor
			end
		end
	end
end

local v4 = {}
local flag = false
local overlapParams = nil

for _, v5 in {
	"RightUpperArm",
	"RightLowerArm",
	"RightHand",
	"RightUpperLeg",
	"RightLowerLeg",
	"RightFoot",
	"LeftUpperArm",
	"LeftLowerArm",
	"LeftHand",
	"LeftUpperLeg",
	"LeftLowerLeg",
	"LeftFoot",
	"UpperTorso",
	"LowerTorso",
	"Head",
	"ModelHitbox"
} do
	v4[v5] = true
end

function removeFromTableBackwards(list, p)
	repeat
		local index = table.find(list, p)

		if index then
			table.remove(list, index)
		end
	until not index
end

function CombatUtil.GetHitDetectionParams(_)
	if flag then
		return overlapParams
	end

	overlapParams = OverlapParams.new()
	flag = true
	return overlapParams
end

local v5 = {}

function CombatUtil.ToggleLoadMovesetAnims(_, p, data, p2)
	for k, v6 in data.WeaponType == "Gun" and data.Moveset or data.Moveset.Basic do
		local name

		if data.Moveset.Basic then
			name = CombatUtil:GetPureWeaponName(data.Name) .. "-basic" .. k
		else
			name = CombatUtil:GetPureWeaponName(data.Name) .. "-" .. k
		end

		if p2 then
			if not v5[p] then
				v5[p] = {}
			end

			local looped = v6.Looped
			local v8 = v2.Anims:Get(p.Parent, v6.AnimationId)

			if v8 then
				v8._Object.Name = name

				if string.match(name, "Idle") then
					v8._Object.Looped = true
				else
					v8._Object.Looped = looped
					v8._Object.Priority = Enum.AnimationPriority.Action
					v8._Object:SetAttribute("SpeedMult", v6.SpeedMult)
				end

				v5[p][name] = v8
			end
		elseif v5[p] then
			local v8 = v5[p][name]

			if v8 then
				v8:Stop()

				if typeof(v8) == "Instance" then
					v8:Destroy()
				else
					v8.Animation:Destroy()
				end
			end

			v5[p][name] = nil

			if not next(v5[p]) then
				v5[p] = nil
			end
		end
	end
end

function CombatUtil:GetMovesetAnimCache(p)
	return v5[p]
end

function CombatUtil.GetLoadedAnimsFor(_, p, p2)
	local pureWeaponName = CombatUtil:GetPureWeaponName(p)
	local result = {}
	local movesetAnimCache = CombatUtil:GetMovesetAnimCache(p2)

	if not movesetAnimCache then
		return result
	end

	for k, v6 in movesetAnimCache do
		local v7, v8 = string.match(k, "(.+)-(.+)")

		if v7 == pureWeaponName then
			result[v8] = v6
		end
	end

	return result
end

function CombatUtil.AttackStart(_, p, combo)
	if not (p and p.Parent) then
		return
	end

	local humanoid = p.Parent:FindFirstChild("Humanoid")
	local rootPart = humanoid and humanoid.RootPart
	local parent = rootPart and rootPart.Parent

	if not parent then
		return
	end

	local Effect = require(game.ReplicatedStorage.Effect)
	local equippedWeapon = parent:FindFirstChild("EquippedWeapon")
	local weaponName = CombatUtil:GetWeaponName(equippedWeapon or p)
	local pureWeaponName = CombatUtil:GetPureWeaponName(weaponName)
	local weaponData = CombatUtil:GetWeaponData(weaponName)
	local moveset = weaponData.Moveset
	assert(moveset.Basic, (`Couldn't find the 'Basic' moveset for {weaponName}`))
	local v6 = moveset.Basic[combo]
	local vFXDelay = weaponData.VFXDelay or v6.VFXDelay
	local isDescendant = parent:IsDescendantOf(enemies)

	if equippedWeapon then
		for _, effect in equippedWeapon:GetDescendants() do
			if effect:IsA("Trail") and pureWeaponName ~= "dragontalon" then
				effect.Enabled = true
			elseif effect.Name == "HitEffect" and effect:IsA("ParticleEmitter") then
				local v7 = effect
				task.delay(vFXDelay or 0.25, function()
					v7:Emit(v7:GetAttribute("EmitCount") or 1)
				end)
			end
		end

		local v7 = localPlayer and parent ~= localPlayer.Character

		if isDescendant or v7 then
			task.delay(0.75, function()
				for _, trail in equippedWeapon:GetDescendants() do
					if trail:IsA("Trail") then
						trail.Enabled = false
					end
				end
			end)
		end
	end

	if pureWeaponName == "superhuman" or pureWeaponName == "godhuman" then
		task.delay(0.25, function()
			Effect.new("Chop.Punch"):play({
				Character = parent,
				God = pureWeaponName == "godhuman"
			})
		end)
	elseif pureWeaponName == "divineart" then
		task.defer(function()
			Effect.new("Angel.M1"):play({
				hrp = rootPart,
				index = combo
			})
		end)
	elseif pureWeaponName == "flail" then
		task.delay(0.3, function()
			Effect.new("Chop.Punch"):play({
				Character = parent,
				God = true
			})
		end)
	elseif pureWeaponName == "dragontalon" then
		task.defer(function()
			task.delay(0.25, function()
				Effect.new("DragonTalon.M1"):play({
					Root = rootPart,
					Index = combo
				})
			end)
		end)
	elseif pureWeaponName == "sanguineart" then
		task.defer(function()
			Effect.new("Ghoul.M1"):play({
				Root = rootPart,
				Combo = combo
			})
		end)
	elseif pureWeaponName == "sharkmankarate" then
		task.defer(function()
			Effect.new("Sharkman2.M1"):play({
				Character = parent,
				Humanoid = humanoid,
				Combo = combo
			})
		end)
	elseif pureWeaponName == "fishmankarate" then
		task.defer(function()
			Effect.new("WaterKungfu.M1"):play({
				Character = parent,
				Humanoid = humanoid,
				Combo = combo
			})
		end)
	elseif pureWeaponName == "anchor" then
		task.defer(function()
			local animation = Instance.new("Animation")
			animation.AnimationId = "rbxassetid://14798724768"
			local animation2 = Instance.new("Animation")
			animation2.AnimationId = "rbxassetid://14798726082"
			local animation3 = Instance.new("Animation")
			animation3.AnimationId = "rbxassetid://14798728487"
			local animation4 = Instance.new("Animation")
			animation4.AnimationId = "rbxassetid://14798729807"
			equippedWeapon.Right.Anchor.AnimationController:LoadAnimation(({
				animation,
				animation2,
				animation3,
				animation4
			})[combo]):Play()
			task.delay(0.2, function()
				v2.Sound:Play("SwordSwing", parent.HumanoidRootPart)
			end)

			if combo == 4 and parent == localPlayer.Character then
				task.delay(0.2, function()
					v2.BodyMover.new(parent):Create("BodyVelocity", {
						Velocity = parent.HumanoidRootPart.CFrame.lookVector * 100,
						Duration = 0.15
					})
				end)
			end
		end)
	end

	local pushDelay = v6.PushDelay
	local pushForce = v6.PushForce

	if pushDelay or pushForce then
		task.delay(pushDelay or 0.2, function()
			v2.BodyMover.new(parent):Create("BodyVelocity", {
				Velocity = rootPart.CFrame.LookVector * pushForce,
				Duration = 0.15
			})
		end)
	end

	task.delay(pushDelay or 0.2, function()
		v2.Sound:Play(weaponData.SwingSound or "SwordSwing", rootPart)
	end)
	local aOEDelay = v6.AOEDelay
	local aOEDistanceFromCharacter = v6.AOEDistanceFromCharacter

	if (aOEDelay or aOEDistanceFromCharacter) and not v6.CustomAOEVFX then
		task.delay(aOEDelay or CombatUtil:GetDefaultAOEDelay(), function()
			local ray = v2.Ray
			local v7 = rootPart.CFrame * Vector3.new(0, 0, -(aOEDistanceFromCharacter or 7.5))
			local v8 = { workspace.Characters, enemies }
			local v9, position = ray(v7, createVector(0, -4, 0), v8)

			if v9 and not v6.CustomAOEEffect then
				Effect.new("Rubber.Transformed.Axe"):play({
					Character = parent,
					PreviousPosition = nil,
					Position = position
				})
			end
		end)
	end
end

function CombatUtil:CanCharacterMeleeAoe(instance)
	local humanoidRootPart = instance and instance:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart and humanoidRootPart:FindFirstChild("Buddha") then
		return 10
	end

	return 1
end

local thread = coroutine.create(function()
	local success, result = pcall(function()
		repeat
			task.wait()
		until v.RegisterHitEvent

		local v6 = tostring(game.Players.LocalPlayer.UserId):sub(2, 4) .. tostring(coroutine.running()):sub(11, 15)
		v.RegisterHitEvent:FireServer(v6)

		while true do
			local v7, v8 = coroutine.yield()
			v.RegisterHitEvent:FireServer(v7, v8, nil, v6)
		end
	end)

	if not success then
		warn(result)
	end
end)

if not isServer then
	local Global = require(game.ReplicatedStorage.Global)

	function Global.checkHits() end

	local Global2 = require(game.ReplicatedStorage.Global)

	function Global2.SendHitsToServer(...)
		local Global3 = require(game.ReplicatedStorage.Global)
		Global3.checkHits(...)
		coroutine.resume(thread, ...)
	end

	coroutine.resume(thread)
end

local v6 = {}

local function registerHit(p, p2, p3, p4, items)
	if isServer then
		local CombatService = require(game.ServerScriptService.Services.CombatService)
		CombatService:RegisterHit(p, p3)
	else
		if items then
			for _, item in pairs(items) do
				table.insert(v6, item)
			end

			table.insert(v6, { p2, p3 })
		end

		if p == true then
			if #v6 > 0 then
				if Flags.COMBAT_REMOTE_THREAD then
					coroutine.resume(thread, table.remove(v6, 1)[2], v6)
				else
					v.RegisterHitEvent:FireServer(table.remove(v6, 1)[2], v6)
				end
			end

			table.clear(v6)
		end

		if p ~= true then
			CombatUtil:ApplyDamageHighlight(p2, p, p4.Name, p4.WeaponType, p3)
		end
	end
end

function CombatUtil:GetAttackAngle(p, p2)
	return (math.acos((p.HumanoidRootPart.CFrame.LookVector:Dot((p2.HumanoidRootPart.Position - p.HumanoidRootPart.Position).unit))))
end

function CombatUtil.RunHitDetection(_, p, p2, p3)
	local parent = p.Parent
	local playerFromCharacter = Players:GetPlayerFromCharacter(parent)
	local humanoidRootPart = parent.HumanoidRootPart
	local upperTorso = parent.UpperTorso
	local rightFoot = parent.RightFoot
	local humanoid = parent.Humanoid
	local equippedWeapon = parent:FindFirstChild("EquippedWeapon") or CombatUtil:GetEquippedWeaponTool(parent)
	local weaponName = CombatUtil:GetWeaponName(equippedWeapon)
	local weaponData = CombatUtil:GetWeaponData(weaponName)
	local v7 = weaponData.WeaponType == "Melee"
	local v8 = equippedWeapon:IsDescendantOf(enemies) and not parent:FindFirstChild("Summoner")
	local summoner = parent:FindFirstChild("Summoner")
	local basic = weaponData.Moveset.Basic
	assert(basic, (`Couldn't find the 'Basic' moveset for {weaponName}`))

	if basic[p2].AOEDelay ~= nil then
		return
	end

	local v9 = {}

	if v7 then
		for _, child in parent:GetChildren() do
			if child:HasTag("WeaponHitbox") or child:HasTag("Blade") then
				table.insert(v9, child)
			end
		end
	end

	for _, descendant in equippedWeapon:GetDescendants() do
		if descendant:HasTag("WeaponHitbox") or descendant:HasTag("Blade") then
			table.insert(v9, descendant)
		end
	end

	if playerFromCharacter then
		local tagged = game.CollectionService:GetTagged("M1HitRegistry")
		table.insert(tagged, characters)
		table.insert(tagged, enemies)
		overlapParams.IncludeInstances = tagged
	else
		overlapParams.IncludeInstances = { characters, enemies }
	end

	local v10 = {}
	local rigOfHitParts = {}
	local v11 = {}
	local canCharacterMeleeAoe = CombatUtil:CanCharacterMeleeAoe(parent)

	local function tryToRegisterHit(partBoundsInBox)
		local v12 = nil
		local v13 = nil

		for _, item in partBoundsInBox do
			local rigOfHitPart = CombatUtil:GetRigOfHitPart(item)

			if rigOfHitPart then
				if v4[item.Name] then
					local summoner2 = rigOfHitPart:FindFirstChild("Summoner")
					local summoner3 = parent:FindFirstChild("Summoner")

					if (not summoner3 or rigOfHitPart ~= summoner3.Value.Character) and (not playerFromCharacter or not summoner2 or summoner2.Value ~= playerFromCharacter) then
						if weaponData.ValidateFrontHits then
							local _ = humanoidRootPart.CFrame.Position
							local _ = rigOfHitPart.PrimaryPart.CFrame.Position

							if CombatUtil:GetAttackAngle(parent, rigOfHitPart) > 1.3 then
								continue
							end
						end

						if (not v8 or not rigOfHitPart:IsDescendantOf(workspace.Enemies) or summoner3 or summoner2) and rigOfHitPart ~= parent and CombatUtil:IsVulnerable(rigOfHitPart) then
							if v12 then
								if canCharacterMeleeAoe > #rigOfHitParts and item.Parent ~= v12 and not table.find(
									rigOfHitParts,
									item.Parent
								) then
									table.insert(v10, { rigOfHitPart, item })
									table.insert(rigOfHitParts, rigOfHitPart)
								end
							else
								table.insert(rigOfHitParts, rigOfHitPart)
								v13 = item
								v12 = rigOfHitPart
							end
						end
					end
				end
			elseif item:HasTag("M1HitRegistry") and RunService:IsClient() then
				if not v11[item] then
					v11[item] = true
					v.RegisterHitEvent:FireServer(item)
				end
			elseif not object[item] then
				object[item] = true
				warn("No rig found for hit part:", item)
			end
		end

		if v12 then
			registerHit(parent, v12, v13, weaponData, v10)
		end

		return v12, v13
	end

	local part = nil
	local part2

	if Flags.NEW_COMBAT_SYSTEM_VISUALIZE_HITBOXES then
		part2 = Instance.new("Part")
		part2.Name = "BroadphaseHitboxPart"
		part2.BrickColor = BrickColor.new("Bright red")
		part2.Transparency = 0.8
		part2.CanCollide = false
		part2.CanTouch = false
		part2.CanQuery = false
		part2.Anchored = true
		part2.Parent = workspace
	else
		part2 = nil
	end

	local buddha2 = parent.HumanoidRootPart:FindFirstChild("Buddha2")
	local v12 = (buddha2 or parent.HumanoidRootPart:FindFirstChild("Buddha")) and true or false
	local v13 = humanoidRootPart.Size.Y * 0.5 + humanoid.HipHeight + 0.5
	local length = p3._Object.Length
	local total = 0
	local v14 = nil
	local v15 = {}

	while total < length and p3._Object.IsPlaying and not v14 do
		total += task.wait()

		if equippedWeapon and not equippedWeapon:IsDescendantOf(workspace) then
			break
		end

		if total < 0.13 then
			continue
		end

		local cFrame = humanoidRootPart.CFrame
		local position = cFrame.Position
		local v16 = cFrame * Vector3.new(upperTorso.Size.X, 0, 0)
		local v17 = math.clamp(total / length, 0, 1)
		local _ = v17 * v13
		local v18 = rightFoot.Position - Vector3.new(0, rightFoot.Size.Y * 0.5, 0)
		local lerped = v16:Lerp(Vector3.new(position.X, v18.Y, position.Z), v17)
		local cFrame2, size2 = GetBoundingBoxCustom(v9)
		local cornersOfPart = GetCornersOfPart({
			CFrame = cFrame2,
			Size = size2
		})
		local v22 = { v16, lerped, unpack(cornersOfPart) }

		for i = #v15, #v15 + 1 - 30, -1 do
			local v23 = v15[i]

			if not v23 then
				continue
			end

			for _, v24 in v23 do
				table.insert(v22, cFrame * v24)
			end
		end

		local v23 = {}

		for _, v24 in cornersOfPart do
			table.insert(v23, cFrame:ToObjectSpace(v24))
		end

		table.insert(v15, v23)
		local v24, v25 = GetBoundingBoxCustom(v22)
		local cFrame3 = v24 * (cFrame - position)
		local vector2 = v25 * (1 / math.clamp(humanoidRootPart:GetAttribute("CharacterSizeScaleNumber") or 1, 1, 999))
		local v27 = v8 and not summoner

		if v27 then
			vector2 *= 0.5
		end

		local v28 = humanoidRootPart.Size * (humanoidRootPart:GetAttribute("HrpSizeScale") or 1)

		if v12 then
			if v7 then
				vector2 = createVector(10.625, 7.5, 10) * v28.Y / 2
				local hitboxMagnitude = weaponData.HitboxMagnitude

				if hitboxMagnitude then
					vector2 *= 1 + (hitboxMagnitude - 2) * 0.1
				end

				if buddha2 then
					vector2 *= createVector(1, 1, 0.875)
				end

				cFrame3 = humanoidRootPart.CFrame * CFrame.new(0, -vector2.Y * 0.125, -vector2.Z / 3.25)
			else
				vector2 = Vector3.new(vector2.X, math.max(v28.Y * 4, vector2.Y), vector2.Z)
			end
		end

		if part2 then
			part2.CFrame = cFrame3
			part2.Size = vector2
		end

		local partBoundsInBox = workspace:GetPartBoundsInBox(cFrame3, vector2, overlapParams)

		if v12 and v7 == false then
			local size = createVector(10.625, 7.5, 10) * v28.Y / 2
			local hitboxMagnitude = weaponData.HitboxMagnitude

			if hitboxMagnitude then
				size *= 1 + (hitboxMagnitude - 2) * 0.1
			end

			if buddha2 then
				size *= createVector(1, 1, 0.875)
			end

			local cFrame4 = humanoidRootPart.CFrame * CFrame.new(0, -size.Y * 0.125, -size.Z / 3.25)

			if Flags.NEW_COMBAT_SYSTEM_VISUALIZE_HITBOXES and not part then
				part = Instance.new("Part")
				part.Name = "BroadphaseHitboxPart"
				part.BrickColor = BrickColor.new("Bright red")
				part.Transparency = 0.8
				part.CanCollide = false
				part.CanTouch = false
				part.CanQuery = false
				part.Anchored = true
				part.CFrame = cFrame4
				part.Size = size
				part.Parent = workspace
			end

			if part then
				part.CFrame = cFrame4
				part.Size = size
			end

			for _, v31 in pairs(workspace:GetPartBoundsInBox(cFrame4, size, overlapParams)) do
				table.insert(partBoundsInBox, v31)
			end
		end

		local v29
		v14, v29 = tryToRegisterHit(partBoundsInBox)

		if v14 then
			local playerFromCharacter2 = Players:GetPlayerFromCharacter(v14)

			if not (isServer and playerFromCharacter2) then
				break
			end

			local position2 = v29.Position

			for _, v30 in Players:GetPlayers() do
				local character = v30.Character

				if v30 ~= playerFromCharacter and character and (character:GetPivot().Position - position2).Magnitude <= 300 then
					v.ReceivedHit:FireClient(
						playerFromCharacter2,
						v14,
						character,
						weaponData.Name,
						weaponData.WeaponType,
						v29
					)
				end
			end

			break
		elseif not v12 or v7 == false then
			for _, v31 in v9 do
				local size = v31.Size
				local vector3

				if v27 then
					vector3 = size * 0.5
				else
					local hitboxMagnitude = weaponData.HitboxMagnitude

					if hitboxMagnitude then
						size += createVector(1, 1, 1) * hitboxMagnitude
					end

					if v7 then
						size += createVector(2, 2, 2)
					end

					if parent.HumanoidRootPart:FindFirstChild("Buddha2") then
						size *= 1.5
					elseif parent.HumanoidRootPart:FindFirstChild("Buddha") then
						size *= 1.2
					end

					vector3 = Vector3.new(math.max(3, size.X), math.max(3, size.Y), (math.max(3, size.Z)))
				end

				if Flags.NEW_COMBAT_SYSTEM_VISUALIZE_HITBOXES then
					local part3 = Instance.new("Part")
					part3.BrickColor = BrickColor.new("Bright red")
					part3.Transparency = 0.5
					part3.CanCollide = false
					part3.CanTouch = false
					part3.CanQuery = false
					part3.Anchored = true
					part3.CFrame = v31.CFrame
					part3.Size = vector3
					part3.Parent = workspace
					task.delay(0, function()
						part3:Destroy()
					end)
				end

				local v32
				v14, v32 = tryToRegisterHit(workspace:GetPartBoundsInBox(v31.CFrame, vector3, overlapParams))

				if not v14 then
					continue
				end

				local playerFromCharacter2 = Players:GetPlayerFromCharacter(v14)

				if isServer and playerFromCharacter2 then
					local position2 = v32.Position

					for _, v33 in Players:GetPlayers() do
						local character = v33.Character

						if v33 ~= playerFromCharacter and character and (character:GetPivot().Position - position2).Magnitude <= 300 then
							v.ReceivedHit:FireClient(
								playerFromCharacter2,
								v14,
								character,
								weaponData.Name,
								weaponData.WeaponType,
								v32
							)
						end
					end
				end

				break
			end
		end
	end

	if playerFromCharacter == game.Players.LocalPlayer then
		registerHit(true)
	end

	if Flags.NEW_COMBAT_SYSTEM_VISUALIZE_HITBOXES then
		task.delay(0.1, function()
			part2:Destroy()
		end)

		if part then
			task.delay(0.1, function()
				part:Destroy()
			end)
		end
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function toCamelCase(value)
	return string.lower(value:sub(1, 1)) .. value:sub(2, #value)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function toPascalCase(value)
	return string.upper(value:sub(1, 1)) .. value:sub(2, #value)
end

local function removeSpaces(value)
	return string.gsub(value, "%s", "")
end

function CombatUtil:GetWeaponData(value)
	for _, v7 in {
		value,
		CombatUtil:GetPureWeaponName(value),
		string.gsub(value, "%s", ""),
		string.lower(value),
		toCamelCase(value),
		toPascalCase(value)
	} do
		local v8 = WeaponData[v7]

		if v8 then
			return v8
		end
	end
end

function CombatUtil:GetWeaponName(instance)
	return instance:GetAttribute("WeaponName") or instance.Name
end

function CombatUtil.GetWeaponModel(_, instance, p)
	local pureWeaponName = CombatUtil:GetPureWeaponName(p)

	for _, child in instance:GetChildren() do
		if CombatUtil:GetPureWeaponName(child.Name) == pureWeaponName then
			return child
		end
	end
end

function CombatUtil:GetEquippedWeaponTool(instance)
	for _, tool in instance:GetChildren() do
		if tool:IsA("Tool") and (tool:HasTag("MeleeTool") or tool:HasTag("GunTool")) then
			return tool
		end
	end
end

function CombatUtil.CreateShootAngles(_, data)
	if data.NoSpread then
		return {
			{
				Angle = CFrame.Angles(0, 0, 0)
			}
		}
	end

	local v7 = {}
	local random = Random.new(data.Seed)
	local bulletSpreadCount = data.BulletSpreadCount or 7
	local bulletSpreadDegree = data.BulletSpreadDegree or 12

	local function addAngle()
		local v8 = math.rad((random:NextNumber(-bulletSpreadDegree / 2, bulletSpreadDegree / 2)))
		local v9 = math.rad((random:NextNumber(-bulletSpreadDegree / 2, bulletSpreadDegree / 2)))
		local v10 = math.rad((random:NextNumber(-bulletSpreadDegree / 2, bulletSpreadDegree / 2)))
		table.insert(v7, {
			Angle = CFrame.Angles(v8, v9, v10)
		})
	end

	if data.BulletSpreadCount == 1 then
		addAngle()
		return v7
	end

	table.insert(v7, {
		Angle = CFrame.Angles(0, 0, 0)
	})

	for _ = 1, bulletSpreadCount - 1 do
		addAngle()
	end

	return v7
end

function CombatUtil:GetToolOfWeaponType(instance, p)
	local playerFromCharacter = Players:GetPlayerFromCharacter(instance)

	if playerFromCharacter then
		for _, tool in playerFromCharacter.Backpack:GetChildren() do
			if tool:IsA("Tool") and tool:GetAttribute("WeaponType") == p then
				return tool
			end
		end
	end

	local tool = instance:FindFirstChildWhichIsA("Tool")

	if tool and tool:GetAttribute("WeaponType") == p then
		return tool
	end
end

function CombatUtil:PlayMeleeHitParticles(instance, p, p2)
	task.defer(function()
		local position = p and p.Position or instance:GetPivot().Position
		local weaponData = CombatUtil:GetWeaponData(p2)
		v3.play("Hit", position, weaponData)
	end)
end

function CombatUtil:ApplyDamageHighlight(parent, instance, p, p2, p3, _)
	if CombatUtil:HasRigEquipped(parent) then
		return
	end

	local playerFromCharacter = Players:GetPlayerFromCharacter(parent)
	local playerFromCharacter2 = Players:GetPlayerFromCharacter(instance)

	if not (playerFromCharacter or playerFromCharacter2) then
		return
	end

	if playerFromCharacter and playerFromCharacter2 then
		local Global = require(game.ReplicatedStorage.Global)

		if Global.InSafeZone then
			return
		end
	end

	if playerFromCharacter then
		if playerFromCharacter:GetAttribute("PvpDisabled") then
			return
		end

		if playerFromCharacter:GetAttribute("KenActive") then
			local kenDodgesLeft = playerFromCharacter:GetAttribute("KenDodgesLeft") or 0
			local lastKenDodge = playerFromCharacter:GetAttribute("LastKenDodge") or 0
			local v7 = tick() - lastKenDodge <= 0.4

			if kenDodgesLeft > 0 or v7 then
				return
			end
		end
	end

	local v7

	if instance and instance:IsDescendantOf(enemies) then
		v7 = instance
	end

	local v8

	if parent and parent:IsDescendantOf(enemies) then
		v8 = parent
	end

	local level = v7 and v7:GetAttribute("Level") or v8 and v8:GetAttribute("Level")
	local isBoss = v7 and v7:GetAttribute("IsBoss") or v8 and v8:GetAttribute("IsBoss")
	local data = playerFromCharacter2 and playerFromCharacter2:FindFirstChild("Data")
	local data2 = playerFromCharacter and playerFromCharacter:FindFirstChild("Data")
	local value = data and data.Level.Value or v7 and level or 1
	local value2 = data2 and data2.Level.Value or v8 and level
	local v9 = math.floor((value / 175) ^ 1.5) * 2
	local weaponName = nil

	if playerFromCharacter2 then
		local toolOfWeaponType = CombatUtil:GetToolOfWeaponType(instance, "Melee")

		if toolOfWeaponType then
			weaponName = toolOfWeaponType:GetAttribute("WeaponName")
		end
	elseif v7 then
		weaponName = v7:GetAttribute("WeaponName")
	end

	local toolOfWeaponType = CombatUtil:GetToolOfWeaponType(parent, "Demon Fruit")

	if p2 == "Melee" or p2 == "Sword" or p2 == "Gun" then
		if toolOfWeaponType and toolOfWeaponType.Name == "Rubber-Rubber" and p2 == "Melee" and data and weaponName == "Electro" then
			return
		end

		if toolOfWeaponType and toolOfWeaponType.Name == "Blade-Blade" and p2 == "Sword" and (v7 and not isBoss or not v7) then
			if v7 and level <= value2 - v9 or not v7 then
				return
			end
		elseif toolOfWeaponType and toolOfWeaponType.Name == "Rubber-Rubber" and p2 == "Gun" and (v7 and not isBoss or not v7) then
			if v7 and level <= value2 - v9 or not v7 then
				return
			end
		elseif toolOfWeaponType and toolOfWeaponType:FindFirstChild("Logia") and not instance:GetAttribute("BusoEnabled") then
			if v7 and level <= value2 - v9 or not v7 then
				return
			end
		elseif toolOfWeaponType and toolOfWeaponType:FindFirstChild("LogiaDough") and playerFromCharacter and playerFromCharacter:GetAttribute("KenActive") and not instance:GetAttribute("BusoEnabled") and (v7 and level <= value2 - v9 or not v7) then
			return
		end
	end

	if not playerFromCharacter and parent:GetAttribute("FruitType") == "Logia" and not instance:GetAttribute("BusoEnabled") then
		return
	end

	if p2 ~= "Gun" then
		CombatUtil:PlayMeleeHitParticles(parent, p3, p)
	end

	local highlight = parent:FindFirstChildOfClass("Highlight")

	if highlight then
		if highlight:GetAttribute("__FillColor") then
			local color = Color3.fromRGB(138, 0, 0)
			TweenService:Create(highlight, TweenInfo.new(0.2), {
				FillColor = color
			}):Play()
			task.delay(0.2, function()
				TweenService:Create(highlight, TweenInfo.new(0.2), {
					FillColor = highlight:GetAttribute("__FillColor")
				}):Play()
			end)
		end

		return true
	else
		local clone = WrapHighlight(script.DamageHighlight):Clone()
		clone.Adornee = HighlightAdornee(parent)
		clone.Parent = parent
		TweenService:Create(clone, TweenInfo.new(0.2), {
			FillTransparency = 0.5
		}):Play()
		task.delay(0.2, function()
			TweenService:Create(clone, TweenInfo.new(0.2), {
				FillTransparency = 1
			}):Play()
			task.wait(0.2)
			clone:Destroy()
		end)
		return true
	end
end

function CombatUtil.IsGunReloading(_, instance)
	if isServer then
		return not instance.Enabled or instance:GetAttribute("IsReloading") or instance:GetAttribute("UnequipAutoReloading")
	end

	return not instance.Enabled or instance:GetAttribute("IsReloading_Client") or instance:GetAttribute("UnequipAutoReloading")
end

local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Exclude
raycastParams.FilterDescendantsInstances = { workspace._WorldOrigin, workspace.Characters, enemies }
local raycastParams2 = RaycastParams.new()
raycastParams2.FilterType = Enum.RaycastFilterType.Exclude

function CombatUtil.GetTargetPosition(_, p, position, value, p2)
	debug.profilebegin("GetTargetPosition")
	local v7 = value or 1e999
	local v8 = position - p

	if v7 < v8.Magnitude then
		position = p + v8.Unit * v7
	end

	if p2 then
		raycastParams2.FilterDescendantsInstances = { workspace._WorldOrigin, p2 }
	end

	local raycastResult = workspace:Raycast(p, position - p, p2 and raycastParams2 or raycastParams)

	if raycastResult then
		position = raycastResult.Position
	end

	debug.profileend()
	return position
end

return CombatUtil