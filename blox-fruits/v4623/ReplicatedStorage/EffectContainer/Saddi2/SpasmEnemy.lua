local Util = require(game.ReplicatedStorage:WaitForChild("Util"))
local RunService = game:GetService("RunService")
return function(player)
	local indicator = player.Indicator
	local character = player.Character
	local duration = player.Duration or 1
	local primaryPart = character.PrimaryPart or character:FindFirstChild("HumanoidRootPart")
	local now = tick()
	local random = Random.new()

	while true do
		local lastTime = tick()
		local v = math.min(1, (lastTime - now) / duration)
		primaryPart.CFrame *= CFrame.Angles(
			random:NextNumber(-1, 1) * 3.141592653589793,
			random:NextNumber(-1, 1) * 3.141592653589793,
			random:NextNumber(-1, 1) * 3.141592653589793
		)

		if v == 1 or not (indicator and indicator:IsDescendantOf(workspace) and primaryPart and primaryPart:IsDescendantOf(workspace)) then
			break
		end

		RunService.RenderStepped:Wait()
		local _ = tick() - lastTime
	end

	primaryPart.CFrame = Util.Misc.AlignCFrame(primaryPart.CFrame)
end