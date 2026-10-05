local createVector = vector.create
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")
local Net = require(ReplicatedStorage.packages.Net)
local localPlayer = Players.LocalPlayer
local remoteEvent = Net:RemoteEvent("Oakling/Snapshot")
local oaklings = ReplicatedStorage.resources.models.EverturnForest.Oaklings
local world = ReplicatedStorage:WaitForChild("world")
local season = world:WaitForChild("season")
local cycle = world:WaitForChild("cycle")
local oakling_Hit = ReplicatedStorage.resources.vfx.Oakling_Hit
local oakling_Change = ReplicatedStorage.resources.vfx.Oakling_Change
local v = {}
local v2 = "Summer"

-- equivalent calls inferred from this helper; original call sites unknown
local function isNightTime()
	return cycle.Value == "Night"
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getVariant()
	if isNightTime() then
		return "Night"
	end

	return season.Value or "Summer"
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getModelTemplate(variant: string)
	return oaklings:FindFirstChild((`Oakling_{variant}`))
end

local function setEyeGlow(model, flag: boolean)
	if flag then
		if not model:FindFirstChild("EvilGlow", true) then
			local pointLight = Instance.new("PointLight")
			pointLight.Name = "EvilGlow"
			pointLight.Color = Color3.new(255, 0, 0)
			pointLight.Brightness = 7
			pointLight.Range = 4
			pointLight.Parent = model.PrimaryPart
		end
	else
		local evilGlow = model:FindFirstChild("EvilGlow", true)

		if evilGlow then
			evilGlow:Destroy()
		end
	end
end

local function setupAnimations(state)
	local model = state.Model

	if not model then
		return
	end

	local humanoid = model:FindFirstChildWhichIsA("Humanoid")
	state.IdleTrack = nil
	state.WalkTrack = nil
	state.AttackTrack = nil
	state.CurrentAnim = nil

	if not humanoid then
		return
	end

	local animate = model:FindFirstChild("Animate")
	local idle = animate and animate:FindFirstChild("idle")
	local walk = animate and animate:FindFirstChild("walk")
	local attack = animate and animate:FindFirstChild("attack")

	local function getAnimFromFolder(animation)
		if not animation then
			return nil
		end

		if animation:IsA("Animation") then
			return animation
		end

		for _, animation2 in animation:GetChildren() do
			if animation2:IsA("Animation") then
				return animation2
			end

			local animation3 = animation2:FindFirstChildWhichIsA("Animation")

			if animation3 then
				return animation3
			end
		end

		return nil
	end

	local animFromFolder = getAnimFromFolder(idle)
	local animFromFolder2 = getAnimFromFolder(walk)
	local animFromFolder3 = getAnimFromFolder(attack)

	if animFromFolder then
		state.IdleTrack = humanoid:LoadAnimation(animFromFolder)
		state.IdleTrack.Looped = true
	end

	if animFromFolder2 then
		state.WalkTrack = humanoid:LoadAnimation(animFromFolder2)
		state.WalkTrack.Looped = true
	end

	if animFromFolder3 then
		state.AttackTrack = humanoid:LoadAnimation(animFromFolder3)
		state.AttackTrack.Looped = true
	end

	if state.IdleTrack then
		state.IdleTrack:Play(0)
		state.CurrentAnim = state.IdleTrack
	end
end

