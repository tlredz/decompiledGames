local RenderDistance = require(game.ReplicatedStorage.Util.RenderDistance)
local Weather = require(script:FindFirstAncestor("Weather"))
require(game.ReplicatedStorage.Controllers.WeatherController.Types)
local object = setmetatable({}, Weather)
object.__index = object

function object.new(p)
	return (setmetatable(Weather.new(p), object))
end

function object:_Instanciate(value)
	if not self._enabled then
		return
	end

	local v = {}
	local v2 = typeof(value) == "Instance" and value or nil
	local v3 = not v2

	if v3 then
		if typeof(value) == "table" then
			v3 = value
		else
			v3 = false
		end
	end

	if v3 then
		for i = #v3, 1, -1 do
			table.insert(v, v3[i])
		end
	elseif v2 then
		for _, child in pairs(v2:GetChildren()) do
			table.insert(v, (child:GetAttributes()))
		end
	end

	for i = 1, #v do
		local v4 = v[i]
		local _ = v4.TopPosition
		local bottomPosition = v4.BottomPosition
		local vector = Vector3.new(bottomPosition.X, workspace.CurrentCamera.CFrame.y, bottomPosition.Z)
		local value2 = RenderDistance.value(vector)

		if value2 > 300 then
			local worldToViewportPoint, v5 = workspace.CurrentCamera:WorldToViewportPoint(v4.BottomPosition)

			if not (v5 and worldToViewportPoint.Z > 0) then
				continue
			end
		end

		task.spawn(function()
			local Default = require(script.Default)
			Default(v4, value2)
		end)
	end
end

return object