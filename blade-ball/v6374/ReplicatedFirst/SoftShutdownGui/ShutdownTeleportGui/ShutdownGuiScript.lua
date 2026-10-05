local TweenService = game:GetService("TweenService")
local main = script.Parent:WaitForChild("Main")
local contents = main:WaitForChild("Contents")
local announcementBar = contents:WaitForChild("AnnouncementBar")
local top = contents:WaitForChild("RadialBar"):WaitForChild("Top")
task.defer(function()
	while true do
		task.wait()
		top.Rotation += 3
	end
end)
local uIPadding = announcementBar:WaitForChild("UIPadding")
uIPadding.PaddingRight = UDim.new(0.5, 0)
TweenService:Create(announcementBar:WaitForChild("UIPadding"), TweenInfo.new(1, Enum.EasingStyle.Circular), {
	PaddingRight = UDim.new(0, 0)
}):Play()
main.GroupTransparency = 1
TweenService:Create(main, TweenInfo.new(1, Enum.EasingStyle.Circular), {
	GroupTransparency = 0
}):Play()