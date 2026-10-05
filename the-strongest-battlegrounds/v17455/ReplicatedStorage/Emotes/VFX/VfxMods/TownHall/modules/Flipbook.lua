game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Flipbook = {
	textureSets = {
		{
			"rbxassetid://130629111061720",
			"rbxassetid://85918277582982",
			"rbxassetid://119607379507449",
			"rbxassetid://81774968961073",
			"rbxassetid://103220043753832",
			"rbxassetid://77226714936241",
			"rbxassetid://85340870834297",
			"rbxassetid://135457002916586",
			"rbxassetid://70918122706338",
			"rbxassetid://110100420187591",
			"rbxassetid://134755247127972",
			"rbxassetid://128126542042134",
			"rbxassetid://112164408619711",
			"rbxassetid://82296772148578",
			"rbxassetid://91070668346062",
			"rbxassetid://114112675971868",
			"rbxassetid://"
		},
		{
			"rbxassetid://105732378646255",
			"rbxassetid://89481778174251",
			"rbxassetid://117771628383659",
			"rbxassetid://76701247249895",
			"rbxassetid://91562861750532",
			"rbxassetid://105133668149667",
			"rbxassetid://99512357475594",
			"rbxassetid://113214868152279",
			"rbxassetid://99744127393588",
			"rbxassetid://80271489296785",
			"rbxassetid://129340926248442",
			"rbxassetid://113078430710440",
			"rbxassetid://121307226171896",
			"rbxassetid://91904278509969",
			"rbxassetid://90170347865413",
			"rbxassetid://115756751613614",
			"rbxassetid://95908181261933",
			"rbxassetid://80232568958811",
			"rbxassetid://135493627589161",
			"rbxassetid://132569766663606",
			"rbxassetid://103054291603173",
			"rbxassetid://120610675396334",
			"rbxassetid://97868570964111",
			"rbxassetid://128487139635172"
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

function Flipbook:animate(p2, p3, p4, p5)
	local v = loadTextures(p4)
	local v2 = 1
	local count = #v
	local v3 = 1 / p3
	local now = tick()
	local heartbeatConnection = nil
	heartbeatConnection = RunService.Heartbeat:Connect(function()
		local now2 = tick()

		if v3 <= now2 - now then
			if p5 then
				p5.TextureId = v[v2].Texture
			else
				self.Texture = v[v2].Texture
				now = now2
			end

			if p2 then
				v2 = v2 % count + 1
				return
			end

			v2 += 1

			if count < v2 then
				heartbeatConnection:Disconnect()
			end
		end
	end)
end

return Flipbook