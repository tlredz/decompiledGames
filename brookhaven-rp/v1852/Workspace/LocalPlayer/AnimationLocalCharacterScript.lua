local ReplicatedStorage = game:GetService("ReplicatedStorage")
local game8Settings = game.Players.LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("Player8Handler"):WaitForChild("Game8Settings")
local module = require(game8Settings)
local UserInputService = game:GetService("UserInputService")
local animationFireClient = module.AnimationFireClient
local marker = game.Workspace.WorkspaceCom["000_AnimationMarker"]:WaitForChild("Marker")
local ContextActionService = game:GetService("ContextActionService")
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local child = workspace:WaitForChild(localPlayer.Name)
local humanoid = child:WaitForChild("Humanoid")
local marker2 = game.Workspace.WorkspaceCom["000_AnimationMarker"]:WaitForChild("Marker")
local textLabel = marker2.GUI.TextLabel.ImageLabel.Selected.TextLabel
local housePart = script:WaitForChild("HousePart")
local playerGui = game.Players.LocalPlayer:WaitForChild("PlayerGui")
local mainGUIHandler = playerGui:WaitForChild("MainGUIHandler")
local client2Client = mainGUIHandler:WaitForChild("Client2Client")
local menu = mainGUIHandler:WaitForChild("Menu")
local client2ClientAccept = client2Client:WaitForChild("Client2ClientAccept")
local CollectionService = game:GetService("CollectionService")
local tagged = CollectionService:GetTagged("001Animations")
local animationPlaying = playerGui:WaitForChild("Player8Handler"):WaitForChild("AnimationPlaying")
local ConsoleControls = require(ReplicatedStorage.Modules.Client.Input.ConsoleControls)
local RPAnimation = require(ReplicatedStorage.Modules.Client.Components.Housing.Objects.RPAnimation)
local seat2 = nil
local v = false
local v2 = false
local v3 = false
local v4 = false
local v5 = false
ContextActionService:UnbindAction("SitRequest", SitRequest, false, Enum.KeyCode.E)
ContextActionService:UnbindAction("JumpRequest", JumpRequest, false, Enum.KeyCode.Space)
marker2.GUI.TextLabel.Visible = true
marker2.ClickDetector.MaxActivationDistance = 20
textLabel:SetAttribute("ConsoleGlyphKeyCode", "ButtonX")

if not textLabel:HasTag("ConsoleGlyphImage") then
	textLabel:AddTag("ConsoleGlyphImage")
end

CollectionService:GetInstanceAddedSignal("001Animations"):Connect(function(p)
	table.insert(tagged, p)
end)
CollectionService:GetInstanceRemovedSignal("001Animations"):Connect(function(_)
	tagged = CollectionService:GetTagged("001Animations")
end)
local jumpingConnection = nil
local jumpRequestConnection = nil
local jumpRequestConnection2 = nil

