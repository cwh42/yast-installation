#!/bin/sh
#================
# FILE          : vnc.sh
#----------------
# PROJECT       : YaST (Yet another Setup Tool v2)
# COPYRIGHT     : (c) 2004 SUSE Linux AG, Germany. All rights reserved
#               :
# AUTHORS       : Marcus Schaefer <ms@suse.de> 
#               :
#               :
# BELONGS TO    : System installation and Administration
#               :
# DESCRIPTION   : VNC helper functions to start the Xvnc server
#               :
#               :
# STATUS        : $Id$
#----------------
#
#----[ setupVNCAuthentication ]------#
function setupVNCAuthentication () {
#---------------------------------------------------
# handle the VNCPassword variable to create a valid
# password file. If not set use "linux123" as pwd
#
	VNCPASS_EXCEPTION=0
	VNCPASS=/usr/X11R6/bin/vncpasswd.arg
	if [ -z "$vncpassword" ];then
	if [ ! -z "$VNCPassword" ];then
		vncpassword=$VNCPassword
	else
		vncpassword=""
	fi
	fi
	if [ ! -e /root/.vnc/passwd ]; then
		rm -rf /root/.vnc && mkdir -p /root/.vnc
		$VNCPASS /root/.vnc/passwd "$vncpassword"
		if [ $? = 0 ];then
			chmod 600 /root/.vnc/passwd
		else
			log "\tcouldn't create VNC password file..."
			VNCPASS_EXCEPTION=1
		fi
	fi
}

#----[ startVNCServer ]------#
function startVNCServer () {
#---------------------------------------------------
# start Xvnc server and write a log file from the
# VNC server process
#
	echo
	echo starting VNC server...
	echo A log file will be written to: /tmp/vncserver.log ...
	cat <<-EOF
	
	***
	***           You can connect to $IP, display :1 now with vncviewer
	***           Or use a Java capable browser on  http://$IP:5801/
	***
	
	(When YaST2 is finished, close your VNC viewer and return to this window.)
	
	EOF
	#==========================================
	# Fake hostname to make VNC screen pretty
	#------------------------------------------
	if [ "$(hostname)" = "(none)" ] ; then
		hostname $IP
	fi
	#==========================================
	# Start Xvnc...
	#------------------------------------------
	/usr/X11R6/bin/Xvnc :0 \
		-rfbauth /root/.vnc/passwd \
		-desktop Installation \
		-geometry 800x600 \
		-depth 16 \
		-rfbwait 120000 \
		-httpd /usr/share/vnc/classes \
		-rfbport 5901 \
		-httpport 5801 \
		-fp /usr/X11R6/lib/X11/fonts/misc/,/usr/X11R6/lib/X11/fonts/uni/ \
	&> /tmp/vncserver.log &
	xserver_pid=$!
	export DISPLAY=:0
	export XCURSOR_CORE=1
}