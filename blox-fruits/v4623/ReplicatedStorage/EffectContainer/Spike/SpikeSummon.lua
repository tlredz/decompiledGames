local TweenService = game:GetService("TweenService")
local _ = coroutine.resume
local _ = coroutine.create
local MeshRockModule = require(game.ReplicatedStorage.Util.MeshRockModule)
local Debris = require(game.ReplicatedStorage.Util.Debris)
local Sound = require(game.ReplicatedStorage.Util.Sound)
local _WorldOrigin = workspace._WorldOrigin
local map = workspace.Map

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
	TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
	TweenInfo.new(0.35, Enum.EasingStyle.Sine, Enum.EasingDirection.In),
	TweenInfo.new(0.35, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
	TweenInfo.new(0.75, Enum.EasingStyle.Sine, Enum.EasingDirection.In)
}

local function createEffect(cFrame, instance, p, p2)
	local clone = instance:Clone()
	clone.Name = p or clone.Name
	clone.CFrame = cFrame
	clone.Parent = p2 or _WorldOrigin
	return clone
end

return function(player)
	local character = player.Character
	local _ = character.Humanoid
	local humanoidRootPart = character.HumanoidRootPart
	local position = player.Position
	local normal = player.Normal
	local scale = player.Scale
	local hit = player.Hit

	if (position - humanoidRootPart.Position).magnitude > 600 then
		return
	end

	local function createSpike(position2, normal2)
		Sound:Play("SpikeSummon", position2)
		local cFrame2 = CFrame.new(position2, position2 + normal2) * CFrame.Angles(-1.5707963267948966, 0, 0)
		local clone = script.Spike:Clone()
		clone.Name = clone.Name
		clone.CFrame = cFrame2
		clone.Parent = _WorldOrigin
		TweenService:Create(clone, v[1], {
			Size = clone.Size * 12.5 * scale,
			CFrame = clone.CFrame * CFrame.new(0, 15 * scale, 0)
		}):Play()
		local cFrame = clone.CFrame
		local clone2 = script.eff:Clone()
		clone2.Name = clone2.Name
		clone2.CFrame = cFrame
		clone2.Parent = _WorldOrigin

		for _, child in pairs(clone2.Spawn:GetChildren()) do
			if child.Name == "rocks" or child.Name == "sm2" then
				if hit then
					child.Color = ColorSequence.new(hit.Color)
					child:Emit(child:GetAttribute("EmitCount"))
				end
			else
				child:Emit(child:GetAttribute("EmitCount"))
			end
		end

		Debris:AddItem(clone2, 1)
		local cFrame3 = clone2.CFrame * CFrame.new(0, 0.75 * scale, 0)
		local clone3 = script.Circle:Clone()
		clone3.Name = clone3.Name
		clone3.CFrame = cFrame3
		clone3.Parent = _WorldOrigin
		local tween = TweenService:Create(clone3, v[3], {
			Size = Vector3.new(clone3.Size.X * 4 * scale, clone3.Size.Y * 2 * scale, clone3.Size.Z * 4 * scale),
			Transparency = 1,
			CFrame = clone3.CFrame * CFrame.Angles(0, 6.28, 0)
		})
		tween.Completed:Connect(function()
			clone3:Destroy()
		end)
		tween:Play()
		local clone4

		if hit then
			local _ = CFrame.new(position2, position2 + normal2 * 10) * CFrame.Angles(-1.5707963267948966, 0, 0)
			local cFrame4 = clone.CFrame * CFrame.new(0, -0.5, 0)
			clone4 = script.Scar:Clone()
			clone4.Name = clone4.Name
			clone4.CFrame = cFrame4
			clone4.Parent = _WorldOrigin
			clone4.Size *= 1.35 * scale
		else
			clone4 = nil
		end

		local v4 = 10 * scale < 3 and 0.3 or scale
		MeshRockModule({
			Cframe = CFrame.new(clone.Position),
			Amount = 10 * v4 or 1,
			Iteration = 12 * scale,
			Max = 3.35 * scale,
			FirstDuration = 0.1,
			RocksLength = 1.65 * scale
		})
		task.delay(1.25 * scale, function()
			if clone4 ~= nil then
				TweenService:Create(clone4.Decal, v[4], {
					Transparency = 1
				}):Play()
				Debris:AddItem(clone4, 1.26)
			end

			TweenService:Create(clone, v[2], {
				Size = clone.Size * 0,
				CFrame = clone.CFrame * CFrame.new(0, -15 * scale, 0)
			}):Play()
			Debris:AddItem(clone, 0.5)
		end)
	end

	createSpike(position, normal)
end