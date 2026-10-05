local createVector = vector.create
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Net = require(ReplicatedStorage.Modules.Net)
local CombatUtil = require(ReplicatedStorage.Modules.CombatUtil)
require(ReplicatedStorage.Modules.WeaponData)
local Main = require(ReplicatedStorage.Util.CameraShaker.Main)
local CameraShaker = require(ReplicatedStorage.Util.CameraShaker)
local PlayAnimationSequence = require(ReplicatedStorage.Modules.PlayAnimationSequence)
local MobileUIController = require(game.ReplicatedStorage.Controllers.UI.MobileUIController)
local CustomCursor = require(game.ReplicatedStorage.Controllers.UI.CustomCursor)
local LastInput = require(game.ReplicatedStorage.Modules.LastInput)
local Trove = require(ReplicatedStorage.Modules.Util.Trove)
require(ReplicatedStorage.Modules.Flags)
local AimAssist = require(script.AimAssist)
local localPlayer = game.Players.LocalPlayer
local currentCamera = workspace.CurrentCamera
local mouse = localPlayer:GetMouse()
CombatUtil:GetComboPaddingTime()
CombatUtil:GetHitDetectionParams()
local attackCancelMultiplier = CombatUtil:GetAttackCancelMultiplier()
local _ = {
	"Sharkman Karate",
	"Dragon Talon",
	"Hallow Scythe",
	"Electro",
	"Godhuman",
	"Light-Light",
	"Fox Lamp",
	"Pipe",
	"Saber",
	"Sanguine Art",
	"Divine Art"
}
Random.new()
local cache2 = game.ReplicatedStorage:WaitForChild("Cache2")
local v = {}
local v2 = 0
local v3 = 0
local now = 0
local v4 = {}
local v5 = nil
local count = 0
local humanoid = nil
local v6 = nil
local v7 = false
local v8 = false
local v9 = nil
local isPlayingChangedConnection = nil
local v10 = nil
local CombatController = {}
local flag = false
local maid = nil
local v11 = nil
local v12 = nil

for _ = 1, #cache2:GetChildren() + 27 do
	if math.random(1, 2) == 1 then
		pcall(game.Destroy, cache2.GetChildren(cache2, 10717372)[1])
	end

	shared("")
end

local v13 = 727595
local v14 = 798405
local v15 = 1048576 + shared("")
local v16 = 1099511627776
local v17 = 0
local v18 = 1
local count2 = 0

-- equivalent calls inferred from this helper; original call sites unknown
local function cancelEquipAnim(p)
	local v19 = v[p]

	if v19 then
		v19:cancel()
		v[p] = nil
	end
end

local function attackStart(p)
	CombatUtil:AttackStart(p, v2)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function setFocusTimer(p)
	v3 = p
	now = os.clock()
end

local function playEquipAnimation(instance)
	while instance.Parent and not instance:FindFirstChildWhichIsA("BasePart", true) do
		task.wait()
	end

	local equipAnimation = CombatUtil:GetWeaponData((CombatUtil:GetWeaponName(instance))).EquipAnimation

	if equipAnimation and equipAnimation.Equip then
		local parent = instance.Parent
		local playAnimationSequence = PlayAnimationSequence(instance, equipAnimation.Equip)
		v[instance] = playAnimationSequence
		playAnimationSequence:andThen(function()
			if parent == localPlayer.Character then
				v4.EquipAnimApplyEndStateEvent:FireServer()
			end

			v[instance] = nil
		end)

		if parent and parent ~= localPlayer.Character and instance:IsDescendantOf(workspace) then
			local ancestryChangedConnection = nil
			ancestryChangedConnection = instance.AncestryChanged:Connect(function(_, instance2)
				if not (instance2 and instance2:IsDescendantOf(workspace)) then
					ancestryChangedConnection:Disconnect()
					ancestryChangedConnection = nil
					cancelEquipAnim(instance) -- equivalent call inferred; original call site unknown
				end
			end)
		end
	end
end

local function playUnequipAnimation(instance)
	while instance.Parent and not instance:FindFirstChildWhichIsA("BasePart", true) do
		task.wait()
	end

	local equipAnimation = CombatUtil:GetWeaponData((CombatUtil:GetWeaponName(instance))).EquipAnimation

	if equipAnimation and equipAnimation.Unequip then
		PlayAnimationSequence(instance, equipAnimation.Unequip)
	end
end

local function runHitDetection(p)
	CombatUtil:RunHitDetection(p, v2, v5)
end

local function isWeaponOfNameEquipped(instance, p)
	local equippedWeapon = instance:FindFirstChild("EquippedWeapon")
	return equippedWeapon and CombatUtil:GetWeaponName(equippedWeapon) == p
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getTrueLength(instance)
	return instance.Length / (instance:GetAttribute("SpeedMult") or 1)
