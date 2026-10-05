local createVector = vector.create
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local spr = require(game.ReplicatedStorage.Modules.Utils.spr)

-- equivalent calls inferred from this helper; original call sites unknown
local function getTweenInfo(duration, easingStyle, easingDirection)
	return TweenInfo.new(
		duration or 0.5,
		easingStyle or Enum.EasingStyle.Quad,
		easingDirection or Enum.EasingDirection.Out
	)
end

return {
	IntroAnimations = {
		default = function(_, p, _)
			spr.target(p, 0.5, 2, {
				Scale = 1
			})
		end,
		bounce = function(p, p2, p3)
			local duration = p3.duration or 0.6
			local bounceHeight = p3.bounceHeight or 1.2
			p.Position = UDim2.fromScale(0.5, -0.5)
			p2.Scale = 0.8
			spr.target(p, duration * 0.7, 0.8, {
				Position = UDim2.fromScale(0.5, 0.5)
			})
			spr.target(p2, duration * 0.3, 0.5, {
				Scale = bounceHeight
			})
			task.wait(duration * 0.3)
			spr.target(p2, duration * 0.7, 0.8, {
				Scale = 1
			})
		end,
		spin = function(p, p2, p3)
			local duration = p3.duration or 0.5
			local spinRotations = p3.spinRotations or 2
			p2.Scale = 0
			p.Rotation = -360 * spinRotations
			spr.target(p2, duration, 1, {
				Scale = 1
			})
			spr.target(p, duration, 1, {
				Rotation = 0
			})
		end,
		drop = function(p, p2, data)
			local duration = data.duration or 0.5
			local dropHeight = data.dropHeight or 3
			p.Position = UDim2.fromScale(0.5, 0.5 - dropHeight)
			p2.Scale = 1
			local tweenInfo = getTweenInfo(duration, data.easingStyle, data.easingDirection) -- equivalent call inferred; original call site unknown
			TweenService:Create(p, tweenInfo, {
				Position = UDim2.fromScale(0.5, 0.5)
			}):Play()
		end,
		zoom = function(_, p, p2)
			local duration = p2.duration or 0.5
			p.Scale = p2.zoomScale or 2
			spr.target(p, duration, 1, {
				Scale = 1
			})
		end,
		flip = function(p, p2, p3)
			local duration = p3.duration or 0.5
			local flipAxis = p3.flipAxis or "Y"
			p2.Scale = 0

			if flipAxis == "Y" or flipAxis == "XY" then
				p.Rotation = 180
			end

			spr.target(p2, duration, 1, {
				Scale = 1
			})
			spr.target(p, duration, 1, {
				Rotation = 0
			})
		end,
		elastic = function(_, p, p2)
			local duration = p2.duration or 0.8
			p.Scale = 0
			TweenService:Create(p, TweenInfo.new(duration, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out), {
				Scale = 1
			}):Play()
		end,
		spiral = function(p, p2, p3)
			local duration = p3.duration or 0.8
			p2.Scale = 0
			p.Rotation = -720
			p.Position = UDim2.fromScale(0.5, 0.5)
			spr.target(p2, duration, 0.8, {
				Scale = 1
			})
			spr.target(p, duration, 0.8, {
				Rotation = 0
			})
		end
	},
	MovementAnimations = {
		none = function(_, _)
			return nil
		end,
		float = function(p, options)
			local v = options or {}
			local intensity = v.intensity or 0.3
			local speed = v.speed or 1
			local floatHeight = v.floatHeight or 0.5
			local position = p.Position
			local total = 0
			return RunService.Heartbeat:Connect(function(dt)
				total += dt * speed
				local v2 = math.sin(total * 2) * floatHeight * intensity
				p.Position = UDim2.new(
					position.X.Scale,
					position.X.Offset,
					position.Y.Scale,
					position.Y.Offset + v2 * 50
				)
			end)
		end,
		bounce = function(p, options)
			local v = options or {}
			local intensity = v.intensity or 0.3
			local speed = v.speed or 1
			local bounceHeight = v.bounceHeight or 0.2
			local position = p.Position
			local total = 0
			return RunService.Heartbeat:Connect(function(dt)
				total += dt * speed
				local v2 = math.abs((math.sin(total * 3))) * bounceHeight * intensity
				p.Position = UDim2.new(
					position.X.Scale,
					position.X.Offset,
					position.Y.Scale,
					position.Y.Offset - v2 * 50
				)
			end)
		end,
		shake = function(p, options)
			local v = options or {}
			local intensity = v.intensity or 0.3
			local shakeAmount = v.shakeAmount or 0.1
			local position = p.Position
			return RunService.Heartbeat:Connect(function(_)
				local v2 = (math.random() - 0.5) * shakeAmount * intensity * 20
				local v3 = (math.random() - 0.5) * shakeAmount * intensity * 20
				p.Position = UDim2.new(
					position.X.Scale,
					position.X.Offset + v2,
					position.Y.Scale,
					position.Y.Offset + v3
				)
			end)
		end,
		sway = function(p, options)
			local v = options or {}
			local intensity = v.intensity or 0.3
			local speed = v.speed or 1
			local swayAngle = v.swayAngle or 15
			local total = 0
			return RunService.Heartbeat:Connect(function(dt)
				total += dt * speed
				p.Rotation = math.sin(total * 2) * swayAngle * intensity
			end)
		end,
		rotate = function(p, options)
			local v = options or {}
			local speed = v.speed or 1
			local rotateSpeed = v.rotateSpeed or 45
			return RunService.Heartbeat:Connect(function(dt)
				p.Rotation += rotateSpeed * dt * speed
			end)
		end,
		pulse = function(instance, options)
			local v = options or {}
			local intensity = v.intensity or 0.3
			local speed = v.speed or 1
			local pulseScale = v.pulseScale or 0.1
			local uIScale = instance:FindFirstChildOfClass("UIScale")

			if not uIScale then
				return nil
			end

			local total = 0
			return RunService.Heartbeat:Connect(function(dt)
				total += dt * speed
				uIScale.Scale = 1 + math.sin(total * 3) * pulseScale * intensity
			end)
		end
	},
	ExitAnimations = {
		default = function(_, p, _, callback)
			spr.target(p, 1, 2, {
				Scale = 0
			})
			task.wait(0.125)

			if callback then
				callback()
			end
		end,
		shrinkSpin = function(p, p2, p3, callback)
			local duration = p3.duration or 0.3
			local spinRotations = p3.spinRotations or 3
			spr.target(p2, duration, 1, {
				Scale = 0
			})
			spr.target(p, duration, 1, {
				Rotation = 360 * spinRotations
			})
			task.wait(duration)

			if callback then
				callback()
			end
		end,
		explode = function(instance, p, p2, callback)
			local duration = p2.duration or 0.3
			local _ = p2.explodeForce or 20
			spr.target(p, duration * 0.3, 0.5, {
				Scale = 1.5
			})
			task.wait(duration * 0.3)
			local icon = instance:FindFirstChild("Icon") or instance:FindFirstChildOfClass("ImageLabel")
			local label = instance:FindFirstChild("Label") or instance:FindFirstChildOfClass("TextLabel")

			if icon then
				spr.target(icon, duration * 0.7, 1, {
					ImageTransparency = 1
				})
			end

			if label then
				spr.target(label, duration * 0.7, 1, {
					TextTransparency = 1
				})
			end

			task.wait(duration * 0.7)

			if callback then
				callback()
			end
		end,
		fadeUp = function(p, p2, p3, callback)
			local duration = p3.duration or 0.5
			local fadeDistance = p3.fadeDistance or 2
			local position = p.Position
			local uDim = UDim2.new(
				position.X.Scale,
				position.X.Offset,
				position.Y.Scale - fadeDistance,
				position.Y.Offset
			)
			spr.target(p, duration, 1, {
				Position = uDim
			})
			spr.target(p2, duration, 1, {
				Scale = 0
			})
			task.wait(duration)

			if callback then
				callback()
			end
		end,
		melt = function(instance, _, p, callback)
			local duration = p.duration or 0.5
			local icon = instance:FindFirstChild("Icon") or instance:FindFirstChildOfClass("ImageLabel")

			if icon then
				spr.target(icon, duration, 1, {
					Size = UDim2.fromScale(icon.Size.X.Scale, 0),
					Position = UDim2.fromScale(0.5, 1),
					AnchorPoint = Vector2.new(0.5, 1)
				})
			end

			task.wait(duration)

			if callback then
				callback()
			end
		end,
		flip = function(p, p2, p3, callback)
			local duration = p3.duration or 0.3
			spr.target(p, duration, 1, {
				Rotation = 90
			})
			spr.target(p2, duration, 1, {
				Scale = 0
			})
			task.wait(duration)

			if callback then
				callback()
			end
		end,
		vacuum = function(p, p2, p3, callback)
			local duration = p3.duration or 0.5
			local _ = p3.vacuumPoint or createVector(0, -5, 0)
			spr.target(p, duration, 0.8, {
				Rotation = 720,
				Position = UDim2.fromScale(0.5, 1)
			})
			spr.target(p2, duration, 0.8, {
				Scale = 0
			})
			task.wait(duration)

			if callback then
				callback()
			end
		end
	},
	LightAnimations = {
		default = function(p, p2)
			TweenService:Create(p, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				Brightness = p2.brightness or 2
			}):Play()
			return nil
		end,
		pulse = function(p, p2)
			local pulseSpeed = p2.pulseSpeed or 1.5
			local v = (p2.brightness or 2) * 0.5
			local brightness = p2.brightness or 2
			local total = 0
			return RunService.Heartbeat:Connect(function(dt)
				total += dt * pulseSpeed
				p.Brightness = v + (brightness - v) * (math.sin(total) * 0.5 + 0.5)
			end)
		end,
		flicker = function(p, p2)
			local brightness = p2.brightness or 2
			local flickerIntensity = p2.flickerIntensity or 0.3
			return RunService.Heartbeat:Connect(function(_)
				if math.random() < 0.1 then
					p.Brightness = brightness * (1 - flickerIntensity + math.random() * flickerIntensity)
				end
			end)
		end,
		rainbow = function(p, p2)
			local rainbowSpeed = p2.rainbowSpeed or 2
			local total = 0
			return RunService.Heartbeat:Connect(function(dt)
				total += dt * rainbowSpeed
				local v = total * 0.1 % 1
				p.Color = Color3.fromHSV(v, 1, 1)
			end)
		end,
		breathing = function(p, p2)
			local breathingSpeed = p2.breathingSpeed or 0.8
			local v = (p2.brightness or 2) * 0.3
			local brightness = p2.brightness or 2
			local total = 0
			return RunService.Heartbeat:Connect(function(dt)
				total += dt * breathingSpeed
				local v2 = (math.sin(total) * 0.5 + 0.5) ^ 2
				p.Brightness = v + (brightness - v) * v2
			end)
		end
	}
}