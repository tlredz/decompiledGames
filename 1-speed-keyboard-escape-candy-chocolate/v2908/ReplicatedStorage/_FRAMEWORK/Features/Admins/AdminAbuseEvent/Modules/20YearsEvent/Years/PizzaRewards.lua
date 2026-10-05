local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Config = require(script.Parent.Parent.Config)
require(script.Parent.Parent.Types)
local AAEventWinAward = require(ReplicatedStorage._FRAMEWORK.Libraries.AAEventWinAward)
return {
	start = function(p)
		local v = AAEventWinAward.create(Config.pizzaAward)
		local connections = {}
		local v2 = {}
		local nowsByPlayer = {}
		local v3 = false

		local function trackTool(player, tool)
			if tool:IsA("Tool") and tool.Name == "Pizza" and not v2[tool] then
				v2[tool] = true
				table.insert(connections, tool.Activated:Connect(function()
					local character = player.Character
					local humanoid

					if character then
						humanoid = character:FindFirstChildOfClass("Humanoid")
					end

					local v4 = nowsByPlayer[player]

					if not v3 and p.isParticipant(player) and tool.Parent == character and humanoid and humanoid.Health > 0 and (v4 == nil or os.clock() - v4 >= Config.pizzaCooldownSeconds) then
						nowsByPlayer[player] = os.clock()
						v(player)
					end
				end))
			end
		end

		local function trackContainer(player, instance)
			if not v2[instance] then
				v2[instance] = true

				for _, child in instance:GetChildren() do
					trackTool(player, child)
				end

				table.insert(connections, instance.ChildAdded:Connect(function(child)
					trackTool(player, child)
				end))
			end
		end

		local function trackPlayer(player)
			if player.Character then
				trackContainer(player, player.Character)
			end

			local backpack = player:FindFirstChildOfClass("Backpack")

			if backpack then
				trackContainer(player, backpack)
			end

			table.insert(connections, player.CharacterAdded:Connect(function(character)
				trackContainer(player, character)
			end))
			table.insert(connections, player.ChildAdded:Connect(function(backpack2)
				if backpack2:IsA("Backpack") then
					trackContainer(player, backpack2)
				end
			end))
		end

		for _, v4 in Players:GetPlayers() do
			trackPlayer(v4)
		end

		table.insert(connections, Players.PlayerAdded:Connect(trackPlayer))
		return function()
			v3 = true

			for _, connection in connections do
				connection:Disconnect()
			end

			table.clear(connections)
			table.clear(v2)
			table.clear(nowsByPlayer)
		end
	end
}