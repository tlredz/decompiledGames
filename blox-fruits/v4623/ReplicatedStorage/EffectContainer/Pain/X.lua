local createVector = vector.create
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local TweenService = game:GetService("TweenService")
local _ = Util.Sound
local currentCamera = workspace.CurrentCamera
local FX = require(game.ReplicatedStorage.FX)
local assets = FX:WaitForChild("Pain").X.Assets
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
	if getColorHSVDistance(color, Color3.new(1, 1, 0)) > 0.05555555555555555 then
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

local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Exclude
raycastParams.FilterDescendantsInstances = { workspace._WorldOrigin, workspace.Characters, workspace.Enemies }
local lightningBoltShafi = Util.LightningBoltShafi

local function ShafiBolt(player, ...)
	local v = lightningBoltShafi.new(...)
	local curveSize = -math.random(5, 25)
	local curveSize2 = math.random(5, 25)
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
	v.Color = Util.WrapColor3Constructor(Color3.new(1, 0.380392, 0.380392), player, "PainFruitVFXColor")
	v.ColorOffsetSpeed = 3

	if player:IsA("Player") and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
		local humanoidRootPart = player.Character:FindFirstChild("HumanoidRootPart")

		if humanoidRootPart and humanoidRootPart:GetAttribute("PainSkin") and humanoidRootPart:GetAttribute("PainSkin") == "PAINSKINsuperspirit" then
			v.Color = Color3.fromRGB(60, 128, 255)
		end
	end

	return v
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

local function TrailCurve(clone, p, position, position2, cframe, cframe2, p2)
	local magnitude = (position - position2).Magnitude
	local v = (position - position2) / 2
	local position3 = CFrame.new(CFrame.new(position) * (v / -1.5)).Position
	local position4 = CFrame.new(CFrame.new(position2) * (v / 1.5)).Position
	math.random(20, 30)
	local v2 = CFrame.new(position3, position3 + p.LookVector) * cframe.Position
	local v3 = CFrame.new(position4, position4 + p.LookVector) * cframe2.Position
	local lastTime = tick()
	local v4 = magnitude / p2 / 60
	local _ = (magnitude / p2 + p2) / 60

	while tick() - lastTime < v4 do
		local v5 = (tick() - lastTime) / v4
		local v6 = cubicBezier(v5, position, v2, v3, position2)
		clone.CFrame = CFrame.new(clone.CFrame:Lerp(CFrame.new(v6, position2), v5).Position)
		RunService.Heartbeat:Wait()
	end
end

