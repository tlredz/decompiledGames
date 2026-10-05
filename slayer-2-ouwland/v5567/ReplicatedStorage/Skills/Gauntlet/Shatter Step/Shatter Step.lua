local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local CAM = ReplicatedStorage.CAM
local skills = ReplicatedStorage.Skills
local cleanit = require(ReplicatedStorage.Packages.cleanit)
local v = cleanit.new()
local RaycastHelper = require(CAM.Global.RaycastHelper)
local Platform_Handler = require(CAM.Client.Controllers.Platform_Handler)
local Utility = require(CAM.Global.Utility)
local Config = require(script.Parent.Config)
local ShatterStep = {
	Id = 0
}
local shatterStep = script.ShatterStep
local shatterStepAir = script.ShatterStepAir
local skill_stand_still = skills.holder.skill_stand_still
local track = nil
local postSimulationConnection = nil

function ShatterStep.Hold(player)
	v:Clean()

	if track then
		track:Stop()
		track = nil
	end

	if postSimulationConnection then
		postSimulationConnection:Disconnect()
		postSimulationConnection = nil
	end

	local character = player.Character
	local humanoidRootPart = character and character.HumanoidRootPart
	local animator = character and character.Humanoid:FindFirstChildOfClass("Animator")

	if not (animator and humanoidRootPart) then
		return
	end

	local id = ShatterStep.Id
	local clone = skill_stand_still:Clone()
	clone.Parent = humanoidRootPart
	v:Add(clone)
	local mousepos = Platform_Handler.mousepos(Config.MOUSE_RANGE)
	local alignOrientationWithAttachment, v2 = Utility.CreateAlignOrientationWithAttachment(
		humanoidRootPart,
		"skill_look_at",
		{
			AlignType = Enum.AlignType.PrimaryAxisParallel,
			Responsiveness = 70,
			MaxTorque = 500000,
			CFrame = Utility.SafeLookAt(
				humanoidRootPart.Position,
				Vector3.new(mousepos.X, humanoidRootPart.Position.Y, mousepos.Z),
				humanoidRootPart.CFrame
			)
		}
	)
	v:Add(alignOrientationWithAttachment)
	v:Add(v2)
	postSimulationConnection = RunService.PostSimulation:Connect(function()
		if ShatterStep.Id ~= id then
			return
		end

		local mousepos2 = Platform_Handler.mousepos(Config.MOUSE_RANGE)
		alignOrientationWithAttachment.CFrame = Utility.SafeLookAt(
			humanoidRootPart.Position,
			Vector3.new(mousepos2.X, humanoidRootPart.Position.Y, mousepos2.Z),
			alignOrientationWithAttachment.CFrame
		)
	end)
	track = animator:LoadAnimation(shatterStep)
	track:Play()
	task.delay(Config.HOLD_PAUSE, function()
		if ShatterStep.Id ~= id then
			return
		end

		if track and track.IsPlaying then
			track:AdjustSpeed(0)
		end
	end)
end

function ShatterStep.UnHold(_)
	local id = ShatterStep.Id

	if postSimulationConnection then
		postSimulationConnection:Disconnect()
		postSimulationConnection = nil
	end

	if track then
		if track.TimePosition < Config.HOLD_PAUSE then
			track.TimePosition = Config.HOLD_PAUSE
		end

		track:AdjustSpeed(1)
	end

	task.delay(Config.STAGE1_END, function()
		if ShatterStep.Id ~= id then
			return
		end

		v:Clean()

		if track then
			track:Stop()
			track = nil
		end
	end)
	return true
end

