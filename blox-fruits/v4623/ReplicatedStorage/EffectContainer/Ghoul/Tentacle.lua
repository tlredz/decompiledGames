local createVector = vector.create
local RunService = game:GetService("RunService")
game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Util = require(game.ReplicatedStorage.Util)
local FX = require(game.ReplicatedStorage.FX)
local ghoulTentacle = FX:WaitForChild("Ghoul").Tentacle.GhoulTentacle
local _WorldOrigin = workspace._WorldOrigin
local animation = Instance.new("Animation")
animation.AnimationId = "rbxassetid://13804826944"
local animation2 = Instance.new("Animation")
animation2.AnimationId = "rbxassetid://13804828606"
local animation3 = Instance.new("Animation")
animation3.AnimationId = "rbxassetid://13804830102"
local animation4 = Instance.new("Animation")
animation4.AnimationId = "rbxassetid://13804831527"
local animation5 = Instance.new("Animation")
animation5.AnimationId = "rbxassetid://13804833394"
ghoulTentacle.Ghoul_tentacle.AnimationController:LoadAnimation(animation)
ghoulTentacle.Ghoul_tentacle.AnimationController:LoadAnimation(animation2)
ghoulTentacle.Ghoul_tentacle.AnimationController:LoadAnimation(animation3)
ghoulTentacle.Ghoul_tentacle.AnimationController:LoadAnimation(animation4)

local function GetNumberDependingDistance(p, p2, p3, p4, p5)
	if p <= p4 then
		return p2
	end

	if p4 < p and p <= p5 then
		return p2 + (p3 - p2) * ((p - p4) / (p5 - p4))
	end

	return p3
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