local function swapModel(state, variant: string)
	local modelTemplate = getModelTemplate(variant) -- equivalent call inferred; original call site unknown

	if not modelTemplate then
		return
	end

	if state.CurrentAnim then
		state.CurrentAnim:Stop(0)
	end

	if state.Model then
		state.Model:Destroy()
	end

	local clone = modelTemplate:Clone()
	clone.Name = `Oakling_{state.Index}`
	local humanoidRootPart = clone:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart then
		humanoidRootPart.Anchored = true
		humanoidRootPart.CanCollide = false
		humanoidRootPart.CanQuery = false
		humanoidRootPart.CanTouch = false
		humanoidRootPart.CollisionGroup = "Active"
		clone.PrimaryPart = humanoidRootPart
	end

	for _, part in clone:GetDescendants() do
		if not (part:IsA("BasePart") and part ~= humanoidRootPart) then
			continue
		end

		part.Anchored = false
		part.CanCollide = false
		part.CollisionGroup = "Active"
	end

	clone:PivotTo(CFrame.new(state.CurrentPos))
	clone.Parent = state.ParentFolder
	state.Model = clone
	state.RootPart = humanoidRootPart
	state.Variant = variant
	local clone2 = oakling_Change:Clone()
	clone2.Anchored = true
	clone2.CanCollide = false
	clone2.CanQuery = false
	clone2.CanTouch = false
	clone2.CFrame = CFrame.new(state.CurrentPos)
	clone2.Parent = workspace

	for _, emitter in clone2:GetDescendants() do
		if emitter:IsA("ParticleEmitter") then
			emitter:Emit(emitter:GetAttribute("EmitCount"))
		end
	end

	Debris:AddItem(clone2, 3)
	setupAnimations(state)

	if state.IsEvil and not clone:FindFirstChild("EvilGlow", true) then
		local pointLight = Instance.new("PointLight")
		pointLight.Name = "EvilGlow"
		pointLight.Color = Color3.new(255, 0, 0)
		pointLight.Brightness = 7
		pointLight.Range = 4
		pointLight.Parent = clone.PrimaryPart
	end
end

local function createVisual(i: number, oaklings2)
	return {
		Index = i,
		Model = nil,
		RootPart = nil,
		ParentFolder = oaklings2,
		Variant = nil,
		TargetPos = createVector(0, 0, 0),
		TargetAngle = 0,
		CurrentPos = createVector(0, 0, 0),
		CurrentAngle = 0,
		Initialized = false,
		PrevSnapshotPos = createVector(0, 0, 0),
		ServerVelocity = createVector(0, 0, 0),
		PrevPos = createVector(0, 0, 0),
		StateId = 0,
		IsEvil = false,
		IsDying = false,
		IsDead = false,
		CurrentAnim = nil,
		IdleTrack = nil,
		WalkTrack = nil,
		AttackTrack = nil
	}
end

