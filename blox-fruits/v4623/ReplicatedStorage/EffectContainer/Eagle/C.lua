local createVector = vector.create
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local currentCamera = workspace.CurrentCamera
local FX = require(ReplicatedStorage:WaitForChild("FX"))
local eagleC = FX:WaitForChild("Eagle").EagleC
local _WorldOrigin = workspace._WorldOrigin
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local RockModule = require(script.RockModule)
local Effect = require(ReplicatedStorage:WaitForChild("Effect"))
local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Exclude
raycastParams.FilterDescendantsInstances = { workspace._WorldOrigin, workspace.Characters, workspace.Enemies }
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

local random = Random.new()

-- equivalent calls inferred from this helper; original call sites unknown
local function ScaleTween(clone, number: number, p, position)
	local total = 0
	local part = clone:FindFirstChildOfClass("Part")
	local lastTime = os.clock()
	local heartbeatConnection = nil
	heartbeatConnection = RunService.Heartbeat:Connect(function(dt)
		local value = game.TweenService:GetValue(
			math.min(total / p, 1),
			Enum.EasingStyle.Linear,
			Enum.EasingDirection.Out
		)
		total += dt
		local scale = clone:GetScale()
		clone:ScaleTo(scale + (number - scale) * value)

		if position then
			part.Position = position
		end

		if clone:GetScale() == number then
			heartbeatConnection:Disconnect()
		elseif p <= os.clock() - lastTime then
			heartbeatConnection:Disconnect()
		end
	end)
end

local function Sin(p)
	return (math.sin((math.rad(p))))
end

local function Cos(p)
	return (math.cos((math.rad(p))))
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

