local createVector = vector.create
local TweenService = game:GetService("TweenService")
local _ = coroutine.resume
local _ = coroutine.create
local LightningBolt3 = require(game.ReplicatedStorage.Util.LightningBolt3)
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
	TweenInfo.new(0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
	TweenInfo.new(0.45, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
	TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.In)
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

	if (workspace.CurrentCamera.CFrame.Position - p2).magnitude < 60 then
		local Effect = require(game.ReplicatedStorage.Effect)
		Effect.new("ShakeCam"):replicate({
			2.5,
			4,
			0.1,
			0.75,
			createVector(0.3, 0.3, 0.3),
			createVector(1, 1, 1)
		})
	end

	local clone = script.explosion:Clone()
	clone.Name = clone.Name
	clone.CFrame = cFrame
	clone.Parent = _WorldOrigin
	Debris:AddItem(clone, 2)

	for _, child in pairs(clone.Attachment:GetChildren()) do
		child.ZOffset += 3
		child:Emit(child:GetAttribute("EmitCount"))
	end

	local clone2 = script.Sphere:Clone()
	clone2.Name = clone2.Name
	clone2.CFrame = cFrame
	clone2.Parent = _WorldOrigin
	Debris:AddItem(clone2, 1)
	TweenService:Create(clone2, v[1], {
		Size = clone2.Size * 3.25,
		Transparency = 1
	}):Play()
	local cFrame2 = clone.CFrame * CFrame.new(0, 2, 0)
	local clone3 = script.AttachPart:Clone()
	clone3.Name = clone3.Name
	clone3.CFrame = cFrame2
	clone3.Parent = _WorldOrigin
	local cFrame3 = clone.CFrame + Vector3.new(0, p.Height, 0)
	local clone4 = script.AttachPart:Clone()
	clone4.Name = clone4.Name
	clone4.CFrame = cFrame3
	clone4.Parent = _WorldOrigin
	Debris:AddItem(clone3, 1.5)
	Debris:AddItem(clone4, 1.5)
	local curveSize = math.random(-100, 100)
	local v5 = LightningBolt3.new(clone4.Attachment, clone3.Attachment, 9)
	v5.PulseSpeed = 6.75 + math.random() * 1.25
	v5.PulseLength = 1
	v5.CurveSize0 = curveSize
	v5.CurveSize1 = -curveSize
	v5.MinRadius = 20
	v5.MaxRadius = 40
	v5.FadeLength = 0.45 + math.random() * 0.2
	v5.Thickness = 3.5 + math.random() * 1.5
	v5.Color = Color3.fromRGB(124, 255, 251):Lerp(Color3.new(1, 1, 1), math.random() * 0.3)
	Sound:Play("ElectricStrikeSpawn", clone4.Attachment.Position)
	task.wait(0.333)
	Sound:Play("ElectricStrike", clone3.Attachment.Position)
	local attachment = clone3.Attachment

	for _ = 1, 3 do
		local attachment2 = Instance.new("Attachment", clone3)
		attachment2.Position = Vector3.new(math.random(-20, 20), math.random(-20, 20), math.random(-20, 20))
		local v6 = LightningBolt3.new(attachment, attachment2, 5)
		v6.PulseSpeed = 5
		v6.PulseLength = 0.8
		v6.FadeLength = 0.35
		v6.Thickness = 2.25
		v6.Color = Color3.fromRGB(110, 255, 251)
		Debris:AddItem(attachment2, 0.5)
	end

	local lookVector = CFrame.new((cFrame * CFrame.new(0, 20, 0)).Position, p2).LookVector
	local raycastResult = workspace:Raycast(p2 - lookVector * 10, lookVector * 40, raycastParams)

	if raycastResult then
		local v6 = CFrame.new(raycastResult.Position, raycastResult.Position + raycastResult.Normal * 10) * CFrame.Angles(
			-1.5707963267948966,
			0,
			0
		)
		local cFrame4 = v6 * CFrame.Angles(0, math.random(-10, 10) / 10 * 3.141592653589793, 0)
		local clone5 = script.Scar:Clone()
		clone5.Name = clone5.Name
		clone5.CFrame = cFrame4
		clone5.Parent = _WorldOrigin

		for _, child in pairs(clone5:GetChildren()) do
			TweenService:Create(child, v[3], {
				Transparency = 1
			}):Play()
		end

		Debris:AddItem(clone5, 1.25)
		local cframe = CFrame.new(p2, p2 + raycastResult.Normal)
		local clone6 = script.dust:Clone()
		clone6.Name = clone6.Name
		clone6.CFrame = cframe
		clone6.Parent = _WorldOrigin
		clone6.Attachment.sm2.Color = ColorSequence.new(raycastResult.Instance.Color)
		clone6.Attachment.sm2:Emit(25)
		Debris:AddItem(clone6, 2)
		local cFrame5 = v6 * CFrame.Angles(0, math.random(-10, 10) / 10 * 3.141592653589793, 0)
		local clone7 = script.Shockwave:Clone()
		clone7.Name = clone7.Name
		clone7.CFrame = cFrame5
		clone7.Parent = _WorldOrigin
		Debris:AddItem(clone7, 0.5)
		TweenService:Create(clone7, v[1], {
			Size = Vector3.new(clone7.Size.X * 3.25, 0, clone7.Size.Z * 3.25),
			Transparency = 1
		}):Play()
	end
end