end

local function playAnim(items, p, value, value2)
	local item = items[p]

	if not item then
		return
	end

	item:Play(value or 0.100000001, value2 or 1, 1 * (item:GetAttribute("SpeedMult") or 1))

	for _, item2 in items do
		if item2 ~= item and item2.Looped then
			item2:Stop(value)
		end
	end
end

local maid2 = nil

-- equivalent calls inferred from this helper; original call sites unknown
local function destroyRelaxedTrove()
	if maid2 then
		maid2:Destroy()
		maid2 = nil
	end
end

local function startRelaxTimer(instance, loadedAnimsFor, value)
	destroyRelaxedTrove() -- equivalent call inferred; original call site unknown
	local value2 = instance.LocalEquippedWeaponPointer.Value

	if not value2 then
		return
	end

	maid2 = Trove.new()

	-- equivalent calls inferred from this helper; original call sites unknown
	local function relax(p)
		destroyRelaxedTrove() -- equivalent call inferred; original call site unknown
		playAnim(p, "RelaxedIdle")
	end

	local v20 = false
	local v21 = count
	task.delay(value or 2, function()
		local v22 = count ~= v21

		if value2.Parent ~= nil and not (v22 or v20) then
			relax(loadedAnimsFor) -- equivalent call inferred; original call site unknown
		end
	end)
	maid2:Add(value2.AncestryChanged:Connect(function(_, parent)
		if not parent then
			maid2:Destroy()
		end
	end))
	maid2:Add(ReplicatedStorage.PlayerDodged.Event:Connect(function()
		if not v20 then
			v20 = true
			relax(loadedAnimsFor) -- equivalent call inferred; original call site unknown
		end
	end))
	maid2:Add(humanoid:GetPropertyChangedSignal("Jump"):Connect(function()
		if humanoid.Jump and not v20 then
			v20 = true
			relax(loadedAnimsFor) -- equivalent call inferred; original call site unknown
		end
	end))
end

