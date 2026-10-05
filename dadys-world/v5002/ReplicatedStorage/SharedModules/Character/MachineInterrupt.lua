local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")
return {
	kickOffMachine = function(player, data)
		if not (player and player.Parent) then
			return false
		end

		local character = player.Character

		if not character then
			return false
		end

		local decoding = character:FindFirstChild("Decoding")

		if not (decoding and decoding.Value) then
			return false
		end

		if data and data.throttleState and data.throttleSeconds then
			local throttleKey = data.throttleKey or player
			local v = data.throttleState[throttleKey]

			if v and os.clock() - v < data.throttleSeconds then
				return false
			else
				data.throttleState[throttleKey] = os.clock()
			end
		end

		local value = decoding.Value

		if not (value and value.Parent and value:FindFirstChild("Stats")) then
			decoding.Value = nil
			return false
		end

		local stats = value:FindFirstChild("Stats")
		local forceStop = stats and stats:FindFirstChild("ForceStop")

		if forceStop then
			forceStop:Fire(player)
			local events = ReplicatedStorage:FindFirstChild("Events")
			local stopInteracting = events and events:FindFirstChild("StopInteracting")

			if stopInteracting then
				stopInteracting:FireClient(player)
			end
		end

		if character:FindFirstChild("NoDecode") then
			return true
		end

		local boolValue = Instance.new("BoolValue")
		boolValue.Name = "NoDecode"
		boolValue.Value = true
		boolValue.Parent = character
		Debris:AddItem(boolValue, 1)
		return true
	end
}