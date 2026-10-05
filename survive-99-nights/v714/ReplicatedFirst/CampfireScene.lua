local CollectionService = game:GetService("CollectionService")
local localPlayer = game.Players.LocalPlayer
local v = CollectionService:GetTagged("Body" .. localPlayer.UserId)[1]
local campfireSet = game.ReplicatedFirst:WaitForChild("CampfireSet")

if localPlayer.Character or v then
	campfireSet:Destroy()
	return
end

campfireSet:PivotTo(CFrame.new(0, 300, 0))
campfireSet.Parent = workspace
workspace.CurrentCamera.CameraType = Enum.CameraType.Scriptable
workspace.CurrentCamera.CFrame = campfireSet.Camera.CFrame

while localPlayer.Character == nil and v == nil do
	task.wait()
	workspace.CurrentCamera.CameraType = Enum.CameraType.Scriptable
	workspace.CurrentCamera.CFrame = campfireSet.Camera.CFrame
	v = CollectionService:GetTagged("Body" .. localPlayer.UserId)[1]
end

campfireSet:Destroy()

if localPlayer.Character then
	workspace.CurrentCamera.CameraType = Enum.CameraType.Custom
	workspace.CurrentCamera.CameraSubject = localPlayer.Character:WaitForChild("Humanoid")
elseif v then
	local humanoid = v:FindFirstChild("Humanoid")
	workspace.CurrentCamera.CameraType = Enum.CameraType.Fixed
	workspace.CurrentCamera.CameraType = Enum.CameraType.Custom
	workspace.CurrentCamera.CameraSubject = humanoid
end