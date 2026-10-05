local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local legacyControllers = ReplicatedStorage.client.legacyControllers
local localPlayer = Players.LocalPlayer
local packages = ReplicatedStorage.packages
local _ = ReplicatedStorage.shared.modules
local FollowingNpcController = require(legacyControllers.FollowingNpcController)
local Net = require(packages.Net)
local Observers = require(packages.Observers)
require(packages.SimplePath)
local remoteEvent = Net:RemoteEvent("MycoReunionQuest/NpcStatus")
local remoteEvent2 = Net:RemoteEvent("MycoReunionQuest/NpcArrive")
local v = {
	chance = 90,
	dialogues = { "Heelp! I’m gonna drown!", "Heeelp", "Aaaah I’m gonna die!" }
}
return {
	currentFollowingNpc = nil,
	npcStatus = "NotRescued",
	Start = function(self)
		local v2 = nil
		local v3 = nil
		Observers.observeTag("Sporey", function(p)
			if p.Name == "Sporey" then
				v2 = p

				if self.npcStatus == "NotRescued" then
					p.Parent = workspace.world.npcs
				elseif self.npcStatus == "InProgress" or self.npcStatus == "Rescued" then
					p.Parent = ReplicatedStorage
				end
			elseif p.Name == "Sporey Rescued" then
				v3 = p

				if self.npcStatus == "Rescued" then
					p.Parent = workspace.world.npcs
				elseif self.npcStatus == "InProgress" or self.npcStatus == "NotRescued" then
					p.Parent = ReplicatedStorage
				end
			end

			return nil
		end)

		local function updateStatus(npcStatus: string, options)
			self.npcStatus = npcStatus
			local v4 = options or {}

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

			if npcStatus == "InProgress" then
				if self.currentFollowingNpc then
					return
				end

				local sporey = FollowingNpcController:New("Sporey", {
					doNotAnimateFirstTime = true,
					firstSpawn = v4.spawnPosition,
					Costs = {
						Water = 1e999
					}
				})

				if not sporey then
					return
				end

				self.currentFollowingNpc = sporey
				sporey.npcStatus = FollowingNpcController.Status.Idle

				local function setUpNpc(currentNpc)
					if not currentNpc then
						return
					end

					local humanoidRootPart = currentNpc:WaitForChild("HumanoidRootPart")
					local humanoid = currentNpc:WaitForChild("Humanoid")

					if not sporey._currentTrove then
						return
					end

					local now = 0
					sporey._currentTrove:Connect(humanoid.Swimming, function()
						if os.clock() - now < 20 then
							return
						end

						sporey:LoadDialogue(nil, v)
						now = os.clock()
					end)
					local finalPosition = v4.finalPosition

					if not finalPosition then
						return
					end

					local poiBeam = currentNpc:FindFirstChild("poiBeam")
					local poiAttachment = humanoidRootPart:FindFirstChild("poiAttachment")

					if poiBeam and poiAttachment then
						local sporeyDestination = workspace:FindFirstChild("SporeyDestination")

						if sporeyDestination then
							sporeyDestination:Destroy()
						end

						local parent = sporey._currentTrove:Add(Instance.new("Model"))
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
					local flag = false
					local flag2 = false
					local total = 0
					sporey._currentTrove:Connect(RunService.RenderStepped, function(p: number)
						if flag then
							return
						end

						total += p

						if total < 0.3333333333333333 then
							return
						end

						total = 0

						if flag2 then
							if (humanoidRootPart.Position - finalPosition.Position).Magnitude > 3.5 then
								return
							end

							remoteEvent2:FireServer(true)
							flag = true
						else
							if (humanoidRootPart2.Position - finalPosition.Position).Magnitude > 25 then
								return
							end

							if poiBeam and poiBeam.Parent then
								poiBeam:Destroy()
							end

							remoteEvent2:FireServer()
							flag2 = true
							sporey.focused = true
							sporey.customTarget = finalPosition
							sporey.customMinDistance = 1
						end
					end)
				end

				setUpNpc(sporey.currentNpc)
				sporey.OnSpawned:Connect(setUpNpc)

				if not v4.firstInteraction then
					return
				end

				sporey:LoadDialogue(nil, nil, "Thank you!")
				task.wait(1)

				if not sporey.Status then
					return
				end

				sporey.npcStatus = FollowingNpcController.Status.Following
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

		if self.currentFollowingNpc then
			self.currentFollowingNpc:Destroy()
		end

		remoteEvent.OnClientEvent:Connect(updateStatus)
	end
}