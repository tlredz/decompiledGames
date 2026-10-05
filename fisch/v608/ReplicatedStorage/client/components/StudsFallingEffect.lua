local createVector = vector.create
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local packages = ReplicatedStorage.packages
local Component = require(packages.Component)
local Trove = require(packages.Trove)
local stud = script:FindFirstChild("Stud")
local v = Component.new({
	Tag = "StudsFalling"
})

function v:Construct()
	self.trove = Trove.new()
end

function v:Start()
	local instance = self.Instance
	local clones = {}

	local function onRemoved()
		if not instance:IsDescendantOf(game) then
			self:Stop()
		end
	end

	self.trove:Add(instance.AncestryChanged:Connect(onRemoved))
	local v2 = {
		Color3.fromRGB(0, 85, 191),
		Color3.fromRGB(129, 0, 123),
		Color3.fromRGB(220, 188, 129),
		Color3.fromRGB(137, 135, 136)
	}
	local Y = instance.Position.Y
	self.trove:Add(task.spawn(function()
		while true do
			local clone = stud:Clone()
			clone.Anchored = true
			clone.CanCollide = false
			clone.Transparency = 1
			local color = v2[math.random(1, #v2)]
			clone.Color = color
			clone.Trail.Color = ColorSequence.new(color)
			clone.Position = Vector3.new(
				instance.Position.X + math.random(-20, 20),
				instance.Position.Y + 50,
				instance.Position.Z + math.random(-20, 20)
			)
			clone.Orientation = Vector3.new(math.random(0, 360), math.random(0, 360), math.random(0, 360))
			clone:SetAttribute(
				"RotSpeed",
				(Vector3.new(math.random(-90, 90), math.random(-90, 90), math.random(-90, 90)))
			)
			clone:SetAttribute("RotAngle", createVector(0, 0, 0))
			clone.Parent = instance
			table.insert(clones, clone)
			TweenService:Create(clone, TweenInfo.new(0.5), {
				Transparency = 0
			}):Play()
			task.wait(0.3)
		end
	end))
	self.trove:Add(RunService.Heartbeat:Connect(function(dt)
		for i = #clones, 1, -1 do
			local v3 = clones[i]

			if v3 and v3.Parent then
				local now = tick()
				local v4 = v3.Position.Y - 12.5 * dt
				local vector2 = Vector3.new(v3.Position.X + math.sin(now * 2) * 2 * dt, v4, v3.Position.Z)
				local rotSpeed = v3:GetAttribute("RotSpeed") or createVector(0, 0, 0)
				local v5 = (v3:GetAttribute("RotAngle") or createVector(0, 0, 0)) + rotSpeed * dt
				v3:SetAttribute("RotAngle", v5)
				local cframe = CFrame.Angles(math.rad(v5.X), math.rad(v5.Y), (math.rad(v5.Z)))
				v3.CFrame = CFrame.new(vector2) * cframe

				if v4 <= Y then
					TweenService:Create(v3, TweenInfo.new(0.5), {
						Transparency = 1
					}):Play()
					task.delay(1, v3.Destroy, v3)
					table.remove(clones, i)
				end
			else
				table.remove(clones, i)
			end
		end
	end))
end

function v:Stop()
	self.trove:Destroy()
end

return v