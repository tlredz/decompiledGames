local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Observers = require(ReplicatedStorage.Packages.Observers)
local Trove = require(ReplicatedStorage.Packages.Trove)
require(ReplicatedStorage.ServerInfo)
local Utils = require(ReplicatedStorage.Common.Utils)

local function lerp(p, p2, p3: number)
	return p + (p2 - p) * p3
end

local function quadBezier(p, p2, p3, p4: number)
	local v = p + (p2 - p) * p4
	return v + (p2 + (p3 - p2) * p4 - v) * p4
end

return Observers.observeTag("HorsemanFireBall", function(part)
	local maid = Trove.new()
	local travelTime = part:GetAttribute("TravelTime")
	local position = part:GetPivot().Position
	local position2 = part:GetAttribute("Target").Position
	local v = position + (position2 - position) * 0.5 + createVector(0, 1, 0) * (position2 - position).Magnitude * 0.2
	local total = 0
	local v2 = false
	local v3 = nil
	v3 = maid:Add(RunService.PostSimulation:Connect(function(dt: number)
		local v4 = total / travelTime

		if not v2 then
			total += dt
		end

		local v5 = total / travelTime
		local position3 = position
		local v7 = v
		local v9 = position3 + (v7 - position3) * v4
		local v10 = v9 + (v7 + (position2 - v7) * v4 - v9) * v4
		local position4 = position
		local v12 = v
		local v14 = position4 + (v12 - position4) * v5
		local v15 = v14 + (v12 + (position2 - v12) * v5 - v14) * v5
		local cframe

		if v10 == v15 then
			cframe = CFrame.new(v10)
		else
			cframe = CFrame.lookAt(v10, v15)
		end

		part:PivotTo(cframe)

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

			local clone = maid:Clone(ReplicatedStorage.Assets.PhoenixBoss.FireBallImpact)
			clone.CFrame = CFrame.new(cframe.Position) + createVector(0, 5, 0)
			clone.Parent = workspace.Runtime
			Utils.Visual:PlayEffects(clone)
			local v16 = maid:Add(ReplicatedStorage.Assets.Sounds.PhoenixBoss.FireballHit:Clone())
			v16.Parent = clone
			v16:Play()
			task.wait(2)
			TweenService:Create(part, TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
				Transparency = 1
			}):Play()
			task.wait(0.5)
			maid:Clean()
		end
	end))
	return function()
		maid:Destroy()
	end
end, { workspace })