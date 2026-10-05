local createVector = vector.create
local TweenService = game:GetService("TweenService")
local ClientDebris = require(script.Parent.ClientDebris)
local ImpactFx = require(script.Parent.ImpactFx)
local v = { Color3.fromRGB(255, 152, 220), Color3.fromRGB(85, 44, 2) }
local ZoneSweet = {}

function ZoneSweet.ZoneWarn(data)
	local x = data.x or 0
	local y = data.y or 0
	local z = data.z or 0
	local hx = data.hx or 14
	local hz = data.hz or 14
	local t = data.t or 1.4
	local part = Instance.new("Part")
	part.Name = "ChichineZoneWarnFx"
	part.Shape = Enum.PartType.Cylinder
	part.Anchored = true
	part.CanCollide = false
	part.CanQuery = false
	part.CastShadow = false
	part.Material = Enum.Material.Neon
	part.Color = Color3.fromRGB(255, 100, 30)
	part.Transparency = 0.35
	part.Size = Vector3.new(0.05, hx * 2, hz * 2)
	part.CFrame = CFrame.new(x, y + 0.15, z) * CFrame.Angles(0, 0, 1.5707963267948966)
	part.Parent = ClientDebris()
	local tween = TweenService:Create(part, TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Size = Vector3.new(5, hx * 2, hz * 2)
	})
	tween:Play()
	tween.Completed:Once(function()
		tween:Destroy()
	end)
	local tween2 = TweenService:Create(
		part,
		TweenInfo.new(0.22, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true),
		{
			Transparency = 0.72
		}
	)
	task.delay(0.18, function()
		if part.Parent then
			tween2:Play()
		end
	end)
	task.delay(math.max(0, t - 0.18), function()
		if not part.Parent then
			tween2:Destroy()
			return
		end

		tween2:Cancel()
		tween2:Destroy()
		local tween3 = TweenService:Create(part, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
			Transparency = 1,
			Size = Vector3.new(0.05, hx * 2, hz * 2)
		})
		tween3.Completed:Once(function()
			tween3:Destroy()
			pcall(function()
				part:Destroy()
			end)
		end)
		tween3:Play()
	end)
end

function ZoneSweet.ZoneHit(data)
	local v2 = math.random(1, #v)
	local x = data.x or 0
	local y = data.y or 0
	local z = data.z or 0
	local hx = data.hx or 14
	local hz = data.hz or 14
	local part = Instance.new("Part")
	part.Name = "ChichineZoneJetFx"
	part.Shape = Enum.PartType.Cylinder
	part.Anchored = true
	part.CanCollide = false
	part.CanQuery = false
	part.CastShadow = false
	part.Material = Enum.Material.Neon
	part.Color = v[v2]
	part.Transparency = 0.15
	part.Size = Vector3.new(2, hx * 2.2, hz * 2.2)
	part.CFrame = CFrame.new(x, y - 4, z) * CFrame.Angles(0, 0, 1.5707963267948966)
	part.Parent = ClientDebris()
	TweenService:Create(part, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Size = Vector3.new(160, hx * 2.6, hz * 2.6),
		CFrame = CFrame.new(x, y + 80 - 4, z) * CFrame.Angles(0, 0, 1.5707963267948966)
	}):Play()
	task.delay(0.3, function()
		if not part.Parent then
			return
		end

		local tween = TweenService:Create(part, TweenInfo.new(0.55, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {
			Transparency = 1,
			Size = createVector(160, 0.1, 0.1)
		})
		tween.Completed:Once(function()
			tween:Destroy()
			pcall(function()
				part:Destroy()
			end)
		end)
		tween:Play()
	end)
	local part2 = Instance.new("Part")
	part2.Anchored = true
	part2.CanCollide = false
	part2.CanQuery = false
	part2.CastShadow = false
	part2.Color = v[v2]
	part2.Transparency = 0.4
	part2.Size = createVector(1.5, 0.3, 1.5)
	part2.CFrame = CFrame.new(x, y + 0.2, z)
	part2.Parent = ClientDebris()
	TweenService:Create(part2, TweenInfo.new(0.3), {
		Transparency = 1,
		Size = Vector3.new(hx * 4.5, 0.3, hz * 4.5)
	}):Play()
	task.delay(0.35, function()
		pcall(function()
			part2:Destroy()
		end)
	end)
	ImpactFx.sounds(x, y, z)
end

return ZoneSweet