local function stopCurrentAnimation()
	if v5 == false then
		return
	end

	humanoid.Sit = false

	if jumpingConnection then
		jumpingConnection:disconnect()
		jumpingConnection = nil
	end

	if jumpRequestConnection then
		jumpRequestConnection:disconnect()
		jumpRequestConnection = nil
	end

	if jumpRequestConnection2 then
		jumpRequestConnection2:disconnect()
		jumpRequestConnection2 = nil
	end

	ContextActionService:UnbindAction("JumpRequest")

	if housePart ~= nil and housePart:FindFirstChild("AnimationName") ~= nil and housePart.AnimationName.Value == "Shower" and housePart.Parent ~= nil then
		animationFireClient:FireServer("ShowerOff" .. housePart.Parent.Parent.Owner.Value)
	end

	if housePart ~= nil and housePart:FindFirstChild("AnimationName") ~= nil and housePart.AnimationName.Value == "Shower2" and housePart.Parent ~= nil then
		animationFireClient:FireServer("ShowerOff2" .. housePart.Parent.Parent.Owner.Value)
	end

	if housePart ~= nil and housePart:FindFirstChild("AnimationName") ~= nil and housePart.AnimationName.Value == "Shower3" and housePart.Parent ~= nil then
		animationFireClient:FireServer("ShowerOff3" .. housePart.Parent.Parent.Owner.Value)
	end

	if housePart ~= nil and housePart:FindFirstChild("AnimationName") ~= nil and housePart.AnimationName.Value == "Shower4" and housePart.Parent ~= nil then
		animationFireClient:FireServer("ShowerOff4" .. housePart.Parent.Parent.Owner.Value)
	end

	if housePart ~= nil and housePart:FindFirstChild("AnimationName") ~= nil and housePart.AnimationName.Value == "Wash hands" and housePart.Parent ~= nil then
		animationFireClient:FireServer("WashHandsOff" .. housePart.Parent.Parent.Owner.Value)
	end

	if housePart ~= nil and housePart:FindFirstChild("AnimationName") ~= nil and housePart.AnimationName.Value == "Wash hands2" and housePart.Parent ~= nil then
		animationFireClient:FireServer("WashHandsOff2" .. housePart.Parent.Parent.Owner.Value)
	end

	if housePart ~= nil and housePart:FindFirstChild("AnimationName") ~= nil and housePart.AnimationName.Value == "Wash hands3" and housePart.Parent ~= nil then
		animationFireClient:FireServer("WashHandsOff3" .. housePart.Parent.Parent.Owner.Value)
	end

	if housePart ~= nil and housePart:FindFirstChild("AnimationName") ~= nil and housePart.AnimationName.Value == "Wash hands4" and housePart.Parent ~= nil then
		animationFireClient:FireServer("WashHandsOff4" .. housePart.Parent.Parent.Owner.Value)
	end

	if housePart ~= nil and housePart:FindFirstChild("AnimationName") ~= nil and housePart.AnimationName.Value == "Wash hands5" and housePart.Parent ~= nil then
		animationFireClient:FireServer("WashHandsOff5" .. housePart.Parent.Parent.Owner.Value)
	end

	if housePart ~= nil and housePart:FindFirstChild("AnimationName") ~= nil and housePart.AnimationName.Value == "Sleep1" and housePart.Parent ~= nil then
		animationFireClient:FireServer("BedOff1" .. housePart.Parent.Parent.Owner.Value)
	end

	if housePart ~= nil and housePart:FindFirstChild("AnimationName") ~= nil and housePart.AnimationName.Value == "Sleep2" and housePart.Parent ~= nil then
		animationFireClient:FireServer("BedOff2" .. housePart.Parent.Parent.Owner.Value)
	end

	if housePart ~= nil and housePart:FindFirstChild("AnimationName") ~= nil and housePart.AnimationName.Value == "Sleep3" and housePart.Parent ~= nil then
		animationFireClient:FireServer("BedOff3" .. housePart.Parent.Parent.Owner.Value)
	end

	if housePart ~= nil and housePart:FindFirstChild("AnimationName") ~= nil and housePart.AnimationName.Value == "Sleep4" and housePart.Parent ~= nil then
		animationFireClient:FireServer("BedOff4" .. housePart.Parent.Parent.Owner.Value)
	end

	if housePart ~= nil and housePart:FindFirstChild("AnimationName") ~= nil and housePart.AnimationName.Value == "Sleep5" and housePart.Parent ~= nil then
		animationFireClient:FireServer("BedOff5" .. housePart.Parent.Parent.Owner.Value)
	end

	if housePart ~= nil and housePart:FindFirstChild("AnimationName") ~= nil and housePart.AnimationName.Value == "Sleep6" and housePart.Parent ~= nil then
		animationFireClient:FireServer("BedOff6" .. housePart.Parent.Parent.Owner.Value)
	end

	if housePart ~= nil and housePart:FindFirstChild("AnimationName") ~= nil and housePart.AnimationName.Value == "Sleep7" and housePart.Parent ~= nil then
		animationFireClient:FireServer("BedOff7" .. housePart.Parent.Parent.Owner.Value)
	end

	if housePart ~= nil and housePart:FindFirstChild("AnimationName") ~= nil and housePart.AnimationName.Value == "Sleep8" and housePart.Parent ~= nil then
		animationFireClient:FireServer("BedOff8" .. housePart.Parent.Parent.Owner.Value)
	end

	if housePart ~= nil and housePart:FindFirstChild("AnimationName") ~= nil and housePart.AnimationName.Value == "SleepBunk1" and housePart.Parent ~= nil then
		animationFireClient:FireServer("BunkBedOff1" .. housePart.Parent.Parent.Owner.Value)
	end

	if housePart ~= nil and housePart:FindFirstChild("AnimationName") ~= nil and housePart.AnimationName.Value == "SleepBunk2" and housePart.Parent ~= nil then
		animationFireClient:FireServer("BunkBedOff2" .. housePart.Parent.Parent.Owner.Value)
	end

	if housePart ~= nil and housePart:FindFirstChild("AnimationName") ~= nil and housePart.AnimationName.Value == "SleepBunk3" and housePart.Parent ~= nil then
		animationFireClient:FireServer("BunkBedOff3" .. housePart.Parent.Parent.Owner.Value)
	end

	if housePart ~= nil and housePart:FindFirstChild("AnimationName") ~= nil and housePart.AnimationName.Value == "SleepBunk4" and housePart.Parent ~= nil then
		animationFireClient:FireServer("BunkBedOff4" .. housePart.Parent.Parent.Owner.Value)
	end

	if housePart ~= nil and housePart:FindFirstChild("AnimationName") ~= nil and housePart.AnimationName.Value == "Bath" and housePart.Parent ~= nil then
		animationFireClient:FireServer("TubOff" .. housePart.Parent.Parent.Owner.Value)
	end

	if housePart ~= nil and housePart:FindFirstChild("AnimationName") ~= nil and housePart.AnimationName.Value == "Bath2" and housePart.Parent ~= nil then
		animationFireClient:FireServer("TubOff2" .. housePart.Parent.Parent.Owner.Value)
	end

	if housePart ~= nil and housePart:FindFirstChild("AnimationName") ~= nil and housePart.AnimationName.Value == "Play piano" then
		animationFireClient:FireServer("Stop Piano")
	end

	if housePart ~= nil and housePart:FindFirstChild("AnimationName") ~= nil and housePart.AnimationName.Value == "ShelterShower" then
		animationFireClient:FireServer("ShelterShowerOff")
	end

	if housePart ~= nil and housePart:FindFirstChild("AnimationName") ~= nil and housePart.AnimationName.Value == "ShelterSink" then
		animationFireClient:FireServer("ShelterSinkOff")
	end

	if menu.BankCards.Visible == true then
		menu.BankCards.Visible = false
	end

	if localPlayer.Character ~= nil and localPlayer.Character:FindFirstChild("Humanoid") ~= nil then
		localPlayer.Character.Humanoid.WalkSpeed = 16
	end

	local playingAnimationTracks = humanoid:GetPlayingAnimationTracks()

	for _, playingAnimationTrack in pairs(playingAnimationTracks) do
		if playingAnimationTrack.Name == "RPanimation" then
			playingAnimationTrack:Stop()
		end
	end

	housePart = nil
	v5 = false
	marker2.GUI.TextLabel.Visible = true
	marker2.ClickDetector.MaxActivationDistance = 20
end

RPAnimation.SetLegacyAnimationCancel(stopCurrentAnimation)
script.Destroying:Connect(function()
	RPAnimation.ClearLegacyAnimationCancel(stopCurrentAnimation)
end)

