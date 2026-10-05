local createVector = vector.create
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UseNewLobby = require(ReplicatedStorage.Shared.UseNewLobby)

if not UseNewLobby() then
	return
end

local tweenInfo = TweenInfo.new(5, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, -1, true, 0)
workspace:WaitForChild("Spawn", 1000000)
local v = {
	script.Parent.Parent.Parent:WaitForChild("SwordCratesSign"),
	script.Parent.Parent.Parent:WaitForChild("ExplosionCratesSign")
}

local function animateSign(instance)
	local v2 = {
		Position = instance.PrimaryPart.Position + createVector(0, 3, 0)
	}
	local tween = TweenService:Create(instance.PrimaryPart, tweenInfo, {
		Orientation = createVector(0, 360, 0)
	})
	local tween2 = TweenService:Create(instance.PrimaryPart, tweenInfo, v2)
	tween:Play()
	tween2:Play()
end

for _, v2 in ipairs(v) do
	animateSign(v2)
end