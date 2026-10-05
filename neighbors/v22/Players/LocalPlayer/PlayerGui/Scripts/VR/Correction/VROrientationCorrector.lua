local character = game.Players.LocalPlayer.Character
local VRService = game:GetService("VRService")

if not VRService.VREnabled then
	return
end

local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
local humanoid = character:WaitForChild("Humanoid")
local attachment = Instance.new("Attachment", humanoidRootPart)
attachment.Name = "VROrientationAttachment"
local clone = script.AlignOrientation:Clone()
clone.Attachment0 = attachment
clone.CFrame = humanoidRootPart.CFrame
clone.Parent = humanoidRootPart

local function update_align_enabled()
	clone.Enabled = not (humanoid.Sit or character:GetAttribute("Carried") or character:GetAttribute("Ragdoll"))
end

humanoidRootPart:GetPropertyChangedSignal("CFrame"):connect(function()
	clone.CFrame = humanoidRootPart.CFrame
end)
humanoid:GetPropertyChangedSignal("Sit"):connect(function()
	return update_align_enabled()
end)
character:GetAttributeChangedSignal("Carried"):connect(function()
	return update_align_enabled()
end)
character:GetAttributeChangedSignal("Ragdoll"):connect(function()
	return update_align_enabled()
end)