function JumpRequestPS5()
	if v4 == false then
		v4 = true

		if jumpingConnection then
			jumpingConnection:disconnect()
		end

		ContextActionService:UnbindAction("JumpRequest", JumpRequest, false, Enum.KeyCode.Space)
		jumpRequestConnection2:disconnect()

		if housePart ~= nil and housePart:FindFirstChild("AnimationName") ~= nil and housePart.AnimationName.Value == "Shower" and housePart.Parent ~= nil then
			animationFireClient:FireServer("ShowerOff" .. housePart.Parent.Parent.Owner.Value)
		end

		if housePart ~= nil and housePart:FindFirstChild("AnimationName") ~= nil and housePart.AnimationName.Value == "Shower2" and housePart.Parent ~= nil then
			animationFireClient:FireServer("ShowerOff2" .. housePart.Parent.Parent.Owner.Value)
		end

		if housePart ~= nil and housePart:FindFirstChild("AnimationName") ~= nil and housePart.AnimationName.Value == "Shower3" and housePart.Parent ~= nil then
			animationFireClient:FireServer("ShowerOff3" .. housePart.Parent.Parent.Owner.Value)
		end

		if housePart ~= nil and housePart:FindFirstChild("AnimationName") ~= nil and housePart.AnimationName.Value == "Shower4" and housePart.Parent ~= nil then
			animationFireClient:FireServer("ShowerOff4" .. housePart.Parent.Parent.Owner.Value)
		end

		if housePart ~= nil and housePart:FindFirstChild("AnimationName") ~= nil and housePart.AnimationName.Value == "Wash hands" and housePart.Parent ~= nil then
			animationFireClient:FireServer("WashHandsOff" .. housePart.Parent.Parent.Owner.Value)
		end

		if housePart ~= nil and housePart:FindFirstChild("AnimationName") ~= nil and housePart.AnimationName.Value == "Wash hands2" and housePart.Parent ~= nil then
			animationFireClient:FireServer("WashHandsOff2" .. housePart.Parent.Parent.Owner.Value)
		end

		if housePart ~= nil and housePart:FindFirstChild("AnimationName") ~= nil and housePart.AnimationName.Value == "Wash hands3" and housePart.Parent ~= nil then
			animationFireClient:FireServer("WashHandsOff3" .. housePart.Parent.Parent.Owner.Value)
		end

		if housePart ~= nil and housePart:FindFirstChild("AnimationName") ~= nil and housePart.AnimationName.Value == "Wash hands4" and housePart.Parent ~= nil then
			animationFireClient:FireServer("WashHandsOff4" .. housePart.Parent.Parent.Owner.Value)
		end

		if housePart ~= nil and housePart:FindFirstChild("AnimationName") ~= nil and housePart.AnimationName.Value == "Wash hands5" and housePart.Parent ~= nil then
			animationFireClient:FireServer("WashHandsOff5" .. housePart.Parent.Parent.Owner.Value)
		end

		if housePart ~= nil and housePart:FindFirstChild("AnimationName") ~= nil and housePart.AnimationName.Value == "Sleep1" and housePart.Parent ~= nil then
			animationFireClient:FireServer("BedOff1" .. housePart.Parent.Parent.Owner.Value)
		end

		if housePart ~= nil and housePart:FindFirstChild("AnimationName") ~= nil and housePart.AnimationName.Value == "Sleep2" and housePart.Parent ~= nil then
			animationFireClient:FireServer("BedOff2" .. housePart.Parent.Parent.Owner.Value)
		end

		if housePart ~= nil and housePart:FindFirstChild("AnimationName") ~= nil and housePart.AnimationName.Value == "Sleep3" and housePart.Parent ~= nil then
			animationFireClient:FireServer("BedOff3" .. housePart.Parent.Parent.Owner.Value)
		end

		if housePart ~= nil and housePart:FindFirstChild("AnimationName") ~= nil and housePart.AnimationName.Value == "Sleep4" and housePart.Parent ~= nil then
			animationFireClient:FireServer("BedOff4" .. housePart.Parent.Parent.Owner.Value)
		end

		if housePart ~= nil and housePart:FindFirstChild("AnimationName") ~= nil and housePart.AnimationName.Value == "Sleep5" and housePart.Parent ~= nil then
			animationFireClient:FireServer("BedOff5" .. housePart.Parent.Parent.Owner.Value)
		end

		if housePart ~= nil and housePart:FindFirstChild("AnimationName") ~= nil and housePart.AnimationName.Value == "Sleep6" and housePart.Parent ~= nil then
			animationFireClient:FireServer("BedOff6" .. housePart.Parent.Parent.Owner.Value)
		end

		if housePart ~= nil and housePart:FindFirstChild("AnimationName") ~= nil and housePart.AnimationName.Value == "Sleep7" and housePart.Parent ~= nil then
			animationFireClient:FireServer("BedOff7" .. housePart.Parent.Parent.Owner.Value)
		end

		if housePart ~= nil and housePart:FindFirstChild("AnimationName") ~= nil and housePart.AnimationName.Value == "Sleep8" and housePart.Parent ~= nil then
			animationFireClient:FireServer("BedOff8" .. housePart.Parent.Parent.Owner.Value)
		end

		if housePart ~= nil and housePart:FindFirstChild("AnimationName") ~= nil and housePart.AnimationName.Value == "SleepBunk1" and housePart.Parent ~= nil then
			animationFireClient:FireServer("BunkBedOff1" .. housePart.Parent.Parent.Owner.Value)
		end

		if housePart ~= nil and housePart:FindFirstChild("AnimationName") ~= nil and housePart.AnimationName.Value == "SleepBunk2" and housePart.Parent ~= nil then
			animationFireClient:FireServer("BunkBedOff2" .. housePart.Parent.Parent.Owner.Value)
		end

		if housePart ~= nil and housePart:FindFirstChild("AnimationName") ~= nil and housePart.AnimationName.Value == "SleepBunk3" and housePart.Parent ~= nil then
			animationFireClient:FireServer("BunkBedOff3" .. housePart.Parent.Parent.Owner.Value)
		end

		if housePart ~= nil and housePart:FindFirstChild("AnimationName") ~= nil and housePart.AnimationName.Value == "SleepBunk4" and housePart.Parent ~= nil then
			animationFireClient:FireServer("BunkBedOff4" .. housePart.Parent.Parent.Owner.Value)
		end

		if housePart ~= nil and housePart:FindFirstChild("AnimationName") ~= nil and housePart.AnimationName.Value == "Bath" and housePart.Parent ~= nil then
			animationFireClient:FireServer("TubOff" .. housePart.Parent.Parent.Owner.Value)
		end

		if housePart ~= nil and housePart:FindFirstChild("AnimationName") ~= nil and housePart.AnimationName.Value == "Bath2" and housePart.Parent ~= nil then
			animationFireClient:FireServer("TubOff2" .. housePart.Parent.Parent.Owner.Value)
		end

		if housePart ~= nil and housePart:FindFirstChild("AnimationName") ~= nil and housePart.AnimationName.Value == "Play piano" then
			animationFireClient:FireServer("Stop Piano")
		end

		if housePart ~= nil and housePart:FindFirstChild("AnimationName") ~= nil and housePart.AnimationName.Value == "ShelterShower" then
			animationFireClient:FireServer("ShelterShowerOff")
		end

		if housePart ~= nil and housePart:FindFirstChild("AnimationName") ~= nil and housePart.AnimationName.Value == "ShelterSink" then
			animationFireClient:FireServer("ShelterSinkOff")
		end

		if menu.BankCards.Visible == true then
			menu.BankCards.Visible = false
		end

		localPlayer.Character.Humanoid.WalkSpeed = 16
		local playingAnimationTracks = humanoid:GetPlayingAnimationTracks()

		for _, playingAnimationTrack in pairs(playingAnimationTracks) do
			if playingAnimationTrack.Name == "RPanimation" then
				playingAnimationTrack:Stop()
			end
		end

		housePart = nil
		v5 = false
		marker2.GUI.TextLabel.Visible = true
		marker2.ClickDetector.MaxActivationDistance = 20
		wait(0.1)
		v4 = false
	end
end