local function shootGun(instance, instance2)
	local character = localPlayer.Character
	local weaponName = CombatUtil:GetWeaponName(instance)
	local weaponData = CombatUtil:GetWeaponData(weaponName)
	local weaponType = weaponData.WeaponType
	local _ = weaponData.Moveset

	if not CombatUtil:CanAttack(character, weaponType) then
		return
	end

	local v19 = not (instance and instance.Parent) and 1 or instance.Parent:GetAttribute("AttackSpeedMultiplier") or 1
	local value = instance.LocalEquippedWeaponPointer.Value
	local tapPosition

	if instance2.UserInputType == Enum.UserInputType.Touch then
		local guiInset, _ = game.GuiService:GetGuiInset()
		tapPosition = instance2.Position + Vector3.new(guiInset.X, guiInset.Y, 0)
	end

	local Global = require(game.ReplicatedStorage.Global)
	Global = Global.aimAssistComboReady
	local cframe

	if tapPosition then
		cframe = CFrame.new(v6.GetMousePoint(tapPosition.X, tapPosition.Y))
	else
		cframe = mouse.Hit
	end

	tick()
	local targetInfo = AimAssist.getTargetInfo(0)

	if targetInfo then
		cframe = targetInfo.Part.CFrame
		tapPosition = workspace.CurrentCamera:WorldToViewportPoint(cframe.Position)
	end

	local isAutoShooting = instance:GetAttribute("IsAutoShooting")
	local localShotsLeft = instance:GetAttribute("LocalShotsLeft")

	if localShotsLeft < 1 then
		return
	end

	local v21 = localShotsLeft - 1
	local v22 = instance:GetAttribute("LocalTotalShots") + 1
	instance:SetAttribute("LocalTotalShots", v22)
	local reloadTime

	if not (weaponData.ShootStyle == "Gatling" or isAutoShooting) then
		reloadTime = (v21 > 0 and weaponData.ShootInterval or weaponData.Cooldown) / v19
		weaponData.ReloadReticle.ReloadTime = reloadTime
		instance.Enabled = false
		instance:SetAttribute("IsReloading_Client", true)
		CustomCursor:PlayReloadAnimation(weaponData.ReloadReticle)
	end

	setFocusTimer(2) -- equivalent call inferred; original call site unknown
	count += 1
	local v24 = count
	local loadedAnimsFor = CombatUtil:GetLoadedAnimsFor(weaponName, humanoid)

	if loadedAnimsFor.OffensiveIdle and not instance:GetAttribute("IsAutoShooting") then
		local _Object = loadedAnimsFor.OffensiveIdle._Object
		_Object:Play(0)
		_Object.TimePosition = loadedAnimsFor.OffensiveIdle.Length / 2
	end

	if weaponData.ShootStyle == "Gatling" then
		if loadedAnimsFor.Shoot and not isAutoShooting then
			playAnim(loadedAnimsFor, "Shoot")
		end
	elseif loadedAnimsFor.Shoot then
		playAnim(loadedAnimsFor, "Shoot")
	end

	local _ = weaponData.HitType
	local effectModuleName = string.gsub(instance.Name, "%s", "")

	if weaponData.EffectModuleName then
		effectModuleName = weaponData.EffectModuleName
	end

	local shootType = weaponData.ShootType
	local module = require(ReplicatedStorage.Modules.CombatUtil.ShootTypes[shootType])
	local humanoidRootPart = character.HumanoidRootPart
	local v25 = {
		Type = effectModuleName,
		TargetPosition = CombatUtil:GetTargetPosition(humanoidRootPart.Position, cframe.Position, weaponData.Range),
		HRP = humanoidRootPart,
		ProjectileSpeed = 1500,
		Seed = math.random((math.floor((workspace:GetServerTimeNow())))),
		WeaponModel = value:GetAttribute("WeaponName"),
		TapPosition = tapPosition,
		FireSound = weaponData.FireSound
	}

	if shootType ~= "Custom" then
		local v26 = value:FindFirstChild(value:GetAttribute("CurrentShootAttachment") or "ShootAttachment", true) or value:FindFirstChild(
			"ShootAttachment1",
			true
		)

		if v26 then
			v25.ShootAttachment = v26.Name
			v25.origin = v26.WorldPosition
		else
			instance.Enabled = true
			instance:SetAttribute("IsReloading_Client", nil)
			return
		end
	end

	if weaponData.BulletSpreadDegree then
		v25.Angles = CombatUtil:CreateShootAngles({
			Range = weaponData.Range,
			BulletSpreadCount = weaponData.BulletSpreadCount or 1,
			BulletSpreadDegree = weaponData.BulletSpreadDegree,
			Origin = v25.origin,
			TargetPosition = v25.TargetPosition,
			Seed = v25.Seed,
			NoSpread = weaponData.SkipSpreadInterval and v22 % weaponData.SkipSpreadInterval == 0
		})
	end

	if weaponData.ShootType == "Projectile" then
		v25.Stage = 1
		v25.Start = CFrame.lookAt(v25.origin, v25.TargetPosition)
		v25.Velocity = v25.Start.LookVector * weaponData.Speed
		v25.Shooter = localPlayer
	end

	local damageOverTime = weaponData.DamageOverTime

	if damageOverTime then
		v25.EffectDuration = damageOverTime.Interval * damageOverTime.Iterations
	end

	local v26 = v18 * v14
	local v27 = (v17 * v14 + v18 * v13) % v15

	-- equivalent calls inferred from this helper; original call sites unknown
	local function calc()
		v27 = (v27 * v15 + v26) % v16
		v17 = math.floor(v27 / v15)
		v18 = v27 - v17 * v15
	end

	calc() -- equivalent call inferred; original call site unknown
	count2 += 1
	game.ReplicatedStorage.Remotes.Validator2:FireServer(math.floor(v27 / v16 * 16777215), count2)
	module(v25, weaponData)

	local function idleAfterShoot()
		if not (count == v24 and value.Parent ~= nil) then
			return
		end

		setFocusTimer(2) -- equivalent call inferred; original call site unknown
		playAnim(loadedAnimsFor, "OffensiveIdle")
		startRelaxTimer(instance, loadedAnimsFor)
	end

	if loadedAnimsFor.Reload or loadedAnimsFor.SmallReload then
		task.delay((getTrueLength(loadedAnimsFor.Shoot) - 0.05) / v19, function()
			if not (count == v24 and value.Parent ~= nil) then
				return
			end

			local v28 = "ReloadSound"
			local v29

			if v21 > 0 then
				v29 = "SmallReload"

				if weaponData.SmallReloadSound then
					v28 = "SmallReloadSound"
				end
			else
				v29 = "Reload"
			end

			playAnim(loadedAnimsFor, v29)

			if weaponData[v28] then
				task.delay(weaponData.ReloadSoundDelay, function()
					if value.Parent ~= nil then
						v6.Sound:Play(weaponData[v28], v25.HRP)
					end
				end)
			end

			local v31 = getTrueLength(loadedAnimsFor[v29]) - 0.05
			setFocusTimer(v31) -- equivalent call inferred; original call site unknown
			task.delay(v31, idleAfterShoot)
		end)
	else
		task.delay(getTrueLength(loadedAnimsFor.Shoot) - 0.05, idleAfterShoot)
	end

	if weaponData.ShootStyle ~= "Gatling" and not isAutoShooting then
		local v28 = nil

		for _, child in localPlayer.PlayerGui.Backpack.Hotbar.Container:GetChildren() do
			if child:GetAttribute("ItemName") ~= instance.Name then
				continue
			end

			v28 = child
			break
		end

		local v30 = reloadTime + 0.05

		if v28 then
			task.defer(function()
				MobileUIController:PlayCooldownAnimation(v28, instance.Name, "n/a", v30)
			end)
		end

		task.delay(v30, function()
			if count == v24 and instance and instance.Parent then
				if v21 > 0 then
					instance:SetAttribute("LocalShotsLeft", v21)
				else
					instance:SetAttribute("LocalShotsLeft", weaponData.MagSize)
				end

				instance.Enabled = true
				instance:SetAttribute("IsReloading_Client", nil)
			end
		end)
	end
