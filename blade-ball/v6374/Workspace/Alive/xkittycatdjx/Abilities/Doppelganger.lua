local createVector = vector.create
local Debris = game:GetService("Debris")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local UserInputService = require(ReplicatedStorage2:WaitForChild("UserInputService"))
local tutorial = ReplicatedStorage.Assets.Tutorial
local controllers = ReplicatedStorage.Controllers
local packages = ReplicatedStorage.Packages
local shared = ReplicatedStorage.Shared
local doubleJump = tutorial.Animations.DoubleJump
local name = script.Name
local Abilities = require(shared.Abilities)
local AbilityUtils = require(shared.AbilityUtils)
local Net = require(packages.Net)
local Replion = require(packages.Replion)
local SettingsController = require(controllers.SettingsController)
local ThreadSafeTargetingHelper = require(shared.ThreadSafeTargetingHelper)
local Utils = require(ReplicatedStorage.Common.Utils)
local localPlayer = Players.LocalPlayer
local character = localPlayer.Character or localPlayer.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
character:WaitForChild("Humanoid")
local v = false
local thread = nil
local remoteFunction = Net:RemoteFunction("NewAbilities/ActivePrimarySlot")
local remoteEvent = Net:RemoteEvent("DoppelgangerSwap")
local ability = localPlayer.PlayerGui:WaitForChild("Hotbar"):WaitForChild("Ability")
require(ReplicatedStorage.Shared.Abilities[script.Name])
local v2 = Replion.Client:WaitReplion("Data")

local function updateIcon()
	local child = ReplicatedStorage.Misc.DataAbilities:FindFirstChild(script.Name)

	if not child then
		return
	end

	local attributes = child:GetAttributes()
	local v3 = v2:Get({ "AbilityUpgrades", script.Name })
	local icon = attributes.Icon

	for i = 1, v3 or 0 do
		icon = attributes["Icon" .. i] or attributes.Icon
	end

	ability.Vector.Image = icon or ""
end

task.spawn(updateIcon)
v2:OnChange({ "AbilityUpgrades", script.Name }, updateIcon)

function getMirrorPlayerPosition(instance, instance2)
	local pivot = instance2:GetPivot()
	local pivot2 = instance:GetPivot()
	local position = pivot.Position
	local position2 = pivot2.Position
	local v3 = position.X * 2 - position2.X
	local v4 = position.Z * 2 - position2.Z
	local vector2 = Vector3.new(v3, position2.Y, v4)
	return CFrame.new(vector2) * (pivot2 - position2)
end

function getBotMirrorLocation(p, cframe: CFrame?)
	if not (p and cframe) then
		return
	end

	local raycastParams = RaycastParams.new()
	raycastParams.IgnoreWater = true
	raycastParams.RespectCanCollide = true
	raycastParams.FilterType = Enum.RaycastFilterType.Include
	raycastParams.FilterDescendantsInstances = { workspace.Map }

	for i = 1, 4 do
		local v3 = 1.5707963267948966 * i * 0.5
		local position = (cframe + Vector3.new(math.cos(v3) * 10, 0, math.sin(v3) * 10)).Position

		if workspace:Raycast(position, createVector(-0, -100, -0), raycastParams) then
			return CFrame.new(position)
		end
	end

	return CFrame.new(cframe.Position) + createVector(6.123234e-16, 0, 10), 1
end

