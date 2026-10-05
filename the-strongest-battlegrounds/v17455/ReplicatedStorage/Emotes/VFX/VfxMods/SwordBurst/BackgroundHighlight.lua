game:GetService("ReplicatedStorage")
game:GetService("Debris")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
game:GetService("Players")
local StarterGui = game:GetService("StarterGui")

function checkProperty(p, p2)
	local _ = p[p2]
end

return function(options)
	local v = options or {}
	local speed = v.Speed or 0.25
	local color = v.Color or Color3.fromRGB(255, 255, 255)
	local color2 = v.Color2 or Color3.fromRGB(0, 0, 0)
	local imageTransparency = v.ImageTransparency or 0.2
	local brightness = v.Brightness or 0.3
	local whitelist = v.Whitelist
	local cFrames = v.CFrames or nil
	local v2 = {
		"Model",
		"LocalScript",
		"Script",
		"Sound"
	}
	local v3 = { "Katana" }

	if not whitelist then
		return
	end

	local v4 = {}
	local flag = false

	local function cleanup()
		if flag then
			return
		end

		flag = true

		for _, callback in ipairs(v4) do
			pcall(callback)
		end

		table.clear(v4)
	end

	local clone = script.BackgroundHighlight:Clone()
	table.insert(v4, function()
		clone:Destroy()
	end)
	local viewportFrame = clone.ViewportFrame
	viewportFrame.BackgroundColor3 = v.Color or Color3.fromRGB(0, 0, 0)
	local moyai = viewportFrame.WorldModel.Moyai
	clone.Parent = StarterGui
	viewportFrame.CurrentCamera = workspace.CurrentCamera
	local lastTime = os.clock()
	task.spawn(function()
		local function sp()
			local function addEntityV2(instance)
				local model = Instance.new("Model")
				model.Parent = moyai

				local function clonePart(handle)
					if table.find(v2, handle.ClassName) or handle.Name == "VISUALRADAR0" then
						return
					end

					local clone2 = handle:Clone()
					clone2.Parent = model

					if clone2:IsA("Humanoid") then
						clone2.DisplayDistanceType = "None"
						clone2.HealthDisplayType = "AlwaysOff"
					end

					for _, child in pairs(clone2:GetChildren()) do
						if not (child:IsA("Motor6D") or child:IsA("Weld") or child:IsA("Sound")) then
							continue
						end

						child:Destroy()
					end

					if clone2:IsA("Accessory") then
						clone2 = clone2:FindFirstChild("handle") or clone2:FindFirstChild("Handle")
						handle = handle:FindFirstChild("handle") or handle:FindFirstChild("Handle")
					end

					local renderSteppedConnection = nil

					local function UpdateCFrame()
						if handle and handle:IsDescendantOf(game) then
							local v5 = os.clock() - lastTime

							if not (speed + speed <= v5) then
								clone2.CFrame = handle.CFrame
								return
							end

							if not renderSteppedConnection then
								return
							end

							renderSteppedConnection:Disconnect()
						else
							if not renderSteppedConnection then
								return
							end

							renderSteppedConnection:Disconnect()
						end
					end

					if clone2:IsA("BasePart") then
						clone2.Anchored = true
					end

					if pcall(function()
						checkProperty(clone2, "Position")
					end) and not cFrames then
						renderSteppedConnection = RunService.RenderStepped:Connect(UpdateCFrame)
						table.insert(v4, function()
							if renderSteppedConnection then
								renderSteppedConnection:Disconnect()
							end
						end)
					end
				end

				if table.find(v3, instance.Name) then
					clonePart(instance)
				end

				for _, child in pairs(instance:GetChildren()) do
					clonePart(child)
				end
			end

			for i = 1, #whitelist do
				addEntityV2(whitelist[i])
			end
		end

		viewportFrame.BackgroundTransparency = brightness
		viewportFrame.ImageTransparency = imageTransparency
		viewportFrame.ImageColor3 = color
		task.spawn(sp)
		TweenService:Create(viewportFrame, TweenInfo.new(speed, Enum.EasingStyle.Linear), {
			ImageColor3 = color2
		}):Play()
		TweenService:Create(viewportFrame, TweenInfo.new(speed, Enum.EasingStyle.Linear), {
			BackgroundTransparency = 1,
			ImageTransparency = 1
		}):Play()
		task.wait(speed)
		cleanup()
	end)
end