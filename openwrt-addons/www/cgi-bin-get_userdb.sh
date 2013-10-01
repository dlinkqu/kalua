#!/bin/sh
. /tmp/loader

_ipsystem include
NODE="$( _ipsystem do "$REMOTE_ADDR" )"			# e.g. 10.10.147.1 -> 147
							# warning, we overwrite our own vars here:
eval $( _ipsystem do "$NODE" | grep "[N|I]ADR=" )	# e.g. LANADR=|WANADR=|WIFIADR=10.10.147.1

case "$REMOTE_ADDR" in
	192.168.*.1)
		# fixme! should match batman-originators
	;;
	$WANADR|$LANADR|$WIFIADR)
		# ok, is a real OLSR/Mid
	;;
	$LOADR)
		# localhost
	;;
	*)
		# simple way for ensure, that only real nodes (OLSR/Mid) can do this
		ip route | fgrep -q "$REMOTE_ADDR via " || {
			echo "# ERROR: Download from '$REMOTE_ADDR' not allowed"
			exit 0
		}
	;;
esac

if [ -e "/tmp/FREE" ]; then
	echo "# OK - FREE"
else
	# fixme! must be updated if something changes
	[ -e "/tmp/USERDB_COPY.cgi" ] || {
		# why tac? it's likely, that we grep for a new login - this should match faster
		# this is >1 magnitude faster than sed-tac
		grep -n '' /tmp/DB/USER/login/meta_index | sort -rn | cut -d: -f2- >/tmp/USERDB_COPY.cgi
		echo "# OK" >>/tmp/USERDB_COPY.cgi

		[ -h "/www/USERDB_COPY.txt" ] && ln -s "/tmp/USERDB_COPY.cgi" "/www/USERDB_COPY.txt"
	}

	_http redirect 302 "/USERDB_COPY.txt"
fi
