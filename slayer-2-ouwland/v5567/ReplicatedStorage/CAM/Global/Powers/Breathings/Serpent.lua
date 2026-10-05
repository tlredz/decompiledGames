local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.CAM.Global.Types.MiscTypes)
return {
	Icon = "rbxassetid://72412803182633",
	Skills = {
		{
			Name = "Blocking",
			Key = "F",
			CoolDown = 1,
			icon = "http://www.roblox.com/asset/?id=12529007524"
		},
		{
			Name = "Serpent Slash",
			Key = "Z",
			CoolDown = 15,
			Stamina = 18,
			icon = "rbxassetid://85851121237817",
			Max_Hold = 5,
			SkillStats = {
				additional_damage_scale = 0.5,
				strict_stun = true
			}
		},
		{
			Name = "Coil Choke",
			Key = "X",
			CoolDown = 18,
			Stamina = 24,
			icon = "rbxassetid://95113084840204",
			Max_Hold = 5,
			SkillStats = {
				additional_damage_scale = 0.8
			}
		},
		{
			Name = "Venom Fangs",
			Key = "C",
			CoolDown = 15,
			Stamina = 22,
			icon = "rbxassetid://136929863608145",
			Max_Hold = 5
		},
		{
			Name = "Twin-Headed Reptile",
			SkillStats = {
				additional_damage_scale = 0.75
			},
			Key = "V",
			CoolDown = 19,
			Stamina = 26,
			icon = "rbxassetid://72087027954070",
			Max_Hold = 5
		},
		{
			Name = "Slithering Serpent",
			Key = "B",
			CoolDown = 50,
			Stamina = 35,
			icon = "rbxassetid://80622219017756",
			Boss = "Obari",
			Max_Hold = 5
		}
	}
}