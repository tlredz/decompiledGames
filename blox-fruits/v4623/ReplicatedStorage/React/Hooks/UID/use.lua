local HttpService = game:GetService("HttpService")
local React = require(game.ReplicatedStorage.Packages.React)
return function(p: string?)
	local ref = React.useRef(HttpService:GenerateGUID(false))

	if p then
		return (`{p}{ref.current}`)
	end

	return ref.current
end