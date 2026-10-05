local Players = game:GetService("Players")
local TextChatService = game:GetService("TextChatService")
game:GetService("Stats")
local MarketplaceService = game:GetService("MarketplaceService")
local shared = script.Parent.Parent:WaitForChild("Shared")
local DefaultEvents = require(shared:WaitForChild("Enums").DefaultEvents)
local DefaultGauges = require(shared:WaitForChild("Enums").DefaultGauges)
return {
	init = function(data, options, options2)
		local localPlayer = Players.LocalPlayer

		if not localPlayer then
			warn("StarwatchDefaultInstrumentation: No LocalPlayer found, default instrumentation will not be enabled.")
			return
		end

		local v = options or {}
		local v2 = options2 or {}

		if type(v) ~= "table" then
			error("StarwatchDefaultInstrumentation: Expected eventList to be a table of event types.")
		end

		if type(v2) ~= "table" then
			error("StarwatchDefaultInstrumentation: Expected gaugeList to be a table of gauge types.")
		end

		local v3 = {}

		for _, defaultEvent in pairs(DefaultEvents) do
			v3[defaultEvent] = true
		end

		local v4 = {}

		for _, defaultGauge in pairs(DefaultGauges) do
			v4[defaultGauge] = true
		end

		local v5 = {}

		for _, v6 in ipairs(v) do
			if v3[v6] then
				v5[v6] = true
			else
				warn("StarwatchDefaultInstrumentation: Unknown event type '" .. tostring(v6) .. "'. Use DefaultEvents enum values.")
			end
		end

		for _, v6 in ipairs(v2) do
			if v4[v6] then
				v5[v6] = true
			else
				warn("StarwatchDefaultInstrumentation: Unknown gauge type '" .. tostring(v6) .. "'. Use DefaultGauges enum values.")
			end
		end

		local function onCharacterAdded(instance)
			data.resume()

			if v5[DefaultEvents.SPAWN] then
				data.submitEvent(DefaultEvents.SPAWN, {})
			end

			local humanoid = instance:WaitForChild("Humanoid")
			local health = humanoid.Health
			local v6 = 0

			if v5[DefaultGauges.HEALTH] then
				data.setGauge("health", health)
			end

			if v5[DefaultGauges.DRIVING_STATE] then
				data.setGauge("drivingState", 0)
			end

			humanoid.HealthChanged:Connect(function(value: number)
				if type(value) ~= "number" then
					warn("StarwatchDefaultInstrumentation: HealthChanged received non-number health value")
					return
				end

				if type(health) ~= "number" then
					health = value
					return
				end

				if v5[DefaultGauges.HEALTH] then
					data.setGauge("health", value)
				end

				if v5[DefaultGauges.HEALTH] or v5[DefaultEvents.TAKE_DAMAGE] or v5[DefaultEvents.HEAL] then
					local v7 = value - health

					if math.abs(v7) < 0.5 then
						return
					end

					if v7 < 0 and v5[DefaultEvents.TAKE_DAMAGE] then
						data.submitEvent(DefaultEvents.TAKE_DAMAGE, {
							amount = math.abs(v7)
						})
						health = value
						v6 = 0
					elseif v7 > 0 and v5[DefaultEvents.HEAL] then
						v6 = (v6 or 0) + v7
						local v8 = math.floor(v6 / 10)

						for _ = 1, v8 do
							data.submitEvent(DefaultEvents.HEAL, {
								amount = 10
							})
						end

						v6 -= v8 * 10
						health = value
					end
				end
			end)

			if v5[DefaultEvents.DEATH] then
				humanoid.Died:Connect(function()
					data.submitEvent(DefaultEvents.DEATH, {})
				end)
			end

			if v5[DefaultEvents.JUMP] then
				humanoid.Jumping:Connect(function(p)
					if p then
						data.submitEvent(DefaultEvents.JUMP, {})
					end
				end)
			end

			if v5[DefaultEvents.SIT] then
				humanoid.StateChanged:Connect(function(_, p)
					if p == Enum.HumanoidStateType.Seated and (not v5[DefaultEvents.VEHICLE_ENTER] or humanoid.SeatPart and not humanoid.SeatPart:IsA("VehicleSeat")) then
						data.submitEvent(DefaultEvents.SIT, {})
					end
				end)
			end

			if v5[DefaultEvents.SWIM] then
				local v7 = false
				humanoid.StateChanged:Connect(function(_, p)
					if p == Enum.HumanoidStateType.Swimming then
						if not v7 then
							v7 = true
							data.submitEvent(DefaultEvents.SWIM, {})
						end
					else
						v7 = false
					end
				end)
			end

			if v5[DefaultEvents.CLIMB] then
				local v7 = false
				humanoid.StateChanged:Connect(function(_, p)
					if p == Enum.HumanoidStateType.Climbing then
						if not v7 then
							v7 = true
							data.submitEvent(DefaultEvents.CLIMB, {})
						end
					else
						v7 = false
					end
				end)
			end

			if v5[DefaultEvents.FREEFALL] then
				local v7 = false
				humanoid.StateChanged:Connect(function(_, p)
					if p == Enum.HumanoidStateType.Freefall then
						if not v7 then
							v7 = true
							data.submitEvent(DefaultEvents.FREEFALL, {})
						end
					else
						v7 = false
					end
				end)
			end

			if v5[DefaultEvents.VEHICLE_ENTER] or v5[DefaultEvents.VEHICLE_EXIT] or v5[DefaultEvents.VEHICLE_THROTTLE] or v5[DefaultEvents.VEHICLE_BRAKE] or v5[DefaultGauges.DRIVING_STATE] then
				local seatPart = nil
				local throttleChangedConnection = nil
				humanoid.StateChanged:Connect(function(_, p)
					if p == Enum.HumanoidStateType.Seated and humanoid.SeatPart and humanoid.SeatPart:IsA("VehicleSeat") then
						seatPart = humanoid.SeatPart

						if v5[DefaultEvents.VEHICLE_ENTER] then
							data.submitEvent(DefaultEvents.VEHICLE_ENTER, {
								vehicleName = seatPart.Name
							})
						end

						if v5[DefaultGauges.DRIVING_STATE] then
							data.setGauge("drivingState", 1)
						end

						if (v5[DefaultEvents.VEHICLE_THROTTLE] or v5[DefaultEvents.VEHICLE_BRAKE]) and seatPart then
							local v7 = 0
							throttleChangedConnection = seatPart:GetPropertyChangedSignal("Throttle"):Connect(function()
								local throttle = seatPart.Throttle

								if v5[DefaultEvents.VEHICLE_THROTTLE] and throttle > 0 and v7 <= 0 then
									data.submitEvent(DefaultEvents.VEHICLE_THROTTLE, {})
								elseif v5[DefaultEvents.VEHICLE_BRAKE] and throttle < 0 and v7 >= 0 then
									data.submitEvent(DefaultEvents.VEHICLE_BRAKE, {})
								end

								v7 = throttle
							end)
						end
					elseif p ~= Enum.HumanoidStateType.Seated and seatPart then
						if v5[DefaultEvents.VEHICLE_EXIT] then
							data.submitEvent(DefaultEvents.VEHICLE_EXIT, {
								vehicleName = seatPart.Name
							})
						end

						if v5[DefaultGauges.DRIVING_STATE] then
							data.setGauge("drivingState", 0)
						end

						if throttleChangedConnection then
							throttleChangedConnection:Disconnect()
							throttleChangedConnection = nil
						end

						seatPart = nil
					end
				end)
			end

			if v5[DefaultEvents.TOOL_EQUIPPED] then
				instance.ChildAdded:Connect(function(tool)
					if tool:IsA("Tool") then
						tool.Equipped:Connect(function()
							data.submitEvent(DefaultEvents.TOOL_EQUIPPED, {
								tool = tool.Name
							})
						end)
					end
				end)
			end

			if v5[DefaultEvents.TOOL_UNEQUIPPED] then
				instance.ChildRemoved:Connect(function(tool)
					if tool:IsA("Tool") then
						data.submitEvent(DefaultEvents.TOOL_UNEQUIPPED, {
							tool = tool.Name
						})
					end
				end)
			end
		end

		localPlayer.CharacterAdded:Connect(onCharacterAdded)

		if localPlayer.Character then
			task.spawn(onCharacterAdded, localPlayer.Character)
		end

		if v5[DefaultEvents.PURCHASE] then
			MarketplaceService.PromptProductPurchaseFinished:Connect(function(p, productId, p3)
				if p == localPlayer.UserId and p3 then
					data.submitEvent(DefaultEvents.PURCHASE, {
						productId = productId
					})
				end
			end)
			MarketplaceService.PromptGamePassPurchaseFinished:Connect(function(p, gamePassId, p3)
				if p == localPlayer.UserId and p3 then
					data.submitEvent(DefaultEvents.PURCHASE, {
						gamePassId = gamePassId
					})
				end
			end)
		end

		localPlayer.CharacterRemoving:Connect(function()
			if v5[DefaultEvents.DESPAWN] then
				data.submitEvent(DefaultEvents.DESPAWN, {})
			end

			data.pause()
		end)

		if v5[DefaultEvents.CHAT] and TextChatService and TextChatService.SendingMessage then
			TextChatService.SendingMessage:Connect(function(p)
				data.submitChatEvent({
					message = p.Text
				})
			end)
		end
	end
}