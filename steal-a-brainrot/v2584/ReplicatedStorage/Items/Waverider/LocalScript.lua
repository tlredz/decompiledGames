local createVector = vector.create
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Net = require(ReplicatedStorage.Packages.Net)
local Spring = require(ReplicatedStorage.Packages.Spring)
local ToolActionInput = require(ReplicatedStorage.Shared.ToolActionInput)
local parent = script.Parent
local playerFromCharacter

if parent.Parent:IsA("Model") then
	playerFromCharacter = Players:GetPlayerFromCharacter(parent.Parent)
else
	playerFromCharacter = parent.Parent.Parent
end

assert(playerFromCharacter and playerFromCharacter:IsA("Player"))

if playerFromCharacter ~= Players.LocalPlayer then
	return
end

local character = playerFromCharacter.Character and playerFromCharacter.Character.Parent == workspace and playerFromCharacter.Character or playerFromCharacter.CharacterAdded:Wait()
local v = assert(character:WaitForChild("HumanoidRootPart", 5))
local v2 = assert(character:WaitForChild("Humanoid", 5))
local animator = assert(v2:WaitForChild("Animator", 5))
local waverider = ReplicatedStorage:WaitForChild("Assets"):WaitForChild("Tools"):WaitForChild("Waverider")
local idleAnimation = waverider:WaitForChild("IdleAnimation")
local movingAnimation = waverider:WaitForChild("MovingAnimation")
local waveriderBoost = playerFromCharacter.PlayerGui:WaitForChild("ToolsFrames"):WaitForChild("WaveriderBoost")
local _ = {
	X = 40,
	Z = 60
}
local flag = false
local v3 = false
local changedConnection = nil

-- equivalent calls inferred from this helper; original call sites unknown
local function CheckIfAlive()
	if character and character.Parent and v2 and v2.Parent and v2.Health > 0 and v and v.Parent and playerFromCharacter and playerFromCharacter.Parent then
		return true
	end

	return false
end

-- equivalent calls inferred from this helper; original call sites unknown
local function GetSpeedMultiplier()
	return tonumber(parent:GetAttribute("SpeedMultiplier")) or 1.65
end

local v4 = nil
local v5 = nil
local v6 = 1.65

local function IsPlayable(p)
	local animationId = p.AnimationId
	return animationId ~= "" and animationId ~= "rbxassetid://0"
end

local function LoadTracks()
	if v4 == nil then
		local animationId = idleAnimation.AnimationId
		local v7

		if animationId == "" then
			v7 = false
		else
			v7 = animationId ~= "rbxassetid://0"
		end

		if v7 then
			local track = animator:LoadAnimation(idleAnimation)
			track.Looped = true
			track.Priority = Enum.AnimationPriority.Idle
			v4 = track
		end
	end

	if v5 == nil then
		local animationId = movingAnimation.AnimationId
		local v7

		if animationId == "" then
			v7 = false
		else
			v7 = animationId ~= "rbxassetid://0"
		end

		if v7 then
			local track = animator:LoadAnimation(movingAnimation)
			track.Looped = true
			track.Priority = Enum.AnimationPriority.Movement
			v5 = track
		end
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function StopTracks()
	if v4 then
		v4:Stop(0.2)
	end

	if v5 then
		v5:Stop(0.2)
	end
end

local function UpdateFlightAnimation(magnitude: number, p: number)
	if parent:GetAttribute("Boosting") ~= true then
		v6 = p
	end

	if magnitude > 5 then
		if v4 and v4.IsPlaying then
			v4:Stop(0.2)
		end

		if v5 then
			if not v5.IsPlaying then
				v5:Play(0.2)
			end

			local v7 = magnitude / math.max(60 * v6, 1)
			v5:AdjustSpeed((math.clamp(v7, 0.1, 4)))
		end
	else
		if v5 and v5.IsPlaying then
			v5:Stop(0.2)
		end

		if v4 and not v4.IsPlaying then
			v4:Play(0.2)
		end
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function DisableJump(flag2: boolean)
	if changedConnection then
		changedConnection:Disconnect()
	end

	if flag2 then
		changedConnection = v2.Changed:Connect(function(p)
			if p == "Jump" then
				v2.Jump = false
			end
		end)
	end
end

local childAddedConnection = nil

