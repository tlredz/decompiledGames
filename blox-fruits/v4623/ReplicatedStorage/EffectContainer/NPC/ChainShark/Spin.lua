local _WorldOrigin = workspace:WaitForChild("_WorldOrigin")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("RunService")
require(ReplicatedStorage:WaitForChild("Effect"))
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local TweenService = game:GetService("TweenService")
local _ = Util.Sound
local _ = Util.MasterClock
local debris = Util.Debris
local SharkPalettes = require(ReplicatedStorage.EffectContainer.NPC.ChainShark.SharkPalettes)

local function SpinSlash(cFrame, p, p2, duration, p3, slash)
	local clone = script.SpinSlash:Clone()
	debris:AddItem(clone, 5)
	clone.CFrame = cFrame * CFrame.Angles(math.rad((math.random(-0, 0))), p3, (math.rad((math.random(-0, 0)))))
	clone.Parent = _WorldOrigin
	local v = {
		Beam = ColorSequence.new(slash[1]),
		Beam2 = ColorSequence.new(slash[2]),
		Beam3 = ColorSequence.new({
			ColorSequenceKeypoint.new(0, slash[4]),
			ColorSequenceKeypoint.new(0.587, slash[5]),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 0, 0))
		}),
		Beam5 = ColorSequence.new(slash[3]),
		Beam6 = ColorSequence.new({
			ColorSequenceKeypoint.new(0, slash[2]),
			ColorSequenceKeypoint.new(0.513, slash[6]),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 0, 0))
		}),
		Beam7 = ColorSequence.new({
			ColorSequenceKeypoint.new(0, slash[2]),
			ColorSequenceKeypoint.new(0.513, slash[5]),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 0, 0))
		})
	}

	for _, descendant in pairs(clone:GetDescendants()) do
		if descendant:IsA("Beam") then
			if v[descendant.Name] then
				descendant.Color = v[descendant.Name]
			end

			local v2 = descendant
			task.spawn(function()
				v2.CurveSize0 *= p
				v2.CurveSize1 *= p
				v2.Width0 *= p / 1
				v2.Width1 *= p / 1
				local tween = TweenService:Create(
					v2,
					TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
					{
						CurveSize0 = v2.CurveSize0 * p2,
						CurveSize1 = v2.CurveSize1 * p2,
						Width0 = v2.Width0 * p2,
						Width1 = v2.Width1 * p2
					}
				)
				tween:Play()
				tween.Completed:Wait()
				local endDelay = v2:GetAttribute("EndDelay")
				local tween2 = TweenService:Create(
					v2,
					TweenInfo.new(endDelay, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
					{
						Width0 = 0,
						Width1 = 0
					}
				)
				tween2:Play()
				tween2.Completed:Wait()
				v2:Destroy()
			end)
		elseif descendant:IsA("Attachment") then
			descendant.Position = Vector3.new(
				descendant.Position.X * p,
				descendant.Position.Y * p,
				descendant.Position.Z * p
			)
			TweenService:Create(descendant, TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				Position = Vector3.new(
					descendant.Position.X * p2,
					descendant.Position.Y * p2,
					descendant.Position.Z * p2
				)
			}):Play()
		end
	end

	task.spawn(function()
		local tween = TweenService:Create(clone, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
			CFrame = clone.CFrame * CFrame.Angles(0, 2.0943951023931953, 0)
		})
		tween:Play()
		tween.Completed:Wait()
		local tween2 = TweenService:Create(clone, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
			CFrame = clone.CFrame * CFrame.Angles(0, 2.0943951023931953, 0)
		})
		tween2:Play()
		tween2.Completed:Wait()
		TweenService:Create(clone, TweenInfo.new(3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
			CFrame = clone.CFrame * CFrame.Angles(0, 2.0943951023931953, 0)
		}):Play()
	end)
end

