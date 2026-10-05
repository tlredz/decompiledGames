local createVector = vector.create
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local _WorldOrigin = Workspace._WorldOrigin
local util = game.ReplicatedStorage:FindFirstChild("Util")
local module

if util then
	module = require(util)
else
	module = nil
end

local Effect = require(game.ReplicatedStorage.Effect)

-- equivalent calls inferred from this helper; original call sites unknown
local function tintToward(value: Color3, color: Color3)
	local _, v, v2 = value:ToHSV()
	local HSV, v3 = color:ToHSV()
	return Color3.fromHSV(HSV, math.clamp(v3 * v, 0, 1), v2)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function applyCommon(p, data)
	p.Anchored = true
	p.CanCollide = false
	p.CanTouch = false
	p.CanQuery = false

	if data.Color then
		p.Color = data.Color
	end

	p.Transparency = data.Transparency == nil and 0.4 or data.Transparency or 0.4
end

local function toCF(instance)
	if typeof(instance) == "CFrame" then
		return instance
	end

	if typeof(instance) == "Vector3" then
		return CFrame.new(instance)
	end

	if typeof(instance) ~= "Instance" then
		return CFrame.new()
	end

	if instance:IsA("CFrameValue") then
		return instance.Value
	end

	if instance:IsA("Vector3Value") then
		return CFrame.new(instance.Value)
	end

	return CFrame.new()
end

local function projectToGround(p, list)
	local position = toCF(p).Position

	if module and module.Ray then
		local v = { Workspace:FindFirstChild("Characters"), Workspace:FindFirstChild("Enemies") }

		if list then
			for _, v2 in ipairs(list) do
				table.insert(v, v2)
			end
		end

		local success, result, v2 = pcall(function()
			return module.Ray(position + createVector(0, 50, 0), createVector(-0, -500, -0), v)
		end)

		if success then
			if typeof(result) == "Vector3" then
				position = result
			elseif typeof(v2) == "Vector3" then
				position = v2
			end
		end
	else
		local raycastParams = RaycastParams.new()
		raycastParams.FilterType = Enum.RaycastFilterType.Exclude
		local filterDescendantsInstances = {}

		for _, childName in ipairs({ "Characters", "Enemies", "SeaEvents" }) do
			local child = Workspace:FindFirstChild(childName)

			if child then
				table.insert(filterDescendantsInstances, child)
			end
		end

		if list then
			for _, v2 in ipairs(list) do
				table.insert(filterDescendantsInstances, v2)
			end
		end

		raycastParams.FilterDescendantsInstances = filterDescendantsInstances
		local raycastResult = Workspace:Raycast(
			position + createVector(0, 50, 0),
			createVector(-0, -500, -0),
			raycastParams
		)

		if raycastResult then
			position = raycastResult.Position
		end
	end

	position += createVector(0, 0.05, 0)
	return CFrame.new(position)
end

local function gatherTargets()
	local models = {}

	for _, childName in ipairs({ "Characters" }) do
		local child = Workspace:FindFirstChild(childName)

		if not child then
			continue
		end

		for _, model in ipairs(child:GetChildren()) do
			if model:IsA("Model") then
				table.insert(models, model)
			end
		end
	end

	return models
end

local function rootOf(instance)
	local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart and humanoidRootPart:IsA("BasePart") then
		return humanoidRootPart
	end

	if instance.PrimaryPart then
		return instance.PrimaryPart
	end

	return instance:FindFirstChildWhichIsA("BasePart")
end

local function makeHighlighter(highlightColor: Color3)
	local v = {}

	local function set(p, flag: boolean)
		if flag then
			if not v[p] then
				local highlight = Instance.new("Highlight")
				highlight.FillColor = highlightColor
				highlight.FillTransparency = 0.5
				highlight.OutlineColor = highlightColor
				highlight.OutlineTransparency = 0
				highlight.DepthMode = Enum.HighlightDepthMode.Occluded
				highlight.Adornee = p
				highlight.Parent = p
				v[p] = highlight
			end
		else
			local v2 = v[p]

			if v2 then
				v2:Destroy()
				v[p] = nil
			end
		end
	end

	return {
		update = function(vector2: Vector3, p: number)
			local v2 = {}

			for _, v3 in ipairs((gatherTargets())) do
				local humanoidRootPart = v3:FindFirstChild("HumanoidRootPart")

				if not (humanoidRootPart and humanoidRootPart:IsA("BasePart")) then
					if v3.PrimaryPart then
						humanoidRootPart = v3.PrimaryPart
					else
						humanoidRootPart = v3:FindFirstChildWhichIsA("BasePart")
					end
				end

				if not humanoidRootPart then
					continue
				end

				v2[v3] = true
				local v4 = humanoidRootPart.Position - vector2
				set(v3, Vector3.new(v4.X, 0, v4.Z).Magnitude <= p)
			end

			for k in pairs(v) do
				if v2[k] then
					continue
				end

				local v3 = v[k]

				if not v3 then
					continue
				end

				v3:Destroy()
				v[k] = nil
			end
		end,
		clear = function()
			for _, v2 in pairs(v) do
				v2:Destroy()
			end

			table.clear(v)
		end
	}
end

local color = Color3.fromRGB(255, 60, 60)
local v = {
	Exclaim = {
		start = "!",
		mid = "!!",
		final = "!!!"
	},
	Question = {
		start = "?",
		mid = "?",
		final = "!!!"
	}
}
local color2 = Color3.fromRGB(255, 255, 255)
local uDim = UDim2.fromScale(9, 9)
UDim2.fromScale(10.5, 10.5)

