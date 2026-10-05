local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local v = require3(ReplicatedStorage2.Packages.Trove)
require3(script.Types)
local v2 = {}
local localPlayer = Players.LocalPlayer
local prompts = localPlayer.PlayerGui.Prompts
local adminPanel = localPlayer.PlayerGui.AdminPanel
local PromptController = {}

function PromptController.Init(_)
	for _, child in script.Prompts:GetChildren() do
		local child2 = ReplicatedStorage2.Assets.UI.Prompt:FindFirstChild(child.Name)

		if child2 then
			local v4 = child2
			local v5 = require3(child)

			v2[child.Name] = function(...)
				local v6 = v.new()
				local clone = v6:Clone(v4)

				if pcall(v5, clone, v6, ...) then
					return clone, v6
				end

				v6:Destroy()
				return nil
			end
		else
			warn((`Prompt UI for PromptType "{child.Name}" not found!`))
		end
	end
end

function PromptController.Start(_)
	local displayOrder = prompts.DisplayOrder
	adminPanel:GetPropertyChangedSignal("Enabled"):Connect(function()
		local v3 = prompts
		local displayOrder2

		if adminPanel.Enabled then
			displayOrder2 = adminPanel.DisplayOrder + 1
		else
			displayOrder2 = displayOrder
		end

		v3.DisplayOrder = displayOrder2
	end)
end

function PromptController.CreatePrompt(p, p2, callback)
	if p._currentConfirmationPrompt then
		if callback then
			task.spawn(callback, false, "Another prompt is being shown currently...")
		end
	else
		local v3 = v2[p2.PromptType]

		if v3 then
			local flag = false
			local v4 = nil

			local function response(...)
				if flag then
					return
				end

				flag = true

				if callback then
					task.spawn(callback, ...)
				end

				if p._currentConfirmationPrompt then
					p._currentConfirmationPrompt:Destroy()
					p._currentConfirmationPrompt = nil
				end

				prompts.Enabled = false

				if v4 then
					v4:Destroy()
					v4 = nil
				end
			end

			local v5, currentConfirmationPrompt, v7 = xpcall(v3, function(p3)
				return debug.traceback(p3, 3)
			end, p2, response)

			if v5 then
				v4 = v7
			else
				v4 = nil
			end

			if v5 and currentConfirmationPrompt then
				p._currentConfirmationPrompt = currentConfirmationPrompt
				currentConfirmationPrompt.Visible = true
				currentConfirmationPrompt.Parent = prompts
				prompts.Enabled = true
			else
				response(false, "Failed to create prompt UI")

				if type(currentConfirmationPrompt) == "string" then
					warn((`Failed to create prompt UI for "{p2.PromptType}", stacktrace:\n{currentConfirmationPrompt}`))
				end
			end
		else
			if callback then
				task.spawn(callback, false, "Failed to create prompt")
			end

			warn((`PromptType "{p2.PromptType}" doesn't exists, stacktrace:\n{debug.traceback()}`))
		end
	end
end

return PromptController