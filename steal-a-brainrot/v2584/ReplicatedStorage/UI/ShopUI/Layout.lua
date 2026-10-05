local v = {
	Resolve = function(child, items)
		for _, childName in items do
			if not child then
				return nil
			end

			child = child:FindFirstChild(childName)
		end

		return child
	end
}

function v.Expect(instance, list)
	local resolved = v.Resolve(instance, list)

	if not resolved then
		error(`ShopUI.Layout: {instance:GetFullName()} has no {table.concat(list, ".")}`, 2)
	end

	return resolved
end

v.Legacy = {
	GuiName = "Shop",
	Root = { "Shop" },
	List = { "Shop", "Content", "List" },
	Close = { "Shop", "Header", "Close" },
	HeaderTitle = {
		"Shop",
		"Header",
		"Txts",
		"Txt1"
	},
	Tabs = {
		Money = { "Money" },
		Gear = { "Gear" },
		Gamepass = { "Gamepass" }
	},
	Sections = {
		ServerLuck = {
			Frame = { "ServerLuck" },
			Title = { "ServerLuckTitle" }
		},
		LuckyBlocks = {
			Frame = { "LuckyBlocksList" },
			Title = { "LuckyBlocks" }
		},
		Items = {
			Frame = { "ItemsList" },
			Title = { "Gear" }
		},
		Gamepasses = {
			Frame = { "GamepassList" },
			Title = { "Gamepass" }
		},
		StarterPack = {
			Frame = { "StarterPack" },
			Title = { "Title" }
		},
		Money = {
			Frame = { "MoneyList" },
			Title = { "Money" }
		},
		Codes = {
			Frame = { "Codes" },
			Title = { "Redeem" }
		}
	},
	LuckyBlocks = {
		List = {
			"Shop",
			"Content",
			"List",
			"LuckyBlocksList"
		},
		Title = {
			"Shop",
			"Content",
			"List",
			"LuckyBlocks"
		}
	},
	ServerLuck = {
		"Shop",
		"Content",
		"List",
		"ServerLuck",
		"Frame"
	},
	CodesTextBox = {
		"Shop",
		"Content",
		"List",
		"Codes",
		"CodeRedeem",
		"TextBox"
	},
	GiftPlayerSelect = { "Shop", "GiftPlayerSelect" },
	Promos = true,
	Merch = {
		"Shop",
		"Content",
		"List",
		"Plush"
	}
}
v.New = {
	GuiName = "NewShop",
	Root = { "Main" },
	List = { "Main", "List" },
	Close = { "Main", "Header", "Close" },
	HeaderTitle = {
		"Main",
		"Header",
		"Txts",
		"Txt1"
	},
	Tabs = {
		Money = { "MoneyList" },
		Gear = { "ItemsList" },
		Gamepass = { "GamepassList" }
	},
	Sections = {
		ServerLuck = {
			Frame = { "ServerLuck" }
		},
		LuckyBlocks = {
			Frame = { "LuckyBlocksList" }
		},
		Items = {
			Frame = { "ItemsList" }
		},
		Gamepasses = {
			Frame = { "GamepassList" }
		},
		StarterPack = {
			Frame = { "StarterPack" }
		},
		Money = {
			Frame = { "MoneyList" }
		},
		Codes = {
			Frame = { "Codes" }
		}
	},
	LuckyBlocks = {
		List = {
			"Main",
			"List",
			"LuckyBlocksList",
			"LuckyBlocksList",
			"List"
		},
		Title = {
			"Main",
			"List",
			"LuckyBlocksList",
			"LuckyBlocksList",
			"Title"
		}
	},
	ServerLuck = {
		"Main",
		"List",
		"ServerLuck",
		"Main"
	},
	CodesTextBox = {
		"Main",
		"List",
		"Codes",
		"Main",
		"CodeRedeem",
		"TextBox"
	},
	GiftPlayerSelect = { "Main", "GiftPlayerSelect" },
	Promos = false,
	Merch = nil
}
return table.freeze(v)