local function HandleFlightControl()
	if not CheckIfAlive() then
		return
	end

	if childAddedConnection then
		childAddedConnection:Disconnect()
	end

	childAddedConnection = v.ChildAdded:Connect(function(child)
		if flag then
			return
		end

		if child.Name == "FlightHold" then
			local flightSpin = v:FindFirstChild("FlightSpin")
			local flightPower = v:FindFirstChild("FlightPower")
			local flightHold = v:FindFirstChild("FlightHold")

			if not (flightSpin and flightPower and flightHold) then
				return
			end

			flag = true
			waveriderBoost.Visible = true
			v2.WalkSpeed = 0
			v2.PlatformStand = true
			v2.AutoRotate = false

			if changedConnection then
				changedConnection:Disconnect()
			end

			changedConnection = v2.Changed:Connect(function(p)
				if p == "Jump" then
					v2.Jump = false
				end
			end)
			v.AssemblyLinearVelocity = createVector(0, 0, 0)
			v.AssemblyAngularVelocity = createVector(0, 0, 0)
			local v7 = assert(workspace.CurrentCamera)

			while flag and flightSpin.Parent and flightPower.Parent and flightHold.Parent and character and character.Parent and v2 and v2.Parent and v2.Health > 0 and v and v.Parent and playerFromCharacter and playerFromCharacter.Parent do
				local speedMultiplier = GetSpeedMultiplier() -- equivalent call inferred; original call site unknown
				local v9 = 40 * speedMultiplier
				local v10 = 60 * speedMultiplier
				local v11 = createVector(0, 0, 0)
				local cFrame = v7.CFrame
				local unit = cFrame:VectorToWorldSpace(createVector(0, 0, -1))
				local vectorToWorldSpace = cFrame:VectorToWorldSpace(createVector(-1, 0, 0))
				local vectorToObjectSpace = CFrame.new(createVector(0, 0, 0), cFrame.LookVector * createVector(1, 0, 1)):VectorToObjectSpace(v2.MoveDirection)
				local v12 = v11 + (unit * v10 * -vectorToObjectSpace.Z or v11)
				local velocity = v12 + (vectorToWorldSpace * v9 * -vectorToObjectSpace.X or v12)

				if velocity.Magnitude > 1 then
					unit = velocity.Unit
				end

				flightSpin.CFrame = CFrame.new(createVector(0, 0, 0), unit)

				if velocity.Magnitude < 1 then
					flightHold.MaxForce = Vector3.new(flightHold.P, flightHold.P, flightHold.P)
					flightPower.MaxForce = createVector(0, 0, 0)
					flightHold.Position = v.Position
				else
					flightHold.MaxForce = createVector(0, 0, 0)
					flightPower.MaxForce = Vector3.new(flightPower.P * 100, flightPower.P * 100, flightPower.P * 100)
				end

				flightPower.Velocity = velocity
				UpdateFlightAnimation(velocity.Magnitude, speedMultiplier)
				task.wait(0.016666666666666666)
			end

			flag = false
			waveriderBoost.Visible = false
			StopTracks() -- equivalent call inferred; original call site unknown

			if CheckIfAlive() then
				v.AssemblyLinearVelocity = createVector(0, 0, 0)
				v.AssemblyAngularVelocity = createVector(0, 0, 0)
				v2.WalkSpeed = 16
				v2.PlatformStand = false
				v2.AutoRotate = true
				DisableJump(false) -- equivalent call inferred; original call site unknown
				v2:ChangeState(Enum.HumanoidStateType.Freefall)
			end
		end
	end)
end

local v7 = nil
local renderSteppedConnection = nil

-- equivalent calls inferred from this helper; original call sites unknown
local function StopFovEffect()
	if renderSteppedConnection then
		renderSteppedConnection:Disconnect()
		renderSteppedConnection = nil
	end

	local currentCamera = workspace.CurrentCamera

	if currentCamera then
		currentCamera.FieldOfView = 70
	end

	v7 = nil
end

local function StartFovEffect()
	if renderSteppedConnection then
		return
	end

	local currentCamera = workspace.CurrentCamera

	if not currentCamera then
		return
	end

	local v8 = Spring.new(currentCamera.FieldOfView)
	v8.Speed = 12
	v8.Damper = 0.65
	v7 = v8
	renderSteppedConnection = RunService.RenderStepped:Connect(function()
		local currentCamera2 = workspace.CurrentCamera

		if not (currentCamera2 and v7) then
			return
		end

		local target

		if flag and v2.MoveDirection.Magnitude > 0.1 then
			local v10 = GetSpeedMultiplier() / 1.65
			local v11 = parent:GetAttribute("Boosting") ~= true and 0 or math.sin(os.clock() * 3) * 1.5 + 15
			target = v10 * 6 + 70 + v11
		else
			target = 70
		end

		v7.Target = target
		currentCamera2.FieldOfView = v7.Position
	end)
end

local function Equipped()
	if not CheckIfAlive() then
		return
	end

	v3 = true
	LoadTracks()
	StartFovEffect()
	task.spawn(HandleFlightControl)
end

local function Unequipped()
	if not v3 then
		return
	end

	flag = false
	waveriderBoost.Visible = false
	StopTracks() -- equivalent call inferred; original call site unknown
	StopFovEffect() -- equivalent call inferred; original call site unknown

	for _, connection in { changedConnection, childAddedConnection } do
		if connection then
			connection:Disconnect()
		end
	end

	v3 = false
end

parent.Equipped:Connect(Equipped)
parent.Unequipped:Connect(Unequipped)
local v8 = ToolActionInput.bind(waveriderBoost, waveriderBoost.Activate, function()
	Net:RemoteEvent("Tools/Waverider/Boost"):FireServer()
end)
parent.Destroying:Connect(function()
	v8()
	StopFovEffect() -- equivalent call inferred; original call site unknown
end)

local function UpdateCooldown()
	local cooldownTime = tonumber(parent:GetAttribute("CooldownTime") or 0) or 0
	local activate = waveriderBoost.Activate

	if cooldownTime > 0 then
		activate.ImageColor3 = Color3.fromRGB(128, 128, 128)
		activate.Icon.ImageColor3 = Color3.fromRGB(128, 128, 128)
		activate.Txt.TextColor3 = Color3.fromRGB(128, 128, 128)
		activate.Cooldown.Text = string.format("%0.1f", cooldownTime)
		activate.Cooldown.Visible = true
	else
		activate.ImageColor3 = Color3.fromRGB(255, 255, 255)
		activate.Icon.ImageColor3 = Color3.fromRGB(255, 255, 255)
		activate.Txt.TextColor3 = Color3.fromRGB(255, 255, 255)
		activate.Cooldown.Visible = false
	end
end

parent:GetAttributeChangedSignal("CooldownTime"):Connect(UpdateCooldown)
UpdateCooldown()