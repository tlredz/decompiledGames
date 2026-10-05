local parent = script.Parent
local parent2 = parent.Parent
local BloodyZee = require(game.ReplicatedStorage.Modules.BloodyZee)
local blood = script:WaitForChild("Blood")
local attachment = script:WaitForChild("Attachment")

if game.Players.LocalPlayer.Character == parent2 then
	script:ClearAllChildren()
	return
end

blood.Parent = parent.FaceFrontAttachment
attachment.Parent = parent

repeat
	attachment.Blood.Enabled = _G.Settings.Gore
	blood.Enabled = attachment.Blood.Enabled
	BloodyZee:Blood(parent.CFrame * CFrame.Angles(-1.5707963267948966, 0, 0), math.random(10, 40), 80, 80)
	task.wait(math.random(5, 100) / 100)
until not (parent.Parent and parent2:GetAttribute("InUlt"))

blood.Enabled = false
attachment.Blood.Enabled = false