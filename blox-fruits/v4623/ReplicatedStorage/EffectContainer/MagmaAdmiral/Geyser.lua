local createVector = vector.create
local TweenService = game:GetService("TweenService")
local Util = require(game.ReplicatedStorage:WaitForChild("Util"))
local color = Color3.fromRGB(255, 83, 26)
return function(p)
	local position = p.position

	if typeof(position) ~= "Vector3" or (position - workspace.CurrentCamera.CFrame.Position).Magnitude > 900 then
		return
	end

	local part = Instance.new("Part")
	part.Anchored = true
	part.CanCollide = false
	part.Size = createVector(6, 4, 6)
	part.CFrame = CFrame.new(position)
	part.Color = color
	part.Material = Enum.Material.Neon
	part.Transparency = 0.2
	part.Parent = workspace._WorldOrigin
	Util.Debris:AddItem(part, 0.7)
	TweenService:Create(part, TweenInfo.new(0.35), {
		Size = createVector(11, 55, 11),
		Transparency = 1
	}):Play()
end