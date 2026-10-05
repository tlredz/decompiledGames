local createVector = vector.create
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local currentCamera = workspace.CurrentCamera
local DebrisModule = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("DebrisModule"))
local RaycastHelper = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("RaycastHelper"))
local Look = require(script.Look)
local modulesByName = {}

for _, moduleScript in script.Shapes:GetChildren() do
	local name = moduleScript.Name
	local module = require(moduleScript)
	modulesByName[name] = module
end

local function fade(items)
	local tweenInfo = TweenInfo.new(Look.Fade)

	for _, instance in items do
		if instance:IsA("BasePart") then
			TweenService:Create(instance, tweenInfo, {
				Transparency = 1
			}):Play()
			local selectionBox = instance:FindFirstChildOfClass("SelectionBox")

			if selectionBox ~= nil then
				TweenService:Create(selectionBox, tweenInfo, {
					Transparency = 1
				}):Play()
			end
		elseif instance:IsA("Highlight") then
			TweenService:Create(instance, tweenInfo, {
				FillTransparency = 1,
				OutlineTransparency = 1
			}):Play()
		end
	end
end

local function destroyFolder(p: string)
	local child = workspace.Debree:FindFirstChild((`{p}-Telegraph`))

	if child and child.Parent then
		child:SetAttribute("Cancelled", true)
		fade(child:GetChildren())
		child.Name = "--"
		DebrisModule:AddItem(child, Look.Fade + 0.05)
	end
end

local function createFolder(p: string, persist: boolean)
	destroyFolder(p)
	local configuration = Instance.new("Configuration")
	configuration.Name = `{p}-Telegraph`
	configuration:SetAttribute("Persist", persist)
	configuration.Parent = workspace.Debree

	if not persist then
		DebrisModule:AddItem(configuration, 15)
	end

	return configuration
end

local function folderAlive(instance)
	return instance.Parent ~= nil and not instance:GetAttribute("Cancelled")
end

local function anchorFrame(instance, cframe: CFrame?)
	local cFrame = nil

	if typeof(instance) == "CFrame" then
		cFrame = instance
	elseif typeof(instance) == "Instance" and instance.Parent ~= nil then
		if instance:IsA("BasePart") then
			cFrame = instance.CFrame
		elseif instance:IsA("Model") then
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart") or instance.PrimaryPart or instance:FindFirstChild("Head")

			if not (humanoidRootPart == nil or not humanoidRootPart:IsA("BasePart")) then
				cFrame = humanoidRootPart.CFrame
			end
		end
	end

	if cFrame == nil or cframe == nil then
		return cFrame
	end

	local v = (cframe.Position - cFrame.Position) * createVector(1, 0, 1)

	if v.Magnitude < 0.01 then
		return cFrame
	end

	return CFrame.lookAt(cFrame.Position, cFrame.Position + v.Unit)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function groundFrame(cframe: CFrame, offset: CFrame)
	local v = cframe * offset
	local v2 = v.LookVector * createVector(1, 0, 1)
	local v3 = not (v2.Magnitude > 0.01) and createVector(0, 0, 1) or v2.Unit
	local raycastResult = workspace:Raycast(
		v.Position + createVector(0, 5, 0),
		createVector(0, -30, 0),
		RaycastHelper.Ground
	)

	if raycastResult == nil then
		return nil, nil
	end

	return raycastResult.Position + raycastResult.Normal * Look.Lift, v3
end

