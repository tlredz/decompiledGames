local Emote = {}
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService")
local RunService = game:GetService("RunService")
local emotes = ReplicatedStorage:WaitForChild("resources"):WaitForChild("animations"):WaitForChild("emotes")
local npc = require(ReplicatedStorage.shared.modules:WaitForChild("character"):WaitForChild("npc"))
local fish = require(ReplicatedStorage.shared.modules:WaitForChild("library"):WaitForChild("fish"))
local legacyServices = ServerScriptService.server.legacyServices
local PlayerService = require(legacyServices.PlayerService)
local EmoteService = require(legacyServices.EmoteService)
ReplicatedStorage.events.CancelEmote.OnServerEvent:Connect(function(player)
	Emote:Cancel(player.Character, "all")
end)

function Emote:Cancel(instance, value: string)
	if not instance then
		return
	end

	local playerFromCharacter = Players:GetPlayerFromCharacter(instance)

	if playerFromCharacter then
		PlayerService.OnEmoteEnd:Fire(playerFromCharacter)
	end

	local humanoid = instance:FindFirstChildWhichIsA("Humanoid")

	if humanoid then
		for _, v in humanoid:GetPlayingAnimationTracks() do
			if string.lower(value) == "all" then
				if emotes:FindFirstChild((tostring(v))) then
					v:Stop()
				end
			elseif tostring(v) == value then
				v:Stop()
			end
		end

		if instance:FindFirstChild("EmoteModel") then
			instance:FindFirstChild("EmoteModel"):Destroy()
		end

		if instance:FindFirstChild("EmoteModel") then
			instance:FindFirstChild("EmoteModel"):Destroy()
		end

		if instance.Head:FindFirstChild("EmoteSound") then
			instance.Head:FindFirstChild("EmoteSound"):Destroy()
		end

		instance:SetAttribute("EmotingWalkSpeed", nil)

		if playerFromCharacter then
			ReplicatedStorage.events.UICompatibility:FireClient(playerFromCharacter, "emoteCancelHide")
		end

		local head = instance:FindFirstChild("Head")
		head.CanCollide = true
		instance:RemoveTag("emoting")
	end
end

local v = {
	Running = true,
	RunningNoPhysics = true,
	FallingDown = true
}

