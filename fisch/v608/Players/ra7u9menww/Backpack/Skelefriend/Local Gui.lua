Tool = script.Parent
local flag = false

function onEquippedLocal(p)
	flag = true

	if p == nil then
		print("Mouse not found")
		return
	end

	while flag do
		print("Setting Mouse to go")
		p.Icon = "rbxasset://textures\\GunCursor.png"

		while Tool.Enabled and flag do
			wait(0.01)
		end

		print("Setting Mouse to wait")
		p.Icon = "rbxasset://textures\\GunWaitCursor.png"

		while not Tool.Enabled and flag do
			wait(0.01)
		end
	end
end

function onUnequippedLocal()
	flag = false
end

Tool.Equipped:connect(onEquippedLocal)
Tool.Unequipped:connect(onUnequippedLocal)