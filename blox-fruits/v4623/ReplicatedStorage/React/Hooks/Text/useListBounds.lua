local TextService = game:GetService("TextService")
local React = require(game.ReplicatedStorage.Packages.React)
local Future = require(game.ReplicatedStorage.Packages.Future)
local Option = require(game.ReplicatedStorage.Packages.Option)
local HashMap = require(game.ReplicatedStorage.Packages.HashMap)
require(game.ReplicatedStorage.Packages.Vec)
return function(list, size: number, font, value: number?)
	local state, setState = React.useState((Option.none()))
	React.useEffect(function()
		local flag = false
		local getTextBoundsParams = Instance.new("GetTextBoundsParams")
		getTextBoundsParams.Font = font
		getTextBoundsParams.Size = size
		getTextBoundsParams.Width = value or 1e999
		local v = Future.from(function()
			local textBoundsAsyncs = {}

			for _, text in ipairs(list) do
				getTextBoundsParams.Text = text
				textBoundsAsyncs[text] = TextService:GetTextBoundsAsync(getTextBoundsParams)
			end

			return HashMap.from(textBoundsAsyncs)
		end)
		task.spawn(function()
			v:awaitResult():inspect(function(p)
				if flag then
					return
				end

				setState(Option.some(p))
			end)
		end)
		return function()
			flag = true
			getTextBoundsParams:Destroy()
			v:cancel()
		end
	end, {
		list,
		size,
		value,
		font
	})
	return Option.map(state, function(object)
		return object:drain()
	end):asNullable()
end