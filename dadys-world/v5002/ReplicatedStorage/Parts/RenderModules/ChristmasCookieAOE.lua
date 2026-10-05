local createVector = vector.create
local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
return {
	RenderObject = function(list)
		local v = list[1]
		local humanoid = v:FindFirstChild("Humanoid")
		local humanoidRootPart = v:FindFirstChild("HumanoidRootPart")

		if not (humanoid and humanoidRootPart) then
			warn("ChristmasCookieAOE: Missing Humanoid or HumanoidRootPart")
			return
		end

		local v2 = humanoidRootPart.Size.Y / 2 + humanoid.HipHeight
		local tishaPoof = ReplicatedStorage.Parts:FindFirstChild("TishaPoof")

		if not tishaPoof then
			warn("ChristmasCookieAOE: TishaPoof not found")
			return
		end

		local clone = tishaPoof:Clone()
		clone.Parent = workspace
		clone.Anchored = true
		clone.CanCollide = false
		clone.CanQuery = false
		clone.CastShadow = false
		clone.CanTouch = false
		clone.Size = createVector(0, 0.25, 0)
		clone.Position = humanoidRootPart.Position + Vector3.new(0, -v2, 0)
		clone.Color = Color3.fromRGB(220, 160, 100)
		Debris:AddItem(clone, 5)
		TweenService:Create(clone, TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Size = createVector(60, 0.25, 60),
			Transparency = 1,
			Rotation = createVector(0, 2.740167, 0)
		}):Play()
	end
}