-- equivalent calls inferred from this helper; original call sites unknown
local function AddBurn(part, parent, p)
	task.spawn(function()
		local clone = ghoulTentacle.HitImpact:Clone()
		clone.CFrame = part.CFrame
		clone.Parent = parent
		Util.Debris:AddItem(clone, 2)

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

		local clone2 = ghoulTentacle.Burn:Clone()
		Util.Debris:AddItem(clone2, 3.5)
		clone2.CFrame = part.CFrame
		clone2.Weld.Part0 = part
		clone2.Parent = parent

		if p == true then
			clone2.Attachment2:Destroy()
		end

		for _ = 1, 5 do
			task.spawn(function()
				os.clock()
				local clone3 = ghoulTentacle.Trail:Clone()
				clone3.CFrame = part.CFrame
				clone3.Attachment.Position = createVector(0, 1, 0)
				clone3.Attachment1.Position = createVector(0, -1, 0)
				clone3.Parent = parent

				for _, emitter in pairs(clone3:GetDescendants()) do
					if emitter:IsA("ParticleEmitter") then
						emitter:Destroy()
					end
				end

				local _ = clone3.Position
				clone3.Anchored = false
				local clone4 = ghoulTentacle.OrbitPart:Clone()
				clone4.Parent = clone3
				clone4.AlignPosition.Enabled = true
				local v = math.random(7, 10)
				local v2 = math.abs(v) * math.random(-1, 1)
				local v3 = math.abs(v) * math.random(-1, 1)

				if v2 == 0 and v3 == 0 then
					local v4 = math.random(1, 2)
					local v5 = math.random(1, 2)

					if v4 == 1 then
						if v5 == 1 then
							v2 = v
						else
							v2 = -v
						end
					elseif v5 == 1 then
						v3 = v
					else
						v3 = -v
					end
				end

				local numberValue = Instance.new("NumberValue")
				numberValue.Value = math.random(4, 7)
				clone4.CFrame *= CFrame.Angles(math.rad(v2), math.rad(v3), 0)
				clone4.AlignPosition.Position = clone4.CFrame * CFrame.new(0, 0, -numberValue.Value).Position
				clone4.Attachment0.Parent = clone3
				local lastTime = os.clock()

				repeat
					clone4.Position = part.Position
					clone4.CFrame *= CFrame.Angles(math.rad(v2), math.rad(v3), 0)
					clone4.AlignPosition.Position = clone4.CFrame * CFrame.new(0, 0, -numberValue.Value).Position
					RunService.Heartbeat:Wait()
				until os.clock() - lastTime >= 2

				for _, trail in pairs(clone3:GetDescendants()) do
					if trail:IsA("Trail") then
						trail.Enabled = false
					end
				end

				Util.Debris:AddItem(clone3, 1)
			end)
		end

		task.wait(2)

		for _, emitter in pairs(clone2:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter.Enabled = false
			end
		end
	end)
end

local function GrabTrails(magnitude, cFrame, parent)
	for _ = 1, 3 do
		task.spawn(function()
			task.wait(0.25)
			local clone = ghoulTentacle.Trail:Clone()
			clone.CFrame = cFrame * CFrame.new(
				math.random(-10, 10) / 10,
				math.random(-10, 10) / 10,
				math.random(-10, 10) / 10
			)
			clone.Parent = parent

			for _, emitter in pairs(clone:GetDescendants()) do
				if emitter:IsA("ParticleEmitter") then
					emitter.Enabled = true
				end
			end

			local position = clone.Position
			local v = cFrame * CFrame.new(math.random(-10, 10) / 10, math.random(-10, 10) / 10, -magnitude).Position
			local magnitude2 = (position - v).Magnitude
			clone.CFrame = CFrame.new(position, v)
			local v2 = (position - v) / 2
			local position2 = CFrame.new(CFrame.new(position) * (v2 / -1.5)).Position
			local position3 = CFrame.new(CFrame.new(v) * (v2 / 1.5)).Position
			local v3 = position2 + Vector3.new(math.random(-35, 35), math.random(-35, 35), math.random(-35, 35))
			local v4 = position3 + Vector3.new(math.random(-35, 35), math.random(-35, 35), math.random(-35, 35))
			local lastTime = tick()
			local v5 = magnitude2 / 7 / 60

			while tick() - lastTime < v5 do
				local v6 = (tick() - lastTime) / v5
				local v7 = cubicBezier(v6, position, v3, v4, v)
				clone.CFrame = clone.CFrame:Lerp(CFrame.new(v7, v), v6)
				RunService.Heartbeat:Wait()
			end

			for _, emitter in pairs(clone:GetDescendants()) do
				if emitter:IsA("ParticleEmitter") then
					emitter.Enabled = false
				end
			end

			Util.Debris:AddItem(clone, 1)
		end)
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function TentacleGrab(cFrame, root, folder, object, p)
	task.spawn(function()
		local clone = ghoulTentacle.Ghoul_tentacle:Clone()

		if p < 119 then
			Util.ResizeModel(clone, p / 120)
		end

		clone.RootPart.CFrame = cFrame
		local weld = clone.RootPart.Weld
		weld.Part0 = root.Parent.RightHand
		clone.Parent = folder
		local v, v2, v3

		if object then
			v = math.rad((object:NextNumber(-12, 12)))
			v2 = math.rad((object:NextNumber(-0, 7)))
			v3 = math.rad((object:NextNumber(-90, 90)))
		else
			v = 0
			v2 = 0
			v3 = 0
		end

		weld.C0 = weld.Part0.CFrame:ToObjectSpace(weld.Part1.CFrame) * CFrame.Angles(v, v2, v3)
		local v4 = object and object:NextInteger(1, 2) or math.random(1, 2)
		local track

		if v4 == 1 then
			track = clone.AnimationController:LoadAnimation(animation)
		else
			track = clone.AnimationController:LoadAnimation(animation2)
		end

		track:Play()
		track:AdjustSpeed(0.25)

		for _, descendant in pairs(clone:GetDescendants()) do
			if descendant:IsA("ParticleEmitter") then
				descendant.Enabled = false
			elseif descendant:IsA("MeshPart") then
				local transparency = descendant.Transparency
				descendant.Transparency = 1
				local v5 = descendant
				task.delay(0.1, function()
					v5.Transparency = transparency
				end)
			end
		end

		task.spawn(function()
			task.wait(0.15)
			track:AdjustSpeed(1)
			task.wait(0.5)
			track:AdjustSpeed(0)
		end)
		local v5 = cFrame * CFrame.Angles(v2, v, v3) * CFrame.new(0, 0, -p).Position
		GrabTrails((cFrame.Position - v5).Magnitude, cFrame, folder)
		task.spawn(function()
			task.wait(0.75)
			track:Stop()
			clone["Cube.013"].Material = Enum.Material.Basalt
			local track2

			if v4 == 1 then
				track2 = clone.AnimationController:LoadAnimation(animation3)
			else
				track2 = clone.AnimationController:LoadAnimation(animation4)
			end

			track2:Play()
			track2:AdjustSpeed(2.5)

			for _, part in pairs(clone:GetDescendants()) do
				if not part:IsA("MeshPart") then
					continue
				end

				local v6 = part
				task.spawn(function()
					local tween = TweenService:Create(
						v6,
						TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, false),
						{
							Color = Color3.fromRGB(35, 6, 7)
						}
					)
					tween:Play()
					tween.Completed:Wait()
					TweenService:Create(
						v6,
						TweenInfo.new(0.135, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, false),
						{
							Transparency = 1
						}
					):Play()
				end)
			end
		end)
		task.wait(1)
	end)
