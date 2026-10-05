local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local mouse = localPlayer:GetMouse()
local flag = false
require(ReplicatedStorage.Modules.Tool)
local DecoyTool = {}
local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Exclude

local function getTargetPlayer()
	local raycastResult = workspace:Raycast(mouse.UnitRay.Origin, mouse.UnitRay.Direction * 500, raycastParams)

	if not raycastResult then
		return nil
	end

	local model = raycastResult.Instance:FindFirstAncestorOfClass("Model")
	local playerFromCharacter = model and Players:GetPlayerFromCharacter(model)

	if playerFromCharacter and playerFromCharacter ~= localPlayer then
		return playerFromCharacter
	end

	return nil
end

function DecoyTool:Initialize()
	self.TransformUI = script:WaitForChild("TransformGui")
	self.ClickConnection = self.TransformUI:WaitForChild("Reset").MouseButton1Click:Connect(function()
		self:FireEvent("ResetSize")
	end)
end

function DecoyTool.Activated(object)
	if flag then
		return
	end

	flag = true
	task.delay(1, function()
		flag = false
	end)
	local raycastResult = workspace:Raycast(mouse.UnitRay.Origin, mouse.UnitRay.Direction * 500, raycastParams)
	local playerFromCharacter

	if raycastResult then
		local model = raycastResult.Instance:FindFirstAncestorOfClass("Model")
		playerFromCharacter = model and Players:GetPlayerFromCharacter(model)

		if not playerFromCharacter or playerFromCharacter == localPlayer then
			playerFromCharacter = nil
		end
	end

	if playerFromCharacter then
		object:FireEvent("MorphIntoTarget", playerFromCharacter)
	end
end

function DecoyTool.Equipped(player)
	raycastParams.FilterDescendantsInstances = { player.Character }
	player.TransformUI.Parent = localPlayer.PlayerGui
end

function DecoyTool.Unequipped(p)
	p.TransformUI.Parent = script
end

function DecoyTool.Destroyed(p)
	if p.ClickConnection then
		p.ClickConnection:Disconnect()
	end
end

return DecoyTool