local function Tap(p, part, p2, _, p3)
	local clone = assets.Phase1.DashAura:Clone()
	clone.CFrame = part.CFrame
	Util.SetParentOverrideWithColor(clone, p2, p, "PainFruitVFXColor")

	if areShiftedColorsEqual(
		p,
		"PainFruitVFXColor",
		Color3.fromRGB(255, 146, 220),
		Color3.fromRGB(128, 183, 255),
		Color3.fromRGB(85, 170, 255)
	) then
		Util.AdjustObjectDescendantsColors(clone, function(_, p4)
			if math.random() > 0.5 then
				p4 = applyColorShiftHSV(p4, 0.7076380848884583, 1.165137614678899, 1) or p4
			end

			return p4
		end)
	end

	if areShiftedColorsEqual(
		p,
		"PainFruitVFXColor",
		Color3.fromRGB(255, 252, 55),
		Color3.fromRGB(95, 95, 14),
		Color3.fromRGB(255, 255, 112)
	) then
		Util.AdjustObjectDescendantsColors(clone, function(instance, p4)
			if instance:GetAttribute("SSJ") then
				p4 = applyColorShiftHSV2(p4, 0.41666667, 1.165137614678899, 1) or p4
			end

			return p4
		end)
	end

	clone.Anchored = false
	clone.Weld.Part1 = part

	for _, emitter in pairs(clone:GetDescendants()) do
		if not emitter:IsA("ParticleEmitter") then
			continue
		end

		emitter.Enabled = true
		emitter:Emit(3)
	end

	part.Anchored = true
	TweenService:Create(part, TweenInfo.new(0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {
		CFrame = part.CFrame * CFrame.new(0, 0, -p3)
	}):Play()
	local v = tick() + 0.1
	tick()

	repeat
		task.wait()
	until v - tick() <= 0

	for k, _ in pairs({}) do
		k.Parent.Weld.Enabled = false
		k.Parent.Anchored = true
	end

	part.Anchored = false

	for _, emitter in pairs(clone:GetDescendants()) do
		if emitter:IsA("ParticleEmitter") then
			emitter.Enabled = false
		end
	end

	clone.Weld.Enabled = false
	clone.Anchored = true
end

local function ParticleState(folder, enabled: boolean)
	local max = 0

	for _, effect in folder:GetDescendants() do
		if not (effect:IsA("ParticleEmitter") or effect:IsA("Trail")) then
			continue
		end

		if enabled == nil and not effect:IsA("Trail") then
			effect:Emit(effect:GetAttribute("EmitCount"))
		else
			effect.Enabled = enabled
		end

		if not (effect:IsA("Trail") or effect.Lifetime.Max <= max) then
			max = effect.Lifetime.Max
		end
	end

	return max
end

return function(player)
	local player2 = player.Player
	local origin = player.Origin

	if (currentCamera.CFrame.p - origin).Magnitude > 1300 then
		return
	end

	local stage = player.Stage
	local character = player.Character

	if stage == 1 then
		local holding = player.Holding

		if not (holding and holding.Value) then
			return
		end

		character:WaitForChild("HumanoidRootPart")
		character:WaitForChild("Head")
		local folder = Instance.new("Folder", workspace._WorldOrigin)
		local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
		character:WaitForChild("Humanoid")
		local cFrame = humanoidRootPart.CFrame
		Util.Sound:Play("X_Activate_02_V1", humanoidRootPart)
		local v = Util.Sound:Play("X_Hold_01_V1", humanoidRootPart)
		TweenService:Create(v, TweenInfo.new(0.3), {
			Volume = 1
		}):Play()
		local clone = assets.Phase0.Aura:Clone()
		clone.Weld.Part0 = humanoidRootPart
		Util.SetParentOverrideWithColor(clone, folder, player2, "PainFruitVFXColor")

		if areShiftedColorsEqual(
			player2,
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

		if areShiftedColorsEqual(
			player2,
			"PainFruitVFXColor",
			Color3.fromRGB(255, 252, 55),
			Color3.fromRGB(95, 95, 14),
			Color3.fromRGB(255, 255, 112)
		) then
			Util.AdjustObjectDescendantsColors(clone, function(instance, p)
				if instance:GetAttribute("SSJ") then
					p = applyColorShiftHSV2(p, 0.41666667, 1.165137614678899, 1) or p
				end

				return p
			end)
		end

		local childAddedConnection = nil
		childAddedConnection = character.ChildAdded:Connect(function(child)
			if child.Name == "PainXTransition" then
				childAddedConnection:Disconnect()

				if clone then
					clone:Destroy()
				end

				Util.Sound:Play("PainX_Transition_01", cFrame.Position)
				local clone2 = assets.Phase1.StartImpact:Clone()
				clone2.CFrame = cFrame
				Util.SetParentOverrideWithColor(clone2, folder, player2, "PainFruitVFXColor")

				if areShiftedColorsEqual(
					player2,
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

				if areShiftedColorsEqual(
					player2,
					"PainFruitVFXColor",
					Color3.fromRGB(255, 252, 55),
					Color3.fromRGB(95, 95, 14),
					Color3.fromRGB(255, 255, 112)
				) then
					Util.AdjustObjectDescendantsColors(clone2, function(instance, p)
						if instance:GetAttribute("SSJ") then
							p = applyColorShiftHSV2(p, 0.41666667, 1.165137614678899, 1) or p
						end

						return p
					end)
				end

				DeleteImpactAfterDuration(clone2) -- equivalent call inferred; original call site unknown

				for _, emitter in pairs(clone2:GetDescendants()) do
					if not emitter:IsA("ParticleEmitter") then
						continue
					end

					local v2 = emitter
					task.spawn(function()
						if v2:GetAttribute("EmitDelay") ~= 0 then
							task.wait(v2:GetAttribute("EmitDelay"))
						end

						v2:Emit(v2:GetAttribute("EmitCount"))
					end)
				end

				clone = assets.PhaseHold.HoldAura:Clone()
				Util.SetParentOverrideWithColor(clone, folder, player2, "PainFruitVFXColor")

				if areShiftedColorsEqual(
					player2,
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

				clone.Anchored = false
				clone.Weld.Part1 = humanoidRootPart

				for _, emitter in pairs(clone:GetDescendants()) do
					if not emitter:IsA("ParticleEmitter") then
						continue
					end

					local v2 = emitter
					task.spawn(function()
						v2.Enabled = true
					end)
				end
			end
		end)

		repeat
			task.wait()
		until not (holding:IsDescendantOf(workspace) and holding.Value)

		Util.Debris:AddItem(folder, 2)

		if childAddedConnection then
			childAddedConnection:Disconnect()
		end

		if v then
			Util.Sound:FadeOut(v, 0.2)
		end

		if clone then
			local particleState = ParticleState(clone, false)
			task.delay(particleState, clone.Destroy, clone)
		end
	elseif stage == 2 then
		local _ = player.Character
		local _ = player.Humanoid
		local folder = Instance.new("Folder")
		Util.SetParentOverrideWithColor(folder, _WorldOrigin, player2, "PainFruitVFXColor")
		Util.Debris:AddItem(folder, 3)
		local root = player.Root
		local startCFrame = player.StartCFrame
		local clone = assets.Phase1.StartImpact:Clone()
		clone.CFrame = startCFrame
		Util.SetParentOverrideWithColor(clone, folder, player2, "PainFruitVFXColor")

		if areShiftedColorsEqual(
			player2,
			"PainFruitVFXColor",
			Color3.fromRGB(255, 252, 55),
			Color3.fromRGB(95, 95, 14),
			Color3.fromRGB(255, 255, 112)
		) then
			Util.AdjustObjectDescendantsColors(clone, function(instance, p)
				if instance:GetAttribute("SSJ") then
					p = applyColorShiftHSV2(p, 0.41666667, 1.165137614678899, 1) or p
				end

				return p
			end)
		end

		Util.Sound:Play("X_DashLaunch_02_V1", root)
		DeleteImpactAfterDuration(clone) -- equivalent call inferred; original call site unknown

		for _, emitter in pairs(clone:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter:Emit(emitter:GetAttribute("EmitCount"))
			end
		end

		local clone2 = assets.Phase1.DashAura:Clone()
		clone2:PivotTo(root.CFrame)
		Util.SetParentOverrideWithColor(clone2, folder, player2, "PainFruitVFXColor")

		if areShiftedColorsEqual(
			player2,
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

		if areShiftedColorsEqual(
			player2,
			"PainFruitVFXColor",
			Color3.fromRGB(255, 252, 55),
			Color3.fromRGB(95, 95, 14),
			Color3.fromRGB(255, 255, 112)
		) then
			Util.AdjustObjectDescendantsColors(clone2, function(instance, p)
				if instance:GetAttribute("SSJ") then
					p = applyColorShiftHSV2(p, 0.41666667, 1.165137614678899, 1) or p
				end

				return p
			end)
		end

		for _, emitter in pairs(clone2:GetDescendants()) do
			if not emitter:IsA("ParticleEmitter") then
				continue
			end

			emitter.Enabled = true
			emitter:Emit(3)
		end

		local _ = player.distTravelledForward
		local _ = player.endPoint
		local timeUntilReachedEndPoint = player.timeUntilReachedEndPoint or 0.1
		local distTravelledForward = player.distTravelledForward
		local cFrame = CFrame.new(player.endPoint, root.Position) * CFrame.Angles(0, 3.141592653589793, 0)
		task.spawn(function()
			root.Anchored = true
			local random = Random.new()
			local lastTime = os.clock()
			local lastTime2 = os.clock()

			while os.clock() - lastTime < timeUntilReachedEndPoint do
				local v2 = (os.clock() - lastTime) / timeUntilReachedEndPoint
				root.CFrame = cFrame * CFrame.new(0, 0, distTravelledForward * (1 - v2 ^ 0.5))
				clone2:PivotTo(root.CFrame)

				if os.clock() - lastTime2 > 0.06 then
					lastTime2 = os.clock()
					local clone3 = assets.Extra3.TravelShockwave:Clone()
					clone3.Weld.Part0 = root
					clone3.Weld.C0 = CFrame.Angles(
						1.5707963267948966,
						random:NextNumber(-3.141592653589793, 3.141592653589793),
						0
					)
					clone3.Mesh.Scale = createVector(2, 6, 2)
					clone3.Mesh.Offset = createVector(0, -16, 0)
					Util.SetParentOverrideWithColor(clone3, _WorldOrigin, player2, "PainFruitVFXColor")
					TweenService:Create(
						clone3.Mesh,
						TweenInfo.new(0.15, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
						{
							Scale = createVector(6, 60, 6),
							Offset = createVector(0, 40, 0)
						}
					):Play()
					TweenService:Create(
						clone3.Decal,
						TweenInfo.new(0.1, Enum.EasingStyle.Cubic, Enum.EasingDirection.In),
						{
							Transparency = 1
						}
					):Play()
				end

				RunService.PreSimulation:Wait()
			end

			root.Anchored = false
			root.CFrame = cFrame
			clone2:PivotTo(root.CFrame)

			for _, emitter in pairs(clone2:GetDescendants()) do
				if emitter:IsA("ParticleEmitter") then
					emitter.Enabled = false
				end
			end
		end)
	elseif stage == 3 then
		local folder = Instance.new("Folder")
		Util.SetParentOverrideWithColor(folder, _WorldOrigin, player2, "PainFruitVFXColor")
		Util.Debris:AddItem(folder, 10)
		local victimChar = player.VictimChar
		local startCFrame = player.StartCFrame
		local root = player.Root
		local v = root:GetAttribute("PainSkin") and root:GetAttribute("PainSkin") == "PAINSKINsuperspirit"

		if not victimChar then
			return
		end

		local head = victimChar.Head
		local clone = assets.Phase2.HitImpact:Clone()
		clone.CFrame = CFrame.new(head.Position, head.Position + startCFrame.LookVector)
		Util.SetParentOverrideWithColor(clone, folder, player2, "PainFruitVFXColor")

		if areShiftedColorsEqual(
			player2,
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

		if areShiftedColorsEqual(
			player2,
			"PainFruitVFXColor",
			Color3.fromRGB(255, 252, 55),
			Color3.fromRGB(95, 95, 14),
			Color3.fromRGB(255, 255, 112)
		) then
			Util.AdjustObjectDescendantsColors(clone, function(_, p)
				return applyColorShiftHSV2(p, 0.41666667, 1.165137614678899, 1) or p
			end)
		end

		Util.Sound:Play("X_Tapped_ConnectHeadbutt_06_V1", head)
		local Players = game:GetService("Players")
		local playerFromCharacter = Players:GetPlayerFromCharacter(victimChar)
		local Players2

		if player.Player then
			local player3 = player.Player
			local Players3 = game:GetService("Players")

			if player3 == Players3.LocalPlayer then
				Util.CameraShaker:ShakeOnce(6, 10, 0.1, 0.25)
			elseif playerFromCharacter then
				Players2 = game:GetService("Players")

				if playerFromCharacter == Players2.LocalPlayer then
					Util.CameraShaker:ShakeOnce(6, 10, 0.1, 0.25)
				end
			end
		elseif playerFromCharacter then
			Players2 = game:GetService("Players")

			if playerFromCharacter == Players2.LocalPlayer then
				Util.CameraShaker:ShakeOnce(6, 10, 0.1, 0.25)
			end
		end

		DeleteImpactAfterDuration(clone) -- equivalent call inferred; original call site unknown

		for _, emitter in pairs(clone:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter:Emit(emitter:GetAttribute("EmitCount"))
			end
		end

		task.wait(0.3)
		local Players3

		if player.Player then
			local player3 = player.Player
			local Players4 = game:GetService("Players")

			if player3 == Players4.LocalPlayer then
				Util.CameraShaker:ShakeOnce(7, 11, 0.1, 0.25)
			elseif playerFromCharacter then
				Players3 = game:GetService("Players")

				if playerFromCharacter == Players3.LocalPlayer then
					Util.CameraShaker:ShakeOnce(7, 11, 0.1, 0.25)
				end
			end
		elseif playerFromCharacter then
			Players3 = game:GetService("Players")

			if playerFromCharacter == Players3.LocalPlayer then
				Util.CameraShaker:ShakeOnce(7, 11, 0.1, 0.25)
			end
		end

		local clone2 = assets.Phase3.HitModel:Clone()
		clone2:PivotTo(CFrame.new(head.Position, head.Position + startCFrame.LookVector))
		Util.SetParentOverrideWithColor(clone2, folder, player2, "PainFruitVFXColor")

		if areShiftedColorsEqual(
			player2,
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

		if areShiftedColorsEqual(
			player2,
			"PainFruitVFXColor",
			Color3.fromRGB(255, 252, 55),
			Color3.fromRGB(95, 95, 14),
			Color3.fromRGB(255, 255, 112)
		) then
			Util.AdjustObjectDescendantsColors(clone2, function(_, p)
				return applyColorShiftHSV2(p, 0.41666667, 1.165137614678899, 1) or p
			end)
		end

		clone2:ScaleTo(1.25)

		for _, emitter in pairs(clone2:GetDescendants()) do
			if not emitter:IsA("ParticleEmitter") or (emitter:IsDescendantOf(clone2.Impact2) or emitter:IsDescendantOf(clone2.Impact3)) then
				continue
			end

			emitter:Emit(emitter:GetAttribute("EmitCount"))
		end

		task.wait(0.3)
		local Players4

		if player.Player then
			local player3 = player.Player
			local Players5 = game:GetService("Players")

			if player3 == Players5.LocalPlayer then
				Util.CameraShaker:ShakeOnce(8, 12, 0.1, 0.25)
			elseif playerFromCharacter then
				Players4 = game:GetService("Players")

				if playerFromCharacter == Players4.LocalPlayer then
					Util.CameraShaker:ShakeOnce(8, 12, 0.1, 0.25)
				end
			end
		elseif playerFromCharacter then
			Players4 = game:GetService("Players")

			if playerFromCharacter == Players4.LocalPlayer then
				Util.CameraShaker:ShakeOnce(8, 12, 0.1, 0.25)
			end
		end

		clone2:ScaleTo(1.5)
		clone2:PivotTo(CFrame.new(head.Position, head.Position + startCFrame.LookVector))

		for _, emitter in pairs(clone2:GetDescendants()) do
			if not emitter:IsA("ParticleEmitter") or emitter:IsDescendantOf(clone2.Impact3) then
				continue
			end

			emitter:Emit(emitter:GetAttribute("EmitCount"))
		end

		task.wait(0.1)
		local cFrame = root.CFrame
		local clone3 = assets.Phase3.Aura:Clone()
		clone3.CFrame = cFrame * CFrame.new(0, 2, 0)
		Util.SetParentOverrideWithColor(clone3, folder, player2, "PainFruitVFXColor")

		for _, emitter in pairs(clone3:GetDescendants()) do
			if not emitter:IsA("ParticleEmitter") then
				continue
			end

			emitter.Enabled = true
			emitter:Emit(3)
		end

		task.delay(0.3, function()
			local clone4 = assets.Phase3.Star1:Clone()
			clone4.CFrame = cFrame * CFrame.new(0, 2, 0)
			Util.SetParentOverrideWithColor(clone4, folder, player2, "PainFruitVFXColor")

			if areShiftedColorsEqual(
				player2,
				"PainFruitVFXColor",
				Color3.fromRGB(255, 146, 220),
				Color3.fromRGB(128, 183, 255),
				Color3.fromRGB(85, 170, 255)
			) then
				Util.AdjustObjectDescendantsColors(clone4, function(_, p)
					if math.random() > 0.5 then
						p = applyColorShiftHSV(p, 0.7076380848884583, 1.165137614678899, 1) or p
					end

					return p
				end)
			end

			if areShiftedColorsEqual(
				player2,
				"PainFruitVFXColor",
				Color3.fromRGB(255, 252, 55),
				Color3.fromRGB(95, 95, 14),
				Color3.fromRGB(255, 255, 112)
			) then
				Util.AdjustObjectDescendantsColors(clone4, function(_, p)
					return applyColorShiftHSV2(p, 0.41666667, 1.165137614678899, 1) or p
				end)
			end

			for _, emitter in pairs(clone4:GetDescendants()) do
				if emitter:IsA("ParticleEmitter") then
					emitter:Emit(emitter:GetAttribute("EmitCount"))
				end
			end
		end)
		local v2 = tick() + 0.55
		local now = tick()

		while true do
			if now - tick() <= 0 then
				now = tick() + 0.035
				task.spawn(function()
					local clone4 = assets.Phase3.Trail:Clone()
					clone4.CFrame = cFrame
					Util.SetParentOverrideWithColor(clone4, folder, player2, "PainFruitVFXColor")
					clone4.CFrame = clone4.CFrame * CFrame.Angles(
						math.rad((math.random(-180, 180))),
						math.rad((math.random(-180, 180))),
						(math.rad((math.random(-180, 180))))
					) * CFrame.new(0, 0, math.random(20, 35))

					for _, effect in pairs(clone4:GetDescendants()) do
						if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
							effect.Enabled = true
						end
					end

					TrailCurve(
						clone4,
						cFrame,
						clone4.Position,
						cFrame * CFrame.new(0, 2, 0).Position,
						CFrame.new(math.random(-50, 50) / 5, math.random(-50, 50) / 5, math.random(-50, 50) / 5),
						CFrame.new(math.random(-50, 50) / 5, math.random(-50, 50) / 5, math.random(-50, 50) / 5),
						math.random(25, 30) / 7,
						true
					)

					for _, effect in pairs(clone4:GetDescendants()) do
						if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
							effect.Enabled = false
						end
					end
				end)
			end

			task.wait()

			if not (v2 - tick() <= 0) then
				continue
			end

			for _, emitter in pairs(clone3:GetDescendants()) do
				if emitter:IsA("ParticleEmitter") then
					emitter.Enabled = false
				end
			end

			clone2:ScaleTo(1.75)
			clone2:PivotTo(CFrame.new(head.Position, head.Position + startCFrame.LookVector))
			DeleteImpactAfterDuration(clone2) -- equivalent call inferred; original call site unknown

			for _, emitter in pairs(clone2:GetDescendants()) do
				if emitter:IsA("ParticleEmitter") then
					emitter:Emit(emitter:GetAttribute("EmitCount"))
				end
			end

			local Effect, Players5

			if player.Player then
				local player3 = player.Player
				local Players6 = game:GetService("Players")

				if player3 == Players6.LocalPlayer then
					Util.CameraShaker:ShakeOnce(10, 14, 0.05, 0.3)
					Effect = require(game.ReplicatedStorage.Effect)
					Effect.new("ColorCorrection"):replicate({
						TintColor = Util.WrapColor3Constructor(
							Color3.fromRGB(126, 64, 64),
							player2,
							"PainFruitVFXColor"
						),
						Brightness = 1,
						Contrast = 1,
						Saturation = -1,
						FadeIn = 0,
						FadeOut = 0.3,
						Lifetime = 0
					})
				elseif playerFromCharacter then
					Players5 = game:GetService("Players")

					if playerFromCharacter == Players5.LocalPlayer then
						Util.CameraShaker:ShakeOnce(10, 14, 0.05, 0.3)
						Effect = require(game.ReplicatedStorage.Effect)
						Effect.new("ColorCorrection"):replicate({
							TintColor = Util.WrapColor3Constructor(
								Color3.fromRGB(126, 64, 64),
								player2,
								"PainFruitVFXColor"
							),
							Brightness = 1,
							Contrast = 1,
							Saturation = -1,
							FadeIn = 0,
							FadeOut = 0.3,
							Lifetime = 0
						})
					end
				end
			elseif playerFromCharacter then
				Players5 = game:GetService("Players")

				if playerFromCharacter == Players5.LocalPlayer then
					Util.CameraShaker:ShakeOnce(10, 14, 0.05, 0.3)
					Effect = require(game.ReplicatedStorage.Effect)
					Effect.new("ColorCorrection"):replicate({
						TintColor = Util.WrapColor3Constructor(
							Color3.fromRGB(126, 64, 64),
							player2,
							"PainFruitVFXColor"
						),
						Brightness = 1,
						Contrast = 1,
						Saturation = -1,
						FadeIn = 0,
						FadeOut = 0.3,
						Lifetime = 0
					})
				end
			end

			task.spawn(function()
				task.wait(0.025)

				for i = 1, 10 do
					local clone4 = FX:WaitForChild("Pain").X.Part:Clone()
					clone4.CFrame = cFrame * CFrame.Angles(0, 0, (math.rad((math.random(-180, 180)))))
					Util.SetParentOverrideWithColor(clone4, folder, player2, "PainFruitVFXColor")

					if areShiftedColorsEqual(
						player2,
						"PainFruitVFXColor",
						Color3.fromRGB(255, 252, 55),
						Color3.fromRGB(95, 95, 14),
						Color3.fromRGB(255, 255, 112)
					) then
						Util.AdjustObjectDescendantsColors(clone4, function(_, p)
							return applyColorShiftHSV2(p, 0.41666667, 1.165137614678899, 1) or p
						end)
					end

					clone4.Attach1.WorldPosition = cFrame * CFrame.new(
						math.random(-50, 50),
						math.random(-50, 50),
						-math.random(40, 80)
					).Position
					local shafiBolt = ShafiBolt(
						player2,
						clone4.Attach0,
						clone4.Attach1,
						math.random(5, 8),
						0.65,
						folder
					)

					if i % 2 == 0 then
						shafiBolt.Color = v and Color3.fromRGB(60, 128, 255) or Util.WrapColor3Constructor(
							Color3.fromRGB(181, 40, 40),
							player2,
							"PainFruitVFXColor"
						)
						shafiBolt.Thickness = 0.35
					end

					task.spawn(function()
						task.wait(0.15 + math.random() * 0.2)
						shafiBolt:Destroy()
					end)
				end
			end)
			return
		end
	elseif stage == 4 then
		local folder = Instance.new("Folder")
		Util.SetParentOverrideWithColor(folder, _WorldOrigin, player2, "PainFruitVFXColor")
		Util.Debris:AddItem(folder, 10)
		local _ = player.GrabObject
		local grabObject = player.GrabObject
		local enemyGrabbed = player.EnemyGrabbed
		local enemyRoot = player.EnemyRoot
		local enemyHum = player.EnemyHum
		local attackerHum = player.AttackerHum
		local root = player.Root
		local cFrame = root.CFrame
		root.Anchored = true
		Util.Sound:Play("X_LaserChargeAndFire_07_V1", root)
		task.spawn(function()
			local lastTime = tick()
			tick()
			tick()

			while tick() - lastTime < player.dur and enemyGrabbed and enemyHum and root and grabObject and grabObject:IsDescendantOf(workspace) and not (attackerHum.Health <= 0) and enemyHum and not (enemyHum.Health <= 0) do
				if grabObject:GetAttribute("BeamHours") then
					local cframe = CFrame.lookAt(root.Position, player.MousePos.Value)
					local _, v = Util.Ray(
						cframe.Position,
						cframe.LookVector * 150,
						{ workspace._WorldOrigin, workspace.Characters, workspace.Enemies }
					)
					local _ = (v - root.Position).Magnitude
					local v2 = enemyRoot.Size.Y * 0.5 + enemyHum.HipHeight
					enemyRoot.CFrame = CFrame.new(v + Vector3.new(0, v2, 0), root.Position)
				else
					local _, v = Util.Ray(
						root.Position,
						root.CFrame.LookVector * 3,
						{ workspace._WorldOrigin, workspace.Characters, workspace.Enemies }
					)
					local magnitude = (v - root.Position).Magnitude
					enemyRoot.CFrame = CFrame.new(root.Position + root.CFrame.LookVector * magnitude, root.Position)
				end

				task.wait()
			end
		end)
		task.spawn(function()
			local v = root.CFrame * CFrame.new(0, 30, 5)
			local clone = assets.Extra1.Slash:Clone()
			clone.CFrame = root.CFrame * CFrame.new(0, 20, 10) * CFrame.Angles(0, 0, -1.5707963267948966)
			Util.SetParentOverrideWithColor(clone, folder, player2, "PainFruitVFXColor")

			if areShiftedColorsEqual(
				player2,
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

			DeleteImpactAfterDuration(clone) -- equivalent call inferred; original call site unknown

			for _, emitter in pairs(clone:GetDescendants()) do
				if emitter:IsA("ParticleEmitter") then
					emitter:Emit(emitter:GetAttribute("EmitCount"))
				end
			end

			task.spawn(function()
				local v2 = v * CFrame.new(0, 0, -22.5)

				for _ = 1, 5 do
					local clone2 = assets.Extra1.SpinTrailModel:Clone()
					clone2.PrimaryPart.CFrame = v2 * CFrame.new(0, -15, 0) * CFrame.Angles(
						0,
						math.rad((math.random(-180, 180))),
						0
					)
					Util.SetParentOverrideWithColor(clone2, folder, player2, "PainFruitVFXColor")
					local v3 = math.random(3, 5)
					local v4 = math.random(10, 15)
					clone2.PrimaryPart.Attach0.Position = Vector3.new(-v3, 0, -v4)
					clone2.PrimaryPart.Attach1.Position = Vector3.new(v3, 0, -v4)
					local v5 = 0.25 + math.random(-10, 10) / 100
					TweenService:Create(
						clone2.PrimaryPart.Attach0,
						TweenInfo.new(v5, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
						{
							Position = Vector3.new(0, 0, -v4 / 3)
						}
					):Play()
					TweenService:Create(
						clone2.PrimaryPart.Attach1,
						TweenInfo.new(v5, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
						{
							Position = Vector3.new(0, 0, -v4 / 3)
						}
					):Play()
					task.spawn(function()
						local v8 = math.random(8, 12)

						for i = 1, 5 do
							local tween = TweenService:Create(
								clone2.PrimaryPart,
								TweenInfo.new(v5 / 5, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
								{
									CFrame = clone2.PrimaryPart.CFrame * CFrame.new(0, v8, 0) * CFrame.Angles(
										0,
										1.3962634015954636,
										0
									)
								}
							)
							tween:Play()
							tween.Completed:Wait()
						end
					end)
				end
			end)
		end)
		local _ = enemyGrabbed.PrimaryPart
		local _ = root.CFrame * CFrame.new(0, 35, -5)
		root.Anchored = true
		TweenService:Create(root, TweenInfo.new(0.2, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {
			CFrame = CFrame.new(player.EndPoint) * cFrame.Rotation
		}):Play()
		task.wait(0.2)
		root.Anchored = false
		local cFrame2 = root.CFrame
		local clone = assets.Extra2.Aura:Clone()
		Util.SetParentOverrideWithColor(clone, folder, player2, "PainFruitVFXColor")

		if areShiftedColorsEqual(
			player2,
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

		if areShiftedColorsEqual(
			player2,
			"PainFruitVFXColor",
			Color3.fromRGB(255, 252, 55),
			Color3.fromRGB(95, 95, 14),
			Color3.fromRGB(255, 255, 112)
		) then
			Util.AdjustObjectDescendantsColors(clone, function(_, p)
				return applyColorShiftHSV2(p, 0.41666667, 1.165137614678899, 1) or p
			end)
		end

		for _, emitter in pairs(clone:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter.Enabled = true
			end
		end

		local clone2 = assets.Extra2.Aura2:Clone()
		clone2.CFrame = cFrame2 * CFrame.new(0, 1, 0)
		Util.SetParentOverrideWithColor(clone2, folder, player2, "PainFruitVFXColor")

		if areShiftedColorsEqual(
			player2,
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

		if areShiftedColorsEqual(
			player2,
			"PainFruitVFXColor",
			Color3.fromRGB(255, 252, 55),
			Color3.fromRGB(95, 95, 14),
			Color3.fromRGB(255, 255, 112)
		) then
			Util.AdjustObjectDescendantsColors(clone2, function(_, p)
				return applyColorShiftHSV2(p, 0.41666667, 1.165137614678899, 1) or p
			end)
		end

		clone2.Anchored = true

		for _, emitter in pairs(clone2:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter.Enabled = true
			end
		end

		task.spawn(function()
			local v = tick() + 0.65 + 0.1

			while tick() < v and root:IsDescendantOf(workspace) and clone2:IsDescendantOf(workspace) do
				clone2.CFrame = root.CFrame * CFrame.new(0, 1, 0)
				task.wait()
			end
		end)
		task.spawn(function()
			local scale = clone2.Model:GetScale()
			local v = 0.85
			local v2 = v * 1
			local total = 0
			local v3 = 0.5

			while total < v3 do
				total += RunService.Heartbeat:Wait()
				local v4 = math.clamp(total / v3, 0, 1)
				local v5

				if v4 < 0.7 then
					v5 = scale + (v2 - scale) * (v4 / 0.7)
				else
					v5 = v2 + (v - v2) * ((v4 - 0.7) / 0.3)
				end

				clone2.Model:ScaleTo(v5)
			end

			local scale2 = clone2.Model:GetScale()
			local v4 = 1.15
			local v5 = v4 * 2
			local total2 = 0
			local v6 = 0.085

			while total2 < v6 do
				total2 += RunService.Heartbeat:Wait()
				local v7 = math.clamp(total2 / v6, 0, 1)
				local v8

				if v7 < 0.7 then
					v8 = scale2 + (v5 - scale2) * (v7 / 0.7)
				else
					v8 = v5 + (v4 - v5) * ((v7 - 0.7) / 0.3)
				end

				clone2.Model:ScaleTo(v8)
			end
		end)
		task.spawn(function()
			local clone3 = assets.Extra2.SpinTrail:Clone()
			clone3.CFrame = root.CFrame * CFrame.Angles(0.5235987755982988, 5.235987755982989, 0.5235987755982988)
			Util.SetParentOverrideWithColor(clone3, folder, player2, "PainFruitVFXColor")

			if areShiftedColorsEqual(
				player2,
				"PainFruitVFXColor",
				Color3.fromRGB(255, 252, 55),
				Color3.fromRGB(95, 95, 14),
				Color3.fromRGB(255, 255, 112)
			) then
				Util.AdjustObjectDescendantsColors(clone3, function(_, p)
					return applyColorShiftHSV2(p, 0.41666667, 1.165137614678899, 1) or p
				end)
			end

			for _, emitter in pairs(clone3:GetDescendants()) do
				if emitter:IsA("ParticleEmitter") then
					emitter.Enabled = true
				end
			end

			for _ = 1, 2 do
				TweenService:Create(clone3, TweenInfo.new(0.115), {
					CFrame = clone3.CFrame * CFrame.Angles(0, -2.443460952792061, 0)
				}):Play()
				task.wait(0.115)
			end

			for _, emitter in pairs(clone3:GetDescendants()) do
				if emitter:IsA("ParticleEmitter") then
					emitter.Enabled = false
				end
			end
		end)
		local v = tick() + 0.65
		local now = tick()
		local mousePos = player.MousePos

		while true do
			local cframe = CFrame.new(root.Position, mousePos.Value)
			clone.CFrame = cframe * CFrame.new(0, 0, -5)

			if now - tick() <= 0 then
				now = tick() + 0.035
				task.spawn(function()
					local clone3 = assets.Extra2.Trail:Clone()
					clone3.CFrame = cframe * CFrame.new(0, 0, -5)
					Util.SetParentOverrideWithColor(clone3, folder, player2, "PainFruitVFXColor")

					if areShiftedColorsEqual(
						player2,
						"PainFruitVFXColor",
						Color3.fromRGB(255, 252, 55),
						Color3.fromRGB(95, 95, 14),
						Color3.fromRGB(255, 255, 112)
					) then
						Util.AdjustObjectDescendantsColors(clone3, function(_, p)
							return applyColorShiftHSV2(p, 0.41666667, 1.165137614678899, 1) or p
						end)
					end

					clone3.CFrame = clone3.CFrame * CFrame.Angles(
						math.rad((math.random(-180, 180))),
						math.rad((math.random(-180, 180))),
						(math.rad((math.random(-180, 180))))
					) * CFrame.new(0, 0, math.random(40, 50))

					for _, effect in pairs(clone3:GetDescendants()) do
						if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
							effect.Enabled = true
						end
					end

					TrailCurve(
						clone3,
						cframe,
						clone3.Position,
						cframe * CFrame.new(0, 0, -5).Position,
						CFrame.new(math.random(-50, 50) / 2, math.random(-50, 50) / 2, math.random(-50, 50) / 2),
						CFrame.new(math.random(-50, 50) / 2, math.random(-50, 50) / 2, math.random(-50, 50) / 2),
						math.random(25, 30) / 6,
						true
					)

					for _, effect in pairs(clone3:GetDescendants()) do
						if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
							effect.Enabled = false
						end
					end
				end)
			end

			task.wait()

			if not (v - tick() <= 0) then
				continue
			end

			for _, emitter in pairs(clone:GetDescendants()) do
				if emitter:IsA("ParticleEmitter") then
					emitter.Enabled = false
				end
			end

			for _, emitter in pairs(clone2:GetDescendants()) do
				if not emitter:IsA("ParticleEmitter") then
					continue
				end

				emitter.Enabled = false
				emitter:Destroy()
			end

			task.wait(0.05)
			task.spawn(function()
				local clone3 = assets.Extra3.FloorExplosion:Clone()
				Util.SetParentOverrideWithColor(clone3, folder, player2, "PainFruitVFXColor")

				if areShiftedColorsEqual(
					player2,
					"PainFruitVFXColor",
					Color3.fromRGB(255, 146, 220),
					Color3.fromRGB(128, 183, 255),
					Color3.fromRGB(85, 170, 255)
				) then
					Util.AdjustObjectDescendantsColors(clone3, function(_, p)
						if math.random() > 0.5 then
							p = applyColorShiftHSV(p, 0.7076380848884583, 1.165137614678899, 1) or p
						end

						return p
					end)
				end

				if areShiftedColorsEqual(
					player2,
					"PainFruitVFXColor",
					Color3.fromRGB(255, 252, 55),
					Color3.fromRGB(95, 95, 14),
					Color3.fromRGB(255, 255, 112)
				) then
					Util.AdjustObjectDescendantsColors(clone3, function(_, p)
						return applyColorShiftHSV2(p, 0.41666667, 1.165137614678899, 1) or p
					end)
				end

				local SingularBeam = require(script.Assets.Garbage["Singular Beam"])
				SingularBeam(
					player2,
					"Start",
					character,
					folder,
					CFrame.lookAt(root.Position, mousePos.Value),
					mousePos,
					clone3
				)
			end)
			break
		end
	end
end