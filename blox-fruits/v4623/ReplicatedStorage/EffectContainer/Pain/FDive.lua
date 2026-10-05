local createVector = vector.create
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local TweenService = game:GetService("TweenService")
local _ = Util.Sound
local currentCamera = workspace.CurrentCamera
local FX = require(game.ReplicatedStorage.FX)
local assets = FX:WaitForChild("Pain").FDive.Assets
local _WorldOrigin = workspace:WaitForChild("_WorldOrigin")

local function Lerp(p, p2, p3)
	return p + (p2 - p) * p3
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

local function TrailCurve(clone, cframe, position, position2, cframe2, cframe3, p)
	local magnitude = (position - position2).Magnitude
	local v = (position - position2) / 2
	local position3 = CFrame.new(CFrame.new(position) * (v / -1.5)).Position
	local position4 = CFrame.new(CFrame.new(position2) * (v / 1.5)).Position
	math.random(20, 30)
	local v2 = CFrame.new(position3, position3 + cframe.LookVector) * cframe2.Position
	local v3 = CFrame.new(position4, position4 + cframe.LookVector) * cframe3.Position
	local lastTime = tick()
	local v4 = magnitude / p / 60
	local _ = (magnitude / p + p) / 60

	while tick() - lastTime < v4 do
		local v5 = (tick() - lastTime) / v4
		local v6 = cubicBezier(v5, position, v2, v3, position2)
		clone.CFrame = CFrame.new(clone.CFrame:Lerp(CFrame.new(v6, position2), v5).Position)
		RunService.Heartbeat:Wait()
	end
end

