local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
return function(cmdr)
	local util = cmdr.Util
	local Window = require(script:WaitForChild("Window"))
	Window.Cmdr = cmdr
	local AutoComplete = require(script:WaitForChild("AutoComplete"))
	local autoComplete = AutoComplete(cmdr)
	Window.AutoComplete = autoComplete

	function Window.ProcessEntry(p)
		local trimString = util.TrimString(p)

		if #trimString == 0 then
			return
		end

		Window:AddLine(Window:GetLabel() .. " " .. trimString, Color3.fromRGB(255, 223, 93))
		Window:AddLine(cmdr.Dispatcher:EvaluateAndRun(trimString, localPlayer, {
			IsHuman = true
		}))
	end

	function Window.OnTextChanged(value)
		local evaluate = cmdr.Dispatcher:Evaluate(value, localPlayer, true)
		local splitString = util.SplitString(value)
		local v2 = table.remove(splitString, 1)
		local v3

		if evaluate then
			splitString = util.MashExcessArguments(splitString, #evaluate.Object.Args)

			if #splitString == #evaluate.Object.Args then
				v3 = true
			else
				v3 = false
			end
		else
			v3 = false
		end

		local v4 = v2 and #splitString > 0

		if value:sub(#value, #value):match("%s") and not v3 then
			splitString[#splitString + 1] = ""
			v4 = true
		end

		if evaluate and v4 then
			local v5, v6 = evaluate:Validate()
			Window:SetIsValidInput(v5, ("Validation errors: %s"):format(v6 or ""))
			local v7 = {}
			local argument = evaluate:GetArgument(#splitString)

			if argument then
				local textSegmentInProgress = argument.TextSegmentInProgress
				local isPartial = false

				if argument.RawSegmentsAreAutocomplete then
					for i, rawSegment in ipairs(argument.RawSegments) do
						v7[i] = { rawSegment, rawSegment }
					end
				else
					local autocomplete, v8 = argument:GetAutocomplete()
					isPartial = (v8 or {}).IsPartial or false

					for k, v9 in pairs(autocomplete) do
						v7[k] = { textSegmentInProgress, v9 }
					end
				end

				local v8

				if #textSegmentInProgress > 0 then
					v8, v6 = argument:Validate()
				else
					v8 = true
				end

				if not v3 and v8 then
					Window:HideInvalidState()
				end

				return autoComplete:Show(v7, {
					at = v3 and #value - #textSegmentInProgress + (value:sub(#value, #value):match("%s") and -1 or 0),
					prefix = #argument.RawSegments ~= 1 and "" or argument.Prefix or "",
					isLast = #evaluate.Arguments == #evaluate.ArgumentDefinitions and #textSegmentInProgress > 0,
					numArgs = #splitString,
					command = evaluate,
					arg = argument,
					name = argument.Name .. (argument.Required and "" or "?"),
					type = argument.Type.DisplayName,
					description = v8 == false and v6 or argument.Object.Description,
					invalid = not v8,
					isPartial = isPartial
				})
			end
		elseif v2 and #splitString == 0 then
			Window:SetIsValidInput(true)
			local command = cmdr.Registry:GetCommand(v2)
			local v5 = nil

			if command then
				v5 = {
					command.Name,
					command.Name,
					options = {
						name = command.Name,
						description = command.Description
					}
				}
				local v6 = command.Args and command.Args[1]

				if type(v6) == "function" then
					v6 = v6(evaluate)
				end

				if v6 and not v6.Optional and v6.Default == nil then
					Window:SetIsValidInput(false, "This command has required arguments.")
					Window:HideInvalidState()
				end
			else
				Window:SetIsValidInput(
					false,
					("%q is not a valid command name. Use the help command to see all available commands."):format(v2)
				)
			end

			local v6 = { v5 }

			for _, v7 in pairs(cmdr.Registry:GetCommandNames()) do
				if not (v2:lower() == v7:lower():sub(1, #v2) and (v5 == nil or v5[1] ~= v2)) then
					continue
				end

				local command2 = cmdr.Registry:GetCommand(v7)
				v6[#v6 + 1] = {
					v2,
					v7,
					options = {
						name = command2.Name,
						description = command2.Description
					}
				}
			end

			return autoComplete:Show(v6)
		end

		Window:SetIsValidInput(false, "Use the help command to see all available commands.")
		autoComplete:Hide()
	end

	Window:UpdateLabel()
	Window:UpdateWindowHeight()
	return {
		Window = Window,
		AutoComplete = autoComplete
	}
end