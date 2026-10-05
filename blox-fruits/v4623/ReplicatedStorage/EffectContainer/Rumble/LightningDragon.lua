local createVector = vector.create
local TweenService = game:GetService("TweenService")
local _ = coroutine.resume
local _ = coroutine.create
local LightningBolt3 = require(game.ReplicatedStorage.Util.LightningBolt3)
require(game.ReplicatedStorage.Util.ScaleParticle)
local _WorldOrigin = workspace._WorldOrigin
local map = workspace.Map
local Debris = require(game.ReplicatedStorage.Util.Debris)
local Sound = require(game.ReplicatedStorage.Util.Sound)

local function scaleNumberRange(p, p2)
	return NumberRange.new(p.Min * p2, p.Max * p2)
end

local function scaleAcceleration(data, p)
	return (Vector3.new(data.X * p, data.Y * p, data.Z * p))
end

local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Whitelist
raycastParams.FilterDescendantsInstances = { map }
local v = {
	TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
	TweenInfo.new(0.75, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
	TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.In),
	TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
}

local function createEffect(cFrame, instance, p, p2)
	local clone = instance:Clone()
	clone.Name = p or clone.Name
	clone.CFrame = cFrame
	clone.Parent = p2 or _WorldOrigin
	return clone
end

return function(p)
	local cFrame = p.CFrame
	local p2 = cFrame.p

	if (workspace.CurrentCamera.CFrame.Position - p2).magnitude > 700 then
		return
	end

	if (workspace.CurrentCamera.CFrame.Position - p2).magnitude < 90 then
		local Effect = require(game.ReplicatedStorage.Effect)
		Effect.new("ShakeCam"):replicate({
			3.5,
			8,
			0,
			1.5,
			createVector(0.25, 0.25, 0.25),
			createVector(1, 1, 1)
		})
	end

	Sound:Play("ElectricDragonStrike", p2)
	local clone = script.explosion:Clone()
	clone.Name = clone.Name
	clone.CFrame = cFrame
	clone.Parent = _WorldOrigin
	Debris:AddItem(clone, 2)

	for _, child in pairs(clone.Attachment:GetChildren()) do
		child.ZOffset += 3

		if child.Name == "Wind" then
			local lifetime = child.Lifetime
			child.Lifetime = NumberRange.new(lifetime.Min * 0.9, lifetime.Max * 0.9)
		else
			local lifetime = child.Lifetime
			child.Lifetime = NumberRange.new(lifetime.Min * 1.2, lifetime.Max * 1.2)
		end

		child:Emit(child:GetAttribute("EmitCount"))
	end

	local cFrame2 = clone.CFrame * CFrame.new(0, 3, 0)
	local clone2 = script.Lightning:Clone()
	clone2.Name = clone2.Name
	clone2.CFrame = cFrame2
	clone2.Parent = _WorldOrigin
	task.delay(0.4, function()
		for _, child in pairs(clone2:GetChildren()) do
			child.Enabled = false
		end

		Debris:AddItem(clone2, 0.1)
	end)

	if (workspace.CurrentCamera.CFrame.Position - p2).magnitude < 90 then
		local clone3 = script.ColorCorrection:Clone()
		clone3.Parent = game.Lighting
		Debris:AddItem(clone3, 1)
		TweenService:Create(clone3, v[2], {
			Brightness = 0,
			TintColor = Color3.new(1, 1, 1)
		}):Play()
	end

	local cFrame3 = clone.CFrame * CFrame.new(0, 2, 0)
	local clone3 = script.AttachPart:Clone()
	clone3.Name = clone3.Name
	clone3.CFrame = cFrame3
	clone3.Parent = _WorldOrigin
	Debris:AddItem(clone3, 1.5)
	local attachment = clone3.Attachment

	for _ = 1, 11 do
		local attachment2 = Instance.new("Attachment", clone3)
		attachment2.Position = Vector3.new(math.random(-50, 50), math.random(-50, 50), math.random(-50, 50))
		local v4 = LightningBolt3.new(attachment, attachment2, 7)
		v4.PulseSpeed = 4
		v4.PulseLength = 1
		v4.FadeLength = 0.65
		v4.Thickness = 4.25
		v4.Color = Color3.fromRGB(115, 223, 255)
		Debris:AddItem(attachment2, 1)
	end

	local _ = cFrame.LookVector
	local raycastResult = workspace:Raycast(p2 + createVector(0, 1, 0), createVector(0, -10, 0), raycastParams)

	if raycastResult then
		local v4 = CFrame.new(raycastResult.Position, raycastResult.Position + raycastResult.Normal * 10) * CFrame.Angles(
			-1.5707963267948966,
			0,
			0
		)
		local cFrame4 = v4 * CFrame.Angles(0, math.random(-10, 10) / 10 * 3.141592653589793, 0)
		local clone4 = script.Scar:Clone()
		clone4.Name = clone4.Name
		clone4.CFrame = cFrame4
		clone4.Parent = _WorldOrigin
		TweenService:Create(clone4, v[4], {
			Size = clone4.Size * 1.25
		}):Play()

		for _, child in pairs(clone4:GetChildren()) do
			TweenService:Create(child, v[3], {
				Transparency = 1
			}):Play()
		end

		Debris:AddItem(clone4, 1.25)
		local cframe = CFrame.new(p2, p2 + raycastResult.Normal)
		local clone5 = script.dust:Clone()
		clone5.Name = clone5.Name
		clone5.CFrame = cframe
		clone5.Parent = _WorldOrigin
		clone5.Attachment.sm2.Color = ColorSequence.new(raycastResult.Instance.Color)
		clone5.Attachment.sm2:Emit(45)
		Debris:AddItem(clone5, 2)

		for i = 1, 2 do
			local cFrame5 = v4 * CFrame.Angles(0, math.random(-10, 10) / 10 * 3.141592653589793, 0)
			local clone6 = script.Shockwave:Clone()
			clone6.Name = clone6.Name
			clone6.CFrame = cFrame5
			clone6.Parent = _WorldOrigin
			Debris:AddItem(clone6, 0.5)

			if i == 1 then
				TweenService:Create(clone6, v[1], {
					CFrame = clone6.CFrame * CFrame.new(0, 37, 0),
					Size = Vector3.new(clone6.Size.X * 4.2, 0, clone6.Size.Z * 4.2),
					Transparency = 1
				}):Play()
			else
				TweenService:Create(clone6, v[1], {
					CFrame = clone6.CFrame * CFrame.new(0, 21.142857142857142, 0),
					Size = Vector3.new(clone6.Size.X * 5, 0, clone6.Size.Z * 5),
					Transparency = 1
				}):Play()
			end
		end
	end
end