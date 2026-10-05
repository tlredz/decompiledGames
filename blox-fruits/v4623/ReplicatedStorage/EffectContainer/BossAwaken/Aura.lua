local RunService = game:GetService("RunService")
local color = Color3.fromRGB(255, 200, 60)
return function(data)
	local target = data.Target

	if typeof(target) ~= "Instance" or not (target:IsA("Model") or target:IsA("BasePart")) then
		return
	end

	local duration = data.Duration or 3
	local v = os.clock() + duration
	local bossAwakenAura = target:FindFirstChild("BossAwakenAura")

	if bossAwakenAura then
		bossAwakenAura:SetAttribute("Until", data.Remove and 0 or v)
		return
	end

	if data.Remove then
		return
	end

	local color2

	if typeof(data.Color) == "Color3" then
		color2 = data.Color
	else
		color2 = color
	end

	local folder = Instance.new("Folder")
	folder.Name = "BossAwakenAura"
	folder:SetAttribute("Until", v)
	folder.Parent = target
	local highlight = Instance.new("Highlight")
	highlight.FillColor = color2
	highlight.OutlineColor = color2
	highlight.FillTransparency = 1
	highlight.OutlineTransparency = 1
	highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
	highlight.Adornee = target
	highlight.Parent = folder
	local primaryPart

	if target:IsA("BasePart") then
		primaryPart = target
	else
		primaryPart = target.PrimaryPart
	end

	local pointLight

	if primaryPart then
		pointLight = Instance.new("PointLight")
		pointLight.Name = "BossAwakenAura"
		pointLight.Color = color2
		pointLight.Range = 14
		pointLight.Brightness = 0
		pointLight.Parent = primaryPart
	else
		pointLight = nil
	end

	task.spawn(function()
		local now = os.clock()

		while folder.Parent and target.Parent do
			local now2 = os.clock()
			local attribute = folder:GetAttribute("Until")

			if typeof(attribute) ~= "number" or attribute <= now2 then
				break
			end

			local v2 = math.clamp((now2 - now) / 0.4, 0, 1)
			local v3 = (math.sin(now2 * 2.4) + 1) * 0.5
			highlight.FillTransparency = 1 - (1 - (0.7 - v3 * 0.44999999999999996)) * v2
			highlight.OutlineTransparency = 1 - v2

			if pointLight then
				pointLight.Brightness = (v3 * 2 + 1.2) * v2
			end

			RunService.Heartbeat:Wait()
		end

		if folder.Parent then
			local lastTime = os.clock()

			while os.clock() - lastTime < 0.4 and folder.Parent do
				local v2 = 1 - (os.clock() - lastTime) / 0.4
				highlight.FillTransparency = 1 - 0.30000000000000004 * v2
				highlight.OutlineTransparency = 1 - v2

				if pointLight then
					pointLight.Brightness = 1.2 * v2
				end

				RunService.Heartbeat:Wait()
			end

			if pointLight then
				pointLight:Destroy()
			end

			folder:Destroy()
		elseif pointLight then
			pointLight:Destroy()
		end
	end)
end