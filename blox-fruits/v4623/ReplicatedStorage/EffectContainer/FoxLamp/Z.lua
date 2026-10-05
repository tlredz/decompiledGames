local createVector = vector.create
local localPlayer = game.Players.LocalPlayer
game:GetService("RunService")
game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Util = require(game.ReplicatedStorage.Util)
local FX = require(game.ReplicatedStorage.FX)
local lampSkill2 = FX:WaitForChild("FoxLamp").Z.LampSkill2
local _WorldOrigin = workspace._WorldOrigin

local function DeleteImpactAfterDuration(folder)
	local v = 0

	for _, emitter in pairs(folder:GetDescendants()) do
		if not emitter:IsA("ParticleEmitter") then
			continue
		end

		local max = emitter.Lifetime.Max
		v = math.max(v, max)
	end

	task.spawn(function()
		task.wait(v)
		folder:Destroy()
	end)
end

local function viewerIsClose(p, p2, callback)
	local character = localPlayer.Character

	if character ~= nil then
		local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

		if humanoidRootPart and (humanoidRootPart.Position - p).Magnitude <= p2 then
			callback()
		end
	end
end

local function AlignCFrame(data, p)
	local v = not (p and p.Magnitude > 0 and p) and createVector(0, 1, 0) or p
	local p2 = data.p
	local unit = data.LookVector:Cross(v).Unit
	local unit2 = (unit.Magnitude > 0.001 and unit or data.RightVector).Unit
	local unit3 = unit2:Cross(v).Unit
	return CFrame.fromMatrix(p2, unit2, v, unit3)
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