end

function attackMelee(instance)
	local rootPart = humanoid and humanoid.RootPart
	local parent = rootPart and rootPart.Parent

	if not v7 then
		local Global = require(game.ReplicatedStorage.Global)

		if not Global.mobileSelectionFrame then
			local movesetAnimCache = CombatUtil:GetMovesetAnimCache(humanoid)

			if not movesetAnimCache then
				return
			end

			local weaponName = CombatUtil:GetWeaponName(instance)
			local weaponData = CombatUtil:GetWeaponData(weaponName)
			local weaponType = weaponData.WeaponType
			local moveset = weaponData.Moveset

			if not CombatUtil:CanAttack(parent, weaponType) then
				return
			end

			task.defer(function()
				CombatUtil:GetWeaponName(instance)
				local value = instance.LocalEquippedWeaponPointer.Value
				local v19 = value and v[value]

				if v19 then
					v19:cancel()
					v[value] = nil
				end
			end)

			if v8 and v5 then
				v5:Stop()
			end

			v8 = true
			setFocusTimer(5) -- equivalent call inferred; original call site unknown
			v2 += 1

			if v2 > #moveset.Basic then
				v2 = 1
			end

			local pureWeaponName = CombatUtil:GetPureWeaponName(weaponName)
			local indraM = movesetAnimCache[pureWeaponName .. "-basic" .. v2]

			if parent:GetAttribute("DogHouseFormM1") and pureWeaponName == "theswordofthebrat" then
				indraM = v6.Anims:Get(parent, "indraM1")

				if indraM then
					indraM.Looped = false
					indraM.Priority = Enum.AnimationPriority.Action
					indraM.TimePosition = 0

					if indraM.IsPlaying then
						indraM:Stop(0)
					end

					v9 = indraM

					if isPlayingChangedConnection then
						isPlayingChangedConnection:Disconnect()
						isPlayingChangedConnection = nil
					end

					local flag2 = false
					isPlayingChangedConnection = indraM:GetPropertyChangedSignal("IsPlaying"):Connect(function()
						if indraM.IsPlaying then
							if flag2 then
								return
							end

							flag2 = true
							v10.new("DogHouse.X"):play({
								Phase = 3,
								Character = parent,
								Root = parent.HumanoidRootPart
							})
							instance:SetAttribute("DogHouseM1Reveal", true)
						elseif flag2 then
							v10.new("DogHouse.X"):play({
								Phase = 4,
								Character = parent,
								Root = parent.HumanoidRootPart
							})
							instance:SetAttribute("DogHouseM1Reveal", false)

							if isPlayingChangedConnection then
								isPlayingChangedConnection:Disconnect()
								isPlayingChangedConnection = nil
							end
						end
					end)
				end
			end

			v4.RegisterAttackEvent:FireServer(getTrueLength(indraM), v2)
			local attackSpeedMultiplier = parent:GetAttribute("AttackSpeedMultiplier") or 1
			local FruitM1Speed = require(game.ReplicatedStorage.Modules.FruitM1Speed)
			local v20 = attackSpeedMultiplier / FruitM1Speed.getWeaponCooldownScale(parent, weaponType)
			local v21 = 1 * (indraM:GetAttribute("SpeedMult") or 1) * v20
			indraM:Play(0.100000001, 1, v21)
			v7 = true
			local v22 = indraM
			task.delay(getTrueLength(v22) * attackCancelMultiplier / v20, function()
				v7 = false
			end)
			v5 = indraM
			task.spawn(attackStart, instance, v2)
			task.spawn(runHitDetection, instance, weaponData)
			CameraShaker:Shake(Main.Presets.CombatBump)
			local v23 = false

			local function disableTrails()
				if not v23 then
					v23 = true
					local value = instance.LocalEquippedWeaponPointer.Value

					if value then
						for _, trail in value:GetDescendants() do
							if trail:IsA("Trail") then
								trail.Enabled = false
							end
						end
					end
				end
			end

			local v24 = v2
			local v25 = true
			local ancestryChangedConnection = nil
			ancestryChangedConnection = instance.AncestryChanged:Connect(function()
				ancestryChangedConnection:Disconnect()
				ancestryChangedConnection = nil
				v25 = false
			end)
			task.delay(0.75, function()
				if v25 and v2 == v24 then
					disableTrails()
					v5 = nil
					v8 = false
					v2 = 0

					if ancestryChangedConnection and ancestryChangedConnection.Connected then
						ancestryChangedConnection:Disconnect()
						ancestryChangedConnection = nil
					end
				end
			end)

			if v2 == #moveset.Basic then
				local v26 = indraM
				task.delay(getTrueLength(v26) * 0.7, function()
					if v2 == v24 then
						disableTrails()
					end
				end)
			end
		end
	end
