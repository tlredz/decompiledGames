local TextService = game:GetService("TextService")
local React = require(game.ReplicatedStorage.Packages.React)
local Future = require(game.ReplicatedStorage.Packages.Future)
local Option = require(game.ReplicatedStorage.Packages.Option)
return function(text: string, size: number, font, value: number?)
	local state, setState = React.useState((Option.none()))
	React.useEffect(function()
		local flag = false
		local getTextBoundsParams = Instance.new("GetTextBoundsParams")
		getTextBoundsParams.Text = text
		getTextBoundsParams.Font = font
		getTextBoundsParams.Size = size
		getTextBoundsParams.Sandboxed = true
		getTextBoundsParams.Width = value or 1e999
		local v = Future.from(function()
			return TextService:GetTextBoundsAsync(getTextBoundsParams)
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
		text,
		size,
		value,
		font
	})
	return state:asNullable()
end