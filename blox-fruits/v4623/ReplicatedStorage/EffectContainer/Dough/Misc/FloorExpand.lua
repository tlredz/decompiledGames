local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local dough = ReplicatedStorage.EffectContainer.Dough
local Pool = require(ReplicatedStorage:WaitForChild("Pool"))
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local Effect = require(ReplicatedStorage:WaitForChild("Effect"))
local currentCamera = workspace.CurrentCamera
local FloorExpand = require(dough.Util.FloorExpand)
local v = Pool.new(string.format("Dough/%s/%s", script.Parent.Name, script.Name))
v:setAction(function(object, p)
	local now = tick()

	for _, v2 in pairs(object.Pool) do
		if now - v2.LastCall > (v2.Lifetime or 3) or not v2.Model:IsDescendantOf(workspace) then
			v2:clear()
			object:remove(v2)
		else
			v2:update(p)
		end
	end
end)

local function theresSpace(cFrame, p, p2)
	local cylinder = Util.RotatedRegion3.Cylinder(
		cFrame * CFrame.Angles(0, 0, 1.5707963267948966),
		(Vector3.new(1, 1 * p, 1 * p))
	)
	local v2 = {}

	for _, v3 in pairs(v.Pool) do
		table.insert(v2, v3)
	end

	table.sort(v2, function(a, b)
		return (a.CFrame.p - cFrame.p).Magnitude - a:__getScale() < (b.CFrame.p - cFrame.p).Magnitude - b:__getScale()
	end)

	if p2 then
		task.spawn(function()
			for _, v3 in pairs(v2) do
				Effect.new("VisualizePart"):replicate({
					Shape = Enum.PartType.Ball,
					Size = createVector(10, 10, 10),
					CFrame = v3.CFrame,
					Duration = 0.5,
					Transparency = 0.5,
					Color = Color3.new(1, 0, 0)
				})
				task.wait(0.5)
			end
		end)
	end

	local v3 = nil
	local v4 = true

	for _, v6 in pairs(v2) do
		local cFrame2 = v6.CFrame
		local __getScale = v6:__getScale()

		if not cylinder:CastPart({
			ClassName = "Part",
			Shape = Enum.PartType.Cylinder,
			Size = Vector3.new(1, 1 * __getScale, 1 * __getScale),
			CFrame = cFrame2 * CFrame.Angles(0, 0, 1.5707963267948966)
		}) then
			continue
		end

		v3 = v6
		v4 = false
		break
	end

	local result = {}

	for _, v6 in pairs(v2) do
		local cFrame2 = v6.CFrame
		local __getScale = v6:__getScale()

		if (cFrame.p - cFrame2.p).Magnitude < (p + __getScale) * 1.25 and v6 ~= v3 then
			table.insert(result, v6)
		end
	end

	v2 = {}
	return v4, v3, result
end

return function(data)
	local cFrame = data.CFrame
	local scale = data.Scale or 5
	local strength = data.Strength or 1
	local baseStrength = data.BaseStrength or 0

	if 250 + scale * (strength + baseStrength) < (currentCamera.CFrame.p - cFrame.p).Magnitude then
		return
	end

	local v2, v3, v4 = theresSpace(cFrame, scale + scale / 5 * (strength + baseStrength))

	if v2 then
		local v5 = FloorExpand.new(data)

		if v5.Model.Parent then
			v:add(v5)
		end
	else
		v3.FastMode = data.FastMode
		v3.Buso = data.Buso
		v3.MaximumStrength = math.max(v3.MaximumStrength, data.MaximumStrength or 0)
		v3:add(strength)

		for _, v5 in pairs(v4) do
			v5:popRocks(1 - math.min(
				1,
				(v5.CFrame.p - v3.CFrame.p).Magnitude / ((v3:__getScale() + v5:__getScale()) * 2)
			))
		end
	end
end