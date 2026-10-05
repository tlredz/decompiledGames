local Players = game:GetService("Players")
local Dialogue = require(script.Parent.Dialogue)
local Legacy = {
	is = function(p)
		return typeof(p) == "table" and typeof(p.Get) == "function" and getmetatable(p) ~= Dialogue
	end
}

local function isDialogueEntity(p)
	return typeof(p) == "table" and getmetatable(p) == Dialogue
end

function Legacy.buildPage(object, p)
	local v

	if typeof(p) == "table" then
		v = getmetatable(p) == Dialogue
	else
		v = false
	end

	if v then
		object:dialogueRedirect(p)
	elseif typeof(p) == "table" and p.Text then
		if p.FloatingHead then
			object:setHead(p.FloatingHead)
		end

		for _, v2 in ipairs(p.Text) do
			if typeof(v2) == "function" then
				v2 = v2()
			end

			object:addText(v2)
		end

		local v2 = {}

		for k in p do
			if typeof(k) ~= "string" then
				continue
			end

			local match = k:match("^Option(%d+)$")

			if match then
				table.insert(v2, {
					index = tonumber(match),
					key = k
				})
			end
		end

		table.sort(v2, function(a, b)
			return a.index < b.index
		end)

		for _, v3 in v2 do
			local v5 = p[v3.key]
			object:addOption(function(object2)
				object2:setText(v5.Label or "?")
				local type = v5.Type or v5.Label == "Purchase" and "Purchase" or nil

				if type then
					object2:setType(type)
				end

				if v5.Locked then
					object2:setLocked(true)
				end

				if typeof(v5.JumpTo) == "function" then
					object2._jump = {
						kind = "dynamic",
						resolve = function(p2)
							local jumpTo = v5.JumpTo(p)
							local v6

							if typeof(jumpTo) == "table" then
								v6 = getmetatable(jumpTo) == Dialogue
							else
								v6 = false
							end

							if v6 then
								return jumpTo:_openTop(p2)
							end

							return object2._dialogue:_openInline(function(p3)
								Legacy.buildPage(p3, jumpTo)
							end, p2)
						end
					}
				elseif v5.Text then
					object2:jumpToPage(function(p2)
						Legacy.buildPage(p2, v5)
					end)
				end
			end)
		end

		if p.CancelText then
			object:setCancelText(p.CancelText)
		end

		if p.NoCancelButton then
			object:noCancel()
		end

		if p.ForceCancelButton then
			object:forceCancel()
		end

		if p.RandomizeCancelSwap then
			object:randomizeCancelSwap()
		end

		if typeof(p.CancelOverride) == "function" then
			object:onCancel(function(object2)
				object2:jumpToPage(function(p2)
					Legacy.buildPage(p2, p.CancelOverride())
				end)
			end)
		end

		if typeof(p.Function) == "function" then
			if #v2 > 0 or p.ForceCancelButton then
				p.Function(Players.LocalPlayer)
			else
				object:onFinished(function()
					p.Function(Players.LocalPlayer)
				end)
			end
		end
	else
		if p then
			warn("[DIALOGUE]", "bad legacy page", p)
		end

		object:close()
	end
end

function Legacy.convert(object)
	local v = Dialogue.new()
	v:setTitle(object.Title or "")
	v:addPage(function(p)
		Legacy.buildPage(p, object:Get())
	end)
	return v:build()
end

return Legacy