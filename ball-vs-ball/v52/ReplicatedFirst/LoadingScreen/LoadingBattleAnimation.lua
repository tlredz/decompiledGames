local RunService = game:GetService("RunService")
return {
	start = function(instance)
		local v = {}

		for _, childName in {
			"红球",
			"红球二",
			"蓝球",
			"蓝球二"
		} do
			local guiObject = instance:FindFirstChild(childName)

			if guiObject and guiObject:IsA("GuiObject") then
				table.insert(v, {
					gui = guiObject,
					team = string.find(childName, "红球", 1, true) == 1 and "red" or "blue",
					initialPosition = guiObject.Position
				})
			end
		end

		assert(#v >= 2, "LoadingBattleAnimation needs at least two balls")
		local v2 = math.clamp(instance:GetAttribute("MoveSpeed") or 0.45, 0.01, 2)
		local v3 = math.clamp(instance:GetAttribute("CollisionJitter") or 0.45, 0, 1)
		local random = Random.new()
		local vector = Vector2.new(1, 1)
		local v4 = instance:WaitForChild("碰撞反馈")
		local v5 = math.max(instance:GetAttribute("ImpactDuration") or 0.15, 0.01)
		local v6 = v5
		local v7 = {}
		local v8 = 1
		local v9 = false
		local v10 = nil

		for _, guiObject in v4:GetChildren() do
			if guiObject:IsA("GuiObject") then
				table.insert(v7, {
					gui = guiObject,
					position = guiObject.Position,
					transparency = guiObject.BackgroundTransparency
				})
			end
		end

		v4.Visible = false

		-- equivalent calls inferred from this helper; original call sites unknown
		local function impact(p)
			v4.Position = UDim2.fromScale(p.X / vector.X, p.Y / vector.Y)
			v6 = 0
		end

		local function wall(state)
			local position = state.position
			local direction = state.direction
			local radius = state.radius

			if position.X < radius then
				if direction.X < 0 then
					impact(Vector2.new(0, (math.clamp(position.Y, 0, vector.Y)))) -- equivalent call inferred; original call site unknown
				end

				direction = Vector2.new(math.abs(direction.X), direction.Y)
			elseif position.X > vector.X - radius then
				if direction.X > 0 then
					impact(Vector2.new(vector.X, (math.clamp(position.Y, 0, vector.Y)))) -- equivalent call inferred; original call site unknown
				end

				direction = Vector2.new(-math.abs(direction.X), direction.Y)
			end

			if position.Y < radius then
				if direction.Y < 0 then
					impact(Vector2.new(math.clamp(position.X, 0, vector.X), 0)) -- equivalent call inferred; original call site unknown
				end

				direction = Vector2.new(direction.X, (math.abs(direction.Y)))
			elseif position.Y > vector.Y - radius then
				if direction.Y > 0 then
					impact(Vector2.new(math.clamp(position.X, 0, vector.X), vector.Y)) -- equivalent call inferred; original call site unknown
				end

				direction = Vector2.new(direction.X, -math.abs(direction.Y))
			end

			state.position = Vector2.new(
				math.clamp(position.X, radius, vector.X - radius),
				(math.clamp(position.Y, radius, vector.Y - radius))
			)
			state.direction = direction
		end

		local heartbeatConnection = nil
		local destroyingConnection = nil
		local flag = false
		local flag2 = false

		local function pause()
			if not flag then
				flag2 = true
			end
		end

		local function resume()
			if not flag then
				flag2 = false
			end
		end

		local function setSpeedMultiplier(p)
			v8 = math.max(p, 0.001)
		end

		local function stop()
			if flag then
				return
			end

			flag = true

			if heartbeatConnection then
				heartbeatConnection:Disconnect()
			end

			if destroyingConnection then
				destroyingConnection:Disconnect()
			end

			v4.Visible = false

			for _, v11 in v do
				v11.gui.Position = v11.initialPosition
			end

			for _, v11 in v7 do
				v11.gui.Position = v11.position
				v11.gui.BackgroundTransparency = v11.transparency
			end
		end

		heartbeatConnection = RunService.Heartbeat:Connect(function(dt)
			if flag2 then
				return
			end

			local absoluteSize = instance.AbsoluteSize

			if absoluteSize.X <= 0 or absoluteSize.Y <= 0 then
				return
			end

			vector = absoluteSize

			if v9 and v10 and v10 ~= absoluteSize then
				for _, v11 in v do
					v11.position = Vector2.new(
						v11.position.X * absoluteSize.X / v10.X,
						v11.position.Y * absoluteSize.Y / v10.Y
					)
				end
			end

			v10 = absoluteSize

			for _, v11 in v do
				v11.radius = math.clamp(
					math.min(v11.gui.AbsoluteSize.X, v11.gui.AbsoluteSize.Y) * 0.5,
					0.001,
					math.min(absoluteSize.X, absoluteSize.Y) * 0.24
				)

				if not v9 then
					v11.position = v11.gui.AbsolutePosition + v11.gui.AbsoluteSize * 0.5 - instance.AbsolutePosition
				end
			end

			if not v9 then
				for _, v11 in v do
					local magnitude = 1e999
					local v12 = nil

					for _, v13 in v do
						if v13.team == v11.team then
							continue
						end

						local v14 = v13.position - v11.position

						if not (v14.Magnitude < magnitude) then
							continue
						end

						magnitude = v14.Magnitude
						v12 = v14
					end

					local direction

					if v12 and v12.Magnitude > 0.00001 then
						direction = v12.Unit
					else
						direction = Vector2.new(1, 0)
					end

					v11.direction = direction
				end

				v9 = true
			end

			v6 += dt
			local v11 = math.min(dt, 0.1)
			local v12 = 1e999

			for _, v13 in v do
				v12 = math.min(v12, v13.radius)
			end

			local v13 = v2 * v8 * math.min(absoluteSize.X, absoluteSize.Y)
			local v14 = math.min(0.008333333333333333, v12 / v13 * 0.5)

			while v11 > 0 do
				local v15 = math.min(v11, v14)
				v11 -= v15

				for _, v16 in v do
					v16.position += v16.direction * v13 * v15
					wall(v16)
				end

				for i = 1, #v - 1 do
					local v16 = v[i]

					for i2 = i + 1, #v do
						local v17 = v[i2]
						local v18 = v17.position - v16.position
						local magnitude = v18.Magnitude

						if not (magnitude < v16.radius + v17.radius) then
							continue
						end

						local vector2

						if magnitude > 0.00001 then
							vector2 = v18 / magnitude
						else
							vector2 = Vector2.new(1, 0)
						end

						local v19 = vector2 * ((v16.radius + v17.radius - magnitude) * 0.5 + 0.0001)
						v16.position -= v19
						v17.position += v19

						if (v17.direction - v16.direction):Dot(vector2) < 0 then
							local vector3 = Vector2.new(-vector2.Y, vector2.X)
							v16.direction = (-vector2 + vector3 * random:NextNumber(-v3, v3)).Unit
							v17.direction = (vector2 + vector3 * random:NextNumber(-v3, v3)).Unit
							impact(v16.position + vector2 * v16.radius) -- equivalent call inferred; original call site unknown
						end

						wall(v16)
						wall(v17)
					end
				end
			end

			for _, v15 in v do
				local v16 = (v15.gui.AnchorPoint - Vector2.new(0.5, 0.5)) * v15.gui.AbsoluteSize
				v15.gui.Position = UDim2.new(
					v15.position.X / absoluteSize.X,
					v16.X,
					v15.position.Y / absoluteSize.Y,
					v16.Y
				)
			end

			v4.Visible = v6 < v5

			if v4.Visible then
				local v15 = math.clamp(v6 / v5, 0, 1)

				for _, v16 in v7 do
					local position = v16.position
					v16.gui.Position = UDim2.new(
						0.5 + (position.X.Scale - 0.5) * (v15 + 1),
						position.X.Offset,
						0.5 + (position.Y.Scale - 0.5) * (v15 + 1),
						position.Y.Offset
					)
					v16.gui.BackgroundTransparency = v16.transparency + (1 - v16.transparency) * v15
				end
			end
		end)
		destroyingConnection = instance.Destroying:Connect(stop)
		return {
			stop = stop,
			pause = pause,
			resume = resume,
			setSpeedMultiplier = setSpeedMultiplier
		}
	end
}