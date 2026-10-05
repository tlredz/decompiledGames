local React = require(game.ReplicatedStorage.Packages.React)
return React.createContext({
	Description = nil,
	SetDescription = function(_: string?, _: number?, _: string?)
		print("Warning: No TemporaryDescription Context Provider found!")
	end
})