local createVector = vector.create
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local TweenService = game:GetService("TweenService")
local _ = Util.Sound
local currentCamera = workspace.CurrentCamera
local FX = require(game.ReplicatedStorage.FX)
local assets = FX:WaitForChild("Pain").VHeld.Assets
local _WorldOrigin = workspace:WaitForChild("_WorldOrigin")

local function areShiftedColorsEqual(instance, childName: string, color: Color3, color2: Color3, color3: Color3)
	local child = instance:FindFirstChild(childName)

	if child == nil then
		return false
	end

	local shifted = child:FindFirstChild("Shifted")

	if shifted == nil then
		return false
	end

	local shifted_Color1 = shifted:GetAttribute("Shifted_Color1")
	local shifted_Color2 = shifted:GetAttribute("Shifted_Color2")
	local shifted_Color3 = shifted:GetAttribute("Shifted_Color3")

	if shifted_Color1 == nil or shifted_Color2 == nil or shifted_Color3 == nil then
		return false
	end

	return color == shifted_Color1 and color2 == shifted_Color2 and color3 == shifted_Color3
end

local function applyColorShiftHSV(color: Color3, p: number, p2: number, p3: number)
	local v = math.max(1, color.R, color.G, color.B)
	local v2 = math.floor(color.R / v * 255) % 256
	local v3 = math.floor(color.G / v * 255) % 256
	local v4 = math.floor(color.B / v * 255) % 256
	local HSV, v5, v6 = Color3.fromRGB(v2, v3, v4):ToHSV()
	local v7 = (HSV + p) % 1
	local v8 = math.clamp(v5 * p2, 0, 1)
	local v9 = math.clamp(v6 * p3, 0, 1)
	return Color3.fromHSV(v7, v8, v9 * v)
end

local function getColorHSVDistance(color: Color3, color2: Color3)
	local v = math.max(1, color.R, color.G, color.B)
	local v2 = math.floor(color.R / v * 255) % 256
	local v3 = math.floor(color.G / v * 255) % 256
	local v4 = math.floor(color.B / v * 255) % 256
	local color3 = Color3.fromRGB(v2, v3, v4)
	local v5 = math.max(1, color2.R, color2.G, color2.B)
	local v6 = math.floor(color2.R / v5 * 255) % 256
	local v7 = math.floor(color2.G / v5 * 255) % 256
	local v8 = math.floor(color2.B / v5 * 255) % 256
	local color4 = Color3.fromRGB(v6, v7, v8)
	local HSV, _, _ = color3:ToHSV()
	local HSV2, _, _ = color4:ToHSV()
	local v9 = math.abs(HSV2 - HSV)
	return (math.min(v9, 1 - v9))
end

local function applyColorShiftHSV2(color: Color3, p: number, p2: number, p3: number)
	if getColorHSVDistance(color, Color3.new(1, 1, 0)) > 0.1111111111111111 then
		return color
	end

	local v = math.max(1, color.R, color.G, color.B)
	local v2 = math.floor(color.R / v * 255) % 256
	local v3 = math.floor(color.G / v * 255) % 256
	local v4 = math.floor(color.B / v * 255) % 256
	local HSV, v5, v6 = Color3.fromRGB(v2, v3, v4):ToHSV()
	local v7 = (HSV + p) % 1
	local v8 = math.clamp(v5 * p2, 0, 1)
	local v9 = math.clamp(v6 * p3, 0, 1)
	return Color3.fromHSV(v7, v8, v9 * v)
end

Random.new()
local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Exclude
raycastParams.FilterDescendantsInstances = { workspace.Characters, workspace.Enemies, workspace._WorldOrigin }
local _ = {
	"rbxassetid://130452828882944",
	"rbxassetid://71120275331630",
	"rbxassetid://83529237504062",
	"rbxassetid://89359982828229",
	"rbxassetid://119164541102628",
	"rbxassetid://128504348629671",
	"rbxassetid://123584584840567"
}

