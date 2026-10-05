local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
game:GetService("Lighting")
local Players = game:GetService("Players")
Players = Players.LocalPlayer
game:GetService("ServerStorage")
local FX = require(ReplicatedStorage:WaitForChild("FX"))
local control_PhysicalFruit = FX:WaitForChild("Control_PhysicalFruit")
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local _ = Util.Sound
local _ = Util.DestroyAfter
local heartbeatLoopFor = Util.HeartbeatLoopFor
local _ = heartbeatLoopFor.HeartbeatLoopFor
local _ = heartbeatLoopFor.AwaitHeartbeatLoopFor
local VisualHelper = require(script.Parent.PhysicalFruitModules.VisualHelper)
local lightningBoltShafi = Util.LightningBoltShafi
Random.new()

local function ApplyColor(list, color: Color3)
	for _, instance in ipairs(list) do
		if instance:GetAttribute("Uncolor") then
			continue
		end

		if instance:IsA("BasePart") then
			instance.Color = color
		elseif instance:IsA("ParticleEmitter") or instance:IsA("Trail") or instance:IsA("Beam") then
			instance.Color = ColorSequence.new(color)
		elseif instance:IsA("ImageLabel") then
			instance.ImageColor3 = color
			instance.BackgroundColor3 = color
		elseif instance:IsA("Light") then
			instance.Color = color
		end
	end
end

