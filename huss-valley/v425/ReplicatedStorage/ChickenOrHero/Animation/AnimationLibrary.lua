local RunService = game:GetService("RunService")
local AnimationConfig = require(script.Parent.AnimationConfig)
local v = nil
return {
	prepare = function()
		if v then
			return v
		end

		local v2 = {}

		if not AnimationConfig.Enabled then
			v = v2
			return v
		end

		local clips = script.Parent:FindFirstChild("Clips")

		local function add(p, animationId, instance)
			if type(animationId) ~= "string" or animationId == "" then
				return
			end

			local animation = Instance.new("Animation")
			animation.Name = "CoH_" .. p
			animation.AnimationId = animationId
			v2[p] = {
				animation = animation,
				length = AnimationConfig.ClipLengths and AnimationConfig.ClipLengths[p] or instance and instance:GetAttribute("Duration") or 1
			}
		end

		for childName, publishedId in AnimationConfig.PublishedIds do
			add(childName, publishedId, clips and clips:FindFirstChild(childName))
		end

		if clips and RunService:IsStudio() then
			for _, keyframeSequence in clips:GetChildren() do
				local studioPreview = AnimationConfig.StudioPreview or AnimationConfig.StudioPreviewClips and AnimationConfig.StudioPreviewClips[keyframeSequence.Name]

				if not keyframeSequence:IsA("KeyframeSequence") or v2[keyframeSequence.Name] or not studioPreview then
					continue
				end

				local v3 = keyframeSequence
				local success, result = pcall(function()
					local AnimationClipProvider = game:GetService("AnimationClipProvider")
					return AnimationClipProvider:RegisterAnimationClip(v3)
				end)

				if success then
					add(keyframeSequence.Name, result, keyframeSequence)
				else
					warn("Animation preview unavailable:", keyframeSequence.Name, result)
				end
			end
		end

		v = v2
		return v2
	end
}