local GlobalUtil = require(game.ReplicatedStorage.GlobalUtil)
local RunService = game:GetService("RunService")

if not RunService:IsRunning() or GlobalUtil.FFlags.IsUnitTest == true then
	return {}
end

local RunService2 = game:GetService("RunService")

if RunService2:IsServer() and GlobalUtil.FFlags.IsUnitTest == false then
	local remoteEvent = Instance.new("RemoteEvent")
	remoteEvent.Name = "SyncAnimations"
	task.spawn(function()
		remoteEvent.Parent = game.ReplicatedStorage:WaitForChild("Remotes")
	end)
	local v = {}
	remoteEvent.OnServerEvent:Connect(function(player, animator, list)
		if (v[player] or 0) > 10 then
			return
		end

		v[player] = (v[player] or 0) + 1

		if not (typeof(animator) == "Instance" and animator:IsA("Animator") and typeof(list) == "table") then
			return
		end

		local v2 = {}

		for i = 1, 6 do
			if not list[i] then
				break
			end

			local v3 = list[i]

			if typeof(v3) ~= "string" then
				return
			end

			for _, v4 in pairs(animator:GetPlayingAnimationTracks()) do
				if not (v4.Animation and v4.Animation.AnimationId == v3) then
					continue
				end

				while v4.Length == 0 do
					task.wait()
				end

				table.insert(v2, {
					v3,
					workspace:GetServerTimeNow(),
					v4.TimePosition,
					v4.Speed
				})
			end
		end

		local Global = require(game.ReplicatedStorage.Global)
		remoteEvent:FireClient(player, Global.Encode(animator), v2)
		task.wait(0.2)
		v[player] -= 1

		if v[player] == 0 then
			v[player] = nil
		end
	end)
	return {}
else
	local syncAnimations = game.ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("SyncAnimations")
	local RunService3 = game:GetService("RunService")
	local v = {}

	local function SyncAnimation(object, p, p2, p3)
		if v[object] then
			v[object]:Disconnect()
			v[object] = nil
		end

		local function adjustSpeed()
			local v2 = (workspace:GetServerTimeNow() - p) * p3 + p2
			local timePosition = object.TimePosition
			local v3 = v2 % object.Length - timePosition % object.Length

			if object.Length / 2 < v3 then
				v3 -= object.Length
			elseif v3 < -object.Length / 2 then
				v3 += object.Length
			end

			if math.abs(v3) <= 0.05 then
				object:AdjustSpeed(p3)
				return true
			end

			object:AdjustSpeed(p3 * (1 + v3 / 2))
			return false
		end

		if not adjustSpeed() then
			local renderSteppedConnection = nil
			renderSteppedConnection = RunService3.RenderStepped:Connect(function()
				if adjustSpeed() then
					renderSteppedConnection:Disconnect()

					if v[object] == renderSteppedConnection then
						v[object] = nil
					end
				end
			end)
			v[object] = renderSteppedConnection
		end
	end

	syncAnimations.OnClientEvent:Connect(function(p, items)
		local Global = require(game.ReplicatedStorage.Global)
		local encoded = Global.Encode(p)

		if not encoded then
			warn("idk why this is happening prolly cuz its an animator though")
			return
		end

		for _, list in pairs(items) do
			local v2, v3, v4, v5 = unpack(list)

			for _, v6 in pairs(encoded:GetPlayingAnimationTracks()) do
				if not (v6.Animation and v6.Animation.AnimationId == v2) then
					continue
				end

				while v6.Length == 0 do
					task.wait()
				end

				local v7 = v4 + (workspace:GetServerTimeNow() - v3) * v5

				if v6.Length < v7 then
					if not v6.Looped then
						return
					end

					v7 %= v6.Length
				end

				SyncAnimation(v6, v3, v4, v5)
				return
			end
		end
	end)
	return function(p, p2)
		syncAnimations:FireServer(p, p2)
	end
end