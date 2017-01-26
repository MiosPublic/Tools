--[[
*	Author: Bacioiu Ciprian
*	Version: 0.0.1
*	License: MIT
*	Device support: SERCOMM ONLY
*
*	The script loops through 10 possible Audio groups on any given Sercomm camera and tries to set it's audioType. If an audio type is supported 
*	and set the camera will return an OK. Useful way to check what Audio Types the camera supports.
--]]

local default_ip = "" -- add yoru camera IP here
local ip_list = "/"

local url_audio_groupCheck = "/adm/set_group.cgi?group=AUDIO&audio_out=1&in_audio_type="
username = "administrator" -- default login username! Might need to edit this before running
password = "admin" -- default password. Might need to edit this before running

audioType = {}
audioType[1] = "G.726"
audioType[2] = "G.711"
audioType[3] = "LPCM"
audioType[4] = "<unknown>"
audioType[5] = "AAC"

WGET_TIMEOUT = 10

for i = 6, 10 do
	audioType[i] = "<unknown>"
end

for i = 1, 10 do -- most Sercomm cameras, depending on the firmware, will have between 2 and 4 audio groups. 
	local status, content, code = luup.inet.wget("http://".. default_ip ..""..url_audio_groupCheck..""..i.."", WGET_TIMEOUT, username , password)
	luup.log("-----------------------")
	luup.log("Audio Group: "..audioType[i].."")
	luup.log("CONTENT: "..content.."")
	luup.log("CODE: "..code.."")
end