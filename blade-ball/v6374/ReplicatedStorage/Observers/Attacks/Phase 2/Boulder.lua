local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Observers = require(ReplicatedStorage.Packages.Observers)
local Trove = require(ReplicatedStorage.Packages.Trove)
local ServerInfo = require(ReplicatedStorage.ServerInfo)
local Utils = require(ReplicatedStorage.Common.Utils)

if not ServerInfo.isBossFightServer() then
	return nil
end

local function lerp(p, p2, p3: number)
	return p + (p2 - p) * p3
end

local function quadBezier(p, p2, p3, p4: number)
	local v = p + (p2 - p) * p4
	return v + (p2 + (p3 - p2) * p4 - v) * p4
end

return Observers.observeTag("GalaxyBossBoulder", function(folder)
	local maid = Trove.new()
	local travelTime = folder:GetAttribute("TravelTime")
	local position = folder:GetPivot().Position
	local position2 = folder:GetAttribute("Target").Position
	local v = position + (position2 - position) * 0.5 + createVector(0, 1, 0) * (position2 - position).Magnitude * 2
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

		folder:PivotTo(cframe)

		if travelTime <= total and not (maid._cleaning or v2) then
			if v3 then
				maid:Remove(v3)
				v3 = nil
			end

			v2 = true

			for _, emitter in folder:GetDescendants() do
				if emitter:IsA("ParticleEmitter") then
					emitter.Enabled = false
				end
			end

			local clone = maid:Clone(ReplicatedStorage.Assets.GalaxyBoss.BoulderHit)
			clone.CFrame = cframe + createVector(0, 5, 0)
			clone.Parent = workspace.Runtime
			Utils.Visual:PlayEffects(clone)
			task.wait(3)
			TweenService:Create(folder, TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
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