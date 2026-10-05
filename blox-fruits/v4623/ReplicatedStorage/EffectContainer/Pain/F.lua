local createVector = vector.create
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local TweenService = game:GetService("TweenService")
local _ = Util.Sound
local currentCamera = workspace.CurrentCamera
local FX = require(game.ReplicatedStorage.FX)
local assets = FX:WaitForChild("Pain").F.Assets
local _WorldOrigin = workspace:WaitForChild("_WorldOrigin")

local function Lerp(p, p2, p3)
	return p + (p2 - p) * p3
end

local function Sin(p)
	return (math.sin((math.rad(p))))
end

local function Cos(p)
	return (math.cos((math.rad(p))))
end

local random = Random.new()
local _ = {
	"rbxassetid://130452828882944",
	"rbxassetid://117619623009426",
	"rbxassetid://71120275331630",
	"rbxassetid://83529237504062",
	"rbxassetid://101597828079212",
	"rbxassetid://119164541102628",
	"rbxassetid://128504348629671",
	"rbxassetid://123584584840567"
}
local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Exclude
raycastParams.FilterDescendantsInstances = { workspace.Characters, workspace.Enemies, workspace._WorldOrigin }

local function ParticleState(folder, enabled: boolean)
	local max = 0

	for _, emitter in folder:GetDescendants() do
		if not emitter:IsA("ParticleEmitter") then
			continue
		end

		if enabled == nil then
			emitter:Emit(emitter:GetAttribute("EmitCount"))
		else
			emitter.Enabled = enabled
		end

		if not (emitter.Lifetime.Max <= max) then
			max = emitter.Lifetime.Max
		end
	end

	return max
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

local lightningBoltShafi = Util.LightningBoltShafi

local function ShafiBolt(player, ...)
	local v = lightningBoltShafi.new(...)
	local curveSize = -math.random(25, 50)
	local curveSize2 = math.random(25, 50)
	v.CurveSize0 = curveSize
	v.CurveSize1 = curveSize2
	v.MinRadius = 2
	v.MaxRadius = 6
	v.Frequency = 0.5
	v.AnimationSpeed = 8
	local maxThicknessMultiplier = math.random(3, 4)
	v.MinThicknessMultiplier = 0.2
	v.MaxThicknessMultiplier = maxThicknessMultiplier
	v.MinTransparency = 0
	v.MaxTransparency = 1
	v.PulseSpeed = 7
	v.PulseLength = 1000000
	v.FadeLength = 0.2
	v.ContractFrom = 0.5
	v.Color = Util.WrapColor3Constructor(Color3.new(1, 0.380392, 0.380392), player, "PainFruitVFXColor")
	v.ColorOffsetSpeed = 3

	if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
		local humanoidRootPart = player.Character:FindFirstChild("HumanoidRootPart")

		if humanoidRootPart and humanoidRootPart:GetAttribute("PainSkin") and humanoidRootPart:GetAttribute("PainSkin") == "PAINSKINsuperspirit" then
			v.Color = Color3.fromRGB(60, 128, 255)
		end
	end

	return v
end

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

local function getColorHSVDistance(color: Color3, color2: Color3)
	local v = math.max(1, color2.R, color2.G, color2.B)
	local v2 = math.floor(color2.R / v * 255) % 256
	local v3 = math.floor(color2.G / v * 255) % 256
	local v4 = math.floor(color2.B / v * 255) % 256
	local color3 = Color3.fromRGB(v2, v3, v4)
	local HSV, _, _ = color:ToHSV()
	local HSV2, _, _ = color3:ToHSV()
	local v5 = math.abs(HSV2 - HSV)
	return (math.min(v5, 1 - v5))
end

local function applyColorShiftHSV(color: Color3, p: number, p2: number, p3: number)
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

