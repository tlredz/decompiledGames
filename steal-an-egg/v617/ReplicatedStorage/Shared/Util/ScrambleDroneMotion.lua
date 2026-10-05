local HttpService = game:GetService("HttpService")
local ScrambleMotion = require(script.Parent.ScrambleMotion)
local v = {
	DeathFadeSeconds = 0.6,
	Pose = function(data, data2, p: number)
		if not data then
			return ScrambleMotion.Pose(data2, p)
		end

		if data.Name == "Death" then
			return data.From
		end

		local v2 = math.clamp((p - data.At) / math.max(data.Duration, 0.001), 0, 1)

		if data.Name == "Knockback" then
			v2 = v2 * v2 * (3 - v2 * 2)
		end

		local lerped = data.From:Lerp(data.To, v2)

		if data.Name ~= "Death" then
			lerped += Vector3.new(0, math.sin((p - data2.StartedAt) * 2.1 + data2.Phase) * data2.Bob, 0)
		end

		return lerped
	end,
	Encode = function(data)
		return HttpService:JSONEncode({
			data.Name,
			data.At,
			data.Duration,
			{ data.From:GetComponents() },
			{ data.To:GetComponents() },
			data.AnimationAt
		})
	end,
	Decode = function(value)
		if type(value) ~= "string" then
			return nil
		end

		local success, result = pcall(HttpService.JSONDecode, HttpService, value)

		if success and type(result) == "table" and #result == 6 then
			return {
				Name = result[1],
				At = result[2],
				Duration = result[3],
				From = CFrame.new(table.unpack(result[4])),
				To = CFrame.new(table.unpack(result[5])),
				AnimationAt = result[6]
			}
		end

		return nil
	end
}

function v.Read(instance)
	return v.Decode(instance:GetAttribute("DroneMotion"))
end

return table.freeze(v)