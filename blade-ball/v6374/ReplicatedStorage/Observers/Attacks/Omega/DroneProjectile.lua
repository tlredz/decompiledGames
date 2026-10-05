local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Observers = require(ReplicatedStorage.Packages.Observers)
local Trove = require(ReplicatedStorage.Packages.Trove)
local ServerInfo = require(ReplicatedStorage.ServerInfo)
local Utils = require(ReplicatedStorage.Common.Utils)

if ServerInfo.isBossFightServer() or ServerInfo.isDungeonsMatchServer() then
	local function lerp(p, p2, p3: number)
		return p + (p2 - p) * p3
	end

	local function quadBezier(p, p2, p3, p4: number)
		local v = p + (p2 - p) * p4
		return v + (p2 + (p3 - p2) * p4 - v) * p4
	end

	return Observers.observeTag("DroneProjectile", function(folder)
		local maid = Trove.new()
		local travelTime = folder:GetAttribute("TravelTime")
		local position = folder:GetPivot().Position
		local position2 = folder:GetAttribute("Target").Position
		local v = position2 + createVector(0, -15, 0)
		local v2 = position + (v - position) * 0.5 + createVector(0, 1, 0) * (v - position).Magnitude * 0.15
		local total = 0
		local v3 = false
		local v4 = nil
		v4 = maid:Add(RunService.PostSimulation:Connect(function(dt: number)
			local v5 = total / travelTime

			if not v3 then
				total += dt
			end

			local v6 = total / travelTime
			local position3 = position
			local v8 = v2
			local v10 = position3 + (v8 - position3) * v5
			local v11 = v10 + (v8 + (v - v8) * v5 - v10) * v5
			local position4 = position
			local v13 = v2
			local v15 = position4 + (v13 - position4) * v6
			local v16 = v15 + (v13 + (v - v13) * v6 - v15) * v6
			local v17

			if v11 == v16 then
				v17 = CFrame.new(v11)
			else
				v17 = CFrame.lookAt(v11, v16)
			end

			folder:PivotTo(v17)

			if travelTime <= total and not (maid._cleaning or v3) then
				if v4 then
					maid:Remove(v4)
					v4 = nil
				end

				v3 = true
				local clone = maid:Clone(ReplicatedStorage.Assets.PhoenixBoss.FireBallImpact)
				clone.CFrame = CFrame.new(position2) + createVector(0, 5, 0)
				clone.Parent = workspace.Runtime
				Utils.Visual:PlayEffects(clone)
				local v18 = maid:Add(ReplicatedStorage.Assets.Sounds.PhoenixBoss.FireballHit:Clone())
				v18.Parent = clone
				v18:Play()

				for _, descendant in folder:GetDescendants() do
					if descendant:IsA("BasePart") then
						descendant.Transparency = 1
					elseif descendant:IsA("ParticleEmitter") or descendant:IsA("Trail") or descendant:IsA("Beam") or descendant:IsA("BillboardGui") then
						descendant.Enabled = false
					end
				end

				task.wait(3.5)
				maid:Clean()
			end
		end))
		return function()
			maid:Destroy()
		end
	end, { workspace })
else
	return nil
end