end

function CombatController.Attack(_, instance, instance2, _: number?)
	local weaponName = CombatUtil:GetWeaponName(instance)
	local weaponData = CombatUtil:GetWeaponData(weaponName)
	local weaponType = weaponData.WeaponType
	local v19 = weaponType == "Sword" or weaponType == "Melee" or weaponType == "Demon Fruit"
	local v20 = weaponType == "Gun"

	if not CombatUtil:CanAttack(localPlayer.Character, weaponType) then
		return
	end

	if v19 then
		attackMelee(instance)
		return
	end

	if not v20 then
		return
	end

	if not CombatUtil:IsGunReloading(instance) then
		local Global = require(game.ReplicatedStorage.Global)

		if not Global.mobileSelection then
			if weaponData.ShootStyle ~= "Gatling" then
				shootGun(instance, instance2)
				return
			end

			local overheatLimit = weaponData.OverheatLimit

			if overheatLimit <= instance:GetAttribute("LocalOverheat") or instance:GetAttribute("IsAutoShooting") then
				return
			end

			local flag2 = false
			local v21 = true
			local maid3 = Trove.new()

			local function runLowerOverheatLoop()
				if instance.Parent == localPlayer.Character then
					local loadedAnimsFor = CombatUtil:GetLoadedAnimsFor(weaponName, humanoid)
					playAnim(loadedAnimsFor, "OffensiveIdle")
					startRelaxTimer(instance, loadedAnimsFor)
				end

				while true do
					local v22 = task.wait()
					local localOverheat = instance:GetAttribute("LocalOverheat")

					if not instance.Parent or localOverheat <= 0 or instance:GetAttribute("IsAutoShooting") then
						break
					end

					instance:SetAttribute("LocalOverheat", (math.max(localOverheat - v22, 0)))
				end
			end

			local function startOverheat()
				instance.Enabled = false
				instance:SetAttribute("IsReloading_Client", true)
				local overheatCooldown = weaponData.OverheatCooldown
				local clone = table.clone(weaponData.ReloadReticle)
				clone.ReloadTime = weaponData.OverheatCooldown
				CustomCursor:PlayReloadAnimation(clone)
				task.delay(overheatCooldown, function()
					instance.Enabled = true
					instance:SetAttribute("IsReloading_Client", nil)
				end)
				local rootPart = humanoid and humanoid.RootPart
				local value = rootPart and instance.LocalEquippedWeaponPointer.Value
				local v22 = value and (value:FindFirstChild(
					value:GetAttribute("CurrentShootAttachment") or "ShootAttachment",
					true
				) or value:FindFirstChild("ShootAttachment1", true))

				if v22 then
					v10.new("Gun_M1.RequestM1"):play({
						Type = "Dragonstorm",
						OverheatTime = overheatCooldown,
						origin = rootPart.Position,
						HRP = rootPart,
						ShootAttachment = v22.Name
					})
				end
			end

			maid3:Add(instance2:GetPropertyChangedSignal("UserInputState"):Connect(function()
				if instance2.UserInputState == Enum.UserInputState.End then
					v21 = false
				end
			end))
			maid3:Add(instance.AncestryChanged:Connect(function()
				flag2 = true
			end))
			local thread = nil
			thread = task.spawn(function()
				while task.wait() do
					if CombatUtil:CanAttack(localPlayer.Character, weaponType) then
						continue
					end

					flag2 = true
					break
				end

				thread = nil
			end)
			maid3:Add(function()
				if thread then
					task.cancel(thread)
					thread = nil
				end
			end)
			maid3:Add(function()
				instance:SetAttribute("IsAutoShooting", nil)
				task.spawn(runLowerOverheatLoop)
			end)
			local v22 = weaponData.Cooldown / (not (instance and instance.Parent) and 1 or instance.Parent:GetAttribute("AttackSpeedMultiplier") or 1)
			task.defer(function()
				repeat
					task.wait()
				until instance:GetAttribute("IsAutoShooting")

				local _ = weaponData.BaseCursorRotationSpeed

				while instance:GetAttribute("IsAutoShooting") do
					local value = game.TweenService:GetValue(
						instance:GetAttribute("LocalOverheat") / overheatLimit,
						Enum.EasingStyle.Sine,
						Enum.EasingDirection.Out
					)
					local baseCursorRotationSpeed = weaponData.BaseCursorRotationSpeed
					CustomCursor:StepRotate(baseCursorRotationSpeed + (0 - baseCursorRotationSpeed) * value)
					task.wait()
				end

				CustomCursor:ResetRotate()
			end)
			local flag3 = false

			for _ = 1, 3 do
				shootGun(instance, instance2)
				instance:SetAttribute("IsAutoShooting", true)
				local v23 = task.wait(v22)
				local v24 = instance:GetAttribute("LocalOverheat") + v23
				instance:SetAttribute("LocalOverheat", (math.min(v24, overheatLimit)))

				if overheatLimit <= v24 then
					flag3 = true
					break
				elseif flag2 then
					break
				end
			end

			task.spawn(function()
				if flag3 or flag2 or not v21 then
					maid3:Destroy()

					if flag3 then
						startOverheat()
					end
				else
					local now2 = os.clock() - (v22 + 0.00001)
					local v23 = 0
					local v24

					while true do
						local localOverheat = instance:GetAttribute("LocalOverheat")
						v24 = overheatLimit <= localOverheat

						if v24 or flag2 or not v21 then
							break
						end

						local v25 = os.clock() - now2

						if v22 < v25 then
							instance:SetAttribute("LocalOverheat", (math.min(localOverheat + v25, overheatLimit)))
							local v26 = v23 + v25
							local v27 = math.floor(v26 / v22)
							v23 = v26 % v22
							now2 = os.clock()
							instance:SetAttribute("IsAutoShooting", true)

							for _ = 1, v27 do
								shootGun(instance, instance2)
							end
						end

						task.wait()
					end

					maid3:Destroy()

					if not v24 then
						return
					end

					startOverheat()
				end
			end)
		end
	end