function Emote.Run(_, parent, childName: string)
	local v2 = true
	local playerFromCharacter = Players:GetPlayerFromCharacter(parent)
	local humanoid = parent:FindFirstChildWhichIsA("Humanoid")
	local animator = humanoid and (humanoid:FindFirstChildWhichIsA("Animator") or Instance.new("Animator", humanoid))
	local humanoidRootPart = parent:FindFirstChild("HumanoidRootPart")

	if not (playerFromCharacter and humanoid and humanoidRootPart and animator) then
		return
	end

	if not emotes:FindFirstChild(childName) then
		return
	end

	local humanoid2 = parent:FindFirstChildWhichIsA("Humanoid")

	if not humanoid2 or humanoid2.Health <= 0 or humanoid2.Sit then
		return
	end

	local tool = parent:FindFirstChildWhichIsA("Tool")

	if tool then
		if not fish[tool.Name] then
			return
		end

		if not (emotes:FindFirstChild(childName):GetAttribute("HideFish") and fish[parent:FindFirstChildWhichIsA("Tool").Name]) then
			local tool_2 = parent:FindFirstChildWhichIsA("Tool")
			tool_2.Parent = playerFromCharacter.Backpack
			Emote:Cancel(parent, "all")
		end
	end

	if humanoidRootPart:IsGrounded() or humanoidRootPart:FindFirstChild("Anchor") then
		return
	end

	if not v[humanoid2:GetState().Name] then
		Emote:Cancel(parent, "all")
	elseif emotes:FindFirstChild(childName) then
		if parent:HasTag("emoting") then
			Emote:Cancel(parent, "all")
		end

		local child = emotes:FindFirstChild(childName)

		if child:GetAttribute("Obtainable") == true and not EmoteService:Owns(playerFromCharacter, child.Name) then
			return
		end

		parent:AddTag("emoting")
		local track = animator:LoadAnimation(child)
		track.Priority = Enum.AnimationPriority.Action4
		track:Play()
		PlayerService.OnEmoteStart:Fire(playerFromCharacter, child)

		if child:FindFirstChild("EmoteModel") then
			local clone = child:FindFirstChild("EmoteModel"):Clone()
			clone.Parent = parent

			for _, part in clone:GetChildren() do
				local motor6D = part:FindFirstChildWhichIsA("Motor6D")

				if motor6D then
					if child.Name == "fan" then
						motor6D.Part0 = parent:FindFirstChild("Left Arm")
					else
						motor6D.Part0 = parent[motor6D:GetAttribute("WeldTo")]
					end

					motor6D.Part1 = part
				end

				if not part:IsA("BasePart") then
					continue
				end

				part.CanCollide = false
				part.CanTouch = false
				part.CanQuery = false
				part.Anchored = false
				part.Massless = true
			end
		end

		task.spawn(function()
			local lastTime = os.time()

			repeat
				task.wait()
			until not parent:FindFirstChildWhichIsA("Tool") or os.time() - lastTime > 20

			if parent:HasTag("emoting") then
				parent:SetAttribute("EmotingWalkSpeed", 0.01)
			end
		end)

		if child:FindFirstChild("EmoteSound") then
			local clone = child:FindFirstChild("EmoteSound"):Clone()
			clone.Playing = true
			clone.RollOffMaxDistance = 60
			clone.RollOffMinDistance = 10
			clone.Name = "EmoteSound"
			clone.Parent = parent.Head

			if clone.Looped == false then
				task.delay(clone.TimeLength / clone.PlaybackSpeed, function()
					v2 = false
					Emote:Cancel(parent, childName)
				end)
			end
		elseif child:FindFirstChild("TimeLength") then
			task.delay(child:FindFirstChild("TimeLength").Value, function()
				v2 = false
				Emote:Cancel(parent, childName)
			end)
		end

		if child:FindFirstChild("Says") then
			for _, v3 in Players:GetPlayers() do
				if not ((v3.Character.Head.Position - parent.Head.Position).Magnitude <= 20) then
					continue
				end

				local v4 = {
					leavemessages = { "-" },
					maxdistance = 50,
					dialog = {
						{
							text = tostring(child:FindFirstChild("Says").Value),
							t = 0.3,
							choices = {}
						}
					}
				}
				local v5 = {
					npc = parent,
					voice = 3
				}
				npc:StartDialog(v5, v5.npc.Head, v3, v4)
			end
		end

		if playerFromCharacter then
			ReplicatedStorage.events.UICompatibility:FireClient(playerFromCharacter, "emoteCancelShow")
		end

		local head = parent:FindFirstChild("Head")
		head.CanCollide = false

		while parent.Parent and humanoid.Parent and parent:HasTag("emoting") and v2 == true do
			debug.profilebegin("emote::Update")

			if humanoid.Health <= 0 or humanoid.Sit == true or not v[humanoid:GetState().Name] or humanoidRootPart:IsGrounded() or humanoidRootPart:FindFirstChild("Anchor") then
				v2 = false
				Emote:Cancel(parent, "all")
				break
			else
				local tool2 = parent:FindFirstChildWhichIsA("Tool")

				if tool2 then
					if emotes:FindFirstChild(childName):GetAttribute("HideFish") and fish[tool2.Name] then
						parent:SetAttribute("EmotingWalkSpeed", 0.01)
					else
						tool2.Parent = playerFromCharacter.Backpack
						Emote:Cancel(parent, "all")
						break
					end
				end

				if emotes:FindFirstChild(childName):GetAttribute("HideFish") and not parent:FindFirstChildWhichIsA("Tool") then
					v2 = false
					Emote:Cancel(parent, "all")
					ReplicatedStorage.events.anno_thought:FireClient(
						playerFromCharacter,
						"Hold out a fish to display this emote!"
					)
					break
				else
					debug.profileend()
					RunService.Heartbeat:Wait()
				end
			end
		end
	elseif childName == "stop" and parent:HasTag("emoting") then
		Emote:Cancel(parent, "all")
	end
end

return Emote