local function ability2()
	if v and character.Parent == workspace.Alive and localPlayer.Upgrades[script.Name].Value >= 1 then
		local v3 = nil

		for _, child in workspace.Alive:GetChildren() do
			if not (child:GetAttribute("IsDoppelganger") and child:GetAttribute("DoppelgangerOwner") == localPlayer.Name) then
				continue
			end

			v3 = child
			break
		end

		if v3 then
			remoteEvent:FireServer()
			return
		end
	end

	if v or localPlayer.Character.Parent ~= workspace.Alive or ability.Red.Visible ~= false then
		return
	end

	local v3 = nil

	for _, child in workspace.Alive:GetChildren() do
		if child:GetAttribute("IsDoppelganger") or not ThreadSafeTargetingHelper.AreCharactersEnemies(character, child) then
			continue
		end

		v3 = true
		break
	end

	if not v3 then
		ReplicatedStorage.Misc.error:Play()
		return
	end

	v = true

	if not remoteFunction:InvokeServer(name) then
		v = false
		return
	end

	ReplicatedStorage.Remotes.VisualBindableCD:Fire(false, true, 0, true)
	local v5 = 1
	local v6 = nil

	while true do
		for _, child in workspace.Alive:GetChildren() do
			if not (child:GetAttribute("IsDoppelganger") and child:GetAttribute("DoppelgangerOwner") == localPlayer.Name) then
				continue
			end

			v6 = child
			break
		end

		v5 -= task.wait()

		if not (v6 or v5 <= 0) then
			continue
		end

		if v6 then
			local v8 = 15 + (AbilityUtils.getAbilityUpgrade(localPlayer, name) or 0) * 5

			repeat
				v8 -= task.wait()
			until not v6 or not v6.Parent or v8 <= 0
		end

		local abilityCooldown = Abilities.getAbilityCooldown(nil, script.Name)
		ReplicatedStorage.Remotes.VisualBindableCD:Fire(false, true, abilityCooldown)
		thread = task.delay(abilityCooldown, function()
			v = false
			thread = nil
		end)
		break
	end
end

local v3 = true
script.Destroying:Connect(function()
	v3 = false
end)

function setDoppelganger(instance)
	if not instance then
		return
	end

	local humanoid = instance:WaitForChild("Humanoid")

	if not humanoid then
		return
	end

	local track = humanoid:WaitForChild("Animator"):LoadAnimation(doubleJump)
	local v4 = workspace.Map:GetChildren()[1]
	local FLOOR = v4 and v4:FindFirstChild("FLOOR")

	if not FLOOR then
		return
	end

	local v5 = false
	local v6 = nil
	local count = 0
	local flag = false

	local function botJumpRequest()
		local now = os.clock()
		local v7 = v6 and now - v6 < 0.1 and true or false
		v6 = now

		if v7 then
			return
		end

		if humanoid.FloorMaterial == Enum.Material.Air and not v5 then
			if flag then
				return
			end

			task.spawn(function()
				flag = true
				task.wait(0.2)
				flag = false
			end)
			count += 1

			if count > 1 then
				return
			end

			local bodyVelocity = Instance.new("BodyVelocity")
			bodyVelocity.Name = "Dash"
			bodyVelocity.Parent = instance.PrimaryPart
			bodyVelocity.MaxForce = createVector(1e999, 1e999, 1e999)

			if count == 1 then
				bodyVelocity.Velocity = createVector(0, 80, 0)
			end

			Debris:AddItem(bodyVelocity, 0.001)

			if count == 1 then
				track:Play()
			elseif count == 2 or count == 3 then
				track:Stop()
			end

			if count == 1 then
				v5 = true
			end

			local v8 = count
			task.wait(1.5)

			if v8 == count then
				count = 0
				v5 = false
			end
		end
	end

	instance:WaitForChild("JumpRequest").Event:Connect(function(flag2: boolean)
		if not instance or not instance.Parent or instance:GetAttribute("Dead") then
			return
		end

		if flag2 then
			botJumpRequest()
		else
			humanoid.Jump = true
		end
	end)

	while v3 and humanoid.Parent and humanoidRootPart.Parent and FLOOR.Parent do
		local mirrorPlayerPosition = getMirrorPlayerPosition(character, FLOOR)
		local botMirrorLocation = getBotMirrorLocation(instance, mirrorPlayerPosition)

		if botMirrorLocation then
			humanoid:MoveTo(botMirrorLocation.Position)
		end

		task.wait(0.05)
	end
end

workspace.Alive.ChildAdded:Connect(function(child)
	if child:GetAttribute("IsDoppelganger") and child:GetAttribute("DoppelgangerOwner") == localPlayer.Name then
		setDoppelganger(child)
	end
end)
UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then
		return
	end

	if SettingsController:UseBind(input, "Ability") then
		ability2()
	end
end)
ReplicatedStorage.Remotes.AbilityButtonPress.Event:Connect(ability2)
ReplicatedStorage.Remotes.EndCD.OnClientEvent:Connect(function()
	v = false

	if thread then
		Utils.Thread.SafeCancel(thread)
		thread = nil
	end
end)