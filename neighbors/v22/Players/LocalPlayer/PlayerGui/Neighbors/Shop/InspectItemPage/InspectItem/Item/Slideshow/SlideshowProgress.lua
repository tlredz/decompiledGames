local parent = script.Parent
local uIPageLayout = parent.UIPageLayout

while task.wait(2 + uIPageLayout.TweenTime) do
	if parent.Parent.Parent.Visible and parent.Visible then
		uIPageLayout:Next()
	end
end