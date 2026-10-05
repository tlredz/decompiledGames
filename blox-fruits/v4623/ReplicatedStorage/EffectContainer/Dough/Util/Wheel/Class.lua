local createVector = vector.create
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("RunService")
local Util = require(ReplicatedStorage.Util)
local _ = game.Players.LocalPlayer
local _ = workspace.CurrentCamera
local mouse = game.Players.LocalPlayer:GetMouse()
local Class = {}
Class.__index = Class

function Class.new(player, char, hrp, wheelPart, collisionPart, value, remote)
	local object = setmetatable({}, Class)
	object.wheelPart = wheelPart
	object.collisionPart = collisionPart
	object.mainJoint = object.collisionPart:WaitForChild("Motor6D", 1)

	if object.mainJoint then
		object.player = player
		object.playerModule = require(player.PlayerScripts.PlayerModule)
		object.char = char
		object.humanoid = object.char:FindFirstChildOfClass("Humanoid")
		object.hrp = hrp
		object.bv = object.wheelPart.BodyVelocity
		object.bg = object.wheelPart.BodyGyro
		object.bp = object.wheelPart.BodyPosition
		object.currentTurnSpeed = 0
		object.drifting = false
		object.initTime = tick()
		object.FadeIn = value or 1
		object.lastRemotePoll = 0
		object.remote = remote
		object.settings = {}

		for k, v in pairs(wheelPart:GetAttributes()) do
			if k ~= "Type" then
				object.settings[k] = v
			end
		end

		object.currentSpeed = 0
		object.prevTurnSpeedOnInput = 0
		object:init()
		return object
	else
		warn("Deactivated wheel early")
		object:destroy()
		return object
	end
end

function Class:init()
	if not self.mainJoint then
		return
	end

	self.bv.Velocity = self.bg.CFrame.LookVector * self.currentSpeed
	workspace.CurrentCamera.CameraSubject = self.wheelPart
end

function Class:getInputDir()
	if not self.mainJoint then
		return
	end

	if UserInputService.TouchEnabled or UserInputService.GamepadEnabled then
		return (self.playerModule:GetControls():GetMoveVector() * createVector(1, 0.01, 1)).Unit
	end

	local position = self.hrp.Position
	local unit = (self.bg.CFrame.LookVector * createVector(1, 0.01, 1)).Unit
	return ((CFrame.new(createVector(0, 0, 0), unit) + position):PointToObjectSpace(mouse.Hit.p).Unit * createVector(
		1,
		0.01,
		1
	)).Unit
end

local function nudgeInterpolate(p, p2, p3)
	if math.abs(p - p2) < 1.5 * p3 then
		return p
	end

	return p + math.sign(p2 - p) * p3
end

function Class:GetMass()
	local total = 0

	for _, part in pairs(self.mainJoint.Part0.Parent:GetDescendants()) do
		if not part:IsA("BasePart") or part.Massless then
			continue
		end

		total += part:GetMass()
	end

	return total
end

local GetWaterHeightAtLocation = require(game.ReplicatedStorage.Util.GetWaterHeightAtLocation)

