wait(1)

repeat
	wait()
until game.Players.LocalPlayer

local localPlayer = game.Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local currentCamera = workspace.CurrentCamera
local mouse = localPlayer:GetMouse()
local character = localPlayer.Character
local humanoidRootPart = character.HumanoidRootPart
local ChatDialogue = require(ReplicatedStorage2.Chest.Modules.ChatDialogue)
character:waitForChild("Humanoid"):SetStateEnabled("FallingDown", false)

ReplicatedStorage2.Chest.Remotes.Functions.RemoteClient.OnClientInvoke = function()
	mouse.TargetFilter = workspace.Effects
	return mouse.Hit
end

ReplicatedStorage2.Chest.Remotes.Functions.GetMTarget.OnClientInvoke = function()
	mouse.TargetFilter = workspace.Effects
	return mouse.Hit, mouse.Target
end

function IsInBox(p)
	local v = humanoidRootPart.CFrame:Inverse() * p
	local v2 = character:GetExtentsSize().Y * 2
	local X = math.abs(v.X)
	local Y = math.abs(v.Y)
	local Z = math.abs(v.Z)

	if X < 15 and Y < math.abs(v2) and Z < 15 then
		return true
	end
end

function GetQuestNPC(player)
	local character2 = player.Character
	local _ = player.RootPart
	local _ = character2:GetExtentsSize().Y

	for _, part in pairs(workspace.AllNPC:GetChildren()) do
		if part:IsA("BasePart") and IsInBox(part.Position) then
			return part
		end
	end

	return nil
end

_G.RichTextSkipped = nil
local v = true
mouse.Button1Down:Connect(function()
	local mainGui = localPlayer.PlayerGui:FindFirstChild("MainGui")

	if not mainGui then
		return
	end

	if UserInputService.TouchEnabled then
		local mouseLocation = UserInputService:GetMouseLocation()

		if _G.IsInSticks({
			Position = mouseLocation
		}) then
			return
		end
	end

	if (currentCamera.CFrame.Position - humanoidRootPart.Position).Magnitude > 80 or _G.CheckDoingClient(localPlayer) then
		return
	end

	local v2 = GetQuestNPC({
		Character = character,
		RootPart = humanoidRootPart
	})

	if not (v2 and v) then
		return
	end

	v = false

	if not _G.NPCTalk then
		_G.NPCTalk = true

		if ChatDialogue[v2.Name] then
			if ChatDialogue[v2.Name] then
				local dialogue = mainGui:FindFirstChild("Dialogue")

				if dialogue and dialogue:FindFirstChild("DialogueModule") then
					local DialogueModule = require(dialogue.DialogueModule)
					DialogueModule.Init(v2.Name)
				end
			end
		elseif ReplicatedStorage.Chest.Remotes.Functions.CheckQuest:InvokeServer(v2) == "Cancel NPCTalk" then
			_G.NPCTalk = false
		end
	end

	task.spawn(function()
		task.wait(0.25)
		v = true
	end)
end)