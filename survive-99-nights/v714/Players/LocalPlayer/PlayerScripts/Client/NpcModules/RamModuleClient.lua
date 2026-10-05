local RamModuleClient = {}
local localPlayer = game.Players.LocalPlayer
local Client = require(localPlayer.PlayerScripts.Client)
game:GetService("TweenService")
TweenInfo.new(0.3)
local random = Random.new()
local v = {
	Vertical = 45,
	Horizontal = 30,
	DelayTime = 0.5,
	Chance = 1
}
local flag = false
local v2 = -100
Client.Events.FillRamChargeBar:Connect(function(p, p2)
	local serverTimeNow = workspace:GetServerTimeNow()

	if p2 < serverTimeNow then
		return
	end

	local v3 = p2 - serverTimeNow
	local clone = game.ReplicatedStorage.Assets.Interface.RamBillboard:Clone()
	clone.Parent = p
	clone.Adornee = p
	Client.TweenModule.new(function(p3)
		if not clone.Parent then
			return true
		end

		clone.Frame.RedHolder.Size = UDim2.new(1, 0, p3, 0)
		clone.Frame.RedHolder.RedFill.Size = UDim2.new(1, 0, 1 / p3, 0)
	end, v3):Play()
	task.wait(v3 + 1)
	clone:Destroy()
end)

function FlickerFlashlight()
	if time() - v2 < 10 then
		return
	end

	local currentlyEquippedClass = Client.InventoryHandler.GetCurrentlyEquippedClass()

	if currentlyEquippedClass and currentlyEquippedClass.Model and currentlyEquippedClass.Model:GetAttribute("ToolName") == "Flashlight" then
		v2 = time()
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

function ConnectRamTouchZone(instance)
	local chargeActive = false
	local v3 = false
	instance:GetAttributeChangedSignal("ChargeActive"):Connect(function()
		chargeActive = instance:GetAttribute("ChargeActive")

		if not chargeActive then
			v3 = false
		end
	end)
	chargeActive = instance:GetAttribute("ChargeActive")
	instance:WaitForChild("Charge_PlayerTouchZone").Touched:Connect(function(otherPart)
		if chargeActive and not v3 and otherPart.Parent == localPlayer.Character then
			v3 = true
			Client.Events.KnockbackPlayer:Fire(instance, v, workspace:GetServerTimeNow() + 0.1)
			Client.Events.RamChargePlayer:FireServer(instance)
			Client.CamShake.ShakeOnce(2.3, 20, 0.1, 0.4)
		end
	end)
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

	ConnectRamTouchZone(instance)
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

Client.Utility.ForAllTagged("Ram", DeerAdded)

function RamModuleClient.Init() end

return RamModuleClient