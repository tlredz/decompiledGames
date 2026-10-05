local Util = {
	ShiftRange = function(list, list2, p: number)
		return list2[1] + (list2[2] - list2[1]) / (list[2] - list[1]) * (p - list[1])
	end,
	GetAlphaValue = function(p: number, p2: number, p3: number)
		return p + (p2 - p) * p3
	end,
	TweenService = {}
}
Util.TweenService.__index = Util.TweenService
local v = {}

function Util.TweenService.new(object)
	local self = setmetatable({
		Object = object
	}, Util.TweenService)
	v[self] = {}
	return self
end

function Util.TweenService.Add(p, p2)
	table.insert(v[p], p2)
end

function Util.TweenService.Tween(p, data, items)
	local TweenService = game:GetService("TweenService")
	local v2 = {}

	for k, _ in pairs(items) do
		v2[k] = p.Object[k]
	end

	local time = data.Time
	local repeatCount = data.RepeatCount
	local delayTime = data.DelayTime
	local v3 = false
	local v4 = 0
	local v5 = {}
	local RunService = game:GetService("RunService")
	local renderSteppedConnection = RunService.RenderStepped:Connect(function(dt)
		if v3 == false then
			v4 += dt
		else
			v4 -= dt
		end

		if delayTime <= v4 or v3 then
			local v6 = (v4 - delayTime) / time

			if repeatCount <= -1 then
				v[p][v5]:Disconnect()
				v[p][v5] = nil
			else
				if v6 >= 1 then
					if data.Reverses == true then
						v3 = true
					else
						v4 = 0
						repeatCount -= 1
					end
				elseif v6 <= 0 then
					v3 = false
					v4 = 0
					repeatCount -= 1
				end

				local value = TweenService:GetValue(v6, data.EasingStyle, data.EasingDirection)

				for k, item in pairs(items) do
					if typeof(item) == "number" then
						p.Object[k] = Util.GetAlphaValue(v2[k], item, value)
					elseif typeof(item) == "UDim2" then
						local uDim = UDim2.new(
							Util.GetAlphaValue(v2[k].X.Scale, item.X.Scale, value),
							Util.GetAlphaValue(v2[k].X.Offset, item.X.Offset, value),
							Util.GetAlphaValue(v2[k].Y.Scale, item.Y.Scale, value),
							Util.GetAlphaValue(v2[k].Y.Offset, item.Y.Offset, value)
						)
						p.Object[k] = uDim
					elseif typeof(item) == "Vector2" then
						local vector = Vector2.new(
							Util.GetAlphaValue(v2[k].X, item.X, value),
							Util.GetAlphaValue(v2[k].Y, item.Y, value)
						)
						p.Object[k] = vector
					elseif typeof(item) == "Vector3" then
						local vector = Vector3.new(
							Util.GetAlphaValue(v2[k].X, item.X, value),
							Util.GetAlphaValue(v2[k].Y, item.Y, value),
							Util.GetAlphaValue(v2[k].Z, item.Z, value)
						)
						p.Object[k] = vector
					elseif typeof(item) == "Color3" then
						local color = Color3.new(
							Util.GetAlphaValue(v2[k].R, item.R, value),
							Util.GetAlphaValue(v2[k].G, item.G, value),
							Util.GetAlphaValue(v2[k].B, item.B, value)
						)
						p.Object[k] = color
					end
				end
			end
		end
	end)
	v[p][v5] = renderSteppedConnection
end

function Util.TweenService.Destroy(p)
	for _, connection in pairs(v[p]) do
		connection:Disconnect()
	end

	v[p] = nil
	setmetatable(p, nil)
end

return Util