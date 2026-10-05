local createVector = vector.create
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Net = require(ReplicatedStorage.Packages.Net)
local ToolActionInput = require(ReplicatedStorage.Shared.ToolActionInput)
local ServerAuthority = require(ReplicatedStorage.Shared.ServerAuthority)
local ServerData = require(ReplicatedStorage.Datas.ServerData)
local flyingBee = ReplicatedStorage:WaitForChild("Assets"):WaitForChild("Tools"):WaitForChild("Flying Bee")
local beeIdleAnimation = flyingBee:WaitForChild("BeeIdleAnimation")
local beeFlyAnimation = flyingBee:WaitForChild("BeeFlyAnimation")
local playerIdleAnimation = flyingBee:WaitForChild("PlayerIdleAnimation")
local playerFlyAnimation = flyingBee:WaitForChild("PlayerFlyAnimation")
local parent = script.Parent
local localPlayer = Players.LocalPlayer
local character

if localPlayer.Character and localPlayer.Character.Parent == workspace then
	character = localPlayer.Character
else
	character = localPlayer.CharacterAdded:Wait()
end

local v = assert(character:WaitForChild("HumanoidRootPart", 5))
local v2 = assert(character:WaitForChild("Humanoid", 5))
local mainHighlight = workspace:WaitForChild("MainHighlight")
local flyingBeeAttack = localPlayer.PlayerGui:WaitForChild("ToolsFrames"):WaitForChild("FlyingBeeAttack")
local enabled = ServerAuthority.isEnabled()
local isTradePlaza = ServerData.IsTradePlaza()
local v3 = false
local v4 = false
local v5 = nil
local childAddedConnection = nil
local v6 = false
local track = nil
local track2 = nil
local track3 = nil
local track4 = nil

local function updateActionButton()
	local cooldownTime = tonumber(parent:GetAttribute("CooldownTime") or 0) or 0
	local v7

	if cooldownTime <= 0 then
		v7 = v5 ~= nil
	else
		v7 = false
	end

	local color

	if v7 then
		color = Color3.fromRGB(255, 255, 255)
	else
		color = Color3.fromRGB(128, 128, 128)
	end

	flyingBeeAttack.Activate.ImageColor3 = color
	flyingBeeAttack.Activate.Icon.ImageColor3 = color
	flyingBeeAttack.Activate.Txt.TextColor3 = color
	flyingBeeAttack.Activate.Cooldown.Text = string.format("%0.1f", cooldownTime)
	flyingBeeAttack.Activate.Cooldown.Visible = cooldownTime > 0
end

-- equivalent calls inferred from this helper; original call sites unknown
local function resetTarget()
	mainHighlight.Adornee = script
	v5 = nil
	updateActionButton()
end

local function getNearestPlayer()
	local abilityRange = parent:GetAttribute("AbilityRange") or 30
	local v7 = 1e999
	local v8 = nil
	local v9 = nil

	for _, v10 in Players:GetPlayers() do
		if v10 == localPlayer then
			continue
		end

		local character2 = v10.Character
		local humanoidRootPart = character2 and character2:FindFirstChild("HumanoidRootPart")
		local humanoid = character2 and character2:FindFirstChildOfClass("Humanoid")

		if not humanoidRootPart or not humanoidRootPart:IsA("BasePart") or not humanoid or humanoid.Health <= 0 then
			continue
		end

		local magnitude = (v.Position - humanoidRootPart.Position).Magnitude

		if not (magnitude <= abilityRange and magnitude < v7) then
			continue
		end

		v9 = v10
		v8 = character2
		v7 = magnitude
	end

	return v8, v9
end

