local DialogNode = {}
DialogNode.__index = DialogNode

function DialogNode.new()
	local self = setmetatable({}, DialogNode)
	self.Message = nil
	self.ButtonAppearDelay = nil
	self.Buttons = {}
	self.DelayedContinue = nil
	self:_Init()
	return self
end

function DialogNode:SetMessage(picture, text, soundID)
	self.Message = {
		Picture = picture,
		Text = text,
		SoundID = soundID
	}
end

function DialogNode:SetButtonAppearDelay(buttonAppearDelay)
	self.ButtonAppearDelay = buttonAppearDelay
end

function DialogNode:ContinueAfterDelay(delay, nextDialog)
	self.DelayedContinue = {
		Delay = delay,
		NextDialog = nextDialog
	}
end

function DialogNode:AddButton(text, nextDialog, dialogActionKey)
	local buttons = self.Buttons
	local isCloseButton

	if not nextDialog then
		isCloseButton = not dialogActionKey or nil
	end

	table.insert(buttons, {
		Text = text,
		NextDialog = nextDialog,
		IsCloseButton = isCloseButton,
		DialogActionKey = dialogActionKey
	})
end

function DialogNode:AddCloseButton(value)
	self:AddButton(value or "Goodbye", nil)
end

function DialogNode.IsDialogActionAvailable(p, p2)
	if not p2 then
		return false
	end

	local search

	search = function(p3)
		for _, v in pairs(p3.Buttons or {}) do
			if v.DialogActionKey == p2 or v.NextDialog and search(v.NextDialog) then
				return true
			end
		end

		return p3.DelayedContinue and p3.DelayedContinue.NextDialog and search(p3.DelayedContinue.NextDialog)
	end

	return (search(p))
end

function DialogNode:_Init() end

return DialogNode