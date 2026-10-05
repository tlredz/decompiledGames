local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
require(ReplicatedStorage.Modules.Utility)
local ReplicatedController = require(Players.LocalPlayer.PlayerScripts.Modules.ReplicatedController)
local object = setmetatable({}, ReplicatedController)
object.__index = object

function object._new()
	local self = setmetatable(ReplicatedController.new("Enemy"), object)
	self._model_to_enemy = {}
	self:_Init()
	return self
end

function object:GetEnemy(p2)
	local v = self._model_to_enemy[p2]

	if v then
		return v
	end

	for _, object2 in pairs(self.Objects) do
		if object2.Model == p2 then
			return object2
		end
	end
end

function object:Update(p2)
	for _, object2 in pairs(self.Objects) do
		if object2.Update then
			object2:Update(p2)
		end
	end
end

function object:_EnemyAdded(p2)
	if p2.Model then
		self._model_to_enemy[p2.Model] = p2
	end
end

function object:_Init()
	self.ObjectAdded:Connect(function(p)
		self:_EnemyAdded(p)
	end)
	self.ObjectRemoved:Connect(function(p)
		for k, v in pairs(self._model_to_enemy) do
			if v == p then
				self._model_to_enemy[k] = nil
			end
		end
	end)
	RunService:BindToRenderStep("EnemyController", Enum.RenderPriority.Camera.Value + 1, function(p)
		self:Update(p)
	end)

	for _, object3 in pairs(self.Objects) do
		self:_EnemyAdded(object3)
	end
end

return object._new()