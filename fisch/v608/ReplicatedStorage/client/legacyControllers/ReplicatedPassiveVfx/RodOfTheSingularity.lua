local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local fx = require(ReplicatedStorage.shared.modules.fx)
require(ReplicatedStorage.packages.Trove)
local GeneralUtils = require(ReplicatedStorage.shared.utils.GeneralUtils)
local RodOfTheSingularity = {}
local _ = {
	Failed = 1,
	Success = 2
}
local v = {}
local v2 = {}
ReplicatedStorage:WaitForChild("resources"):WaitForChild("sounds"):WaitForChild("sfx"):WaitForChild("fishing")
local general = ReplicatedStorage:WaitForChild("resources"):WaitForChild("replicated"):WaitForChild("instances"):WaitForChild("general")
local VFX = script:WaitForChild("VFX")
local trail = VFX:WaitForChild("Trail")
local explosion = VFX:WaitForChild("Explosion")
local random = Random.new()
local ContentProvider = game:GetService("ContentProvider")
task.spawn(function()
	local singularityPlanets = general:WaitForChild("SingularityPlanets", 30)

	if singularityPlanets then
		ContentProvider:PreloadAsync({ singularityPlanets })
	end
end)

function RodOfTheSingularity.PlaySound(p, p2, p3)
	if p and p2 then
		fx:PlaySound(p, p2, false, "FishingSound", p3)
	end
end