return {
	Start = function(_)
		local oaklings2 = workspace:WaitForChild("Oaklings", 30)

		if not oaklings2 then
			return
		end

		v2 = getVariant()

		local function checkVariantSwap()
			local variant = getVariant() -- equivalent call inferred; original call site unknown

			if variant == v2 then
				return
			end

			v2 = variant

			for _, v3 in v do
				swapModel(v3, v2)
			end
		end

		season.Changed:Connect(checkVariantSwap)
		cycle.Changed:Connect(checkVariantSwap)
		remoteEvent.OnClientEvent:Connect(function(buf: buffer)
			for i = 1, buffer.len(buf) / 18 do
				local v3 = (i - 1) * 18
				local v4 = v[i]

				if not v4 then
					v4 = createVisual(i, oaklings2)
					v[i] = v4
				end

				local vector2 = Vector3.new(
					buffer.readf32(buf, v3),
					buffer.readf32(buf, v3 + 4),
					(buffer.readf32(buf, v3 + 8))
				)
				local v5 = buffer.readf32(buf, v3 + 12)
				local stateId = buffer.readu8(buf, v3 + 16)
				local isEvil = buffer.readu8(buf, v3 + 17) == 1

				if not v4.Initialized then
					v4.CurrentPos = vector2
					v4.CurrentAngle = v5
					v4.PrevSnapshotPos = vector2
					v4.PrevPos = vector2
					v4.ServerVelocity = createVector(0, 0, 0)
					v4.Initialized = true
					swapModel(v4, v2)
				end

				if (vector2 - v4.CurrentPos).Magnitude > 15 then
					v4.CurrentPos = vector2
					v4.PrevPos = vector2
					v4.PrevSnapshotPos = vector2
					v4.ServerVelocity = createVector(0, 0, 0)
				end

				v4.ServerVelocity = (vector2 - v4.PrevSnapshotPos) / 0.05
				v4.PrevSnapshotPos = vector2
				v4.TargetPos = vector2
				v4.TargetAngle = v5
				v4.StateId = stateId

				if stateId == 3 and not v4.IsDying then
					v4.IsDying = true

					if v4.Model then
						local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)

						for _, descendant in v4.Model:GetDescendants() do
							if descendant:IsA("BasePart") then
								TweenService:Create(descendant, tweenInfo, {
									Transparency = 1
								}):Play()
							elseif descendant:IsA("Decal") or descendant:IsA("Texture") then
								TweenService:Create(descendant, tweenInfo, {
									Transparency = 1
								}):Play()
							end
						end

						local character = localPlayer.Character

						if character and (character:GetPivot().Position - v4.Model:GetPivot().Position).Magnitude < 10 then
							local highlight = Instance.new("Highlight")
							highlight.FillColor = Color3.new(1, 1, 1)
							highlight.OutlineColor = Color3.new(1, 1, 1)
							highlight.FillTransparency = 0.2
							highlight.OutlineTransparency = 0.2
							highlight.Parent = character
							TweenService:Create(highlight, TweenInfo.new(0.3, Enum.EasingStyle.Quint), {
								FillTransparency = 1,
								OutlineTransparency = 1
							}):Play()
							local clone = oakling_Hit:Clone()
							clone.Anchored = true
							clone.CanCollide = false
							clone.CanQuery = false
							clone.CanTouch = false
							clone.CFrame = CFrame.new(v4.CurrentPos)
							clone.Parent = workspace

							for _, emitter in clone:GetDescendants() do
								if emitter:IsA("ParticleEmitter") then
									emitter:Emit(emitter:GetAttribute("EmitCount"))
								end
							end

							Debris:AddItem(clone, 3)
							task.delay(0.3, function()
								highlight:Destroy()
							end)
						end

						task.delay(0.5, function()
							v4.IsDead = true
						end)
					end
				end

				if stateId ~= 3 and v4.IsDying then
					v4.IsDying = false
					v4.IsDead = false
					v4.CurrentPos = vector2
					v4.PrevPos = vector2
					v4.PrevSnapshotPos = vector2
					v4.ServerVelocity = createVector(0, 0, 0)
					swapModel(v4, v2)
				end

				if isEvil == v4.IsEvil then
					continue
				end

				v4.IsEvil = isEvil

				if v4.Model then
					setEyeGlow(v4.Model, isEvil)
				end
			end
		end)
		RunService.RenderStepped:Connect(function(dt)
			local v3 = math.max(dt, 0.001)

			for _, v4 in v do
				if not v4.Initialized or not v4.RootPart or not v4.RootPart.Parent or v4.IsDead then
					continue
				end

				local v5 = v4.TargetPos - v4.CurrentPos
				local magnitude = v5.Magnitude
				local magnitude2 = v4.ServerVelocity.Magnitude

				if not (magnitude < 0.01) then
					if magnitude2 < 0.01 then
						v4.CurrentPos = v4.CurrentPos:Lerp(v4.TargetPos, 1 - math.exp(-5 * dt))
					else
						local v6 = magnitude2 * dt

						if magnitude <= v6 then
							v4.CurrentPos = v4.TargetPos
						else
							v4.CurrentPos += v5 / magnitude * v6
						end
					end
				end

				local v6 = (v4.CurrentPos - v4.PrevPos).Magnitude / v3
				v4.PrevPos = v4.CurrentPos

				if v6 > 0.2 then
					local v7 = (v4.TargetAngle - v4.CurrentAngle) % 6.283185307179586

					if v7 > 3.141592653589793 then
						v7 -= 6.283185307179586
					end

					v4.CurrentAngle += v7 * math.min(1, 5 * dt)
				end

				local v7 = CFrame.new(v4.CurrentPos) * CFrame.Angles(0, v4.CurrentAngle + 0, 0) * CFrame.Angles(
					0,
					3.141592653589793,
					0
				) * CFrame.new(0, 0.5, 0)
				v4.Model:PivotTo(v7)
				local idleTrack = v4.IdleTrack

				if v4.StateId == 2 then
					idleTrack = v4.AttackTrack or v4.WalkTrack
				elseif v6 > 0.3 then
					idleTrack = v4.WalkTrack
				end

				if idleTrack and idleTrack ~= v4.CurrentAnim then
					if v4.CurrentAnim then
						v4.CurrentAnim:Stop(0.2)
					end

					idleTrack:Play(0.2)
					v4.CurrentAnim = idleTrack
				end

				if v4.WalkTrack and v4.CurrentAnim == v4.WalkTrack then
					v4.WalkTrack:AdjustSpeed((math.clamp(v6 / 3, 0.5, 2)))
				end
			end
		end)
	end
}