local HelpElfClient = {}
local localPlayer = game.Players.LocalPlayer
local Client = require(localPlayer.PlayerScripts.Client)
local TweenService = game:GetService("TweenService")
local random = Random.new()
local v = {}
Client.Events.CelebrateDespawnElf:Connect(function(p)
	HelpElfClient.PlayAnimation(p, "Celebrate")
	task.wait(3)
	HelpElfClient.FadeOutElf(p)
end)
Client.Events.FadeOutElf:Connect(function(p)
	HelpElfClient.FadeOutElf(p)
end)

function HelpElfClient.PlayAnimation(instance, childName: string, p: number)
	local animations = instance:WaitForChild("Animations")
	local animator = instance:FindFirstChildOfClass("Humanoid"):WaitForChild("Animator")
	local child = animations:FindFirstChild(childName)

	if child then
		animator:LoadAnimation(child):Play(nil, nil, p)
	end
end

function HelpElfClient.StopAnimation(instance, p: string)
	local playingAnimationTracks = instance:FindFirstChildOfClass("Humanoid"):WaitForChild("Animator"):GetPlayingAnimationTracks()

	for _, playingAnimationTrack in pairs(playingAnimationTracks) do
		if playingAnimationTrack.Animation.Name == p then
			playingAnimationTrack:Stop()
		end
	end
end

function HelpElfClient.FadeOutElf(folder, value: number)
	local v2 = value or 1
	local tweenInfo = TweenInfo.new(v2)

	for _, descendant in pairs(folder:GetDescendants()) do
		if descendant:IsA("BasePart") then
			descendant.CanCollide = false
			descendant.CanTouch = false
			descendant.CanQuery = false
		end

		if descendant:IsA("BasePart") or descendant:IsA("Decal") then
			TweenService:Create(descendant, tweenInfo, {
				Transparency = 1
			}):Play()
		end
	end

	task.delay(v2, function()
		folder:Destroy()
	end)
end

function HelpElfClient.AddElfMessage(p: string, _, _: boolean)
	Client.PopUpUI.AddPopUp(p, "elf")
end

function HelpElfClient.AttemptHelpElf(instance)
	local elfType = instance:GetAttribute("ElfType")

	if elfType and v[elfType] then
		v[elfType].AttemptHelpElf(instance)
	end
end

function LoadElfModules()
	local elfModules = script.ElfModules

	for _, moduleScript in pairs(elfModules:GetChildren()) do
		local v2 = v
		local name = moduleScript.Name
		local module = require(moduleScript)
		v2[name] = module
	end
end

function ElfAdded(instance)
	local animations = instance:WaitForChild("Animations")
	local animator = instance:FindFirstChildOfClass("Humanoid"):WaitForChild("Animator")
	local idle = animations:FindFirstChild("Idle")

	if idle then
		animator:LoadAnimation(idle):Play()
	end

	instance:GetAttributeChangedSignal("Rescued"):Connect(function()
		if not instance:GetAttribute("Rescued") then
			return
		end

		local elfSoundLoop = instance:FindFirstChild("ElfSoundLoop", true)

		if not elfSoundLoop then
			return
		end

		elfSoundLoop:Stop()
	end)
end

function RandomElfAdded(instance)
	local elfRandom = game.ReplicatedStorage:WaitForChild("Core"):WaitForChild("Animations"):WaitForChild("ElfRandom")
	local animator = instance:WaitForChild("Humanoid"):WaitForChild("Animator")
	local children = elfRandom:GetChildren()
	animator:LoadAnimation(children[random:NextInteger(1, #children)]):Play()
end

function HelpElfClient.Init()
	task.spawn(function()
		LoadElfModules()
	end)
	Client.Utility.ForAllTagged("ChristmasElf", ElfAdded)
	Client.Utility.ForAllTagged("RandomAnimElf", RandomElfAdded)
end

return HelpElfClient