local createVector = vector.create
local localPlayer = game.Players.LocalPlayer
local Client = require(localPlayer.PlayerScripts.Client)
game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UtilityAlec = require(ReplicatedStorage.Modules.UtilityAlec)
local clone = nil
local flag = false
local track = nil
local track2 = nil
local track3 = nil

function FuelBurned(p)
	if not p or flag then
		return
	end

	local fuel = clone:GetAttribute("Fuel")
	local v = math.clamp(fuel / 10000, 0, 1)
	p.Frame.Fill.Size = UDim2.new(v, 0, 1, 0)
	p.Enabled = true

	if fuel >= 10000 then
		p.Frame.TextLabel.Text = "COMPLETE"
	end
end

Client.Events.FuelGemMachine:Connect(function(p)
	if flag then
		return
	end

	if clone then
		clone.PrimaryPart.FuelAdded:Play()
		clone:SetAttribute("Fuel", clone:GetAttribute("Fuel") + p)

		for _, emitter in pairs(clone.Hole.Part:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter:Emit(emitter:GetAttribute("EmitCount") or 1)
			end
		end
	end
end)
Client.Events.SpawnGemMachine:Connect(function()
	clone = script.MachineV2:Clone()
	clone:PivotTo(clone:GetPivot() - createVector(0, 40, 0))
	clone.Parent = workspace

	for _, child in pairs(clone.Animations:GetChildren()) do
		UtilityAlec.GetAnimationLength(child)
	end

	track = clone.AnimationController.Animator:LoadAnimation(clone.Animations.StartUp)
	track2 = clone.AnimationController.Animator:LoadAnimation(clone.Animations.Loop)
	track3 = clone.AnimationController.Animator:LoadAnimation(clone.Animations.OffLoop)
	track3:Play()
	wait(6)
	Client.PopUpUI.AddPopUp("A mysterious machine has spawned near the Missing Posters", "orange")
	task.spawn(function()
		wait(7)
		Client.PopUpUI.AddPopUp("it needs fuel...", "orange")
	end)
	clone:PivotTo(clone:GetPivot() + createVector(0, 40, 0))
	local touchPart = clone.Hole.TouchPart

	if touchPart:FindFirstChild("BillboardGui") then
		local billboardGui = touchPart:FindFirstChild("BillboardGui")
		billboardGui.Enabled = true
	end

	touchPart.Touched:Connect(function(otherPart)
		if otherPart.Parent and otherPart.Parent:GetAttribute("BurnFuel") then
			Client.Events.SpawnGemFueled:FireServer(otherPart.Parent)
		end
	end)
	clone:GetAttributeChangedSignal("Fuel"):Connect(function()
		clone:GetAttribute("Fuel")

		if clone and touchPart then
			FuelBurned(touchPart:FindFirstChild("BillboardGui"))
		end
	end)
end)
Client.Events.ExplodeGemMachine:Connect(function()
	if not clone then
		return
	end

	local billboardGui = clone.Hole.TouchPart:FindFirstChild("BillboardGui")

	if not billboardGui then
		return
	end

	flag = true
	billboardGui.Frame.Fill.Size = UDim2.new(1, 1, 1, 1)
	billboardGui.Frame.TextLabel.Text = "COMPLETE"
	local animationLength = UtilityAlec.GetAnimationLength(clone.Animations.StartUp)
	wait(5)
	billboardGui.Enabled = false
	track3:Stop()

	for _, effect in pairs(clone:GetDescendants()) do
		if effect:IsA("Trail") or effect:IsA("Beam") then
			effect.Enabled = true
		end
	end

	clone.Diamond.Transparency = 0

	for _, child in pairs(clone.Diamond.Charge:GetChildren()) do
		child.Enabled = true
	end

	clone.Stars.Stars.Enabled = true
	track:Play()
	clone.PrimaryPart.StartUp:Play()
	wait(animationLength - 0.05)
	track2:Play()
	clone.PrimaryPart.MachineLoop:Play()
	wait(10)
	Client.PopUpUI.AddAdminAbuseMessage("2x DIAMONDS WEEKEND HAS BEGUN!!!", nil, Color3.fromRGB(0, 251, 255), 20)
	wait(6)
	Client.PopUpUI.AddAdminAbuseMessage("JOIN A NEW LOBBY IN THE MAIN GAME", nil, Color3.fromRGB(0, 251, 255), 20)
	wait(6)
	Client.PopUpUI.AddAdminAbuseMessage(
		"GET 2X DIAMONDS FROM CHESTS AND FOR SURVIVING 100 AND 50 DAYS!",
		nil,
		Color3.fromRGB(0, 251, 255),
		20
	)
end)
return {}