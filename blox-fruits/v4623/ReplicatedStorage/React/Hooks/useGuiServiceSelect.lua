local GuiService = game:GetService("GuiService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local React = require(game.ReplicatedStorage.Packages.React)
require(game.ReplicatedStorage.React.RobloxTypes)
local useFirstTagged = require(game.ReplicatedStorage.React.Hooks.Instance.useFirstTagged)
local useLastInput = require(game.ReplicatedStorage.React.Hooks.useLastInput)
local useOnScreenEffect = require(game.ReplicatedStorage.React.Hooks.useOnScreenEffect)
local playerGui

if RunService:IsRunning() then
	playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
else
	playerGui = game:GetService("CoreGui")
end

return function(p: string?, p2)
	local guiObject = useFirstTagged(p)
	local v = useLastInput()
	local useState = React.useState
	local v2

	if guiObject then
		v2 = guiObject:IsDescendantOf(playerGui)
	else
		v2 = false
	end

	local state, setState = useState(v2)
	useOnScreenEffect(function()
		if not guiObject then
			setState(false)
			return function() end
		end

		local ancestryChangedConnection = guiObject.AncestryChanged:Connect(function(_)
			if state ~= guiObject:IsDescendantOf(playerGui) then
				setState(guiObject:IsDescendantOf(playerGui))
			end
		end)

		if state ~= guiObject:IsDescendantOf(playerGui) then
			setState(guiObject:IsDescendantOf(playerGui))
		end

		return function()
			ancestryChangedConnection:Disconnect()
		end
	end, { guiObject, state })
	useOnScreenEffect(function()
		if p2 == nil or p2 == false then
			if guiObject and GuiService.SelectedObject == guiObject then
				GuiService.SelectedObject = nil
			end

			return function() end
		else
			if v ~= "Gamepad" then
				return function() end
			end

			local function updateSelection()
				if not RunService:IsRunning() then
					return
				end

				if guiObject == nil or not guiObject:IsA("GuiObject") then
					if p2 ~= nil then
						GuiService.SelectedObject = nil
					end
				elseif (guiObject:IsDescendantOf(playerGui) or state) and (not GuiService.SelectedObject or GuiService.SelectedObject ~= guiObject and not guiObject:IsAncestorOf(GuiService.SelectedObject)) then
					local trySelect

					trySelect = function(guiObject2)
						if not guiObject2:IsDescendantOf(playerGui) then
							return false
						end

						if guiObject2.Selectable then
							pcall(function()
								GuiService.SelectedObject = guiObject2
							end)
							return true
						end

						for _, guiObject3 in ipairs(guiObject2:GetChildren()) do
							if not (guiObject3:IsA("GuiObject") and guiObject3.Selectable and guiObject3:IsDescendantOf(playerGui)) then
								continue
							end

							local selectedObject = guiObject3
							pcall(function()
								GuiService.SelectedObject = selectedObject
							end)
							return true
						end

						for _, guiObject3 in ipairs(guiObject2:GetChildren()) do
							if guiObject3:IsA("GuiObject") and trySelect(guiObject3) then
								return true
							end
						end

						return false
					end

					if not trySelect(guiObject) and guiObject:IsDescendantOf(playerGui) then
						pcall(function()
							GuiService.SelectedObject = guiObject
						end)
					end
				end
			end

			local selectedObjectChangedConnection = GuiService:GetPropertyChangedSignal("SelectedObject"):Connect(updateSelection)
			updateSelection()
			return function()
				selectedObjectChangedConnection:Disconnect()
			end
		end
	end, { guiObject, p2, v })
	return function(p3)
		p3[React.Tag] = p
		return p3
	end
end