return function(model, value: string?, value2: string?, data)
	if type(value) ~= "string" or type(value2) ~= "string" then
		return
	end

	if value == "Cancel" then
		destroyFolder(value2)
		destroyFolder(`{value2}-Flash`)
	else
		if type(data) ~= "table" then
			return
		end

		local v = Look.Resolve[data.Class or "Normal"]

		if v == nil then
			return
		end

		local color = v.Color
		local anchor

		if data.Anchor == nil then
			anchor = model
		else
			anchor = data.Anchor
		end

		local v2 = anchorFrame(anchor, anchorFrame(data.Face))

		if v2 == nil or (currentCamera.CFrame.Position - v2.Position).Magnitude >= 250 then
			return
		end

		local v3 = (type(data.Duration) ~= "number" or not (data.Duration > 0)) and 2 or data.Duration

		if value == "Start" or value == "Flash" then
			if value == "Flash" then
				value2 = `{value2}-Flash`
			end

			local v5

			if value == "Start" then
				v5 = data.Persist == true
			else
				v5 = false
			end

			local parent = createFolder(value2, v5)

			if value ~= "Flash" and data.Flash ~= true or typeof(model) ~= "Instance" or not model:IsA("Model") then
				return
			end

			local highlight = Instance.new("Highlight")
			highlight.Adornee = model
			highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
			highlight.FillColor = color
			highlight.OutlineColor = color
			highlight.FillTransparency = Look.Highlight.Transparency
			highlight.OutlineTransparency = 0
			highlight.Parent = parent
			TweenService:Create(
				highlight,
				TweenInfo.new(Look.Highlight.Pulse, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true),
				{
					FillTransparency = Look.Highlight.Dim
				}
			):Play()
			DebrisModule:AddItem(highlight, v3)
		else
			local v4 = modulesByName[value]
			local child = workspace.Debree:FindFirstChild((`{value2}-Telegraph`))

			if v4 == nil or child == nil or type(data.Shape) ~= "table" then
				return
			end

			local shape = data.Shape
			local offset

			if typeof(shape.Offset) == "CFrame" then
				offset = shape.Offset
			else
				offset = CFrame.identity
			end

			local freezeAt

			if type(shape.FreezeAt) == "number" then
				freezeAt = shape.FreezeAt
			else
				freezeAt = nil
			end

			local startedAt

			if type(data.StartedAt) == "number" then
				startedAt = data.StartedAt
			else
				startedAt = workspace:GetServerTimeNow()
			end

			local v5, v6 = groundFrame(v2, offset) -- equivalent call inferred; original call site unknown

			if v5 == nil then
				return
			end

			local cframe = CFrame.lookAt(v5, v5 + v6)
			local v7, v8 = v4(child, shape, {
				Color = color,
				Glow = color:Lerp(Color3.new(1, 1, 1), Look.Glow.Brighten),
				Fill = v.Fill,
				Rim = v.Rim
			})

			if v7 == nil or v8 == nil then
				return
			end

			local v9 = typeof(anchor) ~= "CFrame"
			local v10 = data.Fill == "Shrink"
			local v11 = v2
			local magnitude = nil
			local heartbeatConnection = nil
			heartbeatConnection = RunService.Heartbeat:Connect(function()
				local v12 = child
				local v13

				if v12.Parent == nil then
					v13 = false
				else
					v13 = not v12:GetAttribute("Cancelled")
				end

				if not v13 or v7[1].Parent == nil then
					heartbeatConnection:Disconnect()
				elseif typeof(anchor) == "Instance" and anchor.Parent == nil then
					destroyFolder(value2)
					heartbeatConnection:Disconnect()
				else
					local v14 = workspace:GetServerTimeNow() - startedAt

					if v9 then
						local v15 = anchorFrame(data.Face)
						local v16 = anchorFrame(anchor, v15)

						if v16 ~= nil and ((v16.Position - v11.Position).Magnitude > 0.05 or v16.LookVector:Dot(v11.LookVector) < 0.9999) then
							v11 = v16
							local v17, v18 = groundFrame(v16, offset) -- equivalent call inferred; original call site unknown

							if v17 ~= nil then
								cframe = CFrame.lookAt(v17, v17 + v18)
							end
						end

						if v16 ~= nil and v15 ~= nil then
							magnitude = ((v15.Position - v16.Position) * createVector(1, 0, 1)).Magnitude
						end

						v9 = freezeAt == nil or v14 < freezeAt
					end

					local v15 = math.clamp(v14 / v3, 0, 1)
					local v17 = cframe

					if v10 then
						v15 = 1 - v15
					end

					v8(v17, v15, magnitude)
				end
			end)

			if child:GetAttribute("Persist") == true then
				return
			end

			local v12 = math.max(v3 - (workspace:GetServerTimeNow() - startedAt), 0)
			task.delay(v12, function()
				local v13 = child
				local v14

				if v13.Parent == nil then
					v14 = false
				else
					v14 = not v13:GetAttribute("Cancelled")
				end

				if v14 then
					fade(v7)
				end
			end)

			for _, v13 in v7 do
				DebrisModule:AddItem(v13, v12 + Look.Fade + 0.05)
			end
		end
	end
end