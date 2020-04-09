<?xml version="1.0" encoding="UTF-8"?>

<!-- XSLT stylesheet converting City Archives Amsterdam examples -->
<!-- Endocoded Archival Description 2002 (EAD) into Records in Contexts Ontology (RiC-O) 0.1-->
<!-- Ivo Zandhuis (ivo@zandhuis.nl) -->
<!-- 20191218 First -->
<!-- 20200402 Changed use of rico:hasTitle into rico:title and rico:creationDate into rico:date 
notice rico:title and rico:date are not preferred practice! -->

<xsl:stylesheet version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
    xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
    xmlns:rico="https://www.ica.org/standards/RiC/ontology#">
<xsl:output method="xml" encoding="UTF-8" indent="yes"/>
<xsl:strip-space elements="*"/>

<xsl:param name="baseUri">http://gahetna.nl/</xsl:param>

<!-- RDF wrap, looping hierarchy -->
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
	</rico:RecordResource>	
</xsl:template>

<xsl:template match="revisiondesc/change">
	<rico:history>
		<rico:hasModificationDate>
			<xsl:value-of select="date/@normal"/>
		</rico:hasModificationDate>
		<xsl:value-of select="date"/>
	</rico:history>
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
			<xsl:attribute name="rdf:type">
				<xsl:text>urn:isbn:1-931666-22-9/type/</xsl:text><xsl:value-of select="@type"/>
			</xsl:attribute>
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