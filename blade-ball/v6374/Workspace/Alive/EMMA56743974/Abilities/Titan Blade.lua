local createVector = vector.create
local Debris = game:GetService("Debris")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local UserInputService = require(ReplicatedStorage2:WaitForChild("UserInputService"))
local _ = ReplicatedStorage.Assets
local controllers = ReplicatedStorage.Controllers
local packages = ReplicatedStorage.Packages
local shared = ReplicatedStorage.Shared
local dash = script:WaitForChild("Dash")
local name = script.Name
local Abilities = require(shared.Abilities)
local AbilityUtils = require(shared.AbilityUtils)
local Net = require(packages.Net)
local Replion = require(packages.Replion)
local SettingsController = require(controllers.SettingsController)
local Utils = require(ReplicatedStorage.Common.Utils)
local localPlayer = Players.LocalPlayer
local character = localPlayer.Character or localPlayer.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
local humanoid = character:WaitForChild("Humanoid")
local track = humanoid:WaitForChild("Animator"):LoadAnimation(dash)
local flag = false
local flag2 = false
local v = false
local v2 = false
local mouseButton2 = Enum.UserInputType.MouseButton2
local thread = nil
local thread2 = nil
local remoteFunction = Net:RemoteFunction("NewAbilities/ActivePrimarySlot")
local ability = localPlayer.PlayerGui:WaitForChild("Hotbar"):WaitForChild("Ability")
local v3 = Replion.Client:WaitReplion("Data")

local function updateIcon()
	local child = ReplicatedStorage.Misc.DataAbilities:FindFirstChild(name)

	if not child then
		return
	end

	local attributes = child:GetAttributes()
	local v4 = v3:Get({ "AbilityUpgrades", name })
	local icon = attributes.Icon

	for i = 1, v4 or 0 do
		icon = attributes["Icon" .. i] or attributes.Icon
	end

	ability.Vector.Image = icon or ""
end

task.spawn(updateIcon)
v3:OnChange({ "AbilityUpgrades", name }, updateIcon)

local function dash2()
	if v or character.Parent ~= workspace.Alive or ability.Red.Visible ~= false or humanoid.MoveDirection == createVector(
		0,
		0,
		0
	) then
		return
	end

	v = true
	thread2 = task.delay(2, function()
		v = false
		thread2 = nil
	end)
	local v4 = {
		FieldOfView = workspace.CurrentCamera.FieldOfView * 1.25
	}
	local tweenInfo = TweenInfo.new(0.25, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, true, 0)
	TweenService:Create(workspace.CurrentCamera, tweenInfo, v4):Play()
	local moveDirection = humanoid.MoveDirection
	local v5 = 180
	local scale = character:GetScale()

	if scale > 1 then
		v5 *= scale
	end

	v2 = true
	ReplicatedStorage.Remotes.DashFired:Fire()
	ReplicatedStorage.Remotes.VisualBindableCD:Fire(false, true, 2)
	ReplicatedStorage.Remotes.PlrDashed:FireServer()
	AbilityUtils.playAnimationTrack(track, name, 0.567)
	local rightVector = humanoidRootPart.CFrame.RightVector
	local lookVector = humanoidRootPart.CFrame.LookVector
	local dot = moveDirection:Dot(lookVector)
	local dot2 = moveDirection:Dot(rightVector)
	local v6 = 1 - math.random() / 100000000
	local v7 = math.clamp(dot, -1, v6)
	local v8 = math.clamp(dot2, -1, v6)
	local attachment = Instance.new("Attachment")
	attachment.Parent = humanoidRootPart
	local linearVelocity = Instance.new("LinearVelocity")
	linearVelocity.Name = "Dash"
	linearVelocity.ForceLimitMode = Enum.ForceLimitMode.PerAxis
	linearVelocity.MaxAxesForce = createVector(100000, 0, 100000)
	linearVelocity.Parent = attachment
	linearVelocity.Attachment0 = attachment
	linearVelocity.VectorVelocity = lookVector * v7 * v5 + rightVector * v8 * v5
	Debris:AddItem(attachment, 0.01)
	local descendantAddedConnection = nil
	task.defer(function()
		for _, part in ipairs(character:GetDescendants()) do
			if not part:IsA("BasePart") or part.Massless then
				continue
			end

			part.Massless = true
			part:SetAttribute("DashSetMassless", true)
		end

		descendantAddedConnection = character.DescendantAdded:Connect(function(part)
			if part:IsA("BasePart") then
				part.Massless = true
				part:SetAttribute("DashSetMassless", true)
			end
		end)
	end)
	local colliders = character:FindFirstChild("Colliders")
	local pin = colliders and colliders:FindFirstChild("Pin")
	local rigidConstraint

	if pin then
		rigidConstraint = pin:FindFirstChildWhichIsA("RigidConstraint")

		if rigidConstraint then
			rigidConstraint.Enabled = false
		end
	else
		rigidConstraint = nil
	end

	task.delay(0.3, function()
		for _, descendant in ipairs(character:GetDescendants()) do
			if not descendant:GetAttribute("DashSetMassless") then
				continue
			end

			descendant:SetAttribute("DashSetMassless", nil)
			descendant.Massless = false
		end

		if rigidConstraint then
			rigidConstraint.Enabled = true
		end

		if descendantAddedConnection then
			descendantAddedConnection:Disconnect()
		end

		humanoidRootPart.AssemblyLinearVelocity = createVector(0, 0, 0)
		humanoidRootPart.AssemblyAngularVelocity = createVector(0, 0, 0)
	end)

	if flag2 then
		ReplicatedStorage.Remotes.VisualBindableCD:Fire(false, true, 2)
	end

	task.wait(0.4)
	v2 = false
end

local function ability2()
	if flag then
		if flag2 and not v then
			dash2()
		end
	else
		if character.Parent ~= workspace.Alive or ability.Red.Visible ~= false then
			return
		end

		flag = true
		flag2 = true
		local abilityCooldown = Abilities.getAbilityCooldown(localPlayer, name)
		thread = task.spawn(function()
			local v4 = remoteFunction:InvokeServer(name)

			if v4 then
				ReplicatedStorage.Remotes.VisualBindableCD:Fire(false, true, 0, true)

				if localPlayer:GetAttribute("InTitanBlade") then
					repeat
						task.wait()
					until not (localPlayer:GetAttribute("InTitanBlade") and script.Parent and script.Enabled)
				end

				flag2 = false

				if v4 then
					ReplicatedStorage.Remotes.VisualBindableCD:Fire(false, true, abilityCooldown)
				else
					ReplicatedStorage.Remotes.VisualBindableCD:Fire(false, true, 0.01)
				end

				thread = task.delay(abilityCooldown, function()
					flag = false
					thread = nil
				end)
			else
				flag = false
				flag2 = false
			end
		end)
	end
end

local v4 = true
script.Destroying:Connect(function()
	v4 = false

	if thread then
		Utils.Thread.SafeCancel(thread)
	end

	if thread2 then
		Utils.Thread.SafeCancel(thread2)
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
	flag = false

	if thread then
		Utils.Thread.SafeCancel(thread)
		thread = nil
	end
end)
ReplicatedStorage.Remotes.KeybindM2.OnClientEvent:Connect(function(p)
	if p then
		mouseButton2 = nil
	else
		mouseButton2 = Enum.UserInputType.MouseButton2
	end
end)