local function updateTarget()
	local cooldownTime = tonumber(parent:GetAttribute("CooldownTime") or 0) or 0

	if isTradePlaza or not v4 or not flyingBeeAttack.Visible or cooldownTime > 0 then
		resetTarget() -- equivalent call inferred; original call site unknown
	else
		local nearestPlayer, v7 = getNearestPlayer()

		if nearestPlayer and v7 then
			mainHighlight.Adornee = nearestPlayer
			v5 = v7
		else
			mainHighlight.Adornee = script
			v5 = nil
		end

		updateActionButton()
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function stopTrack(instance)
	if instance then
		instance:Stop(0.2)
		instance:Destroy()
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function stopLegacyAnimations()
	stopTrack(track) -- equivalent call inferred; original call site unknown
	stopTrack(track2) -- equivalent call inferred; original call site unknown
	stopTrack(track3) -- equivalent call inferred; original call site unknown
	stopTrack(track4) -- equivalent call inferred; original call site unknown
	track = nil
	track2 = nil
	track3 = nil
	track4 = nil
	v6 = false
end

-- equivalent calls inferred from this helper; original call sites unknown
local function setTrackActive(object, flag: boolean)
	if not object then
		return
	end

	if flag then
		if object.IsPlaying then
			object:AdjustWeight(1, 0.1)
		else
			object:Play(0.1, 1)
		end
	elseif object.IsPlaying then
		object:Stop(0.1)
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function setLegacyMoving(flag: boolean)
	if v6 == flag then
		return
	end

	v6 = flag
	setTrackActive(track, not flag) -- equivalent call inferred; original call site unknown
	setTrackActive(track2, flag) -- equivalent call inferred; original call site unknown
	setTrackActive(track3, not flag) -- equivalent call inferred; original call site unknown
	setTrackActive(track4, flag) -- equivalent call inferred; original call site unknown
end

local function startLegacyAnimations()
	if enabled then
		return
	end

	stopLegacyAnimations() -- equivalent call inferred; original call site unknown
	local beeRig = character:WaitForChild("BeeRig", 2)

	if not (v3 and beeRig and beeRig:IsA("Model")) then
		return
	end

	local animationController = beeRig:FindFirstChild("AnimationController")
	local animator = animationController and animationController:FindFirstChildOfClass("Animator")
	local animator2 = v2:FindFirstChildOfClass("Animator")

	if not (animator and animator2) then
		return
	end

	track = animator:LoadAnimation(beeIdleAnimation)
	track.Looped = true
	track.Priority = Enum.AnimationPriority.Action
	track2 = animator:LoadAnimation(beeFlyAnimation)
	track2.Looped = true
	track2.Priority = Enum.AnimationPriority.Action
	track3 = animator2:LoadAnimation(playerIdleAnimation)
	track3.Looped = true
	track3.Priority = Enum.AnimationPriority.Action
	track4 = animator2:LoadAnimation(playerFlyAnimation)
	track4.Looped = true
	track4.Priority = Enum.AnimationPriority.Action
	v6 = false
	setTrackActive(track, true) -- equivalent call inferred; original call site unknown
	local v8 = track2

	if v8 and v8.IsPlaying then
		v8:Stop(0.1)
	end

	setTrackActive(track3, true) -- equivalent call inferred; original call site unknown
	setTrackActive(track4, false) -- equivalent call inferred; original call site unknown
end

