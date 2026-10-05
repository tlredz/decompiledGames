local sharedAdminEvent = script:FindFirstAncestor("SharedAdminEvent")
require(sharedAdminEvent.Types)
return {
	Identity = "Collection",
	DisplayName = "Collect My Pages",
	Duration = 300,
	RunGlobally = false,
	Issueable = true,
	RunInTradePlaza = false,
	Actions = {
		"Announcement",
		"Fish",
		"Mutation",
		"Lighting",
		"StartSound",
		"Icon"
	},
	Arguments = {
		"<font color='#353535'>C̴̙̞̒͐̀̚ͅo̷͔͈̹̠̾̍̾͛l̴̛̤̜̲̾̊̐̇͛l̶̼͔̦͕̤͍̒̽̀̌͐ͅe̵̡̞͓̬̣̍̅͛c̷̛̩̪̏̾̾̾̾t̶͒́͊̒̀̏̄ͅ ̷̼̂́͐̊ͅm̴̮͌̓͝ÿ̷͍̘̯̀ ̵̨̠̺̦̺̻̓͂̈́̆͂͝p̸̭͘ä̶̠̆̀̚͝g̷̢̢̗͈̞̮̓̚ë̸͎̥́͂̄́͝s̷͓̬̪͕̦͘.̷̡̟̓͛̒̏̽.̸̨̪̙̫̟̓̋̋.̸̨̝̗̩͈͙̀</font>",
		{},
		{
			Darkened = 15,
			Albino = 15,
			Chaotic = 15
		},
		"Collection",
		129843230923735,
		97389171856416,
		"W̵̨̉̈ͅh̵̖̘͌a̶͓̓t̵̫̎ ̸̘̥͗͆ą̵̰̅̀r̴͕̓̿e̸͉͙͛ ̴̥͉͌̽y̷̨̝̿̋o̴̞̣̕u̴͎̹̚ ̴̬̀̈́w̷̮͒ä̷͎͔̐i̴͙̮̒ť̴̩̊i̷̧̮͒n̵̢̤͒̕g̵̼̳͊͗ ̴͔͕̓̿ḟ̷͔̱o̸͔̼͛r̸̗͆͜?̷̞͈̀̚"
	}
}