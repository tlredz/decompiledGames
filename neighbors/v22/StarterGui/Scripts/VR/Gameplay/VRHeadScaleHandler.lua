local localPlayer = game.Players.LocalPlayer
local currentCamera = workspace.CurrentCamera
local VRService = game:GetService("VRService")
local bodyHeightScale = localPlayer.Character:WaitForChild("Humanoid"):WaitForChild("BodyHeightScale")

if not VRService.VREnabled then
	return
end

-- equivalent calls inferred from this helper; original call sites unknown
local function update()
	currentCamera.HeadScale = bodyHeightScale.Value
end

bodyHeightScale:GetPropertyChangedSignal("Value"):connect(update)
update() -- equivalent call inferred; original call site unknown