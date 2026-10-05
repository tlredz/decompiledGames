local _WorldOrigin = workspace:WaitForChild("_WorldOrigin")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(game.ReplicatedStorage:WaitForChild("Effect"))
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local _ = Util.Sound
local masterClock = Util.MasterClock
local _ = workspace._WorldOrigin
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local function lerp(p, p2, p3)
	return p + (p2 - p) * p3
end

return function(data)
	local cFrame = data.CFrame

	if (cFrame.Position - workspace.CurrentCamera.CFrame.p).magnitude > 600 then
		return
	end

	local timestamp = data.Timestamp
	local distance = data.Distance
	local time = data.Time
	local positionObject = data.PositionObject
	local noise = data.Noise

	if positionObject then
		if noise then
			Util.Sound:Play("shot", cFrame.Position, nil, 2, 0.2)
		end

		local v = false
		local changedConnection = nil
		changedConnection = positionObject.Changed:Connect(function(p)
			v = p or nil
			changedConnection:Disconnect()
		end)
		local v2 = masterClock:GetTime() - timestamp
		local v3 = math.max(0.01, time - v2)
		local clone = script.LightSword:Clone()
		Util.Debris:AddItem(clone, v3 + 1)
		clone.CFrame = cFrame
		clone.Trail.WidthScale = NumberSequence.new(2)
		clone.Parent = _WorldOrigin
		local spawn = clone.Spawn
		Util.Debris:AddItem(spawn, 1)
		spawn.Parent = workspace.Terrain
		spawn.Position = cFrame.Position

		for _, child in pairs(spawn:GetChildren()) do
			Util.Misc.ScaleParticle(child, 1.25)
			local emitCount = child:GetAttribute("EmitCount")

			if emitCount then
				child:Emit(emitCount)
			end
		end

		local lastTime = tick()
		local v4 = cFrame
		local v5 = {
			Time = 0.2,
			Amount = 0
		}

		while true do
			local v6 = math.min(1, (tick() - lastTime + v2) / time)
			local v7 = math.clamp((tick() - lastTime) / v5.Time, 0, 1)
			v5.Amount = 0 + (v6 - 0) * v7
			local lerped = cFrame:Lerp(cFrame * CFrame.new(0, 0, -distance), v5.Amount)
			clone.CFrame = lerped * CFrame.Angles(3.141592653589793, 0, 0)
			local magnitude = (v4.Position - lerped.Position).Magnitude
			local ray, v8, v9 = Util.Ray(
				v4.p,
				v4.lookVector.Unit * magnitude,
				{ workspace.Characters, workspace.Enemies },
				false
			)

			if v then
				clone.Position = positionObject.Value
				break
			end

			if ray or v6 == 1 then
				clone.CFrame = CFrame.new(v8) + v9 * 1.5
				break
			else
				RunService.RenderStepped:Wait()
				v4 = lerped
			end
		end

		if noise then
			Util.Sound:Play("LightBoomShort", v4.Position)
		end

		if clone then
			TweenService:Create(clone.Light, TweenInfo.new(0.35), {
				Range = 0,
				Brightness = 0
			}):Play()
			clone.Transparency = 1
			clone.Trail.Enabled = false

			for _, child in pairs(clone.Hilt:GetChildren()) do
				child.Enabled = false
			end

			for _, child in pairs(clone.Explode:GetChildren()) do
				Util.Misc.ScaleParticle(child, 1.25)
				local emitCount = child:GetAttribute("EmitCount")

				if emitCount then
					child:Emit(emitCount)
				end
			end

			task.delay(1, function()
				if clone then
					clone:Destroy()
				end
			end)
		end

		if changedConnection then
			changedConnection:Disconnect()
		end

		if positionObject then
			positionObject:Destroy()
		end
	end
end