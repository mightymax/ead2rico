<?xml version="1.0" encoding="UTF-8"?>

<!-- XSLT stylesheet converting EAD to RiC-O -->
<!-- Endocoded Archival Description 2002 (EAD) into Records in Contexts Ontology (RiC-O) 0.1-->
<!-- Mark Lindeman, inspired by work from Ivo Zandhuis -->

<xsl:stylesheet version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
    xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
	xmlns:html="http://www.w3.org/1999/xhtml"
    xmlns:rico="https://www.ica.org/standards/RiC/ontology#">
<xsl:output method="xml" encoding="UTF-8" indent="yes"/>
<xsl:strip-space elements="*"/>

<xsl:param name="baseUri">http://gahetna.nl/</xsl:param>

<xsl:template match="ead">
    <rdf:RDF>
        <xsl:apply-templates select="eadheader"/>
    </rdf:RDF>
</xsl:template>

<xsl:template match="eadheader">
    <rico:Record rdf:resource="{eadid/@url}" rdf:about="record/{eadid}">
		<rico:identifier><xsl:value-of select="eadid"/></rico:identifier>
		<rico:hasDocumentaryFormType rdf:resource="https://www.ica.org/standards/RiC/vocabularies/documentaryFormTypes#FindingAid"/>
		<rico:regulatedBy rdf:resource="http://id.loc.gov/vocabulary/iso639-2"/>
		<rico:ruleFollowed xml:lang="en">ISAD(G): General International Standard Archival Description, International Council on Archives (2nd edition, 2000).</rico:ruleFollowed>
		<rico:managedBy rdf:resource="agents/{eadid/@mainagencycode}">
			<xsl:value-of select="filedesc/publicationstmt/publisher"/>
		</rico:managedBy>
		<rico:publishedBy rdf:resource="agents/{eadid/@mainagencycode}">
			<xsl:value-of select="filedesc/publicationstmt/publisher"/>
		</rico:publishedBy>
		<rico:publicationDate rdf:datatype="http://www.w3.org/2001/XMLSchema#date">
			<xsl:value-of select="filedesc/publicationstmt/date"/>
		</rico:publicationDate>
		<rico:hasLanguage rdf:resource="http://id.loc.gov/vocabulary/{/ead/eadheader/@langencoding}/{profiledesc/langusage/language/@langcode}">
			<xsl:value-of select="profiledesc/langusage/language"/>
		</rico:hasLanguage>
		<rico:describes rdf:resource="recordResource/{../archdesc/did/unitid}"/>
		<rico:hasInstantiation>
			<rico:Instantiation rdf:about="instantiation/{eadid}/i1"/>
				<rico:instantiates rdf:resource="record/{eadid}"/>
				<xsl:apply-templates select="./revisiondesc/change"/>
				<xsl:apply-templates select="filedesc/titlestmt/titleproper"/>
				<rico:heldBy rdf:resource="agent/{eadid/@mainagencycode}"/>
				<rdfs:seeAlso rdf:resource="{eadid/@url}"/>
		</rico:hasInstantiation>
    </rico:Record>
	<xsl:apply-templates select="../archdesc"/>
</xsl:template>


<xsl:template match="archdesc">
	<rico:RecordResource rdf:about="recordResource/{did/unitid}">
		<rico:describedBy rdf:resource="record/{../eadheader/eadid}"/>
		<rdf:type rdf:resource="https://www.ica.org/standards/RiC/ontology#RecordSet"/>
        <rico:hasRecordSetType
           rdf:resource="https://www.ica.org/standards/RiC/vocabularies/recordSetTypes#Collection"/>
        <rico:identifier><xsl:value-of select="did/unitid"/></rico:identifier>
		<xsl:apply-templates select="did/unittitle"/>
        <rico:beginningDate rdf:datatype="http://www.w3.org/2001/XMLSchema#gYear">
			<xsl:value-of select="substring-before(did/unitdate[@type='inclusive']/@normal, '/')"/>
		</rico:beginningDate>
        <rico:endDate rdf:datatype="http://www.w3.org/2001/XMLSchema#gYear">
			<xsl:value-of select="substring-after(did/unitdate[@type='inclusive']/@normal, '/')"/>
        </rico:endDate>
        <rico:date>
			<xsl:value-of select="did/unitdate[@type='inclusive']"/>
		</rico:date>
		<rico:hasProvenance>
		<!-- Archiefvormers -->
		<xsl:apply-templates select="did/origination/corpname | did/origination/persname | did/origination/famname"/>
	</rico:hasProvenance>
	<rico:scopeAndContent rdf:parseType="Literal">
		<rdfs:label><xsl:value-of select="did/materialspec/@label"/></rdfs:label>
	</rico:scopeAndContent>
	</rico:RecordResource>	
</xsl:template>

<xsl:template match="revisiondesc/change">
	<rico:history>
		<rico:hasModificationDate rdf:datatype="http://www.w3.org/2001/XMLSchema#date">
			<xsl:value-of select="date/@normal"/>
		</rico:hasModificationDate>
		<!-- this seems a bit odd, for NA finding aids: the literal of the change made is. in the <date> property -->
		<html:p><xsl:value-of select="date"/></html:p>
	</rico:history>
</xsl:template>

