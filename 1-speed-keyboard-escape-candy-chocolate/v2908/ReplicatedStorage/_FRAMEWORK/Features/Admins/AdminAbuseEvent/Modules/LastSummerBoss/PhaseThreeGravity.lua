local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ReverseGravity = require(ReplicatedStorage._FRAMEWORK.Features.ReverseGravity)
local SpacialQuery = require(ReplicatedStorage._FRAMEWORK.Libraries.Basics.SpacialQuery)
local LoggerManager = require(ReplicatedStorage._FRAMEWORK.Libraries.LoggerManager)
local Janitor = require(ReplicatedStorage.Utilities.Janitor)
local logger = LoggerManager.createLogger(script.Name, {
	feature = script:GetFullName()
})

local function getRootPosition(player)
	local character = player.Character
	local humanoidRootPart

	if character then
		humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	end

	if humanoidRootPart and humanoidRootPart:IsA("BasePart") then
		return humanoidRootPart.Position
	end

	return nil
end

return {
	new = function()
		assert(RunService:IsServer(), "PhaseThreeGravity.new can only be called on the server")
		local v = {}
		local maid = Janitor.new()

		local function trackPlayer(p)
			maid:Add(p.CharacterAdded:Connect(function()
				v[p] = nil
			end), "Disconnect", p)
		end

		for _, v2 in Players:GetPlayers() do
			local v3 = v2
			maid:Add(v2.CharacterAdded:Connect(function()
				v[v3] = nil
			end), "Disconnect", v2)
		end

		maid:Add(Players.PlayerAdded:Connect(trackPlayer))
		maid:Add(Players.PlayerRemoving:Connect(function(player)
			v[player] = nil
			maid:Remove(player)
		end))
		return {
			update = function(p)
				if p == nil then
					return
				end

				for _, v2 in Players:GetPlayers() do
					if v[v2] then
						continue
					end

					local character = v2.Character
					local humanoidRootPart

					if character then
						humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
					end

					local position

					if humanoidRootPart and humanoidRootPart:IsA("BasePart") then
						position = humanoidRootPart.Position
					end

					local v3

					if position == nil then
						v3 = false
					else
						v3 = SpacialQuery.isPositionInPart(position, p)
					end

					if not (v3 and ReverseGravity.reverseGravity(v2, true)) then
						continue
					end

					v[v2] = true
					logger:info((`{v2.Name} entered GravityZone -> gravity reversed`))
				end
			end,
			stop = function()
				for k in v do
					if k.Parent then
						ReverseGravity.reverseGravity(k, false)
					end
				end

				table.clear(v)
				maid:Cleanup()
			end
		}
	end
}