local function SpinSlash2(cFrame, p, p2, p3, slash)
	local clone = script.SpinSlash3:Clone()
	debris:AddItem(clone, 5)
	clone.CFrame = cFrame * CFrame.Angles(0, math.rad((math.random(-180, 180))), 0)
	clone.Parent = _WorldOrigin
	local v = {
		Beam = ColorSequence.new(slash[1]),
		Beam2 = ColorSequence.new(slash[2]),
		Beam3 = ColorSequence.new({
			ColorSequenceKeypoint.new(0, slash[4]),
			ColorSequenceKeypoint.new(0.587, slash[5]),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 0, 0))
		}),
		Beam5 = ColorSequence.new(slash[3]),
		Beam6 = ColorSequence.new({
			ColorSequenceKeypoint.new(0, slash[2]),
			ColorSequenceKeypoint.new(0.513, slash[6]),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 0, 0))
		}),
		Beam7 = ColorSequence.new({
			ColorSequenceKeypoint.new(0, slash[2]),
			ColorSequenceKeypoint.new(0.513, slash[5]),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 0, 0))
		})
	}

	for _, descendant in pairs(clone:GetDescendants()) do
		if descendant:IsA("Beam") then
			if v[descendant.Name] then
				descendant.Color = v[descendant.Name]
			end

			local v2 = descendant
			task.spawn(function()
				v2.CurveSize0 = v2.CurveSize0 * p / 2
				v2.CurveSize1 = v2.CurveSize1 * p / 2
				v2.Width0 *= p / 2
				v2.Width1 *= p / 2
				local tween = TweenService:Create(
					v2,
					TweenInfo.new(p3 * 2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
					{
						CurveSize0 = v2.CurveSize0 * p2,
						CurveSize1 = v2.CurveSize1 * p2,
						Width0 = v2.Width0 * p2,
						Width1 = v2.Width1 * p2
					}
				)
				tween:Play()
				tween.Completed:Wait()
				local endDelay = v2:GetAttribute("EndDelay")
				local tween2 = TweenService:Create(
					v2,
					TweenInfo.new(endDelay / 2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
					{
						Width0 = 0,
						Width1 = 0
					}
				)
				tween2:Play()
				tween2.Completed:Wait()
				v2:Destroy()
			end)
		elseif descendant:IsA("Attachment") then
			descendant.Position = Vector3.new(
				descendant.Position.X * p / 2,
				descendant.Position.Y * p / 2,
				descendant.Position.Z * p / 2
			)
			TweenService:Create(descendant, TweenInfo.new(p3 * 2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				Position = Vector3.new(
					descendant.Position.X * p2,
					descendant.Position.Y * p2,
					descendant.Position.Z * p2
				)
			}):Play()
		end
	end

	task.spawn(function()
		local tween = TweenService:Create(clone, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
			CFrame = clone.CFrame * CFrame.new(0, 1, 0) * CFrame.Angles(0, 2.0943951023931953, 0)
		})
		tween:Play()
		tween.Completed:Wait()
		local tween2 = TweenService:Create(clone, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
			CFrame = clone.CFrame * CFrame.new(0, 1.5, 0) * CFrame.Angles(0, 2.0943951023931953, 0)
		})
		tween2:Play()
		tween2.Completed:Wait()
		local tween3 = TweenService:Create(clone, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
			CFrame = clone.CFrame * CFrame.new(0, 1, 0) * CFrame.Angles(0, 2.0943951023931953, 0)
		})
		tween3:Play()
		tween3.Completed:Wait()
		local tween4 = TweenService:Create(clone, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
			CFrame = clone.CFrame * CFrame.new(0, 1.5, 0) * CFrame.Angles(0, 2.0943951023931953, 0)
		})
		tween4:Play()
		tween4.Completed:Wait()
		TweenService:Create(clone, TweenInfo.new(3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
			CFrame = clone.CFrame * CFrame.new(0, 7, 0) * CFrame.Angles(0, 2.0943951023931953, 0)
		}):Play()
	end)
end

return function(data)
	local cFrame = data.CFrame
	local super = data.Super
	local scale = data.Scale or 1
	local colorSet = data.ColorSet or 1
	local v = scale * 0.6
	local v2 = v < 1 and 1 or v

	if (workspace.CurrentCamera.CFrame.Position - cFrame.Position).Magnitude > 1000 then
		return
	end

	local slash = SharkPalettes[colorSet].Slash

	if super then
		Util.Sound:Play("QuakePull", cFrame.Position, nil, 1.8, 0.55)
		local parent = Util.Sound:Play("NewDarkness3", cFrame.Position, nil, 1.8, 0.85)
		local chorusSoundEffect = Instance.new("ChorusSoundEffect")
		chorusSoundEffect.Parent = parent
		chorusSoundEffect.Mix = 0.48
		chorusSoundEffect.Depth = 0.35
		SpinSlash(cFrame, 1 * v2, 1.5 * v2, 0.15, 5, slash)
		SpinSlash(cFrame, 1.4 * v2, 1.8 * v2, 0.2, 10, slash)
		SpinSlash2(cFrame, 2 * v2, 4.5 * v2, 0.25, slash)
	else
		Util.Sound:Play("QuakePull", cFrame.Position, nil, 2, 0.65)
		Util.Sound:Play("Lazy.Slice", cFrame.Position, nil, 0.9, 0.8)
		SpinSlash(cFrame, 1 * v2, 1.5 * v2, 0.15, 5, slash)
		SpinSlash(cFrame, 1.4 * v2, 2.8 * v2, 0.2, 10, slash)
		SpinSlash2(cFrame, 3 * v2, 3.8 * v2, 0.25, slash)
	end
end