end

local function PortalTentacleCurve(clone, instance)
	local position = clone.Position
	local position2 = instance.Position
	local magnitude = (position - position2).Magnitude
	clone.CFrame = CFrame.new(position, position2)
	local v = (position - position2) / 2
	local position3 = CFrame.new(CFrame.new(position) * (v / -1.5)).Position
	local position4 = CFrame.new(CFrame.new(position2) * (v / 1.5)).Position
	local v2 = position3 + Vector3.new(math.random(-20, 20), math.random(-20, 20), math.random(-20, 20))
	local v3 = position4 + Vector3.new(math.random(-20, 20), math.random(-20, 20), math.random(-20, 20))
	local v4 = magnitude / 15
	local lastTime = tick()
	local v5 = magnitude / v4 / 60

	while tick() - lastTime < v5 do
		local v6 = (tick() - lastTime) / v5
		local v7 = cubicBezier(v6, position, v2, v3, position2)
		clone.CFrame = clone.CFrame:Lerp(CFrame.new(v7, position2), v6)
		position2 = instance.Position
		RunService.Heartbeat:Wait()
	end
end

local function PortalTentacles(humanoidRootPart, folder)
	local v = humanoidRootPart.Position + Vector3.new(math.random(-35, 35), math.random(-5, 35), math.random(-35, 35))
	local cframe = CFrame.new(v, humanoidRootPart.Position)
	local clone = ghoulTentacle.TentaclePortal:Clone()
	clone.CFrame = humanoidRootPart.CFrame
	clone.Parent = folder
	local descendants = clone:GetDescendants()

	for _, emitter in pairs(descendants) do
		if emitter:IsA("ParticleEmitter") then
			emitter.Enabled = true
		end
	end

	Util.Sound:Play("DevourerOfWorldsOrbSpawn", humanoidRootPart.CFrame, 25, 2.75, 0.1)
	local tween = TweenService:Create(clone, TweenInfo.new(0.35, Enum.EasingStyle.Quart, Enum.EasingDirection.InOut), {
		CFrame = cframe
	})
	tween:Play()
	tween.Completed:Wait()
	task.wait(0.6833333333333332)
	Util.Sound:Play("DevourerOfWorldsOrbSpawn", cframe.Position, 25, 2.25, 0.175)
	local clone2 = ghoulTentacle.MainTrail:Clone()
	clone2.CFrame = cframe
	clone2.Parent = folder
	clone2.Ghoul_tentacle.AnimationController:LoadAnimation(animation5):Play()
	local descendants2 = clone2:GetDescendants()

	for _, instance in pairs(descendants2) do
		if instance:IsA("ParticleEmitter") then
			instance.Enabled = true
		elseif instance:IsA("MeshPart") then
			local transparency = instance.Transparency
			instance.Transparency = 1
			local v2 = instance
			task.spawn(function()
				task.wait(0.05)
				v2.Transparency = transparency
			end)
		end
	end

	PortalTentacleCurve(clone2, humanoidRootPart)
	Util.Sound:Play("DevourerOfWorldsOrbDespawn", cframe.Position, 25, 1.5, 0.175)

	for _, emitter in pairs(descendants) do
		if emitter:IsA("ParticleEmitter") then
			emitter.Enabled = false
		end
	end

	for _, instance in pairs(descendants2) do
		if instance:IsA("ParticleEmitter") then
			instance.Enabled = false
		elseif instance:IsA("MeshPart") then
			instance.Transparency = 1
		end
	end

	Util.Debris:AddItem(clone2, 1)
	local clone3 = ghoulTentacle.TentaclePortalImpact:Clone()
	clone3.CFrame = clone.CFrame
	clone3.Parent = folder

	for _, emitter in pairs(clone3:GetDescendants()) do
		if emitter:IsA("ParticleEmitter") then
			emitter:Emit(emitter:GetAttribute("EmitCount"))
		end
	end

	local clone4 = ghoulTentacle.SmallTentacleImpact:Clone()
	clone4.CFrame = humanoidRootPart.CFrame
	clone4.Parent = folder

	for _, emitter in pairs(clone4:GetDescendants()) do
		if emitter:IsA("ParticleEmitter") then
			emitter:Emit(emitter:GetAttribute("EmitCount"))
		end
	end
