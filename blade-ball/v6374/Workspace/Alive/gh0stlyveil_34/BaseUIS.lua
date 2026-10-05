local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = require(ReplicatedStorage:WaitForChild("UserInputService"))
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

while not workspace:GetAttribute("ClientStarted") do
	workspace:GetAttributeChangedSignal("ClientStarted"):Wait()
end

local Net = require(ReplicatedStorage2.Packages.Net)
local Replion = require(ReplicatedStorage2.Packages.Replion)
local UseBall2 = require(ReplicatedStorage2.Shared.UseBall2)
local EmoteController = require(ReplicatedStorage2.Controllers.EmoteController)
local Inventory = require(ReplicatedStorage2.Shared.Inventory)
Inventory = Inventory.Client
local AbilityUtils = require(ReplicatedStorage2.Shared.AbilityUtils)
local localPlayer = Players.LocalPlayer
local mouse = localPlayer:GetMouse()
local character = localPlayer.Character or localPlayer.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid", 99)
Replion.Client:WaitReplion("Data")
humanoid:WaitForChild("Animator", 5)
local remoteEvent = Net:RemoteEvent("WindowFocused")
local tracksByName = {}

for _, animation in script:WaitForChild("DoubleJumps"):GetChildren() do
	local track = humanoid:FindFirstChildOfClass("Animator"):LoadAnimation(animation)
	track.Priority = Enum.AnimationPriority.Action2
	tracksByName[animation.Name] = track
end

local clone = script:WaitForChild("Twirl"):Clone()
local track = humanoid:FindFirstChildOfClass("Animator"):LoadAnimation(clone)
track.Destroying:Once(function()
	clone:Destroy()
end)
local hotbar = localPlayer.PlayerGui:WaitForChild("Hotbar")
local v = { "MoonMap", "ZeroGravityArena" }
local currentCamera = workspace.CurrentCamera
local v2 = true
local v3 = false
local v4 = nil
local count = 0
local mouseButton1 = Enum.UserInputType.MouseButton1
local flag = false
local alive = workspace:WaitForChild("Alive")
workspace:WaitForChild("Dead")
script.PlayEmote.Event:Connect(function(p, _)
	warn("PlayEmote event is deprecated, switch to EmoteController:Play() instead")
	EmoteController:Play(p)
end)
UserInputService.WindowFocused:Connect(function()
	v2 = true
	remoteEvent:FireServer(true)
end)
UserInputService.WindowFocusReleased:Connect(function()
	v2 = false
	remoteEvent:FireServer(false)
end)
UserInputService.InputBegan:Connect(function()
	if not v2 then
		v2 = true
		remoteEvent:FireServer(true)
	end
end)

ReplicatedStorage2.Remotes.RequestReflectionData.OnClientInvoke = function()
	local people = {}

	for _, child in ipairs(alive:GetChildren()) do
		if child:FindFirstChild("HumanoidRootPart") then
			people[child.Name] = currentCamera:WorldToScreenPoint(child.HumanoidRootPart.Position)
		end
	end

	local lastInputType = UserInputService:GetLastInputType()
	local mouseposition

	if lastInputType == Enum.UserInputType.MouseButton1 or lastInputType == Enum.UserInputType.Keyboard or lastInputType == Enum.UserInputType.MouseButton2 then
		mouseposition = { mouse.X, mouse.Y }
	else
		mouseposition = { currentCamera.ViewportSize.X / 2, currentCamera.ViewportSize.Y / 2 }
	end

	return {
		refCFrame = workspace.CurrentCamera.CFrame,
		people = people,
		mouseposition = mouseposition
	}
end

local function getJumpCapValue()
	if character:GetAttribute("PULSED") or character.Parent ~= alive then
		return 1
	end

	local equippedAbility = AbilityUtils.getEquippedAbility(localPlayer)
	local abilityBlockPassive = character:GetAttribute("AbilityBlockPassive")
	local abilityBlockCharges = character:GetAttribute("AbilityBlockCharges")

	if equippedAbility and equippedAbility.Name == "Quad Jump" or abilityBlockPassive == "Quad Jump" and abilityBlockCharges > 0 then
		return 3
	end

	return 1
