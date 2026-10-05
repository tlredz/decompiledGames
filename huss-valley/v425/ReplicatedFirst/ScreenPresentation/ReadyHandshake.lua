local ReadyHandshake = {}
ReadyHandshake.__index = ReadyHandshake

function ReadyHandshake.new(player, p2, options)
	local v = options or {}
	return (setmetatable({
		player = player,
		alive = p2 or function()
			return true
		end,
		spawn = v.spawn or task.spawn,
		wait = v.wait or task.wait,
		remote = v.remote or function()
			local chickenOrHero = game.ReplicatedStorage:FindFirstChild("ChickenOrHero")
			local game2 = chickenOrHero and chickenOrHero:FindFirstChild("Game")
			return game2 and game2:FindFirstChild("PlayerPreferences")
		end
	}, ReadyHandshake))
end

function ReadyHandshake:run()
	if self.running then
		return
	end

	self.running = true
	self.spawn(function()
		while self.alive() and self.player.Parent do
			local v = self.completeRequested and self.player:GetAttribute("ClientReady") ~= true
			local v2 = self.transferRequested and self.player:GetAttribute("TransferReady") ~= true

			if v or v2 then
				local v3 = v2
				local v4 = v
				pcall(function()
					local remote = self.remote()

					if remote then
						if v3 then
							remote:FireServer("TransferReady")
						end

						if v4 then
							remote:FireServer("Ready")
						end
					end
				end)
				self.wait(2)
			else
				break
			end
		end

		self.running = false
	end)
end

function ReadyHandshake:complete()
	self.completeRequested = true
	self:run()
end

function ReadyHandshake:transferReady()
	self.transferRequested = true
	self:run()
end

return ReadyHandshake