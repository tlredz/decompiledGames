local ColorEncoder = require(game.ReplicatedStorage.Util.ColorEncoder)
local ColorPaletteCache = require(game.ReplicatedStorage.Util.ColorPaletteCache)
local ColorSequenceUtil = require(game.ReplicatedStorage.Util.ColorSequenceUtil)

local function WrapColorSequenceConstructor(sequence, instance, childName: string)
	if instance == nil or instance.Parent == nil then
		warn("WrapColorSequenceConstructor: WARNING, MISSING PLAYER" .. [[

 
]] .. "Traceback:\n" .. debug.traceback())
		return sequence
	end

	local child = instance:FindFirstChild(childName)

	if child == nil then
		return sequence
	end

	local v = ColorPaletteCache.get(child)

	if v == nil or v.AllColorsUnchanged then
		return sequence
	end

	local times = nil

	for _, keypoint in ipairs(sequence.Keypoints) do
		if ColorEncoder.isColorDataEncoded(keypoint.Value) then
			return sequence
		end

		local gradientFor = ColorPaletteCache.getGradientFor(v, keypoint.Value)

		if gradientFor == nil then
			continue
		end

		times = times or {}

		for _, keypoint2 in ipairs(gradientFor.Keypoints) do
			table.insert(times, keypoint2.Time)
		end
	end

	local mergeKeypointTimes = ColorSequenceUtil.mergeKeypointTimes(sequence, times)
	local colorSequenceKeypoints = table.create(#mergeKeypointTimes)

	for _, mergeKeypointTime in ipairs(mergeKeypointTimes) do
		local eval = ColorSequenceUtil.eval(sequence, mergeKeypointTime)
		table.insert(
			colorSequenceKeypoints,
			ColorSequenceKeypoint.new(mergeKeypointTime, ColorPaletteCache.transformColor(v, eval, mergeKeypointTime))
		)
	end

	return ColorSequence.new(colorSequenceKeypoints)
end

return WrapColorSequenceConstructor