function Class:physicsUpdate(p)
	if not self.mainJoint then
		return
	end

	local v = math.min(1, (tick() - self.initTime) / self.FadeIn)
	self.currentSpeed = self.settings.MaxSpeed * v
	local wheelPart = self.wheelPart
	local collisionPart = self.collisionPart
	local bv = self.bv
	local bg = self.bg
	local bp = self.bp
	local magnitude = wheelPart.Velocity.Magnitude
	local currentSpeed = self.currentSpeed
	local v2

	if v == 1 then
		v2 = magnitude < self.currentSpeed * 0.75
	else
		v2 = false
	end

	if v2 then
		bv.MaxForce = createVector(1, 1, 1) * self:GetMass() * workspace.Gravity * 25
		bv.Velocity = bv.Velocity * createVector(1, 0, 1) + createVector(0, 1, 0) * math.sqrt(currentSpeed ^ 2 - magnitude ^ 2)
	else
		bv.MaxForce = createVector(1, -0.25, 1) * self:GetMass() * workspace.Gravity * 25
		bv.Velocity = bg.CFrame.LookVector * currentSpeed
	end

	local v3 = ({ GetWaterHeightAtLocation(collisionPart.Position) })[1]
	local v4 = math.abs((math.min(0, wheelPart.Velocity.Y * 1 / 30)))

	if collisionPart.Position.Y - collisionPart.Size.Y - v4 > v3 + collisionPart.Size.Y or v2 then
		bp.MaxForce = createVector(0, 0, 0)
	else
		bp.MaxForce = createVector(0, 1, 0) * self:GetMass() * workspace.Gravity * 30
		bp.Position = createVector(-0, -1, -0) * (v3 - collisionPart.Size.Y / 2)
	end

	local inputDir = self:getInputDir()
	local currentTurnSpeed = self.currentTurnSpeed
	local v6 = inputDir.X * self.settings.MaxInputTurnPower
	local v7 = self.settings.TurnSpeedNudgeInterpolate * p

	if not (math.abs(currentTurnSpeed - v6) < 1.5 * v7) then
		currentTurnSpeed += math.sign(v6 - currentTurnSpeed) * v7
	end

	self.currentTurnSpeed = currentTurnSpeed
	self.prevTurnSpeedOnInput = self.currentTurnSpeed
	local v8 = math.abs(inputDir.X) > 0.05 or false
	local v9 = false

	if v8 == false then
		local unit = (workspace.CurrentCamera.CFrame.LookVector * createVector(1, 0.001, 1)).Unit
		local unit2 = (bv.Velocity.Unit * createVector(1, 0.001, 1)).Unit
		local v10 = unit2.Y ~= unit2.Y and createVector(0, 0, 0) or unit2
		local dot = unit:Dot(v10)
		local Y = unit:Cross(v10).Y

		if dot < 0.98 then
			local currentTurnSpeed2 = self.currentTurnSpeed
			local v11 = math.sign(Y) * self.settings.MaxCameraTurnPower
			local v12 = self.settings.TurnSpeedNudgeInterpolate * p

			if not (math.abs(currentTurnSpeed2 - v11) < 1.5 * v12) then
				currentTurnSpeed2 += math.sign(v11 - currentTurnSpeed2) * v12
			end

			self.currentTurnSpeed = currentTurnSpeed2
			self.prevTurnSpeedOnInput = self.currentTurnSpeed
			v9 = true
		end
	end

	if math.abs(self.currentTurnSpeed) > self.settings.DriftAboveTurnPower then
		self.drifting = true
	else
		self.drifting = false
	end

	if not (v8 or v9) then
		local currentTurnSpeed2 = self.currentTurnSpeed
		local v10 = self.settings.TurnSpeedNudgeInterpolate * p

		if not (math.abs(currentTurnSpeed2 - 0) < 1.5 * v10) then
			currentTurnSpeed2 += math.sign(0 - currentTurnSpeed2) * v10
		end

		self.currentTurnSpeed = currentTurnSpeed2
	end

	self.currentTurnSpeed = Util.Misc.round(self.currentTurnSpeed, 5)
	bg.CFrame *= CFrame.Angles(0, -self.settings.MaxTurnSpeed * p * self.currentTurnSpeed, 0)
end

function Class:visualsUpdate(_)
	if not self.mainJoint then
		return
	end

	local now = tick()
	local mainJoint = self.mainJoint
	local v = self.settings.MaxTiltAngle * self.currentTurnSpeed
	mainJoint.C0 = CFrame.Angles(0, -1 * self.currentTurnSpeed ^ 3, 0) * CFrame.new(
		0,
		-self.collisionPart.Size.Y * 0.5,
		0
	) * CFrame.Angles(0, 0, -v) * CFrame.new(0, self.collisionPart.Size.Y * 0.5, 0)

	if self.remote and now - self.lastRemotePoll >= 0.03333333333333333 then
		self.remote:FireServer({
			Wheel = self.collisionPart,
			Attributes = {
				CurrentTurnSpeed = self.currentTurnSpeed
			}
		})
		self.lastRemotePoll = now
	end
end

function Class:destroy()
	workspace.CurrentCamera.CameraSubject = self.humanoid
end

return Class