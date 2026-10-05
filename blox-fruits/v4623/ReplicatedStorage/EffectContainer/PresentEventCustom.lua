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

return function(data)
	if data.Index ~= 1 then
		local _ = data.Index == 2
		return
	end

	local point = data.Point
	local now = os.clock()
	local v2 = {}

	for _, obj in pairs(data.Obj) do
		sound:Play("GiftDrop", obj.Root)
		local magnitude = (obj.Root.Position - point).Magnitude
		local v4 = CFrame.new(point, obj.Root.Position) * CFrame.new(0, 0, -magnitude / 2) + Vector3.new(
			0,
			math.random() * 20 + 30,
			0
		)
		local cframe = CFrame.Angles(0, math.rad(math.random() * 360), 0)
		local v5 = math.random() * 0.3 + 0.6
		table.insert(v2, {
			p0 = point,
			p1 = v4.Position,
			p2 = obj.Root.Position,
			rotation = cframe,
			ends = v5 + now,
			started = now,
			obj = obj
		})
		obj.Root.CFrame = CFrame.new(point) * cframe
	end

	task.wait()
	local now2 = os.clock()

	for _, v3 in pairs(v2) do
		v3.ends = now2 + v3.ends - v3.started
		v3.started = now2
		table.insert(v, v3)
	end

	Hook()
end