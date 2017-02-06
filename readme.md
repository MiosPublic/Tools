Tools
---------------

This repository contains tools, scripts and snippets to perform small tasks such as checking cameras for hidden parameters or features. To run most scripts present here all you have to do is go to your Home Controller's *Develop Apps* tab (**Apps -> Develop Apps -> Test Luup code (Lua)**) and run the code presented here. 

Some scripts require you to change parameters and data within them while others will perform checks through out your network eighter by searching through your ARP list for known mac addresses.

Scripts that mention luvit require you to install the luvit server and run the scripts with it. Go to [luvit.io](http://www.luvit.io) and grab yourself a copy. After that, from a terminal or cmd, run Luvit.exe (./luvit) and the lua file in order to power it up using luvit.

* **server.lua** - requires luvit. It acts as a post server that receives incomming video recordings from IP Cameras. Add the IP Address:port of the server to the camera's HTTP Post and trigger a recording. In sercomm's case go to http://camera_ip/adm/im.htm and add the ip there. You can trigger a HTTP Recording from the camera using http://camera_ip/adm/http_trigger.cgi. The server listens for incoming HTTP post recordings and saves the file as an .avi in the same folder as the Luvit server.
* **pretty_data.lua** - Source Code for the Pretty Data plugin. It takes output from the Vera Simple User Data requests and formats it to HTML for better readability. Plugin can be installed from [here](http://apps.mios.com/plugin.php?id=8886).
* **camera_snapshot_checker.lua** - Added a alpha version of the camera snapshot checker! In short, you need to add each camera's IP manually to the camera_ip_table. Every X seconds the script will grab a snapshot image from the camera via eighter VERA Data request or manual curl and log details in /storage/camera_status.txt. Note that zombie processes can be triggered by this. It's a alpha of the script. Commiting it now just in case I'll get another OS Wipe.
* **sercomm_check_support_audio_types.lua** - The script loops through 10 possible Audio groups on any given Sercomm camera and tries to set it's audioType. If an audio type is supported and set the camera will return an OK. Useful way to check what Audio Types the camera supports.