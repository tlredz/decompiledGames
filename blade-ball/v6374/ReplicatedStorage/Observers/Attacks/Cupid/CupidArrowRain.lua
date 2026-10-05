local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Observers = require(ReplicatedStorage.Packages.Observers)
local Trove = require(ReplicatedStorage.Packages.Trove)
require(ReplicatedStorage.ServerInfo)
require(ReplicatedStorage.Common.Utils)

local function lerp(p, p2, p3: number)
	return p + (p2 - p) * p3
end

local function quadBezier(p, p2, p3, p4: number)
	local v = p + (p2 - p) * p4
	return v + (p2 + (p3 - p2) * p4 - v) * p4
end

return Observers.observeTag("CupidArrowRain", function(part)
	local maid = Trove.new()
	local travelTime = part:GetAttribute("TravelTime")
	local position = part:GetPivot().Position
	local position2 = part:GetAttribute("Target").Position
	local v = position + (position2 - position) * 0.5 + createVector(0, 1, 0) * (position2 - position).Magnitude * 3
	local total = 0
	local v2 = false
	local v3 = nil
	local arrowShaft = part:FindFirstChild("ArrowShaft")
	local v4 = false
	local rotation = part:GetPivot().Rotation
	v3 = maid:Add(RunService.PostSimulation:Connect(function(dt: number)
		local v5 = total / travelTime

		if not v2 then
			total += dt
		end

		if total >= 0.5 and arrowShaft and not v4 then
			v4 = true
			arrowShaft:PivotTo(CFrame.new(arrowShaft:GetPivot().Position) * CFrame.Angles(0, 0, 3.141592653589793))
		end

		local _ = total / travelTime
		local position3 = position
		local v7 = v
		local v9 = position3 + (v7 - position3) * v5
		local v10 = v9 + (v7 + (position2 - v7) * v5 - v9) * v5
		local v11 = CFrame.new(v10) * rotation
		part:PivotTo(v11)

		if travelTime <= total and not (maid._cleaning or v2) then
			if v3 then
				maid:Remove(v3)
				v3 = nil
			end

			v2 = true

			if part:IsA("BasePart") then
				part.Anchored = true
			end

			for _, descendant in part:GetDescendants() do
				if descendant:IsA("ParticleEmitter") then
					descendant.Enabled = false
				elseif descendant:IsA("BasePart") then
					descendant.Anchored = true
				end
			end

			local clone = maid:Clone(ReplicatedStorage.Assets.CupidBoss.HeartExplosion)
			clone:AddTag("HideInCutscene")
			clone.CFrame = CFrame.new(v11.Position + createVector(0, 2.5, 0))
			clone.Parent = workspace.Runtime

			for _, descendant in clone:GetDescendants() do
				if descendant:IsA("ParticleEmitter") then
					descendant:Emit(descendant.Rate)
				elseif descendant:IsA("Beam") or descendant:IsA("PointLight") then
					descendant.Enabled = true
				end
			end

			local v12 = maid:Add(ReplicatedStorage.Assets.Sounds.CupidBoss.ExplosionHit:Clone())
			v12.Parent = clone
			v12:Play()

			for _, part2 in part:GetDescendants() do
				if part2:IsA("BasePart") then
					part2.Transparency = 1
				end
			end

			task.wait(1.5)

			for _, descendant in clone:GetDescendants() do
				if descendant:IsA("Beam") or descendant:IsA("PointLight") then
					descendant.Enabled = false
				end
			end

			task.wait(0.5)
			maid:Clean()
		end
	end))
	return function()
		maid:Destroy()
	end
end, { workspace })