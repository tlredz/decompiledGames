local DialogueController = require(game.ReplicatedStorage:WaitForChild("DialogueController"))
local Component = require(game.ReplicatedStorage.Modules.Component)
require(game.ReplicatedStorage.Modules.Data.EasterEggs)
local v = Component.new({
	Tag = "ThirstyEggTool",
	Extensions = { require(game.ReplicatedStorage.Modules.Extensions.OnlyLocalPlayer) },
	Ancestors = { workspace }
})

function v.Start(p)
	local instance = p.Instance
	local text = instance:GetAttribute("Text")

	if text == nil then
		local name = instance.Name

		if name == "Thirsty Egg" then
			local v2 = {
				"Not all purposes are fulfilled on solid ground.",
				"Its story feels unfinished—like it's waiting to be submerged in something greater.",
				"It might reveal its true function under the right conditions.",
				"It feels strangely incomplete… as if it belongs somewhere deeper."
			}
			text = { v2[math.random(#v2)] }
		elseif name == "Molten Egg" then
			local v2 = {
				"It may only reveal its true nature under extreme conditions.",
				"It seems like ordinary environments aren't enough to affect it.",
				"Some things must be broken down before they can become whole.",
				"Perhaps it requires a force strong enough to change it completely."
			}
			text = { v2[math.random(#v2)] }
		elseif name == "Mended Egg" then
			local v2 = {
				"You get the sense this was never meant to stand alone.",
				"It looks like it was once joined with something else.",
				"Some creations are destined to be reunited.",
				"You wonder what would happen if it were combined with something similar."
			}
			text = { v2[math.random(#v2)] }
		elseif name == "Falling Sky Egg" then
			local v2 = {
				"It looks like it has some kind of barrier surrounding it.",
				"It doesn't seem like the barrier can be destroyed by conventional means.",
				"Breaking the barrier may require an alternative approach."
			}

			text = function()
				return { v2[math.random(1, #v2)] }
			end
		end
	else
		text = { text }
	end

	instance.Activated:Connect(function()
		if DialogueController.Active then
			return
		end

		local remoteEvent = instance:FindFirstChildOfClass("RemoteEvent")
		local option = remoteEvent and {
			Label = "Drop",
			JumpTo = function()
				remoteEvent:FireServer()
			end
		} or nil
		DialogueController.start({
			Title = "Egg",
			Get = function(_)
				return {
					Text = type(text) == "function" and text() or text or { "An egg...what am I supposed to do with this?" },
					Option1 = option
				}
			end
		})
	end)
end

return v