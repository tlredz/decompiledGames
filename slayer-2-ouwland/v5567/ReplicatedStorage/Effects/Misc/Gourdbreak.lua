local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local DebrisModule = require(ReplicatedStorage.CAM.DebrisModule)
local tweenInfo = TweenInfo.new(0.25)
return function(cframe: CFrame, value: number?)
	if cframe == nil then
		return
	end

	local firstChild = script:FindFirstChild("Break")

	if firstChild == nil then
		return
	end

	local clone = firstChild:Clone()
	clone:ScaleTo(clone:GetScale() * (value or 1))
	clone:PivotTo(cframe)
	clone.Parent = workspace.Debree
	local parts = {}

	for _, part in ipairs(clone:GetDescendants()) do
		if not part:IsA("BasePart") then
			continue
		end

		table.insert(parts, part)
		part.Anchored = false
		part.CanCollide = true
		part.CollisionGroup = "HumanoidsCollide"
		part.CastShadow = false
		part.CanTouch = false
		part.CanQuery = false
		part.AssemblyLinearVelocity = Vector3.new(math.random(-10, 10), math.random(10, 20), math.random(-10, 10))
		part.AssemblyAngularVelocity = Vector3.new(math.random(-10, 10), math.random(-10, 10), math.random(-10, 10))
	end

	task.delay(4 - tweenInfo.Time, function()
		if clone.Parent == nil then
			return
		end

		for _, v in parts do
			TweenService:Create(v, tweenInfo, {
				Transparency = 1
			}):Play()
		end
	end)
	DebrisModule:AddItem(clone, 4)
end