#!/bin/bash

shazamDatabasePath=apps/com.shazam.android/db/library.db
shazamDbDevicePath=/data/data/com.shazam.android/databases/library.db
filename="myTags[`date +"%m_%d_%Y-%H:%M:%S]"`.html"

echo "rooted? yes/no"
read rooted

# TODO : check env (adb, python, ...)

echo "<html>"  >  $filename
echo "<!DOCTYPE html>" >> $filename
echo "<html>" >> $filename
echo 	"<head>" >> $filename
echo 	"<!-- En-tête de la page -->" >> $filename
echo 	"<meta charset="utf-8" />" >> $filename
echo	"<link rel="stylesheet" href="style.css" />" >> $filename
echo 	"<title>Shazam Song List</title>" >> $filename
echo 	"</head>" >> $filename

echo "<body>"  >> $filename
echo "<table>" >> $filename

echo "<caption>Songs list</caption>" >> $filename
echo "<thead>" >> $filename
	echo "<th>Artist</th>" >> $filename
	echo "<th>Title</th>" >> $filename
	echo "<th>Subtitle</th>" >> $filename
	echo "<th>Album</th>" >> $filename
	echo "<th>Subgenre</th>" >> $filename
	echo "<th>Date time</th>" >> $filename
	echo "<th>Location</th>" >> $filename
	echo "<th>GPS</th>" >> $filename
echo "</thead>" >> $filename

echo "<tbody>" >> $filename

if [ "$rooted" == "no" ]
then
	# Get shazam database from the device
	adb backup -f shazam.ab -noapk com.shazam.android && dd if=shazam.ab bs=1 skip=24 | python -c "import zlib,sys;sys.stdout.write(zlib.decompress(sys.stdin.read()))" | tar -xvf -
	# Then query the DB on the host
	sqlite3 -html $shazamDatabasePath "SELECT t.artist_name, t.title,  t.subtitle, t.album, t.subgenre_name, tg.short_datetime, tg.location_name , tg.lon FROM track t, tag tg WHERE tg.track_id = t._id ORDER BY tg.timestamp;" | while read line; do
		echo "$line" >> $filename
	done
else
	adb shell 'sqlite3 -html '$shazamDbDevicePath' "SELECT t.artist_name, t.title,  t.subtitle, t.album, t.subgenre_name, tg.short_datetime, tg.location_name , tg.lon FROM track t, tag tg WHERE tg.track_id = t._id ORDER BY tg.timestamp;"' >> $filename
fi

echo "</tbody>" >> $filename

echo "</table>" >> $filename
echo "</body>"  >> $filename
echo "</html>"  >> $filename

