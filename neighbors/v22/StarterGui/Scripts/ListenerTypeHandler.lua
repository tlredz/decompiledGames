local createVector = vector.create
local localPlayer = game.Players.LocalPlayer
localPlayer.Character:WaitForChild("HumanoidRootPart")
local SoundService = game:GetService("SoundService")
local _ = {
	Idle = 1,
	Queued = 2,
	Matched = 3,
	Dead = 4
}

local function update()
	local state = localPlayer:GetAttribute("State")

	if state == 1 or state == 2 then
		SoundService:SetListener(
			Enum.ListenerType.CFrame,
			CFrame.new(localPlayer:GetAttribute("IdlePosition") or createVector(0, 20000, 0))
		)
	else
		SoundService:SetListener(Enum.ListenerType.Camera)
	end
end

localPlayer:GetAttributeChangedSignal("State"):connect(function()
	return update()
end)
localPlayer:GetAttributeChangedSignal("IdlePosition"):connect(function()
	return update()
end)
update()