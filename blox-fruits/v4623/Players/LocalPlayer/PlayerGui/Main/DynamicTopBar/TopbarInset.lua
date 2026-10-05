local GuiService = game:GetService("GuiService")
local parent = script.Parent
local version = script.Parent:WaitForChild("Version")

local function update()
	local topbarInset = GuiService.TopbarInset
	local v = topbarInset.Height > 36
	local v2 = v and 2 or -2
	parent.Size = UDim2.new(0, topbarInset.Width - 12, 0, topbarInset.Height - v2)
	parent.Position = UDim2.new(0, topbarInset.Min.X + 12, 0, -topbarInset.Height - v2)
	version.TextYAlignment = v and Enum.TextYAlignment.Bottom or Enum.TextYAlignment.Center
end

update()
GuiService:GetPropertyChangedSignal("TopbarInset"):Connect(update)