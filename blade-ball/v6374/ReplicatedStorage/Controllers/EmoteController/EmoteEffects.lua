local createVector = vector.create
local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local v = require3(ReplicatedStorage2.Packages.Trove)
local v2 = require3(ReplicatedStorage2.Packages.Spring)
local v3 = require3(ReplicatedStorage2.Common.Utils)
local EmoteEffects = {}

function EmoteEffects.LotusGrow(instance, ...)
	if instance and instance:IsDescendantOf(workspace) then
		TweenService:Create(instance, TweenInfo.new(0.75, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Size = instance:GetAttribute("TargetSize"),
			CFrame = instance:GetAttribute("TargetCFrame")
		}):Play()
	end
end

function EmoteEffects.MirageFireballs(pVInstance, ...)
	if not (pVInstance and pVInstance:IsDescendantOf(workspace) and pVInstance:IsA("PVInstance")) then
		return
	end

	local maid = v.new()
	maid:AttachToInstance(pVInstance)

	for _, emitter in pVInstance:GetDescendants() do
		if emitter:IsA("ParticleEmitter") then
			emitter.Enabled = true
		end
	end

	local fireballTarget = pVInstance:WaitForChild("FireballTarget")
	local value = fireballTarget and fireballTarget.Value

	if not value then
		return
	end

	local velocity = pVInstance:GetAttribute("Velocity")
	local radius = pVInstance:GetAttribute("Radius")
	local angle = pVInstance:GetAttribute("Angle")
	maid:Add(RunService.PostSimulation:Connect(function(_: number)
		local v4 = os.clock() * velocity
		pVInstance:PivotTo((CFrame.Angles(0, angle, 0) + value:GetPivot().Position) * CFrame.new(
			math.cos(v4) * radius,
			0,
			math.sin(v4) * radius
		))
	end))
end

function EmoteEffects.WinFlex(billboardGui, goal: number, ...)
	if not (billboardGui and billboardGui:IsDescendantOf(workspace) and billboardGui:IsA("BillboardGui")) then
		return
	end

	local textLabel = billboardGui:WaitForChild("TextLabel", 5)
	local uIStroke = textLabel and textLabel:WaitForChild("UIStroke", 5)

	if not (uIStroke and textLabel) then
		return
	end

	local maid = v.new()
	maid:AttachToInstance(billboardGui)
	local v4 = v2.new(0, 4, nil, 0.5)
	local lastTime = os.clock()
	maid:Add(RunService.PostSimulation:Connect(function(dt: number)
		if math.abs(v4.velocity) <= 4 and os.clock() - lastTime > 0.2 then
			v4.dampingRatio = 0.9
		end

		local v5 = v4:update(dt) // 1

		if math.abs(goal - v5) <= 1 then
			v5 = goal
		end

		textLabel.Text = v3.ValueConvertor:AddCommas(v5)
	end))
	maid:Add(task.delay(0.1, function()
		if not billboardGui:IsDescendantOf(workspace) then
			return
		end

		v4.goal = goal
	end))
	maid:Add(TweenService:Create(textLabel, TweenInfo.new(0.45, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		TextTransparency = 0
	})):Play()
	maid:Add(TweenService:Create(uIStroke, TweenInfo.new(0.45, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Transparency = 0
	})):Play()
	billboardGui.StudsOffsetWorldSpace = createVector(-0, -1.5, -0)
	maid:Add(TweenService:Create(billboardGui, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		StudsOffsetWorldSpace = createVector(0, 0, 0)
	})):Play()
end

function EmoteEffects.KillCollector(billboardGui, goal: number, ...)
	if not (billboardGui and billboardGui:IsDescendantOf(workspace) and billboardGui:IsA("BillboardGui")) then
		return
	end

	local textLabel = billboardGui:WaitForChild("TextLabel", 5)
	local uIStroke = textLabel and textLabel:WaitForChild("UIStroke", 5)

	if not (uIStroke and textLabel) then
		return
	end

	local maid = v.new()
	maid:AttachToInstance(billboardGui)
	local v4 = v2.new(0, 4, nil, 0.5)
	local lastTime = os.clock()
	maid:Add(RunService.PostSimulation:Connect(function(dt: number)
		if math.abs(v4.velocity) <= 4 and os.clock() - lastTime > 0.2 then
			v4.dampingRatio = 0.9
		end

		local v5 = v4:update(dt) // 1

		if math.abs(goal - v5) <= 1 then
			v5 = goal
		end

		textLabel.Text = v3.ValueConvertor:AddCommas(v5)
	end))
	maid:Add(task.delay(0.1, function()
		if not billboardGui:IsDescendantOf(workspace) then
			return
		end

		v4.goal = goal
	end))
	maid:Add(TweenService:Create(textLabel, TweenInfo.new(0.45, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		TextTransparency = 0
	})):Play()
	maid:Add(TweenService:Create(uIStroke, TweenInfo.new(0.45, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Transparency = 0
	})):Play()
	billboardGui.StudsOffsetWorldSpace = createVector(-0, -1.5, -0)
	maid:Add(TweenService:Create(billboardGui, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		StudsOffsetWorldSpace = createVector(0, 0, 0)
	})):Play()
end

function EmoteEffects.Emote162(parent, instance, p: number)
	if not (parent and parent:IsDescendantOf(game)) then
		return
	end

	local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

	if not humanoidRootPart then
		return
	end

	local maid = v.new()
	maid:AttachToInstance(parent)
	local v4 = workspace:GetServerTimeNow() - p
	local VFX = ReplicatedStorage2.Misc.SwordPacksVFX["Dual Void Scythes"].VFX
	local cloneAndWeld_2 = v3.Physics.CloneAndWeld(
		instance,
		VFX.FloorEmotePart,
		CFrame.new(0, -2.98, 0),
		humanoidRootPart,
		maid
	)
	cloneAndWeld_2.Parent = parent

	for _, v5 in {
		{ 179, CFrame.new(4.68, 7.03, 0.34) },
		{ 191, CFrame.new(-3.98, 0.99, -0.81) },
		{ 202, CFrame.new(8.4, 3.05, 0.57) },
		{ 212, CFrame.new(-0.4, 9.87, 0.56) },
		{ 219, CFrame.new(-0.42, -1.93, 0.58) },
		{ 223, CFrame.new(-0.43, -0.53, 23.93) }
	} do
		local v6 = v5
		maid:Add(task.delay(v5[1] / 60 - v4, function()
			local cloneAndWeld = v3.Physics.CloneAndWeld(instance, VFX.BodyEmit, v6[2], humanoidRootPart, maid)
			cloneAndWeld.Parent = parent
			v3.Visual:PlayEffects(cloneAndWeld)
		end))
	end

	maid:Add(task.delay(0, function()
		local clone = maid:Clone(ReplicatedStorage2.Misc.DualVoidScythes)
		clone.Parent = humanoidRootPart
		clone:Play()
	end))
	maid:Add(task.delay(5.4, function()
		local clone = maid:Clone(ReplicatedStorage2.Misc.DualVoidScythesLoop)
		clone.Parent = humanoidRootPart
		clone:Play()
	end))
end

return EmoteEffects