
local http = require("socket.http")
local https = require("ssl.https")
local mime = require("mime")
local dkjson = require("dkjson")
local ltn12 = require("ltn12")

deviceList = {}
g_ip_address = ""
UPDATE_RATE = 60

function FindAddress()
	local gatewayAddress = ""
	local stdout = io.popen("GetNetworkState.sh ip_wan")
	local wanIp = stdout:read("*a")
	stdout:close()
	if wanIp then
		gatewayAddress = wanIp
	end
	return gatewayAddress
end

function main( )
	luup.log("Initialising User Data Plugin::::::::::::::::::::::::::::")
	g_ip_address = FindAddress( )
	luup.log("IP IS: "..g_ip_address.."")
	GetUserDataString(g_ip_address)


	MakePrettyHTML()
	luup.call_delay("Update", UPDATE_RATE)
	luup.log("User Data Plugin initialized")
end

function GetUserDataString(_ip)
	local data_request = "http://".._ip..":3480/data_request?id=sdata&output_format=xml"

	local code, content, trei = luup.inet.wget(data_request) --HttpsRequest(data_request, "GET")
	luup.log("CODE IS: "..code.."")
	if content ~= nil then
		luup.log("Content is: "..content.."")
	end
	local index = 1
	local udTable = {}

	for value in string.gmatch(content,"[^\r\n]+") do 
	    udTable [index] = value
	    index = index + 1

	end

	for i,v in ipairs(udTable) do
		local entryName = 'device name="'
		local device_namePos = string.find(v, entryName)
		local altid_pos = string.find(v, "altid")
		local ip_pos = string.find(v,' ip="')
		local commFailure_pos = string.find(v, "commFailure=")
		local room_pos = string.find(v, "room=")
		local parrent_pos = string.find(v, "parent=")
		if string.find(v, entryName) then
			local device_name = v:sub(device_namePos+#entryName, altid_pos-3)
			local ip_address = ""
			if ip_pos then
				ip_address = v:sub(ip_pos+5, ip_pos+19)
				ip_address = ip_address:gsub('"', '')
				ip_address = ip_address:gsub("'", "")
				ip_address = ip_address:gsub(" ", "")
				ip_address = ip_address:gsub("tri", "")
				ip_address = ip_address:gsub("st", "")
			end
			local comFailBool = false
			if commFailure_pos then
				local comFail = v:sub(commFailure_pos+13, commFailure_pos+14)
				comFail = comFail:gsub(" ", "")
				comFail = comFail:gsub('"', '')

				if comFail ~= "0" then
					comFailBool = true
				end
				luup.log("COM FAIL : "..comFail.."")
			end
			local device_room = v:sub(room_pos+6, parrent_pos-3)
			luup.log("ENTRY: "..device_name.."")
			luup.log("Room: "..device_room.."")
			local temp = {
				name = ""..device_name.."",
				room = ""..device_room.."",
				ip = ""..ip_address.."",
				color = "",
			}

			if comFailBool == false then
				temp.color = "#006F00"
			else
				temp.color = "#fde0dc"
			end
			table.insert(deviceList, temp)
		end
	end


	if trei ~= nil then
		luup.log(": "..trei.."")
	end
end

function ResetDeviceList( )
	deviceList = {}
end

function Update( )
	luup.log("Updating Pretty Device List")
	ResetDeviceList( )
	GetUserDataString(g_ip_address)
	MakePrettyHTML()
	luup.call_delay("Update", UPDATE_RATE)
end

function MakePrettyHTML ( )
	-- set permission for writing
	local chmodFolder = io.popen("chmod 777 /www/cmh")
	local htmlStringBegin = [[
		<html>
			<head><title>Pretty SData</title></head>
			<body>
				<ul>



	]]
	local finalHTML = htmlStringBegin
	for i = 1, #deviceList do
		finalHTML = ""..finalHTML.."<li><b><font color="..deviceList[i].color..">"..deviceList[i].name.."</b></font> | ".." IP: "..deviceList[i].ip.." | Room: "..deviceList[i].room.."</li>\n"
	end

	local htmlStringEnd = [[
				</ul>
			</body>
		</html>
	]]

	finalHTML = ""..finalHTML..""..htmlStringEnd..""
	htmlFile = io.open("www/cmh/pretty_data.html", "w")
	for value in string.gmatch(finalHTML,"[^\r\n]+") do 
		htmlFile:write(value)
	end
	htmlFile:close( )
end

main( )