function JumpRequestMobile()
	if v4 == false then
		v4 = true
		ContextActionService:UnbindAction("JumpRequest", JumpRequest, false, Enum.KeyCode.Space)
		jumpRequestConnection:disconnect()

		if jumpingConnection then
			jumpingConnection:disconnect()
		end

		if housePart ~= nil and housePart:FindFirstChild("AnimationName") ~= nil and housePart.AnimationName.Value == "Shower" and housePart.Parent ~= nil then
			animationFireClient:FireServer("ShowerOff" .. housePart.Parent.Parent.Owner.Value)
		end

		if housePart ~= nil and housePart:FindFirstChild("AnimationName") ~= nil and housePart.AnimationName.Value == "Shower2" and housePart.Parent ~= nil then
			animationFireClient:FireServer("ShowerOff2" .. housePart.Parent.Parent.Owner.Value)
		end

		if housePart ~= nil and housePart:FindFirstChild("AnimationName") ~= nil and housePart.AnimationName.Value == "Shower3" and housePart.Parent ~= nil then
			animationFireClient:FireServer("ShowerOff3" .. housePart.Parent.Parent.Owner.Value)
		end

		if housePart ~= nil and housePart:FindFirstChild("AnimationName") ~= nil and housePart.AnimationName.Value == "Shower4" and housePart.Parent ~= nil then
			animationFireClient:FireServer("ShowerOff4" .. housePart.Parent.Parent.Owner.Value)
		end

		if housePart ~= nil and housePart:FindFirstChild("AnimationName") ~= nil and housePart.AnimationName.Value == "Wash hands" and housePart.Parent ~= nil then
			animationFireClient:FireServer("WashHandsOff" .. housePart.Parent.Parent.Owner.Value)
		end

		if housePart ~= nil and housePart:FindFirstChild("AnimationName") ~= nil and housePart.AnimationName.Value == "Wash hands2" and housePart.Parent ~= nil then
			animationFireClient:FireServer("WashHandsOff2" .. housePart.Parent.Parent.Owner.Value)
		end

		if housePart ~= nil and housePart:FindFirstChild("AnimationName") ~= nil and housePart.AnimationName.Value == "Wash hands3" and housePart.Parent ~= nil then
			animationFireClient:FireServer("WashHandsOff3" .. housePart.Parent.Parent.Owner.Value)
		end

		if housePart ~= nil and housePart:FindFirstChild("AnimationName") ~= nil and housePart.AnimationName.Value == "Wash hands4" and housePart.Parent ~= nil then
			animationFireClient:FireServer("WashHandsOff4" .. housePart.Parent.Parent.Owner.Value)
		end

		if housePart ~= nil and housePart:FindFirstChild("AnimationName") ~= nil and housePart.AnimationName.Value == "Wash hands5" and housePart.Parent ~= nil then
			animationFireClient:FireServer("WashHandsOff5" .. housePart.Parent.Parent.Owner.Value)
		end

		if housePart ~= nil and housePart:FindFirstChild("AnimationName") ~= nil and housePart.AnimationName.Value == "Sleep1" and housePart.Parent ~= nil then
			animationFireClient:FireServer("BedOff1" .. housePart.Parent.Parent.Owner.Value)
		end

		if housePart ~= nil and housePart:FindFirstChild("AnimationName") ~= nil and housePart.AnimationName.Value == "Sleep2" and housePart.Parent ~= nil then
			animationFireClient:FireServer("BedOff2" .. housePart.Parent.Parent.Owner.Value)
		end

		if housePart ~= nil and housePart:FindFirstChild("AnimationName") ~= nil and housePart.AnimationName.Value == "Sleep3" and housePart.Parent ~= nil then
			animationFireClient:FireServer("BedOff3" .. housePart.Parent.Parent.Owner.Value)
		end

		if housePart ~= nil and housePart:FindFirstChild("AnimationName") ~= nil and housePart.AnimationName.Value == "Sleep4" and housePart.Parent ~= nil then
			animationFireClient:FireServer("BedOff4" .. housePart.Parent.Parent.Owner.Value)
		end

		if housePart ~= nil and housePart:FindFirstChild("AnimationName") ~= nil and housePart.AnimationName.Value == "Sleep5" and housePart.Parent ~= nil then
			animationFireClient:FireServer("BedOff5" .. housePart.Parent.Parent.Owner.Value)
		end

		if housePart ~= nil and housePart:FindFirstChild("AnimationName") ~= nil and housePart.AnimationName.Value == "Sleep6" and housePart.Parent ~= nil then
			animationFireClient:FireServer("BedOff6" .. housePart.Parent.Parent.Owner.Value)
		end

		if housePart ~= nil and housePart:FindFirstChild("AnimationName") ~= nil and housePart.AnimationName.Value == "Sleep7" and housePart.Parent ~= nil then
			animationFireClient:FireServer("BedOff7" .. housePart.Parent.Parent.Owner.Value)
		end

		if housePart ~= nil and housePart:FindFirstChild("AnimationName") ~= nil and housePart.AnimationName.Value == "Sleep8" and housePart.Parent ~= nil then
			animationFireClient:FireServer("BedOff8" .. housePart.Parent.Parent.Owner.Value)
		end

		if housePart ~= nil and housePart:FindFirstChild("AnimationName") ~= nil and housePart.AnimationName.Value == "SleepBunk1" and housePart.Parent ~= nil then
			animationFireClient:FireServer("BunkBedOff1" .. housePart.Parent.Parent.Owner.Value)
		end

		if housePart ~= nil and housePart:FindFirstChild("AnimationName") ~= nil and housePart.AnimationName.Value == "SleepBunk2" and housePart.Parent ~= nil then
			animationFireClient:FireServer("BunkBedOff2" .. housePart.Parent.Parent.Owner.Value)
		end

		if housePart ~= nil and housePart:FindFirstChild("AnimationName") ~= nil and housePart.AnimationName.Value == "SleepBunk3" and housePart.Parent ~= nil then
			animationFireClient:FireServer("BunkBedOff3" .. housePart.Parent.Parent.Owner.Value)
		end

		if housePart ~= nil and housePart:FindFirstChild("AnimationName") ~= nil and housePart.AnimationName.Value == "SleepBunk4" and housePart.Parent ~= nil then
			animationFireClient:FireServer("BunkBedOff4" .. housePart.Parent.Parent.Owner.Value)
		end

		if housePart ~= nil and housePart:FindFirstChild("AnimationName") ~= nil and housePart.AnimationName.Value == "Bath" and housePart.Parent ~= nil then
			animationFireClient:FireServer("TubOff" .. housePart.Parent.Parent.Owner.Value)
		end

		if housePart ~= nil and housePart:FindFirstChild("AnimationName") ~= nil and housePart.AnimationName.Value == "Bath2" and housePart.Parent ~= nil then
			animationFireClient:FireServer("TubOff2" .. housePart.Parent.Parent.Owner.Value)
		end

		if housePart ~= nil and housePart:FindFirstChild("AnimationName") ~= nil and housePart.AnimationName.Value == "Play piano" then
			animationFireClient:FireServer("Stop Piano")
		end

		if housePart ~= nil and housePart:FindFirstChild("AnimationName") ~= nil and housePart.AnimationName.Value == "ShelterShower" then
			animationFireClient:FireServer("ShelterShowerOff")
		end

		if housePart ~= nil and housePart:FindFirstChild("AnimationName") ~= nil and housePart.AnimationName.Value == "ShelterSink" then
			animationFireClient:FireServer("ShelterSinkOff")
		end

		if menu.BankCards.Visible == true then
			menu.BankCards.Visible = false
		end

		localPlayer.Character.Humanoid.WalkSpeed = 16
		local playingAnimationTracks = humanoid:GetPlayingAnimationTracks()

		for _, playingAnimationTrack in pairs(playingAnimationTracks) do
			if playingAnimationTrack.Name == "RPanimation" then
				playingAnimationTrack:Stop()
			end
		end

		housePart = nil
		v5 = false
		marker2.GUI.TextLabel.Visible = true
		marker2.ClickDetector.MaxActivationDistance = 20
		wait(0.1)
		v4 = false
	end
