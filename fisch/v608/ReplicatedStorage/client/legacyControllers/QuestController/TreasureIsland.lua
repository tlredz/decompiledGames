game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local legacyControllers = ReplicatedStorage.client.legacyControllers
local localPlayer = Players.LocalPlayer
local packages = ReplicatedStorage.packages
local _ = ReplicatedStorage.shared.modules
local WorldController = require(legacyControllers.WorldController)

if WorldController:GetCurrentWorldIndex() ~= "Sea 1" then
	return {}
end

local FollowingNpcController = require(legacyControllers.FollowingNpcController)
local Net = require(packages.Net)
local Observers = require(packages.Observers)
require(packages.SimplePath)
local remoteEvent = Net:RemoteEvent("TreasureIslandQuest/NpcStatus")
local sittingDialogueStatusTable = {
	chance = 90,
	dialogues = {
		"Ugh, it's slimy!",
		"I stepped on something... squishy.",
		"Disgusting! Absolutely disgusting!",
		"The smell... it's unbearable!",
		"Why is it so wet in here?",
		"Did it just... move?",
		"I’m going to throw up.",
		"This is worse than I imagined.",
		"My nose is crying!",
		"It stinks! Make it stop!",
		"Something dripped on me!",
		"I regret everything!",
		"Are we there yet?!",
		"I can taste the air... and it’s awful!",
		"This place is a nightmare.",
		"I think I sat on a tongue...",
		"Are we almost there? I can't stand being in here anymore!",
		"What a weird place, when are we going to leave?",
		"The smell in here is killing me!!!"
	}
}
return {
	currentFollowingNpc = nil,
	npcStatus = "NotRescued",
	Start = function(self)
		local v2 = nil
		local v3 = nil
		Observers.observeTag("CrazyManNpc", function(p)
			if p.Name == "Crazy Man" then
				v2 = p

				if self.npcStatus == "NotRescued" then
					p.Parent = workspace.world.npcs
				elseif self.npcStatus == "InProgress" or self.npcStatus == "Rescued" then
					p.Parent = ReplicatedStorage
				end
			elseif p.Name == "Crazy Man Rescued" then
				v3 = p

				if self.npcStatus == "Rescued" then
					p.Parent = workspace.world.npcs
				elseif self.npcStatus == "InProgress" or self.npcStatus == "NotRescued" then
					p.Parent = ReplicatedStorage
				end
			end

			return nil
		end)
		local v4 = nil
		Observers.observeTag("TreasureRod", function(p)
			v4 = p

			if self.npcStatus == "Rescued" then
				p.Parent = workspace.world.interactables
			else
				p.Parent = ReplicatedStorage
			end

			return nil
		end)

		local function updateStatus(npcStatus: string, options)
			self.npcStatus = npcStatus
			local v5 = options or {}

			if v2 then
				v2.Parent = ReplicatedStorage

				if npcStatus == "NotRescued" then
					v2.Parent = workspace.world.npcs
				end
			end

			if v3 then
				v3.Parent = ReplicatedStorage

				if npcStatus == "Rescued" then
					v3.Parent = workspace.world.npcs
				end
			end

			if v4 then
				v4.Parent = ReplicatedStorage

				if npcStatus == "Rescued" then
					v4.Parent = workspace.world.interactables
				end
			end

			if npcStatus == "InProgress" then
				if self.currentFollowingNpc then
					return
				end

				local crazyMan = FollowingNpcController:New("Crazy Man", {
					doNotAnimateFirstTime = true,
					firstSpawn = v5.spawnPosition
				}, {
					GetUpAfterTeleport = true,
					SitWhenPlayerSeat = false,
					SittingDialogueStatusTable = sittingDialogueStatusTable
				})

				if not crazyMan then
					return
				end

				self.currentFollowingNpc = crazyMan
				crazyMan.npcStatus = FollowingNpcController.Status.Idle
				local customTarget = nil

				local function setUpNpc(currentNpc)
					if not currentNpc then
						return
					end

					local humanoidRootPart = currentNpc:WaitForChild("HumanoidRootPart")
					currentNpc:WaitForChild("Humanoid")
					local head = currentNpc:WaitForChild("Head")

					if not crazyMan._currentTrove then
						return
					end

					local finalPosition = v5.finalPosition

					if not finalPosition then
						return
					end

					local v7 = Observers.observeTag("CrazyNpcWhaleSeat", function(p)
						customTarget = p
						return function()
							customTarget = nil
						end
					end)
					crazyMan._trove:Add(function()
						v7()
					end)
					local poiBeam = currentNpc:FindFirstChild("poiBeam")
					local poiAttachment = humanoidRootPart:FindFirstChild("poiAttachment")

					if poiBeam and poiAttachment then
						local sporeyDestination = workspace:FindFirstChild("SporeyDestination")

						if sporeyDestination then
							sporeyDestination:Destroy()
						end

						local parent = crazyMan._currentTrove:Add(Instance.new("Model"))
						parent.Name = "SporeyDestination"
						parent.ModelStreamingMode = Enum.ModelStreamingMode.Persistent
						parent.Parent = workspace
						local part = Instance.new("Part")
						part.Transparency = 1
						part.CFrame = finalPosition
						part.Anchored = true
						part.CanCollide = false
						part.CanQuery = false
						part.CanTouch = false
						part.Parent = parent
						local attachment = Instance.new("Attachment")
						attachment.Parent = part
						poiBeam.Attachment0 = poiAttachment
						poiBeam.Attachment1 = attachment
					end

					local humanoidRootPart2 = (localPlayer.Character or localPlayer.CharacterAdded:Wait()):FindFirstChild("HumanoidRootPart")
					local v8 = false
					local total = 0
					crazyMan._currentTrove:Connect(RunService.RenderStepped, function(p: number)
						total += p

						if total < 0.3333333333333333 then
							return
						end

						total = 0

						if customTarget and crazyMan.npcStatus ~= crazyMan.Status.Seated and crazyMan.npcStatus ~= crazyMan.Status.Spawning then
							local magnitude = (humanoidRootPart.Position - customTarget.Position).Magnitude

							if magnitude <= 80 and not v8 then
								local face = head and head:FindFirstChild("face")

								if face then
									face.Texture = "http://www.roblox.com/asset/?id=20909031"
								end

								v8 = true
								crazyMan.focused = true
								crazyMan.customTarget = customTarget
								crazyMan.customMinDistance = 1
							elseif magnitude <= 6 then
								crazyMan.focused = false
								crazyMan.customTarget = nil
								crazyMan.customMinDistance = nil
								crazyMan:Seat(customTarget)
							end
						end

						if (humanoidRootPart2.Position - finalPosition.Position).Magnitude > 25 then
						end
					end)
				end

				setUpNpc(crazyMan.currentNpc)
				crazyMan.OnSpawned:Connect(setUpNpc)

				if not v5.firstInteraction then
					return
				end

				crazyMan:LoadDialogue(nil, nil, "Thank you for believing in me!")
				task.wait(1)

				if not crazyMan.Status then
					return
				end

				crazyMan.npcStatus = FollowingNpcController.Status.Following
			elseif self.currentFollowingNpc then
				self.currentFollowingNpc:Destroy()
			end
		end

		self.npcStatus = "NotRescued"

		if v2 then
			v2.Parent = ReplicatedStorage
			v2.Parent = workspace.world.npcs
		end

		if v3 then
			v3.Parent = ReplicatedStorage
		end

		if v4 then
			v4.Parent = ReplicatedStorage
		end

		if self.currentFollowingNpc then
			self.currentFollowingNpc:Destroy()
		end

		remoteEvent.OnClientEvent:Connect(updateStatus)
	end
}