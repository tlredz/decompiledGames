local createVector = vector.create
local Util = require(game.ReplicatedStorage:WaitForChild("Util"))
local RunService = game:GetService("RunService")
return function(player)
	local indicator = player.Indicator
	local reference = player.Reference
	local character = player.Character
	local duration = player.Duration or 1

	if not reference then
		return
	end

	local primaryPart = character.PrimaryPart or character:FindFirstChild("HumanoidRootPart")
	local offset = player.Offset or Vector3.new(0, 0, -primaryPart.Size.Z)
	local now = tick()
	local v = 0.016666666666666666

	while true do
		local lastTime = tick()
		local v2 = math.min(1, (lastTime - now) / duration)
		local unit = reference.Velocity * v

		if unit.Magnitude > 1 then
			unit = unit.Unit
		end

		local v3 = not player.GrowingOffset and createVector(0, 0, 0) or player.GrowingOffset * v2
		local v4 = reference.CFrame * (offset + v3) + unit
		local ray, v5, v6 = Util.Ray(
			reference.Position,
			v4 - reference.Position,
			{ workspace.Characters, workspace.Enemies }
		)

		if ray then
			v4 = v5 - v6 * primaryPart.Size.Z
		end

		if v2 == 1 or not (indicator and indicator:IsDescendantOf(workspace) and primaryPart and primaryPart:IsDescendantOf(workspace)) then
			break
		end

		if primaryPart.Anchored == false then
			primaryPart.CFrame = CFrame.new(createVector(0, 0, 0), -reference.CFrame.LookVector) + v4
		end

		RunService.Heartbeat:Wait()
		v = tick() - lastTime
	end
end