local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local assets = ReplicatedStorage.AdminAbuse.ChichineBossRoom.Assets
local ClientDebris = require(script.Parent.ClientDebris)
local ImpactFx = require(script.Parent.ImpactFx)
local v = nil

local function tweenModelPivot(instance, cframe: CFrame, p: number, p2, p3)
	local pivot = instance:GetPivot()
	local v2 = 0
	local thread = coroutine.running()
	local heartbeatConnection = nil
	heartbeatConnection = RunService.Heartbeat:Connect(function(dt: number)
		if instance.Parent then
			v2 = math.min(v2 + dt, p)
			instance:PivotTo(pivot:Lerp(cframe, (TweenService:GetValue(v2 / p, p2, p3))))

			if p <= v2 then
				heartbeatConnection:Disconnect()
				task.spawn(thread)
			end
		else
			heartbeatConnection:Disconnect()
			task.spawn(thread)
		end
	end)
	coroutine.yield()
end

local HammerSmash = {}

function HammerSmash.hover(data)
	HammerSmash.cleanup()
	local banhammer = assets:FindFirstChild("Banhammer")

	if not banhammer then
		warn("[ChichineBossRoom] HammerSmash: Banhammer model not found in Assets")
		return
	end

	local clone = banhammer:Clone()

	for _, part in clone:GetDescendants() do
		if not part:IsA("BasePart") then
			continue
		end

		part.Anchored = true
		part.CanCollide = false
		part.CastShadow = false
	end

	local cx = data.cx or 0
	local cy = data.cy or 0
	local cz = data.cz or 0
	local hx = data.hx or 20
	local hz = data.hz or 20
	local tx = data.tx or cx
	local ty = data.ty or cy
	local tz = data.tz or cz
	local height = data.height or 50
	local hoverSec = data.hoverSec or 3
	local steps = data.steps or 3
	local cframe = CFrame.Angles(1.5707963267948966, 0, 0)
	clone:ScaleTo(2)
	clone:PivotTo(CFrame.new(cx, cy + height, cz) * cframe)
	clone.Parent = ClientDebris()
	v = clone
	task.spawn(function()
		local v2 = hoverSec * 0.6 / math.max(steps, 1)
		local v3 = hoverSec * 0.4

		for _ = 1, steps do
			if v and v.Parent then
				local v4 = (math.random() * 2 - 1) * hx
				local v5 = (math.random() * 2 - 1) * hz
				tweenModelPivot(
					clone,
					CFrame.new(cx + v4, cy + height, cz + v5) * cframe,
					v2,
					Enum.EasingStyle.Sine,
					Enum.EasingDirection.InOut
				)
			else
				return
			end
		end

		if v and v.Parent then
			tweenModelPivot(
				clone,
				CFrame.new(tx, ty + height, tz) * cframe,
				v3,
				Enum.EasingStyle.Quad,
				Enum.EasingDirection.Out
			)
		end
	end)
end

function HammerSmash.warn(data)
	local r = data.r or 50
	local t = data.t or 2.5
	local x = data.x or 0
	local y = data.y or 0
	local z = data.z or 0

	if v then
		local hammerSmashZone = v:FindFirstChild("HammerSmashZone", true)

		if hammerSmashZone and hammerSmashZone:IsA("BasePart") then
			local position = hammerSmashZone.Position
			x = position.X
			y = position.Y - 2
			z = position.Z
		end
	end

	local part = Instance.new("Part")
	part.Name = "ChichineHMWarnDisc"
	part.Shape = Enum.PartType.Cylinder
	part.Size = Vector3.new(0.35, r * 2, r * 2)
	part.CFrame = CFrame.new(x, y - 25, z) * CFrame.Angles(0, 0, 1.5707963267948966)
	part.Anchored = true
	part.CanCollide = false
	part.CanQuery = false
	part.CastShadow = false
	part.Material = Enum.Material.Neon
	part.Color = Color3.fromRGB(255, 0, 0)
	part.Transparency = 0.4
	part.Parent = ClientDebris()
	task.delay(math.max(0, t - 0.2), function()
		if not part.Parent then
			return
		end

		local tween = TweenService:Create(part, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
			Transparency = 1
		})
		tween.Completed:Once(function()
			tween:Destroy()
			pcall(function()
				part:Destroy()
			end)
		end)
		tween:Play()
	end)
end

function HammerSmash.smash(p)
	local v2 = v

	if not (v2 and v2.Parent) then
		return
	end

	local prepareSec = p.prepareSec or 0.5
	local smashSec = p.smashSec or 0.5
	task.spawn(function()
		local pivot = v2:GetPivot()
		tweenModelPivot(
			v2,
			pivot * CFrame.Angles(-1.5707963267948966, 0, 0),
			prepareSec,
			Enum.EasingStyle.Quad,
			Enum.EasingDirection.Out
		)

		if v2 and v2.Parent then
			tweenModelPivot(v2, pivot, smashSec, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
		end
	end)
end

function HammerSmash.impact(data)
	local x = data.x or 0
	local y = data.y or 0
	local z = data.z or 0
	local r = data.r or 50

	if v then
		local hammerSmashZone = v:FindFirstChild("HammerSmashZone", true)

		if hammerSmashZone and hammerSmashZone:IsA("BasePart") then
			local position = hammerSmashZone.Position
			x = position.X
			y = position.Y
			z = position.Z
		end
	end

	ImpactFx.explosion(x, y, z, r * 2)
	HammerSmash.cleanup()
end

function HammerSmash.cleanup()
	if v then
		pcall(function()
			v:Destroy()
		end)
		v = nil
	end
end

return HammerSmash