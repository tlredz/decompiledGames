local createVector = vector.create
local CaveInstanceClient = {}
local localPlayer = game.Players.LocalPlayer
local Client = require(localPlayer.PlayerScripts.Client)
local random = Random.new()
local TweenService = game:GetService("TweenService")
local count = 0

function FadeBack(value)
	local caveFadeScreen = Client.Interface.CaveFadeScreen
	local v = value or 0.5
	TweenService:Create(caveFadeScreen, TweenInfo.new(v), {
		BackgroundTransparency = 1
	}):Play()
	task.wait(v + 0.1)
	caveFadeScreen.Visible = false
end

function FadeToColour(backgroundColor: Color3, value: number)
	local caveFadeScreen = Client.Interface.CaveFadeScreen
	caveFadeScreen.BackgroundTransparency = 1
	caveFadeScreen.BackgroundColor3 = backgroundColor
	caveFadeScreen.Visible = true
	count += 1
	TweenService:Create(caveFadeScreen, TweenInfo.new(value or 0.5), {
		BackgroundTransparency = 0
	}):Play()
end

function Rand(p, p2)
	return p + random:NextNumber() * (p2 - p)
end

function AnimateDetonator(instance)
	instance:SetAttribute("Detonated", true)
	print("KABOOOOOM")
	task.delay(8, function()
		instance:Destroy()
	end)
	local rockfall = instance.Rockfall
	local primaryPart = rockfall.PrimaryPart

	if primaryPart:FindFirstChild("ArmSound") then
		primaryPart.ArmSound:Play()
	end

	task.wait(0.75)

	if primaryPart:FindFirstChild("ExplodeSound") then
		primaryPart.ExplodeSound:Play()
	end

	Client.Utility.RunParticles(primaryPart)
	Client.CamShake.ShakeOnce(5, 25, 0.1, 0.4)
	local position = primaryPart.Position

	for _, child in pairs(rockfall:GetChildren()) do
		if child.Name ~= "Rock" then
			continue
		end

		for _ = 1, random:NextInteger(3, 5) do
			local clone = child:Clone()
			clone.Size = child.Size * Rand(0.1, 0.35)
			clone.CFrame = child.CFrame + Vector3.new(Rand(-2, 2), Rand(-2, 2), Rand(-2, 2))
			clone.Anchored = false
			clone.Parent = workspace.Particles
			clone:ApplyImpulse((clone.Position - position).Unit * random:NextInteger(250, 280) * clone:GetMass())
			task.delay(Rand(5, 7), function()
				clone:Destroy()
			end)
		end

		child:Destroy()
	end
end

Client.Events.AnimateCaveDetonator:Connect(AnimateDetonator)

function LocalAnimateDetonator(instance)
	if instance:GetAttribute("LeverPushed") == nil then
		instance:SetAttribute("LeverPushed", true)
		local lever = instance.Detonator.Lever
		local pivot = lever:GetPivot()
		Client.TweenModule.new(function(p)
			lever:PivotTo(pivot - Vector3.new(0, 2 * p, 0))
		end, 0.15):Play()
	end

	print("click")
	local proximityInteraction = instance.PrimaryPart.ProximityAttachment.ProximityInteraction
	proximityInteraction.Enabled = false
	task.delay(10, function()
		if proximityInteraction.Parent then
			proximityInteraction.Enabled = true
		end
	end)
end

function CaveInstanceClient.TriggerDetonator(instance)
	if instance:GetAttribute("Detonated") or not instance.Parent:GetAttribute("Unlocked") then
		return
	end

	LocalAnimateDetonator(instance)
	Client.Events.RequestDetonateCaveEntrance:FireServer(instance)
end

function CaveInstanceClient.PopUpWarning()
	Client.PopUpUI.AddPopUp("You won't be able to re-enter until everyone else leaves. Are you sure?", "warning", 9)
end

function CaveInstanceClient.TeleportTo(value: string)
	if localPlayer:GetAttribute("CaveTeleporting") then
		return
	end

	if workspace:GetAttribute("CaveResetting") or workspace:GetAttribute("CavesLocked") then
		Client.PopUpUI.AddPopUp("Caves are currently locked", "warning")
		return
	end

	if localPlayer:GetAttribute("LastCaveExit") and localPlayer:GetAttribute("LastCaveExit") > (workspace:GetAttribute("LastCaveReset") or 0) then
		Client.PopUpUI.AddPopUp("You can't re-enter an active cave", "warning")
		return
	end

	local v = "CaveTeleport_" .. value
	local attribute = workspace:GetAttribute(v)

	if not attribute then
		Client.PopUpUI.AddPopUp("This cave section is blocked", "warning")
	elseif string.sub(value, 1, 4) == "Exit" and (attribute.Position * createVector(1, 0, 1)).Magnitude > (workspace:GetAttribute("MapRange") or 100) then
		Client.PopUpUI.AddPopUp("You have not expanded the fire enough yet", "warning")
	elseif string.sub(value, 1, 4) == "Exit" and localPlayer:GetAttribute("CaveExitWarning") == nil then
		localPlayer:SetAttribute("CaveExitWarning", true)
		CaveInstanceClient.PopUpWarning()
	else
		localPlayer:SetAttribute("CaveTeleporting", true)
		local v2

		if string.sub(value, 1, 4) == "Exit" then
			v2 = Client.TeleportingClient.AnimateTeleportScreen({
				CoverType = "Forest",
				FadeDelay = 0,
				FadeDuration = 0.5,
				FadeColour = Color3.fromRGB(255, 255, 255),
				PreloadLighting = "Forest"
			})
		else
			v2 = Client.TeleportingClient.AnimateTeleportScreen({
				CoverType = "Cave",
				FadeDelay = 0,
				FadeDuration = 0.5,
				PreloadLighting = "Cave"
			})
		end

		local v3 = nil
		task.spawn(function()
			local v4 = workspace:GetServerTimeNow() + 0.5
			v3 = Client.Events.RequestCaveTeleport:InvokeServer(value, v4)
		end)
		task.wait(0.9)

		if not v3 then
			local total = 0

			while total < 2 and v3 == nil do
				total += task.wait()
			end
		end

		Client.Events.CloseMap:Fire()

		if v2 then
			v2()
		end

		task.wait(0.5)
		localPlayer:SetAttribute("CaveTeleporting", nil)
	end
end

return CaveInstanceClient