end

local function BigTentacleCurve(clone, p)
	local position = clone.Position
	local position2 = p.Position
	local _ = (position - position2).Magnitude
	clone.CFrame = CFrame.new(position, position2)
	local v = (position - position2) / 2
	local position3 = CFrame.new(CFrame.new(position) * (v / -1.5)).Position
	local position4 = CFrame.new(CFrame.new(position2) * (v / 1.5)).Position
	local v2 = math.random(40, 60)
	local v3 = position3 + Vector3.new(math.random(-v2, v2), math.random(0, v2), math.random(-v2, v2))
	local v4 = position4 + Vector3.new(math.random(-v2, v2), math.random(0, v2), math.random(-v2, v2))
	local v5 = 0.6 + math.random() * 0.4
	local lastTime = tick()

	while tick() - lastTime < v5 do
		local v6 = (tick() - lastTime) / v5
		local v7 = cubicBezier(v6, position, v3, v4, position2)
		clone.CFrame = clone.CFrame:Lerp(CFrame.new(v7, position2), v6)
		position2 = p.Position
		RunService.Heartbeat:Wait()
	end
end

local function Curve(clone, p, p2, p3, _)
	local position = clone.Position
	local v = p3 == true and 2000 or 2
	local v2 = p2 * CFrame.new(math.random(-15, 15) / v, math.random(-15, 15) / v, -p).Position
	local magnitude = (position - v2).Magnitude
	clone.CFrame = CFrame.new(position, v2)
	local v3 = (position - v2) / 2
	local position2 = CFrame.new(CFrame.new(position) * (v3 / -1.5)).Position
	local position3 = CFrame.new(CFrame.new(v2) * (v3 / 1.5)).Position
	local v4 = position2 + Vector3.new(math.random(-20, 20), math.random(-20, 20), math.random(-20, 20))
	local v5 = position3 + Vector3.new(math.random(-20, 20), math.random(-20, 20), math.random(-20, 20))
	local lastTime = tick()
	local v6 = magnitude / 8 / 60

	while tick() - lastTime < v6 do
		local v7 = (tick() - lastTime) / v6
		local v8 = cubicBezier(v7, position, v4, v5, v2)
		clone.CFrame = clone.CFrame:Lerp(CFrame.new(v8, v2), v7)
		RunService.Heartbeat:Wait()
	end
