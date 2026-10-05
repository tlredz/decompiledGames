local createVector = vector.create
local TweenService = game:GetService("TweenService")
local Create = require(game.ReplicatedStorage.Util.Create)
local Flare = {}
Flare.__index = Flare

function Flare.new(instance)
	local v = {
		Color = instance.Color or Color3.new(1, 1, 1),
		Size = instance.Size or createVector(1, 1, 1),
		CFrame = instance.CFrame,
		Transparency = instance.Transparency or 0,
		Distance = instance.Distance or 20,
		DistanceOffset = instance.DistanceOffset or 0,
		TweenInfo = instance.TweenInfo or TweenInfo.new(0.2),
		Part = Create.Sphere()
	}
	v.Part.Material = "Neon"
	v.Part.Color = v.Color
	v.Part.Mesh.Scale = v.Size
	v.Part.Mesh.Offset = Vector3.new(0, 0, -v.DistanceOffset)
	v.Part.Transparency = instance.Transparency
	v.Part.CFrame = instance.CFrame
	return (setmetatable(v, {
		__index = Flare
	}))
end

function Flare:Emit(data2)
	if data2.Color or data2.Transparency then
		TweenService:Create(self.Part, self.TweenInfo, {
			Color = data2.Color,
			Transparency = data2.Transparency
		}):Play()
	end

	local tween = TweenService:Create(self.Part.Mesh, self.TweenInfo, {
		Offset = Vector3.new(0, 0, -self.Distance),
		Scale = data2.Size or Vector3.new()
	})
	tween.Completed:Connect(function()
		self.Part:Destroy()
	end)
	tween:Play()
	self.Part.Parent = workspace._WorldOrigin
end

function Flare:EmitRadial(p)
	self.CFrame = self.CFrame * CFrame.Angles(0, (math.random() - 0.5) * math.rad(p.SpreadAngle.Y), 0) * CFrame.Angles(
		(math.random() - 0.5) * math.rad(p.SpreadAngle.X),
		0,
		0
	)
	self.Part.CFrame = self.CFrame
	self:Emit(p)
end

return Flare