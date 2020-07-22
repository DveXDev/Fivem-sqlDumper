local banco = "bcrp1"
local tabelas = {
	"vrp_users",
	"vrp_user_identities",
	"vrp_user_ids",
	"vrp_user_moneys",
	"vrp_user_vehicles",
	"vrp_user_data",
	"vrp_srv_data"
}

local estrutura_apenas = false

AddEventHandler('onMySQLReady',function()
	Citizen.CreateThreadNow(function()
		Wait(500)
		local currentDatetime = os.date("%Y%m%d%H%M%S")
		local currentDatetime = ""
		local dados = nil
		
		local logFile,errorReason = io.open(banco..currentDatetime..".sql","w")
		if not logFile then return print("["..GetCurrentResourceName().."]: "..errorReason) end
		
		dados = MySQL.Sync.fetchAll("SHOW CREATE DATABASE `"..banco.."`;", {})
		if dados then
			dados[1]["Create Database"] = dados[1]["Create Database"]:gsub("CREATE DATABASE", "CREATE DATABASE IF NOT EXISTS")
			logFile:write(dados[1]["Create Database"]..";\n\n")
			logFile:write("USE `"..banco.."`;\n\n")
			for k,v in pairs(tabelas) do
				dados = MySQL.Sync.fetchAll("SHOW CREATE TABLE `"..banco.."`.`"..v.."`;", {})
				if dados then
					dados[1]["Create Table"] = dados[1]["Create Table"]:gsub("CREATE TABLE", "CREATE TABLE IF NOT EXISTS")
					logFile:write(dados[1]["Create Table"]..";\n\n")
				
					if not estrutura_apenas then
						local insert = ""
						local linha = ""
						local columns = {}
						dados = MySQL.Sync.fetchAll("SELECT * FROM `information_schema`.`COLUMNS` WHERE TABLE_SCHEMA='"..banco.."' AND TABLE_NAME='"..v.."' ORDER BY ORDINAL_POSITION;", {})
						for i,j in pairs(dados) do
							columns[i] = j['COLUMN_NAME']
							if insert == "" then
								insert = "INSERT INTO `"..v.."` (`"..j['COLUMN_NAME'].."`"
							else
								insert = insert..",`"..j['COLUMN_NAME'].."`"
							end
						end
						insert = insert..") VALUES\n"
						dados = MySQL.Sync.fetchAll("SELECT * FROM `"..v.."`", {})
						for i,j in pairs(dados) do
							linha = ""
							for l,m in pairs(columns) do
								if linha == "" then
									linha =  "\t("..trataTipo(j[m])
								else
									linha = linha..", "..trataTipo(j[m])
								end
							end
							if i == #dados then
								linha = linha..");\n"
							else
								linha = linha.."),\n"
							end
							insert = insert..linha
						end
						logFile:write(insert.."\n\n")
					end
				else
					print("["..GetCurrentResourceName().."]: Invalid table: `"..banco.."`.`"..v.."`")
				end
			end
		else
			print("["..GetCurrentResourceName().."]: Invalid database: `"..banco.."`")
		end
		logFile:close()
	end)
end)

function trataTipo(node)
	if type(node) == "number" then
		return(node)
	elseif type(node) == "string" then
		return("'"..node.."'")
	elseif type(node) == "nil" then
		return("NULL")
	elseif type(node) == "boolean" then
		if node == true then
			return(1)
		else
			return(0)
		end
	else
		print("["..GetCurrentResourceName().."]: Invalid data type: "..node.."("..type(node)..")")
	end
end

function sprint(sql)
	print("\n")
	print(sql)
	print_table(MySQL.Sync.fetchAll(sql, {}))
	print("\n")
end
function print_table(node)
    local cache, stack, output = {},{},{}
    local depth = 1
    local output_str = "{\n"

    while true do
        local size = 0
        for k,v in pairs(node) do
            size = size + 1
        end

        local cur_index = 1
        for k,v in pairs(node) do
            if (cache[node] == nil) or (cur_index >= cache[node]) then

                if (string.find(output_str,"}",output_str:len())) then
                    output_str = output_str .. ",\n"
                elseif not (string.find(output_str,"\n",output_str:len())) then
                    output_str = output_str .. "\n"
                end

                -- This is necessary for working with HUGE tables otherwise we run out of memory using concat on huge strings
                table.insert(output,output_str)
                output_str = ""

                local key
                if (type(k) == "number" or type(k) == "boolean") then
                    key = "["..tostring(k).."]"
                else
                    key = "['"..tostring(k).."']"
                end

                if (type(v) == "number" or type(v) == "boolean") then
                    output_str = output_str .. string.rep('\t',depth) .. key .. " = "..tostring(v)
                elseif (type(v) == "table") then
                    output_str = output_str .. string.rep('\t',depth) .. key .. " = {\n"
                    table.insert(stack,node)
                    table.insert(stack,v)
                    cache[node] = cur_index+1
                    break
                else
                    output_str = output_str .. string.rep('\t',depth) .. key .. " = '"..tostring(v).."'"
                end

                if (cur_index == size) then
                    output_str = output_str .. "\n" .. string.rep('\t',depth-1) .. "}"
                else
                    output_str = output_str .. ","
                end
            else
                -- close the table
                if (cur_index == size) then
                    output_str = output_str .. "\n" .. string.rep('\t',depth-1) .. "}"
                end
            end

            cur_index = cur_index + 1
        end

        if (size == 0) then
            output_str = output_str .. "\n" .. string.rep('\t',depth-1) .. "}"
        end

        if (#stack > 0) then
            node = stack[#stack]
            stack[#stack] = nil
            depth = cache[node] == nil and depth + 1 or depth - 1
        else
            break
        end
    end

    -- This is necessary for working with HUGE tables otherwise we run out of memory using concat on huge strings
    table.insert(output,output_str)
    output_str = table.concat(output)

    print(output_str)
end