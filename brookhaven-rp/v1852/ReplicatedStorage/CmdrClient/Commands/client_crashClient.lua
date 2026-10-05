return {
	Name = "client_crashClient",
	Aliases = {},
	Description = "Force a crash on the client",
	Group = "Client",
	Args = {
		{
			Type = "number",
			Name = "KB",
			Description = "The amount of memory to leak to in KB"
		}
	},
	ClientRun = function(object, p: number)
		local Stats = game:GetService("Stats")
		local v = {}
		local v2 = {}

		while true do
			local v3 = {}

			for _ = 1, 1000000 do
				table.insert(v3, math.random())
			end

			if #v > 1000 then
				table.insert(v2, v)
			else
				table.insert(v, v3)
			end

			if p < gcinfo() / 1024 then
				object:Reply("Stopping at Memory usage:" .. tostring(gcinfo() / 1024) .. "MB")
				task.delay(999999999, function()
					print(#v, #v2)
				end)
				break
			else
				object:Reply("Memory usage:" .. tostring(gcinfo() / 1024) .. "MB" .. "  Total" .. Stats:GetTotalMemoryUsageMb())
				task.wait(0.1)
			end
		end
	end
}