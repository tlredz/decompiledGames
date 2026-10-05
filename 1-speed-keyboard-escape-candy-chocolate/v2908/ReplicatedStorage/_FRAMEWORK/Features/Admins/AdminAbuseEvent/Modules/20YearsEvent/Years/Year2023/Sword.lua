local Debris = game:GetService("Debris")
local Players = game:GetService("Players")
local Config = require(script.Parent.Config)
require(script.Parent.Types)

local function prepareSword(template)
	local clone = template:Clone()
	clone.Name = Config.toolName
	clone.ToolTip = Config.toolTip
	clone.CanBeDropped = false

	for _, baseScript in clone:GetDescendants() do
		if baseScript:IsA("BaseScript") then
			baseScript:Destroy()
		end
	end

	return clone
end

local function playSwingFeedback(parent)
	local stringValue = Instance.new("StringValue")
	stringValue.Name = "toolanim"
	stringValue.Value = "Slash"
	stringValue.Parent = parent
	Debris:AddItem(stringValue, 0.1)
	local sound = parent:FindFirstChild(Config.swingSoundName, true)

	if sound and sound:IsA("Sound") then
		sound:Play()
	end
end

return {
	start = function(data)
		local connections = {}
		local v = {}
		local v2 = {}
		local v3 = false

		local function handleActivated(p, parent)
			local now = os.clock()

			if v3 or now - v2[p] < Config.swingCooldownSeconds then
				return
			end

			v2[p] = now
			playSwingFeedback(parent)
			data.onSwing(p)
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function grantSword(instance, backpack)
			local parent = prepareSword(data.template)
			parent.Parent = backpack
			table.insert(v, parent)
			table.insert(connections, parent.Activated:Connect(function()
				local v5 = instance
				local parent2 = parent
				local now = os.clock()

				if not v3 then
					if now - v2[v5] < Config.swingCooldownSeconds then
						return
					end

					v2[v5] = now
					playSwingFeedback(parent2)
					data.onSwing(v5)
				end
			end))
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function giveSwordToPlayer(instance)
			local backpack = instance:FindFirstChildOfClass("Backpack")

			if not backpack then
				data.logger:warn(string.format(
					"20th Anniversary 2023 could not hand the sword to %s: no Backpack",
					instance.Name
				))
				return
			end

			grantSword(instance, backpack) -- equivalent call inferred; original call site unknown
		end

		local function trackPlayer(p)
			v2[p] = 0
			table.insert(connections, p.CharacterAdded:Connect(function()
				giveSwordToPlayer(p) -- equivalent call inferred; original call site unknown
			end))
		end

		for _, v4 in Players:GetPlayers() do
			v2[v4] = 0
			local v5 = v4
			table.insert(connections, v4.CharacterAdded:Connect(function()
				giveSwordToPlayer(v5) -- equivalent call inferred; original call site unknown
			end))

			if not v4.Character then
				continue
			end

			local backpack = v4:FindFirstChildOfClass("Backpack")

			if backpack then
				local parent = prepareSword(data.template)
				parent.Parent = backpack
				table.insert(v, parent)
				local v7 = v4
				table.insert(connections, parent.Activated:Connect(function()
					local v9 = v7
					local parent2 = parent
					local now = os.clock()

					if not v3 then
						if now - v2[v9] < Config.swingCooldownSeconds then
							return
						end

						v2[v9] = now
						playSwingFeedback(parent2)
						data.onSwing(v9)
					end
				end))
			else
				data.logger:warn(string.format(
					"20th Anniversary 2023 could not hand the sword to %s: no Backpack",
					v4.Name
				))
			end
		end

		table.insert(connections, Players.PlayerAdded:Connect(trackPlayer))
		return {
			stop = function()
				v3 = true

				for _, connection in connections do
					connection:Disconnect()
				end

				table.clear(connections)

				for _, v4 in v do
					v4:Destroy()
				end

				table.clear(v)
				table.clear(v2)
			end
		}
	end
}