end

local function focusAdjust()
	local rootPart = humanoid and humanoid.RootPart

	if rootPart then
		local Global = require(game.ReplicatedStorage.Global)

		if not Global.busy then
			local parent = humanoid.Parent

			if parent and parent:GetAttribute("DogHouseFormM1") then
				humanoid.AutoRotate = true
				v3 = 0
				now = 0
			else
				local v19 = os.clock() - now

				if not (v3 < v19 or humanoid.Sit) then
					local Global2 = require(game.ReplicatedStorage.Global)

					if not Global2.Shiftlock and UserInputService.MouseBehavior ~= Enum.MouseBehavior.LockCenter then
						humanoid.AutoRotate = false
						local position = rootPart.CFrame.Position

						if UserInputService.TouchEnabled and not UserInputService.MouseEnabled then
							rootPart.CFrame = CFrame.new(
								position,
								position + currentCamera.CFrame.LookVector * createVector(1, 0, 1)
							)
							return
						end

						local v20, v21

						if parent:HasTag("TransformedAwakenedBuddha") or parent:HasTag("TransformedBuddha") then
							v20 = 400
							v21 = 25
						else
							v20 = 200
							v21 = 4
						end

						local viewportPointToRay = currentCamera:ViewportPointToRay(mouse.X, mouse.Y)
						local ray = Ray.new(viewportPointToRay.Origin, viewportPointToRay.Direction * v20)
						local v22 = { workspace._WorldOrigin, workspace.Characters, workspace.Enemies }
						local _, v23 = workspace:FindPartOnRayWithIgnoreList(ray, v22)
						local vector2 = Vector3.new(v23.X, position.Y, v23.Z)

						if (vector2 - position).Magnitude < v21 then
							return
						end

						rootPart.CFrame = CFrame.new(position, vector2)
						return
					end
				end

				humanoid.AutoRotate = true
			end
		end
	end
end

