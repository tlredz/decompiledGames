local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local TweenService = game:GetService("TweenService")
local _ = Util.Sound
local currentCamera = workspace.CurrentCamera
local FX = require(ReplicatedStorage:WaitForChild("FX"))
local X = FX:WaitForChild("BombRework").X
local _WorldOrigin = workspace._WorldOrigin

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

	while tick() - lastTime < v4 do
		local v5 = (tick() - lastTime) / v4
		local v6 = cubicBezier(v5, position, v2, v3, position2)
		clone.CFrame = CFrame.new(clone.CFrame:Lerp(CFrame.new(v6, position2), v5).Position)
		RunService.Heartbeat:Wait()
	end
end

return function(data)
	local origin = data.Origin
	local player = data.Player

	if (currentCamera.CFrame.p - origin).Magnitude > 800 then
		return
	end

	local stage = data.Stage

	if stage == 1 then
		local folder = Instance.new("Folder")
		Util.SetParentOverrideWithColor(folder, _WorldOrigin, player, "BombFruitVFXColor")
		Util.Debris:AddItem(folder, 7)
		local root = data.Root
		local startCFrame = data.StartCFrame
		local clone = X.Phase1.StartImpact:Clone()
		clone.CFrame = startCFrame
		Util.SetParentOverrideWithColor(clone, folder, player, "BombFruitVFXColor")
		Util.Sound:Play("BF_NewFruit_X_Explosion_01", startCFrame.Position)

		if (workspace.CurrentCamera.CFrame.p - startCFrame.Position).Magnitude < 70 then
			Util.CameraShaker:ShakeOnce(8, 6, 0.1, 0.25)
		end

		DeleteImpactAfterDuration(clone) -- equivalent call inferred; original call site unknown

		for _, emitter in pairs(clone:GetDescendants()) do
			if not emitter:IsA("ParticleEmitter") then
				continue
			end

			local v = emitter
			task.spawn(function()
				if v:GetAttribute("EmitDelay") ~= 0 then
					task.wait(v:GetAttribute("EmitDelay"))
				end

				v:Emit(v:GetAttribute("EmitCount"))
			end)
		end

		local _ = data.distTravelledForward
		local _ = data.endPoint
		local timeUntilReachedEndPoint = data.timeUntilReachedEndPoint or 0.1
		local distTravelledForward = data.distTravelledForward
		local cFrame = CFrame.new(data.endPoint, root.Position) * CFrame.Angles(0, 3.141592653589793, 0)
		local clone2 = X.Phase1.DashAura:Clone()
		clone2.CFrame = root.CFrame
		Util.SetParentOverrideWithColor(clone2, folder, player, "BombFruitVFXColor")
		clone2.Anchored = true
		Util.Sound:Play("BF_NewFruit_X_FlameWhoosh_Dash_05", root)

		for _, emitter in pairs(clone2:GetDescendants()) do
			if not emitter:IsA("ParticleEmitter") then
				continue
			end

			emitter.Enabled = true
			emitter:Emit(3)
		end

		root.Anchored = true
		local lastTime = os.clock()

		while os.clock() - lastTime < timeUntilReachedEndPoint do
			local v2 = (os.clock() - lastTime) / timeUntilReachedEndPoint
			root.CFrame = cFrame * CFrame.new(0, 0, distTravelledForward * (1 - v2 ^ 0.5))
			clone2.CFrame = root.CFrame
			RunService.PreSimulation:Wait()
		end

		root.Anchored = false
		root.CFrame = cFrame
		clone2.CFrame = root.CFrame

		for _, emitter in pairs(clone2:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter.Enabled = false
			end
		end

		clone2.Weld.Enabled = false
		clone2.Anchored = true
	elseif stage == 2 then
		local folder = Instance.new("Folder")
		Util.SetParentOverrideWithColor(folder, _WorldOrigin, player, "BombFruitVFXColor")
		Util.Debris:AddItem(folder, 5)
		local proxy = data.Proxy

		if not proxy then
			return
		end

		local victimChar = data.VictimChar

		if victimChar then
			local _ = victimChar.Head
			local cFrame = data.HitCF * CFrame.new(0, 0, -3)
			local clone = X.Phase3.Aura:Clone()
			clone.CFrame = cFrame * CFrame.new(0, 2, 0)
			Util.SetParentOverrideWithColor(clone, folder, player, "BombFruitVFXColor")

			for _, emitter in pairs(clone:GetDescendants()) do
				if not emitter:IsA("ParticleEmitter") then
					continue
				end

				emitter.Enabled = true
				emitter:Emit(3)
			end

			local v2 = tick() + 0.15
			local now = tick()
			local v3 = tick() + 0

			while true do
				if v3 - tick() > 0 and now - tick() <= 0 then
					now = tick() + 0.01
					task.spawn(function()
						local clone2 = X.Phase3.Trail:Clone()
						clone2.CFrame = cFrame
						Util.SetParentOverrideWithColor(clone2, folder, player, "BombFruitVFXColor")
						clone2.CFrame = clone2.CFrame * CFrame.Angles(
							math.rad((math.random(-180, 180))),
							math.rad((math.random(-180, 180))),
							(math.rad((math.random(-180, 180))))
						) * CFrame.new(0, 0, math.random(20, 35))

						for _, effect in pairs(clone2:GetDescendants()) do
							if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
								effect.Enabled = true
							end
						end

						TrailCurve(
							clone2,
							cFrame,
							clone2.Position,
							cFrame * CFrame.new(0, 2, 0).Position,
							CFrame.new(math.random(-50, 50) / 8, math.random(-50, 50) / 8, math.random(-50, 50) / 8),
							CFrame.new(math.random(-50, 50) / 8, math.random(-50, 50) / 8, math.random(-50, 50) / 8),
							math.random(25, 30) / 10,
							true
						)

						for _, effect in pairs(clone2:GetDescendants()) do
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

				for _, emitter in pairs(clone:GetDescendants()) do
					if emitter:IsA("ParticleEmitter") then
						emitter.Enabled = false
					end
				end

				task.wait(0.1)
				local clone2 = X.Phase3.ShockImpact:Clone()
				clone2.CFrame = cFrame * CFrame.Angles(0, 3.141592653589793, 0)
				Util.SetParentOverrideWithColor(clone2, folder, player, "BombFruitVFXColor")
				DeleteImpactAfterDuration(clone2) -- equivalent call inferred; original call site unknown
				Util.Sound:Play("BF_NewFruit_X_Explosion_02", clone2.Position)

				for _, emitter in pairs(clone2:GetDescendants()) do
					if not emitter:IsA("ParticleEmitter") then
						continue
					end

					local v4 = emitter
					task.spawn(function()
						if v4:GetAttribute("EmitDelay") ~= 0 then
							task.wait(v4:GetAttribute("EmitDelay"))
						end

						v4:Emit(v4:GetAttribute("EmitCount"))
					end)
				end

				victimChar:PivotTo(cFrame * CFrame.new(0, 0, 25))
				local clone3 = X.Phase3.Bomb:Clone()
				clone3:PivotTo(victimChar.Head.CFrame * CFrame.Angles(1.5707963267948966, 0, -1.5707963267948966))
				Util.SetParentOverrideWithColor(clone3, folder, player, "BombFruitVFXColor")
				local numberValue = Instance.new("NumberValue")
				numberValue.Parent = folder
				numberValue.Value = 1
				task.spawn(function()
					local heartbeatConnection = nil
					heartbeatConnection = RunService.Heartbeat:Connect(function(dt)
						if not (clone3 and clone3:IsDescendantOf(workspace)) then
							heartbeatConnection:Disconnect()
							return
						end

						if not (victimChar and victimChar:IsDescendantOf(workspace)) then
							heartbeatConnection:Disconnect()
							return
						end

						if clone3:GetScale() ~= numberValue.Value then
							clone3:ScaleTo(numberValue.Value)
						end

						clone3:PivotTo(victimChar.Head.CFrame * CFrame.Angles(
							1.5707963267948966,
							0,
							-1.5707963267948966
						))
					end)
				end)
				local highlight = Instance.new("Highlight")
				highlight.FillColor = Util.WrapColor3Constructor(Color3.fromRGB(255, 0, 0), player, "BombFruitVFXColor")
				highlight.FillTransparency = 1
				highlight.OutlineColor = Util.WrapColor3Constructor(
					Color3.fromRGB(255, 156, 106),
					player,
					"BombFruitVFXColor"
				)
				highlight.OutlineTransparency = 0
				highlight.DepthMode = Enum.HighlightDepthMode.Occluded
				Util.SetParentOverrideWithColor(highlight, clone3, player, "BombFruitVFXColor")
				local v6 = Util.Sound:Play("BF_NewFruit_X_FuseTick_01", clone3.PrimaryPart)
				local bombDur = data.BombDur
				-- equivalent calls inferred from this helper; original call sites unknown
				local v7 = clone3

				local function blink(p)
					if v7 and highlight then
						pcall(function()
							local tweenInfo = TweenInfo.new(
								p / 2,
								Enum.EasingStyle.Exponential,
								Enum.EasingDirection.Out
							)
							local tween = TweenService:Create(highlight, tweenInfo, {
								FillTransparency = 0
							})
							local tween2 = TweenService:Create(highlight, tweenInfo, {
								FillTransparency = 1
							})
							tween:Play()
							tween.Completed:Wait()
							tween2:Play()
							tween2.Completed:Wait()
						end)
					end
				end

				local v10 = clone3
				local v11 = highlight
				local v12 = numberValue
				local thread = task.spawn(function()
					blink(bombDur / 2.14) -- equivalent call inferred; original call site unknown
					blink(bombDur / 3.75) -- equivalent call inferred; original call site unknown
					blink(bombDur / 10) -- equivalent call inferred; original call site unknown
					blink(bombDur / 15) -- equivalent call inferred; original call site unknown
					blink(bombDur / 30) -- equivalent call inferred; original call site unknown
					TweenService:Create(v12, TweenInfo.new(0.1, Enum.EasingStyle.Back, Enum.EasingDirection.InOut), {
						Value = 3
					}):Play()

					if v10 and v11 then
						local v19 = 0.1
						pcall(function()
							local tweenInfo = TweenInfo.new(
								v19 / 2,
								Enum.EasingStyle.Exponential,
								Enum.EasingDirection.Out
							)
							local tween = TweenService:Create(v11, tweenInfo, {
								FillTransparency = 0
							})
							local tween2 = TweenService:Create(v11, tweenInfo, {
								FillTransparency = 1
							})
							tween:Play()
							tween.Completed:Wait()
							tween2:Play()
							tween2.Completed:Wait()
						end)
					end

					if v6 then
						Util.Sound:FadeOut(v6, 0.2)
					end

					v10:Destroy()
				end)
				local thread2 = task.delay(bombDur - 0.05, function()
					pcall(function()
						local clone4 = X.Phase3.Star1:Clone()
						clone4.CFrame = victimChar.PrimaryPart.CFrame * CFrame.new(0, 2.5, 0)
						Util.SetParentOverrideWithColor(clone4, folder, player, "BombFruitVFXColor")

						for _, emitter in pairs(clone4:GetDescendants()) do
							if emitter:IsA("ParticleEmitter") then
								emitter:Emit(emitter:GetAttribute("EmitCount"))
							end
						end
					end)
				end)

				repeat
					task.wait()
				until not proxy or proxy:GetAttribute("Exploding")

				if thread then
					task.cancel(thread)
				end

				if thread2 then
					task.cancel(thread2)
				end

				local v14 = clone3
				pcall(function()
					if v14 then
						v14:Destroy()
					end
				end)
				local clone4 = X.Phase4.Explosion:Clone()
				clone4.CFrame = victimChar and victimChar:FindFirstChild("HumanoidRootPart") and victimChar.PrimaryPart.CFrame or CFrame.new(proxy:GetAttribute("Exploding"))
				Util.SetParentOverrideWithColor(clone4, folder, player, "BombFruitVFXColor")

				if (workspace.CurrentCamera.CFrame.p - clone4.CFrame.Position).Magnitude < 125 then
					Util.CameraShaker:ShakeOnce(12, 8, 0.1, 0.3)
				end

				DeleteImpactAfterDuration(clone4) -- equivalent call inferred; original call site unknown
				Util.Sound:Play("BF_NewFruit_X_Explosion_03", clone4.Position)

				for _, emitter in pairs(clone4:GetDescendants()) do
					if not emitter:IsA("ParticleEmitter") then
						continue
					end

					local v15 = emitter
					task.spawn(function()
						if v15:GetAttribute("EmitDelay") ~= 0 then
							task.wait(v15:GetAttribute("EmitDelay"))
						end

						v15:Emit(v15:GetAttribute("EmitCount"))
					end)
				end

				break
			end
		end
	end
end