return function(state)
	local holding = state.Holding
	local root = state.Root

	if not state.FirePosition or (root.Position - workspace.CurrentCamera.CFrame.p).Magnitude > 1000 then
		return
	end

	local folder = Instance.new("Folder")
	folder.Parent = _WorldOrigin
	Util.Debris:AddItem(folder, 30)
	local cFrame = root.CFrame
	local boolValue = Instance.new("BoolValue")
	boolValue.Value = true
	task.spawn(function()
		while holding and holding:IsDescendantOf(workspace) and holding.Value do
			task.wait()
		end

		boolValue.Value = false
	end)
	local clone = lampSkill2.Phase1.OrbMain:Clone()
	clone.CFrame = cFrame
	clone.Parent = folder
	local weld = clone.Weld
	weld.Part0 = root
	local v = true
	local orbFolder = lampSkill2.Phase1.OrbFolder
	local count = #orbFolder:GetChildren()
	local _ = clone.CFrame
	local total = -40
	local cframe = CFrame.new(0, 10, 0)
	local cframe2 = CFrame.new(0, 5, 0)
	local v2 = false
	task.spawn(function()
		Util.Sound:Play("Z Attacks- Spawn Effect", clone.CFrame)

		for _ = 1, 9 do
			local clone2 = orbFolder["Orb" .. math.random(1, count)]:Clone()
			clone2.CFrame = clone.CFrame
			clone2.Parent = clone

			for _, effect in pairs(clone2:GetDescendants()) do
				if not (effect:IsA("ParticleEmitter") or effect:IsA("Trail")) then
					continue
				end

				if effect:GetAttribute("EMIT") then
					effect:Emit(effect:GetAttribute("EmitCount"))
				else
					local v4 = effect
					task.spawn(function()
						task.wait(0.1)
						v4.Enabled = true
					end)
				end
			end

			local v4 = CFrame.Angles(0, 0, (math.rad(total))) * cframe
			local weld2 = clone2.Weld
			weld2.Part0 = clone
			weld2.C0 = weld2.Part0.CFrame:ToObjectSpace(weld2.Part1.CFrame) * v4
			total += 40

			if v2 then
				continue
			end

			local lastTime = os.clock()

			while os.clock() - lastTime < 0.05 and not v2 do
				task.wait()
			end
		end

		for _, part in pairs(clone:GetChildren()) do
			if not part:IsA("BasePart") then
				continue
			end

			local weld2 = part.Weld
			local clone2 = lampSkill2.Phase1.Orb:Clone()
			clone2.CFrame = part.CFrame
			clone2.Parent = clone
			clone2.Weld.Part0 = part.Weld.Part0
			local C0 = weld2.C0 * cframe2
			clone2.Weld.C0 = weld2.C0

			for _, effect in pairs(clone2:GetDescendants()) do
				if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
					effect.Enabled = true
				end
			end

			part:Destroy()
			TweenService:Create(clone2.Weld, TweenInfo.new(0.1), {
				C0 = C0
			}):Play()

			if v2 then
				continue
			end

			local lastTime = os.clock()

			while os.clock() - lastTime < 0.15 and not v2 do
				task.wait()
			end
		end

		v = false
	end)
	local numberValue = Instance.new("NumberValue")
	numberValue.Value = 5
	numberValue.Parent = folder
	TweenService:Create(numberValue, TweenInfo.new(1), {
		Value = 50
	}):Play()
	local v3 = Util.Sound:Play("Z Attacks- Hovering flames", root)

	while true do
		local tween = TweenService:Create(weld, TweenInfo.new(0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {
			C0 = weld.Part0.CFrame:ToObjectSpace(weld.Part1.CFrame) * CFrame.Angles(0, 0, (math.rad(numberValue.Value)))
		})
		tween:Play()
		local lastTime = os.clock()

		while os.clock() - lastTime < 0.1 do
			if boolValue.Value == false then
				tween:Pause()
				break
			else
				task.wait()
			end
		end

		if boolValue.Value ~= false then
			continue
		end

		Util.Sound:FadeOut(v3, 0.1)
		v2 = true
		Util.Debris:AddItem(folder, 7)

		if state.FirePosition:IsA("ObjectValue") then
			while not state.FirePosition.Value do
				state.FirePosition.Changed:Wait()
			end

			state.FirePosition = state.FirePosition.Value
		end

		local range = state.Range
		local lifetime = state.Lifetime

		if state.FirePosition.Value.Magnitude < 0.1 then
			state.FirePosition.Changed:Wait()
		end

		local position2 = state.FirePosition.Value
		local cframe3 = CFrame.new(clone.Position, position2)
		Util.Sound:Play("C Attacks- Bullet fire", cframe3)
		local clone2 = lampSkill2.Phase1.StartImpact:Clone()
		clone2.CFrame = cframe3
		clone2.Parent = folder
		DeleteImpactAfterDuration(clone2)

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

		local magnitude = (cframe3.Position - position2).Magnitude
		local v4 = cframe3 * CFrame.new(0, 0, -magnitude)
		local v5 = magnitude / range * lifetime
		clone.Weld.Enabled = false
		clone.Anchored = true
		local magnitude2 = (cframe3.Position - v4.Position).Magnitude
		local victimRoot = state.FirePosition:FindFirstChild("VictimRoot")
		task.spawn(function()
			if not victimRoot then
				local lastTime2 = os.clock()

				while os.clock() - lastTime2 < state.Lifetime do
					victimRoot = state.FirePosition:FindFirstChild("VictimRoot")

					if victimRoot then
						break
					else
						task.wait()
					end
				end
			end
		end)

		for _ = 1, 4 do
			cframe3 = cframe3 * CFrame.new(0, 0, -magnitude2 / 4) * CFrame.Angles(0, 0, 0.8726646259971648)
			TweenService:Create(clone, TweenInfo.new(v5 / 4, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {
				CFrame = cframe3
			}):Play()
			local lastTime2 = os.clock()

			while os.clock() - lastTime2 < v5 / 4 and not victimRoot do
				task.wait()
			end

			if victimRoot then
				break
			end
		end

		if victimRoot then
			local value2 = state.FirePosition.VictimRoot.Value or {
				Position = position2
			}
			local clone3 = lampSkill2.Phase2.HitImpact:Clone()
			clone3.CFrame = CFrame.new(value2.Position)
			clone3.Parent = folder
			DeleteImpactAfterDuration(clone3)

			for _, emitter in pairs(clone3:GetDescendants()) do
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

			local children = clone:GetChildren()

			for _, part in pairs(children) do
				if not part:IsA("BasePart") then
					continue
				end

				local weld2 = part.Weld
				weld2.Enabled = false
				part.Massless = false
				part.Anchored = true
				TweenService:Create(part, TweenInfo.new(0.25), {
					CFrame = CFrame.new(value2.Position) * CFrame.Angles(
						math.rad((math.random(-90, 90))),
						math.rad((math.random(-90, 90))),
						0
					) * CFrame.new(0, 0, -50)
				})
				local v7 = part
				task.spawn(function()
					weld2.C0 = clone.CFrame:ToObjectSpace(v7.CFrame)
					weld2.C1 *= CFrame.new(0, 0, 50)
					v7:SetAttribute("CanMove", true)
				end)
			end

			local v6 = true
			task.spawn(function()
				repeat
					for k, part in pairs(children) do
						if not (part:IsA("BasePart") and part:GetAttribute("CanMove") == true) then
							continue
						end

						local weld2 = part.Weld
						weld2.Enabled = true
						part.Massless = true
						part.Anchored = false
						TweenService:Create(
							weld2,
							TweenInfo.new(0.25, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
							{
								C1 = weld2.C1 * CFrame.Angles(0.5235987755982988, 0.5235987755982988, 0)
							}
						):Play()
					end

					task.wait(0.25)
				until v6 == false
			end)
			task.wait(0.1)
			local clone4 = lampSkill2.Phase2.OrbHit:Clone()
			clone4.Parent = folder

			for _, part in pairs(children) do
				if not part:IsA("BasePart") then
					continue
				end

				local weld2 = part:FindFirstChild("Weld")

				if not weld2 then
					continue
				end

				Util.Sound:Play("X Attacks- Zig-zag bullet fired", part.Position)
				part:SetAttribute("CanMove", false)
				weld2.Enabled = false
				part.Massless = false
				part.Anchored = true
				weld2.Enabled = false
				local tween2 = TweenService:Create(part, TweenInfo.new(0.175), {
					CFrame = CFrame.new(part.Position, value2.Position) * CFrame.new(0, 0, -125)
				})
				tween2:Play()
				local v8 = part
				local folder2 = clone4
				local v9 = value2
				task.spawn(function()
					local position = v8.Position
					task.wait(0.04375)
					folder2.CFrame = CFrame.new(v9.Position, v9.Position + CFrame.new(position, v9.Position).LookVector)

					for i, emitter in pairs(folder2:GetDescendants()) do
						if not emitter:IsA("ParticleEmitter") then
							continue
						end

						local v10 = emitter
						task.spawn(function()
							if v10:GetAttribute("EmitDelay") ~= 0 then
								task.wait(v10:GetAttribute("EmitDelay"))
							end

							v10:Emit(v10:GetAttribute("EmitCount"))
						end)
					end
				end)
				tween2.Completed:Wait()
				part:SetAttribute("CanMove", true)
			end

			v6 = false

			for _, part in pairs(children) do
				if not part:IsA("BasePart") then
					continue
				end

				local weld2 = part:FindFirstChild("Weld")

				if not weld2 then
					continue
				end

				part:SetAttribute("CanMove", false)
				weld2.Enabled = false
				part.Massless = false
				part.Anchored = true
				local magnitude3 = (part.Position - value2.Position).Magnitude
				TweenService:Create(part, TweenInfo.new(0.15), {
					CFrame = CFrame.new(
						part.Position,
						part.Position + CFrame.new(part.Position, value2.Position).LookVector
					) * CFrame.new(0, 0, -magnitude3)
				}):Play()
			end

			local cframe4 = CFrame.new(value2.Position)
			Util.Sound:Play("KitsuneM1FinisherGround", cframe4)
			task.wait(0.15)
			Util.Sound:Play("X Attacks- Transformed explosion", cframe4)

			if (workspace.CurrentCamera.CFrame.p - cframe4.Position).Magnitude < 80 then
				Util.CameraShaker:ShakeOnce(12, 10, 0.2, 1)
			end

			local clone5 = lampSkill2.Phase2.Explosion:Clone()
			clone5.CFrame = cframe4
			clone5.Parent = folder
			DeleteImpactAfterDuration(clone5)

			for _, emitter in pairs(clone5:GetDescendants()) do
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
		end

		for _, effect in pairs(clone:GetDescendants()) do
			if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
				effect.Enabled = false
			end
		end

		break
	end
end