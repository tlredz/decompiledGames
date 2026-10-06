local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
ReplicatedStorage:WaitForChild("Chest"):WaitForChild("Assets"):WaitForChild("Modules")
local PeoUtils = require(ReplicatedStorage.Chest.Modules.PeoUtils)
local EntityClient = require(ReplicatedStorage.Chest.Assets.Modules.EntityClient)
local tracks = script.Parent:WaitForChild("Tracks")
local animationReplication = script:WaitForChild("AnimationReplication")
local _ = {
	Play = 1,
	Stop = 2,
	AdjustSpeed = 3,
	Destroy = 4
}

if RunService:IsClient() then
	animationReplication.OnClientEvent:Connect(function(p, buf: buffer)
		local entityController = EntityClient.GetEntityController(p)

		if not (entityController and entityController.PlayAnimation and entityController.GetPerformanceMode) then
			return
		end

		entityController._AnimationTracks = entityController._AnimationTracks or {}
		local v = buffer.readu8(buf, 0)
		local v2 = buffer.readu8(buf, 1)
		local v3 = buffer.readstring(buf, 2, v2)
		local _AnimationTrack = entityController._AnimationTracks[v3]

		if v == 1 then
			if entityController:GetPerformanceMode() then
				return
			end

			if _AnimationTrack then
				_AnimationTrack:Play()
				return
			end

			local v4 = buffer.readu8(buf, v2 + 2)
			local v5 = buffer.readstring(buf, v2 + 2 + 1, v4)
			local v6

			if typeof(v5) == "string" then
				v6 = tracks:FindFirstChild(v5)

				if not v6 then
					v6 = Instance.new("Animation")
					v6.Name = v5
					v6.AnimationId = v5
					v6.Parent = tracks
				end
			else
				v6 = v5
			end

			if not v6 then
				return
			end

			local v7 = entityController:PlayAnimation(nil, v6)
			v7:Play()
			entityController._AnimationTracks[v3] = v7
		else
			if v == 2 and _AnimationTrack then
				_AnimationTrack:Stop()
				return
			end

			if v == 3 and _AnimationTrack then
				_AnimationTrack:AdjustSpeed(buffer.readu8(buf, v2 + 2) or 1)
				return
			end

			if v ~= 4 or not _AnimationTrack then
				return
			end

			if _AnimationTrack.IsPlaying then
				_AnimationTrack:Stop()
			end

			_AnimationTrack:Destroy()
			entityController._AnimationTracks[v3] = nil
		end
	end)
end

return {
	LoadAnimation = function(_, p, animationId: string)
		if not RunService:IsServer() then
			return
		end

		local v = {}
		local randomUniqueId = PeoUtils.RandomUniqueId()

		if typeof(animationId) == "Instance" then
			animationId = animationId.AnimationId
		end

		if not animationId then
			return
		end

		function v:Play()
			local v2 = #randomUniqueId + 2 + 1 + #animationId
			local buf = buffer.create(v2)
			buffer.writeu8(buf, 0, 1)
			buffer.writeu8(buf, 1, #randomUniqueId)
			buffer.writestring(buf, 2, randomUniqueId)
			buffer.writeu8(buf, #randomUniqueId + 2, #animationId)
			buffer.writestring(buf, #randomUniqueId + 2 + 1, animationId)
			animationReplication:FireAllClients(p, buf)
			return v
		end

		function v:Stop()
			local v2 = #randomUniqueId + 2
			local buf = buffer.create(v2)
			buffer.writeu8(buf, 0, 2)
			buffer.writeu8(buf, 1, #randomUniqueId)
			buffer.writestring(buf, 2, randomUniqueId)
			animationReplication:FireAllClients(p, buf)
			return v
		end

		function v:AdjustSpeed(value: number)
			local v2 = #randomUniqueId + 2 + 1
			local buf = buffer.create(v2)
			buffer.writeu8(buf, 0, 3)
			buffer.writeu8(buf, 1, #randomUniqueId)
			buffer.writestring(buf, 2, randomUniqueId)
			buffer.writeu8(buf, #randomUniqueId + 2, value)
			animationReplication:FireAllClients(p, buf)
			return v
		end

		function v:Destroy()
			local v2 = #randomUniqueId + 2
			local buf = buffer.create(v2)
			buffer.writeu8(buf, 0, 4)
			buffer.writeu8(buf, 1, #randomUniqueId)
			buffer.writestring(buf, 2, randomUniqueId)
			animationReplication:FireAllClients(p, buf)
			return v
		end

		return v
	end
}