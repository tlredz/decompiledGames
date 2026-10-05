require(script:FindFirstAncestor("WeatherController"))
local Weather = require(script:FindFirstAncestor("Weather"))
require(game.ReplicatedStorage.Controllers.WeatherController.Types)
local object = setmetatable({}, Weather)
object.__index = object
local v = {}
local renderSteppedConnection = nil

function object.new(p)
	local self = setmetatable(Weather.new(p), object)
	self._tornados = {}
	return self
end

function object:_Start()
	for _, _tornado in pairs(self._tornados) do
		_tornado:Spawn()
	end
end

function object:_Stop()
	for _, scope in pairs(self._tornados) do
		scope:Tween(0, 0.25)
	end
end

function object:_Cleanup()
	for _, _tornado in pairs(self._tornados) do
		_tornado:Destroy()
	end

	return nil
end

function object:_Instanciate(instance)
	local clone = game.ReplicatedStorage.Assets.Models.Tornados[instance.Name]:Clone()
	local ModuleScript = require(clone:FindFirstChildOfClass("ModuleScript"))
	self._tornados[clone] = ModuleScript

	function ModuleScript.Spawn(p2, value, p3)
		if not self._enabled or p2._Destroyed then
			return false
		end

		clone.Parent = p3 or workspace.SeaEvents
		v[clone] = instance
		ModuleScript:Tween(1, value or 0.5)
	end

	instance.AncestryChanged:Connect(function(_, parent)
		if not parent then
			ModuleScript:Destroy()
		end
	end)
	clone.AncestryChanged:Connect(function(_, parent)
		if not parent then
			v[clone] = nil
			self._tornados[clone] = nil
			ModuleScript:Destroy()
		end
	end)
	clone:PivotTo(instance:GetPivot())

	if not renderSteppedConnection then
		local RunService = game:GetService("RunService")
		renderSteppedConnection = RunService.RenderStepped:Connect(function(dt)
			if next(v) then
				for k, v2 in pairs(v) do
					k:PivotTo((k:GetPivot():Lerp(v2:GetPivot(), dt)))
				end
			elseif renderSteppedConnection then
				renderSteppedConnection:Disconnect()
				renderSteppedConnection = nil
			end
		end)
	end

	return ModuleScript
end

return object