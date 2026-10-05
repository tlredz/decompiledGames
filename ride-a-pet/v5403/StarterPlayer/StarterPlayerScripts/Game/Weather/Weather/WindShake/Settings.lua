local createVector = vector.create
local _ = {
	WindPower = "number",
	WindSpeed = "number",
	WindDirection = "Vector3",
	PivotOffset = "CFrame"
}
return {
	new = function(part)
		local v = {}
		local windPower = part:GetAttribute("WindPower")
		local windSpeed = part:GetAttribute("WindSpeed")
		local windDirection = part:GetAttribute("WindDirection")
		local windPower2

		if typeof(windPower) == "number" then
			windPower2 = windPower
		end

		v.WindPower = windPower2
		local windSpeed2

		if typeof(windSpeed) == "number" then
			windSpeed2 = windSpeed
		end

		v.WindSpeed = windSpeed2
		local windDirection2

		if typeof(windDirection) == "Vector3" then
			windDirection2 = not (windDirection.Magnitude > 0) and createVector(0, 0, 0) or windDirection.Unit
		end

		v.WindDirection = windDirection2
		local pivotOffset

		if part:IsA("BasePart") then
			pivotOffset = part.PivotOffset
		end

		v.PivotOffset = pivotOffset
		local pivotOffsetInverse

		if typeof(v.PivotOffset) == "CFrame" then
			pivotOffsetInverse = v.PivotOffset:Inverse()
		end

		v.PivotOffsetInverse = pivotOffsetInverse
		local windPowerChangedConnection = part:GetAttributeChangedSignal("WindPower"):Connect(function()
			windPower = part:GetAttribute("WindPower")
			local v7 = v
			local windPower3

			if typeof(windPower) == "number" then
				windPower3 = windPower
			end

			v7.WindPower = windPower3
		end)
		local windSpeedChangedConnection = part:GetAttributeChangedSignal("WindSpeed"):Connect(function()
			windSpeed = part:GetAttribute("WindSpeed")
			local v7 = v
			local windSpeed3

			if typeof(windSpeed) == "number" then
				windSpeed3 = windSpeed
			end

			v7.WindSpeed = windSpeed3
		end)
		local windDirectionChangedConnection = part:GetAttributeChangedSignal("WindDirection"):Connect(function()
			windDirection = part:GetAttribute("WindDirection")
			local v7 = v
			local windDirection3

			if typeof(windDirection) == "Vector3" then
				windDirection3 = not (windDirection.Magnitude > 0) and createVector(0, 0, 0) or windDirection.Unit
			end

			v7.WindDirection = windDirection3
		end)
		local pivotOffsetChangedConnection

		if part:IsA("BasePart") then
			pivotOffsetChangedConnection = part:GetPropertyChangedSignal("PivotOffset"):Connect(function()
				v.PivotOffset = part.PivotOffset
				v.PivotOffsetInverse = v.PivotOffset:Inverse()
			end)
		else
			pivotOffsetChangedConnection = nil
		end

		function v.Destroy(_)
			windPowerChangedConnection:Disconnect()
			windSpeedChangedConnection:Disconnect()
			windDirectionChangedConnection:Disconnect()

			if pivotOffsetChangedConnection then
				pivotOffsetChangedConnection:Disconnect()
			end

			table.clear(v)
		end

		return v
	end
}