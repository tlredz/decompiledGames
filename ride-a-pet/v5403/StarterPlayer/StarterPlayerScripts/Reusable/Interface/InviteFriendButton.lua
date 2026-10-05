local CollectionService = game:GetService("CollectionService")
local SocialService = game:GetService("SocialService")
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local now = 0

local function Invite()
	if os.clock() - now < 2 then
		return
	end

	now = os.clock()
	pcall(function()
		SocialService:CanSendGameInviteAsync(localPlayer)
	end)
	pcall(function()
		SocialService:PromptGameInvite(localPlayer)
	end)
end

local v = {}
local v2 = {}

local function LiftSurfaceGui(instance)
	local surfaceGui = instance:FindFirstAncestorOfClass("SurfaceGui")

	if not surfaceGui or v2[surfaceGui] or surfaceGui:IsDescendantOf(localPlayer.PlayerGui) then
		return
	end

	local parent = surfaceGui.Parent

	if not (parent and parent:IsA("BasePart")) then
		return
	end

	v2[surfaceGui] = true
	surfaceGui.Adornee = parent
	surfaceGui.Parent = localPlayer.PlayerGui
end

local function Hook(instance)
	if v[instance] then
		return
	end

	v[instance] = true

	if instance:IsA("GuiButton") then
		LiftSurfaceGui(instance)
		instance.Activated:Connect(Invite)
	elseif instance:IsA("BasePart") then
		local clickDetector = instance:FindFirstChildWhichIsA("ClickDetector")

		if clickDetector then
			clickDetector.MouseClick:Connect(Invite)
		end

		local proximityPrompt = instance:FindFirstChildWhichIsA("ProximityPrompt")

		if proximityPrompt then
			proximityPrompt.Triggered:Connect(Invite)
		end
	elseif instance:IsA("ProximityPrompt") then
		instance.Triggered:Connect(Invite)
	end
end

for _, v3 in CollectionService:GetTagged("InviteFriend") do
	Hook(v3)
end

CollectionService:GetInstanceAddedSignal("InviteFriend"):Connect(Hook)