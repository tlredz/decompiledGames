local parent = script.Parent
local cells = script:GetAttribute("Cells")
local FPS = script:GetAttribute("FPS")

while task.wait() do
	for i = 0, cells.Y - 1 do
		for i2 = 0, cells.X - 1 do
			parent.ImageRectOffset = Vector2.new(parent.ImageRectSize.X * i2, parent.ImageRectSize.Y * i)
			task.wait(1 / FPS)

			if not parent:IsDescendantOf(game) then
				return
			end
		end
	end
end