local EmoteCatalog = require(script.Parent.EmoteCatalog)
local v = {}
local EmotePlayback = {}

function EmotePlayback.load(animator, childName)
	local v2 = EmoteCatalog.get(childName)

	if not v2 then
		return nil
	end

	local assetId = EmoteCatalog.assetId(childName)

	if not assetId and EmoteCatalog.StudioPreview then
		local RunService = game:GetService("RunService")

		if RunService:IsStudio() then
			assetId = v[childName]

			if not assetId then
				local clips = script.Parent:FindFirstChild("Clips")
				local child = clips and clips:FindFirstChild(childName)

				if child then
					local success, result = pcall(function()
						local AnimationClipProvider = game:GetService("AnimationClipProvider")
						return AnimationClipProvider:RegisterAnimationClip(child)
					end)

					if success then
						v[childName] = result
						assetId = result
					end
				end
			end
		end
	end

	if not assetId then
		return nil
	end

	local animation = Instance.new("Animation")
	animation.AnimationId = assetId
	animation.Name = "ValleyEmote_" .. childName
	local success, result = pcall(function()
		return animator:LoadAnimation(animation)
	end)
	animation:Destroy()

	if not success then
		return nil
	end

	result.Name = "ValleyEmote_" .. childName
	result.Priority = Enum.AnimationPriority.Action3
	result.Looped = v2.Loop
	return result
end

function EmotePlayback.dispose(instance)
	if instance then
		instance:Stop(0.12)
		task.delay(0.2, function()
			instance:Destroy()
		end)
	end
end

return EmotePlayback