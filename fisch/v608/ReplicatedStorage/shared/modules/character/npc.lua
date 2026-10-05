local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("HttpService")
local Npc = {
	RandomSpeakers = {}
}
local CurrencyService = nil
local WorldService = nil
local PlayerService = nil
local RunService = game:GetService("RunService")
local forPlayer

if RunService:IsServer() then
	WorldService = require(game.ServerScriptService.server.legacyServices.WorldService)
	CurrencyService = require(game.ServerScriptService.server.legacyServices.CurrencyService)
	PlayerService = require(game.ServerScriptService.server.legacyServices.PlayerService)
	local ServerScriptService = game:GetService("ServerScriptService")
	local legacyPlayerData = require(ServerScriptService.server.modules.legacyPlayerData)
	forPlayer = legacyPlayerData.forPlayer
else
	local legacyLocalPlayerData = require(ReplicatedStorage.client.modules.legacyLocalPlayerData)
	forPlayer = legacyLocalPlayerData.fetch
end

local v = {}

function Npc:New()
	local v2 = {}

	if self:FindFirstChild("description") then
		v2.voice = self:FindFirstChild("description").voice.Value
		v2.idle = self:FindFirstChild("description").idle
	else
		v2.voice = 1
		v2.idle = Instance.new("Animation")
		v2.idle.AnimationId = "rbxassetid://180435571"
		v2.idle.Parent = self
	end

	v2.npc = self

	for _, part in pairs(self:GetDescendants()) do
		if part:IsA("BasePart") then
			part.CollisionGroup = "Npc"
		end
	end

	local track = self:FindFirstChild("Humanoid"):LoadAnimation(v2.idle)
	track.Priority = Enum.AnimationPriority.Idle
	track:Play()

	if not self:GetAttribute("IgnoreParent") then
		self.Parent = workspace:WaitForChild("world"):WaitForChild("npcs")
	end

	return v2
end

