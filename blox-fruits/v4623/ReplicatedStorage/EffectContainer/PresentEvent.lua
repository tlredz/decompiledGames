local createVector = vector.create
workspace:WaitForChild("_WorldOrigin")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(game.ReplicatedStorage:WaitForChild("Effect"))
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local sound = Util.Sound
local _ = workspace._WorldOrigin
local _ = workspace.Map
game:GetService("TweenService")
game:GetService("RunService")
local flag = false
local v = {}

function lerp(p, p2, p3)
	return p + (p2 - p) * p3
end

function bezier(p, p2, p3, p4)
	local lerped = lerp(p, p2, p4)
	local lerped2 = lerp(p2, p3, p4)
	return (lerp(lerped, lerped2, p4))
end

function Hook()
	if flag then
		return
	end

	flag = true
	local RunService = game:GetService("RunService")
	RunService:BindToRenderStep("PresentTweens", 100, function()
		local now = os.clock()
		local v2 = {}

		for _, v3 in pairs(v) do
			if not (v3.obj and v3.obj:FindFirstChild("Root")) then
				continue
			end

			local v4 = math.clamp((now - v3.started) / (v3.ends - v3.started), 0, 1)
			v3.obj.Root.CFrame = CFrame.new(bezier(v3.p0, v3.p1, v3.p2, v4)) * v3.rotation
			v3.obj.Parent = workspace._WorldOrigin

			if v4 ~= 1 then
				table.insert(v2, v3)
			end
		end

		v = v2

		if #v2 == 0 then
			local RunService2 = game:GetService("RunService")
			RunService2:UnbindFromRenderStep("PresentTweens")
			flag = false
		end
	end)
end

return function(p)
	if p.Index ~= 1 then
		local _ = p.Index == 2
		return
	end

	local presentPad = workspace:WaitForChild("PresentPad", 60)

	if not presentPad then
		print("present spawn point not found")
		return
	end

	if (workspace.CurrentCamera.CFrame.Position - presentPad.Position).Magnitude > 915.3485 then
		return
	end

	local _ = presentPad.Position + createVector(0, 50, 0)
	local clone = script.GiantPresent:Clone()
	clone.Parent = workspace._WorldOrigin
	clone.RootPart.CFrame = CFrame.new(presentPad.Position + createVector(0, 50, 0))
	local v2 = {}
	local TweenService = game:GetService("TweenService")
	local tween = TweenService:Create(
		clone.RootPart,
		TweenInfo.new(2.2, Enum.EasingStyle.Sine, Enum.EasingDirection.In),
		{
			CFrame = CFrame.new(presentPad.Position)
		}
	)
	tween:Play()
	sound:Play("GiftDrop", clone.RootPart.Position)
	tween.Completed:Connect(function()
		clone.AnimationController.Animator:LoadAnimation(script.PresentBounce):Play()
		task.wait(1.65)
		local v3 = sound:Play("WingFlapsBox", clone.RootPart.Position)
		clone.AnimationController.Animator:LoadAnimation(script.PresentTickExplode):Play()
		task.wait(8.1)
		sound:Play("GiftRelease", clone.RootPart.Position)
		sound:FadeOut(v3, 0.25)
		local now = os.clock()

		for _, v4 in pairs(v2) do
			v4.ends = now + v4.ends - v4.started
			v4.started = now
			table.insert(v, v4)
		end

		Hook()

		for _, part in pairs(clone:GetChildren()) do
			if not part:IsA("BasePart") then
				continue
			end

			local TweenService2 = game:GetService("TweenService")
			TweenService2:Create(part, TweenInfo.new(0.15), {
				Transparency = 1
			}):Play()
		end

		task.wait(0.25)
		clone:Destroy()
	end)
	local now = os.clock()

	for _, obj in pairs(p.Obj) do
		local magnitude = (obj.Root.Position - presentPad.Position).Magnitude
		local v4 = CFrame.new(presentPad.Position, obj.Root.Position) * CFrame.new(0, 0, -magnitude / 2) + Vector3.new(
			0,
			math.random() * 20 + 30,
			0
		)
		local cframe = CFrame.Angles(0, math.rad(math.random() * 360), 0)
		local v5 = math.random() * 0.3 + 0.6
		table.insert(v2, {
			p0 = presentPad.Position,
			p1 = v4.Position,
			p2 = obj.Root.Position,
			rotation = cframe,
			ends = v5 + now,
			started = now,
			obj = obj
		})
		obj.Root.CFrame = CFrame.new(presentPad.Position) * cframe
	end
end