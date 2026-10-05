return {
	Clearance = 1,
	Keys = {
		{
			Type = "Players",
			Required = true
		},
		{
			Type = "Amount",
			Name = "Amount",
			Required = true,
			Completer = function(p: string)
				return (tonumber(p))
			end
		}
	},
	Server = function(_, list, p)
		local v = tonumber(p)

		if v == nil or v <= 0 then
			return
		end

		for _, v2 in ipairs(list) do
			local character = v2.Character
			local humanoid

			if character ~= nil then
				humanoid = character:FindFirstChild("Humanoid") or nil
			end

			if humanoid ~= nil and humanoid.Health > 0 then
				humanoid:TakeDamage((math.min(v, humanoid.Health)))
			end
		end
	end
}