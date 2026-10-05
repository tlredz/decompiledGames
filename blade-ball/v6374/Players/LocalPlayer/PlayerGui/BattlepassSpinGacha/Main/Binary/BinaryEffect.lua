local RunService = game:GetService("RunService")
local layerCollector = script:FindFirstAncestorWhichIsA("LayerCollector")
local count = 0
RunService.Heartbeat:Connect(function()
	if layerCollector and not layerCollector.Enabled then
		return
	end

	count += 1

	if count % 6 ~= 0 then
		return
	end

	local v = ""

	for i = 1, 20 do
		for i2 = 1, 100 do
			local v2 = math.noise(i2 * 0.1 * 0.46, i * 0.1, os.clock() / 3)
			v ..= (v2 < -0.25 or v2 > 0.25) and " " or v2 > 0 and "1" or "0"
		end

		v ..= "\n"
	end

	script.Parent.Text = v:sub(1, -2)
end)