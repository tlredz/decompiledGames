game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Flipbook = {
	textureSets = {
		{
			"",
			"rbxassetid://123444840704562",
			"rbxassetid://137092240719651",
			"rbxassetid://117585143649558",
			"rbxassetid://105035420145374",
			"rbxassetid://136979941742696",
			"rbxassetid://127781491718949",
			"rbxassetid://74230766959453",
			"rbxassetid://114304195939199",
			"rbxassetid://140544855956347",
			"rbxassetid://135125373352719",
			"rbxassetid://73985902359002",
			"rbxassetid://74765086201315",
			"rbxassetid://112672240687968",
			"rbxassetid://122333326866019",
			"rbxassetid://102185411652914",
			"rbxassetid://99166975389104",
			"rbxassetid://111018846864456",
			"rbxassetid://75671795457707",
			"rbxassetid://70561794510668",
			"rbxassetid://98058898784869",
			"rbxassetid://106503688486559",
			"rbxassetid://137118142669135",
			"rbxassetid://105232856578345",
			""
		}
	}
}

local function loadTextures(p)
	local result = {}

	for _, texture2 in ipairs(Flipbook.textureSets[p]) do
		local texture = Instance.new("Texture")
		texture.Texture = texture2
		table.insert(result, texture)
	end

	return result
end

function Flipbook:animate(p2, p3, p4, p5, p6)
	local v = loadTextures(p4)
	local v2 = 1
	local count = #v
	local v3 = 1 / p3
	local now = tick()
	local heartbeatConnection = nil
	heartbeatConnection = RunService.Heartbeat:Connect(function()
		local now2 = tick()

		if v3 <= now2 - now then
			if p6 then
				v2 = math.random(1, count)
			end

			if p5 then
				p5.TextureId = v[v2].Texture
			else
				self.Texture = v[v2].Texture
			end

			now = now2

			if not p6 then
				if p2 then
					v2 = v2 % count + 1
					return
				end

				v2 += 1

				if count < v2 then
					heartbeatConnection:Disconnect()
				end
			end
		end
	end)
	return heartbeatConnection
end

return Flipbook