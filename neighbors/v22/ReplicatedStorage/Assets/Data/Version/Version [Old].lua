local function isPunctionation(value: string)
	return value:match("%p") and true or false
end

local function Item(value: string, value2: string)
	local v = value2:sub(#value2)

	if not value:sub(#value):match("%p") then
		value ..= ":"
	end

	if not v:match("%p") then
		value2 ..= "."
	end

	return (`<font size="12"><b>{value}</b> {value2}</font>`)
end

local VersionOld = {}
local v = {
	Title = "Neighbors VC 🔊",
	Version = 9.1,
	Patch = 0,
	Date = os.time({
		month = 3,
		day = 2,
		year = 2026
	}),
	Content = 0
}
local v5 = "Ramadan Bundle"
local v6 = "The Ramadan bundle is now available for purchase!!"
local v7 = v6:sub(#v6)

if not v5:sub(#v5):match("%p") then
	v5 ..= ":"
end

if not v7:match("%p") then
	v6 ..= "."
end

local formatted = `<font size="12"><b>{v5}</b> {v6}</font>`
local v8 = "Ramadan Banner"
local v9 = "The Ramadan banner is now available to Spin!!"
local v10 = v9:sub(#v9)

if not v8:sub(#v8):match("%p") then
	v8 ..= ":"
end

if not v10:match("%p") then
	v9 ..= "."
end

v.Content = {
	"Patch",
	{ formatted, `<font size="12"><b>{v8}</b> {v9}</font>`, "Bug Fixes." }
}
local v11 = {
	Title = "Neighbors VC 🔊",
	Version = 9,
	Patch = 0,
	Date = os.time({
		month = 2,
		day = 23,
		year = 2026
	}),
	Content = 0
}
local v15 = "Better server filter!"
local v16 = "You can now filter for nationalities & player tags to find people with similar interests!"
local v17 = v16:sub(#v16)

if not v15:sub(#v15):match("%p") then
	v15 ..= ":"
end

if not v17:match("%p") then
	v16 ..= "."
end

local formatted2 = `<font size="12"><b>{v15}</b> {v16}</font>`
local v18 = "Improved party search"
local v19 = "You can now search by country and tags within the player menu. The verified icon is now added back as well."
local v20 = v19:sub(#v19)

if not v18:sub(#v18):match("%p") then
	v18 ..= ":"
end

if not v20:match("%p") then
	v19 ..= "."
end

local formatted3 = `<font size="12"><b>{v18}</b> {v19}</font>`
local v21 = "Added new tags"
local v22 = "#boba, #valorant, #league, #fortnite, and more!"
local v23 = v22:sub(#v22)

if not v21:sub(#v21):match("%p") then
	v21 ..= ":"
end

if not v23:match("%p") then
	v22 ..= "."
end

v11.Content = {
	"Patch",
	{ formatted2, formatted3, (`<font size="12"><b>{v21}</b> {v22}</font>`) }
}
local v24 = {
	Title = "Valentines 💗",
	Version = 8.9,
	Patch = 0,
	Date = os.time({
		month = 2,
		day = 18,
		year = 2026
	}),
	Content = 0
}
local v28 = "Match Requests!"
local v29 = "You can now send invites to directly match with players! Check it out in the Party menu."
local v30 = v29:sub(#v29)

if not v28:sub(#v28):match("%p") then
	v28 ..= ":"
end

if not v30:match("%p") then
	v29 ..= "."
end

local formatted4 = `<font size="12"><b>{v28}</b> {v29}</font>`
local v31 = "Party UI Revamp"
local v32 = "The party UI now has a cleaner look!"
local v33 = v32:sub(#v32)

if not v31:sub(#v31):match("%p") then
	v31 ..= ":"
end

if not v33:match("%p") then
	v32 ..= "."
end

local formatted5 = `<font size="12"><b>{v31}</b> {v32}</font>`
local v34 = "Bigger servers"
local v35 = "The server size has been increased which should give you more potential people to talk to!"
local v36 = v35:sub(#v35)

if not v34:sub(#v34):match("%p") then
	v34 ..= ":"
end

if not v36:match("%p") then
	v35 ..= "."
end

local formatted6 = `<font size="12"><b>{v34}</b> {v35}</font>`
local v37 = "Weekly Banners w/ Credits"
local v38 = "You can now purchase weekly banners with credits!"
local v39 = v38:sub(#v38)

if not v37:sub(#v37):match("%p") then
	v37 ..= ":"
end

if not v39:match("%p") then
	v38 ..= "."
end

local formatted7 = `<font size="12"><b>{v37}</b> {v38}</font>`
local v40 = "Better Spin Animation"
local v41 = "The animation for case & banner spins has been overhauled to look a lot better."
local v42 = v41:sub(#v41)

if not v40:sub(#v40):match("%p") then
	v40 ..= ":"
end

if not v42:match("%p") then
	v41 ..= "."
end

local formatted8 = `<font size="12"><b>{v40}</b> {v41}</font>`
local v43 = "Profile Tags"
local v44 = "You can now add tags to your profile."
local v45 = v44:sub(#v44)

if not v43:sub(#v43):match("%p") then
	v43 ..= ":"
end

if not v45:match("%p") then
	v44 ..= "."
end

v24.Content = {
	"Patch 2/18/2026",
	{
		formatted4,
		formatted5,
		formatted6,
		formatted7,
		formatted8,
		`<font size="12"><b>{v43}</b> {v44}</font>`,
		"You can now find the Match History on the top right instead of settings.",
		"Added 5x & 10x option to title/skin spins"
	},
	"💕 HAPPY VALENTINES DAY! 💕",
	{
		"<font size=\"14\"><b>😈 Heart Snatcher:</b> Snatch your friends and get a taste of their heart!</font>",
		"<font size=\"14\"><b>💘 Cupid Bow:</b> Now completely reworked and is available for a <b>LIMITED</b> time only!</font>",
		"<font size=\"14\"><b>🧭 Cupid Merchant:</b> located in your backyard who shows you where all the valentines skins can be obtained!</font>",
		"<font size=\"14\"><b>💝 Valentine’s Bundle 3:</b> has arrived! New skins to help you celebrate in style!</font>",
		"<font size=\"14\"><b>🎁 Valentine’s Titles:</b> Fun pack to show off — Will you be a Heartbreaker..?</font>",
		"<font size=\"14\"><b>✨ Valentine’s Banner:</b> The valentines banner is now available for a <b>LIMITED</b> time only!</font>",
		"<font size=\"14\"><b>✨ Valentine’s Skins:</b> Many new valentines skins have been added to most cases!</font>",
		"<font size=\"14\"><b>😲 New Emotes:</b> Check out the newly added emotes: Bouquet of Flowers, Dap Up, Get Groovy, Heart You!</font>",
		"<font size=\"14\"><b>🃏 Full Counter Skins:</b> Full Counter tool has received new spinnable skins!</font>",
		"<font size=\"14\"><b>🏠 Amberwood House Skin:</b> Go grab the newly added house skin!</font>"
	},
	"Game Changes",
	{ "<font size=\"14\">Support for console has been implemented!</font>" }
}
local v46 = {
	Title = "Neighbors VC 🔊",
	Version = 8.7,
	Patch = 5,
	Date = os.time({
		month = 1,
		day = 4,
		year = 2026
	}),
	Content = {
		"Holiday Update is over!",
		{ "We hope you enjoyed our holiday update! We have lots of new & exciting content coming to you soon!" }
	}
}
local v47 = {
	Title = "🎇 NEW YEARS!",
	Version = 8.6,
	Patch = 5,
	Date = os.time({
		month = 12,
		day = 30,
		year = 2025
	}),
	Content = {
		"New Content",
		{
			"<font size=\"14\"><b>✨ LIMITED TIME BANNER</b>: The New Years banner is now available for a <b>LIMITED</b> time only, don't miss out!</font>",
			"<font size=\"14\"><b>🤵 LIMITED TIME VENUE</b>: A special venue will open in your backyard when New Year arrives. Be sure to check it out!</font>",
			"<font size=\"14\"><b>🎊 LIMITED TIME EVENT</b>: As the New Year approaches, the ball drop will begin in your backyard.</font>",
			"<font size=\"14\"><b>🎁 New Skins</b>: New Years themed skins have been added to the Jolly Shop in a new section.</font>"
		},
		"Game Changes",
		{ "<font size=\"14\">Krampus has been temporarily disabled for the New Years event.</font>" }
	}
}
local v48 = {
	Title = "🎄 CHRISTMAS!",
	Version = 8.5,
	Patch = 5,
	Date = os.time({
		month = 12,
		day = 8,
		year = 2025
	}),
	Content = {
		"New Content",
		{
			"<font size=\"14\"><b>😈 LIMITED TIME BANNER</b>: The Mean Green banner is currently available for only a <b>LIMITED</b> amount of time!</font>",
			"<font size=\"14\"><b>👿 Krampus Domain</b>: Fight the newly added Krampus boss in his Domain! The entrance appears every 30 minutes.</font>",
			"<font size=\"14\"><b>🎁 New Bundle</b>: The Christmas bundle has been brought to the robux shop!</font>",
			"<font size=\"14\"><b>🛒 New Shop</b>: The Jolly Shop is here! You can locate it through the Camper Van in the backyard.</font>",
			"<font size=\"14\"><b>🎅 Santa's back</b>: Santa and his reindeers now soar through the sky, delivering presents!</font>",
			"<font size=\"14\"><b>🗓️ Advent Calendar</b>: Earn many types of rewards by logging into the game daily!</font>",
			"<font size=\"14\"><b>🖼️ Decorations</b>: Many newly added decorations to the profile tab!</font>",
			"<font size=\"14\"><b>⛸️ Ice Skating</b>: Head to your personal ice rink in your front yard!</font>"
		},
		"Game Changes",
		{ "<font size=\"14\">Removed Krampus peeking through the window...</font>" }
	}
}
local v49 = {
	Title = "🍂 THANKSGIVING!",
	Version = 8.4,
	Patch = 0,
	Date = os.time({
		month = 11,
		day = 26,
		year = 2025
	}),
	Content = {
		"New Tools",
		{
			"<font size=\"14\"><b>🔊 Echo Fork</b>: Ever wanted to make everyone around you echo obnoxiously? Now you can!</font>",
			"<font size=\"14\"><b>🐔 Chicken Toy</b>: With this, you can wack anyone with a wacky chicken!</font>",
			"<font size=\"14\"><b>🐝 Bee Swarm</b>: Throw a hive at your friends and have bees swarming them!</font>"
		},
		"New Content",
		{
			"<font size=\"14\"><b>🍂 LIMITED TIME BANNER</b>: The Thanksgiving banner is currently available for only a <b>LIMITED</b> amount of time!</font>",
			"<font size=\"14\"><b>🚀 Buddy Jetpacks</b>: Newly added skins for the jetpack that allow you to soar through the sky with a buddy!</font>",
			"<font size=\"14\"><b>🍁 New Banner</b>: The Fall banner, has been brought to the weekly shop!</font>",
			"<font size=\"14\"><b>🔤 New Titles</b>: The Thanksgiving titles case has been brought back to the titles section in the shop!</font>"
		},
		"Bug Fixes",
		{ "<font size=\"14\">Plenty of bug fixes!</font>" }
	}
}
local v50 = {
	Title = "Neighbors VC 🔊",
	Version = 8.3,
	Patch = 0,
	Date = os.time({
		month = 11,
		day = 11,
		year = 2025
	}),
	Content = {
		"Halloween Update is over!",
		{ "We hope you enjoyed our Halloween Update! We have lots of new & exciting Content coming to you soon!" }
	}
}
local v51 = {
	Title = "🎃 Freight Season",
	Version = 8.2,
	Patch = 0,
	Date = os.time({
		month = 10,
		day = 25,
		year = 2025
	}),
	HeaderColor = Color3.fromRGB(255, 113, 66),
	Color = Color3.fromRGB(255, 113, 66),
	StarColor = Color3.fromRGB(255, 113, 66),
	Content = {
		"New Features",
		{
			"<font size=\"12\"><b>🎮 Custom Server Gamemodes:</b> A new selection of gamemodes in Custom Servers have been added under Server Options!</font>",
			"<font size=\"11\"><b>Single House:</b> One house, one queue, but.. an entire server put together.</font>",
			"<font size=\"11\"><b>Blitz:</b> Do you just want to say hi, then skip? Make a friend under a few minutes!</font>",
			"<font size=\"12\"><b>🌀 Regular Server Teleport (18+):</b> You can now teleport back into Regular Neighbors from 18+</font>",
			"<font size=\"12\"><b>✨ A variety of new profile banners and backgrounds are now available in the shop!</b></font>",
			"<font size=\"12\"><b>😎 Aura Farming emotes are now available!</b></font>",
			"<font size=\"12\"><b>🛠️ Admin Support in Custom Servers:</b> Custom Server owners can now assign moderators under Server Options.</font>",
			"<font size=\"12\"><b>🎵 Custom Menu Music:</b> Choose your own soundtrack in Custom Server Options.</font>",
			"<font size=\"12\"><b>🔕 Disable Tool Setting:</b> Customize your custom server further by disabling tools in your server.</font>"
		},
		"Additions",
		{ "<font size=\"12\"><b>🎧 Volume Slider:</b> Adjust player volume in their profile under the “...” section.</font>" },
		"Bug Fixes",
		{ "<font size=\"14\">Various bug fixes and stability improvements!</font>" }
	}
}
local v52 = {
	Title = "🎃 Halloween is here",
	Version = 8.1,
	Patch = 0,
	Date = os.time({
		month = 10,
		day = 3,
		year = 2025
	}),
	HeaderColor = Color3.fromRGB(255, 113, 66),
	Color = Color3.fromRGB(255, 113, 66),
	StarColor = Color3.fromRGB(255, 113, 66),
	Content = {
		"New Content",
		{
			"<font size=\"12\"><b>👻 Halloween Bundle:</b> Grab the Halloween Bundle while the season of Spooks lasts!</font>",
			"<font size=\"12\"><b>😱 Halloween Banner:</b> Hallowen-themed Tool skins to freshen your style this season!</font>"
		},
		"Halloween House Skin",
		{ "<font size=\"14\">Enjoy the spooky season with our new halloween themed house and garden!</font>" },
		"New Tools",
		{
			"<font size=\"14\"><b>Death Notebook</b>: Ever wanted to feel like an anime villain? Now you can!</font>",
			"<font size=\"14\"><b>Blackout</b>: With this, you can now scare the socks of anyone in the house... like a real ghost!</font>"
		},
		"Visual Improvements",
		{
			"<font size=\"14\">Scythe has received a visual overhaul!</font>",
			"<font size=\"14\">Pitchfork has received a visual overhaul!</font>",
			"<font size=\"14\">Jumpscare has received a visual overhaul!</font>"
		},
		"Bug Fixes",
		{
			"<font size=\"12\">We've acknowledged the piano sound issue and a fix is coming soon.</font>",
			"<font size=\"14\">Lots of bug fixes!</font>"
		}
	}
}
local v53 = {
	Version = 8,
	Patch = 0,
	Date = os.time({
		month = 9,
		day = 13,
		year = 2025
	}),
	Content = 0
}
local v57 = "New Minigame"
local v58 = "Memory tiles!"
local v59 = v58:sub(#v58)

if not v57:sub(#v57):match("%p") then
	v57 ..= ":"
end

if not v59:match("%p") then
	v58 ..= "."
end

local formatted9 = `<font size="12"><b>{v57}</b> {v58}</font>`
local v60 = "House Chores!"
local v61 = "Interactive Mop + Sponge -- You can find them in the closet!"
local v62 = v61:sub(#v61)

if not v60:sub(#v60):match("%p") then
	v60 ..= ":"
end

if not v62:match("%p") then
	v61 ..= "."
end

v53.Content = {
	"NEW CONTENT",
	{ formatted9, (`<font size="12"><b>{v60}</b> {v61}</font>`) },
	"ADDITIONS",
	{
		"Added a plus button on the side to make it easier to invite party members",
		"Added a mailbox which lets you see what the current house skin is."
	},
	"GAME CHANGES",
	{ "Improved weekly banner notification", "Undarkened items in the bundle preview." }
}
VersionOld[1], VersionOld[2], VersionOld[3], VersionOld[4], VersionOld[5], VersionOld[6], VersionOld[7], VersionOld[8], VersionOld[9], VersionOld[10], VersionOld[11], VersionOld[12], VersionOld[13], VersionOld[14], VersionOld[15], VersionOld[16] = v, v11, v24, v46, v47, v48, v49, v50, v51, v52, v53, {
	Title = "Back To School!",
	Version = 7.9,
	Patch = 0,
	Date = os.time({
		month = 8,
		day = 29,
		year = 2025
	}),
	HeaderColor = Color3.fromRGB(255, 205, 3),
	Color = Color3.fromRGB(250, 250, 250),
	StarColor = Color3.fromRGB(0, 136, 255),
	Content = {
		"NEW CONTENT",
		{
			"<font size=\"12\"><b>New Banners:</b> Upcoming... Toy Banner, Kitty Banner, Steampunk Banner, Back to School! One banner will be shown every week in the Weekly shop!</font>",
			"<font size=\"12\"><b>Random Backyard Variations:</b> Added four random background variations to the houses. </font>"
		},
		"ADDITIONS",
		{
			"<font size=\"12\"><b>Offline Gifting:</b> You can now send gifts to players even if your they aren’t online! </font>",
			"<font size=\"12\">Server owners now get a crown icon next to their name. </font>",
			"<font size=\"12\">You can now undo/redo with the spray paint!</font>",
			"<font size=\"12\">You can now directly purchase some item skins for credits without spinning!</font>"
		},
		"NEW TOOLS",
		{ "<font size=\"12\"><b>Sticky Note Tool:</b> Write a custom message and leave your mark! </font>" },
		"GAME CHANGES",
		{
			"<font size=\"12\">Default home reverted & refreshed.</font>",
			"<font size=\"12\">Added setting to hide all purchasable house items.</font>",
			"<font size=\"12\">Settings page now has headers for equipped, owned, and new sections.</font>"
		},
		"BUG FIXES",
		{ "<font size=\"12\">Bug Fixes</font>" }
	}
}, {
	Title = "We're back & Better!",
	Version = 7.8,
	Patch = 0,
	Date = os.time({
		month = 8,
		day = 19,
		year = 2025
	}),
	HeaderColor = Color3.fromRGB(170, 1, 1),
	Color = Color3.fromRGB(250, 214, 36),
	StarColor = Color3.fromRGB(0, 0, 0),
	Content = {
		"NEW CONTENT",
		{ "<font size=\"12\"><b>Weekly Shop:</b> Check out the new Weekly Shop with Limited-Time Items! </font>" },
		"NEW SHOP UI",
		{ "<font size=\"14\"><b>Check out our new & fresh shop interface!</b></font>" },
		"NEW TOOLS",
		{
			"<font size=\"12\"><b>Electric Guitar:</b> Rock out with your friends, maybe start a band?! </font>",
			"<font size=\"12\"><b>Harmonica:</b> From campfire chill to boss-fight thrill — whistle’s cooler cousin!</font>",
			"<font size=\"12\"><b>Ukulele:</b> Tiny titan of tunes — portable, plucky, and party-ready!</font>",
			"<font size=\"12\"><b>Heat Vision:</b> Grill cheese, light campfires, or just look dramatically awesome -- now in the Weekly Shop!</font>",
			"<font size=\"12\"><b>Donation Tool:</b> Receive donations from other players!</font>"
		},
		"GAME CHANGES",
		{
			"<font size=\"12\">There is now a notification prompt if you don't have enough credits to buy store items!</font>",
			"<font size=\"12\">Streaks have been added to Profiles!</font>",
			"<font size=\"12\">Houses reworked: Removed all bathrooms, beds, and disabled closets.</font>",
			"<font size=\"12\">Added Extra Slots Purchasing in-shop.</font>",
			"<font size=\"12\">Added shop items throughout the house.</font>"
		},
		"BUG FIXES",
		{ "<font size=\"12\">Misc bugs i.e QOL & feature/item reworks</font>" }
	}
}, {
	Title = "Summer 2025",
	Version = 7.7,
	Patch = 0,
	Date = os.time({
		month = 7,
		day = 20,
		year = 2025
	}),
	Color = Color3.fromRGB(250, 214, 36),
	HeaderColor = Color3.fromRGB(250, 214, 36),
	StarColor = Color3.fromRGB(250, 214, 36),
	Content = {
		"☀️ SUMMER RECESS HAS ARRIVED!",
		{ "<font size=\"14\"><b>🗺️ SUMMER MAP:</b> Check out the summer-themed map while it's live!</font>" },
		"NEW CONTENT",
		{
			"<font size=\"12\"><b>🏘️ HOUSE CUSTOMIZATION:</b> Express yourself through the design of your House!!</font>",
			"<font size=\"12\"><b>☀️ Summer Bundle:</b> Holiday-themed tool skins to freshen your style this season!</font>",
			"<font size=\"12\"><b>5 New Emotes!</b></font>",
			"<font size=\"12\"><b>New Non-Limited Tool Skins!</b></font>",
			"<font size=\"12\"><b>New Summer Pack Titles!</b></font>"
		},
		"NEW HOUSE SKIN",
		{ "<font size=\"14\"><b>Japandi House:</b> Show your inner calm with this stylish, laid-back Japandi home—where minimalism meets natural warmth!</font>" },
		"NEW TOOLS",
		{
			"<font size=\"14\"><b>👩‍🦲 Hair Snatcher:</b> Cash me outside how bout dat!</font>",
			"<font size=\"14\"><b>👻 Puppeteer:</b> Choose your victim... step inside their skin...</font>",
			"<font size=\"14\"><b>🔵 Bubble Blower:</b> Blow a big ol’ bubble, bop your target, and watch ‘em float away like a jellyfish on vacation!</font>",
			"<font size=\"14\"><b>🎷 Instruments:</b> Play some sweet tunes!</font>"
		},
		"GAME CHANGES",
		{
			"<font size=\"14\">Tic-Tac-Toe has received improvements!</font>",
			"<font size=\"14\">New Rock-Paper-Scissors gamemode!</font>",
			"<font size=\"14\">New Custom Servers will appear at the top of the list!</font>",
			"<font size=\"14\">All Tool prices have been re-calculated!</font>"
		},
		"BUG FIXES",
		{
			"<font size=\"14\">Fixed Bubble crashing servers</font>",
			"<font size=\"14\">Fixed Scaling for all of the Instruments</font>",
			"<font size=\"14\">Fixed Puppeteer breaking TicTacToe</font>",
			"<font size=\"14\">Fixed Jetpack bug with scaling</font>",
			"<font size=\"14\">Fixed Right shift key not changing transposition on piano</font>",
			"<font size=\"14\">Fixed party members not getting credits</font>",
			"<font size=\"14\">Lots more fixes!</font>"
		}
	}
}, {
	Version = 7.6,
	Patch = 1,
	Date = os.time({
		month = 5,
		day = 11,
		year = 2025
	}),
	Content = {
		"Easter Update Reverted",
		{ "We hope you enjoyed our Easter Update! We have lots of new & exciting Content coming to you soon!" },
		"🛠️ Bug Fixes 🛠️",
		{
			"<font size=\"11\">Fixed Selfie Stick FOV Bug</font>",
			"<font size=\"11\">Fixed Freeze Ray not cleaning up parts properly</font>",
			"<font size=\"11\">Fixed Fishbowl audio dampening breaking when using Helium Balloon</font>",
			"<font size=\"11\">Minor bug fixes!</font>"
		}
	}
}, {
	Title = "Easter Update",
	Version = 7.6,
	Patch = 0,
	Date = os.time({
		month = 4,
		day = 20,
		year = 2025
	}),
	Color = Color3.fromRGB(255, 170, 255),
	HeaderColor = Color3.fromRGB(250, 102, 213),
	StarColor = Color3.fromRGB(250, 102, 213),
	Content = {
		"EASTER IS HERE!",
		{ "<font size=\"14\"><b>🗺️ EASTER MAP:</b> Check out the easter-themed map while it's live!</font>" },
		"NEW CONTENT",
		{
			"<font size=\"14\"><b>🛍️ UGC SHOP TAB:</b> Explore a wide variety of new UGC items to wear inside and outside of Neighbors!</font>",
			"<font size=\"14\"><b>🐇 Easter Bundle 2:</b> Holiday-themed tool skins to freshen your style this season!</font>",
			"<font size=\"14\"><b>🥚 EASTER EGG HUNT:</b> Search around the neighborhood and collect all the hidden eggs!</font>",
			"<font size=\"14\"><b>🐣 LIMITED EASTER TITLES:</b> Show off your holiday spirit with new titles!</font>",
			"<font size=\"14\"><b>🧑‍🦰 Clippers Crate:</b> Grab brand new clippers and become the ultimate barber!</font>"
		},
		"NEW HOUSE SKIN",
		{ "<font size=\"14\"><b>Hipster House:</b> Express your inner hippie with this stylish and laid-back house design!</font>" },
		"NEW TOOLS",
		{
			"<font size=\"14\"><b>🐟 Fishbowl:</b> Muffle your friends and trap them in a fishy dome!</font>",
			"<font size=\"14\"><b>📸 Selfie Stick:</b> Time for a group photo—say cheese!</font>"
		},
		"GAME CHANGES",
		{
			"<font size=\"14\">Improved icons for shop categories for better browsing!</font>",
			"<font size=\"14\">Rock Paper Scissors has received improvements for smoother play!</font>"
		},
		"BUG FIXES",
		{ "<font size=\"14\">Minor bug fixes!</font>" }
	}
}
VersionOld[17], VersionOld[18], VersionOld[19], VersionOld[20], VersionOld[21], VersionOld[22], VersionOld[23], VersionOld[24], VersionOld[25] = {
	Version = 7.5,
	Patch = 1,
	Date = os.time({
		month = 3,
		day = 31,
		year = 2025
	}),
	Content = {
		"🛍️ New Features 🛍️",
		{
			"<font size=\"14\"><b>ITEM SHOP CATEGORIES:</b> You now have the ability to sort the shop by categories for an easy way to find tools that fit you the best!</font>",
			"<font size=\"14\"><b>NEW SHOP TAB (UGC):</b> Look at the bottom of the shop menu to find the UGC shop tab and represent Neighbors in every game you visit! (These UGC do not grant any benefits in the game)</font>"
		},
		"🛠️ Bug Fixes 🛠️",
		{ "<font size=\"14\">Minor bug fixes!</font>" }
	}
}, {
	Version = 7.5,
	Patch = 0,
	Date = os.time({
		month = 3,
		day = 19,
		year = 2025
	}),
	Content = {
		"🍀 ST. PATRICKS DAY UPDATE 🍀",
		{
			"<font size=\"14\"><b>ST. PATRICKS DAY BUNDLE 2:</b> Grab the St. Patricks Day Bundle 2 while the season of luck is here! 🍀</font>",
			"<font size=\"14\"><b>LIMITED ST. PATRICKS DAY TITLES</b> You got that... Pot'O Gold? </font>",
			"<font size=\"14\"><b>WEST CORNER</b>: Are you in our group yet? Because when you join, you get access to items that are group-exclusive!</font>"
		},
		" ✂️  Rock Paper Scissors 🪨 ",
		{ "<font size=\"14\"><b>Do you own the Cabin skin? If so make your way to the carpet in the master bedroom and vs your friends in a game of Rock Paper Scissors! Best of 3, who will be the champion?!?!</b></font>" },
		"🔔 Content Additions🔔",
		{
			"<font size=\"14\"><b>NEW TOOL: AIRHORN</b> LETS GET NOISY IN HERE!!!</font>",
			"<font size=\"14\"><b>NEW TOOL: CLIPBOARD</b> Jot down some notes to make sure you don't forget your conversations!!!</font>",
			"<font size=\"14\"><b>NEW TOOL: POPCORN</b> Sit back and watch while you enjoy a tasty treat as you watch your fellow Neighbors talk it up!</font>"
		},
		"🛠️ Bug Fixes 🛠️",
		{ "<font size=\"14\">Minor bug fixes!</font>" }
	}
}, {
	Version = 7.1,
	Patch = 1,
	Date = os.time({
		month = 3,
		day = 7,
		year = 2025
	}),
	Content = {
		"✨ NEIGHBORS UGC! ✨",
		{
			"<font size=\"14\"><b>Neighbors Jetpack</b>: You can fly and stuff like that</font>",
			"<font size=\"14\"><b>WEST CORNER</b>: Are you in our group yet? Because when you join, you get access to items that are group-exclusive!</font>"
		},
		"🔔 DING DONG 🔔",
		{ "<font size=\"14\">Knock knock, who's there? Check the front door!</font>" },
		"🛠️ Bug Fixes 🛠️",
		{ "<font size=\"14\">Minor bug fixes!</font>" }
	}
}, {
	Version = 7.1,
	Patch = 0,
	Date = os.time({
		month = 3,
		day = 5,
		year = 2025
	}),
	Content = {
		"🎉 NEIGHBORS 2 YEAR ANNIVERSARY! 🎉",
		{ "<font size=\"14\"><b>Today is the marking day of Neighbors release on ROBLOX, and we're thrilled to celebrate this 2nd milestone with all of you! As a token of our appreciation, we're rolling out some exciting updates and surprises this month. Today, we bring you our second UGC , the iconic Neighbors Jetpack! 🎊 </b></font>" },
		"✨ NEIGHBORS UGC! ✨",
		{
			"<font size=\"14\"><b>Neighbors Jetpack</b>: You can fly and stuff like that</font>",
			"<font size=\"14\"><b>WEST CORNER</b>: Are you in our group yet? Because when you join, you get access to items that are group-exclusive!</font>"
		},
		"⭐ Tool Changes ⭐",
		{
			"<font size=\"14\">Players now have the ability to favorite tools in their inventory to sort their most used from the rest they own!</font>",
			"<font size=\"14\">You can queue up with previously matched with players using match history!</font>",
			"<font size=\"14\">Tools will now stay in the the order you place them to in your hotbar so you dont lose them!</font>",
			"<font size=\"14\">Minor bug fixes!</font>"
		}
	}
}, {
	Version = 7,
	Patch = 0,
	Date = os.time({
		month = 2,
		day = 14,
		year = 2025
	}),
	Content = {
		"❤️💕 HAPPY VALENTINE'S DAY! 💕❤️",
		{
			"<font size=\"14\"><b>Pillow Tool:</b> Grab your friends and start the ultimate pillow fight frenzy!</font>",
			"<font size=\"14\"><b>Cupid Bow & Rose Tools</b> are back for a limited time — make sure to get them before they're gone!</font>",
			"<font size=\"14\">Challenge your friends to a classic game of <b>Tic-Tac-Toe</b> right in the driveway—who's the champ?</font>",
			"<font size=\"14\"><b>Valentine’s Bundle 2</b> has arrived! New skins to help you celebrate in style!</font>",
			"<font size=\"14\"><b>Valentine’s Pack:</b> Fun titles to show off — Will you be a Heartbreaker..?</font>"
		},
		"😎 Awesome New Features! 😊",
		{
			"<font size=\"14\">Custom server owners now get the exclusive title <b>'Server Owner'</b> — wear it with pride in your own domain!</font>",
			"<font size=\"14\">Trying to join your packed custom server? No worries! Inactive players will be automatically kicked so you can get in!</font>"
		},
		"🛠️ Bug Fixes & Tweaks! 🛠️",
		{
			"<font size=\"14\">Fixed a weird interaction with the speed coil and other speed tools — now you’re zooming smoother than ever!</font>",
			"<font size=\"14\">Prop Hunt tool is finally back in action — time to blend in and outsmart your friends!</font>",
			"<font size=\"14\">Various minor bug fixes!</font>"
		}
	}
}, {
	Version = 6.7,
	Patch = 1,
	Date = os.time({
		month = 1,
		day = 8,
		year = 2025
	}),
	Content = {
		"🛠️ Bug Fixes 🛠️",
		{
			"<font size=\"14\">Bug causing player to be rapidy reset fixed</font>",
			"<font size=\"14\">Going invisible in 18+ servers now makes title invisible aswell</font>",
			"<font size=\"14\">A few more minor bug fixes</font>"
		}
	}
}, {
	Version = 6.7,
	Patch = 0,
	Date = os.time({
		month = 1,
		day = 2,
		year = 2025
	}),
	Content = { "HAPPY NEW YEAR NEIGHBORS!🎉" }
}, {
	Version = 6.6,
	Patch = 1,
	Date = os.time({
		month = 12,
		day = 18,
		year = 2024
	}),
	Content = {
		"🛠️ Changes 🛠️",
		{
			"<font size=\"14\"><b>Added ability to kick players in your custom server while not being in it.</b></font>",
			"<font size=\"14\">Expired streak now allows you to continue and not wait the 24 hours to restore while still prompting the option.</font>"
		},
		"🛠️ Bug Fixes 🛠️",
		{ "<font size=\"14\">Minor performance fixes</font>" }
	}
}, {
	Version = 6.6,
	Patch = 0,
	Date = os.time({
		month = 12,
		day = 12,
		year = 2024
	}),
	Content = {
		"Merry Christmas! Experience our snowy map while it lasts. 🎅🎄",
		{
			"<font size=\"14\"><b>Christmas Presents:</b> Head to the Christmas tree in your house every day to receive a free gift!</font>",
			"<font size=\"14\"><b>Christmas Quest:</b> Quests are back! Use the Quests menu to collect ornaments for your Christmas tree! Click or tap the quest name for more info!</font>",
			"<font size=\"14\"><b>Christmas Titles:</b> Check them out in the shop!</font>",
			"<font size=\"14\"><b>Christmas Bundle:</b> This LIMITED bundle grants you the Krampus Pitchfork and Christmas-themed skins! Check the bundle for the full list!</font>",
			"<font size=\"14\"><b>LIMITED TIME TOOL:</b> FREEZE RAY, encase your friends in ice!</font>",
			"<font size=\"14\"><b>LIMITED TIME TOOL:</b> GINGERBREAD MORPH, check it out in the shop!</font>"
		},
		"Changes",
		{ "<font size=\"14\">Fixed a multitude of bugs and issues.</font>" }
	}
}
return VersionOld