local createVector = vector.create
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

local function doEmit(explode)
	for _, child in pairs(explode:GetChildren()) do
		Util.Misc.ScaleParticle(child, 1.25)
		child:Emit(child:GetAttribute("EmitCount") or 1)
	end
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

	if data.Noise then
		Util.Sound:Play("DiscFire2", cFrame.Position, nil, 1.2, 0.5)
	end

	local v = false
	local changedConnection = nil

	if positionObject then
		changedConnection = positionObject.Changed:Connect(function(p)
			v = p or nil
			changedConnection:Disconnect()
		end)
	end

	local v2 = masterClock:GetTime() - timestamp
	local v3 = math.max(0.01, time - v2)
	local clone = script.Dart:Clone()
	Util.Debris:AddItem(clone, v3 + 1)
	clone:SetPrimaryPartCFrame(cFrame * CFrame.Angles(0, 1.5707963267948966, 0))
	clone.Parent = _WorldOrigin
	local children = {}
	local v4 = {
		Time = 0.2,
		Amount = 0
	}

	for _, child in pairs(clone:GetChildren()) do
		if child.Name == "Burst" then
			table.insert(children, child)
		end
	end

	local tweenInfo = TweenInfo.new(0.6, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0)
	local lastTime = tick()
	local lastTime2 = tick()
	local v5 = cFrame

	while true do
		local v6 = math.min(1, (tick() - lastTime + v2) / time)
		local v7 = math.clamp((tick() - lastTime) / v4.Time, 0, 1)
		v4.Amount = 0 + (v6 - 0) * v7
		local lerped = cFrame:Lerp(cFrame * CFrame.new(0, 0, -distance), v4.Amount)
		clone:SetPrimaryPartCFrame(lerped * CFrame.Angles(1.5707963267948966, 0, 0))
		local magnitude = (v5.Position - lerped.Position).Magnitude
		local v8

		if tick() - lastTime2 > 0.2 then
			local clone2 = clone.Wind1:Clone()
			local clone3 = clone.Wind2:Clone()
			Util.Debris:AddItem(clone2, 2)
			Util.Debris:AddItem(clone3, 2)
			local decal = clone2.Decal
			local decal2 = clone3.Decal
			decal.Transparency = 0
			decal2.Transparency = 0
			clone2.Parent = _WorldOrigin
			clone3.Parent = _WorldOrigin
			v8 = v5
			v5 = lerped

			for _, v10 in pairs({ clone2, clone3 }) do
				local tween = TweenService:Create(v10, tweenInfo, {
					Position = v10.Position + createVector(0, 10, 0),
					Orientation = createVector(0, 1.5707964, 0)
				})
				local tween2 = TweenService:Create(v10.Decal, tweenInfo, {
					Transparency = 1
				})
				local tween3 = TweenService:Create(v10.Mesh, tweenInfo, {
					Scale = v10.Name == "Wind1" and createVector(42, 16, 42) or createVector(-42, 16, 42)
				})
				tween:Play()
				tween2:Play()
				tween3:Play()
				local v11 = clone2
				local v12 = clone3
				tween2.Completed:Connect(function()
					for k, v14 in pairs({ v11, v12 }) do
						if v14 then
							v14:Destroy()
						end
					end
				end)
			end

			lastTime2 = tick()
		else
			v8 = v5
			v5 = lerped
		end

		if #children > 0 then
			for _, v9 in pairs(children) do
				if v9 == nil then
					continue
				end

				local v10 = v9.CFrame - v9.CFrame.p
				v9.CFrame = CFrame.new(v5.p) * v10 * CFrame.Angles(0, 0.5235987755982988, 0)
			end
		end

		local ray, _, _ = Util.Ray(
			v8.p,
			v8.lookVector.Unit * magnitude,
			{ workspace.Characters, workspace.Enemies },
			false
		)

		if v then
			clone.Core.Position = positionObject.Value
		elseif not ray and v6 ~= 1 then
			RunService.RenderStepped:Wait()
			continue
		end

		Util.Sound:Play("LightBoomShort", v8.Position, nil, math.random(15, 20) / 10, 1)

		if clone then
			for _, child in pairs(clone:GetChildren()) do
				if child.Name == "Core" then
					doEmit(child.Explode)
				else
					child:Destroy()
				end
			end

			task.delay(2, function()
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

		break
	end
end