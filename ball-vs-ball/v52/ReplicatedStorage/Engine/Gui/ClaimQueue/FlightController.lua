local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local FlightController = {}

function FlightController.new(parent, p, callback)
	local v = {}
	local icons = {}
	local v2 = {}
	local v3 = 1
	local count = 0
	local heartbeatConnection = nil
	local v4 = 0

	-- equivalent calls inferred from this helper; original call sites unknown
	local function callback2(p2)
		if p2.onLanded then
			task.spawn(function()
				local success, result = pcall(p2.onLanded)

				if not success then
					warn("[ClaimQueue] onLanded: " .. tostring(result))
				end
			end)
		end
	end

	local function launch(payload, origin)
		local flyTarget = payload.flyTarget or p

		if flyTarget and flyTarget.Parent and parent.Parent then
			local icon = table.remove(icons)

			if not icon then
				icon = Instance.new("ImageLabel")
				icon.Name = "领取飞行图标"
				icon.BackgroundTransparency = 1
				icon.AnchorPoint = Vector2.new(0.5, 0.5)
				icon.ZIndex = 100
				icon.Parent = parent
			end

			icon.Image = payload.image
			icon.ImageColor3 = origin.color
			icon.ScaleType = origin.scaleType
			icon.ImageRectOffset = origin.rectOffset
			icon.ImageRectSize = origin.rectSize
			icon.Position = UDim2.fromOffset(origin.position.X, origin.position.Y)
			icon.Size = UDim2.fromOffset(origin.size.X, origin.size.Y)
			icon.Visible = true
			local finish = flyTarget.AbsolutePosition + flyTarget.AbsoluteSize / 2
			table.insert(v, {
				icon = icon,
				payload = payload,
				origin = origin,
				finish = finish,
				control = (origin.position + finish) / 2 - Vector2.new(0, 140),
				elapsed = 0
			})
		else
			callback2(payload) -- equivalent call inferred; original call site unknown
		end
	end

	local function step(p2)
		local now = os.clock()
		local v6 = 1

		while v6 <= #v do
			local v7 = v[v6]
			v7.elapsed += p2
			local v8 = math.clamp(v7.elapsed / 0.8, 0, 1)
			local value = TweenService:GetValue(v8, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
			local v9 = 1 - value
			local origin = v7.origin
			local v10 = origin.position * v9 * v9 + v7.control * (2 * v9 * value) + v7.finish * value * value
			v7.icon.Position = UDim2.fromOffset(v10.X, v10.Y)
			local v11 = 1 - 0.65 * value
			v7.icon.Size = UDim2.fromOffset(origin.size.X * v11, origin.size.Y * v11)

			if v8 >= 1 then
				table.remove(v, v6)
				v7.icon.Visible = false
				table.insert(icons, v7.icon)
				callback2(v7.payload) -- equivalent call inferred; original call site unknown
				callback(v7.payload.flyTarget == nil)
			else
				v6 += 1
			end
		end

		if v3 <= count and #v < 24 and v4 <= now then
			local v7 = v2[v3]
			local payload = table.remove(v7.records)

			if payload then
				local origin = v7.origin

				if v7.onLaunch then
					origin = v7.onLaunch() or origin
				end

				launch(payload, origin)
			end

			v4 = now + v7.interval
			v7.interval = math.max(0.035, v7.interval * 0.88)

			if #v7.records == 0 then
				v2[v3] = nil
				v3 += 1

				if v7.onLaunched then
					v7.onLaunched()
				end
			end
		end

		if count < v3 and #v == 0 then
			heartbeatConnection:Disconnect()
			heartbeatConnection = nil
			v3 = 1
			count = 0
			v4 = 0
		end
	end

	return {
		enqueue = function(records, origin, flag: boolean, onLaunch, onLaunched)
			if #records == 0 then
				return
			end

			count += 1
			v2[count] = {
				records = records,
				origin = origin,
				interval = flag and 0.15 or 0.035,
				onLaunch = onLaunch,
				onLaunched = onLaunched
			}

			if not heartbeatConnection then
				heartbeatConnection = RunService.Heartbeat:Connect(step)
			end
		end
	}
end

function FlightController.snapshot(data)
	return {
		position = data.AbsolutePosition + data.AbsoluteSize / 2,
		size = data.AbsoluteSize,
		color = data.ImageColor3,
		scaleType = data.ScaleType,
		rectOffset = data.ImageRectOffset,
		rectSize = data.ImageRectSize
	}
end

return FlightController