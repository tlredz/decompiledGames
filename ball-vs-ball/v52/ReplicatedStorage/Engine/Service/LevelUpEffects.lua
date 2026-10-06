local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Net = require(ReplicatedStorage.Packages.Net)
local ExperienceService = require(script.Parent.ExperienceService)
local remoteEvent = Net:RemoteEvent("PlayerLevelUpEffect")
local v = {}

if RunService:IsServer() then
	local PlayerData = require(script.Parent.PlayerData)
	local server = PlayerData.server
	local flag = false
	local v2 = {}

	-- equivalent calls inferred from this helper; original call sites unknown
	local function observePlayer(p)
		task.spawn(function()
			server.Service:waitForData(p)

			if p.Parent ~= Players or v2[p] then
				return
			end

			local v3 = {
				total = server[p].exp.total(),
				pending = {}
			}
			v2[p] = v3
			v3.disconnect = server[p].exp.total.Changed(function(total)
				local total2 = v3.total
				v3.total = total

				if total < total2 then
					table.clear(v3.pending)
				elseif ExperienceService.getLevelInfo(total).level > ExperienceService.getLevelInfo(total2).level then
					v3.pending[total] = true
				end
			end)
		end)
	end

	function v.init()
		if flag then
			return
		end

		flag = true
		remoteEvent.OnServerEvent:Connect(function(player, value)
			local v3 = v2[player]

			if not v3 or typeof(value) ~= "number" or value ~= value or value < 0 or v3.total < value then
				return
			end

			local v4 = false

			for k in v3.pending do
				if not (k <= value) then
					continue
				end

				v3.pending[k] = nil
				v4 = true
			end

			if not v4 then
				return
			end

			local character = player.Character

			if not character then
				return
			end

			for _, player2 in Players:GetPlayers() do
				if player2 ~= player then
					remoteEvent:FireClient(player2, player, character)
				end
			end
		end)
		Players.PlayerAdded:Connect(observePlayer)
		Players.PlayerRemoving:Connect(function(player)
			local v3 = v2[player]
			v2[player] = nil

			if v3 and v3.disconnect then
				v3.disconnect()
			end
		end)

		for _, v3 in Players:GetPlayers() do
			observePlayer(v3) -- equivalent call inferred; original call site unknown
		end
	end

	return v
else
	local EffectPlayer = require(script.Parent.EffectPlayer)
	local part = ReplicatedStorage:WaitForChild("美术素材"):WaitForChild("特效"):WaitForChild("玩家升级特效")
	local flag = false

	local function playCharacter(parent)
		if not (parent and parent:IsDescendantOf(workspace)) then
			return
		end

		local humanoidRootPart = parent:FindFirstChild("HumanoidRootPart")

		if not (humanoidRootPart and humanoidRootPart:IsA("BasePart") and part:IsA("BasePart")) then
			return
		end

		local clone = part:Clone()
		clone.Anchored = false
		clone.CanCollide = false
		clone.CanTouch = false
		clone.CanQuery = false
		clone.Massless = true
		clone.CFrame = humanoidRootPart.CFrame

		for _, emitter in clone:GetDescendants() do
			if emitter:IsA("ParticleEmitter") then
				emitter.Enabled = false
			end
		end

		local weldConstraint = Instance.new("WeldConstraint")
		weldConstraint.Part0 = humanoidRootPart
		weldConstraint.Part1 = clone
		weldConstraint.Parent = clone
		clone.Parent = parent
		EffectPlayer.play(clone)
	end

	function v.init()
		if flag then
			return
		end

		flag = true
		remoteEvent.OnClientEvent:Connect(function(player, parent)
			if player ~= Players.LocalPlayer and player.Character == parent then
				playCharacter(parent)
			end
		end)
	end

	function v.play(p: number)
		playCharacter(Players.LocalPlayer.Character)
		remoteEvent:FireServer(p)
	end

	return v
end