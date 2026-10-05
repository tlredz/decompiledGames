local createVector = vector.create
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Util = require(ReplicatedStorage:WaitForChild("Util"))
game:GetService("TweenService")
local FX = require(ReplicatedStorage:WaitForChild("FX"))
local gameplay = FX:WaitForChild("ControlRework").Gameplay
local _ = Players.LocalPlayer
local utility = script.Parent.Shared.Utility
local VisualHelper = require(utility.VisualHelper)
require(utility.MathHelper)

-- equivalent calls inferred from this helper; original call sites unknown
local function easeOutQuad(value)
	local v = math.clamp(value, 0, 1)
	return 1 - (1 - v) * (1 - v)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function easeInOutQuad(value)
	local v = math.clamp(value, 0, 1)

	if v < 0.5 then
		return 2 * v * v
	end

	return 1 - (-2 * v + 2) ^ 2 / 2
end

-- equivalent calls inferred from this helper; original call sites unknown
local function randomUnitVector(value)
	local vector2 = Vector3.new(math.random() - 0.5, math.random() - (value or 0.2), math.random() - 0.5)

	if vector2.Magnitude < 0.001 then
		return createVector(1, 0, 0)
	end

	return vector2.Unit
end

local function yawOnly(cFrame: CFrame)
	local position = cFrame.Position
	local lookVector = cFrame.LookVector
	local vector2 = Vector3.new(lookVector.X, 0, lookVector.Z)
	local v = vector2.Magnitude < 0.0001 and createVector(0, 0, -1) or vector2.Unit
	local v2 = math.atan2(-v.X, -v.Z)
	return CFrame.new(position) * CFrame.Angles(0, v2, 0)
end

local function setEnabled(vfxAttachment, enabled: boolean)
	for _, emitter in vfxAttachment:GetChildren() do
		if emitter:IsA("ParticleEmitter") then
			emitter.Enabled = enabled
		end
	end
end

