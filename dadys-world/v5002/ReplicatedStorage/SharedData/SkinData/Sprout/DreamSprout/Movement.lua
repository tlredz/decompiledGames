local TweenService = game:GetService("TweenService")
return {
	parabola = function(p, vector: Vector3, vector2: Vector3, p2: number, p3: number, duration: number)
		local v = {
			p,
			vector,
			vector2,
			p2,
			p3,
			duration
		}

		for i = 1, #v do
			assert(v[i], "Err: Missing argument " .. i)
		end

		local vector3 = Vector3.new(vector2.Position.X, 0, vector2.Position.Z)
		local vector4 = Vector3.new(vector.X, 0, vector.Z)
		local Y = vector2.Position.Y
		local Y2 = vector.Y
		local v2 = p3 * math.sin((math.rad(p2)))
		local v3 = Y2 * 19.6
		local v4 = (math.sqrt(v3 - 19.6 * Y + v2 ^ 2) + v2) / 9.8
		local v5 = (vector3 - vector4) / v4
		local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Linear)
		local numberValue = Instance.new("NumberValue", script)
		local tween = TweenService:Create(numberValue, tweenInfo, {
			Value = v4
		})
		local v6 = true
		local completedConnection = nil
		tween:Play()
		completedConnection = tween.Completed:Connect(function()
			completedConnection:Disconnect()
			v6 = false
		end)

		while task.wait() and v6 do
			local value = numberValue.Value
			local vector5 = Vector3.new(vector2.Position.X, 0, vector2.Position.Z)
			vector4 = Vector3.new(vector.X, 0, vector.Z)
			local Y3 = vector2.Position.Y
			Y2 = vector.Y
			v2 = p3 * math.sin((math.rad(p2)))
			local v7 = Y2 * 19.6
			local v8 = (math.sqrt(v7 - 19.6 * Y3 + v2 ^ 2) + v2) / 9.8
			v5 = (vector5 - vector4) / v8
			local v9 = vector4 + v5 * value
			local v11 = Y2 + v2 * value - 4.9 * value ^ 2
			local vector6 = Vector3.new(v9.X, v11, v9.Z)
			local v12 = value + 0.1
			local v13 = vector4 + v5 * v12
			local v15 = Y2 + v2 * v12 - 4.9 * v12 ^ 2
			p.CFrame = CFrame.new(vector6, (Vector3.new(v13.X, v15, v13.Z)))
		end

		numberValue:Destroy()
	end
}