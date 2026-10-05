local createVector = vector.create
workspace:WaitForChild("_WorldOrigin")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Effect = require(game.ReplicatedStorage:WaitForChild("Effect"))
Effect.new("RingWind")
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local _ = Util.Sound
local _ = Util.MasterClock
local _WorldOrigin = workspace._WorldOrigin
local TweenService = game:GetService("TweenService")
game:GetService("RunService")
return function(data)
	local cFrame = data.CFrame
	local targetCFrame = data.TargetCFrame
	local speed = data.Speed or 220

	if (cFrame.p - workspace.CurrentCamera.CFrame.p).magnitude > 900 then
		return
	end

	local magnitude = (cFrame.p - targetCFrame.p).magnitude
	local cframe = CFrame.new(cFrame.p, targetCFrame.p)
	local _ = cframe * CFrame.new(0, 0, -magnitude)
	local clone = script.SpikeyTrident:Clone()
	clone:SetPrimaryPartCFrame(cframe)
	clone.Parent = _WorldOrigin
	local attachment = Instance.new("Attachment", workspace.Terrain)
	attachment.CFrame = cFrame
	local attachment1 = data.Beam.Attachment1
	data.Beam.Attachment1 = attachment
	local v = math.max(magnitude / speed, 0.05)
	local lastTime = tick()
	local count = 0

	while tick() - lastTime < v do
		local v2 = math.clamp((tick() - lastTime) / v, 0.001, 1)
		local lerped = cFrame:Lerp(targetCFrame, v2)
		attachment.CFrame = lerped

		if count >= 5 then
			break
		end

		if not data.Ref then
			count += 1
		end

		if data.Ref and not data.Ref:IsDescendantOf(workspace) then
			count += 1
		end

		clone:SetPrimaryPartCFrame(lerped * CFrame.Angles(-1.5707963267948966, 0, 0))
		local clone2 = script.MochiSwirl:Clone()
		clone2:SetPrimaryPartCFrame(lerped * CFrame.Angles(1.5707963267948966, math.random() * 3.141592653589793 * 2, 0))
		clone2.Parent = _WorldOrigin

		for _, child in pairs(clone2:GetChildren()) do
			if child.Name == "Color1" then
				if math.random() < 0.25 then
					child:Destroy()
				else
					child.Transparency = math.random() * 0.7
					local v3 = (2 + math.random() * 2) * 0.8
					local tween = TweenService:Create(
						child,
						TweenInfo.new(
							0.1 + child.Size.Magnitude * 0.005 + math.random() * 0.1,
							Enum.EasingStyle.Circular
						),
						{
							Size = child.Size * Vector3.new(v3, 2, v3),
							CFrame = child.CFrame * CFrame.new(0, math.random(2, 10), 0),
							Transparency = 1
						}
					)
					local v4 = child
					tween.Completed:Connect(function()
						v4:Destroy()
					end)
					tween:Play()
				end
			elseif child.Name == "Color2" then
				if math.random() < 0.5 and v2 > 0.1 then
					local v3 = 50 + math.random() * 25
					child.Size *= 1 + math.random() * 3
					local tween = TweenService:Create(child, TweenInfo.new(0.2 + math.random() * 0.2), {
						Size = child.Size * Vector3.new(0, v3, 0)
					})
					local v4 = child
					tween.Completed:Connect(function()
						v4:Destroy()
					end)
					tween:Play()
				else
					local v3 = 2.5 + math.random() * 2.5
					local v4 = v3 + math.random() * 2.5
					local tween = TweenService:Create(child, TweenInfo.new(0.05 + math.random() * 0.1), {
						Size = child.Size * Vector3.new(v3, v4, v3)
					})
					local v5 = child
					tween.Completed:Connect(function()
						v5:Destroy()
					end)
					tween:Play()
				end
			elseif child.Name == "FaintWind" then
				local tween = TweenService:Create(child, TweenInfo.new(0.1 + math.random() * 0.1), {
					Size = createVector(0, 100, 0)
				})
				local v3 = child
				tween.Completed:Connect(function()
					v3:Destroy()
				end)
				tween:Play()
			end
		end

		task.delay(1, function()
			clone2:Destroy()
		end)
		task.wait()
	end

	if data.Real and data.Real:IsDescendantOf(workspace) then
		data.Beam.Attachment1 = attachment1
		local v2 = 1 - (tick() - lastTime)

		if v2 > 0 then
			TweenService:Create(data.Beam, TweenInfo.new(v2), {
				Width0 = 0,
				Width1 = 0
			}):Play()
		end

		while data.Real:IsDescendantOf(workspace) do
			clone:SetPrimaryPartCFrame(data.Real.CFrame * CFrame.new(0, -4, 0))
			task.wait()
		end
	end

	attachment:Destroy()
	clone:Destroy()
end