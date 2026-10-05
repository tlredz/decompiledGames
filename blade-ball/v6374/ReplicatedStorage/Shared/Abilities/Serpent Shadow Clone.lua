local createVector = vector.create
local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local CollectionService = game:GetService("CollectionService")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local Debris = game:GetService("Debris")
game:GetService("Teams")
local Players = game:GetService("Players")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
require3(script.Parent._Types)
local v = require3(ReplicatedStorage2.Packages.Net)
local v2 = require3(game.ReplicatedStorage.Shared.ThreadSafeTargetingHelper)
local v3 = nil
local v4 = nil
local flag = false
local remoteEvent = v:RemoteEvent("PlayBotParticles")

local function getParticleLifetime(folder)
	local max = -1e999

	for _, emitter in ipairs(folder:GetDescendants()) do
		if emitter:IsA("ParticleEmitter") and max < emitter.Lifetime.Max then
			max = emitter.Lifetime.Max
		end
	end

	return max
end

local function playVFXFromContainer(child, duration: number, cFrame: CFrame)
	local raycastParams

	if child:FindFirstChild("GROUND", true) then
		local characters = {}

		for _, v5 in ipairs(game.Players:GetPlayers()) do
			local character = v5.Character

			if character then
				table.insert(characters, character)
			end
		end

		raycastParams = RaycastParams.new()
		raycastParams.FilterType = Enum.RaycastFilterType.Exclude
		raycastParams.IgnoreWater = true
		raycastParams.RespectCanCollide = true
		raycastParams.FilterDescendantsInstances = characters
	end

	local particleLifetime = getParticleLifetime(child)
	local clone = child:Clone()
	clone.CFrame = cFrame
	clone.Parent = workspace.CurrentCamera

	for _, descendant in ipairs(clone:GetDescendants()) do
		if descendant:IsA("BasePart") and descendant.Name == "GROUND" then
			local raycastResult

			if raycastParams then
				raycastResult = workspace:Raycast(cFrame.Position, createVector(-0, -100, -0), raycastParams)
			end

			if raycastResult then
				descendant.Position = raycastResult.Position
			end
		elseif descendant:IsA("ParticleEmitter") then
			descendant.Enabled = true
		end
	end

	task.delay(duration, function()
		for _, emitter in ipairs(clone:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter.Enabled = false
			end
		end
	end)
	Debris:AddItem(clone, duration + particleLifetime)
	return particleLifetime
end

local function addChevron(character, folder)
	local head = folder:FindFirstChild("Head")

	if head == nil or head:FindFirstChild("Chevron") then
		return
	end

	local clone = game.ServerScriptService.Game.CoreGameModules.MapManager.Modes.BaseMode.Chevron:Clone()
	clone.ImageLabel.ImageColor3 = character:GetAttribute("VirtualTeamColor").Color
	clone.Parent = head
	v3.giveToRoundMaid(clone)
end

local SerpentShadowClone = {}
SerpentShadowClone.cooldown = 45
SerpentShadowClone.cooldownReductionPerUpgrade = 0
SerpentShadowClone.iconId = "rbxassetid://15508130858"

function SerpentShadowClone.validateArguments(_, _)
	if not flag then
		flag = true

		if RunService:IsClient() then
			remoteEvent.OnClientEvent:Connect(function(childName: string, p: number, cframe: CFrame)
				local child = script:FindFirstChild(childName)

				if child then
					playVFXFromContainer(child, p, cframe)
				end
			end)
		end
	end

	return true
end

function SerpentShadowClone.canBeUsed(_)
	return true
end

function SerpentShadowClone.serverActivationAsync(data, _, _)
	if not v4 then
		v4 = require3(game.ServerScriptService.Game.CoreGameModules.BotUtility)
	end

	if not v3 then
		v3 = require3(game.ServerScriptService.Game.CoreGameModules.MapManager)
	end

	local formatted = ("Bots-%d"):format(data.player.UserId)
	local count = #CollectionService:GetTagged(("Bots-%d"):format(data.player.UserId))
	local v5 = math.clamp(data.upgradeLevel + 2, 1, 3)
	local currentMode = v3.getCurrentMode()
	local modeState = v3.getModeState()
	local playerTeam = v2.GetPlayerTeam(data.player)

	if data.character:GetAttribute("VirtualTeamId") == nil then
		data.character:SetAttribute("VirtualTeamId", HttpService:GenerateGUID(false))
		data.character:SetAttribute("VirtualTeamColor", BrickColor.Random())
	end

	data.character:SetAttribute("TeamColor", data.character:GetAttribute("VirtualTeamColor"))

	if not (playerTeam and currentMode:isTeamVisible(modeState, playerTeam)) then
		task.spawn(addChevron, data.character, data.character)
	end

	if v5 > 0 then
		local v6 = {}
		local flag2 = false

		local function onPlayerDied()
			if flag2 then
				return
			end

			flag2 = true

			for _, v7 in ipairs(v6) do
				local playerFromCharacterInMatch = v3.getPlayerFromCharacterInMatch(v7)
				v3.ejectPlayer(playerFromCharacterInMatch)
				v3.killCharacter(v7, nil, true)
				local v8 = v7
				task.defer(function()
					if v8.Parent then
						v8:Destroy()
					end
				end)
			end

			local head = data.character:FindFirstChild("Head")
			local chevron

			if head then
				chevron = head:FindFirstChild("Chevron")
			end

			if chevron then
				chevron:Destroy()
			end
		end

		for _ = 1, v5 do
			local v7 = count + 1
			local botSpawnLocation = v4:getBotSpawnLocation(data.player, nil, v7)
			task.delay(0, function()
				remoteEvent:FireClient(data.player, "Appear", 1, botSpawnLocation)
			end)
			local v9 = botSpawnLocation
			task.delay(0.9, function()
				if flag2 or not v3.gameIsActive() then
					v7 -= 1
					return
				end

				local modeState2 = v3.getModeState()

				if modeState2 and table.find(modeState2.winners, data.player) then
					return
				end

				local v10 = game.ServerScriptService.Game.Server.BotManager.InjectBot:Invoke({
					difficulty = "Impossible",
					botsTargetPlayers = true,
					joinData = {
						team = playerTeam,
						spawnLocation = v9 - createVector(0, 2, 0)
					},
					customBotModel = "PlayerBot",
					noClothing = true,
					moves = true,
					botsFaceBall = true,
					ownerCharacter = data.character,
					customAI = false
				}, function(folder)
					folder:SetAttribute("VirtualTeamId", data.character:GetAttribute("VirtualTeamId"))
					folder:SetAttribute("VirtualTeamColor", data.character:GetAttribute("VirtualTeamColor"))
					folder:SetAttribute("TeamColor", data.character:GetAttribute("VirtualTeamColor"))
					folder:SetAttribute("BotSerial", v7)
					folder:SetAttribute("Owner", data.character.Name)
					folder:SetAttribute("IsBot", true)
					CollectionService:AddTag(folder, formatted)

					if not (playerTeam and currentMode:isTeamVisible(modeState, playerTeam)) then
						addChevron(data.character, folder)
					end

					local flag3 = false

					local function botDied()
						if flag3 then
							return
						end

						flag3 = true
						local primaryPart = folder.PrimaryPart

						if primaryPart then
							remoteEvent:FireClient(data.player, "Disappear", 4, primaryPart.CFrame)
						end

						for i, descendant in ipairs(folder:GetDescendants()) do
							if descendant:IsA("BasePart") or descendant:IsA("Decal") then
								descendant.Transparency = 1
							elseif descendant:IsA("ParticleEmitter") or descendant:IsA("Beam") or descendant:IsA("PointLight") then
								descendant.Enabled = false
							end
						end

						task.defer(function()
							if folder.Parent then
								folder:Destroy()
							end
						end)
					end

					v3.giveToRoundMaid(folder:GetAttributeChangedSignal("Dead"):Once(botDied))
					v3.giveToRoundMaid(onPlayerDied)
					task.delay(31, onPlayerDied)
				end)
				local playerFromCharacterInMatch = v3.getPlayerFromCharacterInMatch(v10)
				playerFromCharacterInMatch.CanBeWinner = false
				table.insert(v6, v10)
				task.delay(3, function()
					if not v10:GetAttribute("Dead") then
						v10:SetAttribute("botDifficulty", "Intermediate")
					end
				end)
			end)
			count += 1
		end

		v3.giveToRoundMaid(data.character:GetAttributeChangedSignal("Dead"):Once(onPlayerDied))
		v3.giveToRoundMaid(data.humanoid.Died:Once(onPlayerDied))
		v3.giveToRoundMaid(Players.PlayerRemoving:Connect(function(player)
			if player == data.player then
				onPlayerDied()
			end
		end))

		if data.character:GetAttribute("Dead") then
			onPlayerDied()
		end
	end
end

return SerpentShadowClone