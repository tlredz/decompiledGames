game:GetService("TweenService")
local Players = game:GetService("Players")
local WrapGroupObject = require(Players.LocalPlayer.PlayerScripts.Modules.WrapGroupObject)
local currentCamera = workspace.CurrentCamera
local v = { 0.086, 0.156, 0.128 }
local v2 = { 1, 1, 0.639 }
local object = setmetatable({}, WrapGroupObject)
object.__index = object

function object.new(...)
	local self = setmetatable(WrapGroupObject.new(...), object)
	self._color_objects = {}
	self._color_sequence_objects = {}
	self._brick_color_objects = {}
	self:_Init()
	return self
end

function object:Update(_)
	workspace:GetServerTimeNow()
	local v3 = self:_GetOffset() % 1

	for _, _color_object in pairs(self._color_objects) do
		local wrapGroup = _color_object:GetAttribute("WrapGroup") or 1
		_color_object.Color = Color3.fromHSV(v3, v[wrapGroup], v2[wrapGroup])
	end

	for _, _color_sequence_object in pairs(self._color_sequence_objects) do
		local wrapGroup = _color_sequence_object:GetAttribute("WrapGroup") or 1
		_color_sequence_object.Color = ColorSequence.new(Color3.fromHSV(v3, v[wrapGroup], v2[wrapGroup]))
	end

	for _, _brick_color_object in pairs(self._brick_color_objects) do
		local wrapGroup = _brick_color_object:GetAttribute("WrapGroup") or 1
		_brick_color_object.Color = BrickColor.new(Color3.fromHSV(v3, v[wrapGroup], v2[wrapGroup]))
	end
end

function object:_NormalizeAngle(p)
	return (math.abs(p % 6.283185307179586 / 6.283185307179586 * 2 - 1))
end

function object:_GetOffset()
	local position = currentCamera.CFrame.Position
	local eulerAnglesXYZ, v3, v4 = currentCamera.CFrame:ToEulerAnglesXYZ()
	return (position + Vector3.new(
		self:_NormalizeAngle(eulerAnglesXYZ),
		self:_NormalizeAngle(v3),
		self:_NormalizeAngle(v4)
	) * 32).Magnitude / 128
end

function object:_Evaluate(instance)
	if instance:IsA("BasePart") then
		table.insert(self._color_objects, instance)
	elseif instance:IsA("ParticleEmitter") or instance:IsA("Beam") or instance:IsA("Trail") then
		table.insert(self._color_sequence_objects, instance)
	elseif instance:IsA("RopeConstraint") or instance:IsA("RodConstraint") then
		table.insert(self._brick_color_objects, instance)
	end
end

function object:_Setup()
	self:_Evaluate(self.Object)

	for _, extraObject in self.ExtraObjects do
		self:_Evaluate(extraObject)
	end
end

function object:_Init()
	self:_Setup()
end

return object