end

function JumpRequest(_, p, _)
	if v2 == false and p == Enum.UserInputState.Begin then
		v2 = true
		humanoid.Sit = false

		if jumpingConnection then
			jumpingConnection:disconnect()
		end

		ContextActionService:UnbindAction("JumpRequest", JumpRequest, false, Enum.KeyCode.Space)

		if housePart ~= nil and housePart:FindFirstChild("AnimationName") ~= nil and housePart.AnimationName.Value == "Shower" and housePart.Parent ~= nil then
			animationFireClient:FireServer("ShowerOff" .. housePart.Parent.Parent.Owner.Value)
		end

		if housePart ~= nil and housePart:FindFirstChild("AnimationName") ~= nil and housePart.AnimationName.Value == "Shower2" and housePart.Parent ~= nil then
			animationFireClient:FireServer("ShowerOff2" .. housePart.Parent.Parent.Owner.Value)
		end

		if housePart ~= nil and housePart:FindFirstChild("AnimationName") ~= nil and housePart.AnimationName.Value == "Shower3" and housePart.Parent ~= nil then
			animationFireClient:FireServer("ShowerOff3" .. housePart.Parent.Parent.Owner.Value)
		end

		if housePart ~= nil and housePart:FindFirstChild("AnimationName") ~= nil and housePart.AnimationName.Value == "Shower4" and housePart.Parent ~= nil then
			animationFireClient:FireServer("ShowerOff4" .. housePart.Parent.Parent.Owner.Value)
		end

		if housePart ~= nil and housePart:FindFirstChild("AnimationName") ~= nil and housePart.AnimationName.Value == "Wash hands" and housePart.Parent ~= nil then
			animationFireClient:FireServer("WashHandsOff" .. housePart.Parent.Parent.Owner.Value)
		end

		if housePart ~= nil and housePart:FindFirstChild("AnimationName") ~= nil and housePart.AnimationName.Value == "Wash hands2" and housePart.Parent ~= nil then
			animationFireClient:FireServer("WashHandsOff2" .. housePart.Parent.Parent.Owner.Value)
		end

		if housePart ~= nil and housePart:FindFirstChild("AnimationName") ~= nil and housePart.AnimationName.Value == "Wash hands3" and housePart.Parent ~= nil then
			animationFireClient:FireServer("WashHandsOff3" .. housePart.Parent.Parent.Owner.Value)
		end

		if housePart ~= nil and housePart:FindFirstChild("AnimationName") ~= nil and housePart.AnimationName.Value == "Wash hands4" and housePart.Parent ~= nil then
			animationFireClient:FireServer("WashHandsOff4" .. housePart.Parent.Parent.Owner.Value)
		end

		if housePart ~= nil and housePart:FindFirstChild("AnimationName") ~= nil and housePart.AnimationName.Value == "Wash hands5" and housePart.Parent ~= nil then
			animationFireClient:FireServer("WashHandsOff5" .. housePart.Parent.Parent.Owner.Value)
		end

		if housePart ~= nil and housePart:FindFirstChild("AnimationName") ~= nil and housePart.AnimationName.Value == "Sleep1" and housePart.Parent ~= nil then
			animationFireClient:FireServer("BedOff1" .. housePart.Parent.Parent.Owner.Value)
		end

		if housePart ~= nil and housePart:FindFirstChild("AnimationName") ~= nil and housePart.AnimationName.Value == "Sleep2" and housePart.Parent ~= nil then
			animationFireClient:FireServer("BedOff2" .. housePart.Parent.Parent.Owner.Value)
		end

		if housePart ~= nil and housePart:FindFirstChild("AnimationName") ~= nil and housePart.AnimationName.Value == "Sleep3" and housePart.Parent ~= nil then
			animationFireClient:FireServer("BedOff3" .. housePart.Parent.Parent.Owner.Value)
		end

		if housePart ~= nil and housePart:FindFirstChild("AnimationName") ~= nil and housePart.AnimationName.Value == "Sleep4" and housePart.Parent ~= nil then
			animationFireClient:FireServer("BedOff4" .. housePart.Parent.Parent.Owner.Value)
		end

		if housePart ~= nil and housePart:FindFirstChild("AnimationName") ~= nil and housePart.AnimationName.Value == "Sleep5" and housePart.Parent ~= nil then
			animationFireClient:FireServer("BedOff5" .. housePart.Parent.Parent.Owner.Value)
		end

		if housePart ~= nil and housePart:FindFirstChild("AnimationName") ~= nil and housePart.AnimationName.Value == "Sleep6" and housePart.Parent ~= nil then
			animationFireClient:FireServer("BedOff6" .. housePart.Parent.Parent.Owner.Value)
		end

		if housePart ~= nil and housePart:FindFirstChild("AnimationName") ~= nil and housePart.AnimationName.Value == "Sleep7" and housePart.Parent ~= nil then
			animationFireClient:FireServer("BedOff7" .. housePart.Parent.Parent.Owner.Value)
		end

		if housePart ~= nil and housePart:FindFirstChild("AnimationName") ~= nil and housePart.AnimationName.Value == "Sleep8" and housePart.Parent ~= nil then
			animationFireClient:FireServer("BedOff8" .. housePart.Parent.Parent.Owner.Value)
		end

		if housePart ~= nil and housePart:FindFirstChild("AnimationName") ~= nil and housePart.AnimationName.Value == "SleepBunk1" and housePart.Parent ~= nil then
			animationFireClient:FireServer("BunkBedOff1" .. housePart.Parent.Parent.Owner.Value)
		end

		if housePart ~= nil and housePart:FindFirstChild("AnimationName") ~= nil and housePart.AnimationName.Value == "SleepBunk2" and housePart.Parent ~= nil then
			animationFireClient:FireServer("BunkBedOff2" .. housePart.Parent.Parent.Owner.Value)
		end

		if housePart ~= nil and housePart:FindFirstChild("AnimationName") ~= nil and housePart.AnimationName.Value == "SleepBunk3" and housePart.Parent ~= nil then
			animationFireClient:FireServer("BunkBedOff3" .. housePart.Parent.Parent.Owner.Value)
		end

		if housePart ~= nil and housePart:FindFirstChild("AnimationName") ~= nil and housePart.AnimationName.Value == "SleepBunk4" and housePart.Parent ~= nil then
			animationFireClient:FireServer("BunkBedOff4" .. housePart.Parent.Parent.Owner.Value)
		end

		if housePart ~= nil and housePart:FindFirstChild("AnimationName") ~= nil and housePart.AnimationName.Value == "Bath" and housePart.Parent ~= nil then
			animationFireClient:FireServer("TubOff" .. housePart.Parent.Parent.Owner.Value)
		end

		if housePart ~= nil and housePart:FindFirstChild("AnimationName") ~= nil and housePart.AnimationName.Value == "Bath2" and housePart.Parent ~= nil then
			animationFireClient:FireServer("TubOff2" .. housePart.Parent.Parent.Owner.Value)
		end

		if housePart ~= nil and housePart:FindFirstChild("AnimationName") ~= nil and housePart.AnimationName.Value == "Play piano" then
			animationFireClient:FireServer("Stop Piano")
		end

		if housePart ~= nil and housePart:FindFirstChild("AnimationName") ~= nil and housePart.AnimationName.Value == "ShelterShower" then
			animationFireClient:FireServer("ShelterShowerOff")
		end

		if housePart ~= nil and housePart:FindFirstChild("AnimationName") ~= nil and housePart.AnimationName.Value == "ShelterSink" then
			animationFireClient:FireServer("ShelterSinkOff")
		end

		if menu.BankCards.Visible == true then
			menu.BankCards.Visible = false
		end

		localPlayer.Character.Humanoid.WalkSpeed = 16
		local playingAnimationTracks = humanoid:GetPlayingAnimationTracks()

		for _, playingAnimationTrack in pairs(playingAnimationTracks) do
			if playingAnimationTrack.Name == "RPanimation" then
				playingAnimationTrack:Stop()
			end
		end

		marker2.GUI.TextLabel.Visible = true
		marker2.ClickDetector.MaxActivationDistance = 20
		housePart = nil
		v5 = false
		wait(0.2)
		v2 = false
	end
