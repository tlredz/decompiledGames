workspace:WaitForChild("_WorldOrigin")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(game.ReplicatedStorage:WaitForChild("Effect"))
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local sound = Util.Sound
local _ = Util.MasterClock
local WingsOld = require(game.ReplicatedStorage.Util.WingsOld)
local _ = workspace._WorldOrigin
game:GetService("TweenService")
local RunService = game:GetService("RunService")
local v = {}

local function lerpNumber(p, p2, p3)
	return p + (p2 - p) * p3
end

return function(data)
	local HRP = data.HRP
	local enabled = data.Enabled
	local color = data.Color

	if enabled then
		if (workspace.CurrentCamera.CFrame.p - HRP.Position).Magnitude > 1500 then
			return
		end

		if v[HRP] then
			v[HRP] = nil
			task.wait(0.1)
		end

		sound:Play("SpinWoosh2Weak", HRP)
		local upperTorso = HRP.Parent and HRP.Parent:FindFirstChild("UpperTorso")

		if upperTorso then
			local wings = WingsOld.Attach({
				Root = upperTorso,
				Color = color,
				Size = 0
			}):Activate()
			local v3 = {
				Wings = wings,
				Angle = 0
			}
			v[HRP] = v3
			local lastTime = tick()

			while tick() - lastTime < 0.2 do
				local v4 = (tick() - lastTime) / 0.2
				wings.Size = 3.5 * v4
				wings:Update(0, 1 - v4)
				RunService.RenderStepped:Wait()
			end

			wings.Size = 3.5
			wings:Update(0, 0)
			local v4 = 0.016666666666666666
			local v5 = 1

			while v[HRP] do
				if HRP:IsDescendantOf(workspace) then
					if HRP.Velocity.Y > -10 then
						local v6 = math.clamp((10 + HRP.Velocity.Y) / 2.5, 5, 40)
						v3.Angle += v4 * 0.20943951023931956 * v5 * v6

						if v3.Angle >= 1.5707963267948966 then
							v5 = -1
						elseif v3.Angle <= 0.35 then
							Util.Sound:Play("WingFlap", upperTorso)
							v5 = 1
						end

						v3.Angle = math.clamp(v3.Angle, 0.35, 1.5707963267948966)
					else
						local angle = v3.Angle
						local v6 = v4 * 2
						v3.Angle = angle + (1.5707963267948966 - angle) * v6
					end

					wings:Update(v3.Angle)
					v4 = RunService.RenderStepped:Wait()
				else
					v[HRP] = nil
					pcall(function()
						wings:Destroy()
					end)
					return
				end
			end
		end
	elseif v[HRP] then
		sound:Play("SpinWooshWeak", HRP)
		local angle = v[HRP].Angle
		local wings = v[HRP].Wings
		v[HRP] = nil
		local lastTime = tick()

		while tick() - lastTime < 0.25 do
			wings.Size = 3.5 * (1 - (tick() - lastTime) / 0.25)
			wings:Update(angle)
			RunService.RenderStepped:Wait()
		end

		wings:Destroy()
	end
end