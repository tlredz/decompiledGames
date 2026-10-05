return table.freeze({
	{
		Id = "myServer",
		Title = "My server",
		Category = "Servers",
		Description = "Start your own recording server, then invite who you want.",
		Owner = true,
		Fields = {}
	},
	{
		Id = "joinps",
		Title = "Join server",
		Category = "Servers",
		Description = "Step into your next recording session.",
		Admin = true,
		Guest = true,
		Fields = { "server" }
	},
	{
		Id = "listps",
		Title = "Server directory",
		Category = "Servers",
		Description = "View creator servers and manage their guest lists.",
		Admin = true,
		Fields = {}
	},
	{
		Id = "sendps",
		Title = "Send player",
		Category = "Servers",
		Description = "Send a player in this session to an approved creator server.",
		Admin = true,
		Fields = { "target", "server" }
	},
	{
		Id = "manageWhitelist",
		Title = "Manage whitelist",
		Category = "Servers",
		Description = "Preview and add guests by username or user ID, including offline accounts.",
		Admin = true,
		Fields = { "server" }
	},
	{
		Id = "freecam",
		Title = "Free camera",
		Category = "Camera",
		Description = "Find the perfect angle with a freely moving camera.",
		Toggle = true,
		Fields = {}
	},
	{
		Id = "hideUI",
		Title = "Hide game UI",
		Category = "Camera",
		Description = "Keep the action in focus. This panel stays accessible.",
		Toggle = true,
		Fields = {}
	},
	{
		Id = "hideNameplates",
		Title = "Hide nameplates",
		Category = "Camera",
		Description = "A cleaner shot without player labels.",
		Toggle = true,
		Fields = {}
	},
	{
		Id = "setSpeed",
		Title = "Movement speed",
		Category = "Character",
		Description = "Set your movement speed for the scene.",
		Fields = { "speed" },
		Reset = true
	},
	{
		Id = "tpZone",
		Title = "Go to zone",
		Category = "Character",
		Description = "Jump straight to the next location.",
		Fields = { "zone" }
	},
	{
		Id = "invincible",
		Title = "Invincibility",
		Category = "Character",
		Description = "Stay protected from guards and player attacks.",
		Toggle = true,
		Fields = {}
	},
	{
		Id = "morphGuard",
		Title = "Guard disguise",
		Category = "Character",
		Description = "Wear a guard's appearance for your scene.",
		Toggle = true,
		Fields = { "guard" }
	},
	{
		Id = "disguisePlayer",
		Title = "Player disguise",
		Category = "Character",
		Description = "Look like another player by username or user ID.",
		Toggle = true,
		Fields = {}
	},
	{
		Id = "spawnEgg",
		Title = "Spawn an egg",
		Category = "Collection",
		Description = "Place an egg in this server for everyone to see and collect.",
		Fields = { "asset", "zone", "size" }
	},
	{
		Id = "giveEgg",
		Title = "Give egg",
		Category = "Collection",
		Description = "Grant eggs. They last for this session only and never save.",
		Fields = { "asset", "amount", "size" }
	},
	{
		Id = "skipEggTimer",
		Title = "Skip egg timer",
		Category = "Collection",
		Description = "Choose one placed egg and make it ready to hatch.",
		Fields = { "egg" }
	},
	{
		Id = "giveAnimal",
		Title = "Give animal",
		Category = "Collection",
		Description = "Grant animals. They last for this session only and never save.",
		Fields = { "asset", "amount", "size" }
	},
	{
		Id = "giveShards",
		Title = "Give event items",
		Category = "Collection",
		Description = "Grant an event's currency or its mutation consumable. It lasts for this session only and never saves.",
		Fields = { "currency", "amount" }
	},
	{
		Id = "spawnMutatedPet",
		Title = "Spawn mutated pet",
		Category = "Mutations",
		Description = "Grant a pet that already has a mutation. It lasts for this session only and never saves.",
		Fields = {
			"asset",
			"mutation",
			"amount",
			"size"
		}
	},
	{
		Id = "setPetMutation",
		Title = "Mutate a pen pet",
		Category = "Mutations",
		Description = "Change the mutation on a pet in your pen. The change lasts for this session only and never saves.",
		Fields = { "pet", "mutation" }
	},
	{
		Id = "pauseGuard",
		Title = "Pause pursuit",
		Category = "Scene",
		Description = "Stop guards in a selected zone from chasing you.",
		Toggle = true,
		Fields = { "zoneOrAll" }
	},
	{
		Id = "troll",
		Title = "Stage a prank",
		Category = "Scene",
		Description = "Fling, slip, or drop a carried egg in a creator server.",
		Fields = { "target", "prank" }
	},
	{
		Id = "invitePlayers",
		Title = "Invite players",
		Category = "Servers",
		Description = "Invite a player from another server, or send a Roblox invitation.",
		Admin = true,
		Fields = { "server" }
	},
	{
		Id = "followPlayer",
		Title = "Follow player",
		Category = "Manage",
		Description = "Find a player by username or user ID and join their server.",
		Admin = true,
		Fields = {}
	},
	{
		Id = "openps",
		Title = "Open creator server",
		Category = "Manage",
		Description = "Open or reopen a creator’s personal recording server.",
		Admin = true,
		Fields = { "server" }
	},
	{
		Id = "closeps",
		Title = "Close creator server",
		Category = "Manage",
		Description = "Notify guests and return them to a public server.",
		Admin = true,
		Fields = { "server" },
		Confirm = true
	}
})