function Npc:NewRandomSpeaker(data)
	local result = {}

	if self:FindFirstChild("description") then
		result.voice = self:FindFirstChild("description").voice.Value
		result.idle = self:FindFirstChild("description").idle
	else
		result.voice = 1
		result.idle = Instance.new("Animation")
		result.idle.AnimationId = "rbxassetid://180435571"
		result.idle.Parent = self
	end

	result.npc = self
	result.locked = false

	for _, part in pairs(self:GetDescendants()) do
		if part:IsA("BasePart") then
			part.CollisionGroup = "Npc"
		end
	end

	local track = self:FindFirstChild("Humanoid"):LoadAnimation(result.idle)
	track.Priority = Enum.AnimationPriority.Idle
	track:Play()

	if not self:GetAttribute("IgnoreParent") then
		self.Parent = workspace:WaitForChild("world"):WaitForChild("npcs")
	end

	local v2 = self:FindFirstChild("HumanoidRootPart").Position.X // 75
	local v3 = self:FindFirstChild("HumanoidRootPart").Position.Y // 75
	local v4 = self:FindFirstChild("HumanoidRootPart").Position.Z // 75
	v[Vector3.new(v2, v3, v4)] = true
	v[Vector3.new(v2 + 1, v3, v4)] = true
	v[Vector3.new(v2 - 1, v3, v4)] = true
	v[Vector3.new(v2, v3 + 1, v4)] = true
	v[Vector3.new(v2, v3 - 1, v4)] = true
	v[Vector3.new(v2, v3, v4 + 1)] = true
	v[Vector3.new(v2, v3, v4 - 1)] = true
	v[Vector3.new(v2 + 1, v3, v4 + 1)] = true
	v[Vector3.new(v2 + 1, v3, v4 - 1)] = true
	v[Vector3.new(v2 + 1, v3, v4 + 1)] = true
	v[Vector3.new(v2 - 1, v3, v4 + 1)] = true
	Npc.RandomSpeakers[self] = result
	local v5 = math.random(math.floor((math.clamp(data.interval / 2, 2, 1e999))), (math.ceil(data.interval)))
	task.spawn(function()
		local v6 = {}

		while self and self.Parent do
			task.wait(v5)
			v5 = math.random(math.floor((math.clamp(data.interval / 2, 2, 1e999))), (math.ceil(data.interval)))

			for k in v6 do
				if not game.Players:GetPlayerByUserId(k) then
					v6[k] = nil
				end
			end

			local v7 = false

			for _, v8 in pairs(game.Players:GetPlayers()) do
				if not v8.Character then
					continue
				end

				if not self:FindFirstChild("Head") then
					break
				end

				if v[Vector3.new(
					v8.Character.Head.Position.X // 75,
					v8.Character.Head.Position.Y // 75,
					v8.Character.Head.Position.Z // 75
				)] and (v8.Character.Head.Position - result.npc.Head.Position).Magnitude <= data.maxdistance then
					v7 = true

					if v6[v8.UserId] then
						continue
					end

					if data.keepAliveUntilLeave then
						v6[v8.UserId] = true
					end

					local linesGenerator = data.linesGenerator

					if linesGenerator then
						local v9 = linesGenerator(v8)
						local dialog = {}

						for k, text in v9 do
							local skipTo

							if v9[k + 1] then
								skipTo = k + 1
							end

							table.insert(dialog, {
								text = text,
								t = 2,
								choices = {},
								skipTo = skipTo
							})
						end

						result.dialog = dialog
					else
						result.dialog = {
							{
								text = data.lines[math.random(1, #data.lines)],
								t = 2,
								choices = {}
							}
						}
					end

					Npc:StartDialog(result, result.npc.Head, v8, {
						dialog = result.dialog,
						runBehaviourFunction = data.runBehaviourFunction
					})
				end

				if not v7 then
					v6[v8.UserId] = nil
				end
			end
		end
	end)
	return result
end

function Npc.SendMessage(p, text: string, p3)
	local v2 = {
		dialog = {
			{
				text = text,
				t = 0.95,
				choices = {}
			}
		},
		idle = Instance.new("Animation")
	}
	v2.idle.AnimationId = "rbxassetid://180435571"
	v2.idle.Parent = p
	v2.npc = p
	v2.locked = false
	v2.voice = 8

	for _, player in pairs(p3 or game.Players:GetPlayers()) do
		ReplicatedStorage:WaitForChild("events"):WaitForChild("dialogstart"):FireClient(player, v2, v2.npc.Head, {
			dialog = v2.dialog
		})
	end

	return v2
end

function Npc:StartDialog(p, p2, player, p3, p4: number?)
	xpcall(function()
		local count = 0

		for _, v2 in table.clone(p3.dialog) do
			if not v2.choices then
				continue
			end

			for _, choice in v2.choices do
				if not choice.response then
					continue
				end

				count += 1
				table.insert(p3.dialog, {
					cs_await = `slop{count}`,
					text = choice.response,
					t = choice.t or v2.t or 4,
					choices = {}
				})
				choice.cs_trigger = `slop{count}`
			end
		end
	end, warn)
	local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
	ReplicatedStorage2:WaitForChild("events"):WaitForChild("dialogstart"):FireClient(player, p, p2, p3, p4)
	PlayerService.OnNPCTalkedTo:Fire(player, p)
end

function Npc.InnKeeper(_, p, childName, p2)
	local v2 = forPlayer(p)
	local stats = v2:WaitForChild("Stats")

	if CurrencyService:Get(p) < p2 then
		return
	end

	if stats and workspace.world.spawns:FindFirstChild(childName) then
		local currentWorldIndex = WorldService:GetCurrentWorldIndex()

		if currentWorldIndex == "Sea 1" then
			stats.spawnlocation.Value = childName
			CurrencyService:Increase(p, -p2)
		elseif v2:FindFirstChild("WorldSpawns") and v2.WorldSpawns:FindFirstChild(currentWorldIndex) then
			v2.WorldSpawns[currentWorldIndex].Value = childName
			CurrencyService:Increase(p, -p2)
		end
	end
end

return Npc