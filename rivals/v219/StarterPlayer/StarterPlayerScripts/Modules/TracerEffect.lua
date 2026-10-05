local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local CONSTANTS = require(ReplicatedStorage.Modules.CONSTANTS)
local BetterDebris = require(ReplicatedStorage.Modules.BetterDebris)
local Utility = require(ReplicatedStorage.Modules.Utility)
local tracerEffect = Players.LocalPlayer.PlayerScripts.Assets.Misc:WaitForChild("TracerEffect")
local colorSequence = ColorSequence.new(Color3.fromRGB(255, 81, 0))
local colorSequence2 = ColorSequence.new(Color3.fromRGB(255, 8, 0))
local TracerEffect = {}

function TracerEffect:VerifyTracerData(options, options2, options3)
	local v = options or {}
	v.RaycastResults = v.RaycastResults or {}
	v.IsLocal = v.IsLocal or false
	v.IsEnemy = v.IsEnemy or false
	local v2 = options2 or {}
	v2.EnemyColor = v2.EnemyColor or nil
	v2.Color = v2.Color or nil
	v2.BeamProperties = v2.BeamProperties or nil
	v2.MaxLengthFirstPerson = v2.MaxLengthFirstPerson or nil
	v2.MaxLength = v2.MaxLength or nil
	v2.NoDistanceDelay = v2.NoDistanceDelay or nil
	v2.Template = v2.Template or nil
	v2.InitCallback = v2.InitCallback or nil
	v2.UpdateSpeed = v2.UpdateSpeed or nil
	v2.CustomUpdate = v2.CustomUpdate or nil
	v2.PlayFlyBySound = v2.PlayFlyBySound or nil
	local v3 = options3 or {}
	v3.FriendlyTracerColor = v3.FriendlyTracerColor or colorSequence
	v3.ActuallyFirstPerson = v3.ActuallyFirstPerson or false
	v3.MuzzlePosition = v3.MuzzlePosition or nil
	return v, v2, v3
end

function TracerEffect:Play(p, p2, p3)
	local v, v2, v3 = self:VerifyTracerData(p, p2, p3)

	if not v3.MuzzlePosition then
		return
	end

	local v4 = {}

	for _, raycastResult in pairs(v.RaycastResults) do
		if v.IsLocal then
			continue
		end

		local lastRaycastResult = raycastResult

		while lastRaycastResult.LastRaycastResult do
			lastRaycastResult = lastRaycastResult.LastRaycastResult
		end

		v4[lastRaycastResult] = v4[lastRaycastResult] or {}
		table.insert(v4[lastRaycastResult], raycastResult)
	end

	for _, v5 in pairs(v4) do
		local v6 = nil
		local v7 = nil

		for _, v8 in pairs(v5) do
			local startPosition = v8.StartPosition or v3.MuzzlePosition
			local closestPoint = Ray.new(startPosition, (v8.Position - startPosition).Unit):ClosestPoint(workspace.CurrentCamera.CFrame.Position)

			if not (not v6 or (closestPoint - workspace.CurrentCamera.CFrame.Position).Magnitude < (v6 - workspace.CurrentCamera.CFrame.Position).Magnitude) then
				continue
			end

			v7 = startPosition
			v6 = closestPoint
		end

		if not v6 then
			continue
		end

		local magnitude = (v6 - v7).Magnitude

		if not (magnitude > 1 and magnitude < CONSTANTS.RENDER_DISTANCE) then
			continue
		end

		local v8 = 1 - ((v6 - workspace.CurrentCamera.CFrame.Position).Magnitude / 50) ^ 3

		if v2.PlayFlyBySound then
			v2.PlayFlyBySound(v6, v8, 50)
		else
			Utility:CreateSound("rbxassetid://14767954026", 1 * v8, 1.4 + 0.2 * math.random(), v6, true, 10, 50, 50)
		end
	end

	local maxLengthFirstPerson

	if v3.ActuallyFirstPerson then
		maxLengthFirstPerson = v2.MaxLengthFirstPerson or 75
	else
		maxLengthFirstPerson = v2.MaxLength or 15
	end

	for k, raycastResult in pairs(v.RaycastResults) do
		local v5 = raycastResult
		local v6 = k
		task.defer(function()
			local lastRaycastResult = v5
			local total = 0

			while lastRaycastResult and lastRaycastResult.LastRaycastResult and not v2.NoDistanceDelay do
				total += ((lastRaycastResult.StartPosition or v3.MuzzlePosition) - v5.Position).Magnitude
				lastRaycastResult = lastRaycastResult.LastRaycastResult
			end

			if total > 0 then
				wait(1.6666666666666667 / (800 / total))
			end

			local startPosition = v5.StartPosition or v3.MuzzlePosition
			local magnitude = (startPosition - v5.Position).Magnitude
			local clone = (v2.Template or tracerEffect):Clone()
			clone.CFrame = CFrame.identity
			clone.Parent = workspace
			BetterDebris:AddItem(clone, 10)

			if v2.InitCallback then
				v2.InitCallback(clone, v6)
			else
				local beam = clone.Beam
				local color

				if v.IsEnemy then
					color = v2.EnemyColor or colorSequence2
				else
					color = v2.Color or v3.FriendlyTracerColor
				end

				beam.Color = color
				clone.Attachment1.PointLight.Color = clone.Beam.Color.Keypoints[1].Value

				for k2, v8 in pairs(v2.BeamProperties or {}) do
					clone.Beam[k2] = v8
				end
			end

			local attachment0 = clone.Attachment0
			local attachment1 = clone.Attachment1
			Utility:RenderstepForLoop(0, 100, v2.UpdateSpeed or 800 / magnitude, function(p4)
				local v7 = p4 / 100

				if v2.CustomUpdate then
					v2.CustomUpdate(clone, attachment0, attachment1, v7, startPosition, v5.Position)
					return
				end

				attachment1.WorldPosition = startPosition:Lerp(v5.Position, v7)
				attachment0.WorldPosition = attachment1.WorldPosition + (v5.Position - startPosition).Unit * math.min(
					(attachment1.WorldPosition - v5.Position).Magnitude,
					maxLengthFirstPerson
				)
			end)
			clone:Destroy()
		end)
	end
end

return TracerEffect