-- equivalent calls inferred from this helper; original call sites unknown
local function setLegacyFlightState(flag: boolean)
	v3 = flag
	flyingBeeAttack.Visible = flag and not isTradePlaza

	if not flag then
		resetTarget() -- equivalent call inferred; original call site unknown
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function handleLegacyFlight()
	if childAddedConnection then
		childAddedConnection:Disconnect()
	end

	childAddedConnection = v.ChildAdded:Connect(function(child)
		if v3 or child.Name ~= "FlightHold" then
			return
		end

		local flightSpin = v:FindFirstChild("FlightSpin")
		local flightPower = v:FindFirstChild("FlightPower")
		local flightHold = v:FindFirstChild("FlightHold")

		if not (flightSpin and flightPower and flightHold) then
			return
		end

		setLegacyFlightState(true) -- equivalent call inferred; original call site unknown
		v2.WalkSpeed = 0
		v2.PlatformStand = true
		v2.AutoRotate = false
		v.AssemblyLinearVelocity = createVector(0, 0, 0)
		v.AssemblyAngularVelocity = createVector(0, 0, 0)
		startLegacyAnimations()

		while v3 and flightSpin.Parent and flightPower.Parent and flightHold.Parent and v2.Health > 0 and parent.Parent == character do
			local currentCamera = workspace.CurrentCamera

			if currentCamera then
				local flightSpeed = parent:GetAttribute("FlightSpeed") or 105
				local unit = currentCamera.CFrame:VectorToWorldSpace(createVector(0, 0, -1))
				local vectorToWorldSpace = currentCamera.CFrame:VectorToWorldSpace(createVector(-1, 0, 0))
				local vectorToObjectSpace = CFrame.new(
					createVector(0, 0, 0),
					currentCamera.CFrame.LookVector * createVector(1, 0, 1)
				):VectorToObjectSpace(v2.MoveDirection)
				local velocity = unit * flightSpeed * -vectorToObjectSpace.Z + vectorToWorldSpace * flightSpeed * 0.6666666666666666 * -vectorToObjectSpace.X

				if velocity.Magnitude > 1 then
					unit = velocity.Unit
				end

				flightSpin.CFrame = CFrame.new(createVector(0, 0, 0), unit)

				if velocity.Magnitude < 1 then
					flightHold.MaxForce = createVector(1, 1, 1) * flightHold.P
					flightPower.MaxForce = createVector(0, 0, 0)
					flightHold.Position = v.Position
				else
					flightHold.MaxForce = createVector(0, 0, 0)
					flightPower.MaxForce = createVector(1, 1, 1) * flightPower.P * 100
				end

				flightPower.Velocity = velocity
				setLegacyMoving(velocity.Magnitude > 5) -- equivalent call inferred; original call site unknown
				RunService.Heartbeat:Wait()
			else
				RunService.Heartbeat:Wait()
			end
		end

		setLegacyFlightState(false) -- equivalent call inferred; original call site unknown
		stopLegacyAnimations() -- equivalent call inferred; original call site unknown

		if v2.Health > 0 then
			v.AssemblyLinearVelocity = createVector(0, 0, 0)
			v.AssemblyAngularVelocity = createVector(0, 0, 0)
			v2.WalkSpeed = 16
			v2.PlatformStand = false
			v2.AutoRotate = true
			v2:ChangeState(Enum.HumanoidStateType.Freefall)
		end
	end)
end

parent.Equipped:Connect(function()
	v4 = true
	RunService:UnbindFromRenderStep("FlyingBeeTarget")
	RunService:BindToRenderStep("FlyingBeeTarget", Enum.RenderPriority.Character.Value + 1, updateTarget)
	handleLegacyFlight() -- equivalent call inferred; original call site unknown
end)
parent.Unequipped:Connect(function()
	v4 = false
	setLegacyFlightState(false) -- equivalent call inferred; original call site unknown
	stopLegacyAnimations() -- equivalent call inferred; original call site unknown
	RunService:UnbindFromRenderStep("FlyingBeeTarget")

	if childAddedConnection then
		childAddedConnection:Disconnect()
		childAddedConnection = nil
	end
end)
local v7 = ToolActionInput.bind(flyingBeeAttack, flyingBeeAttack.Activate, function()
	if v5 then
		Net:RemoteEvent("Tools/FlyingBee/Attack"):FireServer(v5)
	end
end)
parent:GetAttributeChangedSignal("CooldownTime"):Connect(updateActionButton)
flyingBeeAttack:GetPropertyChangedSignal("Visible"):Connect(updateTarget)
parent.Destroying:Connect(function()
	RunService:UnbindFromRenderStep("FlyingBeeTarget")
	stopLegacyAnimations() -- equivalent call inferred; original call site unknown
	resetTarget() -- equivalent call inferred; original call site unknown
	v7()
end)
updateActionButton()