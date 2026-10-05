local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(game.ReplicatedStorage:WaitForChild("Effect"))
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local _ = Util.Sound
local _ = Util.MasterClock

local function CalculateCurve(p, p2)
	return 0.6666666666666666 * (p2 - p).magnitude
end

local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local _ = Util.Debris
require(ReplicatedStorage2:WaitForChild("Effect"))
local meshes = ReplicatedStorage2:WaitForChild("Assets"):WaitForChild("Meshes")
local _WorldOrigin = workspace:WaitForChild("_WorldOrigin")
local color = Color3.fromRGB(170, 0, 170)
return function(data)
	local origin = data.Origin
	local scale = data.Scale or 10
	local height = data.Height or 200

	if (origin - workspace.CurrentCamera.CFrame.p).magnitude > 500 then
		return
	end

	Util.Sound:Play("GenesisFire", origin)
	local cframe = CFrame.new(origin)
	local clone = meshes.Ring:Clone()
	clone.Color = color
	clone.Size = Vector3.new()
	clone.CFrame = cframe * CFrame.Angles(1.5707963267948966, 0, 0)
	clone.Parent = _WorldOrigin
	local tweenInfo = TweenInfo.new(0.1, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
	TweenInfo.new(0.1, Enum.EasingStyle.Sine, Enum.EasingDirection.In)
	local tween = TweenService:Create(clone, tweenInfo, {
		Size = Vector3.new(1 * scale, 1 * scale, 0.25 * scale)
	})
	local tween2 = TweenService:Create(clone, tweenInfo, {
		Size = Vector3.new(0.75 * scale, 0.75 * scale, 0.25 * scale)
	})

	for _ = 1, 2 do
		tween:Play()
		tween.Completed:Wait()
		tween2:Play()
		tween2.Completed:Wait()
	end

	tween:Play()
	local width = scale * 1.25 * height / (scale * 2.5)
	local v2 = {}

	for i = 1, 2 do
		local v3 = i == 1 and 1 or -1
		local attachment = Instance.new("Attachment")
		attachment.CFrame = cframe * CFrame.new(v3 * scale / 2 * 0.75, 0, 0) * CFrame.Angles(0, 1.5707963267948966, 0)
		attachment.Parent = workspace.Terrain
		v2[i] = attachment
	end

	local position = v2[1].Position
	local curveSize = 0.6666666666666666 * (v2[2].Position - position).magnitude
	local beam = Instance.new("Beam")
	beam.LightInfluence = 0
	beam.LightEmission = 0.5
	beam.Transparency = NumberSequence.new(0.25)
	beam.Color = ColorSequence.new(color)
	beam.CurveSize0 = curveSize
	beam.CurveSize1 = -curveSize
	beam.Attachment0 = v2[1]
	beam.Attachment1 = v2[2]
	beam.Parent = _WorldOrigin
	local tweenInfo2 = TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
	local tween3 = TweenService:Create(v2[1], tweenInfo2, {
		CFrame = cframe * CFrame.new(scale / 2 * 0.75, width / 2, 0) * CFrame.Angles(0, 1.5707963267948966, 0)
	})
	local tween4 = TweenService:Create(v2[2], tweenInfo2, {
		CFrame = cframe * CFrame.new(-scale / 2 * 0.75, width / 2, 0) * CFrame.Angles(0, 1.5707963267948966, 0)
	})
	local tween5 = TweenService:Create(beam, tweenInfo2, {
		Width0 = width,
		Width1 = width
	})
	tween3:Play()
	tween4:Play()
	tween5:Play()
	tween5.Completed:Connect(function()
		wait(0.1)
		local tweenInfo3 = TweenInfo.new(1.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
		local tween6 = TweenService:Create(v2[1], tweenInfo3, {
			CFrame = cframe * CFrame.new(0, width / 2, 0) * CFrame.Angles(0, 1.5707963267948966, 0)
		})
		local tween7 = TweenService:Create(v2[2], tweenInfo3, {
			CFrame = cframe * CFrame.new(0, width / 2, 0) * CFrame.Angles(0, 1.5707963267948966, 0)
		})
		local tween8 = TweenService:Create(beam, tweenInfo3, {
			CurveSize0 = 0,
			CurveSize1 = 0
		})
		tween6.Completed:Connect(function()
			for _, v4 in next, v2, nil do
				v4:Destroy()
			end

			beam:Destroy()
		end)
		tween6:Play()
		tween7:Play()
		tween8:Play()
	end)
	local width2 = scale * 1.25 * height / (scale * 2.5)
	local v5 = {}

	for i = 1, 2 do
		local v6 = i == 1 and 1 or -1
		local attachment = Instance.new("Attachment")
		attachment.CFrame = cframe * CFrame.new(v6 * scale / 2 * 0.75, 0, 0) * CFrame.Angles(0, -1.5707963267948966, 0)
		attachment.Parent = workspace.Terrain
		v5[i] = attachment
	end

	local position2 = v5[1].Position
	local curveSize2 = 0.6666666666666666 * (v5[2].Position - position2).magnitude
	local beam2 = Instance.new("Beam")
	beam2.LightInfluence = 0
	beam2.LightEmission = 0.5
	beam2.Transparency = NumberSequence.new(0.25)
	beam2.Color = ColorSequence.new(color)
	beam2.CurveSize0 = curveSize2
	beam2.CurveSize1 = -curveSize2
	beam2.Attachment0 = v5[1]
	beam2.Attachment1 = v5[2]
	beam2.Parent = _WorldOrigin
	local tweenInfo3 = TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
	local tween6 = TweenService:Create(v5[1], tweenInfo3, {
		CFrame = cframe * CFrame.new(scale / 2 * 0.75, width2 / 2, 0) * CFrame.Angles(0, -1.5707963267948966, 0)
	})
	local tween7 = TweenService:Create(v5[2], tweenInfo3, {
		CFrame = cframe * CFrame.new(-scale / 2 * 0.75, width2 / 2, 0) * CFrame.Angles(0, -1.5707963267948966, 0)
	})
	local tween8 = TweenService:Create(beam2, tweenInfo3, {
		Width0 = width2,
		Width1 = width2
	})
	tween6:Play()
	tween7:Play()
	tween8:Play()
	tween8.Completed:Connect(function()
		wait(0.1)
		local tweenInfo4 = TweenInfo.new(1.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
		local tween9 = TweenService:Create(v5[1], tweenInfo4, {
			CFrame = cframe * CFrame.new(0, width2 / 2, 0) * CFrame.Angles(0, -1.5707963267948966, 0)
		})
		local tween10 = TweenService:Create(v5[2], tweenInfo4, {
			CFrame = cframe * CFrame.new(0, width2 / 2, 0) * CFrame.Angles(0, -1.5707963267948966, 0)
		})
		local tween11 = TweenService:Create(beam2, tweenInfo4, {
			CurveSize0 = 0,
			CurveSize1 = 0
		})
		tween9.Completed:Connect(function()
			for _, v7 in next, v5, nil do
				v7:Destroy()
			end

			beam2:Destroy()
		end)
		tween9:Play()
		tween10:Play()
		tween11:Play()
	end)
	local tweenInfo4 = TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
	local v7 = height / (scale * 2.5)
	local clones = {}

	for i = 1, v7 do
		local clone2 = meshes.Ring:Clone()
		clone2.Size = Vector3.new()
		clone2.CFrame = cframe * CFrame.new(0, i * scale * 1.25, 0) * CFrame.Angles(1.5707963267948966, 0, 0)
		clone2.Parent = _WorldOrigin
		clones[i] = clone2
		TweenService:Create(clone2, tweenInfo4, {
			Size = Vector3.new(1 * scale, 1 * scale, 0.25 * scale)
		}):Play()
		wait(tweenInfo4.Time / v7)
	end

	wait(0.1)
	local tween9 = TweenService:Create(clone, TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
		Size = Vector3.new(0, 0, 0.25 * scale)
	})
	tween9.Completed:Connect(function()
		clone:Destroy()
	end)
	tween9:Play()

	for _, v8 in next, clones, nil do
		local tween10 = TweenService:Create(v8, tweenInfo4, {
			Size = Vector3.new(0, 0, 0.25 * scale)
		})
		local v9 = v8
		tween10.Completed:Connect(function()
			v9:Destroy()
		end)
		tween10:Play()
		wait(tweenInfo4.Time / v7)
	end
end