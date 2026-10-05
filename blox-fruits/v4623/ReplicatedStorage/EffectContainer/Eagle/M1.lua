local createVector = vector.create
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local currentCamera = workspace.CurrentCamera
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local FX = require(ReplicatedStorage:WaitForChild("FX"))
local eagleM1 = FX:WaitForChild("Eagle").EagleM1
local _WorldOrigin = workspace._WorldOrigin
local random = Random.new()
local v = {
	"rbxassetid://97218754302954",
	"rbxassetid://92512315439090",
	"rbxassetid://132257721027585",
	"rbxassetid://109043178609027",
	"rbxassetid://115658457608521",
	"rbxassetid://94038468481404",
	"rbxassetid://111899774172836",
	"rbxassetid://95331025420540",
	"rbxassetid://104310000298124",
	"rbxassetid://92106515101094",
	"rbxassetid://114921472789923",
	"rbxassetid://110904262719869",
	"rbxassetid://121352197431255"
}

local function Lerp(p, p2, p3)
	return p + (p2 - p) * p3
end

local function Sin(p)
	return (math.sin((math.rad(p))))
end

local function Cos(p)
	return (math.cos((math.rad(p))))
end

local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Exclude
raycastParams.FilterDescendantsInstances = { workspace.Characters, workspace.Enemies, workspace._WorldOrigin }

local function ParticleState(folder, enabled, p)
	for _, effect in pairs(folder:GetDescendants()) do
		if not (effect:IsA("ParticleEmitter") or effect:IsA("Trail")) then
			continue
		end

		if p and effect:GetAttribute("Color") == true then
			effect.Color = ColorSequence.new({ ColorSequenceKeypoint.new(0, p), ColorSequenceKeypoint.new(1, p) })
		end

		if enabled == nil then
			effect:Emit(effect:GetAttribute("EmitCount"))
		else
			effect.Enabled = enabled
		end
	end
end

local function makeHighlight(player)
	local highlight = Instance.new("Highlight")
	highlight.FillColor = Util.WrapColor3Constructor(Color3.fromRGB(255, 183, 110), player, "EagleFruitVFXColor")
	highlight.FillTransparency = 0.55
	highlight.OutlineTransparency = 0.2
	highlight.OutlineColor = Util.WrapColor3Constructor(Color3.fromRGB(255, 183, 110), player, "EagleFruitVFXColor")
	highlight.DepthMode = Enum.HighlightDepthMode.Occluded
	return highlight
end