local function AlignCFrame(data, normal)
	local v = not (normal and normal.Magnitude > 0 and normal) and createVector(0, 1, 0) or normal
	local p = data.p
	local unit = data.LookVector:Cross(v).Unit
	local unit2 = (unit.Magnitude > 0.001 and unit or data.RightVector).Unit
	local unit3 = unit2:Cross(v).Unit
	return CFrame.fromMatrix(p, unit2, v, unit3)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function DeleteImpactAfterDuration(folder)
	task.spawn(function()
		local v = 0

		for _, emitter in pairs(folder:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				v = math.max(v, emitter.Lifetime.Max)
			end
		end

		task.wait(v)
		folder:Destroy()
	end)
end

local function quadBezier(p, p2, p3, p4)
	return (1 - p) ^ 2 * p2 + 2 * (1 - p) * p * p3 + p ^ 2 * p4
end

local function lerp(p, p2, p3)
	return p + (p2 - p) * p3
end

function cubicBezier(p, p2, p3, p4, p5)
	local v = p2 + (p3 - p2) * p
	local v2 = p3 + (p4 - p3) * p
	local v3 = p4 + (p5 - p4) * p
	local v4 = v + (v2 - v) * p
	return v4 + (v2 + (v3 - v2) * p - v4) * p
end

local function TrailCurve(p, p2, position, position2, p3, p4, p5)
	local magnitude = (position - position2).Magnitude
	local v = (position - position2) / 2
	local position3 = CFrame.new(CFrame.new(position) * (v / -1.5)).Position
	local position4 = CFrame.new(CFrame.new(position2) * (v / 1.5)).Position
	math.random(20, 30)
	local v2 = CFrame.new(position3, position3 + p2.LookVector) * p3.Position
	local v3 = CFrame.new(position4, position4 + p2.LookVector) * p4.Position
	local lastTime = tick()
	local v4 = magnitude / p5 / 60
	local _ = (magnitude / p5 + p5) / 60

	while tick() - lastTime < v4 do
		local v5 = (tick() - lastTime) / v4
		local v6 = cubicBezier(v5, position, v2, v3, position2)
		p.CFrame = CFrame.new(p.CFrame:Lerp(CFrame.new(v6, position2), v5).Position)
		RunService.Heartbeat:Wait()
	end
end

local function fn(color: Color3, p, p2: string)
	local color3Constructor = Util.WrapColor3Constructor(color, p, p2)

	if areShiftedColorsEqual(
		p,
		"PainFruitVFXColor",
		Color3.fromRGB(255, 252, 55),
		Color3.fromRGB(95, 95, 14),
		Color3.fromRGB(255, 255, 112)
	) then
		color3Constructor = applyColorShiftHSV2(color3Constructor, 0.41666667, 1.165137614678899, 1)
	end

	return color3Constructor
end

local lightningBoltShafi = Util.LightningBoltShafi

local function ShafiBolt(player, ...)
	local v = lightningBoltShafi.new(...)
	local curveSize = -math.random(5, 35)
	local curveSize2 = math.random(5, 35)
	v.CurveSize0 = curveSize
	v.CurveSize1 = curveSize2
	v.MinRadius = 3
	v.MaxRadius = 13
	v.Frequency = 0.5
	v.AnimationSpeed = 8
	local maxThicknessMultiplier = math.random(3, 4)
	v.MinThicknessMultiplier = 0.2
	v.MaxThicknessMultiplier = maxThicknessMultiplier
	v.MinTransparency = 0
	v.MaxTransparency = 1
	v.PulseSpeed = 10
	v.PulseLength = 1000000
	v.FadeLength = 0.2
	v.ContractFrom = 0.5
	v.Color = fn(Color3.new(1, 0.380392, 0.380392), player, "PainFruitVFXColor")
	v.ColorOffsetSpeed = 3
	return v
end

local function ShafiBolt2(player, ...)
	local v = lightningBoltShafi.new(...)
	v.CurveSize0 = -50
	v.CurveSize1 = 83.33333333333333
	v.MinRadius = 0
	v.MaxRadius = 25
	v.Frequency = 25
	v.AnimationSpeed = 10
	local maxThicknessMultiplier = math.random(3, 4)
	v.MinThicknessMultiplier = 0.2
	v.MaxThicknessMultiplier = maxThicknessMultiplier
	v.MinTransparency = 0
	v.MaxTransparency = 1
	v.PulseSpeed = 10
	v.PulseLength = 1000000
	v.FadeLength = 0.2
	v.ContractFrom = 0.5
	v.Color = fn(Color3.new(1, 0.380392, 0.380392), player, "PainFruitVFXColor")
	v.ColorOffsetSpeed = 3
	return v
end

local function fn2(p, p2, p3, p4, p5)
	Util.SetParentOverrideWithColor(p, p2, p3, p4, p5)

	if areShiftedColorsEqual(
		p3,
		"PainFruitVFXColor",
		Color3.fromRGB(255, 252, 55),
		Color3.fromRGB(95, 95, 14),
		Color3.fromRGB(255, 255, 112)
	) then
		Util.AdjustObjectDescendantsColors(p, function(_, p6)
			return applyColorShiftHSV2(p6, 0.41666667, 1.165137614678899, 1) or p6
		end)
	end
end

local function RingBeam(player, cFrame, child, scale)
	local clone = assets.Phase2.RingBeamModel:Clone()
	local v = TweenService
	local cFrame2 = cFrame * CFrame.new(0, 0, -50)
	clone.PrimaryPart.CFrame = cFrame2
	fn2(clone, child, player, "PainFruitVFXColor")
	local v3 = {}

	for _, beam in pairs(clone:GetDescendants()) do
		if not beam:IsA("Beam") then
			continue
		end

		local v4 = beam
		task.spawn(function()
			local v5 = v:Create(v4, TweenInfo.new(0.035, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0), {
				Width0 = v4.Width0 * 5,
				Width1 = v4.Width1 * 5
			})
			v5:Play()
			v5.Completed:Wait()
			local v6 = v:Create(v4, TweenInfo.new(0.05, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0), {
				Width0 = v4.Width0 * 10,
				Width1 = v4.Width1 * 10
			})
			v6:Play()
			v6.Completed:Wait()
			v:Create(v4, TweenInfo.new(0.035, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0), {
				Width0 = v4.Width0 * 0,
				Width1 = v4.Width1 * 0
			}):Play()
		end)
		v3[beam] = beam
	end

	task.spawn(function()
		local v4 = v:Create(
			clone.PrimaryPart,
			TweenInfo.new(0.125, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
			{
				CFrame = clone.PrimaryPart.CFrame * CFrame.new(0, 0, 112.5)
			}
		)
		v4:Play()
		v4.Completed:Wait()
		v:Create(clone.PrimaryPart, TweenInfo.new(0.075, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
			CFrame = clone.PrimaryPart.CFrame * CFrame.new(0, 0, 37.5)
		}):Play()
	end)
	local numberValue = Instance.new("NumberValue")
	numberValue.Value = 0.0001
	fn2(numberValue, clone, player, "PainFruitVFXColor")
	v:Create(numberValue, TweenInfo.new(0.35), {
		Value = 0.1
	}):Play()
	task.spawn(function()
		clone:ScaleTo(scale)
		local scale2 = clone:GetScale()
		local v4 = scale2 * 2.35
		local total = 0

		while total < 0.5 do
			total += RunService.Heartbeat:Wait()
			local v5 = math.clamp(total / 0.5, 0, 1)
			clone:ScaleTo(scale2 + (v4 - scale2) * v5)
		end
	end)
end

local function RingBeamS(player, cFrame, child, scale)
	local clone = assets.Phase2.RingBeamModel:Clone()
	local v = TweenService
	local cFrame2 = cFrame * CFrame.new(0, 0, -100)
	clone.PrimaryPart.CFrame = cFrame2
	fn2(clone, child, player, "PainFruitVFXColor")

	if areShiftedColorsEqual(
		player,
		"PainFruitVFXColor",
		Color3.fromRGB(255, 146, 220),
		Color3.fromRGB(128, 183, 255),
		Color3.fromRGB(85, 170, 255)
	) then
		Util.AdjustObjectDescendantsColors(clone, function(_, p)
			if math.random() > 0.5 then
				p = applyColorShiftHSV(p, 0.7076380848884583, 1.165137614678899, 1) or p
			end

			return p
		end)
	end

	local v3 = {}

	for _, beam in pairs(clone:GetDescendants()) do
		if not beam:IsA("Beam") then
			continue
		end

		local v4 = beam
		task.spawn(function()
			local v5 = v:Create(v4, TweenInfo.new(0.035, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0), {
				Width0 = v4.Width0 * 3,
				Width1 = v4.Width1 * 3
			})
			v5:Play()
			v5.Completed:Wait()
			local v6 = v:Create(v4, TweenInfo.new(0.085, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0), {
				Width0 = v4.Width0 * 5,
				Width1 = v4.Width1 * 5
			})
			v6:Play()
			v6.Completed:Wait()
			v:Create(v4, TweenInfo.new(0.05, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0), {
				Width0 = v4.Width0 * 0,
				Width1 = v4.Width1 * 0
			}):Play()
		end)
		v3[beam] = beam
	end

	task.spawn(function()
		local v4 = v:Create(
			clone.PrimaryPart,
			TweenInfo.new(0.125, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
			{
				CFrame = clone.PrimaryPart.CFrame * CFrame.new(0, 0, 63.75)
			}
		)
		v4:Play()
		v4.Completed:Wait()
		v:Create(clone.PrimaryPart, TweenInfo.new(0.075, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
			CFrame = clone.PrimaryPart.CFrame * CFrame.new(0, 0, 21.25)
		}):Play()
	end)
	local numberValue = Instance.new("NumberValue")
	numberValue.Value = 0.0001
	fn2(numberValue, clone, player, "PainFruitVFXColor")
	v:Create(numberValue, TweenInfo.new(0.35), {
		Value = 0.1
	}):Play()
	task.spawn(function()
		clone:ScaleTo(scale)
		local scale2 = clone:GetScale()
		local v4 = scale2 * 2.35
		local total = 0

		while total < 0.5 do
			total += RunService.Heartbeat:Wait()
			local v5 = math.clamp(total / 0.5, 0, 1)
			clone:ScaleTo(scale2 + (v4 - scale2) * v5)
		end
	end)
end

Util.ResizeModel(assets.Phase0.HoldBall.Aura2, 0.5)
return function(data)
	local player = data.Player
	local origin = data.Origin

	if (currentCamera.CFrame.p - origin).Magnitude > 700 then
		return
	end

	local stage = data.Stage

	if stage == 1 then
		local holding = data.Holding

		if not (holding and holding.Value) then
			return
		end

		local folder = Instance.new("Folder")
		fn2(folder, _WorldOrigin, player, "PainFruitVFXColor")
		folder.Name = "PainVBall_" .. data.Player.Name
		local v = { "rbxassetid://139968635569467", "rbxassetid://110931244887804" }
		local root = data.Root
		local cFrame = root.CFrame
		local v2 = root:GetAttribute("PainSkin") and root:GetAttribute("PainSkin") == "PAINSKINsuperspirit"
		Random.new()
		local clone = assets.Phase0.HoldBall:Clone()
		clone:PivotTo(root.CFrame * CFrame.new(0, 2, -12))
		fn2(clone, folder, player, "PainFruitVFXColor")

		if v2 then
			pcall(function()
				local hacker = assets.Phase0.Hacker
				clone.PainBall.Attachment:Destroy()
				local clone_2 = hacker.Attachment:Clone()
				clone_2.Parent = clone.PainBall
			end)
		end

		clone:ScaleTo(0.05)
		local clone2 = assets.Phase0A.Aura:Clone()
		clone2.CFrame = cFrame
		fn2(clone2, folder, player, "PainFruitVFXColor")

		if areShiftedColorsEqual(
			player,
			"PainFruitVFXColor",
			Color3.fromRGB(255, 146, 220),
			Color3.fromRGB(128, 183, 255),
			Color3.fromRGB(85, 170, 255)
		) then
			Util.AdjustObjectDescendantsColors(clone2, function(_, p)
				if math.random() > 0.5 then
					p = applyColorShiftHSV(p, 0.7076380848884583, 1.165137614678899, 1) or p
				end

				return p
			end)
		end

		clone2.Anchored = false
		clone2.Massless = true
		clone2.Weld.Part1 = root

		for _, emitter in pairs(clone2:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter.Enabled = true
			end
		end

		local numberValue = Instance.new("NumberValue")
		numberValue.Value = clone:GetScale()
		fn2(numberValue, clone, player, "PainFruitVFXColor")
		numberValue.Changed:Connect(function(p)
			clone:ScaleTo(p)
		end)
		local clone3 = assets.Phase0.GrowModel:Clone()
		clone3.PrimaryPart.CFrame = clone.PrimaryPart.CFrame
		fn2(clone3, folder, player, "PainFruitVFXColor")
		clone3:ScaleTo(0.75)

		for _, emitter in pairs(clone3:GetDescendants()) do
			if not emitter:IsA("ParticleEmitter") then
				continue
			end

			local v3 = emitter
			task.spawn(function()
				if v3:GetAttribute("EmitDelay") ~= 0 then
					task.wait(v3:GetAttribute("EmitDelay"))
				end

				v3:Emit(v3:GetAttribute("EmitCount"))
			end)
		end

		task.spawn(function()
			local bubbleModule = Util.BubbleModule
			task.spawn(function()
				bubbleModule.CreateBubble(
					player,
					clone.PrimaryPart.CFrame,
					createVector(10, 10, 10),
					6,
					createVector(50, 50, 50),
					0.1,
					folder
				)
			end)
		end)
		TweenService:Create(numberValue, TweenInfo.new(0.5, Enum.EasingStyle.Back), {
			Value = 0.75
		}):Play()
		clone.PrimaryPart.Anchored = true
		local primaryPart = clone.PrimaryPart
		task.spawn(function()
			pcall(function()
				while primaryPart and primaryPart:IsDescendantOf(workspace) and primaryPart and primaryPart:IsDescendantOf(workspace) do
					if primaryPart:GetAttribute("Cooked") then
						primaryPart.Attachment.Background.Enabled = false
						break
					end

					primaryPart.Attachment.Background.Enabled = false
					primaryPart.Attachment.Background:Clear()
					primaryPart.Attachment.Background:Emit()
					task.wait()
				end
			end)
		end)
		Util.Sound:Play("V_Activate_09_V1", root)
		local v3 = Util.Sound:Play("V_Held_Loop_01_V1", root)
		TweenService:Create(v3, TweenInfo.new(0.6), {
			Volume = 1
		}):Play()

		for _, emitter in pairs(clone:GetDescendants()) do
			if not emitter:IsA("ParticleEmitter") then
				continue
			end

			if emitter.Parent.Name == "AngryMark" then
				emitter.Enabled = false
			elseif emitter:IsDescendantOf(clone.Aura) or emitter:IsDescendantOf(clone.Aura2) then
				emitter.Enabled = false
			else
				emitter.Enabled = true
			end

			emitter:Emit(1)
		end

		clone.PrimaryPart.Attachment3.Particle_:Emit(1)
		tick()
		local clone4 = assets.Phase0.ChargeEmit:Clone()
		clone4.CFrame = clone.PrimaryPart.CFrame
		fn2(clone4, folder, player, "PainFruitVFXColor")
		local v4 = false

		for _, emitter in pairs(clone4:GetDescendants()) do
			if not emitter:IsA("ParticleEmitter") then
				continue
			end

			local v5 = emitter
			task.spawn(function()
				if v5:GetAttribute("EmitDelay") ~= 0 then
					task.wait(v5:GetAttribute("EmitDelay"))
				end

				v5:Emit(v5:GetAttribute("EmitCount"))
			end)
		end

		task.spawn(function()
			local clone5 = assets.Phase0.AuraOrbModel:Clone()
			clone5.PrimaryPart.CFrame = clone.PrimaryPart.CFrame
			fn2(clone5, folder, player, "PainFruitVFXColor")
			clone5:ScaleTo(clone:GetScale())

			for _, emitter in pairs(clone5:GetDescendants()) do
				if emitter:IsA("ParticleEmitter") then
					emitter.Enabled = true
				end
			end

			local scale = clone:GetScale()
			local total = 0

			while total < 0.35 do
				total += RunService.Heartbeat:Wait()

				if holding.Value == false or not holding:IsDescendantOf(workspace) then
					break
				end

				local v5 = math.clamp(total / 0.35, 0, 1)
				local _ = scale + (1 - scale) * v5
				clone5.PrimaryPart.CFrame = clone.PrimaryPart.CFrame
				clone5:ScaleTo(clone:GetScale())
			end

			for _, emitter in pairs(clone5:GetDescendants()) do
				if emitter:IsA("ParticleEmitter") then
					emitter.Enabled = false
				end
			end
		end)
		local flag = false
		local childAddedConnection = nil
		childAddedConnection = root.ChildAdded:Connect(function(child)
			if child.Name == "PainVTrigger" then
				flag = true

				if v3 then
					Util.Sound:FadeOut(v3, 0.2)
				end

				Util.Sound:Play("V_GiantBall_Transition_03", root)
				v3 = Util.Sound:Play("V_MassiveBall_Held_01", root)
				TweenService:Create(v3, TweenInfo.new(1.2), {
					Volume = 1
				}):Play()
				childAddedConnection:Disconnect()
			end
		end)
		local now = tick()
		local now2 = tick()
		local now3 = tick()
		local v5 = 0.016666666666666666
		local model = nil

		while true do
			local cFrame2 = root.CFrame

			if clone and now < tick() then
				if flag then
					local v6 = math.min(6 + 1 * (clone:GetScale() * 12), 50)
					clone:PivotTo(clone:GetPivot():Lerp(root.CFrame * CFrame.new(0, v6, 0), v5 * 4))
				else
					local scale = clone:GetScale()
					clone:PivotTo(root.CFrame * CFrame.new(0, 2, -12 - 1 * (scale * 1.5)))
				end
			end

			if v4 == false and flag then
				v4 = true
				now = tick() + 0.25
				now2 = tick()
				now3 = tick()
				task.spawn(function()
					local bubbleModule = Util.BubbleModule
					task.spawn(function()
						bubbleModule.CreateBubble(
							player,
							clone.PrimaryPart.CFrame,
							createVector(10, 10, 10),
							6,
							createVector(60, 60, 60),
							0.25,
							folder
						)
					end)
					task.spawn(function()
						bubbleModule.CreateBubble(
							player,
							clone.PrimaryPart.CFrame,
							createVector(80, 80, 80),
							15,
							createVector(10, 10, 10),
							0.2,
							folder
						)
					end)
				end)
				model = Instance.new("Model")
				fn2(model, folder, player, "PainFruitVFXColor")
				model:ScaleTo(1)
				task.spawn(function()
					local scale = model:GetScale()
					local v6 = scale * 2.85
					local total = 0

					while total < 3 do
						total += RunService.Heartbeat:Wait()
						local v7 = math.clamp(total / 3, 0, 1)
						local v8 = scale + (v6 - scale) * v7
						model:ScaleTo(v8)
					end

					model:ScaleTo(v6)
				end)
				task.spawn(function()
					local position = cFrame2.Position
					local raycastResult = workspace:Raycast(
						position + createVector(0, 1, 0),
						createVector(-0, -10, -0),
						raycastParams
					)

					if raycastResult then
						local clone5 = assets.Phase0A.FloorAura:Clone()
						clone5.CFrame = AlignCFrame(CFrame.new(raycastResult.Position), raycastResult.Normal) + raycastResult.Normal * 1

						for _, emitter in pairs(clone5:GetDescendants()) do
							if emitter:IsA("ParticleEmitter") then
								emitter.Enabled = true
							end
						end

						fn2(clone5, model, player, "PainFruitVFXColor")
					end
				end)
				local clone5 = assets.Phase0.GrowModel:Clone()
				clone5.PrimaryPart.CFrame = clone.PrimaryPart.CFrame
				fn2(clone5, folder, player, "PainFruitVFXColor")
				clone5:ScaleTo(clone:GetScale() * 1.25)

				for _, emitter in pairs(clone5:GetDescendants()) do
					if not emitter:IsA("ParticleEmitter") then
						continue
					end

					local v6 = emitter
					task.spawn(function()
						if v6:GetAttribute("EmitDelay") ~= 0 then
							task.wait(v6:GetAttribute("EmitDelay"))
						end

						v6:Emit(v6:GetAttribute("EmitCount"))
					end)
				end

				TweenService:Create(clone.Weld, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
					C1 = CFrame.new(0, 20, 0)
				}):Play()

				if root.Parent == game.Players.LocalPlayer.Character then
					Util.CameraShaker:ShakeOnce(5, 5, 0.1, 0.4)
					local screenColorPV = assets.Phase0.ScreenColorPV
					local colorCorrectionEffect = Instance.new("ColorCorrectionEffect")
					colorCorrectionEffect.Name = screenColorPV.Name
					fn2(colorCorrectionEffect, game.Lighting, player, "PainFruitVFXColor")
					TweenService:Create(colorCorrectionEffect, TweenInfo.new(0.1), {
						Brightness = screenColorPV.Brightness,
						Contrast = screenColorPV.Contrast,
						Saturation = screenColorPV.Saturation,
						TintColor = screenColorPV.TintColor
					}):Play()
					task.delay(0.15, function()
						TweenService:Create(colorCorrectionEffect, TweenInfo.new(0.15), {
							TintColor = fn(Color3.fromRGB(255, 255, 255), player, "PainFruitVFXColor"),
							Brightness = 0,
							Contrast = 0,
							Saturation = 0
						}):Play()
						task.wait(0.15)
						colorCorrectionEffect:Destroy()
					end)
				end

				task.spawn(function()
					if not (holding:IsDescendantOf(workspace) and holding.Value) then
						return
					end

					local lastTime = tick()

					-- equivalent calls inferred from this helper; original call sites unknown
					local function wave()
						return math.cos((tick() - lastTime) * 3.141592653589793 * 6) * 0.075 + 1
					end

					local scale = clone:GetScale()
					local total = 0

					while total < 0.35 do
						total += RunService.Heartbeat:Wait()

						if not (holding:IsDescendantOf(workspace) and holding.Value) then
							break
						end

						local v6 = math.clamp(total / 0.35, 0, 1)
						local v7

						if v6 < 0.7 then
							v7 = scale + (1.5 - scale) * (v6 / 0.7)
						else
							v7 = (v6 - 0.7) / 0.3 * -0.5 + 1.5
						end

						clone:ScaleTo(v7 * wave())
					end

					local total2 = 0
					local v6 = 2.85

					while total2 < 2 do
						total2 += RunService.Heartbeat:Wait()

						if holding:IsDescendantOf(workspace) and holding.Value and not holding:GetAttribute("StopGrowing") then
							local v7 = math.clamp(total2 / 2, 0, 1)
							clone:ScaleTo(((v6 - 1) * v7 + 1) * wave())
						else
							break
						end
					end

					local scale2 = clone:GetScale()

					while clone:IsDescendantOf(workspace) do
						RunService.Heartbeat:Wait()
						clone:ScaleTo(scale2 * wave())
					end
				end)
			end

			if v4 == true and flag then
				if now2 - tick() <= 0 then
					now2 = tick() + 0.25
					local clone5 = assets.Phase0A.SpinSlash:Clone()
					clone5:PivotTo(root.CFrame)
					fn2(clone5, model, player, "PainFruitVFXColor")
					local v6 = math.random(1, 2)

					for _, beam in pairs(clone5:GetDescendants()) do
						if beam:IsA("Beam") then
							beam.Texture = v[v6]
						end
					end

					local scale = model:GetScale()
					clone5:ScaleTo(scale * 0.1)
					local primaryPart2 = clone5.PrimaryPart
					local v7 = clone5.PrimaryPart.CFrame * CFrame.new(0, scale / 2, 0) * CFrame.Angles(
						0,
						math.rad((math.random(-180, 180))),
						0
					)
					local angularVelocity = primaryPart2.AngularVelocity
					primaryPart2.Anchored = false
					primaryPart2.AlignPosition.Responsiveness = 10
					primaryPart2.AlignPosition.Position = primaryPart2.Position + createVector(0, 0, 0)
					angularVelocity.AngularVelocity = Vector3.new(0, -math.random(10, 15) * 2, 0)
					clone5:PivotTo(v7)
					primaryPart2.AlignPosition.Enabled = true
					angularVelocity.Enabled = true
					clone5:GetScale()
					local folder2 = clone5
					task.spawn(function()
						task.spawn(function()
							TweenService:Create(
								angularVelocity,
								TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
								{
									AngularVelocity = angularVelocity.AngularVelocity + Vector3.new(
										math.random(-5, 5) / 2,
										-math.random(5, 15),
										math.random(-5, 5) / 2
									)
								}
							):Play()
						end)
						task.wait(0.035 * math.random() + 0.1)

						for i, effect in pairs(folder2:GetDescendants()) do
							if effect:IsA("Beam") then
								TweenService:Create(effect, TweenInfo.new(0.5 / (i / 2.5)), {
									Width0 = 0,
									Width1 = 0
								}):Play()
								local v9 = effect
								task.delay(1, function()
									v9:Destroy()
								end)
							elseif effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
								effect.Enabled = false
							end
						end

						task.wait(1)
						angularVelocity.Enabled = false
					end)
					task.spawn(function()
						local scale2 = clone5:GetScale()
						local v11 = scale
						local v12 = v11 * 1.05
						local total = 0

						while total < 0.25 do
							total += RunService.Heartbeat:Wait()
							local v13 = math.clamp(total / 0.25, 0, 1)
							local v14

							if v13 < 0.7 then
								v14 = scale2 + (v12 - scale2) * (v13 / 0.7)
							else
								v14 = v12 + (v11 - v12) * ((v13 - 0.7) / 0.3)
							end

							clone5:ScaleTo(v14)
						end

						clone5:ScaleTo(v11)
						local scale3 = clone5:GetScale()
						local v13 = scale3 * 1.25

						for i = scale3 * 100, v13 * 100, 5 do
							clone5:ScaleTo(i / 100)
							task.wait(0.005)
						end
					end)
				end

				if now3 - tick() <= 0 then
					now3 = tick() + 0.75
					local clone5 = assets.Phase0A.MinionSpin:Clone()
					clone5:PivotTo(root.CFrame)
					fn2(clone5, model, player, "PainFruitVFXColor")
					local v6 = math.random(1, 3)

					for _, beam in pairs(clone5:GetDescendants()) do
						if beam:IsA("Beam") then
							beam.Texture = v[v6]
						end
					end

					local scale = model:GetScale()
					clone5:ScaleTo(scale)
					local primaryPart2 = clone5.PrimaryPart
					local v7 = clone5.PrimaryPart.CFrame * CFrame.new(0, scale / 2, 0) * CFrame.Angles(
						0,
						math.rad((math.random(-180, 180))),
						0
					)
					local angularVelocity = primaryPart2.AngularVelocity
					primaryPart2.Anchored = false
					primaryPart2.AlignPosition.Responsiveness = 10
					primaryPart2.AlignPosition.Position = primaryPart2.Position + createVector(0, 0, 0)
					angularVelocity.AngularVelocity = Vector3.new(0, -math.random(10, 15) * 0.2, 0)
					clone5:PivotTo(v7)
					primaryPart2.AlignPosition.Enabled = true
					angularVelocity.Enabled = true
					clone5:GetScale()
					local folder2 = clone5
					task.spawn(function()
						task.spawn(function()
							TweenService:Create(
								angularVelocity,
								TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
								{
									AngularVelocity = angularVelocity.AngularVelocity + Vector3.new(
										math.random(-5, 5) / 2,
										-math.random(5, 15),
										math.random(-5, 5) / 2
									)
								}
							):Play()
						end)
						task.wait(0.035 * math.random() + 1)
						local clone6 = assets.Phase0A.EndModel:Clone()
						local endImpact = clone6.EndImpact
						endImpact.CFrame = folder2.model.RootPart.CFrame
						fn2(clone6, folder, player, "PainFruitVFXColor")
						clone6:ScaleTo(folder2:GetScale())

						for i, emitter in pairs(endImpact:GetDescendants()) do
							if emitter:IsA("ParticleEmitter") then
								emitter:Emit(emitter:GetAttribute("EmitCount"))
							end
						end

						for i, descendant in pairs(folder2:GetDescendants()) do
							if descendant:IsA("Beam") then
								TweenService:Create(descendant, TweenInfo.new(0.5 / (i / 2.5)), {
									Width0 = 0,
									Width1 = 0
								}):Play()
								local v9 = descendant
								task.delay(1, function()
									v9:Destroy()
								end)
							elseif descendant:IsA("ParticleEmitter") or descendant:IsA("Trail") then
								descendant.Enabled = false
							elseif descendant:IsA("MeshPart") then
								descendant.Transparency = 1
							end
						end

						task.wait(1)
						angularVelocity.Enabled = false
					end)
					task.spawn(function()
						local scale2 = clone5:GetScale()
						local v10 = scale2 * 1.25

						for i = scale2 * 100, v10 * 100, 5 do
							clone5:ScaleTo(i / 100)
							task.wait(0.005)
						end
					end)
				end
			end

			v5 = task.wait()

			if holding:IsDescendantOf(workspace) and holding.Value then
				continue
			end

			if v3 then
				Util.Sound:FadeOut(v3, 0.2)
			end

			for _, emitter in pairs(clone2:GetDescendants()) do
				if emitter:IsA("ParticleEmitter") then
					emitter.Enabled = false
				end
			end

			if model then
				for _, emitter in pairs(model:GetDescendants()) do
					if emitter:IsA("ParticleEmitter") then
						emitter.Enabled = false
					end
				end
			end

			if childAddedConnection then
				childAddedConnection:Disconnect()
			end

			Util.Debris:AddItem(folder, 10)
			local primaryPart2 = clone.PrimaryPart

			for _, emitter in pairs(primaryPart2:GetDescendants()) do
				if emitter:IsA("ParticleEmitter") and emitter.Parent.Name == "AngryMark" then
					emitter.Enabled = true
				end
			end

			return
		end
	elseif stage == 2 then
		local child = workspace._WorldOrigin:FindFirstChild("PainVBall_" .. data.Player.Name)
		local proxy = data.Proxy

		if not proxy then
			return
		end

		local holdBall, painBall

		if child then
			holdBall = child:FindFirstChild("HoldBall")
			holdBall.Weld.Enabled = false
			painBall = child:FindFirstChild("HoldBall").PainBall
			painBall.CFrame = data.StartCFrame
			painBall.Anchored = true
		else
			holdBall = assets.Phase0.HoldBall:Clone()
			holdBall.Weld.Enabled = false
			painBall = holdBall.PainBall
			painBall.CFrame = data.StartCFrame
			painBall.Anchored = true
			fn2(painBall, child, player, "PainFruitVFXColor")

			if data.Root then
				pcall(function()
					if data.Root:GetAttribute("PainSkin") and data.Root:GetAttribute("PainSkin") == "PAINSKINsuperspirit" then
						local hacker = assets.Phase0.Hacker
						holdBall.PainBall.Attachment:Destroy()
						local clone = hacker.Attachment:Clone()
						clone.Parent = holdBall.PainBall
					end
				end)
			end

			holdBall:ScaleTo(0.75)
		end

		child.Name = "Destroying"
		local root = data.Root
		Util.Sound:Play("V_Launch_Massive_02", root)

		for _, emitter in pairs(painBall:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") and emitter.Parent.Name == "AngryMark" then
				emitter.Enabled = true
			end
		end

		if holdBall:FindFirstChild("Aura2") then
			for _, emitter in pairs(holdBall:GetDescendants()) do
				if emitter:IsA("ParticleEmitter") and emitter:IsDescendantOf(holdBall.Aura2) then
					emitter.Enabled = true
				end
			end
		end

		local raycastResult = nil
		local clone = assets.Phase1.FloorEffect:Clone()
		local primaryPart = clone.PrimaryPart
		primaryPart.CFrame = root.CFrame
		fn2(clone, child, player, "PainFruitVFXColor")
		clone:ScaleTo(holdBall:GetScale() / 2.5)
		local v = false
		local lifetime = data.Lifetime
		local lifetime2 = data.Lifetime
		local v2 = data.Dist / lifetime2
		local total = 0
		local v3 = false
		local v4 = nil
		local v5 = 0
		local heartbeatConnection = nil
		heartbeatConnection = RunService.Heartbeat:Connect(function(dt)
			if proxy:IsDescendantOf(workspace) then
				total += dt
				local v6 = v2 * dt
				local Y = painBall.Size.Y
				local ray, v7, v8 = Util.Ray(
					painBall.Position + createVector(0, 1, 0) * Y * 0.5,
					createVector(-0, -1, -0) * (Y + 1),
					{ workspace._WorldOrigin, workspace.Characters, workspace.Enemies }
				)

				if ray then
					local v9 = v7.Y + Y * 0.5 + 0
					v3 = true
					v4 = math.max(v4 or -1e999, v9)
				end

				local v9 = 0

				if v3 and v4 then
					local Y2 = painBall.Position.Y

					if Y2 < v4 then
						v9 = math.min(v2 * dt, v4 - Y2)
					elseif not select(
						1,
						Util.Ray(
							painBall.Position + createVector(0, 1, 0) * Y * 0.5,
							createVector(-0, -1, -0) * (Y + 1),
							{ workspace._WorldOrigin, workspace.Characters, workspace.Enemies }
						)
					) then
						v3 = false
						v4 = nil
					end
				end

				local v10 = math.clamp(dt * 6, 0, 1)
				local v11 = math.max(0, v5 + (v9 - v5) * v10)
				local lookVector = painBall.CFrame.LookVector
				local v12 = lookVector * v6
				local vector2 = Vector3.new(0, v11, 0)
				local v13 = painBall.Position + v12 + vector2

				if ray then
					painBall.CFrame = Util.Misc.AlignCFrame(CFrame.lookAt(v13, v13 + lookVector), v8)
				else
					painBall.CFrame = CFrame.lookAt(v13, v13 + lookVector)
				end

				v5 = v11

				if lifetime2 <= total then
					heartbeatConnection:Disconnect()
				end
			elseif heartbeatConnection then
				heartbeatConnection:Disconnect()
			end
		end)
		task.spawn(function()
			local v6 = tick() + lifetime

			repeat
				local position = raycastResult and raycastResult.Position
				raycastResult = workspace:Raycast(
					painBall.Position + Vector3.new(0, painBall.Size.Y / 2, 0),
					Vector3.new(0, -painBall.Size.Y * 2, 0),
					raycastParams
				)
				local position2 = raycastResult and raycastResult.Position

				if position and position2 then
					primaryPart.CFrame = CFrame.lookAt(position2, position)

					if v == false then
						for _, emitter in pairs(primaryPart:GetDescendants()) do
							if emitter:IsA("ParticleEmitter") then
								emitter.Enabled = true
							end
						end

						v = true
					end
				elseif v == true then
					for _, emitter in pairs(primaryPart:GetDescendants()) do
						if emitter:IsA("ParticleEmitter") then
							emitter.Enabled = false
						end
					end
				end

				task.wait(0.015)
			until v6 - tick() <= 0
		end)
		RingBeam(player, painBall.CFrame, child, holdBall:GetScale())
		local clone2 = assets.Phase1.ThrowImpactModel:Clone()
		local primaryPart2 = clone2.PrimaryPart
		primaryPart2.CFrame = holdBall.PrimaryPart.CFrame * CFrame.new(0, 0, -(25 + painBall.Size.Z / 1.5))
		fn2(clone2, child, player, "PainFruitVFXColor")
		clone2:ScaleTo(holdBall:GetScale())

		for _, emitter in pairs(clone2:GetDescendants()) do
			if not emitter:IsA("ParticleEmitter") then
				continue
			end

			local v6 = emitter
			task.spawn(function()
				if v6:GetAttribute("EmitDelay") ~= 0 then
					task.wait(v6:GetAttribute("EmitDelay"))
				end

				v6:Emit(v6:GetAttribute("EmitCount"))
			end)
		end

		local v6 = true
		task.spawn(function()
			repeat
				RingBeamS(player, painBall.CFrame, child, holdBall:GetScale())
				task.wait(0.5)
			until v6 == false
		end)
		local v7 = tick() + lifetime2

		repeat
			task.wait()
		until v7 < tick() or not data.Proxy:IsDescendantOf(workspace)

		v6 = false
		painBall:SetAttribute("Cooked", true)
		local cFrame2 = painBall.CFrame

		for _, emitter in pairs(holdBall:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter.Enabled = false
			end
		end

		for _, emitter in pairs(primaryPart:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter.Enabled = false
			end
		end

		local clone3 = assets.Phase2.ImpactModel:Clone()
		clone3.PrimaryPart.CFrame = cFrame2
		fn2(clone3, child, player, "PainFruitVFXColor")
		clone3:ScaleTo(holdBall:GetScale())
		Util.Sound:Play("V_MassiveBall_Explosion_01", cFrame2.Position)

		for _, emitter in pairs(clone3:GetDescendants()) do
			if not emitter:IsA("ParticleEmitter") then
				continue
			end

			local v8 = emitter
			task.spawn(function()
				if v8:GetAttribute("EmitDelay") ~= 0 then
					task.wait(v8:GetAttribute("EmitDelay"))
				end

				v8:Emit(v8:GetAttribute("EmitCount"))
			end)
		end

		task.wait(0.1)
		local clone4 = assets.Phase2.CircleModel:Clone()
		clone4.PrimaryPart.CFrame = cFrame2
		fn2(clone4, child, player, "PainFruitVFXColor")
		clone4:ScaleTo(holdBall:GetScale() / 1.5)

		for _, emitter in pairs(clone4:GetDescendants()) do
			if not emitter:IsA("ParticleEmitter") then
				continue
			end

			local v8 = emitter
			task.spawn(function()
				v8:Emit(1)

				if v8.Parent.Name == "Attachment1" then
					v8.Enabled = false
					task.spawn(function()
						task.wait(0.19)

						if v8 == nil then
						end
					end)
				else
					v8.Enabled = true
				end

				task.wait(0.5)
				v8.Enabled = false
				v8:Destroy()
			end)
		end

		task.spawn(function()
			for i = 1, 15 do
				local clone5 = FX:WaitForChild("Pain").VHeld.Part:Clone()
				clone5.CFrame = cFrame2 * CFrame.Angles(
					math.rad((math.random(-180, 180))),
					math.rad((math.random(-180, 180))),
					(math.rad((math.random(-180, 180))))
				) * CFrame.new(0, 0, -painBall.Size.X)
				fn2(clone5, child, player, "PainFruitVFXColor")
				clone5.Attach1.WorldPosition = cFrame2.Position
				local shafiBolt = ShafiBolt(player, clone5.Attach0, clone5.Attach1, math.random(5, 8), 1, child)

				if i % 2 == 0 then
					shafiBolt.Color = fn(Color3.fromRGB(181, 40, 40), player, "PainFruitVFXColor")
					shafiBolt.Thickness = 0.65
				end

				task.spawn(function()
					task.wait(0.175 + math.random() * 0.25)
					shafiBolt:Destroy()
				end)
				task.wait(0.05)
			end
		end)
		local raycastResult2 = workspace:Raycast(
			cFrame2.Position + createVector(0, 1, 0),
			createVector(-0, -300, -0),
			raycastParams
		)
		task.spawn(function()
			local v8 = tick() + 0.5

			repeat
				for _ = 1, math.random(1, 3) do
					local clone5 = assets.Phase2.Beam:Clone()
					clone5.CFrame = cFrame2
					fn2(clone5, child, player, "PainFruitVFXColor")
					clone5.CFrame *= CFrame.Angles(
						math.rad((math.random(-180, 180))),
						math.rad((math.random(-180, 180))),
						(math.rad((math.random(-180, 180))))
					) * CFrame.new(0, 0, -painBall.Size.Z / 1.15)
					local _ = 0.105 * math.random() + 0.105

					for _, beam in pairs(clone5:GetDescendants()) do
						if beam:IsA("Beam") then
							local v9 = beam
							task.spawn(function()
								local curveSize = math.random(25, 50)
								local curveSize2 = -math.random(25, 50) * 2
								v9.CurveSize0 = curveSize
								v9.CurveSize1 = curveSize2
								local tween = TweenService:Create(
									v9,
									TweenInfo.new(0.065, Enum.EasingStyle.Back, Enum.EasingDirection.In),
									{
										Width0 = 0,
										Width1 = 0
									}
								)
								tween:Play()
								tween.Completed:Wait()
								v9:Destroy()
							end)
						elseif beam.Name == "Attach0" then
							local v9 = painBall.Size.Z * 2
							beam.Position = Vector3.new(math.random(-100, 100), 0, -math.random(v9, v9 * 1.5))
							TweenService:Create(beam, TweenInfo.new(0.05 * math.random() + 0.05), {
								Position = createVector(0, 0, 0)
							}):Play()
						end
					end
				end

				task.spawn(function()
					local v9 = holdBall
					task.spawn(function()
						local clone5 = FX:WaitForChild("Pain").VHeld.Part:Clone()
						fn2(clone5, child, player, "PainFruitVFXColor")
						clone5.Attach1.Position = Vector3.new(0, 0, -v9.PrimaryPart.Size.Z + math.random(-100, 200))
						clone5.CFrame = CFrame.new(v9.PrimaryPart.Position) * CFrame.Angles(
							0,
							math.rad((math.random(-180, 180))),
							-1.5707963267948966
						) * CFrame.new(math.random(-100, 100) / 5, math.random(-100, 100) / 5, -painBall.Size.Z)
						local shafiBolt2 = ShafiBolt2(
							player,
							clone5.Attach0,
							clone5.Attach1,
							math.random(10, 15),
							3,
							child,
							v9.PrimaryPart.Size.Z / 3
						)
						local v11 = 0.15 * math.random() + 0.15

						if raycastResult2 then
							TweenService:Create(clone5.Attach1, TweenInfo.new(v11), {
								WorldPosition = raycastResult2.Position + Vector3.new(
									math.random(-100, 100),
									0,
									math.random(-100, 100)
								)
							}):Play()
						else
							clone5.CFrame *= CFrame.Angles(
								math.rad((math.random(-180, 180))),
								math.rad((math.random(-180, 180))),
								(math.rad((math.random(-180, 180))))
							)
							local curveSize = math.random(-50, 50)
							local curveSize2 = math.random(-50, 50)
							shafiBolt2.CurveSize0 = curveSize
							shafiBolt2.CurveSize1 = curveSize2
							shafiBolt2.Thickness = 10
							clone5.Attach1.Position = Vector3.new(0, 0, -(v9.PrimaryPart.Size.Z + math.random(-50, 50)))
							v11 *= 0.75
							TweenService:Create(clone5.Attach1, TweenInfo.new(v11), {
								Position = clone5.Attach1.Position + Vector3.new(
									math.random(-100, 100) / 5,
									math.random(-100, 100) / 5,
									math.random(-100, 100) / 5
								)
							}):Play()

							for _, emitter in pairs(clone5:GetDescendants()) do
								if emitter:IsA("ParticleEmitter") then
									emitter.Enabled = false
								end
							end
						end

						if v11 < v8 - tick() then
							task.wait(v11)
						else
							task.wait(v8 - tick())
						end

						shafiBolt2:Destroy()

						for _, emitter in pairs(clone5:GetDescendants()) do
							if emitter:IsA("ParticleEmitter") then
								emitter.Enabled = false
							end
						end
					end)
				end)
				task.wait(0.035)
			until v8 - tick() <= 0
		end)
		task.wait(0.5)
		local clone5 = assets.Phase3.ExplosionStart:Clone()
		clone5:PivotTo(cFrame2)
		fn2(clone5, child, player, "PainFruitVFXColor")

		if areShiftedColorsEqual(
			player,
			"PainFruitVFXColor",
			Color3.fromRGB(255, 146, 220),
			Color3.fromRGB(128, 183, 255),
			Color3.fromRGB(85, 170, 255)
		) then
			Util.AdjustObjectDescendantsColors(clone5, function(_, p)
				if math.random() > 0.5 then
					p = applyColorShiftHSV(p, 0.7076380848884583, 1.165137614678899, 1) or p
				end

				return p
			end)
		end

		clone5:ScaleTo(0.25 + holdBall:GetScale() / 5)
		DeleteImpactAfterDuration(clone5) -- equivalent call inferred; original call site unknown

		for _, emitter in pairs(clone5:GetDescendants()) do
			if not emitter:IsA("ParticleEmitter") then
				continue
			end

			local v8 = emitter
			task.spawn(function()
				if v8:IsDescendantOf(clone5.Aura) then
					v8.Enabled = true
					task.wait(0.25)
					v8.Enabled = false
				elseif v8:IsDescendantOf(clone5.Impact) then
					if v8:GetAttribute("EmitDelay") ~= 0 then
						task.wait(v8:GetAttribute("EmitDelay"))
					end

					v8:Emit(v8:GetAttribute("EmitCount"))
				elseif v8:IsDescendantOf(clone5.Explosion) then
					task.wait(0.285)
					v8:Emit(v8:GetAttribute("EmitCount"))
				end
			end)
		end

		local v8 = {}

		if proxy and proxy:IsDescendantOf(workspace) then
			for _, objectValue in pairs(proxy:GetChildren()) do
				if objectValue:IsA("ObjectValue") and objectValue.Value:IsDescendantOf(workspace) then
					table.insert(v8, objectValue.Value)
				end
			end
		end

		for _, v9 in pairs(v8) do
			local position = v9.Position
			task.spawn(function()
				local clone6 = assets.Phase3.SpinSlash:Clone()
				clone6:PivotTo(CFrame.new(cFrame2.Position))
				fn2(clone6, child, player, "PainFruitVFXColor")
				local model = clone6.Model

				for i = 1, 3 do
					local v11 = math.random(50, 85) / 130
					local clone7 = model:Clone()
					clone7:ScaleTo(i * 0.35 + 2.25)
					local primaryPart3 = clone7.PrimaryPart
					local v13 = clone6.PrimaryPart.CFrame * CFrame.Angles(
						math.rad((math.random(-180, 180))),
						math.rad((math.random(-180, 180))),
						(math.rad((math.random(-180, 180))))
					)
					local angularVelocity = primaryPart3.AngularVelocity
					primaryPart3.Anchored = false
					primaryPart3.AlignPosition.Position = primaryPart3.Position
					angularVelocity.AngularVelocity = Vector3.new(0, math.random(10, 15) * 2, 0)
					clone7:PivotTo(v13)
					fn2(clone7, clone6, player, "PainFruitVFXColor")
					primaryPart3.AlignPosition.Enabled = true
					angularVelocity.Enabled = true
					clone7:GetScale()
					local folder = clone7
					task.spawn(function()
						task.spawn(function()
							TweenService:Create(
								angularVelocity,
								TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
								{
									AngularVelocity = angularVelocity.AngularVelocity + Vector3.new(
										math.random(-15, 15) / 10,
										math.random(5, 15),
										math.random(-15, 15) / 10
									)
								}
							):Play()
							task.wait(v11 / 2)
							primaryPart3.AlignPosition.Position = position
						end)
						task.wait(0.035 * math.random() + 0.15)

						for i2, effect in pairs(folder:GetDescendants()) do
							if effect:IsA("Beam") then
								TweenService:Create(effect, TweenInfo.new(0.35 + math.random() * 0.125), {
									Width0 = 0,
									Width1 = 0
								}):Play()
								local v17 = effect
								task.delay(1, function()
									v17:Destroy()
								end)
							elseif effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
								effect.Enabled = false
							end
						end

						task.wait(1)
						angularVelocity.Enabled = false
						task.wait(3)
						angularVelocity:Destroy()
					end)
				end

				model:Destroy()
				task.spawn(function()
					local scale = clone6:GetScale()
					local v11 = scale * 0.1

					for i = scale * 100, v11 * 100, -13 do
						clone6:ScaleTo(i / 100)
						task.wait(0.005)
					end
				end)
			end)
			local position2 = position
			task.spawn(function()
				for i = 1, 3 do
					task.spawn(function()
						local v12 = math.random(45, 50) / 130
						local clone6 = assets.Phase3.TrailModel:Clone()
						clone6.Start.CFrame = CFrame.new(cFrame2.Position) * CFrame.Angles(
							math.rad((math.random(-180, 180))),
							math.rad((math.random(-180, 180))),
							(math.rad((math.random(-180, 180))))
						)
						fn2(clone6, child, player, "PainFruitVFXColor")
						clone6:ScaleTo(math.random(10, 13) / 10)
						local start = clone6.Start
						local trail = clone6.Trail
						local cframe = CFrame.new(0, 0, -math.random(100, 150) * 0.5)
						TweenService:Create(trail.Weld, TweenInfo.new(v12 / 5), {
							C1 = cframe
						}):Play()
						TweenService:Create(start, TweenInfo.new(v12), {
							CFrame = CFrame.new(position2)
						}):Play()
						trail.Weld.C1 = CFrame.new(0, 0, 0)
						task.delay(v12 / 5, function()
							TweenService:Create(trail.Weld, TweenInfo.new(v12), {
								C1 = CFrame.new(0, 0, 0)
							}):Play()
							start.AlignPosition.Position = position2
						end)
						trail.Trail1.Lifetime = math.random(50, 200) / 1500
						local angularVelocity = start.AngularVelocity
						start.Anchored = false
						start.AlignPosition.Position = start.Position
						TweenService:Create(angularVelocity, TweenInfo.new(0.15), {
							AngularVelocity = Vector3.new(
								math.random(-20, 25),
								math.random(-20, 25),
								math.random(-20, 25)
							)
						}):Play()

						for i2, effect in pairs(clone6:GetDescendants()) do
							if not (effect:IsA("ParticleEmitter") or effect:IsA("Trail")) then
								continue
							end

							effect.Enabled = true
							local v13 = effect
							task.delay(v12 + v12 / 5, function()
								v13.Enabled = false
							end)
						end

						task.wait(v12)
						angularVelocity.Enabled = false
						task.wait(v12)
						clone6:Destroy()
					end)
				end
			end)
		end
	end
end