end

function SitRequest(_, p, _)
	if v == false and p == Enum.UserInputState.Begin then
		v = true

		if seat2 then
			local overlapParams = OverlapParams.new()
			overlapParams.CollisionGroup = "PrivateSpace"
			local partBoundsInBox = workspace:GetPartBoundsInBox(seat2.CFrame, seat2.Size, overlapParams)
			local flag = false

			for _, v7 in partBoundsInBox do
				if not (v7:GetAttribute("OccupiedBy") and v7:GetAttribute("OccupiedBy") ~= localPlayer.UserId) then
					continue
				end

				flag = true
				break
			end

			if flag then
				v = false
				return
			end
		end

		RPAnimation.CancelAllEnabled()
		v5 = true
		ContextActionService:UnbindAction("SitRequest", SitRequest, false, Enum.KeyCode.E)
		marker2.GUI.TextLabel.Visible = false
		marker2.ClickDetector.MaxActivationDistance = 0
		local value = marker.EventObject.Value

		if seat2 and seat2.ClassName == "Seat" then
			seat2:Sit(humanoid)

			if value.AnimationName.Value == "Sleep1" then
				housePart = value
				animationFireClient:FireServer("BedOn1" .. value.Parent.Parent.Owner.Value)
			end

			if value.AnimationName.Value == "Sleep2" then
				housePart = value
				animationFireClient:FireServer("BedOn2" .. value.Parent.Parent.Owner.Value)
			end

			if value.AnimationName.Value == "Sleep3" then
				housePart = value
				animationFireClient:FireServer("BedOn3" .. value.Parent.Parent.Owner.Value)
			end

			if value.AnimationName.Value == "Sleep4" then
				housePart = value
				animationFireClient:FireServer("BedOn4" .. value.Parent.Parent.Owner.Value)
			end

			if value.AnimationName.Value == "Sleep5" then
				housePart = value
				animationFireClient:FireServer("BedOn5" .. value.Parent.Parent.Owner.Value)
			end

			if value.AnimationName.Value == "Sleep6" then
				housePart = value
				animationFireClient:FireServer("BedOn6" .. value.Parent.Parent.Owner.Value)
			end

			if value.AnimationName.Value == "Sleep7" then
				housePart = value
				animationFireClient:FireServer("BedOn7" .. value.Parent.Parent.Owner.Value)
			end

			if value.AnimationName.Value == "Sleep8" then
				housePart = value
				animationFireClient:FireServer("BedOn8" .. value.Parent.Parent.Owner.Value)
			end

			if value.AnimationName.Value == "SleepBunk1" then
				housePart = value
				animationFireClient:FireServer("BunkBedOn1" .. value.Parent.Parent.Owner.Value)
			end

			if value.AnimationName.Value == "SleepBunk2" then
				housePart = value
				animationFireClient:FireServer("BunkBedOn2" .. value.Parent.Parent.Owner.Value)
			end

			if value.AnimationName.Value == "SleepBunk3" then
				housePart = value
				animationFireClient:FireServer("BunkBedOn3" .. value.Parent.Parent.Owner.Value)
			end

			if value.AnimationName.Value == "SleepBunk4" then
				housePart = value
				animationFireClient:FireServer("BunkBedOn4" .. value.Parent.Parent.Owner.Value)
			end

			if value.AnimationName.Value == "Bath" then
				housePart = value
				animationFireClient:FireServer("TubOn" .. value.Parent.Parent.Owner.Value)
			end

			if value.AnimationName.Value == "Bath2" then
				housePart = value
				animationFireClient:FireServer("TubOn2" .. value.Parent.Parent.Owner.Value)
			end

			if value.AnimationName.Value == "Play piano" then
				housePart = value
				animationFireClient:FireServer("Play Piano")
			end

			if value.AnimationName.Value == "Use computer" then
				housePart = value
				animationFireClient:FireServer("ComputerOnSit" .. value.Parent.Parent.Owner.Value)
			end

			if value.AnimationName.Value == "Use computer2" then
				housePart = value
				animationFireClient:FireServer("ComputerOnSit2" .. value.Parent.Parent.Owner.Value)
			end

			local value2 = marker.AnimationNumber.Value
			local animation = Instance.new("Animation")
			animation.Name = "RPanimation"
			animation.AnimationId = "rbxassetid://" .. value2
			localPlayer.Character.Humanoid:LoadAnimation(animation):Play()
			ContextActionService:BindAction("JumpRequest", JumpRequest, false, Enum.KeyCode.Space, Enum.KeyCode.ButtonA)
		elseif seat2 and seat2.ClassName == "Part" and humanoid.Sit == false then
			v5 = true

			if value.AnimationName.Value == "Shower" then
				housePart = value
				animationFireClient:FireServer("ShowerOn" .. value.Parent.Parent.Owner.Value)
			end

			if value.AnimationName.Value == "Shower2" then
				housePart = value
				animationFireClient:FireServer("ShowerOn2" .. value.Parent.Parent.Owner.Value)
			end

			if value.AnimationName.Value == "Shower3" then
				housePart = value
				animationFireClient:FireServer("ShowerOn3" .. value.Parent.Parent.Owner.Value)
			end

			if value.AnimationName.Value == "Shower4" then
				housePart = value
				animationFireClient:FireServer("ShowerOn4" .. value.Parent.Parent.Owner.Value)
			end

			if value.AnimationName.Value == "Wash hands" then
				housePart = value
				animationFireClient:FireServer("WashHandsOn" .. value.Parent.Parent.Owner.Value)
			end

			if value.AnimationName.Value == "Wash hands2" then
				housePart = value
				animationFireClient:FireServer("WashHandsOn2" .. value.Parent.Parent.Owner.Value)
			end

			if value.AnimationName.Value == "Wash hands3" then
				housePart = value
				animationFireClient:FireServer("WashHandsOn3" .. value.Parent.Parent.Owner.Value)
			end

			if value.AnimationName.Value == "Wash hands4" then
				housePart = value
				animationFireClient:FireServer("WashHandsOn4" .. value.Parent.Parent.Owner.Value)
			end

			if value.AnimationName.Value == "Wash hands5" then
				housePart = value
				animationFireClient:FireServer("WashHandsOn5" .. value.Parent.Parent.Owner.Value)
			end

			if value.AnimationName.Value == "ShelterSink" then
				housePart = value
				animationFireClient:FireServer("ShelterSinkOn")
			end

			if value.AnimationName.Value == "ShelterShower" then
				housePart = value
				animationFireClient:FireServer("ShelterShowerOn")
			end

			if value.AnimationName.Value == "Open account" then
				menu.BankCards.Visible = true
			end

			localPlayer.Character.Humanoid.WalkSpeed = 0
			localPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(value.Position) * (value.CFrame - value.Position)
			localPlayer.Character.HumanoidRootPart.CFrame = value.CFrame * CFrame.new(0, 0, -2)
			local value2 = marker.AnimationNumber.Value
			local animation = Instance.new("Animation")
			animation.Name = "RPanimation"
			animation.AnimationId = "rbxassetid://" .. value2
			localPlayer.Character.Humanoid:LoadAnimation(animation):Play()
			ContextActionService:BindAction("JumpRequest", JumpRequest, false, Enum.KeyCode.Space, Enum.KeyCode.ButtonA)
		else
			v5 = false
			marker2.GUI.TextLabel.Visible = true
			marker2.ClickDetector.MaxActivationDistance = 20
		end

		wait(2)
		v = false
	end
