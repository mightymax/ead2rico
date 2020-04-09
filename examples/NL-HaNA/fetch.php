<?php

$o = json_decode(file_get_contents('overzicht.json'));

foreach($o->documents as $document) {
	$eadid = $document->id;
	$url = "http://www.gahetna.nl/archievenoverzicht/ead/xml/eadid/{$eadid}";
	echo $url;
	$fp = fopen("ead/{$eadid}.xml", 'w');
	fwrite($fp, file_get_contents($url));
	fclose($fp);
	echo " done\n";
}