return function(instance)
	local player = instance.player
	local origin = instance.Origin

	if (currentCamera.CFrame.p - origin).Magnitude > 700 then
		return
	end

	local stage = instance.Stage
	local suppressSound = instance.SuppressSound

	if stage == 1 then
		local holding = instance.Holding

		if not (holding and holding.Value) then
			return
		end

		local folder = Instance.new("Folder")
		folder.Name = "FalconTAPEffect"
		Util.SetParentOverrideWithColor(folder, _WorldOrigin, player, "EagleFruitVFXColor")
		local flying = instance.Flying
		local root = instance.Root
		local clone = eagleM1.Charge:Clone()
		clone.Weld.Part0 = root
		Util.SetParentOverrideWithColor(clone, folder, player, "EagleFruitVFXColor")
		local v2

		if not suppressSound then
			if flying then
				v2 = Util.Sound:Play("EagleFt_M1_MoreWind_01_V2", root)
			else
				v2 = Util.Sound:Play("EagleFt_M1_WindAndShimmer_01_V2", root)
			end
		end

		local clone2 = eagleM1.FloatWind:Clone()
		clone2.Position = root.Position
		Util.SetParentOverrideWithColor(clone2, folder, player, "EagleFruitVFXColor")
		local clone3 = eagleM1.FloorWind:Clone()
		clone3.Position = root.Position
		Util.SetParentOverrideWithColor(clone3, folder, player, "EagleFruitVFXColor")
		local lastTime = os.clock()
		local v3 = false
		local v4 = false
		local lastTime2 = os.clock()
		local raycastResult = nil
		local highlight = makeHighlight(player)
		local fillTransparency = highlight.FillTransparency
		local outlineTransparency = highlight.OutlineTransparency
		highlight.FillTransparency = 1
		highlight.OutlineTransparency = 1
		task.spawn(function()
			repeat
				TweenService:Create(
					highlight,
					TweenInfo.new(0.4, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out, 0, true),
					{
						FillTransparency = fillTransparency,
						OutlineTransparency = outlineTransparency
					}
				):Play()
				task.wait(0.8)
			until not (holding and holding.Value)

			highlight:Destroy()
		end)
		Util.SetParentOverrideWithColor(highlight, instance.Rig.Wings, player, "EagleFruitVFXColor")
		local v5 = nil
		local heartbeatConnection = RunService.Heartbeat:Connect(function()
			raycastResult = workspace:Raycast(root.Position, createVector(0, -10, 0), raycastParams)
			clone2.Position = root.Position + createVector(0, -3, 0)

			if flying then
				clone2.Position = root.Position + createVector(0, -3, 0)

				if os.clock() - lastTime2 >= 0.03 then
					lastTime2 = os.clock()
					local number = random:NextNumber(0, 360)
					local number2 = random:NextNumber(3, 5)
					local number3 = random:NextNumber(7, 14)
					local number4 = random:NextNumber(270, 450)
					local number5 = random:NextNumber(0, 1)
					local number6 = random:NextNumber(10, 15)
					local number7 = random:NextNumber(0.3, 0.6)
					local v6 = root.Position + createVector(0, -3, 0)
					local clone4 = eagleM1.WindTrail:Clone()
					local v7 = math.sin((math.rad(number))) * number2
					local v8 = math.cos((math.rad(number))) * number2
					clone4.Position = v6 + Vector3.new(v7, number5, v8)
					Util.SetParentOverrideWithColor(clone4, folder, player, "EagleFruitVFXColor")
					local heartbeatConnection2 = RunService.Heartbeat:Connect(function(dt)
						number += number4 * dt
						number2 += number3 * dt
						number5 += number6 * dt
						clone4.Position = v6 + Vector3.new(
							math.sin((math.rad(number))) * number2,
							number5,
							math.cos((math.rad(number))) * number2
						)
					end)
					task.delay(number7, function()
						heartbeatConnection2:Disconnect()
					end)
				end

				if v4 == false then
					local folder2 = clone2

					for _, effect in pairs(folder2:GetDescendants()) do
						if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
							effect.Enabled = true
						end
					end

					v4 = true
				end
			elseif v4 == true then
				local folder2 = clone2

				for _, effect in pairs(folder2:GetDescendants()) do
					if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
						effect.Enabled = false
					end
				end

				v4 = false
			end

			if raycastResult then
				clone3.CFrame = CFrame.lookAt(raycastResult.Position, raycastResult.Position + raycastResult.Normal) * CFrame.Angles(
					-1.5707963267948966,
					0,
					0
				)

				if os.clock() - lastTime >= 0.04 then
					lastTime = os.clock()
					local clone4 = eagleM1.FloorMesh:Clone()
					clone4.CFrame = CFrame.lookAt(raycastResult.Position, raycastResult.Position + raycastResult.Normal) * CFrame.Angles(
						-1.5707963267948966,
						random:NextNumber(0, 6.283185307179586),
						0
					)
					Util.SetParentOverrideWithColor(clone4, folder, player, "EagleFruitVFXColor")
					local number = random:NextNumber(9, 11)
					local number2 = random:NextNumber(3, 6)
					TweenService:Create(
						clone4.Mesh,
						TweenInfo.new(#v * 0.04, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
						{
							Scale = Vector3.new(number, number2, number),
							Offset = Vector3.new(0, number2 / 3, 0)
						}
					):Play()
					task.spawn(function()
						for _, texture in v do
							clone4.Decal.Texture = texture
							task.wait(0.02)
						end

						clone4:Destroy()
					end)
				end

				if v3 == true then
					return
				end

				if not suppressSound then
					v5 = Util.Sound:Play("EagleFt_WindRushingLoop_03_V1", root)
				end

				local folder2 = clone3

				for _, effect in pairs(folder2:GetDescendants()) do
					if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
						effect.Enabled = true
					end
				end

				v3 = true
			elseif v3 == true then
				local folder2 = clone3

				for _, effect in pairs(folder2:GetDescendants()) do
					if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
						effect.Enabled = false
					end
				end

				if v5 then
					Util.Sound:FadeOut(v5, 0.1)
				end

				v3 = false
			end
		end)

		if instance.Side == "Right" then
			clone.Aura.Weld.C0 = CFrame.new(0, 1.5, 2) * CFrame.Angles(0, -0.17453292519943295, 1.5707963267948966)
		else
			clone.Aura.Weld.C0 = CFrame.new(0, 1.5, 2.5) * CFrame.Angles(0.3490658503988659, 0, -1.5707963267948966)
		end

		local lastTime3 = tick()
		local v6 = false

		while true do
			task.wait()

			if tick() - lastTime3 >= 1 and not v6 then
				v6 = true

				if not suppressSound then
					Util.Sound:Play("EagleFt_M1_Activate_01_V1", root)
				end

				local clone4 = eagleM1.ChargeExplosion:Clone()
				clone4.CFrame = root.CFrame * CFrame.Angles(0, 3.141592653589793, 0)
				Util.SetParentOverrideWithColor(clone4, folder, player, "EagleFruitVFXColor")
				ParticleState(clone4)
			end

			if holding:IsDescendantOf(workspace) and holding.Value then
				continue
			end

			if v5 then
				Util.Sound:FadeOut(v5, 0.1)
			end

			if v2 then
				Util.Sound:FadeOut(v2, 0.2)
			end

			for _, effect in pairs(clone3:GetDescendants()) do
				if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
					effect.Enabled = false
				end
			end

			heartbeatConnection:Disconnect()

			for _, effect in pairs(clone2:GetDescendants()) do
				if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
					effect.Enabled = false
				end
			end

			for _, effect in pairs(clone:GetDescendants()) do
				if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
					effect.Enabled = false
				end
			end

			task.wait(5)
			folder:Destroy()
			return
		end
	elseif stage == 2 then
		local totalTime = instance.TotalTime
		local speed = instance.Speed
		local lifetime = instance.Lifetime
		local _ = instance.Spread
		local featherCount = instance.FeatherCount
		local attachTime = instance.AttachTime
		local _ = speed * lifetime
		local _ = instance.Humanoid
		local HRP = instance.HRP
		local _ = instance.Tool
		local folder = Instance.new("Folder")
		folder.Name = "FalconTAPEffect"
		Util.SetParentOverrideWithColor(folder, _WorldOrigin, player, "EagleFruitVFXColor")
		Util.Debris:AddItem(folder, 10)
		local clone = eagleM1.ShootEffect:Clone()
		clone.CFrame = HRP.CFrame * CFrame.new(0, 0, -5)
		Util.SetParentOverrideWithColor(clone, folder, player, "EagleFruitVFXColor")

		if not suppressSound then
			Util.Sound:Play("EagleFt_M1_ThrowFeather_0" .. tostring(math.random(1, 6)) .. "_V3", HRP)
		end

		ParticleState(clone)

		for i = 1, featherCount do
			local v3 = instance.FeatherData[i]
			task.delay(random:NextNumber(0, totalTime), function()
				local randomEndPos = v3.RandomEndPos
				local clone2 = eagleM1["Feather" .. math.random(1, 4)]:Clone()
				clone2.CFrame = clone.CFrame * v3.clientStartCFrame
				clone2.Feather.Feather.Brightness = math.random(1, 2) == 1 and 0.175 or clone2.Feather.Feather.Brightness
				Util.SetParentOverrideWithColor(clone2, folder, player, "EagleFruitVFXColor")
				local number = random:NextNumber(0, 1)
				local position = clone2.Position
				local lookVector = CFrame.lookAt(clone.Position, position).LookVector

				if v3.CanStick then
					if typeof(v3.CanStick) == "boolean" or typeof(v3.CanStick) == "number" then
						v3.CanStick = nil
					else
						randomEndPos = v3.CanStick.Position
					end
				end

				local position2 = clone2.Position
				local v4 = HRP.Position + lookVector * 30
				local v5 = position + (randomEndPos - position) * 0.1
				local position3 = HRP.Position
				local duration = v3.Duration
				local lastTime = tick()
				local v7 = false

				while tick() - lastTime < duration do
					local v8 = (tick() - lastTime) / duration
					local v9 = position2 + (v4 - position2) * v8
					local v10 = v4 + (v5 - v4) * v8
					local v11 = v5 + (randomEndPos - v5) * v8
					local v12 = v9 + (v10 - v9) * v8
					local v13 = v10 + (v11 - v10) * v8

					if number < v8 and v7 == false then
						local clone3 = eagleM1.Glow:Clone()
						clone3.Weld.Part0 = clone2
						Util.SetParentOverrideWithColor(clone3, folder, player, "EagleFruitVFXColor")
						ParticleState(clone3)
						clone2.SharpStar.Enabled = true
						v7 = true
					end

					local v14 = v12 + (v13 - v12) * v8

					if v8 ~= 0 then
						clone2.CFrame = CFrame.lookAt(v14, position3) * CFrame.Angles(0, 3.141592653589793, 0)
					end

					task.wait()
					position3 = v14
				end

				clone2.Attachment.SharpStar.Enabled = false
				clone2.Circles.Enabled = false
				clone2.SharpStar.Enabled = false

				if v3.HitSurface or v3.CanStick then
					if v3.CanStick then
						for i2, effect in pairs(clone2:GetDescendants()) do
							if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
								effect.Enabled = false
							end
						end

						local clone3 = eagleM1.Feathers["Feather" .. random:NextInteger(1, 3)]:Clone()
						clone3.Weld.Part0 = v3.CanStick
						clone3.Weld.C0 = CFrame.new(
							random:NextNumber(-3, 3),
							random:NextNumber(-3, 3),
							random:NextNumber(-3, 3)
						) * CFrame.Angles(
							random:NextNumber(0, 6.283185307179586),
							random:NextNumber(0, 6.283185307179586),
							random:NextNumber(0, 6.283185307179586)
						)
						Util.SetParentOverrideWithColor(clone3, folder, player, "EagleFruitVFXColor")

						if not suppressSound then
							Util.Sound:Play(
								"EagleFt_Z_TargetHit_0" .. tostring(math.random(1, 5)) .. "_V2",
								clone3.Position
							)
						end

						task.wait(attachTime)
						local position4 = clone3.Position
						clone3:Destroy()
						local clone4 = eagleM1.Explosion:Clone()
						clone4.Position = position4
						Util.SetParentOverrideWithColor(clone4, folder, player, "EagleFruitVFXColor")
						TweenService:Create(clone4.PointLight, TweenInfo.new(0.2, Enum.EasingStyle.Linear), {
							Brightness = 0,
							Range = 0
						}):Play()
						ParticleState(clone4)

						if not suppressSound then
							Util.Sound:Play(
								"EagleFt_M1_Explode_0" .. tostring(math.random(1, 7)) .. "_V1",
								clone4.Position
							)
						end
					else
						clone2.Position = randomEndPos
						task.wait(attachTime)
					end
				else
					clone2.Position = randomEndPos
					local bodyVelocity = Instance.new("BodyVelocity")
					bodyVelocity.Velocity = Vector3.new(
						random:NextNumber(-1, 1),
						random:NextNumber(-1, 1),
						random:NextNumber(-1, 1)
					).Unit * speed * 0.2
					bodyVelocity.MaxForce = createVector(700000, 700000, 700000)
					Util.SetParentOverrideWithColor(bodyVelocity, clone2, player, "EagleFruitVFXColor")
					local number2 = random:NextNumber(0.2, 0.5)
					TweenService:Create(
						bodyVelocity,
						TweenInfo.new(number2, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out),
						{
							Velocity = Vector3.new(0, random:NextNumber(-20, -10), 0)
						}
					):Play()
					clone2.Anchored = false
					task.wait(number2)
					bodyVelocity:Destroy()
				end

				if not v3.CanStick then
					local clone3 = eagleM1.Explosion:Clone()
					clone3.Position = clone2.Position
					Util.SetParentOverrideWithColor(clone3, folder, player, "EagleFruitVFXColor")
					TweenService:Create(clone3.PointLight, TweenInfo.new(0.2, Enum.EasingStyle.Linear), {
						Brightness = 0,
						Range = 0
					}):Play()

					for i2, effect in pairs(clone2:GetDescendants()) do
						if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
							effect.Enabled = false
						end
					end

					ParticleState(clone3)

					if not suppressSound then
						Util.Sound:Play("EagleFt_M1_Explode_0" .. tostring(math.random(1, 7)) .. "_V1", clone3.Position)
					end
				end

				task.wait(5)
				folder:Destroy()
			end)
		end
	end
end