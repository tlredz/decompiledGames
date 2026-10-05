local CommonUtils = require(script.Parent.Parent:WaitForChild("CommonUtils"))
CommonUtils.get("FlagUtil")
local _ = {
	SERVER_AUTHORITY_CHANGED = "SERVER_AUTHORITY_CHANGED",
	ACTIONS_RELOADED = "ACTIONS_RELOADED"
}
local ActionController = {}
ActionController.__index = ActionController

function ActionController.new()
	local self = setmetatable({}, ActionController)
	self.enabled = true
	return self
end

function ActionController.initializeActions(data, state)
	data.connectionUtil:trackConnection(
		"SERVER_AUTHORITY_CHANGED",
		data.eventBus:subscribe("SERVER_AUTHORITY_CHANGED"):Connect(function()
			state.actions = {}
		end)
	)

	if state.actions.MoveAction and state.actions.JumpAction or not state.player then
		return
	end

	pcall(function()
		local inputContexts = script.Parent.Parent.InputContexts

		if data.isServerAuthority then
			inputContexts = state.player.InputContexts
		end

		local characterContext = inputContexts.CharacterContext
		state.actions = {
			MoveAction = characterContext.MoveAction,
			JumpAction = characterContext.JumpAction
		}
		data.eventBus:publish("ACTIONS_RELOADED")
	end)
end

function ActionController:update()
	self.moveVector = self.actions.MoveAction:GetState()
	self.isJumping = self.actions.JumpAction:GetState()
end

function ActionController.Enable(_, _: boolean) end

return ActionController