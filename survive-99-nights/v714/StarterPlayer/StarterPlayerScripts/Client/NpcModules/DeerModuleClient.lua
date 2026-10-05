local DeerModuleClient = {}
local localPlayer = game.Players.LocalPlayer
local Client = require(localPlayer.PlayerScripts.Client)
game:GetService("TweenService")
TweenInfo.new(0.3)
local random = Random.new()
local flag = false
local v = -100

function FlickerFlashlight()
	if time() - v < 10 then
		return
	end

	local currentlyEquippedClass = Client.InventoryHandler.GetCurrentlyEquippedClass()

	if currentlyEquippedClass and currentlyEquippedClass.Model and currentlyEquippedClass.Model:GetAttribute("ToolName") == "Flashlight" then
		v = time()
		currentlyEquippedClass.Tool:Flicker()
	end
end

function DeerAggroPlayer(instance)
	if flag then
		return
	end

	flag = true

	if not instance.Parent then
		return
	end

	local nPCTarget = instance:FindFirstChild("NPCTarget")

	if not nPCTarget then
		return
	end

	FlickerFlashlight()

	while nPCTarget.Value == localPlayer.Character and instance.Parent ~= nil do
		wait(1)

		if random:NextInteger(1, 10) == 1 then
			FlickerFlashlight()
		end
	end

	flag = false
end

function DeerAdded(instance)
	if instance.Parent ~= workspace.Characters then
		return
	end

	if not instance.PrimaryPart then
		repeat
			task.wait()
		until instance.PrimaryPart
	end

	instance.PrimaryPart.Touched:Connect(function(otherPart)
		if otherPart.Name == "TorchTouchZone" then
			print("Deer touched by torch")
			Client.Events.MonsterHitByTorch:InvokeServer(instance)
		end
	end)
	task.spawn(function()
		local nPCTarget = instance:WaitForChild("NPCTarget")
		nPCTarget.Changed:Connect(function()
			if nPCTarget.Value == localPlayer.Character then
				DeerAggroPlayer(instance)
			end
		end)

		if nPCTarget.Value == localPlayer.Character then
			DeerAggroPlayer(instance)
		end
	end)
end

Client.Utility.ForAllTagged("Deer", DeerAdded)

function DeerModuleClient.Init() end

return DeerModuleClient