end

local function TrailsCurve(p, parent, p2, p3)
	local clone = ghoulTentacle.TrailBig:Clone()
	clone.CFrame = p * CFrame.new(math.random(-15, 15) / 10, math.random(-15, 15) / 10, math.random(-15, 15) / 10)
	clone.Parent = parent

	if p3 == true then
		clone.Attachment.Position = createVector(0, 2.5, 0)
		clone.Attachment1.Position = createVector(0, -2.5, 0)
	end

	for _, emitter in pairs(clone:GetDescendants()) do
		if emitter:IsA("ParticleEmitter") then
			emitter.Enabled = true
		end
	end

	for i = 1, 5 do
		if p2 >= 60 and i ~= 5 then
			local v2 = 60
			Curve(clone, v2, p, false, nil)
			p *= CFrame.new(0, 0, -v2)
			p2 -= 60
			continue
		end

		Curve(clone, p2, p, true, nil)
		p *= CFrame.new(0, 0, -p2)
		break
	end

	for _, emitter in pairs(clone:GetDescendants()) do
		if emitter:IsA("ParticleEmitter") then
			emitter.Enabled = false
		end
	end

	Util.Debris:AddItem(clone, 1)
end

local function MainTrail(cFrame, parent, p)
	local clone = ghoulTentacle.MainTrailBig:Clone()
	clone.CFrame = cFrame
	clone.Parent = parent
	clone.Ghoul_tentacle.AnimationController:LoadAnimation(animation5):Play()

	for _, descendant in pairs(clone:GetDescendants()) do
		if descendant:IsA("ParticleEmitter") then
			descendant.Enabled = true
		elseif descendant:IsA("MeshPart") then
			local transparency = descendant.Transparency
			descendant.Transparency = 1
			local v = descendant
			task.spawn(function()
				task.wait(0.05)
				v.Transparency = transparency
			end)
		end
	end

	Util.Sound:Play("DevourerOfWorldsOrbSpawn", cFrame.Position)
	BigTentacleCurve(clone, p)
	Util.Sound:Play("DevourerOfWorldsOrbDespawn", p.Position)

	for _, descendant in pairs(clone:GetDescendants()) do
		if descendant:IsA("ParticleEmitter") then
			descendant.Enabled = false
		elseif descendant:IsA("MeshPart") then
			descendant.Transparency = 1
		end
	end

	Util.Debris:AddItem(clone, 1)
end

local function ProjectileTrails(cFrame, parent, _, p3)
	MainTrail(cFrame, parent, p3)
end

local function ChainEnemy(endPosition, hitTable)
	local folder = Instance.new("Folder", _WorldOrigin)
	Util.Debris:AddItem(folder, 5)

	for _, item in pairs(hitTable) do
		local v = item
		task.spawn(function()
			local humanoidRootPart = v:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local magnitude = (endPosition - humanoidRootPart.Position).Magnitude
			local cframe = CFrame.new(endPosition, humanoidRootPart.Position)
			math.ceil(magnitude)
			MainTrail(cframe, folder, humanoidRootPart)
			AddBurn(humanoidRootPart, folder, true) -- equivalent call inferred; original call site unknown
		end)
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function GetFeetCFrame(destination: CFrame, parent, value: number?)
	local humanoid = parent:FindFirstChildOfClass("Humanoid")
	local humanoidRootPart = parent:FindFirstChild("HumanoidRootPart")

	if humanoid and humanoidRootPart then
		local v = humanoid.HipHeight + humanoidRootPart.Size.Y * 0.5
		return destination * CFrame.new(0, -(v + (value or 0.05)), 0)
	else
		return nil
	end
end

