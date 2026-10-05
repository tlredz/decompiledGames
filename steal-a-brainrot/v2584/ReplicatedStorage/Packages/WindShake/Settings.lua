local createVector = vector.create

-- equivalent calls inferred from this helper; original call sites unknown
local function Normalize(vector2: Vector3)
	return vector2.Magnitude > 0 and vector2.Unit or createVector(0, 0, 0)
end

return {
	new = function(part)
		local v = {}
		local windPower = part:GetAttribute("WindPower")
		local windSpeed = part:GetAttribute("WindSpeed")
		local windDirection = part:GetAttribute("WindDirection")
		local windPower2

		if type(windPower) == "number" then
			windPower2 = windPower
		end

		v.WindPower = windPower2
		local windSpeed2

		if type(windSpeed) == "number" then
			windSpeed2 = windSpeed
		end

		v.WindSpeed = windSpeed2
		local unit

		if typeof(windDirection) == "Vector3" then
			unit = Normalize(windDirection)
		end

		v.WindDirection = unit
		local pivotOffset2

		if part:IsA("BasePart") then
			pivotOffset2 = part.PivotOffset
		end

		v.PivotOffset = pivotOffset2
		local pivotOffsetInverse

		if v.PivotOffset then
			pivotOffsetInverse = v.PivotOffset:Inverse()
		end

		v.PivotOffsetInverse = pivotOffsetInverse
		local v6 = {
			PowerConnection = part:GetAttributeChangedSignal("WindPower"):Connect(function()
				windPower = part:GetAttribute("WindPower")
				local v7 = v
				local windPower3

				if type(windPower) == "number" then
					windPower3 = windPower
				end

				v7.WindPower = windPower3
			end),
			SpeedConnection = part:GetAttributeChangedSignal("WindSpeed"):Connect(function()
				windSpeed = part:GetAttribute("WindSpeed")
				local v7 = v
				local windSpeed3

				if type(windSpeed) == "number" then
					windSpeed3 = windSpeed
				end

				v7.WindSpeed = windSpeed3
			end),
			DirectionConnection = part:GetAttributeChangedSignal("WindDirection"):Connect(function()
				windDirection = part:GetAttribute("WindDirection")
				local v7 = v
				local unit2

				if typeof(windDirection) == "Vector3" then
					unit2 = Normalize(windDirection)
				end

				v7.WindDirection = unit2
			end)
		}

		if part:IsA("BasePart") then
			v6.PivotConnection = part:GetPropertyChangedSignal("PivotOffset"):Connect(function()
				local pivotOffset = part.PivotOffset
				v.PivotOffset = pivotOffset
				v.PivotOffsetInverse = pivotOffset:Inverse()
			end)
		end

		function v.Destroy(_)
			for _, connection in pairs(v6) do
				connection:Disconnect()
			end
		end

		return v
	end
}