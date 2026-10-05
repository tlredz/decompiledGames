local createVector = vector.create
local GuiService = game:GetService("GuiService")
GuiService:SetGameplayPausedNotificationEnabled(false)
local part = Instance.new("Part")
part.Transparency = 1
part.Size = createVector(100, 1, 100)
part.CanCollide = true
part.Anchored = true
part.CanTouch = false
local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Include
raycastParams.FilterDescendantsInstances = { workspace.Map }

local function timeout_wait(p, fn)
	local v = fn()
	local total = 0

	while not v do
		v = fn()
		total += task.wait()

		if p < total then
			return false
		end
	end

	return v
end

local v = false

local function LoadingChanged(p)
	v = p

	if p then
	end
end

game.Players.LocalPlayer:GetPropertyChangedSignal("GameplayPaused"):Connect(function()
	local gameplayPaused = game.Players.LocalPlayer.GameplayPaused
	v = gameplayPaused

	if gameplayPaused then
	end
end)
local Net = require(game.ReplicatedStorage:WaitForChild("Modules").Net)
local remoteFunction = Net:RemoteFunction("WaitForStreamingLoad")

remoteFunction.OnClientInvoke = function(instance, p, _)
	if instance == nil then
		warn("WaitForStreamingLoad: Character was nil, only false/character is acceptable")
		return true
	end

	if instance ~= false and not timeout_wait(5, function()
		return instance == game.Players.LocalPlayer.Character
	end) then
		warn("WaitForStreamingLoad: Character was invalid/different")
		return true
	end

	if instance and not timeout_wait(5, function()
		return (instance:GetBoundingBox().p - p).Magnitude < 200
	end) then
		warn("WaitForStreamingLoad: Character refused to relocate")
		return true
	end

	timeout_wait(5, function()
		return v == false
	end)
	return true
end

local Net2 = require(game.ReplicatedStorage:WaitForChild("Modules").Net)
Net2:RemoteEvent("TeleportPad").OnClientEvent:Connect(function(cFrame)
	local v2 = time()
	local clone = part:Clone()
	clone.CFrame = cFrame
	clone.Parent = workspace._WorldOrigin

	while true do
		task.wait()

		if time() - v2 > 20 then
			break
		end

		local raycastResult = workspace:Raycast(
			cFrame.Position + createVector(0, 7.5, 0),
			createVector(-0, -30, -0),
			raycastParams
		)

		if raycastResult and raycastResult.Instance then
			break
		end
	end

	clone:Destroy()
end)