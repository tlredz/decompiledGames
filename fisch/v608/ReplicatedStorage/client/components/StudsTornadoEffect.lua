local createVector = vector.create
game:GetService("TweenService")
game:GetService("RunService")
local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local packages = ReplicatedStorage.packages
local Component = require(packages.Component)
local Trove = require(packages.Trove)
local stud = script:FindFirstChild("Stud")
local v = Component.new({
	Tag = "StudsTornado"
})

function v:Construct()
	self.trove = Trove.new()
end

function v:Start()
	local instance = self.Instance
	local clones = {}
	local v2 = {
		Color3.fromRGB(0, 85, 191),
		Color3.fromRGB(129, 0, 123),
		Color3.fromRGB(220, 188, 129),
		Color3.fromRGB(137, 135, 136)
	}

	local function onRemoved()
		if not instance:IsDescendantOf(game) then
			self:Stop()
		end
	end

	self.trove:Add(instance.AncestryChanged:Connect(onRemoved))

	local function spawnStud()
		local clone = stud:Clone()
		clone.Position = instance.Position
		clone.Anchored = true
		clone.CanCollide = false
		local color = v2[math.random(1, #v2)]
		clone.Color = color
		clone.Trail.Color = ColorSequence.new(color)
		clone.Parent = instance
		table.insert(clones, clone)
		local lastTime = tick()
		local v4 = math.random(4, 6)
		local v5 = math.random(1, 360)
		local rotSpeed = clone:GetAttribute("RotSpeed") or createVector(10, 10, 10)
		self.trove:Add(task.spawn(function()
			while clone.Parent == instance do
				local v6 = tick() - lastTime
				local v7 = (tick() + v5) * 10 * 0.5
				local v8 = 1 + 80 * (v6 / v4)
				local v9 = v8 * math.cos(v7)
				local v10 = v8 * math.sin(v7)
				local vector2 = Vector3.new(
					instance.Position.X + v9,
					instance.Position.Y + 100 * (v6 / v4),
					instance.Position.Z + v10
				)
				local cframe = CFrame.Angles(
					math.rad(rotSpeed.X * v6),
					math.rad(rotSpeed.Y * v6),
					(math.rad(rotSpeed.Z * v6))
				)
				clone.CFrame = CFrame.new(vector2) * cframe
				task.wait(0.025)
			end
		end))
		Debris:AddItem(clone, v4)
	end

	self.trove:Add(task.spawn(function()
		while instance:IsDescendantOf(game) do
			spawnStud()
			task.wait(0.15)
		end
	end))
end

function v:Stop()
	self.trove:Destroy()
end

return v