<xsl:template match="corpname|persname|famname">
    <rico:Agent>
		<xsl:choose>
			<xsl:when test="name()='persname'"><rdf:type rdf:resource="https://www.ica.org/standards/RiC/ontology#Person"/></xsl:when>
			<xsl:when test="name()='corpname'"><rdf:type rdf:resource="https://www.ica.org/standards/RiC/ontology#CorporateBody"/></xsl:when>
			<xsl:when test="name()='famname'"><rdf:type rdf:resource="https://www.ica.org/standards/RiC/ontology#Family"/></xsl:when>
		</xsl:choose>
		<rico:hasAgentName>
			<rico:AgentName>
				<rdfs:label><xsl:value-of select=".."/></rdfs:label>
			</rico:AgentName>
	   </rico:hasAgentName>
   </rico:Agent>
</xsl:template>


<xsl:template match="dsc">
    <xsl:apply-templates select="c01"/>
</xsl:template>

<xsl:template match="c01">
    <rico:RecordSet>
        <xsl:attribute name="rdf:about">
            <xsl:value-of select="$baseUri"/>
            <xsl:value-of select="did/@id"/>
        </xsl:attribute>
        <rico:includedIn>
            <xsl:attribute name="rdf:resource">
                <xsl:value-of select="$baseUri"/>
                <xsl:value-of select="../../did/@id"/>
            </xsl:attribute>
        </rico:includedIn>  
        <xsl:call-template name="set-recordsettype">
            <xsl:with-param name="type" select="@level"/>
        </xsl:call-template>
        <xsl:apply-templates select="did"/>
    </rico:RecordSet>
    <xsl:apply-templates select="c02"/>
</xsl:template>

<xsl:template match="c02 | c03 | c04 | c05 | c06 | c07 | c08 | c09 | c10 | c11 | c12">
    <rico:RecordSet>
        <xsl:attribute name="rdf:about">
            <xsl:value-of select="$baseUri"/>
            <xsl:value-of select="did/@id"/>
        </xsl:attribute>
        <rico:includedIn>
            <xsl:attribute name="rdf:resource">
                <xsl:value-of select="$baseUri"/>
                <xsl:value-of select="../did/@id"/>
            </xsl:attribute>
        </rico:includedIn>
        <xsl:call-template name="set-recordsettype">
            <xsl:with-param name="type" select="@level"/>
        </xsl:call-template>
        <xsl:apply-templates select="did"/>
    </rico:RecordSet>

    <xsl:apply-templates select="c02"/>
    <xsl:apply-templates select="c03"/>
    <xsl:apply-templates select="c04"/>
    <xsl:apply-templates select="c05"/>
    <xsl:apply-templates select="c06"/>
    <xsl:apply-templates select="c07"/>
    <xsl:apply-templates select="c08"/>
    <xsl:apply-templates select="c09"/>
    <xsl:apply-templates select="c10"/>
    <xsl:apply-templates select="c11"/>
    <xsl:apply-templates select="c12"/>
</xsl:template>

<!-- creating predicates and objects -->
<!-- very preliminary mapping, created in my learning-by-doing way of working! -->
<!-- super minimal: only four basic fields, most important in Dutch Archival Culture -->
<xsl:template match="did">
    <xsl:apply-templates select="unitid"/>
    <xsl:apply-templates select="unittitle"/>
    <xsl:apply-templates select="unitdate"/>
    <xsl:apply-templates select="physdesc"/>
</xsl:template>

<xsl:template match="unitid">
    <rico:identifier>
        <xsl:value-of select="."/>
    </rico:identifier>
</xsl:template>

<xsl:template match="unittitle|titleproper">
    <rico:title>
		<xsl:if test="@type">
			<rdf:type>
				<xsl:text>urn:isbn:1-931666-22-9/type/</xsl:text><xsl:value-of select="@type"/>
			</rdf:type>
		</xsl:if>
		<xsl:if test="@label">
			<rdfs:label><xsl:value-of select="@label"/></rdfs:label>
		</xsl:if>
        <xsl:value-of select="."/>
    </rico:title>
</xsl:template>

<xsl:template match="unitdate">
    <rico:date>
        <xsl:value-of select="."/>
    </rico:date>
</xsl:template>

<xsl:template match="physdesc">
    <rico:recordResourceExtent>
        <xsl:value-of select="."/>
    </rico:recordResourceExtent>
</xsl:template>

<!-- named templates -->
<xsl:template name="set-recordsettype">
    <xsl:param name="type"/>
    <xsl:choose>
        <xsl:when test="$type = 'fonds'">
            <rico:hasRecordSetType>
                <xsl:attribute name="rdf:resource">
                    <xsl:text>https://www.ica.org/standards/RiC/vocabularies/recordSetTypes#Fonds</xsl:text>
                </xsl:attribute>
            </rico:hasRecordSetType>
        </xsl:when>
        <xsl:when test="$type = 'collection'">
            <rico:hasRecordSetType>
                <xsl:attribute name="rdf:resource">
                    <xsl:text>https://www.ica.org/standards/RiC/vocabularies/recordSetTypes#Collection</xsl:text>
                </xsl:attribute>
            </rico:hasRecordSetType>
        </xsl:when>
        <xsl:when test="$type = 'series'">
            <rico:hasRecordSetType>
                <xsl:attribute name="rdf:resource">
                    <xsl:text>https://www.ica.org/standards/RiC/vocabularies/recordSetTypes#Series</xsl:text>
                </xsl:attribute>
            </rico:hasRecordSetType>
        </xsl:when>
        <xsl:when test="$type = 'file'">
            <rico:hasRecordSetType>
                <xsl:attribute name="rdf:resource">
                    <xsl:text>https://www.ica.org/standards/RiC/vocabularies/recordSetTypes#File</xsl:text>
                </xsl:attribute>
            </rico:hasRecordSetType>
        </xsl:when>
    </xsl:choose>
</xsl:template>

</xsl:stylesheet>