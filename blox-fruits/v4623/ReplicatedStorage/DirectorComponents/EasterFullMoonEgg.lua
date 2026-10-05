local class = {}
class.__index = class
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
require(ReplicatedStorage:WaitForChild("Director"))
local Maid = require(game.ReplicatedStorage.Util.Maid)
RunService:IsServer()
local isClient = RunService:IsClient()

function class:Init()
	self.Maid = Maid.new()

	if not isClient then
		return
	end

	local sky = game.Lighting:WaitForChild("Sky")
	local moonTextureId = sky.MoonTextureId
	sky.MoonTextureId = "rbxassetid://134552772008492"
	self.Maid:GiveTask(function()
		sky.MoonTextureId = moonTextureId
	end)
	local currentCamera = workspace.CurrentCamera
	local flag = false
	local now = 0
	local RayMap = require(game.ReplicatedStorage.Util.RayMap)
	self.Maid.updateMoonEgg = RunService.RenderStepped:Connect(function(_: number)
		local moonDirection = game.Lighting:GetMoonDirection()
		local dot = moonDirection:Dot(workspace.CurrentCamera.CFrame.LookVector)
		local v, v2, _ = RayMap(workspace.CurrentCamera.CFrame.p, moonDirection * 1000)
		local v3 = math.acos(dot)
		local v4 = v3 ~= v3 and 0 or v3
		local worldToViewportPoint, v5 = currentCamera:WorldToViewportPoint(v2)
		local v6 = v5 and worldToViewportPoint.Z > 0

		if v or not (v4 <= 0.3490658503988659 and v6) then
			if flag then
				flag = false
			end
		elseif flag == false then
			flag = true
			now = tick()
		elseif flag and tick() - now > 10 then
			self.Instance.Collect:FireServer()
			self.Instance:Destroy()
		end
	end)
end

function class:Destroy()
	if self.Maid then
		self.Maid:DoCleaning()
	end
end

return {
	new = function(instance, _)
		return (setmetatable({
			Instance = instance
		}, class))
	end,
	ancestor = nil
}