end

marker.ClickDetector.MouseClick:connect(function(player)
	if v3 == false then
		v3 = true

		if seat2 then
			local overlapParams = OverlapParams.new()
			overlapParams.CollisionGroup = "PrivateSpace"
			local partBoundsInBox = workspace:GetPartBoundsInBox(marker2.CFrame, marker2.Size, overlapParams)
			local flag = false

			for _, v7 in partBoundsInBox do
				if not (v7:GetAttribute("OccupiedBy") and v7:GetAttribute("OccupiedBy") ~= player.UserId) then
					continue
				end

				flag = true
				break
			end

			if flag then
				v3 = false
				return
			end
		end

		RPAnimation.CancelAllEnabled()
		v5 = true
		ContextActionService:UnbindAction("SitRequest", SitRequest, false, Enum.KeyCode.E)
		marker2.GUI.TextLabel.Visible = false
		marker2.ClickDetector.MaxActivationDistance = 0
		local value = marker.EventObject.Value

		if value.ClassName == "Part" and humanoid.Sit == false then
			if value.AnimationName.Value == "Shower" then
				housePart = value
				animationFireClient:FireServer("ShowerOn" .. value.Parent.Parent.Owner.Value)
			end

			if value.AnimationName.Value == "Shower2" then
				housePart = value
				animationFireClient:FireServer("ShowerOn2" .. value.Parent.Parent.Owner.Value)
			end

			if value.AnimationName.Value == "Shower3" then
				housePart = value
				animationFireClient:FireServer("ShowerOn3" .. value.Parent.Parent.Owner.Value)
			end

			if value.AnimationName.Value == "Shower4" then
				housePart = value
				animationFireClient:FireServer("ShowerOn4" .. value.Parent.Parent.Owner.Value)
			end

			if value.AnimationName.Value == "Wash hands" then
				housePart = value
				animationFireClient:FireServer("WashHandsOn" .. value.Parent.Parent.Owner.Value)
			end

			if value.AnimationName.Value == "Wash hands2" then
				housePart = value
				animationFireClient:FireServer("WashHandsOn2" .. value.Parent.Parent.Owner.Value)
			end

			if value.AnimationName.Value == "Wash hands3" then
				housePart = value
				animationFireClient:FireServer("WashHandsOn3" .. value.Parent.Parent.Owner.Value)
			end

			if value.AnimationName.Value == "Wash hands4" then
				housePart = value
				animationFireClient:FireServer("WashHandsOn4" .. value.Parent.Parent.Owner.Value)
			end

			if value.AnimationName.Value == "Wash hands5" then
				housePart = value
				animationFireClient:FireServer("WashHandsOn5" .. value.Parent.Parent.Owner.Value)
			end

			if value.AnimationName.Value == "ShelterSink" then
				housePart = value
				animationFireClient:FireServer("ShelterSinkOn")
			end

			if value.AnimationName.Value == "ShelterShower" then
				housePart = value
				animationFireClient:FireServer("ShelterShowerOn")
			end

			if value.AnimationName.Value == "Open account" and not (player.Character:FindFirstChild("CreditCardBoy") or player.Character:FindFirstChild("CreditCardGirl") or player.Backpack:FindFirstChild("CreditCardGirl") or player.Backpack:FindFirstChild("CreditCardBoy")) then
				menu.BankCards.Visible = true
			end

			player.Character.Humanoid.WalkSpeed = 0
			player.Character.HumanoidRootPart.CFrame = CFrame.new(value.Position) * (value.CFrame - value.Position)
			player.Character.HumanoidRootPart.CFrame = value.CFrame * CFrame.new(0, 0, -2)
			local value2 = marker.AnimationNumber.Value
			local animation = Instance.new("Animation")
			animation.Name = "RPanimation"
			animation.AnimationId = "rbxassetid://" .. value2
			local humanoid2 = player.Character.Humanoid
			player.Character.Humanoid:LoadAnimation(animation):Play()
			ContextActionService:BindAction("JumpRequest", JumpRequest, false, Enum.KeyCode.Space, Enum.KeyCode.ButtonA)
			jumpingConnection = humanoid2.Jumping:Connect(function()
				JumpRequest(nil, Enum.UserInputState.Begin, nil)
			end)

			if UserInputService.TouchEnabled then
				jumpRequestConnection = UserInputService.JumpRequest:Connect(function()
					JumpRequestMobile()
					jumpRequestConnection:disconnect()
				end)
			end

			if UserInputService.GamepadEnabled then
				jumpRequestConnection2 = UserInputService.JumpRequest:Connect(function()
					JumpRequestPS5()
					jumpRequestConnection2:disconnect()
				end)
			end
		elseif seat2 and seat2.ClassName == "Seat" then
			v3 = true
			seat2:Sit(humanoid)

			if value.AnimationName.Value == "Sleep1" then
				housePart = value
				animationFireClient:FireServer("BedOn1" .. value.Parent.Parent.Owner.Value)
			end

			if value.AnimationName.Value == "Sleep2" then
				housePart = value
				animationFireClient:FireServer("BedOn2" .. value.Parent.Parent.Owner.Value)
			end

			if value.AnimationName.Value == "Sleep3" then
				housePart = value
				animationFireClient:FireServer("BedOn3" .. value.Parent.Parent.Owner.Value)
			end

			if value.AnimationName.Value == "Sleep4" then
				housePart = value
				animationFireClient:FireServer("BedOn4" .. value.Parent.Parent.Owner.Value)
			end

			if value.AnimationName.Value == "Sleep5" then
				housePart = value
				animationFireClient:FireServer("BedOn5" .. value.Parent.Parent.Owner.Value)
			end

			if value.AnimationName.Value == "Sleep6" then
				housePart = value
				animationFireClient:FireServer("BedOn6" .. value.Parent.Parent.Owner.Value)
			end

			if value.AnimationName.Value == "Sleep7" then
				housePart = value
				animationFireClient:FireServer("BedOn7" .. value.Parent.Parent.Owner.Value)
			end

			if value.AnimationName.Value == "Sleep8" then
				housePart = value
				animationFireClient:FireServer("BedOn8" .. value.Parent.Parent.Owner.Value)
			end

			if value.AnimationName.Value == "SleepBunk1" then
				housePart = value
				animationFireClient:FireServer("BunkBedOn1" .. value.Parent.Parent.Owner.Value)
			end

			if value.AnimationName.Value == "SleepBunk2" then
				housePart = value
				animationFireClient:FireServer("BunkBedOn2" .. value.Parent.Parent.Owner.Value)
			end

			if value.AnimationName.Value == "SleepBunk3" then
				housePart = value
				animationFireClient:FireServer("BunkBedOn3" .. value.Parent.Parent.Owner.Value)
			end

			if value.AnimationName.Value == "SleepBunk4" then
				housePart = value
				animationFireClient:FireServer("BunkBedOn4" .. value.Parent.Parent.Owner.Value)
			end

			if value.AnimationName.Value == "Bath" then
				housePart = value
				animationFireClient:FireServer("TubOn" .. value.Parent.Parent.Owner.Value)
			end

			if value.AnimationName.Value == "Bath2" then
				housePart = value
				animationFireClient:FireServer("TubOn2" .. value.Parent.Parent.Owner.Value)
			end

			if value.AnimationName.Value == "Play piano" then
				housePart = value
				animationFireClient:FireServer("Play Piano")
			end

			if value.AnimationName.Value == "Use computer" then
				housePart = value
				animationFireClient:FireServer("ComputerOnSit" .. value.Parent.Parent.Owner.Value)
			end

			if value.AnimationName.Value == "Use computer2" then
				housePart = value
				animationFireClient:FireServer("ComputerOnSit2" .. value.Parent.Parent.Owner.Value)
			end

			local value2 = marker.AnimationNumber.Value
			local animation = Instance.new("Animation")
			animation.Name = "RPanimation"
			animation.AnimationId = "rbxassetid://" .. value2
			local humanoid2 = player.Character.Humanoid
			humanoid2:LoadAnimation(animation):Play()
			ContextActionService:BindAction("JumpRequest", JumpRequest, false, Enum.KeyCode.Space, Enum.KeyCode.ButtonA)
			jumpingConnection = humanoid2.Jumping:Connect(function()
				JumpRequest(nil, Enum.UserInputState.Begin, nil)
			end)

			if UserInputService.TouchEnabled then
				jumpRequestConnection = UserInputService.JumpRequest:Connect(function()
					JumpRequestMobile()
				end)
			end

			if UserInputService.GamepadEnabled then
				jumpRequestConnection2 = UserInputService.JumpRequest:Connect(function()
					JumpRequestPS5()
					jumpRequestConnection2:disconnect()
				end)
			end
		else
			v5 = false
			marker2.GUI.TextLabel.Visible = true
			marker2.ClickDetector.MaxActivationDistance = 20
		end

		wait(2)
		v3 = false
	end
end)
humanoid.Died:connect(function()
	if housePart ~= nil and housePart:FindFirstChild("AnimationName") ~= nil and housePart.AnimationName.Value == "Play piano" then
		animationFireClient:FireServer("Stop Piano")
	end

	housePart = nil
	marker2.GUI.TextLabel.Visible = true
	marker2.ClickDetector.MaxActivationDistance = 20
end)