local random = Random.new()
local Crater = require(script.Crater)
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
local _ = {
	"rbxassetid://101209636636460",
	"rbxassetid://100567280039661",
	"rbxassetid://132292015450321",
	"rbxassetid://79010666407686",
	"rbxassetid://91750260034032",
	"rbxassetid://94419174296494",
	"rbxassetid://93281703243338",
	"rbxassetid://126716501698224",
	"rbxassetid://100216815243045",
	""
}
local _ = {
	"rbxassetid://85637129215139",
	"rbxassetid://96699820771383",
	"rbxassetid://137435909640640",
	"rbxassetid://115627397038144",
	"rbxassetid://110583586317888",
	"rbxassetid://78001177696805",
	"rbxassetid://86401875084731",
	"rbxassetid://104742342417476",
	"rbxassetid://80031433763147",
	"rbxassetid://77104125478788",
	""
}
local v = {
	"rbxassetid://88771098185018",
	"rbxassetid://96005854960728",
	"rbxassetid://117325338135183",
	"rbxassetid://93453260088779",
	"rbxassetid://78476917309896",
	"rbxassetid://98893789629427",
	"rbxassetid://72761888588062",
	"rbxassetid://75710440595597",
	"rbxassetid://102806897654090",
	"rbxassetid://86092907664424"
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

local lightningBoltShafi = Util.LightningBoltShafi

local function ShafiBolt(player, ...)
	local v2 = lightningBoltShafi.new(...)
	local curveSize = -math.random(25, 50)
	local curveSize2 = math.random(25, 50)
	v2.CurveSize0 = curveSize
	v2.CurveSize1 = curveSize2
	v2.MinRadius = 3
	v2.MaxRadius = 13
	v2.Frequency = 0.5
	v2.AnimationSpeed = 8
	local maxThicknessMultiplier = math.random(3, 4)
	v2.MinThicknessMultiplier = 0.2
	v2.MaxThicknessMultiplier = maxThicknessMultiplier
	v2.MinTransparency = 0
	v2.MaxTransparency = 1
	v2.PulseSpeed = 7
	v2.PulseLength = 1000000
	v2.FadeLength = 0.2
	v2.ContractFrom = 0.5
	v2.Color = Util.WrapColor3Constructor(Color3.new(1, 0.380392, 0.380392), player, "PainFruitVFXColor")
	v2.ColorOffsetSpeed = 3

	if player:IsA("Player") and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
		local humanoidRootPart = player.Character:FindFirstChild("HumanoidRootPart")

		if humanoidRootPart and humanoidRootPart:GetAttribute("PainSkin") and humanoidRootPart:GetAttribute("PainSkin") == "PAINSKINsuperspirit" then
			v2.Color = Color3.fromRGB(60, 128, 255)
		end
	end

	return v2
end

Util.ResizeModel(assets.Explosion, 1.45)
Util.ResizeModel(assets.PreExplosion, 1.45)
Util.ResizeModel(assets.FloorSmudge, 1.45)
Util.ResizeModel(assets.FloorExplosion, 1.45)
return function(data)
	local player = data.Player
	local origin = data.Origin

	if (currentCamera.CFrame.p - origin).Magnitude > 1300 then
		return
	end

	local stage = data.Stage

	if stage == 1 then
		local root = data.Root
		root.Anchored = true
		local v2 = root:GetAttribute("PainSkin") and root:GetAttribute("PainSkin") == "PAINSKINsuperspirit"
		local startCFrame = data.StartCFrame
		local magnitude = (root.Position - startCFrame.Position).Magnitude
		local noUp = data.noUp
		local parent = root.Parent

		if not noUp then
			Util.Sound:Play("F_DropKick_LeapUp_Release_0" .. tostring(math.random(1, 3)) .. "_V1", root)
			Util.Anims:Get(parent, "PainFStart"):Play()
			local clone = assets.LaunchParticles:Clone()
			Util.ResizeModel(clone, 0.7)
			clone.CFrame = CFrame.lookAt(root.Position, startCFrame.Position) * CFrame.Angles(0, 3.141592653589793, 0)
			Util.SetParentOverrideWithColor(clone, _WorldOrigin, player, "PainFruitVFXColor")
			local clone2 = assets.DashEmit:Clone()
			clone2.CFrame = root.CFrame
			Util.SetParentOverrideWithColor(clone2, _WorldOrigin, player, "PainFruitVFXColor")
			local particleState = ParticleState(clone2)
			task.delay(particleState, clone2.Destroy, clone2)
			local position = startCFrame.Position
			local cFrame = CFrame.lookAt(position, root.CFrame.Position) * CFrame.Angles(0, 3.141592653589793, 0)
			TweenService:Create(clone, TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
				CFrame = cFrame
			}):Play()
			task.delay(0.2, function()
				local particleState2 = ParticleState(clone, false)
				task.delay(particleState2, clone.Destroy, clone)
			end)
			local lastTime = os.clock()

			while os.clock() - lastTime < 0.05 do
				local v5 = (os.clock() - lastTime) / 0.05
				root.CFrame = startCFrame * CFrame.new(0, 0, magnitude * (1 - v5 ^ 0.5))
				RunService.PreSimulation:Wait()
			end

			root.CFrame = startCFrame
			root.Anchored = false
		end

		local painFAirHold = Util.Anims:Get(parent, "PainFAirHold")
		painFAirHold.Looped = true
		painFAirHold:Play()

		if not noUp then
			task.wait(0.2)
		end

		if noUp then
			Util.Sound:Play("F_InAir_WindUp_Release_0" .. tostring(math.random(1, 2)) .. "_V1", root)
		end

		task.spawn(function()
			local cframe = CFrame.new(root.Position)
			local v3 = _WorldOrigin
			local v4 = assets
			local clone = v4.Phase1.Aura:Clone()
			clone.CFrame = cframe
			Util.SetParentOverrideWithColor(clone, v3, player, "PainFruitVFXColor")

			for _, emitter in pairs(clone:GetDescendants()) do
				if emitter:IsA("ParticleEmitter") then
					emitter.Enabled = true
				end
			end

			local clone2 = v4.Phase1.Aura2:Clone()
			clone2.CFrame = cframe * CFrame.new(0, 1, 0)
			Util.SetParentOverrideWithColor(clone2, v3, player, "PainFruitVFXColor")

			for _, emitter in pairs(clone2:GetDescendants()) do
				if emitter:IsA("ParticleEmitter") then
					emitter.Enabled = true
				end
			end

			local v6 = tick() + (noUp and 0.4 or 0.2)
			local now = tick()
			local mouse = data.Mouse

			while true do
				local cframe2 = CFrame.new(root.Position, mouse.Value)

				if now - tick() <= 0 then
					now = tick() + 0.08
					task.spawn(function()
						local clone3 = v4.Phase1.Trail:Clone()
						clone3.CFrame = cframe2
						Util.SetParentOverrideWithColor(clone3, v3, player, "PainFruitVFXColor")
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
							cframe2,
							clone3.Position,
							cframe2.Position,
							CFrame.new(math.random(-50, 50) / 2, math.random(-50, 50) / 2, math.random(-50, 50) / 2),
							CFrame.new(math.random(-50, 50) / 2, math.random(-50, 50) / 2, math.random(-50, 50) / 2),
							math.random(25, 30) / 7,
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

				if not (v6 - tick() <= 0) then
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

				local clone3 = v4.Phase1.Explosion:Clone()
				clone3.CFrame = cframe2
				Util.SetParentOverrideWithColor(clone3, v3, player, "PainFruitVFXColor")

				for _, emitter in pairs(clone3:GetDescendants()) do
					if not emitter:IsA("ParticleEmitter") then
						continue
					end

					local v7 = emitter
					task.spawn(function()
						if v7:GetAttribute("EmitDelay") ~= 0 then
							task.wait(v7:GetAttribute("EmitDelay"))
						end

						v7:Emit(v7:GetAttribute("EmitCount"))
					end)
				end

				break
			end
		end)
		local clone = assets.Aura:Clone()
		clone.CFrame = root.CFrame
		Util.SetParentOverrideWithColor(clone, _WorldOrigin, player, "PainFruitVFXColor")

		if v2 then
			pcall(function()
				for _, descendant in pairs(clone:GetDescendants()) do
					if descendant.Name == "BigLightning" or descendant.Name == "BigStar" or descendant.Name == "StraightLightning" then
						descendant.Color = ColorSequence.new(Color3.fromRGB(60, 128, 255))
					end
				end
			end)
		end

		repeat
			task.wait()
		until not data.Proxy:IsDescendantOf(workspace)

		if painFAirHold then
			painFAirHold:Stop()
		end

		ParticleState(clone, false)
		task.spawn(function()
			task.wait(1)
			clone:Destroy()
		end)
	elseif stage == 2 then
		local root = data.Root
		local parent = root.Parent
		root.Anchored = true
		local v2 = root:GetAttribute("PainSkin") and root:GetAttribute("PainSkin") == "PAINSKINsuperspirit"
		local startCFrame = data.StartCFrame
		local dist = data.Dist
		local clone = assets.CharacterAura:Clone()
		clone.Anchored = true
		clone.CFrame = root.CFrame
		Util.SetParentOverrideWithColor(clone, _WorldOrigin, player, "PainFruitVFXColor")

		if v2 then
			pcall(function()
				clone.BigLightning.Color = ColorSequence.new(Color3.fromRGB(60, 128, 255))
				clone.BigStar.Color = ColorSequence.new(Color3.fromRGB(60, 128, 255))
			end)
		end

		local clone2 = assets.ShotEffect:Clone()
		clone2.CFrame = root.CFrame
		Util.SetParentOverrideWithColor(clone2, _WorldOrigin, player, "PainFruitVFXColor")
		local painFKick = Util.Anims:Get(parent, "PainFKick")
		painFKick.Looped = true
		painFKick:Play()
		local particleState = ParticleState(clone2)
		task.delay(particleState, clone2.Destroy, clone2)
		local lastTime = os.clock()
		local lastTime2 = os.clock()
		local heartbeatConnection = RunService.Heartbeat:Connect(function(_)
			if os.clock() - lastTime >= 0.03 then
				task.spawn(function()
					lastTime = os.clock()
					local clone3 = assets.AuraTrail:Clone()
					clone3.Trail.Lifetime = random:NextNumber(0.08, 0.15)
					local vector2 = Vector3.new(
						random:NextNumber(-45, 45),
						random:NextNumber(-45, 45),
						random:NextNumber(-45, 45)
					)
					local vector3 = Vector3.new(
						random:NextNumber(-45, 45),
						random:NextNumber(-45, 45),
						random:NextNumber(-45, 45)
					)
					local position = root.Position
					local _ = root.Position + vector2
					local _ = root.Position + vector3
					local _ = root.Position
					local number = random:NextNumber(0.1, 0.2)
					local position2 = root.Position
					clone3.Position = position2
					Util.SetParentOverrideWithColor(clone3, _WorldOrigin, player, "PainFruitVFXColor")

					for i = 0, 1, RunService.Heartbeat:Wait() / number do
						local v4 = root.Position + vector2
						local v5 = root.Position + vector3
						local position3 = root.Position
						local v6 = position + (v4 - position) * i
						local v7 = v4 + (v5 - v4) * i
						local v8 = v5 + (position3 - v5) * i
						local v9 = v6 + (v7 - v6) * i
						local v10 = v9 + (v7 + (v8 - v7) * i - v9) * i

						if position2 == v10 then
							continue
						end

						clone3.CFrame = CFrame.lookAt(v10, position2) * CFrame.Angles(0, 3.141592653589793, 0)
						RunService.Heartbeat:Wait()
						position2 = v10
					end

					local particleState2 = ParticleState(clone3, false)
					task.delay(particleState2 + 0.4, clone3.Destroy, clone3)
				end)
			end

			if os.clock() - lastTime2 >= 0.1 then
				lastTime2 = os.clock()
				local clone3 = assets.TravelShockwave:Clone()
				clone3.Weld.Part0 = root
				clone3.Weld.C0 = CFrame.Angles(
					1.5707963267948966,
					random:NextNumber(-3.141592653589793, 3.141592653589793),
					0
				)
				clone3.Mesh.Scale = createVector(25, 0, 25)
				clone3.Mesh.Offset = createVector(0, -15, 0)
				Util.SetParentOverrideWithColor(clone3, _WorldOrigin, player, "PainFruitVFXColor")
				TweenService:Create(
					clone3.Mesh,
					TweenInfo.new(0.15, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out),
					{
						Scale = createVector(10, 80, 10),
						Offset = createVector(0, 50, 0)
					}
				):Play()
				TweenService:Create(
					clone3.Decal,
					TweenInfo.new(0.15, Enum.EasingStyle.Cubic, Enum.EasingDirection.In),
					{
						Transparency = 1
					}
				):Play()
			end
		end)
		local duration = data.Duration
		local lastTime3 = os.clock()

		while os.clock() - lastTime3 < duration do
			local v4 = (os.clock() - lastTime3) / duration
			root.CFrame = startCFrame * CFrame.new(0, 0, dist * (1 - v4 ^ 0.5))
			clone.CFrame = root.CFrame
			RunService.PreSimulation:Wait()
		end

		if heartbeatConnection then
			heartbeatConnection:Disconnect()
		end

		root.CFrame = startCFrame
		root.Anchored = false
		local particleState3 = ParticleState(clone, false)
		task.delay(particleState3, clone.Destroy, clone)
		local Players = game:GetService("Players")

		if player == Players.LocalPlayer then
			TweenService:Create(currentCamera, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
				FieldOfView = 60
			}):Play()
		end

		if (workspace.CurrentCamera.CFrame.p - startCFrame.Position).Magnitude < 140 then
			Util.CameraShaker:ShakeOnce(10, 8, 0.2, 0.8)
			local clone3 = assets.ColorCorrection:Clone()
			Util.SetParentOverrideWithColor(clone3, game.Lighting, player, "PainFruitVFXColor")
			Util.Debris:AddItem(clone3, 0.5)
			TweenService:Create(clone3, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				Brightness = 0
			}):Play()
		end

		task.wait(0.010000000000000002)
		local raycastResult = workspace:Raycast(startCFrame.Position, createVector(0, -10, 0), raycastParams)
		local clone3 = assets.PreExplosion:Clone()
		clone3.CFrame = startCFrame
		Util.SetParentOverrideWithColor(clone3, _WorldOrigin, player, "PainFruitVFXColor")

		if raycastResult then
			Util.Sound:Play("F_Explosion_Debris_0" .. tostring(math.random(1, 2)) .. "_V1", startCFrame.Position)
		else
			Util.Sound:Play("F_Explosion_NoDebris_0" .. tostring(math.random(1, 2)) .. "_V1", startCFrame.Position)
		end

		task.delay(ParticleState(clone3), clone3.Destroy, clone3)

		if raycastResult then
			if painFKick then
				painFKick:Stop()
			end

			local painFLand = Util.Anims:Get(parent, "PainFLand")
			painFLand.Priority = Enum.AnimationPriority.Action2
			painFLand:Play()
			Crater(raycastResult, 120, 3, 9, 14)
			local clone4 = assets.FloorSmudge:Clone()
			clone4.CFrame = CFrame.lookAt(raycastResult.Position, raycastResult.Position + raycastResult.Normal) * CFrame.Angles(
				-1.5707963267948966,
				0,
				0
			)
			Util.SetParentOverrideWithColor(clone4, _WorldOrigin, player, "PainFruitVFXColor")
			local clone5 = assets.FloorExplosion:Clone()
			clone5.CFrame = CFrame.lookAt(raycastResult.Position, raycastResult.Position + raycastResult.Normal)
			Util.SetParentOverrideWithColor(clone5, _WorldOrigin, player, "PainFruitVFXColor")
			pcall(function()
				for _, descendant in pairs(clone5:GetDescendants()) do
					if descendant.Name == "BigLightning" or descendant.Name == "BigStar" or descendant.Name == "StraightLightning" then
						descendant.Color = ColorSequence.new(Color3.fromRGB(60, 128, 255))
					end
				end
			end)
			task.wait(0.1)
			task.delay(ParticleState(clone4), clone4.Destroy, clone4)
			task.delay(ParticleState(clone5), clone5.Destroy, clone5)
		else
			local clone4 = assets.Explosion:Clone()
			clone4.CFrame = startCFrame
			Util.SetParentOverrideWithColor(clone4, _WorldOrigin, player, "PainFruitVFXColor")

			if v2 then
				pcall(function()
					for _, descendant in pairs(clone4:GetDescendants()) do
						if descendant.Name == "BigLightning" or descendant.Name == "BigStar" or descendant.Name == "StraightLightning" then
							descendant.Color = ColorSequence.new(Color3.fromRGB(60, 128, 255))
						end
					end
				end)
			end

			task.wait(0.1)

			if painFKick then
				painFKick:Stop()
			end

			task.delay(ParticleState(clone4), clone4.Destroy, clone4)
		end

		task.spawn(function()
			for i = 1, 3 do
				task.spawn(function()
					local clone4 = assets.Cylinder:Clone()
					clone4.CFrame = startCFrame * CFrame.new(0, 50, 0) * CFrame.Angles(
						0,
						random:NextNumber(0, 6.283185307179586),
						0
					)
					clone4.Mesh.Scale = createVector(80, 150, 80)
					clone4.Decal.Transparency = random:NextNumber(0.9, 0.95)
					Util.SetParentOverrideWithColor(clone4, _WorldOrigin, player, "PainFruitVFXColor")
					local v5 = RunService.Heartbeat:Wait() * #v
					clone4.Mesh.Scale = createVector(10, 100, 10)
					clone4.Decal.Color3 = Util.WrapColor3Constructor(Color3.new(1, 1, 1), player, "PainFruitVFXColor")
					TweenService:Create(
						clone4.Mesh,
						TweenInfo.new(v5, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out),
						{
							Scale = createVector(75, 50, 75)
						}
					):Play()
					TweenService:Create(
						clone4.Decal,
						TweenInfo.new(v5, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
						{
							Transparency = 1
						}
					):Play()

					for _, texture in v do
						clone4.Decal.Texture = texture
						task.wait()
					end

					clone4:Destroy()
				end)

				if i % 2 == 0 then
					task.wait(random:NextNumber(0.02, 0.05))
				end
			end
		end)

		if raycastResult then
			task.spawn(function()
				for i = 1, 15 do
					local clone4 = FX:WaitForChild("Pain").FDive.Part:Clone()
					local cFrame = CFrame.new(startCFrame.Position) * CFrame.Angles(
						0,
						math.rad((math.random(-180, 180))),
						0
					) * CFrame.new(0, 0, -math.random(5, 25)) * CFrame.Angles(0, 0, -1.5707963267948966)
					clone4.CFrame = cFrame
					Util.SetParentOverrideWithColor(clone4, _WorldOrigin, player, "PainFruitVFXColor")
					clone4.Attach1.WorldPosition = cFrame * CFrame.new(
						math.random(-50, 50),
						math.random(-50, 50),
						-math.random(40, 70)
					).Position
					local shafiBolt = ShafiBolt(
						player,
						clone4.Attach0,
						clone4.Attach1,
						math.random(5, 10),
						1.5,
						_WorldOrigin
					)

					if i % 2 == 0 then
						shafiBolt.Color = Util.WrapColor3Constructor(
							Color3.fromRGB(214, 50, 50),
							player,
							"PainFruitVFXColor"
						)
						shafiBolt.Thickness = 1.25
					end

					task.spawn(function()
						task.wait(0.185 + math.random() * 0.2)
						shafiBolt:Destroy()
					end)
				end
			end)
		end

		local Players2 = game:GetService("Players")

		if player == Players2.LocalPlayer then
			TweenService:Create(currentCamera, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				FieldOfView = 70
			}):Play()
		end

		root.AssemblyLinearVelocity = createVector(0, 0, 0)
		root.AssemblyAngularVelocity = createVector(0, 0, 0)
		task.wait(0.25)
		root.Parent.Humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, true)
	end
end