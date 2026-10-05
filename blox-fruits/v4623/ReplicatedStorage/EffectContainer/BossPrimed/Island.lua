local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local function ramp(p: number, p2: number, p3: number)
	return (math.clamp(1 - (p - p2) / (p3 - p2), 0, 1))
end

local function localRoot()
	local localPlayer = Players.LocalPlayer
	local character = localPlayer and localPlayer.Character
	local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart and humanoidRootPart:IsA("BasePart") then
		return humanoidRootPart
	end

	return nil
end

local function getWindLines()
	local localPlayer = Players.LocalPlayer
	local playerScripts = localPlayer and localPlayer:FindFirstChild("PlayerScripts")
	local waterCFrame = playerScripts and playerScripts:FindFirstChild("WaterCFrame")
	local wind = waterCFrame and waterCFrame:FindFirstChild("Wind")
	local windLines = wind and wind:FindFirstChild("WindLines")

	if not (windLines and windLines:IsA("ModuleScript")) then
		return nil
	end

	local success, result = pcall(require, windLines)

	if success and type(result) == "table" then
		return result
	end

	return nil
end

return function(data)
	if not data then
		return
	end

	local remove = data.Remove == true
	local handoff = data.Handoff == true
	local v = os.clock() + (data.Duration or 5)
	local bossPrimedIsland = Lighting:FindFirstChild("BossPrimedIsland")

	if bossPrimedIsland then
		if handoff then
			bossPrimedIsland:SetAttribute("Handoff", os.clock() + 3.2)
			bossPrimedIsland:SetAttribute("Until", os.clock() + 3.2 + 1)
		else
			bossPrimedIsland:SetAttribute("Until", remove and 0 or v)
			local root = bossPrimedIsland:FindFirstChild("Root")

			if not remove and root and root:IsA("ObjectValue") and typeof(data.Root) == "Instance" then
				root.Value = data.Root
			end
		end
	else
		if remove or handoff then
			return
		end

		local root = data.Root

		if typeof(root) ~= "Instance" or not root:IsA("BasePart") then
			return
		end

		local color

		if typeof(data.Color) == "Color3" then
			color = data.Color
		else
			color = Color3.fromRGB(255, 200, 60)
		end

		local folder = Instance.new("Folder")
		folder.Name = "BossPrimedIsland"
		folder:SetAttribute("Until", v)
		local objectValue = Instance.new("ObjectValue")
		objectValue.Name = "Root"
		objectValue.Value = root
		objectValue.Parent = folder
		local colorCorrectionEffect = Instance.new("ColorCorrectionEffect")
		colorCorrectionEffect.Name = "Tint"
		colorCorrectionEffect.Saturation = 0
		colorCorrectionEffect.TintColor = Color3.new(1, 1, 1)
		colorCorrectionEffect.Parent = folder
		folder.Parent = Lighting
		local windLines = getWindLines()
		local v2 = 0
		local lerped = Color3.new(1, 1, 1):Lerp(color, 0.55)
		task.spawn(function()
			local v3 = false
			local total = 0

			while true do
				local v4 = RunService.Heartbeat:Wait()

				if not folder.Parent then
					break
				end

				local now = os.clock()
				local attribute = folder:GetAttribute("Until")
				local handoff2 = folder:GetAttribute("Handoff")

				if typeof(handoff2) ~= "number" then
					handoff2 = nil
				end

				local v5 = handoff2 ~= nil
				v3 = (typeof(attribute) ~= "number" or attribute <= now or handoff2 and handoff2 <= now) and true or v3
				local currentCamera = workspace.CurrentCamera
				local value = objectValue.Value
				local localPlayer = Players.LocalPlayer
				local character = localPlayer and localPlayer.Character
				local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

				if not (humanoidRootPart and humanoidRootPart:IsA("BasePart")) then
					humanoidRootPart = nil
				end

				local v7 = not (v3 or v5) and 1 or 0

				if v7 > 0 and humanoidRootPart and currentCamera and typeof(value) == "Instance" and value:IsA("BasePart") and value.Parent then
					local magnitude = (value.Position - humanoidRootPart.Position).Magnitude

					if windLines and windLines.UpdateConnection then
						local v8 = value.Position - currentCamera.CFrame.Position

						if v8.Magnitude > 1 then
							local v9 = math.clamp(1 - (magnitude - 70) / 630, 0, 1) * 0.65 + 0.35
							v2 += v4 * 30 * v9
							local count = 0

							while v2 >= 1 and count < 6 do
								v2 -= 1
								count += 1
								local v10 = v8
								pcall(function()
									windLines:Create({
										Direction = v10.Unit,
										Speed = 34,
										Lifetime = 1.1
									})
									local updateQueue = windLines.UpdateQueue
									local v11 = updateQueue and updateQueue[#updateQueue]

									if v11 and v11.Trail then
										v11.Trail.Color = ColorSequence.new(lerped)
									end
								end)
							end

							if v2 > 6 then
								v2 = 6
							end
						end
					end
				end

				if v3 then
					v7 = 0
				elseif v5 then
					v7 = total
				end

				local v8 = total < v7 and 1.4 or 2.2
				total += (v7 - total) * math.min(v4 * v8, 1)
				colorCorrectionEffect.Saturation = total * -0.35
				colorCorrectionEffect.TintColor = Color3.new(1, 1, 1):Lerp(color, total * 0.1)

				if v3 and total < 0.01 then
					break
				end
			end

			if folder.Parent then
				folder:Destroy()
			end
		end)
	end
end