-- equivalent calls inferred from this helper; original call sites unknown
local function alertLighten(color3: Color3, p: number)
	return color3:Lerp(Color3.new(1, 1, 1), p)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function alertDarken(color3: Color3, p: number)
	return color3:Lerp(Color3.new(0, 0, 0), p)
end

local color3 = Color3.fromRGB(255, 255, 0)

local function buildAlertBillboard(adornee, p: number, color4: Color3, text: string)
	local billboardGui = Instance.new("BillboardGui")
	billboardGui.Name = "SkillAlert"
	billboardGui.Adornee = adornee
	billboardGui.AlwaysOnTop = true
	billboardGui.LightInfluence = 0
	billboardGui.Size = UDim2.fromScale(0, 0)
	billboardGui.StudsOffsetWorldSpace = Vector3.new(0, p, 0)
	billboardGui.MaxDistance = 1200
	local textLabel = Instance.new("TextLabel")
	textLabel.Name = "Shadow"
	textLabel.BackgroundTransparency = 1
	textLabel.Size = UDim2.fromScale(1, 1)
	textLabel.AnchorPoint = Vector2.new(0.5, 0.5)
	textLabel.Position = UDim2.fromScale(0.5, 0.5)
	textLabel.Font = Enum.Font.FredokaOne
	textLabel.Text = text
	textLabel.TextScaled = false
	textLabel.TextSize = 64
	textLabel.TextColor3 = Color3.new(0, 0, 0)
	textLabel.TextTransparency = 1
	textLabel.TextStrokeTransparency = 1
	textLabel.ZIndex = 1
	textLabel.Parent = billboardGui
	local textLabel2 = Instance.new("TextLabel")
	textLabel2.Name = "Text"
	textLabel2.BackgroundTransparency = 1
	textLabel2.Size = UDim2.fromScale(1, 1)
	textLabel2.AnchorPoint = Vector2.new(0.5, 0.5)
	textLabel2.Position = UDim2.fromScale(0.5, 0.5)
	textLabel2.Font = Enum.Font.FredokaOne
	textLabel2.Text = text
	textLabel2.TextScaled = false
	textLabel2.TextSize = 64
	textLabel2.TextColor3 = Color3.new(1, 1, 1)
	textLabel2.TextStrokeTransparency = 1
	textLabel2.TextTransparency = 1
	textLabel2.ZIndex = 2
	local uIGradient = Instance.new("UIGradient")
	uIGradient.Rotation = 90
	uIGradient.Color = ColorSequence.new(color4:Lerp(Color3.new(1, 1, 1), 0.15), alertDarken(color4, 0.15))
	uIGradient.Parent = textLabel2
	local uIStroke = Instance.new("UIStroke")
	uIStroke.Thickness = 1.5
	uIStroke.Color = Color3.new(0, 0, 0)
	uIStroke.Transparency = 0.15
	uIStroke.LineJoinMode = Enum.LineJoinMode.Miter
	uIStroke.Parent = textLabel2
	local uIScale = Instance.new("UIScale")
	uIScale.Scale = 1
	uIScale.Parent = textLabel2
	textLabel2.Parent = billboardGui
	return billboardGui, textLabel2, textLabel, uIStroke, uIGradient, uIScale
end

-- equivalent calls inferred from this helper; original call sites unknown
local function startFlash(alertBillboard, p, p2, _)
	return task.spawn(function()
		task.wait(0.18)
		local visible = false

		while alertBillboard.Parent do
			visible = not visible
			p.Visible = visible
			p2.Visible = visible
			task.wait(0.18)
		end

		p.Visible = true
		p2.Visible = true
	end)
end