local object = setmetatable({}, {
	__mode = "k"
})
return function(p)
	if (Workspace.CurrentCamera.CFrame.Position - p.Fruit:GetPivot().Position).Magnitude > 800 then
		return
	end

	local v = {}
	local fruit = p.Fruit
	local v2 = object[fruit]

	if v2 then
		v2()
	end

	Util.Anims:Preload("ControlPhysicalFruitAnimationModel")
	local controlPhysicalFruitAnimationModel = Util.Anims:Get(fruit.ControlModel, "ControlPhysicalFruitAnimationModel")
	controlPhysicalFruitAnimationModel:Play()
	controlPhysicalFruitAnimationModel:AdjustSpeed(0)
	local controlPhysicalFruitAnimationModel2 = Util.Anims:Get(fruit.ChargeModel, "ControlPhysicalFruitAnimationModel")
	controlPhysicalFruitAnimationModel2:Play()
	controlPhysicalFruitAnimationModel2:AdjustSpeed(0)
	local clone = control_PhysicalFruit.Cubes:Clone()
	clone:PivotTo(fruit:GetPivot() * CFrame.new(0, 100, 0))
	clone.Parent = Workspace._WorldOrigin
	local children = clone:GetChildren()
	local v3 = 6.283185307179586 / #children
	local v4 = 2.65
	local v5 = 2.65
	local v6 = 1
	local v7 = 1
	local v8 = 10
	local v9 = 10
	local color3Value = Instance.new("Color3Value")
	local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Sine)
	local charge = fruit:FindFirstChild("Charge")

	if not charge then
		clone:Destroy()
		return
	end

	local A001 = fruit.ChargeModel["A.001"]

	if A001 then
		A001.Transparency = 1
	end

	local blueSurfaceAppearance = fruit.ControlModel["A.001"].BlueSurfaceAppearance
	local purpleSurfaceAppearance = fruit.PurpleSurfaceAppearance

	for _, parent in ipairs(children) do
		Instance.new("Attachment", parent)
	end

	local flag = true
	local flag2 = false
	local v10 = {}
	local Cleanup

	Cleanup = function()
		if flag2 then
			return
		end

		flag2 = true
		flag = false

		if object[fruit] == Cleanup then
			object[fruit] = nil
		end

		for _, v11 in ipairs(v10) do
			local v12 = v11
			pcall(function()
				v12:Destroy()
			end)
		end

		table.clear(v10)

		for _, v11 in ipairs(v) do
			local connection = v11
			pcall(function()
				connection:Disconnect()
			end)
		end

		table.clear(v)

		if clone and clone.Parent then
			clone:Destroy()
		end

		purpleSurfaceAppearance.Parent = fruit
		blueSurfaceAppearance.Parent = fruit.ControlModel["A.001"]
		fruit.ControlModel["Neon.003"].Color = Color3.fromRGB(97, 163, 152)
		fruit.ControlModel["Neon.004"].Color = Color3.fromRGB(35, 126, 168)
		VisualHelper:Tween(A001, tweenInfo, {
			Transparency = 1,
			Color = Color3.fromRGB(114, 143, 197) or Color3.fromRGB(163, 128, 197)
		})
		color3Value.Value = Color3.fromRGB(35, 94, 255)
		ApplyColor(charge:GetDescendants(), Color3.fromRGB(114, 143, 197))
	end

	object[fruit] = Cleanup
	table.insert(v, fruit.AncestryChanged:Connect(function()
		if flag and not fruit:IsDescendantOf(Workspace) then
			Cleanup()
		end
	end))

	if fruit.Destroying then
		table.insert(v, fruit.Destroying:Connect(function()
			Cleanup()
		end))
	end

	local function waitAlive(p2: number)
		local total = 0

		while flag and total < p2 do
			total += RunService.Heartbeat:Wait()
		end

		return flag
	end

	local total = 0
	local v11 = 1
	local v12 = 1

	-- equivalent calls inferred from this helper; original call sites unknown
	local function expAlpha(p2: number, p3: number)
		return 1 - math.exp(-p2 * p3)
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function expLerp(p2: number, p3: number, p4: number, p5: number)
		return p2 + (p3 - p2) * expAlpha(p4, p5)
	end

	table.insert(v, RunService.Heartbeat:Connect(function(dt)
		if not flag then
			return
		end

		if not fruit:IsDescendantOf(Workspace) then
			Cleanup()
			return
		end

		v11 = math.lerp(v11, v12, dt * 3)
		total += dt * v11
		local v13 = v6
		v6 = v13 + (v7 - v13) * (1 - math.exp(dt * -10))
		local v14 = v8
		v8 = v14 + (v9 - v14) * (1 - math.exp(dt * -10))
		v4 = expLerp(v4, v5, v8, dt)
		local beams = charge:FindFirstChild("Beams")

		if beams then
			for _, part in ipairs(beams:GetChildren()) do
				if part:IsA("BasePart") then
					part.CFrame *= CFrame.Angles(0, dt * 15, 0)
				end
			end
		end

		local pivot = fruit:GetPivot()

		for i, v17 in ipairs(children) do
			local v18 = math.sin(total * 1.5 + i * 0.08)
			local v19 = v18 * 0.65 + 0
			local v20 = -v4 + v18 * 0.35
			v17.CFrame = pivot * CFrame.Angles(1.3368479376977842, v3 * i + total * v6, 0) * CFrame.new(0, v19, v20)
		end

		fruit.Charge.Eye0.WorldPosition = fruit.ControlModel.RootPart.Body1.Body2["EyeController.R"].WorldPosition
		fruit.Charge.Eye1.WorldPosition = fruit.ControlModel.RootPart.Body1.Body2["EyeController.L"].WorldPosition
		fruit.Charge.Eye0_Small.WorldPosition = fruit.ControlModel.RootPart.Body1.Body2["EyeController.R"].WorldPosition
		fruit.Charge.Eye1_Small.WorldPosition = fruit.ControlModel.RootPart.Body1.Body2["EyeController.L"].WorldPosition
	end))

	local function ToggleBolts(flag3: boolean)
		if flag3 then
			if #v10 > 0 then
				return
			end

			local function NewBolt(attachment, attachment2)
				local v13 = lightningBoltShafi.new(attachment, attachment2, 6, 0.2, Workspace.Terrain)
				v13.CurveSize0 = 0
				v13.CurveSize1 = 0
				v13.MinRadius = 0.3
				v13.MaxRadius = 0.8
				v13.Frequency = 0.35
				v13.AnimationSpeed = math.random(5, 9)
				local maxThicknessMultiplier = 0.3 + math.random() * 0.75
				v13.MinThicknessMultiplier = 0.1
				v13.MaxThicknessMultiplier = maxThicknessMultiplier
				v13.MinTransparency = 0
				v13.MaxTransparency = 1
				v13.PulseSpeed = 10
				v13.PulseLength = 1000000
				v13.FadeLength = 0.2
				v13.Color = ColorSequence.new({
					ColorSequenceKeypoint.new(0, Color3.fromRGB(155, 107, 197)),
					ColorSequenceKeypoint.new(1, Color3.fromRGB(163, 128, 197))
				})
				v13.ContractFrom = 0.5
				v13.ColorOffsetSpeed = 3
				return v13
			end

			local v13 = nil

			for _, v14 in ipairs(children) do
				if v13 then
					table.insert(v10, (NewBolt(v13.Attachment, v14.Attachment)))
				end

				v13 = v14
			end

			if v13 and children[1] then
				table.insert(v10, (NewBolt(v13.Attachment, children[1].Attachment)))
			end
		else
			for _, v13 in ipairs(v10) do
				v13:Destroy()
			end

			table.clear(v10)
		end
	end

	local v13 = "Blue"

	local function ToggleCharge(flag3: boolean, p2: string?, flag4: boolean?)
		if not flag then
			return
		end

		if not fruit:IsDescendantOf(Workspace) then
			Cleanup()
			return
		end

		if p2 == nil then
			flag3 = false
			flag4 = false
		else
			v13 = p2
		end

		local v14 = p2 or v13
		local v15 = v14 == "Blue"

		local function ApplyModePalette()
			VisualHelper:Tween(fruit.ControlModel["Neon.003"], tweenInfo, {
				Color = v15 and Color3.fromRGB(97, 163, 152) or Color3.fromRGB(143, 119, 149)
			})
			VisualHelper:Tween(fruit.ControlModel["Neon.004"], tweenInfo, {
				Color = v15 and Color3.fromRGB(35, 126, 168) or Color3.fromRGB(135, 93, 149)
			})

			if A001 then
				VisualHelper:Tween(A001, tweenInfo, {
					Color = v15 and Color3.fromRGB(114, 143, 197) or Color3.fromRGB(163, 128, 197)
				})
			end

			local color = v15 and Color3.fromRGB(35, 94, 255) or Color3.fromRGB(141, 48, 222)
			color3Value.Value = color

			for _, v16 in ipairs(children) do
				local shader = v16:FindFirstChild("Shader")

				if shader then
					for _, child in ipairs(shader:GetChildren()) do
						local imageLabel = child:FindFirstChild("ImageLabel")

						if imageLabel and imageLabel:IsA("ImageLabel") then
							VisualHelper:Tween(imageLabel, tweenInfo, {
								ImageColor3 = v15 and Color3.fromRGB(151, 179, 255) or Color3.fromRGB(202, 171, 255),
								BackgroundColor3 = v15 and Color3.fromRGB(76, 91, 108) or Color3.fromRGB(145, 83, 189)
							})
						end
					end
				end

				local particles = v16:FindFirstChild("Particles")

				if particles then
					ApplyColor(particles:GetChildren(), color)
				end
			end

			ApplyColor(charge:GetDescendants(), v15 and Color3.fromRGB(114, 143, 197) or Color3.fromRGB(163, 128, 197))
		end

		ToggleBolts((v14 == "Purple" or v13 == "Purple") and v14 ~= "Blue")
		VisualHelper:SetEnableAll(charge, flag3)
		VisualHelper:SetEnableAll(charge.Beams, flag3 and flag4 == true and true or false)
		VisualHelper:SetEnableAll(charge.Eye0, flag3)
		VisualHelper:SetEnableAll(charge.Eye1, flag3)
		VisualHelper:SetEnableAll(charge.Eye1_Small, v14 == "Purple" and not flag3)
		VisualHelper:SetEnableAll(charge.Eye0_Small, v14 == "Purple" and not flag3)

		if flag3 then
			v12 = 4

			if A001 then
				VisualHelper:Tween(A001, tweenInfo, {
					Transparency = 0.135,
					Color = v15 and Color3.fromRGB(114, 143, 197) or Color3.fromRGB(163, 128, 197)
				})
			end

			ApplyModePalette()
			local valueChangedConnection = color3Value:GetPropertyChangedSignal("Value"):Connect(function()
				local value = color3Value.Value

				for _, v22 in ipairs(children) do
					local particles = v22:FindFirstChild("Particles")

					if particles then
						ApplyColor(particles:GetChildren(), value)
					end
				end

				ApplyColor(charge:GetDescendants(), value)
			end)
			table.insert(v, valueChangedConnection)
			VisualHelper:Tween(color3Value, tweenInfo, {
				Value = v15 and Color3.fromRGB(35, 94, 255) or Color3.fromRGB(141, 48, 222)
			})
			local time = tweenInfo.Time
			local total2 = 0

			while flag and total2 < time do
				total2 += RunService.Heartbeat:Wait()
			end

			if not flag then
				return
			end

			local blueSurfaceAppearance2 = blueSurfaceAppearance
			local purpleSurfaceAppearance2 = purpleSurfaceAppearance
			local A0012 = v15 and fruit.ControlModel["A.001"] or fruit
			local A0013 = not v15 and fruit.ControlModel["A.001"] or fruit
			blueSurfaceAppearance2.Parent = A0012
			purpleSurfaceAppearance2.Parent = A0013
			pcall(function()
				valueChangedConnection:Disconnect()
			end)
		else
			v12 = 1

			if fruit:FindFirstChild("Main") and fruit.Main:FindFirstChild("EndCharge") then
				VisualHelper:EmitAll(fruit.Main.EndCharge, nil, nil, ColorSequence.new(color3Value.Value))
			end

			if A001 then
				VisualHelper:Tween(A001, tweenInfo, {
					Transparency = 1
				})
			end

			if p2 ~= nil then
				ApplyModePalette()
				local blueSurfaceAppearance2 = blueSurfaceAppearance
				local purpleSurfaceAppearance2 = purpleSurfaceAppearance
				local A0012 = v15 and fruit.ControlModel["A.001"] or fruit
				local A0013 = not v15 and fruit.ControlModel["A.001"] or fruit
				blueSurfaceAppearance2.Parent = A0012
				purpleSurfaceAppearance2.Parent = A0013
			end
		end

		local v22 = p2 == nil and 1.5 or 0.5
		local total2 = 0

		while flag and total2 < v22 do
			total2 += RunService.Heartbeat:Wait()
		end

		if flag then
		end
	end

	local total2 = 13
	local flag3 = false

	local function PlayEffect15()
		if flag3 then
			return
		end

		flag3 = true
		ToggleCharge(true, "Blue", true)
		task.spawn(function()
			v9 = 10
			v5 = 1.8549999999999998
			v7 = 8
			task.spawn(function()
				local total3 = 0

				while flag and total3 < 0.8 do
					total3 += RunService.Heartbeat:Wait()
				end

				if not flag then
					flag3 = false
					return
				end

				v9 = 55
				v5 = 3.8425
				v7 = 6
				local total4 = 0

				while flag and total4 < 0.1 do
					total4 += RunService.Heartbeat:Wait()
				end

				if not flag then
					flag3 = false
					return
				end

				v9 = 10
				v5 = 2.65
				v7 = 1
				local total5 = 0

				while flag and total5 < 0.75 do
					total5 += RunService.Heartbeat:Wait()
				end

				if flag then
					v9 = 10
				else
					flag3 = false
				end
			end)
			task.wait(0.25)
			ToggleCharge(true, "Purple", true)
			ToggleCharge(false)
			flag3 = false
		end)
	end

	local function PlayEffect21667()
		ToggleCharge(false, "Blue")
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function FireForTrigger(p2: number, length: number, p3: number, p4: number, callback)
		if math.floor((p3 - p2) / length) < math.floor((p4 - p2) / length) then
			task.spawn(callback)
		end
	end

	table.insert(v, RunService.RenderStepped:Connect(function(dt)
		local length = controlPhysicalFruitAnimationModel.Length

		if not length or length <= 0 then
			return
		end

		local v14 = total2
		total2 += dt
		local timePosition = total2 % length
		controlPhysicalFruitAnimationModel.TimePosition = timePosition
		controlPhysicalFruitAnimationModel2.TimePosition = timePosition

		if length >= 15 then
			FireForTrigger(15, length, v14, total2, PlayEffect15) -- equivalent call inferred; original call site unknown
		end

		if length >= 21.667 then
			FireForTrigger(21.667, length, v14, total2, PlayEffect21667) -- equivalent call inferred; original call site unknown
		end
	end))
	ToggleCharge(false)

	while flag and fruit:IsDescendantOf(Workspace) do
		task.wait()
	end

	Cleanup()
end