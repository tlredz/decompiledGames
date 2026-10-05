local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local QuaternionSpring = require(ReplicatedStorage.Modules.QuaternionSpring)
local Quaternion = require(ReplicatedStorage.Modules.Quaternion)
local Spring = require(ReplicatedStorage.Modules.Spring)
local SmokeCloud = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("SmokeCloud"))
local object = setmetatable({}, SmokeCloud)
object.__index = object

function object.new(...)
	local self = setmetatable(SmokeCloud.new(...), object)
	self._direction_spring = QuaternionSpring.new(Quaternion.fromCFrame(CFrame.identity), 0.75, 10)
	self._pupil_size_spring = Spring.new(0.187, 0.75, 5)
	self._next_direction_update = 0
	self._direction_update_count = 0
	self:_Init()
	return self
end

function object:Update(_)
	if self:_UpdateCoreLogic() then
		return
	end

	if tick() > self._next_direction_update then
		self._direction_update_count += 1
		local cframe

		if self._direction_update_count % 30 == 0 then
			cframe = CFrame.new(self.Part.Position, workspace.CurrentCamera.CFrame.Position)
			self._direction_spring.Speed = 10
			self._pupil_size_spring.Target = 0.3
			self._next_direction_update = tick() + 3
		else
			local unitVector = Random.new():NextUnitVector()
			cframe = CFrame.new(
				createVector(0, 0, 0),
				(Vector3.new(unitVector.X, (unitVector.Y + 1) / 2, unitVector.Z))
			)
			self._direction_spring.Speed = 10
			self._pupil_size_spring.Target = 0.187
			self._next_direction_update = tick() + 0.1
		end

		self._direction_spring.Target = Quaternion.fromCFrame(cframe)
	elseif self._direction_update_count % 30 == 0 then
		self._direction_spring.Target = Quaternion.fromCFrame(CFrame.new(
			self.Part.Position,
			workspace.CurrentCamera.CFrame.Position
		))
	end

	self.Model.Pupil.Size = Vector3.new(self._pupil_size_spring.Value, self._pupil_size_spring.Value, 0.009) * self.Model:GetScale()
	self.Model:PivotTo(CFrame.new(self.Part.Position) * self._direction_spring.Position:ToCFrame().Rotation)
end

function object:_Setup()
	self.Model.Iris.Color = Color3.fromHSV(math.random(), 1, 1)
end

function object:_Init()
	self:_Setup()
end

return object