function RodOfTheSingularity.CreateModel(p, _)
	local singularityPlanets = ReplicatedStorage.resources.replicated.instances.general:FindFirstChild("SingularityPlanets")

	if not singularityPlanets then
		warn("Failed to find SingularityPlanets folder!")
		return nil
	end

	local children = singularityPlanets:GetChildren()

	if #children == 0 then
		warn("SingularityPlanets folder is empty!")
		return nil
	end

	local clone = children[random:NextInteger(1, #children)]:Clone()
	clone:ScaleTo(clone:GetScale() * (p.ModelScale or 1))

	for _, descendant in clone:GetDescendants() do
		if descendant:IsA("BasePart") then
			descendant.Anchored = true
			descendant.CanCollide = false
			descendant.CanTouch = false
			descendant.CanQuery = false
			descendant.Massless = true
			descendant.CastShadow = false
		elseif descendant:IsA("JointInstance") or descendant:IsA("WeldConstraint") then
			descendant:Destroy()
		end
	end

	return clone
end

function RodOfTheSingularity:Update(p: number)
	self.elapsed += p
	self.phaseElapsed += p
	local v3 = 0.2617993877991494
	local value = TweenService:GetValue(math.min(self.elapsed / 1, 1), Enum.EasingStyle.Back, Enum.EasingDirection.Out)
	local value2

	if self.phase == "Failed" then
		value2 = TweenService:GetValue(
			math.min(self.phaseElapsed / 1, 1),
			Enum.EasingStyle.Quart,
			Enum.EasingDirection.In
		)
		value *= 1 - value2
		v3 *= 1 - value2
	else
		value2 = 0
	end

	self.spinAngle += v3 * p
	local v4 = math.max(value, 0.01)
	local v5 = CFrame.new(self.centerPos) * self.tiltCF * CFrame.Angles(0, self.spinAngle, 0)
	local phaseElapsed = self.phaseElapsed
	local v6 = self.phase == "Success"
	local v7 = not v6 and 0 or TweenService:GetValue(
		math.min(phaseElapsed / 0.45, 1),
		Enum.EasingStyle.Quart,
		Enum.EasingDirection.Out
	)

	for _, piece in self.pieces do
		if piece.consumed then
			continue
		end

		local offsetPos = piece.offsetPos
		local v8 = 1
		local identity = CFrame.identity

		if v6 then
			local v9 = math.max(phaseElapsed - 0.45, 0) * 1.25
			offsetPos += piece.burstDir * (piece.burstDist * v7 + v9)
			identity = CFrame.fromAxisAngle(piece.tumbleAxis, piece.tumbleSpeed * phaseElapsed)
			local v10 = (phaseElapsed - 0.8 - piece.suckDelay) / 1

			if v10 >= 1 then
				piece.consumed = true
				piece.part.Transparency = 1

				for _, trail2 in piece.part:GetDescendants() do
					if trail2:IsA("Trail") then
						trail2.Enabled = false
					end
				end

				continue
			elseif v10 > 0 then
				local value3 = TweenService:GetValue(v10, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
				offsetPos = CFrame.fromAxisAngle(createVector(0, 1, 0), 3.839724354387525 * value3) * (offsetPos * (1 - value3))
				v8 = 1 - value3
			end
		end

		piece.part.Size = piece.originalSize * v4 * v8
		piece.part.CFrame = v5 * CFrame.new(offsetPos * v4) * piece.offsetRot * identity

		if value2 > 0 then
			piece.part.Transparency = piece.originalTransparency + (1 - piece.originalTransparency) * value2
		end
	end
end

function RodOfTheSingularity.CreateVfx(object, maid, p, data, p2)
	local flag = false

	if v[p] then
		v[p]:Clean()
	end

	local maid2 = object:Extend()
	v[p] = maid2
	maid:Add(function()
		flag = true
		task.delay(10, function()
			maid2:Clean()
		end)
	end)
	maid2:Add(function()
		flag = true
		v[p] = nil
		v2[p] = nil
	end)
	local v3 = p2.Owner == localPlayer
	local folder = RodOfTheSingularity.CreateModel(data, p2)

	if not folder then
		return
	end

	maid2:Add(folder)

	if not v3 then
		folder:ScaleTo(folder:GetScale() * 0.5)
	end

	local primaryPart = folder.PrimaryPart or folder:FindFirstChildWhichIsA("BasePart")

	if not primaryPart then
		folder:Destroy()
		return
	end

	primaryPart.Transparency = 1
	local position = (p2.Center + createVector(0, 10, 0)).Position
	folder:PivotTo(CFrame.new(position))
	local cFrame = primaryPart.CFrame
	local pieces = {}

	for _, part in folder:GetDescendants() do
		if not (part:IsA("BasePart") and part ~= primaryPart) then
			continue
		end

		local objectSpace = cFrame:ToObjectSpace(part.CFrame)
		local burstDir

		if objectSpace.Position.Magnitude > 0.05 then
			burstDir = objectSpace.Position.Unit
		else
			burstDir = random:NextUnitVector()
		end

		table.insert(pieces, {
			part = part,
			offsetPos = objectSpace.Position,
			offsetRot = objectSpace.Rotation,
			originalSize = part.Size,
			originalTransparency = part.Transparency,
			burstDir = burstDir,
			burstDist = random:NextNumber(6, 12),
			tumbleAxis = random:NextUnitVector(),
			tumbleSpeed = math.rad((random:NextNumber(60, 140))),
			suckDelay = random:NextNumber(0, 0.25),
			consumed = false
		})
	end

	local v5 = {
		planet = folder,
		primary = primaryPart,
		pieces = pieces,
		holeScale = (data.ModelScale or 0.125) * (v3 and 1 or 0.75),
		centerPos = position,
		tiltCF = CFrame.Angles(
			math.rad((random:NextNumber(-12, 12))),
			math.rad((random:NextNumber(0, 360))),
			(math.rad((random:NextNumber(-12, 12))))
		),
		spinAngle = 0,
		elapsed = 0,
		phase = "Idle",
		phaseElapsed = 0,
		owner = p2.Owner,
		successSound = data.SuccessSound,
		failSound = data.FailSound
	}
	v2[p] = v5

	if flag then
		folder:Destroy()
		return
	end

	for _, v6 in pieces do
		v6.part.Size = createVector(0.01, 0.01, 0.01)
		v6.part.CFrame = CFrame.new(position)
	end

	folder.Parent = workspace.active.debrisfx
	RodOfTheSingularity.PlaySound(data.SpawnSound, primaryPart, p2.Owner)
	maid2:Add(RunService.RenderStepped:Connect(function(dt)
		RodOfTheSingularity.Update(v5, dt)
	end))
end

function RodOfTheSingularity.EndVfx(_, _, p: string, p2: number)
	local v3 = v2[p]
	local v4 = v[p]

	if not (v3 and v4 and v3.phase == "Idle") then
		return
	end

	if p2 == 2 then
		v3.phase = "Success"
		v3.phaseElapsed = 0
		RodOfTheSingularity.PlaySound(v3.successSound, v3.primary, v3.owner)
		local clone = explosion:Clone()
		clone.Parent = v3.primary

		for _, emitter in clone:GetDescendants() do
			if emitter:IsA("ParticleEmitter") then
				emitter:Emit(emitter:GetAttribute("EmitCount") or 15)
			end
		end

		for _, piece in v3.pieces do
			local clone2 = trail:Clone()

			for _, child in clone2:GetChildren() do
				child.Parent = piece.part
			end

			clone2:Destroy()
		end

		task.delay(0.45, function()
			if v2[p] ~= v3 then
				return
			end

			local clone2 = general:WaitForChild("SingularityVoid"):Clone()

			for _, v5 in clone2:QueryDescendants("BasePart") do
				v5.Anchored = true
				v5.CanCollide = false
				v5.CanTouch = false
				v5.CanQuery = false
				v5.CastShadow = false
			end

			clone2:PivotTo(CFrame.new(v3.centerPos))
			v4:Add(clone2)
			v3.blackHole = clone2
			clone2.Parent = workspace.active.debrisfx
			GeneralUtils.scaleTween(
				clone2,
				TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
				v3.holeScale * 8
			)
		end)
		task.delay(2.15, function()
			if v2[p] ~= v3 then
				return
			end

			local blackHole = v3.blackHole

			if not blackHole then
				return
			end

			local scaleTween = GeneralUtils.scaleTween(
				blackHole,
				TweenInfo.new(0.12, Enum.EasingStyle.Circular, Enum.EasingDirection.In),
				blackHole:GetScale() * 1.1,
				true
			)
			scaleTween.Completed:Once(function()
				if v2[p] ~= v3 then
					return
				end

				GeneralUtils.scaleTween(
					blackHole,
					TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.In),
					0
				)
			end)
			scaleTween:Play()
		end)
		task.delay(2.8499999999999996, function()
			v4:Clean()
		end)
	elseif p2 == 1 then
		v3.phase = "Failed"
		v3.phaseElapsed = 0
		RodOfTheSingularity.PlaySound(v3.failSound, v3.primary, v3.owner)

		for _, descendant in v3.planet:GetDescendants() do
			if descendant:IsA("ParticleEmitter") then
				descendant.Enabled = false
			elseif descendant:IsA("Light") then
				TweenService:Create(descendant, TweenInfo.new(1, Enum.EasingStyle.Linear), {
					Brightness = 0
				}):Play()
			end
		end

		task.delay(2, function()
			v4:Clean()
		end)
	end
end

return RodOfTheSingularity