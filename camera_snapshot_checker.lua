--[[
	Author: Bacioiu Constantin Ciprain
	Publishing date: 06 / 02 / 2017
	Script status: Alpha!
	Camera Snapshot Checker:
	It uses both built in luup and bash-powered wget tools to
	retrieve a snapshoot from any given camera and compare the
	output between the two! 

]]
g_Counter = 0

camera_ip_table = {}
camera_ip_table[1] = { ip = "192.168.6.74", deviceID = "26", stdout = nil }
camera_ip_table[2] = { ip = "192.168.6.74", deviceID = "26", stdout = nil }

cameraIP = "192.168.6.101"
loopTable = {}
loopTableSize = 0
breakLoop = false
loopCounter = 1
logFileName = "camera_status.txt"

local clock = os.clock
function sleep(n)  -- seconds
   local t0 = clock()
   while clock() - t0 <= n do
   end
end

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
	GetUserData( )
	InitializeLoopTable()
	loopTableSize = #loopTable
	loop( )
end

function loop( )
	sleep(5)
	loopCounter = loopCounter + 1
	print("Loop counter: "..loopCounter.."")
	if loopCounter == 200 then
		breakLoop = true
	end
	GetSnapshoot( )
	GetSnapshootUPnP( )

	ForceProcessKill( )
	if breakLoop == false then
		loop()
	end
end

function InitializeLoopTable()
	for i = 1, 67 do
		loopTable[i] = 2
	end
end

function GetSnapshoot( )
	print("Acquiring snapshot - name: "..g_Counter.."")
	for i = 1, #camera_ip_table do
		local fileName = ""..g_Counter.."-"..math.random(1, 255)..".jpg"
		camera_ip_table[i].stdout = io.popen("curl -m 2 -o "..fileName.." 'http://admin:admin@"..camera_ip_table[i].ip.."/img/snapshot.cgi'")
		print("return snapshot: "..camera_ip_table[i].stdout:read("*a").."\n")
		g_Counter = g_Counter+1
		
		--- check the fileSize
		local size = GetFileSize(fileName)
		print("SIZE IS: "..size.."")
		print("Writtign to log")
		local bFailed = false
		local failStatus = ""
		if size <= 4925 then
			bFailed = true
			failStatus = "IMAGE SIZE IMPROPPER! IS CAMERA DOWN?! SIZE 4925"
		end

		WriteLogWithData(fileName, size, "Acquired via DIRECT CGI REQUEST "..failStatus.."")
		print("------------------------------------------------------------")
		camera_ip_table[i].stdout:close()
		DeleteFile(fileName)
	end
end

function GetSnapshootUPnP( )
	for i = 1, #camera_ip_table do
		print("Acquiring UPnP Snapshoot - name: "..g_Counter.."")
		local fileName = ""..g_Counter.."-"..math.random(1, 255)..".jpg"
		camera_ip_table[i].stdout = io.popen("curl -m 2 -o "..fileName.." 'http://127.0.0.1:3480/data_request?id=request_image&cam="..camera_ip_table[i].deviceID.."&res=low'")
		print("return snapshot: "..camera_ip_table[i].stdout:read("*a").."\n")
		g_Counter = g_Counter + 1

		local size = GetFileSize(fileName)
		print("SIZE IS: "..size.."")
		print("Writtign to log")
		local bFailed = false
		local failStatus = ""
		if size <= 4925 then
			bFailed = true
			failStatus = "IMAGE SIZE IMPROPPER! IS CAMERA DOWN?! SIZE 4925"
		end
		WriteLogWithData(fileName, size, "Acquired via Vera DATA Request  "..failStatus.."")
		print("------------------------------------------------------------")
		camera_ip_table[i].stdout:close()
		camera_ip_table[i].stdout = nil
		DeleteFile(fileName)
	end
	--end
end

function ForceProcessKill( )
	for i = 1, #camera_ip_table do
		if camera_ip_table[i].stdout ~= nil then
			camera_ip_table[i].stdout:close()
		end
	end
end

function GetFileSize(_filename)
	local f = io.open(_filename, "rb")
	local size = 0
	if f ~= nil then
		size = f:seek("end")
		f:close()
	end
	return size
end

function DeleteFile(_filename)
	local stdout = io.popen("rm -rf ".._filename.."")
end

function WriteLogWithData(_name, _size, _acquiredVia)
	local logFile = io.open("/storage/"..logFileName, "a+")
	logFile:write("T: "..os.date ("%c").." Image: ".._name.." | Size: ".._size.." | DOWNLOADED VIA: ".._acquiredVia.."\n")
	logFile:close( )
end

function GetUserData( )
	local data_request = "http://localhost:3480/data_request?id=user_data&output_format=xml"

	local stdout = io.popen("curl -o userdata.xml "..data_request.."")

	stdout:close()
	--local code, content, trei =  --HttpsRequest(data_request, "GET")
end

main( )

