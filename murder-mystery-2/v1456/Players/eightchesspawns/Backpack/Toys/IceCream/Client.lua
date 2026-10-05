Tool = script.Parent
local flag = false

function onEquippedLocal(p)
	flag = true

	if p == nil then
		return
	end

	while flag do
		while Tool.Enabled and flag do
			wait(0.01)
		end

		while not Tool.Enabled and flag do
			wait(0.01)
		end
	end
end

local lickAnim = nil
local v = true

function onActivated()
	if not (Tool.Enabled and v) then
		return
	end

	v = false
	local humanoid = script.Parent.Parent:FindFirstChild("Humanoid")

	if humanoid then
		lickAnim = Tool:FindFirstChild("LickAnim")

		if lickAnim then
			lickAnim = humanoid:LoadAnimation(lickAnim)
			lickAnim:Play()
		end

		wait(0.3)
		wait(2)
	end

	v = true
end

function onUnequippedLocal()
	if lickAnim then
		lickAnim:Stop()
	end

	flag = false
end

Tool.Equipped:connect(onEquippedLocal)
Tool.Unequipped:connect(onUnequippedLocal)
Tool.Activated:connect(onActivated)