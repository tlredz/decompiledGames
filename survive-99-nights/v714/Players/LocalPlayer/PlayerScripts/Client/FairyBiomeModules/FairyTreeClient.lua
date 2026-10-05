local localPlayer = game.Players.LocalPlayer
local Client = require(localPlayer.PlayerScripts.Client)
local TweenService = game:GetService("TweenService")

function TweenColourHSV(p, color: Color3, p2)
	local HSV, v, v2 = p.Color:ToHSV()
	local HSV2, v3, v4 = color:ToHSV()
	Client.TweenModule.new(function(p3)
		local v5 = HSV + (HSV2 - HSV) * p3
		local v6 = v + (v3 - v) * p3
		local v7 = v2 + (v4 - v2) * p3
		p.Color = Color3.fromHSV(v5, v6, v7)
	end, p2):Play()
end

function TweenColour(p, color: Color3, p2)
	local color2 = p.Color
	Client.TweenModule.new(function(p3)
		p.Color = color2:Lerp(color, p3)
	end, p2):Play()
end

local FairyTreeClient = {
	TweenColour = TweenColour
}

function RestoreTreeColour(folder, _)
	local position = localPlayer.Character and localPlayer.Character:GetPivot().Position

	if not position or (position - folder:GetPivot().Position).Magnitude > 1000 then
		return
	end

	for _, part in pairs(folder:GetDescendants()) do
		if part:IsA("BasePart") and part.Transparency > 0 and part.Transparency < 1 then
			TweenService:Create(part, TweenInfo.new(1), {
				Transparency = 0
			}):Play()
		end
	end

	for _, part in pairs(folder.FairyTree:GetDescendants()) do
		if part:IsA("BasePart") and part:GetAttribute("PartColour") then
			TweenColour(part, part:GetAttribute("PartColour"), 1)
		end
	end
end

function FairyTreeAdded(instance)
	if instance.Parent ~= workspace:WaitForChild("Map"):WaitForChild("Landmarks") then
		return
	end

	local animator = instance:WaitForChild("FairyTree"):WaitForChild("AnimationController"):WaitForChild("Animator")
	local animations = instance:WaitForChild("FairyTree"):WaitForChild("Animations")
	local track = animator:LoadAnimation(animations:WaitForChild("WitheredIdle"))
	local track2 = animator:LoadAnimation(animations:WaitForChild("RestoredIdle"))
	local track3 = animator:LoadAnimation(animations:WaitForChild("Restoration"))

	if instance:GetAttribute("Restored") then
		track2:Play()
		return
	end

	track:Play()
	task.spawn(function()
		instance:GetAttributeChangedSignal("Restored"):Wait()

		if instance.Parent then
			track3:Play()
			task.delay(1.5, function()
				RestoreTreeColour(instance)
			end)
			task.wait(1)
			track:Stop()
			track2:Play()
		end
	end)
end

function FairyTreeClient.Init()
	Client.Utility.ForAllTagged("FairyTree", FairyTreeAdded)
end

return FairyTreeClient