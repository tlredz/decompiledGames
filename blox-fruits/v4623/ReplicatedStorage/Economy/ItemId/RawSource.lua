local TableUtil = require(game.ReplicatedStorage.Packages.TableUtil)
require(script.Parent.Types)
local v = {
	{
		SecurityKey = "21fe3206ac2791c59f8426a70d5f595d",
		Id = {
			Type = "NonFruitItem",
			StorageKey = "Bisento",
			ItemId = 1
		}
	},
	{
		SecurityKey = "d72a6730c9f59341af3a8d97f700f01f",
		Id = {
			Type = "NonFruitItem",
			StorageKey = "Triple Katana",
			ItemId = 2
		}
	},
	{
		SecurityKey = "1f49a8f15aa383b26ad0492f2dacc4bf",
		Id = {
			Type = "Fruit",
			StorageKey = "Quake-Quake",
			ItemId = 3
		}
	},
	{
		SecurityKey = "cbd5ca9ffe7039c6cef86b07cb6b2b03",
		Id = {
			Type = "Fruit",
			StorageKey = "Rocket-Rocket",
			ItemId = 4
		}
	},
	{
		SecurityKey = "2666936896dee1bb4865a1d52ed2bf96",
		Id = {
			Type = "NonFruitItem",
			StorageKey = "Refined Slingshot",
			ItemId = 5
		}
	},
	{
		SecurityKey = "10c1873d4a822f8dfa1d37fca398801b",
		Id = {
			Type = "NonFruitItem",
			StorageKey = "Dual Flintlock",
			ItemId = 6
		}
	},
	{
		SecurityKey = "4683970781ba6a1daedf41d0c9d272f7",
		Id = {
			Type = "NonFruitItem",
			StorageKey = "Musket",
			ItemId = 7
		}
	},
	{
		SecurityKey = "6044d9e4dcda8d5f9f80bbb5675bb189",
		Id = {
			Type = "Fruit",
			StorageKey = "Magma-Magma",
			ItemId = 8
		}
	},
	{
		SecurityKey = "b26d07f32b03c2209f7d0ca54d78e4ab",
		Id = {
			Type = "NonFruitItem",
			StorageKey = "Hidden Key",
			ItemId = 9
		}
	},
	{
		SecurityKey = "872d2207d4ced1bd62aa2b7fc1ec22d4",
		Id = {
			Type = "NonFruitItem",
			StorageKey = "Shark Saw",
			ItemId = 10
		}
	},
	{
		SecurityKey = "e5b00c3ad747ad58a6ba15ce26906076",
		Id = {
			Type = "NonFruitItem",
			StorageKey = "Katana",
			ItemId = 11
		}
	},
	{
		SecurityKey = "5aac3dfb91b16e1173002f731d7aeaac",
		Id = {
			Type = "NonFruitItem",
			StorageKey = "Iron Mace",
			ItemId = 12
		}
	},
	{
		SecurityKey = "2e2e973aaef48378955a28154613835d",
		Id = {
			Type = "Fruit",
			StorageKey = "Ice-Ice",
			ItemId = 13
		}
	},
	{
		SecurityKey = "4d06a7b1295b017f6490090298089a93",
		Id = {
			Type = "Fruit",
			StorageKey = "Buddha-Buddha",
			ItemId = 14
		}
	},
	{
		SecurityKey = "c0f1f5bc728d6406d88ed2599065a323",
		Id = {
			Type = "NonFruitItem",
			StorageKey = "Sanguine Art",
			ItemId = 15
		}
	},
	{
		SecurityKey = "e1fb189f1df8f08923489945384560ca",
		Id = {
			Type = "NonFruitItem",
			StorageKey = "Saber",
			ItemId = 16
		}
	},
	{
		SecurityKey = "6ed66143785159fcbd19347ad8e9f92c",
		Id = {
			Type = "NonFruitItem",
			StorageKey = "Flintlock",
			ItemId = 17
		}
	},
	{
		SecurityKey = "48d16f7291020d0c94f45bfee5958470",
		Id = {
			Type = "Fruit",
			StorageKey = "Flame-Flame",
			ItemId = 18
		}
	},
	{
		SecurityKey = "0f108c9c88e707b38fb3ce155bd3c937",
		Id = {
			Type = "NonFruitItem",
			StorageKey = "Dual Katana",
			ItemId = 19
		}
	},
	{
		SecurityKey = "3a32b2dcc5042d1c0d789befa7e9be61",
		Id = {
			Type = "Fruit",
			StorageKey = "Dark-Dark",
			ItemId = 20
		}
	},
	{
		SecurityKey = "49aac03f984f441da27e005aaa7fc57c",
		Id = {
			Type = "NonFruitItem",
			StorageKey = "Cutlass",
			ItemId = 21
		}
	},
	{
		SecurityKey = "6a5fc35b5bf19454023720f50e9069fa",
		Id = {
			Type = "NonFruitItem",
			StorageKey = "Combat",
			ItemId = 22
		}
	},
	{
		SecurityKey = "369db1db4f0acdf151e2a0cec1439d2e",
		Id = {
			Type = "NonFruitItem",
			StorageKey = "Cannon",
			ItemId = 23
		}
	},
	{
		SecurityKey = "8841a2e9e482b465a196120e639b010d",
		Id = {
			Type = "Fruit",
			StorageKey = "Rubber-Rubber",
			ItemId = 24
		}
	},
	{
		SecurityKey = "72bd3bc3a048e0f574806005bf6df6ee",
		Id = {
			Type = "Fruit",
			StorageKey = "Bomb-Bomb",
			ItemId = 25
		}
	},
	{
		SecurityKey = "6eefcd864d8e458cd9b822f7cd705f5b",
		Id = {
			Type = "Fruit",
			StorageKey = "Spike-Spike",
			ItemId = 26
		}
	},
	{
		SecurityKey = "f707c01a4969e79711778d748c79f63d",
		Id = {
			Type = "NonFruitItem",
			StorageKey = "Wardens Sword",
			ItemId = 27
		}
	},
	{
		SecurityKey = "67437be7cb639a501ad86796fdb49e5d",
		Id = {
			Type = "NonFruitItem",
			StorageKey = "Pipe",
			ItemId = 28
		}
	},
	{
		SecurityKey = "fd0e0f0ab60ab54e61c3c71692c72456",
		Id = {
			Type = "NonFruitItem",
			StorageKey = "Dual-Headed Blade",
			ItemId = 29
		}
	},
	{
		SecurityKey = "de266a1aae4e094d291f1beccad0812c",
		Id = {
			Type = "NonFruitItem",
			StorageKey = "Meme-Meme",
			ItemId = 30
		}
	},
	{
		SecurityKey = "1eddcae76172562329c9439744a434de",
		Id = {
			Type = "Fruit",
			StorageKey = "Blade-Blade",
			ItemId = 31
		}
	},
	{
		SecurityKey = "effa95ee09e41c21bdca40df30e9e25d",
		Id = {
			Type = "Fruit",
			StorageKey = "Smoke-Smoke",
			ItemId = 32
		}
	},
	{
		SecurityKey = "09c8723016e873824c4313a4a79a1112",
		Id = {
			Type = "NonFruitItem",
			StorageKey = "_Black Leg",
			ItemId = 33
		}
	},
	{
		SecurityKey = "10f6e5ffb76d7a7596f8b652f1a9eb0b",
		Id = {
			Type = "NonFruitItem",
			StorageKey = "Black Leg",
			ItemId = 34
		}
	},
	{
		SecurityKey = "75b74bf5cbaac5249033d0b361e678cf",
		Id = {
			Type = "NonFruitItem",
			StorageKey = "Coat",
			ItemId = 35
		}
	},
	{
		SecurityKey = "e7d1312191b1f642561f6712fb14ea8c",
		Id = {
			Type = "NonFruitItem",
			StorageKey = "Pink Coat",
			ItemId = 36
		}
	},
	{
		SecurityKey = "7762538da04fc8a63170cb61c9f599b9",
		Id = {
			Type = "NonFruitItem",
			StorageKey = "Torch",
			ItemId = 37
		}
	},
	{
		SecurityKey = "e3e2536f8cdbc9a0454e0c46852a4e2f",
		Id = {
			Type = "NonFruitItem",
			StorageKey = "Cup",
			ItemId = 38
		}
	},
	{
		SecurityKey = "b8d67a146a05861d1dd6ba45f6aaeac4",
		Id = {
			Type = "NonFruitItem",
			StorageKey = "Tomoe Ring",
			ItemId = 39
		}
	},
	{
		SecurityKey = "de4af9307cf8168f79075a6e8378a653",
		Id = {
			Type = "NonFruitItem",
			StorageKey = "Black Cape",
			ItemId = 40
		}
	},
	{
		SecurityKey = "0703f1c44dd1ee8fe7703fb8633d4e5a",
		Id = {
			Type = "NonFruitItem",
			StorageKey = "Swordsman Hat",
			ItemId = 41
		}
	},
	{
		SecurityKey = "0b13348f22003ec719b515415a2a58ac",
		Id = {
			Type = "NonFruitItem",
			StorageKey = "Cool Shades",
			ItemId = 42
		}
	},
	{
		SecurityKey = "4a425ee60a5d1ecc13b8f552791fd86c",
		Id = {
			Type = "Fruit",
			StorageKey = "Phoenix-Phoenix",
			ItemId = 43
		}
	},
	{
		SecurityKey = "c9725518566ba14a99803eb32e488c2a",
		Id = {
			Type = "NonFruitItem",
			StorageKey = "Soul Cane",
			ItemId = 44
		}
	},
	{
		SecurityKey = "846f4ba3671133840248ed082a25d7b8",
		Id = {
			Type = "NonFruitItem",
			StorageKey = "Electro",
			ItemId = 45
		}
	},
	{
		SecurityKey = "04052af50d3a0731275d7596710b4b19",
		Id = {
			Type = "Fruit",
			StorageKey = "Spring-Spring",
			ItemId = 46
		}
	},
	{
		SecurityKey = "7ae18d1588737fd6aa73747c9b113bad",
		Id = {
			Type = "NonFruitItem",
			StorageKey = "Magma Blaster",
			ItemId = 47
		}
	},
	{
		SecurityKey = "d83e4dff56dbf7a405f74e180f455f31",
		Id = {
			Type = "Fruit",
			StorageKey = "Spider-Spider",
			ItemId = 48
		}
	},
	{
		SecurityKey = "a5873d6aedf86cdac99eedb8271c3662",
		Id = {
			Type = "NonFruitItem",
			StorageKey = "Trident",
			ItemId = 49
		}
	},
	{
		SecurityKey = "17751800a3df8c6abac6da6a992cfb99",
		Id = {
			Type = "Fruit",
			StorageKey = "Rumble-Rumble",
			ItemId = 50
		}
	},
	{
		SecurityKey = "4d1a40a27bf818a815a47911cac7309d",
		Id = {
			Type = "NonFruitItem",
			StorageKey = "Pole (1st Form)",
			ItemId = 51
		}
	},
	{
		SecurityKey = "13baf6d7f10e235bc471df8eda5f4e45",
		Id = {
			Type = "NonFruitItem",
			StorageKey = "Bazooka",
			ItemId = 52
		}
	},
	{
		SecurityKey = "2dd88dfae3454ba358531e92fbc5eaf7",
		Id = {
			Type = "Fruit",
			StorageKey = "Sand-Sand",
			ItemId = 53
		}
	},
	{
		SecurityKey = "df6241bf4132d761eea4fbf1939d8b97",
		Id = {
			Type = "Fruit",
			StorageKey = "Gravity-Gravity",
			ItemId = 54
		}
	},
	{
		SecurityKey = "5e13ded544be19ec2af7ec843308f9c4",
		Id = {
			Type = "NonFruitItem",
			StorageKey = "Fishman Karate",
			ItemId = 55
		}
	},
	{
		SecurityKey = "9bc42bf8202e12f72907840bd22fe7ae",
		Id = {
			Type = "NonFruitItem",
			StorageKey = "D.S. Coat",
			ItemId = 56
		}
	},
	{
		SecurityKey = "fc0f9b4848369b7c8d9ba37341ecb486",
		Id = {
			Type = "Fruit",
			StorageKey = "Pain-Pain",
			ItemId = 57
		}
	},
	{
		SecurityKey = "5e48569117888f812b62b76f0df887ed",
		Id = {
			Type = "Fruit",
			StorageKey = "Barrier-Barrier",
			ItemId = 58
		}
	},
	{
		SecurityKey = "6c0c549055cd377a6b709fb1b74185c6",
		Id = {
			Type = "NonFruitItem",
			StorageKey = "Usoap's Hat",
			ItemId = 59
		}
	},
	{
		SecurityKey = "2f79668db2e7e8f5bf07bbc412a758c2",
		Id = {
			Type = "NonFruitItem",
			StorageKey = "Top Hat",
			ItemId = 60
		}
	},
	{
		SecurityKey = "93e9b01b147bccf95829966b67e274e3",
		Id = {
			Type = "NonFruitItem",
			StorageKey = "Marine Cap",
			ItemId = 61
		}
	},
	{
		SecurityKey = "32a6ca4723a56a25ebfefa94bfbf90af",
		Id = {
			Type = "NonFruitItem",
			StorageKey = "Warrior Helmet",
			ItemId = 62
		}
	},
	{
		SecurityKey = "45a7c3e9850b5ffcf5a996f823d89f19",
		Id = {
			Type = "NonFruitItem",
			StorageKey = "Choppa",
			ItemId = 63
		}
	},
	{
		SecurityKey = "66dcecf2fb440c3069f7bd8cf816a5c1",
		Id = {
			Type = "Fruit",
			StorageKey = "Leopard-Leopard",
			ItemId = 64
		}
	},
	{
		SecurityKey = "67499017fd2fa31af092c400cdbcb021",
		Id = {
			Type = "NonFruitItem",
			StorageKey = "Gravity Blade",
			ItemId = 65
		}
	},
	{
		SecurityKey = "8bc0862422ca7134852ee40ac16d8139",
		Id = {
			Type = "NonFruitItem",
			StorageKey = "Shizu",
			ItemId = 66
		}
	},
	{
		SecurityKey = "3bebe06d8d2d2254f1f4705dba3396a0",
		Id = {
			Type = "NonFruitItem",
			StorageKey = "Longsword",
			ItemId = 67
		}
	},
	{
		SecurityKey = "461529d351f72efada53a8b9c06c0d04",
		Id = {
			Type = "NonFruitItem",
			StorageKey = "Dragon Claw",
			ItemId = 68
		}
	},
	{
		SecurityKey = "3fbc2e1ed60f5231fa6792c8cc0e1414",
		Id = {
			Type = "NonFruitItem",
			StorageKey = "Saishi",
			ItemId = 69
		}
	},
	{
		SecurityKey = "7e25eb787dfadea9e2256523c595c83e",
		Id = {
			Type = "NonFruitItem",
			StorageKey = "Oroshi",
			ItemId = 70
		}
	},
	{
		SecurityKey = "65482811fc56fcd0c94de2eed2a4873f",
		Id = {
			Type = "NonFruitItem",
			StorageKey = "Swan Glasses",
			ItemId = 71
		}
	},
	{
		SecurityKey = "b1d989790b1b7c859e4417c33df0eaaf",
		Id = {
			Type = "NonFruitItem",
			StorageKey = "Dark Coat",
			ItemId = 72
		}
	},
	{
		SecurityKey = "20e1075339b2e72535f30e17531c3942",
		Id = {
			Type = "NonFruitItem",
			StorageKey = "Flower 1",
			ItemId = 73
		}
	},
	{
		SecurityKey = "1b0efacdca5098be1d818eccace963d0",
		Id = {
			Type = "NonFruitItem",
			StorageKey = "Flower 2",
			ItemId = 74
		}
	},
	{
		SecurityKey = "b3961ffff3ad815b75e1b6ba3546f568",
		Id = {
			Type = "NonFruitItem",
			StorageKey = "Flower 3",
			ItemId = 75
		}
	},
	{
		SecurityKey = "1481381b23b4aa8fe82ada796fe44ea9",
		Id = {
			Type = "NonFruitItem",
			StorageKey = "Last Resort",
			ItemId = 76
		}
	},
	{
		SecurityKey = "c270a749f120597191aebdba93123a98",
		Id = {
			Type = "NonFruitItem",
			StorageKey = "Agility",
			ItemId = 77
		}
	},
	{
		SecurityKey = "1e213062cf21517f784d2b92981aefc1",
		Id = {
			Type = "NonFruitItem",
			StorageKey = "Water Body",
			ItemId = 78
		}
	},
	{
		SecurityKey = "d5e679f195edcb3fc20a4a1d73d948bf",
		Id = {
			Type = "NonFruitItem",
			StorageKey = "Heavenly Blood",
			ItemId = 79
		}
	},
	{
		SecurityKey = "f9ad33c906ae778bbed7fb82372732db",
		Id = {
			Type = "Fruit",
			StorageKey = "Light-Light",
			ItemId = 80
		}
	},
	{
		SecurityKey = "1b1146aeeec53ec925c49b391b49951c",
		Id = {
			Type = "NonFruitItem",
			StorageKey = "Rare Artifact",
			ItemId = 81
		}
	},
	{
		SecurityKey = "5dc74593aae501807d9dd5948f3f5f47",
		Id = {
			Type = "NonFruitItem",
			StorageKey = "Acidum Rifle",
			ItemId = 82
		}
	},
	{
		SecurityKey = "5b69f68fdef498a180bb3fd0410d308b",
		Id = {
			Type = "NonFruitItem",
			StorageKey = "Summon Sea Beast",
			ItemId = 83
		}
	},
	{
		SecurityKey = "f363efe7aa826cf749271672994f0548",
		Id = {
			Type = "NonFruitItem",
			StorageKey = "Kabucha",
			ItemId = 84
		}
	},
	{
		SecurityKey = "eb8cc911f9f4d24d9b38b421f5040258",
		Id = {
			Type = "NonFruitItem",
			StorageKey = "Black Spikey Coat",
			ItemId = 85
		}
	},
	{
		SecurityKey = "c54d0b0da9ba1583072161f5d77f3997",
		Id = {
			Type = "Fruit",
			StorageKey = "Love-Love",
			ItemId = 86
		}
	},
	{
		SecurityKey = "cd1fad6342c2a1962044e2d9f1f9d2fe",
		Id = {
			Type = "NonFruitItem",
			StorageKey = "True Triple Katana",
			ItemId = 87
		}
	},
	{
		SecurityKey = "77d0bcd8ae2a6dbd489af9bcc61996ea",
		Id = {
			Type = "NonFruitItem",
			StorageKey = "Superhuman",
			ItemId = 88
		}
	},
	{
		SecurityKey = "fd351603cfd7eeea5e9a881ca01927ed",
		Id = {
			Type = "NonFruitItem",
			StorageKey = "black pillar",
			ItemId = 89
		}
	},
	{
		SecurityKey = "d71b314715519484841a3f6a1edb0cfb",
		Id = {
			Type = "NonFruitItem",
			StorageKey = "black nuke",
			ItemId = 90
		}
	},
	{
		SecurityKey = "5ae99a9ebd590d3ab5a2c03c554e2119",
		Id = {
			Type = "NonFruitItem",
			StorageKey = "Rogue-Rogue",
			ItemId = 91
		}
	},
	{
		SecurityKey = "4853570f7689d26fb7b4fb81208d58f8",
		Id = {
			Type = "NonFruitItem",
			StorageKey = "black blast",
			ItemId = 92
		}
	},
	{
		SecurityKey = "42c9f92bb8ba0952687f049eaba58cb7",
		Id = {
			Type = "NonFruitItem",
			StorageKey = "Microchip",
			ItemId = 93
		}
	},
	{
		SecurityKey = "467c0e682e2028fc52cbab6e5b642ddd",
		Id = {
			Type = "NonFruitItem",
			StorageKey = "Special Microchip",
			ItemId = 94
		}
	},
	{
		SecurityKey = "c509e33ee2fdf45c5ba69d185985baf2",
		Id = {
			Type = "Fruit",
			StorageKey = "Control-Control",
			ItemId = 95
		}
	},
	{
		SecurityKey = "f7cfd9555e8ce0953dc5ed339604ce81",
		Id = {
			Type = "NonFruitItem",
			StorageKey = "Flail",
			ItemId = 96
		}
	},
	{
		SecurityKey = "170d7364a97c77172cc7e90e9f464427",
		Id = {
			Type = "NonFruitItem",
			StorageKey = "Koko",
			ItemId = 97
		}
	},
	{
		SecurityKey = "15458a81ad14cc3a4ddd3cfd6e807ace",
		Id = {
			Type = "NonFruitItem",
			StorageKey = "Zebra Cap",
			ItemId = 98
		}
	},
	{
		SecurityKey = "3791bf5239f380e3f505aaf691c7fd31",
		Id = {
			Type = "NonFruitItem",
			StorageKey = "black meteors",
			ItemId = 99
		}
	},
	{
		SecurityKey = "d52f0c432625f1b8e64941c92e10f175",
		Id = {
			Type = "NonFruitItem",
			StorageKey = "kamui",
			ItemId = 100
		}
	},
	{
		SecurityKey = "07cbecc202725ccbc92fe0111e7109cd",
		Id = {
			Type = "NonFruitItem",
			StorageKey = "gate",
			ItemId = 101
		}
	},
	{
		SecurityKey = "2fb2bc015ae67931d8f5cd063db2f708",
		Id = {
			Type = "NonFruitItem",
			StorageKey = "amaterasu",
			ItemId = 102
		}
	},
	{
		SecurityKey = "e2f6c2794a94365ad03048d1b64955f3",
		Id = {
			Type = "NonFruitItem",
			StorageKey = "Old Dragon Egg",
			ItemId = 103
		}
	},
	{
		SecurityKey = "1c3af0791de224cf74f3443f180699e2",
		Id = {
			Type = "NonFruitItem",
			StorageKey = "Midnight Blade",
			ItemId = 104
		}
	},
	{
		SecurityKey = "9258d04aa7d3fd5ac4ee1db82d18b370",
		Id = {
			Type = "NonFruitItem",
			StorageKey = "Ghoul Mask",
			ItemId = 105
		}
	},
	{
		SecurityKey = "ef76a3960c2b2d9167c1a41a8ab7f311",
		Id = {
			Type = "NonFruitItem",
			StorageKey = "Heightened Senses",
			ItemId = 106
		}
	},
	{
		SecurityKey = "3ad9955250bf34a02df98991922a7b8b",
		Id = {
			Type = "NonFruitItem",
			StorageKey = "Hellfire Torch",
			ItemId = 107
		}
	},
	{
		SecurityKey = "f1e6213e912a8f1ff01830483ffd8350",
		Id = {
			Type = "NonFruitItem",
			StorageKey = "Red Spikey Coat",
			ItemId = 108
		}
	},
	{
		SecurityKey = "1acd10ae96500f435c049f72c5f019cf",
		Id = {
			Type = "NonFruitItem",
			StorageKey = "Blue Spikey Coat",
			ItemId = 109
		}
	},
	{
		SecurityKey = "5a6fa69ae16a4b5ff31b443d9764fa7e",
		Id = {
			Type = "NonFruitItem",
			StorageKey = "tensei",
			ItemId = 110
		}
	},
	{
		SecurityKey = "36738580d445a0d5c748f45432057ae3",
		Id = {
			Type = "NonFruitItem",
			StorageKey = "Death Step",
			ItemId = 111
		}
	},
	{
		SecurityKey = "2b349fd89918e3fc01ec68f7d542865f",
		Id = {
			Type = "NonFruitItem",
			StorageKey = "Rengoku",
			ItemId = 112
		}
	},
	{
		SecurityKey = "dbf2ec9947130a66c138855e104f6bac",
		Id = {
			Type = "NonFruitItem",
			StorageKey = "Santa Hat",
			ItemId = 113
		}
	},
	{
		SecurityKey = "deaed9070d6fdc264518d85ce431c414",
		Id = {
			Type = "NonFruitItem",
			StorageKey = "Elf Hat",
			ItemId = 114
		}
	},
	{
		SecurityKey = "4c06bee344087af346ef0e8f09af00e8",
		Id = {
			Type = "NonFruitItem",
			StorageKey = "Fist of Darkness",
			ItemId = 115
		}
	},
	{
		SecurityKey = "caad6638fb3599889042bc26e61aa72a",
		Id = {
			Type = "NonFruitItem",
			StorageKey = "Relic",
			ItemId = 116
		}
	},
	{
		SecurityKey = "b837a0d97742f8bb6106de9e43444674",
		Id = {
			Type = "Fruit",
			StorageKey = "Dragon (Classic)-Dragon (Classic)",
			ItemId = 117
		}
	},
	{
		SecurityKey = "7c68ef7269fd0a522c00f987edd7c35e",
		Id = {
			Type = "NonFruitItem",
			StorageKey = "Triple Dark Blade",
			ItemId = 118
		}
	},
	{
		SecurityKey = "9d0b891cf59469d457e0fadfb0cd0707",
		Id = {
			Type = "NonFruitItem",
			StorageKey = "rip kamui",
			ItemId = 119
		}
	},
	{
		SecurityKey = "b7441cbb9b4af699940b990597913ce6",
		Id = {
			Type = "NonFruitItem",
			StorageKey = "Dragon Trident",
			ItemId = 120
		}
	},
	{
		SecurityKey = "01635fb353ab231278153f742284f71c",
		Id = {
			Type = "NonFruitItem",
			StorageKey = "Pole (2nd Form)",
			ItemId = 121
		}
	},
	{
		SecurityKey = "278fc1d2dc8f3e2bec1ed727e9250e97",
		Id = {
			Type = "NonFruitItem",
			StorageKey = "Sharkman Karate",
			ItemId = 122
		}
	},
	{
		SecurityKey = "bd356be03a0183f05aadddb25dfadd01",
		Id = {
			Type = "NonFruitItem",
			StorageKey = "Sweet Chalice",
			ItemId = 123
		}
	},
	{
		SecurityKey = "1ae72735c798efd90c7f36583ef9147e",
		Id = {
			Type = "NonFruitItem",
			StorageKey = "Energy Core",
			ItemId = 124
		}
	},
	{
		SecurityKey = "b03d6bbafb97266c38a50214d52128b7",
		Id = {
			Type = "NonFruitItem",
			StorageKey = "Core Brain",
			ItemId = 125
		}
	},
	{
		SecurityKey = "3a8073eed2d6912434ddea4d8cb799a6",
		Id = {
			Type = "NonFruitItem",
			StorageKey = "Electric Claw",
			ItemId = 126
		}
	},
	{
		SecurityKey = "ee1f70ed03a6c1ae8b35e45fc01d7731",
		Id = {
			Type = "Fruit",
			StorageKey = "Venom-Venom",
			ItemId = 127
		}
	},
	{
		SecurityKey = "77f4228b8b40782fc35b016d9c76865e",
		Id = {
			Type = "Fruit",
			StorageKey = "Spin-Spin",
			ItemId = 128
		}
	},
	{
		SecurityKey = "9621362046ea1b2f57f5cf93c9952fd8",
		Id = {
			Type = "NonFruitItem",
			StorageKey = "Door-Door",
			ItemId = 129
		}
	},
	{
		SecurityKey = "d0d5a241a5cc7ae467132df47138869f",
		Id = {
			Type = "NonFruitItem",
			StorageKey = "Kilo-Kilo",
			ItemId = 130
		}
	},
	{
		SecurityKey = "2ebe7db867a4c3773bbbe3bb9dc41900",
		Id = {
			Type = "NonFruitItem",
			StorageKey = "Bizarre Revolver",
			ItemId = 131
		}
	},
	{
		SecurityKey = "31480ab2abc6c70715e584262356b683",
		Id = {
			Type = "NonFruitItem",
			StorageKey = "Love2-Love2",
			ItemId = 132
		}
	},
	{
		SecurityKey = "8a9e9e33e12062f282c9131c007944cf",
		Id = {
			Type = "Fruit",
			StorageKey = "Falcon-Falcon",
			ItemId = 133
		}
	},
	{
		SecurityKey = "61b7c0fe3c473078493e871a1b1fc03a",
		Id = {
			Type = "NonFruitItem",
			StorageKey = "Canvander",
			ItemId = 134
		}
	},
	{
		SecurityKey = "9aee478cf66640c609efb8b687adae6d",
		Id = {
			Type = "NonFruitItem",
			StorageKey = "Yama",
			ItemId = 135
		}
	},
	{
		SecurityKey = "fc408ec916be273c938e66ea11552365",
		Id = {
			Type = "NonFruitItem",
			StorageKey = "Tushita",
			ItemId = 136
		}
	},
	{
		SecurityKey = "c8b0f5e7590efd6c48587475351ae6f6",
		Id = {
			Type = "NonFruitItem",
			StorageKey = "Twin Hooks",
			ItemId = 137
		}
	},
	{
		SecurityKey = "0712f06a617df4841a813ae9d77d3245",
		Id = {
			Type = "NonFruitItem",
			StorageKey = "Apple",
			ItemId = 138
		}
	},
	{
		SecurityKey = "c513d79c7a0378222538358868315b1c",
		Id = {
			Type = "NonFruitItem",
			StorageKey = "Pretty Helmet",
			ItemId = 139
		}
	},
	{
		SecurityKey = "c2ad5ae940441e0c9e2cbf91c2f51ecb",
		Id = {
			Type = "NonFruitItem",
			StorageKey = "Jaw Shield",
			ItemId = 140
		}
	},
	{
		SecurityKey = "e7f2daaaff159b10599d0f1e670d6425",
		Id = {
			Type = "NonFruitItem",
			StorageKey = "God's Chalice",
			ItemId = 141
		}
	},
	{
		SecurityKey = "90bed782c0f75dd7699748cf0a74367b",
		Id = {
			Type = "NonFruitItem",
			StorageKey = "Holy Torch",
			ItemId = 142
		}
	},
	{
		SecurityKey = "ab253bac12616ea1385291ffa5de46f9",
		Id = {
			Type = "NonFruitItem",
			StorageKey = "Venom Bow",
			ItemId = 143
		}
	},
	{
		SecurityKey = "d7536649ea8a3b1fa813c16b71824c73",
		Id = {
			Type = "NonFruitItem",
			StorageKey = "Banana",
			ItemId = 144
		}
	},
	{
		SecurityKey = "a9444f93ef1c20fed4db3be240eb4d8b",
		Id = {
			Type = "NonFruitItem",
			StorageKey = "Pineapple",
			ItemId = 145
		}
	},
	{
		SecurityKey = "d4dd21f42b4ef581b36cf1aff6d1a1b2",
		Id = {
			Type = "NonFruitItem",
			StorageKey = "Fruit Bowl",
			ItemId = 146
		}
	},
	{
		SecurityKey = "1cb3fc88c0818babb9be66999325aeb1",
		Id = {
			Type = "NonFruitItem",
			StorageKey = "Valkyrie Helm",
			ItemId = 147
		}
	},
	{
		SecurityKey = "0bbe670f629dfe93cb5ddbc8e305effa",
		Id = {
			Type = "NonFruitItem",
			StorageKey = "Hunter Cape (Red)",
			ItemId = 148
		}
	},
	{
		SecurityKey = "c17209f40e4576c18d01a8978114e12e",
		Id = {
			Type = "NonFruitItem",
			StorageKey = "Hunter Cape (Green)",
			ItemId = 149
		}
	},
	{
		SecurityKey = "0d90780bf3ffcbdcaa2a64ea41c8321b",
		Id = {
			Type = "NonFruitItem",
			StorageKey = "Hunter Cape (Black)",
			ItemId = 150
		}
	},
	{
		SecurityKey = "9733c3f1c46428656cc9ba2d1bfc64b8",
		Id = {
			Type = "NonFruitItem",
			StorageKey = "Bandanna (Black)",
			ItemId = 151
		}
	},
	{
		SecurityKey = "56b785a3b0b867d5cfa03c02676e2e79",
		Id = {
			Type = "NonFruitItem",
			StorageKey = "Bandanna (Green)",
			ItemId = 152
		}
	},
	{
		SecurityKey = "97bff4fb9b63ba7d53632e1928ef2e5f",
		Id = {
			Type = "NonFruitItem",
			StorageKey = "Bandanna (Red)",
			ItemId = 153
		}
	},
	{
		SecurityKey = "3a7580b048a7b83f52a7348622589e21",
		Id = {
			Type = "NonFruitItem",
			StorageKey = "Musketeer Hat",
			ItemId = 154
		}
	},
	{
		SecurityKey = "278b25cb6a1b368c12542142c0eb6b16",
		Id = {
			Type = "NonFruitItem",
			StorageKey = "Pilot Helmet",
			ItemId = 155
		}
	},
	{
		SecurityKey = "5418e048d12924d5fcc8163722bc8382",
		Id = {
			Type = "NonFruitItem",
			StorageKey = "Lei",
			ItemId = 156
		}
	},
	{
		SecurityKey = "f33a5ff07227510f51d03cb9b71916f9",
		Id = {
			Type = "NonFruitItem",
			StorageKey = "Dark Dagger",
			ItemId = 157
		}
	},
	{
		SecurityKey = "40ade1edfb7adf6ae6d5d0682e852873",
		Id = {
			Type = "Fruit",
			StorageKey = "Ghost-Ghost",
			ItemId = 158
		}
	},
	{
		SecurityKey = "e2828686901baffddbb58b0ee91c38b4",
		Id = {
			Type = "NonFruitItem",
			StorageKey = "Dragon Talon",
			ItemId = 159
		}
	},
	{
		SecurityKey = "51f993fdb91d50c0ac7f72263dddbe11",
		Id = {
			Type = "NonFruitItem",
			StorageKey = "Hallow Scythe",
			ItemId = 160
		}
	},
	{
		SecurityKey = "911ec93151e29fc705603a6dbb298311",
		Id = {
			Type = "NonFruitItem",
			StorageKey = "Fire Essence",
			ItemId = 161
		}
	},
	{
		SecurityKey = "a8aec042178a3ebd172ae803198199b8",
		Id = {
			Type = "NonFruitItem",
			StorageKey = "Hallow Essence",
			ItemId = 162
		}
	},
	{
		SecurityKey = "6fa4061123561b1fdd9fad7270d73ae0",
		Id = {
			Type = "Fruit",
			StorageKey = "Shadow-Shadow",
			ItemId = 163
		}
	},
	{
		SecurityKey = "5861b908a06fe16a0dc6ba7472fa678a",
		Id = {
			Type = "NonFruitItem",
			StorageKey = "Bear Ears",
			ItemId = 164
		}
	},
	{
		SecurityKey = "08fed02a3adf2ec55ef3634574f1472d",
		Id = {
			Type = "NonFruitItem",
			StorageKey = "Golden Sunhat",
			ItemId = 165
		}
	},
	{
		SecurityKey = "17d11829c96abc103a34156b3e6d3b43",
		Id = {
			Type = "NonFruitItem",
			StorageKey = "Holy Crown",
			ItemId = 166
		}
	},
	{
		SecurityKey = "3517cd1aa3b134a710eff08485f8c146",
		Id = {
			Type = "NonFruitItem",
			StorageKey = "Buddy Sword",
			ItemId = 167
		}
	},
	{
		SecurityKey = "6cffd0cc405ec30ecb043839adc7b226",
		Id = {
			Type = "NonFruitItem",
			StorageKey = "Spikey Trident",
			ItemId = 168
		}
	},
	{
		SecurityKey = "f4aeec82c48b9c465a248abe16bfb170",
		Id = {
			Type = "NonFruitItem",
			StorageKey = "Pale Scarf",
			ItemId = 169
		}
	},
	{
		SecurityKey = "6f55903b2fff21dd43e2b83c8eb80d17",
		Id = {
			Type = "Fruit",
			StorageKey = "Portal-Portal",
			ItemId = 170
		}
	},
	{
		SecurityKey = "71e445d3b592303b4b00b26a52271acb",
		Id = {
			Type = "NonFruitItem",
			StorageKey = "arena kamui",
			ItemId = 171
		}
	},
	{
		SecurityKey = "c3ffe69d1b8fedeb908d251cd2d96143",
		Id = {
			Type = "NonFruitItem",
			StorageKey = "heaven kamui",
			ItemId = 172
		}
	},
	{
		SecurityKey = "0e8226f0d569a64eaceee037f0b5f245",
		Id = {
			Type = "NonFruitItem",
			StorageKey = "Awakening",
			ItemId = 173
		}
	},
	{
		SecurityKey = "410526878e2c82c0cfe9071b709d9954",
		Id = {
			Type = "NonFruitItem",
			StorageKey = "Skull Guitar",
			ItemId = 174
		}
	},
	{
		SecurityKey = "7fc1e46168db3ad7ea5a6c2aac343835",
		Id = {
			Type = "NonFruitItem",
			StorageKey = "Cursed Dual Katana",
			ItemId = 175
		}
	},
	{
		SecurityKey = "95bb5f858527a96d6185759de4941332",
		Id = {
			Type = "NonFruitItem",
			StorageKey = "Godhuman",
			ItemId = 176
		}
	},
	{
		SecurityKey = "48509c2772a7d203d5a80b993a35ff3d",
		Id = {
			Type = "NonFruitItem",
			StorageKey = "Key",
			ItemId = 177
		}
	},
	{
		SecurityKey = "b003dc4b9225fc5ab4536c4a6fda5c5a",
		Id = {
			Type = "NonFruitItem",
			StorageKey = "Library Key",
			ItemId = 178
		}
	},
	{
		SecurityKey = "3d36a224d9278269f4a22a5469f98af1",
		Id = {
			Type = "NonFruitItem",
			StorageKey = "Red Key",
			ItemId = 179
		}
	},
	{
		SecurityKey = "f84bc801678e52bbecc769a33d225d7f",
		Id = {
			Type = "NonFruitItem",
			StorageKey = "Water Key",
			ItemId = 180
		}
	},
	{
		SecurityKey = "0c5b1c0b30780da083512f196da03368",
		Id = {
			Type = "Fruit",
			StorageKey = "Spirit-Spirit",
			ItemId = 181
		}
	},
	{
		SecurityKey = "aebf41771cbd9f764fa437b9b6d85c98",
		Id = {
			Type = "NonFruitItem",
			StorageKey = "Holiday Cloak",
			ItemId = 182
		}
	},
	{
		SecurityKey = "3db5a3f64e1ed0d79bfdb1abe6069716",
		Id = {
			Type = "NonFruitItem",
			StorageKey = "Party Hat",
			ItemId = 183
		}
	},
	{
		SecurityKey = "5c0b443fb13c84804e5658227b8717ef",
		Id = {
			Type = "Fruit",
			StorageKey = "Blizzard-Blizzard",
			ItemId = 184
		}
	},
	{
		SecurityKey = "5803b5b8df4ea6b79313c3cd07523344",
		Id = {
			Type = "NonFruitItem",
			StorageKey = "Soul-Soul",
			ItemId = 185
		}
	},
	{
		SecurityKey = "bba85d8a003e7d4de003b1c813e1367b",
		Id = {
			Type = "NonFruitItem",
			StorageKey = "Heart Shades",
			ItemId = 186
		}
	},
	{
		SecurityKey = "d9ec33a12d7eb910667daed0a9e3abdb",
		Id = {
			Type = "NonFruitItem",
			StorageKey = "Draconic Incandescence of the Vermillion Firmament",
			ItemId = 187
		}
	},
	{
		SecurityKey = "ccd333f9d05d034eba044137fea3e116",
		Id = {
			Type = "Fruit",
			StorageKey = "Dough-Dough",
			ItemId = 188
		}
	},
	{
		SecurityKey = "807f1d12bf2e20feb590a6d1011a27f4",
		Id = {
			Type = "NonFruitItem",
			StorageKey = "Cupid's Coat",
			ItemId = 189
		}
	},
	{
		SecurityKey = "b03fc70a50d0042cacc8b7947eb01fd5",
		Id = {
			Type = "NonFruitItem",
			StorageKey = "Dark Blade",
			ItemId = 190
		}
	},
	{
		SecurityKey = "1ce8b9d99cba6d97350eb9d72004063f",
		Id = {
			Type = "Fruit",
			StorageKey = "Mammoth-Mammoth",
			ItemId = 191
		}
	},
	{
		SecurityKey = "909fd7f7fe0f7f410abd89c410b3535c",
		Id = {
			Type = "NonFruitItem",
			StorageKey = "TestTool",
			ItemId = 192
		}
	},
	{
		SecurityKey = "73925b9b614a618f9272cfe8197f31e0",
		Id = {
			Type = "Fruit",
			StorageKey = "Sound-Sound",
			ItemId = 193
		}
	},
	{
		SecurityKey = "cfe6e23a942422851abd18a7ecbd6690",
		Id = {
			Type = "NonFruitItem",
			StorageKey = "Shark Anchor",
			ItemId = 194
		}
	},
	{
		SecurityKey = "657ce028433fd0d27cf352856d4cfde8",
		Id = {
			Type = "NonFruitItem",
			StorageKey = "Slingshot",
			ItemId = 195
		}
	},
	{
		SecurityKey = "66a67c9c534e03efd4f830d744311b76",
		Id = {
			Type = "NonFruitItem",
			StorageKey = "Leviathan Crown",
			ItemId = 196
		}
	},
	{
		SecurityKey = "2ed55e77616b742643859b6cfbb24694",
		Id = {
			Type = "NonFruitItem",
			StorageKey = "Terror Jaw",
			ItemId = 197
		}
	},
	{
		SecurityKey = "65486b25a84a7fa014a927f58ae3868e",
		Id = {
			Type = "NonFruitItem",
			StorageKey = "Shark Tooth Necklace",
			ItemId = 198
		}
	},
	{
		SecurityKey = "8bc565c4891b6e7ca930550a1b9d39cb",
		Id = {
			Type = "NonFruitItem",
			StorageKey = "Leviathan Shield",
			ItemId = 199
		}
	},
	{
		SecurityKey = "7881d2153662f237f053fad06adba76e",
		Id = {
			Type = "NonFruitItem",
			StorageKey = "Fox Lamp",
			ItemId = 200
		}
	},
	{
		SecurityKey = "27dbf3d61a2189a3f1d5e91e28a3d983",
		Id = {
			Type = "NonFruitItem",
			StorageKey = "Dragon Mantle",
			ItemId = 201
		}
	},
	{
		SecurityKey = "195b10a5115b5649c9bbbb26b8796f16",
		Id = {
			Type = "NonFruitItem",
			StorageKey = "Kitsune Mask",
			ItemId = 202
		}
	},
	{
		SecurityKey = "c3ea1707252ba8f09fb7175e7a9e11db",
		Id = {
			Type = "NonFruitItem",
			StorageKey = "Kitsune Ribbon",
			ItemId = 203
		}
	},
	{
		SecurityKey = "944159d972d26675a2fb081ac88e5210",
		Id = {
			Type = "Fruit",
			StorageKey = "T-Rex-T-Rex",
			ItemId = 204
		}
	},
	{
		SecurityKey = "4d4d2629ac5152c9e173e4df1577c244",
		Id = {
			Type = "NonFruitItem",
			StorageKey = "Divine Art",
			ItemId = 205
		}
	},
	{
		SecurityKey = "4428a60c89c1e681ebe34ded5f110d24",
		Id = {
			Type = "NonFruitItem",
			StorageKey = "Primordial Reign",
			ItemId = 206
		}
	},
	{
		SecurityKey = "ed8a448ce4fa48b54a07be91f3a0e57c",
		Id = {
			Type = "NonFruitItem",
			StorageKey = "Dragonheart",
			ItemId = 207
		}
	},
	{
		SecurityKey = "ff8c0c9cf6728634a9e0f242a0f02717",
		Id = {
			Type = "Fruit",
			StorageKey = "Diamond-Diamond",
			ItemId = 208
		}
	},
	{
		SecurityKey = "cea58f0568a161fd92fc92f9cd5981a4",
		Id = {
			Type = "NonFruitItem",
			StorageKey = "Dojo Belt (Black)",
			ItemId = 209
		}
	},
	{
		SecurityKey = "df1de08a509364f687e6f7756ccfb370",
		Id = {
			Type = "NonFruitItem",
			StorageKey = "Dojo Belt (Red)",
			ItemId = 210
		}
	},
	{
		SecurityKey = "985c6559ae422a5e95a13167e5e36521",
		Id = {
			Type = "NonFruitItem",
			StorageKey = "Dojo Belt (Blue)",
			ItemId = 211
		}
	},
	{
		SecurityKey = "1ce60fa82cf7c65e0bcb3903779e8fd7",
		Id = {
			Type = "NonFruitItem",
			StorageKey = "Dojo Belt (Green)",
			ItemId = 212
		}
	},
	{
		SecurityKey = "e7a4eea24c9f40dcee72c50d233d97d5",
		Id = {
			Type = "NonFruitItem",
			StorageKey = "Dojo Belt (Orange)",
			ItemId = 213
		}
	},
	{
		SecurityKey = "3dc30ac24168342c7f658134717447ba",
		Id = {
			Type = "NonFruitItem",
			StorageKey = "Dojo Belt (Yellow)",
			ItemId = 214
		}
	},
	{
		SecurityKey = "0d6ad683f795a6da15b59790ba1f8940",
		Id = {
			Type = "NonFruitItem",
			StorageKey = "Dojo Belt (White)",
			ItemId = 215
		}
	},
	{
		SecurityKey = "4b7d55a77a3857faa2527a6ed67bdc1d",
		Id = {
			Type = "NonFruitItem",
			StorageKey = "Dojo Belt (Purple)",
			ItemId = 216
		}
	},
	{
		SecurityKey = "ab690156bc96fc6e3dad369b701607f6",
		Id = {
			Type = "NonFruitItem",
			StorageKey = "Uzoth's Cloak",
			ItemId = 217
		}
	},
	{
		SecurityKey = "365e288ae1cb0cf49fc06c5b710312cc",
		Id = {
			Type = "NonFruitItem",
			StorageKey = "Dino Hood",
			ItemId = 218
		}
	},
	{
		SecurityKey = "f85b5d48ffedf0ccc20c749cc01421c5",
		Id = {
			Type = "NonFruitItem",
			StorageKey = "T-Rex Skull",
			ItemId = 219
		}
	},
	{
		SecurityKey = "8f870e8d1c5026b7786f7e09a8a884af",
		Id = {
			Type = "Fruit",
			StorageKey = "Gas-Gas",
			ItemId = 220
		}
	},
	{
		SecurityKey = "2e7302c0bf073d7b0cf8af0d8b427f17",
		Id = {
			Type = "Fruit",
			StorageKey = "Kitsune-Kitsune",
			ItemId = 221
		}
	},
	{
		SecurityKey = "15e5681f24583b5235fa7b52c9cf5619",
		Id = {
			Type = "NonFruitItem",
			StorageKey = "Dragon-Dragon",
			ItemId = 222
		}
	},
	{
		SecurityKey = "e5a432b2f966161ea49020c538651f57",
		Id = {
			Type = "NonFruitItem",
			StorageKey = "Dragon Egg",
			ItemId = 223
		}
	},
	{
		SecurityKey = "00004946252008d53e4806f74bfd00d3",
		Id = {
			Type = "NonFruitItem",
			StorageKey = "Dragonstorm",
			ItemId = 224
		}
	},
	{
		SecurityKey = "7120b8c4516bacd4147e806b2ec22d10",
		Id = {
			Type = "NonFruitItem",
			StorageKey = "Wyvern Helmet",
			ItemId = 225
		}
	},
	{
		SecurityKey = "92f1a3b93c3cc822ff5fe650484620b7",
		Id = {
			Type = "NonFruitItem",
			StorageKey = "Admin Holiday Gift",
			ItemId = 226
		}
	},
	{
		SecurityKey = "533c076cf4c10a19ea064237dcbb445b",
		Id = {
			Type = "NonFruitItem",
			StorageKey = "Legendary Holiday Gift",
			ItemId = 227
		}
	},
	{
		SecurityKey = "e89e7e2fe9aff7ec70873e4f2e09a7e0",
		Id = {
			Type = "NonFruitItem",
			StorageKey = "Rare Holiday Gift",
			ItemId = 228
		}
	},
	{
		SecurityKey = "4b319b1ce78337137d7619cf4bf43564",
		Id = {
			Type = "Fruit",
			StorageKey = "Yeti-Yeti",
			ItemId = 229
		}
	},
	{
		SecurityKey = "3c0ad0bdcf67764a5bddaeb1fa6102c2",
		Id = {
			Type = "NonFruitItem",
			StorageKey = "Holiday Gift",
			ItemId = 230
		}
	},
	{
		SecurityKey = "7519bdc4aa5a05b3832bc1d5cf0f77e2",
		Id = {
			Type = "NonFruitItem",
			StorageKey = "Mythical Holiday Gift",
			ItemId = 231
		}
	},
	{
		SecurityKey = "1d7531ff04f909694f7c76de9c4b748d",
		Id = {
			Type = "NonFruitItem",
			StorageKey = "Uncommon Holiday Gift",
			ItemId = 232
		}
	},
	{
		SecurityKey = "8ea76493c9a8ef1fa356bfdef8e3408a",
		Id = {
			Type = "Gamepass",
			StorageKey = "Fruit Notifier",
			ItemId = 233
		}
	},
	{
		SecurityKey = "b24dc8f7cc9ec8d25ec3f3c0dbba0c77",
		Id = {
			Type = "Gamepass",
			StorageKey = "2x Mastery",
			ItemId = 234
		}
	},
	{
		SecurityKey = "50f6e7ec1756b19eb9ae78efb41301a8",
		Id = {
			Type = "SpecialProduct",
			StorageKey = "+1 Fruit Storage",
			ItemId = 235
		}
	},
	{
		SecurityKey = "d821cb4f1d4704d42784c808cbdd264b",
		Id = {
			Type = "SpecialProduct",
			StorageKey = "Discounted Permanent Dragon",
			ItemId = 236
		}
	},
	{
		SecurityKey = "06d195880ba52233d8bff4bbaaf5f1a2",
		Id = {
			Type = "SpecialProduct",
			StorageKey = "Respawn Bosses",
			ItemId = 237
		}
	},
	{
		SecurityKey = "8de457d7d781b89cc6773bca8a41584d",
		Id = {
			Type = "NonFruitItem",
			StorageKey = "Legendary Scroll",
			ItemId = 238
		}
	},
	{
		SecurityKey = "6496a0c40a9b88feaa342da1263dc50b",
		Id = {
			Type = "NonFruitItem",
			StorageKey = "Mythical Scroll",
			ItemId = 239
		}
	},
	{
		SecurityKey = "48dcb66e461e583b4f7903dadfa8d390",
		Id = {
			Type = "SpecialProduct",
			StorageKey = "Dragon Token (Tradable)",
			ItemId = 240
		}
	},
	{
		SecurityKey = "d1780e7e927b24945b0eabbf11d34589",
		Id = {
			Type = "SpecialProduct",
			StorageKey = "Refund Points",
			ItemId = 241
		}
	},
	{
		SecurityKey = "94a301e0d19315646cf382d21c9faabe",
		Id = {
			Type = "Gamepass",
			StorageKey = "2x Money",
			ItemId = 242
		}
	},
	{
		SecurityKey = "8bcd351dcae61e8fa3a8cf4ab966e6ff",
		Id = {
			Type = "SpecialProduct",
			StorageKey = "Change Race",
			ItemId = 243
		}
	},
	{
		SecurityKey = "82ecce32672558d4ee71440ef7afcd6d",
		Id = {
			Type = "Gamepass",
			StorageKey = "2x Boss Drops",
			ItemId = 244
		}
	},
	{
		SecurityKey = "036b25b155d6f359bed570d5da13bad8",
		Id = {
			Type = "Gamepass",
			StorageKey = "Fast Boats",
			ItemId = 245
		}
	},
	{
		SecurityKey = "c645bb36d402707657bec4ea13359903",
		Id = {
			Type = "FruitBox",
			StorageKey = "UncommonBoxS2",
			ItemId = 246
		}
	},
	{
		SecurityKey = "edfb38263f442bd8f7db88600b46c8c3",
		Id = {
			Type = "FruitBox",
			StorageKey = "RareBoxS2",
			ItemId = 247
		}
	},
	{
		SecurityKey = "0ccdb4d204929c58bdc4e94006776540",
		Id = {
			Type = "FruitBox",
			StorageKey = "Fruit Box",
			ItemId = 248
		}
	},
	{
		SecurityKey = "781956824d1e919fef0b783516fc3d96",
		Id = {
			Type = "FruitBox",
			StorageKey = "MythicalBoxS2",
			ItemId = 249
		}
	},
	{
		SecurityKey = "d47e31b73040fa246a18201f618053ab",
		Id = {
			Type = "FruitBox",
			StorageKey = "Super Fruit Box",
			ItemId = 250
		}
	},
	{
		SecurityKey = "e0ec66e88f4afaf10ca18c7307496522",
		Id = {
			Type = "FruitBox",
			StorageKey = "PremiumBoxS2",
			ItemId = 251
		}
	},
	{
		SecurityKey = "84fe33ac31f2176516d6e343f169b93e",
		Id = {
			Type = "FruitBox",
			StorageKey = "MysteryBoxS2",
			ItemId = 252
		}
	},
	{
		SecurityKey = "75bb822b35bc6852806118cd26e7e2ff",
		Id = {
			Type = "FruitBox",
			StorageKey = "LegendaryBoxS2",
			ItemId = 253
		}
	},
	{
		SecurityKey = "e6ac7f7c69e2cc64fd11f3778221d14b",
		Id = {
			Type = "Fruit",
			StorageKey = "Dragon-Dragon",
			ItemId = 254
		}
	},
	{
		SecurityKey = "2148d333a9f5f4e495e2c77de5f5bc36",
		Id = {
			Type = "Gamepass",
			StorageKey = "Dark Blade",
			ItemId = 255
		}
	},
	{
		SecurityKey = "965a628f70a50e519a4c1828410731ab",
		Id = {
			Type = "FruitSkin",
			StorageKey = "WSTDSKINemerald",
			ItemId = 256
		}
	},
	{
		SecurityKey = "b31f5fa0918ded81899fbbbe1408abba",
		Id = {
			Type = "FruitSkin",
			StorageKey = "WSTDSKINyellow",
			ItemId = 257
		}
	},
	{
		SecurityKey = "270b357963cab0f20760799271859965",
		Id = {
			Type = "FruitSkin",
			StorageKey = "WSTDSKINvioletnight",
			ItemId = 258
		}
	},
	{
		SecurityKey = "69d88940119c69f42d1e9a31f07ef356",
		Id = {
			Type = "AuraSkin",
			StorageKey = "Blue Jeans",
			ItemId = 259
		}
	},
	{
		SecurityKey = "91bdc073cab1d0a52d0b66b6bf77393f",
		Id = {
			Type = "AuraSkin",
			StorageKey = "Orange Soda",
			ItemId = 260
		}
	},
	{
		SecurityKey = "626b59e2eb70dba3595bbfa83a500659",
		Id = {
			Type = "FruitSkin",
			StorageKey = "WSTDSKINfrostbite",
			ItemId = 261
		}
	},
	{
		SecurityKey = "211b18e0fd7d8f260f613ab583e25981",
		Id = {
			Type = "AuraSkin",
			StorageKey = "Fiery Rose",
			ItemId = 262
		}
	},
	{
		SecurityKey = "88ecbd2ff5654daa3d624cf2f0e736c7",
		Id = {
			Type = "FruitSkin",
			StorageKey = "ESTDSKINblack",
			ItemId = 263
		}
	},
	{
		SecurityKey = "1eddf7b3f2eb9a78c2d5c56bf9d41c09",
		Id = {
			Type = "FruitSkin",
			StorageKey = "ESTDSKINember",
			ItemId = 264
		}
	},
	{
		SecurityKey = "03c5899fcbec88c8070415c241d668a1",
		Id = {
			Type = "AuraSkin",
			StorageKey = "Plump Purple",
			ItemId = 265
		}
	},
	{
		SecurityKey = "a74c2551eab169bc69f7d1c55897ff3d",
		Id = {
			Type = "AuraSkin",
			StorageKey = "Kitsune",
			ItemId = 266
		}
	},
	{
		SecurityKey = "a44efa777c1b5a8e0b09cd7bdac73b5c",
		Id = {
			Type = "FruitSkin",
			StorageKey = "ESTDSKINyellow",
			ItemId = 267
		}
	},
	{
		SecurityKey = "0d068f6b8e08e144fd1d9101b53e2986",
		Id = {
			Type = "FruitSkin",
			StorageKey = "WSTDSKINphoenixsky",
			ItemId = 268
		}
	},
	{
		SecurityKey = "45df763bff488c6a7c955bb7b17b3ade",
		Id = {
			Type = "FruitSkin",
			StorageKey = "WSTDSKINblue",
			ItemId = 269
		}
	},
	{
		SecurityKey = "99eb05dfb5ad0a359a482f8e7a4788f5",
		Id = {
			Type = "AuraSkin",
			StorageKey = "Heat Wave",
			ItemId = 270
		}
	},
	{
		SecurityKey = "8ae9de350d40e8a608e43a541851c88c",
		Id = {
			Type = "FruitSkin",
			StorageKey = "WSTDSKINeclipse",
			ItemId = 271
		}
	},
	{
		SecurityKey = "5bb59898ee3da7361ca21c45a712491a",
		Id = {
			Type = "FruitSkin",
			StorageKey = "ESTDSKINgreen",
			ItemId = 272
		}
	},
	{
		SecurityKey = "b7361b0a2085e5a2aaf264b9ee6d50ad",
		Id = {
			Type = "FruitSkin",
			StorageKey = "ESTDSKINbloodmoon",
			ItemId = 273
		}
	},
	{
		SecurityKey = "5c90d95857c684898714ad83bf6a7a52",
		Id = {
			Type = "FruitSkin",
			StorageKey = "ESTDSKINphoenixsky",
			ItemId = 274
		}
	},
	{
		SecurityKey = "70d8e39d56f9b892307acc687259b5ef",
		Id = {
			Type = "AuraSkin",
			StorageKey = "Bright Yellow",
			ItemId = 275
		}
	},
	{
		SecurityKey = "276095c40823126e5f8993efcdb07dac",
		Id = {
			Type = "AuraSkin",
			StorageKey = "Yellow Sunshine",
			ItemId = 276
		}
	},
	{
		SecurityKey = "04fbd4bafc587e40e32fff479179de08",
		Id = {
			Type = "AuraSkin",
			StorageKey = "Snow White",
			ItemId = 277
		}
	},
	{
		SecurityKey = "1d63c6bae5a4796ebbf38609b8369d44",
		Id = {
			Type = "FruitSkin",
			StorageKey = "WSTDSKINblack",
			ItemId = 278
		}
	},
	{
		SecurityKey = "470e866b0bc852aa5c1e3098e1430854",
		Id = {
			Type = "AuraSkin",
			StorageKey = "Dragon",
			ItemId = 279
		}
	},
	{
		SecurityKey = "098640acda5b0b4e2c653da033f24666",
		Id = {
			Type = "AuraSkin",
			StorageKey = "Green Lizard",
			ItemId = 280
		}
	},
	{
		SecurityKey = "412071fa971219360c8cfbbd097ecdbe",
		Id = {
			Type = "FruitSkin",
			StorageKey = "ESTDSKINeclipse",
			ItemId = 281
		}
	},
	{
		SecurityKey = "a9bb0adf7e146a7e49c66138a3eda5b7",
		Id = {
			Type = "AuraSkin",
			StorageKey = "Aquamarine",
			ItemId = 282
		}
	},
	{
		SecurityKey = "33cf9e411916065688e05aab9da2b1e9",
		Id = {
			Type = "FruitSkin",
			StorageKey = "ESTDSKINblue",
			ItemId = 283
		}
	},
	{
		SecurityKey = "dad2eb33dd1966351dd427ea23b728ed",
		Id = {
			Type = "AuraSkin",
			StorageKey = "Light Pink",
			ItemId = 284
		}
	},
	{
		SecurityKey = "f320c815227c2bdf596f447ded1b8a16",
		Id = {
			Type = "AuraSkin",
			StorageKey = "Rainbow Saviour",
			ItemId = 285
		}
	},
	{
		SecurityKey = "f9c37084aab3ac6c8076eb00d7bba082",
		Id = {
			Type = "FruitSkin",
			StorageKey = "WSTDSKINbloodmoon",
			ItemId = 286
		}
	},
	{
		SecurityKey = "4ff8e0a785102ec5f9e11025ddbea4d2",
		Id = {
			Type = "AuraSkin",
			StorageKey = "Pure Red",
			ItemId = 287
		}
	},
	{
		SecurityKey = "16c858cf0e7dc1e61296dcfc967de446",
		Id = {
			Type = "AuraSkin",
			StorageKey = "Absolute Zero",
			ItemId = 288
		}
	},
	{
		SecurityKey = "f04d5a2d87e74133db81a05a70b221f5",
		Id = {
			Type = "FruitSkin",
			StorageKey = "WSTDSKINgreen",
			ItemId = 289
		}
	},
	{
		SecurityKey = "7bf074170cd501cea616991b2b7f3e14",
		Id = {
			Type = "FruitSkin",
			StorageKey = "ESTDSKINfrostbite",
			ItemId = 290
		}
	},
	{
		SecurityKey = "2d89cb31f3514ec23a7c2c27fb9ec8fe",
		Id = {
			Type = "FruitSkin",
			StorageKey = "ESTDSKINpurple",
			ItemId = 291
		}
	},
	{
		SecurityKey = "1599dac698f732c0a97b55a13dfe099b",
		Id = {
			Type = "AuraSkin",
			StorageKey = "Winter Sky",
			ItemId = 292
		}
	},
	{
		SecurityKey = "37cfcef921309697b9fa5215262e4ff2",
		Id = {
			Type = "FruitSkin",
			StorageKey = "WSTDSKINpurple",
			ItemId = 293
		}
	},
	{
		SecurityKey = "e34827164c5470291ffb75fcf75581f3",
		Id = {
			Type = "FruitSkin",
			StorageKey = "WSTDSKINred",
			ItemId = 294
		}
	},
	{
		SecurityKey = "d84ce4d714d8b3fa23a659f6d7c2addc",
		Id = {
			Type = "FruitSkin",
			StorageKey = "WSTDSKINorange",
			ItemId = 295
		}
	},
	{
		SecurityKey = "88636f80d15c384a490c44c74b96295e",
		Id = {
			Type = "AuraSkin",
			StorageKey = "Slimy Green",
			ItemId = 296
		}
	},
	{
		SecurityKey = "9e925c2e6abde10f839f14c6057cdb70",
		Id = {
			Type = "FruitSkin",
			StorageKey = "ESTDSKINorange",
			ItemId = 297
		}
	},
	{
		SecurityKey = "075a53c65236aa179d1f17fc5791e5e9",
		Id = {
			Type = "FruitSkin",
			StorageKey = "WSTDSKINember",
			ItemId = 298
		}
	},
	{
		SecurityKey = "adf1327f9ebd47f8a9fe47738ba7521a",
		Id = {
			Type = "FruitSkin",
			StorageKey = "ESTDSKINvioletnight",
			ItemId = 299
		}
	},
	{
		SecurityKey = "eb0254a01b31ab667133b07919a682e9",
		Id = {
			Type = "FruitSkin",
			StorageKey = "ESTDSKINemerald",
			ItemId = 300
		}
	},
	{
		SecurityKey = "9da6f8dc476fdfcb8d5133ba99bd08e9",
		Id = {
			Type = "FruitSkin",
			StorageKey = "ESTDSKINred",
			ItemId = 301
		}
	},
	{
		SecurityKey = "2cc23876c7c2dea2d448db5c733db16c",
		Id = {
			Type = "FruitSkin",
			StorageKey = "PhoenixSkyChromaticDragon",
			ItemId = 302
		}
	},
	{
		SecurityKey = "f7fb162ebe7a685996680bed4b24d6d2",
		Id = {
			Type = "FruitSkin",
			StorageKey = "EclipseChromaticDragon",
			ItemId = 303
		}
	},
	{
		SecurityKey = "4775786e9a6559aa78dba554ba3bcfe6",
		Id = {
			Type = "FruitSkin",
			StorageKey = "VioletNightChromaticDragon",
			ItemId = 304
		}
	},
	{
		SecurityKey = "7ca412132129967185b1f6e26e021e42",
		Id = {
			Type = "FruitSkin",
			StorageKey = "EmberChromaticDragon",
			ItemId = 305
		}
	},
	{
		SecurityKey = "4cb869ae00bf34422fd2ec4e1a2409e6",
		Id = {
			Type = "FruitSkin",
			StorageKey = "BloodmoonChromaticDragon",
			ItemId = 306
		}
	},
	{
		SecurityKey = "8ea8eb6f1bbc8ab530b21f5d7da0d14e",
		Id = {
			Type = "CurrencyBag",
			StorageKey = "2.1K Fragments",
			ItemId = 307
		}
	},
	{
		SecurityKey = "faec086d5dfd397676930f3f4c71ae54",
		Id = {
			Type = "CurrencyBag",
			StorageKey = "135K Money",
			ItemId = 308
		}
	},
	{
		SecurityKey = "1a3d1f2c3663fcebaf618f25d06b9523",
		Id = {
			Type = "CurrencyBag",
			StorageKey = "10K Fragments",
			ItemId = 309
		}
	},
	{
		SecurityKey = "39d6dea14e3f6a13e3b298bdf4e0cb22",
		Id = {
			Type = "CurrencyBag",
			StorageKey = "4.5K Fragments",
			ItemId = 310
		}
	},
	{
		SecurityKey = "45483c7d48adb0a28fd0d0ad9f303c59",
		Id = {
			Type = "CurrencyBag",
			StorageKey = "10K Money",
			ItemId = 311
		}
	},
	{
		SecurityKey = "5255b783ff2c578797f7e50e19f53017",
		Id = {
			Type = "CurrencyBag",
			StorageKey = "810K Money",
			ItemId = 312
		}
	},
	{
		SecurityKey = "e54ed794c9add246179805d5933956b8",
		Id = {
			Type = "CurrencyBag",
			StorageKey = "1.5M Money",
			ItemId = 313
		}
	},
	{
		SecurityKey = "0d1225aa97c3e5e29ab9275fbab5e560",
		Id = {
			Type = "CurrencyBag",
			StorageKey = "300K Money",
			ItemId = 314
		}
	},
	{
		SecurityKey = "9a9545a40c364e5e7210793140c566fb",
		Id = {
			Type = "CurrencyBag",
			StorageKey = "500 Fragments",
			ItemId = 315
		}
	},
	{
		SecurityKey = "d4ac44d70c751aaf9dd9f023977c2a39",
		Id = {
			Type = "CurrencyBag",
			StorageKey = "30K Money",
			ItemId = 316
		}
	},
	{
		SecurityKey = "48a2a0c8e1ba14fe3b149bce666823e5",
		Id = {
			Type = "CurrencyBag",
			StorageKey = "1.8M Money",
			ItemId = 317
		}
	},
	{
		SecurityKey = "d09d6d413b03fa3a2e487e25466aea63",
		Id = {
			Type = "CurrencyBag",
			StorageKey = "50K Money",
			ItemId = 318
		}
	},
	{
		SecurityKey = "150dff07bbeb0a725b4bb1c06029575d",
		Id = {
			Type = "CurrencyBag",
			StorageKey = "150K Money",
			ItemId = 319
		}
	},
	{
		SecurityKey = "179bd2fb4c91a1ff644d3cde9916b202",
		Id = {
			Type = "CurrencyBag",
			StorageKey = "16K Fragments",
			ItemId = 320
		}
	},
	{
		SecurityKey = "7ad1ca7bbffe6b3bcae233134548a040",
		Id = {
			Type = "CurrencyBag",
			StorageKey = "600K Money",
			ItemId = 321
		}
	},
	{
		SecurityKey = "9c3559c02ff2a1adbdaf8cc90b0dd2bd",
		Id = {
			Type = "CurrencyBag",
			StorageKey = "900K Money",
			ItemId = 322
		}
	},
	{
		SecurityKey = "12ae55c00f54e637badf054eed654b54",
		Id = {
			Type = "CurrencyBag",
			StorageKey = "500K Money",
			ItemId = 323
		}
	},
	{
		SecurityKey = "0e6feb51bb52c3b4850ad5e67bb6e88f",
		Id = {
			Type = "CurrencyBag",
			StorageKey = "305K Money",
			ItemId = 324
		}
	},
	{
		SecurityKey = "1eb172d880060559ea14187c3d803624",
		Id = {
			Type = "CurrencyBag",
			StorageKey = "60K Money",
			ItemId = 325
		}
	},
	{
		SecurityKey = "b2ebe1ff4ba989121c843e543413311f",
		Id = {
			Type = "CurrencyBag",
			StorageKey = "405K Money",
			ItemId = 326
		}
	},
	{
		SecurityKey = "3632045e776395c0ac0338a169d8edb8",
		Id = {
			Type = "CurrencyBag",
			StorageKey = "3M Money",
			ItemId = 327
		}
	},
	{
		SecurityKey = "b5fe19b278b25a6129eba1120989b64a",
		Id = {
			Type = "SkinBundle",
			StorageKey = "ESTDSKINphoenixsky",
			ItemId = 328
		}
	},
	{
		SecurityKey = "b9d8a4f6891eecc26552096cf3ae3a96",
		Id = {
			Type = "SkinBundle",
			StorageKey = "WSTDSKINvioletnight",
			ItemId = 329
		}
	},
	{
		SecurityKey = "be471ea92d07fbc825bb9a078071ffb8",
		Id = {
			Type = "SkinBundle",
			StorageKey = "WSTDSKINphoenixsky",
			ItemId = 330
		}
	},
	{
		SecurityKey = "a7d6b9f9f19e3097c281cfeeb54485d3",
		Id = {
			Type = "SkinBundle",
			StorageKey = "WSTDSKINeclipse",
			ItemId = 331
		}
	},
	{
		SecurityKey = "5bf9704001a08f5406940530f5ff1c6d",
		Id = {
			Type = "SkinBundle",
			StorageKey = "ESTDSKINember",
			ItemId = 332
		}
	},
	{
		SecurityKey = "ebb65cd66ecc05b24435d393a7617faa",
		Id = {
			Type = "SkinBundle",
			StorageKey = "ESTDSKINeclipse",
			ItemId = 333
		}
	},
	{
		SecurityKey = "3137bfc7cdebdef0d831d35dd1e71908",
		Id = {
			Type = "SkinBundle",
			StorageKey = "WSTDSKINember",
			ItemId = 334
		}
	},
	{
		SecurityKey = "7d582e68d9c44da819b39483847bab11",
		Id = {
			Type = "SkinBundle",
			StorageKey = "ESTDSKINvioletnight",
			ItemId = 335
		}
	},
	{
		SecurityKey = "a655600695014b621a27bb5906985d9d",
		Id = {
			Type = "SkinBundle",
			StorageKey = "WSTDSKINbloodmoon",
			ItemId = 336
		}
	},
	{
		SecurityKey = "438a702e974d72a0f7f68beb03174cbe",
		Id = {
			Type = "SkinBundle",
			StorageKey = "ESTDSKINbloodmoon",
			ItemId = 337
		}
	},
	{
		SecurityKey = "8ca8d0e78bb841051f87daccfb635881",
		Id = {
			Type = "SaleBundle",
			StorageKey = "WinterCombo24",
			ItemId = 338
		}
	},
	{
		SecurityKey = "17def6e1e86895465447899d7fa1d789",
		Id = {
			Type = "SaleBundle",
			StorageKey = "ULTIMATEBUNDLE24",
			ItemId = 339
		}
	},
	{
		SecurityKey = "c0479c12bdab11ad741398dd5fd520d7",
		Id = {
			Type = "SaleBundle",
			StorageKey = "HolidayEssentials24",
			ItemId = 340
		}
	},
	{
		SecurityKey = "da6d98421da8e0274cca83e9a84e0749",
		Id = {
			Type = "StorageIdOnly",
			StorageKey = "Permanent Ghost-Ghost",
			ItemId = 341
		}
	},
	{
		SecurityKey = "2c7716d2ac6d0190be556ee6880faaba",
		Id = {
			Type = "StorageIdOnly",
			StorageKey = "Permanent Love-Love",
			ItemId = 342
		}
	},
	{
		SecurityKey = "10cc5a3b8f8d89cd499f6ea92be48bfe",
		Id = {
			Type = "StorageIdOnly",
			StorageKey = "Permanent Yeti-Yeti",
			ItemId = 343
		}
	},
	{
		SecurityKey = "22baee768bbe549b28a583a317686e1b",
		Id = {
			Type = "StorageIdOnly",
			StorageKey = "Permanent Bomb-Bomb",
			ItemId = 344
		}
	},
	{
		SecurityKey = "90b07549c73bc0a62df35d69143d1563",
		Id = {
			Type = "StorageIdOnly",
			StorageKey = "Permanent Light-Light",
			ItemId = 345
		}
	},
	{
		SecurityKey = "b8f7a0e05c1cba9e57636b4bf884bbfe",
		Id = {
			Type = "StorageIdOnly",
			StorageKey = "Permanent Sound-Sound",
			ItemId = 346
		}
	},
	{
		SecurityKey = "8cb5760e468381a838c50d528cfd47aa",
		Id = {
			Type = "StorageIdOnly",
			StorageKey = "Permanent Flame-Flame",
			ItemId = 347
		}
	},
	{
		SecurityKey = "829d53af00866a1ebf12c1b4fdea565c",
		Id = {
			Type = "StorageIdOnly",
			StorageKey = "Permanent Venom-Venom",
			ItemId = 348
		}
	},
	{
		SecurityKey = "df37736b9fbdf467c0f6ec6a8283b66f",
		Id = {
			Type = "StorageIdOnly",
			StorageKey = "Permanent Magma-Magma",
			ItemId = 349
		}
	},
	{
		SecurityKey = "87ecf3ee37bc4ce911583189b0c792cb",
		Id = {
			Type = "StorageIdOnly",
			StorageKey = "Permanent Blade-Blade",
			ItemId = 350
		}
	},
	{
		SecurityKey = "0d2d26ce989362fb614258be5dca35be",
		Id = {
			Type = "StorageIdOnly",
			StorageKey = "Permanent Diamond-Diamond",
			ItemId = 351
		}
	},
	{
		SecurityKey = "9b2f506d585edc823954feaba1db59f9",
		Id = {
			Type = "StorageIdOnly",
			StorageKey = "Permanent Blizzard-Blizzard",
			ItemId = 352
		}
	},
	{
		SecurityKey = "2d2cfc83607869f2f35263ba6df291b6",
		Id = {
			Type = "StorageIdOnly",
			StorageKey = "Permanent Sand-Sand",
			ItemId = 353
		}
	},
	{
		SecurityKey = "06e2190c646e2c7cf68d53af96ed4fef",
		Id = {
			Type = "StorageIdOnly",
			StorageKey = "Permanent Mammoth-Mammoth",
			ItemId = 354
		}
	},
	{
		SecurityKey = "4fe09f2dfae1c05f602a171e7352fc60",
		Id = {
			Type = "StorageIdOnly",
			StorageKey = "Permanent Dragon (East)-Dragon (East)",
			ItemId = 355
		}
	},
	{
		SecurityKey = "2d7d64f23bc4f1a8240ee853a2384336",
		Id = {
			Type = "StorageIdOnly",
			StorageKey = "Permanent Dragon (West)-Dragon (West)",
			ItemId = 356
		}
	},
	{
		SecurityKey = "ebd794577b5afa9aab72a0d1b089be94",
		Id = {
			Type = "StorageIdOnly",
			StorageKey = "Permanent Rocket-Rocket",
			ItemId = 357
		}
	},
	{
		SecurityKey = "326e72475d95c0209e80887800f9ab34",
		Id = {
			Type = "StorageIdOnly",
			StorageKey = "Permanent Control-Control",
			ItemId = 358
		}
	},
	{
		SecurityKey = "f3c016e8b5a289b27161faa1137d0590",
		Id = {
			Type = "StorageIdOnly",
			StorageKey = "Permanent Ice-Ice",
			ItemId = 359
		}
	},
	{
		SecurityKey = "db1693fbb7fc51db8464290508663420",
		Id = {
			Type = "StorageIdOnly",
			StorageKey = "Permanent Spin-Spin",
			ItemId = 360
		}
	},
	{
		SecurityKey = "0f915c37bfe09ef4e89ad000f7530d57",
		Id = {
			Type = "StorageIdOnly",
			StorageKey = "Permanent Pain-Pain",
			ItemId = 361
		}
	},
	{
		SecurityKey = "9e8811fac55acf91afac8b4f3e2c978e",
		Id = {
			Type = "StorageIdOnly",
			StorageKey = "Permanent Rumble-Rumble",
			ItemId = 362
		}
	},
	{
		SecurityKey = "ac2a37a5afecd9e5db8b6f1fb4c4d83c",
		Id = {
			Type = "StorageIdOnly",
			StorageKey = "Permanent Gas-Gas",
			ItemId = 363
		}
	},
	{
		SecurityKey = "5a8593d52e345d3734d90c0a826b95c3",
		Id = {
			Type = "StorageIdOnly",
			StorageKey = "Permanent Leopard-Leopard",
			ItemId = 364
		}
	},
	{
		SecurityKey = "666d7e5d7c406499a6603bfb3f432bf5",
		Id = {
			Type = "StorageIdOnly",
			StorageKey = "Permanent Gravity-Gravity",
			ItemId = 365
		}
	},
	{
		SecurityKey = "97ed672c04e4c3cd9057931540ee27d8",
		Id = {
			Type = "StorageIdOnly",
			StorageKey = "Permanent Quake-Quake",
			ItemId = 366
		}
	},
	{
		SecurityKey = "72490737b4e8badcdbab6f30a002ba03",
		Id = {
			Type = "StorageIdOnly",
			StorageKey = "Permanent Shadow-Shadow",
			ItemId = 367
		}
	},
	{
		SecurityKey = "7e995a7271902bd21fccbbdfa5b62611",
		Id = {
			Type = "StorageIdOnly",
			StorageKey = "Permanent Portal-Portal",
			ItemId = 368
		}
	},
	{
		SecurityKey = "23bfb2f98037f74a52aa79b4ec6c7328",
		Id = {
			Type = "StorageIdOnly",
			StorageKey = "Permanent Rubber-Rubber",
			ItemId = 369
		}
	},
	{
		SecurityKey = "64f455be3cf005c5a1e3c92c637f93f8",
		Id = {
			Type = "StorageIdOnly",
			StorageKey = "Permanent Phoenix-Phoenix",
			ItemId = 370
		}
	},
	{
		SecurityKey = "91616de2a7eeb9ced4bb7d87bd8c92c1",
		Id = {
			Type = "StorageIdOnly",
			StorageKey = "Permanent Dark-Dark",
			ItemId = 371
		}
	},
	{
		SecurityKey = "ea3ea3688f3fa40062d52cb777a33783",
		Id = {
			Type = "StorageIdOnly",
			StorageKey = "Permanent Buddha-Buddha",
			ItemId = 372
		}
	},
	{
		SecurityKey = "6647223520665a11b04aef29a663741d",
		Id = {
			Type = "StorageIdOnly",
			StorageKey = "Permanent Dough-Dough",
			ItemId = 373
		}
	},
	{
		SecurityKey = "657aed41d9a409b6e16f3f02dcc362ea",
		Id = {
			Type = "StorageIdOnly",
			StorageKey = "Permanent Kitsune-Kitsune",
			ItemId = 374
		}
	},
	{
		SecurityKey = "dc6f2314b3b7681960480552e25fcb4a",
		Id = {
			Type = "StorageIdOnly",
			StorageKey = "Permanent T-Rex-T-Rex",
			ItemId = 375
		}
	},
	{
		SecurityKey = "a1ae3d210c368253cbace81ad0e754fe",
		Id = {
			Type = "StorageIdOnly",
			StorageKey = "Permanent Barrier-Barrier",
			ItemId = 376
		}
	},
	{
		SecurityKey = "714120c0481e4d261ad2fb7f54a7fd99",
		Id = {
			Type = "StorageIdOnly",
			StorageKey = "Permanent Falcon-Falcon",
			ItemId = 377
		}
	},
	{
		SecurityKey = "cf5b8705e4d3d3a29de86be39c89d66b",
		Id = {
			Type = "StorageIdOnly",
			StorageKey = "Permanent Spike-Spike",
			ItemId = 378
		}
	},
	{
		SecurityKey = "5268030af90cf58c24ae7fd83bc519f3",
		Id = {
			Type = "StorageIdOnly",
			StorageKey = "Permanent Smoke-Smoke",
			ItemId = 379
		}
	},
	{
		SecurityKey = "ab351ed995f8257cd1e1c5f7622cc5e9",
		Id = {
			Type = "StorageIdOnly",
			StorageKey = "Permanent Spider-Spider",
			ItemId = 380
		}
	},
	{
		SecurityKey = "a8e9e455d3813455e19d09923fbff432",
		Id = {
			Type = "StorageIdOnly",
			StorageKey = "Permanent Spring-Spring",
			ItemId = 381
		}
	},
	{
		SecurityKey = "003c8cf2d192f7ca4b9231459cd95796",
		Id = {
			Type = "StorageIdOnly",
			StorageKey = "Permanent Dragon (Classic)-Dragon (Classic)",
			ItemId = 382
		}
	},
	{
		SecurityKey = "838228c8c9dc2ab447abfd706077d4b8",
		Id = {
			Type = "StorageIdOnly",
			StorageKey = "Permanent Spirit-Spirit",
			ItemId = 383
		}
	},
	{
		SecurityKey = "f505e767e002614964bcd090c5ed0aba",
		Id = {
			Type = "StorageIdOnly",
			StorageKey = "Physical Rocket Fruit",
			ItemId = 384
		}
	},
	{
		SecurityKey = "db3787971441d1095c4d3b2918e20084",
		Id = {
			Type = "SkinBundle",
			StorageKey = "EclipseChromaticDragon",
			ItemId = 385
		}
	},
	{
		SecurityKey = "e4c831b22ee01e7fc841a8fb78b00f23",
		Id = {
			Type = "SkinBundle",
			StorageKey = "PhoenixSkyChromaticDragon",
			ItemId = 386
		}
	},
	{
		SecurityKey = "d47ac5c9a7028eb9ff2d4c5102778ad3",
		Id = {
			Type = "SkinBundle",
			StorageKey = "EmberChromaticDragon",
			ItemId = 387
		}
	},
	{
		SecurityKey = "e7fd327d73c5d4045cef6d6725c51510",
		Id = {
			Type = "SkinBundle",
			StorageKey = "VioletNightChromaticDragon",
			ItemId = 388
		}
	},
	{
		SecurityKey = "4ce88d5f99aaa9c6e46b94b676078de7",
		Id = {
			Type = "SkinBundle",
			StorageKey = "BloodmoonChromaticDragon",
			ItemId = 389
		}
	},
	{
		SecurityKey = "5e0d735520bfbdfaacf1b5d77077736b",
		Id = {
			Type = "StorageIdOnly",
			StorageKey = "2x EXP (1 hour)",
			ItemId = 390
		}
	},
	{
		SecurityKey = "bf86af7806770a8c856103c089217a9f",
		Id = {
			Type = "StorageIdOnly",
			StorageKey = "2x EXP (12 hours)",
			ItemId = 391
		}
	},
	{
		SecurityKey = "0de5be26219521c296b65fa71d36bfb7",
		Id = {
			Type = "StorageIdOnly",
			StorageKey = "2x EXP (6 hours)",
			ItemId = 392
		}
	},
	{
		SecurityKey = "2cc739221a17a5971e2cf7d4921fa92d",
		Id = {
			Type = "StorageIdOnly",
			StorageKey = "2x EXP (24 hours)",
			ItemId = 393
		}
	},
	{
		SecurityKey = "6e2adccd5241a6ab3a1550a6afc084cc",
		Id = {
			Type = "StorageIdOnly",
			StorageKey = "2x EXP (15 mins.)",
			ItemId = 394
		}
	},
	{
		SecurityKey = "7b2b98d24fc438d4f7c17664e4674afc",
		Id = {
			Type = "StorageIdOnly",
			StorageKey = "5x Legendary Scrolls",
			ItemId = 395
		}
	},
	{
		SecurityKey = "10a648444dd4ffe0bbac353beb3f75b1",
		Id = {
			Type = "StorageIdOnly",
			StorageKey = "Mythical Scroll",
			ItemId = 396
		}
	},
	{
		SecurityKey = "51f9cc7ab5d989625441b0ba29d8b5ad",
		Id = {
			Type = "StorageIdOnly",
			StorageKey = "3x Mythical Scrolls",
			ItemId = 397
		}
	},
	{
		SecurityKey = "66db31b220da1af27b3c89f9602b0b3e",
		Id = {
			Type = "StorageIdOnly",
			StorageKey = "Legendary Scroll",
			ItemId = 398
		}
	},
	{
		SecurityKey = "7cabc2a61e775dfaece19e8c77fd3649",
		Id = {
			Type = "StorageIdOnly",
			StorageKey = "Permanent Dragon-Dragon",
			ItemId = 399
		}
	},
	{
		SecurityKey = "2596a3a14719975545e2c8ed572ce03a",
		Id = {
			Type = "Fruit",
			StorageKey = "Eagle-Eagle",
			ItemId = 400
		}
	},
	{
		SecurityKey = "120213481f4937be70ce4d3e0a7dc3c3",
		Id = {
			Type = "StorageIdOnly",
			StorageKey = "Permanent Eagle-Eagle",
			ItemId = 401
		}
	},
	{
		SecurityKey = "f3898e1872d482628ea309a1d2b3f163",
		Id = {
			Type = "Fruit",
			StorageKey = "Creation-Creation",
			ItemId = 402
		}
	},
	{
		SecurityKey = "8a1869ead206b89e5f32b25595d7c161",
		Id = {
			Type = "StorageIdOnly",
			StorageKey = "Permanent Creation-Creation",
			ItemId = 403
		}
	},
	{
		SecurityKey = "03d74693cf2136fe20e2987ca49522db",
		Id = {
			Type = "FruitSkin",
			StorageKey = "FALCSKINparrot",
			ItemId = 404
		}
	},
	{
		SecurityKey = "7d6b87bc64ad95ca02b1b0a784d319db",
		Id = {
			Type = "FruitSkin",
			StorageKey = "FALCSKINgoldmoss",
			ItemId = 405
		}
	},
	{
		SecurityKey = "24e9e856fd485458217189ed13913afd",
		Id = {
			Type = "FruitSkin",
			StorageKey = "FALCSKINeagle",
			ItemId = 406
		}
	},
	{
		SecurityKey = "3614e7c11110c4254bde836b43111af7",
		Id = {
			Type = "FruitSkin",
			StorageKey = "FALCSKINvelvet",
			ItemId = 407
		}
	},
	{
		SecurityKey = "96958f6409f31b5de31d7aa14c9e29cc",
		Id = {
			Type = "FruitSkin",
			StorageKey = "FALCSKINfalcon",
			ItemId = 408
		}
	},
	{
		SecurityKey = "ba22258cf34bb0fde4a4e05c7075cca7",
		Id = {
			Type = "FruitSkin",
			StorageKey = "FALCSKINocreamsicle",
			ItemId = 409
		}
	},
	{
		SecurityKey = "92a419f0c07541f8c04a630f8fa1381a",
		Id = {
			Type = "FruitSkin",
			StorageKey = "FALCSKINbluesky",
			ItemId = 410
		}
	},
	{
		SecurityKey = "6db19b5aa259eca4f4a1546e8d27f072",
		Id = {
			Type = "Fish",
			StorageKey = "Candyfish",
			ItemId = 411
		}
	},
	{
		SecurityKey = "5139c6ff841f5792a565e12ff9de765d",
		Id = {
			Type = "Fish",
			StorageKey = "Catfish",
			ItemId = 412
		}
	},
	{
		SecurityKey = "098ed2db44b86b55e35135b510ebc484",
		Id = {
			Type = "Fish",
			StorageKey = "Angelfish",
			ItemId = 413
		}
	},
	{
		SecurityKey = "66e64d81f08698081583a3c4e0708b22",
		Id = {
			Type = "Fish",
			StorageKey = "Carp",
			ItemId = 414
		}
	},
	{
		SecurityKey = "6bb2f6f82654ecd7f9496b85c543a5b7",
		Id = {
			Type = "Fish",
			StorageKey = "Flatfish",
			ItemId = 415
		}
	},
	{
		SecurityKey = "1b8283872956618a8b614f30a7401f44",
		Id = {
			Type = "Fish",
			StorageKey = "Redfin",
			ItemId = 416
		}
	},
	{
		SecurityKey = "baafcafc8ffe3cb374ae624dd762a3ec",
		Id = {
			Type = "Fish",
			StorageKey = "Tidegill",
			ItemId = 417
		}
	},
	{
		SecurityKey = "2ffecf829e28c317094d7d4ec5a6d44d",
		Id = {
			Type = "Fish",
			StorageKey = "Saltwater Salmon",
			ItemId = 418
		}
	},
	{
		SecurityKey = "89eac1f57d9f15e696c276ff8bf00601",
		Id = {
			Type = "Fish",
			StorageKey = "Goldfish",
			ItemId = 419
		}
	},
	{
		SecurityKey = "03c77154d6332bd8faeed0c1463a9d24",
		Id = {
			Type = "Fish",
			StorageKey = "Ghostfish",
			ItemId = 420
		}
	},
	{
		SecurityKey = "7b0c433bddbdc6bbfcc58560f45a9a33",
		Id = {
			Type = "Fish",
			StorageKey = "Sea Sturgeon",
			ItemId = 421
		}
	},
	{
		SecurityKey = "6dc646d0e3f1ad9b689da037311bb771",
		Id = {
			Type = "Fish",
			StorageKey = "Grouper",
			ItemId = 422
		}
	},
	{
		SecurityKey = "49f0a329d06293485a062a59b3f2779e",
		Id = {
			Type = "Fish",
			StorageKey = "Clownfish",
			ItemId = 423
		}
	},
	{
		SecurityKey = "2abfe54d780105b750bca1dba79c5bf9",
		Id = {
			Type = "Fish",
			StorageKey = "Mossback",
			ItemId = 424
		}
	},
	{
		SecurityKey = "93429b4a0ae31f9b7338351c8f9a8009",
		Id = {
			Type = "Fish",
			StorageKey = "Amber Trout",
			ItemId = 425
		}
	},
	{
		SecurityKey = "ac7431f0534f394762c723d12321691a",
		Id = {
			Type = "Fish",
			StorageKey = "Frostjaw",
			ItemId = 426
		}
	},
	{
		SecurityKey = "11b9a13fcbaab28bcb36cde5fc383f66",
		Id = {
			Type = "Fish",
			StorageKey = "Gravelhead Shark",
			ItemId = 427
		}
	},
	{
		SecurityKey = "874e0c645e0918dcd80af52f6fc4b2dd",
		Id = {
			Type = "Fish",
			StorageKey = "Bullfish",
			ItemId = 428
		}
	},
	{
		SecurityKey = "75a6426545dfbe590684206c3f38786e",
		Id = {
			Type = "Fish",
			StorageKey = "Parrotfish",
			ItemId = 429
		}
	},
	{
		SecurityKey = "920aa08872349285cb292ccd460b6fb5",
		Id = {
			Type = "Fish",
			StorageKey = "Leafy Trout",
			ItemId = 430
		}
	},
	{
		SecurityKey = "6f24cebf221624ec731c5c9fa534b2e1",
		Id = {
			Type = "Fish",
			StorageKey = "Azure Marlin",
			ItemId = 431
		}
	},
	{
		SecurityKey = "5130970711ca4fe732ec2f7449262428",
		Id = {
			Type = "Fish",
			StorageKey = "Terrorfish",
			ItemId = 432
		}
	},
	{
		SecurityKey = "5be0d9703a0f8c26b85810824aa62dab",
		Id = {
			Type = "Fish",
			StorageKey = "Deepglow Oarfish",
			ItemId = 433
		}
	},
	{
		SecurityKey = "10f346aad52e04eee936a5da14d9bfae",
		Id = {
			Type = "Fish",
			StorageKey = "Sand Bass",
			ItemId = 434
		}
	},
	{
		SecurityKey = "19091611467605355dc5abf46ae12464",
		Id = {
			Type = "Fish",
			StorageKey = "Angler",
			ItemId = 435
		}
	},
	{
		SecurityKey = "10d9ca6dba8da2de676b57123e5fd02e",
		Id = {
			Type = "Fish",
			StorageKey = "Molten Trout",
			ItemId = 436
		}
	},
	{
		SecurityKey = "e86001db73416e91c69920c5a8a068f0",
		Id = {
			Type = "Fish",
			StorageKey = "Gliderfish",
			ItemId = 437
		}
	},
	{
		SecurityKey = "91baf8f3f49c8a15c85a30dbb4796859",
		Id = {
			Type = "Fish",
			StorageKey = "Rock Dweller",
			ItemId = 438
		}
	},
	{
		SecurityKey = "5a3808788fb8a89357a3dbe1d8c39649",
		Id = {
			Type = "Fish",
			StorageKey = "Levi",
			ItemId = 439
		}
	},
	{
		SecurityKey = "36efec1db4888e97ede6aa0e87be6bdc",
		Id = {
			Type = "Fish",
			StorageKey = "Pufferfish",
			ItemId = 440
		}
	},
	{
		SecurityKey = "925cff43ca0f438669b94b933179c476",
		Id = {
			Type = "Fish",
			StorageKey = "Barracuda",
			ItemId = 441
		}
	},
	{
		SecurityKey = "3d144af5694f272a8d592370e65cd90b",
		Id = {
			Type = "Fish",
			StorageKey = "Kelp Bass",
			ItemId = 442
		}
	},
	{
		SecurityKey = "ef5a4385536bfd050ad894ded3837653",
		Id = {
			Type = "Fish",
			StorageKey = "Tuna",
			ItemId = 443
		}
	},
	{
		SecurityKey = "4ac1d5aae24adffcce6678b070191cec",
		Id = {
			Type = "Fish",
			StorageKey = "Crab",
			ItemId = 444
		}
	},
	{
		SecurityKey = "d97f6a08051299cb48d7ed7627044582",
		Id = {
			Type = "Fish",
			StorageKey = "Seahorse",
			ItemId = 445
		}
	},
	{
		SecurityKey = "4578759b0bc9d91c94291004e4f5ca43",
		Id = {
			Type = "Fish",
			StorageKey = "Colossal Shrimp",
			ItemId = 446
		}
	},
	{
		SecurityKey = "74a65dd9f50cb397734c2921bd39118a",
		Id = {
			Type = "Fish",
			StorageKey = "Dragon Koi",
			ItemId = 447
		}
	},
	{
		SecurityKey = "2aeabcb8fa29e67daa142facf01cf07c",
		Id = {
			Type = "Fruit",
			StorageKey = "Lightning-Lightning",
			ItemId = 448
		}
	},
	{
		SecurityKey = "a5480fa2527b94fa66c6d938a2ab737c",
		Id = {
			Type = "StorageIdOnly",
			StorageKey = "Permanent Lightning-Lightning",
			ItemId = 449
		}
	},
	{
		SecurityKey = "285c08e672064b0ab2b54573bb545c97",
		Id = {
			Type = "FruitWithSkin",
			StorageKey = "Yellow Lightning",
			ItemId = 450
		}
	},
	{
		SecurityKey = "0e3bc36180f0681ec2daf814fd5416b7",
		Id = {
			Type = "FruitSkin",
			StorageKey = "LIGHTNINGSKINyellow",
			ItemId = 451
		}
	},
	{
		SecurityKey = "e017c58592bb6e1f7dcbcd2dc1a344ed",
		Id = {
			Type = "FruitSkin",
			StorageKey = "DIAMONDSKINblue",
			ItemId = 452
		}
	},
	{
		SecurityKey = "608ca47bf37b46ab1d344a7ecd9210d5",
		Id = {
			Type = "FruitSkin",
			StorageKey = "PORTALSKINpink",
			ItemId = 453
		}
	},
	{
		SecurityKey = "779f4dabce5e1629477e1389a752a141",
		Id = {
			Type = "FruitWithSkin",
			StorageKey = "Green Diamond",
			ItemId = 454
		}
	},
	{
		SecurityKey = "3be6b0f0fe4ecf80e43c35fb75ed03d4",
		Id = {
			Type = "FruitSkin",
			StorageKey = "DIAMONDSKINred",
			ItemId = 455
		}
	},
	{
		SecurityKey = "7034527cc23b2b8db01f9b080f06a70d",
		Id = {
			Type = "FruitSkin",
			StorageKey = "DIAMONDSKINgreen",
			ItemId = 456
		}
	},
	{
		SecurityKey = "dbba2c839bde6e150522c97c32fac5e9",
		Id = {
			Type = "FruitSkin",
			StorageKey = "PORTALSKINorange",
			ItemId = 457
		}
	},
	{
		SecurityKey = "5bfa70d1506d83acd19f6c139871470d",
		Id = {
			Type = "FruitWithSkin",
			StorageKey = "Pink Portal",
			ItemId = 458
		}
	},
	{
		SecurityKey = "a814f8cf0f5fa13646cf559024a171d0",
		Id = {
			Type = "FruitWithSkin",
			StorageKey = "Red Diamond",
			ItemId = 459
		}
	},
	{
		SecurityKey = "11c3a6a3ec0a0c89f4a00dc2719ad224",
		Id = {
			Type = "FruitWithSkin",
			StorageKey = "Purple Lightning",
			ItemId = 460
		}
	},
	{
		SecurityKey = "1cb0ba9b242b2dca1c6c0daf88950fed",
		Id = {
			Type = "FruitSkin",
			StorageKey = "LIGHTNINGSKINblue",
			ItemId = 461
		}
	},
	{
		SecurityKey = "32de9e07bc3698a4fd488aa8f6d86a97",
		Id = {
			Type = "FruitWithSkin",
			StorageKey = "Green Lightning",
			ItemId = 462
		}
	},
	{
		SecurityKey = "7f55cb4e2208534c5e1db3f92cd9321d",
		Id = {
			Type = "FruitWithSkin",
			StorageKey = "Orange Portal",
			ItemId = 463
		}
	},
	{
		SecurityKey = "204d82a41ed838aa48251966086f257a",
		Id = {
			Type = "FruitSkin",
			StorageKey = "LIGHTNINGSKINpurple",
			ItemId = 464
		}
	},
	{
		SecurityKey = "420973a7ceeef301eba5fb352ff7772d",
		Id = {
			Type = "FruitSkin",
			StorageKey = "LIGHTNINGSKINgreen",
			ItemId = 465
		}
	},
	{
		SecurityKey = "d777386c71518480b7dddd351fd298d2",
		Id = {
			Type = "FruitSkin",
			StorageKey = "PORTALSKINblue",
			ItemId = 466
		}
	},
	{
		SecurityKey = "65003dced2d40f8e13506e0d95b07e6c",
		Id = {
			Type = "NonFruitItem",
			StorageKey = "SummerWeek1Box",
			ItemId = 467
		}
	},
	{
		SecurityKey = "21a3a53928981c90726bc332096178c3",
		Id = {
			Type = "FruitWithSkin",
			StorageKey = "Ruby Diamond",
			ItemId = 468
		}
	},
	{
		SecurityKey = "765e08b0c4c90f4c14cfcc7aeeffc1b2",
		Id = {
			Type = "FruitWithSkin",
			StorageKey = "Topaz Diamond",
			ItemId = 469
		}
	},
	{
		SecurityKey = "58f32fe7a88ae0e18d91b95a4de5ac29",
		Id = {
			Type = "FruitWithSkin",
			StorageKey = "Rose Quartz Diamond",
			ItemId = 470
		}
	},
	{
		SecurityKey = "9d63c292eaf29b2603bbfe34e25213f0",
		Id = {
			Type = "FruitWithSkin",
			StorageKey = "Emerald Diamond",
			ItemId = 471
		}
	},
	{
		SecurityKey = "b9407c610344952ca02050c5bdc2dac1",
		Id = {
			Type = "FruitSkin",
			StorageKey = "DIAMONDSKINpoudretteite",
			ItemId = 472
		}
	},
	{
		SecurityKey = "5689eb3f6ea6534341808d329ee30106",
		Id = {
			Type = "FruitSkin",
			StorageKey = "DIAMONDSKINtopaz",
			ItemId = 473
		}
	},
	{
		SecurityKey = "c20b793ca669849364cd87067a28b778",
		Id = {
			Type = "FruitSkin",
			StorageKey = "PAINSKINdeepblue",
			ItemId = 474
		}
	},
	{
		SecurityKey = "4b4a77a2a08109a7e697f01911732027",
		Id = {
			Type = "FruitSkin",
			StorageKey = "PAINSKINyellow",
			ItemId = 475
		}
	},
	{
		SecurityKey = "c2cab135131c7660e0fecd549eab1ffe",
		Id = {
			Type = "FruitSkin",
			StorageKey = "PAINSKINpinkblue",
			ItemId = 476
		}
	},
	{
		SecurityKey = "deadfeda6328d99192e96abfbf401d00",
		Id = {
			Type = "FruitWithSkin",
			StorageKey = "Super Ultra Pain",
			ItemId = 477
		}
	},
	{
		SecurityKey = "243fd74d0c83a7660c86020fb96eafb0",
		Id = {
			Type = "FruitWithSkin",
			StorageKey = "Cotton Candy Pain",
			ItemId = 478
		}
	},
	{
		SecurityKey = "f4279a63b3ee9e45b7060470e71ea25e",
		Id = {
			Type = "FruitWithSkin",
			StorageKey = "Sadness Pain",
			ItemId = 479
		}
	},
	{
		SecurityKey = "4a0b2ae15ed4cb030fd6bc2225043691",
		Id = {
			Type = "FruitSkin",
			StorageKey = "PAINSKINdefault",
			ItemId = 480
		}
	},
	{
		SecurityKey = "e1b1810eb231a9bb20b2101b86611401",
		Id = {
			Type = "NonFruitItem",
			StorageKey = "Headband (Red)",
			ItemId = 481
		}
	},
	{
		SecurityKey = "738227b4f71e59a1c31a1c130a0a0ec7",
		Id = {
			Type = "NonFruitItem",
			StorageKey = "Headband (Black)",
			ItemId = 482
		}
	},
	{
		SecurityKey = "2de8ce07c442a3a86aa77e6e3e652fec",
		Id = {
			Type = "NonFruitItem",
			StorageKey = "Headband (Green)",
			ItemId = 483
		}
	},
	{
		SecurityKey = "2fbafa36aa1d2d1ac4c251ec2fdb0fb8",
		Id = {
			Type = "NonFruitItem",
			StorageKey = "Headband (Purple)",
			ItemId = 484
		}
	},
	{
		SecurityKey = "072484147af18162a017573486600579",
		Id = {
			Type = "NonFruitItem",
			StorageKey = "Headband (Orange)",
			ItemId = 485
		}
	},
	{
		SecurityKey = "419b390d0af0e59c96988418e0000480",
		Id = {
			Type = "NonFruitItem",
			StorageKey = "Headband (Yellow)",
			ItemId = 486
		}
	},
	{
		SecurityKey = "137372c1fee74496f2e5a99ae7ee3431",
		Id = {
			Type = "NonFruitItem",
			StorageKey = "Headband (White)",
			ItemId = 487
		}
	},
	{
		SecurityKey = "9132d1089b1ff444295b13a61c468f53",
		Id = {
			Type = "NonFruitItem",
			StorageKey = "Headband (Blue)",
			ItemId = 488
		}
	},
	{
		SecurityKey = "8d232282d601ff5e36e45b0f007b236c",
		Id = {
			Type = "FruitSkin",
			StorageKey = "PAINSKINorange",
			ItemId = 489
		}
	},
	{
		SecurityKey = "c3f616de6ff0ec9e1c1029d2a8776722",
		Id = {
			Type = "FruitSkin",
			StorageKey = "PAINSKINred",
			ItemId = 490
		}
	},
	{
		SecurityKey = "7f2d4f4ef319dac84966ecc1c01a493e",
		Id = {
			Type = "FruitWithSkin",
			StorageKey = "Torment Pain",
			ItemId = 491
		}
	},
	{
		SecurityKey = "17b92d25c30b14163e916381b2d83fd9",
		Id = {
			Type = "FruitWithSkin",
			StorageKey = "Frustration Pain",
			ItemId = 492
		}
	},
	{
		SecurityKey = "62813ce4e96e61b0bd22b5d8a2c94b66",
		Id = {
			Type = "FruitSkin",
			StorageKey = "PAINSKINgreen",
			ItemId = 493
		}
	},
	{
		SecurityKey = "f8d1214a837315a0f0c36277e2d613ac",
		Id = {
			Type = "FruitWithSkin",
			StorageKey = "Envy Pain",
			ItemId = 494
		}
	},
	{
		SecurityKey = "1b8a8380fbcd3b9464cbf8a25f6db261",
		Id = {
			Type = "FruitWithSkin",
			StorageKey = "Requiem Eagle",
			ItemId = 495
		}
	},
	{
		SecurityKey = "3b987a2bb4c8ae0d9fc478d5d0146b3b",
		Id = {
			Type = "FruitWithSkin",
			StorageKey = "Glacier Eagle",
			ItemId = 496
		}
	},
	{
		SecurityKey = "f81c5f76d3520a58a4a012dc0a09cea8",
		Id = {
			Type = "FruitSkin",
			StorageKey = "FALCSKINmatrix",
			ItemId = 497
		}
	},
	{
		SecurityKey = "36338549802706720a8723ac3857683f",
		Id = {
			Type = "FruitWithSkin",
			StorageKey = "Celestial Pain",
			ItemId = 498
		}
	},
	{
		SecurityKey = "445d9e93a89a0e906a4c8ea7c859e1ef",
		Id = {
			Type = "FruitSkin",
			StorageKey = "FALCSKINglacier",
			ItemId = 499
		}
	},
	{
		SecurityKey = "b1f605aa1ff25dd8461fcbb158642b1d",
		Id = {
			Type = "FruitSkin",
			StorageKey = "PAINSKINcelestial",
			ItemId = 500
		}
	},
	{
		SecurityKey = "a53066ca7a280045c556c8593203b4c3",
		Id = {
			Type = "FruitSkin",
			StorageKey = "FALCSKINrequiem",
			ItemId = 501
		}
	},
	{
		SecurityKey = "76861b65dc5196ab74b951f9a99599c5",
		Id = {
			Type = "FruitWithSkin",
			StorageKey = "Matrix Eagle",
			ItemId = 502
		}
	},
	{
		SecurityKey = "b25b6e9f66a51075d641eefbb8eef1af",
		Id = {
			Type = "NonFruitItem",
			StorageKey = "Celestial Helmet",
			ItemId = 503
		}
	},
	{
		SecurityKey = "e86487fc9e40e770837697b0004aad95",
		Id = {
			Type = "NonFruitItem",
			StorageKey = "Divine Cloak",
			ItemId = 504
		}
	},
	{
		SecurityKey = "363e50688cde4bb20800be8c2d70ace0",
		Id = {
			Type = "FruitWithSkin",
			StorageKey = "Dry Ice Bomb",
			ItemId = 505
		}
	},
	{
		SecurityKey = "72a1a000965d9f83513f75f52fc49aa5",
		Id = {
			Type = "FruitSkin",
			StorageKey = "BOMBSKINnuclear",
			ItemId = 506
		}
	},
	{
		SecurityKey = "d6390aeef2403792833f1d2bab41b1fa",
		Id = {
			Type = "FruitWithSkin",
			StorageKey = "Bloodfire Bomb",
			ItemId = 507
		}
	},
	{
		SecurityKey = "f1e16265449d7eec649a73839df1582a",
		Id = {
			Type = "FruitWithSkin",
			StorageKey = "Nuclear Bomb",
			ItemId = 508
		}
	},
	{
		SecurityKey = "da5853cc0c5ed2b0efa78dd008118bcd",
		Id = {
			Type = "FruitSkin",
			StorageKey = "BOMBSKINdryice",
			ItemId = 509
		}
	},
	{
		SecurityKey = "2a0c3fe0d12b113be32d0c45a3dfc311",
		Id = {
			Type = "FruitSkin",
			StorageKey = "BOMBSKINbloodfire",
			ItemId = 510
		}
	},
	{
		SecurityKey = "1a1198865dffb2fb80806b3750d798b8",
		Id = {
			Type = "FruitWithSkin",
			StorageKey = "Thermite Bomb",
			ItemId = 511
		}
	},
	{
		SecurityKey = "8cb273522df1871eb9bdeef0a2714332",
		Id = {
			Type = "FruitWithSkin",
			StorageKey = "Azura Bomb",
			ItemId = 512
		}
	},
	{
		SecurityKey = "331e1dd860a34a997910305cc72d1a60",
		Id = {
			Type = "Fish",
			StorageKey = "Golden Carp",
			ItemId = 513
		}
	},
	{
		SecurityKey = "098adc16ef7cd3e7e835886e6f68553b",
		Id = {
			Type = "Fish",
			StorageKey = "Starfish (Yellow)",
			ItemId = 514
		}
	},
	{
		SecurityKey = "e1042ab6b1abf79e1b37830da10fa9a3",
		Id = {
			Type = "Fish",
			StorageKey = "Swamp Lurker",
			ItemId = 515
		}
	},
	{
		SecurityKey = "27fb024a911f67f2e1d62ff43b1b4616",
		Id = {
			Type = "Fish",
			StorageKey = "Hermit Crab",
			ItemId = 516
		}
	},
	{
		SecurityKey = "f69f38b41076aff38b9fe49a48cc9420",
		Id = {
			Type = "Fish",
			StorageKey = "Starfish (Purple)",
			ItemId = 517
		}
	},
	{
		SecurityKey = "bc077e20503e555c0fbd7c8ce2b38fe9",
		Id = {
			Type = "Fish",
			StorageKey = "Jellyfish",
			ItemId = 518
		}
	},
	{
		SecurityKey = "3742bb10e4a1c48ab1d6080b57927082",
		Id = {
			Type = "Fish",
			StorageKey = "Turtle",
			ItemId = 519
		}
	},
	{
		SecurityKey = "6a5845d6551d5a9526a8a3f056171691",
		Id = {
			Type = "Fish",
			StorageKey = "Deepsea Squid",
			ItemId = 520
		}
	},
	{
		SecurityKey = "9ed59e955401e9b75791255e0adec2e9",
		Id = {
			Type = "Fish",
			StorageKey = "Starfish (Blue)",
			ItemId = 521
		}
	},
	{
		SecurityKey = "fc29c0eae5174e00b18d1d655f87b364",
		Id = {
			Type = "Fish",
			StorageKey = "Starfish (Green)",
			ItemId = 522
		}
	},
	{
		SecurityKey = "cd6edfe77eafd4f4fb10cb8d4f46627c",
		Id = {
			Type = "Fish",
			StorageKey = "Starfish (Pink)",
			ItemId = 523
		}
	},
	{
		SecurityKey = "bd07273e49bbc2529ab5f595e7371523",
		Id = {
			Type = "Fish",
			StorageKey = "Starfish (Red)",
			ItemId = 524
		}
	},
	{
		SecurityKey = "3fe4ca7eba6903d0fc5308829205d42e",
		Id = {
			Type = "Fish",
			StorageKey = "Lumo Whale",
			ItemId = 525
		}
	},
	{
		SecurityKey = "d1d0994a926a0f25cbcc56351e09a1bc",
		Id = {
			Type = "Fish",
			StorageKey = "Deepsea Octopus",
			ItemId = 526
		}
	},
	{
		SecurityKey = "16575f40657e4fbb901a77aaef9479c1",
		Id = {
			Type = "FruitSkin",
			StorageKey = "BOMBSKINdefault",
			ItemId = 527
		}
	},
	{
		SecurityKey = "1b5f343da9cbc99a383ad64162a003bf",
		Id = {
			Type = "FruitSkin",
			StorageKey = "BOMBSKINthermite",
			ItemId = 528
		}
	},
	{
		SecurityKey = "ca9efd6f429242c94a6775ff2356d855",
		Id = {
			Type = "FruitSkin",
			StorageKey = "BOMBSKINazura",
			ItemId = 529
		}
	},
	{
		SecurityKey = "581f9fd7b633d4bfbeca03376be31f03",
		Id = {
			Type = "NonFruitItem",
			StorageKey = "Fishing Trophy",
			ItemId = 530
		}
	},
	{
		SecurityKey = "17d7301e026e80be9efa1baab8b54499",
		Id = {
			Type = "FruitBox",
			StorageKey = "GachaData",
			ItemId = 531
		}
	},
	{
		SecurityKey = "55f131418f973db27885a99e4cee1164",
		Id = {
			Type = "FruitBox",
			StorageKey = "SummerWeek2Gacha",
			ItemId = 532
		}
	},
	{
		SecurityKey = "7f9400154fb3a91cf1977385396cd176",
		Id = {
			Type = "FruitBox",
			StorageKey = "SummerWeek3Gacha",
			ItemId = 533
		}
	},
	{
		SecurityKey = "347c7053e3b35feebf3decea8de192eb",
		Id = {
			Type = "FruitBox",
			StorageKey = "SummerWeek4Gacha",
			ItemId = 534
		}
	},
	{
		SecurityKey = "2ca240a4002c8936d728da217af756a3",
		Id = {
			Type = "FruitBox",
			StorageKey = "SummerWeek5Gacha",
			ItemId = 535
		}
	},
	{
		SecurityKey = "3bad3bbc0f8f4385bc1a97180f563559",
		Id = {
			Type = "FruitSkin",
			StorageKey = "BOMBSKINcelebration",
			ItemId = 536
		}
	},
	{
		SecurityKey = "592b68b5a554c300b5fdeb8a27217d5b",
		Id = {
			Type = "FruitSkin",
			StorageKey = "LIGHTNINGSKINred",
			ItemId = 537
		}
	},
	{
		SecurityKey = "de9aa3e33798e6537025137208903835",
		Id = {
			Type = "FruitSkin",
			StorageKey = "PAINSKINsuperspirit",
			ItemId = 538
		}
	},
	{
		SecurityKey = "ff8c354c98c089380c3c9362f12009e7",
		Id = {
			Type = "FruitWithSkin",
			StorageKey = "Celebration Bomb",
			ItemId = 539
		}
	},
	{
		SecurityKey = "4c8527175726c421f731670be07fb93b",
		Id = {
			Type = "FruitWithSkin",
			StorageKey = "Red Lightning",
			ItemId = 540
		}
	},
	{
		SecurityKey = "c96e3a8f8efea24898b318e1ec6b5dff",
		Id = {
			Type = "FruitWithSkin",
			StorageKey = "Super Spirit Pain",
			ItemId = 541
		}
	},
	{
		SecurityKey = "082e313881fcb1eeedd0cfc071f4db3b",
		Id = {
			Type = "NonFruitItem",
			StorageKey = "Shell (Celestial)",
			ItemId = 542
		}
	},
	{
		SecurityKey = "5d591c19d93b67fd2d93c68411190ff6",
		Id = {
			Type = "NonFruitItem",
			StorageKey = "Fishing Rod",
			ItemId = 543
		}
	},
	{
		SecurityKey = "fc06d2ae4b345de561d48d490fe56024",
		Id = {
			Type = "NonFruitItem",
			StorageKey = "Gold Rod",
			ItemId = 544
		}
	},
	{
		SecurityKey = "bbd93d02442de1afab0a68510fca3a3e",
		Id = {
			Type = "NonFruitItem",
			StorageKey = "Shark Rod",
			ItemId = 545
		}
	},
	{
		SecurityKey = "db4556a00f9d17798f56279f54bd3c23",
		Id = {
			Type = "NonFruitItem",
			StorageKey = "Shell Rod",
			ItemId = 546
		}
	},
	{
		SecurityKey = "f21889cfa3823bdfb699d8aa2fd97d52",
		Id = {
			Type = "NonFruitItem",
			StorageKey = "Treasure Rod",
			ItemId = 547
		}
	},
	{
		SecurityKey = "ce67654e2ac1c6f0813bfbda9be89879",
		Id = {
			Type = "Material",
			StorageKey = "Fish Tail",
			ItemId = 548
		}
	},
	{
		SecurityKey = "9111b6b6f49a6208542cf8183e242e83",
		Id = {
			Type = "Material",
			StorageKey = "Volt Capsule",
			ItemId = 549
		}
	},
	{
		SecurityKey = "877b338b59edc33ea9942c83d08c43a2",
		Id = {
			Type = "Material",
			StorageKey = "Volcanic Magnet",
			ItemId = 550
		}
	},
	{
		SecurityKey = "766049f95ae8f3554753d8a3c5f0e2ca",
		Id = {
			Type = "Material",
			StorageKey = "Mystic Droplet",
			ItemId = 551
		}
	},
	{
		SecurityKey = "cc187ff77b2650f13785f8a017db9136",
		Id = {
			Type = "Material",
			StorageKey = "Electric Wing",
			ItemId = 552
		}
	},
	{
		SecurityKey = "ed0247a6742fc4024e77eca8dd10412b",
		Id = {
			Type = "Material",
			StorageKey = "Oni Token",
			ItemId = 553
		}
	},
	{
		SecurityKey = "fd7fbdace7fd0e76ed23a0b1cc71e898",
		Id = {
			Type = "Material",
			StorageKey = "Yellow Star Berry",
			ItemId = 554
		}
	},
	{
		SecurityKey = "ddf86e73bfa9eece7b610dbfde1798cb",
		Id = {
			Type = "Material",
			StorageKey = "Mirror Fractal",
			ItemId = 555
		}
	},
	{
		SecurityKey = "28efae3e404bd26330d3a2d3dcded186",
		Id = {
			Type = "Material",
			StorageKey = "Wooden Plank",
			ItemId = 556
		}
	},
	{
		SecurityKey = "3a4d64ad7f68cc1b4ac2a20fd16a2823",
		Id = {
			Type = "Material",
			StorageKey = "Red Cherry Berry",
			ItemId = 557
		}
	},
	{
		SecurityKey = "8ceb24f4bc8b31a39c7a70b874479216",
		Id = {
			Type = "Material",
			StorageKey = "Nightmare Catcher",
			ItemId = 558
		}
	},
	{
		SecurityKey = "1152fbcc047695a45455067ec00230a8",
		Id = {
			Type = "Material",
			StorageKey = "Vampire Fang",
			ItemId = 559
		}
	},
	{
		SecurityKey = "e09c1a1cafb389543ff380956fa5c08c",
		Id = {
			Type = "Material",
			StorageKey = "Mini Tusk",
			ItemId = 560
		}
	},
	{
		SecurityKey = "af1b681f45bd2a00dc5c1cf6d3645ca7",
		Id = {
			Type = "Material",
			StorageKey = "Leviathan Scale",
			ItemId = 561
		}
	},
	{
		SecurityKey = "079479822d52cd4faecd78a33d5a4fc3",
		Id = {
			Type = "Material",
			StorageKey = "Purple Jelly Berry",
			ItemId = 562
		}
	},
	{
		SecurityKey = "926d4aae5fdac7fc0484ea0a2caf9c0f",
		Id = {
			Type = "Material",
			StorageKey = "Summer Token",
			ItemId = 563
		}
	},
	{
		SecurityKey = "25dc804330fef3475735fbe9a27750fc",
		Id = {
			Type = "Material",
			StorageKey = "Moonstone",
			ItemId = 564
		}
	},
	{
		SecurityKey = "39e803d3683c0d21f6a2855f840e2881",
		Id = {
			Type = "Material",
			StorageKey = "Dragon Egg",
			ItemId = 565
		}
	},
	{
		SecurityKey = "99e843d9e62ad8adc2aa6780435dd2a2",
		Id = {
			Type = "Material",
			StorageKey = "Scrap Metal",
			ItemId = 566
		}
	},
	{
		SecurityKey = "74c8c93771eb377c1d48e6b533cfb0e2",
		Id = {
			Type = "Material",
			StorageKey = "Angel Wings",
			ItemId = 567
		}
	},
	{
		SecurityKey = "5f52785b4a3e9dfdc2fc203491e294f0",
		Id = {
			Type = "Material",
			StorageKey = "Tetraminos",
			ItemId = 568
		}
	},
	{
		SecurityKey = "06c4d273d7ccc681889a1d035a1c64be",
		Id = {
			Type = "Material",
			StorageKey = "Fire Feather",
			ItemId = 569
		}
	},
	{
		SecurityKey = "62a9f005ca83b38c07ea42735b84f46a",
		Id = {
			Type = "Material",
			StorageKey = "Leviathan Heart",
			ItemId = 570
		}
	},
	{
		SecurityKey = "e4f674c2f31ae4fa6f3f09d4102ffd1e",
		Id = {
			Type = "Material",
			StorageKey = "Ectoplasm",
			ItemId = 571
		}
	},
	{
		SecurityKey = "3b084b25a9b2e4086ab0bfb189a6dba5",
		Id = {
			Type = "Material",
			StorageKey = "Bones",
			ItemId = 572
		}
	},
	{
		SecurityKey = "5a9ef3fec15b09b551bce9befca8e776",
		Id = {
			Type = "Material",
			StorageKey = "Gunpowder",
			ItemId = 573
		}
	},
	{
		SecurityKey = "1e0cef40755694d4ab7e4b620ba176c0",
		Id = {
			Type = "Material",
			StorageKey = "Yeti Fur",
			ItemId = 574
		}
	},
	{
		SecurityKey = "6465eb5412e71a18e92607b327e1e33d",
		Id = {
			Type = "Material",
			StorageKey = "Orange Berry",
			ItemId = 575
		}
	},
	{
		SecurityKey = "ada77a55c2b32fb00381bfab7828bdf5",
		Id = {
			Type = "Material",
			StorageKey = "Pink Pig Berry",
			ItemId = 576
		}
	},
	{
		SecurityKey = "7842be1361db493ce95f73e0cd0cb268",
		Id = {
			Type = "Material",
			StorageKey = "Green Toad Berry",
			ItemId = 577
		}
	},
	{
		SecurityKey = "c974619d26b373c86ee3e805f7985c04",
		Id = {
			Type = "Material",
			StorageKey = "Alucard Fragment",
			ItemId = 578
		}
	},
	{
		SecurityKey = "c90768217d8ec6f77ba04f0538b62853",
		Id = {
			Type = "Material",
			StorageKey = "White Cloud Berry",
			ItemId = 579
		}
	},
	{
		SecurityKey = "dc121ff668b18cc6ec452a5b20c3672b",
		Id = {
			Type = "Material",
			StorageKey = "Celestial Token",
			ItemId = 580
		}
	},
	{
		SecurityKey = "c084052ca8956f33818b17cc0a9daa72",
		Id = {
			Type = "Material",
			StorageKey = "Magma Ore",
			ItemId = 581
		}
	},
	{
		SecurityKey = "0733ad2756b6f4d9055b7e3dec775b36",
		Id = {
			Type = "Material",
			StorageKey = "Terror Eyes",
			ItemId = 582
		}
	},
	{
		SecurityKey = "0fdd449c0ccacc1c48083f8beff0fff1",
		Id = {
			Type = "Material",
			StorageKey = "Fire Flower",
			ItemId = 583
		}
	},
	{
		SecurityKey = "9b36aa7b6359eaa44b72bcaba19db9b6",
		Id = {
			Type = "Material",
			StorageKey = "Dragon Scale",
			ItemId = 584
		}
	},
	{
		SecurityKey = "d546e5bad594ac8a78c8cf8d1390e543",
		Id = {
			Type = "Material",
			StorageKey = "Dinosaur Bones",
			ItemId = 585
		}
	},
	{
		SecurityKey = "79f70b1b5b2f1852d5644d152413fd4d",
		Id = {
			Type = "Material",
			StorageKey = "Meteorite",
			ItemId = 586
		}
	},
	{
		SecurityKey = "8c3b47c96b45619f1032915d856bb2ce",
		Id = {
			Type = "Material",
			StorageKey = "Blaze Ember",
			ItemId = 587
		}
	},
	{
		SecurityKey = "ddac2f61bce260bcf1dc9bb2fa6010ae",
		Id = {
			Type = "Material",
			StorageKey = "Mutant Tooth",
			ItemId = 588
		}
	},
	{
		SecurityKey = "01b64f2dec5d4f1d05e363689db87b43",
		Id = {
			Type = "Material",
			StorageKey = "Shark Tooth",
			ItemId = 589
		}
	},
	{
		SecurityKey = "faa0dfea650f8c99ccfe90e61c19325a",
		Id = {
			Type = "Material",
			StorageKey = "Hearts",
			ItemId = 590
		}
	},
	{
		SecurityKey = "705aca335ff0586f740b417e41f58658",
		Id = {
			Type = "Material",
			StorageKey = "Candy",
			ItemId = 591
		}
	},
	{
		SecurityKey = "51c6105708f091c86f8a424fb28f60a2",
		Id = {
			Type = "Material",
			StorageKey = "Confetti",
			ItemId = 592
		}
	},
	{
		SecurityKey = "565f82c49ea3ea6d7bb2f8cfbd029451",
		Id = {
			Type = "Material",
			StorageKey = "Blue Icicle Berry",
			ItemId = 593
		}
	},
	{
		SecurityKey = "3f8892b3382c51acccb6a8998249ebe9",
		Id = {
			Type = "Material",
			StorageKey = "Leather",
			ItemId = 594
		}
	},
	{
		SecurityKey = "d68c3f3af7ab15a592a32156ce785e40",
		Id = {
			Type = "Material",
			StorageKey = "Azure Ember",
			ItemId = 595
		}
	},
	{
		SecurityKey = "26c09503900cb9ea0b3b8bb9d8d268c9",
		Id = {
			Type = "Material",
			StorageKey = "Monster Magnet",
			ItemId = 596
		}
	},
	{
		SecurityKey = "a2710b7586feb26e301ae0cba6d5f6ba",
		Id = {
			Type = "Material",
			StorageKey = "Fool's Gold",
			ItemId = 597
		}
	},
	{
		SecurityKey = "e720e94bd86d7bb966d7d7abe52b978e",
		Id = {
			Type = "Material",
			StorageKey = "Dark Fragment",
			ItemId = 598
		}
	},
	{
		SecurityKey = "f57904ed17fc6f20901ec1dd3474e1e1",
		Id = {
			Type = "Material",
			StorageKey = "Conjured Cocoa",
			ItemId = 599
		}
	},
	{
		SecurityKey = "f2e9c5aa86ddf7cf56c61e762ce68b93",
		Id = {
			Type = "Material",
			StorageKey = "Radioactive Material",
			ItemId = 600
		}
	},
	{
		SecurityKey = "8a2856c575e65cce1f714980915a3dd8",
		Id = {
			Type = "Material",
			StorageKey = "Demonic Wisp",
			ItemId = 601
		}
	},
	{
		SecurityKey = "6a27f8bba670c5cf66c0ce1cf85af7cc",
		Id = {
			Type = "NonFruitItem",
			StorageKey = "Oni Helmet",
			ItemId = 602
		}
	},
	{
		SecurityKey = "aa1283c7a897f9c6ce9e1dbd9bcbab97",
		Id = {
			Type = "Fruit",
			StorageKey = "Celestial-Celestial",
			ItemId = 603
		}
	},
	{
		SecurityKey = "28c23531ee957962ea47c7135fe88a72",
		Id = {
			Type = "Fruit",
			StorageKey = "Oni-Oni",
			ItemId = 604
		}
	},
	{
		SecurityKey = "a0c2324febfe30e9fcaf39d917d7480e",
		Id = {
			Type = "StorageIdOnly",
			StorageKey = "Permanent Celestial-Celestial",
			ItemId = 605
		}
	},
	{
		SecurityKey = "2310358d1441752ac5856085c656d4b4",
		Id = {
			Type = "StorageIdOnly",
			StorageKey = "Permanent Oni-Oni",
			ItemId = 606
		}
	},
	{
		SecurityKey = "41353a055b26a578247366909b5a7dc2",
		Id = {
			Type = "NonFruitItem",
			StorageKey = "50b Party Hat",
			ItemId = 607
		}
	},
	{
		SecurityKey = "b7811b01be13fde15fdf98a4b0e7ff77",
		Id = {
			Type = "NonFruitItem",
			StorageKey = "Aggro Elixir",
			ItemId = 608
		}
	},
	{
		SecurityKey = "43a87ec5d1748a0e9332a99e6075b617",
		Id = {
			Type = "NonFruitItem",
			StorageKey = "Berserkers Elixir",
			ItemId = 609
		}
	},
	{
		SecurityKey = "6bf476fe79638a48cd1c7588c647f468",
		Id = {
			Type = "NonFruitItem",
			StorageKey = "Exp Boost",
			ItemId = 610
		}
	},
	{
		SecurityKey = "0c10252d07b94039833a8435a2c1e330",
		Id = {
			Type = "NonFruitItem",
			StorageKey = "Feathered Visage",
			ItemId = 611
		}
	},
	{
		SecurityKey = "97ea6d62de7deae094e15d83e9b82d51",
		Id = {
			Type = "NonFruitItem",
			StorageKey = "Fish Kebab",
			ItemId = 612
		}
	},
	{
		SecurityKey = "44a853457d5aa51cd548c975c6c214af",
		Id = {
			Type = "NonFruitItem",
			StorageKey = "Fortune Elixir",
			ItemId = 613
		}
	},
	{
		SecurityKey = "e78796f80a911f9d20157f92ce1afeab",
		Id = {
			Type = "NonFruitItem",
			StorageKey = "Fragments Elixir",
			ItemId = 614
		}
	},
	{
		SecurityKey = "e17f8b0f4ccdd0e8f81ad544bef87444",
		Id = {
			Type = "NonFruitItem",
			StorageKey = "Gate Potion",
			ItemId = 615
		}
	},
	{
		SecurityKey = "15b20619f93c29a11125dcad97354039",
		Id = {
			Type = "NonFruitItem",
			StorageKey = "Invisibility Potion",
			ItemId = 616
		}
	},
	{
		SecurityKey = "b75303dbda59dd49037151835ac98def",
		Id = {
			Type = "NonFruitItem",
			StorageKey = "Lava Potion",
			ItemId = 617
		}
	},
	{
		SecurityKey = "c442f3e7eda645274964e01743accb71",
		Id = {
			Type = "NonFruitItem",
			StorageKey = "Loot Seeker",
			ItemId = 618
		}
	},
	{
		SecurityKey = "83840868b2c90447d18aa9bae6606deb",
		Id = {
			Type = "NonFruitItem",
			StorageKey = "Materials Elixir",
			ItemId = 619
		}
	},
	{
		SecurityKey = "9ecfbe5fb2eda735dcea73f34bb457b6",
		Id = {
			Type = "NonFruitItem",
			StorageKey = "Monk Potion",
			ItemId = 620
		}
	},
	{
		SecurityKey = "af693316bd5753242dcc2a47b44cfb0b",
		Id = {
			Type = "NonFruitItem",
			StorageKey = "Oni Soul",
			ItemId = 621
		}
	},
	{
		SecurityKey = "46ec1474ce9d1ae1878b04657786e419",
		Id = {
			Type = "NonFruitItem",
			StorageKey = "Quest-Grab Elixir",
			ItemId = 622
		}
	},
	{
		SecurityKey = "36580a8def034ea2aecb05510043ae07",
		Id = {
			Type = "NonFruitItem",
			StorageKey = "Sanguine Cloak",
			ItemId = 623
		}
	},
	{
		SecurityKey = "d0163314e1851a3f8f1f763580787a70",
		Id = {
			Type = "NonFruitItem",
			StorageKey = "Water Walking",
			ItemId = 624
		}
	},
	{
		SecurityKey = "dd7f55f6a5fe2b888bba7ddd213f676b",
		Id = {
			Type = "NonFruitItem",
			StorageKey = "Bronze Trophy",
			ItemId = 625
		}
	},
	{
		SecurityKey = "2b8d919ac0c67a87946f8b4bbf1bf079",
		Id = {
			Type = "NonFruitItem",
			StorageKey = "Silver Trophy",
			ItemId = 626
		}
	},
	{
		SecurityKey = "66bd4831cfe8619034dd17e0cbda3476",
		Id = {
			Type = "NonFruitItem",
			StorageKey = "Gold Trophy",
			ItemId = 627
		}
	},
	{
		SecurityKey = "c87684f83ce2647535565810d60412cf",
		Id = {
			Type = "NonFruitItem",
			StorageKey = "Platinum Trophy",
			ItemId = 628
		}
	},
	{
		SecurityKey = "bb8b8c49e02576b7890b9f79c962604f",
		Id = {
			Type = "NonFruitItem",
			StorageKey = "Diamond Trophy",
			ItemId = 629
		}
	},
	{
		SecurityKey = "18c6143aee8a89babfda20d61244d03e",
		Id = {
			Type = "NonFruitItem",
			StorageKey = "Master Trophy",
			ItemId = 630
		}
	},
	{
		SecurityKey = "6711b345493d03bbc7ece151c555f6a6",
		Id = {
			Type = "Title",
			StorageKey = "The Unleashed",
			ItemId = 631
		}
	},
	{
		SecurityKey = "dda2522c57da7e121fdd6eed3f943be1",
		Id = {
			Type = "Title",
			StorageKey = "Unmatched Speed",
			ItemId = 632
		}
	},
	{
		SecurityKey = "4fd4d368d23f4f43976dd3235de74bcb",
		Id = {
			Type = "Title",
			StorageKey = "Sea Monster",
			ItemId = 633
		}
	},
	{
		SecurityKey = "cb7aafe92107478fe6bdf9b91496bf45",
		Id = {
			Type = "Title",
			StorageKey = "Sacred Warrior",
			ItemId = 634
		}
	},
	{
		SecurityKey = "5a45e88d6fa0b6ae44c2cb80951b0ee0",
		Id = {
			Type = "Title",
			StorageKey = "The Ghoul",
			ItemId = 635
		}
	},
	{
		SecurityKey = "987842e278d166d367e0e0b05768eabd",
		Id = {
			Type = "Title",
			StorageKey = "The Cyborg",
			ItemId = 636
		}
	},
	{
		SecurityKey = "d265fb9fad8eabe19137dff8a9b16ce3",
		Id = {
			Type = "Title",
			StorageKey = "Elder Wyrm",
			ItemId = 637
		}
	},
	{
		SecurityKey = "e07d4aace988a871e03f8e68b1798009",
		Id = {
			Type = "Title",
			StorageKey = "Full Power",
			ItemId = 638
		}
	},
	{
		SecurityKey = "f6c70eec710f6a392be2b4790c374fe6",
		Id = {
			Type = "Title",
			StorageKey = "Godspeed",
			ItemId = 639
		}
	},
	{
		SecurityKey = "7d4d99587f2ee15f719943a83cb217ea",
		Id = {
			Type = "Title",
			StorageKey = "Warrior of the Sea",
			ItemId = 640
		}
	},
	{
		SecurityKey = "0809bcf10fc8a50eb5c989fbfb81db11",
		Id = {
			Type = "Title",
			StorageKey = "Perfect Being",
			ItemId = 641
		}
	},
	{
		SecurityKey = "986e047dbacdf1aac64a11d74caad28c",
		Id = {
			Type = "Title",
			StorageKey = "Hell Hound",
			ItemId = 642
		}
	},
	{
		SecurityKey = "a16db52ebc9d8b21bcf6f5bb1a10d5bb",
		Id = {
			Type = "Title",
			StorageKey = "War Machine",
			ItemId = 643
		}
	},
	{
		SecurityKey = "816346b294ac8b0534a9a64670d3b9c5",
		Id = {
			Type = "Title",
			StorageKey = "Berserker",
			ItemId = 644
		}
	},
	{
		SecurityKey = "097a308151321c51391a181d94d2c7fe",
		Id = {
			Type = "Title",
			StorageKey = "Ancient Flame",
			ItemId = 645
		}
	},
	{
		SecurityKey = "747419a3a41b39f31e1cb3e040578c17",
		Id = {
			Type = "Title",
			StorageKey = "Thunderbolt",
			ItemId = 646
		}
	},
	{
		SecurityKey = "e2a82d6e18220de079fa0d8ebd44905c",
		Id = {
			Type = "Title",
			StorageKey = "Leviathan",
			ItemId = 647
		}
	},
	{
		SecurityKey = "e2788c2721da7f09f49034e417855c5b",
		Id = {
			Type = "Title",
			StorageKey = "His Majesty",
			ItemId = 648
		}
	},
	{
		SecurityKey = "f697f7393804c296efe979029da7c6a9",
		Id = {
			Type = "Title",
			StorageKey = "Nightwalker",
			ItemId = 649
		}
	},
	{
		SecurityKey = "34aa38304f4caebba22f2910af73c9f0",
		Id = {
			Type = "Title",
			StorageKey = "Genesis",
			ItemId = 650
		}
	},
	{
		SecurityKey = "c26d67929290bc56f1fcee35463b5ad4",
		Id = {
			Type = "Title",
			StorageKey = "Primordial Guardian",
			ItemId = 651
		}
	},
	{
		SecurityKey = "6469f82043e5f2566d13648bb02690e7",
		Id = {
			Type = "Title",
			StorageKey = "Pirate Hunter",
			ItemId = 652
		}
	},
	{
		SecurityKey = "5e78ce4151f3c90ade5fe1b07eca83da",
		Id = {
			Type = "Title",
			StorageKey = "Bounty Hunter",
			ItemId = 653
		}
	},
	{
		SecurityKey = "d21be34f8ce83366f92113a5df6b6f1b",
		Id = {
			Type = "Title",
			StorageKey = "Warlord of the Sea",
			ItemId = 654
		}
	},
	{
		SecurityKey = "496e1dbee4846ae5de58f279d47653e6",
		Id = {
			Type = "Title",
			StorageKey = "Emperor of the Sea",
			ItemId = 655
		}
	},
	{
		SecurityKey = "cfca75009c7f60f8859340bd41857ac4",
		Id = {
			Type = "Title",
			StorageKey = "Empress of the Sea",
			ItemId = 656
		}
	},
	{
		SecurityKey = "b6ff2912a0fdb7d043fc941739688f06",
		Id = {
			Type = "Title",
			StorageKey = "Admiral",
			ItemId = 657
		}
	},
	{
		SecurityKey = "a62e26e5524b09d3d44254de7d6cffe8",
		Id = {
			Type = "Title",
			StorageKey = "Fleet Admiral",
			ItemId = 658
		}
	},
	{
		SecurityKey = "0f9a60030aedde0b8183b46163f78805",
		Id = {
			Type = "Title",
			StorageKey = "Enlightened One",
			ItemId = 659
		}
	},
	{
		SecurityKey = "d6150f6c4ed5e4153da4ee8b8a999957",
		Id = {
			Type = "Title",
			StorageKey = "Awakened One",
			ItemId = 660
		}
	},
	{
		SecurityKey = "1c34f12e5e632fe2069be229ca3550c3",
		Id = {
			Type = "Title",
			StorageKey = "Over Heaven",
			ItemId = 661
		}
	},
	{
		SecurityKey = "57bca4b9cd715bce7b5a9f8190aa8245",
		Id = {
			Type = "Title",
			StorageKey = "Over Hell",
			ItemId = 662
		}
	},
	{
		SecurityKey = "7244b48c0152ca4bf76a4995dbc224e9",
		Id = {
			Type = "Title",
			StorageKey = "Flame Fist",
			ItemId = 663
		}
	},
	{
		SecurityKey = "241e46310984f989d1e6f8eed7ffc0c5",
		Id = {
			Type = "Title",
			StorageKey = "The Ice Queen",
			ItemId = 664
		}
	},
	{
		SecurityKey = "dc42f1021e23cf4aae11e388f9bde1db",
		Id = {
			Type = "Title",
			StorageKey = "The Ice King",
			ItemId = 665
		}
	},
	{
		SecurityKey = "302dcbf9e61532c5489dd662f8ad5e0e",
		Id = {
			Type = "Title",
			StorageKey = "The Strongest One",
			ItemId = 666
		}
	},
	{
		SecurityKey = "42c98be3f521e711ea32d84427d651d3",
		Id = {
			Type = "Title",
			StorageKey = "The First Light",
			ItemId = 667
		}
	},
	{
		SecurityKey = "8a78414d64b752ceadd39fb8450590a0",
		Id = {
			Type = "Title",
			StorageKey = "Dark Lord",
			ItemId = 668
		}
	},
	{
		SecurityKey = "9aca10e9d7dcdae2ccafcdf768853fe7",
		Id = {
			Type = "Title",
			StorageKey = "The Spider",
			ItemId = 669
		}
	},
	{
		SecurityKey = "d31d4014dfa9064c53620acbfbc1170f",
		Id = {
			Type = "Title",
			StorageKey = "Thunder God",
			ItemId = 670
		}
	},
	{
		SecurityKey = "7595a09a56380616b5ce803d0d526f7a",
		Id = {
			Type = "Title",
			StorageKey = "The Red Dog",
			ItemId = 671
		}
	},
	{
		SecurityKey = "9fe059c3607d649b04167c85edb330d5",
		Id = {
			Type = "Title",
			StorageKey = "Colossal God",
			ItemId = 672
		}
	},
	{
		SecurityKey = "ed580e0718aba81a28f6cbbda18275eb",
		Id = {
			Type = "Title",
			StorageKey = "Desert Prince",
			ItemId = 673
		}
	},
	{
		SecurityKey = "7e8d92c961cb325a16f3e090c002508f",
		Id = {
			Type = "Title",
			StorageKey = "The Phoenix",
			ItemId = 674
		}
	},
	{
		SecurityKey = "7e784b70b5e27481269129a873b389e2",
		Id = {
			Type = "Title",
			StorageKey = "Bread Chaser",
			ItemId = 675
		}
	},
	{
		SecurityKey = "df550c8ab28775fe00034f2d7d1f92f7",
		Id = {
			Type = "Title",
			StorageKey = "Innovator",
			ItemId = 676
		}
	},
	{
		SecurityKey = "a576e81b64b9f1251b30f2bb462fbce0",
		Id = {
			Type = "Title",
			StorageKey = "Wen Lord Toad",
			ItemId = 677
		}
	},
	{
		SecurityKey = "b5e146eb56d618ed01645e72cc91dc1d",
		Id = {
			Type = "Title",
			StorageKey = "Pygglor, Devourer of Worlds",
			ItemId = 678
		}
	},
	{
		SecurityKey = "e39ad2df9e3d867c96fbcacbc45c08b0",
		Id = {
			Type = "Title",
			StorageKey = "Big News",
			ItemId = 679
		}
	},
	{
		SecurityKey = "9367fcce60b38ef2be755e20f78edcae",
		Id = {
			Type = "Title",
			StorageKey = "YouTuber",
			ItemId = 680
		}
	},
	{
		SecurityKey = "3d4275cea98f1c05c5080aeaa9ee2b82",
		Id = {
			Type = "Title",
			StorageKey = "Ace Squad",
			ItemId = 681
		}
	},
	{
		SecurityKey = "85070fd1fd0b22dc3620137704b3b2b0",
		Id = {
			Type = "Title",
			StorageKey = "Officially a Noob",
			ItemId = 682
		}
	},
	{
		SecurityKey = "462fb718ddae5c4fae1f446a8f90fdc2",
		Id = {
			Type = "Title",
			StorageKey = "Water Gang",
			ItemId = 683
		}
	},
	{
		SecurityKey = "d00626019b790f43e0443168c76e57a3",
		Id = {
			Type = "Title",
			StorageKey = "Don Axiore Familia",
			ItemId = 684
		}
	},
	{
		SecurityKey = "5413defe9397c6a6289f494375ba8936",
		Id = {
			Type = "Title",
			StorageKey = "Mafia Gang",
			ItemId = 685
		}
	},
	{
		SecurityKey = "c1230cc5d05316748d6590be9ed5fb7f",
		Id = {
			Type = "Title",
			StorageKey = "Heorua Family",
			ItemId = 686
		}
	},
	{
		SecurityKey = "1fb7d42760fdd54240c95d2a7aec3c97",
		Id = {
			Type = "Title",
			StorageKey = "Magic Slayer",
			ItemId = 687
		}
	},
	{
		SecurityKey = "aed526a897618c3985694012f5218b38",
		Id = {
			Type = "Title",
			StorageKey = "Kitt Katt",
			ItemId = 688
		}
	},
	{
		SecurityKey = "d2f6d4e0fa1a9c26e8c9a0ff84df6a77",
		Id = {
			Type = "Title",
			StorageKey = "Team JC",
			ItemId = 689
		}
	},
	{
		SecurityKey = "55678846ffd6a562d8392cba5970728f",
		Id = {
			Type = "Title",
			StorageKey = "El Combo God",
			ItemId = 690
		}
	},
	{
		SecurityKey = "4b87d7c8d3c55c61e3d02f39cead5f31",
		Id = {
			Type = "Title",
			StorageKey = "Nakama Forever",
			ItemId = 691
		}
	},
	{
		SecurityKey = "4f5bbeaf89a0bc2ff361c7dab3ced459",
		Id = {
			Type = "Title",
			StorageKey = "Endless Fantasy",
			ItemId = 692
		}
	},
	{
		SecurityKey = "3a2b6f64f87c0daba9749e007eb72e96",
		Id = {
			Type = "Title",
			StorageKey = "El Krazy Editor",
			ItemId = 693
		}
	},
	{
		SecurityKey = "3fbdaacf28b662f04b4f1e0a0e726869",
		Id = {
			Type = "Title",
			StorageKey = "rip_family",
			ItemId = 694
		}
	},
	{
		SecurityKey = "0b61e2b457c093b0b6eb132659fa6d13",
		Id = {
			Type = "Title",
			StorageKey = "red_legion",
			ItemId = 695
		}
	},
	{
		SecurityKey = "d0d06c85a58540f6dc4206669cd3e9a8",
		Id = {
			Type = "Title",
			StorageKey = "Justice Seeker",
			ItemId = 696
		}
	},
	{
		SecurityKey = "ad0ef6ed6600ded2b0ea4408132a3258",
		Id = {
			Type = "Title",
			StorageKey = "Empty Vessel",
			ItemId = 697
		}
	},
	{
		SecurityKey = "7c4faea949c57134ddcde96e42119c10",
		Id = {
			Type = "Title",
			StorageKey = "The Unlucky",
			ItemId = 698
		}
	},
	{
		SecurityKey = "d931ba696fe61e826627b4145a48a43b",
		Id = {
			Type = "Title",
			StorageKey = "The Vanquished",
			ItemId = 699
		}
	},
	{
		SecurityKey = "8ed83366a36aee79f459b4a48c1432ec",
		Id = {
			Type = "Title",
			StorageKey = "Fallen Hero",
			ItemId = 700
		}
	},
	{
		SecurityKey = "b392e7b8381299507339f61593b3adb5",
		Id = {
			Type = "Title",
			StorageKey = "Iron Man",
			ItemId = 701
		}
	},
	{
		SecurityKey = "98ad95f25906dcc36894cb5c4f4647b1",
		Id = {
			Type = "Title",
			StorageKey = "Ultra Instinct",
			ItemId = 702
		}
	},
	{
		SecurityKey = "92bdf22d8b6bd78531602253255d6215",
		Id = {
			Type = "Title",
			StorageKey = "Mad Scientist",
			ItemId = 703
		}
	},
	{
		SecurityKey = "7c5f6b641b59c02c19bdfdfa6a467328",
		Id = {
			Type = "Title",
			StorageKey = "The Professor",
			ItemId = 704
		}
	},
	{
		SecurityKey = "24ac59cfc90c5861be0d72b29ef722de",
		Id = {
			Type = "Title",
			StorageKey = "The Shadow",
			ItemId = 705
		}
	},
	{
		SecurityKey = "2ec2421494ca7017ac94994eb8789539",
		Id = {
			Type = "Title",
			StorageKey = "The Vampire",
			ItemId = 706
		}
	},
	{
		SecurityKey = "25c9dabec102022c869378a418763860",
		Id = {
			Type = "Title",
			StorageKey = "Dracula",
			ItemId = 707
		}
	},
	{
		SecurityKey = "83f187f89b53b3df81a97d3140272b54",
		Id = {
			Type = "Title",
			StorageKey = "The Grandfather",
			ItemId = 708
		}
	},
	{
		SecurityKey = "bf49fd2b7c87a2168c0ff8e61457df76",
		Id = {
			Type = "Title",
			StorageKey = "Jack of All Trades",
			ItemId = 709
		}
	},
	{
		SecurityKey = "a7f79a07c03c3e192ae40790b86ff0a7",
		Id = {
			Type = "Title",
			StorageKey = "The Undefeated One",
			ItemId = 710
		}
	},
	{
		SecurityKey = "6412093fdad6e95ba4058652d1573a54",
		Id = {
			Type = "Title",
			StorageKey = "Immortal Being",
			ItemId = 711
		}
	},
	{
		SecurityKey = "2e237bd04969d000c43d9810b0c6e210",
		Id = {
			Type = "Title",
			StorageKey = "The Mad King",
			ItemId = 712
		}
	},
	{
		SecurityKey = "f08e7ca02d27ab7dcef110c1b3a423ab",
		Id = {
			Type = "Title",
			StorageKey = "The Mastermind",
			ItemId = 713
		}
	},
	{
		SecurityKey = "a57629d36eb8be422994788cf51a865c",
		Id = {
			Type = "Title",
			StorageKey = "The Dog",
			ItemId = 714
		}
	},
	{
		SecurityKey = "95a075f1b91bb8718d7507248acf3f01",
		Id = {
			Type = "Title",
			StorageKey = "Ship Destroyer",
			ItemId = 715
		}
	},
	{
		SecurityKey = "44610c2535a7c06ba00708a0d4b7914b",
		Id = {
			Type = "Title",
			StorageKey = "The Explorer",
			ItemId = 716
		}
	},
	{
		SecurityKey = "e51e1c300701ef7921a20c633ba4b10f",
		Id = {
			Type = "Title",
			StorageKey = "The Adventurer",
			ItemId = 717
		}
	},
	{
		SecurityKey = "3d99a61ae34ed46c5c102be2126145a9",
		Id = {
			Type = "Title",
			StorageKey = "The Mercenary",
			ItemId = 718
		}
	},
	{
		SecurityKey = "e7a6b9b4a121401c88463cd16d3261ac",
		Id = {
			Type = "Title",
			StorageKey = "The Viking",
			ItemId = 719
		}
	},
	{
		SecurityKey = "f2fa3f1129e3a40a6caa7cf8e4ca6691",
		Id = {
			Type = "Title",
			StorageKey = "The Pioneer",
			ItemId = 720
		}
	},
	{
		SecurityKey = "1eed9168671cce737c61b7440f03202c",
		Id = {
			Type = "Title",
			StorageKey = "The Glorious",
			ItemId = 721
		}
	},
	{
		SecurityKey = "5756c4e9b2482403b7a80a4e65265c2a",
		Id = {
			Type = "Title",
			StorageKey = "The Master",
			ItemId = 722
		}
	},
	{
		SecurityKey = "8fa6328495e13a6f553582ee8889836e",
		Id = {
			Type = "Title",
			StorageKey = "Unbreakable Will",
			ItemId = 723
		}
	},
	{
		SecurityKey = "268c5e22685023a3aafda917600cc5e4",
		Id = {
			Type = "Title",
			StorageKey = "Fist of Death",
			ItemId = 724
		}
	},
	{
		SecurityKey = "c7f2aa1f8dc8fdf779c3aa219c93e73c",
		Id = {
			Type = "Title",
			StorageKey = "God Blade",
			ItemId = 725
		}
	},
	{
		SecurityKey = "565b25467fad1aa4cd6d686e0e95c218",
		Id = {
			Type = "Title",
			StorageKey = "King Sniper",
			ItemId = 726
		}
	},
	{
		SecurityKey = "325a90c3b09e9c048cca134ec7275e7c",
		Id = {
			Type = "Title",
			StorageKey = "Beyond the Sea",
			ItemId = 727
		}
	},
	{
		SecurityKey = "534291b4457abe10a7eea56369251825",
		Id = {
			Type = "Title",
			StorageKey = "Broken Heart",
			ItemId = 728
		}
	},
	{
		SecurityKey = "d9b8f505de6909f97b4c2a385952f464",
		Id = {
			Type = "Title",
			StorageKey = "The Conqueror",
			ItemId = 729
		}
	},
	{
		SecurityKey = "67829c69d4f0eb60f35317c211f21252",
		Id = {
			Type = "Title",
			StorageKey = "Last Hope",
			ItemId = 730
		}
	},
	{
		SecurityKey = "f56f28e03e89c4b21cf3b2fa2f5e9d71",
		Id = {
			Type = "Title",
			StorageKey = "The Supersonic",
			ItemId = 731
		}
	},
	{
		SecurityKey = "9c8ba938a3c01feafd0ce8c30bcc206f",
		Id = {
			Type = "Title",
			StorageKey = "The Flash",
			ItemId = 732
		}
	},
	{
		SecurityKey = "42f80b1b780a52d10587ddf1ebd9d0cb",
		Id = {
			Type = "Title",
			StorageKey = "The Champion",
			ItemId = 733
		}
	},
	{
		SecurityKey = "ab671ad5c21454ee796632a5e22513c9",
		Id = {
			Type = "Title",
			StorageKey = "Tide Warrior",
			ItemId = 734
		}
	},
	{
		SecurityKey = "f6fcb61cdc3623ea1c758946af98d13c",
		Id = {
			Type = "Title",
			StorageKey = "The Toxic",
			ItemId = 735
		}
	},
	{
		SecurityKey = "c76612e904d1b66758c41ace990aa5d4",
		Id = {
			Type = "Title",
			StorageKey = "Blessed One",
			ItemId = 736
		}
	},
	{
		SecurityKey = "f324993f5edb1f20d0f5aeb4c710a97b",
		Id = {
			Type = "Title",
			StorageKey = "Equal to the Heavens",
			ItemId = 737
		}
	},
	{
		SecurityKey = "9f818b7a71031280bdb1c99ad6ff1300",
		Id = {
			Type = "Title",
			StorageKey = "The Rich",
			ItemId = 738
		}
	},
	{
		SecurityKey = "b8344356e64c5840a75e01afa9e999ec",
		Id = {
			Type = "Title",
			StorageKey = "Unlimited Money",
			ItemId = 739
		}
	},
	{
		SecurityKey = "e5608a944bba4b86f61746198832210a",
		Id = {
			Type = "Title",
			StorageKey = "The Richest in the World",
			ItemId = 740
		}
	},
	{
		SecurityKey = "d04211b4373eddf6d8a4bf40a19a779f",
		Id = {
			Type = "Title",
			StorageKey = "The Collector",
			ItemId = 741
		}
	},
	{
		SecurityKey = "32694862f9a32c4623c19897c939d149",
		Id = {
			Type = "Title",
			StorageKey = "The Swordsman",
			ItemId = 742
		}
	},
	{
		SecurityKey = "534023ea8bc1e046cb076d6dd26014fe",
		Id = {
			Type = "Title",
			StorageKey = "Beast Hunter",
			ItemId = 743
		}
	},
	{
		SecurityKey = "a1342d06c942afc6c7eaf02cf735e7b1",
		Id = {
			Type = "Title",
			StorageKey = "The Beast",
			ItemId = 744
		}
	},
	{
		SecurityKey = "8323fa61e24bdeae9b117c09eba1a9c9",
		Id = {
			Type = "Title",
			StorageKey = "The Lost Soul",
			ItemId = 745
		}
	},
	{
		SecurityKey = "48548f7415b1454f6300be6a66e6b22b",
		Id = {
			Type = "Title",
			StorageKey = "Forbidden One",
			ItemId = 746
		}
	},
	{
		SecurityKey = "935627e7457cba71e12cd12bd5a70d85",
		Id = {
			Type = "Title",
			StorageKey = "The Troll",
			ItemId = 747
		}
	},
	{
		SecurityKey = "7c6ba92a1d40d2a87c9fdf39ea4b1ebd",
		Id = {
			Type = "Title",
			StorageKey = "Hidden Power",
			ItemId = 748
		}
	},
	{
		SecurityKey = "27427798b79a5476e4d26b9b0feca798",
		Id = {
			Type = "Title",
			StorageKey = "Heavenly Devil",
			ItemId = 749
		}
	},
	{
		SecurityKey = "abf418b3dcfa01c7569cff5304d19fd7",
		Id = {
			Type = "Title",
			StorageKey = "The Cursed One",
			ItemId = 750
		}
	},
	{
		SecurityKey = "6e512a5fedcec2c1392f11df947006a3",
		Id = {
			Type = "Title",
			StorageKey = "Beyond Death",
			ItemId = 751
		}
	},
	{
		SecurityKey = "2a8d7499d0303d456375925f43570893",
		Id = {
			Type = "Title",
			StorageKey = "Night's Edge",
			ItemId = 752
		}
	},
	{
		SecurityKey = "bedc350a6c16233b688ba0d3d53a4e3d",
		Id = {
			Type = "Title",
			StorageKey = "Kind-Hearted",
			ItemId = 753
		}
	},
	{
		SecurityKey = "27943665569eab27f09afe16992fed54",
		Id = {
			Type = "Title",
			StorageKey = "The Kraken",
			ItemId = 754
		}
	},
	{
		SecurityKey = "db396f0022971a5220998dd05d22399d",
		Id = {
			Type = "Title",
			StorageKey = "Lavish Living",
			ItemId = 755
		}
	},
	{
		SecurityKey = "8b531bd47274519ce13a7532d393b431",
		Id = {
			Type = "Title",
			StorageKey = "Night Owl",
			ItemId = 756
		}
	},
	{
		SecurityKey = "fd5230d576223f0679d37ba88c28990e",
		Id = {
			Type = "Title",
			StorageKey = "Wicked Captain",
			ItemId = 757
		}
	},
	{
		SecurityKey = "24f3a9fb6e4b796217367246c3ad3c0f",
		Id = {
			Type = "Title",
			StorageKey = "Dragonborn",
			ItemId = 758
		}
	},
	{
		SecurityKey = "2537f092f3542c9d047f179e50e78005",
		Id = {
			Type = "Title",
			StorageKey = "Burning Leg",
			ItemId = 759
		}
	},
	{
		SecurityKey = "c127359f79f1f43af924cdd1216969ce",
		Id = {
			Type = "Title",
			StorageKey = "Sharkman",
			ItemId = 760
		}
	},
	{
		SecurityKey = "e942ff83afcfc2aca9dffa5fa295ac5d",
		Id = {
			Type = "Title",
			StorageKey = "Samurai",
			ItemId = 761
		}
	},
	{
		SecurityKey = "ec1e004be4e901c43f7b3106ce9398c5",
		Id = {
			Type = "Title",
			StorageKey = "The Silent",
			ItemId = 762
		}
	},
	{
		SecurityKey = "d361813254d351a5fb3f5f83fd7c6bf0",
		Id = {
			Type = "Title",
			StorageKey = "The Executioner",
			ItemId = 763
		}
	},
	{
		SecurityKey = "2add384035cbe6ce02b7559eb5c1fa5b",
		Id = {
			Type = "Title",
			StorageKey = "The Stalker",
			ItemId = 764
		}
	},
	{
		SecurityKey = "e32f00d6eb45e4bacd7c58d17050cdf9",
		Id = {
			Type = "Title",
			StorageKey = "Risk Taker",
			ItemId = 765
		}
	},
	{
		SecurityKey = "44ba74c04cde71f3b9c8111d22dbeae9",
		Id = {
			Type = "Title",
			StorageKey = "Luck of the Draw",
			ItemId = 766
		}
	},
	{
		SecurityKey = "fa93b380b60b384d04059e86af3030ac",
		Id = {
			Type = "Title",
			StorageKey = "Unstoppable Force",
			ItemId = 767
		}
	},
	{
		SecurityKey = "87772250cf29cf8ba6721ff05d052588",
		Id = {
			Type = "Title",
			StorageKey = "Raging Demon",
			ItemId = 768
		}
	},
	{
		SecurityKey = "8713d8620ff362d5fbe65251b9fda7ab",
		Id = {
			Type = "Title",
			StorageKey = "The Protagonist",
			ItemId = 769
		}
	},
	{
		SecurityKey = "d3251f2fc3677cb3871901b791bb7454",
		Id = {
			Type = "Title",
			StorageKey = "Coldblooded",
			ItemId = 770
		}
	},
	{
		SecurityKey = "27b23fa44cce4b21215f5e9297f6c5b4",
		Id = {
			Type = "Title",
			StorageKey = "Apex Predator",
			ItemId = 771
		}
	},
	{
		SecurityKey = "071d478b571d068f4cdb8f0c6113dc12",
		Id = {
			Type = "Title",
			StorageKey = "The Killer",
			ItemId = 772
		}
	},
	{
		SecurityKey = "dc9f14d08c8a1b84fd5f809fe4688b59",
		Id = {
			Type = "Title",
			StorageKey = "Human Weapon",
			ItemId = 773
		}
	},
	{
		SecurityKey = "c95abef5a4271b46938eea96b7811b1b",
		Id = {
			Type = "Title",
			StorageKey = "emon Eye",
			ItemId = 774
		}
	},
	{
		SecurityKey = "ee842edc3e614934097e81b60adb72c8",
		Id = {
			Type = "Title",
			StorageKey = "The Hurricane",
			ItemId = 775
		}
	},
	{
		SecurityKey = "f9a7a35b153bee0b86b0df6995bd4787",
		Id = {
			Type = "Title",
			StorageKey = "The Enhancer",
			ItemId = 776
		}
	},
	{
		SecurityKey = "9e43430d0b0c9bad7667c9cd5a661e4f",
		Id = {
			Type = "Title",
			StorageKey = "True Heart",
			ItemId = 777
		}
	},
	{
		SecurityKey = "cbbc3ec8145906bb0073b3a9e63dcb99",
		Id = {
			Type = "Title",
			StorageKey = "Bringer of Doom",
			ItemId = 778
		}
	},
	{
		SecurityKey = "14a2c14b860fcbf2501a074f35866200",
		Id = {
			Type = "Title",
			StorageKey = "Realm Creator",
			ItemId = 779
		}
	},
	{
		SecurityKey = "0e46d53db9c0a8d625623dd08dbe554c",
		Id = {
			Type = "Title",
			StorageKey = "Hakaishin",
			ItemId = 780
		}
	},
	{
		SecurityKey = "6c1a0d8ffcc5782de85d28b87a8fa6a2",
		Id = {
			Type = "Title",
			StorageKey = "Slayer of God",
			ItemId = 781
		}
	},
	{
		SecurityKey = "718b2e4a8acbd32012a3369b72586865",
		Id = {
			Type = "Title",
			StorageKey = "The Ghost",
			ItemId = 782
		}
	},
	{
		SecurityKey = "2b21d94b7cb34f044c09f0d759ff13b6",
		Id = {
			Type = "Title",
			StorageKey = "Ruler of Night",
			ItemId = 783
		}
	},
	{
		SecurityKey = "45d3c5a88c3cef5f3ea0a6b8b8685ec9",
		Id = {
			Type = "Title",
			StorageKey = "Lonely Reaper",
			ItemId = 784
		}
	},
	{
		SecurityKey = "86ca89d1af2bb1989dea5a97e028d051",
		Id = {
			Type = "Title",
			StorageKey = "The Most Wanted",
			ItemId = 785
		}
	},
	{
		SecurityKey = "8ef83ea976387242310d5ebaa04f1d7c",
		Id = {
			Type = "Title",
			StorageKey = "Pirate King",
			ItemId = 786
		}
	},
	{
		SecurityKey = "84ce114e9427ea2a45948d797e9f4cf0",
		Id = {
			Type = "Title",
			StorageKey = "Sugar Rush",
			ItemId = 787
		}
	},
	{
		SecurityKey = "33f8df887ee326e706b24a6dce462488",
		Id = {
			Type = "Title",
			StorageKey = "Christmas Spirit",
			ItemId = 788
		}
	},
	{
		SecurityKey = "d57001c552070f846e6effb12a85a37e",
		Id = {
			Type = "Title",
			StorageKey = "Loco Verde",
			ItemId = 789
		}
	},
	{
		SecurityKey = "193b261a39650b77dfc8ad722bdb3ea2",
		Id = {
			Type = "Title",
			StorageKey = "Raid Boss",
			ItemId = 790
		}
	},
	{
		SecurityKey = "c6fbe0276d6636cde73d318e34088bae",
		Id = {
			Type = "Title",
			StorageKey = "The Real Deal",
			ItemId = 791
		}
	},
	{
		SecurityKey = "1c8881b3374df223255a723a5c1f047c",
		Id = {
			Type = "Title",
			StorageKey = "Demon Mode",
			ItemId = 792
		}
	},
	{
		SecurityKey = "e2db26bb7ef5f4df9078b6458262f211",
		Id = {
			Type = "Title",
			StorageKey = "Celestial Swordsman",
			ItemId = 793
		}
	},
	{
		SecurityKey = "60e26989b342f8b270f368665610a36b",
		Id = {
			Type = "Title",
			StorageKey = "Raiton",
			ItemId = 794
		}
	},
	{
		SecurityKey = "85200a3a6c95fba522ab1a98e9c60220",
		Id = {
			Type = "Title",
			StorageKey = "Shadow Sovereign",
			ItemId = 795
		}
	},
	{
		SecurityKey = "71e63274139f377240c4f9c32499b5ef",
		Id = {
			Type = "Title",
			StorageKey = "The Chosen One",
			ItemId = 796
		}
	},
	{
		SecurityKey = "cce160052051da649212460ff22b2d31",
		Id = {
			Type = "Title",
			StorageKey = "Main Character",
			ItemId = 797
		}
	},
	{
		SecurityKey = "f6dc28eb3d35681ab4110bda9880e1a3",
		Id = {
			Type = "Title",
			StorageKey = "Final Hero",
			ItemId = 798
		}
	},
	{
		SecurityKey = "dd67ef6122e926343b978bc0d3f26b97",
		Id = {
			Type = "Title",
			StorageKey = "Skeleton",
			ItemId = 799
		}
	},
	{
		SecurityKey = "18451985dce2b424b4e8970ec12e1e6e",
		Id = {
			Type = "Title",
			StorageKey = "Undead Lord",
			ItemId = 800
		}
	},
	{
		SecurityKey = "95ceb9b9c806c896c7d5a754a74d6beb",
		Id = {
			Type = "Title",
			StorageKey = "Death King",
			ItemId = 801
		}
	},
	{
		SecurityKey = "69599ec746a94ce51acb4cf077ff9ba3",
		Id = {
			Type = "Title",
			StorageKey = "Shinigami",
			ItemId = 802
		}
	},
	{
		SecurityKey = "8cb696acc890ae2ef47f496af427567d",
		Id = {
			Type = "Title",
			StorageKey = "The Devil's Luck",
			ItemId = 803
		}
	},
	{
		SecurityKey = "0b9a204e7a150f1367f8bb912c958141",
		Id = {
			Type = "Title",
			StorageKey = "Dough Commander",
			ItemId = 804
		}
	},
	{
		SecurityKey = "77416db2db2520cac4083e5b35705651",
		Id = {
			Type = "Title",
			StorageKey = "Dough King",
			ItemId = 805
		}
	},
	{
		SecurityKey = "90be5cfe9be43e114863736b288016a3",
		Id = {
			Type = "Title",
			StorageKey = "Terrorbringer",
			ItemId = 806
		}
	},
	{
		SecurityKey = "a2a2f7765b60d563f9477930ea3f6679",
		Id = {
			Type = "Title",
			StorageKey = "Serpent Slayer",
			ItemId = 807
		}
	},
	{
		SecurityKey = "ae3ee519648bf3f75ddc33f91ab7b536",
		Id = {
			Type = "Title",
			StorageKey = "Abyss Tamer",
			ItemId = 808
		}
	},
	{
		SecurityKey = "169c6c95f51d134cc263dd14368fdddc",
		Id = {
			Type = "Title",
			StorageKey = "Nautical Bane",
			ItemId = 809
		}
	},
	{
		SecurityKey = "7af0bb14430043a94762a07f6de53ff3",
		Id = {
			Type = "Title",
			StorageKey = "Tailed Beast",
			ItemId = 810
		}
	},
	{
		SecurityKey = "60e549dfda02a27488ef79427925623c",
		Id = {
			Type = "Title",
			StorageKey = "Liberator of the Sky",
			ItemId = 811
		}
	},
	{
		SecurityKey = "6f6af26899802b9ed728b2417b69e363",
		Id = {
			Type = "Title",
			StorageKey = "Dragon Talon Prodigy",
			ItemId = 812
		}
	},
	{
		SecurityKey = "30557e2c9ec4c098ea5553023ee9f360",
		Id = {
			Type = "Title",
			StorageKey = "Brazillian Warrior",
			ItemId = 813
		}
	},
	{
		SecurityKey = "f6ee1d1ceb103ca1ebae575039cec3f9",
		Id = {
			Type = "FruitWithMutation",
			StorageKey = "Werewolf (Tiger)-Werewolf (Tiger)",
			ItemId = 814
		}
	},
	{
		SecurityKey = "b8519b49254a57af1ab299268651e251",
		Id = {
			Type = "FruitMutation",
			StorageKey = "TIGERMUTWerewolf",
			ItemId = 815
		}
	},
	{
		SecurityKey = "8d88f10e06f55fe553d45bff477da716",
		Id = {
			Type = "FruitMutation",
			StorageKey = "TIGERMUTTiger",
			ItemId = 816
		}
	},
	{
		SecurityKey = "c649e396dd522ab5a7c2402c6535ce61",
		Id = {
			Type = "FruitSkin",
			StorageKey = "TIGERSKINdefault",
			ItemId = 817
		}
	},
	{
		SecurityKey = "aad7cfb981b17ab94e029a7f1555242a",
		Id = {
			Type = "FruitSkin",
			StorageKey = "TIGERSKINwerewolf",
			ItemId = 818
		}
	},
	{
		SecurityKey = "6fc9b2029638ed767764de914557498f",
		Id = {
			Type = "SaleBundle",
			StorageKey = "Halloween 2025 Bundle",
			ItemId = 819
		}
	},
	{
		SecurityKey = "ccc2567d6a3720296b1734fb41bb52a0",
		Id = {
			Type = "NonFruitItem",
			StorageKey = "Big Head Elixir",
			ItemId = 820
		}
	},
	{
		SecurityKey = "bae9afc8ce180d74419ad1bd13a57af8",
		Id = {
			Type = "NonFruitItem",
			StorageKey = "Candy Concoction",
			ItemId = 821
		}
	},
	{
		SecurityKey = "ccbcbe6345df9dd4ba25ebde72102863",
		Id = {
			Type = "NonFruitItem",
			StorageKey = "Disguise Elixir",
			ItemId = 822
		}
	},
	{
		SecurityKey = "286057e457a236bca0a16bcd5567f56e",
		Id = {
			Type = "NonFruitItem",
			StorageKey = "Lava Bomb Elixir",
			ItemId = 823
		}
	},
	{
		SecurityKey = "571fc532db5c8245a24ece3cb76afea1",
		Id = {
			Type = "NonFruitItem",
			StorageKey = "Monster Mash Elixir",
			ItemId = 824
		}
	},
	{
		SecurityKey = "1b824471eb7983a59f20b49aaf4e4010",
		Id = {
			Type = "NonFruitItem",
			StorageKey = "Pumpkin Potion",
			ItemId = 825
		}
	},
	{
		SecurityKey = "af75a7a7d2490ca5042b35510f080b71",
		Id = {
			Type = "NonFruitItem",
			StorageKey = "Suspicious Growth Potion",
			ItemId = 826
		}
	},
	{
		SecurityKey = "da2a65be837da5fdfa34ced858a24d92",
		Id = {
			Type = "Fish",
			StorageKey = "Jack-O-Fish",
			ItemId = 827
		}
	},
	{
		SecurityKey = "3a7ec901e42429fe09fe44aa5ac787a3",
		Id = {
			Type = "Fish",
			StorageKey = "Jester Clownfish",
			ItemId = 828
		}
	},
	{
		SecurityKey = "6ac0092c9583b3febbc140cc50e8f56a",
		Id = {
			Type = "Fish",
			StorageKey = "Zombie Bass",
			ItemId = 829
		}
	},
	{
		SecurityKey = "cade55815538116aae09aed2af663e62",
		Id = {
			Type = "Fish",
			StorageKey = "Vampire Squid",
			ItemId = 830
		}
	},
	{
		SecurityKey = "5b8b6a569df8771c95e89ad4c1c5d23d",
		Id = {
			Type = "Fish",
			StorageKey = "Terrorbones",
			ItemId = 831
		}
	},
	{
		SecurityKey = "7a4253c775672dea434cfb617b50f04d",
		Id = {
			Type = "Material",
			StorageKey = "Candy Corn",
			ItemId = 832
		}
	},
	{
		SecurityKey = "27b7de354e384387d31cd5c811388a78",
		Id = {
			Type = "Fruit",
			StorageKey = "Tiger-Tiger",
			ItemId = 833
		}
	},
	{
		SecurityKey = "47d0626b2a7749540d28722e0eadd658",
		Id = {
			Type = "StorageIdOnly",
			StorageKey = "Permanent Tiger-Tiger",
			ItemId = 834
		}
	},
	{
		SecurityKey = "c342d8e28dc0550842c372f13f3420f8",
		Id = {
			Type = "FruitBox",
			StorageKey = "LegendaryBoxS3",
			ItemId = 835
		}
	},
	{
		SecurityKey = "d4574a7bb6a5196e0c48842ffa686ed8",
		Id = {
			Type = "FruitBox",
			StorageKey = "MythicalBoxS3",
			ItemId = 836
		}
	},
	{
		SecurityKey = "ab4209206ba394c2f9f8bdf1775cdaec",
		Id = {
			Type = "FruitBox",
			StorageKey = "MysteryBoxS3",
			ItemId = 837
		}
	},
	{
		SecurityKey = "ae43a9b6ff70f6c8d2166f169fcb7a08",
		Id = {
			Type = "FruitBox",
			StorageKey = "PremiumBoxS3",
			ItemId = 838
		}
	},
	{
		SecurityKey = "a5f4ec79097e73ef4346d200f430cc89",
		Id = {
			Type = "FruitBox",
			StorageKey = "RareBoxS3",
			ItemId = 839
		}
	},
	{
		SecurityKey = "e0a676ffb3d15e665b21679e47d5f182",
		Id = {
			Type = "FruitBox",
			StorageKey = "UncommonBoxS3",
			ItemId = 840
		}
	},
	{
		SecurityKey = "e6a9e501165435e8a6f78083f86da366",
		Id = {
			Type = "SpecialProduct",
			StorageKey = "Dragon Token (Physical)",
			ItemId = 841
		}
	},
	{
		SecurityKey = "174d408b6b1a9e8ceb6f89874879f2ea",
		Id = {
			Type = "SpecialProduct",
			StorageKey = "Dragon Token (West)",
			ItemId = 842
		}
	},
	{
		SecurityKey = "b61538262ee00d9f2157275664973f21",
		Id = {
			Type = "SpecialProduct",
			StorageKey = "Dragon Token (East)",
			ItemId = 843
		}
	},
	{
		SecurityKey = "6f6251372ef38e8147253142e5e00f73",
		Id = {
			Type = "SpecialProduct",
			StorageKey = "Permanent Dragon Token",
			ItemId = 844
		}
	},
	{
		SecurityKey = "b75941c02c2d3d34d44f30a90d25c41a",
		Id = {
			Type = "NonFruitItem",
			StorageKey = "Shark (Corrupted)",
			ItemId = 845
		}
	},
	{
		SecurityKey = "cffb011319af5f06b3369d2adef45469",
		Id = {
			Type = "Fruit",
			StorageKey = "Revive-Revive",
			ItemId = 846
		}
	},
	{
		SecurityKey = "2d6245831b46b4db0766070fd08d4385",
		Id = {
			Type = "NonFruitItem",
			StorageKey = "Coven Witch Hat",
			ItemId = 847
		}
	},
	{
		SecurityKey = "d92bd1f30ddef7bf9a60d90a37a18b9c",
		Id = {
			Type = "NonFruitItem",
			StorageKey = "Pumpkin Mask",
			ItemId = 848
		}
	},
	{
		SecurityKey = "0730d557092e4dab502639b66098f1f2",
		Id = {
			Type = "NonFruitItem",
			StorageKey = "Admin Rod",
			ItemId = 849
		}
	},
	{
		SecurityKey = "8b5472a1dd1647892087c29f79df8d78",
		Id = {
			Type = "Fruit",
			StorageKey = "Chop-Chop",
			ItemId = 850
		}
	},
	{
		SecurityKey = "42188f2a864efed1617b9b851f5f5181",
		Id = {
			Type = "AuraSkin",
			StorageKey = "Oni Aura",
			ItemId = 851
		}
	},
	{
		SecurityKey = "a57cf2af456fdd494509ff9a61923678",
		Id = {
			Type = "AuraSkin",
			StorageKey = "Celestial Aura",
			ItemId = 852
		}
	},
	{
		SecurityKey = "5e7c43aef068d6fab9fe60af9e6f426a",
		Id = {
			Type = "Scroll",
			StorageKey = "Cursed Scroll",
			ItemId = 853
		}
	},
	{
		SecurityKey = "6b8223fe82bf9835cf733d65576fb8b8",
		Id = {
			Type = "Scroll",
			StorageKey = "Blessed Scroll",
			ItemId = 854
		}
	},
	{
		SecurityKey = "0677a583eb62749b71e5dfe096ecae01",
		Id = {
			Type = "Scroll",
			StorageKey = "Common Scroll",
			ItemId = 855
		}
	},
	{
		SecurityKey = "0cc6a074244ede337a7a478792d478d9",
		Id = {
			Type = "Scroll",
			StorageKey = "Rare Scroll",
			ItemId = 856
		}
	},
	{
		SecurityKey = "9c819d1c758d9b0d0ae43c9bd29ab216",
		Id = {
			Type = "Scroll",
			StorageKey = "Legendary Scroll",
			ItemId = 857
		}
	},
	{
		SecurityKey = "f114f9fa3f11ee63d64255fff912d700",
		Id = {
			Type = "Scroll",
			StorageKey = "Mythical Scroll",
			ItemId = 858
		}
	},
	{
		SecurityKey = "5172f9d803b2771e28213f074ff19bc6",
		Id = {
			Type = "Bait",
			StorageKey = "Basic Bait",
			ItemId = 859
		}
	},
	{
		SecurityKey = "e74b27249e10336c11b316a3e4e2cc71",
		Id = {
			Type = "Bait",
			StorageKey = "Good Bait",
			ItemId = 860
		}
	},
	{
		SecurityKey = "3d14fcf4209adf4b740a1ffe3995b07b",
		Id = {
			Type = "Bait",
			StorageKey = "Epic Bait",
			ItemId = 861
		}
	},
	{
		SecurityKey = "7d19a535716101352ff7a4c26fbb35a8",
		Id = {
			Type = "Bait",
			StorageKey = "Frozen Bait",
			ItemId = 862
		}
	},
	{
		SecurityKey = "0890d4fd0c8f7b3ab63c0f2b71619d7e",
		Id = {
			Type = "Bait",
			StorageKey = "Kelp Bait",
			ItemId = 863
		}
	},
	{
		SecurityKey = "66ca5dc60d47ca05348567cfdd375bcd",
		Id = {
			Type = "Bait",
			StorageKey = "Carnivore Bait",
			ItemId = 864
		}
	},
	{
		SecurityKey = "12da423ec014550294ba775e14fdc6ef",
		Id = {
			Type = "Bait",
			StorageKey = "Sweet Bait",
			ItemId = 865
		}
	},
	{
		SecurityKey = "b48555d5514443cff99ba1d58e894542",
		Id = {
			Type = "Bait",
			StorageKey = "Spicy Bait",
			ItemId = 866
		}
	},
	{
		SecurityKey = "1a30e6d42c45b898020c515d9e308c3b",
		Id = {
			Type = "Bait",
			StorageKey = "Abyssal Bait",
			ItemId = 867
		}
	},
	{
		SecurityKey = "e9b1edc33cbe02c0119a92587b9c046a",
		Id = {
			Type = "Fish",
			StorageKey = "Soggy Boot",
			ItemId = 868
		}
	},
	{
		SecurityKey = "52d5ff0600e739332485d3c6fbf6972e",
		Id = {
			Type = "Abstract",
			StorageKey = "Air Jump",
			ItemId = 869
		}
	},
	{
		SecurityKey = "b24eb26ffffe619126eadaee8613640b",
		Id = {
			Type = "Abstract",
			StorageKey = "Flash Step",
			ItemId = 870
		}
	},
	{
		SecurityKey = "ff9190f8615a4bb48d0d4744fc361059",
		Id = {
			Type = "Abstract",
			StorageKey = "Instinct",
			ItemId = 871
		}
	},
	{
		SecurityKey = "79cab73907bd211875aebd950076b8a3",
		Id = {
			Type = "AuraSkin",
			StorageKey = "Basic Aura",
			ItemId = 872
		}
	},
	{
		SecurityKey = "6b9966d9af096bf24399d4333ba82821",
		Id = {
			Type = "Abstract",
			StorageKey = "Human",
			ItemId = 873
		}
	},
	{
		SecurityKey = "23105894b2d984c91d7dc948c20e659b",
		Id = {
			Type = "Abstract",
			StorageKey = "Rabbit",
			ItemId = 874
		}
	},
	{
		SecurityKey = "76e878b6b305f7710f18738256e48a8e",
		Id = {
			Type = "Abstract",
			StorageKey = "Shark",
			ItemId = 875
		}
	},
	{
		SecurityKey = "26c927728018308b090f8693d875b181",
		Id = {
			Type = "Abstract",
			StorageKey = "Angel",
			ItemId = 876
		}
	},
	{
		SecurityKey = "9ba8d43c9f47ecd2414c15fcdd69ea3b",
		Id = {
			Type = "Abstract",
			StorageKey = "Ghoul",
			ItemId = 877
		}
	},
	{
		SecurityKey = "d94f2379541167a98a2cc8c2622ff41a",
		Id = {
			Type = "Abstract",
			StorageKey = "Cyborg",
			ItemId = 878
		}
	},
	{
		SecurityKey = "2e7301d2cf610f2478ceb8d79464aa1c",
		Id = {
			Type = "Abstract",
			StorageKey = "Draco",
			ItemId = 879
		}
	},
	{
		SecurityKey = "f087f9e265a8afb0521361a5e36cd08c",
		Id = {
			Type = "NonFruitItem",
			StorageKey = "Peppermint Helmet",
			ItemId = 880
		}
	},
	{
		SecurityKey = "a38b5e6dd123d99309772c16004ed188",
		Id = {
			Type = "Abstract",
			StorageKey = "Air Jump V0",
			ItemId = 881
		}
	},
	{
		SecurityKey = "b910a497f9fb8119d09379247e891075",
		Id = {
			Type = "Abstract",
			StorageKey = "Instinct V2",
			ItemId = 882
		}
	},
	{
		SecurityKey = "b366f1a6d1b78308354b2d42c8122f63",
		Id = {
			Type = "Abstract",
			StorageKey = "Instinct V0",
			ItemId = 883
		}
	},
	{
		SecurityKey = "1a26c17396f012516baf97d0b132e0bb",
		Id = {
			Type = "FruitFusion",
			StorageKey = "Dragon (West)-Dragon (West)",
			ItemId = 884
		}
	},
	{
		SecurityKey = "79d835f9053f49f26cb02b1dd313debd",
		Id = {
			Type = "FruitFusion",
			StorageKey = "Dragon (East)-Dragon (East)",
			ItemId = 885
		}
	},
	{
		SecurityKey = "13b75c5b6021a897dee7ed4ce50a6825",
		Id = {
			Type = "Material",
			StorageKey = "Simulation Data",
			ItemId = 886
		}
	},
	{
		SecurityKey = "4e6785fd00bfef686f0e36ead90fa7c4",
		Id = {
			Type = "Fish",
			StorageKey = "Reindeer Bullfish",
			ItemId = 887
		}
	},
	{
		SecurityKey = "8cf3d7cc8996b7c2847c65ec9dba1050",
		Id = {
			Type = "Fish",
			StorageKey = "Snowman Marlin",
			ItemId = 888
		}
	},
	{
		SecurityKey = "78f048cfbb63a6d7d3ebf9e9ca51850b",
		Id = {
			Type = "Fish",
			StorageKey = "Gingerbread Sturgeon",
			ItemId = 889
		}
	},
	{
		SecurityKey = "fe9a1081f6f02c08c99997d083f9dec9",
		Id = {
			Type = "Fish",
			StorageKey = "Peppermint Fish",
			ItemId = 890
		}
	},
	{
		SecurityKey = "ab0ca36c01bbc72f2046a6c89baccbd9",
		Id = {
			Type = "NonFruitItem",
			StorageKey = "Ring of Carving I",
			ItemId = 891
		}
	},
	{
		SecurityKey = "6f86f17d73c89ae032224a40d09ad269",
		Id = {
			Type = "NonFruitItem",
			StorageKey = "Ring of Essence I",
			ItemId = 892
		}
	},
	{
		SecurityKey = "6de7b9f97ebdcc2447d237318b54fd14",
		Id = {
			Type = "NonFruitItem",
			StorageKey = "Ring of Might I",
			ItemId = 893
		}
	},
	{
		SecurityKey = "f9551a21f8a49ede39cd77df9f4d1680",
		Id = {
			Type = "NonFruitItem",
			StorageKey = "Ring of the Outlaw I",
			ItemId = 894
		}
	},
	{
		SecurityKey = "2ff3c50f711025acbd111fd3de005ac2",
		Id = {
			Type = "NonFruitItem",
			StorageKey = "Ring of Spirit I",
			ItemId = 895
		}
	},
	{
		SecurityKey = "134b4bbccda791eca622c98df87e4a2f",
		Id = {
			Type = "NonFruitItem",
			StorageKey = "Ring of Striking I",
			ItemId = 896
		}
	},
	{
		SecurityKey = "3dda49bc9f391ca4973fd30dfd452af0",
		Id = {
			Type = "NonFruitItem",
			StorageKey = "Ring of the Vanguard I",
			ItemId = 897
		}
	},
	{
		SecurityKey = "4b4faae608b2ef2da53683c1af909f05",
		Id = {
			Type = "NonFruitItem",
			StorageKey = "Ring of the Arcanist I",
			ItemId = 898
		}
	},
	{
		SecurityKey = "b3d7a60f182bdf85684e1a63fd3d637e",
		Id = {
			Type = "NonFruitItem",
			StorageKey = "Ring of Renewal I",
			ItemId = 899
		}
	},
	{
		SecurityKey = "0819624a17ba375fae56d6fb139f0d73",
		Id = {
			Type = "NonFruitItem",
			StorageKey = "Ring of Twin Blades I",
			ItemId = 900
		}
	},
	{
		SecurityKey = "240b2c08a3284bda09242b5ba63f1aba",
		Id = {
			Type = "NonFruitItem",
			StorageKey = "Ring of Steelheart I",
			ItemId = 901
		}
	},
	{
		SecurityKey = "44be00ec05a6def3ca7828b1d1350dd2",
		Id = {
			Type = "NonFruitItem",
			StorageKey = "Ring of Carving II",
			ItemId = 902
		}
	},
	{
		SecurityKey = "3497e33771eddc2f9f374d1079e31346",
		Id = {
			Type = "NonFruitItem",
			StorageKey = "Ring of Essence II",
			ItemId = 903
		}
	},
	{
		SecurityKey = "d06575b00fa45986b70138067edd59ab",
		Id = {
			Type = "NonFruitItem",
			StorageKey = "Ring of Might II",
			ItemId = 904
		}
	},
	{
		SecurityKey = "e54cbf90be7741412e7c5aa4e57a6d38",
		Id = {
			Type = "NonFruitItem",
			StorageKey = "Ring of the Outlaw II",
			ItemId = 905
		}
	},
	{
		SecurityKey = "feca20158e47882cf8a36e6d8fff3b63",
		Id = {
			Type = "NonFruitItem",
			StorageKey = "Ring of Spirit II",
			ItemId = 906
		}
	},
	{
		SecurityKey = "3e92e2d5d73c761277a873563148bfdd",
		Id = {
			Type = "NonFruitItem",
			StorageKey = "Ring of Striking II",
			ItemId = 907
		}
	},
	{
		SecurityKey = "d6342681a18368ccae87166b5feb89b7",
		Id = {
			Type = "NonFruitItem",
			StorageKey = "Ring of the Vanguard II",
			ItemId = 908
		}
	},
	{
		SecurityKey = "fa68896c94f0d086b1f388b1dc5e6cf8",
		Id = {
			Type = "NonFruitItem",
			StorageKey = "Ring of the Arcanist II",
			ItemId = 909
		}
	},
	{
		SecurityKey = "9c5c1c4e76835c472c8fb2095a040440",
		Id = {
			Type = "NonFruitItem",
			StorageKey = "Ring of Renewal II",
			ItemId = 910
		}
	},
	{
		SecurityKey = "566fd40432f33326ff0e59c9e6c2856f",
		Id = {
			Type = "NonFruitItem",
			StorageKey = "Ring of Twin Blades II",
			ItemId = 911
		}
	},
	{
		SecurityKey = "033f5611cb5a41cda72b7ee29b76f7bf",
		Id = {
			Type = "NonFruitItem",
			StorageKey = "Ring of Steelheart II",
			ItemId = 912
		}
	},
	{
		SecurityKey = "a79d3c8f5dd5f7cc1c2e6f20b79b948a",
		Id = {
			Type = "NonFruitItem",
			StorageKey = "Ring of Carving III",
			ItemId = 913
		}
	},
	{
		SecurityKey = "bb32a1358e704a4089f6057f97bbe4e6",
		Id = {
			Type = "NonFruitItem",
			StorageKey = "Ring of Essence III",
			ItemId = 914
		}
	},
	{
		SecurityKey = "82b9f676f7cdd40bd4cd955a3362dc84",
		Id = {
			Type = "NonFruitItem",
			StorageKey = "Ring of Might III",
			ItemId = 915
		}
	},
	{
		SecurityKey = "69eefa8196fc3426bc6e2cb72d8ca686",
		Id = {
			Type = "NonFruitItem",
			StorageKey = "Ring of the Outlaw III",
			ItemId = 916
		}
	},
	{
		SecurityKey = "75006505caa13f0d91312ab99aac87f1",
		Id = {
			Type = "NonFruitItem",
			StorageKey = "Ring of Spirit III",
			ItemId = 917
		}
	},
	{
		SecurityKey = "7e54d7c55a3a4a88b8779dabba9f00a9",
		Id = {
			Type = "NonFruitItem",
			StorageKey = "Ring of Striking III",
			ItemId = 918
		}
	},
	{
		SecurityKey = "df15c33d9c65a8833d9089c499e0b043",
		Id = {
			Type = "NonFruitItem",
			StorageKey = "Ring of the Vanguard III",
			ItemId = 919
		}
	},
	{
		SecurityKey = "3126f13b8dc59e5ddcbf6b91c86f303a",
		Id = {
			Type = "NonFruitItem",
			StorageKey = "Ring of the Arcanist III",
			ItemId = 920
		}
	},
	{
		SecurityKey = "1e33961241eb4e243da9b0e18c27ce1e",
		Id = {
			Type = "NonFruitItem",
			StorageKey = "Ring of Renewal III",
			ItemId = 921
		}
	},
	{
		SecurityKey = "1bbcc8b819bb2a063c7d676c82ff3b07",
		Id = {
			Type = "NonFruitItem",
			StorageKey = "Ring of Twin Blades III",
			ItemId = 922
		}
	},
	{
		SecurityKey = "6dee58d21d756363e6b577c8cff60c2e",
		Id = {
			Type = "NonFruitItem",
			StorageKey = "Ring of Steelheart III",
			ItemId = 923
		}
	},
	{
		SecurityKey = "09f8fcbbeffc4d523d0cfa4ea9eb4249",
		Id = {
			Type = "NonFruitItem",
			StorageKey = "Ring of Carving IV",
			ItemId = 924
		}
	},
	{
		SecurityKey = "1b513995ddc13918cabb2c4f73c8b14e",
		Id = {
			Type = "NonFruitItem",
			StorageKey = "Ring of Essence IV",
			ItemId = 925
		}
	},
	{
		SecurityKey = "71542b696b2d850abba31234baf4f2d0",
		Id = {
			Type = "NonFruitItem",
			StorageKey = "Ring of Might IV",
			ItemId = 926
		}
	},
	{
		SecurityKey = "5666b8af74f7eefd29f7e3206b244328",
		Id = {
			Type = "NonFruitItem",
			StorageKey = "Ring of the Outlaw IV",
			ItemId = 927
		}
	},
	{
		SecurityKey = "95a66b44fbed9570960ad3fbc1314118",
		Id = {
			Type = "NonFruitItem",
			StorageKey = "Ring of Spirit IV",
			ItemId = 928
		}
	},
	{
		SecurityKey = "9e5a945ec03aa0abae7c1c1a6621cf6a",
		Id = {
			Type = "NonFruitItem",
			StorageKey = "Ring of Striking IV",
			ItemId = 929
		}
	},
	{
		SecurityKey = "df42764227070de32510c0ba33d691f1",
		Id = {
			Type = "NonFruitItem",
			StorageKey = "Ring of the Vanguard IV",
			ItemId = 930
		}
	},
	{
		SecurityKey = "51d9626815635718c5be3e5900998b56",
		Id = {
			Type = "NonFruitItem",
			StorageKey = "Ring of the Arcanist IV",
			ItemId = 931
		}
	},
	{
		SecurityKey = "75b2dd0d1afc5de40c2a5ba7d7a84579",
		Id = {
			Type = "NonFruitItem",
			StorageKey = "Ring of Renewal IV",
			ItemId = 932
		}
	},
	{
		SecurityKey = "4bb6f53f108a55f6c6902e52d79d1765",
		Id = {
			Type = "NonFruitItem",
			StorageKey = "Ring of Twin Blades IV",
			ItemId = 933
		}
	},
	{
		SecurityKey = "521391067e1037f664a351ea705548ee",
		Id = {
			Type = "NonFruitItem",
			StorageKey = "Ring of Steelheart IV",
			ItemId = 934
		}
	},
	{
		SecurityKey = "26ef3ff7063bf3205dca463606c6eb8f",
		Id = {
			Type = "CurrencyBag",
			StorageKey = "200 Simulation Data",
			ItemId = 935
		}
	},
	{
		SecurityKey = "7c60cf42e14252f57dfb80c3688b6c80",
		Id = {
			Type = "CurrencyBag",
			StorageKey = "1000 Simulation Data",
			ItemId = 936
		}
	},
	{
		SecurityKey = "1f7699349731543a1de6c98015295469",
		Id = {
			Type = "CurrencyBag",
			StorageKey = "2700 Simulation Data",
			ItemId = 937
		}
	},
	{
		SecurityKey = "547f66a2c731cf1dbc15ec6f7bd878aa",
		Id = {
			Type = "CurrencyBag",
			StorageKey = "6000 Simulation Data",
			ItemId = 938
		}
	},
	{
		SecurityKey = "91220fba7c03c98a38a4179dfd409307",
		Id = {
			Type = "CurrencyBag",
			StorageKey = "10000 Simulation Data",
			ItemId = 939
		}
	},
	{
		SecurityKey = "442475144a2a476de4b9b38559184e2f",
		Id = {
			Type = "StorageIdOnly",
			StorageKey = "WSTDSKINemerald",
			ItemId = 940
		}
	},
	{
		SecurityKey = "4c90db85a53ebaeb2f0c1050cbd627e4",
		Id = {
			Type = "StorageIdOnly",
			StorageKey = "WSTDSKINyellow",
			ItemId = 941
		}
	},
	{
		SecurityKey = "4e015854508781d83db65d08f2d034b9",
		Id = {
			Type = "StorageIdOnly",
			StorageKey = "WSTDSKINvioletnight",
			ItemId = 942
		}
	},
	{
		SecurityKey = "9e97aa1785eb5e597526777078bccda0",
		Id = {
			Type = "StorageIdOnly",
			StorageKey = "Blue Jeans",
			ItemId = 943
		}
	},
	{
		SecurityKey = "d20de9dc59f70ff9c75b2306523fb10d",
		Id = {
			Type = "StorageIdOnly",
			StorageKey = "Orange Soda",
			ItemId = 944
		}
	},
	{
		SecurityKey = "683cd3aff73455f5e865278ca2c36415",
		Id = {
			Type = "StorageIdOnly",
			StorageKey = "WSTDSKINfrostbite",
			ItemId = 945
		}
	},
	{
		SecurityKey = "dcbab0fa37a8e3cfdac344dd1bb9e04a",
		Id = {
			Type = "StorageIdOnly",
			StorageKey = "Fiery Rose",
			ItemId = 946
		}
	},
	{
		SecurityKey = "c7267d6a9db2831f4cc725b4d36df58f",
		Id = {
			Type = "StorageIdOnly",
			StorageKey = "ESTDSKINblack",
			ItemId = 947
		}
	},
	{
		SecurityKey = "72bb09d2bc2ff2c9323724d8001b8b22",
		Id = {
			Type = "StorageIdOnly",
			StorageKey = "ESTDSKINember",
			ItemId = 948
		}
	},
	{
		SecurityKey = "6bced066acb494843d83bf32acc01fd0",
		Id = {
			Type = "StorageIdOnly",
			StorageKey = "Plump Purple",
			ItemId = 949
		}
	},
	{
		SecurityKey = "3ed83659ce2a2f8a341ff79b9cd8181c",
		Id = {
			Type = "StorageIdOnly",
			StorageKey = "Kitsune",
			ItemId = 950
		}
	},
	{
		SecurityKey = "c5e3a39f603821b584b8a58d98732e93",
		Id = {
			Type = "StorageIdOnly",
			StorageKey = "ESTDSKINyellow",
			ItemId = 951
		}
	},
	{
		SecurityKey = "37ae8fffadd9c2fc6337a5d3430cea26",
		Id = {
			Type = "StorageIdOnly",
			StorageKey = "WSTDSKINphoenixsky",
			ItemId = 952
		}
	},
	{
		SecurityKey = "d0f9737c8a486aeb357d60251dac235c",
		Id = {
			Type = "StorageIdOnly",
			StorageKey = "WSTDSKINblue",
			ItemId = 953
		}
	},
	{
		SecurityKey = "d9b1ff7cd9a70f7cc384d269962d0f2c",
		Id = {
			Type = "StorageIdOnly",
			StorageKey = "Heat Wave",
			ItemId = 954
		}
	},
	{
		SecurityKey = "d2b6dfcf1dfb9a45b8a5774abefbe17a",
		Id = {
			Type = "StorageIdOnly",
			StorageKey = "WSTDSKINeclipse",
			ItemId = 955
		}
	},
	{
		SecurityKey = "ebc4f1fecc8dbd79aa5969aa9ef2cb50",
		Id = {
			Type = "StorageIdOnly",
			StorageKey = "ESTDSKINgreen",
			ItemId = 956
		}
	},
	{
		SecurityKey = "c52c99a0e8432e16fd4dd4a6cc01f1d2",
		Id = {
			Type = "StorageIdOnly",
			StorageKey = "ESTDSKINbloodmoon",
			ItemId = 957
		}
	},
	{
		SecurityKey = "5b059d1bffa681e9f55e7cccdc958345",
		Id = {
			Type = "StorageIdOnly",
			StorageKey = "ESTDSKINphoenixsky",
			ItemId = 958
		}
	},
	{
		SecurityKey = "bc6311a7ad262930b8577ed6947de578",
		Id = {
			Type = "StorageIdOnly",
			StorageKey = "Bright Yellow",
			ItemId = 959
		}
	},
	{
		SecurityKey = "570b76904c25430a69efdc00a53558b9",
		Id = {
			Type = "StorageIdOnly",
			StorageKey = "Yellow Sunshine",
			ItemId = 960
		}
	},
	{
		SecurityKey = "2c1a8f462e2bd50778d5c3c03a977db1",
		Id = {
			Type = "StorageIdOnly",
			StorageKey = "Snow White",
			ItemId = 961
		}
	},
	{
		SecurityKey = "f825921b53a12178c19e4a696cbae902",
		Id = {
			Type = "StorageIdOnly",
			StorageKey = "WSTDSKINblack",
			ItemId = 962
		}
	},
	{
		SecurityKey = "95d32f7578c63398a05df6fa05b61911",
		Id = {
			Type = "StorageIdOnly",
			StorageKey = "Dragon",
			ItemId = 963
		}
	},
	{
		SecurityKey = "b174167389b0882ffcf0e32ce1437f54",
		Id = {
			Type = "StorageIdOnly",
			StorageKey = "Green Lizard",
			ItemId = 964
		}
	},
	{
		SecurityKey = "6e982972b3b79a1ac488cee77bb6dc9c",
		Id = {
			Type = "StorageIdOnly",
			StorageKey = "ESTDSKINeclipse",
			ItemId = 965
		}
	},
	{
		SecurityKey = "047a7393386cf684b7d4c9bd83862229",
		Id = {
			Type = "StorageIdOnly",
			StorageKey = "Aquamarine",
			ItemId = 966
		}
	},
	{
		SecurityKey = "6846da469e39a65c5992504d979ed1c6",
		Id = {
			Type = "StorageIdOnly",
			StorageKey = "ESTDSKINblue",
			ItemId = 967
		}
	},
	{
		SecurityKey = "a2a14005d6c84fcd569cf064a17763f2",
		Id = {
			Type = "StorageIdOnly",
			StorageKey = "Light Pink",
			ItemId = 968
		}
	},
	{
		SecurityKey = "40483b966a3a27bd9d0dba336cdb36c6",
		Id = {
			Type = "StorageIdOnly",
			StorageKey = "Rainbow Saviour",
			ItemId = 969
		}
	},
	{
		SecurityKey = "6cf95b40ba5ab5d670a5a50059f8b539",
		Id = {
			Type = "StorageIdOnly",
			StorageKey = "WSTDSKINbloodmoon",
			ItemId = 970
		}
	},
	{
		SecurityKey = "79cb2076d856b58680d16bb83e30aecb",
		Id = {
			Type = "StorageIdOnly",
			StorageKey = "Pure Red",
			ItemId = 971
		}
	},
	{
		SecurityKey = "678270ee3c1530b01737aaacc4fc75ae",
		Id = {
			Type = "StorageIdOnly",
			StorageKey = "Absolute Zero",
			ItemId = 972
		}
	},
	{
		SecurityKey = "e4b37be8d2fe7e1b18138982c5cca90b",
		Id = {
			Type = "StorageIdOnly",
			StorageKey = "WSTDSKINgreen",
			ItemId = 973
		}
	},
	{
		SecurityKey = "f164620e088d68303593067e6b771bae",
		Id = {
			Type = "StorageIdOnly",
			StorageKey = "ESTDSKINfrostbite",
			ItemId = 974
		}
	},
	{
		SecurityKey = "bf5375a63306580f30951770841012e3",
		Id = {
			Type = "StorageIdOnly",
			StorageKey = "ESTDSKINpurple",
			ItemId = 975
		}
	},
	{
		SecurityKey = "b263f914201ebf4639c8e1a1cbe0896b",
		Id = {
			Type = "StorageIdOnly",
			StorageKey = "Winter Sky",
			ItemId = 976
		}
	},
	{
		SecurityKey = "b33efbeb9777f1707c5e22bc3bb28529",
		Id = {
			Type = "StorageIdOnly",
			StorageKey = "WSTDSKINpurple",
			ItemId = 977
		}
	},
	{
		SecurityKey = "a1a439b6ee55c5113b0de6b6b8d7963f",
		Id = {
			Type = "StorageIdOnly",
			StorageKey = "WSTDSKINred",
			ItemId = 978
		}
	},
	{
		SecurityKey = "464be2f172551243525211eec4c6fa24",
		Id = {
			Type = "StorageIdOnly",
			StorageKey = "WSTDSKINorange",
			ItemId = 979
		}
	},
	{
		SecurityKey = "b0ea2713fa114d16dde6156f630b74bb",
		Id = {
			Type = "StorageIdOnly",
			StorageKey = "Slimy Green",
			ItemId = 980
		}
	},
	{
		SecurityKey = "f7896554deb3d39871b4939a9532e0ce",
		Id = {
			Type = "StorageIdOnly",
			StorageKey = "ESTDSKINorange",
			ItemId = 981
		}
	},
	{
		SecurityKey = "116e7b09663eb7f0cae693519e07951e",
		Id = {
			Type = "StorageIdOnly",
			StorageKey = "WSTDSKINember",
			ItemId = 982
		}
	},
	{
		SecurityKey = "a2feb29553b9af40f38c2e7c2f81ea75",
		Id = {
			Type = "StorageIdOnly",
			StorageKey = "ESTDSKINvioletnight",
			ItemId = 983
		}
	},
	{
		SecurityKey = "336af3745650e7a2089e5070b06db4b7",
		Id = {
			Type = "StorageIdOnly",
			StorageKey = "ESTDSKINemerald",
			ItemId = 984
		}
	},
	{
		SecurityKey = "848b7502030ff5a0a5c832e3bfd51d20",
		Id = {
			Type = "StorageIdOnly",
			StorageKey = "ESTDSKINred",
			ItemId = 985
		}
	},
	{
		SecurityKey = "8f90cc575a1b21f9ad72bf6377ff1d2e",
		Id = {
			Type = "StorageIdOnly",
			StorageKey = "PhoenixSkyChromaticDragon",
			ItemId = 986
		}
	},
	{
		SecurityKey = "3e8aa07f7b3ef8357ae5c5fedd6e1479",
		Id = {
			Type = "StorageIdOnly",
			StorageKey = "EclipseChromaticDragon",
			ItemId = 987
		}
	},
	{
		SecurityKey = "f8161c35775e38250d9fed250c53a677",
		Id = {
			Type = "StorageIdOnly",
			StorageKey = "VioletNightChromaticDragon",
			ItemId = 988
		}
	},
	{
		SecurityKey = "21c4c9aed01684ab7a0a506bb6ed8b4d",
		Id = {
			Type = "StorageIdOnly",
			StorageKey = "EmberChromaticDragon",
			ItemId = 989
		}
	},
	{
		SecurityKey = "83d8bc15936a5e200ec356733b8da673",
		Id = {
			Type = "StorageIdOnly",
			StorageKey = "BloodmoonChromaticDragon",
			ItemId = 990
		}
	},
	{
		SecurityKey = "6a27ea70f2106d698fa3f5a9f4761023",
		Id = {
			Type = "StorageIdOnly",
			StorageKey = "FALCSKINparrot",
			ItemId = 991
		}
	},
	{
		SecurityKey = "49d2e207d240bbca63d24628bea4acd4",
		Id = {
			Type = "StorageIdOnly",
			StorageKey = "FALCSKINgoldmoss",
			ItemId = 992
		}
	},
	{
		SecurityKey = "fb8c9b71ac724c596df3e56dc68674ae",
		Id = {
			Type = "StorageIdOnly",
			StorageKey = "FALCSKINeagle",
			ItemId = 993
		}
	},
	{
		SecurityKey = "1053955f801b3e0359178245f3671fb9",
		Id = {
			Type = "StorageIdOnly",
			StorageKey = "FALCSKINvelvet",
			ItemId = 994
		}
	},
	{
		SecurityKey = "ef266a29299da7f754e57beba285f5eb",
		Id = {
			Type = "StorageIdOnly",
			StorageKey = "FALCSKINfalcon",
			ItemId = 995
		}
	},
	{
		SecurityKey = "dae5daaa41c95da7c7cc8b435aa12784",
		Id = {
			Type = "StorageIdOnly",
			StorageKey = "FALCSKINocreamsicle",
			ItemId = 996
		}
	},
	{
		SecurityKey = "0e81dc57ad883a722836af8c574a97f7",
		Id = {
			Type = "StorageIdOnly",
			StorageKey = "FALCSKINbluesky",
			ItemId = 997
		}
	},
	{
		SecurityKey = "b42e14f642614087e1c4c25932f5b7b6",
		Id = {
			Type = "StorageIdOnly",
			StorageKey = "LIGHTNINGSKINyellow",
			ItemId = 998
		}
	},
	{
		SecurityKey = "ef936bbc46bb718fd86764b64f7d30ae",
		Id = {
			Type = "StorageIdOnly",
			StorageKey = "DIAMONDSKINblue",
			ItemId = 999
		}
	},
	{
		SecurityKey = "4829b7a0b725b34a1d34db64887d5779",
		Id = {
			Type = "StorageIdOnly",
			StorageKey = "PORTALSKINpink",
			ItemId = 1000
		}
	},
	{
		SecurityKey = "b69ebaf192543a6402a4769ce7a7695e",
		Id = {
			Type = "StorageIdOnly",
			StorageKey = "DIAMONDSKINred",
			ItemId = 1001
		}
	},
	{
		SecurityKey = "6d7abb6c3e22841cbbd6034c2fcae715",
		Id = {
			Type = "StorageIdOnly",
			StorageKey = "DIAMONDSKINgreen",
			ItemId = 1002
		}
	},
	{
		SecurityKey = "ac6e5985c891814dd6ab3133884e4a18",
		Id = {
			Type = "StorageIdOnly",
			StorageKey = "PORTALSKINorange",
			ItemId = 1003
		}
	},
	{
		SecurityKey = "28c8afaf789bdf7e2d714654d272d6f6",
		Id = {
			Type = "StorageIdOnly",
			StorageKey = "LIGHTNINGSKINblue",
			ItemId = 1004
		}
	},
	{
		SecurityKey = "a535f62b8f752a5eb7374c6e74463fe4",
		Id = {
			Type = "StorageIdOnly",
			StorageKey = "LIGHTNINGSKINpurple",
			ItemId = 1005
		}
	},
	{
		SecurityKey = "15d900187d18d5ef6f066a93cfc9b857",
		Id = {
			Type = "StorageIdOnly",
			StorageKey = "LIGHTNINGSKINgreen",
			ItemId = 1006
		}
	},
	{
		SecurityKey = "fcca15b9f9898b16e599b02dd116ff85",
		Id = {
			Type = "StorageIdOnly",
			StorageKey = "PORTALSKINblue",
			ItemId = 1007
		}
	},
	{
		SecurityKey = "5922a93d110609e6c7368e4919f12e45",
		Id = {
			Type = "StorageIdOnly",
			StorageKey = "DIAMONDSKINpoudretteite",
			ItemId = 1008
		}
	},
	{
		SecurityKey = "1587de1d5f1662b4a9cd44accc219061",
		Id = {
			Type = "StorageIdOnly",
			StorageKey = "DIAMONDSKINtopaz",
			ItemId = 1009
		}
	},
	{
		SecurityKey = "083397a07238678a8201eee1150f00c1",
		Id = {
			Type = "StorageIdOnly",
			StorageKey = "PAINSKINdeepblue",
			ItemId = 1010
		}
	},
	{
		SecurityKey = "ef3fcd21fad77f4382aada55597fa208",
		Id = {
			Type = "StorageIdOnly",
			StorageKey = "PAINSKINyellow",
			ItemId = 1011
		}
	},
	{
		SecurityKey = "cef11f35488798706f8be365c3b28adf",
		Id = {
			Type = "StorageIdOnly",
			StorageKey = "PAINSKINpinkblue",
			ItemId = 1012
		}
	},
	{
		SecurityKey = "ea4dafd859128314bcfc8af330fd474a",
		Id = {
			Type = "StorageIdOnly",
			StorageKey = "PAINSKINdefault",
			ItemId = 1013
		}
	},
	{
		SecurityKey = "255a0aa6ed3d69118e31be319dd7c4ff",
		Id = {
			Type = "StorageIdOnly",
			StorageKey = "PAINSKINorange",
			ItemId = 1014
		}
	},
	{
		SecurityKey = "dec19c3b4fcef9df5e2b5a22e0ea2a65",
		Id = {
			Type = "StorageIdOnly",
			StorageKey = "PAINSKINred",
			ItemId = 1015
		}
	},
	{
		SecurityKey = "b1a4476cc71ccad5b7591cd8f4c6b67b",
		Id = {
			Type = "StorageIdOnly",
			StorageKey = "PAINSKINgreen",
			ItemId = 1016
		}
	},
	{
		SecurityKey = "c16fc586859d08743c2f21d6efea0973",
		Id = {
			Type = "StorageIdOnly",
			StorageKey = "FALCSKINmatrix",
			ItemId = 1017
		}
	},
	{
		SecurityKey = "688bff46fbf772a3e2aa8229310079c7",
		Id = {
			Type = "StorageIdOnly",
			StorageKey = "FALCSKINglacier",
			ItemId = 1018
		}
	},
	{
		SecurityKey = "8d98f691787d52fd8ac391e9fd8e6580",
		Id = {
			Type = "StorageIdOnly",
			StorageKey = "PAINSKINcelestial",
			ItemId = 1019
		}
	},
	{
		SecurityKey = "347e1c3b940fdacadfba036dba71a408",
		Id = {
			Type = "StorageIdOnly",
			StorageKey = "FALCSKINrequiem",
			ItemId = 1020
		}
	},
	{
		SecurityKey = "b361961c7258a6202db797864730df55",
		Id = {
			Type = "StorageIdOnly",
			StorageKey = "BOMBSKINnuclear",
			ItemId = 1021
		}
	},
	{
		SecurityKey = "f6e902dace097b48680423af09e655f6",
		Id = {
			Type = "StorageIdOnly",
			StorageKey = "BOMBSKINdryice",
			ItemId = 1022
		}
	},
	{
		SecurityKey = "7a5956f677e81b27968bcfd17ecd36f1",
		Id = {
			Type = "StorageIdOnly",
			StorageKey = "BOMBSKINbloodfire",
			ItemId = 1023
		}
	},
	{
		SecurityKey = "186edc7191686fbe2f3ce2cea7438aa2",
		Id = {
			Type = "StorageIdOnly",
			StorageKey = "BOMBSKINdefault",
			ItemId = 1024
		}
	},
	{
		SecurityKey = "9e7cc97855287e4729511fa902b82738",
		Id = {
			Type = "StorageIdOnly",
			StorageKey = "BOMBSKINthermite",
			ItemId = 1025
		}
	},
	{
		SecurityKey = "11c2e147be7af119412546063f65728f",
		Id = {
			Type = "StorageIdOnly",
			StorageKey = "BOMBSKINazura",
			ItemId = 1026
		}
	},
	{
		SecurityKey = "2180861ab2f6682ad2a1e84affda5c5d",
		Id = {
			Type = "StorageIdOnly",
			StorageKey = "BOMBSKINcelebration",
			ItemId = 1027
		}
	},
	{
		SecurityKey = "77b58d60c6690a8a2a49bee01e3e1730",
		Id = {
			Type = "StorageIdOnly",
			StorageKey = "LIGHTNINGSKINred",
			ItemId = 1028
		}
	},
	{
		SecurityKey = "52424039559f93795f2977c6d814c070",
		Id = {
			Type = "StorageIdOnly",
			StorageKey = "PAINSKINsuperspirit",
			ItemId = 1029
		}
	},
	{
		SecurityKey = "39a2b0bfae9a08a34a9ed6745275711e",
		Id = {
			Type = "StorageIdOnly",
			StorageKey = "TIGERMUTWerewolf",
			ItemId = 1030
		}
	},
	{
		SecurityKey = "e992d62f442b72b7d433d8893187d264",
		Id = {
			Type = "StorageIdOnly",
			StorageKey = "TIGERMUTTiger",
			ItemId = 1031
		}
	},
	{
		SecurityKey = "e1c43c795858bcfa6a4034a6687632e7",
		Id = {
			Type = "StorageIdOnly",
			StorageKey = "TIGERSKINdefault",
			ItemId = 1032
		}
	},
	{
		SecurityKey = "90941358eb533ec2ed2e7e8934100343",
		Id = {
			Type = "StorageIdOnly",
			StorageKey = "TIGERSKINwerewolf",
			ItemId = 1033
		}
	},
	{
		SecurityKey = "b18c22318552313e991077b56ed82ee8",
		Id = {
			Type = "StorageIdOnly",
			StorageKey = "Oni Aura",
			ItemId = 1034
		}
	},
	{
		SecurityKey = "85cbfe07a85fb9e58d3509575d28843d",
		Id = {
			Type = "StorageIdOnly",
			StorageKey = "Celestial Aura",
			ItemId = 1035
		}
	},
	{
		SecurityKey = "5aef8a80e8a6defc34c26743838da846",
		Id = {
			Type = "SaleBundle",
			StorageKey = "Holiday Bundle 2025",
			ItemId = 1036
		}
	},
	{
		SecurityKey = "1cd6de5d8f559fda4df199a39c9f3113",
		Id = {
			Type = "SaleBundle",
			StorageKey = "Ultimate Bundle 2025",
			ItemId = 1037
		}
	},
	{
		SecurityKey = "bf21161020aa4d33eb148f7c6516580b",
		Id = {
			Type = "SaleBundle",
			StorageKey = "Fox Spirit Bundle",
			ItemId = 1038
		}
	},
	{
		SecurityKey = "52c528bc435ce8346194cbdf42cef5e7",
		Id = {
			Type = "NonFruitItem",
			StorageKey = "Frosty Helmet",
			ItemId = 1039
		}
	},
	{
		SecurityKey = "2dec8c4dd65941be8bdfd970b2fbef08",
		Id = {
			Type = "NonFruitItem",
			StorageKey = "Red Ribbon",
			ItemId = 1040
		}
	},
	{
		SecurityKey = "33f559e640076b15ba1b7370ae8b47a1",
		Id = {
			Type = "FruitWithMutation",
			StorageKey = "Empyrean (Kitsune)-Empyrean (Kitsune)",
			ItemId = 1041
		}
	},
	{
		SecurityKey = "43e8bd0308e693a5705e45bb0c87f559",
		Id = {
			Type = "FruitWithSkin",
			StorageKey = "Galaxy Empyrean Kitsune",
			ItemId = 1042
		}
	},
	{
		SecurityKey = "950968227fb93bd20c048dae688edc5a",
		Id = {
			Type = "FruitMutation",
			StorageKey = "KITSUNEMUTKitsune",
			ItemId = 1043
		}
	},
	{
		SecurityKey = "3d1441599be39f034e7cb8e2874dd255",
		Id = {
			Type = "FruitMutation",
			StorageKey = "KITSUNEMUTKyukon",
			ItemId = 1044
		}
	},
	{
		SecurityKey = "ee5b271775567a8abd58ce7444d4baf7",
		Id = {
			Type = "FruitSkin",
			StorageKey = "KYUKONSKINcrimson",
			ItemId = 1045
		}
	},
	{
		SecurityKey = "26910aa78df8430fdb8d0f561c31bb9c",
		Id = {
			Type = "FruitSkin",
			StorageKey = "KYUKONSKINgalaxy",
			ItemId = 1046
		}
	},
	{
		SecurityKey = "db87374ea85cf1037ad7e3c7258fc094",
		Id = {
			Type = "FruitWithSkin",
			StorageKey = "Ember Dragon (West)",
			ItemId = 1047
		}
	},
	{
		SecurityKey = "9b0abab442b13f4345952449b9e64c9d",
		Id = {
			Type = "FruitWithSkin",
			StorageKey = "Divine Portal",
			ItemId = 1048
		}
	},
	{
		SecurityKey = "1e5284927bd4f18455bfdbaba3fbe6d9",
		Id = {
			Type = "FruitSkin",
			StorageKey = "PORTALSKINdivine",
			ItemId = 1049
		}
	},
	{
		SecurityKey = "cee8cf211003c8c7122cc86796ea2e4f",
		Id = {
			Type = "SpecialProduct",
			StorageKey = "x1 Premium Holiday 2025 Box",
			ItemId = 1050
		}
	},
	{
		SecurityKey = "049c7d24203280de724a293db1efbe5e",
		Id = {
			Type = "SpecialProduct",
			StorageKey = "x3 Premium Holiday 2025 Box",
			ItemId = 1051
		}
	},
	{
		SecurityKey = "bd3c659d63068931327f38288a8c21e0",
		Id = {
			Type = "SpecialProduct",
			StorageKey = "x10 Premium Holiday 2025 Box",
			ItemId = 1052
		}
	},
	{
		SecurityKey = "3efea21880f3cc58c51c998fe3247d10",
		Id = {
			Type = "StorageIdOnly",
			StorageKey = "KITSUNEMUTKitsune",
			ItemId = 1053
		}
	},
	{
		SecurityKey = "49c1d3cc40c2e2037797352506633672",
		Id = {
			Type = "StorageIdOnly",
			StorageKey = "KITSUNEMUTKyukon",
			ItemId = 1054
		}
	},
	{
		SecurityKey = "474f831efb89d892afc439b3f075fbdb",
		Id = {
			Type = "StorageIdOnly",
			StorageKey = "KYUKONSKINcrimson",
			ItemId = 1055
		}
	},
	{
		SecurityKey = "7a6e22b063049c7642e9464f5e6bcf65",
		Id = {
			Type = "StorageIdOnly",
			StorageKey = "KYUKONSKINgalaxy",
			ItemId = 1056
		}
	},
	{
		SecurityKey = "e08e2db98d75f341687018f7280a230f",
		Id = {
			Type = "StorageIdOnly",
			StorageKey = "PORTALSKINdivine",
			ItemId = 1057
		}
	},
	{
		SecurityKey = "f21f18b17adc2d32ab6b929be391fad8",
		Id = {
			Type = "Redeemable",
			StorageKey = "Werewolf (Tiger)-Werewolf (Tiger)",
			ItemId = 1058
		}
	},
	{
		SecurityKey = "700f3c4e7cb655163942913517fb1bcf",
		Id = {
			Type = "Redeemable",
			StorageKey = "Empyrean (Kitsune)-Empyrean (Kitsune)",
			ItemId = 1059
		}
	},
	{
		SecurityKey = "d9b409145f64df5b719427f1b5d35f01",
		Id = {
			Type = "MutatedFruit",
			StorageKey = "Fiend (Yeti)-Fiend (Yeti)",
			ItemId = 1060
		}
	},
	{
		SecurityKey = "fed5e478db1a04ef4bd978c426d69bce",
		Id = {
			Type = "FruitMutation",
			StorageKey = "YETIMUTFiend",
			ItemId = 1061
		}
	},
	{
		SecurityKey = "9b472de6e6057f77ed9fd47e6522a298",
		Id = {
			Type = "FruitMutation",
			StorageKey = "YETIMUTYeti",
			ItemId = 1062
		}
	},
	{
		SecurityKey = "4ab3dca455501ecd3b4aa0b84da0acee",
		Id = {
			Type = "FruitSkin",
			StorageKey = "YETISKINfiend",
			ItemId = 1063
		}
	},
	{
		SecurityKey = "7f635b73cb539b4679e424bdaa09d140",
		Id = {
			Type = "FruitSkin",
			StorageKey = "YETISKINdefault",
			ItemId = 1064
		}
	},
	{
		SecurityKey = "d6d376f9b02880592573918d89007056",
		Id = {
			Type = "Redeemable",
			StorageKey = "Fiend (Yeti)-Fiend (Yeti)",
			ItemId = 1065
		}
	},
	{
		SecurityKey = "0f066a8b7b6663b0bc72a076ff31d035",
		Id = {
			Type = "Redeemable",
			StorageKey = "YETIMUTFiend",
			ItemId = 1066
		}
	},
	{
		SecurityKey = "a31257eb747e53bf261711ac0f07d7df",
		Id = {
			Type = "Redeemable",
			StorageKey = "YETIMUTYeti",
			ItemId = 1067
		}
	},
	{
		SecurityKey = "cff03f1040e3212345cd3c364fca1930",
		Id = {
			Type = "Redeemable",
			StorageKey = "YETISKINfiend",
			ItemId = 1068
		}
	},
	{
		SecurityKey = "8170e039468bb71c6ab20065f1844d6e",
		Id = {
			Type = "Redeemable",
			StorageKey = "YETISKINdefault",
			ItemId = 1069
		}
	},
	{
		SecurityKey = "b954aea51cab7582a9c6914a5f70017e",
		Id = {
			Type = "Redeemable",
			StorageKey = "Bloodfrost Bundle",
			ItemId = 1070
		}
	},
	{
		SecurityKey = "336e6e5d42b3b1a860c65fe1582e3b7e",
		Id = {
			Type = "Item",
			StorageKey = "Romantic Bouquet",
			ItemId = 1071
		}
	},
	{
		SecurityKey = "163947a0f299895529441bc7263c459c",
		Id = {
			Type = "Item",
			StorageKey = "Cupid's Top Hat",
			ItemId = 1072
		}
	},
	{
		SecurityKey = "952841cc4cd1d8c7b0d1dbc7ef26d53e",
		Id = {
			Type = "Title",
			StorageKey = "True Egglord",
			ItemId = 1073
		}
	},
	{
		SecurityKey = "8e4713488955582a8584786194c31fd7",
		Id = {
			Type = "Material",
			StorageKey = "Candy Egg",
			ItemId = 1074
		}
	},
	{
		SecurityKey = "282696d884d59c095f2ca1df52da6e04",
		Id = {
			Type = "Redeemable",
			StorageKey = "GamepassBundle",
			ItemId = 1075
		}
	},
	{
		SecurityKey = "fd4a8e5e58945357c826b0ad687fff5e",
		Id = {
			Type = "Redeemable",
			StorageKey = "Easter2026Bundle",
			ItemId = 1076
		}
	},
	{
		SecurityKey = "748ab7fe9528a722b6c623a42ee72672",
		Id = {
			Type = "Redeemable",
			StorageKey = "RareEasterGift26",
			ItemId = 1077
		}
	},
	{
		SecurityKey = "a2c8e5781e677ca43fa9238fad6c59c4",
		Id = {
			Type = "Redeemable",
			StorageKey = "LegendaryEasterGift26",
			ItemId = 1078
		}
	},
	{
		SecurityKey = "4cbb05d46cdb28e86b7a080b83c5a024",
		Id = {
			Type = "Item",
			StorageKey = "Easter Bunny Cape",
			ItemId = 1079
		}
	},
	{
		SecurityKey = "e86188b71a535e0a8d05c658394a29c1",
		Id = {
			Type = "Item",
			StorageKey = "Cracked Egg Helmet",
			ItemId = 1080
		}
	},
	{
		SecurityKey = "20c8f6507942746e6d5ccb9a5dc5febf",
		Id = {
			Type = "Material",
			StorageKey = "Plastic Gravity-Gravity",
			ItemId = 1081
		}
	},
	{
		SecurityKey = "7a0b578d90cbacb0094817cb34ad5e84",
		Id = {
			Type = "Material",
			StorageKey = "Plastic Tiger-Tiger",
			ItemId = 1082
		}
	},
	{
		SecurityKey = "bdce123184cede3afc88d5e86564d1e0",
		Id = {
			Type = "Material",
			StorageKey = "Plastic Control-Control",
			ItemId = 1083
		}
	},
	{
		SecurityKey = "1a9c60d3a79d824389e5dfa71608d0f2",
		Id = {
			Type = "Material",
			StorageKey = "Plastic Venom-Venom",
			ItemId = 1084
		}
	},
	{
		SecurityKey = "0ff689ccdf435d264ecaca3c9589e0df",
		Id = {
			Type = "Material",
			StorageKey = "Plastic Shadow-Shadow",
			ItemId = 1085
		}
	},
	{
		SecurityKey = "80f319aac8b70c73a65ba6fbbaf44f5b",
		Id = {
			Type = "Material",
			StorageKey = "Plastic Spirit-Spirit",
			ItemId = 1086
		}
	},
	{
		SecurityKey = "093f97b3a99439442c35f6fa0dccdf92",
		Id = {
			Type = "Material",
			StorageKey = "Plastic Dough-Dough",
			ItemId = 1087
		}
	},
	{
		SecurityKey = "246b0dbd2e702ea11f86d5e455bf3b73",
		Id = {
			Type = "Material",
			StorageKey = "Plastic Mammoth-Mammoth",
			ItemId = 1088
		}
	},
	{
		SecurityKey = "c6feee5e419099704dbe0d2666fe2975",
		Id = {
			Type = "Material",
			StorageKey = "Plastic T-Rex-T-Rex",
			ItemId = 1089
		}
	},
	{
		SecurityKey = "f15c6301209d2306286bf539e5cd84c6",
		Id = {
			Type = "Material",
			StorageKey = "Plastic Gas-Gas",
			ItemId = 1090
		}
	},
	{
		SecurityKey = "29c2b44db821e9ff536ab39741327e1e",
		Id = {
			Type = "Material",
			StorageKey = "Plastic Kitsune-Kitsune",
			ItemId = 1091
		}
	},
	{
		SecurityKey = "e3f44f65b75687ec79dcc76618d5a279",
		Id = {
			Type = "Material",
			StorageKey = "Plastic Yeti-Yeti",
			ItemId = 1092
		}
	},
	{
		SecurityKey = "50595f04e54971cf97e23b1148fe12d1",
		Id = {
			Type = "Material",
			StorageKey = "Plastic Dragon (West)-Dragon (West)",
			ItemId = 1093
		}
	},
	{
		SecurityKey = "cfb7210cb83166ea9482ab0572f0ebd7",
		Id = {
			Type = "Material",
			StorageKey = "Plastic Dragon (East)-Dragon (East)",
			ItemId = 1094
		}
	},
	{
		SecurityKey = "490d94f030a126ae35965f7c94e11aad",
		Id = {
			Type = "Material",
			StorageKey = "Plastic Meme-Meme",
			ItemId = 1095
		}
	},
	{
		SecurityKey = "ad08ab50ccd884f5293af22dbd6a293d",
		Id = {
			Type = "AuraSkin",
			StorageKey = "Hacker Aura",
			ItemId = 1096
		}
	},
	{
		SecurityKey = "54f47da18bebf61d113404fef29f1e2f",
		Id = {
			Type = "Redeemable",
			StorageKey = "Hacker Aura",
			ItemId = 1097
		}
	},
	{
		SecurityKey = "56a3c5a655014a665bb3e82cf7331f0e",
		Id = {
			Type = "Fruit",
			StorageKey = "Meme-Meme",
			ItemId = 1098
		}
	},
	{
		SecurityKey = "7464c53a2a26feda926c3b2d30a86f04",
		Id = {
			Type = "Moveset",
			StorageKey = "Bisento",
			ItemId = 1099
		}
	},
	{
		SecurityKey = "06a23ab67767ab508b6dbbc88b780ffa",
		Id = {
			Type = "Moveset",
			StorageKey = "Triple Katana",
			ItemId = 1100
		}
	},
	{
		SecurityKey = "98e6b82c40b428353993106299917257",
		Id = {
			Type = "Moveset",
			StorageKey = "Refined Slingshot",
			ItemId = 1101
		}
	},
	{
		SecurityKey = "ed9c28094a23ba92e447335d8c8ccfa6",
		Id = {
			Type = "Moveset",
			StorageKey = "Dual Flintlock",
			ItemId = 1102
		}
	},
	{
		SecurityKey = "4b22e406f0e0bdc350b11f1e237ee73e",
		Id = {
			Type = "Moveset",
			StorageKey = "Musket",
			ItemId = 1103
		}
	},
	{
		SecurityKey = "f9a1aa5be906a79702a5814554f278d8",
		Id = {
			Type = "Tool",
			StorageKey = "Hidden Key",
			ItemId = 1104
		}
	},
	{
		SecurityKey = "6d1fe759a8037fd6e75435bb988bb532",
		Id = {
			Type = "Moveset",
			StorageKey = "Shark Saw",
			ItemId = 1105
		}
	},
	{
		SecurityKey = "29c8f9263d2925c902308424cc5958b9",
		Id = {
			Type = "Moveset",
			StorageKey = "Katana",
			ItemId = 1106
		}
	},
	{
		SecurityKey = "a7c0ec83bd5dd433ed75aeabbd0b9758",
		Id = {
			Type = "Moveset",
			StorageKey = "Iron Mace",
			ItemId = 1107
		}
	},
	{
		SecurityKey = "c894f42dc77de632d5ea1302021e38bd",
		Id = {
			Type = "Moveset",
			StorageKey = "Sanguine Art",
			ItemId = 1108
		}
	},
	{
		SecurityKey = "03e9b1a66207b311c80ab35901b6d948",
		Id = {
			Type = "Moveset",
			StorageKey = "Saber",
			ItemId = 1109
		}
	},
	{
		SecurityKey = "6d04238b6e082f44a617fc2fd41f8bb3",
		Id = {
			Type = "Moveset",
			StorageKey = "Flintlock",
			ItemId = 1110
		}
	},
	{
		SecurityKey = "0692bb31bbb0617e81957af3c54a977f",
		Id = {
			Type = "Moveset",
			StorageKey = "Dual Katana",
			ItemId = 1111
		}
	},
	{
		SecurityKey = "e8d36150776c46274f852f92147ef7a8",
		Id = {
			Type = "Moveset",
			StorageKey = "Cutlass",
			ItemId = 1112
		}
	},
	{
		SecurityKey = "a721bee32f62918714677d08478c6bd2",
		Id = {
			Type = "Moveset",
			StorageKey = "Combat",
			ItemId = 1113
		}
	},
	{
		SecurityKey = "f910ff63a26bd1330654536e7f53841c",
		Id = {
			Type = "Moveset",
			StorageKey = "Cannon",
			ItemId = 1114
		}
	},
	{
		SecurityKey = "a476dfab7864de452b5c144cfeca47e5",
		Id = {
			Type = "Moveset",
			StorageKey = "Wardens Sword",
			ItemId = 1115
		}
	},
	{
		SecurityKey = "78bf92652096c27cbec2ecb2408e731c",
		Id = {
			Type = "Moveset",
			StorageKey = "Pipe",
			ItemId = 1116
		}
	},
	{
		SecurityKey = "a3d48782546edba30e029e25e937537a",
		Id = {
			Type = "Moveset",
			StorageKey = "Dual-Headed Blade",
			ItemId = 1117
		}
	},
	{
		SecurityKey = "f337b483b5670b99feab9073342133aa",
		Id = {
			Type = "Tool",
			StorageKey = "_Black Leg",
			ItemId = 1118
		}
	},
	{
		SecurityKey = "38dcca1be8a1b2a6e1f0c69815b89979",
		Id = {
			Type = "Tool",
			StorageKey = "Black Leg",
			ItemId = 1119
		}
	},
	{
		SecurityKey = "cd2ce5a99903c8bd255c4622ae2cbf9f",
		Id = {
			Type = "Accessory",
			StorageKey = "Coat",
			ItemId = 1120
		}
	},
	{
		SecurityKey = "41d88cba5dbc9f7d7c693edcdc6a8b63",
		Id = {
			Type = "Accessory",
			StorageKey = "Pink Coat",
			ItemId = 1121
		}
	},
	{
		SecurityKey = "816916703fb876fb045899a68611f267",
		Id = {
			Type = "Tool",
			StorageKey = "Torch",
			ItemId = 1122
		}
	},
	{
		SecurityKey = "8ce1aaa94157ac7fb5eb19c5ae374fcd",
		Id = {
			Type = "Tool",
			StorageKey = "Cup",
			ItemId = 1123
		}
	},
	{
		SecurityKey = "c0c5f9800e49aba00636fc9196e230f3",
		Id = {
			Type = "Accessory",
			StorageKey = "Tomoe Ring",
			ItemId = 1124
		}
	},
	{
		SecurityKey = "800591b27bab368ea1aec0713e284f80",
		Id = {
			Type = "Accessory",
			StorageKey = "Black Cape",
			ItemId = 1125
		}
	},
	{
		SecurityKey = "e259bd48e140257c029566645dcf1a53",
		Id = {
			Type = "Accessory",
			StorageKey = "Swordsman Hat",
			ItemId = 1126
		}
	},
	{
		SecurityKey = "ba39d3ad47006baa42aaf057c5719f1a",
		Id = {
			Type = "Accessory",
			StorageKey = "Cool Shades",
			ItemId = 1127
		}
	},
	{
		SecurityKey = "dfbe69d90b9247b045b72a5583799a5e",
		Id = {
			Type = "Moveset",
			StorageKey = "Soul Cane",
			ItemId = 1128
		}
	},
	{
		SecurityKey = "c183ab25a7496e17760c935de4c01af5",
		Id = {
			Type = "Moveset",
			StorageKey = "Electro",
			ItemId = 1129
		}
	},
	{
		SecurityKey = "8504c13ab220e9596bcb9bc4617c8c0e",
		Id = {
			Type = "Moveset",
			StorageKey = "Magma Blaster",
			ItemId = 1130
		}
	},
	{
		SecurityKey = "80e8ef60f03c43a538f08e66d5b72a46",
		Id = {
			Type = "Moveset",
			StorageKey = "Trident",
			ItemId = 1131
		}
	},
	{
		SecurityKey = "d6ee5fbb58d3b5df37ed712688f24515",
		Id = {
			Type = "Moveset",
			StorageKey = "Pole (1st Form)",
			ItemId = 1132
		}
	},
	{
		SecurityKey = "a4b1a3776cd6041bdfd2454fd3875442",
		Id = {
			Type = "Moveset",
			StorageKey = "Bazooka",
			ItemId = 1133
		}
	},
	{
		SecurityKey = "badc85597d0c00e54e7ff1e5b62a1d5e",
		Id = {
			Type = "Moveset",
			StorageKey = "Fishman Karate",
			ItemId = 1134
		}
	},
	{
		SecurityKey = "27eaa55508c051e74bcf65218dd3ccdc",
		Id = {
			Type = "Accessory",
			StorageKey = "D.S. Coat",
			ItemId = 1135
		}
	},
	{
		SecurityKey = "0dd654e7cf9b7df323e2c61aa8140f30",
		Id = {
			Type = "Accessory",
			StorageKey = "Usoap's Hat",
			ItemId = 1136
		}
	},
	{
		SecurityKey = "ce51be6f6cd005719604fedda8a7ed62",
		Id = {
			Type = "Accessory",
			StorageKey = "Top Hat",
			ItemId = 1137
		}
	},
	{
		SecurityKey = "5de7c6ea5111a39f3989d3b203e8befe",
		Id = {
			Type = "Accessory",
			StorageKey = "Marine Cap",
			ItemId = 1138
		}
	},
	{
		SecurityKey = "eb858c8adad7a26a2881b903eb20116b",
		Id = {
			Type = "Accessory",
			StorageKey = "Warrior Helmet",
			ItemId = 1139
		}
	},
	{
		SecurityKey = "e1f47ce56dda0a196c57372568a46581",
		Id = {
			Type = "Accessory",
			StorageKey = "Choppa",
			ItemId = 1140
		}
	},
	{
		SecurityKey = "a488c1843faa8f73c3620a976e92d0ca",
		Id = {
			Type = "Moveset",
			StorageKey = "Gravity Blade",
			ItemId = 1141
		}
	},
	{
		SecurityKey = "1e53a665599ece6455582e92f177d24b",
		Id = {
			Type = "Moveset",
			StorageKey = "Shizu",
			ItemId = 1142
		}
	},
	{
		SecurityKey = "788cd59d7864c2d70647bc963ee37fa3",
		Id = {
			Type = "Moveset",
			StorageKey = "Longsword",
			ItemId = 1143
		}
	},
	{
		SecurityKey = "23fa2f5ba841a1dd65ae8ddeb79a7f5d",
		Id = {
			Type = "Moveset",
			StorageKey = "Dragon Claw",
			ItemId = 1144
		}
	},
	{
		SecurityKey = "79526059de5c7ea2b81cf30147a56c06",
		Id = {
			Type = "Moveset",
			StorageKey = "Saishi",
			ItemId = 1145
		}
	},
	{
		SecurityKey = "a393c3a1bd7b8100b91a776de2266639",
		Id = {
			Type = "Moveset",
			StorageKey = "Oroshi",
			ItemId = 1146
		}
	},
	{
		SecurityKey = "17574a0c570e8f595371b964d18902fc",
		Id = {
			Type = "Accessory",
			StorageKey = "Swan Glasses",
			ItemId = 1147
		}
	},
	{
		SecurityKey = "4d092da22a95d505c4494257fde4391c",
		Id = {
			Type = "Accessory",
			StorageKey = "Dark Coat",
			ItemId = 1148
		}
	},
	{
		SecurityKey = "d0c7f21df6acb5da990001be7173fda9",
		Id = {
			Type = "Tool",
			StorageKey = "Flower 1",
			ItemId = 1149
		}
	},
	{
		SecurityKey = "e70fad40b7cd82a2a1f46dcfa18d050d",
		Id = {
			Type = "Tool",
			StorageKey = "Flower 2",
			ItemId = 1150
		}
	},
	{
		SecurityKey = "cc5b2d6c6a6f2e63e36fffb2f8e2e976",
		Id = {
			Type = "Tool",
			StorageKey = "Flower 3",
			ItemId = 1151
		}
	},
	{
		SecurityKey = "81f1f9d5f0e63f0aa8a3ff8372f7fc7d",
		Id = {
			Type = "Ability",
			StorageKey = "Last Resort",
			ItemId = 1152
		}
	},
	{
		SecurityKey = "16e929d94742c846d0fbde31664add19",
		Id = {
			Type = "Ability",
			StorageKey = "Agility",
			ItemId = 1153
		}
	},
	{
		SecurityKey = "318f26e6e21472627d7911abce5b5958",
		Id = {
			Type = "Ability",
			StorageKey = "Water Body",
			ItemId = 1154
		}
	},
	{
		SecurityKey = "2d197758eb23c880929dd02cf5e7b799",
		Id = {
			Type = "Ability",
			StorageKey = "Heavenly Blood",
			ItemId = 1155
		}
	},
	{
		SecurityKey = "9b34e7c37283aaff4beba215128deb34",
		Id = {
			Type = "Tool",
			StorageKey = "Rare Artifact",
			ItemId = 1156
		}
	},
	{
		SecurityKey = "11ac9949d4e7a4a51db8e4a97729c82f",
		Id = {
			Type = "Moveset",
			StorageKey = "Acidum Rifle",
			ItemId = 1157
		}
	},
	{
		SecurityKey = "7f921bed03eaee14b2434a4e7c7aa9c5",
		Id = {
			Type = "Tool",
			StorageKey = "Summon Sea Beast",
			ItemId = 1158
		}
	},
	{
		SecurityKey = "2811aebcd27a844c111a93bfc4e7bcf5",
		Id = {
			Type = "Moveset",
			StorageKey = "Kabucha",
			ItemId = 1159
		}
	},
	{
		SecurityKey = "5e432537b44b79b0c62272be27836477",
		Id = {
			Type = "Accessory",
			StorageKey = "Black Spikey Coat",
			ItemId = 1160
		}
	},
	{
		SecurityKey = "25bd5614c3f122fd049552949663231f",
		Id = {
			Type = "Moveset",
			StorageKey = "True Triple Katana",
			ItemId = 1161
		}
	},
	{
		SecurityKey = "7db695fb5eeaedad112c3a0ee0e99e52",
		Id = {
			Type = "Moveset",
			StorageKey = "Superhuman",
			ItemId = 1162
		}
	},
	{
		SecurityKey = "9d32225311ef4758fe43b603a40b54da",
		Id = {
			Type = "Tool",
			StorageKey = "black pillar",
			ItemId = 1163
		}
	},
	{
		SecurityKey = "09511a22d599101f8e0b5c83aa4d9d7c",
		Id = {
			Type = "Tool",
			StorageKey = "black nuke",
			ItemId = 1164
		}
	},
	{
		SecurityKey = "529cc9545dc21327605e197dcfe71fe3",
		Id = {
			Type = "Tool",
			StorageKey = "Rogue-Rogue",
			ItemId = 1165
		}
	},
	{
		SecurityKey = "082e902a08d17228e6277d0385d37bd1",
		Id = {
			Type = "Tool",
			StorageKey = "black blast",
			ItemId = 1166
		}
	},
	{
		SecurityKey = "4d5950de8825b3b66450acd5ec5ddb7b",
		Id = {
			Type = "Tool",
			StorageKey = "Microchip",
			ItemId = 1167
		}
	},
	{
		SecurityKey = "f5669e1b897619742f4b1d7d971fcee5",
		Id = {
			Type = "Tool",
			StorageKey = "Special Microchip",
			ItemId = 1168
		}
	},
	{
		SecurityKey = "7c5b2a985474b6f843e3297bc35f0297",
		Id = {
			Type = "Moveset",
			StorageKey = "Flail",
			ItemId = 1169
		}
	},
	{
		SecurityKey = "e2fe2d0a05c624731efea7117617e77b",
		Id = {
			Type = "Moveset",
			StorageKey = "Koko",
			ItemId = 1170
		}
	},
	{
		SecurityKey = "d2615c6a31bd709127fbfbc669cfd7aa",
		Id = {
			Type = "Accessory",
			StorageKey = "Zebra Cap",
			ItemId = 1171
		}
	},
	{
		SecurityKey = "b561ace534a73fdca7400d71167f1877",
		Id = {
			Type = "Tool",
			StorageKey = "black meteors",
			ItemId = 1172
		}
	},
	{
		SecurityKey = "670d5f6d2baeab84b7de980f85a0f881",
		Id = {
			Type = "Tool",
			StorageKey = "kamui",
			ItemId = 1173
		}
	},
	{
		SecurityKey = "74343cfff7b4ff54e83f1d680416576d",
		Id = {
			Type = "Tool",
			StorageKey = "gate",
			ItemId = 1174
		}
	},
	{
		SecurityKey = "d0b5645e1cc70fc6716f4a2957d6f828",
		Id = {
			Type = "Tool",
			StorageKey = "amaterasu",
			ItemId = 1175
		}
	},
	{
		SecurityKey = "d2281d461061caf6d29ae24bd274eaac",
		Id = {
			Type = "Tool",
			StorageKey = "Old Dragon Egg",
			ItemId = 1176
		}
	},
	{
		SecurityKey = "81432b09161ed50c1f2625a4f05fcff4",
		Id = {
			Type = "Moveset",
			StorageKey = "Midnight Blade",
			ItemId = 1177
		}
	},
	{
		SecurityKey = "67c16af5c846dfb62b42a2d67dad9a1c",
		Id = {
			Type = "Accessory",
			StorageKey = "Ghoul Mask",
			ItemId = 1178
		}
	},
	{
		SecurityKey = "77230b2f0f400de6026c07069ef2181f",
		Id = {
			Type = "Ability",
			StorageKey = "Heightened Senses",
			ItemId = 1179
		}
	},
	{
		SecurityKey = "be09e492d607bee42e89308e0815dd10",
		Id = {
			Type = "Tool",
			StorageKey = "Hellfire Torch",
			ItemId = 1180
		}
	},
	{
		SecurityKey = "21b2d600b5e22fa053eaab23ae48867a",
		Id = {
			Type = "Accessory",
			StorageKey = "Red Spikey Coat",
			ItemId = 1181
		}
	},
	{
		SecurityKey = "1868235613c4e9babefda8684de46162",
		Id = {
			Type = "Accessory",
			StorageKey = "Blue Spikey Coat",
			ItemId = 1182
		}
	},
	{
		SecurityKey = "9fdc2042074041359a0112723cfea817",
		Id = {
			Type = "Tool",
			StorageKey = "tensei",
			ItemId = 1183
		}
	},
	{
		SecurityKey = "4737af37f56b577788f0860a54bdbba7",
		Id = {
			Type = "Moveset",
			StorageKey = "Death Step",
			ItemId = 1184
		}
	},
	{
		SecurityKey = "dc60e24092d5bcb9478b90c6bb234cdb",
		Id = {
			Type = "Moveset",
			StorageKey = "Rengoku",
			ItemId = 1185
		}
	},
	{
		SecurityKey = "2e07d3d993b3864ae65854f26203fef1",
		Id = {
			Type = "Accessory",
			StorageKey = "Santa Hat",
			ItemId = 1186
		}
	},
	{
		SecurityKey = "0b4d91d2a30fdac0935ff2db530c1c54",
		Id = {
			Type = "Accessory",
			StorageKey = "Elf Hat",
			ItemId = 1187
		}
	},
	{
		SecurityKey = "e99a0996c9c325676a8a10054e89c0c7",
		Id = {
			Type = "Tool",
			StorageKey = "Fist of Darkness",
			ItemId = 1188
		}
	},
	{
		SecurityKey = "0c52ae4e55f5d4f8a4ecfa0749ba60f3",
		Id = {
			Type = "Tool",
			StorageKey = "Relic",
			ItemId = 1189
		}
	},
	{
		SecurityKey = "44dde4ef5b497d526441771a1ed698ae",
		Id = {
			Type = "Moveset",
			StorageKey = "Triple Dark Blade",
			ItemId = 1190
		}
	},
	{
		SecurityKey = "a385ff0def51e6b15ae7ccbe1ddb1c20",
		Id = {
			Type = "Tool",
			StorageKey = "rip kamui",
			ItemId = 1191
		}
	},
	{
		SecurityKey = "e11479e648b14ca7c668666965453ec3",
		Id = {
			Type = "Moveset",
			StorageKey = "Dragon Trident",
			ItemId = 1192
		}
	},
	{
		SecurityKey = "6d77d162116b555b840aacc7a28d0101",
		Id = {
			Type = "Moveset",
			StorageKey = "Pole (2nd Form)",
			ItemId = 1193
		}
	},
	{
		SecurityKey = "7b9b8ebfd43fc8c3570ea6f3c1af72bb",
		Id = {
			Type = "Moveset",
			StorageKey = "Sharkman Karate",
			ItemId = 1194
		}
	},
	{
		SecurityKey = "e89eb50b97ef7849187950f2d04e411c",
		Id = {
			Type = "Tool",
			StorageKey = "Sweet Chalice",
			ItemId = 1195
		}
	},
	{
		SecurityKey = "d4ca462f536030f7c442dd982fcf26f6",
		Id = {
			Type = "Tool",
			StorageKey = "Energy Core",
			ItemId = 1196
		}
	},
	{
		SecurityKey = "0ac48c4cab48997a3ae4c1fae484fa9c",
		Id = {
			Type = "Tool",
			StorageKey = "Core Brain",
			ItemId = 1197
		}
	},
	{
		SecurityKey = "380b42cbc6f344d185ab473f136174be",
		Id = {
			Type = "Moveset",
			StorageKey = "Electric Claw",
			ItemId = 1198
		}
	},
	{
		SecurityKey = "f2239bb6ef06a16145fe30dd1227ed34",
		Id = {
			Type = "Moveset",
			StorageKey = "Bizarre Revolver",
			ItemId = 1199
		}
	},
	{
		SecurityKey = "0213bb5059fb7839a43f18d897c7cdbf",
		Id = {
			Type = "Tool",
			StorageKey = "Love2-Love2",
			ItemId = 1200
		}
	},
	{
		SecurityKey = "f43ee13a506772e8493dd69f5bfb8b1e",
		Id = {
			Type = "Moveset",
			StorageKey = "Canvander",
			ItemId = 1201
		}
	},
	{
		SecurityKey = "8836fa5ab7ded7f43427ba97cfa113a6",
		Id = {
			Type = "Moveset",
			StorageKey = "Yama",
			ItemId = 1202
		}
	},
	{
		SecurityKey = "d9940d97cbf7c098886a20ed97d74e6e",
		Id = {
			Type = "Moveset",
			StorageKey = "Tushita",
			ItemId = 1203
		}
	},
	{
		SecurityKey = "6c9fb80be4e45a1fa70eeed895934cf3",
		Id = {
			Type = "Moveset",
			StorageKey = "Twin Hooks",
			ItemId = 1204
		}
	},
	{
		SecurityKey = "372ee1dc1d48a954938905e9c7fd2e3a",
		Id = {
			Type = "Tool",
			StorageKey = "Apple",
			ItemId = 1205
		}
	},
	{
		SecurityKey = "8c6ab9cabd48cea5e8dffdacd3575970",
		Id = {
			Type = "Accessory",
			StorageKey = "Pretty Helmet",
			ItemId = 1206
		}
	},
	{
		SecurityKey = "a1b57cfb37c143f2be4ebafc993288aa",
		Id = {
			Type = "Accessory",
			StorageKey = "Jaw Shield",
			ItemId = 1207
		}
	},
	{
		SecurityKey = "f4fbc04e2e8e830f5eccc4a06bbd629d",
		Id = {
			Type = "Tool",
			StorageKey = "God's Chalice",
			ItemId = 1208
		}
	},
	{
		SecurityKey = "282c71ee473c98d4781a103bbae3bc47",
		Id = {
			Type = "Tool",
			StorageKey = "Holy Torch",
			ItemId = 1209
		}
	},
	{
		SecurityKey = "359f6bc3a1c3affb8ac357ce6ac364a6",
		Id = {
			Type = "Moveset",
			StorageKey = "Venom Bow",
			ItemId = 1210
		}
	},
	{
		SecurityKey = "392758fee03ecfb3a018282e30d3b4f9",
		Id = {
			Type = "Tool",
			StorageKey = "Banana",
			ItemId = 1211
		}
	},
	{
		SecurityKey = "0e703a59a9a17cf82d3e967d81046453",
		Id = {
			Type = "Tool",
			StorageKey = "Pineapple",
			ItemId = 1212
		}
	},
	{
		SecurityKey = "cd344d51536c6002f7f8ed7fc4665e9e",
		Id = {
			Type = "Tool",
			StorageKey = "Fruit Bowl",
			ItemId = 1213
		}
	},
	{
		SecurityKey = "3467f2eb4ed0a3089f3220ce5dfcb2fc",
		Id = {
			Type = "Accessory",
			StorageKey = "Valkyrie Helm",
			ItemId = 1214
		}
	},
	{
		SecurityKey = "fe020f898be9089c9274b8f1a8ba2614",
		Id = {
			Type = "Accessory",
			StorageKey = "Hunter Cape (Red)",
			ItemId = 1215
		}
	},
	{
		SecurityKey = "aad3ab31d15f69e788c6e47a96c1fad9",
		Id = {
			Type = "Accessory",
			StorageKey = "Hunter Cape (Green)",
			ItemId = 1216
		}
	},
	{
		SecurityKey = "eac4ec0a2416ebb139cfdda1f4211571",
		Id = {
			Type = "Accessory",
			StorageKey = "Hunter Cape (Black)",
			ItemId = 1217
		}
	},
	{
		SecurityKey = "c92261c84e5608f6b0faafa901c81c47",
		Id = {
			Type = "Accessory",
			StorageKey = "Bandanna (Black)",
			ItemId = 1218
		}
	},
	{
		SecurityKey = "b6ef43aa885d198df2ea5aaedcc0761f",
		Id = {
			Type = "Accessory",
			StorageKey = "Bandanna (Green)",
			ItemId = 1219
		}
	},
	{
		SecurityKey = "3a33dd40d380dd4a0c9cd1d9e652fff7",
		Id = {
			Type = "Accessory",
			StorageKey = "Bandanna (Red)",
			ItemId = 1220
		}
	},
	{
		SecurityKey = "aba2d69afe8cd0a2480db706a9350793",
		Id = {
			Type = "Accessory",
			StorageKey = "Musketeer Hat",
			ItemId = 1221
		}
	},
	{
		SecurityKey = "986153441f324510a960ba29e4b15e4a",
		Id = {
			Type = "Accessory",
			StorageKey = "Pilot Helmet",
			ItemId = 1222
		}
	},
	{
		SecurityKey = "1e02ed1d0614134219af044ca46b90bd",
		Id = {
			Type = "Accessory",
			StorageKey = "Lei",
			ItemId = 1223
		}
	},
	{
		SecurityKey = "1d054489b098af769acce734194efc4e",
		Id = {
			Type = "Moveset",
			StorageKey = "Dark Dagger",
			ItemId = 1224
		}
	},
	{
		SecurityKey = "28bd36da8f227a453ce09dc183f98567",
		Id = {
			Type = "Moveset",
			StorageKey = "Dragon Talon",
			ItemId = 1225
		}
	},
	{
		SecurityKey = "91c5da820e6befd77240904b670cfae8",
		Id = {
			Type = "Moveset",
			StorageKey = "Hallow Scythe",
			ItemId = 1226
		}
	},
	{
		SecurityKey = "6886e86b317f63854af737ed493b6788",
		Id = {
			Type = "Tool",
			StorageKey = "Fire Essence",
			ItemId = 1227
		}
	},
	{
		SecurityKey = "be7ec076fa3536b64cbcbdefaf1e2e21",
		Id = {
			Type = "Tool",
			StorageKey = "Hallow Essence",
			ItemId = 1228
		}
	},
	{
		SecurityKey = "47b6986af53fe2abea935fe99c2192d7",
		Id = {
			Type = "Accessory",
			StorageKey = "Bear Ears",
			ItemId = 1229
		}
	},
	{
		SecurityKey = "1c887b1e6482fc14046217925fea492c",
		Id = {
			Type = "Accessory",
			StorageKey = "Golden Sunhat",
			ItemId = 1230
		}
	},
	{
		SecurityKey = "d2cfc4674e6d7d6e309211fb60c3b04e",
		Id = {
			Type = "Accessory",
			StorageKey = "Holy Crown",
			ItemId = 1231
		}
	},
	{
		SecurityKey = "5771102bffaf63ee208813c46c156e1a",
		Id = {
			Type = "Moveset",
			StorageKey = "Buddy Sword",
			ItemId = 1232
		}
	},
	{
		SecurityKey = "338356a00c11d28cc8654aa5ae8f26d5",
		Id = {
			Type = "Moveset",
			StorageKey = "Spikey Trident",
			ItemId = 1233
		}
	},
	{
		SecurityKey = "2e3ddc6e438737fac6adb1044614e1b8",
		Id = {
			Type = "Accessory",
			StorageKey = "Pale Scarf",
			ItemId = 1234
		}
	},
	{
		SecurityKey = "72a664c398ad50c89976240d6089e8e6",
		Id = {
			Type = "Tool",
			StorageKey = "arena kamui",
			ItemId = 1235
		}
	},
	{
		SecurityKey = "3596c8c62d8e8115e5d0fd07b9a61e88",
		Id = {
			Type = "Tool",
			StorageKey = "heaven kamui",
			ItemId = 1236
		}
	},
	{
		SecurityKey = "31dfa629cbe7e210be688d648bc845fd",
		Id = {
			Type = "Tool",
			StorageKey = "Awakening",
			ItemId = 1237
		}
	},
	{
		SecurityKey = "4da82b2e973232b99774f86e02e8a9a5",
		Id = {
			Type = "Moveset",
			StorageKey = "Skull Guitar",
			ItemId = 1238
		}
	},
	{
		SecurityKey = "519b6d6ff24f1883caa4b5da74140ed3",
		Id = {
			Type = "Moveset",
			StorageKey = "Cursed Dual Katana",
			ItemId = 1239
		}
	},
	{
		SecurityKey = "acc226122eea25b28b95dc4c2137adbd",
		Id = {
			Type = "Moveset",
			StorageKey = "Godhuman",
			ItemId = 1240
		}
	},
	{
		SecurityKey = "ea661a41a2c9a2ac5e271843ec3172b7",
		Id = {
			Type = "Tool",
			StorageKey = "Key",
			ItemId = 1241
		}
	},
	{
		SecurityKey = "67093b2309651fdc8004bb905660314a",
		Id = {
			Type = "Tool",
			StorageKey = "Library Key",
			ItemId = 1242
		}
	},
	{
		SecurityKey = "a521fccd85850757f0c07f6bfb9952f0",
		Id = {
			Type = "Tool",
			StorageKey = "Red Key",
			ItemId = 1243
		}
	},
	{
		SecurityKey = "1cc78ec0b1e66dba92c0948e899fea14",
		Id = {
			Type = "Tool",
			StorageKey = "Water Key",
			ItemId = 1244
		}
	},
	{
		SecurityKey = "bbe042d2e5af1a57c38d67e12807d243",
		Id = {
			Type = "Accessory",
			StorageKey = "Holiday Cloak",
			ItemId = 1245
		}
	},
	{
		SecurityKey = "0603a8a4772d6fcd4bcd34d526258391",
		Id = {
			Type = "Accessory",
			StorageKey = "Party Hat",
			ItemId = 1246
		}
	},
	{
		SecurityKey = "8ea7899487e1fc5b187c3851abf203a3",
		Id = {
			Type = "Accessory",
			StorageKey = "Heart Shades",
			ItemId = 1247
		}
	},
	{
		SecurityKey = "669878c4699e7ccc73735c4fcf71389e",
		Id = {
			Type = "Tool",
			StorageKey = "Draconic Incandescence of the Vermillion Firmament",
			ItemId = 1248
		}
	},
	{
		SecurityKey = "7989055437a1accb39f63b1a939af903",
		Id = {
			Type = "Accessory",
			StorageKey = "Cupid's Coat",
			ItemId = 1249
		}
	},
	{
		SecurityKey = "eaaf06edc2e0c20e886cac27cd9b17a5",
		Id = {
			Type = "Moveset",
			StorageKey = "Dark Blade",
			ItemId = 1250
		}
	},
	{
		SecurityKey = "7f3a85e9dcd0e98a56e69ac362fc48f4",
		Id = {
			Type = "Tool",
			StorageKey = "TestTool",
			ItemId = 1251
		}
	},
	{
		SecurityKey = "a1f917f363a9c5982269056993394345",
		Id = {
			Type = "Moveset",
			StorageKey = "Shark Anchor",
			ItemId = 1252
		}
	},
	{
		SecurityKey = "adc24908cfb762c9a9690535ddf9d380",
		Id = {
			Type = "Moveset",
			StorageKey = "Slingshot",
			ItemId = 1253
		}
	},
	{
		SecurityKey = "a80008c08d7ca380198c987c766e5f10",
		Id = {
			Type = "Accessory",
			StorageKey = "Leviathan Crown",
			ItemId = 1254
		}
	},
	{
		SecurityKey = "29b393a238f18f652f18bb3df982fb84",
		Id = {
			Type = "Accessory",
			StorageKey = "Terror Jaw",
			ItemId = 1255
		}
	},
	{
		SecurityKey = "bb877a34ddd1c72c2307289b53c36297",
		Id = {
			Type = "Accessory",
			StorageKey = "Shark Tooth Necklace",
			ItemId = 1256
		}
	},
	{
		SecurityKey = "d325b0901f6f0df8185a8b73d94175db",
		Id = {
			Type = "Accessory",
			StorageKey = "Leviathan Shield",
			ItemId = 1257
		}
	},
	{
		SecurityKey = "cc907e0ddc5be3d0ccee4fbfe3cdba01",
		Id = {
			Type = "Moveset",
			StorageKey = "Fox Lamp",
			ItemId = 1258
		}
	},
	{
		SecurityKey = "aef0129afe3c94edb25333a66c59930a",
		Id = {
			Type = "Accessory",
			StorageKey = "Dragon Mantle",
			ItemId = 1259
		}
	},
	{
		SecurityKey = "c40e4a811c78a56cae013565624d05eb",
		Id = {
			Type = "Accessory",
			StorageKey = "Kitsune Mask",
			ItemId = 1260
		}
	},
	{
		SecurityKey = "79c8f8d9cdc3c6553ce207746a72a8a4",
		Id = {
			Type = "Accessory",
			StorageKey = "Kitsune Ribbon",
			ItemId = 1261
		}
	},
	{
		SecurityKey = "1326b14caaaf1653f2abc824f36975ac",
		Id = {
			Type = "Moveset",
			StorageKey = "Divine Art",
			ItemId = 1262
		}
	},
	{
		SecurityKey = "85b4ea4a05de2418bdbe9208f43dfe6c",
		Id = {
			Type = "Ability",
			StorageKey = "Primordial Reign",
			ItemId = 1263
		}
	},
	{
		SecurityKey = "f731242e83350aebc1c95afbb3309e7c",
		Id = {
			Type = "Moveset",
			StorageKey = "Dragonheart",
			ItemId = 1264
		}
	},
	{
		SecurityKey = "2b75981839dca8687bae8fb28b79983e",
		Id = {
			Type = "Accessory",
			StorageKey = "Dojo Belt (Black)",
			ItemId = 1265
		}
	},
	{
		SecurityKey = "8330fd6a85c9356900c3fc7fac6d6856",
		Id = {
			Type = "Accessory",
			StorageKey = "Dojo Belt (Red)",
			ItemId = 1266
		}
	},
	{
		SecurityKey = "9837f9408db282d6cbb52e5b40efe02e",
		Id = {
			Type = "Accessory",
			StorageKey = "Dojo Belt (Blue)",
			ItemId = 1267
		}
	},
	{
		SecurityKey = "191bfdad50fa6622e0464dc3915c02f8",
		Id = {
			Type = "Accessory",
			StorageKey = "Dojo Belt (Green)",
			ItemId = 1268
		}
	},
	{
		SecurityKey = "a0e2b21076772a55380cd5aa8269bbb0",
		Id = {
			Type = "Accessory",
			StorageKey = "Dojo Belt (Orange)",
			ItemId = 1269
		}
	},
	{
		SecurityKey = "b6f2888470332c9a93773a52fab2ede5",
		Id = {
			Type = "Accessory",
			StorageKey = "Dojo Belt (Yellow)",
			ItemId = 1270
		}
	},
	{
		SecurityKey = "08396e5696cd3c9ed71ac1449b498730",
		Id = {
			Type = "Accessory",
			StorageKey = "Dojo Belt (White)",
			ItemId = 1271
		}
	},
	{
		SecurityKey = "b378e9f9ccd24da076c4aaf43c2ab84c",
		Id = {
			Type = "Accessory",
			StorageKey = "Dojo Belt (Purple)",
			ItemId = 1272
		}
	},
	{
		SecurityKey = "89c017238ba6fe3720da1c6db47d1151",
		Id = {
			Type = "Accessory",
			StorageKey = "Uzoth's Cloak",
			ItemId = 1273
		}
	},
	{
		SecurityKey = "4801fd3d0c132b2ab06dda6702ef636c",
		Id = {
			Type = "Accessory",
			StorageKey = "Dino Hood",
			ItemId = 1274
		}
	},
	{
		SecurityKey = "28533d7d55ec17c9f89649044194743e",
		Id = {
			Type = "Accessory",
			StorageKey = "T-Rex Skull",
			ItemId = 1275
		}
	},
	{
		SecurityKey = "2215789eec67638fc3e76961a6d5672b",
		Id = {
			Type = "Tool",
			StorageKey = "Dragon Egg",
			ItemId = 1276
		}
	},
	{
		SecurityKey = "b25bf0298dcc686f80d2d75cb8022cdf",
		Id = {
			Type = "Moveset",
			StorageKey = "Dragonstorm",
			ItemId = 1277
		}
	},
	{
		SecurityKey = "2970c50197cd2f49640ea658087e913c",
		Id = {
			Type = "Accessory",
			StorageKey = "Wyvern Helmet",
			ItemId = 1278
		}
	},
	{
		SecurityKey = "76043b1872ea756f13af7e905e675134",
		Id = {
			Type = "Tool",
			StorageKey = "Admin Holiday Gift",
			ItemId = 1279
		}
	},
	{
		SecurityKey = "36486588bb3e148b8509f8ae40489e99",
		Id = {
			Type = "Tool",
			StorageKey = "Legendary Holiday Gift",
			ItemId = 1280
		}
	},
	{
		SecurityKey = "cdad8a4352af698bfc49a25c9cc01ada",
		Id = {
			Type = "Tool",
			StorageKey = "Rare Holiday Gift",
			ItemId = 1281
		}
	},
	{
		SecurityKey = "29bab3611d3ed97a2d925a0f2b0b012b",
		Id = {
			Type = "Tool",
			StorageKey = "Holiday Gift",
			ItemId = 1282
		}
	},
	{
		SecurityKey = "687c241b95557c574e2959afeb8c6888",
		Id = {
			Type = "Tool",
			StorageKey = "Mythical Holiday Gift",
			ItemId = 1283
		}
	},
	{
		SecurityKey = "843463d5c0cbf840ba9b3c35d481cb40",
		Id = {
			Type = "Tool",
			StorageKey = "Uncommon Holiday Gift",
			ItemId = 1284
		}
	},
	{
		SecurityKey = "6bcb1ad8c964c1bdbc607f5a8411c6be",
		Id = {
			Type = "Accessory",
			StorageKey = "Headband (Red)",
			ItemId = 1285
		}
	},
	{
		SecurityKey = "eeb951111e3cda7a1e255dd356e0c913",
		Id = {
			Type = "Accessory",
			StorageKey = "Headband (Black)",
			ItemId = 1286
		}
	},
	{
		SecurityKey = "ae69f2fdfefdebc4ead7c48f2ca89d65",
		Id = {
			Type = "Accessory",
			StorageKey = "Headband (Green)",
			ItemId = 1287
		}
	},
	{
		SecurityKey = "850c82a1f3abe79e0c7acecd24c75693",
		Id = {
			Type = "Accessory",
			StorageKey = "Headband (Purple)",
			ItemId = 1288
		}
	},
	{
		SecurityKey = "3659915666be1c3de1b1dcba46569a2e",
		Id = {
			Type = "Accessory",
			StorageKey = "Headband (Orange)",
			ItemId = 1289
		}
	},
	{
		SecurityKey = "b78320846e64d24412406a0a34b4c7ff",
		Id = {
			Type = "Accessory",
			StorageKey = "Headband (Yellow)",
			ItemId = 1290
		}
	},
	{
		SecurityKey = "a73ff49ee2c9ac0b31d2a28871f17a45",
		Id = {
			Type = "Accessory",
			StorageKey = "Headband (White)",
			ItemId = 1291
		}
	},
	{
		SecurityKey = "fd0f2550f711701b7204f129aa04e5d7",
		Id = {
			Type = "Accessory",
			StorageKey = "Headband (Blue)",
			ItemId = 1292
		}
	},
	{
		SecurityKey = "1e1acb422bff6024978ef20f4f65e33f",
		Id = {
			Type = "Accessory",
			StorageKey = "Celestial Helmet",
			ItemId = 1293
		}
	},
	{
		SecurityKey = "25a81f292dfea60ce96dde0d607f64f6",
		Id = {
			Type = "Accessory",
			StorageKey = "Divine Cloak",
			ItemId = 1294
		}
	},
	{
		SecurityKey = "9c7d1cd91a70c78ccd32f95809e0bc95",
		Id = {
			Type = "Tool",
			StorageKey = "Fishing Trophy",
			ItemId = 1295
		}
	},
	{
		SecurityKey = "86e4972f53db776b8fb697ed89f6c4dc",
		Id = {
			Type = "Rod",
			StorageKey = "Shell (Celestial)",
			ItemId = 1296
		}
	},
	{
		SecurityKey = "c0c031108e5ebde3522d957f3b969bcc",
		Id = {
			Type = "Rod",
			StorageKey = "Fishing Rod",
			ItemId = 1297
		}
	},
	{
		SecurityKey = "5b980316cbaecc32666fd419c4104994",
		Id = {
			Type = "Rod",
			StorageKey = "Gold Rod",
			ItemId = 1298
		}
	},
	{
		SecurityKey = "a9d98fc3790e2eb800a553ce0ebbf03d",
		Id = {
			Type = "Rod",
			StorageKey = "Shark Rod",
			ItemId = 1299
		}
	},
	{
		SecurityKey = "3d2dff43c6988b90aaaf6bdede19a4f0",
		Id = {
			Type = "Rod",
			StorageKey = "Shell Rod",
			ItemId = 1300
		}
	},
	{
		SecurityKey = "16678e89e4704e743c73524699a3db31",
		Id = {
			Type = "Rod",
			StorageKey = "Treasure Rod",
			ItemId = 1301
		}
	},
	{
		SecurityKey = "bc2056777bef974124284cbe5f708125",
		Id = {
			Type = "Accessory",
			StorageKey = "Oni Helmet",
			ItemId = 1302
		}
	},
	{
		SecurityKey = "8b43f22dd10c06af2fa129a99f909aec",
		Id = {
			Type = "Accessory",
			StorageKey = "50b Party Hat",
			ItemId = 1303
		}
	},
	{
		SecurityKey = "4fd61d97a778d590cc1539ba9c759ba4",
		Id = {
			Type = "Potion",
			StorageKey = "Aggro Elixir",
			ItemId = 1304
		}
	},
	{
		SecurityKey = "0303dd5d44680f213484d2238b81b48d",
		Id = {
			Type = "Potion",
			StorageKey = "Berserkers Elixir",
			ItemId = 1305
		}
	},
	{
		SecurityKey = "04cfa3efcc2e45c4ce47054a53d093a9",
		Id = {
			Type = "Potion",
			StorageKey = "Exp Boost",
			ItemId = 1306
		}
	},
	{
		SecurityKey = "c24dd68b258d70131cb93e6eef6be244",
		Id = {
			Type = "Accessory",
			StorageKey = "Feathered Visage",
			ItemId = 1307
		}
	},
	{
		SecurityKey = "5afd7e16bd3f50231fa13e1d7c06f922",
		Id = {
			Type = "Consumable",
			StorageKey = "Fish Kebab",
			ItemId = 1308
		}
	},
	{
		SecurityKey = "fcb3ffebaf2c964188e7de0642c83a4f",
		Id = {
			Type = "Potion",
			StorageKey = "Fortune Elixir",
			ItemId = 1309
		}
	},
	{
		SecurityKey = "94e06bda5df5098b51aca3d1736bd2c9",
		Id = {
			Type = "Potion",
			StorageKey = "Fragments Elixir",
			ItemId = 1310
		}
	},
	{
		SecurityKey = "f31916c198f04ffdd49a2043ebe08b5b",
		Id = {
			Type = "Potion",
			StorageKey = "Gate Potion",
			ItemId = 1311
		}
	},
	{
		SecurityKey = "336c8aac6f642393a961596c576d6840",
		Id = {
			Type = "Potion",
			StorageKey = "Invisibility Potion",
			ItemId = 1312
		}
	},
	{
		SecurityKey = "cea08c0e71ee9739357d15beb9cb5b0e",
		Id = {
			Type = "Potion",
			StorageKey = "Lava Potion",
			ItemId = 1313
		}
	},
	{
		SecurityKey = "6fd033410d367b9195660e49245bad1f",
		Id = {
			Type = "Potion",
			StorageKey = "Loot Seeker",
			ItemId = 1314
		}
	},
	{
		SecurityKey = "2ec2d5277756451373ece30dfad427d4",
		Id = {
			Type = "Potion",
			StorageKey = "Materials Elixir",
			ItemId = 1315
		}
	},
	{
		SecurityKey = "548273cebab37d926294ec451124802b",
		Id = {
			Type = "Potion",
			StorageKey = "Monk Potion",
			ItemId = 1316
		}
	},
	{
		SecurityKey = "f17f58955d0b15290d3610e2f9942720",
		Id = {
			Type = "Potion",
			StorageKey = "Oni Soul",
			ItemId = 1317
		}
	},
	{
		SecurityKey = "1806ef1fea21b777511c5bb74b2d5bea",
		Id = {
			Type = "Potion",
			StorageKey = "Quest-Grab Elixir",
			ItemId = 1318
		}
	},
	{
		SecurityKey = "afe480a06c15a4f067e6ef6b05193ce1",
		Id = {
			Type = "Potion",
			StorageKey = "Sanguine Cloak",
			ItemId = 1319
		}
	},
	{
		SecurityKey = "06dc3999ee8f6879d606718ee4bf7e0f",
		Id = {
			Type = "Potion",
			StorageKey = "Water Walking",
			ItemId = 1320
		}
	},
	{
		SecurityKey = "a69b2e6bfa95b1318f236b21ccec5d11",
		Id = {
			Type = "Potion",
			StorageKey = "Bronze Trophy",
			ItemId = 1321
		}
	},
	{
		SecurityKey = "93cf7b37e9f39414f19ff1e730f7d89f",
		Id = {
			Type = "Potion",
			StorageKey = "Silver Trophy",
			ItemId = 1322
		}
	},
	{
		SecurityKey = "ab65218996a3c836de60c41de35e1926",
		Id = {
			Type = "Potion",
			StorageKey = "Gold Trophy",
			ItemId = 1323
		}
	},
	{
		SecurityKey = "9202b57db342dcb6e1329f0d21ff006e",
		Id = {
			Type = "Potion",
			StorageKey = "Platinum Trophy",
			ItemId = 1324
		}
	},
	{
		SecurityKey = "2430830f5d636566de00b2dae1e3bd41",
		Id = {
			Type = "Potion",
			StorageKey = "Diamond Trophy",
			ItemId = 1325
		}
	},
	{
		SecurityKey = "94e02c64c50c6a560e233a4ab9acf1d0",
		Id = {
			Type = "Potion",
			StorageKey = "Master Trophy",
			ItemId = 1326
		}
	},
	{
		SecurityKey = "6fa72ce474b85bbf31c6782e8b98d90a",
		Id = {
			Type = "Potion",
			StorageKey = "Big Head Elixir",
			ItemId = 1327
		}
	},
	{
		SecurityKey = "c3ddaceb19e605e16ec6e76b61703db7",
		Id = {
			Type = "Potion",
			StorageKey = "Candy Concoction",
			ItemId = 1328
		}
	},
	{
		SecurityKey = "e2cbfd3ffa418ac476f205bd156cc15e",
		Id = {
			Type = "Potion",
			StorageKey = "Disguise Elixir",
			ItemId = 1329
		}
	},
	{
		SecurityKey = "1df01dec5794370c17fcea5d3902ab63",
		Id = {
			Type = "Potion",
			StorageKey = "Lava Bomb Elixir",
			ItemId = 1330
		}
	},
	{
		SecurityKey = "dc8cea6dd48a6fa6360257ced3eb4b67",
		Id = {
			Type = "Potion",
			StorageKey = "Monster Mash Elixir",
			ItemId = 1331
		}
	},
	{
		SecurityKey = "be46205a2a9675b867ac597cd31174bc",
		Id = {
			Type = "Potion",
			StorageKey = "Pumpkin Potion",
			ItemId = 1332
		}
	},
	{
		SecurityKey = "689e61f75d2b541852c6edebcd54661e",
		Id = {
			Type = "Potion",
			StorageKey = "Suspicious Growth Potion",
			ItemId = 1333
		}
	},
	{
		SecurityKey = "f4b2a21b226fcb09850f87727696284f",
		Id = {
			Type = "Rod",
			StorageKey = "Shark (Corrupted)",
			ItemId = 1334
		}
	},
	{
		SecurityKey = "616dd752d3881d014f308e6f3a1602b3",
		Id = {
			Type = "Accessory",
			StorageKey = "Coven Witch Hat",
			ItemId = 1335
		}
	},
	{
		SecurityKey = "187ed5aeeca457c669a54ff44a552e10",
		Id = {
			Type = "Accessory",
			StorageKey = "Pumpkin Mask",
			ItemId = 1336
		}
	},
	{
		SecurityKey = "eb1da94fe8f4c1963524643bcae693fc",
		Id = {
			Type = "Rod",
			StorageKey = "Admin Rod",
			ItemId = 1337
		}
	},
	{
		SecurityKey = "fb7a3acbe6bfdd1815eee53f7cfbf473",
		Id = {
			Type = "Accessory",
			StorageKey = "Peppermint Helmet",
			ItemId = 1338
		}
	},
	{
		SecurityKey = "de85ab66f565de683260bf9602b25d73",
		Id = {
			Type = "Accessory",
			StorageKey = "Ring of Carving I",
			ItemId = 1339
		}
	},
	{
		SecurityKey = "5733e802316fb30ff595886ec78a198e",
		Id = {
			Type = "Accessory",
			StorageKey = "Ring of Essence I",
			ItemId = 1340
		}
	},
	{
		SecurityKey = "08d92063aaa71dd285f00b6feebce77c",
		Id = {
			Type = "Accessory",
			StorageKey = "Ring of Might I",
			ItemId = 1341
		}
	},
	{
		SecurityKey = "4bc82cc9149b8b1cfc868a9c557636ea",
		Id = {
			Type = "Accessory",
			StorageKey = "Ring of the Outlaw I",
			ItemId = 1342
		}
	},
	{
		SecurityKey = "896db09241bb4467bcb4e1f50f1daba2",
		Id = {
			Type = "Accessory",
			StorageKey = "Ring of Spirit I",
			ItemId = 1343
		}
	},
	{
		SecurityKey = "60a851100f181f47eb56e1d2861e1ff2",
		Id = {
			Type = "Accessory",
			StorageKey = "Ring of Striking I",
			ItemId = 1344
		}
	},
	{
		SecurityKey = "605e82f4f2d754d71f64c03b516a863b",
		Id = {
			Type = "Accessory",
			StorageKey = "Ring of the Vanguard I",
			ItemId = 1345
		}
	},
	{
		SecurityKey = "13aea334fa5937a621d53d9196ed54eb",
		Id = {
			Type = "Accessory",
			StorageKey = "Ring of the Arcanist I",
			ItemId = 1346
		}
	},
	{
		SecurityKey = "45bbcec0c76ecd225b6138ae22a170fd",
		Id = {
			Type = "Accessory",
			StorageKey = "Ring of Renewal I",
			ItemId = 1347
		}
	},
	{
		SecurityKey = "90fc2e68d51d351d050ec96ab4a0b3ea",
		Id = {
			Type = "Accessory",
			StorageKey = "Ring of Twin Blades I",
			ItemId = 1348
		}
	},
	{
		SecurityKey = "d932dcc931ed60c5ea46d154d02ee302",
		Id = {
			Type = "Accessory",
			StorageKey = "Ring of Steelheart I",
			ItemId = 1349
		}
	},
	{
		SecurityKey = "7f94f1206b093cbaccfff38c02134a21",
		Id = {
			Type = "Accessory",
			StorageKey = "Ring of Carving II",
			ItemId = 1350
		}
	},
	{
		SecurityKey = "06da15af0a248a3719e43512df492390",
		Id = {
			Type = "Accessory",
			StorageKey = "Ring of Essence II",
			ItemId = 1351
		}
	},
	{
		SecurityKey = "f743c37e976178026cd8f7d2d52f66f3",
		Id = {
			Type = "Accessory",
			StorageKey = "Ring of Might II",
			ItemId = 1352
		}
	},
	{
		SecurityKey = "4c46248c7123ddc9068894fc141ba199",
		Id = {
			Type = "Accessory",
			StorageKey = "Ring of the Outlaw II",
			ItemId = 1353
		}
	},
	{
		SecurityKey = "56ce648863a145f9db04d36570af04c2",
		Id = {
			Type = "Accessory",
			StorageKey = "Ring of Spirit II",
			ItemId = 1354
		}
	},
	{
		SecurityKey = "fb6372fb898dbeef56b3d2d665fa8713",
		Id = {
			Type = "Accessory",
			StorageKey = "Ring of Striking II",
			ItemId = 1355
		}
	},
	{
		SecurityKey = "d837035a6805ace906b6c7affd883746",
		Id = {
			Type = "Accessory",
			StorageKey = "Ring of the Vanguard II",
			ItemId = 1356
		}
	},
	{
		SecurityKey = "ceec457ed844a852296e84d2f1279069",
		Id = {
			Type = "Accessory",
			StorageKey = "Ring of the Arcanist II",
			ItemId = 1357
		}
	},
	{
		SecurityKey = "ee4d4d6c1708f08b13987638ab900b7c",
		Id = {
			Type = "Accessory",
			StorageKey = "Ring of Renewal II",
			ItemId = 1358
		}
	},
	{
		SecurityKey = "4c1e69ffae43d98e2cd94f2dd0adc11c",
		Id = {
			Type = "Accessory",
			StorageKey = "Ring of Twin Blades II",
			ItemId = 1359
		}
	},
	{
		SecurityKey = "062608c50a929951cceb6e376291103e",
		Id = {
			Type = "Accessory",
			StorageKey = "Ring of Steelheart II",
			ItemId = 1360
		}
	},
	{
		SecurityKey = "6dc5767af701f9a575857d3e45e31216",
		Id = {
			Type = "Accessory",
			StorageKey = "Ring of Carving III",
			ItemId = 1361
		}
	},
	{
		SecurityKey = "f12377c69cd1c0991cb60470600793ad",
		Id = {
			Type = "Accessory",
			StorageKey = "Ring of Essence III",
			ItemId = 1362
		}
	},
	{
		SecurityKey = "b382e30d3d20476aa36859086b5837dd",
		Id = {
			Type = "Accessory",
			StorageKey = "Ring of Might III",
			ItemId = 1363
		}
	},
	{
		SecurityKey = "a068192b2be0ab32636a9f7989c37773",
		Id = {
			Type = "Accessory",
			StorageKey = "Ring of the Outlaw III",
			ItemId = 1364
		}
	},
	{
		SecurityKey = "9191770cb20be699211548652abbfb16",
		Id = {
			Type = "Accessory",
			StorageKey = "Ring of Spirit III",
			ItemId = 1365
		}
	},
	{
		SecurityKey = "eda687b5a296bcd04c6f68ed85c846da",
		Id = {
			Type = "Accessory",
			StorageKey = "Ring of Striking III",
			ItemId = 1366
		}
	},
	{
		SecurityKey = "1e5be161a59abfe01250cff271575929",
		Id = {
			Type = "Accessory",
			StorageKey = "Ring of the Vanguard III",
			ItemId = 1367
		}
	},
	{
		SecurityKey = "46331e67a3664c7209cdfb35b04097eb",
		Id = {
			Type = "Accessory",
			StorageKey = "Ring of the Arcanist III",
			ItemId = 1368
		}
	},
	{
		SecurityKey = "e6113579d58efecf00c0219e1a02f4a4",
		Id = {
			Type = "Accessory",
			StorageKey = "Ring of Renewal III",
			ItemId = 1369
		}
	},
	{
		SecurityKey = "cd7c8a5ad40135db9123321fc8b5d1ea",
		Id = {
			Type = "Accessory",
			StorageKey = "Ring of Twin Blades III",
			ItemId = 1370
		}
	},
	{
		SecurityKey = "6874e9fd070457ce8d37ab426af815fe",
		Id = {
			Type = "Accessory",
			StorageKey = "Ring of Steelheart III",
			ItemId = 1371
		}
	},
	{
		SecurityKey = "936d3014adfe0be6f63d2f1db1971450",
		Id = {
			Type = "Accessory",
			StorageKey = "Ring of Carving IV",
			ItemId = 1372
		}
	},
	{
		SecurityKey = "2a4b366093a7921462e1f1cc23439e82",
		Id = {
			Type = "Accessory",
			StorageKey = "Ring of Essence IV",
			ItemId = 1373
		}
	},
	{
		SecurityKey = "a121ecdae70d6a03ee0e671717a95b98",
		Id = {
			Type = "Accessory",
			StorageKey = "Ring of Might IV",
			ItemId = 1374
		}
	},
	{
		SecurityKey = "d0f256dfb4cd65ccaf28339421a7b6b5",
		Id = {
			Type = "Accessory",
			StorageKey = "Ring of the Outlaw IV",
			ItemId = 1375
		}
	},
	{
		SecurityKey = "a06bae9a5ba0b929b81c30dfe162b025",
		Id = {
			Type = "Accessory",
			StorageKey = "Ring of Spirit IV",
			ItemId = 1376
		}
	},
	{
		SecurityKey = "54daed2369b3ac8a962f018e9f4564c0",
		Id = {
			Type = "Accessory",
			StorageKey = "Ring of Striking IV",
			ItemId = 1377
		}
	},
	{
		SecurityKey = "c2aa83e8bf8cb03ab063000115403677",
		Id = {
			Type = "Accessory",
			StorageKey = "Ring of the Vanguard IV",
			ItemId = 1378
		}
	},
	{
		SecurityKey = "c4ce95e0ae035d87378f81dc7b972767",
		Id = {
			Type = "Accessory",
			StorageKey = "Ring of the Arcanist IV",
			ItemId = 1379
		}
	},
	{
		SecurityKey = "6e86b6bb8a85e5ed9845b11a2ebbc671",
		Id = {
			Type = "Accessory",
			StorageKey = "Ring of Renewal IV",
			ItemId = 1380
		}
	},
	{
		SecurityKey = "c298d79e3552ab51e71abb4dace6b095",
		Id = {
			Type = "Accessory",
			StorageKey = "Ring of Twin Blades IV",
			ItemId = 1381
		}
	},
	{
		SecurityKey = "426af6d328aadac5040d08316bd267e6",
		Id = {
			Type = "Accessory",
			StorageKey = "Ring of Steelheart IV",
			ItemId = 1382
		}
	},
	{
		SecurityKey = "0c5bf48197a46426dff4f6385f4e37f1",
		Id = {
			Type = "Accessory",
			StorageKey = "Frosty Helmet",
			ItemId = 1383
		}
	},
	{
		SecurityKey = "174a5452ad91e0998ab7c51f913500c2",
		Id = {
			Type = "Accessory",
			StorageKey = "Red Ribbon",
			ItemId = 1384
		}
	},
	{
		SecurityKey = "3217eca722958eb7b9d6c40b42e23868",
		Id = {
			Type = "Accessory",
			StorageKey = "Romantic Bouquet",
			ItemId = 1385
		}
	},
	{
		SecurityKey = "2fe4ec4807068e2dac60916ceecb92a6",
		Id = {
			Type = "Accessory",
			StorageKey = "Cupid's Top Hat",
			ItemId = 1386
		}
	},
	{
		SecurityKey = "8e92dabb33cb034a560f7607222b6751",
		Id = {
			Type = "Accessory",
			StorageKey = "Easter Bunny Cape",
			ItemId = 1387
		}
	},
	{
		SecurityKey = "4dad559b8d0d30d707347db35faa6d10",
		Id = {
			Type = "Accessory",
			StorageKey = "Cracked Egg Helmet",
			ItemId = 1388
		}
	},
	{
		SecurityKey = "f2453214a2f8eae9826322ad676af3a1",
		Id = {
			Type = "PhysicalFruit",
			StorageKey = "Quake-Quake",
			ItemId = 1389
		}
	},
	{
		SecurityKey = "60909a1da234b0f6e2fa65488b9c978a",
		Id = {
			Type = "PhysicalFruit",
			StorageKey = "Rocket-Rocket",
			ItemId = 1390
		}
	},
	{
		SecurityKey = "61dcd6a7d8ae8af23a4ae60425d4c309",
		Id = {
			Type = "PhysicalFruit",
			StorageKey = "Magma-Magma",
			ItemId = 1391
		}
	},
	{
		SecurityKey = "3bf00866d03d4f6ba5911fdc8d52004c",
		Id = {
			Type = "PhysicalFruit",
			StorageKey = "Ice-Ice",
			ItemId = 1392
		}
	},
	{
		SecurityKey = "4c78b0b9b2a8dfd0ba3c91cecd8f828f",
		Id = {
			Type = "PhysicalFruit",
			StorageKey = "Buddha-Buddha",
			ItemId = 1393
		}
	},
	{
		SecurityKey = "8c12a3b667f1f99b2ca91c306b29154f",
		Id = {
			Type = "PhysicalFruit",
			StorageKey = "Flame-Flame",
			ItemId = 1394
		}
	},
	{
		SecurityKey = "8b1b426a439774326f439eeb90441a94",
		Id = {
			Type = "PhysicalFruit",
			StorageKey = "Dark-Dark",
			ItemId = 1395
		}
	},
	{
		SecurityKey = "5ed6bd2b6eb73552c38bfb08a8349909",
		Id = {
			Type = "PhysicalFruit",
			StorageKey = "Rubber-Rubber",
			ItemId = 1396
		}
	},
	{
		SecurityKey = "2c87f1e05e85a4e0b58928e3bc2c5bdb",
		Id = {
			Type = "PhysicalFruit",
			StorageKey = "Bomb-Bomb",
			ItemId = 1397
		}
	},
	{
		SecurityKey = "f755e6ca31a2083faa243e26664a4ced",
		Id = {
			Type = "PhysicalFruit",
			StorageKey = "Spike-Spike",
			ItemId = 1398
		}
	},
	{
		SecurityKey = "d36fdc0f8bafaa198570dbcc28009697",
		Id = {
			Type = "PhysicalFruit",
			StorageKey = "Blade-Blade",
			ItemId = 1399
		}
	},
	{
		SecurityKey = "dbaf6d0f41a7bc459a4884af081a857e",
		Id = {
			Type = "PhysicalFruit",
			StorageKey = "Smoke-Smoke",
			ItemId = 1400
		}
	},
	{
		SecurityKey = "14e15e4c35d1e1853e2457aead698fd1",
		Id = {
			Type = "PhysicalFruit",
			StorageKey = "Phoenix-Phoenix",
			ItemId = 1401
		}
	},
	{
		SecurityKey = "3fee2f6977dd1bc5d726f996923929e3",
		Id = {
			Type = "PhysicalFruit",
			StorageKey = "Spring-Spring",
			ItemId = 1402
		}
	},
	{
		SecurityKey = "8b3475a426e6aa04abf689f48d58dec5",
		Id = {
			Type = "PhysicalFruit",
			StorageKey = "Spider-Spider",
			ItemId = 1403
		}
	},
	{
		SecurityKey = "8926ecaa6d4aacea0afea4f4b4d014ce",
		Id = {
			Type = "PhysicalFruit",
			StorageKey = "Sand-Sand",
			ItemId = 1404
		}
	},
	{
		SecurityKey = "458d7ade93564c995923a56180b4e45d",
		Id = {
			Type = "PhysicalFruit",
			StorageKey = "Gravity-Gravity",
			ItemId = 1405
		}
	},
	{
		SecurityKey = "7a79f514dfb693c86c433d224b10e1f5",
		Id = {
			Type = "PhysicalFruit",
			StorageKey = "Pain-Pain",
			ItemId = 1406
		}
	},
	{
		SecurityKey = "3b9b171471436257ab58405d677341d4",
		Id = {
			Type = "PhysicalFruit",
			StorageKey = "Light-Light",
			ItemId = 1407
		}
	},
	{
		SecurityKey = "da6fe0fbf03d2f4343abd4bbec19b647",
		Id = {
			Type = "PhysicalFruit",
			StorageKey = "Love-Love",
			ItemId = 1408
		}
	},
	{
		SecurityKey = "f01d812066ede240ee1b7e1b66bf6d63",
		Id = {
			Type = "PhysicalFruit",
			StorageKey = "Control-Control",
			ItemId = 1409
		}
	},
	{
		SecurityKey = "12aa35ac78be16cf6b8caf4704521a7b",
		Id = {
			Type = "PhysicalFruit",
			StorageKey = "Venom-Venom",
			ItemId = 1410
		}
	},
	{
		SecurityKey = "3045daa3d35fb911c847b866a83b49fc",
		Id = {
			Type = "PhysicalFruit",
			StorageKey = "Spin-Spin",
			ItemId = 1411
		}
	},
	{
		SecurityKey = "31932b239795edfbbfade36913dc7859",
		Id = {
			Type = "PhysicalFruit",
			StorageKey = "Ghost-Ghost",
			ItemId = 1412
		}
	},
	{
		SecurityKey = "ecbeacdce528c052a24938638c451886",
		Id = {
			Type = "PhysicalFruit",
			StorageKey = "Shadow-Shadow",
			ItemId = 1413
		}
	},
	{
		SecurityKey = "93f5bf603aae3253917f5daecac38d74",
		Id = {
			Type = "PhysicalFruit",
			StorageKey = "Portal-Portal",
			ItemId = 1414
		}
	},
	{
		SecurityKey = "74ecce0ea4642ec024da6f6434fc4d5b",
		Id = {
			Type = "PhysicalFruit",
			StorageKey = "Spirit-Spirit",
			ItemId = 1415
		}
	},
	{
		SecurityKey = "340927b2eb4693f870ea7effc66da4cc",
		Id = {
			Type = "PhysicalFruit",
			StorageKey = "Blizzard-Blizzard",
			ItemId = 1416
		}
	},
	{
		SecurityKey = "e69a79c37437b4d8e940fe35c824f275",
		Id = {
			Type = "PhysicalFruit",
			StorageKey = "Dough-Dough",
			ItemId = 1417
		}
	},
	{
		SecurityKey = "61ecad31417f778a50015ff0467d7c71",
		Id = {
			Type = "PhysicalFruit",
			StorageKey = "Mammoth-Mammoth",
			ItemId = 1418
		}
	},
	{
		SecurityKey = "51321031f6800bd45cc1686391d5501f",
		Id = {
			Type = "PhysicalFruit",
			StorageKey = "Sound-Sound",
			ItemId = 1419
		}
	},
	{
		SecurityKey = "914696f2c78f435473aa4bcf720ad89f",
		Id = {
			Type = "PhysicalFruit",
			StorageKey = "T-Rex-T-Rex",
			ItemId = 1420
		}
	},
	{
		SecurityKey = "f512c7a67a8eea6207b72475bf0b4759",
		Id = {
			Type = "PhysicalFruit",
			StorageKey = "Diamond-Diamond",
			ItemId = 1421
		}
	},
	{
		SecurityKey = "d1955ab2d19e84f7a22b93280401c60d",
		Id = {
			Type = "PhysicalFruit",
			StorageKey = "Gas-Gas",
			ItemId = 1422
		}
	},
	{
		SecurityKey = "c773a6626fcdf08c4e33d3c11dc9e7ec",
		Id = {
			Type = "PhysicalFruit",
			StorageKey = "Kitsune-Kitsune",
			ItemId = 1423
		}
	},
	{
		SecurityKey = "a7ac2c285ea78c7335a48951b3e3b6fe",
		Id = {
			Type = "PhysicalFruit",
			StorageKey = "Yeti-Yeti",
			ItemId = 1424
		}
	},
	{
		SecurityKey = "0725384828b3043b5728d79d4dc8e506",
		Id = {
			Type = "PhysicalFruit",
			StorageKey = "Eagle-Eagle",
			ItemId = 1425
		}
	},
	{
		SecurityKey = "c4164050403997bff80e25048866951b",
		Id = {
			Type = "PhysicalFruit",
			StorageKey = "Creation-Creation",
			ItemId = 1426
		}
	},
	{
		SecurityKey = "3f58d5abd8b5b77179e913c1b3fb4f2a",
		Id = {
			Type = "PhysicalFruit",
			StorageKey = "Lightning-Lightning",
			ItemId = 1427
		}
	},
	{
		SecurityKey = "0ec29d8026208a39c3b803740e42d348",
		Id = {
			Type = "PhysicalFruit",
			StorageKey = "Celestial-Celestial",
			ItemId = 1428
		}
	},
	{
		SecurityKey = "ddd304937409be849088374c80651924",
		Id = {
			Type = "PhysicalFruit",
			StorageKey = "Oni-Oni",
			ItemId = 1429
		}
	},
	{
		SecurityKey = "e7049019398f809d6da758f582539864",
		Id = {
			Type = "PhysicalFruit",
			StorageKey = "Tiger-Tiger",
			ItemId = 1430
		}
	},
	{
		SecurityKey = "034ff32371fe1b7c48307106cd2ac39e",
		Id = {
			Type = "PhysicalFruit",
			StorageKey = "Meme-Meme",
			ItemId = 1431
		}
	},
	{
		SecurityKey = "a94ef5d79e6b90b949d109c041ed299e",
		Id = {
			Type = "Moveset",
			StorageKey = "Werewolf (Tiger)-Werewolf (Tiger)",
			ItemId = 1432
		}
	},
	{
		SecurityKey = "ac3da6d79a1f383fa2c12f2998d9565a",
		Id = {
			Type = "Moveset",
			StorageKey = "Empyrean (Kitsune)-Empyrean (Kitsune)",
			ItemId = 1433
		}
	},
	{
		SecurityKey = "19a8c4364a5a50c4f4eaf9d3d212c98f",
		Id = {
			Type = "Moveset",
			StorageKey = "Fiend (Yeti)-Fiend (Yeti)",
			ItemId = 1434
		}
	},
	{
		SecurityKey = "2500f2081b552ef9d4f53497da607318",
		Id = {
			Type = "Moveset",
			StorageKey = "Dragon (West)-Dragon (West)",
			ItemId = 1435
		}
	},
	{
		SecurityKey = "f998831af56138f01e7213e09343264e",
		Id = {
			Type = "Moveset",
			StorageKey = "Dragon (East)-Dragon (East)",
			ItemId = 1436
		}
	},
	{
		SecurityKey = "6406ac9542e051e3aa2d5874615d1877",
		Id = {
			Type = "Skin",
			StorageKey = "DARKBLADESKINdefault",
			ItemId = 1437
		}
	},
	{
		SecurityKey = "bd09beee4fd231ea34cc557e809707bf",
		Id = {
			Type = "Skin",
			StorageKey = "DARKBLADESKINslayer",
			ItemId = 1438
		}
	},
	{
		SecurityKey = "efa2c3616d0c6fe4a4b9c3547d2b3c59",
		Id = {
			Type = "Equipment",
			StorageKey = "WestDragBodyArmor",
			ItemId = 1439
		}
	},
	{
		SecurityKey = "30d66bd28e64e501e04b312d145b965a",
		Id = {
			Type = "Equipment",
			StorageKey = "WestDragHeadArmor",
			ItemId = 1440
		}
	},
	{
		SecurityKey = "927b8a1547200fc0bd5ccb5bdf258b47",
		Id = {
			Type = "Equipment",
			StorageKey = "WestDragSaddle",
			ItemId = 1441
		}
	},
	{
		SecurityKey = "584513a690f0503f26fc3b427994c567",
		Id = {
			Type = "Equipment",
			StorageKey = "EastDragBodyArmor",
			ItemId = 1442
		}
	},
	{
		SecurityKey = "504d90320b7372cd7fee7e1a335559d7",
		Id = {
			Type = "Equipment",
			StorageKey = "EastDragCrown",
			ItemId = 1443
		}
	},
	{
		SecurityKey = "9044d233222f63cc4404933adfd63355",
		Id = {
			Type = "Equipment",
			StorageKey = "EastDragSaddle",
			ItemId = 1444
		}
	},
	{
		SecurityKey = "c14c76ebaf9c0e274e9885a2efd6b874",
		Id = {
			Type = "Ability",
			StorageKey = "Aura",
			ItemId = 1445
		}
	},
	{
		SecurityKey = "f6fb2cc671f9f0afde94d2e9530887ca",
		Id = {
			Type = "Skin",
			StorageKey = "AURASKINdefault",
			ItemId = 1446
		}
	},
	{
		SecurityKey = "26c6891c28540f0a19a372efc0cf49c6",
		Id = {
			Type = "PhysicalFruit",
			StorageKey = "Dragon-Dragon",
			ItemId = 1447
		}
	},
	{
		SecurityKey = "5a6e50fe546a35b2b82ae0b71c4e810c",
		Id = {
			Type = "Accessory",
			StorageKey = "Sanguine Cloak",
			ItemId = 1448
		}
	},
	{
		SecurityKey = "f50e507d554f75d27fb337c6eb6614b3",
		Id = {
			Type = "Ability",
			StorageKey = "Water Walking",
			ItemId = 1449
		}
	},
	{
		SecurityKey = "3d5483b8bcb07e43ca64c8e3d20bd64e",
		Id = {
			Type = "Tool",
			StorageKey = "Bronze Trophy",
			ItemId = 1450
		}
	},
	{
		SecurityKey = "d568f32275dc95b9a5998db90d57d753",
		Id = {
			Type = "Tool",
			StorageKey = "Silver Trophy",
			ItemId = 1451
		}
	},
	{
		SecurityKey = "092e8e5a0da37e05f96c926db7058a17",
		Id = {
			Type = "Tool",
			StorageKey = "Gold Trophy",
			ItemId = 1452
		}
	},
	{
		SecurityKey = "2556287d659d46f32e38c4d9d9cacae7",
		Id = {
			Type = "Tool",
			StorageKey = "Platinum Trophy",
			ItemId = 1453
		}
	},
	{
		SecurityKey = "f7a22edc2d36f7cc96ec10fc3b3f51ae",
		Id = {
			Type = "Tool",
			StorageKey = "Diamond Trophy",
			ItemId = 1454
		}
	},
	{
		SecurityKey = "d04f6a46ea9046b39775bbea55a4689d",
		Id = {
			Type = "Tool",
			StorageKey = "Master Trophy",
			ItemId = 1455
		}
	},
	{
		SecurityKey = "3016b49a8988d3f23ddef2268ba2d874",
		Id = {
			Type = "Moveset",
			StorageKey = "Black Leg",
			ItemId = 1456
		}
	},
	{
		SecurityKey = "9c3b0d4bf74dfd66880562f8a9c67f48",
		Id = {
			Type = "Ability",
			StorageKey = "Air Jump",
			ItemId = 1457
		}
	},
	{
		SecurityKey = "db46f81a431d39d1226cab1c9e183e4f",
		Id = {
			Type = "Ability",
			StorageKey = "Instinct",
			ItemId = 1458
		}
	},
	{
		SecurityKey = "aaaeeadb5f371fb6a8d128dbab9a8424",
		Id = {
			Type = "Ability",
			StorageKey = "Instinct V2",
			ItemId = 1459
		}
	},
	{
		SecurityKey = "d043321a097d4819408a635a86174dd4",
		Id = {
			Type = "Ability",
			StorageKey = "Flash Step",
			ItemId = 1460
		}
	},
	{
		SecurityKey = "860afd8b2fd885a7b48aecfc4a85803d",
		Id = {
			Type = "Race",
			StorageKey = "Human",
			ItemId = 1461
		}
	},
	{
		SecurityKey = "98e669efc453e8d46fb0538b75d96e7b",
		Id = {
			Type = "Race",
			StorageKey = "Rabbit",
			ItemId = 1462
		}
	},
	{
		SecurityKey = "13cbb1a5859e6307755202edff487341",
		Id = {
			Type = "Race",
			StorageKey = "Shark",
			ItemId = 1463
		}
	},
	{
		SecurityKey = "460e6d2a43ad512e7e8de55e5b27044e",
		Id = {
			Type = "Race",
			StorageKey = "Angel",
			ItemId = 1464
		}
	},
	{
		SecurityKey = "8b6c357b34a1191e3a8714e7a0739008",
		Id = {
			Type = "Race",
			StorageKey = "Ghoul",
			ItemId = 1465
		}
	},
	{
		SecurityKey = "713826b7e3afe539d0f70533fffc6ec9",
		Id = {
			Type = "Race",
			StorageKey = "Cyborg",
			ItemId = 1466
		}
	},
	{
		SecurityKey = "69d54c3ca7d59869d261c6f3480b1f50",
		Id = {
			Type = "Race",
			StorageKey = "Draco",
			ItemId = 1467
		}
	},
	{
		SecurityKey = "ed473aa1a70af80a925e2a993c5ba8dc",
		Id = {
			Type = "Tool",
			StorageKey = "SwanTool",
			ItemId = 1468
		}
	},
	{
		SecurityKey = "6d72803fd633d70200a21c2e8f5b9f40",
		Id = {
			Type = "Tool",
			StorageKey = "Easter Chalice",
			ItemId = 1469
		}
	},
	{
		SecurityKey = "978f408eb62e1a270155ef6d502ee706",
		Id = {
			Type = "ProfileBackground",
			StorageKey = "Default",
			ItemId = 1470
		}
	},
	{
		SecurityKey = "76caa2ebd54a72aea9a39407d0a0c34a",
		Id = {
			Type = "ProfileBackground",
			StorageKey = "Oni",
			ItemId = 1471
		}
	},
	{
		SecurityKey = "d77f04946ad8d0548104e2796afcaf41",
		Id = {
			Type = "ProfileBackground",
			StorageKey = "Hacker",
			ItemId = 1472
		}
	},
	{
		SecurityKey = "b445db71ba8bc3ba274c25bade8f4f94",
		Id = {
			Type = "ProfileBackground",
			StorageKey = "Developer",
			ItemId = 1473
		}
	},
	{
		SecurityKey = "5befb0bce11fc05bec8335127834ad38",
		Id = {
			Type = "ProfileBackground",
			StorageKey = "Celestial",
			ItemId = 1474
		}
	},
	{
		SecurityKey = "abec45e68ff456bf8ddf0d96523b76c4",
		Id = {
			Type = "ProfileBackground",
			StorageKey = "Full Moon",
			ItemId = 1475
		}
	},
	{
		SecurityKey = "cf96adfed55a9bbbb2c3f6d6e7cda74a",
		Id = {
			Type = "ProfileBackground",
			StorageKey = "Halloween Tapestry",
			ItemId = 1476
		}
	},
	{
		SecurityKey = "8958d2ba890ba6fc4dd404c10b1dafb5",
		Id = {
			Type = "ProfileBackground",
			StorageKey = "Control Override",
			ItemId = 1477
		}
	},
	{
		SecurityKey = "b79454236579499b1253477969e26c0a",
		Id = {
			Type = "ProfileBackground",
			StorageKey = "Lover",
			ItemId = 1478
		}
	},
	{
		SecurityKey = "65876ab61cadd2f3246cf2274103304e",
		Id = {
			Type = "ProfileBackground",
			StorageKey = "Heartbreak",
			ItemId = 1479
		}
	},
	{
		SecurityKey = "c16f93ded595771edd48d0b20cd6b136",
		Id = {
			Type = "ProfileBackground",
			StorageKey = "Easter Tapestry",
			ItemId = 1480
		}
	},
	{
		SecurityKey = "5aadfdc26ac251d61f758bfd1c52db2f",
		Id = {
			Type = "ProfileBackground",
			StorageKey = "Aurora Sky",
			ItemId = 1481
		}
	},
	{
		SecurityKey = "ea6064e3172695e3acf9ba628a351768",
		Id = {
			Type = "Moveset",
			StorageKey = "The Sword Of The Brat",
			ItemId = 1482
		}
	},
	{
		SecurityKey = "908c272a6f5bb2477a33f4b812f84819",
		Id = {
			Type = "Skin",
			StorageKey = "BRATSKINdefault",
			ItemId = 1483
		}
	},
	{
		SecurityKey = "1a55de436c585ad5e9c10e6c6d09404d",
		Id = {
			Type = "Skin",
			StorageKey = "BRATSKINslayer",
			ItemId = 1484
		}
	},
	{
		SecurityKey = "f5354e6d7b6bacd8b0a913e4ba8a889a",
		Id = {
			Type = "Redeemable",
			StorageKey = "DogHouseGacha26",
			ItemId = 1485
		}
	},
	{
		SecurityKey = "2594a9446624472a6924151dded586f1",
		Id = {
			Type = "Redeemable",
			StorageKey = "The Sword Of The Brat",
			ItemId = 1486
		}
	},
	{
		SecurityKey = "6b2924bfda2f8510f5d095ace5efec24",
		Id = {
			Type = "Redeemable",
			StorageKey = "BRATSKINslayer",
			ItemId = 1487
		}
	},
	{
		SecurityKey = "596291b43d8ff1427797140e4d06acd5",
		Id = {
			Type = "ProfileBackground",
			StorageKey = "Doge",
			ItemId = 1488
		}
	},
	{
		SecurityKey = "343147d00e9a89d990e6ab7fe9eec8c5",
		Id = {
			Type = "ProfileFullArt",
			StorageKey = "Doge",
			ItemId = 1489
		}
	},
	{
		SecurityKey = "4948986329ca5116b8039b53bf5ab066",
		Id = {
			Type = "Redeemable",
			StorageKey = "Doge",
			ItemId = 1490
		}
	},
	{
		SecurityKey = "8679200135c36917de8cba8a36fd6de2",
		Id = {
			Type = "ProfileFullArt",
			StorageKey = "Beach",
			ItemId = 1491
		}
	},
	{
		SecurityKey = "66c0339a139370742c06532b179011df",
		Id = {
			Type = "Redeemable",
			StorageKey = "Big Money Reward",
			ItemId = 1492
		}
	},
	{
		SecurityKey = "d53b7800e625b832c85faad6f9313ce6",
		Id = {
			Type = "Redeemable",
			StorageKey = "Medium Money Reward",
			ItemId = 1493
		}
	},
	{
		SecurityKey = "d24225872502e155187b26f7a84bd8de",
		Id = {
			Type = "Redeemable",
			StorageKey = "Small Money Reward",
			ItemId = 1494
		}
	},
	{
		SecurityKey = "08f55cb4155783a5d85f2693afeea967",
		Id = {
			Type = "Tool",
			StorageKey = "Silver Sunken Chest",
			ItemId = 1495
		}
	},
	{
		SecurityKey = "642226f8f43cd5c9380baef40a12a28f",
		Id = {
			Type = "Tool",
			StorageKey = "Gold Sunken Chest",
			ItemId = 1496
		}
	},
	{
		SecurityKey = "4082b924ba9c2e54e3c69c9f2a567c44",
		Id = {
			Type = "Tool",
			StorageKey = "Diamond Sunken Chest",
			ItemId = 1497
		}
	},
	{
		SecurityKey = "14abb3fc29aca9f89b574fd24c37f147",
		Id = {
			Type = "Tool",
			StorageKey = "Fragment Sunken Chest",
			ItemId = 1498
		}
	},
	{
		SecurityKey = "3fe533000fa823b36ee713991ca325d3",
		Id = {
			Type = "Tool",
			StorageKey = "Summer Sunken Chest",
			ItemId = 1499
		}
	},
	{
		SecurityKey = "3aa62e3e8843366d48c578704fd07fc5",
		Id = {
			Type = "Tool",
			StorageKey = "Fall Sunken Chest",
			ItemId = 1500
		}
	},
	{
		SecurityKey = "0fcc7b649f227e697536b9cdcd16d5d4",
		Id = {
			Type = "Tool",
			StorageKey = "Azure Sunken Chest",
			ItemId = 1501
		}
	},
	{
		SecurityKey = "fd117de056281801734271f0e325a7a1",
		Id = {
			Type = "Tool",
			StorageKey = "Aquamarine Sunken Chest",
			ItemId = 1502
		}
	},
	{
		SecurityKey = "d2add80236bf7a279826b533555d2406",
		Id = {
			Type = "Title",
			StorageKey = "Demon Eye",
			ItemId = 1503
		}
	},
	{
		SecurityKey = "0939f1692bfcf2486216b60c89162068",
		Id = {
			Type = "Title",
			StorageKey = "Heavyweight Fishing Champion",
			ItemId = 1504
		}
	},
	{
		SecurityKey = "dfdc266840b7c06293a598eaa3c49a74",
		Id = {
			Type = "Title",
			StorageKey = "Fisherman",
			ItemId = 1505
		}
	},
	{
		SecurityKey = "9fc3b1c4f1d4377a82efd0ddf8621e5c",
		Id = {
			Type = "Title",
			StorageKey = "true egglord",
			ItemId = 1506
		}
	},
	{
		SecurityKey = "e82da96fe951cbb1d41e2efd2acc1aa3",
		Id = {
			Type = "Title",
			StorageKey = "Master Fisherman",
			ItemId = 1507
		}
	},
	{
		SecurityKey = "086d5c6c66b60eb2e603a5da5905c124",
		Id = {
			Type = "Title",
			StorageKey = "The Debugger",
			ItemId = 1508
		}
	},
	{
		SecurityKey = "f6a7d5b74a2860617b28b1f91ab9352a",
		Id = {
			Type = "Title",
			StorageKey = "Godly Rods",
			ItemId = 1509
		}
	},
	{
		SecurityKey = "0fd10b0913df0f2a92bd724790fe44d2",
		Id = {
			Type = "Title",
			StorageKey = "Treasure Catcher",
			ItemId = 1510
		}
	},
	{
		SecurityKey = "6900c5ecd6fa6a5d5281f2a64e6fd62d",
		Id = {
			Type = "Title",
			StorageKey = "Jack of all Trades",
			ItemId = 1511
		}
	},
	{
		SecurityKey = "3aad275a7ffc7a8f9d6f17c423f26348",
		Id = {
			Type = "Title",
			StorageKey = "Grounded",
			ItemId = 1512
		}
	},
	{
		SecurityKey = "cdf0c40566e440075e31e355b67fa3d2",
		Id = {
			Type = "Title",
			StorageKey = "Youtuber",
			ItemId = 1513
		}
	},
	{
		SecurityKey = "9297454ab6ef1f1a65ddacecaa5562d5",
		Id = {
			Type = "Title",
			StorageKey = "Fish Wrangler",
			ItemId = 1514
		}
	},
	{
		SecurityKey = "c8c0b4b21657222a093075ce4c9d7c22",
		Id = {
			Type = "Moveset",
			StorageKey = "Magnet-Magnet",
			ItemId = 1515
		}
	},
	{
		SecurityKey = "2ca0250e7c05921172973fa9db7ff21a",
		Id = {
			Type = "PhysicalMoveset",
			StorageKey = "Magnet-Magnet",
			ItemId = 1516
		}
	},
	{
		SecurityKey = "9316fefb0ef95f4391a45ba4dcf22ed1",
		Id = {
			Type = "Redeemable",
			StorageKey = "Permanent Magnet-Magnet",
			ItemId = 1517
		}
	},
	{
		SecurityKey = "5959afcd16f287731ccd50f91065aace",
		Id = {
			Type = "Redeemable",
			StorageKey = "x1 Chromatic Magnet 2026 Box",
			ItemId = 1518
		}
	},
	{
		SecurityKey = "f3769a67a822bdf040b5f7834d5f1035",
		Id = {
			Type = "Redeemable",
			StorageKey = "x3 Chromatic Magnet 2026 Box",
			ItemId = 1519
		}
	},
	{
		SecurityKey = "82c851df8c471e2db946ff962952d4a1",
		Id = {
			Type = "Redeemable",
			StorageKey = "x10 Chromatic Magnet 2026 Box",
			ItemId = 1520
		}
	},
	{
		SecurityKey = "cbb21a2b65b75bc237c292e3efb8ceeb",
		Id = {
			Type = "Redeemable",
			StorageKey = "x50 Chromatic Magnet 2026 Box",
			ItemId = 1521
		}
	},
	{
		SecurityKey = "758a6dc931388cd1a2e90e27103e3709",
		Id = {
			Type = "PhysicalMoveset",
			StorageKey = "Sealed Fiend",
			ItemId = 1522
		}
	},
	{
		SecurityKey = "9d111ffde70681d939da99e0c039c473",
		Id = {
			Type = "PhysicalMoveset",
			StorageKey = "Heavenly Gravity",
			ItemId = 1523
		}
	},
	{
		SecurityKey = "6b34a99cff368d74f483191600512689",
		Id = {
			Type = "PhysicalMoveset",
			StorageKey = "Red Ghost",
			ItemId = 1524
		}
	},
	{
		SecurityKey = "d55d2c2dff031e791b615148042397a8",
		Id = {
			Type = "PhysicalMoveset",
			StorageKey = "Arcsteel Magnet",
			ItemId = 1525
		}
	},
	{
		SecurityKey = "3ee8c3371157d1ed783b98c2abf029dd",
		Id = {
			Type = "PhysicalMoveset",
			StorageKey = "Lime Blade",
			ItemId = 1526
		}
	},
	{
		SecurityKey = "8c9a792d4b5d1cd41b5ee72fd487f834",
		Id = {
			Type = "ProfileBackground",
			StorageKey = "Vaporwave",
			ItemId = 1527
		}
	},
	{
		SecurityKey = "305df22ca25b24845d3c009434a19ee2",
		Id = {
			Type = "ProfileFullArt",
			StorageKey = "Vaporwave",
			ItemId = 1528
		}
	},
	{
		SecurityKey = "374b1f368e3573710fb1db30d172bd8c",
		Id = {
			Type = "Redeemable",
			StorageKey = "Vaporwave",
			ItemId = 1529
		}
	},
	{
		SecurityKey = "7cac9142bd12b66bfb2dca32a9c6a892",
		Id = {
			Type = "Redeemable",
			StorageKey = "20K Money",
			ItemId = 1530
		}
	},
	{
		SecurityKey = "2abbd4c7f6a018e982629b321148c037",
		Id = {
			Type = "Accessory",
			StorageKey = "Royal Nimbus",
			ItemId = 1531
		}
	},
	{
		SecurityKey = "80d3cb117126b8b8b83de603cff0f3d7",
		Id = {
			Type = "Skin",
			StorageKey = "FIENDSKINsealed",
			ItemId = 1532
		}
	},
	{
		SecurityKey = "7f9dd5293e4b6fc2c65d6331af857b4f",
		Id = {
			Type = "Skin",
			StorageKey = "GRAVITYSKINdefault",
			ItemId = 1533
		}
	},
	{
		SecurityKey = "1502ae54e0317ff3aadb224823520b41",
		Id = {
			Type = "Skin",
			StorageKey = "GRAVITYSKINheavenly",
			ItemId = 1534
		}
	},
	{
		SecurityKey = "a95566fb680addd3196b038ddded5587",
		Id = {
			Type = "Skin",
			StorageKey = "GHOSTSKINdefault",
			ItemId = 1535
		}
	},
	{
		SecurityKey = "18d966787989fe65af4c65d8ce797923",
		Id = {
			Type = "Skin",
			StorageKey = "GHOSTSKINred",
			ItemId = 1536
		}
	},
	{
		SecurityKey = "b8bd5ec0d957463a9300ea191782eda6",
		Id = {
			Type = "Skin",
			StorageKey = "MAGNETSKINdefault",
			ItemId = 1537
		}
	},
	{
		SecurityKey = "c41348ad3b8f3efa498f00a1a69b4fbc",
		Id = {
			Type = "Skin",
			StorageKey = "MAGNETSKINarksteel",
			ItemId = 1538
		}
	},
	{
		SecurityKey = "d697bef2d7243cc055c54ad9a5d017a6",
		Id = {
			Type = "Skin",
			StorageKey = "BLADESKINdefault",
			ItemId = 1539
		}
	},
	{
		SecurityKey = "9985c176733d3442061399b97bf8d2be",
		Id = {
			Type = "Skin",
			StorageKey = "BLADESKINlime",
			ItemId = 1540
		}
	},
	{
		SecurityKey = "ea277a2d7886e6b115fada050be93782",
		Id = {
			Type = "Redeemable",
			StorageKey = "+50 Sword Mastery",
			ItemId = 1541
		}
	},
	{
		SecurityKey = "31555907cb6c315026c73261f964cb82",
		Id = {
			Type = "Redeemable",
			StorageKey = "+100 Sword Mastery",
			ItemId = 1542
		}
	},
	{
		SecurityKey = "bfaad8e6eb2030676e0538277c30ce65",
		Id = {
			Type = "Redeemable",
			StorageKey = "+150 Sword Mastery",
			ItemId = 1543
		}
	},
	{
		SecurityKey = "49a0dddcee2835c1bc134cf77cb739da",
		Id = {
			Type = "Redeemable",
			StorageKey = "+200 Sword Mastery",
			ItemId = 1544
		}
	},
	{
		SecurityKey = "338c6ae9cce2ff98a9432a516ef0f983",
		Id = {
			Type = "Redeemable",
			StorageKey = "+250 Sword Mastery",
			ItemId = 1545
		}
	},
	{
		SecurityKey = "aa903904851f3cf6b4ae21657219d334",
		Id = {
			Type = "Redeemable",
			StorageKey = "+300 Sword Mastery",
			ItemId = 1546
		}
	},
	{
		SecurityKey = "f580c2ec2b97b97921532107dbb5b0e2",
		Id = {
			Type = "Redeemable",
			StorageKey = "+350 Sword Mastery",
			ItemId = 1547
		}
	},
	{
		SecurityKey = "6171c96693e95a4ec3c4618d4b1589e5",
		Id = {
			Type = "Redeemable",
			StorageKey = "+400 Sword Mastery",
			ItemId = 1548
		}
	},
	{
		SecurityKey = "c3c9cedf27a6b313c2aea3da606ae468",
		Id = {
			Type = "Redeemable",
			StorageKey = "+50 Gun Mastery",
			ItemId = 1549
		}
	},
	{
		SecurityKey = "07beef950a3d30b84df78a091120ba9b",
		Id = {
			Type = "Redeemable",
			StorageKey = "+100 Gun Mastery",
			ItemId = 1550
		}
	},
	{
		SecurityKey = "82c3e9339cf10ca1c8019c9b4c24d417",
		Id = {
			Type = "Redeemable",
			StorageKey = "+150 Gun Mastery",
			ItemId = 1551
		}
	},
	{
		SecurityKey = "9c529e626ed76eadcf90a5a6e04ab6f9",
		Id = {
			Type = "Redeemable",
			StorageKey = "+200 Gun Mastery",
			ItemId = 1552
		}
	},
	{
		SecurityKey = "c76847f3bcf365cbcc32b0b23eba7789",
		Id = {
			Type = "Redeemable",
			StorageKey = "+250 Gun Mastery",
			ItemId = 1553
		}
	},
	{
		SecurityKey = "ce4a9a410d8c208467152a8c857e0fca",
		Id = {
			Type = "Redeemable",
			StorageKey = "+300 Gun Mastery",
			ItemId = 1554
		}
	},
	{
		SecurityKey = "c1b9108cd322f75b12249995e38538ea",
		Id = {
			Type = "Redeemable",
			StorageKey = "+350 Gun Mastery",
			ItemId = 1555
		}
	},
	{
		SecurityKey = "ae382659850c52f740e253bdfd9abf63",
		Id = {
			Type = "Redeemable",
			StorageKey = "+400 Gun Mastery",
			ItemId = 1556
		}
	},
	{
		SecurityKey = "5fe44db1ab68f9a1690ba22b8f1ab87d",
		Id = {
			Type = "Redeemable",
			StorageKey = "+50 Fruit Mastery",
			ItemId = 1557
		}
	},
	{
		SecurityKey = "6643211aed453e383e2d5c92a677733e",
		Id = {
			Type = "Redeemable",
			StorageKey = "+100 Fruit Mastery",
			ItemId = 1558
		}
	},
	{
		SecurityKey = "aaf2542ce26377d25769e7fe1db2de8b",
		Id = {
			Type = "Redeemable",
			StorageKey = "+150 Fruit Mastery",
			ItemId = 1559
		}
	},
	{
		SecurityKey = "15945aa3890886387ead1c979ed08164",
		Id = {
			Type = "Redeemable",
			StorageKey = "+200 Fruit Mastery",
			ItemId = 1560
		}
	},
	{
		SecurityKey = "2e6288390caf1473920e2ec7d802df39",
		Id = {
			Type = "Redeemable",
			StorageKey = "+250 Fruit Mastery",
			ItemId = 1561
		}
	},
	{
		SecurityKey = "c77102304b63ceefd59e139101917fe4",
		Id = {
			Type = "Redeemable",
			StorageKey = "+300 Fruit Mastery",
			ItemId = 1562
		}
	},
	{
		SecurityKey = "71ba8f54c808e343068224017adfd5db",
		Id = {
			Type = "Redeemable",
			StorageKey = "+350 Fruit Mastery",
			ItemId = 1563
		}
	},
	{
		SecurityKey = "d358c40f507e666140a9aa0cedcd946c",
		Id = {
			Type = "Redeemable",
			StorageKey = "+400 Fruit Mastery",
			ItemId = 1564
		}
	},
	{
		SecurityKey = "09abf6cdf3c2b4e4dc408277acf00f5a",
		Id = {
			Type = "Redeemable",
			StorageKey = "+50 FightingStyle Mastery",
			ItemId = 1565
		}
	},
	{
		SecurityKey = "90c58e9b0fd890a7b86eb2bd3a3ef695",
		Id = {
			Type = "Redeemable",
			StorageKey = "+100 FightingStyle Mastery",
			ItemId = 1566
		}
	},
	{
		SecurityKey = "4fac3b04623c3d319701bf45be3f15cd",
		Id = {
			Type = "Redeemable",
			StorageKey = "+150 FightingStyle Mastery",
			ItemId = 1567
		}
	},
	{
		SecurityKey = "53159b62f3202f0161a6e0e23d9e69ba",
		Id = {
			Type = "Redeemable",
			StorageKey = "+200 FightingStyle Mastery",
			ItemId = 1568
		}
	},
	{
		SecurityKey = "82ebf936364bb2928b57d655431d9c9d",
		Id = {
			Type = "Redeemable",
			StorageKey = "+250 FightingStyle Mastery",
			ItemId = 1569
		}
	},
	{
		SecurityKey = "24e2fc74addb505c4ccaf13a538b2b3d",
		Id = {
			Type = "Redeemable",
			StorageKey = "+300 FightingStyle Mastery",
			ItemId = 1570
		}
	},
	{
		SecurityKey = "01ab66a488f59970fb010c55ad026eda",
		Id = {
			Type = "Redeemable",
			StorageKey = "+350 FightingStyle Mastery",
			ItemId = 1571
		}
	},
	{
		SecurityKey = "737235bc60499e3db499377e5a9e1034",
		Id = {
			Type = "Redeemable",
			StorageKey = "+400 FightingStyle Mastery",
			ItemId = 1572
		}
	},
	{
		SecurityKey = "bff1d68f42153bf8042f3a19f6b05d0a",
		Id = {
			Type = "Material",
			StorageKey = "Silver Key",
			ItemId = 1573
		}
	},
	{
		SecurityKey = "2488880c7c3206372cea5a7fb3a31eb0",
		Id = {
			Type = "Material",
			StorageKey = "Magnet Token",
			ItemId = 1574
		}
	},
	{
		SecurityKey = "98dd309522382dc4d35a5b72921a793f",
		Id = {
			Type = "Tool",
			StorageKey = "Disguiser",
			ItemId = 1575
		}
	},
	{
		SecurityKey = "9c39791da13ec990ba4a06a999f76aea",
		Id = {
			Type = "Tool",
			StorageKey = "Treasure Map",
			ItemId = 1576
		}
	},
	{
		SecurityKey = "422a5dc9d9b77b82674f00b71316a555",
		Id = {
			Type = "Accessory",
			StorageKey = "Shark Cape",
			ItemId = 1577
		}
	},
	{
		SecurityKey = "6ae2f1dab44fe58c293523f50b38eeae",
		Id = {
			Type = "Accessory",
			StorageKey = "Coral Crown",
			ItemId = 1578
		}
	},
	{
		SecurityKey = "fe96e625a51d2fc9b7695feb566aa52b",
		Id = {
			Type = "Accessory",
			StorageKey = "Shark Glasses",
			ItemId = 1579
		}
	},
	{
		SecurityKey = "0397db8f71ad814fafcf41fba825a981",
		Id = {
			Type = "Moveset",
			StorageKey = "Advanced Combat",
			ItemId = 1580
		}
	},
	{
		SecurityKey = "62cbac9041281018e60eae16f7aebacd",
		Id = {
			Type = "Tool",
			StorageKey = "Cactus Petal",
			ItemId = 1581
		}
	},
	{
		SecurityKey = "4020b4ff0c949137f64d04eba5c5cff2",
		Id = {
			Type = "Tool",
			StorageKey = "Refreshing Drink",
			ItemId = 1582
		}
	},
	{
		SecurityKey = "dcd6f5ea689f63a03ed292b2d6fc30fc",
		Id = {
			Type = "Tool",
			StorageKey = "Grappling Hook",
			ItemId = 1583
		}
	},
	{
		SecurityKey = "98d8f9fb706a0dacb9a1d0a1f0fbb573",
		Id = {
			Type = "Tool",
			StorageKey = "Tesla Ball",
			ItemId = 1584
		}
	},
	{
		SecurityKey = "2b47fa07edc994d362a3672bb595dc17",
		Id = {
			Type = "ProfileBackground",
			StorageKey = "Beach",
			ItemId = 1585
		}
	},
	{
		SecurityKey = "30e6bb20004bd3de06cb13aae0a117cf",
		Id = {
			Type = "Title",
			StorageKey = "Class S",
			ItemId = 1586
		}
	},
	{
		SecurityKey = "2ee7381ad5e7493e1e769af6e70cffac",
		Id = {
			Type = "Tool",
			StorageKey = "Cell Block Key",
			ItemId = 1587
		}
	},
	{
		SecurityKey = "f02c432333fa34eacd18dce4a1bd220b",
		Id = {
			Type = "Material",
			StorageKey = "Lightning Bolt",
			ItemId = 1588
		}
	},
	{
		SecurityKey = "c985de4718ed5e19765867f14d328eb0",
		Id = {
			Type = "Title",
			StorageKey = "I Was There",
			ItemId = 1589
		}
	},
	{
		SecurityKey = "cb5efb1817d5b474d2755dd2b22baa05",
		Id = {
			Type = "Tool",
			StorageKey = "Mythical Sunken Chest",
			ItemId = 1590
		}
	},
	{
		SecurityKey = "c16ae3bc7d3e285619043712623b8d3c",
		Id = {
			Type = "Redeemable",
			StorageKey = "LegendaryBoxS4",
			ItemId = 1591
		}
	},
	{
		SecurityKey = "10c3b4a7faf831ca2247a62c775061a7",
		Id = {
			Type = "Redeemable",
			StorageKey = "MythicalBoxS4",
			ItemId = 1592
		}
	},
	{
		SecurityKey = "757018d55456624c472adb4e71d69b35",
		Id = {
			Type = "Redeemable",
			StorageKey = "MysteryBoxS4",
			ItemId = 1593
		}
	},
	{
		SecurityKey = "624436e8a558269133970e60ea12c5e7",
		Id = {
			Type = "Redeemable",
			StorageKey = "PremiumBoxS4",
			ItemId = 1594
		}
	},
	{
		SecurityKey = "600ed11a099b014a94f41e4ec42a98f2",
		Id = {
			Type = "Redeemable",
			StorageKey = "RareBoxS4",
			ItemId = 1595
		}
	},
	{
		SecurityKey = "d1e2ceabf704450694872490e4e05cc2",
		Id = {
			Type = "Redeemable",
			StorageKey = "UncommonBoxS4",
			ItemId = 1596
		}
	},
	{
		SecurityKey = "93b38d14524e648253422337cb83eca7",
		Id = {
			Type = "Tool",
			StorageKey = "Rusted Key",
			ItemId = 1597
		}
	}
}
TableUtil.deepFreeze(v)
return table.clone(v)