return function(data)
	local DISTANCE_THRESHOLD = 1500
	local root = data.Root

	if not root then
		return
	end

	local parent = root.Parent

	if data.Holding then
		if data.ShowWarning then
			local part = Instance.new("Part", workspace._WorldOrigin)
			local feetCFrame = GetFeetCFrame(data.Destination, parent) -- equivalent call inferred; original call site unknown
			part.CFrame = CFrame.new(feetCFrame.Position) * CFrame.Angles(0, 0, 1.5707963267948966)
			part.Shape = Enum.PartType.Cylinder
			part.Anchored = true
			part.Size = createVector(1, 1, 1)
			part.Transparency = 1
			part.CanCollide = false
			part.CanTouch = false
			part.CanQuery = false
			part.Color = Color3.fromRGB(255, 0, 0)
			part.Material = Enum.Material.Neon
			local TweenService2 = game:GetService("TweenService")
			local tween = TweenService2:Create(
				part,
				TweenInfo.new(data.ChargeTime - (workspace:GetServerTimeNow() - data.Started), Enum.EasingStyle.Linear),
				{
					Size = Vector3.new(1, data.ShowWarning * 2, data.ShowWarning * 2),
					Transparency = 0
				}
			)
			tween.Completed:Once(function()
				local TweenService3 = game:GetService("TweenService")
				TweenService3:Create(part, TweenInfo.new(0.2), {
					Transparency = 1
				}):Play()
				Util.Debris:AddItem(part, 2)
			end)
			tween:Play()
		end

		if (root.Position - workspace.CurrentCamera.CFrame.Position).Magnitude > DISTANCE_THRESHOLD then
			return
		end

		local v = Util.Sound:Play("GenericDarkSkillCharge", root)
		local folder = Instance.new("Folder")
		folder.Parent = root.Parent
		local clone = ghoulTentacle.HoldHand:Clone()
		clone.CFrame = root.Parent.RightHand.CFrame
		clone.Parent = folder
		clone.Weld.Part0 = root.Parent.RightHand
		local clone2 = ghoulTentacle.TentacleAura:Clone()
		clone2.CFrame = root.Parent.UpperTorso.CFrame
		clone2.Parent = folder
		clone2.Weld.Part0 = root.Parent.UpperTorso
		local descendants = clone2:GetDescendants()

		for _, effect in pairs(descendants) do
			if effect:IsA("ParticleEmitter") or effect:IsA("Beam") then
				effect.Enabled = false
			end
		end

		for _, part in pairs(clone2:GetChildren()) do
			if not part:IsA("Part") then
				continue
			end

			local v2 = part.Name == "2" and 0.1 or part.Name == "3" and 0.2 or 0

			for _, effect in pairs(part:GetDescendants()) do
				if not (effect:IsA("ParticleEmitter") or effect:IsA("Beam")) then
					continue
				end

				local v3 = effect
				task.spawn(function()
					task.wait(v2)
					v3.Enabled = true
				end)
			end

			local tween = TweenService:Create(
				part,
				TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, false, v2),
				{
					Size = part.Size
				}
			)
			part.Size = Vector3.new(part.Size.X, part.Size.Y, 0)
			tween:Play()
		end

		repeat
			wait()
		until data.Holding.Value == false or not data.Holding:IsDescendantOf(workspace)

		Util.Sound:FadeOut(v, 0.25)
		task.wait(1)

		for _, effect in pairs(clone:GetDescendants()) do
			if effect:IsA("ParticleEmitter") then
				effect.Enabled = false
			elseif effect:IsA("Beam") then
				Util.BoatTween:Create(effect, {
					Time = 0.4,
					EasingStyle = "Sine",
					EasingDirection = "In",
					StepType = "Heartbeat",
					Goal = {
						Transparency = NumberSequence.new({
							NumberSequenceKeypoint.new(0, 1),
							NumberSequenceKeypoint.new(1, 1)
						})
					}
				}):Play()
			end
		end

		for _, effect in pairs(descendants) do
			if effect:IsA("ParticleEmitter") then
				effect.Enabled = false
			elseif effect:IsA("Beam") then
				Util.BoatTween:Create(effect, {
					Time = 0.4,
					EasingStyle = "Sine",
					EasingDirection = "In",
					StepType = "Heartbeat",
					Goal = {
						Transparency = NumberSequence.new({
							NumberSequenceKeypoint.new(0, 1),
							NumberSequenceKeypoint.new(1, 1)
						})
					}
				}):Play()
			end
		end

		task.wait(1)
		folder:Destroy()
	elseif data.Vortex then
		local root2 = data.Root
		local endPosition = data.EndPosition
		local vortexRadius = data.VortexRadius or 70
		local vortexDuration = data.VortexDuration or 3.5

		if (endPosition - workspace.CurrentCamera.CFrame.Position).Magnitude > DISTANCE_THRESHOLD then
			return
		end

		local folder = Instance.new("Folder")
		folder.Parent = _WorldOrigin
		Util.Debris:AddItem(folder, vortexDuration + 2)
		TentacleGrab(
			CFrame.new(root2.Position, endPosition),
			root2,
			folder,
			nil,
			math.clamp((endPosition - root2.Position).Magnitude, 20, 120)
		) -- equivalent call inferred; original call site unknown
		task.spawn(function()
			task.wait(0.25)
			local clone = ghoulTentacle.Blackhole:Clone()
			clone.CFrame = CFrame.new(endPosition)
			clone.Parent = folder
			local v3 = math.clamp(vortexRadius / 50, 1, 2.2)

			for _, part in ipairs(clone:GetDescendants()) do
				if part:IsA("BasePart") then
					part.Size *= v3
				end
			end

			local v4 = {}

			for _, descendant in pairs(clone:GetDescendants()) do
				if descendant:IsA("ParticleEmitter") then
					if descendant.Name == "Orb" then
						descendant:Emit(2)
					else
						descendant.Enabled = true
					end
				elseif descendant:IsA("PointLight") then
					table.insert(v4, descendant)
					TweenService:Create(
						descendant,
						TweenInfo.new(
							0.08,
							Enum.EasingStyle.Quad,
							Enum.EasingDirection.Out,
							math.floor(vortexDuration / 0.16),
							true
						),
						{
							Range = v3 * 28,
							Brightness = 2.2
						}
					):Play()
				end
			end

			local v5 = Util.Sound:Play("DevourerOfWorldsAmbience", clone.Position)
			task.wait(vortexDuration)
			Util.Sound:FadeOut(v5, 0.1)
			Util.Sound:Play("SanguineArtCOrbExplode", clone.CFrame)
			local clone2 = ghoulTentacle.BlackholeImpact:Clone()
			clone2.CFrame = clone.CFrame
			clone2.Parent = folder

			for _, emitter in pairs(clone2:GetDescendants()) do
				if emitter:IsA("ParticleEmitter") then
					emitter:Emit(emitter:GetAttribute("EmitCount"))
				end
			end

			clone:Destroy()
		end)
	elseif data.Burn then
		if not data.Target or (data.Target.Position - workspace.CurrentCamera.CFrame.Position).Magnitude > 1100 then
			return
		end

		AddBurn(data.Target, _WorldOrigin, nil) -- equivalent call inferred; original call site unknown
	else
		local endPosition = data.EndPosition
		local v = math.clamp((endPosition - root.Position).Magnitude, 20, 120)

		if (endPosition - workspace.CurrentCamera.CFrame.Position).Magnitude > DISTANCE_THRESHOLD then
			return
		end

		if data.Chain then
			ChainEnemy(endPosition, data.HitTable)
			return
		end

		local timestamp = data.Timestamp or Util.MasterClock:GetTime()
		local time = Util.MasterClock:GetTime()
		local cframe = CFrame.new(root.Position, endPosition)
		root.Anchored = true
		root.CFrame = cframe
		local cFrame = cframe * CFrame.new(1, 0, -1.5)
		Util.Sound:Play("SanguineArtCFire", cFrame)
		local folder = Instance.new("Folder")
		folder.Parent = _WorldOrigin
		local random = Random.new(data.Seed)
		local hitTable = data.HitTable
		local flag = true

		for _, v3 in pairs(hitTable) do
			TentacleGrab(cFrame, root, folder, random, v) -- equivalent call inferred; original call site unknown
			local v5 = v3
			task.spawn(function()
				local humanoidRootPart = v5:FindFirstChild("HumanoidRootPart")

				if not humanoidRootPart then
					return
				end

				task.wait(2)

				if not humanoidRootPart:IsDescendantOf(workspace) then
					return
				end

				local enemyHumanoid = v5:FindFirstChild("EnemyHumanoid")

				if enemyHumanoid and enemyHumanoid.Health <= 0 then
					return
				end

				for i = 1, 5 do
					task.wait(0.1)
					task.spawn(function()
						PortalTentacles(humanoidRootPart, folder)
					end)
				end
			end)
			flag = false
		end

		if flag then
			TentacleGrab(cFrame, root, folder, nil, v) -- equivalent call inferred; original call site unknown
			task.spawn(function()
				task.wait(0.3)
				local clone = ghoulTentacle.Blackhole:Clone()
				clone.CFrame = CFrame.new(endPosition)
				clone.Parent = folder

				for _, descendant in pairs(clone:GetDescendants()) do
					if descendant:IsA("ParticleEmitter") then
						if descendant.Name == "Orb" then
							descendant:Emit(1)
						else
							descendant.Enabled = true
						end
					elseif descendant:IsA("PointLight") then
						TweenService:Create(
							descendant,
							TweenInfo.new(0.05, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 20, true),
							{
								Range = 25,
								Brightness = 2.5
							}
						):Play()
					end
				end

				task.wait(0.15)
				local v5 = Util.Sound:Play("DevourerOfWorldsAmbience", clone.Position)
				task.wait(2)
				Util.Sound:FadeOut(v5, 0.1)
				Util.Sound:Play("SanguineArtCOrbExplode", clone.CFrame)
				local clone2 = ghoulTentacle.BlackholeImpact:Clone()
				clone2.CFrame = clone.CFrame
				clone2.Parent = folder
				clone:Destroy()

				for _, emitter in pairs(clone2:GetDescendants()) do
					if emitter:IsA("ParticleEmitter") then
						emitter:Emit(emitter:GetAttribute("EmitCount"))
					end
				end
			end)
		else
			task.delay(0.2, function()
				Util.Sound:Play("DevourerOfWorldsTentacleHit", cFrame * CFrame.new(0, 0, -v))
			end)
		end

		task.spawn(function()
			task.wait(0.3)
			local clone = ghoulTentacle.GrabImpact:Clone()
			clone.CFrame = cFrame * CFrame.new(0, 0, -v)
			clone.Parent = folder
			Util.Debris:AddItem(clone, 2)

			for _, emitter in pairs(clone:GetDescendants()) do
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
		end)
		task.spawn(function()
			task.wait(0.19)
			local clone = ghoulTentacle.StartGrabImpact:Clone()
			clone.CFrame = cFrame
			clone.Parent = folder
			Util.Debris:AddItem(clone, 2)

			for _, emitter in pairs(clone:GetDescendants()) do
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
		end)
		local clone = ghoulTentacle.HoldHandGrab:Clone()
		clone.CFrame = root.Parent.RightHand.CFrame
		clone.Parent = folder
		clone.Weld.Part0 = root.Parent.RightHand
		local descendants = clone:GetDescendants()

		for _, emitter in pairs(descendants) do
			if emitter:IsA("ParticleEmitter") then
				emitter.Enabled = true
			end
		end

		task.spawn(function()
			task.wait(0.7)

			for _, emitter in pairs(descendants) do
				if emitter:IsA("ParticleEmitter") then
					emitter.Enabled = false
				end
			end

			local v3 = time - timestamp
			task.wait(0.3 - v3)
			root.Anchored = false
		end)
		Util.Debris:AddItem(folder, 5)
	end
end