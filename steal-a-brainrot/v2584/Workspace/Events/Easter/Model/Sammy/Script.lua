local ReplicatedStorage = game:GetService("ReplicatedStorage")
local animator = script.Parent.Humanoid.Animator
local animation = script.Animation
local track = nil

local function update()
	local easterNPCEvent = ReplicatedStorage:GetAttribute("EasterNPCEvent") == true

	if easterNPCEvent and not track then
		track = animator:LoadAnimation(animation)
		track.Looped = true
		track:Play()
	elseif not easterNPCEvent and track then
		track:Stop(0)
		track:Destroy()
		track = nil
	end
end

ReplicatedStorage:GetAttributeChangedSignal("EasterNPCEvent"):Connect(update)
update()