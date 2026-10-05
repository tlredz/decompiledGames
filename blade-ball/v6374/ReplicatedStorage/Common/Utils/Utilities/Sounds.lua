local RunService = game:GetService("RunService")
local SoundService = game:GetService("SoundService")
local Network = require(script.Parent.Network)
local Sounds = {
	Play = function(self, p, parent, items)
		local clone = nil

		for _, descendant in SoundService:GetDescendants() do
			if not (descendant.Name == p and (descendant:IsA("Sound") or descendant:IsA("Configuration"))) then
				continue
			end

			if descendant:IsA("Configuration") then
				local children = descendant:GetChildren()
				descendant = children[math.random(1, #children)]
			end

			clone = descendant
			break
		end

		if not clone then
			return
		end

		if parent or items or clone.Playing or clone.Looped then
			clone = clone:Clone()
			clone:Stop()
			parent = parent or SoundService

			if items then
				for k, item in items do
					clone[k] = item
				end
			end
		end

		for k, v2 in clone:GetAttributes() do
			if typeof(v2) == "NumberRange" then
				clone[k] = math.random() * (v2.Max - v2.Min) + v2.Min
			else
				clone[k] = v2
			end
		end

		if parent ~= nil then
			clone.Parent = parent
			local stoppedConnection = nil
			local endedConnection = nil

			local function clear()
				stoppedConnection:Disconnect()
				endedConnection:Disconnect()
				clone:Destroy()
			end

			stoppedConnection = clone.Stopped:Connect(clear)
			endedConnection = clone.Ended:Connect(clear)
		end

		clone:Play()
		return clone
	end
}

function Sounds:PlayAt(position: Vector3, p: string, ...)
	local part = Instance.new("Part")
	part.Size = Vector3.new()
	part.Anchored = true
	part.Massless = true
	part.CanCollide = false
	part.Position = position
	part.Transparency = 1
	local v = Sounds:Play(p, part, ...)

	if not v then
		part:Destroy()
		return
	end

	local endedConnection = nil
	endedConnection = v.Ended:Connect(function()
		endedConnection:Disconnect()
		part:Destroy()
	end)
	part.Parent = workspace
	return v
end

if RunService:IsServer() then
	function Sounds.PlayLocal(_, p, ...)
		Network:Fire(p, "PlayLocal", ...)
	end

	function Sounds.PlayLocalAt(_, p, ...)
		Network:Fire(p, "PlayLocalAt", ...)
	end
else
	function Network.Events.PlayLocal(...)
		Sounds:Play(...)
	end

	function Network.Events.PlayLocalAt(...)
		Sounds:PlayAt(...)
	end
end

return Sounds