while true do
	local v6 = 1e999

	for _, v7 in pairs(tagged) do
		local distanceFromCharacter = localPlayer:DistanceFromCharacter(v7.Position)

		if not (distanceFromCharacter < 10 and distanceFromCharacter < v6 and v7.TF.Value == true) then
			continue
		end

		seat = v7
		v6 = distanceFromCharacter
	end

	seat2 = seat

	if seat == nil or v5 ~= false or localPlayer.Character:FindFirstChild("ClientToClient") or client2ClientAccept.Visible ~= false or animationPlaying.Value ~= false or localPlayer.Character:FindFirstChild("NoMotorVehicleModel") or child:FindFirstChild(localPlayer.Name .. "Horse") then
		marker2.CFrame = CFrame.new(64.59, -29.998, -57.417)
		ContextActionService:UnbindAction("SitRequest")
	else
		local v7 = false

		for _, child2 in game.Players:GetChildren() do
			if not (child2.Character ~= nil and child2.Character:FindFirstChild("UpperTorso") ~= nil) then
				continue
			end

			local upperTorso = child2.Character:FindFirstChild("UpperTorso")

			if upperTorso.Parent.Name ~= localPlayer.Name and (seat.Position - upperTorso.Position).magnitude <= 3 then
				v7 = true
			end
		end

		if v7 == false then
			marker2.EventObject.Value = seat
			marker2.AnimationNumber.Value = seat.AnimationNumber.Value
			marker2.AnimationName.Value = seat.AnimationName.Value
			marker2.GUI.TextLabel.Text = seat.Name
			marker2.CFrame = seat.CFrame * CFrame.new(0, 4, 0)

			if ConsoleControls.isNavigationEnabled then
				ContextActionService:BindAction("SitRequest", SitRequest, false, Enum.KeyCode.E, Enum.KeyCode.ButtonX)
			else
				ContextActionService:BindAction("SitRequest", SitRequest, false, Enum.KeyCode.E)
			end
		else
			marker2.CFrame = CFrame.new(64.59, -29.998, -57.417)
			ContextActionService:UnbindAction("SitRequest")
		end
	end

	seat = nil
	wait(0.5)
end