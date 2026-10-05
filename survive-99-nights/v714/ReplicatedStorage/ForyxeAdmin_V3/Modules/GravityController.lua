local createVector = vector.create
local RunService = game:GetService("RunService")
local utility = script:WaitForChild("Utility")
local characterModules = script:WaitForChild("CharacterModules")
local Maid = require(utility:WaitForChild("Maid"))
require(utility:WaitForChild("Signal"))
local Camera = require(characterModules:WaitForChild("Camera"))
local Control = require(characterModules:WaitForChild("Control"))
local Collider = require(script:WaitForChild("Collider"))
local StateTracker = require(script:WaitForChild("StateTracker"))
local GravityController = {}
GravityController.__index = GravityController
GravityController.ClassName = "GravityController"

function GravityController.new(player)
	local object = setmetatable({}, GravityController)
	object.Player = player
	object.Character = player.Character
	object.Humanoid = player.Character:WaitForChild("Humanoid")
	object.HRP = object.Humanoid.RootPart
	object._gravityUp = createVector(0, 1, 0)
	object._characterMass = 0
	object._camera = Camera.new(object)
	object._control = Control.new(object)
	object._collider = Collider.new(object)
	object._fallStart = object.HRP.Position.y
	object._prevPart = workspace.Terrain
	object._prevCFrame = CFrame.new()
	object.StateTracker = StateTracker.new(object)
	object.Maid = Maid.new()
	init(object)
	return object
end

local function getRotationBetween(vector2, p, p2)
	local dot = vector2:Dot(p)
	local cross = vector2:Cross(p)

	if dot < -0.99999 then
		return CFrame.fromAxisAngle(p2, 3.141592653589793)
	end

	return CFrame.new(0, 0, 0, cross.x, cross.y, cross.z, 1 + dot)
end

local function getModelMass(folder)
	local total = 0

	for _, part in pairs(folder:GetDescendants()) do
		if not part:IsA("BasePart") or part.Massless then
			continue
		end

		total += part:GetMass()
	end

	return total
end

-- equivalent calls inferred from this helper; original call sites unknown
local function onJumpRequest(instance)
	if not instance.StateTracker.Jumped and instance._collider:IsGrounded(true) then
		local velocity = instance.HRP.Velocity
		instance.HRP.Velocity = velocity + instance._gravityUp * instance.Humanoid.JumpPower * 1.2
		instance.StateTracker:RequestJump()
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function onHeartbeat(state, _)
	local standingPart = state._collider:GetStandingPart()

	if standingPart and state._prevPart and state._prevPart == standingPart then
		local objectSpace = state._prevCFrame:ToObjectSpace(state.HRP.CFrame)
		state.HRP.CFrame = standingPart.CFrame * objectSpace
	end

	state._prevPart = standingPart
	state._prevCFrame = standingPart and standingPart.CFrame
end

local function onGravityStep(player, p)
	local cFrame = workspace.CurrentCamera.CFrame
	local _gravityUp = player._gravityUp
	local gravityUp = player:GetGravityUp(_gravityUp)
	local rotationBetween = getRotationBetween(_gravityUp, gravityUp, cFrame.XVector)
	player._gravityUp = CFrame.new():Lerp(rotationBetween, 0.15) * _gravityUp
	local dot = cFrame.ZVector:Dot(gravityUp)
	local vector2 = -(math.abs(dot) > 0.5 and math.sign(dot) * cFrame.YVector or -cFrame.ZVector):Cross(gravityUp).Unit
	local v = -vector2:Cross(gravityUp).Unit
	local moveVector = player._control:GetMoveVector()
	local v2 = v * moveVector.z - vector2 * moveVector.x
	local magnitude = v2.Magnitude
	local flag

	if magnitude > 0 then
		v2 /= magnitude
		flag = true
	else
		flag = false
	end

	local vector3 = -player.HRP.CFrame.ZVector
	local vector4 = vector3:Dot(v) * v + vector3:Dot(vector2) * vector2
	local unit = vector4:Cross(gravityUp).Unit
	local cframe = CFrame.new()
	local cframe2 = CFrame.fromMatrix(createVector(0, 0, 0), unit, gravityUp, -vector4)

	if flag then
		cframe = cframe:Lerp(getRotationBetween(vector4, v2, gravityUp), 0.7)
	end

	local v3 = workspace.Gravity * player._characterMass * (createVector(0, 1, 0) - gravityUp)
	local velocity = player.HRP.Velocity
	local v4 = player.Humanoid.WalkSpeed * v2
	local vector5 = velocity - velocity:Dot(gravityUp) * gravityUp
	local v5 = v4 - (vector5:Dot(vector5) < 1 and createVector(0, 0, 0) or vector5)
	local magnitude2 = v5.Magnitude
	local v6 = math.min(10000, 66.66666666666667 * player._characterMass * magnitude2 / (p * 60))
	local v7 = v6 > 0 and v5 / magnitude2 * v6 or createVector(0, 0, 0)
	local v8 = cframe * cframe2
	player.StateTracker:Update(player._gravityUp, player._collider:IsGrounded(false), flag)
	player._collider:Update(v7 + v3, v8)
end

function init(player)
	player.Maid:Mark(player._camera)
	player.Maid:Mark(player._control)
	player.Maid:Mark(player._collider)
	player._characterMass = getModelMass(player.Character)
	player.Maid:Mark(player.Character.AncestryChanged:Connect(function()
		player._characterMass = getModelMass(player.Character)
	end))
	player.Humanoid.PlatformStand = true
	player.Maid:Mark(player.Humanoid:GetPropertyChangedSignal("Jump"):Connect(function()
		if player.Humanoid.Jump then
			onJumpRequest(player) -- equivalent call inferred; original call site unknown
			player.Humanoid.Jump = false
		end
	end))
	player.Maid:Mark(player.StateTracker.Changed:Connect(function(p, _)
		if p == Enum.HumanoidStateType.Freefall then
			player._fallStart = player.HRP.Position:Dot(player._gravityUp)
		end
	end))
	player.Maid:Mark(RunService.Heartbeat:Connect(function(_)
		onHeartbeat(player) -- equivalent call inferred; original call site unknown
	end))
	RunService:BindToRenderStep("GravityStep", Enum.RenderPriority.Camera.Value - 1, function(p)
		onGravityStep(player, p)
	end)
	player.Humanoid.StateChanged:Wait()
	player.StateTracker.Changed:Fire(player.StateTracker.State, 0)
end

function GravityController:ResetGravity(gravityUp)
	self._gravityUp = gravityUp
	self._fallStart = self.HRP.Position:Dot(gravityUp)
end

function GravityController:GetFallHeight()
	if self.StateTracker.State == Enum.HumanoidStateType.Freefall then
		return self.HRP.Position:Dot(self._gravityUp) - self._fallStart
	end

	return 0
end

function GravityController:GetGravityUp(p)
	return p
end

function GravityController.Destroy(instance)
	RunService:UnbindFromRenderStep("GravityStep")
	instance.Maid:Sweep()
	instance.Humanoid.PlatformStand = false
end

return GravityController