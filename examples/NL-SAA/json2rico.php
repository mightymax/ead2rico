#!/usr/bin/php
<?php
$SCRIPT = array_shift($argv);
if (!count($argv)) {
	fwrite(STDERR, "usage: {$SCRIPT} unitid\n");
	exit(1);
}

$unitid = array_shift($argv);
$jsonURL = 'https://webservices.picturae.com/mediabank/media?apiKey=eb37e65a-eb47-11e9-b95c-60f81db16c0e&rows=1&q=' . $unitid;
$jsonString = @file_get_contents($jsonURL);
if (!$jsonString) {
	fwrite(STDERR, "Failed to load URL '{$jsonURL}'\n");
	exit(2);
}
$data = @json_decode($jsonString);
if (!$data) {
	fwrite(STDERR, "Failed to decode JSON data from URL '{$jsonURL}'\n");
	exit(2);
}

$record = $data->media[0];
$metadata = [];
foreach ($record->metadata as $r) {
	$metadata[$r->field] = [
		'label' => $r->label,
		'value' => $r->value
	];
}
// var_dump($metadata['dc_source']['value']); exit;

class ricoDocument extends DOMDocument
{

}

class ricoElement extends DOMElement {

	public function append($nodeName, $nodeValue = null, $attrName = null, $attrValue = null)
	{
		$node = $this->appendChild($this->ownerDocument->createElement($nodeName, $nodeValue));
		if (null !== $attrName) {
			$node->setAttribute($attrName, $attrValue);
		}
		return $node;
	}
}

$dom = new ricoDocument('1.0', 'utf-8');
$dom->registerNodeClass('DOMElement', 'ricoElement');

$dom->formatOutput = true;
$dom->loadXML(<<<XML
<rdf:RDF xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
	xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
	xmlns:html="http://www.w3.org/1999/xhtml"
	xmlns:rico="https://www.ica.org/standards/RiC/ontology#"
	xmlns:dcterms="http://purl.org/dc/terms/"
/>
XML
);

$rico = $dom->documentElement->append('rico:Record', null, 'rdf:about', $record->handle);
$rico->append('rico:Identifier', null, 'rdf:about', $record->entity_uuid);
$rico->append('rico:ContentType', null, 'rdf:resource', 'http://id.loc.gov/authorities/subjects/sh85101195');
$rico->append('rico:title')->append('dcterms:title', $metadata['dc_title']['value']);
$rico->append('rico:descriptiveNote')->append('dcterms:descriptiom', $metadata['dc_description']['value']);

//link to inventaris:
$d = new DOMDocument(); @$d->loadHTML($metadata['dc_source']['value']); $url = $d->documentElement->nodeValue;


$rico->append('rico:includedIn', '', 'rdf:resource', $url);

$hasInstantiation = $rico->append('rico:hasInstantiation');
$Instantiation = $hasInstantiation->append('rico:Instantiation', null, 'rdf:about', $record->handle."/Instantiation");
$Instantiation->append('rico:instantiates', null, 'rdf:resource', $record->handle);
$Instantiation->append('rico:carrierExtent', "1 foto");	
$Instantiation->append('dcterms:format', 'Foto', 'rdf:resource', 'http://id.loc.gov/authorities/subjects/sh85101195');
$Instantiation->append('rico:hasProvenance')->append('rico:Agent')->append('rico:hasAgentName')
	->append('AgentName')->append('rdfs:label', $metadata['dc_provenance']['value']);

$Instantiation->append('rico:createdBy')->append('rico:Agent')->append('rico:hasAgentName')
	->append('AgentName')->append('dcterms:creator', implode('; ', $metadata['sk_vervaardiger']['value']));

$hasPhysicalLocation = $Instantiation->append('rico:hasPhysicalLocation');

foreach($metadata['geografische_aanduiding']['value'][0] as $geografische_aanduiding) {
	$node = $hasPhysicalLocation->append('rico:PhysicalLocation');
	$node->append('rdfs:label', $geografische_aanduiding->label);
	$node->append('dcterms:coverage', $geografische_aanduiding->value);
}


foreach ($record->asset as $asset) {
	$Instantiation = $hasInstantiation->append('rico:Instantiation', null, 'rdf:about', $asset->topview);
	$Instantiation->append('rico:instantiates', null, 'rdf:resource', $record->handle);
	$Instantiation->append('rico:title')->append('rico:textualValue', $asset->dc_title);
	$Instantiation->append('rico:carrierExtent', "{$asset->width}x{$asset->height} px");
	$Instantiation->append('rico:Identifier', "{$asset->uuid}");
}

	
echo $dom->saveXml();