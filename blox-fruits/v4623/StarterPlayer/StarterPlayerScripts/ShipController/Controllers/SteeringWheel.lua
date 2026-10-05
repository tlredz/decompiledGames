local SteeringWheel = {}
SteeringWheel.__index = SteeringWheel
local Util = require(game.ReplicatedStorage:WaitForChild("Util"))

function SteeringWheel:update(_: number, p: number, p2: number, p3: number)
	if self.c1 then
		local v = math.clamp((-p + p2) * 90, -90, 90)
		local C1 = self.c1 * CFrame.Angles(0, 0, (math.rad(v))) * self.steerWeld.C0.Rotation
		self.steerWeld.C1 = C1

		if self.leftSteer and self.rightSteer then
			if p3 > 0.01 and p < 0.9 then
				if self.steerState ~= 1 then
					self.steerState = 1
					self.rightSteer:Play(0.4)
					self.leftSteer:Stop(0.4)
				end
			elseif p3 < -0.01 and p > -0.9 then
				if self.steerState ~= -1 then
					self.steerState = -1
					self.rightSteer:Stop(0.4)
					self.leftSteer:Play(0.4)
				end
			elseif self.steerState ~= 0 then
				self.steerState = 0
				self.rightSteer:Stop(0.4)
				self.leftSteer:Stop(0.4)
			end
		end
	end
end

local function setAnimations(p, p2)
	if not p2 or not p or p.Owner ~= game.Players.LocalPlayer then
		return
	end

	local steerIdle = Util.Anims:Get(p.Owner.Character, "SteerIdle")
	steerIdle:Play()
	return steerIdle, Util.Anims:Get(p.Owner.Character, "SteerLeft"), (Util.Anims:Get(p.Owner.Character, "SteerRight"))
end

function SteeringWheel:refresh(options)
	for k, v in pairs(options or {}) do
		self[k] = v
	end

	local steerIdle, leftSteer, rightSteer = setAnimations(self, self.steerWeld)
	self.steerIdle = steerIdle
	self.leftSteer = leftSteer
	self.rightSteer = rightSteer
end

function SteeringWheel.register(instance, p)
	local steeringWheelWeld = instance:FindFirstChildOfClass("VehicleSeat") and instance:FindFirstChild(
		"SteeringWheelWeld",
		true
	)
	local steerIdle, leftSteer, rightSteer = setAnimations(p, steeringWheelWeld)
	return (setmetatable({
		c1 = steeringWheelWeld and CFrame.new(steeringWheelWeld.C1.Position),
		steerWeld = steeringWheelWeld,
		steerIdle = steerIdle,
		leftSteer = leftSteer,
		rightSteer = rightSteer,
		steerState = 0
	}, SteeringWheel))
end

function SteeringWheel:unregister()
	if self.steerIdle then
		self.steerIdle:Stop()
		self.steerIdle = nil
	end

	if self.leftSteer then
		self.leftSteer:Stop()
		self.leftSteer = nil
	end

	if self.rightSteer then
		self.rightSteer:Stop()
		self.rightSteer = nil
	end

	self.steerState = 0
end

return SteeringWheel