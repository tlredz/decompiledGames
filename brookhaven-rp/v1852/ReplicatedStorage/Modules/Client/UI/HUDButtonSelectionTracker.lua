local v = nil
local HUDButtonSelectionTracker = {}

function HUDButtonSelectionTracker.SetLastClickedButton(p)
	v = p
end

function HUDButtonSelectionTracker.GetLastClickedButton()
	if v == nil then
		return nil
	end

	if v.Parent ~= nil then
		return v
	end

	v = nil
	return nil
end

function HUDButtonSelectionTracker.ClearIfMatches(p)
	if v ~= p then
		return
	end

	v = nil
end

return HUDButtonSelectionTracker