local DebugOptions = {
	set = function(p, p2)
		script:SetAttribute(p, p2)
	end,
	get = function(attributeName)
		return script:GetAttribute(attributeName)
	end
}

for k, v in pairs({}) do
	DebugOptions.set(k, v)
end

task.defer(function()
	while true do
		local Global = require(game.ReplicatedStorage.Global)

		if Global.addAdminCommand then
			break
		end

		task.wait()
	end

	local Global = require(game.ReplicatedStorage.Global)
	Global.addAdminCommand("dbg", {
		"/dbg",
		{ "/string", "/string" },
		4,
		function(_, value: string)
			local v = string.split(value, " ")
			print(v)
			local v2 = v[1]
			local v3 = v[2]

			if v3 == "true" then
				v3 = true
			elseif v3 == "false" then
				v3 = false
			elseif tonumber(v3) ~= nil then
				v3 = tonumber(v3)
			end

			DebugOptions.set(v2, v3)
			print("set", v2, v3)
		end
	}, false)
end)
return DebugOptions