local function alertCharacter(_, parent, color4: Color3, duration: number, p, callback, p2)
	local alertBillboard, v2, v3, v4, _, v5 = buildAlertBillboard(parent, 12, color4, p2.start)
	alertBillboard.Parent = parent
	TweenService:Create(alertBillboard, TweenInfo.new(0.18, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Size = uDim
	}):Play()
	TweenService:Create(v2, TweenInfo.new(0.14), {
		TextTransparency = 0
	}):Play()
	TweenService:Create(v3, TweenInfo.new(0.14), {
		TextTransparency = 0.35
	}):Play()
	local v6 = startFlash(alertBillboard, v2, v3) -- equivalent call inferred; original call site unknown

	if callback then
		task.spawn(callback)
	end

	task.delay(duration, function()
		if not alertBillboard.Parent then
			return
		end

		if v6 then
			task.cancel(v6)
			v6 = nil
		end

		v2.Text = p2.final
		v3.Text = p2.final
		v2.TextColor3 = color3
		local uIGradient = v2:FindFirstChildOfClass("UIGradient")

		if uIGradient then
			uIGradient.Color = ColorSequence.new(color3:Lerp(Color3.new(1, 1, 1), 0.35), alertDarken(color3, 0.4))
		end

		v2.TextTransparency = 0
		v3.TextTransparency = 0.35
		v4.Transparency = 0
		alertBillboard.Size = UDim2.fromScale(16, 16)
		v5.Scale = 0.5
		local studsOffsetWorldSpace = alertBillboard.StudsOffsetWorldSpace
		local studsOffsetWorldSpace2 = studsOffsetWorldSpace + createVector(0, 1.5, 0)
		local thickness = v4.Thickness
		local tweenInfo = TweenInfo.new(0.13, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
		TweenService:Create(v5, tweenInfo, {
			Scale = 2
		}):Play()
		TweenService:Create(v4, tweenInfo, {
			Thickness = thickness * 2
		}):Play()
		local tween = TweenService:Create(alertBillboard, tweenInfo, {
			StudsOffsetWorldSpace = studsOffsetWorldSpace2
		})
		tween:Play()
		tween.Completed:Connect(function()
			if alertBillboard.Parent then
				local tweenInfo2 = TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
				TweenService:Create(v5, tweenInfo2, {
					Scale = 1.3
				}):Play()
				TweenService:Create(v4, tweenInfo2, {
					Thickness = thickness * 1.3
				}):Play()
				TweenService:Create(alertBillboard, tweenInfo2, {
					StudsOffsetWorldSpace = studsOffsetWorldSpace
				}):Play()
			end
		end)
		local charge = p.charge or 1
		task.delay(math.max(charge - duration, 0), function()
			if not alertBillboard.Parent then
				return
			end

			v2.Visible = true
			v3.Visible = true
			v2.Text = p2.final
			v3.Text = p2.final
			v2.TextColor3 = color3
			local uIGradient2 = v2:FindFirstChildOfClass("UIGradient")

			if uIGradient2 then
				uIGradient2.Color = ColorSequence.new(color3:Lerp(Color3.new(1, 1, 1), 0.15), alertDarken(color3, 0.15))
			end

			v2.TextTransparency = 0
			v3.TextTransparency = 0.35
			v4.Transparency = 0
			local tweenInfo2 = TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
			TweenService:Create(v5, tweenInfo2, {
				Scale = 2.6
			}):Play()
			TweenService:Create(v4, tweenInfo2, {
				Thickness = thickness * 2.6
			}):Play()
			task.delay(0.25, function()
				if not alertBillboard.Parent then
					return
				end

				v2.Visible = false
				v3.Visible = false
				task.delay(0.25, function()
					if alertBillboard.Parent then
						alertBillboard:Destroy()
					end
				end)
			end)
		end)
	end)
end

local function alertIndicator(parent, color4: Color3, p, callback, data)
	local alertBillboard, v2, v3, v4 = buildAlertBillboard(parent, 6, color4, data.start)
	alertBillboard.Parent = parent
	local uDim2 = UDim2.fromScale(uDim.X.Scale * 1.35, uDim.Y.Scale * 1.35)
	TweenService:Create(v2, TweenInfo.new(0.1), {
		TextTransparency = 0
	}):Play()
	TweenService:Create(v3, TweenInfo.new(0.1), {
		TextTransparency = 0.35
	}):Play()
	local tween = TweenService:Create(
		alertBillboard,
		TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		{
			Size = uDim2
		}
	)
	tween:Play()
	tween.Completed:Connect(function()
		if alertBillboard.Parent then
			TweenService:Create(alertBillboard, TweenInfo.new(0.14, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				Size = uDim
			}):Play()
		end
	end)
	local thread = nil
	task.delay(0.3, function()
		if alertBillboard.Parent then
			local v5 = alertBillboard
			local v6 = v2
			local v7 = v3
			thread = task.spawn(function()
				task.wait(0.18)
				local visible = false

				while v5.Parent do
					visible = not visible
					v6.Visible = visible
					v7.Visible = visible
					task.wait(0.18)
				end

				v6.Visible = true
				v7.Visible = true
			end)
		end
	end)
	local charge = p.charge or 1
	local fade = p.fade or 0.25

	if callback then
		task.spawn(callback)
	end

	task.delay(charge / 3, function()
		if not alertBillboard.Parent then
			return
		end

		v2.Text = data.mid
		v3.Text = data.mid
	end)
	task.delay(charge / 3 * 2, function()
		if not alertBillboard.Parent then
			return
		end

		v2.Text = data.final
		v3.Text = data.final
	end)
	task.delay(charge, function()
		if not alertBillboard.Parent then
			return
		end

		if thread then
			task.cancel(thread)
			thread = nil
		end

		v2.Visible = true
		v3.Visible = true
		v2.Text = "✦"
		v3.Text = "✦"
		v2.TextColor3 = color3
		v2.TextTransparency = 0
		v3.TextTransparency = 0.35
		v4.Transparency = 0
		task.delay(fade + 0.15, function()
			if alertBillboard.Parent then
				v2.Visible = false
				v3.Visible = false
				alertBillboard:Destroy()
			end
		end)
	end)
end

local function alertCircle(position: Vector3, color4: Color3, p, callback, data, callback2)
	local part = Instance.new("Part")
	part.Name = "SkillAlertAnchor"
	part.Anchored = true
	part.CanCollide = false
	part.CanQuery = false
	part.CanTouch = false
	part.Transparency = 1
	part.Size = createVector(0.1, 0.1, 0.1)
	part.CFrame = CFrame.new(position)
	part.Parent = _WorldOrigin or Workspace

	if callback2 then
		local heartbeatConnection = nil
		heartbeatConnection = RunService.Heartbeat:Connect(function()
			if part.Parent then
				part.CFrame = CFrame.new(callback2())
			elseif heartbeatConnection then
				heartbeatConnection:Disconnect()
				heartbeatConnection = nil
			end
		end)
	end

	local alertBillboard, v2, v3, v4, _, v5 = buildAlertBillboard(part, 6, color4, data.start)
	alertBillboard.Parent = part
	TweenService:Create(alertBillboard, TweenInfo.new(0.18, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Size = UDim2.fromScale(9, 9)
	}):Play()
	TweenService:Create(v2, TweenInfo.new(0.12), {
		TextTransparency = 0
	}):Play()
	TweenService:Create(v3, TweenInfo.new(0.12), {
		TextTransparency = 0.35
	}):Play()
	local charge = p.charge or 1
	local fade = p.fade or 0.25

	if callback then
		task.spawn(callback)
	end

	local v6 = charge / 3
	task.delay(0 + v6, function()
		if not alertBillboard.Parent then
			return
		end

		v2.Text = data.mid
		v3.Text = data.mid
	end)
	task.delay(0 + v6 * 2, function()
		if not alertBillboard.Parent then
			return
		end

		v2.Text = data.final
		v3.Text = data.final
	end)
	local v7 = 0 + charge * 0.75
	local thread = nil
	task.delay(v7, function()
		if not alertBillboard.Parent then
			return
		end

		v2.Text = data.final
		v3.Text = data.final
		local v8 = os.clock() + charge * 0.25
		thread = task.spawn(function()
			local visible = false

			while alertBillboard.Parent and os.clock() < v8 do
				visible = not visible
				v2.Visible = visible
				v3.Visible = visible
				task.wait(0.05)
			end

			v2.Visible = true
			v3.Visible = true
		end)
	end)
	task.delay(0 + charge, function()
		if not alertBillboard.Parent then
			return
		end

		if thread then
			task.cancel(thread)
			thread = nil
		end

		v2.Visible = true
		v3.Visible = true
		v2.Text = data.final
		v3.Text = data.final
		v2.TextColor3 = color3
		local uIGradient = v2:FindFirstChildOfClass("UIGradient")

		if uIGradient then
			uIGradient.Color = ColorSequence.new(color3:Lerp(Color3.new(1, 1, 1), 0.15), alertDarken(color3, 0.15))
		end

		v2.TextTransparency = 0
		v3.TextTransparency = 0.35
		v4.Transparency = 0
		v5.Scale = 1
		local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
		TweenService:Create(v5, tweenInfo, {
			Scale = 1.8
		}):Play()
		TweenService:Create(v4, tweenInfo, {
			Thickness = v4.Thickness * 1.8
		}):Play()
		task.delay(0.25, function()
			if not alertBillboard.Parent then
				return
			end

			v2.Visible = false
			v3.Visible = false
			task.delay(fade + 0.1, function()
				if part.Parent then
					part:Destroy()
				end
			end)
		end)
	end)
end

local function alertDanger(parent, p: number, color4: Color3, p2, callback, flag: boolean?)
	local alertBillboard, v2, v3, v4, _, v5 = buildAlertBillboard(parent, p, color4, "⚠")
	alertBillboard.Parent = parent
	local v6 = nil
	local hold = p2.hold or 0.5
	local charge = p2.charge or 1
	TweenService:Create(alertBillboard, TweenInfo.new(0.18, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Size = uDim
	}):Play()

	if v6 then
		TweenService:Create(v6, TweenInfo.new(0.14), {
			ImageTransparency = 0
		}):Play()
	else
		TweenService:Create(v2, TweenInfo.new(0.14), {
			TextTransparency = 0
		}):Play()
		TweenService:Create(v3, TweenInfo.new(0.14), {
			TextTransparency = 0.35
		}):Play()
	end

	if callback then
		task.spawn(callback)
	end

	local studsOffsetWorldSpace = alertBillboard.StudsOffsetWorldSpace
	local thickness = v4.Thickness
	local v7 = alertDarken(color4, 0.25) -- equivalent call inferred; original call site unknown
	local v8 = alertLighten(color4, 0.2) -- equivalent call inferred; original call site unknown
	local thread = task.spawn(function()
		local lastTime = os.clock()

		while alertBillboard.Parent do
			local v9 = os.clock() - lastTime
			local v10 = math.clamp(v9 / charge, 0, 1)
			local lerped = v7:Lerp(v8, v10)

			if v6 then
				v6.ImageColor3 = lerped
			else
				local uIGradient = v2:FindFirstChildOfClass("UIGradient")

				if uIGradient then
					uIGradient.Color = ColorSequence.new(
						lerped:Lerp(Color3.new(1, 1, 1), 0.15),
						alertDarken(lerped, 0.2)
					)
				end
			end

			local v11 = v10 * 14 + 3
			local v12 = v10 * 0.4 + 0.1
			local v13 = (math.sin(v9 * v11) * 0.5 + 0.5) * v12
			v5.Scale = v13 + 1
			v4.Thickness = thickness * (v13 + 1)

			if v10 >= 1 then
				break
			else
				task.wait()
			end
		end
	end)
	task.delay(charge, function()
		if not alertBillboard.Parent then
			return
		end

		if thread then
			task.cancel(thread)
			thread = nil
		end

		if v6 then
			v6.ImageColor3 = color2
		else
			v2.TextColor3 = color2
			local uIGradient = v2:FindFirstChildOfClass("UIGradient")

			if uIGradient then
				uIGradient.Color = ColorSequence.new(color2, alertDarken(color2, 0.1))
			end
		end

		v4.Transparency = 0
		v5.Scale = 1.2
		v4.Thickness = thickness * 1.2
		local tweenInfo = TweenInfo.new(0.12, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
		TweenService:Create(v5, tweenInfo, {
			Scale = 2.2
		}):Play()
		TweenService:Create(v4, tweenInfo, {
			Thickness = thickness * 2.2
		}):Play()
		task.spawn(function()
			local v9 = os.clock() + 0.22

			while alertBillboard.Parent and os.clock() < v9 do
				alertBillboard.StudsOffsetWorldSpace = studsOffsetWorldSpace + Vector3.new(
					(math.random() - 0.5) * 1.2,
					(math.random() - 0.5) * 1.2,
					0
				)
				task.wait()
			end

			if alertBillboard.Parent then
				alertBillboard.StudsOffsetWorldSpace = studsOffsetWorldSpace
			end
		end)
		task.delay(0.14, function()
			if not alertBillboard.Parent then
				return
			end

			local tweenInfo2 = TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
			TweenService:Create(v5, tweenInfo2, {
				Scale = 1.5
			}):Play()
			TweenService:Create(v4, tweenInfo2, {
				Thickness = thickness * 1.5
			}):Play()
		end)
		task.delay(hold, function()
			if not alertBillboard.Parent then
				return
			end

			if v6 then
				v6.Visible = false
			end

			v2.Visible = false
			v3.Visible = false
			task.delay(0.05, function()
				if alertBillboard.Parent then
					alertBillboard:Destroy()
				end

				if flag and parent and parent.Parent then
					parent:Destroy()
				end
			end)
		end)
	end)
end

local function headOffset(model, p)
	local selected = p.Name == "HumanoidRootPart" and 12 or 6

	if not (model and model:IsA("Model")) then
		return selected
	end

	local success, result, v3 = pcall(function()
		return model:GetBoundingBox()
	end)

	if success and result and v3 then
		return (math.max(selected, result.Position.Y + v3.Y * 0.5 - p.Position.Y + 4))
	end

	return selected
end

local function showAlert(model, originPart, color4: Color3, warnTime: number, options, fireShape, type: string?, position: Vector3?, alertStyle: string?, fn)
	local v2 = model and model:IsA("Model") and model:FindFirstChild("HumanoidRootPart") and true or originPart and originPart.Name == "HumanoidRootPart" and true or false

	if alertStyle == "Danger" then
		alertDanger(originPart, headOffset(model, originPart), color4, options or {}, fireShape)
		return
	end

	local v3 = v[alertStyle] or v.Exclaim

	if type == "Circle" then
		alertCircle(
			position or originPart and originPart.Position or createVector(0, 0, 0),
			color4,
			options or {},
			fireShape,
			v3,
			fn
		)
	elseif v2 then
		alertCharacter(model, originPart, color4, warnTime, options or {}, fireShape, v3)
	else
		alertIndicator(originPart, color4, options or {}, fireShape, v3)
	end
end

local function fireCasterGlow(data, p: number, holdTime: number, fadeTime: number)
	local caster = data.Caster or data.OriginPart and data.OriginPart:FindFirstAncestorWhichIsA("Model")

	if data.CasterHighlight and caster then
		Effect.new("Highlight"):play({
			Model = caster,
			Type = data.CasterType,
			PartNames = data.ArmNames or { "Arm" },
			Color = data.ArmColor or data.HighlightColor or data.Color or Color3.fromRGB(255, 40, 40),
			Transparency = 0.7,
			FadeIn = p > 0 and p or 0.15,
			FreezeDuration = holdTime > 0 and holdTime or nil,
			Duration = fadeTime > 0 and fadeTime or 0.2,
			UID = caster,
			Flash = data.CasterFlash ~= false
		})
	end
end

local function spawnCircle(player)
	local circle = script.Folder:FindFirstChild("Circle")
	assert(circle, "SkillIndicator: Circle template missing")
	local clone = circle:Clone()
	applyCommon(clone, player) -- equivalent call inferred; original call site unknown
	local radius = player.Radius or 20
	local chargeTime = player.ChargeTime or 0
	local holdTime = player.HoldTime or 0
	local fadeTime = player.FadeTime or 0.25
	local size = circle.Size
	local v2 = math.min(size.Y, size.Z) * 0.5
	local v3 = v2 <= 0 and 1 or v2
	local originCF = player.OriginCF or CFrame.new()
	local originPart = player.OriginPart
	local mousePosValue = player.MousePosValue
	local ray = player.Ray ~= false
	local highlight = player.Highlight ~= false
	local highlightColor = player.HighlightColor or player.Color or Color3.fromRGB(255, 40, 40)

	-- equivalent calls inferred from this helper; original call sites unknown
	local function computeOriginCF()
		if mousePosValue and mousePosValue.Parent then
			return CFrame.new(mousePosValue.Value)
		end

		if originPart and originPart.Parent then
			return originPart.CFrame
		end

		return originCF
	end

	local function computeGroundCF(cframe: CFrame)
		if player.EndCF then
			return player.EndCF
		end

		if ray then
			return projectToGround(cframe)
		end

		return cframe
	end

	local endCF = computeOriginCF() -- equivalent call inferred; original call site unknown

	if player.EndCF then
		endCF = player.EndCF
	elseif ray then
		endCF = projectToGround(endCF)
	end

	local cframe = CFrame.Angles(0, 0, 1.5707963267948966)
	clone.CFrame = CFrame.new(endCF.Position) * cframe
	clone.Parent = _WorldOrigin or Workspace
	local thickness = player.Thickness or size.X
	local v4 = radius / v3
	local vector2 = Vector3.new(thickness, size.Y * v4, size.Z * v4)
	local vector3 = Vector3.new(thickness, math.max(vector2.Y * 0.01, 0.05), (math.max(vector2.Z * 0.01, 0.05)))
	local v5 = highlight and makeHighlighter(highlightColor) or nil
	local position = endCF.Position
	fireCasterGlow(player, chargeTime, holdTime, fadeTime)
	local heartbeatConnection = nil
	heartbeatConnection = RunService.Heartbeat:Connect(function()
		if clone.Parent then
			if mousePosValue or originPart then
				local endCF2 = computeOriginCF() -- equivalent call inferred; original call site unknown

				if player.EndCF then
					endCF2 = player.EndCF
				elseif ray then
					endCF2 = projectToGround(endCF2)
				end

				clone.CFrame = CFrame.new(endCF2.Position) * cframe
				position = endCF2.Position
			end

			if v5 then
				v5.update(position, radius)
			end
		elseif heartbeatConnection then
			heartbeatConnection:Disconnect()
			heartbeatConnection = nil
		end
	end)

	if chargeTime > 0 then
		clone.Size = vector3
		local tween = TweenService:Create(
			clone,
			TweenInfo.new(chargeTime, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
			{
				Size = vector2
			}
		)
		tween:Play()
		tween.Completed:Wait()
	else
		clone.Size = vector2
	end

	local v6 = holdTime + (player.SustainTime or 0)

	if v6 > 0 then
		task.wait(v6)
	end

	if fadeTime > 0 then
		local tween = TweenService:Create(
			clone,
			TweenInfo.new(fadeTime, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
			{
				Transparency = 1
			}
		)
		tween:Play()
		tween.Completed:Wait()
	end

	if heartbeatConnection then
		heartbeatConnection:Disconnect()
		heartbeatConnection = nil
	end

	if v5 then
		v5.clear()
	end

	clone:Destroy()
end

local function makeRectHighlighter(highlightColor: Color3)
	local v2 = {}

	local function set(p, flag: boolean)
		if flag then
			if not v2[p] then
				local highlight = Instance.new("Highlight")
				highlight.FillColor = highlightColor
				highlight.FillTransparency = 0.5
				highlight.OutlineColor = highlightColor
				highlight.OutlineTransparency = 0
				highlight.DepthMode = Enum.HighlightDepthMode.Occluded
				highlight.Adornee = p
				highlight.Parent = p
				v2[p] = highlight
			end
		else
			local v3 = v2[p]

			if v3 then
				v3:Destroy()
				v2[p] = nil
			end
		end
	end

	return {
		update = function(vector2: Vector3, vector3: Vector3, p: number, p2: number)
			local vector4 = Vector3.new(vector3.X, 0, vector3.Z)
			local v3 = vector4.Magnitude < 0.001 and createVector(0, 0, 1) or vector4.Unit
			local vector5 = Vector3.new(v3.Z, 0, -v3.X)
			local v4 = p2 * 0.5
			local v5 = {}

			for _, v6 in ipairs((gatherTargets())) do
				local humanoidRootPart = v6:FindFirstChild("HumanoidRootPart")

				if not (humanoidRootPart and humanoidRootPart:IsA("BasePart")) then
					if v6.PrimaryPart then
						humanoidRootPart = v6.PrimaryPart
					else
						humanoidRootPart = v6:FindFirstChildWhichIsA("BasePart")
					end
				end

				if not humanoidRootPart then
					continue
				end

				v5[v6] = true
				local vector6 = humanoidRootPart.Position - vector2
				local dot = vector6:Dot(v3)
				local dot2 = vector6:Dot(vector5)
				set(v6, dot >= 0 and dot <= p and math.abs(dot2) <= v4)
			end

			for k in pairs(v2) do
				if v5[k] then
					continue
				end

				local v6 = v2[k]

				if not v6 then
					continue
				end

				v6:Destroy()
				v2[k] = nil
			end
		end,
		clear = function()
			for _, v3 in pairs(v2) do
				v3:Destroy()
			end

			table.clear(v2)
		end
	}
end

local function spawnLinear(player)
	local linear = script.Folder:FindFirstChild("Linear")
	assert(linear, "SkillIndicator: Linear template missing")
	local originPart = player.OriginPart
	local originCF = player.OriginCF or originPart and originPart.Parent and originPart.CFrame or CFrame.new()
	local v2

	if originPart and originPart.Parent and originPart then
		v2 = originPart
	end

	local ray = player.Ray ~= false
	local highlight = player.Highlight ~= false
	local highlightColor = player.HighlightColor or player.Color or Color3.fromRGB(255, 40, 40)
	local clone = linear:Clone()
	clone.Parent = _WorldOrigin or Workspace
	local main = clone:WaitForChild("Main")
	local charge = clone:WaitForChild("Charge")
	local _, v3 = clone:GetBoundingBox()
	local X = v3.X
	local radius

	if player.Length == nil then
		if player.Radius == nil then
			radius = X
		else
			radius = player.Radius
		end
	else
		radius = player.Length
	end

	if radius <= 0 then
		radius = X
	end

	local scale = clone:GetScale()
	local v4 = ((scale <= 0 or scale ~= scale) and 1 or scale) * (radius / X)
	clone:ScaleTo(v4 <= 0 and 0.01 or v4)

	if player.Width and player.Width > 0 and main.Size.Z > 0 then
		local v5 = player.Width / main.Size.Z

		for _, v6 in { main, charge } do
			v6.Size = Vector3.new(v6.Size.X, v6.Size.Y, v6.Size.Z * v5)
		end
	end

	if player.Color then
		for _, folder in { main, charge } do
			folder.Color = tintToward(folder.Color, player.Color)

			for _, descendant in ipairs(folder:GetDescendants()) do
				if descendant:IsA("UIGradient") then
					local colorSequenceKeypoints = {}

					for _, keypoint in ipairs(descendant.Color.Keypoints) do
						table.insert(
							colorSequenceKeypoints,
							ColorSequenceKeypoint.new(keypoint.Time, tintToward(keypoint.Value, player.Color))
						)
					end

					descendant.Color = ColorSequence.new(colorSequenceKeypoints)
				elseif descendant:IsA("ImageLabel") then
					descendant.ImageColor3 = tintToward(descendant.ImageColor3, player.Color)
				end
			end
		end
	end

	local model = v2 and v2:FindFirstAncestorWhichIsA("Model") or originPart and originPart:FindFirstAncestorWhichIsA("Model")
	local v5 = model and { model } or nil
	local lookVector, position

	if v2 then
		lookVector = v2.CFrame.LookVector
		position = (ray and projectToGround(v2.CFrame, v5) or CFrame.new(v2.Position)).Position
	else
		lookVector = originCF.LookVector

		if ray then
			originCF = projectToGround(originCF, v5) or originCF
		end

		position = originCF.Position
	end

	local vector2 = Vector3.new(lookVector.X, 0, lookVector.Z)
	local unit = (vector2.Magnitude < 0.001 and createVector(0, 0, 1) or vector2).Unit
	local v6 = position + createVector(0, 0.05, 0)
	clone:PivotTo(CFrame.lookAt(v6, v6 + unit) * CFrame.Angles(0, 1.5707963267948966, 0) * clone:GetPivot():ToObjectSpace(main.CFrame * CFrame.new(
		-main.Size.X * 0.5,
		0,
		0
	)):Inverse())
	local Z = main.Size.Z
	local v7 = highlight and makeRectHighlighter(highlightColor) or nil
	local size = main.Size
	local cFrame = main.CFrame
	main.Size = Vector3.new(0.01, size.Y, size.Z)
	main.Transparency = 1
	local v8 = 0.2
	local v9 = 0.5
	local chargeTime = player.ChargeTime or 1
	local fadeTime = player.FadeTime or 0.25
	local v10 = v8 + v9

	if chargeTime < v10 + 0.1 then
		local v11 = math.max(chargeTime - 0.1, 0) / v10
		v8 *= v11
		v9 *= v11
	end

	local v11 = math.max(chargeTime - v8 - v9, 0.05)
	local heartbeatConnection = nil

	if v7 then
		heartbeatConnection = RunService.Heartbeat:Connect(function()
			if clone.Parent then
				local X2 = main.Size.X
				v7.update(v6, unit, X2, Z)
			elseif heartbeatConnection then
				heartbeatConnection:Disconnect()
				heartbeatConnection = nil
			end
		end)
	end

	task.spawn(function()
		task.wait(v8)
		local tweenInfo = TweenInfo.new(v9, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
		local cFrame3 = cFrame
		local rightVector = cFrame3.RightVector
		local size3 = size
		local X2 = size3.X
		local rotation = cFrame3.Rotation
		local v14 = cFrame3.Position - rightVector * (X2 * 0.5)
		main.Size = Vector3.new(0.01, size3.Y, size3.Z)
		main.CFrame = CFrame.new(v14 + rightVector * 0.005) * rotation
		main.Transparency = 1
		local cFrame4 = CFrame.new(v14 + rightVector * (X2 * 0.5)) * rotation
		TweenService:Create(main, tweenInfo, {
			Size = size3
		}):Play()
		TweenService:Create(main, tweenInfo, {
			CFrame = cFrame4
		}):Play()
		TweenService:Create(main, tweenInfo, {
			Transparency = 0.8
		}):Play()

		for _, image in pairs(main:GetDescendants()) do
			if image:IsA("ImageLabel") then
				TweenService:Create(image, tweenInfo, {
					ImageTransparency = 0
				}):Play()
			end
		end

		task.wait(v9)
		fireCasterGlow(player, v11, player.HoldTime or 0.5, fadeTime)
		local cFrame2 = charge.CFrame
		local v16 = -cFrame2.RightVector
		local size2 = charge.Size
		local rotation2 = cFrame2.Rotation
		local v17 = cFrame2.Position - v16 * (size2.X * 0.5)
		local X3 = main.Size.X
		charge.Size = Vector3.new(0.01, size2.Y, size2.Z)
		charge.CFrame = CFrame.new(v17 + v16 * 0.005) * rotation2
		local tweenInfo2 = TweenInfo.new(v11, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut)
		local vector3 = Vector3.new(X3, size2.Y, size2.Z)
		local cFrame5 = CFrame.new(v17 + v16 * (X3 * 0.5)) * rotation2
		TweenService:Create(charge, tweenInfo2, {
			Size = vector3
		}):Play()
		TweenService:Create(charge, tweenInfo2, {
			CFrame = cFrame5
		}):Play()
		task.wait(v11)
		local v19 = (player.HoldTime or 0.5) + (player.SustainTime or 0)

		if v19 > 0 then
			task.wait(v19)
		end

		local tweenInfo3 = TweenInfo.new(fadeTime, Enum.EasingStyle.Quad, Enum.EasingDirection.In)

		for _, image in pairs(main:GetDescendants()) do
			if image:IsA("ImageLabel") then
				TweenService:Create(image, tweenInfo3, {
					ImageTransparency = 1
				}):Play()
			end
		end

		TweenService:Create(main, tweenInfo3, {
			Transparency = 1
		}):Play()
		task.wait(fadeTime)

		if heartbeatConnection then
			heartbeatConnection:Disconnect()
			heartbeatConnection = nil
		end

		if v7 then
			v7.clear()
		end

		if clone.Parent then
			clone:Destroy()
		end
	end)
end

local function spawnTest(player)
	local radius = player.Radius or 16
	local chargeTime = player.ChargeTime or 0
	local holdTime = player.HoldTime or 0
	local fadeTime = player.FadeTime or 0.25
	local thickness = player.Thickness or 0.2
	local ray = player.Ray ~= false
	local originCF = player.OriginCF or CFrame.new()
	local originPart = player.OriginPart
	local mousePosValue = player.MousePosValue
	local highlight = player.Highlight ~= false
	local highlightColor = player.HighlightColor or player.Color or Color3.fromRGB(255, 40, 40)

	-- equivalent calls inferred from this helper; original call sites unknown
	local function computeOriginCF()
		if mousePosValue and mousePosValue.Parent then
			return CFrame.new(mousePosValue.Value)
		end

		if originPart and originPart.Parent then
			return originPart.CFrame
		end

		return originCF
	end

	local function computeGroundCF(cframe: CFrame)
		if player.EndCF then
			return player.EndCF
		end

		if ray then
			return projectToGround(cframe)
		end

		return cframe
	end

	local part = Instance.new("Part")
	part.Name = "TestDisc"
	part.Shape = Enum.PartType.Cylinder
	applyCommon(part, player) -- equivalent call inferred; original call site unknown
	local endCF = computeOriginCF() -- equivalent call inferred; original call site unknown

	if player.EndCF then
		endCF = player.EndCF
	elseif ray then
		endCF = projectToGround(endCF)
	end

	local position = endCF.Position

	-- equivalent calls inferred from this helper; original call sites unknown
	local function placeAt(position2: Vector3)
		part.CFrame = CFrame.new(position2) * CFrame.Angles(0, 0, 1.5707963267948966)
	end

	local vector2 = Vector3.new(thickness, radius * 2, radius * 2)
	local vector3 = Vector3.new(thickness, math.max(radius * 2 * 0.01, 0.05), (math.max(radius * 2 * 0.01, 0.05)))
	placeAt(position) -- equivalent call inferred; original call site unknown
	part.Parent = _WorldOrigin or Workspace
	local v2 = highlight and makeHighlighter(highlightColor) or nil
	local heartbeatConnection = nil
	heartbeatConnection = RunService.Heartbeat:Connect(function()
		if part.Parent then
			if mousePosValue or originPart then
				local endCF2 = computeOriginCF() -- equivalent call inferred; original call site unknown

				if player.EndCF then
					endCF2 = player.EndCF
				elseif ray then
					endCF2 = projectToGround(endCF2)
				end

				position = endCF2.Position
				placeAt(position) -- equivalent call inferred; original call site unknown
			end

			if v2 then
				v2.update(position, radius)
			end
		elseif heartbeatConnection then
			heartbeatConnection:Disconnect()
			heartbeatConnection = nil
		end
	end)

	if chargeTime > 0 then
		part.Size = vector3
		local tween = TweenService:Create(
			part,
			TweenInfo.new(chargeTime, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
			{
				Size = vector2
			}
		)
		tween:Play()
		tween.Completed:Wait()
	else
		part.Size = vector2
	end

	local v3 = holdTime + (player.SustainTime or 0)

	if v3 > 0 then
		task.wait(v3)
	end

	if fadeTime > 0 then
		local tween = TweenService:Create(
			part,
			TweenInfo.new(fadeTime, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
			{
				Transparency = 1
			}
		)
		tween:Play()
		tween.Completed:Wait()
	end

	if heartbeatConnection then
		heartbeatConnection:Disconnect()
		heartbeatConnection = nil
	end

	if v2 then
		v2.clear()
	end

	part:Destroy()
end

return function(player)
	if not player then
		warn("SkillIndicator: missing data table")
		return
	end

	if not player.OriginCF and player.OriginPart and player.OriginPart:IsA("BasePart") then
		player.OriginCF = player.OriginPart.CFrame
	end

	local v2 = (player.WarnTime or 1) + (player.ChargeTime or 1) + (player.HoldTime or 0.5)
	local charge = math.max(v2 - math.min(0.15, v2), 0.05)
	local holdTime = math.min(player.Type ~= "Circle" and 0.15 or math.min(0.35, v2 * 0.5), v2)
	player.HoldTime = holdTime
	player.ChargeTime = math.max(v2 - holdTime, 0.05)

	local function fireShape()
		if player.Type == "Circle" then
			spawnCircle(player)
		elseif player.Type == "Test" then
			spawnTest(player)
		elseif player.Type == "Linear" then
			spawnLinear(player)
		else
			warn("SkillIndicator: unknown Type", player.Type)
		end
	end

	if not player.Alert then
		fireShape()
		return
	end

	local originPart = player.OriginPart
	local character = player.Character or originPart and originPart:FindFirstAncestorWhichIsA("Model")

	if not (originPart and originPart:IsA("BasePart") and originPart) then
		originPart = character and (character:FindFirstChild("HumanoidRootPart") or character.PrimaryPart)
	end

	if not (originPart and originPart:IsA("BasePart")) then
		fireShape()
		return
	end

	local warnTime = player.WarnTime or 1
	local color4 = player.Color or color
	local v5 = {
		preDelay = 0.5,
		appear = 1,
		warn = warnTime,
		charge = charge,
		hold = player.HoldTime or 0.5,
		fade = player.FadeTime or 0.25
	}
	local position

	if player.Type == "Circle" then
		local originCF = player.OriginCF or originPart and originPart.CFrame or CFrame.new()

		if player.Ray ~= false then
			originCF = projectToGround(originCF) or originCF
		end

		position = originCF.Position
	end

	local fn = (player.Type == "Circle" or player.Type == "Test") and (player.MousePosValue or player.OriginPart) and function()
		local cframe

		if player.MousePosValue and player.MousePosValue.Parent then
			cframe = CFrame.new(player.MousePosValue.Value)
		elseif player.OriginPart and player.OriginPart.Parent then
			cframe = player.OriginPart.CFrame
		else
			cframe = player.OriginCF or CFrame.new()
		end

		if player.EndCF then
			return player.EndCF.Position
		end

		if player.Ray == false then
			return cframe.Position
		end

		return projectToGround(cframe).Position
	end or nil
	local alertStyle = player.AlertStyle or player.Type == "Circle" and "Exclaim" or "Question"
	showAlert(character, originPart, color4, warnTime, v5, fireShape, player.Type, position, alertStyle, fn)
end