local createVector = vector.create
game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("UserInputService")
game:GetService("TweenService")
local currentCamera = workspace.CurrentCamera
local Util = require(ReplicatedStorage.Util)
local CombatUtil = require(ReplicatedStorage.Modules.CombatUtil)
local localPlayer = game.Players.LocalPlayer
require(ReplicatedStorage:WaitForChild("FX"))
local _WorldOrigin = workspace._WorldOrigin
local CustomCollisions = require(ReplicatedStorage:WaitForChild("CustomCollisions"))
local rocks = CustomCollisions.new("Rocks")

local function isSwordModel(model)
	if not model:IsA("Model") then
		return false
	end

	if model.Name == "EquippedWeapon" then
		return model:GetAttribute("WeaponType") == "Sword"
	end

	if model.Name ~= "UnequippedWeapon" then
		return false
	end

	local weaponName = model:GetAttribute("WeaponName")
	local weaponData = weaponName and CombatUtil:GetWeaponData(weaponName)
	return weaponData ~= nil and weaponData.WeaponType == "Sword"
end

local function setModelHidden(folder, p)
	for _, descendant in folder:GetDescendants() do
		if descendant:IsA("BasePart") or descendant:IsA("Decal") or descendant:IsA("Texture") then
			if p then
				if descendant:GetAttribute("MagnetSwordDisableHidden") == nil then
					descendant:SetAttribute(
						"MagnetSwordDisableHidden",
						descendant:GetAttribute("TrueTransparency") or descendant.Transparency
					)
				end

				descendant:SetAttribute("TransparencyBypass", true)
				descendant.Transparency = 1
			else
				descendant:SetAttribute("TransparencyBypass", nil)
				local magnetSwordDisableHidden = descendant:GetAttribute("MagnetSwordDisableHidden")

				if magnetSwordDisableHidden ~= nil then
					descendant.Transparency = magnetSwordDisableHidden
					descendant:SetAttribute("MagnetSwordDisableHidden", nil)
				end
			end
		elseif descendant:IsA("ParticleEmitter") or descendant:IsA("Trail") or descendant:IsA("Beam") or descendant:IsA("Light") then
			if p then
				if descendant:GetAttribute("MagnetSwordDisableHidden") == nil then
					descendant:SetAttribute("MagnetSwordDisableHidden", descendant.Enabled)
				end

				descendant.Enabled = false
			else
				local magnetSwordDisableHidden = descendant:GetAttribute("MagnetSwordDisableHidden")

				if magnetSwordDisableHidden ~= nil then
					descendant.Enabled = magnetSwordDisableHidden
					descendant:SetAttribute("MagnetSwordDisableHidden", nil)
				end
			end
		end
	end
end

local function launchClone(child, instance, p)
	local clone = child:Clone()
	clone:RemoveTag("Weapon")
	clone:RemoveTag("WeaponBack")

	for _, descendant in clone:GetDescendants() do
		descendant:RemoveTag("WeaponHitbox")
		descendant:RemoveTag("Blade")
		descendant:RemoveTag("Weapon")
		descendant:RemoveTag("WeaponBack")
	end

	for _, descendant in clone:GetDescendants() do
		if not (descendant:IsA("Weld") or descendant:IsA("WeldConstraint") or descendant:IsA("Motor6D") or descendant:IsA("Snap") or descendant:IsA("Glue")) then
			continue
		end

		local part0 = descendant.Part0
		local part1 = descendant.Part1

		if part0 and part1 and part0:IsDescendantOf(clone) and part1:IsDescendantOf(clone) then
			continue
		end

		descendant:Destroy()
	end

	local v = nil

	for _, part in clone:GetDescendants() do
		if not part:IsA("BasePart") then
			continue
		end

		part.Anchored = false
		part.CanCollide = false
		v = v or part
	end

	if not v then
		clone:Destroy()
		return
	end

	Util.SetParentOverrideWithColor(clone, _WorldOrigin, p, "MagnetFruitVFXColor")
	local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")
	local v2 = humanoidRootPart and v.Position - humanoidRootPart.Position
	v.AssemblyLinearVelocity = (v2 and v2.Magnitude > 0.1 and v2.Unit or humanoidRootPart and humanoidRootPart.CFrame.LookVector or createVector(
		0,
		1,
		0
	)) * 50 + createVector(0, 25, 0)
	v.AssemblyAngularVelocity = Vector3.new(math.random(-18, 18), math.random(-18, 18), math.random(-18, 18))
	Util.Debris:AddItem(clone, 3)

	for _, part in clone:GetDescendants() do
		if part:IsA("BasePart") then
			rocks:ApplyCollision(part, nil, true)
		end
	end
end

local function runDisableVisual(character, origin: Vector3, expiry, fn, p)
	if not character or (origin - currentCamera.CFrame.Position).Magnitude > 500 then
		return
	end

	local function ensureHidden()
		for _, child in character:GetChildren() do
			if isSwordModel(child) then
				setModelHidden(child, true)
			end
		end
	end

	local function restore()
		for _, child in character:GetChildren() do
			if isSwordModel(child) then
				setModelHidden(child, false)
			end
		end
	end

	pcall(function()
		for _, child in character:GetChildren() do
			if not (isSwordModel(child) and fn(child)) then
				continue
			end

			launchClone(child, character, p)
			break
		end
	end)
	task.spawn(function()
		local flag = false

		-- equivalent calls inferred from this helper; original call sites unknown
		local function safeRestore()
			if flag then
				return
			end

			flag = true
			pcall(restore)
		end

		task.delay(60, safeRestore)
		local serverTimeNow = workspace:GetServerTimeNow()
		local success, result = pcall(function()
			ensureHidden()
			local swordDisableProxy = character:FindFirstChild("SwordDisableProxy") or character:WaitForChild(
				"SwordDisableProxy",
				2
			)

			local function stillDisabled()
				if not character.Parent or workspace:GetServerTimeNow() - serverTimeNow >= 60 then
					return false
				end

				if not swordDisableProxy then
					return workspace:GetServerTimeNow() < (expiry or 0)
				end

				if swordDisableProxy.Parent then
					return workspace:GetServerTimeNow() < (swordDisableProxy:GetAttribute("Expiry") or 0)
				end

				return false
			end

			while stillDisabled() do
				ensureHidden()
				task.wait(0.2)
			end
		end)

		if not success then
			warn("[SwordDisableEffect] error while hiding sword, restoring:", result)
		end

		safeRestore() -- equivalent call inferred; original call site unknown
	end)
end

return function(player)
	local origin = player.Origin or player.Root and player.Root.Position or player.hrp and player.hrp.Position or player.Player and player.Player.Character.PrimaryPart.Position
	assert(origin, "Origin Vector3 missing in: ", script:GetFullName())
	local player2 = player.Player
	local stage = player.Stage

	if stage == 1 then
		local character = player2 and player2.Character

		if not character then
			return
		end

		local v = player2 == localPlayer
		runDisableVisual(character, origin, player.Expiry, function(instance)
			return v == (instance:GetAttribute("IsLocal") == true)
		end, player2)
	elseif stage == 2 then
		runDisableVisual(player.Character, origin, player.Expiry, function()
			return true
		end, player.Character)
	end
end