function ShatterStep.Switch(player)
	if track then
		track:Stop()
		track = nil
	end

	if postSimulationConnection then
		postSimulationConnection:Disconnect()
		postSimulationConnection = nil
	end

	v:Clean()
	local character = player.Character
	local humanoid = character.Humanoid
	local animator = humanoid.Animator
	local humanoidRootPart = character.HumanoidRootPart
	local id = ShatterStep.Id
	local getvaluesfolder = Utility.getvaluesfolder(character)
	local shatterStepTarget = getvaluesfolder and getvaluesfolder:FindFirstChild("ShatterStepTarget")
	local value = shatterStepTarget and shatterStepTarget.Value

	-- equivalent calls inferred from this helper; original call sites unknown
	local function getAim()
		local humanoidRootPart2 = value and value:FindFirstChild("HumanoidRootPart")

		if humanoidRootPart2 then
			return humanoidRootPart2.Position
		end

		return Platform_Handler.mousepos(Config.MOUSE_RANGE)
	end

	local track2 = animator:LoadAnimation(shatterStepAir)
	v:Add(track2)
	track2:Play()
	local clone = skill_stand_still:Clone()
	clone.LinearVelocity.ForceLimitMode = Enum.ForceLimitMode.PerAxis
	clone.LinearVelocity.MaxAxesForce = createVector(1000000, 1000000, 1000000)
	clone.LinearVelocity.VectorVelocity = createVector(0, 0, 0)
	clone.Parent = humanoidRootPart
	v:Add(clone)
	local v2 = nil

	-- equivalent calls inferred from this helper; original call sites unknown
	local function writeAim(aim: Vector3)
		v2 = v2 or character:FindFirstChild(Config.POS_PART_NAME)

		if v2 then
			v2.Position = aim
			v2.bp.Position = aim
		end
	end

	local createAlignOrientationWithAttachment = Utility.CreateAlignOrientationWithAttachment
	local v4 = {
		AlignType = Enum.AlignType.PrimaryAxisParallel,
		Responsiveness = 70,
		MaxTorque = 500000,
		CFrame = 0
	}
	local safeLookAt = Utility.SafeLookAt
	local position = humanoidRootPart.Position
	local aim = getAim() -- equivalent call inferred; original call site unknown
	v4.CFrame = safeLookAt(position, aim, humanoidRootPart.CFrame)
	local alignOrientationWithAttachment, v5 = createAlignOrientationWithAttachment(
		humanoidRootPart,
		"skill_look_at",
		v4
	)
	v:Add(alignOrientationWithAttachment)
	v:Add(v5)
	local v6 = true
	v:Connect(RunService.PostSimulation, function()
		if not v6 or ShatterStep.Id ~= id then
			return
		end

		local aim2 = getAim() -- equivalent call inferred; original call site unknown
		alignOrientationWithAttachment.CFrame = Utility.SafeLookAt(
			humanoidRootPart.Position,
			Vector3.new(aim2.X, humanoidRootPart.Position.Y, aim2.Z),
			alignOrientationWithAttachment.CFrame
		)
		writeAim(aim2) -- equivalent call inferred; original call site unknown
	end)
	task.wait(0.03333333333333333)

	if ShatterStep.Id ~= id then
		return
	end

	local Y = humanoidRootPart.Position.Y
	clone.LinearVelocity.VectorVelocity = Vector3.new(0, Config.JUMP_HEIGHT / 0.3, 0)
	task.wait(0.3)

	if ShatterStep.Id ~= id then
		return
	end

	clone.LinearVelocity.VectorVelocity = createVector(0, 0, 0)
	task.wait(0.6333333333333333)

	if ShatterStep.Id ~= id then
		return
	end

	v6 = false
	local aim2 = getAim() -- equivalent call inferred; original call site unknown
	writeAim(aim2) -- equivalent call inferred; original call site unknown
	local unit = ((aim2 - humanoidRootPart.Position) * createVector(1, 0, 1)).Unit
	humanoidRootPart.CFrame = Utility.SafeLookAt(
		humanoidRootPart.Position,
		humanoidRootPart.Position + unit,
		humanoidRootPart.CFrame
	)
	local position2 = humanoidRootPart.Position
	local v7 = Y - Config.DIVE_MAX_DROP

	local function groundGoal(vector2: Vector3)
		local raycastResult = workspace:Raycast(
			Vector3.new(vector2.X, position2.Y, vector2.Z),
			createVector(0, -80, 0),
			RaycastHelper.Crater
		)
		local vector3 = (raycastResult and raycastResult.Position or vector2 - Vector3.new(0, Config.JUMP_HEIGHT, 0)) + Vector3.new(
			0,
			humanoid.HipHeight + humanoidRootPart.Size.Y / 2,
			0
		)

		if vector3.Y < v7 then
			vector3 = Vector3.new(vector3.X, v7, vector3.Z)
		end

		return vector3
	end

	local v8 = groundGoal(position2 + unit * Config.DIVE_FORWARD)
	local spherecast = workspace:Spherecast(position2, Config.DIVE_PROBE_RADIUS, v8 - position2, RaycastHelper.Crater)

	if spherecast then
		v8 = groundGoal(spherecast.Position + spherecast.Normal * Config.DIVE_WALL_OFFSET)
	end

	clone.LinearVelocity.VectorVelocity = (v8 - humanoidRootPart.Position) / 0.06666666666666667
	task.wait(0.06666666666666667)

	if ShatterStep.Id ~= id then
		return
	end

	clone.LinearVelocity.VectorVelocity = createVector(0, 0, 0)
	humanoidRootPart.AssemblyLinearVelocity = createVector(0, 0, 0)
	humanoidRootPart.AssemblyAngularVelocity = createVector(0, 0, 0)
	humanoidRootPart.CFrame = CFrame.lookAt(v8, v8 + unit)
	task.wait(0.06666666666666667)

	if ShatterStep.Id ~= id then
		return
	end

	clone:Destroy()
	alignOrientationWithAttachment:Destroy()
	v5:Destroy()
	task.wait(0.6833333333333333)

	if ShatterStep.Id ~= id then
		return
	end

	v:Clean()
end

function ShatterStep.Cancel(_)
	if postSimulationConnection then
		postSimulationConnection:Disconnect()
		postSimulationConnection = nil
	end

	v:Clean()

	if track then
		track:Stop()
		track = nil
	end
end

return ShatterStep