return function(player)
	local player2 = player.Player
	local origin = player.Origin

	if (currentCamera.CFrame.p - origin).Magnitude > 1300 then
		return
	end

	local v = player2 and player2:IsA("Model") and player2:IsDescendantOf(workspace.Enemies) and {
		Character = player2,
		FindFirstChild = function() end
	} or player2
	local stage = player.Stage
	local character = player.Character

	if stage == 1 then
		local holding = player.Holding

		if not (holding and holding.Value) then
			return
		end

		local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
		local v2 = humanoidRootPart:GetAttribute("PainSkin") and humanoidRootPart:GetAttribute("PainSkin") == "PAINSKINsuperspirit"
		local head = character:WaitForChild("Head")
		local folder = Instance.new("Folder", workspace._WorldOrigin)
		local cFrame = humanoidRootPart.CFrame
		local clone = assets.StartEmit:Clone()
		clone.CFrame = humanoidRootPart.CFrame
		Util.SetParentOverrideWithColor(clone, _WorldOrigin, v, "PainFruitVFXColor")
		local v3 = Util.Sound:Play("F_Held_01_V1", humanoidRootPart)
		local particleState = ParticleState(clone)
		task.delay(particleState, clone.Destroy, clone)
		local clone2 = assets.HeadAura:Clone()
		clone2.Weld.Part0 = head
		Util.SetParentOverrideWithColor(clone2, _WorldOrigin, v, "PainFruitVFXColor")
		local clone3 = assets.StartAura:Clone()
		clone3.Weld.Part0 = humanoidRootPart
		Util.SetParentOverrideWithColor(clone3, _WorldOrigin, v, "PainFruitVFXColor")
		local clone4 = nil
		local painFHold = nil
		local childAddedConnection = nil
		childAddedConnection = character.ChildAdded:Connect(function(child)
			if child.Name == "PainFTransition" then
				childAddedConnection:Disconnect()

				if clone3 then
					clone3:Destroy()
				end

				if clone2 then
					clone2:Destroy()
				end

				painFHold = Util.Anims:Get(character, "PainFHold")
				painFHold.Looped = true
				painFHold:Play()
				local clone5 = assets.Phase1.StartImpact:Clone()
				clone5.CFrame = cFrame
				Util.SetParentOverrideWithColor(clone5, folder, v, "PainFruitVFXColor")

				if v2 then
					for _, emitter in pairs(clone5.Aura:GetChildren()) do
						if emitter:IsA("ParticleEmitter") then
							emitter.Color = ColorSequence.new(Color3.fromRGB(60, 128, 255))
						end
					end
				end

				Util.Sound:Play("PainX_Transition_02", cFrame.Position)
				DeleteImpactAfterDuration(clone5) -- equivalent call inferred; original call site unknown

				for _, emitter in pairs(clone5:GetDescendants()) do
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

				clone4 = assets.Phase1.HoldAura:Clone()
				Util.SetParentOverrideWithColor(clone4, folder, v, "PainFruitVFXColor")

				if v2 then
					clone4.HoldAura3.Attachment1.Particle_5.Color = ColorSequence.new(Color3.fromRGB(60, 128, 255))
				end

				clone4.Anchored = false
				clone4.Weld.Part1 = humanoidRootPart

				for _, emitter in pairs(clone4:GetDescendants()) do
					if not emitter:IsA("ParticleEmitter") then
						continue
					end

					local v5 = emitter
					task.spawn(function()
						v5.Enabled = true
					end)
				end
			end
		end)

		repeat
			task.wait()
		until not (holding:IsDescendantOf(workspace) and holding.Value)

		if painFHold then
			painFHold:Stop()
		end

		Util.Debris:AddItem(folder, 2)

		if v3 then
			Util.Sound:FadeOut(v3, 0.2)
		end

		if clone2 then
			local particleState2 = ParticleState(clone2, false)
			task.delay(particleState2, clone2.Destroy, clone2)
		end

		if clone3 then
			local particleState2 = ParticleState(clone3, false)
			task.delay(particleState2, clone3.Destroy, clone3)
		end

		if clone4 then
			for _, emitter in pairs(clone4:GetDescendants()) do
				if not emitter:IsA("ParticleEmitter") then
					continue
				end

				local v5 = emitter
				task.spawn(function()
					v5.Enabled = false
				end)
			end
		end
	elseif stage == 2 then
		local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
		character:WaitForChild("Head")
		local v2 = humanoidRootPart:GetAttribute("PainSkin") and humanoidRootPart:GetAttribute("PainSkin") == "PAINSKINsuperspirit"
		local startCFrame = player.StartCFrame

		if player.newCF and humanoidRootPart:GetAttribute("Tapped") then
			local player3 = player.Player
			local Players = game:GetService("Players")

			if player3 == Players.LocalPlayer then
				humanoidRootPart:SetAttribute("Tapped", nil)
				return
			end
		elseif player.newCF and not humanoidRootPart:GetAttribute("Tapped") then
			local player3 = player.Player
			local Players = game:GetService("Players")

			if player3 == Players.LocalPlayer then
				humanoidRootPart.CFrame = player.newCF
			end
		end

		local folder = Instance.new("Folder", workspace._WorldOrigin)
		Util.Debris:AddItem(folder, 5)
		local clone = assets.LaunchParticles:Clone()
		clone.CFrame = startCFrame
		Util.SetParentOverrideWithColor(clone, _WorldOrigin, v, "PainFruitVFXColor")

		if areShiftedColorsEqual(
			v,
			"PainFruitVFXColor",
			Color3.fromRGB(255, 252, 55),
			Color3.fromRGB(95, 95, 14),
			Color3.fromRGB(255, 255, 112)
		) then
			Util.AdjustObjectDescendantsColors(clone, function(_, p)
				return applyColorShiftHSV(p, 0.41666667, 1.165137614678899, 1) or p
			end)
		end

		Util.Sound:Play("F_Dash_0" .. tostring(math.random(1, 3)) .. "_V1", humanoidRootPart)
		local clone2 = assets.DashEmit:Clone()
		clone2.CFrame = startCFrame
		Util.SetParentOverrideWithColor(clone2, _WorldOrigin, v, "PainFruitVFXColor")

		if areShiftedColorsEqual(
			v,
			"PainFruitVFXColor",
			Color3.fromRGB(255, 252, 55),
			Color3.fromRGB(95, 95, 14),
			Color3.fromRGB(255, 255, 112)
		) then
			Util.AdjustObjectDescendantsColors(clone2, function(_, p)
				return applyColorShiftHSV(p, 0.41666667, 1.165137614678899, 1) or p
			end)
		end

		local position = startCFrame.Position
		local particleState = ParticleState(clone2)
		task.delay(particleState, clone2.Destroy, clone2)
		local endPos = player.EndPos
		Util.Sound:Play("PainF_AirHit_0" .. tostring(math.random(1, 4)), humanoidRootPart.Position)
		local clone3 = assets.Implode:Clone()
		clone3.CFrame = CFrame.new(endPos)
		Util.SetParentOverrideWithColor(clone3, folder, v, "PainFruitVFXColor")
		task.spawn(function()
			task.wait((ParticleState(clone3)))
			clone3:Destroy()
		end)
		local ray = Util.Ray
		local v4 = endPos + createVector(0, 1, 0)
		local v5 = { workspace._WorldOrigin, workspace.Characters, workspace.Enemies }
		local v6, v7, v8 = ray(v4, createVector(-0, -5, -0), v5)

		if v6 then
			local v9 = Util.Misc.AlignCFrame(CFrame.new(createVector(0, 0, 0), createVector(0, 0, 1)) + v7, v8) + v8 * 0.01
			local clone4 = assets.FloorSmudge:Clone()
			clone4.CFrame = v9 * CFrame.Angles(0, random:NextNumber(-1, 1) * 3.141592653589793, 0)
			clone4.Attachment.ParticleEmitter.Size = NumberSequence.new(stage == 1 and 50 or 25)
			Util.SetParentOverrideWithColor(clone4, folder, v, "PainFruitVFXColor")

			if areShiftedColorsEqual(
				v,
				"PainFruitVFXColor",
				Color3.fromRGB(255, 252, 55),
				Color3.fromRGB(95, 95, 14),
				Color3.fromRGB(255, 255, 112)
			) then
				Util.AdjustObjectDescendantsColors(clone4, function(_, p)
					return applyColorShiftHSV(p, 0.41666667, 1.165137614678899, 1) or p
				end)
			end

			local v10 = ParticleState(clone4) + 0.02
			Util.Debris:AddItem(clone4, v10 + 0.25)

			for i = 1, 12 do
				local v11 = i * 30
				local v12 = CFrame.new(v7, v7 + v8) * CFrame.Angles(-1.5707963267948966, 0, 0) * CFrame.Angles(
					0,
					math.rad(v11),
					0
				) * CFrame.new(0, 0, -12)
				local ray2, v13, v14 = Util.Ray(
					v12.Position,
					v12.upVector.Unit * -30,
					{ workspace.Characters, workspace.Enemies },
					false
				)

				if not ray2 then
					continue
				end

				local rock = Util.Rock2.new({
					FadeIn = { 0, 0.1 },
					Lifetime = math.random(10, 15) / 10,
					FadeOut = { 0.4, 0.5 },
					Size = Vector3.new(math.random(3, 6) * 0.7, 1.4, math.random(3, 6) * 0.7),
					Scale = { 1, 2 }
				})
				rock:Spawn(CFrame.new(v13, v13 + v14) * CFrame.Angles(-1.5707963267948966, 0, 0) * CFrame.Angles(
					0,
					math.rad(v11),
					0
				))

				if not (math.random(1, 100) <= 50) then
					continue
				end

				rock.Type = "Flying"
				rock:Eject({
					Velocity = (v12.UpVector * (workspace.Gravity / 2 + math.random(-20, 40)) + rock.Part.CFrame.lookVector * math.random(
						30,
						50
					)) * 0.7,
					RotVelocity = createVector(3.1415927, 3.1415927, 3.1415927)
				})
			end
		end

		local _ = player.VictimCharacter
		local _ = player.VictimRoot
		local cFrame = CFrame.lookAt(endPos, startCFrame.Position) * CFrame.Angles(0, 3.141592653589793, 0)
		task.spawn(function()
			local bubbleModule = Util.BubbleModule
			task.spawn(function()
				bubbleModule.CreateBubble(
					v,
					cFrame,
					createVector(10, 10, 10),
					6,
					createVector(40, 40, 40),
					0.15,
					folder
				)
			end)
			task.spawn(function()
				bubbleModule.CreateBubble(
					v,
					cFrame,
					createVector(60, 60, 60),
					15,
					createVector(10, 10, 10),
					0.1,
					folder
				)
			end)
		end)
		TweenService:Create(clone, TweenInfo.new(0.15, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
			CFrame = cFrame
		}):Play()
		local clone4 = assets.BeamPart1:Clone()
		local beamPart2 = clone4.BeamPart2
		beamPart2.CFrame = humanoidRootPart.CFrame
		clone4.CFrame = humanoidRootPart.CFrame
		Util.SetParentOverrideWithColor(clone4, folder, v, "PainFruitVFXColor")

		if areShiftedColorsEqual(
			v,
			"PainFruitVFXColor",
			Color3.fromRGB(255, 252, 55),
			Color3.fromRGB(95, 95, 14),
			Color3.fromRGB(255, 255, 112)
		) then
			Util.AdjustObjectDescendantsColors(clone4, function(_, p)
				return applyColorShiftHSV(p, 0.41666667, 1.165137614678899, 1) or p
			end)
		end

		TweenService:Create(clone4, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			CFrame = cFrame
		}):Play()
		task.delay(0.1, function()
			TweenService:Create(beamPart2, TweenInfo.new(0.2, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out), {
				CFrame = cFrame
			}):Play()
			task.wait(0.2)
			TweenService:Create(clone4.Beam, TweenInfo.new(0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
				Width0 = 0,
				Width1 = 0
			}):Play()
			task.wait(0.1)
			clone4:Destroy()
		end)
		task.delay(0.09, function()
			for i = 1, 4 do
				local position2 = startCFrame.Position
				local v11 = position2 + (cFrame.Position - position2) * (i / 4)

				if i < 4 then
					local clone5 = assets.ShockwaveEmit:Clone()
					clone5.CFrame = CFrame.lookAt(v11, v11 + startCFrame.LookVector)
					Util.SetParentOverrideWithColor(clone5, folder, v, "PainFruitVFXColor")

					if areShiftedColorsEqual(
						v,
						"PainFruitVFXColor",
						Color3.fromRGB(255, 252, 55),
						Color3.fromRGB(95, 95, 14),
						Color3.fromRGB(255, 255, 112)
					) then
						Util.AdjustObjectDescendantsColors(clone5, function(_, p)
							return applyColorShiftHSV(p, 0.41666667, 1.165137614678899, 1) or p
						end)
					end

					task.delay(ParticleState(clone5), clone5.Destroy, clone5)
				end

				task.wait(0.03)
			end
		end)
		task.spawn(function()
			for i = 1, 10 do
				local clone5 = assets.LightningPart:Clone()
				clone5.CFrame = cFrame * CFrame.Angles(
					random:NextNumber(0, 6.283185307179586),
					random:NextNumber(0, 6.283185307179586),
					random:NextNumber(0, 6.283185307179586)
				)
				Util.SetParentOverrideWithColor(clone5, folder, v, "PainFruitVFXColor")
				local attach1 = clone5.Attach1
				local position2 = position
				attach1.WorldPosition = position2 + (cFrame.Position - position2) * (i / 15) + Vector3.new(
					random:NextNumber(-25, 25),
					random:NextNumber(-25, 25),
					random:NextNumber(-25, 25)
				)
				local shafiBolt = ShafiBolt(v, clone5.Attach0, clone5.Attach1, random:NextNumber(35, 55), 5, folder)
				shafiBolt.CurveSize0 = 2
				shafiBolt.CurveSize1 = 2
				shafiBolt.PulseSpeed = 5
				shafiBolt.MinRadius = 3
				shafiBolt.MaxRadius = 5
				shafiBolt.Thickness = random:NextNumber(2.8, 4)

				if i % 2 == 0 then
					shafiBolt.Color = v2 and Color3.fromRGB(60, 128, 255) or Util.WrapColor3Constructor(
						Color3.fromRGB(214, 50, 50),
						v,
						"PainFruitVFXColor"
					)
					shafiBolt.Thickness = random:NextNumber(1.2, 2.4)
				end

				task.spawn(function()
					task.wait(0.05)
					local v15 = 0.08 + math.random() * 0.1
					local thickness = shafiBolt.Thickness

					for i2 = 0, 1, RunService.Heartbeat:Wait() / v15 do
						shafiBolt.Thickness = thickness + (0 - thickness) * i2
						task.wait()
					end

					shafiBolt:Destroy()
					clone5:Destroy()
				end)
				task.wait(0.03)
			end
		end)
		task.spawn(function()
			for i = 1, 6 do
				local clone5 = assets.LightningPart:Clone()
				local position2 = position
				local v12 = position2 + (cFrame.Position - position2) * (i / 8)
				local cframe = CFrame.lookAt(v12, v12 + cFrame.LookVector)
				local cFrame2 = cframe * CFrame.Angles(0, 3.141592653589793, 0) * CFrame.new(0, 0, -3) * CFrame.Angles(
					random:NextNumber(-0.7853981633974483, 1.5707963267948966),
					random:NextNumber(-1.5707963267948966, 1.5707963267948966),
					random:NextNumber(-1.5707963267948966, 1.5707963267948966)
				)
				clone5.CFrame = cFrame2
				Util.SetParentOverrideWithColor(clone5, folder, v, "PainFruitVFXColor")
				local raycastResult = nil

				for _ = 1, 12 do
					cFrame2 = cframe * CFrame.Angles(0, 3.141592653589793, 0) * CFrame.new(0, 0, -3) * CFrame.Angles(
						random:NextNumber(-0.7853981633974483, 1.5707963267948966),
						random:NextNumber(-1.5707963267948966, 1.5707963267948966),
						random:NextNumber(-1.5707963267948966, 1.5707963267948966)
					)
					clone5.CFrame = cFrame2
					raycastResult = workspace:Raycast(cFrame2.Position, cFrame2.LookVector * 30, raycastParams)

					if raycastResult and (raycastResult.Position - cFrame2.Position).Magnitude > 10 then
						break
					else
						raycastResult = nil
					end
				end

				if raycastResult then
					local clone6 = assets.LightningHit:Clone()
					clone6.CFrame = CFrame.lookAt(raycastResult.Position, raycastResult.Position + raycastResult.Normal)
					Util.SetParentOverrideWithColor(clone6, folder, v, "PainFruitVFXColor")
					task.delay(ParticleState(clone6), clone6.Destroy, clone6)
				end

				clone5.Attach1.WorldPosition = raycastResult and raycastResult.Position or cFrame2 * CFrame.new(
					0,
					0,
					random:NextNumber(20, 30)
				).Position
				local shafiBolt = ShafiBolt(v, clone5.Attach0, clone5.Attach1, random:NextNumber(10, 15), 1, folder)
				shafiBolt.PulseSpeed = 25
				shafiBolt.MinRadius = 5
				shafiBolt.MaxRadius = 12
				shafiBolt.Thickness = random:NextNumber(0.5, 1.2)

				if i % 2 == 0 then
					shafiBolt.Color = v2 and Color3.fromRGB(60, 128, 255) or Util.WrapColor3Constructor(
						Color3.fromRGB(214, 50, 50),
						v,
						"PainFruitVFXColor"
					)
					shafiBolt.Thickness = random:NextNumber(0.3, 1.5)
				end

				task.spawn(function()
					task.wait(0.1)
					local v17 = 0.08 + math.random() * 0.1
					local thickness = shafiBolt.Thickness

					for i2 = 0, 1, RunService.Heartbeat:Wait() / v17 do
						shafiBolt.Thickness = thickness + (0 - thickness) * i2
						task.wait()
					end

					shafiBolt:Destroy()
					clone5:Destroy()
				end)

				if i % 2 == 0 then
					task.wait(0.06)
				end
			end
		end)
		task.spawn(function()
			task.wait(0.2)

			for i = 1, 4 do
				local clone5 = assets.LightningPart:Clone()
				clone5.Anchored = false
				clone5.Weld.Part0 = humanoidRootPart
				Util.SetParentOverrideWithColor(clone5, folder, v, "PainFruitVFXColor")
				clone5.Attach1.WorldPosition = humanoidRootPart.Position + Vector3.new(
					random:NextNumber(-18, 18),
					random:NextNumber(5, 15),
					random:NextNumber(-18, 18)
				)
				local shafiBolt = ShafiBolt(v, clone5.Attach0, clone5.Attach1, random:NextNumber(35, 55), 5, folder)
				shafiBolt.CurveSize0 = 2
				shafiBolt.CurveSize1 = 15
				shafiBolt.PulseSpeed = 15
				shafiBolt.MinRadius = 2
				shafiBolt.MaxRadius = 4
				shafiBolt.Thickness = random:NextNumber(0.3, 0.6)

				if i % 2 == 0 then
					shafiBolt.Color = v2 and Color3.fromRGB(60, 128, 255) or Util.WrapColor3Constructor(
						Color3.fromRGB(214, 50, 50),
						v,
						"PainFruitVFXColor"
					)
					shafiBolt.Thickness = random:NextNumber(0.7, 1)
				end

				task.spawn(function()
					task.wait(0.05)
					local v13 = 0.08 + math.random() * 0.1
					local thickness = shafiBolt.Thickness

					for i2 = 0, 1, RunService.Heartbeat:Wait() / v13 do
						shafiBolt.Thickness = thickness + (0 - thickness) * i2
						task.wait()
					end

					shafiBolt:Destroy()
					clone5:Destroy()
				end)
				task.wait(0.05)
			end
		end)
		task.spawn(function()
			task.wait(0.15)
			local particleState2 = ParticleState(clone, false)
			task.delay(particleState2, clone.Destroy, clone)
		end)
	end
end