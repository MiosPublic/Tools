local http = require("http")
local https = require("https")
local pathJoin = require('luvi').path.join
local fs = require('fs')

local function onRequest(req, res)
	local buffer = {}
	print(req.socket.options and "https" or "http", req.method, req.url)
	if req.method == "POST" then
		req:on('data', function(chunk)
			table.insert(buffer, chunk)
			if type(chunk) == "string" then
				
			end
		end)
		req:on('end', function()
			print("Saving video file -------------------------")
			file = io.open("vid-"..os.time()..".avi", "a")
			for i = 1, #buffer do
				print("Completion: "..i.."/"..#buffer.."")
				file:write(""..buffer[i].."")
			end
			file:close()
			print("File saved -------------------------------")
			buffer = {}
		end)
	else

		local htmlString = [[<img src="http://192.168.6.218/img/video.mjpeg">
							<form action = "" method = "post">
								<input type="text" name="Camera IP"><br>
								<input type="submit" formaction="">
							</form>
							]]
		local body = htmlString
		res:setHeader("Content-Type", "text/html")
		res:setHeader("Content-Length", #body)
		res:finish(body)
	end
end


http.createServer(onRequest):listen(8080)
print("Server listening at http://localhost:8080/")
