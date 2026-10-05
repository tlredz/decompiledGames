local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local GingerMeterController = require(ReplicatedStorage.Modules.ClientUI.GingerMeterController)
local TowerLUT = require(ReplicatedStorage.SharedUtils.TowerLUT)
local tower = TowerLUT:GetTower("Ginger")
local module = require(tower)
local HealTargetController = {}
local flag = false
local v = nil
local connections = {}
local v2 = nil
local heartbeatConnection = nil
local v3 = nil
local v4 = nil
local healRange = module.HealRange

local function cancelTargetHealMeter()
	if heartbeatConnection then
		heartbeatConnection:Disconnect()
		heartbeatConnection = nil
	end

	if v3 then
		v3:Destroy()
		v3 = nil
	end

	if v4 then
		v4:Destroy()
		v4 = nil
	end

	if v2 then
		local v5 = v2
		v2 = nil
		pcall(function()
			GingerMeterController.cancel(v5)
		end)
	end
end

function HealTargetController.init(p)
	if flag then
		HealTargetController.cleanup()
	end

	v = p
	table.insert(connections, v:GetAttributeChangedSignal("BeingHealedBy"):Connect(function()
		local beingHealedBy = v:GetAttribute("BeingHealedBy")

		if beingHealedBy then
			local beingHealedDuration = v:GetAttribute("BeingHealedDuration") or 3
			cancelTargetHealMeter()
			local inGamePlayers = workspace:FindFirstChild("InGamePlayers")
			local child = inGamePlayers and inGamePlayers:FindFirstChild(beingHealedBy)
			v2 = GingerMeterController.create(v)

			if v2 and v2.billboard then
				local billboard = v2.billboard
				billboard.Size = UDim2.new(
					billboard.Size.X.Scale * 0.5,
					billboard.Size.X.Offset * 0.5,
					billboard.Size.Y.Scale * 0.5,
					billboard.Size.Y.Offset * 0.5
				)
				billboard.StudsOffset = Vector3.new(
					billboard.StudsOffset.X,
					billboard.StudsOffset.Y * 0.7,
					billboard.StudsOffset.Z
				)
				local textLabel = billboard:FindFirstChild("TextLabel")

				if textLabel then
					textLabel.Text = "HEAL INCOMING!"
				end

				local frame = Instance.new("Frame")
				frame.Name = "RangeIndicator"
				frame.Size = UDim2.new(0.8, 0, 0.08, 0)
				frame.Position = UDim2.new(0.1, 0, 0.92, 0)
				frame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
				frame.BorderSizePixel = 0
				frame.Parent = billboard
				frame.Visible = true
				local uICorner = Instance.new("UICorner")
				uICorner.CornerRadius = UDim.new(0.5, 0)
				uICorner.Parent = frame
				local frame2 = Instance.new("Frame")
				frame2.Name = "Fill"
				frame2.Size = UDim2.new(1, 0, 1, 0)
				frame2.BackgroundColor3 = Color3.fromRGB(100, 255, 100)
				frame2.BorderSizePixel = 0
				frame2.Parent = frame
				local uICorner2 = Instance.new("UICorner")
				uICorner2.CornerRadius = UDim.new(0.5, 0)
				uICorner2.Parent = frame2
				v3 = frame2
				local textLabel2 = Instance.new("TextLabel")
				textLabel2.Name = "RangeText"
				textLabel2.Size = UDim2.new(0.3, 0, 0.12, 0)
				textLabel2.Position = UDim2.new(0.35, 0, 1.02, 0)
				textLabel2.BackgroundTransparency = 1
				textLabel2.TextColor3 = Color3.fromRGB(255, 255, 255)
				textLabel2.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
				textLabel2.TextStrokeTransparency = 0.5
				textLabel2.Font = Enum.Font.GothamBold
				textLabel2.TextScaled = true
				textLabel2.Text = "20"
				textLabel2.Parent = billboard
				v4 = textLabel2
				GingerMeterController.start(v2, beingHealedDuration)

				if child then
					heartbeatConnection = RunService.Heartbeat:Connect(function()
						if v2 and child and child.Parent then
							local humanoidRootPart = v:FindFirstChild("HumanoidRootPart")
							local humanoidRootPart2 = child:FindFirstChild("HumanoidRootPart")

							if humanoidRootPart and humanoidRootPart2 then
								local magnitude = (humanoidRootPart.Position - humanoidRootPart2.Position).Magnitude
								local v5 = math.clamp(1 - magnitude / healRange, 0, 1)

								if v3 then
									v3.Size = UDim2.new(v5, 0, 1, 0)

									if v5 > 0.5 then
										v3.BackgroundColor3 = Color3.fromRGB(100, 255, 100)
									elseif v5 > 0.25 then
										v3.BackgroundColor3 = Color3.fromRGB(255, 255, 100)
									else
										v3.BackgroundColor3 = Color3.fromRGB(255, 100, 100)
									end
								end

								if v4 then
									local v6 = math.max(0, healRange - magnitude)
									v4.Text = math.floor(v6) .. ""
									v4.TextColor3 = v3 and v3.BackgroundColor3 or Color3.fromRGB(255, 255, 255)
								end
							end
						elseif heartbeatConnection then
							heartbeatConnection:Disconnect()
							heartbeatConnection = nil
						end
					end)
				end
			end
		else
			local beingHealedCancelled = v:GetAttribute("BeingHealedCancelled")

			if v2 then
				if beingHealedCancelled then
					cancelTargetHealMeter()
					return
				end

				if heartbeatConnection then
					heartbeatConnection:Disconnect()
					heartbeatConnection = nil
				end

				if v3 then
					v3:Destroy()
					v3 = nil
				end

				if v4 then
					v4:Destroy()
					v4 = nil
				end

				local v5 = v2
				v2 = nil
				task.delay(1, function()
					pcall(function()
						GingerMeterController.cancel(v5)
					end)
				end)
			end
		end
	end))
	table.insert(connections, v:GetAttributeChangedSignal("BeingHealedCancelled"):Connect(function()
		if v:GetAttribute("BeingHealedCancelled") and v2 then
			cancelTargetHealMeter()
		end
	end))
	flag = true
end

function HealTargetController.cleanup()
	cancelTargetHealMeter()

	for _, connection in ipairs(connections) do
		if typeof(connection) == "RBXScriptConnection" then
			connection:Disconnect()
		end
	end

	connections = {}
	flag = false
	v = nil
end

return HealTargetController