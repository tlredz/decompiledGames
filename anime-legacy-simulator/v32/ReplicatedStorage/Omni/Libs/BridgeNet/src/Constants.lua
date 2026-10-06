return (table.freeze({
	IDENTIFIER_CAP = 65536,
	IDENTIFIER_CAP_STRING = "2^16",
	SERVER_CONNECT_LOG = [[
connection '%*' was triggered by [%*] with data: 
===============
%* (%*B)
===============
at: script %* line %*]],
	SERVER_FIRE_LOG = [[
fired bridge '%*' to players: %* with data: 
===============
%* (%*B)
===============
]],
	CLIENT_CONNECT_LOG = [[
connection '%*' was triggered with data: 
===============
%* (%*B)
===============
at: script %* line %*]],
	CLIENT_FIRE_LOG = [[
fired bridge '%*' with data: 
===============
%* (%*B)
===============
]]
}))