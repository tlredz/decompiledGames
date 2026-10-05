game:GetService("RunService")
local SimpleFresnel = {}
SimpleFresnel.__index = SimpleFresnel

function SimpleFresnel.new(shapes, sphereCenter: Vector3, value: number?, value2: number?, value3: number?)
	local self = setmetatable({}, SimpleFresnel)
	self.shapes = shapes
	self.sphereCenter = sphereCenter
	self.minTransparency = value or 0.1
	self.maxTransparency = value2 or 0.95
	self.power = value3 or 1
	self.connection = nil
	return self
end

function SimpleFresnel:start()
	if self.connection then
		return
	end

	self.connection = task.spawn(function()
		while task.wait(0.03333333333333333) do
			local position = workspace.CurrentCamera.CFrame.Position
			local now = os.clock()

			for _, shape in self.shapes do
				local cFrame = shape:GetCFrame()

				if cFrame.Position.Y < -10 or shape.Shaking or shape.Pulsing or shape.Solid then
					continue
				end

				local position2 = cFrame.Position
				local v = math.abs(((position2 - self.sphereCenter).Unit:Dot((position - position2).Unit)))
				local minTransparency = shape.minTransparency or self.minTransparency
				local v2 = minTransparency + ((shape.maxTransparency or self.maxTransparency) - minTransparency) * v
				local v3 = shape.OriginalCFrame.X + shape.OriginalCFrame.Y + shape.OriginalCFrame.Z
				shape:SetTransparency((math.clamp(
					v2 + (math.sin(now * 0.2 + v3) * 0.5 + 0.5 - 0.5) * 2 * 0.3 * (1 - v2),
					0,
					1
				)))
			end
		end
	end)
end

function SimpleFresnel:stop()
	if self.connection then
		task.cancel(self.connection)
		self.connection = nil
	end
end

function SimpleFresnel:updateSphereCenter(sphereCenter: Vector3)
	self.sphereCenter = sphereCenter
end

function SimpleFresnel:destroy()
	self:stop()
	self.shapes = nil
end

return SimpleFresnel