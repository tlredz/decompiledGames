local screenGui = Instance.new("ScreenGui")
screenGui.Name = "TooltipLayer"
screenGui.DisplayOrder = 1000000000
screenGui.IgnoreGuiInset = true
screenGui.ResetOnSpawn = false
screenGui.ScreenInsets = Enum.ScreenInsets.DeviceSafeInsets
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
return screenGui