end

local function getDoppelgangerBot()
	local character2 = localPlayer.Character

	if not character2 or character2.Parent ~= workspace.Alive then
		return
	end

	for _, child in workspace.Alive:GetChildren() do
		if child:GetAttribute("IsDoppelganger") and child:GetAttribute("DoppelgangerOwner") == localPlayer.Name then
			return child
		end
	end

	return nil
end

UserInputService.JumpRequest:Connect(function()
	local doppelgangerBot = getDoppelgangerBot()
	local jumpRequest = doppelgangerBot and doppelgangerBot:FindFirstChild("JumpRequest")

	-- equivalent calls inferred from this helper; original call sites unknown
	local function tryRequestDoppelNormalJump()
		if jumpRequest then
			jumpRequest:Fire()
		end
	end

	local now = os.clock()
	local v5 = v4 and now - v4 < 0.1 and true or false
	v4 = now

	if v5 then
		tryRequestDoppelNormalJump() -- equivalent call inferred; original call site unknown
	else
		if character:GetAttribute("JumpDB") then
			return
		end

		if humanoid.FloorMaterial == Enum.Material.Air then
			if not v3 then
				if flag then
					tryRequestDoppelNormalJump() -- equivalent call inferred; original call site unknown
				else
					if jumpRequest then
						jumpRequest:Fire(true)
					end

					task.spawn(function()
						flag = true
						task.wait(0.2)
						flag = false
					end)
					count += 1
					local jumpCapValue = getJumpCapValue()

					if jumpCapValue < count then
						return
					end

					local humanoidRootPart = character.HumanoidRootPart
					local total = 80

					if count > 1 then
						total += 10 * localPlayer.Upgrades["Quad Jump"].Value
					end

					local assemblyLinearVelocity = humanoidRootPart.AssemblyLinearVelocity
					humanoidRootPart.AssemblyLinearVelocity = Vector3.new(
						assemblyLinearVelocity.X,
						total,
						assemblyLinearVelocity.Z
					)
					local torso = character:FindFirstChild("Torso")

					if torso:FindFirstChild("Whirlwinds") or torso:FindFirstChild("MaxWhirlwinds") then
						ReplicatedStorage2.Remotes.CloakJump:FireServer()
					end

					if character.Parent == alive then
						ReplicatedStorage2.Remotes.DoubleJump:FireServer()
					end

					if count == 1 then
						local v6 = tracksByName[character:GetAttribute("SwordAnimationProfile") or character:GetAttribute("AnimationProfile") or "Default"] or tracksByName.Default

						for _, v7 in tracksByName do
							if v7 == v6 then
								v7:Play()
							else
								v7:Stop(0)
							end
						end
					elseif count == 2 or count == 3 then
						for _, v6 in tracksByName do
							v6:Stop()
						end

						track:Stop()
						track:Play()

						if UseBall2() then
							ReplicatedStorage2.Shared.Abilities["Quad Jump"].Activated:Fire()
						else
							ReplicatedStorage2.Remotes.XtraJumped:FireServer()
						end
					end

					if jumpCapValue <= count then
						v3 = true
					end

					local v6 = count
					local currentlySelectedMap = workspace:GetAttribute("CurrentlySelectedMap")

					if table.find(v, currentlySelectedMap) then
						task.wait(3)
					else
						task.wait(1.5)
					end

					if count == v6 or getJumpCapValue() ~= jumpCapValue then
						count = 0
						v3 = false
					end
				end
			end
		else
			tryRequestDoppelNormalJump() -- equivalent call inferred; original call site unknown
		end
	end
end)
local EmoteWheelController = require(ReplicatedStorage2.Controllers.EmoteWheelController)
local zero = Vector2.zero
local vector = zero
UserInputService.InputChanged:Connect(function(input)
	if input.UserInputType.Name:find("Gamepad") then
		EmoteWheelController.thumbstickDelta = Vector2.new(20 * input.Position.X, -20 * input.Position.Y)
		return
	end

	if input.UserInputType ~= Enum.UserInputType.Touch then
		return
	end

	vector = Vector2.new(input.Position.X, input.Position.Y)
	EmoteWheelController.thumbstickDelta = (vector - zero) * 5
end)
humanoid.Died:Connect(function()
	ReplicatedStorage2.Remotes.OnDeath:FireServer(localPlayer)

	if localPlayer.Character:FindFirstChildOfClass("Highlight") then
		localPlayer.Character:FindFirstChildOfClass("Highlight"):Destroy()
	end

	if localPlayer.Character.HumanoidRootPart:FindFirstChild("ParticleShine") then
		localPlayer.Character.HumanoidRootPart:FindFirstChild("ParticleShine"):Destroy()
	end
end)
ReplicatedStorage2.Remotes.KeybindM2.OnClientEvent:Connect(function(p)
	if p then
		mouseButton1 = Enum.UserInputType.MouseButton2
	else
		mouseButton1 = Enum.UserInputType.MouseButton1
	end
end)
local CollectionService = game:GetService("CollectionService")
CollectionService:GetInstanceAddedSignal("Platform"):Connect(function(instance)
	task.defer(function()
		if not instance:FindFirstChild("OwnerCharacter") or instance.OwnerCharacter.Value == Players.LocalPlayer.Character then
			instance.CanCollide = true
			return
		end

		for _, part in instance:GetChildren() do
			if part:IsA("BasePart") then
				part.CanCollide = false
			end
		end

		instance.CanCollide = false
	end)
end)
local ready = hotbar.Ability.ready
script.Parent:WaitForChild("Abilities"):WaitForChild("Blink"):GetPropertyChangedSignal("Enabled"):Connect(function()
	if script.Parent.Abilities.Blink.Enabled then
		ready.counts.Visible = true
	else
		ready.counts.Visible = false
	end
end)
local _ = workspace.CurrentCamera.FieldOfView
local Observers = require(ReplicatedStorage2.Packages.Observers)
Observers.observeChildren(script.Parent.Abilities, function(instance)
	instance:GetPropertyChangedSignal("Enabled"):Connect(function()
		if not instance.Enabled then
			ReplicatedStorage2.Remotes.ResetFOV:Fire()

			if instance.Name == "Slash of Duality" then
				local dualityChoice = instance:FindFirstChild("DualityChoice")

				if dualityChoice then
					local module = require(dualityChoice)
					module.toggleOff()
				end
			elseif instance.Name == "Death Slash" then
				ReplicatedStorage2.Remotes.M1Stop:Fire(false)
				local timingUIHandler = instance:FindFirstChild("TimingUIHandler")

				if timingUIHandler then
					local module = require(timingUIHandler)
					module.ToggleUIOff()
				end
			elseif instance.Name == "Slashes of Fury" then
				local furyTimer = localPlayer.PlayerGui:FindFirstChild("FuryTimer")

				if furyTimer then
					furyTimer.Enabled = false
				end

				for _, child in workspace.Alive:GetChildren() do
					local furyHighlight = child:FindFirstChild("FuryHighlight")

					if furyHighlight then
						furyHighlight:Destroy()
					end
				end

				for _, child in workspace.Balls:GetChildren() do
					local comboCounter = child:FindFirstChild("ComboCounter")

					if comboCounter then
						comboCounter:Destroy()
					end
				end
			elseif instance.Name == "Raging Deflection" then
				local SpeedModifiers = require(ReplicatedStorage2.Shared.SpeedModifiers)
				SpeedModifiers:RemoveModifierFor(character, "Initial Raging Deflect Debuff")
			else
				local character2 = (instance.Name == "Dash" or instance.Name == "NinjaDash") and localPlayer.Character

				if character2 then
					for _, descendant in character2:GetDescendants() do
						if not descendant:GetAttribute("DashSetMassless") then
							continue
						end

						descendant:SetAttribute("DashSetMassless", nil)
						descendant.Massless = false
					end
				end
			end
		end
	end)
end)