return function(state)
	local WAIT_INTERVAL = 5
	local DISTANCE_THRESHOLD = 70
	local player = state.player
	local origin = state.Origin

	if (currentCamera.CFrame.p - origin).Magnitude > 800 then
		return
	end

	local stage = state.Stage
	local root = state.Root

	if stage == 0 then
		local holding = state.Holding

		if not (holding and holding.Value) then
			return
		end

		local folder = Instance.new("Folder")
		folder.Name = "EffectsFolder"
		Util.SetParentOverrideWithColor(folder, _WorldOrigin, player, "EagleFruitVFXColor")
		local random2 = Random.new()
		local clone = eagleC.Charge:Clone()
		clone.Weld.Part0 = root.Parent:FindFirstChild("UpperTorso") or root
		Util.SetParentOverrideWithColor(clone, folder, player, "EagleFruitVFXColor")
		Util.Sound:Play("EagleFt_CV_Activate_01_V1", root)
		local v2 = Util.Sound:Play("EagleFt_M1_ShimmerOnly_01_V2", root)
		TweenService:Create(v2, TweenInfo.new(1), {
			Volume = 0.8
		}):Play()
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
			until not (holding:IsDescendantOf(workspace) and holding.Value)

			highlight:Destroy()
		end)
		Util.SetParentOverrideWithColor(highlight, state.Rig.Wings, player, "EagleFruitVFXColor")
		local clone2 = eagleC.FloorWind:Clone()
		clone2.Position = root.Position
		Util.SetParentOverrideWithColor(clone2, folder, player, "EagleFruitVFXColor")
		local lastTime = os.clock()
		local v3 = false
		os.clock()
		local raycastResult = nil
		local v4 = nil
		local heartbeatConnection = RunService.Heartbeat:Connect(function()
			raycastResult = workspace:Raycast(root.Position, createVector(0, -10, 0), raycastParams)

			if raycastResult then
				clone2.CFrame = CFrame.lookAt(raycastResult.Position, raycastResult.Position + raycastResult.Normal) * CFrame.Angles(
					-1.5707963267948966,
					0,
					0
				)

				if os.clock() - lastTime >= 0.04 then
					lastTime = os.clock()
					local clone3 = eagleC.FloorMesh:Clone()
					clone3.CFrame = CFrame.lookAt(raycastResult.Position, raycastResult.Position + raycastResult.Normal) * CFrame.Angles(
						-1.5707963267948966,
						random2:NextNumber(0, 6.283185307179586),
						0
					)
					Util.SetParentOverrideWithColor(clone3, _WorldOrigin, player, "EagleFruitVFXColor")
					local number = random2:NextNumber(9, 11)
					local number2 = random2:NextNumber(3, 6)
					TweenService:Create(
						clone3.Mesh,
						TweenInfo.new(#v * 0.04, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
						{
							Scale = Vector3.new(number, number2, number),
							Offset = Vector3.new(0, number2 / 3, 0)
						}
					):Play()
					task.spawn(function()
						for _, texture in v do
							clone3.Decal.Texture = texture
							task.wait(0.02)
						end

						clone3:Destroy()
					end)
				end

				if v3 == true then
					return
				end

				v4 = Util.Sound:Play("EagleFt_WindRushingLoop_03_V1", root)
				local folder2 = clone2

				for _, effect in pairs(folder2:GetDescendants()) do
					if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
						effect.Enabled = true
					end
				end

				v3 = true
			elseif v3 == true then
				local folder2 = clone2

				for _, effect in pairs(folder2:GetDescendants()) do
					if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
						effect.Enabled = false
					end
				end

				if v4 then
					Util.Sound:FadeOut(v4, 0.1)
				end

				v3 = false
			end
		end)

		repeat
			task.wait()
		until not (holding:IsDescendantOf(workspace) and holding.Value)

		heartbeatConnection:Disconnect()

		if v4 then
			Util.Sound:FadeOut(v4, 0.1)
		end

		if v2 then
			Util.Sound:FadeOut(v2, 0.2)
		end

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

		heartbeatConnection:Disconnect()
		task.wait(WAIT_INTERVAL)
		folder:Destroy()
	elseif stage == 1 then
		local flightTime = state.FlightTime
		local root2 = state.Root
		local startCFrame = state.StartCFrame
		local folder = Instance.new("Folder")
		folder.Name = "EffectsFolder"
		Util.SetParentOverrideWithColor(folder, _WorldOrigin, player, "EagleFruitVFXColor")
		Util.Debris:AddItem(folder, 10)
		local clone = eagleC.Wind:Clone()
		clone.Weld.Part0 = root
		Util.SetParentOverrideWithColor(clone, folder, player, "EagleFruitVFXColor")
		Util.Sound:Play("EagleFt_C_Release_Flight_01_V1", root)
		local flag = false
		local lastTime = os.clock()
		os.clock()
		local heartbeatConnection = RunService.Heartbeat:Connect(function(_)
			if os.clock() - lastTime <= 0.01 then
				return
			end

			lastTime = os.clock()
			local clone2 = eagleC.BeamModel:Clone()
			local beams = clone2.Beams
			clone2:ScaleTo(0.001)
			beams.CFrame = root.CFrame * CFrame.new(0, 0, -16) * CFrame.Angles(
				0,
				0,
				random:NextNumber(0, 6.283185307179586)
			)
			Util.SetParentOverrideWithColor(clone2, folder, player, "EagleFruitVFXColor")
			local position = beams.Position
			local number = random:NextNumber(0.4, 0.5)
			TweenService:Create(
				beams.MainSlash,
				TweenInfo.new(number * random:NextNumber(0.7, 0.9), Enum.EasingStyle.Linear),
				{
					Brightness = 0,
					LightEmission = 1
				}
			):Play()
			TweenService:Create(beams, TweenInfo.new(number, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
				Orientation = beams.Orientation + Vector3.new(0, 0, random:NextNumber(180, 600))
			}):Play()
			ScaleTween(clone2, random:NextNumber(0.6, 0.7), number + 0.3, position) -- equivalent call inferred; original call site unknown
		end)
		local endPoint = state.endPoint
		local flightTime2 = state.FlightTime or 0.5
		local magnitude = (startCFrame.Position - endPoint).Magnitude
		task.spawn(function()
			root2.Anchored = true
			local cFrame = CFrame.new(state.endPoint, root2.Position) * CFrame.Angles(0, 3.141592653589793, 0)
			local lastTime2 = os.clock()

			while os.clock() - lastTime2 < flightTime2 do
				local v3 = (os.clock() - lastTime2) / flightTime2
				root2.CFrame = cFrame * CFrame.new(0, 0, magnitude * (1 - v3))
				RunService.PreSimulation:Wait()
			end

			root2.CFrame = cFrame
			root2.Anchored = false
		end)

		for i = 0, 2 do
			local clone2 = eagleC.Trail:Clone()
			local v2 = i * 120
			clone2.CFrame = root.CFrame * CFrame.new(0, math.cos((math.rad(v2))) * 7, math.sin((math.rad(v2))) * 7)
			Util.SetParentOverrideWithColor(clone2, folder, player, "EagleFruitVFXColor")
			local heartbeatConnection2 = nil
			heartbeatConnection2 = RunService.Heartbeat:Connect(function(dt)
				if flag then
					local folder2 = clone2

					for i2, effect in pairs(folder2:GetDescendants()) do
						if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
							effect.Enabled = false
						end
					end

					heartbeatConnection2:Disconnect()
				end

				clone2.CFrame = root.CFrame * CFrame.new(math.sin((math.rad(v2))) * 7, math.cos((math.rad(v2))) * 7, 0)
				v2 += 360 * dt
			end)
		end

		task.wait(flightTime)
		flag = true

		for _, effect in pairs(clone:GetDescendants()) do
			if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
				effect.Enabled = false
			end
		end

		if heartbeatConnection then
			heartbeatConnection:Disconnect()
		end
	elseif stage == 2 then
		local folder = Instance.new("Folder")
		folder.Name = "EffectsFolder"
		Util.SetParentOverrideWithColor(folder, _WorldOrigin, player, "EagleFruitVFXColor")
		Util.Debris:AddItem(folder, 10)

		if state.EnemyGrabbed and state.GrabObject then
			local grabObject = state.GrabObject
			local enemyRoot = state.EnemyRoot
			local _ = state.EnemyGrabbed
			local enemyHum = state.EnemyHum
			local _ = state.Attacker
			local attackerHum = state.AttackerHum
			enemyRoot.CFrame = root.CFrame * CFrame.new(0, 0, -3) * CFrame.Angles(0, 3.141592653589793, 0)
			task.spawn(function()
				local lastTime = tick()

				while tick() - lastTime < state.GrabDur and grabObject and grabObject:IsDescendantOf(workspace) and root and enemyRoot and enemyRoot.Parent and root.Parent and attackerHum and enemyHum and not (enemyHum.Health <= 0 or attackerHum.Health <= 0) do
					enemyRoot.CFrame = root.CFrame * CFrame.new(0, 0, -3) * CFrame.Angles(0, 3.141592653589793, 0)
					RunService.PreSimulation:Wait()
				end
			end)

			if game.Players.LocalPlayer.Character == root.Parent or game.Players.LocalPlayer.Character == enemyRoot.Parent then
				Effect.new("ShakeCam"):play({
					4,
					12,
					0.1,
					1.5,
					createVector(1, 1, 1),
					createVector(1, 1, 2)
				})
			end

			local clone = eagleC.HitEffect:Clone()
			clone.CFrame = enemyRoot.CFrame * CFrame.Angles(0, 3.141592653589793, 0)
			Util.SetParentOverrideWithColor(clone, folder, player, "EagleFruitVFXColor")
			ParticleState(clone)
			task.spawn(function()
				task.wait(0.35)

				for _ = 1, 3 do
					local clone2 = eagleC.StarModel:Clone()
					clone2:ScaleTo(random:NextNumber(0.6, 1))
					local star = clone2.Star
					star.CFrame = root.CFrame * CFrame.new(
						random:NextNumber(-20, 20),
						random:NextNumber(0, 20),
						random:NextNumber(-20, 20)
					)
					Util.SetParentOverrideWithColor(star, folder, player, "EagleFruitVFXColor")
					ParticleState(star)
					task.wait(0.08333333333333333)
				end
			end)
			local clone2 = eagleC.WindUp:Clone()
			clone2.Weld.Part0 = root
			Util.SetParentOverrideWithColor(clone2, folder, player, "EagleFruitVFXColor")
			local clone3 = eagleC.ClawModel:Clone()
			local clawWindup = clone3.ClawWindup
			clawWindup.Weld.Part0 = enemyRoot
			Util.SetParentOverrideWithColor(clone3, folder, player, "EagleFruitVFXColor")
			local total = 0
			local part = clone3:FindFirstChildOfClass("Part")
			local lastTime = os.clock()
			local heartbeatConnection = nil
			local v2 = 3.5
			local v3 = 4
			local position2 = nil
			local v5 = 3.5
			heartbeatConnection = RunService.Heartbeat:Connect(function(dt)
				local value = game.TweenService:GetValue(
					math.min(total / v2, 1),
					Enum.EasingStyle.Linear,
					Enum.EasingDirection.Out
				)
				total += dt
				local scale = clone3:GetScale()
				clone3:ScaleTo(scale + (v3 - scale) * value)

				if position2 then
					part.Position = position2
				end

				if clone3:GetScale() == v3 then
					heartbeatConnection:Disconnect()
				elseif v5 <= os.clock() - lastTime then
					heartbeatConnection:Disconnect()
				end
			end)
			task.spawn(function()
				for _ = 1, 15 do
					task.spawn(function()
						local clone4 = eagleC["WindUpTrail" .. random:NextInteger(1, 4)]:Clone()
						local position3 = root.Position + Vector3.new(
							random:NextNumber(-40, 40),
							random:NextNumber(-40, 40),
							random:NextNumber(-40, 40)
						)
						local v7 = root.Position + Vector3.new(
							random:NextNumber(-40, 40),
							random:NextNumber(-40, 40),
							random:NextNumber(-40, 40)
						)
						local v8 = root.Position + Vector3.new(
							random:NextNumber(-40, 40),
							random:NextNumber(-40, 40),
							random:NextNumber(-40, 40)
						)
						local position = enemyRoot.Position
						clone4.Trail.Lifetime = random:NextNumber(0.06, 0.14)
						clone4.Position = position3
						Util.SetParentOverrideWithColor(clone4, folder, player, "EagleFruitVFXColor")

						for i = 0, 1, 0.1 do
							local v9 = position3 + (v7 - position3) * i
							local v10 = v7 + (v8 - v7) * i
							local v11 = v8 + (position - v8) * i
							local v12 = v9 + (v10 - v9) * i
							clone4.Position = v12 + (v10 + (v11 - v10) * i - v12) * i
							task.wait(0.015)
						end

						clone4.Position = position

						for _, effect in pairs(clone4:GetDescendants()) do
							if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
								effect.Enabled = false
							end
						end
					end)
					task.wait(0.04)
				end
			end)
			Util.Sound:Play("EagleFt_C_Target_RapidKicks_02_V1", enemyRoot)
			task.wait(0.5)

			for _, effect in pairs(clawWindup:GetDescendants()) do
				if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
					effect.Enabled = false
				end
			end

			for _, effect in pairs(clone2:GetDescendants()) do
				if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
					effect.Enabled = false
				end
			end

			local clone4 = eagleC.StarModel:Clone()
			local star = clone4.Star
			clone4:ScaleTo(5)
			star.Position = enemyRoot.Position
			Util.SetParentOverrideWithColor(star, folder, player, "EagleFruitVFXColor")
			ParticleState(star)
			task.wait(0.1)
			local clone5 = eagleC.Explosion:Clone()
			clone5.CFrame = enemyRoot.CFrame
			Util.SetParentOverrideWithColor(clone5, folder, player, "EagleFruitVFXColor")
			ParticleState(clone5)
			TweenService:Create(clone5.PointLight, TweenInfo.new(0.3, Enum.EasingStyle.Linear), {
				Range = 0,
				Brightness = 0
			}):Play()

			if (currentCamera.CFrame.p - clone5.Position).Magnitude <= DISTANCE_THRESHOLD then
				Util.CameraShaker:ShakeOnce(20, 16, 0.2, 0.25)
			end

			Util.Sound:Play("EagleFt_V_Spear_Feather_Explosions_01_V1", clone5.Position)
			Util.Sound:Play("EagleFt_C_TargetKick_AddFeathers_02_V2", clone5.Position)
			eagleC.HitEffect:Clone()
			clone.CFrame = enemyRoot.CFrame
			Util.SetParentOverrideWithColor(clone, folder, player, "EagleFruitVFXColor")
			ParticleState(clone)
			local clone6 = eagleC.KnockbackEfx:Clone()
			clone6.CFrame = enemyRoot.CFrame
			Util.SetParentOverrideWithColor(clone6, folder, player, "EagleFruitVFXColor")
			ParticleState(clone6)
			task.wait(WAIT_INTERVAL)
			folder:Destroy()
		end
	elseif stage == 3 then
		local folder = Instance.new("Folder")
		folder.Name = "EffectsFolder"
		Util.SetParentOverrideWithColor(folder, _WorldOrigin, player, "EagleFruitVFXColor")
		Util.Debris:AddItem(folder, 10)

		if state.EnemyGrabbed and state.GrabObject then
			local grabObject = state.GrabObject
			local enemyRoot = state.EnemyRoot
			local _ = state.EnemyGrabbed
			local enemyHum = state.EnemyHum
			local _ = state.Attacker
			local attackerHum = state.AttackerHum
			enemyRoot.CFrame = root.CFrame * CFrame.new(0, 0, -3) * CFrame.Angles(0, 3.141592653589793, 0)
			state.GrabDur += 0.3
			task.spawn(function()
				local lastTime = tick()

				while tick() - lastTime < state.GrabDur and grabObject and grabObject:IsDescendantOf(workspace) and root and enemyRoot and enemyRoot.Parent and root.Parent and attackerHum and enemyHum and not (enemyHum.Health <= 0 or attackerHum.Health <= 0) do
					enemyRoot.CFrame = root.CFrame * CFrame.new(0, 0, -3) * CFrame.Angles(0, 3.141592653589793, 0)
					RunService.PreSimulation:Wait()
				end
			end)

			if game.Players.LocalPlayer.Character == root.Parent or game.Players.LocalPlayer.Character == enemyRoot.Parent then
				Effect.new("ShakeCam"):play({
					4,
					12,
					0.1,
					1.5,
					createVector(1, 1, 1),
					createVector(1, 1, 2)
				})
			end

			local clone = eagleC.HitEffect:Clone()
			clone.CFrame = enemyRoot.CFrame * CFrame.Angles(0, 3.141592653589793, 0)
			Util.SetParentOverrideWithColor(clone, folder, player, "EagleFruitVFXColor")
			ParticleState(clone)
			task.spawn(function()
				task.wait(0.21)

				for _ = 1, 3 do
					local clone2 = eagleC.StarModel:Clone()
					clone2:ScaleTo(random:NextNumber(0.6, 1))
					local star = clone2.Star
					star.CFrame = root.CFrame * CFrame.new(
						random:NextNumber(-20, 20),
						random:NextNumber(0, 20),
						random:NextNumber(-20, 20)
					)
					Util.SetParentOverrideWithColor(star, folder, player, "EagleFruitVFXColor")
					ParticleState(star)
					task.wait(0.049999999999999996)
				end
			end)
			local clone2 = eagleC.WindUp:Clone()
			clone2.Weld.Part0 = root
			Util.SetParentOverrideWithColor(clone2, folder, player, "EagleFruitVFXColor")
			Util.Sound:Play("EagleFt_C_Target_LiftFromGround_Additional_01_V1", root)
			local clone3 = eagleC.ClawModel:Clone()
			local clawWindup = clone3.ClawWindup
			clawWindup.Weld.Part0 = enemyRoot
			Util.SetParentOverrideWithColor(clone3, folder, player, "EagleFruitVFXColor")
			local total = 0
			local part = clone3:FindFirstChildOfClass("Part")
			local lastTime = os.clock()
			local heartbeatConnection = nil
			local v2 = 3.3
			local v3 = 4
			local position2 = nil
			local v5 = 3.3
			heartbeatConnection = RunService.Heartbeat:Connect(function(dt)
				local value = game.TweenService:GetValue(
					math.min(total / v2, 1),
					Enum.EasingStyle.Linear,
					Enum.EasingDirection.Out
				)
				total += dt
				local scale = clone3:GetScale()
				clone3:ScaleTo(scale + (v3 - scale) * value)

				if position2 then
					part.Position = position2
				end

				if clone3:GetScale() == v3 then
					heartbeatConnection:Disconnect()
				elseif v5 <= os.clock() - lastTime then
					heartbeatConnection:Disconnect()
				end
			end)
			task.spawn(function()
				for _ = 1, 15 do
					task.spawn(function()
						local clone4 = eagleC["WindUpTrail" .. random:NextInteger(1, 4)]:Clone()
						local position3 = root.Position + Vector3.new(
							random:NextNumber(-40, 40),
							random:NextNumber(-40, 40),
							random:NextNumber(-40, 40)
						)
						local v7 = root.Position + Vector3.new(
							random:NextNumber(-40, 40),
							random:NextNumber(-40, 40),
							random:NextNumber(-40, 40)
						)
						local v8 = root.Position + Vector3.new(
							random:NextNumber(-40, 40),
							random:NextNumber(-40, 40),
							random:NextNumber(-40, 40)
						)
						local position = enemyRoot.Position
						clone4.Trail.Lifetime = random:NextNumber(0.06, 0.14)
						clone4.Position = position3
						Util.SetParentOverrideWithColor(clone4, folder, player, "EagleFruitVFXColor")

						for i = 0, 1, 0.1 do
							local v9 = position3 + (v7 - position3) * i
							local v10 = v7 + (v8 - v7) * i
							local v11 = v8 + (position - v8) * i
							local v12 = v9 + (v10 - v9) * i
							clone4.Position = v12 + (v10 + (v11 - v10) * i - v12) * i
							task.wait(0.015)
						end

						clone4.Position = position

						for _, effect in pairs(clone4:GetDescendants()) do
							if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
								effect.Enabled = false
							end
						end
					end)
					task.wait(0.04)
				end
			end)
			local quad = Util.Tween.ease.inout.quad
			local upCFrame = state.UpCFrame
			local magnitude = (root.Position - upCFrame.Position).Magnitude
			local lastTime2 = os.clock()

			while os.clock() - lastTime2 < 0.3 do
				local v6 = quad(math.clamp((os.clock() - lastTime2) / 0.3, 0, 1), 0, 1, 1)
				root.CFrame = upCFrame * CFrame.new(0, -magnitude * (1 - v6), 0)
				RunService.PreSimulation:Wait()
			end

			root.CFrame = upCFrame
			Util.Sound:Play("EagleFt_C_Target_RapidKicks_02_V1", root)
			task.wait(0.55)

			for _, effect in pairs(clawWindup:GetDescendants()) do
				if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
					effect.Enabled = false
				end
			end

			for _, effect in pairs(clone2:GetDescendants()) do
				if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
					effect.Enabled = false
				end
			end

			local clone4 = eagleC.StarModel:Clone()
			local star = clone4.Star
			clone4:ScaleTo(5)
			star.Position = root.Position
			Util.SetParentOverrideWithColor(star, folder, player, "EagleFruitVFXColor")
			ParticleState(star)
			task.wait(0.1)
			local clone5 = eagleC.Explosion:Clone()
			clone5.CFrame = root.CFrame
			Util.SetParentOverrideWithColor(clone5, folder, player, "EagleFruitVFXColor")
			ParticleState(clone5)

			if (currentCamera.CFrame.p - clone5.Position).Magnitude <= DISTANCE_THRESHOLD or game.Players.LocalPlayer.Character == root.Parent or game.Players.LocalPlayer.Character == enemyRoot.Parent then
				Util.CameraShaker:ShakeOnce(20, 16, 0.2, 0.25)
				local Effect2 = require(game.ReplicatedStorage.Effect)
				Effect2.new("ColorCorrection"):replicate({
					TintColor = Util.WrapColor3Constructor(Color3.fromRGB(126, 113, 64), player, "EagleFruitVFXColor"),
					Brightness = 1,
					Contrast = 1,
					Saturation = -1,
					FadeIn = 0,
					FadeOut = 0.3,
					Lifetime = 0
				})
			end

			Util.Sound:Play("EagleFt_V_Spear_Feather_Explosions_01_V1", clone5.Position)
			Util.Sound:Play("EagleFt_C_TargetKick_AddFeathers_02_V2", clone5.Position)
			TweenService:Create(clone5.PointLight, TweenInfo.new(0.3, Enum.EasingStyle.Linear), {
				Range = 0,
				Brightness = 0
			}):Play()
			eagleC.HitEffect:Clone()
			clone.CFrame = root.CFrame
			Util.SetParentOverrideWithColor(clone, folder, player, "EagleFruitVFXColor")
			ParticleState(clone)
			local clone6 = eagleC.KnockbackEfx:Clone()
			clone6.CFrame = root.CFrame
			Util.SetParentOverrideWithColor(clone6, folder, player, "EagleFruitVFXColor")
			ParticleState(clone6)
			task.wait(WAIT_INTERVAL)
			folder:Destroy()
		end
	elseif stage == 4 then
		local folder = Instance.new("Folder")
		folder.Name = "EffectsFolder"
		Util.SetParentOverrideWithColor(folder, _WorldOrigin, player, "EagleFruitVFXColor")
		Util.Debris:AddItem(folder, 10)
		local v2 = {
			Position = state.Origin,
			Instance = state.Ground,
			Normal = state.GroundNor
		}
		local clone = eagleC.FloorHit:Clone()
		clone.CFrame = CFrame.lookAt(state.Origin, state.Origin + state.GroundNor)
		Util.SetParentOverrideWithColor(clone, folder, player, "EagleFruitVFXColor")
		ParticleState(clone)

		if (currentCamera.CFrame.p - clone.Position).Magnitude <= DISTANCE_THRESHOLD then
			Util.CameraShaker:ShakeOnce(20, 16, 0.2, 0.25)
		end

		Util.Sound:Play("EagleFt_C_TargetGrab_Explosion_03_V1", clone.Position)
		RockModule.Crater(v2, 20, 3, 7, 6, folder)
		RockModule.Rocks(v2, 7, 20, 1, 3, 20, folder)
		local clone2 = eagleC.BeamModel2:Clone()
		local beam = clone2.Beam
		beam.CFrame = CFrame.lookAt(state.Origin, state.Origin + state.GroundNor) * CFrame.new(0, 0, -5) * CFrame.Angles(
			1.5707963267948966,
			0,
			0
		)
		Util.SetParentOverrideWithColor(clone2, folder, player, "EagleFruitVFXColor")
		local position = beam.Position
		local total = 0
		local part = clone2:FindFirstChildOfClass("Part")
		local lastTime = os.clock()
		local heartbeatConnection = nil
		local v3 = 4
		local v4 = 6
		local v5 = 4
		heartbeatConnection = RunService.Heartbeat:Connect(function(dt)
			local value = game.TweenService:GetValue(
				math.min(total / v3, 1),
				Enum.EasingStyle.Linear,
				Enum.EasingDirection.Out
			)
			total += dt
			local scale = clone2:GetScale()
			clone2:ScaleTo(scale + (v4 - scale) * value)

			if position then
				part.Position = position
			end

			if clone2:GetScale() == v4 then
				heartbeatConnection:Disconnect()
			elseif v5 <= os.clock() - lastTime then
				heartbeatConnection:Disconnect()
			end
		end)

		for _, beam2 in beam:GetChildren() do
			if beam2:IsA("Beam") then
				TweenService:Create(beam2, TweenInfo.new(0.2, Enum.EasingStyle.Linear), {
					Width0 = 0,
					Width1 = 0
				}):Play()
			end
		end
	end
end