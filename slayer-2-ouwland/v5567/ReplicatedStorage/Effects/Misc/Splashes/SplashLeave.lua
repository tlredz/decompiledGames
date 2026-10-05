local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Ouwmit = require(ReplicatedStorage.CAM.Client.Modules.Effects.Ouwmit)
local DebrisModule = require(ReplicatedStorage.CAM.DebrisModule)
local splashExit = ReplicatedStorage.Assets.Swim.SplashExit
local pS2DP2waterSPLASHOUT = ReplicatedStorage.Assets.Swim.Sounds.PS2DP2waterSPLASHOUT
return function(cframe: CFrame)
	local clone = splashExit:Clone()
	clone.Parent = workspace
	clone:PivotTo(cframe + createVector(0, 0.325, 0))
	Ouwmit.Emit(clone)
	local clone2 = pS2DP2waterSPLASHOUT:Clone()
	clone2.Parent = clone.PrimaryPart or clone:FindFirstChildWhichIsA("BasePart") or clone
	clone2:Play()
	DebrisModule:AddItem(clone, 3)
end