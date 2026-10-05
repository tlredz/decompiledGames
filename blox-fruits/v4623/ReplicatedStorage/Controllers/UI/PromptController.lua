local PromptController = {}
local GuiService = game:GetService("GuiService")
require(game.ReplicatedStorage.Modules.Util.Trove)
require(game.ReplicatedStorage.Modules.Util.Signal)
local v = nil
local v2 = nil
local count = 0

function PromptController.OnStart(_)
	GuiService.MenuOpened:Connect(function()
		PromptController:DestroyPrompt()
	end)
end

function PromptController:DestroyPrompt(p: string?)
	if v2 and (not p or v2._uid == p) then
		v2:Destroy()
	end
end

function PromptController.new(p: string?)
	v = v or game.Players.LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("Prompt")
	count += 1
	PromptController:DestroyPrompt()
	local PromptComponent = require(game.ReplicatedStorage.Modules.Create.PromptComponent)
	local promptComponent = PromptComponent(v)
	promptComponent._uid = p or count
	v2 = promptComponent
	promptComponent:OnDestroy(function()
		v2 = nil
	end)
	return promptComponent
end

return PromptController