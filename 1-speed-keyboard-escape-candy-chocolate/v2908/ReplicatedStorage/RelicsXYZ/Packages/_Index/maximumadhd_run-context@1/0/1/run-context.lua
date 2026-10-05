local UserInputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")
local RunService = game:GetService("RunService")
local VRService = game:GetService("VRService")
local isEdit = false
local isServer = RunService:IsServer()
local isClient = RunService:IsClient()
local isStudio = RunService:IsStudio()
local isOnline = game.JobId ~= ""
pcall(function()
	isEdit = RunService:IsEdit()
end)
return table.freeze({
	Identity = isEdit and "Edit" or isServer and "Server" or "Client",
	IsRCC = isOnline and isServer,
	IsEdit = isEdit,
	IsTestRun = isStudio and not isEdit,
	IsServer = isServer,
	IsClient = isClient,
	IsStudio = isStudio,
	IsOnline = isOnline,
	IsTenFoot = GuiService:IsTenFootInterface(),
	IsTouch = UserInputService.TouchEnabled,
	IsVR = VRService.VREnabled
})