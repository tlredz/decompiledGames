local guiObjects = {}
local v = {}
local v2 = {}

local function updateStack(p)
	for _, v3 in guiObjects do
		v3.Visible = false
	end

	for k, v3 in v2 do
		v3.Visible = k == #v2

		if v3.Visible and v[v3] then
			v[v3](p)
		end
	end
end

local WindowService = {}

function WindowService.ToggleFrame(_, p, p2)
	local v3 = guiObjects[p] or p

	if type(v3) == "string" or v3 == nil then
		warn("Frame not found: " .. tostring(p))
		return
	end

	if v3.Visible then
		v3.Visible = false
		v2 = {}
	else
		v2 = { v3 }
	end

	updateStack(p2)
end

function WindowService.ViewFrame(_, p, p2)
	local v3 = guiObjects[p] or p

	if type(v3) == "string" or v3 == nil then
		warn("Frame not found: " .. tostring(p))
		return
	end

	v2 = { v3 }
	updateStack(p2)
end

function WindowService.CloseAllFrames(_)
	v2 = {}
	updateStack()
end

function WindowService.Back(_)
	if #v2 < 1 then
		return
	end

	local count = #v2
	v2[count].Visible = false
	table.remove(v2, count)
	updateStack()
end

function WindowService.AddToStack(_, p, p2)
	local v3 = guiObjects[p] or p

	if v3 == nil or typeof(v3) == "string" then
		warn("WindowService: Frame not found: " .. tostring(p))
		return
	end

	local index = table.find(v2, v3)

	if index then
		table.remove(v2, index)
	end

	table.insert(v2, v3)
	updateStack(p2)
end

function WindowService.GetFrame(_, p: string)
	return guiObjects[p]
end

function WindowService.RegisterFrame(_, guiObject, p: string, callback)
	if typeof(guiObject) ~= "Instance" then
		warn("WindowService: First argument must be a GuiObject")
		return
	end

	if not guiObject:IsA("GuiObject") then
		warn("WindowService: First argument must be a GuiObject")
		return
	end

	local _ = guiObjects[p] == nil
	guiObjects[p] = guiObject

	if callback then
		v[guiObject] = callback
	end
end

return WindowService