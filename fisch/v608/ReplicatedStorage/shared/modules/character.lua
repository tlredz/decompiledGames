local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ServerScriptService = game:GetService("ServerScriptService")
local TweenService = game:GetService("TweenService")
local CollectionService = game:GetService("CollectionService")
local Net = require(ReplicatedStorage.packages.Net)
local debris = require(ReplicatedStorage.shared.modules.fx.debris)
local fx = require(ReplicatedStorage.shared.modules.fx)
local rods = require(ReplicatedStorage.shared.modules.library.rods)
local Bestiary = require(ReplicatedStorage.shared.modules.Bestiary)
local SharedPlayerStats = require(ReplicatedStorage.shared.modules.SharedPlayerStats)
local FischUtils = require(ReplicatedStorage.shared.utils.FischUtils)
local lanterns = require(ReplicatedStorage.shared.modules.library.lanterns)
local assets = require(ReplicatedStorage.shared.utils.assets)
local WorldSpawns = nil
local RunService2 = game:GetService("RunService")
local forPlayer

if RunService2:IsServer() then
	local legacyPlayerData = require(ServerScriptService.server.modules.legacyPlayerData)
	forPlayer = legacyPlayerData.forPlayer
	WorldSpawns = require(ServerScriptService.server.legacyServices.WorldSpawns)
else
	local legacyLocalPlayerData = require(ReplicatedStorage.client.modules.legacyLocalPlayerData)
	forPlayer = legacyLocalPlayerData.fetch
end

if RunService:IsServer() then
	require(ServerScriptService.server.legacyServices.WorldService)
else
	require(ReplicatedStorage:WaitForChild("client").legacyControllers.WorldController)
end

local remoteFunction = Net:RemoteFunction("GetSpawnPosition")
local Character = {
	PS = function(p)
		if not p then
			return
		end

		if RunService:IsServer() then
			return forPlayer(p)
		end

		local _ = p == game.Players.LocalPlayer
		return forPlayer(p)
	end,
	WaitDataFolder = function(p)
		assert(p, "No player!")
		return forPlayer(p)
	end
}
local v = {
	"The sea stirs, indifferent to your fall...",
	"A ripple carries your echo deeper...",
	"Something faint listens from below...",
	"The current shifts, ever so slightly...",
	"A distant hum brushes your bones...",
	"Salt clings heavier with each return...",
	"The seabed murmurs in forgotten tones...",
	"Shadows wait beyond the drifting silt...",
	"The pressure deepens, almost expectant...",
	"You feel watched, though nothing moves...",
	"A subtle pull tugs at your spirit...",
	"Faint lights flicker far beneath you...",
	"The silence feels strangely rehearsed...",
	"You're getting kindof used to it...",
	"Each blast leaves the world thinner...",
	"Whispers trace the edge of your hearing...",
	"The water grows heavier with intent...",
	"Something vast shifts in the dark...",
	"The explosions echo like distant drums...",
	"The ocean holds its breath...",
	"Your path coils toward unseen gates...",
	"The pressure sings, low and hollow...",
	"A threshold hums, just out of sight...",
	"The deep awaits. Almost ready..."
}

