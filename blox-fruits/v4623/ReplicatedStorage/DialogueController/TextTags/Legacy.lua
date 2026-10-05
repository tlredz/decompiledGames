local Legacy = {}

for k, metadata in {
	AnimateYield = "yieldAfter",
	AnimateStyle = "style",
	AnimateEffect = "effect",
	AnimateStepFrequency = "stepFrequency",
	AnimateStepTime = "stepTime",
	AnimateStyleTime = "styleTime",
	AnimateStyleNumPeriods = "styleNumPeriods",
	AnimateStyleAmplitude = "styleAmplitude"
} do
	table.insert(Legacy, {
		names = { k },
		metadata = metadata,
		point = k == "AnimateYield"
	})
end

return Legacy