local _ = {
	WindPower = "number",
	WindSpeed = "number",
	WindDirection = "Vector3"
}
return {
	new = function(instance, data)
		local v = table.create(3)
		local windPower = instance:GetAttribute("WindPower")
		local windSpeed = instance:GetAttribute("WindSpeed")
		local windDirection = instance:GetAttribute("WindDirection")
		v.WindPower = typeof(windPower) == "number" and windPower or data.WindPower
		v.WindSpeed = typeof(windSpeed) == "number" and windSpeed or data.WindSpeed
		v.WindDirection = typeof(windDirection) == "Vector3" and windDirection or data.WindDirection
		local windPowerChangedConnection = instance:GetAttributeChangedSignal("WindPower"):Connect(function()
			windPower = instance:GetAttribute("WindPower")
			v.WindPower = typeof(windPower) == "number" and windPower or data.WindPower
		end)
		local windSpeedChangedConnection = instance:GetAttributeChangedSignal("WindSpeed"):Connect(function()
			windSpeed = instance:GetAttribute("WindSpeed")
			v.WindSpeed = typeof(windSpeed) == "number" and windSpeed or data.WindSpeed
		end)
		local windDirectionChangedConnection = instance:GetAttributeChangedSignal("WindDirection"):Connect(function()
			windDirection = instance:GetAttribute("WindDirection")
			v.WindDirection = typeof(windDirection) == "Vector3" and windDirection or data.WindDirection
		end)

		function v.Destroy(_)
			windPowerChangedConnection:Disconnect()
			windSpeedChangedConnection:Disconnect()
			windDirectionChangedConnection:Disconnect()
			table.clear(v)
		end

		return v
	end
}