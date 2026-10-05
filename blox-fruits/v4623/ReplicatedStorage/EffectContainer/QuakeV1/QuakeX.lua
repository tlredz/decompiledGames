local createVector = vector.create
game:GetService("TweenService")
local FX = require(game.ReplicatedStorage.FX)
local quakeEffects = FX:WaitForChild("QuakeEffects")
local TweenService = game:GetService("TweenService")
local quakeRocks = require(game.ReplicatedStorage.EffectContainer.quakeRocks)
require(game.ReplicatedStorage.Effect)
local Util = require(game.ReplicatedStorage.Util)
local debris = Util.Debris
return function(p)
	local _ = p.hrp
	local dir = p.dir
	local clone = quakeEffects.halfWindSphere:Clone()
	clone.CFrame = dir * CFrame.new(0, 0, -5) * CFrame.Angles(1.5707963267948966, 0, 0)
	debris:AddItem(clone, 0.125)
	TweenService:Create(clone, TweenInfo.new(0.125, Enum.EasingStyle.Sine), {
		Size = createVector(35, 12.5, 35),
		Transparency = 1,
		CFrame = clone.CFrame * CFrame.new(0, 10, 0)
	}):Play()
	clone.Parent = workspace._WorldOrigin
	local clone2 = quakeEffects.windCylinder:Clone()
	clone2.CFrame = dir * CFrame.Angles(1.5707963267948966, 0, 0) * CFrame.new(0, 0, 0)
	clone2.Size = createVector(5, 12.5, 5)
	debris:AddItem(clone2, 0.5)
	TweenService:Create(clone2, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {
		Size = createVector(45, 0, 45),
		Transparency = 1,
		CFrame = clone2.CFrame * CFrame.new(0, 15, 0)
	}):Play()
	clone2.Parent = workspace._WorldOrigin
	local clone3 = quakeEffects.windCylinder:Clone()
	clone3.Parent = workspace._WorldOrigin
	clone3.CFrame = dir * CFrame.Angles(1.5707963267948966, 0, 0) * CFrame.new(0, 0, 0)
	clone3.Size = createVector(5, 12.5, 5)
	debris:AddItem(clone3, 0.5)
	TweenService:Create(clone3, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {
		Size = createVector(35, 0, 35),
		Transparency = 1,
		CFrame = clone2.CFrame * CFrame.new(0, -25, 0)
	}):Play()
	task.spawn(quakeRocks, {
		CFrame = dir
	}, 1, -10, 250)
	task.spawn(quakeRocks, {
		CFrame = dir
	}, -1, 10, 250)
	local p2 = dir.p
	local v = dir.LookVector * 250
	local _, v2 = Util.Ray(p2, v, { workspace.Characters, workspace.Enemies, workspace._WorldOrigin })
	local magnitude = (p2 - v2).Magnitude

	for i = 1, magnitude, magnitude / 8 do
		local v3 = CFrame.new(p2, v2) * Vector3.new(0, 0, -i)
		local ray = Util.Ray
		local v4 = { workspace.Characters, workspace.Enemies }
		local v5, v6 = ray(v3, createVector(0, -15, 0), v4)

		if v5 then
			local integer = Random.new():NextInteger(1, 2)

			if integer == 2 then
				local number = Random.new():NextNumber(1.5, 2)
				local part = Instance.new("Part")
				part.Position = v6 + createVector(0, -2.5, 0)
				part.CanCollide = false
				part.Size = Vector3.new(number, number, number)
				part.Material = v5.Material
				part.Color = v5.Color
				part.Name = 2
				part.Parent = workspace._WorldOrigin
				debris:AddItem(part, 1.5)
				local bodyVelocity = Instance.new("BodyVelocity")
				bodyVelocity.Parent = part
				bodyVelocity.MaxForce = createVector(1e17, 1e17, 1e17)
				bodyVelocity.Velocity = Vector3.new(
					Random.new():NextNumber(-35, 35),
					Random.new():NextNumber(75, 100),
					Random.new():NextNumber(-35, 35)
				)
				debris:AddItem(bodyVelocity, 0.025)
				local bodyAngularVelocity = Instance.new("BodyAngularVelocity")
				bodyAngularVelocity.Parent = part
				bodyAngularVelocity.MaxTorque = createVector(1e17, 1e17, 1e17)
				bodyAngularVelocity.AngularVelocity = Vector3.new(
					Random.new():NextNumber(-15, 15),
					Random.new():NextNumber(-15, 15),
					Random.new():NextNumber(-15, 15)
				)
				debris:AddItem(bodyAngularVelocity, 0.1)
			end
		end

		task.wait(0.03333333333333333)
	end
end