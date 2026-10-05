local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Animations = require(ReplicatedStorage._FRAMEWORK.Features.Admins.AdminAbuseEvent.AdminAbuseUtils.Animations)
local Config = require(script.Parent.Config)
require(script.Parent.Types)
return {
	start = function(data)
		local template = data.template
		local logger = data.logger
		local animation = template:FindFirstChild(Config.swingAnimationName)
		local connections = {}
		local clones = {}
		local v = {}
		local v2 = {}
		local v3 = false

		local function playSwingFeedback(player, instance)
			local character = player.Character

			if character and animation and animation:IsA("Animation") then
				local v4 = v2[player]

				if not v4 then
					v4 = Animations.loadAnimation(character, animation)
					v2[player] = v4
				end

				v4:Play()
			end

			local sound = instance:FindFirstChild(Config.chopSoundName, true)

			if sound and sound:IsA("Sound") then
				sound:Play()
			end
		end

		local function handleActivated(p, p2)
			local now = os.clock()

			if v3 or now - v[p] < Config.swingCooldownSeconds then
				return
			end

			v[p] = now
			playSwingFeedback(p, p2)
			data.onSwing(p)
		end

		local function grantAxe(instance, parent)
			local clone = template:Clone()
			clone.Name = Config.toolName
			clone.ToolTip = Config.toolTip
			clone.CanBeDropped = false
			local handle = clone:FindFirstChild("Handle")

			if handle and handle:IsA("BasePart") then
				handle.CanCollide = false
			end

			clone.Parent = parent
			table.insert(clones, clone)
			table.insert(connections, clone.Activated:Connect(function()
				local v4 = instance
				local v5 = clone
				local now = os.clock()

				if not v3 then
					if now - v[v4] < Config.swingCooldownSeconds then
						return
					end

					v[v4] = now
					playSwingFeedback(v4, v5)
					data.onSwing(v4)
				end
			end))
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function checkGrantReady(instance)
			local backpack = instance:FindFirstChildOfClass("Backpack")

			if backpack then
				return true, backpack
			end

			return false, nil
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function giveToolToPlayer(instance)
			local v4, parent = checkGrantReady(instance) -- equivalent call inferred; original call site unknown

			if v4 then
				grantAxe(instance, parent)
			else
				logger:warn(string.format(
					"20th Anniversary 2015 could not hand the axe to %s: no Backpack",
					instance.Name
				))
			end
		end

		local function trackPlayer(p)
			v[p] = 0
			table.insert(connections, p.CharacterAdded:Connect(function()
				local v4 = v2[p]

				if v4 then
					v4:Destroy()
					v2[p] = nil
				end

				giveToolToPlayer(p) -- equivalent call inferred; original call site unknown
			end))
		end

		for _, v4 in Players:GetPlayers() do
			v[v4] = 0
			local v5 = v4
			table.insert(connections, v4.CharacterAdded:Connect(function()
				local v6 = v2[v5]

				if v6 then
					v6:Destroy()
					v2[v5] = nil
				end

				giveToolToPlayer(v5) -- equivalent call inferred; original call site unknown
			end))

			if not v4.Character then
				continue
			end

			giveToolToPlayer(v4) -- equivalent call inferred; original call site unknown
		end

		table.insert(connections, Players.PlayerAdded:Connect(trackPlayer))
		return {
			stop = function()
				v3 = true

				for _, connection in connections do
					connection:Disconnect()
				end

				table.clear(connections)

				for _, v4 in v2 do
					v4:Stop()
					v4:Destroy()
				end

				table.clear(v2)

				for _, v4 in clones do
					v4:Destroy()
				end

				table.clear(clones)
				table.clear(v)
			end
		}
	end
}