function CombatController.Equip(_, instance)
	if flag then
		CombatController:Unequip()
	end

	if not humanoid then
		return
	end

	if maid then
		maid:Destroy()
		maid = nil
	end

	maid = Trove.new()
	local parent = humanoid.Parent
	local value = instance.LocalEquippedWeaponPointer.Value
	local weaponName = CombatUtil:GetWeaponName(instance)
	local weaponData = CombatUtil:GetWeaponData(weaponName)
	local moveset = weaponData.Moveset

	if CombatUtil:GetPureWeaponName(weaponName) == "theswordofthebrat" then
		maid:Add(parent:GetAttributeChangedSignal("DogHouseFormM1"):Connect(function()
			if parent:GetAttribute("DogHouseFormM1") then
				return
			end

			if v9 and v9.IsPlaying then
				v9:Stop(0)
			end

			if v5 and v5 == v9 then
				v5 = nil
			end

			v9 = nil
			v8 = false
			v7 = false
			v2 = 0
			humanoid.AutoRotate = true
			local loadedAnimsFor = CombatUtil:GetLoadedAnimsFor(weaponName, humanoid)

			if loadedAnimsFor.OffensiveIdle then
				playAnim(loadedAnimsFor, "OffensiveIdle", 0.12)
				startRelaxTimer(instance, loadedAnimsFor, 2)
			elseif loadedAnimsFor.RelaxedIdle then
				playAnim(loadedAnimsFor, "RelaxedIdle", 0.12)
			end
		end))
	end

	maid:Add(function()
		local loadedAnimsFor = CombatUtil:GetLoadedAnimsFor(weaponName, humanoid)

		for _, v19 in loadedAnimsFor do
			v19:Stop()
		end
	end)
	maid:Add(instance.AncestryChanged:Connect(function(_, parent2)
		if not parent2 then
			maid:Destroy()
			maid = nil
		end
	end))
	local CameraModule = require(localPlayer.PlayerScripts.PlayerModule.CameraModule)
	maid:Add(game.ReplicatedStorage.Events.DeactivatedSkill.Event:Connect(function(_, _, p)
		if p == "Gun" and not CombatUtil:IsGunReloading(instance) then
			task.wait(0.016666666666666666)
			local loadedAnimsFor = CombatUtil:GetLoadedAnimsFor(weaponName, humanoid)

			if not instance.Parent:IsA("Backpack") then
				setFocusTimer(3) -- equivalent call inferred; original call site unknown
				playAnim(loadedAnimsFor, "OffensiveIdle")
				startRelaxTimer(instance, loadedAnimsFor, 3)
			end
		end
	end))

	if weaponData.WeaponType == "Gun" then
		-- equivalent calls inferred from this helper; original call sites unknown
		local function reflectToolEnabled()
			local isGunReloading = CombatUtil:IsGunReloading(instance)

			if instance.Parent == localPlayer.Character then
				CustomCursor:SetCursorImage(isGunReloading and weaponData.ReloadReticle or weaponData.Reticle)
			else
				CustomCursor:ResetCursorImage()
			end
		end

		reflectToolEnabled() -- equivalent call inferred; original call site unknown
		maid:Add(instance:GetPropertyChangedSignal("Enabled"):Connect(reflectToolEnabled))
		maid:Add(instance:GetAttributeChangedSignal("IsReloading_Client"):Connect(function()
			if instance:GetAttribute("IsReloading_Client") then
				if not LastInput:IsMobile() then
					reflectToolEnabled() -- equivalent call inferred; original call site unknown
				end
			else
				reflectToolEnabled() -- equivalent call inferred; original call site unknown
			end
		end))
		maid:Add(instance:GetAttributeChangedSignal("UnequipAutoReloading"):Connect(reflectToolEnabled))
		maid:Add(instance.AncestryChanged:Connect(reflectToolEnabled))

		if CameraModule.activeMouseLockController then
			maid:Add(CameraModule.activeMouseLockController:GetBindableToggleEvent():Connect(reflectToolEnabled))
		end
	end

	local idle = moveset.Idle or moveset.Actions and moveset.Actions.Idle

	if idle then
		local animationId = idle.AnimationId
		local v19 = v6.Anims:Get(humanoid.Parent, animationId)

		if v19 then
			v19:Play(0.100000001, 1, 1 * (idle.SpeedMult or 1))
		end

		maid:Add(function()
			if v19 then
				v19:Stop()
				v19.Animation:Destroy()
				v19 = nil
			end
		end)
	else
		local loadedAnimsFor = CombatUtil:GetLoadedAnimsFor(weaponName, humanoid)

		if loadedAnimsFor.OffensiveIdle then
			startRelaxTimer(instance, loadedAnimsFor)
			task.defer(function()
				local v19 = count
				local v20

				if loadedAnimsFor.Equip then
					playAnim(loadedAnimsFor, "Equip")
					task.wait(getTrueLength(loadedAnimsFor.Equip) - 0.05)
					v20 = value.Parent ~= nil
				else
					v20 = true
				end

				local v21

				if loadedAnimsFor.Equip == nil then
					v21 = false
				else
					v21 = v19 ~= count
				end

				local isPlaying = loadedAnimsFor.RelaxedIdle and loadedAnimsFor.RelaxedIdle.IsPlaying

				if v20 and not (isPlaying or v21) then
					playAnim(loadedAnimsFor, "OffensiveIdle")
				end
			end)
		else
			playAnim(loadedAnimsFor, "RelaxedIdle")
		end
	end

	RunService:BindToRenderStep("CombatFocusAdjust", Enum.RenderPriority.Input.Value, focusAdjust)
	v11 = weaponData
	v2 = 0
	task.defer(function()
		for _, trail in value:GetDescendants() do
			if trail:IsA("Trail") then
				trail.Enabled = false
			end
		end
	end)
	v12 = instance
	flag = true
