fx_version 'bodacious'
game 'gta5'

dependency 'mysql-async'

server_scripts {
	'@mysql-async/lib/MySQL.lua',
	"cfg.lua",
	"sv.lua"
}