function Character.SpawnPlayer(_, player)
	if RunService:IsServer() and (player.Character or player.CharacterAdded:Wait()) and forPlayer(player):WaitForChild("Stats") then
		player.Character:WaitForChild("HumanoidRootPart")
		local v2 = nil
		local seamineTeleport = player:GetAttribute("SeamineTeleport")

		if seamineTeleport then
			v2 = CFrame.new(seamineTeleport) * CFrame.Angles(0, 4.71238898038469, 0)
			player:SetAttribute("SeamineTeleport", nil)
			local screenGui = Instance.new("ScreenGui")
			screenGui.Name = "SeamineBlackFade"
			screenGui.IgnoreGuiInset = true
			screenGui.ResetOnSpawn = false
			screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
			screenGui.DisplayOrder = 1000
			screenGui.Parent = player.PlayerGui
			local frame = Instance.new("Frame")
			frame.Size = UDim2.new(1, 0, 1, 0)
			frame.BackgroundColor3 = Color3.new(0, 0, 0)
			frame.BackgroundTransparency = 0
			frame.ZIndex = 1000
			frame.Parent = screenGui
			local tween = TweenService:Create(
				frame,
				TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
				{
					BackgroundTransparency = 0
				}
			)
			tween:Play()
			tween.Completed:Once(function()
				FischUtils.TeleportPlayer(player, v2)
				task.wait(2)
				local tween2 = TweenService:Create(
					frame,
					TweenInfo.new(8, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
					{
						BackgroundTransparency = 1
					}
				)
				tween2:Play()
				tween2.Completed:Once(function()
					screenGui:Destroy()
					tween:Destroy()
					tween2:Destroy()
				end)
			end)
		elseif player:GetAttribute("DeathZone") then
			local deathZone = player:GetAttribute("DeathZone")
			player:SetAttribute("DeathZone", nil)
			local tagged = CollectionService:GetTagged(deathZone .. "Spawn")

			if #tagged > 0 then
				local v3 = tagged[1].CFrame + createVector(0, 2.5, 0)
				FischUtils.TeleportPlayer(player, v3)
			end
		else
			local spawnLocation = WorldSpawns:GetSpawnLocation(player)
			local v3 = nil

			for _, v4 in spawnLocation do
				if v4.Name == player.Name then
					v3 = v4
				end
			end

			if v3 then
				spawnLocation = { v3 }
			else
				for i = #spawnLocation, 1, -1 do
					if spawnLocation[i].Name ~= "spawn" then
						table.remove(spawnLocation, i)
					end
				end
			end

			local nextSpawn = player:GetAttribute("NextSpawn") or remoteFunction:InvokeClient(player) or spawnLocation[math.random(#spawnLocation)].CFrame + createVector(
				0,
				2.5,
				0
			)
			player:SetAttribute("NextSpawn", nil)
			FischUtils.TeleportPlayer(player, nextSpawn)
		end

		fx:PlaySound(
			ReplicatedStorage.resources.sounds.sfx.player.spawn,
			player.Character:WaitForChild("HumanoidRootPart"),
			true
		)
		local clone = ReplicatedStorage.resources.replicated.fx.player_spawn:Clone()
		clone.Enabled = false
		clone.Parent = player.Character:FindFirstChild("HumanoidRootPart")
		clone:Emit(math.random(15, 36))
		debris:AddItem(clone, 2)
		local clone2 = ReplicatedStorage.resources.replicated.fx.player_spawnaura:Clone()
		clone2.Enabled = false
		clone2.Parent = player.Character:FindFirstChild("HumanoidRootPart")
		clone2:Emit(math.random(5, 15))
		debris:AddItem(clone2, 5)
		player:SetAttribute("SpawnFinished", true)
		player.Character:SetAttribute("SpawnFinished", true)
		local v3 = SharedPlayerStats.GetSubStat(player, "deaths", "Sea Mines") or 0
		local v4 = v3 >= 1 and v3 <= 24 and player:GetAttribute("DiedBySeamine") and v[v3]

		if v4 then
			ReplicatedStorage.events.anno_thought:FireClient(player, v4)
			player:SetAttribute("DiedBySeamine", nil)
		end
	end
end

function Character.Can(_, player)
	if not player.Character then
		return false
	end

	local character = player.Character

	if player:FindFirstChild("PlayerGui") then
		if not player:FindFirstChild("PlayerGui"):FindFirstChild("hud") then
			return false
		end

		local hud = player.PlayerGui:FindFirstChild("hud")

		if player.PlayerGui:FindFirstChild("backpack").Enabled == false and player.PlayerGui:GetAttribute("UiEnabled") then
			return false
		end

		if not (hud:WaitForChild("safezone"):FindFirstChild("bestiary").Visible ~= true and hud:WaitForChild("safezone"):FindFirstChild("equipment").Visible ~= true) then
			return false
		end
	end

	if not (character:FindFirstChild("HumanoidRootPart") and character:FindFirstChild("HumanoidRootPart").Anchored ~= true) then
		return false
	end

	if character:FindFirstChildWhichIsA("Tool") then
		local tool = character:FindFirstChildWhichIsA("Tool")

		if rods[tool.Name] and tool:FindFirstChild("bobber") then
			return false
		end
	end

	return true
end

function Character.UpdateLantern(_, player)
	if RunService:IsClient() == false and player.Character then
		local character = player.Character
		local v2, v3 = Character.PS(player)

		if v2 then
			if character:FindFirstChild("Lantern") then
				character:FindFirstChild("Lantern"):Destroy()
			end

			if v2:WaitForChild("Stats"):WaitForChild("hasbodylantern").Value == true and v2:WaitForChild("Stats"):WaitForChild("hasbodylantern"):WaitForChild("enabled").Value == true then
				local value = v2:WaitForChild("Stats"):WaitForChild("hasbodylantern"):WaitForChild("lanterntype").Value

				if value == "Random Lantern" then
					local v4 = {}
					local lanterns2 = v2.Lanterns

					if next(v3.Data.NewFormat.FavoritedEquipment.Lanterns) then
						for childName in v3.Data.NewFormat.FavoritedEquipment.Lanterns do
							if lanterns[childName] and lanterns2:FindFirstChild(childName) and childName ~= "Random Lantern" then
								table.insert(v4, childName)
							end
						end
					end

					if #v4 == 0 then
						for _, child in lanterns2:GetChildren() do
							if lanterns[child.Name] and child.Name ~= "Random Lantern" then
								table.insert(v4, child.Name)
							end
						end
					end

					if #v4 == 0 then
						return
					else
						value = v4[math.random(1, #v4)]
					end
				end

				local async = assets.getAsync("lantern", value)

				if not async then
					return
				end

				local clone = async:Clone()
				clone:AddTag("PlayerLantern")
				clone.Name = "Lantern"
				local rigidConstraint = Instance.new("RigidConstraint")
				rigidConstraint.Attachment0 = character:FindFirstChild("Torso"):FindFirstChild("BodyBackAttachment")
				rigidConstraint.Attachment1 = clone:FindFirstChild("Center"):FindFirstChild("WeldAttachment")
				rigidConstraint.Parent = clone
				clone.Parent = character

				for _, part in pairs(clone:GetChildren()) do
					if not part:IsA("BasePart") then
						continue
					end

					part.CanCollide = false
					part.CanTouch = false
					part.CanQuery = false
					part.Anchored = false
					part.Massless = true
				end

				local alternativeSound = clone:FindFirstChild("Center"):FindFirstChild("AlternativeSound")

				if alternativeSound then
					fx:PlaySound(alternativeSound, character:WaitForChild("HumanoidRootPart"), true)
				end

				fx:PlaySound(
					ReplicatedStorage:WaitForChild("resources"):WaitForChild("sounds"):WaitForChild("sfx"):WaitForChild("player"):WaitForChild("lanternequip"),
					character:WaitForChild("HumanoidRootPart"),
					true
				)
			end
		end
	end
end

function Character.GetBestiary(_, p, p2: string)
	return Bestiary:GetDiscoveryPercentages(p, p2, false)
end

return Character