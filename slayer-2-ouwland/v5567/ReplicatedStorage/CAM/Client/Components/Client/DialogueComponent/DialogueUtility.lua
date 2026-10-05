local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DialogueUtility = {}
local Dialogue = require(ReplicatedStorage.CAM.Client.Modules.GamePlay.Dialogue)
local typeof2 = typeof

function DialogueUtility.ExtractValue(callback, p)
	if callback == nil then
		return
	end

	local storage = Dialogue.Storage

	if Dialogue.Functions[callback] then
		return DialogueUtility.ExtractValue(Dialogue.Functions[callback](p, storage))
	end

	if typeof2(callback) == "function" then
		return DialogueUtility.ExtractValue(callback(p, storage))
	end

	if Dialogue.Diagloues[callback] == nil then
	end

	return callback
end

function DialogueUtility.BeforeRun(p, p2)
	if type(p) == "table" then
		if p.Function == nil then
			return nil
		end

		local value = DialogueUtility.ExtractValue(p.Function, p2)

		if value == nil then
			return nil
		end

		if p.Results ~= nil and p.Results[value] ~= nil then
			value = DialogueUtility.ExtractValue(p.Results[value], value)
		end

		if value ~= nil then
			return value ~= "Close" and value ~= false and value
		end

		return nil
	else
		local value = DialogueUtility.ExtractValue(p, p2)

		if value == nil then
			return nil
		end

		if value == "Close" or value == false then
			return false
		end

		if Dialogue.Diagloues[value] == nil then
			return nil
		end

		return value
	end
end

function DialogueUtility.Close()
	Dialogue.CurrentDialogue.Current = nil
	Dialogue.CurrentDialogue.Cancel:Fire()
end

function DialogueUtility.Do(p, p2)
	if p == nil then
		return
	end

	if Dialogue.Functions[p] then
		Dialogue.Functions[p](p2, Dialogue.Storage)
		return true
	end

	if not Dialogue.Diagloues[p] then
		return nil
	end

	Dialogue.AttemptDialogue:Fire(p)
	return true
end

function DialogueUtility.DoAll(p, p2, flag: boolean?)
	if p == nil then
		return
	end

	local value = DialogueUtility.ExtractValue(p, p2)

	if DialogueUtility.Do(value, p2) then
		return true
	end

	if value ~= nil and value ~= "" and value ~= false then
		warn((`[Dialogue] answer value "{tostring(value)}" (from "{tostring(p)}") is neither a Function nor a dialogue node, closing`))
	end

	if not flag then
		DialogueUtility.Close()
	end

	return nil
end

return DialogueUtility