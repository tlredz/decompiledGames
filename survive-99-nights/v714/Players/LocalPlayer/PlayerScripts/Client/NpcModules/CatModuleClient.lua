local CatModuleClient = {}
local localPlayer = game.Players.LocalPlayer
local Client = require(localPlayer.PlayerScripts.Client)
game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
TweenInfo.new(0.3)
local random = Random.new()
local _ = {
	Vertical = 45,
	Horizontal = 30,
	DelayTime = 0.5,
	Chance = 1
}
local flag = false
local v = -100

function FillCatChargeBar(p, p2)
	local serverTimeNow = workspace:GetServerTimeNow()

	if p2 < serverTimeNow then
		return
	end

	local v2 = p2 - serverTimeNow
	local clone = game.ReplicatedStorage.Assets.Interface.CatBillboard:Clone()
	clone.Parent = p
	clone.Adornee = p
	local frame = clone.Frame
	Client.TweenModule.new(function(p3)
		if not frame.Parent then
			return true
		end

		frame.RedHolder.Size = UDim2.new(1, 0, p3, 0)
		frame.RedHolder.RedFill.Size = UDim2.new(1, 0, 1 / p3, 0)
	end, v2):Play()
	task.spawn(function()
		task.wait(v2)
		clone:Destroy()
	end)
end

function SpawnCatLandingZone(cframe: CFrame, p: number, p2: number)
	local v2 = p - workspace:GetServerTimeNow()
	local clone = ReplicatedStorage.Assets.Alec.CatHitbox:Clone()

	if p2 then
		clone.Size = Vector3.new(p2 * 2, clone.Size.Y, p2 * 2)
	end

	clone:PivotTo(cframe * CFrame.new(0, -clone.Size.Y / 2, 0))
	clone.Parent = workspace.Particles
	task.spawn(function()
		wait(v2 + 0.5)

		if clone then
			print("DESTROY IT")
			clone:Destroy()
		end
	end)
end

Client.Events.CatPounce:Connect(function(instance, p, p2, p3, p4)
	if not instance then
		return
	end

	task.spawn(function()
		SpawnCatLandingZone(p, p3, p4)
	end)
	local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

	if not humanoidRootPart then
		return
	end

	humanoidRootPart.PrePounce:Play()
	local v2 = p2 - workspace:GetServerTimeNow()
	FillCatChargeBar(instance, p2)
	task.wait(v2)
	local v3 = p3 - workspace:GetServerTimeNow()

	if v3 < 0 then
		return
	end

	humanoidRootPart.Pounce:Play()
	local animations = instance:WaitForChild("Animations")
	animations:SetAttribute("PounceCharge", nil)
	animations:SetAttribute("Pounce", 1)
	local pivot = instance:GetPivot()
	local tweenModule = Client.TweenModule.new(function(p5)
		instance:PivotTo(pivot:Lerp(p, p5) + Vector3.new(0, 10 * (-(2 * p5 - 1) ^ 2 + 1), 0))
	end, v3)
	tweenModule:BindToComplete(function()
		animations:SetAttribute("PounceLand", 1)
		task.wait(0.1)
		animations:SetAttribute("Pounce", nil)
		task.wait(1)
		animations:SetAttribute("PounceLand", nil)
	end)
	tweenModule:Play()
end)

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

function CatAdded(instance)
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

Client.Utility.ForAllTagged("Cat", CatAdded)

function CatModuleClient.Init() end

return CatModuleClient