local v = {
	RootJoint = true,
	Waist = true,
	Neck = true,
	Root = true,
	LeftShoulder = true,
	LeftElbow = true,
	LeftWrist = true,
	RightShoulder = true,
	RightElbow = true,
	RightWrist = true,
	LeftHip = true,
	LeftKnee = true,
	LeftAnkle = true,
	RightHip = true,
	RightKnee = true,
	RightAnkle = true
}
return function(player)
	if typeof(player.Player) == "Instance" and player.Player:IsA("Player") and not player.Player:FindFirstChild("PlayerGui") and player.Player ~= game.Players.LocalPlayer then
		local folder = Instance.new("Folder", player.Player)
		folder.Name = "PlayerGui"
	end

	local duration = player.Duration or 2
	local character = player.Character

	if not character then
		return
	end

	local humanoid = character:FindFirstChildOfClass("Humanoid")
	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

	if not (humanoid and humanoidRootPart) then
		return
	end

	local upperTorso = character:FindFirstChild("UpperTorso")
	local lowerTorso = character:FindFirstChild("LowerTorso")
	local head = character:FindFirstChild("Head")

	if not (upperTorso and lowerTorso and head) then
		return
	end

	if character:GetAttribute("ControlDisassemble") then
		character:SetAttribute("ControlDisassemble", nil)
		task.wait()
		task.wait()

		if character:GetAttribute("ControlDisassemble") then
			return
		end
	end

	local motor6Ds = {}

	for _, motor6D in ipairs(character:GetDescendants()) do
		if motor6D:IsA("Motor6D") and v[motor6D.Name] and motor6D.Part0 and motor6D.Part1 then
			table.insert(motor6Ds, motor6D)
		end
	end

	if #motor6Ds == 0 then
		warn("[Disassemble] no limbs/motors found")
		return
	end

	humanoid.RequiresNeck = false
	local cFrame = humanoidRootPart.CFrame
	Util.Sound:Play("X_Disassembly_0" .. tostring(math.random(1, 3)), humanoidRootPart)
	local v2 = {}

	for _, motor in ipairs(motor6Ds) do
		local part0 = motor.Part0
		local C0 = motor.C0
		local part1 = motor.Part1

		if not (part0 and part1) then
			continue
		end

		local cFrame2 = part1.CFrame
		local C02 = humanoidRootPart.CFrame:Inverse() * cFrame2 * motor.C1
		motor.Part0 = humanoidRootPart
		motor.C0 = C02
		motor.Transform = CFrame.identity
		local v5 = C02 * motor.C1:Inverse()
		local position = v5.Position
		local baseLocalRot = v5 - position
		local disassembleBodyPattern = part1:FindFirstChild("DisassembleBodyPattern")

		if not disassembleBodyPattern and part1.Transparency < 1 then
			local clone = gameplay.Disassemble:Clone()
			clone:ScaleTo(part1.Size.Magnitude * 0.1)
			disassembleBodyPattern = clone.Part.DisassembleBodyPattern
			Util.SetParentOverrideWithColor(disassembleBodyPattern, part1, player.Player, "ControlFruitVFXColor")
			clone:Destroy()
		end

		local v7 = {
			motor = motor,
			vfxAttachment = disassembleBodyPattern,
			origPart0 = part0,
			origC0 = C0,
			C0Inv = motor.C0:Inverse(),
			C1 = motor.C1,
			baseLocalPos = position,
			baseLocalRot = baseLocalRot,
			simPos = (cFrame * v5).Position,
			lastTransform = CFrame.identity,
			dir = randomUnitVector(player.Radial and 0.5 or nil),
			maxDist = math.random(80, 240) / 10,
			chaseDelay = math.random() * (1.35 - (2 - duration)),
			phase = math.random() * 3.141592653589793 * 2
		}
		table.insert(v2, v7)
	end

	local now = os.clock()
	local preSimulationConnection = nil
	local main, clone

	if player.NoExtras then
		main = nil
		clone = nil
	else
		clone = gameplay.MarkGUI:Clone()
		clone.Adornee = humanoidRootPart
		clone.Enabled = false
		Util.SetParentOverrideWithColor(clone, workspace.Terrain, player.Player, "ControlFruitVFXColor")
		main = clone.Main
		main.Magnitude.Text = "0%"
		task.delay(0.2, function()
			VisualHelper:Tween(main.IconA, TweenInfo.new(0.9, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, -1), {
				Rotation = main.IconA.Rotation - 360
			})
			VisualHelper:Tween(
				main.IconB,
				TweenInfo.new(0.4, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, -1, true),
				{
					ImageTransparency = 0.8,
					Size = UDim2.fromScale(0.85, 0.85)
				}
			)
			VisualHelper:Tween(
				main.IconC,
				TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, -1, true),
				{
					ImageTransparency = 1,
					Size = UDim2.fromScale(0.8, 0.8)
				}
			)
			clone.Enabled = true
			main.Size = UDim2.new()
			VisualHelper:Tween(main, TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
				Size = UDim2.fromScale(1, 1)
			})
		end)
	end

	character:SetAttribute("ControlDisassemble", true)
	local v3 = false
	preSimulationConnection = RunService.PreSimulation:Connect(function(dt)
		upperTorso.CanCollide = false
		lowerTorso.CanCollide = false
		head.CanCollide = false
		humanoid.AutoRotate = false
		local now2 = os.clock()
		local v4 = now2 - now

		if main then
			main.Magnitude.Text = string.format("%d%%", 100 * ((v4 - 0.2) / (duration - 0.2)))
		end

		if duration < v4 or character:GetAttribute("ControlDisassemble") == nil then
			for _, v5 in ipairs(v2) do
				local motor = v5.motor

				if motor and motor.Parent then
					motor.Transform = CFrame.identity
					motor.Part0 = v5.origPart0
					motor.C0 = v5.origC0
				end

				if not v5.vfxAttachment then
					continue
				end

				setEnabled(v5.vfxAttachment, false)
				v5.vfxAttachment.Name = "Destroying"
				local v6 = v5
				task.delay(1, function()
					v6.vfxAttachment:Destroy()
				end)
			end

			if not player.NoExtras then
				local clone2 = gameplay.ReassemblyExplosion.Part.Boom:Clone()
				Util.SetParentOverrideWithColor(clone2, humanoidRootPart, player.Player, "ControlFruitVFXColor")

				for _, emitter in clone2:GetChildren() do
					if emitter:IsA("ParticleEmitter") then
						emitter:Emit(emitter:GetAttribute("EmitCount") or 1)
					end
				end

				task.delay(3, function()
					clone2:Destroy()
				end)
				VisualHelper:Tween(main, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
					Size = UDim2.new()
				})
				task.delay(1, function()
					clone:Destroy()
				end)
			end

			upperTorso.CanCollide = true
			lowerTorso.CanCollide = true
			head.CanCollide = true
			humanoid.AutoRotate = true
			humanoid.RequiresNeck = true
			character:SetAttribute("ControlDisassemble", nil)

			if preSimulationConnection then
				preSimulationConnection:Disconnect()
				preSimulationConnection = nil
			end
		else
			local v5 = duration - 0.25
			local cframe = yawOnly(humanoidRootPart.CFrame)

			for _, v6 in ipairs(v2) do
				local motor = v6.motor

				if not (motor and motor.Parent) then
					continue
				end

				local position = (cframe * CFrame.new(v6.baseLocalPos)).Position
				local maxDist = v6.maxDist
				local chaseDelay = v6.chaseDelay
				local v7 = 0.5 + chaseDelay
				local v8 = math.max(v5 - v7, 0.001)

				if v4 <= 0.35 then
					maxDist *= easeOutQuad(v4 / 0.35)
				elseif not (v4 <= 0.5 or v4 < v7) then
					if v4 < v5 then
						local v9 = easeInOutQuad((v4 - v7) / v8) -- equivalent call inferred; original call site unknown
						maxDist = math.max(maxDist * (1 - v9), 0.6)
					else
						maxDist = 0.6 * (1 - easeOutQuad((v4 - v5) / 0.25))
					end
				end

				local v9 = math.sin(now2 * 12 + v6.phase) * 0.5
				local v10 = position + v6.dir * maxDist + Vector3.new(0, v9, 0)
				local v11

				if v4 <= 0.5 then
					v11 = 5 * (0.5 + v6.phase / 6.283185307179586)
				elseif v4 < v5 then
					local v12 = math.max(v5 - 0.5, 0.001)
					local v13 = math.clamp((v4 - 0.5) / v12, 0, 1)
					local v14

					if v13 < 0.5 then
						v14 = v13 / 0.5 * 4 + 1
					else
						local v15 = (v13 - 0.5) / 0.5
						v14 = (math.max(chaseDelay * 30, 3) - 3) * v15 + 5
					end

					v11 = v14 * (0.5 + v6.phase / 6.283185307179586)
				else
					v11 = 60

					if v6.vfxAttachment then
						setEnabled(v6.vfxAttachment, false)
					end

					if not v3 then
						v3 = true
						Util.Sound:Play("X_Reassembly_0" .. tostring(math.random(1, 3)), humanoidRootPart)
					end
				end

				local v12 = 1 - math.exp(-v11 * dt)
				v6.simPos = v6.simPos:Lerp(v10, v12)
				local v13 = v6.phase + v4 * 4
				local v14

				if v7 <= v4 and v4 < v5 then
					v14 = v13 * (1 - (v4 - v7) / v8)
				else
					v14 = v5 <= v4 and 0 or v13
				end

				local v15 = CFrame.new(v6.simPos) * (cframe.Rotation * v6.baseLocalRot.Rotation) * CFrame.Angles(
					v14 * 0.1,
					v14 * 0.3,
					v14 * 0.15
				)
				local v16 = v6.C0Inv * cframe:Inverse() * v15 * v6.C1
				local v17 = 1 - math.exp(-25 * dt)
				v6.lastTransform = v6.lastTransform:Lerp(v16, v17)
				motor.Transform = v6.lastTransform
			end
		end
	end)
end