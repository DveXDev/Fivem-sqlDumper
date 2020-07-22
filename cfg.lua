Config = {}

Config.database = "bcrp1"
Config.tables = {
	"vrp_users",
	"vrp_user_identities",
	"vrp_user_ids",
	"vrp_user_moneys",
	"vrp_user_vehicles",
	"vrp_user_data",
	"vrp_srv_data"
}

Config.structure_only = false

-- Config.file_name = Config.database..os.date("%Y%m%d%H%M%S")..".sql"
Config.file_name = Config.database..".sql"

Config.debug = false