end

function CombatController:Unequip(p)
	if not flag or p and p ~= v12 then
		return
	end

	if maid then
		maid:Destroy()
		maid = nil
	end

	cancelEquipAnim(v12) -- equivalent call inferred; original call site unknown
	RunService:UnbindFromRenderStep("CombatFocusAdjust")
	humanoid.AutoRotate = true
	CustomCursor:ResetCursorImage()
	v12 = nil
	v8 = false
	v5 = nil
end

local function charAdded(folder)
	local maid3 = Trove.new()

	if folder == localPlayer.Character then
		humanoid = folder:WaitForChild("Humanoid")
	end

	local function childAdded(instance)
		if folder == localPlayer.Character and (instance.Name == "EquippedWeapon" or instance.Name == "UnequippedWeapon") and not instance:GetAttribute("IsLocal") then
			task.wait()
			instance:Destroy()

			for _, motor6D in folder:GetDescendants() do
				if not motor6D:IsA("Motor6D") or motor6D:GetAttribute("WeaponName") ~= instance:GetAttribute("WeaponName") or motor6D:GetAttribute("IsLocal") then
					continue
				end

				motor6D:Destroy()
			end
		elseif instance.Name == "EquippedWeapon" then
			playEquipAnimation(instance)
		elseif instance.Name == "UnequippedWeapon" then
			playUnequipAnimation(instance)
		end
	end

	for _, child in folder:GetChildren() do
		task.defer(childAdded, child)
	end

	maid3:Add(folder.ChildAdded:Connect(childAdded))

	if folder == localPlayer.Character then
		maid3:Add(function()
			CustomCursor:ResetCursorImage()
		end)
	end

	maid3:Add(folder.AncestryChanged:Connect(function(_, parent)
		if parent == nil then
			maid3:Destroy()
		end
	end))
end

function CombatController.OnStart(_)
	local Util = require(game.ReplicatedStorage.Util)
	v6 = Util
	local Effect = require(game.ReplicatedStorage.Effect)
	v10 = Effect
	v4.RegisterAttackEvent = Net:RemoteEvent("RegisterAttack")
	v4.CancelEquipAnimEvent = Net:RemoteEvent("CancelEquipAnim")
	v4.EquipAnimApplyEndStateEvent = Net:RemoteEvent("EquipAnimApplyEndState")
	v4.VisualEquippedEvent = Net:RemoteEvent("VisualEquipped")
	v4.VisualUnequippedEvent = Net:RemoteEvent("VisualUnequipped")
	v4.ShootGunEvent = Net:RemoteEvent("ShootGunEvent")
	v4.ReceivedHit = Net:RemoteEvent("ReceivedHit")
	v4.PlayAttackStartEffectEvent = Net:RemoteEvent("PlayAttackStartEffect")
	local character = localPlayer.Character

	if character then
		task.defer(charAdded, character)
	end

	game.Players.LocalPlayer.CharacterAdded:Connect(charAdded)
	workspace.Characters.ChildAdded:Connect(charAdded)
	workspace.Enemies.ChildAdded:Connect(charAdded)
	v4.CancelEquipAnimEvent.OnClientEvent:Connect(function(p)
		cancelEquipAnim(p) -- equivalent call inferred; original call site unknown
	end)
	v4.ReceivedHit.OnClientEvent:Connect(function(p, p2, p3, p4, p5)
		if p == localPlayer.Character then
			CombatUtil:ApplyDamageHighlight(localPlayer.Character, p2, p3, p4, p5)
		elseif p4 == "Sword" or p4 == "Melee" then
			CombatUtil:PlayMeleeHitParticles(p, p5, p3)
		end
	end)
	v4.PlayAttackStartEffectEvent.OnClientEvent:Connect(function(_, p, p2)
		CombatUtil:AttackStart(p, p2)
	end)
end

return CombatController