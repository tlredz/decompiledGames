local import = _G.import("romodel")
local playerInteractionBillboard = _G.import("viewImports"):get("playerInteractionBillboard")
local ProximityPromptService = game:GetService("ProximityPromptService")
local UserInputService = game:GetService("UserInputService")
local TextChatService = game:GetService("TextChatService")
local localPlayer = game.Players.LocalPlayer
local playerGui = localPlayer.PlayerGui
local BUTTONS = playerInteractionBillboard.BUTTONS
local v = {}
local isFocused = false
local chatInputBarConfiguration = TextChatService:WaitForChild("ChatInputBarConfiguration")

local function onShown(instance)
	if not instance:HasTag("PlayerPrompt") then
		return
	end

	local parent = instance.Parent

	if not parent or parent == localPlayer.Character then
		return
	end

	local instance2 = import.make(playerInteractionBillboard.PlayerInteractionBillboard, {
		Character = parent,
		Adornee = parent
	})
	import.mount(instance2, playerGui)
	local connections = {}

	for _, v3 in ipairs(BUTTONS) do
		if not v3.Key then
			continue
		end

		local v4 = Enum.KeyCode[v3.Key]

		if not v4 then
			continue
		end

		local v5 = v4
		local v6 = v3
		connections[#connections + 1] = UserInputService.InputBegan:Connect(function(input, gameProcessed)
			if isFocused or input.KeyCode ~= v5 then
				return
			end

			v6.Callback(parent)
		end)
	end

	v[instance] = {
		instance = instance2,
		connections = connections
	}
end

local function onHidden(instance)
	if not instance:HasTag("PlayerPrompt") then
		return
	end

	local v2 = v[instance]

	if not v2 then
		return
	end

	for _, connection in ipairs(v2.connections) do
		connection:Disconnect()
	end

	v2.instance:Destroy()
	v[instance] = nil
end

return {
	Priority = 1,
	Run = function()
		ProximityPromptService.PromptShown:Connect(onShown)
		ProximityPromptService.PromptHidden:Connect(onHidden)
		chatInputBarConfiguration:GetPropertyChangedSignal("IsFocused"):Connect(function()
			isFocused = chatInputBarConfiguration.IsFocused
		end)
	end
}