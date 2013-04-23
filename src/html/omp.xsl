<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
    version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:str="http://exslt.org/strings"
    xmlns:func = "http://exslt.org/functions"
    xmlns:gsa="http://openvas.org"
    xmlns:vuln="http://scap.nist.gov/schema/vulnerability/0.4"
    xmlns:cpe-lang="http://cpe.mitre.org/language/2.0"
    xmlns:scap-core="http://scap.nist.gov/schema/scap-core/0.1"
    xmlns:cve="http://scap.nist.gov/schema/feed/vulnerability/2.0"
    xmlns:cvss="http://scap.nist.gov/schema/cvss-v2/0.2"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns:patch="http://scap.nist.gov/schema/patch/0.1"
    xmlns:meta="http://scap.nist.gov/schema/cpe-dictionary-metadata/0.2"
    xmlns:ns6="http://scap.nist.gov/schema/scap-core/0.1"
    xmlns:config="http://scap.nist.gov/schema/configuration/0.1"
    xmlns:cpe="http://cpe.mitre.org/dictionary/2.0"
    xmlns:oval="http://oval.mitre.org/XMLSchema/oval-common-5"
    xmlns:oval_definitions="http://oval.mitre.org/XMLSchema/oval-definitions-5"
    xmlns:dfncert="http://www.dfn-cert.de/dfncert.dtd"
    xmlns:atom="http://www.w3.org/2005/Atom"
    xsi:schemaLocation="http://scap.nist.gov/schema/configuration/0.1 http://nvd.nist.gov/schema/configuration_0.1.xsd http://scap.nist.gov/schema/scap-core/0.3 http://nvd.nist.gov/schema/scap-core_0.3.xsd http://cpe.mitre.org/dictionary/2.0 http://cpe.mitre.org/files/cpe-dictionary_2.2.xsd http://scap.nist.gov/schema/scap-core/0.1 http://nvd.nist.gov/schema/scap-core_0.1.xsd http://scap.nist.gov/schema/cpe-dictionary-metadata/0.2 http://nvd.nist.gov/schema/cpe-dictionary-metadata_0.2.xsd"
    xmlns:date="http://exslt.org/dates-and-times"
    xmlns:exslt="http://exslt.org/common"
    extension-element-prefixes="str func date exslt">
    <xsl:output
      method="html"
      doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd"
      doctype-public="-//W3C//DTD XHTML 1.0 Transitional//EN"
      encoding="UTF-8"/>

<!--
Greenbone Security Assistant
$Id$
Description: OpenVAS Manager Protocol (OMP) stylesheet

Authors:
Matthew Mundell <matthew.mundell@greenbone.net>
Jan-Oliver Wagner <jan-oliver.wagner@greenbone.net>
Michael Wiegand <michael.wiegand@greenbone.net>
Timo Pollmeier <timo.pollmeier@greenbone.net>

Copyright:
Copyright (C) 2009-2013 Greenbone Networks GmbH

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License version 2,
or, at your option, any later version as published by the Free
Software Foundation

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110-1301 USA.
-->

<!-- XPATH FUNCTIONS -->

<func:function name="gsa:capitalise">
  <xsl:param name="string"/>
  <func:result select="concat (gsa:upper-case (substring ($string, 1, 1)), substring ($string, 2))"/>
</func:function>

<func:function name="gsa:lower-case">
  <xsl:param name="string"/>
  <func:result select="translate($string, 'ABCDEFGHIJKLMNOPQRSTUVWXYZ', 'abcdefghijklmnopqrstuvwxyz')"/>
</func:function>

<func:function name="gsa:upper-case">
  <xsl:param name="string"/>
  <func:result select="translate($string, 'abcdefghijklmnopqrstuvwxyz', 'ABCDEFGHIJKLMNOPQRSTUVWXYZ')"/>
</func:function>

<func:function name="gsa:date-tz">
  <xsl:param name="time"></xsl:param>
  <func:result>
    <!-- 2013-03-26T13:15:00-04:00 -->
    <!-- 2013-03-26T13:15:00Z -->
    <!-- 2013-03-26T13:15:00+04:00 -->
    <xsl:variable name="length" select="string-length ($time)"/>
    <xsl:if test="$length &gt; 0">
      <xsl:choose>
        <xsl:when test="substring ($time, $length) = 'Z'">
          <xsl:value-of select="'UTC'"/>
        </xsl:when>
        <xsl:when test="contains ('+-', substring ($time, $length - 5, 1)) and (substring ($time, $length - 2, 1) = ':')">
          <xsl:value-of select="substring ($time, $length - 5)"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="'ERROR'"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:if>
  </func:result>
</func:function>

<func:function name="gsa:long-time-tz">
  <xsl:param name="time"></xsl:param>
  <func:result>
    <xsl:if test="string-length ($time) &gt; 0">
      <xsl:value-of select="concat (date:day-abbreviation ($time), ' ', date:month-abbreviation ($time), ' ', date:day-in-month ($time), ' ', format-number(date:hour-in-day($time), '00'), ':', format-number(date:minute-in-hour($time), '00'), ':', format-number(date:second-in-minute($time), '00'), ' ', date:year($time), ' ', gsa:date-tz($time))"/>
    </xsl:if>
  </func:result>
</func:function>

<func:function name="gsa:long-time">
  <xsl:param name="time"></xsl:param>
  <func:result>
    <xsl:if test="string-length ($time) &gt; 0">
      <xsl:value-of select="concat (date:day-abbreviation ($time), ' ', date:month-abbreviation ($time), ' ', date:day-in-month ($time), ' ', format-number(date:hour-in-day($time), '00'), ':', format-number(date:minute-in-hour($time), '00'), ':', format-number(date:second-in-minute($time), '00'), ' ', date:year($time))"/>
    </xsl:if>
  </func:result>
</func:function>

<func:function name="gsa:date">
  <xsl:param name="datetime"></xsl:param>
  <func:result>
    <xsl:if test="string-length ($datetime) &gt; 0">
      <xsl:value-of select="concat (date:day-abbreviation ($datetime), ' ', date:month-abbreviation ($datetime), ' ', date:day-in-month ($datetime), ' ', date:year($datetime))"/>
    </xsl:if>
  </func:result>
</func:function>

<func:function name="gsa:type-many">
  <xsl:param name="type"></xsl:param>
  <func:result>
    <xsl:choose>
      <xsl:when test="$type = 'info'">
        <xsl:value-of select="$type"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$type"/><xsl:text>s</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
  </func:result>
</func:function>

<func:function name="gsa:html-attribute-quote">
  <xsl:param name="text"/>
  <func:result>
    <xsl:value-of select="translate ($text, '&quot;', '&amp;quot;')"/>
  </func:result>
</func:function>

<!-- This is only safe for HTML attributes. -->
<func:function name="gsa:param-or">
  <xsl:param name="name"/>
  <xsl:param name="alternative"/>
  <xsl:choose>
    <xsl:when test="/envelope/params/node()[name()=$name]">
      <func:result>
        <xsl:value-of select="gsa:html-attribute-quote (/envelope/params/node()[name()=$name])"/>
      </func:result>
    </xsl:when>
    <xsl:otherwise>
      <func:result>
        <xsl:value-of select="$alternative"/>
      </func:result>
    </xsl:otherwise>
  </xsl:choose>
</func:function>

<func:function name="gsa:get-nvt-tag">
    <xsl:param name="tags"/>
    <xsl:param name="name"/>
  <xsl:variable name="after">
    <xsl:value-of select="substring-after (nvt/tags, concat ($name, '='))"/>
  </xsl:variable>
  <xsl:choose>
      <xsl:when test="contains ($after, '|')">
        <func:result select="substring-before ($after, '|')"/>
      </xsl:when>
      <xsl:otherwise>
        <func:result select="$after"/>
      </xsl:otherwise>
  </xsl:choose>
</func:function>

<func:function name="gsa:newstyle-nvt">
    <xsl:param name="nvt"/>
    <xsl:choose>
      <xsl:when test="string-length(gsa:get-nvt-tag ($nvt/tags, 'summary'))
                    and string-length(gsa:get-nvt-tag ($nvt/tags, 'affected'))
                    and string-length(gsa:get-nvt-tag ($nvt/tags, 'insight'))
                    and string-length(gsa:get-nvt-tag ($nvt/tags, 'vuldetect'))
                    and string-length(gsa:get-nvt-tag ($nvt/tags, 'impact'))
                    and string-length(gsa:get-nvt-tag ($nvt/tags, 'solution'))">
        <func:result select="1"/>
      </xsl:when>
      <xsl:otherwise>
        <func:result select="0"/>
      </xsl:otherwise>
    </xsl:choose>
</func:function>

<func:function name="gsa:cvss-threat">
  <xsl:param name="cvss_score"/>
  <xsl:variable name="threat">
    <xsl:choose>
      <xsl:when test="$cvss_score &lt;= 3.9">Low</xsl:when>
      <xsl:when test="$cvss_score &lt;= 6.9 and $cvss_score &gt; 3.9">Medium</xsl:when>
      <xsl:when test="$cvss_score &gt; 6.9">High</xsl:when>
      <xsl:otherwise>Log</xsl:otherwise>
    </xsl:choose>
  </xsl:variable>
  <func:result select="$threat"/>
</func:function>

<func:function name="gsa:threat-max-cvss">
  <xsl:param name="threat"/>
  <xsl:variable name="cvss">
    <xsl:choose>
      <xsl:when test="gsa:lower-case($threat) = 'low'">3.9</xsl:when>
      <xsl:when test="gsa:lower-case($threat) = 'medium'">6.9</xsl:when>
      <xsl:when test="gsa:lower-case($threat) = 'high'">10.0</xsl:when>
      <xsl:otherwise>0</xsl:otherwise>
    </xsl:choose>
  </xsl:variable>
  <func:result select="$cvss"/>
</func:function>

<func:function name="gsa:threat-color">
  <xsl:param name="threat"/>
  <xsl:variable name="color">
    <xsl:choose>
      <xsl:when test="gsa:lower-case($threat) = 'high'">red</xsl:when>
      <xsl:when test="gsa:lower-case($threat) = 'medium'">orange</xsl:when>
      <xsl:when test="gsa:lower-case($threat) = 'low'">lightskyblue</xsl:when>
      <xsl:otherwise></xsl:otherwise>
    </xsl:choose>
  </xsl:variable>
  <func:result select="$color"/>
</func:function>

<!-- NAMED TEMPLATES -->

<!-- Currently only a very simple formatting method to produce
     nice HTML from a structured text:
     - create paragraphs for each text block separated with a empty line
-->
<xsl:template name="structured-text">
  <xsl:param name="string"/>

  <xsl:for-each select="str:split($string, '&#10;&#10;')">
    <p>
      <xsl:value-of select="."/>
    </p>
  </xsl:for-each>
</xsl:template>

<xsl:template name="prognostic-description">
  <xsl:param name="string"/>

  <xsl:for-each select="str:split($string, '&#10;&#10;')">
    <p>
      <xsl:for-each select="str:split(., '&#10;')">
        <xsl:value-of select="."/>
        <br/>
      </xsl:for-each>
    </p>
  </xsl:for-each>
</xsl:template>

<xsl:template name="filter-window-pager">
  <xsl:param name="type"/>
  <xsl:param name="list"/>
  <xsl:param name="count"/>
  <xsl:param name="filtered_count"/>
  <xsl:param name="full_count"/>
  <xsl:param name="extra_params"/>
  <xsl:choose>
    <xsl:when test="$count &gt; 0">
      <xsl:variable name="last" select="$list/@start + $count - 1"/>
      <xsl:if test = "$list/@start &gt; 1">
        <a href="?cmd=get_{gsa:type-many($type)}{$extra_params}&amp;filter=first={$list/@start - $list/@max} rows={$list/@max} {filters/term}&amp;token={/envelope/token}"><img style="margin-left:10px;margin-right:3px;" src="/img/previous.png" border="0" title="Previous"/></a>
      </xsl:if>
      <xsl:value-of select="$list/@start"/> -
      <xsl:value-of select="$last"/>
      of <div style="display: inline; margin-right: 0px;"><xsl:value-of select="$filtered_count"/></div>
      <xsl:if test="$full_count">
        (total: <xsl:value-of select="$full_count"/>)
      </xsl:if>
      <xsl:if test = "$last &lt; $filtered_count">
        <a href="?cmd=get_{gsa:type-many($type)}{$extra_params}&amp;filter=first={$list/@start + $list/@max} rows={$list/@max} {filters/term}&amp;token={/envelope/token}"><img style="margin-left:3px;margin-right:10px;" src="/img/next.png" border="0" title="Next"/></a>
      </xsl:if>
    </xsl:when>
    <xsl:otherwise>
      <xsl:if test="$full_count">
        (total: <xsl:value-of select="$full_count"/>)
      </xsl:if>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template name="filter-window-part">
  <xsl:param name="type"/>
  <xsl:param name="list"/>
  <xsl:param name="extra_params"/>
  <div class="gb_window_part_content">
    <div style="background-color: #EEEEEE;">
      <div style="float: right">
        <form style="display: inline; margin: 0; vertical-align:middle;" action="" method="post">
          <div style="display: inline; padding: 2px; vertical-align:middle;">
            <input type="hidden" name="token" value="{/envelope/token}"/>
            <input type="hidden" name="cmd" value="create_filter"/>
            <input type="hidden" name="caller" value="{/envelope/caller}"/>
            <input type="hidden" name="comment" value=""/>
            <input type="hidden" name="term" value="{filters/term}"/>
            <input type="hidden" name="optional_resource_type" value="{$type}"/>
            <input type="hidden" name="next" value="get_{gsa:type-many($type)}"/>
            <input type="hidden" name="filter" value="{/envelope/params/filter}"/>
            <xsl:for-each select="exslt:node-set($extra_params)/param">
              <input type="hidden" name="{name}" value="{value}"/>
            </xsl:for-each>
            <input type="text" name="name" value="" size="10"
                   maxlength="80" style="vertical-align:middle"/>
            <input type="image"
                   name="New Filter"
                   src="/img/new.png"
                   alt="New Filter"
                   style="vertical-align:middle;margin-left:3px;margin-right:3px;"/>
          </div>
        </form>
        <form style="display: inline; margin: 0; vertical-align:middle" action="" method="get">
          <div style="display: inline; padding: 2px; vertical-align:middle;">
            <input type="hidden" name="token" value="{/envelope/token}"/>
            <input type="hidden" name="cmd" value="get_{gsa:type-many($type)}"/>
            <xsl:for-each select="exslt:node-set($extra_params)/param">
              <input type="hidden" name="{name}" value="{value}"/>
            </xsl:for-each>
            <select style="margin-bottom: 0px; max-width: 100px;" name="filt_id">
              <option value="--">--</option>
              <xsl:variable name="id" select="filters/@id"/>
              <xsl:for-each select="../filters/get_filters_response/filter">
                <xsl:choose>
                  <xsl:when test="@id = $id">
                    <option value="{@id}" selected="1"><xsl:value-of select="name"/></option>
                  </xsl:when>
                  <xsl:otherwise>
                    <option value="{@id}"><xsl:value-of select="name"/></option>
                  </xsl:otherwise>
                </xsl:choose>
              </xsl:for-each>
            </select>
            <input type="image"
                   name="Switch Filter"
                   src="/img/refresh.png"
                   alt="Switch" style="vertical-align:middle;margin-left:3px;margin-right:3px;"/>
            <a href="/omp?cmd=get_filters&amp;token={/envelope/token}"
               title="Filters">
              <img style="vertical-align:middle;margin-left:3px;margin-right:3px;"
                   src="/img/list.png" border="0" alt="Filters"/>
            </a>
          </div>
        </form>
      </div>
      <form action="" method="get">
        <input type="hidden" name="token" value="{/envelope/token}"/>
        <input type="hidden" name="cmd" value="get_{gsa:type-many($type)}"/>
        <xsl:for-each select="exslt:node-set($extra_params)/param">
          <input type="hidden" name="{name}" value="{value}"/>
        </xsl:for-each>
        <div style="padding: 2px;">
          Filter:
          <input type="text" name="filter" size="57"
                 value="{concat (filters/term, ' ')}"
                 maxlength="1000"/>
          <input type="image"
                 name="Update Filter"
                 src="/img/refresh.png"
                 alt="Update" style="vertical-align:middle;margin-left:3px;margin-right:3px;"/>
          <a href="/help/powerfilter.html?token={/envelope/token}" title="Help: Powerfilter">
            <img style="vertical-align:middle;margin-left:3px;margin-right:3px;"
                 src="/img/help.png" border="0"/>
          </a>
        </div>
      </form>
    </div>
  </div>
</xsl:template>

<xsl:template name="auto-refresh">
  <select style="margin-bottom: 0px;" name="refresh_interval" size="1">
    <xsl:choose>
      <xsl:when test="/envelope/autorefresh/@interval='0'">
        <option value="0" selected="1">&#8730;No auto-refresh</option>
      </xsl:when>
      <xsl:otherwise>
        <option value="0">No auto-refresh</option>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:choose>
      <xsl:when test="/envelope/autorefresh/@interval='10'">
        <option value="10" selected="1">&#8730;Refresh every 10 Sec.</option>
      </xsl:when>
      <xsl:otherwise>
        <option value="10">Refresh every 10 Sec.</option>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:choose>
      <xsl:when test="/envelope/autorefresh/@interval='30'">
        <option value="30" selected="1">&#8730;Refresh every 30 Sec.</option>
      </xsl:when>
      <xsl:otherwise>
        <option value="30">Refresh every 30 Sec.</option>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:choose>
      <xsl:when test="/envelope/autorefresh/@interval='60'">
        <option value="60" selected="1">&#8730;Refresh every 60 Sec.</option>
      </xsl:when>
      <xsl:otherwise>
        <option value="60">Refresh every 60 Sec.</option>
      </xsl:otherwise>
    </xsl:choose>
  </select>
</xsl:template>

<xsl:template name="edit-header-icons">
  <xsl:param name="type"/>
  <xsl:param name="cap-type"/>
  <xsl:param name="id"/>

  <a href="/help/{$type}s.html?token={/envelope/token}#edit{$type}" title="Help: Edit {$cap-type}">
    <img src="/img/help.png"/>
  </a>
  <a href="/omp?cmd=get_{$type}s&amp;filter={str:encode-uri (/envelope/params/filter, true ())}&amp;filt_id={/envelope/params/filt_id}&amp;token={/envelope/token}"
     title="{$cap-type}s" style="margin-left:3px;">
    <img src="/img/list.png" border="0" alt="{$cap-type}s"/>
  </a>
  <div id="small_inline_form" style="display: inline; margin-left: 15px; font-weight: normal;">
      <a href="/omp?cmd=get_{$type}&amp;{$type}_id={$id}&amp;filter={str:encode-uri (/envelope/params/filter, true ())}&amp;filt_id={/envelope/params/filt_id}&amp;token={/envelope/token}"
         title="{$cap-type} Details" style="margin-left:3px;">
      <img src="/img/details.png" border="0" alt="Details"/>
    </a>
  </div>
</xsl:template>

<xsl:template name="get-settings-filter">
  <xsl:param name="filter"/>

  <xsl:choose>
    <xsl:when test="$filter">
      <a href="/omp?cmd=get_filter&amp;filter_id={$filter}&amp;token={/envelope/token}"
         title="Filter Details">
        <xsl:value-of select="get_filters_response/filter[@id=$filter]/name"/>
      </a>
    </xsl:when>
    <xsl:otherwise>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template name="edit-settings-filters">
  <xsl:param name="uuid"/>
  <xsl:param name="filter-type"/>
  <xsl:param name="filter"/>
  <select style="margin-bottom: 0px;" name="settings_filter:{$uuid}">
    <option value="">--</option>
    <xsl:variable name="id" select="filters/@id"/>
    <xsl:for-each select="get_filters_response/filter[type=$filter-type]">
      <xsl:choose>
        <xsl:when test="@id = $filter">
          <option value="{@id}" selected="1"><xsl:value-of select="name"/></option>
        </xsl:when>
        <xsl:otherwise>
          <option value="{@id}"><xsl:value-of select="name"/></option>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:for-each>
  </select>
</xsl:template>

<xsl:template name="list-window-line-icons">
  <xsl:param name="type"/>
  <xsl:param name="cap-type"/>

  <xsl:param name="id"/>
  <xsl:param name="noedit"/>
  <xsl:param name="noclone"/>
  <xsl:param name="noexport"/>
  <xsl:param name="notrash"/>
  <xsl:param name="params" select="''"/>
  <xsl:param name="next" select="concat ('get_', $type, 's')"/>
  <xsl:param name="extra-params-details"/>

  <xsl:choose>
    <xsl:when test="$notrash">
    </xsl:when>
    <xsl:when test="writable='0' or in_use!='0'">
      <img src="/img/trashcan_inactive.png"
           border="0"
           alt="To Trashcan"
           style="margin-left:3px;"/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:call-template name="trashcan-icon">
        <xsl:with-param name="type" select="$type"/>
        <xsl:with-param name="id" select="@id"/>
        <xsl:with-param name="params">
          <input type="hidden" name="filter" value="{/envelope/params/filter}"/>
          <input type="hidden" name="filt_id" value="{/envelope/params/filt_id}"/>
        </xsl:with-param>
      </xsl:call-template>
    </xsl:otherwise>
  </xsl:choose>
  <a href="/omp?cmd=get_{$type}&amp;{$type}_id={@id}&amp;filter={str:encode-uri (/envelope/params/filter, true ())}&amp;filt_id={/envelope/params/filt_id}{$extra-params-details}&amp;token={/envelope/token}"
     title="{$cap-type} Details" style="margin-left:3px;">
    <img src="/img/details.png" border="0" alt="Details"/>
  </a>
  <xsl:choose>
    <xsl:when test="$noedit">
    </xsl:when>
    <xsl:otherwise>
      <xsl:choose>
        <xsl:when test="writable='0'">
          <img src="/img/edit_inactive.png" border="0" alt="Edit"
               style="margin-left:3px;"/>
        </xsl:when>
        <xsl:otherwise>
          <a href="/omp?cmd=edit_{$type}&amp;{$type}_id={@id}&amp;next={$next}{$params}&amp;filter={str:encode-uri (/envelope/params/filter, true ())}&amp;filt_id={/envelope/params/filt_id}&amp;token={/envelope/token}"
             title="Edit {$cap-type}"
             style="margin-left:3px;">
            <img src="/img/edit.png" border="0" alt="Edit"/>
          </a>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:otherwise>
  </xsl:choose>
  <xsl:choose>
    <xsl:when test="$noclone">
    </xsl:when>
    <xsl:otherwise>
      <div style="display: inline">
        <form style="display: inline; font-size: 0px; margin-left: 3px" action="/omp" method="post" enctype="multipart/form-data">
          <input type="hidden" name="token" value="{/envelope/token}"/>
          <input type="hidden" name="caller" value="{/envelope/caller}"/>
          <input type="hidden" name="cmd" value="clone"/>
          <input type="hidden" name="resource_type" value="{$type}"/>
          <input type="hidden" name="next" value="{$next}"/>
          <input type="hidden" name="id" value="{@id}"/>
          <input type="hidden" name="filter" value="{/envelope/params/filter}"/>
          <input type="hidden" name="filt_id" value="{/envelope/params/filt_id}"/>
          <input type="image" src="/img/clone.png" alt="Clone {$cap-type}"
                 name="Clone" value="Clone" title="Clone"/>
        </form>
      </div>
    </xsl:otherwise>
  </xsl:choose>
  <xsl:choose>
    <xsl:when test="$noexport">
    </xsl:when>
    <xsl:otherwise>
      <a href="/omp?cmd=export_{$type}&amp;{$type}_id={@id}&amp;next={$next}{$params}&amp;filter={str:encode-uri (/envelope/params/filter, true ())}&amp;filt_id={/envelope/params/filt_id}&amp;token={/envelope/token}"
         title="Export {$cap-type}"
         style="margin-left:3px;">
        <img src="/img/download.png" border="0" alt="Export"/>
      </a>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template name="trash-delete-icon">
  <xsl:param name="type"></xsl:param>
  <xsl:param name="id"></xsl:param>
  <xsl:param name="params"></xsl:param>

  <div style="display: inline">
    <form style="display: inline; font-size: 0px; margin-left: 3px" action="/omp" method="post" enctype="multipart/form-data">
      <input type="hidden" name="token" value="{/envelope/token}"/>
      <input type="hidden" name="caller" value="{/envelope/caller}"/>
      <input type="hidden" name="cmd" value="delete_trash_{$type}"/>
      <input type="hidden" name="{$type}_id" value="{$id}"/>
      <input type="image" src="/img/delete.png" alt="Delete"
             name="Delete" value="Delete" title="Delete"/>
      <xsl:copy-of select="$params"/>
    </form>
  </div>
</xsl:template>

<xsl:template name="delete-icon">
  <xsl:param name="type"></xsl:param>
  <xsl:param name="id"></xsl:param>
  <xsl:param name="params"></xsl:param>

  <div style="display: inline">
    <form style="display: inline; font-size: 0px; margin-left: 3px" action="/omp" method="post" enctype="multipart/form-data">
      <input type="hidden" name="token" value="{/envelope/token}"/>
      <input type="hidden" name="caller" value="{/envelope/caller}"/>
      <input type="hidden" name="cmd" value="delete_{$type}"/>
      <input type="hidden" name="{$type}_id" value="{$id}"/>
      <input type="image" src="/img/delete.png" alt="Delete"
             name="Delete" value="Delete" title="Delete"/>
      <xsl:copy-of select="$params"/>
    </form>
  </div>
</xsl:template>

<xsl:template name="pause-icon">
  <xsl:param name="type"></xsl:param>
  <xsl:param name="id"></xsl:param>
  <xsl:param name="params"></xsl:param>

  <div style="display: inline">
    <form style="display: inline; font-size: 0px; margin-left: 3px"
          action="/omp" method="post" enctype="multipart/form-data">
      <input type="hidden" name="token" value="{/envelope/token}"/>
      <input type="hidden" name="caller" value="{/envelope/caller}"/>
      <input type="hidden" name="cmd" value="pause_{$type}"/>
      <input type="hidden" name="{$type}_id" value="{$id}"/>
      <input type="image" src="/img/pause.png" alt="Pause"
             name="Pause" value="Pause" title="Pause"/>
      <xsl:copy-of select="$params"/>
    </form>
  </div>
</xsl:template>

<xsl:template name="restore-icon">
  <xsl:param name="id"></xsl:param>

  <div style="display: inline">
    <form style="display: inline; font-size: 0px; margin-left: 3px" action="/omp"
          method="post" enctype="multipart/form-data">
      <input type="hidden" name="token" value="{/envelope/token}"/>
      <input type="hidden" name="caller" value="{/envelope/caller}"/>
      <input type="hidden" name="cmd" value="restore"/>
      <input type="hidden" name="target_id" value="{$id}"/>
      <input type="image" src="/img/restore.png" alt="Restore"
             name="Restore" value="Restore" title="Restore"/>
    </form>
  </div>
</xsl:template>

<xsl:template name="resume-icon">
  <xsl:param name="type"></xsl:param>
  <xsl:param name="id"></xsl:param>
  <xsl:param name="params"></xsl:param>
  <xsl:param name="cmd">resume_<xsl:value-of select="type"/></xsl:param>

  <div style="display: inline">
    <form style="display: inline; font-size: 0px; margin-left: 3px"
          action="/omp" method="post" enctype="multipart/form-data">
      <input type="hidden" name="token" value="{/envelope/token}"/>
      <input type="hidden" name="caller" value="{/envelope/caller}"/>
      <input type="hidden" name="cmd" value="{$cmd}"/>
      <input type="hidden" name="{$type}_id" value="{$id}"/>
      <input type="image" src="/img/resume.png" alt="Resume"
             name="Resume" value="Resume" title="Resume"/>
      <xsl:copy-of select="$params"/>
    </form>
  </div>
</xsl:template>

<xsl:template name="start-icon">
  <xsl:param name="type"></xsl:param>
  <xsl:param name="id"></xsl:param>
  <xsl:param name="params"></xsl:param>
  <xsl:param name="cmd">start_<xsl:value-of select="$type"/></xsl:param>
  <xsl:param name="alt">Start</xsl:param>

  <div style="display: inline">
    <form style="display: inline; font-size: 0px; margin-left: 3px"
          action="/omp" method="post" enctype="multipart/form-data">
      <input type="hidden" name="token" value="{/envelope/token}"/>
      <input type="hidden" name="caller" value="{/envelope/caller}"/>
      <input type="hidden" name="cmd" value="{$cmd}"/>
      <input type="hidden" name="{$type}_id" value="{$id}"/>
      <input type="hidden" name="filter" value="{/envelope/params/filter}"/>
      <input type="hidden" name="filt_id" value="{/envelope/params/filt_id}"/>
      <input type="image" src="/img/start.png" alt="{$alt}"
             name="{$alt}" value="{$alt}" title="{$alt}"/>
      <xsl:copy-of select="$params"/>
    </form>
  </div>
</xsl:template>

<xsl:template name="stop-icon">
  <xsl:param name="type"></xsl:param>
  <xsl:param name="id"></xsl:param>
  <xsl:param name="params"></xsl:param>

  <div style="display: inline">
    <form style="display: inline; font-size: 0px; margin-left: 3px"
          action="/omp" method="post" enctype="multipart/form-data">
      <input type="hidden" name="token" value="{/envelope/token}"/>
      <input type="hidden" name="caller" value="{/envelope/caller}"/>
      <input type="hidden" name="cmd" value="stop_{$type}"/>
      <input type="hidden" name="{$type}_id" value="{$id}"/>
      <input type="image" src="/img/stop.png" alt="Stop"
             name="Stop" value="Stop" title="Stop"/>
      <xsl:copy-of select="$params"/>
    </form>
  </div>
</xsl:template>

<xsl:template name="trashcan-icon">
  <xsl:param name="type"></xsl:param>
  <xsl:param name="id"></xsl:param>
  <xsl:param name="fragment"></xsl:param>
  <xsl:param name="params"></xsl:param>

  <div style="display: inline">
    <form style="display: inline; font-size: 0px; margin-left: 3px" action="/omp{$fragment}" method="post" enctype="multipart/form-data">
      <input type="hidden" name="token" value="{/envelope/token}"/>
      <input type="hidden" name="caller" value="{/envelope/caller}"/>
      <input type="hidden" name="cmd" value="delete_{$type}"/>
      <input type="hidden" name="{$type}_id" value="{$id}"/>
      <input type="image" src="/img/trashcan.png" alt="To Trashcan"
             name="To Trashcan" value="To Trashcan" title="Move To Trashcan"/>
      <xsl:copy-of select="$params"/>
    </form>
  </div>
</xsl:template>

<!-- This is called within a PRE. -->
<xsl:template name="wrap">
  <xsl:param name="string"></xsl:param>
  <xsl:param name="width">90</xsl:param>
  <xsl:param name="marker">&#8629;&#10;</xsl:param>

  <xsl:for-each select="str:split($string, '&#10;&#10;')">
    <xsl:for-each select="str:tokenize(text(), '&#10;')">
      <xsl:call-template name="wrap-line">
        <xsl:with-param name="string"><xsl:value-of select="."/></xsl:with-param>
        <xsl:with-param name="width" select="$width"/>
        <xsl:with-param name="marker" select="$marker"/>
      </xsl:call-template>
      <xsl:text>
</xsl:text>
    </xsl:for-each>
    <xsl:choose>
      <xsl:when test="position() = last()">
      </xsl:when>
      <xsl:otherwise>
        <xsl:text>
</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:for-each>
</xsl:template>

<!-- This is called within a PRE. -->
<xsl:template name="wrap-line">
  <xsl:param name="string"></xsl:param>
  <xsl:param name="width">90</xsl:param>
  <xsl:param name="marker">&#8629;</xsl:param>

  <xsl:variable name="to-next-newline">
    <xsl:value-of select="substring-before($string, '&#10;')"/>
  </xsl:variable>

  <xsl:choose>
    <xsl:when test="string-length($string) = 0">
      <!-- The string is empty. -->
    </xsl:when>
    <xsl:when test="(string-length($to-next-newline) = 0) and (substring($string, 1, 1) != '&#10;')">
      <!-- A single line missing a newline, output up to the edge. -->
      <xsl:value-of select="substring($string, 1, number($width))"/>
      <xsl:if test="string-length($string) &gt; number($width)"><xsl:value-of select="$marker" disable-output-escaping="yes"/>
        <xsl:call-template name="wrap-line">
          <xsl:with-param name="string"><xsl:value-of select="substring($string, number($width) + 1, string-length($string))"/></xsl:with-param>
          <xsl:with-param name="width" select="$width"/>
          <xsl:with-param name="marker" select="$marker"/>
        </xsl:call-template>
      </xsl:if>
    </xsl:when>
    <xsl:when test="(string-length($to-next-newline) + 1 &lt; string-length($string)) and (string-length($to-next-newline) &lt; number($width))">
      <!-- There's a newline before the edge, so output the line. -->
      <xsl:value-of select="substring($string, 1, string-length($to-next-newline) + 1)"/>
      <xsl:call-template name="wrap-line">
        <xsl:with-param name="string"><xsl:value-of select="substring($string, string-length($to-next-newline) + 2, string-length($string))"/></xsl:with-param>
        <xsl:with-param name="width" select="$width"/>
        <xsl:with-param name="marker" select="$marker"/>
      </xsl:call-template>
    </xsl:when>
    <xsl:otherwise>
      <!-- Any newline comes after the edge, so output up to the edge. -->
      <xsl:value-of select="substring($string, 1, number($width))"/>
      <xsl:if test="string-length($string) &gt; numer($width)"><xsl:value-of select="$marker" disable-output-escaping="yes"/>
        <xsl:call-template name="wrap-line">
          <xsl:with-param name="string"><xsl:value-of select="substring($string, number($width) + 1, string-length($string))"/></xsl:with-param>
          <xsl:with-param name="width" select="$width"/>
          <xsl:with-param name="marker" select="$marker"/>
        </xsl:call-template>
      </xsl:if>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template name="highlight-diff">
  <xsl:param name="string"></xsl:param>

  <xsl:for-each select="str:tokenize($string, '&#10;')">
      <xsl:call-template name="highlight-diff-line">
        <xsl:with-param name="string"><xsl:value-of select="."/></xsl:with-param>
      </xsl:call-template>
  </xsl:for-each>
</xsl:template>

<!-- This is called within a PRE. -->
<xsl:template name="highlight-diff-line">
  <xsl:param name="string"></xsl:param>

  <xsl:variable name="to-next-newline">
    <xsl:value-of select="substring-before($string, '&#10;')"/>
  </xsl:variable>

  <xsl:choose>
    <xsl:when test="string-length($string) = 0">
      <!-- The string is empty. -->
    </xsl:when>
    <xsl:when test="(string-length($to-next-newline) = 0) and (substring($string, 1, 1) != '&#10;')">
      <!-- A single line missing a newline, output up to the edge. -->
      <xsl:choose>
        <xsl:when test="(substring($string, 1, 1) = '@')">
<div class="diff-line-hunk">
<xsl:value-of select="substring($string, 1, 90)"/>
</div>
        </xsl:when>
        <xsl:when test="(substring($string, 1, 1) = '+')">
<div class="diff-line-plus">
<xsl:value-of select="substring($string, 1, 90)"/>
</div>
        </xsl:when>
        <xsl:when test="(substring($string, 1, 1) = '-')">
<div class="diff-line-minus">
<xsl:value-of select="substring($string, 1, 90)"/>
</div>
        </xsl:when>
        <xsl:otherwise>
<div class="diff-line">
<xsl:value-of select="substring($string, 1, 90)"/>
</div>
        </xsl:otherwise>
      </xsl:choose>
      <xsl:if test="string-length($string) &gt; 90">&#8629;
<xsl:call-template name="highlight-diff-line">
  <xsl:with-param name="string"><xsl:value-of select="substring($string, 91, string-length($string))"/></xsl:with-param>
</xsl:call-template>
      </xsl:if>
    </xsl:when>
    <xsl:when test="(string-length($to-next-newline) + 1 &lt; string-length($string)) and (string-length($to-next-newline) &lt; 90)">
      <!-- There's a newline before the edge, so output the line. -->
      <xsl:choose>
        <xsl:when test="(substring($string, 1, 1) = '@')">
<div class="diff-line-hunk">
<xsl:value-of select="substring($string, 1, string-length($to-next-newline) + 1)"/>
</div>
        </xsl:when>
        <xsl:when test="(substring($string, 1, 1) = '+')">
<div class="diff-line-plus">
<xsl:value-of select="substring($string, 1, 90)"/>
</div>
        </xsl:when>
        <xsl:when test="(substring($string, 1, 1) = '-')">
<div class="diff-line-minus">
<xsl:value-of select="substring($string, 1, 90)"/>
</div>
        </xsl:when>
        <xsl:otherwise>
<div class="diff-line">
<xsl:value-of select="substring($string, 1, string-length($to-next-newline) + 1)"/>
</div>
        </xsl:otherwise>
      </xsl:choose>
<xsl:call-template name="highlight-diff-line">
  <xsl:with-param name="string"><xsl:value-of select="substring($string, string-length($to-next-newline) + 2, string-length($string))"/></xsl:with-param>
</xsl:call-template>
    </xsl:when>
    <xsl:otherwise>
      <!-- Any newline comes after the edge, so output up to the edge. -->
      <xsl:choose>
        <xsl:when test="(substring($string, 1, 1) = '@')">
<div class="diff-line-hunk">
<xsl:value-of select="substring($string, 1, 90)"/>
</div>
        </xsl:when>
        <xsl:when test="(substring($string, 1, 1) = '+')">
<div class="diff-line-plus">
<xsl:value-of select="substring($string, 1, 90)"/>
</div>
        </xsl:when>
        <xsl:when test="(substring($string, 1, 1) = '-')">
<div class="diff-line-minus">
<xsl:value-of select="substring($string, 1, 90)"/>
</div>
        </xsl:when>
        <xsl:otherwise>
<div class="diff-line">
<xsl:value-of select="substring($string, 1, 90)"/>
</div>
        </xsl:otherwise>
      </xsl:choose>
      <xsl:if test="string-length($string) &gt; 90">&#8629;
<xsl:call-template name="hightlight-diff-line">
  <xsl:with-param name="string"><xsl:value-of select="substring($string, 91, string-length($string))"/></xsl:with-param>
</xsl:call-template>
      </xsl:if>
    </xsl:otherwise>
  </xsl:choose>

</xsl:template>

<xsl:template match="sort">
</xsl:template>

<xsl:template match="apply_overrides">
</xsl:template>

<xsl:template name="html-tasks-table">
  <xsl:call-template name="list-window">
    <xsl:with-param name="type" select="'task'"/>
    <xsl:with-param name="cap-type" select="'Task'"/>
    <xsl:with-param name="resources-summary" select="tasks"/>
    <xsl:with-param name="resources" select="task"/>
    <xsl:with-param name="count" select="count (task)"/>
    <xsl:with-param name="filtered-count" select="task_count/filtered"/>
    <xsl:with-param name="full-count" select="task_count/text ()"/>
    <xsl:with-param name="headings" select="'Name|name Status|status Total|total Reports~First|first~Last|last~Threat|threat Trend|trend'"/>
  </xsl:call-template>
</xsl:template>

<xsl:template name="severity-bar">
  <xsl:param name="extra_text"></xsl:param>
  <xsl:param name="notext"></xsl:param>
  <xsl:param name="cvss"></xsl:param>
  <xsl:param name="threat"><xsl:value-of select="gsa:cvss-threat($cvss)"/></xsl:param>
  <xsl:param name="title"><xsl:value-of select="$threat"/></xsl:param>
  <xsl:param name="scale">10</xsl:param>

  <xsl:variable name="fill">
    <xsl:value-of select="number($cvss) * $scale"/>
  </xsl:variable>
  <xsl:variable name="width"><xsl:value-of select="10 * $scale"/></xsl:variable>
  <div class="progressbar_box" title="{$title}" style="width:{$width}px;">
    <xsl:choose>
      <xsl:when test="$threat = 'Low'">
        <div class="progressbar_bar_done" style="width:{$fill}px;"></div>
      </xsl:when>
      <xsl:when test="$threat = 'Medium'">
        <div class="progressbar_bar_request" style="width:{$fill}px;"></div>
      </xsl:when>
      <xsl:when test="$threat = 'High'">
        <div class="progressbar_bar_error" style="width:{$fill}px;"></div>
      </xsl:when>
      <xsl:when test="$threat = 'Log'">
        <div class="progressbar_bar_done" style="width:0px;"></div>
      </xsl:when>
    </xsl:choose>
      <div class="progressbar_text">
        <xsl:if test="not($notext)">
          <xsl:value-of select="$cvss"/>
        </xsl:if>
        <xsl:if test="$extra_text">
          <xsl:value-of select="$extra_text"/>
        </xsl:if>
      </div>
  </div>
</xsl:template>
<func:function name="gsa:build-levels">
  <xsl:param name="filters"></xsl:param>
  <func:result>
    <xsl:for-each select="$filters/filter">
      <xsl:choose>
        <xsl:when test="text()='High'">h</xsl:when>
        <xsl:when test="text()='Medium'">m</xsl:when>
        <xsl:when test="text()='Low'">l</xsl:when>
        <xsl:when test="text()='Log'">g</xsl:when>
        <xsl:when test="text()='False Positive'">f</xsl:when>
      </xsl:choose>
    </xsl:for-each>
  </func:result>
</func:function>

<func:function name="gsa:join">
  <xsl:param name="nodes"/>
  <func:result>
    <xsl:for-each select="$nodes">
      <xsl:value-of select="name"/>
      <xsl:text> </xsl:text>
    </xsl:for-each>
  </func:result>
</func:function>

<xsl:template name="build-levels">
  <xsl:param name="filters"></xsl:param>
  <xsl:for-each select="$filters">
    <xsl:choose>
      <xsl:when test="text()='High'">h</xsl:when>
      <xsl:when test="text()='Medium'">m</xsl:when>
      <xsl:when test="text()='Low'">l</xsl:when>
      <xsl:when test="text()='Log'">g</xsl:when>
      <xsl:when test="text()='False Positive'">f</xsl:when>
    </xsl:choose>
  </xsl:for-each>
</xsl:template>

<xsl:template match="all">
</xsl:template>

<xsl:template match="get_reports_alert_response">
  <xsl:call-template name="command_result_dialog">
    <xsl:with-param name="operation">Run Alert</xsl:with-param>
    <xsl:with-param name="status">
      <xsl:value-of select="@status"/>
    </xsl:with-param>
    <xsl:with-param name="msg">
      <xsl:value-of select="@status_text"/>
    </xsl:with-param>
  </xsl:call-template>
</xsl:template>

<xsl:template name="assets">
  <xsl:variable name="levels"
                select="report/filters/text()"/>
  <xsl:variable name="apply-overrides"
                select="report/filters/apply_overrides"/>
  <xsl:if test="report/@scap_loaded = 0">
    <xsl:call-template name="error_window">
      <xsl:with-param name="heading">Warning: SCAP Database Missing</xsl:with-param>
      <xsl:with-param name="message">
        SCAP database missing on OMP server.  Prognostic reporting disabled.
        <a href="/help/hosts.html?token={/envelope/token}#scap_missing"
           title="Help: SCAP database missing">
          <img style="margin-left:5px" src="/img/help.png"/>
        </a>
      </xsl:with-param>
    </xsl:call-template>
    <br/>
  </xsl:if>
  <div class="gb_window">
    <div class="gb_window_part_left"></div>
    <div class="gb_window_part_right"></div>
    <div class="gb_window_part_center">
      Host Filtering
      <a href="/help/hosts.html?token={/envelope/token}" title="Help: Hosts">
        <img src="/img/help.png" border="0"/>
      </a>
      <div id="small_inline_form" style="display: inline; margin-left: 40px; font-weight: normal;">
        <form action="" method="get">
          <input type="hidden" name="token" value="{/envelope/token}"/>
          <input type="hidden" name="cmd" value="get_report"/>
          <input type="hidden" name="type" value="assets"/>
          <input type="hidden" name="levels" value="{$levels}"/>
          <input type="hidden" name="search_phrase" value="{report/filters/phrase}"/>
          <!-- Switch back to the first page if the override state changes, because
               this could lead to changes in the number of hosts in the table. -->
          <input type="hidden" name="first_result" value="1"/>
          <input type="hidden" name="max_results" value="{report/hosts/@max}"/>
          <select style="margin-bottom: 0px;" name="overrides" size="1">
            <xsl:choose>
              <xsl:when test="$apply-overrides = 0">
                <option value="0" selected="1">&#8730;No overrides</option>
                <option value="1" >Apply overrides</option>
              </xsl:when>
              <xsl:otherwise>
                <option value="0">No overrides</option>
                <option value="1" selected="1">&#8730;Apply overrides</option>
              </xsl:otherwise>
            </xsl:choose>
          </select>
          <input type="image"
                 name="Update"
                 src="/img/refresh.png"
                 alt="Update" style="margin-left:3px;margin-right:3px;"/>
        </form>
      </div>
    </div>
    <div class="gb_window_part_content">
      <div style="background-color: #EEEEEE;">
        <xsl:variable name="sort_field">
          <xsl:value-of select="report/sort/field/text()"/>
        </xsl:variable>
        <xsl:variable name="sort_order">
          <xsl:value-of select="report/sort/field/order"/>
        </xsl:variable>
        <form action="" method="get">
          <input type="hidden" name="token" value="{/envelope/token}"/>
          <input type="hidden" name="cmd" value="get_report"/>
          <input type="hidden" name="type" value="assets"/>
          <input type="hidden" name="sort_field" value="{$sort_field}"/>
          <input type="hidden" name="sort_order" value="{$sort_order}"/>
          <input type="hidden"
                 name="overrides"
                 value="{report/filters/apply_overrides}"/>
          <div style="padding: 2px;">
            Results per page:
            <input type="text" name="max_results" size="5"
                   value="{report/hosts/@max}"
                   maxlength="400"/>
          </div>
<!--
          <div style="padding: 2px;">
            <label>
              <xsl:choose>
                <xsl:when test="report/filters/result_hosts_only = 0">
                  <input type="checkbox" name="result_hosts_only" value="1"/>
                </xsl:when>
                <xsl:otherwise>
                  <input type="checkbox" name="result_hosts_only" value="1" checked="1"/>
                </xsl:otherwise>
              </xsl:choose>
              Only show hosts that have results
            </label>
          </div>
          <div style="padding: 2px;">
            <label>
              <xsl:choose>
                <xsl:when test="report/filters/min_cvss_base = ''">
                  <input type="checkbox" name="apply_min_cvss_base" value="1"/>
                </xsl:when>
                <xsl:otherwise>
                  <input type="checkbox" name="apply_min_cvss_base" value="1"
                         checked="1"/>
                </xsl:otherwise>
              </xsl:choose>
              CVSS &gt;=
            </label>
            <select name="min_cvss_base">
              <xsl:call-template name="opt">
                <xsl:with-param name="value" select="'10.0'"/>
                <xsl:with-param name="select-value" select="report/filters/min_cvss_base"/>
              </xsl:call-template>
              <xsl:call-template name="opt">
                <xsl:with-param name="value" select="'9.0'"/>
                <xsl:with-param name="select-value" select="report/filters/min_cvss_base"/>
              </xsl:call-template>
              <xsl:choose>
                <xsl:when test="report/filters/min_cvss_base = ''">
                  <xsl:call-template name="opt">
                    <xsl:with-param name="value" select="'8.0'"/>
                    <xsl:with-param name="select-value" select="'8.0'"/>
                  </xsl:call-template>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:call-template name="opt">
                    <xsl:with-param name="value" select="'8.0'"/>
                    <xsl:with-param name="select-value" select="report/filters/min_cvss_base"/>
                  </xsl:call-template>
                </xsl:otherwise>
              </xsl:choose>
              <xsl:call-template name="opt">
                <xsl:with-param name="value" select="'7.0'"/>
                <xsl:with-param name="select-value" select="report/filters/min_cvss_base"/>
              </xsl:call-template>
              <xsl:call-template name="opt">
                <xsl:with-param name="value" select="'6.0'"/>
                <xsl:with-param name="select-value" select="report/filters/min_cvss_base"/>
              </xsl:call-template>
              <xsl:call-template name="opt">
                <xsl:with-param name="value" select="'5.0'"/>
                <xsl:with-param name="select-value" select="report/filters/min_cvss_base"/>
              </xsl:call-template>
              <xsl:call-template name="opt">
                <xsl:with-param name="value" select="'4.0'"/>
                <xsl:with-param name="select-value" select="report/filters/min_cvss_base"/>
              </xsl:call-template>
              <xsl:call-template name="opt">
                <xsl:with-param name="value" select="'3.0'"/>
                <xsl:with-param name="select-value" select="report/filters/min_cvss_base"/>
              </xsl:call-template>
              <xsl:call-template name="opt">
                <xsl:with-param name="value" select="'2.0'"/>
                <xsl:with-param name="select-value" select="report/filters/min_cvss_base"/>
              </xsl:call-template>
              <xsl:call-template name="opt">
                <xsl:with-param name="value" select="'1.0'"/>
                <xsl:with-param name="select-value" select="report/filters/min_cvss_base"/>
              </xsl:call-template>
              <xsl:call-template name="opt">
                <xsl:with-param name="value" select="'0.0'"/>
                <xsl:with-param name="select-value" select="report/filters/min_cvss_base"/>
              </xsl:call-template>
            </select>
          </div>
-->
          <div style="padding: 2px;">
            Text phrase:
            <input type="text" name="search_phrase" size="50"
                   value="{report/filters/phrase}"
                   maxlength="400"/>
          </div>
          <div style="float: right">
            <input type="submit" value="Apply" title="Apply"/>
          </div>
          <div style="padding: 2px;">
            Threat:
            <table style="display: inline">
              <tr>
                <td class="threat_info_table_h">
                  <label>
                    <xsl:choose>
                      <xsl:when test="report/filters/filter[text()='High']">
                        <input type="checkbox" name="level_high" value="1"
                               checked="1"/>
                      </xsl:when>
                      <xsl:otherwise>
                        <input type="checkbox" name="level_high" value="1"/>
                      </xsl:otherwise>
                    </xsl:choose>
                    <img src="/img/high.png" alt="High" title="High"/>
                  </label>
                </td>
                <td class="threat_info_table_h">
                  <label>
                    <xsl:choose>
                      <xsl:when test="report/filters/filter[text()='Medium']">
                        <input type="checkbox" name="level_medium" value="1"
                               checked="1"/>
                      </xsl:when>
                      <xsl:otherwise>
                        <input type="checkbox" name="level_medium" value="1"/>
                      </xsl:otherwise>
                    </xsl:choose>
                    <img src="/img/medium.png" alt="Medium" title="Medium"/>
                  </label>
                </td>
                <td class="threat_info_table_h">
                  <label>
                    <xsl:choose>
                      <xsl:when test="report/filters/filter[text()='Low']">
                        <input type="checkbox" name="level_low" value="1"
                               checked="1"/>
                      </xsl:when>
                      <xsl:otherwise>
                        <input type="checkbox" name="level_low" value="1"/>
                      </xsl:otherwise>
                    </xsl:choose>
                    <img src="/img/low.png" alt="Low" title="Low"/>
                  </label>
                </td>
              </tr>
            </table>
          </div>
        </form>
      </div>
    </div>
  </div>
  <br/>
  <div class="gb_window">
    <div class="gb_window_part_left"></div>
    <div class="gb_window_part_right"></div>
    <div class="gb_window_part_center">
      Filtered Hosts
      <xsl:choose>
        <xsl:when test="count(report/host) &gt; 0">
          <xsl:variable name="last" select="report/hosts/@start + count(report/host) - 1"/>
          <xsl:if test = "report/hosts/@start &gt; 1">
            <a style="margin-right: 5px" class="gb_window_part_center" href="?cmd=get_report&amp;type=assets&amp;first_result={report/hosts/@start - report/hosts/@max}&amp;max_results={report/hosts/@max}&amp;sort_field={report/sort/field/text()}&amp;sort_order={report/sort/field/order}&amp;overrides={report/filters/apply_overrides}&amp;search_phrase={report/filters/phrase}&amp;levels={$levels}&amp;search_phrase={report/filters/phrase}&amp;token={/envelope/token}">&lt;&lt;</a>
          </xsl:if>
          <xsl:value-of select="report/hosts/@start"/> -
          <xsl:value-of select="$last"/>
          of <xsl:value-of select="report/host_count/filtered"/>
          <xsl:if test = "$last &lt; report/host_count/filtered">
            <a style="margin-left: 5px; text-align: right" class="gb_window_part_center" href="?cmd=get_report&amp;type=assets&amp;first_result={report/hosts/@start + report/hosts/@max}&amp;max_results={report/hosts/@max}&amp;overrides={report/filters/apply_overrides}&amp;search_phrase={report/filters/phrase}&amp;levels={$levels}&amp;search_phrase={report/filters/phrase}&amp;token={/envelope/token}">&gt;&gt;</a>
          </xsl:if>
        </xsl:when>
        <xsl:otherwise>
        </xsl:otherwise>
      </xsl:choose>
      <a style="margin-left: 7px" href="/help/hosts.html?token={/envelope/token}" title="Help: Hosts">
        <img src="/img/help.png" border="0"/>
      </a>
      <xsl:choose>
        <xsl:when test="count (report/host) = 0 or report/@scap_loaded = 0">
          <img src="/img/prognosis_inactive.png" border="0" alt="Prognostic Report"
               style="margin-left:3px;"/>
        </xsl:when>
        <xsl:otherwise>
          <a href="/omp?cmd=get_report&amp;type=prognostic&amp;pos=1&amp;host_search_phrase={report/filters/phrase}&amp;host_levels={gsa:build-levels(report/filters)}&amp;host_first_result={report/hosts/@start}&amp;host_max_results={report/hosts/@max}&amp;result_hosts_only=1&amp;overrides={$apply-overrides}&amp;token={/envelope/token}"
             title="Prognostic Report" style="margin-left:3px;">
            <img src="/img/prognosis.png" border="0" alt="Prognostic Report"/>
          </a>
        </xsl:otherwise>
      </xsl:choose>
    </div>
    <xsl:choose>
      <xsl:when test="count (report/host)=0">
        <div class="gb_window_part_content">
          0 hosts
        </div>
      </xsl:when>
      <xsl:otherwise>
        <div class="gb_window_part_content">
          <xsl:apply-templates select="report" mode="assets"/>
        </div>
      </xsl:otherwise>
    </xsl:choose>
  </div>
</xsl:template>

<xsl:template name="report-summary-sorting-link">
  <xsl:param name="report"/>
  <xsl:param name="field"/>
  <xsl:param name="order"/>
  <xsl:param name="levels"/>
  <xsl:param name="name"><xsl:value-of select="$field"/></xsl:param>

  <xsl:choose>
    <xsl:when test="$report/sort/field/text() = $field and $report/sort/field/order = $order">
      <xsl:value-of select="concat($name, ' ', $order)"/>
    </xsl:when>
    <xsl:otherwise>
        <a href="/omp?cmd=get_report&amp;report_id={$report/@id}&amp;delta_report_id={$report/delta/report/@id}&amp;delta_states={$report/filters/delta/text()}&amp;sort_field={$field}&amp;sort_order={$order}&amp;max_results={$report/results/@max}&amp;levels={$levels}&amp;notes={$report/filters/notes}&amp;overrides={$report/filters/overrides}&amp;result_hosts_only={$report/filters/result_hosts_only}&amp;autofp={$report/filters/autofp}&amp;token={/envelope/token}">
        <xsl:value-of select="concat($name, ' ', $order)"/>
      </a>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template name="report-summary-sorting">
  <xsl:param name="report"/>
  <xsl:param name="levels"/>
  <table border="0" cellspacing="0" cellpadding="3" width="100%">
    <tr>
      <td>
        Sorting:
      </td>
      <td>
        <xsl:call-template name="report-summary-sorting-link">
          <xsl:with-param name="report" select="$report"/>
          <xsl:with-param name="field" select="'port'"/>
          <xsl:with-param name="order" select="'ascending'"/>
          <xsl:with-param name="levels" select="$levels"/>
        </xsl:call-template>
        |
        <xsl:call-template name="report-summary-sorting-link">
          <xsl:with-param name="report" select="$report"/>
          <xsl:with-param name="field" select="'port'"/>
          <xsl:with-param name="order" select="'descending'"/>
          <xsl:with-param name="levels" select="$levels"/>
        </xsl:call-template>
        |
        <xsl:call-template name="report-summary-sorting-link">
          <xsl:with-param name="report" select="$report"/>
          <xsl:with-param name="name" select="'threat'"/>
          <xsl:with-param name="field" select="'type'"/>
          <xsl:with-param name="order" select="'ascending'"/>
          <xsl:with-param name="levels" select="$levels"/>
        </xsl:call-template>
        |
        <xsl:call-template name="report-summary-sorting-link">
          <xsl:with-param name="report" select="$report"/>
          <xsl:with-param name="name" select="'threat'"/>
          <xsl:with-param name="field" select="'type'"/>
          <xsl:with-param name="order" select="'descending'"/>
          <xsl:with-param name="levels" select="$levels"/>
        </xsl:call-template>
      </td>
    </tr>
  </table>
</xsl:template>

<xsl:template name="html-report-details">
  <xsl:variable name="levels"
                select="report/filters/text()"/>
  <xsl:variable name="apply-overrides"
                select="report/filters/apply_overrides"/>
  <div class="gb_window">
    <div class="gb_window_part_left"></div>
    <div class="gb_window_part_right"></div>
    <div class="gb_window_part_center">

      Report:
      <xsl:if test="../../delta">Delta</xsl:if>
      <xsl:if test="@type='prognostic'">Prognostic</xsl:if>
      Results

      <xsl:choose>
        <xsl:when test="count(report/results/result) &gt; 0">
          <xsl:variable name="last" select="report/results/@start + count(report/results/result) - 1"/>
          <xsl:if test = "report/results/@start &gt; 1">
            <xsl:choose>
              <xsl:when test="../../delta">
                <a href="?cmd=get_report&amp;delta_report_id={../../delta}&amp;report_id={report/@id}&amp;first_result={report/results/@start - report/results/@max}&amp;max_results={report/results/@max}&amp;levels={$levels}&amp;sort_field={report/sort/field/text()}&amp;sort_order={report/sort/field/order}&amp;notes={report/filters/notes}&amp;overrides={report/filters/apply_overrides}&amp;result_hosts_only={report/filters/result_hosts_only}&amp;apply_min_cvss_base={number (string-length (report/filters/min_cvss_base) &gt; 0)}&amp;min_cvss_base={report/filters/min_cvss_base}&amp;search_phrase={report/filters/phrase}&amp;autofp={report/filters/autofp}&amp;delta_states={report/filters/delta/text()}&amp;delta_states={report/filters/delta/text()}&amp;token={/envelope/token}"><img style="margin-left:10px;margin-right:3px;" src="/img/previous.png" border="0" title="Previous"/></a>
              </xsl:when>
              <xsl:when test="@type='prognostic'">
                <a href="?cmd=get_report&amp;type=prognostic&amp;host={report/filters/host}&amp;pos=1&amp;host_search_phrase={../../host_search_phrase}&amp;host_levels={../../host_levels}&amp;host_first_result={../../results/@start}&amp;host_max_results={../../results/@max}&amp;first_result={report/results/@start - report/results/@max}&amp;max_results={report/results/@max}&amp;levels={$levels}&amp;sort_field={report/sort/field/text()}&amp;sort_order={report/sort/field/order}&amp;notes={report/filters/notes}&amp;overrides={report/filters/apply_overrides}&amp;result_hosts_only={report/filters/result_hosts_only}&amp;apply_min_cvss_base={number (string-length (report/filters/min_cvss_base) &gt; 0)}&amp;min_cvss_base={report/filters/min_cvss_base}&amp;search_phrase={report/filters/phrase}&amp;autofp={report/filters/autofp}&amp;delta_states={report/filters/delta/text()}&amp;token={/envelope/token}"><img style="margin-left:10px;margin-right:3px;" src="/img/previous.png" border="0" title="Previous"/></a>
              </xsl:when>
              <xsl:otherwise>
                <a href="?cmd=get_report&amp;report_id={report/@id}&amp;first_result={report/results/@start - report/results/@max}&amp;max_results={report/results/@max}&amp;levels={$levels}&amp;sort_field={report/sort/field/text()}&amp;sort_order={report/sort/field/order}&amp;notes={report/filters/notes}&amp;overrides={report/filters/apply_overrides}&amp;result_hosts_only={report/filters/result_hosts_only}&amp;apply_min_cvss_base={number (string-length (report/filters/min_cvss_base) &gt; 0)}&amp;min_cvss_base={report/filters/min_cvss_base}&amp;search_phrase={report/filters/phrase}&amp;autofp={report/filters/autofp}&amp;delta_states={report/filters/delta/text()}&amp;token={/envelope/token}"><img style="margin-left:10px;margin-right:3px;" src="/img/previous.png" border="0" title="Previous"/></a>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:if>
          <xsl:value-of select="report/results/@start"/> -
          <xsl:value-of select="$last"/>
          of <xsl:value-of select="report/result_count/filtered"/>
          <xsl:if test = "$last &lt; report/result_count/filtered">
            <xsl:choose>
              <xsl:when test="../../delta">
                <a href="?cmd=get_report&amp;delta_report_id={../../delta}&amp;report_id={report/@id}&amp;first_result={report/results/@start + report/results/@max}&amp;max_results={report/results/@max}&amp;levels={$levels}&amp;sort_field={report/sort/field/text()}&amp;sort_order={report/sort/field/order}&amp;notes={report/filters/notes}&amp;overrides={report/filters/apply_overrides}&amp;result_hosts_only={report/filters/result_hosts_only}&amp;apply_min_cvss_base={number (string-length (report/filters/min_cvss_base) &gt; 0)}&amp;min_cvss_base={report/filters/min_cvss_base}&amp;search_phrase={report/filters/phrase}&amp;autofp={report/filters/autofp}&amp;delta_states={report/filters/delta/text()}&amp;token={/envelope/token}"><img style="margin-left:3px;margin-right:10px;" src="/img/next.png" border="0" title="Next"/></a>
              </xsl:when>
              <xsl:when test="@type='prognostic'">
                <a href="?cmd=get_report&amp;type=prognostic&amp;host={report/filters/host}&amp;pos=1&amp;host_search_phrase={../../host_search_phrase}&amp;host_levels={../../host_levels}&amp;host_first_result={../../results/@start}&amp;host_max_results={../../results/@max}&amp;first_result={report/results/@start + report/results/@max}&amp;max_results={report/results/@max}&amp;levels={$levels}&amp;sort_field={report/sort/field/text()}&amp;sort_order={report/sort/field/order}&amp;notes={report/filters/notes}&amp;overrides={report/filters/apply_overrides}&amp;result_hosts_only={report/filters/result_hosts_only}&amp;apply_min_cvss_base={number (string-length (report/filters/min_cvss_base) &gt; 0)}&amp;min_cvss_base={report/filters/min_cvss_base}&amp;search_phrase={report/filters/phrase}&amp;token={/envelope/token}"><img style="margin-left:3px;margin-right:10px;" src="/img/next.png" border="0" title="Next"/></a>
              </xsl:when>
              <xsl:otherwise>
                <a href="?cmd=get_report&amp;report_id={report/@id}&amp;first_result={report/results/@start + report/results/@max}&amp;max_results={report/results/@max}&amp;levels={$levels}&amp;sort_field={report/sort/field/text()}&amp;sort_order={report/sort/field/order}&amp;notes={report/filters/notes}&amp;overrides={report/filters/apply_overrides}&amp;result_hosts_only={report/filters/result_hosts_only}&amp;apply_min_cvss_base={number (string-length (report/filters/min_cvss_base) &gt; 0)}&amp;min_cvss_base={report/filters/min_cvss_base}&amp;search_phrase={report/filters/phrase}&amp;autofp={report/filters/autofp}&amp;token={/envelope/token}"><img style="margin-left:3px;margin-right:10px;" src="/img/next.png" border="0" title="Next"/></a>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:if>
        </xsl:when>
        <xsl:otherwise>
        </xsl:otherwise>
      </xsl:choose>

      <a href="/help/view_report.html?token={/envelope/token}#viewreport"
         title="Help: View Report (View Report)">
        <img style="vertical-align: text-top;margin-left: 3px" src="/img/help.png"/>
      </a>
      <div id="small_inline_form" style="vertical-align: text-top;display: inline; margin-left: 8px; font-weight: normal;">
        <form action="/omp" method="get">
          <input type="hidden" name="cmd" value="get_report_section"/>
          <input type="hidden" name="report_id" value="{report/@id}"/>
          <xsl:call-template name="report-sections">
            <xsl:with-param name="current" select="'results'"/>
          </xsl:call-template>
          <input type="image"
                 name="Go to Section"
                 src="/img/refresh.png"
                 alt="Go to Section"
                 style="vertical-align: text-top;margin-left:3px;"/>
          <input type="hidden" name="filter" value="{/envelope/params/filter}"/>
          <input type="hidden" name="filt_id" value="{/envelope/params/filt_id}"/>
          <input type="hidden" name="token" value="{/envelope/token}"/>
        </form>
      </div>
    </div>
    <div class="gb_window_part_content">
      <!-- TODO: Move to template. -->
      <xsl:choose>
        <xsl:when test="@type='prognostic'">
        </xsl:when>
        <xsl:otherwise>
          <p>
            <xsl:call-template name="report-summary-sorting">
              <xsl:with-param name="report" select="report"/>
              <xsl:with-param name="levels" select="$levels"/>
            </xsl:call-template>
          </p>
        </xsl:otherwise>
      </xsl:choose>
      <br/>
      <div style="background-color: #EEEEEE;">
        <xsl:variable name="sort_field">
          <xsl:value-of select="report/sort/field/text()"/>
        </xsl:variable>
        <xsl:variable name="sort_order">
          <xsl:value-of select="report/sort/field/order"/>
        </xsl:variable>
        <form action="" method="get">
          <input type="hidden" name="token" value="{/envelope/token}"/>
          <input type="hidden" name="cmd" value="get_report"/>
          <input type="hidden" name="report_id" value="{report/@id}"/>
          <xsl:choose>
            <xsl:when test="@type='prognostic'">
              <input type="hidden" name="type" value="prognostic"/>
              <input type="hidden" name="host" value="{report/filters/host}"/>
              <input type="hidden" name="host_search_phrase" value="{../../host_search_phrase}"/>
              <input type="hidden" name="host_levels" value="{../../host_levels}"/>
              <input type="hidden" name="host_first_result" value="{../../results/@start}"/>
              <input type="hidden" name="host_max_results" value="{../../results/@max}"/>
            </xsl:when>
            <xsl:when test="../../delta">
              <input type="hidden" name="delta_report_id" value="{report/delta/report/@id}"/>
            </xsl:when>
            <xsl:otherwise>
            </xsl:otherwise>
          </xsl:choose>
          <input type="hidden" name="sort_field" value="{$sort_field}"/>
          <input type="hidden" name="sort_order" value="{$sort_order}"/>
          <input type="hidden"
                 name="overrides"
                 value="{report/filters/apply_overrides}"/>
          <xsl:if test="../../delta">
            <div style="float: right;">
              <div style="padding: 2px;">Show delta results:</div>
              <div style="margin-left: 8px;">
                <label>
                  <xsl:choose>
                    <xsl:when test="report/filters/delta/same = 0">
                      <input type="checkbox" name="delta_state_same" value="1"/>
                    </xsl:when>
                    <xsl:otherwise>
                      <input type="checkbox" name="delta_state_same"
                             value="1" checked="1"/>
                    </xsl:otherwise>
                  </xsl:choose>
                  = same
                </label>
              </div>
              <div style="margin-left: 8px;">
                <label>
                  <xsl:choose>
                    <xsl:when test="report/filters/delta/new = 0">
                      <input type="checkbox" name="delta_state_new" value="1"/>
                    </xsl:when>
                    <xsl:otherwise>
                      <input type="checkbox" name="delta_state_new"
                             value="1" checked="1"/>
                    </xsl:otherwise>
                  </xsl:choose>
                  + new
                </label>
              </div>
              <div style="margin-left: 8px;">
                <label>
                  <xsl:choose>
                    <xsl:when test="report/filters/delta/gone = 0">
                      <input type="checkbox" name="delta_state_gone" value="1"/>
                    </xsl:when>
                    <xsl:otherwise>
                      <input type="checkbox" name="delta_state_gone"
                             value="1" checked="1"/>
                    </xsl:otherwise>
                  </xsl:choose>
                  &#8722; gone
                </label>
              </div>
              <div style="margin-left: 8px;">
                <label>
                  <xsl:choose>
                    <xsl:when test="report/filters/delta/changed = 0">
                      <input type="checkbox" name="delta_state_changed" value="1"/>
                    </xsl:when>
                    <xsl:otherwise>
                      <input type="checkbox" name="delta_state_changed"
                             value="1" checked="1"/>
                    </xsl:otherwise>
                  </xsl:choose>
                  ~ changed
                </label>
              </div>
            </div>
          </xsl:if>
          <div style="padding: 2px;">
            Results per page:
            <input type="text" name="max_results" size="5"
                   value="{report/results/@max}"
                   maxlength="400"/>
          </div>

          <xsl:choose>
            <xsl:when test="@type='prognostic'">
            </xsl:when>
            <xsl:otherwise>
              <div style="padding: 2px;">
                Auto-FP:
                <div style="margin-left: 30px">
                  <label>
                    <xsl:choose>
                      <xsl:when test="report/filters/autofp = 0">
                        <input type="checkbox" name="autofp" value="1"/>
                      </xsl:when>
                      <xsl:otherwise>
                        <input type="checkbox" name="autofp" value="1" checked="1"/>
                      </xsl:otherwise>
                    </xsl:choose>
                    Trust vendor security updates
                  </label>
                  <div style="margin-left: 30px">
                    <label>
                      <xsl:choose>
                        <xsl:when test="report/filters/autofp = 2">
                          <input type="radio" name="autofp_value" value="1"/>
                        </xsl:when>
                        <xsl:otherwise>
                          <input type="radio" name="autofp_value" value="1" checked="1"/>
                        </xsl:otherwise>
                      </xsl:choose>
                      Full CVE match
                    </label>
                    <br/>
                    <label>
                      <xsl:choose>
                        <xsl:when test="report/filters/autofp = 2">
                          <input type="radio" name="autofp_value" value="2" checked="1"/>
                        </xsl:when>
                        <xsl:otherwise>
                          <input type="radio" name="autofp_value" value="2"/>
                        </xsl:otherwise>
                      </xsl:choose>
                      Partial CVE match
                    </label>
                  </div>
                </div>
              </div>
            </xsl:otherwise>
          </xsl:choose>

          <xsl:choose>
            <xsl:when test="@type='prognostic'">
            </xsl:when>
            <xsl:otherwise>
              <div style="padding: 2px;">
                <label>
                  <xsl:choose>
                    <xsl:when test="report/filters/notes = 0">
                      <input type="checkbox" name="notes" value="1"/>
                    </xsl:when>
                    <xsl:otherwise>
                      <input type="checkbox" name="notes" value="1" checked="1"/>
                    </xsl:otherwise>
                  </xsl:choose>
                  Show notes
                </label>
              </div>
            </xsl:otherwise>
          </xsl:choose>

          <div style="padding: 2px;">
            <xsl:choose>
              <xsl:when test="report/filters/result_hosts_only = 0">
                <label>
                  <input type="checkbox" name="result_hosts_only" value="1"/>
                  Only show hosts that have results
                </label>
              </xsl:when>
              <xsl:otherwise>
                <label>
                  <input type="checkbox" name="result_hosts_only" value="1" checked="1"/>
                  Only show hosts that have results
                </label>
              </xsl:otherwise>
            </xsl:choose>
          </div>
          <div style="padding: 2px;">
            <label>
              <xsl:choose>
                <xsl:when test="report/filters/min_cvss_base = ''">
                  <input type="checkbox" name="apply_min_cvss_base" value="1"/>
                </xsl:when>
                <xsl:otherwise>
                  <input type="checkbox" name="apply_min_cvss_base" value="1"
                         checked="1"/>
                </xsl:otherwise>
              </xsl:choose>
              CVSS &gt;=
            </label>
            <select name="min_cvss_base">
              <xsl:call-template name="opt">
                <xsl:with-param name="value" select="'10.0'"/>
                <xsl:with-param name="select-value" select="report/filters/min_cvss_base"/>
              </xsl:call-template>
              <xsl:call-template name="opt">
                <xsl:with-param name="value" select="'9.0'"/>
                <xsl:with-param name="select-value" select="report/filters/min_cvss_base"/>
              </xsl:call-template>
              <xsl:choose>
                <xsl:when test="report/filters/min_cvss_base = ''">
                  <xsl:call-template name="opt">
                    <xsl:with-param name="value" select="'8.0'"/>
                    <xsl:with-param name="select-value" select="'8.0'"/>
                  </xsl:call-template>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:call-template name="opt">
                    <xsl:with-param name="value" select="'8.0'"/>
                    <xsl:with-param name="select-value" select="report/filters/min_cvss_base"/>
                  </xsl:call-template>
                </xsl:otherwise>
              </xsl:choose>
              <xsl:call-template name="opt">
                <xsl:with-param name="value" select="'7.0'"/>
                <xsl:with-param name="select-value" select="report/filters/min_cvss_base"/>
              </xsl:call-template>
              <xsl:call-template name="opt">
                <xsl:with-param name="value" select="'6.0'"/>
                <xsl:with-param name="select-value" select="report/filters/min_cvss_base"/>
              </xsl:call-template>
              <xsl:call-template name="opt">
                <xsl:with-param name="value" select="'5.0'"/>
                <xsl:with-param name="select-value" select="report/filters/min_cvss_base"/>
              </xsl:call-template>
              <xsl:call-template name="opt">
                <xsl:with-param name="value" select="'4.0'"/>
                <xsl:with-param name="select-value" select="report/filters/min_cvss_base"/>
              </xsl:call-template>
              <xsl:call-template name="opt">
                <xsl:with-param name="value" select="'3.0'"/>
                <xsl:with-param name="select-value" select="report/filters/min_cvss_base"/>
              </xsl:call-template>
              <xsl:call-template name="opt">
                <xsl:with-param name="value" select="'2.0'"/>
                <xsl:with-param name="select-value" select="report/filters/min_cvss_base"/>
              </xsl:call-template>
              <xsl:call-template name="opt">
                <xsl:with-param name="value" select="'1.0'"/>
                <xsl:with-param name="select-value" select="report/filters/min_cvss_base"/>
              </xsl:call-template>
              <xsl:call-template name="opt">
                <xsl:with-param name="value" select="'0.0'"/>
                <xsl:with-param name="select-value" select="report/filters/min_cvss_base"/>
              </xsl:call-template>
            </select>
          </div>
          <div style="padding: 2px;">
            Text phrase:
            <input type="text" name="search_phrase" size="50"
                   value="{report/filters/phrase}"
                   maxlength="400"/>
          </div>
          <div style="float: right">
            <input type="submit" value="Apply" title="Apply"/>
          </div>
          <div style="padding: 2px;">
            Threat:
            <table style="display: inline">
              <tr>
                <td class="threat_info_table_h">
                  <label>
                    <xsl:choose>
                      <xsl:when test="report/filters/filter[text()='High']">
                        <input type="checkbox" name="level_high" value="1"
                               checked="1"/>
                      </xsl:when>
                      <xsl:otherwise>
                        <input type="checkbox" name="level_high" value="1"/>
                      </xsl:otherwise>
                    </xsl:choose>
                    <img src="/img/high.png" alt="High" title="High"/>
                  </label>
                </td>
                <td class="threat_info_table_h">
                  <label>
                    <xsl:choose>
                      <xsl:when test="report/filters/filter[text()='Medium']">
                        <input type="checkbox" name="level_medium" value="1"
                               checked="1"/>
                      </xsl:when>
                      <xsl:otherwise>
                        <input type="checkbox" name="level_medium" value="1"/>
                      </xsl:otherwise>
                    </xsl:choose>
                    <img src="/img/medium.png" alt="Medium" title="Medium"/>
                  </label>
                </td>
                <td class="threat_info_table_h">
                  <label>
                    <xsl:choose>
                      <xsl:when test="report/filters/filter[text()='Low']">
                        <input type="checkbox" name="level_low" value="1"
                               checked="1"/>
                      </xsl:when>
                      <xsl:otherwise>
                        <input type="checkbox" name="level_low" value="1"/>
                      </xsl:otherwise>
                    </xsl:choose>
                    <img src="/img/low.png" alt="Low" title="Low"/>
                  </label>
                </td>
                <td class="threat_info_table_h">
                  <label>
                    <xsl:choose>
                      <xsl:when test="report/filters/filter[text()='Log']">
                        <input type="checkbox" name="level_log" value="1"
                               checked="1"/>
                      </xsl:when>
                      <xsl:otherwise>
                        <input type="checkbox" name="level_log" value="1"/>
                      </xsl:otherwise>
                    </xsl:choose>
                    <img src="/img/log.png" alt="Log" title="Log"/>
                  </label>
                </td>
                <td class="threat_info_table_h">
                  <label>
                    <xsl:choose>
                      <xsl:when test="report/filters/filter[text()='False Positive']">
                        <input type="checkbox"
                               name="level_false_positive"
                               value="1"
                               checked="1"/>
                      </xsl:when>
                      <xsl:otherwise>
                        <input type="checkbox"
                               name="level_false_positive"
                               value="1"/>
                      </xsl:otherwise>
                    </xsl:choose>
                    <img src="/img/false_positive.png" alt="False Positive" title="False Positive"/>
                  </label>
                </td>
              </tr>
            </table>
          </div>
        </form>
      </div>
      <br/>
      <div style="background-color: #EEEEEE;">
        <div style="float: right">
          <form style="display: inline; margin: 0; vertical-align:middle;" action="" method="post">
            <div style="display: inline; padding: 2px; vertical-align:middle;">
              <input type="hidden" name="token" value="{/envelope/token}"/>
              <input type="hidden" name="cmd" value="create_filter"/>
              <input type="hidden" name="caller" value="{/envelope/caller}"/>
              <input type="hidden" name="comment" value=""/>
              <input type="hidden" name="term" value="{report/filters/term}"/>
              <input type="hidden" name="optional_resource_type" value="report"/>
              <input type="hidden" name="next" value="get_report"/>
              <input type="hidden" name="report_id" value="{report/@id}"/>
              <input type="hidden" name="overrides" value="{$apply-overrides}"/>
              <xsl:choose>
                <xsl:when test="@type='prognostic'">
                  <input type="hidden" name="type" value="prognostic"/>
                  <input type="hidden" name="host" value="{report/filters/host}"/>
                  <input type="hidden" name="host_search_phrase" value="{../../host_search_phrase}"/>
                  <input type="hidden" name="host_levels" value="{../../host_levels}"/>
                  <input type="hidden" name="host_first_result" value="{../../results/@start}"/>
                  <input type="hidden" name="host_max_results" value="{../../results/@max}"/>
                </xsl:when>
                <xsl:when test="../../delta">
                  <input type="hidden" name="delta_report_id" value="{report/delta/report/@id}"/>
                </xsl:when>
                <xsl:otherwise>
                </xsl:otherwise>
              </xsl:choose>
              <input type="hidden" name="filter" value="{/envelope/params/filter}"/>
              <input type="text" name="name" value="" size="10"
                     maxlength="80" style="vertical-align:middle"/>
              <input type="image"
                     name="New Filter"
                     src="/img/new.png"
                     alt="New Filter"
                     style="vertical-align:middle;margin-left:3px;margin-right:3px;"/>
            </div>
          </form>
          <form style="display: inline; margin: 0; vertical-align:middle" action="" method="get">
            <div style="display: inline; padding: 2px; vertical-align:middle;">
              <input type="hidden" name="token" value="{/envelope/token}"/>
              <input type="hidden" name="cmd" value="get_report"/>
              <input type="hidden" name="report_id" value="{report/@id}"/>
              <input type="hidden" name="overrides" value="{$apply-overrides}"/>
              <xsl:choose>
                <xsl:when test="@type='prognostic'">
                  <input type="hidden" name="type" value="prognostic"/>
                  <input type="hidden" name="host" value="{report/filters/host}"/>
                  <input type="hidden" name="host_search_phrase" value="{../../host_search_phrase}"/>
                  <input type="hidden" name="host_levels" value="{../../host_levels}"/>
                  <input type="hidden" name="host_first_result" value="{../../results/@start}"/>
                  <input type="hidden" name="host_max_results" value="{../../results/@max}"/>
                </xsl:when>
                <xsl:when test="../../delta">
                  <input type="hidden" name="delta_report_id" value="{report/delta/report/@id}"/>
                </xsl:when>
                <xsl:otherwise>
                </xsl:otherwise>
              </xsl:choose>
              <select style="margin-bottom: 0px;" name="filt_id">
                <option value="">--</option>
                <xsl:variable name="id" select="report/filters/@id"/>
                <xsl:for-each select="../../filters/get_filters_response/filter">
                  <xsl:choose>
                    <xsl:when test="@id = $id">
                      <option value="{@id}" selected="1"><xsl:value-of select="name"/></option>
                    </xsl:when>
                    <xsl:otherwise>
                      <option value="{@id}"><xsl:value-of select="name"/></option>
                    </xsl:otherwise>
                  </xsl:choose>
                </xsl:for-each>
              </select>
              <input type="image"
                     name="Switch Filter"
                     src="/img/refresh.png"
                     alt="Switch" style="vertical-align:middle;margin-left:3px;margin-right:3px;"/>
              <a href="/omp?cmd=get_filters&amp;token={/envelope/token}"
                 title="Filters">
                <img style="vertical-align:middle;margin-left:3px;margin-right:3px;"
                     src="/img/list.png" border="0" alt="Filters"/>
              </a>
            </div>
          </form>
        </div>
        <form action="" method="get">
          <input type="hidden" name="token" value="{/envelope/token}"/>
          <input type="hidden" name="cmd" value="get_report"/>
          <input type="hidden" name="report_id" value="{report/@id}"/>
          <input type="hidden" name="overrides" value="{$apply-overrides}"/>
          <xsl:choose>
            <xsl:when test="@type='prognostic'">
              <input type="hidden" name="type" value="prognostic"/>
              <input type="hidden" name="host" value="{report/filters/host}"/>
              <input type="hidden" name="host_search_phrase" value="{../../host_search_phrase}"/>
              <input type="hidden" name="host_levels" value="{../../host_levels}"/>
              <input type="hidden" name="host_first_result" value="{../../results/@start}"/>
              <input type="hidden" name="host_max_results" value="{../../results/@max}"/>
            </xsl:when>
            <xsl:when test="../../delta">
              <input type="hidden" name="delta_report_id" value="{report/delta/report/@id}"/>
            </xsl:when>
            <xsl:otherwise>
            </xsl:otherwise>
          </xsl:choose>
          <div style="padding: 2px;">
            Filter:
            <input type="text" name="filter" size="57"
                   value="{report/filters/term}"
                   maxlength="1000"/>
            <input type="image"
                   name="Update Filter"
                   src="/img/refresh.png"
                   alt="Update" style="vertical-align:middle;margin-left:3px;margin-right:3px;"/>
            <a href="/help/powerfilter.html?token={/envelope/token}" title="Help: Powerfilter">
              <img style="vertical-align:middle;margin-left:3px;margin-right:3px;"
                   src="/img/help.png" border="0"/>
            </a>
          </div>
        </form>
      </div>

      <xsl:choose>
        <xsl:when test="count(report/results/result) &gt; 0">
          <xsl:apply-templates select="report" mode="details"/>
        </xsl:when>
        <xsl:otherwise>
          0 results
        </xsl:otherwise>
      </xsl:choose>
    </div>
  </div>
</xsl:template>

<xsl:template name="task-icons">
  <xsl:param name="next" select="'get_tasks'"/>
  <xsl:param name="observed" select="owner/name!=/envelope/login/text()"/>
  <xsl:choose>
    <xsl:when test="$observed or target/@id=''">
      <img style="margin-left: 3px" src="/img/start_inactive.png" border="0" alt="Start"/>
    </xsl:when>
    <xsl:when test="string-length(schedule/@id) &gt; 0">
      <a href="/omp?cmd=get_schedule&amp;schedule_id={schedule/@id}&amp;token={/envelope/token}"
         title="Schedule Details">
        <img style="margin-left: 3px" src="/img/scheduled.png" border="0" alt="Schedule Details"/>
      </a>
    </xsl:when>
    <xsl:when test="status='Running'">
      <xsl:call-template name="pause-icon">
        <xsl:with-param name="type">task</xsl:with-param>
        <xsl:with-param name="id" select="@id"/>
        <xsl:with-param name="params">
          <input type="hidden" name="filter" value="{/envelope/params/filter}"/>
          <input type="hidden" name="filt_id" value="{/envelope/params/filt_id}"/>
          <input type="hidden" name="refresh_interval" value="{/envelope/autorefresh/@interval}"/>
          <input type="hidden" name="next" value="{$next}"/>
        </xsl:with-param>
      </xsl:call-template>
    </xsl:when>
    <xsl:when test="status='Stop Requested' or status='Delete Requested' or status='Ultimate Delete Requested' or status='Pause Requested' or status = 'Paused' or status='Resume Requested' or status='Requested'">
      <img style="margin-left: 3px" src="/img/start_inactive.png" border="0" alt="Start"/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:call-template name="start-icon">
        <xsl:with-param name="type">task</xsl:with-param>
        <xsl:with-param name="id" select="@id"/>
        <xsl:with-param name="params">
          <input type="hidden" name="filter" value="{/envelope/params/filter}"/>
          <input type="hidden" name="filt_id" value="{/envelope/params/filt_id}"/>
          <input type="hidden" name="refresh_interval" value="{/envelope/autorefresh/@interval}"/>
          <input type="hidden" name="next" value="{$next}"/>
        </xsl:with-param>
      </xsl:call-template>
    </xsl:otherwise>
  </xsl:choose>
  <xsl:choose>
    <xsl:when test="$observed or target/@id=''">
      <img src="/img/resume_inactive.png" border="0" alt="Resume"
         style="margin-left:3px;"/>
    </xsl:when>
    <xsl:when test="string-length(schedule/@id) &gt; 0">
      <img src="/img/resume_inactive.png" border="0" alt="Resume"
           style="margin-left:3px;"/>
    </xsl:when>
    <xsl:when test="status='Stopped'">
      <xsl:call-template name="resume-icon">
        <xsl:with-param name="type">task</xsl:with-param>
        <xsl:with-param name="cmd">resume_stopped_task</xsl:with-param>
        <xsl:with-param name="id" select="@id"/>
        <xsl:with-param name="params">
          <input type="hidden" name="filter" value="{/envelope/params/filter}"/>
          <input type="hidden" name="filt_id" value="{/envelope/params/filt_id}"/>
          <input type="hidden" name="refresh_interval" value="{/envelope/autorefresh/@interval}"/>
          <input type="hidden" name="next" value="{$next}"/>
        </xsl:with-param>
      </xsl:call-template>
    </xsl:when>
    <xsl:when test="status='Paused'">
      <xsl:call-template name="resume-icon">
        <xsl:with-param name="type">task</xsl:with-param>
        <xsl:with-param name="cmd">resume_paused_task</xsl:with-param>
        <xsl:with-param name="id" select="@id"/>
        <xsl:with-param name="params">
          <input type="hidden" name="filter" value="{/envelope/params/filter}"/>
          <input type="hidden" name="filt_id" value="{/envelope/params/filt_id}"/>
          <input type="hidden" name="refresh_interval" value="{/envelope/autorefresh/@interval}"/>
          <input type="hidden" name="next" value="{$next}"/>
        </xsl:with-param>
      </xsl:call-template>
    </xsl:when>
    <xsl:otherwise>
      <img src="/img/resume_inactive.png" border="0" alt="Resume"
           style="margin-left:3px;"/>
    </xsl:otherwise>
  </xsl:choose>
  <xsl:choose>
    <xsl:when test="$observed or target/@id=''">
      <img src="/img/stop_inactive.png" border="0" alt="Stop"
         style="margin-left:3px;"/>
    </xsl:when>
    <xsl:when test="string-length(schedule/@id) &gt; 0">
      <img src="/img/stop_inactive.png" border="0"
           alt="Stop"
           style="margin-left:3px;"/>
    </xsl:when>
    <xsl:when test="string-length (/envelope/params/enable_stop) &gt; 0 and /envelope/params/enable_stop = 1">
      <xsl:call-template name="stop-icon">
        <xsl:with-param name="type">task</xsl:with-param>
        <xsl:with-param name="id" select="@id"/>
        <xsl:with-param name="params">
          <input type="hidden" name="filter" value="{/envelope/params/filter}"/>
          <input type="hidden" name="filt_id" value="{/envelope/params/filt_id}"/>
          <input type="hidden" name="refresh_interval" value="{/envelope/autorefresh/@interval}"/>
          <input type="hidden" name="next" value="{$next}"/>
        </xsl:with-param>
      </xsl:call-template>
    </xsl:when>
    <xsl:when test="status='New' or status='Requested' or status='Done' or status='Stopped' or status='Internal Error' or status='Pause Requested' or status='Stop Requested' or status='Resume Requested' or status='Delete Requested' or status='Ultimate Delete Requested'">
      <img src="/img/stop_inactive.png" border="0"
           alt="Stop"
           style="margin-left:3px;"/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:call-template name="stop-icon">
        <xsl:with-param name="type">task</xsl:with-param>
        <xsl:with-param name="id" select="@id"/>
        <xsl:with-param name="params">
          <input type="hidden" name="filter" value="{/envelope/params/filter}"/>
          <input type="hidden" name="filt_id" value="{/envelope/params/filt_id}"/>
          <input type="hidden" name="refresh_interval" value="{/envelope/autorefresh/@interval}"/>
          <input type="hidden" name="next" value="{$next}"/>
        </xsl:with-param>
      </xsl:call-template>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template match="task" mode="details">
  <xsl:variable name="apply-overrides" select="/envelope/params/overrides"/>
  <xsl:variable name="observed" select="owner/name!=/envelope/login/text()"/>
  <div class="gb_window">
    <div class="gb_window_part_left"></div>
    <div class="gb_window_part_right"></div>
    <div class="gb_window_part_center">
      Task Details
      <xsl:call-template name="details-header-icons">
        <xsl:with-param name="cap-type" select="'Task'"/>
        <xsl:with-param name="type" select="'task'"/>
      </xsl:call-template>
      <div id="small_inline_form" style="display: inline; margin-left: 15px; font-weight: normal;">
        <xsl:call-template name="task-icons">
          <xsl:with-param name="next" select="'get_task'"/>
        </xsl:call-template>
      </div>
    </div>
    <div class="gb_window_part_content">
      <xsl:call-template name="minor-details"/>
      <table>
        <tr>
          <td><b>Name:</b></td>
          <td><b><xsl:value-of select="name"/></b></td>
        </tr>
        <tr>
          <td>Comment:</td>
          <td><xsl:value-of select="comment"/></td>
        </tr>
        <tr>
          <td>Scan Config:</td>
          <td>
            <a href="/omp?cmd=get_config&amp;config_id={config/@id}&amp;token={/envelope/token}">
              <xsl:value-of select="config/name"/>
            </a>
          </td>
        </tr>
        <tr>
          <td>Alerts:</td>
          <td>
            <xsl:for-each select="alert">
              <a href="/omp?cmd=get_alert&amp;alert_id={@id}&amp;token={/envelope/token}">
                <xsl:value-of select="name"/>
              </a>
              <xsl:if test="position() != last()">, </xsl:if>
            </xsl:for-each>
          </td>
        </tr>
        <tr>
          <td>Schedule:</td>
          <td>
            <xsl:if test="schedule">
              <a href="/omp?cmd=get_schedule&amp;schedule_id={schedule/@id}&amp;token={/envelope/token}">
                <xsl:value-of select="schedule/name"/>
              </a>
              <xsl:choose>
                <xsl:when test="schedule/next_time = 'over'">
                  (Next due: over)
                </xsl:when>
                <xsl:otherwise>
                  (Next due: <xsl:value-of select="gsa:long-time-tz (schedule/next_time)"/>)
                </xsl:otherwise>
              </xsl:choose>
            </xsl:if>
          </td>
        </tr>
        <tr>
          <td>Target:</td>
          <td>
            <a href="/omp?cmd=get_target&amp;target_id={target/@id}&amp;token={/envelope/token}">
              <xsl:value-of select="target/name"/>
            </a>
          </td>
        </tr>
        <tr>
          <td>Slave:</td>
          <td>
            <a href="/omp?cmd=get_slave&amp;slave_id={slave/@id}&amp;token={/envelope/token}">
              <xsl:value-of select="slave/name"/>
            </a>
          </td>
        </tr>
        <tr>
          <td>Status:</td>
          <td>
            <xsl:call-template name="status_bar">
              <xsl:with-param name="status">
                <xsl:choose>
                  <xsl:when test="target/@id='' and status='Running'">
                    <xsl:text>Uploading</xsl:text>
                  </xsl:when>
                  <xsl:when test="target/@id=''">
                    <xsl:text>Container</xsl:text>
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:value-of select="status"/>
                  </xsl:otherwise>
                </xsl:choose>
              </xsl:with-param>
              <xsl:with-param name="progress">
                <xsl:value-of select="progress/text()"/>
              </xsl:with-param>
            </xsl:call-template>
          </td>
        </tr>
        <tr>
          <td>Reports:</td>
          <td>
            <xsl:value-of select="report_count/text()"/>
            (Finished: <xsl:value-of select="report_count/finished"/>)
          </td>
        </tr>
        <xsl:choose>
          <xsl:when test="$observed">
            <tr>
              <td><b>Owner:</b></td>
              <td>
                <b><xsl:value-of select="owner/name"/></b>
              </td>
            </tr>
          </xsl:when>
          <xsl:otherwise>
            <tr>
              <td>Observers:</td>
              <td>
                <xsl:value-of select="observers/text()"/>
              </td>
            </tr>
            <tr>
              <td>Observer Groups:</td>
              <td>
                <xsl:for-each select="observers/group">
                  <a href="/omp?cmd=get_group&amp;group_id={@id}&amp;token={/envelope/token}">
                    <xsl:value-of select="name"/>
                  </a>
                  <xsl:if test="position() != last()">, </xsl:if>
                </xsl:for-each>
              </td>
            </tr>
          </xsl:otherwise>
        </xsl:choose>
        <tr>
          <xsl:variable name="in_assets"
                        select="preferences/preference[scanner_name='in_assets']"/>
          <td>
            Add to Assets:
          </td>
          <td>
            <xsl:value-of select="$in_assets/value"/>
          </td>
        </tr>
        <tr>
          <td>
            Notes:
          </td>
          <td>
            <a href="/omp?cmd=get_notes&amp;filter=task_id={@id} sort=nvt&amp;filt_id={/envelope/params/filt_id}&amp;token={/envelope/token}"
               title="Notes on Task {name}">
              <xsl:value-of select="count (../../get_notes_response/note)"/>
            </a>
          </td>
        </tr>
        <tr>
          <td>
            Overrides:
          </td>
          <td>
            <a href="/omp?cmd=get_overrides&amp;filter=task_id={@id} sort=nvt&amp;filt_id={/envelope/params/filt_id}&amp;token={/envelope/token}"
               title="Overrides on Task {name}">
              <xsl:value-of select="count (../../get_overrides_response/override)"/>
            </a>
          </td>
        </tr>
      </table>
      <xsl:choose>
        <xsl:when test="target/@id=''">
        </xsl:when>
        <xsl:otherwise>
          <h4>Scan Intensity</h4>
          <table>
            <tr>
              <td><xsl:value-of select="preferences/preference[scanner_name='max_checks']/name"/>:</td>
              <td>
                <xsl:value-of select="preferences/preference[scanner_name='max_checks']/value"/>
              </td>
            </tr>
            <tr>
              <td><xsl:value-of select="preferences/preference[scanner_name='max_hosts']/name"/>:</td>
              <td>
                <xsl:value-of select="preferences/preference[scanner_name='max_hosts']/value"/>
              </td>
            </tr>
          </table>
        </xsl:otherwise>
      </xsl:choose>
    </div>
  </div>
  <xsl:if test="target/@id=''">
    <br/>
    <div class="gb_window">
      <div class="gb_window_part_left"></div>
      <div class="gb_window_part_right"></div>
      <div class="gb_window_part_center">Import Report
        <a href="/help/reports.html?token={/envelope/token}#import_report" title="Help: Import Report">
          <img src="/img/help.png"/>
        </a>
      </div>
      <div class="gb_window_part_content">
        <form action="/omp" method="post" enctype="multipart/form-data">
          <div style="float: right">
            <input type="submit" name="submit" value="Add Report"/>
          </div>
          <input type="hidden" name="token" value="{/envelope/token}"/>
          <input type="hidden" name="cmd" value="create_report"/>
          <input type="hidden" name="caller" value="{/envelope/caller}"/>
          <input type="hidden" name="next" value="get_task"/>
          <input type="hidden" name="task_id" value="{@id}"/>
          <input type="hidden" name="overrides" value="{apply_overrides}"/>
          <input type="file" name="xml_file" size="30"/>
        </form>
      </div>
    </div>
  </xsl:if>
  <br/>
  <div class="gb_window">
    <div class="gb_window_part_left"></div>
    <div class="gb_window_part_right"></div>
    <div class="gb_window_part_center">
      Reports for "<xsl:value-of select="name"/>"
      <a href="/help/reports.html?token={/envelope/token}#reports" title="Help: Reports (Reports)">
        <img src="/img/help.png"/>
      </a>
      <div id="small_inline_form" style="display: inline; margin-left: 40px; font-weight: normal;">
        <form action="" method="get">
          <input type="hidden" name="token" value="{/envelope/token}"/>
          <input type="hidden" name="cmd" value="get_task"/>
          <input type="hidden" name="task_id" value="{@id}"/>
          <input type="hidden" name="filter" value="{/envelope/params/filter}"/>
          <input type="hidden" name="filt_id" value="{/envelope/params/filt_id}"/>
          <input type="hidden" name="original_overrides" value="{$apply-overrides}"/>
          <select style="margin-bottom: 0px;" name="overrides" size="1">
            <xsl:choose>
              <xsl:when test="$apply-overrides = 0">
                <option value="0" selected="1">&#8730;No overrides</option>
                <option value="1" >Apply overrides</option>
              </xsl:when>
              <xsl:otherwise>
                <option value="0">No overrides</option>
                <option value="1" selected="1">&#8730;Apply overrides</option>
              </xsl:otherwise>
            </xsl:choose>
          </select>
          <input type="image"
                 name="Update"
                 src="/img/refresh.png"
                 alt="Update" style="margin-left:3px;margin-right:3px;"/>
        </form>
      </div>
    </div>
    <div class="gb_window_part_content_no_pad">
      <div id="reports">
        <table class="gbntable" cellspacing="2" cellpadding="4">
          <tr class="gbntablehead2">
            <td rowspan="2">Report</td>
            <td rowspan="2">Threat</td>
            <td colspan="5">Scan Results</td>
            <td rowspan="2">Actions</td>
          </tr>
          <tr class="gbntablehead2">
            <td class="threat_info_table_h">
              <img src="/img/high.png" alt="High" title="High"/>
            </td>
            <td class="threat_info_table_h">
              <img src="/img/medium.png" alt="Medium" title="Medium"/>
            </td>
            <td class="threat_info_table_h">
              <img src="/img/low.png" alt="Low" title="Low"/>
            </td>
            <td class="threat_info_table_h">
              <img src="/img/log.png" alt="Log" title="Log"/>
            </td>
            <td class="threat_info_table_h">
              <img src="/img/false_positive.png" alt="False Positive" title="False Positive"/>
            </td>
          </tr>
          <xsl:variable name="container" select="target/@id='' and status='Running'"/>
          <xsl:for-each select="reports/report">
            <xsl:call-template name="report">
              <xsl:with-param name="container" select="$container"/>
              <xsl:with-param name="observed" select="$observed"/>
            </xsl:call-template>
          </xsl:for-each>
        </table>
      </div>
    </div>
  </div>
</xsl:template>

<xsl:template name="short_timestamp_first">
  <xsl:if test="first_report/report/timestamp">
    <xsl:value-of select="concat (date:month-abbreviation(first_report/report/timestamp), ' ', date:day-in-month(first_report/report/timestamp), ' ', date:year(first_report/report/timestamp))"/>
  </xsl:if>
</xsl:template>

<xsl:template name="short_timestamp_last">
  <xsl:if test="first_report/report/timestamp">
    <xsl:value-of select="concat (date:month-abbreviation(last_report/report/timestamp), ' ', date:day-in-month(last_report/report/timestamp), ' ', date:year(last_report/report/timestamp))"/>
  </xsl:if>
</xsl:template>

<xsl:template name="short_timestamp_second_last">
  <xsl:if test="first_report/report/timestamp">
    <xsl:value-of select="concat (date:month-abbreviation(second_last_report/report/timestamp), ' ', date:day-in-month(second_last_report/report/timestamp), ' ', date:year(second_last_report/report/timestamp))"/>
  </xsl:if>
</xsl:template>

<!-- TREND METER -->
<xsl:template name="trend_meter">
  <xsl:choose>
    <xsl:when test="trend = 'up'">
      <img src="/img/trend_up.png" alt="Threat level increased"
           title="Threat level increased"/>
    </xsl:when>
    <xsl:when test="trend = 'down'">
      <img src="/img/trend_down.png" alt="Threat level decreased"
           title="Threat level decreased"/>
    </xsl:when>
    <xsl:when test="trend = 'more'">
      <img src="/img/trend_more.png" alt="Threat count increased"
           title="Threat count increased"/>
    </xsl:when>
    <xsl:when test="trend = 'less'">
      <img src="/img/trend_less.png" alt="Threat count decreased"
           title="Threat count decreased"/>
    </xsl:when>
    <xsl:when test="trend = 'same'">
      <img src="/img/trend_nochange.png" alt="Threat did not change"
           title="The threat did not change"/>
    </xsl:when>
    <xsl:otherwise>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template match="target" mode="newtask">
  <option value="{@id}"><xsl:value-of select="name"/></option>
</xsl:template>

<xsl:template match="config" mode="newtask">
  <option value="{@id}"><xsl:value-of select="name"/></option>
</xsl:template>

<xsl:template match="alert" mode="newtask">
  <option value="{@id}"><xsl:value-of select="name"/></option>
</xsl:template>

<xsl:template match="group" mode="newtask">
  <option value="{@id}"><xsl:value-of select="name"/></option>
</xsl:template>

<xsl:template match="schedule" mode="newtask">
  <option value="{@id}"><xsl:value-of select="name"/></option>
</xsl:template>

<xsl:template match="slave" mode="newtask">
  <option value="{@id}"><xsl:value-of select="name"/></option>
</xsl:template>

<xsl:template name="status_bar">
  <xsl:param name="status">(Unknown)</xsl:param>
  <xsl:param name="progress">(Unknown)</xsl:param>
  <xsl:choose>
    <xsl:when test="$status='Running'">
      <div class="progressbar_box" title="{$status}">
        <div class="progressbar_bar" style="width:{$progress}px;"></div>
        <div class="progressbar_text">
          <xsl:value-of select="$progress"/> %
        </div>
      </div>
    </xsl:when>
    <xsl:when test="$status='New'">
      <div class="progressbar_box" title="{$status}">
        <div class="progressbar_bar_new" style="width:100px;"></div>
        <div class="progressbar_text">
          <i><b><xsl:value-of select="$status"/></b></i>
        </div>
      </div>
    </xsl:when>
    <xsl:when test="$status='Requested'">
      <div class="progressbar_box" title="{$status}">
        <div class="progressbar_bar_request" style="width:100px;"></div>
        <div class="progressbar_text"><xsl:value-of select="$status"/></div>
      </div>
    </xsl:when>
    <xsl:when test="$status='Delete Requested'">
      <div class="progressbar_box" title="{$status}">
        <div class="progressbar_bar_request" style="width:100px;"></div>
        <div class="progressbar_text"><xsl:value-of select="$status"/></div>
      </div>
    </xsl:when>
    <xsl:when test="$status='Ultimate Delete Requested'">
      <div class="progressbar_box" title="Delete Requested">
        <div class="progressbar_bar_request" style="width:100px;"></div>
        <div class="progressbar_text">Delete Requested</div>
      </div>
    </xsl:when>
    <xsl:when test="$status='Pause Requested'">
      <div class="progressbar_box" title="{$status}">
        <div class="progressbar_bar_request" style="width:100px;"></div>
        <div class="progressbar_text"><xsl:value-of select="$status"/></div>
      </div>
    </xsl:when>
    <xsl:when test="$status='Paused'">
      <div class="progressbar_box" title="{$status}">
        <div class="progressbar_bar_request" style="width:{$progress}px;"></div>
        <div class="progressbar_text">
          <xsl:value-of select="$status"/>
          <xsl:if test="$progress &gt;= 0">
            at <xsl:value-of select="$progress"/> %
          </xsl:if>
        </div>
      </div>
    </xsl:when>
    <xsl:when test="$status='Resume Requested'">
      <div class="progressbar_box" title="{$status}">
        <div class="progressbar_bar_request" style="width:100px;"></div>
        <div class="progressbar_text"><xsl:value-of select="$status"/></div>
      </div>
    </xsl:when>
    <xsl:when test="$status='Stop Requested'">
      <div class="progressbar_box" title="{$status}">
        <div class="progressbar_bar_request" style="width:100px;"></div>
        <div class="progressbar_text"><xsl:value-of select="$status"/></div>
      </div>
    </xsl:when>
    <xsl:when test="$status='Stopped'">
      <div class="progressbar_box" title="{$status}">
        <div class="progressbar_bar_request" style="width:{$progress}px;"></div>
        <div class="progressbar_text">
          <xsl:value-of select="$status"/>
          <xsl:if test="$progress &gt;= 0">
            at <xsl:value-of select="$progress"/> %
          </xsl:if>
        </div>
      </div>
    </xsl:when>
    <xsl:when test="$status='Internal Error'">
      <div class="progressbar_box" title="{$status}">
        <div class="progressbar_bar_error" style="width:100px;"></div>
        <div class="progressbar_text"><xsl:value-of select="$status"/></div>
      </div>
    </xsl:when>
    <xsl:when test="$status='Done'">
      <div class="progressbar_box" title="{$status}">
        <div class="progressbar_bar_done" style="width:100px;"></div>
        <div class="progressbar_text"><xsl:value-of select="$status"/></div>
      </div>
    </xsl:when>
    <xsl:when test="$status='Uploading'">
      <div class="progressbar_box" title="{$status}">
        <div class="progressbar_bar_done" style="width:{$progress}px;"></div>
        <div class="progressbar_text">
          <xsl:value-of select="$status"/>
          <xsl:if test="$progress &gt;= 0">
            <xsl:text>: </xsl:text>
            <xsl:value-of select="$progress"/> %
          </xsl:if>
        </div>
      </div>
    </xsl:when>
    <xsl:when test="$status='Container'">
      <div class="progressbar_box" title="{$status}">
        <div class="progressbar_bar_done" style="width:100px;"></div>
        <div class="progressbar_text"><xsl:value-of select="$status"/></div>
      </div>
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="$status"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<!-- END NAMED TEMPLATES -->

<xsl:template match="message">
  <div class="message">
    <xsl:apply-templates/>
  </div>
</xsl:template>

<xsl:template match="error">
  <div class="error">
    <xsl:apply-templates/>
  </div>
</xsl:template>

<xsl:template match="status">
</xsl:template>

<xsl:template match="hole">
  H=<xsl:apply-templates/>
</xsl:template>

<xsl:template match="warning">
  W=<xsl:apply-templates/>
</xsl:template>

<xsl:template match="info">
  I=<xsl:apply-templates/>
</xsl:template>

<xsl:template match="debug">
  D=<xsl:apply-templates/>
</xsl:template>

<xsl:template match="log">
  L=<xsl:apply-templates/>
</xsl:template>

<xsl:template match="false_positive">
  F=<xsl:apply-templates/>
</xsl:template>

<xsl:template match="result_count">
  <div>
    <xsl:apply-templates/>
  </div>
</xsl:template>

<xsl:template match="gsad_msg">
  <xsl:call-template name="command_result_dialog">
    <xsl:with-param name="operation">
      <xsl:value-of select="@operation"/>
    </xsl:with-param>
    <xsl:with-param name="status">
      <xsl:value-of select="@status"/>
    </xsl:with-param>
    <xsl:with-param name="msg">
      <xsl:value-of select="@status_text"/>
    </xsl:with-param>
    <xsl:with-param name="details">
      <xsl:value-of select="text()"/>
    </xsl:with-param>
  </xsl:call-template>
</xsl:template>

<xsl:template match="create_report_response">
  <xsl:call-template name="command_result_dialog">
    <xsl:with-param name="operation">Create Container Task</xsl:with-param>
    <xsl:with-param name="status">
      <xsl:value-of select="@status"/>
    </xsl:with-param>
    <xsl:with-param name="msg">
      <xsl:value-of select="@status_text"/>
    </xsl:with-param>
  </xsl:call-template>
</xsl:template>

<xsl:template match="create_task_response">
  <xsl:call-template name="command_result_dialog">
    <xsl:with-param name="operation">Create Task</xsl:with-param>
    <xsl:with-param name="status">
      <xsl:value-of select="@status"/>
    </xsl:with-param>
    <xsl:with-param name="msg">
      <xsl:value-of select="@status_text"/>
    </xsl:with-param>
  </xsl:call-template>
</xsl:template>

<xsl:template match="delete_task_response">
  <xsl:call-template name="command_result_dialog">
    <xsl:with-param name="operation">Delete Task</xsl:with-param>
    <xsl:with-param name="status">
      <xsl:value-of select="@status"/>
    </xsl:with-param>
    <xsl:with-param name="msg">
      <xsl:value-of select="@status_text"/>
    </xsl:with-param>
  </xsl:call-template>
</xsl:template>

<xsl:template match="delete_report_response">
  <xsl:call-template name="command_result_dialog">
    <xsl:with-param name="operation">Delete Report</xsl:with-param>
    <xsl:with-param name="status">
      <xsl:value-of select="@status"/>
    </xsl:with-param>
    <xsl:with-param name="msg">
      <xsl:value-of select="@status_text"/>
    </xsl:with-param>
  </xsl:call-template>
</xsl:template>

<xsl:template match="run_wizard_response">
  <xsl:call-template name="command_result_dialog">
    <xsl:with-param name="operation">Run Wizard</xsl:with-param>
    <xsl:with-param name="status">
      <xsl:value-of select="@status"/>
    </xsl:with-param>
    <xsl:with-param name="msg">
      <xsl:value-of select="@status_text"/>
    </xsl:with-param>
  </xsl:call-template>
</xsl:template>

<xsl:template match="start_task_response">
  <xsl:call-template name="command_result_dialog">
    <xsl:with-param name="operation">Start Task</xsl:with-param>
    <xsl:with-param name="status">
      <xsl:value-of select="@status"/>
    </xsl:with-param>
    <xsl:with-param name="msg">
      <xsl:value-of select="@status_text"/>
    </xsl:with-param>
  </xsl:call-template>
</xsl:template>

<xsl:template match="stop_task_response">
  <xsl:call-template name="command_result_dialog">
    <xsl:with-param name="operation">Stop Task</xsl:with-param>
    <xsl:with-param name="status">
      <xsl:value-of select="@status"/>
    </xsl:with-param>
    <xsl:with-param name="msg">
      <xsl:value-of select="@status_text"/>
    </xsl:with-param>
  </xsl:call-template>
</xsl:template>

<xsl:template match="pause_task_response">
  <xsl:call-template name="command_result_dialog">
    <xsl:with-param name="operation">Pause Task</xsl:with-param>
    <xsl:with-param name="status">
      <xsl:value-of select="@status"/>
    </xsl:with-param>
    <xsl:with-param name="msg">
      <xsl:value-of select="@status_text"/>
    </xsl:with-param>
  </xsl:call-template>
</xsl:template>

<xsl:template match="resume_paused_task_response">
  <xsl:call-template name="command_result_dialog">
    <xsl:with-param name="operation">Resume Task</xsl:with-param>
    <xsl:with-param name="status">
      <xsl:value-of select="@status"/>
    </xsl:with-param>
    <xsl:with-param name="msg">
      <xsl:value-of select="@status_text"/>
    </xsl:with-param>
  </xsl:call-template>
</xsl:template>

<xsl:template match="resume_stopped_task_response">
  <xsl:call-template name="command_result_dialog">
    <xsl:with-param name="operation">Resume Stopped Task</xsl:with-param>
    <xsl:with-param name="status">
      <xsl:value-of select="@status"/>
    </xsl:with-param>
    <xsl:with-param name="msg">
      <xsl:value-of select="@status_text"/>
    </xsl:with-param>
  </xsl:call-template>
</xsl:template>

<xsl:template match="task_count">
</xsl:template>

<!-- LAST_REPORT -->

<xsl:template match="last_report">
  <xsl:apply-templates/>
</xsl:template>

<!-- REPORT -->
<xsl:template match="report" name="report">
  <xsl:param name="container">0</xsl:param>
  <xsl:param name="observed">0</xsl:param>
  <xsl:variable name="class">
    <xsl:choose>
      <xsl:when test="position() mod 2 = 0">even</xsl:when>
      <xsl:otherwise>odd</xsl:otherwise>
    </xsl:choose>
  </xsl:variable>
  <tr class="{$class}">
    <td>
      <b><xsl:value-of select="concat (date:day-abbreviation (timestamp), ' ', date:month-abbreviation (timestamp), ' ', date:day-in-month (timestamp), ' ', format-number(date:hour-in-day(timestamp), '00'), ':', format-number(date:minute-in-hour(timestamp), '00'), ':', format-number(date:second-in-minute(timestamp), '00'), ' ', date:year(timestamp))"/></b><br/>
      <xsl:choose>
        <xsl:when test="$container=1 and scan_run_status='Running'">
          <xsl:text>Uploading</xsl:text>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="scan_run_status"/>
        </xsl:otherwise>
      </xsl:choose>
    </td>
    <td>
      <xsl:choose>
        <xsl:when test="result_count/hole &gt; 0">
          <img src="/img/high_big.png"
               title="High={result_count/hole} Medium={result_count/warning} Low={result_count/info} FP={result_count/false_positive}"
               alt="High"/>
        </xsl:when>
        <xsl:when test="result_count/warning &gt; 0">
          <img src="/img/medium_big.png"
               title="High={result_count/hole} Medium={result_count/warning} Low={result_count/info} FP={result_count/false_positive}"
               alt="Medium"/>
        </xsl:when>
        <xsl:when test="result_count/info &gt; 0">
          <img src="/img/low_big.png"
               title="High={result_count/hole} Medium={result_count/warning} Low={result_count/info} FP={result_count/false_positive}"
               alt="Low"/>
        </xsl:when>
        <xsl:otherwise>
          <img src="/img/none_big.png"
               title="High={result_count/hole} Medium={result_count/warning} Low={result_count/info} FP={result_count/false_positive}"
               alt="None"/>
        </xsl:otherwise>
      </xsl:choose>
    </td>
    <td class="threat_info_table">
      <xsl:value-of select="result_count/hole"/>
    </td>
    <td class="threat_info_table">
      <xsl:value-of select="result_count/warning"/>
    </td>
    <td class="threat_info_table">
      <xsl:value-of select="result_count/info"/>
    </td>
    <td class="threat_info_table">
      <xsl:value-of select="result_count/log"/>
    </td>
    <td class="threat_info_table">
      <xsl:value-of select="result_count/false_positive"/>
    </td>
    <td>
      <xsl:choose>
        <xsl:when test="../../../../../delta = @id">
          <img src="/img/delta_inactive.png" border="0" alt="Compare"
               style="margin-left:3px;"/>
        </xsl:when>
        <xsl:when test="string-length (../../../../../delta) &gt; 0">
          <a href="/omp?cmd=get_report&amp;report_id={../../../../../delta}&amp;delta_report_id={@id}&amp;notes=1&amp;overrides={../../../../../apply_overrides}&amp;result_hosts_only=1&amp;token={/envelope/token}"
             title="Compare"
             style="margin-left:3px;">
            <img src="/img/delta_second.png" border="0" alt="Compare"/>
          </a>
        </xsl:when>
        <xsl:otherwise>
          <a href="/omp?cmd=get_task&amp;task_id={../../../task/@id}&amp;report_id={@id}&amp;overrides={../../../../../apply_overrides}&amp;token={/envelope/token}"
             title="Compare"
             style="margin-left:3px;">
            <img src="/img/delta.png" border="0" alt="Compare"/>
          </a>
        </xsl:otherwise>
      </xsl:choose>
      <a href="/omp?cmd=get_report&amp;report_id={@id}&amp;notes=1&amp;overrides={../../../../../apply_overrides}&amp;result_hosts_only=1&amp;token={/envelope/token}"
         title="Details"
         style="margin-left:3px;">
        <img src="/img/details.png" border="0" alt="Details"/>
      </a>
      <xsl:choose>
        <xsl:when test="$observed or scan_run_status='Running' or scan_run_status='Requested' or scan_run_status='Pause Requested' or scan_run_status='Stop Requested' or scan_run_status='Resume Requested' or scan_run_status='Paused'">
          <img src="/img/delete_inactive.png"
               border="0"
               alt="Delete"
               style="margin-left:3px;"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:call-template name="delete-icon">
            <xsl:with-param name="type">report</xsl:with-param>
            <xsl:with-param name="id" select="@id"/>
            <xsl:with-param name="params">
              <input type="hidden" name="task_id" value="{../../@id}"/>
              <input type="hidden" name="overrides" value="{/envelope/params/overrides}"/>
              <input type="hidden" name="next" value="get_task"/>
            </xsl:with-param>
          </xsl:call-template>
        </xsl:otherwise>
      </xsl:choose>
    </td>
  </tr>
</xsl:template>

<!-- LAST_REPORT -->
<xsl:template match="last_report">
  <xsl:choose>
    <xsl:when test="report/result_count/hole &gt; 0">
      <img src="/img/high_big.png"
           title="High={report/result_count/hole} Medium={report/result_count/warning} Low={report/result_count/info} FP={report/result_count/false_positive}"
           alt="High"/>
    </xsl:when>
    <xsl:when test="report/result_count/warning &gt; 0">
      <img src="/img/medium_big.png"
           title="High={report/result_count/hole} Medium={report/result_count/warning} Low={report/result_count/info} FP={report/result_count/false_positive}"
           alt="Medium"/>
    </xsl:when>
    <xsl:when test="report/result_count/info &gt; 0">
      <img src="/img/low_big.png"
           title="High={report/result_count/hole} Medium={report/result_count/warning} Low={report/result_count/info} FP={report/result_count/false_positive}"
           alt="Low"/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:choose>
        <xsl:when test="../status!='Running'">
          <img src="/img/none_big.png"
               title="High={report/result_count/hole} Medium={report/result_count/warning} Low={report/result_count/info} FP={report/result_count/false_positive}"
               alt="None"/>
        </xsl:when>
      </xsl:choose>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template name="html-edit-task-form">
  <div class="gb_window">
    <div class="gb_window_part_left"></div>
    <div class="gb_window_part_right"></div>
    <div class="gb_window_part_center">Edit Task
      <xsl:call-template name="edit-header-icons">
        <xsl:with-param name="cap-type" select="'Task'"/>
        <xsl:with-param name="type" select="'task'"/>
        <xsl:with-param name="id"
                        select="commands_response/get_tasks_response/task/@id"/>
      </xsl:call-template>
    </div>
    <div class="gb_window_part_content">
      <form action="" method="post" enctype="multipart/form-data">
        <input type="hidden" name="token" value="{/envelope/token}"/>
        <input type="hidden" name="caller" value="{/envelope/caller}"/>
        <input type="hidden"
               name="task_id"
               value="{commands_response/get_tasks_response/task/@id}"/>
        <input type="hidden"
               name="refresh_interval"
               value="{refresh_interval}"/>
        <input type="hidden" name="next" value="{next}"/>
        <input type="hidden" name="sort_field" value="{sort_field}"/>
        <input type="hidden" name="sort_order" value="{sort_order}"/>
        <xsl:if test="string-length (/envelope/params/filt_id) = 0">
          <input type="hidden" name="overrides" value="{apply_overrides}"/>
        </xsl:if>
        <input type="hidden" name="filter" value="{/envelope/params/filter}"/>
        <input type="hidden" name="filt_id" value="{/envelope/params/filt_id}"/>
        <table border="0" cellspacing="0" cellpadding="3" width="100%">
          <tr>
           <td valign="top" width="185">Name</td>
           <td>
             <input type="text"
                    name="name"
                    value="{gsa:param-or ('name', commands_response/get_tasks_response/task/name)}"
                    size="30"
                    maxlength="80"/>
           </td>
          </tr>
          <tr>
            <td valign="top">Comment (optional)</td>
            <td>
              <input type="text" name="comment" size="30" maxlength="400"
                     value="{gsa:param-or ('comment', commands_response/get_tasks_response/task/comment)}"/>
            </td>
          </tr>
          <xsl:choose>
            <xsl:when test="commands_response/get_tasks_response/task/target/@id = ''">
              <input type="hidden" name="target_id" value="--"/>
              <input type="hidden" name="cmd" value="save_container_task"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:choose>
                <xsl:when test="commands_response/get_tasks_response/task/status = 'New'">
                  <tr>
                    <td valign="top">Scan Config</td>
                    <td>
                      <input type="hidden" name="cmd" value="save_task"/>
                      <xsl:variable name="config_id" select="gsa:param-or ('config_id', commands_response/get_tasks_response/task/config/@id)"/>
                      <select name="config_id">
                        <xsl:choose>
                          <xsl:when
                            test="string-length (commands_response/get_configs_response/config/name) &gt; 0">
                            <xsl:for-each select="commands_response/get_configs_response/config">
                              <xsl:choose>
                                <xsl:when test="@id = $config_id">
                                  <option value="{@id}" selected="1"><xsl:value-of select="name"/></option>
                                </xsl:when>
                                <xsl:otherwise>
                                  <option value="{@id}"><xsl:value-of select="name"/></option>
                                </xsl:otherwise>
                              </xsl:choose>
                            </xsl:for-each>
                          </xsl:when>
                          <xsl:otherwise>
                            <option value="0">--</option>
                          </xsl:otherwise>
                        </xsl:choose>
                      </select>
                    </td>
                  </tr>
                  <tr>
                    <td>Scan Targets</td>
                    <td>
                      <xsl:variable name="target_id" select="gsa:param-or ('target_id', commands_response/get_tasks_response/task/target/@id)"/>
                      <select name="target_id">
                        <xsl:choose>
                          <xsl:when
                            test="string-length (commands_response/get_targets_response/target/name) &gt; 0">
                            <xsl:for-each select="commands_response/get_targets_response/target">
                              <xsl:choose>
                                <xsl:when test="@id = $target_id">
                                  <option value="{@id}" selected="1"><xsl:value-of select="name"/></option>
                                </xsl:when>
                                <xsl:otherwise>
                                  <option value="{@id}"><xsl:value-of select="name"/></option>
                                </xsl:otherwise>
                              </xsl:choose>
                            </xsl:for-each>
                          </xsl:when>
                          <xsl:otherwise>
                            <option value="0">--</option>
                          </xsl:otherwise>
                        </xsl:choose>
                      </select>
                    </td>
                  </tr>
                </xsl:when>
                <xsl:otherwise>
                  <tr>
                    <td valign="top">Scan Config (immutable)</td>
                    <td>
                      <input type="hidden" name="cmd" value="save_task"/>
                      <input type="hidden" name="config_id" value="0"/>
                      <select name="dummy" disabled="0">
                        <xsl:choose>
                          <xsl:when
                            test="string-length (commands_response/get_tasks_response/task/config/name) &gt; 0">
                            <xsl:apply-templates
                              select="commands_response/get_tasks_response/task/config"
                              mode="newtask"/>
                          </xsl:when>
                          <xsl:otherwise>
                            <option value="0">--</option>
                          </xsl:otherwise>
                        </xsl:choose>
                      </select>
                    </td>
                  </tr>
                  <tr>
                    <td>Scan Targets (immutable)</td>
                    <td>
                      <input type="hidden" name="target_id" value="0"/>
                      <select name="dummy2" disabled="0">
                        <xsl:choose>
                          <xsl:when
                            test="string-length (commands_response/get_tasks_response/task/target/name) &gt; 0">
                            <xsl:apply-templates
                              select="commands_response/get_tasks_response/task/target"
                              mode="newtask"/>
                          </xsl:when>
                          <xsl:otherwise>
                            <option value="0">--</option>
                          </xsl:otherwise>
                        </xsl:choose>
                      </select>
                    </td>
                  </tr>
                </xsl:otherwise>
              </xsl:choose>
              <tr>
                <td>Alerts (optional)</td>
                <td>
                  <xsl:variable name="alerts"
                                select="commands_response/get_alerts_response/alert"/>
                  <xsl:choose>
                    <xsl:when test="count (/envelope/params/_param[substring-before (name, ':') = 'alert_id_optional'][value != '--']) &gt; 0">
                      <xsl:for-each select="/envelope/params/_param[substring-before (name, ':') = 'alert_id_optional'][value != '--']/value">
                        <select name="alert_id_optional:{position ()}">
                          <xsl:variable name="alert_id" select="text ()"/>
                          <xsl:choose>
                            <xsl:when test="string-length ($alert_id) &gt; 0">
                              <option value="0">--</option>
                            </xsl:when>
                            <xsl:otherwise>
                              <option value="0" selected="1">--</option>
                            </xsl:otherwise>
                          </xsl:choose>
                          <xsl:for-each select="$alerts">
                            <xsl:choose>
                              <xsl:when test="@id = $alert_id">
                                <option value="{@id}" selected="1"><xsl:value-of select="name"/></option>
                              </xsl:when>
                              <xsl:otherwise>
                                <option value="{@id}"><xsl:value-of select="name"/></option>
                              </xsl:otherwise>
                            </xsl:choose>
                          </xsl:for-each>
                        </select>
                        <br/>
                      </xsl:for-each>
                    </xsl:when>
                    <xsl:otherwise>
                      <xsl:for-each select="commands_response/get_tasks_response/task/alert">
                        <select name="alert_id_optional:{position ()}">
                          <xsl:variable name="alert_id" select="@id"/>
                          <xsl:choose>
                            <xsl:when test="string-length ($alert_id) &gt; 0">
                              <option value="0">--</option>
                            </xsl:when>
                            <xsl:otherwise>
                              <option value="0" selected="1">--</option>
                            </xsl:otherwise>
                          </xsl:choose>
                          <xsl:for-each select="$alerts">
                            <xsl:choose>
                              <xsl:when test="@id = $alert_id">
                                <option value="{@id}" selected="1"><xsl:value-of select="name"/></option>
                              </xsl:when>
                              <xsl:otherwise>
                                <option value="{@id}"><xsl:value-of select="name"/></option>
                              </xsl:otherwise>
                            </xsl:choose>
                          </xsl:for-each>
                        </select>
                        <br/>
                      </xsl:for-each>
                    </xsl:otherwise>
                  </xsl:choose>

                  <xsl:variable name="count">
                    <xsl:variable name="params"
                                  select="count (/envelope/params/_param[substring-before (name, ':') = 'alert_id_optional'][value != '--'])"/>
                    <xsl:choose>
                      <xsl:when test="$params &gt; 0">
                        <xsl:value-of select="$params"/>
                      </xsl:when>
                      <xsl:otherwise>
                        <xsl:value-of select="count (commands_response/get_tasks_response/task/alert)"/>
                      </xsl:otherwise>
                    </xsl:choose>
                  </xsl:variable>
                  <xsl:call-template name="new-task-alert-select">
                    <xsl:with-param name="alerts" select="commands_response/get_alerts_response"/>
                    <xsl:with-param name="count" select="alerts - $count"/>
                    <xsl:with-param name="position" select="$count + 1"/>
                  </xsl:call-template>

                  <!-- Force the Create Task button to be the default. -->
                  <input style="position: absolute; left: -100%"
                         type="submit" name="submit" value="Create Task"/>
                  <input type="submit" name="submit_plus" value="+"/>

                  <xsl:choose>
                    <xsl:when test="string-length (/envelope/params/alerts)">
                      <input type="hidden" name="alerts" value="{/envelope/params/alerts}"/>
                    </xsl:when>
                    <xsl:otherwise>
                      <input type="hidden" name="alerts" value="{$count + 1}"/>
                    </xsl:otherwise>
                  </xsl:choose>
                </td>
              </tr>
              <tr>
                <td>Schedule (optional)</td>
                <td>
                  <select name="schedule_id">
                    <xsl:variable name="schedule_id">
                      <xsl:choose>
                        <xsl:when test="string-length (/envelope/params/schedule_id) &gt; 0">
                          <xsl:value-of select="/envelope/params/schedule_id"/>
                        </xsl:when>
                        <xsl:otherwise>
                          <xsl:value-of select="commands_response/get_tasks_response/task/schedule/@id"/>
                        </xsl:otherwise>
                      </xsl:choose>
                    </xsl:variable>
                    <xsl:choose>
                      <xsl:when test="string-length ($schedule_id) &gt; 0">
                        <option value="0">--</option>
                      </xsl:when>
                      <xsl:otherwise>
                        <option value="0" selected="1">--</option>
                      </xsl:otherwise>
                    </xsl:choose>
                    <xsl:for-each select="commands_response/get_schedules_response/schedule">
                      <xsl:choose>
                        <xsl:when test="@id = $schedule_id">
                          <option value="{@id}" selected="1"><xsl:value-of select="name"/></option>
                        </xsl:when>
                        <xsl:otherwise>
                          <option value="{@id}"><xsl:value-of select="name"/></option>
                        </xsl:otherwise>
                      </xsl:choose>
                    </xsl:for-each>
                  </select>
                </td>
              </tr>
              <tr>
                <td>Slave (optional)</td>
                <td>
                  <select name="slave_id">
                    <xsl:variable name="slave_id">
                      <xsl:choose>
                        <xsl:when test="string-length (/envelope/params/slave_id) &gt; 0">
                          <xsl:value-of select="/envelope/params/slave_id"/>
                        </xsl:when>
                        <xsl:otherwise>
                          <xsl:value-of select="commands_response/get_tasks_response/task/slave/@id"/>
                        </xsl:otherwise>
                      </xsl:choose>
                    </xsl:variable>
                    <xsl:choose>
                      <xsl:when test="string-length ($slave_id) &gt; 0">
                        <option value="0">--</option>
                      </xsl:when>
                      <xsl:otherwise>
                        <option value="0" selected="1">--</option>
                      </xsl:otherwise>
                    </xsl:choose>
                    <xsl:for-each select="commands_response/get_slaves_response/slave">
                      <xsl:choose>
                        <xsl:when test="@id = $slave_id">
                          <option value="{@id}" selected="1"><xsl:value-of select="name"/></option>
                        </xsl:when>
                        <xsl:otherwise>
                          <option value="{@id}"><xsl:value-of select="name"/></option>
                        </xsl:otherwise>
                      </xsl:choose>
                    </xsl:for-each>
                  </select>
                </td>
              </tr>
            </xsl:otherwise>
          </xsl:choose>
          <tr>
            <td valign="top">Observers (optional)</td>
            <td>
              <input type="text" name="observers" size="30" maxlength="400"
                     value="{gsa:param-or ('observers', commands_response/get_tasks_response/task/observers/text())}"/>
            </td>
          </tr>
          <tr>
            <td>Observer Groups (optional)</td>
            <td>
              <xsl:variable name="groups"
                            select="commands_response/get_groups_response/group"/>
              <xsl:choose>
                <xsl:when test="count (/envelope/params/_param[substring-before (name, ':') = 'group_id_optional'][value != '--']) &gt; 0">
                  <xsl:for-each select="/envelope/params/_param[substring-before (name, ':') = 'group_id_optional'][value != '--']/value">
                    <select name="group_id_optional:{position ()}">
                      <xsl:variable name="group_id" select="text ()"/>
                      <xsl:choose>
                        <xsl:when test="string-length ($group_id) &gt; 0">
                          <option value="0">--</option>
                        </xsl:when>
                        <xsl:otherwise>
                          <option value="0" selected="1">--</option>
                        </xsl:otherwise>
                      </xsl:choose>
                      <xsl:for-each select="$groups">
                        <xsl:choose>
                          <xsl:when test="@id = $group_id">
                            <option value="{@id}" selected="1"><xsl:value-of select="name"/></option>
                          </xsl:when>
                          <xsl:otherwise>
                            <option value="{@id}"><xsl:value-of select="name"/></option>
                          </xsl:otherwise>
                        </xsl:choose>
                      </xsl:for-each>
                    </select>
                    <br/>
                  </xsl:for-each>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:for-each select="commands_response/get_tasks_response/task/observers/group">
                    <select name="group_id_optional:{position ()}">
                      <xsl:variable name="group_id" select="@id"/>
                      <xsl:choose>
                        <xsl:when test="string-length ($group_id) &gt; 0">
                          <option value="0">--</option>
                        </xsl:when>
                        <xsl:otherwise>
                          <option value="0" selected="1">--</option>
                        </xsl:otherwise>
                      </xsl:choose>
                      <xsl:for-each select="$groups">
                        <xsl:choose>
                          <xsl:when test="@id = $group_id">
                            <option value="{@id}" selected="1"><xsl:value-of select="name"/></option>
                          </xsl:when>
                          <xsl:otherwise>
                            <option value="{@id}"><xsl:value-of select="name"/></option>
                          </xsl:otherwise>
                        </xsl:choose>
                      </xsl:for-each>
                    </select>
                    <br/>
                  </xsl:for-each>
                </xsl:otherwise>
              </xsl:choose>

              <xsl:variable name="count">
                <xsl:variable name="params"
                              select="count (/envelope/params/_param[substring-before (name, ':') = 'group_id_optional'][value != '--'])"/>
                <xsl:choose>
                  <xsl:when test="$params &gt; 0">
                    <xsl:value-of select="$params"/>
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:value-of select="count (commands_response/get_tasks_response/task/observers/group)"/>
                  </xsl:otherwise>
                </xsl:choose>
              </xsl:variable>
              <xsl:call-template name="new-task-group-select">
                <xsl:with-param name="groups" select="commands_response/get_groups_response"/>
                <xsl:with-param name="count" select="groups - $count"/>
                <xsl:with-param name="position" select="$count + 1"/>
              </xsl:call-template>

              <input type="submit" name="submit_plus_group" value="+"/>

              <xsl:choose>
                <xsl:when test="string-length (/envelope/params/groups)">
                  <input type="hidden" name="groups" value="{/envelope/params/groups}"/>
                </xsl:when>
                <xsl:otherwise>
                  <input type="hidden" name="groups" value="{$count + 1}"/>
                </xsl:otherwise>
              </xsl:choose>
            </td>
          </tr>
          <tr>
            <xsl:variable name="in_assets"
                          select="commands_response/get_tasks_response/task/preferences/preference[scanner_name='in_assets']"/>
            <td valign="top">
              <xsl:value-of select="$in_assets/name"/>
            </td>
            <td>
              <xsl:variable name="param_yes" select="/envelope/params/in_assets"/>
              <xsl:choose>
                <xsl:when test="string-length ($param_yes) &gt; 0">
                  <xsl:choose>
                    <xsl:when test="$param_yes = '1'">
                      <label>
                        <input type="radio" name="in_assets" value="1" checked="1"/>
                        yes
                      </label>
                      <label>
                        <input type="radio" name="in_assets" value="0"/>
                        no
                      </label>
                    </xsl:when>
                    <xsl:otherwise>
                      <label>
                        <input type="radio" name="in_assets" value="1"/>
                        yes
                      </label>
                      <label>
                        <input type="radio" name="in_assets" value="0" checked="1"/>
                        no
                      </label>
                    </xsl:otherwise>
                  </xsl:choose>
                </xsl:when>
                <xsl:when test="((string-length ($param_yes) &gt; 0) and ($param_yes = '1')) or $in_assets/value='yes'">
                  <label>
                    <input type="radio" name="in_assets" value="1" checked="1"/>
                    yes
                  </label>
                  <label>
                    <input type="radio" name="in_assets" value="0"/>
                    no
                  </label>
                </xsl:when>
                <xsl:otherwise>
                  <label>
                    <input type="radio" name="in_assets" value="1"/>
                    yes
                  </label>
                  <label>
                    <input type="radio" name="in_assets" value="0" checked="1"/>
                    no
                  </label>
                </xsl:otherwise>
              </xsl:choose>
            </td>
          </tr>
        </table>
        <table border="0" cellspacing="0" cellpadding="3" width="100%">
          <xsl:choose>
            <xsl:when test="commands_response/get_tasks_response/task/target/@id = ''">
              <input type="hidden" name="target_id" value="--"/>
            </xsl:when>
            <xsl:otherwise>
              <h2>Scan Intensity</h2>
              <tr>
                <td valign="top" width="320">
                  <xsl:value-of select="commands_response/get_tasks_response/task/preferences/preference[scanner_name='max_checks']/name"/>
                </td>
                <td>
                  <input type="text"
                         name="max_checks"
                         value="{gsa:param-or ('max_checks', commands_response/get_tasks_response/task/preferences/preference[scanner_name='max_checks']/value)}"
                         size="10"
                         maxlength="10"/>
                </td>
              </tr>
              <tr>
                <td>
                  <xsl:value-of select="commands_response/get_tasks_response/task/preferences/preference[scanner_name='max_hosts']/name"/>
                </td>
                <td>
                  <input type="text"
                         name="max_hosts"
                         value="{gsa:param-or ('max_hosts', commands_response/get_tasks_response/task/preferences/preference[scanner_name='max_hosts']/value)}"
                         size="10"
                         maxlength="10"/>
                </td>
              </tr>
            </xsl:otherwise>
          </xsl:choose>
          <tr>
            <td colspan="2" style="text-align:right;">
              <input type="submit" name="submit" value="Save Task"/>
            </td>
          </tr>
        </table>
        <br/>
      </form>
    </div>
  </div>
  <xsl:if test="commands_response/get_tasks_response/task/target/@id = ''">
    <br/>
    <div class="gb_window">
      <div class="gb_window_part_left"></div>
      <div class="gb_window_part_right"></div>
      <div class="gb_window_part_center">Import Report
        <a href="/help/reports.html?token={/envelope/token}#import_report" title="Help: Import Report">
          <img src="/img/help.png"/>
        </a>
      </div>
      <div class="gb_window_part_content">
        <form action="/omp" method="post" enctype="multipart/form-data">
          <div style="float: right">
            <input type="submit" name="submit" value="Add Report"/>
          </div>
          <input type="hidden" name="token" value="{/envelope/token}"/>
          <input type="hidden" name="cmd" value="create_report"/>
          <input type="hidden" name="caller" value="{/envelope/caller}"/>
          <input type="hidden" name="next" value="{next}"/>
          <input type="hidden" name="task_id" value="{task/@id}"/>
          <input type="hidden" name="overrides" value="{apply_overrides}"/>
          <input type="file" name="xml_file" size="30"/>
        </form>
      </div>
    </div>
  </xsl:if>
</xsl:template>

<xsl:template match="edit_task">
  <xsl:apply-templates select="gsad_msg"/>
  <xsl:call-template name="html-edit-task-form"/>
</xsl:template>

<xsl:template match="modify_task_response">
  <xsl:call-template name="command_result_dialog">
    <xsl:with-param name="operation">Save Task</xsl:with-param>
    <xsl:with-param name="status">
      <xsl:value-of select="@status"/>
    </xsl:with-param>
    <xsl:with-param name="msg">
      <xsl:value-of select="@status_text"/>
    </xsl:with-param>
  </xsl:call-template>
</xsl:template>

<!-- TASK -->

<xsl:template match="task">
  <xsl:choose>
    <xsl:when test="report">
      <xsl:variable name="class">
        <xsl:choose>
          <xsl:when test="position() mod 2 = 0">even</xsl:when>
          <xsl:otherwise>odd</xsl:otherwise>
        </xsl:choose>
      </xsl:variable>
      <xsl:apply-templates select="report"/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:variable name="class">
        <xsl:choose>
          <xsl:when test="position() mod 2 = 0">even</xsl:when>
          <xsl:otherwise>odd</xsl:otherwise>
        </xsl:choose>
      </xsl:variable>
      <tr class="{$class}">
        <td>
          <div class="float_right">
            <xsl:choose>
              <xsl:when test="string-length(slave/@id) &gt; 0">
                <img src="/img/sensor.png"
                     style="margin-left:3px;"
                     border="0"
                     alt="Task is configured to run on slave {slave/name}"
                     title="Task is configured to run on slave {slave/name}"/>
              </xsl:when>
              <xsl:otherwise>
              </xsl:otherwise>
            </xsl:choose>
            <xsl:choose>
              <xsl:when test="string-length (observers) &gt; 0 or count (observers/group) &gt; 0">
                <xsl:variable name="observer_groups">
                  <xsl:choose>
                    <xsl:when test="count (observers/group) &gt; 0">
                      <xsl:value-of select="concat ('&#10;Task made visible for Groups: ', gsa:join (observers/group))"/>
                    </xsl:when>
                    <xsl:otherwise></xsl:otherwise>
                  </xsl:choose>
                </xsl:variable>
                <img src="/img/provide_view.png"
                     border="0"
                     alt="Task made visible for: {observers/text()}{$observer_groups}"
                     title="Task made visible for: {observers/text()}{$observer_groups}"/>
              </xsl:when>
              <xsl:otherwise>
              </xsl:otherwise>
            </xsl:choose>
            <xsl:choose>
              <xsl:when test="owner/name=/envelope/login/text()">
              </xsl:when>
              <xsl:otherwise>
                <img src="/img/view_other.png"
                     style="margin-left:3px;"
                     border="0"
                     alt="Observing task owned by {owner/name}"
                     title="Observing task owned by {owner/name}"/>
              </xsl:otherwise>
            </xsl:choose>
          </div>
          <b>
            <a href="/omp?cmd=get_task&amp;task_id={@id}&amp;overrides={../apply_overrides}&amp;filter={str:encode-uri (../filters/term, true ())}&amp;filt_id={../filters/@id}&amp;token={/envelope/token}">
              <xsl:value-of select="name"/>
            </a>
          </b>
          <xsl:choose>
            <xsl:when test="comment != ''">
              <br/>(<xsl:value-of select="comment"/>)
            </xsl:when>
            <xsl:otherwise></xsl:otherwise>
          </xsl:choose>
        </td>
        <td>
          <xsl:call-template name="status_bar">
            <xsl:with-param name="status">
              <xsl:choose>
                <xsl:when test="target/@id='' and status='Running'">
                  <xsl:text>Uploading</xsl:text>
                </xsl:when>
                <xsl:when test="target/@id=''">
                  <xsl:text>Container</xsl:text>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:value-of select="status"/>
                </xsl:otherwise>
              </xsl:choose>
            </xsl:with-param>
            <xsl:with-param name="progress">
              <xsl:value-of select="progress/text()"/>
            </xsl:with-param>
          </xsl:call-template>
        </td>
        <td style="text-align:right;font-size:10px;">
          <xsl:choose>
            <xsl:when test="report_count &gt; 0">
              <a href="/omp?cmd=get_task&amp;task_id={@id}&amp;filter={str:encode-uri (../filters/term, true ())}&amp;filt_id={../filters/@id}&amp;overrides={../apply_overrides}&amp;token={/envelope/token}">
                <xsl:value-of select="report_count/finished"/>
              </a>
            </xsl:when>
            <xsl:otherwise>
            </xsl:otherwise>
          </xsl:choose>
        </td>
        <td style="font-size:10px;">
          <xsl:choose>
            <xsl:when test="last_report/report/@id = first_report/report/@id">
            </xsl:when>
            <xsl:otherwise>
              <a href="/omp?cmd=get_report&amp;report_id={first_report/report/@id}&amp;notes=1&amp;overrides={../apply_overrides}&amp;result_hosts_only=1&amp;token={/envelope/token}">
                <xsl:call-template name="short_timestamp_first"/>
              </a>
            </xsl:otherwise>
          </xsl:choose>
        </td>
        <td style="font-size:10px;">
          <a href="/omp?cmd=get_report&amp;report_id={last_report/report/@id}&amp;notes=1&amp;overrides={../apply_overrides}&amp;result_hosts_only=1&amp;token={/envelope/token}">
            <xsl:call-template name="short_timestamp_last"/>
          </a>
        </td>
        <td style="text-align:center;">
          <xsl:choose>
            <xsl:when test="target/@id=''">
            </xsl:when>
            <xsl:when test="last_report">
              <xsl:apply-templates select="last_report"/>
            </xsl:when>
          </xsl:choose>
        </td>
        <td style="text-align:center;">
          <xsl:choose>
            <xsl:when test="target/@id=''">
            </xsl:when>
            <xsl:otherwise>
              <!-- Trend -->
              <xsl:call-template name="trend_meter"/>
            </xsl:otherwise>
          </xsl:choose>
        </td>
        <td>
          <xsl:call-template name="task-icons"/>
          <xsl:call-template name="list-window-line-icons">
            <xsl:with-param name="cap-type" select="'Task'"/>
            <xsl:with-param name="type" select="'task'"/>
            <xsl:with-param name="id" select="@id"/>
            <xsl:with-param name="extra-params-details" select="concat ('&amp;overrides=', ../apply_overrides)"/>
          </xsl:call-template>
        </td>
      </tr>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<func:function name="gsa:alert-in-trash">
  <xsl:for-each select="alert">
    <xsl:if test="trash/text() != '0'">
      <func:result>1</func:result>
    </xsl:if>
  </xsl:for-each>
  <func:result>0</func:result>
</func:function>

<func:function name="gsa:table-row-class">
  <xsl:param name="position"/>
  <func:result>
    <xsl:choose>
      <xsl:when test="$position mod 2 = 0">even</xsl:when>
      <xsl:otherwise>odd</xsl:otherwise>
    </xsl:choose>
  </func:result>
</func:function>

<xsl:template match="task" mode="trash">
  <xsl:variable name="class">
    <xsl:choose>
      <xsl:when test="position() mod 2 = 0">even</xsl:when>
      <xsl:otherwise>odd</xsl:otherwise>
    </xsl:choose>
  </xsl:variable>
  <tr class="{$class}">
    <td>
      <b><xsl:value-of select="name"/></b>
      <xsl:choose>
        <xsl:when test="comment != ''">
          <br/>(<xsl:value-of select="comment"/>)
        </xsl:when>
        <xsl:otherwise></xsl:otherwise>
      </xsl:choose>
    </td>
    <td>
      <xsl:call-template name="status_bar">
        <xsl:with-param name="status">
          <xsl:choose>
            <xsl:when test="target/@id=''">
              <xsl:text>Container</xsl:text>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="status"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:with-param>
        <xsl:with-param name="progress">
          <xsl:value-of select="progress/text()"/>
        </xsl:with-param>
      </xsl:call-template>
    </td>
    <td style="text-align:right;font-size:10px;">
      <xsl:choose>
        <xsl:when test="report_count &gt; 0">
          <xsl:value-of select="report_count/finished"/>
        </xsl:when>
        <xsl:otherwise>
        </xsl:otherwise>
      </xsl:choose>
    </td>
    <td style="font-size:10px;">
      <xsl:choose>
        <xsl:when test="last_report/report/@id = first_report/report/@id">
        </xsl:when>
        <xsl:otherwise>
          <xsl:call-template name="short_timestamp_first"/>
        </xsl:otherwise>
      </xsl:choose>
    </td>
    <td style="font-size:10px;">
      <xsl:call-template name="short_timestamp_last"/>
    </td>
    <td style="text-align:center;">
      <xsl:choose>
        <xsl:when test="last_report">
          <xsl:apply-templates select="last_report"/>
        </xsl:when>
      </xsl:choose>
    </td>
    <td style="text-align:center;">
      <!-- Trend -->
      <xsl:call-template name="trend_meter"/>
    </td>
    <td>
      <xsl:choose>
        <xsl:when test="(target/trash = '0') and (config/trash = '0') and (schedule/trash = '0') and (slave/trash = '0') and (gsa:alert-in-trash () = 0)">
          <xsl:call-template name="restore-icon">
            <xsl:with-param name="id" select="@id"/>
          </xsl:call-template>
        </xsl:when>
        <xsl:otherwise>
          <img src="/img/restore_inactive.png" border="0" alt="Restore"
               style="margin-left:3px;"/>
        </xsl:otherwise>
      </xsl:choose>
      <xsl:call-template name="trash-delete-icon">
        <xsl:with-param name="type">task</xsl:with-param>
        <xsl:with-param name="id" select="@id"/>
      </xsl:call-template>
    </td>
  </tr>
</xsl:template>

<!-- GET_TASKS_RESPONSE -->

<xsl:template match="get_tasks_response">
  <xsl:choose>
    <xsl:when test="substring(@status, 1, 1) = '4' or substring(@status, 1, 1) = '5'">
      <xsl:call-template name="command_result_dialog">
        <xsl:with-param name="operation">Get Tasks</xsl:with-param>
        <xsl:with-param name="status">
          <xsl:value-of select="@status"/>
        </xsl:with-param>
        <xsl:with-param name="msg">
          <xsl:value-of select="@status_text"/>
        </xsl:with-param>
      </xsl:call-template>
    </xsl:when>
    <xsl:otherwise>
      <xsl:call-template name="html-tasks-table"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<!-- GET_TASK -->

<xsl:template match="get_task">
  <xsl:apply-templates select="gsad_msg"/>
  <xsl:apply-templates select="commands_response/delete_task_response"/>
  <xsl:apply-templates select="commands_response/get_tasks_response/task"
                       mode="details"/>
</xsl:template>

<!-- GET_TASKS -->

<xsl:template match="get_tasks">
  <xsl:apply-templates select="run_wizard_response"/>
  <xsl:apply-templates select="delete_task_response"/>
  <xsl:apply-templates select="create_filter_response"/>
  <xsl:apply-templates select="create_report_response"/>
  <xsl:apply-templates select="create_task_response"/>
  <xsl:apply-templates select="start_task_response"/>
  <xsl:apply-templates select="stop_task_response"/>
  <xsl:apply-templates select="modify_task_response"/>
  <xsl:apply-templates select="pause_task_response"/>
  <xsl:apply-templates select="resume_task_response"/>
  <xsl:apply-templates select="resume_stopped_task_response"/>
  <xsl:apply-templates select="get_tasks_response"/>
</xsl:template>

<!-- BEGIN LSC_CREDENTIALS MANAGEMENT -->

<xsl:template match="new_lsc_credential">
  <xsl:apply-templates select="gsad_msg"/>
  <xsl:apply-templates select="create_lsc_credential_response"/>
  <xsl:apply-templates select="commands_response/delete_lsc_credential_response"/>
  <xsl:call-template name="html-create-lsc-credential-form"/>
</xsl:template>

<xsl:template name="html-create-lsc-credential-form">
  <div class="gb_window">
    <div class="gb_window_part_left"></div>
    <div class="gb_window_part_right"></div>
    <div class="gb_window_part_center">
      New Credential
      <a href="/help/new_lsc_credential.html?token={/envelope/token}"
         title="Help: New Credential">
        <img src="/img/help.png"/>
      </a>
      <a href="/omp?cmd=get_lsc_credentials&amp;filter={str:encode-uri (/envelope/params/filter, true ())}&amp;filt_id={/envelope/params/filt_id}&amp;token={/envelope/token}"
         title="Credentials" style="margin-left:3px;">
        <img src="/img/list.png" border="0" alt="Credentials"/>
      </a>
    </div>
    <div class="gb_window_part_content">
      <form action="/omp" method="post" enctype="multipart/form-data">
        <input type="hidden" name="token" value="{/envelope/token}"/>
        <input type="hidden" name="cmd" value="create_lsc_credential"/>
        <input type="hidden" name="caller" value="{/envelope/caller}"/>
        <table border="0" cellspacing="0" cellpadding="3" width="100%">
          <tr>
            <td valign="top" width="125">Name</td>
            <td>
              <input type="text" name="name" value="unnamed" size="30"
                     maxlength="80"/>
            </td>
          </tr>
          <tr>
            <td valign="top" width="125">Login</td>
            <td>
              <input type="text" name="credential_login" value="" size="30"
                     maxlength="80"/>
            </td>
          </tr>
          <tr>
            <td valign="top" width="125">Comment (optional)</td>
            <td>
              <input type="text" name="comment" value="" size="30"
                     maxlength="400"/>
            </td>
          </tr>
          <tr>
            <td></td>
            <td>
              <table>
                <tr>
                  <td colspan="3">
                    <label>
                      <input type="radio" name="base" value="gen"/>
                      Autogenerate credential
                    </label>
                  </td>
                </tr>
                <tr>
                  <td colspan="2">
                    <label>
                      <input type="radio" name="base" value="pass" checked="1"/>
                      Password
                    </label>
                  </td>
                  <td>
                    <input type="password" autocomplete="off"
                           name="lsc_password" value="" size="30"
                           maxlength="40"/>
                  </td>
                </tr>
                <tr>
                  <td colspan="3">
                    <label>
                      <input type="radio" name="base" value="key"/>
                      Key pair
                    </label>
                  </td>
                </tr>
                <tr>
                  <td width="45"></td>
                  <td>
                    Public key
                  </td>
                  <td>
                    <input type="file" name="public_key" size="30"/>
                  </td>
                </tr>
                <tr>
                  <td width="45"></td>
                  <td>
                    Private key
                  </td>
                  <td>
                    <input type="file" name="private_key" size="30"/>
                  </td>
                </tr>
                <tr>
                  <td width="45"></td>
                  <td>
                    Passphrase
                  </td>
                  <td>
                    <input type="password" autocomplete="off" name="passphrase"
                           value="" size="30" maxlength="40"/>
                  </td>
                </tr>
              </table>
            </td>
          </tr>
          <tr>
            <td colspan="2" style="text-align:right;">
              <input type="submit" name="submit" value="Create Credential"/>
            </td>
          </tr>
        </table>
      </form>
    </div>
  </div>
</xsl:template>

<xsl:template name="html-lsc-credentials-table">
  <xsl:call-template name="list-window">
    <xsl:with-param name="type" select="'lsc_credential'"/>
    <xsl:with-param name="cap-type" select="'Credential'"/>
    <xsl:with-param name="resources-summary" select="lsc_credentials"/>
    <xsl:with-param name="resources" select="lsc_credential"/>
    <xsl:with-param name="count" select="count (lsc_credential)"/>
    <xsl:with-param name="filtered-count" select="lsc_credential_count/filtered"/>
    <xsl:with-param name="full-count" select="lsc_credential_count/text ()"/>
    <xsl:with-param name="headings" select="'Name|name Login|login'"/>
  </xsl:call-template>
</xsl:template>

<!--     CREATE_LSC_CREDENTIAL_RESPONSE -->

<xsl:template match="create_lsc_credential_response">
  <xsl:call-template name="command_result_dialog">
    <xsl:with-param name="operation">Create Credential</xsl:with-param>
    <xsl:with-param name="status">
      <xsl:value-of select="@status"/>
    </xsl:with-param>
    <xsl:with-param name="msg">
      <xsl:value-of select="@status_text"/>
    </xsl:with-param>
  </xsl:call-template>
</xsl:template>

<!--     DELETE_LSC_CREDENTIAL_RESPONSE -->

<xsl:template match="delete_lsc_credential_response">
  <xsl:call-template name="command_result_dialog">
    <xsl:with-param name="operation">
      Delete Credential
    </xsl:with-param>
    <xsl:with-param name="status">
      <xsl:value-of select="@status"/>
    </xsl:with-param>
    <xsl:with-param name="msg">
      <xsl:value-of select="@status_text"/>
    </xsl:with-param>
  </xsl:call-template>
</xsl:template>

<!--     EDITING LSC CREDENTIALS -->

<xsl:template name="html-edit-lsc-credential-form">
  <div class="gb_window">
    <div class="gb_window_part_left"></div>
    <div class="gb_window_part_right"></div>
    <div class="gb_window_part_center">Edit Credential
      <xsl:call-template name="edit-header-icons">
        <xsl:with-param name="cap-type" select="'Credential'"/>
        <xsl:with-param name="type" select="'lsc_credential'"/>
        <xsl:with-param name="id"
                        select="commands_response/get_lsc_credentials_response/lsc_credential/@id"/>
      </xsl:call-template>
    </div>
    <div class="gb_window_part_content">
      <form action="" method="post">
        <input type="hidden" name="token" value="{/envelope/token}"/>
        <input type="hidden" name="cmd" value="save_lsc_credential"/>
        <input type="hidden" name="caller" value="{/envelope/caller}"/>
        <input type="hidden"
               name="lsc_credential_id"
               value="{commands_response/get_lsc_credentials_response/lsc_credential/@id}"/>
        <input type="hidden" name="next" value="{/envelope/params/next}"/>
        <table border="0" cellspacing="0" cellpadding="3" width="100%">
          <tr>
            <td valign="top" width="165">Name</td>
            <td>
              <input type="text"
                     name="name"
                     value="{commands_response/get_lsc_credentials_response/lsc_credential/name}"
                     size="30"
                     maxlength="80"/>
            </td>
          </tr>
          <tr>
            <td valign="top">Comment</td>
            <td>
              <input type="text" name="comment" size="30" maxlength="400"
                     value="{commands_response/get_lsc_credentials_response/lsc_credential/comment}"/>
            </td>
          </tr>
          <tr>
            <td valign="top">Login</td>
            <td>
              <xsl:choose>
                <xsl:when test="commands_response/get_lsc_credentials_response/lsc_credential/type = 'gen'">
                  <input type="text" name="credential_login_off" size="30" maxlength="400"
                         disabled="1"
                         value="{commands_response/get_lsc_credentials_response/lsc_credential/login}"/>
                </xsl:when>
                <xsl:otherwise>
                  <input type="text" name="credential_login" size="30" maxlength="400"
                         value="{commands_response/get_lsc_credentials_response/lsc_credential/login}"/>
                </xsl:otherwise>
              </xsl:choose>
            </td>
          </tr>
          <tr>
            <td valign="top">Password</td>
            <td>
              <xsl:choose>
                <xsl:when test="commands_response/get_lsc_credentials_response/lsc_credential/type = 'gen'">
                  <label>
                    <input type="checkbox" name="enable_off" value="1"
                           disabled="1"/>
                    Replace existing value with:
                    <br/>
                  </label>
                  <input type="password" name="password" size="30" maxlength="400"
                         disabled="1" value=""/>
                </xsl:when>
                <xsl:otherwise>
                  <label>
                    <input type="checkbox" name="enable" value="1"/>
                    Replace existing value with:
                    <br/>
                  </label>
                  <input type="password" autocomplete="off" name="password"
                         size="30" maxlength="400" value=""/>
                </xsl:otherwise>
              </xsl:choose>
            </td>
          </tr>
          <tr>
            <td colspan="2" style="text-align:right;">
              <input type="submit" name="submit" value="Save Credential"/>
            </td>
          </tr>
        </table>
        <br/>
      </form>
    </div>
  </div>
</xsl:template>

<xsl:template match="edit_lsc_credential">
  <xsl:apply-templates select="gsad_msg"/>
  <xsl:call-template name="html-edit-lsc-credential-form"/>
</xsl:template>

<xsl:template match="modify_lsc_credential_response">
  <xsl:call-template name="command_result_dialog">
    <xsl:with-param name="operation">Save Credential</xsl:with-param>
    <xsl:with-param name="status">
      <xsl:value-of select="@status"/>
    </xsl:with-param>
    <xsl:with-param name="msg">
      <xsl:value-of select="@status_text"/>
    </xsl:with-param>
  </xsl:call-template>
</xsl:template>

<!--     LSC_CREDENTIAL -->

<xsl:template name="lsc-credential-download-icons">
  <a href="/omp?cmd=download_lsc_credential&amp;lsc_credential_id={@id}&amp;package_format=rpm&amp;token={/envelope/token}"
     title="Download RPM package" style="margin-left:3px;">
    <img src="/img/rpm.png" border="0" alt="Download RPM"/>
  </a>
  <a href="/omp?cmd=download_lsc_credential&amp;lsc_credential_id={@id}&amp;package_format=deb&amp;token={/envelope/token}"
     title="Download Debian package" style="margin-left:3px;">
    <img src="/img/deb.png" border="0" alt="Download Deb"/>
  </a>
  <a href="/omp?cmd=download_lsc_credential&amp;lsc_credential_id={@id}&amp;package_format=exe&amp;token={/envelope/token}"
     title="Download Exe package" style="margin-left:3px;">
    <img src="/img/exe.png" border="0" alt="Download Exe"/>
  </a>
  <a href="/omp?cmd=download_lsc_credential&amp;lsc_credential_id={@id}&amp;package_format=key&amp;token={/envelope/token}"
     title="Download Public Key" style="margin-left:3px;">
    <img src="/img/key.png" border="0" alt="Download Public Key"/>
  </a>
</xsl:template>

<xsl:template match="lsc_credential">
  <xsl:variable name="class">
    <xsl:choose>
      <xsl:when test="position() mod 2 = 0">even</xsl:when>
      <xsl:otherwise>odd</xsl:otherwise>
    </xsl:choose>
  </xsl:variable>
  <tr class="{$class}">
    <td>
      <b>
        <a href="/omp?cmd=get_lsc_credential&amp;lsc_credential_id={@id}&amp;filter={str:encode-uri (../filters/term, true ())}&amp;token={/envelope/token}">
          <xsl:value-of select="name"/>
        </a>
      </b>
      <xsl:choose>
        <xsl:when test="comment != ''">
          <br/>(<xsl:value-of select="comment"/>)
        </xsl:when>
        <xsl:otherwise></xsl:otherwise>
      </xsl:choose>
    </td>
    <td>
      <xsl:value-of select="login"/>
    </td>
    <td>
      <xsl:call-template name="list-window-line-icons">
        <xsl:with-param name="cap-type" select="'Credential'"/>
        <xsl:with-param name="type" select="'lsc_credential'"/>
        <xsl:with-param name="id" select="@id"/>
      </xsl:call-template>
      <xsl:if test="type='gen'">
        <xsl:call-template name="lsc-credential-download-icons"/>
      </xsl:if>
    </td>
  </tr>
</xsl:template>

<xsl:template match="lsc_credential" mode="trash">
  <xsl:variable name="class">
    <xsl:choose>
      <xsl:when test="position() mod 2 = 0">even</xsl:when>
      <xsl:otherwise>odd</xsl:otherwise>
    </xsl:choose>
  </xsl:variable>
  <tr class="{$class}">
    <td>
      <b><xsl:value-of select="name"/></b>
    </td>
    <td>
      <xsl:value-of select="login"/>
    </td>
    <td>
      <xsl:value-of select="comment"/>
    </td>
    <td>
      <xsl:call-template name="restore-icon">
        <xsl:with-param name="id" select="@id"/>
      </xsl:call-template>
      <xsl:choose>
        <xsl:when test="in_use='0'">
          <xsl:call-template name="trash-delete-icon">
            <xsl:with-param name="type">lsc_credential</xsl:with-param>
            <xsl:with-param name="id" select="@id"/>
          </xsl:call-template>
        </xsl:when>
        <xsl:otherwise>
          <img src="/img/delete_inactive.png" border="0" alt="Delete"
               style="margin-left:3px;"/>
        </xsl:otherwise>
      </xsl:choose>
    </td>
  </tr>
</xsl:template>

<xsl:template match="lsc_credential" mode="details">
  <div class="gb_window">
    <div class="gb_window_part_left"></div>
    <div class="gb_window_part_right"></div>
    <div class="gb_window_part_center">
      Credential Details
      <xsl:call-template name="details-header-icons">
        <xsl:with-param name="cap-type" select="'Credential'"/>
        <xsl:with-param name="type" select="'lsc_credential'"/>
      </xsl:call-template>
      <xsl:if test="type='gen'">
        <xsl:call-template name="lsc-credential-download-icons"/>
      </xsl:if>
    </div>
    <div class="gb_window_part_content">
      <xsl:call-template name="minor-details"/>
      <table>
        <tr>
          <td><b>Name:</b></td>
          <td><b><xsl:value-of select="name"/></b></td>
        </tr>
        <tr>
          <td>Comment:</td>
          <td><xsl:value-of select="comment"/></td>
        </tr>
        <tr>
          <td>Login:</td>
          <td><xsl:value-of select="login"/></td>
        </tr>
      </table>

      <xsl:choose>
        <xsl:when test="count(targets/target) = 0">
          <h1>Targets using this Credential: None</h1>
        </xsl:when>
        <xsl:otherwise>
          <h1>Targets using this Credential</h1>
          <table class="gbntable" cellspacing="2" cellpadding="4">
            <tr class="gbntablehead2">
              <td>Name</td>
              <td>Actions</td>
            </tr>
            <xsl:for-each select="targets/target">
              <xsl:variable name="class">
                <xsl:choose>
                  <xsl:when test="position() mod 2 = 0">even</xsl:when>
                  <xsl:otherwise>odd</xsl:otherwise>
                </xsl:choose>
              </xsl:variable>
              <tr class="{$class}">
                <td><xsl:value-of select="name"/></td>
                <td width="100">
                  <a href="/omp?cmd=get_target&amp;target_id={@id}&amp;token={/envelope/token}"
                     title="Target Details">
                    <img src="/img/details.png"
                         border="0"
                         alt="Details"
                         style="margin-left:3px;"/>
                  </a>
                </td>
              </tr>
            </xsl:for-each>
          </table>
        </xsl:otherwise>
      </xsl:choose>
    </div>
  </div>
</xsl:template>

<!--     GET_LSC_CREDENTIAL -->

<xsl:template match="get_lsc_credential">
  <xsl:apply-templates select="gsad_msg"/>
  <xsl:apply-templates select="commands_response/delete_lsc_credential_response"/>
  <xsl:apply-templates select="commands_response/modify_lsc_credential_response"/>
  <xsl:apply-templates select="get_lsc_credentials_response/lsc_credential"
                       mode="details"/>
</xsl:template>

<!--     GET_LSC_CREDENTIALS_RESPONSE -->

<xsl:template match="get_lsc_credentials_response">
  <xsl:apply-templates select="gsad_msg"/>
  <xsl:apply-templates select="delete_lsc_credential_response"/>
  <xsl:call-template name="html-lsc-credentials-table"/>
</xsl:template>

<xsl:template match="lsc_credential" mode="select">
  <option value="{@id}"><xsl:value-of select="name"/></option>
</xsl:template>

<xsl:template match="lsc_credentials_response" mode="select">
  <xsl:apply-templates select="lsc_credential" mode="select"/>
</xsl:template>

<!-- END LSC_CREDENTIALS MANAGEMENT -->

<!-- BEGIN AGENTS MANAGEMENT -->

<xsl:template name="html-create-agent-form">
  <div class="gb_window">
    <div class="gb_window_part_left"></div>
    <div class="gb_window_part_right"></div>
    <div class="gb_window_part_center">
      New Agent
      <a href="/help/new_agent.html?token={/envelope/token}"
         title="Help: New Agent">
        <img src="/img/help.png"/>
      </a>
      <a href="/omp?cmd=get_agents&amp;filter={str:encode-uri (/envelope/params/filter, true ())}&amp;filt_id={/envelope/params/filt_id}&amp;token={/envelope/token}"
         title="Agents" style="margin-left:3px;">
        <img src="/img/list.png" border="0" alt="Agents"/>
      </a>
    </div>
    <div class="gb_window_part_content">
      <form action="/omp" method="post" enctype="multipart/form-data">
        <input type="hidden" name="token" value="{/envelope/token}"/>
        <input type="hidden" name="cmd" value="create_agent"/>
        <input type="hidden" name="caller" value="{/envelope/caller}"/>
        <table border="0" cellspacing="0" cellpadding="3" width="100%">
          <tr>
            <td valign="top" width="125">Name</td>
            <td>
              <input type="text" name="name" value="unnamed" size="30"
                     maxlength="80"/>
            </td>
          </tr>
          <tr>
            <td valign="top" width="125">Comment (optional)</td>
            <td>
              <input type="text" name="comment" size="30" maxlength="400"/>
            </td>
          </tr>
          <tr>
            <td valign="top" width="125">Installer</td>
            <td><input type="file" name="installer" size="30"/></td>
          </tr>
          <tr>
            <td valign="top" width="125">Installer signature (optional)</td>
            <td><input type="file" name="installer_sig" size="30"/></td>
          </tr>
          <!--
          <tr>
            <td valign="top" width="125">Howto Install</td>
            <td><input type="file" name="howto_install" size="30"/></td>
          </tr>
          <tr>
            <td valign="top" width="125">Howto Use</td>
            <td><input type="file" name="howto_use" size="30"/></td>
          </tr>
          -->
          <tr>
            <td colspan="2" style="text-align:right;">
              <input type="submit" name="submit" value="Create Agent"/>
            </td>
          </tr>
        </table>
      </form>
    </div>
  </div>
</xsl:template>

<xsl:template match="new_agent">
  <xsl:apply-templates select="gsad_msg"/>
  <xsl:apply-templates select="create_agent_response"/>
  <xsl:apply-templates select="commands_response/delete_agent_response"/>
  <xsl:call-template name="html-create-agent-form"/>
</xsl:template>

<xsl:template name="html-agents-table">
  <xsl:call-template name="list-window">
    <xsl:with-param name="type" select="'agent'"/>
    <xsl:with-param name="cap-type" select="'Agent'"/>
    <xsl:with-param name="resources-summary" select="agents"/>
    <xsl:with-param name="resources" select="agent"/>
    <xsl:with-param name="count" select="count (agent)"/>
    <xsl:with-param name="filtered-count" select="agent_count/filtered"/>
    <xsl:with-param name="full-count" select="agent_count/text ()"/>
    <xsl:with-param name="headings" select="'Name|name Trust|trust'"/>
  </xsl:call-template>
</xsl:template>

<!--     EDIT_AGENT -->

<xsl:template name="html-edit-agent-form">
  <div class="gb_window">
    <div class="gb_window_part_left"></div>
    <div class="gb_window_part_right"></div>
    <div class="gb_window_part_center">Edit Agent
      <xsl:call-template name="edit-header-icons">
        <xsl:with-param name="cap-type" select="'Agent'"/>
        <xsl:with-param name="type" select="'agent'"/>
        <xsl:with-param name="id"
                        select="commands_response/get_agents_response/agent/@id"/>
      </xsl:call-template>
    </div>
    <div class="gb_window_part_content">
      <form action="" method="post" enctype="multipart/form-data">
        <input type="hidden" name="token" value="{/envelope/token}"/>
        <input type="hidden" name="cmd" value="save_agent"/>
        <input type="hidden" name="caller" value="{/envelope/caller}"/>
        <input type="hidden"
               name="agent_id"
               value="{commands_response/get_agents_response/agent/@id}"/>
        <input type="hidden" name="next" value="{/envelope/params/next}"/>
        <input type="hidden" name="agent" value="{/envelope/params/agent}"/>
        <input type="hidden" name="filt_id" value="{/envelope/params/filt_id}"/>
        <table border="0" cellspacing="0" cellpadding="3" width="100%">
          <tr>
            <td valign="top" width="165">Name</td>
            <td>
              <input type="text" name="name" size="30" maxlength="80"
                     value="{commands_response/get_agents_response/agent/name}"/>
            </td>
          </tr>
          <tr>
            <td valign="top" width="165">Comment (optional)</td>
            <td>
              <input type="text" name="comment" size="30" maxlength="400"
                     value="{commands_response/get_agents_response/agent/comment}"/>
            </td>
          </tr>
          <tr>
            <td colspan="2" style="text-align:right;">
              <input type="submit" name="submit" value="Save Agent"/>
            </td>
          </tr>
        </table>
        <br/>
      </form>
    </div>
  </div>
</xsl:template>

<xsl:template match="edit_agent">
  <xsl:apply-templates select="gsad_msg"/>
  <xsl:call-template name="html-edit-agent-form"/>
</xsl:template>

<!--     CREATE_AGENT_RESPONSE -->

<xsl:template match="create_agent_response">
  <xsl:call-template name="command_result_dialog">
    <xsl:with-param name="operation">Create Agent</xsl:with-param>
    <xsl:with-param name="status">
      <xsl:value-of select="@status"/>
    </xsl:with-param>
    <xsl:with-param name="msg">
      <xsl:value-of select="@status_text"/>
    </xsl:with-param>
  </xsl:call-template>
</xsl:template>

<!--     DELETE_AGENT_RESPONSE -->

<xsl:template match="delete_agent_response">
  <xsl:call-template name="command_result_dialog">
    <xsl:with-param name="operation">
      Delete Agent
    </xsl:with-param>
    <xsl:with-param name="status">
      <xsl:value-of select="@status"/>
    </xsl:with-param>
    <xsl:with-param name="msg">
      <xsl:value-of select="@status_text"/>
    </xsl:with-param>
  </xsl:call-template>
</xsl:template>

<!--     MODIFY_AGENT_RESPONSE -->

<xsl:template match="modify_agent_response">
  <xsl:call-template name="command_result_dialog">
    <xsl:with-param name="operation">Save Agent</xsl:with-param>
    <xsl:with-param name="status">
      <xsl:value-of select="@status"/>
    </xsl:with-param>
    <xsl:with-param name="msg">
      <xsl:value-of select="@status_text"/>
    </xsl:with-param>
  </xsl:call-template>
</xsl:template>

<!--     AGENT -->

<xsl:template match="agent">
  <xsl:variable name="class">
    <xsl:choose>
      <xsl:when test="position() mod 2 = 0">even</xsl:when>
      <xsl:otherwise>odd</xsl:otherwise>
    </xsl:choose>
  </xsl:variable>
  <tr class="{$class}">
    <td>
      <b>
        <a href="/omp?cmd=get_agent&amp;agent_id={@id}&amp;filter={str:encode-uri (../filters/term, true ())}&amp;token={/envelope/token}">
          <xsl:value-of select="name"/>
        </a>
      </b>
      <xsl:choose>
        <xsl:when test="comment != ''">
          <br/>(<xsl:value-of select="comment"/>)
        </xsl:when>
        <xsl:otherwise></xsl:otherwise>
      </xsl:choose>
    </td>
    <td>
      <xsl:value-of select="installer/trust/text()"/>
      <xsl:choose>
        <xsl:when test="installer/trust/time != ''">
          (<xsl:value-of select="concat (date:month-abbreviation (installer/trust/time), ' ', date:day-in-month (installer/trust/time), ' ', date:year (installer/trust/time))"/>)
        </xsl:when>
        <xsl:otherwise></xsl:otherwise>
      </xsl:choose>
    </td>
    <td>
      <xsl:call-template name="list-window-line-icons">
        <xsl:with-param name="cap-type" select="'Agent'"/>
        <xsl:with-param name="type" select="'agent'"/>
        <xsl:with-param name="id" select="@id"/>
      </xsl:call-template>
      <a href="/omp?cmd=download_agent&amp;agent_id={@id}&amp;agent_format=installer&amp;token={/envelope/token}"
         title="Download installer package" style="margin-left:3px;">
        <img src="/img/agent.png" border="0" alt="Download Installer"/>
      </a>
      <a href="/omp?cmd=verify_agent&amp;agent_id={@id}&amp;token={/envelope/token}&amp;filter={str:encode-uri (/envelope/params/filter, true ())}&amp;filt_id={/envelope/params/filt_id}"
         title="Verify Agent"
         style="margin-left:3px;">
        <img src="/img/verify.png" border="0" alt="Verify Agent"/>
      </a>
    </td>
  </tr>
</xsl:template>

<xsl:template match="agent" mode="trash">
  <xsl:variable name="class">
    <xsl:choose>
      <xsl:when test="position() mod 2 = 0">even</xsl:when>
      <xsl:otherwise>odd</xsl:otherwise>
    </xsl:choose>
  </xsl:variable>
  <tr class="{$class}">
    <td>
      <b><xsl:value-of select="name"/></b>
      <xsl:choose>
        <xsl:when test="comment != ''">
          <br/>(<xsl:value-of select="comment"/>)
        </xsl:when>
        <xsl:otherwise></xsl:otherwise>
      </xsl:choose>
    </td>
    <td>
      <xsl:value-of select="installer/trust/text()"/>
      <xsl:choose>
        <xsl:when test="installer/trust/time != ''">
          <br/>(<xsl:value-of select="concat (date:month-abbreviation (installer/trust/time), ' ', date:day-in-month (installer/trust/time), ' ', date:year (installer/trust/time))"/>)
        </xsl:when>
        <xsl:otherwise></xsl:otherwise>
      </xsl:choose>
    </td>
    <td>
      <xsl:call-template name="restore-icon">
        <xsl:with-param name="id" select="@id"/>
      </xsl:call-template>
      <xsl:call-template name="trash-delete-icon">
        <xsl:with-param name="type" select="'agent'"/>
        <xsl:with-param name="id" select="@id"/>
      </xsl:call-template>
    </td>
  </tr>
</xsl:template>

<xsl:template match="agent" mode="details">
  <div class="gb_window">
    <div class="gb_window_part_left"></div>
    <div class="gb_window_part_right"></div>
    <div class="gb_window_part_center">
       Agent Details
      <xsl:call-template name="details-header-icons">
        <xsl:with-param name="cap-type" select="'Agent'"/>
        <xsl:with-param name="type" select="'agent'"/>
      </xsl:call-template>
    </div>
    <div class="gb_window_part_content">
      <xsl:call-template name="minor-details"/>
      <table>
        <tr>
          <td><b>Name:</b></td>
          <td><b><xsl:value-of select="name"/></b></td>
        </tr>
        <tr>
          <td>Comment:</td>
          <td><xsl:value-of select="comment"/></td>
        </tr>
        <tr>
          <td>Trust:</td>
          <td>
            <xsl:value-of select="installer/trust/text()"/>
            <xsl:choose>
              <xsl:when test="installer/trust/time != ''">
                (<xsl:value-of select="concat (date:month-abbreviation (installer/trust/time), ' ', date:day-in-month (installer/trust/time), ' ', date:year (installer/trust/time))"/>)
              </xsl:when>
              <xsl:otherwise></xsl:otherwise>
            </xsl:choose>
        </td>
        </tr>
      </table>
    </div>
  </div>
</xsl:template>

<!--     GET_AGENT -->

<xsl:template match="get_agent">
  <xsl:apply-templates select="gsad_msg"/>
  <xsl:apply-templates select="commands_response/delete_agent_response"/>
  <xsl:apply-templates select="modify_agent_response"/>
  <xsl:apply-templates select="get_agents_response/agent" mode="details"/>
</xsl:template>

<!--     GET_AGENTS_RESPONSE -->

<xsl:template match="get_agents_response">
  <xsl:apply-templates select="modify_agent_response"/>
  <xsl:choose>
    <xsl:when test="substring(@status, 1, 1) = '4' or substring(@status, 1, 1) = '5'">
      <xsl:call-template name="command_result_dialog">
        <xsl:with-param name="operation">
          Get Agents
        </xsl:with-param>
        <xsl:with-param name="status">
          <xsl:value-of select="@status"/>
        </xsl:with-param>
        <xsl:with-param name="msg">
          <xsl:value-of select="@status_text"/>
        </xsl:with-param>
      </xsl:call-template>
    </xsl:when>
    <xsl:otherwise>
      <xsl:call-template name="html-agents-table"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template match="agent" mode="select">
  <option value="{name}"><xsl:value-of select="name"/></option>
</xsl:template>

<xsl:template match="agents_response" mode="select">
  <xsl:apply-templates select="agent" mode="select"/>
</xsl:template>

<!-- END AGENTS MANAGEMENT -->

<!-- BEGIN ALERTS MANAGEMENT -->

<xsl:template name="html-create-alert-form">
  <xsl:param name="report-formats"></xsl:param>
  <xsl:param name="filters"/>
  <div class="gb_window">
    <div class="gb_window_part_left"></div>
    <div class="gb_window_part_right"></div>
    <div class="gb_window_part_center">New Alert
      <a href="/help/new_alert.html?token={/envelope/token}"
         title="Help: New Alert">
        <img src="/img/help.png"/>
      </a>
      <a href="/omp?cmd=get_alerts&amp;filter={str:encode-uri (/envelope/params/filter, true ())}&amp;filt_id={/envelope/params/filt_id}&amp;token={/envelope/token}"
         title="Alerts" style="margin-left:3px;">
        <img src="/img/list.png" border="0" alt="Alerts"/>
      </a>
    </div>
    <div class="gb_window_part_content">
      <form action="/omp" method="post" enctype="multipart/form-data">
        <input type="hidden" name="token" value="{/envelope/token}"/>
        <input type="hidden" name="cmd" value="create_alert"/>
        <input type="hidden" name="caller" value="{/envelope/caller}"/>
        <table border="0" cellspacing="0" cellpadding="3" width="100%">
          <tr class="odd">
            <td valign="top" width="145">Name</td>
            <td>
              <input type="text" name="name" value="unnamed" size="30"
                     maxlength="80"/>
            </td>
          </tr>
          <tr class="even">
            <td valign="top" width="145">Comment (optional)</td>
            <td>
              <input type="text" name="comment" size="30" maxlength="400"/>
            </td>
          </tr>
          <tr class="odd">
            <td valign="top" width="145">Event</td>
            <td colspan="2">
              <table border="0" width="100%">
                <tr>
                  <td colspan="2" valign="top">
                    <label>
                      <input type="radio" name="event" value="Task run status changed" checked="1"/>
                      Task run status changed to
                    </label>
                    <select name="event_data:status">
                      <option value="Delete Requested">Delete Requested</option>
                      <option value="Done" selected="1">Done</option>
                      <option value="New">New</option>
                      <option value="Requested">Requested</option>
                      <option value="Running">Running</option>
                      <option value="Stop Requested">Stop Requested</option>
                      <option value="Stopped">Stopped</option>
                    </select>
                  </td>
                </tr>
              </table>
            </td>
          </tr>
          <tr class="even">
            <td valign="top" width="125">Condition</td>
            <td colspan="2">
              <table border="0" width="100%">
                <tr>
                  <td colspan="2" valign="top">
                    <label>
                      <input type="radio" name="condition" value="Always" checked="1"/>
                      Always
                    </label>
                  </td>
                </tr>
                <tr>
                  <td colspan="2" valign="top">
                    <label>
                      <input type="radio" name="condition" value="Threat level at least"/>
                      Threat level is at least
                    </label>
                    <select name="condition_data:level">
                      <option value="High" selected="1">High</option>
                      <option value="Medium">Medium</option>
                      <option value="Low">Low</option>
                      <option value="Log">Log</option>
                    </select>
                  </td>
                </tr>
                <tr>
                  <td colspan="2" valign="top">
                    <label>
                      <input type="radio" name="condition" value="Threat level changed"/>
                      Threat level
                    </label>
                    <select name="condition_data:direction">
                      <option value="changed" selected="1">changed</option>
                      <option value="increased">increased</option>
                      <option value="decreased">decreased</option>
                    </select>
                  </td>
                </tr>
              </table>
            </td>
          </tr>
          <tr class="odd">
            <td valign="top" width="145">Method</td>
            <td colspan="2">
              <table border="0" width="100%">
                <tr>
                  <td colspan="3" valign="top">
                    <label>
                      <input type="radio" name="method" value="Email" checked="1"/>
                      Email
                    </label>
                  </td>
                </tr>
                <tr>
                  <td width="45"></td>
                  <td width="150">To Address</td>
                  <td>
                    <input type="text" name="method_data:to_address" size="30" maxlength="301"/>
                  </td>
                </tr>
                <tr>
                  <td width="45"></td>
                  <td width="150">From Address</td>
                  <td>
                    <input type="text" name="method_data:from_address" size="30" maxlength="301"/>
                  </td>
                </tr>
                <tr>
                  <td width="45"></td>
                  <td width="150">Content</td>
                  <td>
                    <table>
                      <tr>
                        <td colspan="3" valign="top">
                          <label>
                            <input type="radio" name="method_data:notice" value="1" checked="1"/>
                            Simple notice
                          </label>
                        </td>
                      </tr>
                      <tr>
                        <td colspan="3" valign="top">
                          <label>
                            <input type="radio" name="method_data:notice" value="0"/>
                            Include report
                          </label>
                          <select name="method_data:notice_report_format">
                            <xsl:for-each select="$report-formats/report_format">
                              <xsl:if test="substring(content_type, 1, 5) = 'text/'">
                                <xsl:choose>
                                  <xsl:when test="@id='19f6f1b3-7128-4433-888c-ccc764fe6ed5'">
                                    <option value="{@id}" selected="1">
                                      <xsl:value-of select="name"/>
                                    </option>
                                  </xsl:when>
                                  <xsl:otherwise>
                                    <option value="{@id}">
                                      <xsl:value-of select="name"/>
                                    </option>
                                  </xsl:otherwise>
                                </xsl:choose>
                              </xsl:if>
                            </xsl:for-each>
                          </select>
                        </td>
                      </tr>
                      <tr>
                        <td colspan="3" valign="top">
                          <label>
                            <input type="radio" name="method_data:notice" value="2"/>
                            Attach report
                          </label>
                          <select name="method_data:notice_attach_format">
                            <xsl:for-each select="$report-formats/report_format">
                              <xsl:choose>
                                <xsl:when test="@id='1a60a67e-97d0-4cbf-bc77-f71b08e7043d'">
                                  <option value="{@id}" selected="1">
                                    <xsl:value-of select="name"/>
                                  </option>
                                </xsl:when>
                                <xsl:otherwise>
                                  <option value="{@id}">
                                    <xsl:value-of select="name"/>
                                  </option>
                                </xsl:otherwise>
                              </xsl:choose>
                            </xsl:for-each>
                          </select>
                        </td>
                      </tr>
                    </table>
                  </td>
                </tr>
              </table>
            </td>
          </tr>
          <tr class="odd">
            <td valign="top" width="125"></td>
            <td colspan="2">
              <table border="0" width="100%">
                <tr>
                  <td colspan="2" valign="top">
                    <label width="250">
                      <input type="radio" name="method" value="syslog"/>
                      System Logger
                    </label>
                    <select margin="50" name="method_data:submethod">
                      <option value="syslog" selected="1">syslog</option>
                      <option value="SNMP">SNMP</option>
                    </select>
                  </td>
                </tr>
              </table>
            </td>
          </tr>
          <tr class="odd">
            <td valign="top" width="125"></td>
            <td colspan="2">
              <table border="0" width="100%">
                <tr>
                  <td colspan="3" valign="top">
                    <label>
                      <input type="radio" name="method" value="HTTP Get"/>
                      HTTP Get
                    </label>
                  </td>
                </tr>
                <tr>
                  <td width="45"></td>
                  <td width="150">URL</td>
                  <td>
                    <input type="text" name="method_data:URL" size="30" maxlength="301"/>
                  </td>
                </tr>
              </table>
            </td>
          </tr>
          <tr class="odd">
            <td valign="top" width="125"></td>
            <td colspan="2">
              <table border="0" width="100%">
                <tr>
                  <td colspan="3" valign="top">
                    <label>
                      <input type="radio" name="method" value="Sourcefire Connector"/>
                      Sourcefire Connector
                    </label>
                  </td>
                </tr>
                <tr>
                  <td width="45"></td>
                  <td width="150">Defense Center IP</td>
                  <td>
                    <input type="text" name="method_data:defense_center_ip"
                           size="30" maxlength="40"/>
                  </td>
                </tr>
                <tr>
                  <td width="45"></td>
                  <td width="150">Defense Center Port</td>
                  <td>
                    <input type="text" name="method_data:defense_center_port"
                           size="30" maxlength="400" value="8307"/>
                  </td>
                </tr>
                <tr>
                  <td width="45"></td>
                  <td width="150">PKCS12 file</td>
                  <td>
                    <input type="file" name="method_data:pkcs12" size="30"/>
                  </td>
                </tr>
              </table>
            </td>
          </tr>
          <tr class="odd">
            <td valign="top" width="125"></td>
            <td colspan="2">
              <table border="0" width="100%">
                <tr>
                  <td colspan="3" valign="top">
                    <label>
                      <input type="radio" name="method" value="verinice Connector"/>
                      verinice.PRO Connector
                    </label>
                  </td>
                </tr>
                <tr>
                  <td width="45"></td>
                  <td width="150">verinice.PRO URL</td>
                  <td>
                    <input type="text" name="method_data:verinice_server_url"
                           size="30" maxlength="256"/>
                  </td>
                </tr>
                <tr>
                  <td width="45"></td>
                  <td width="150">verinice.PRO Username</td>
                  <td>
                    <input type="text" name="method_data:verinice_server_username"
                           size="30" maxlength="40"/>
                  </td>
                </tr>
                <tr>
                  <td width="45"></td>
                  <td width="150">verinice.PRO Password</td>
                  <td>
                    <input type="password" name="method_data:verinice_server_password"
                           size="30" maxlength="40"/>
                  </td>
                </tr>
              </table>
            </td>
          </tr>
          <tr>
            <td valign="top" width="145">Report Filter (optional)</td>
            <td colspan="2">
              <select name="filter_id">
                <option value="0">--</option>
                <xsl:for-each select="$filters/filter">
                  <option value="{@id}"><xsl:value-of select="name"/></option>
                </xsl:for-each>
              </select>
            </td>
          </tr>
          <tr class="even">
            <td colspan="2" style="text-align:right;">
              <input type="submit" name="submit" value="Create Alert"/>
            </td>
          </tr>
        </table>
      </form>
    </div>
  </div>
</xsl:template>

<xsl:template match="new_alert">
  <xsl:apply-templates select="gsad_msg"/>
  <xsl:apply-templates select="create_alert_response"/>
  <xsl:apply-templates select="commands_response/delete_alert_response"/>
  <xsl:call-template name="html-create-alert-form">
    <xsl:with-param
      name="report-formats"
      select="get_report_formats_response | commands_response/get_report_formats_response"/>
    <xsl:with-param
      name="filters"
      select="get_filters_response | commands_response/get_filters_response"/>
  </xsl:call-template>
</xsl:template>

<xsl:template name="html-alerts-table">
  <xsl:call-template name="list-window">
    <xsl:with-param name="type" select="'alert'"/>
    <xsl:with-param name="cap-type" select="'Alert'"/>
    <xsl:with-param name="resources-summary" select="alerts"/>
    <xsl:with-param name="resources" select="alert"/>
    <xsl:with-param name="count" select="count (alert)"/>
    <xsl:with-param name="filtered-count" select="alert_count/filtered"/>
    <xsl:with-param name="full-count" select="alert_count/text ()"/>
    <xsl:with-param name="headings" select="'Name|name Event|event Condition|condition Method|method Filter|filter'"/>
  </xsl:call-template>
</xsl:template>

<xsl:template name="radio-button">
  <xsl:param name="name"></xsl:param>
  <xsl:param name="value"></xsl:param>
  <xsl:param name="text"></xsl:param>
  <xsl:param name="select-value"></xsl:param>
  <label>
  <xsl:choose>
    <xsl:when test="$value = $select-value">
        <input type="radio" name="{$name}" checked="1" value="{$value}"/>
    </xsl:when>
    <xsl:otherwise>
        <input type="radio" name="{$name}" value="{$value}"/>
    </xsl:otherwise>
  </xsl:choose>
  <xsl:choose>
    <xsl:when test="$text">
      <xsl:value-of select="$text"/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="$value"/>
    </xsl:otherwise>
  </xsl:choose>

  </label>
</xsl:template>

<xsl:template name="html-edit-alert-form">
  <xsl:param name="report-formats"></xsl:param>
  <xsl:param name="filters"/>
  <div class="gb_window">
    <div class="gb_window_part_left"></div>
    <div class="gb_window_part_right"></div>
    <div class="gb_window_part_center">Edit Alert
      <xsl:call-template name="edit-header-icons">
        <xsl:with-param name="cap-type" select="'Alert'"/>
        <xsl:with-param name="type" select="'alert'"/>
        <xsl:with-param name="id"
                        select="commands_response/get_alerts_response/alert/@id"/>
      </xsl:call-template>
    </div>
    <div class="gb_window_part_content">
      <form action="" method="post" enctype="multipart/form-data">
        <input type="hidden" name="token" value="{/envelope/token}"/>
        <input type="hidden" name="cmd" value="save_alert"/>
        <input type="hidden" name="caller" value="{/envelope/caller}"/>
        <input type="hidden"
               name="alert_id"
               value="{commands_response/get_alerts_response/alert/@id}"/>
        <input type="hidden" name="next" value="{/envelope/params/next}"/>
        <input type="hidden" name="alert" value="{/envelope/params/alert}"/>
        <input type="hidden" name="filt_id" value="{/envelope/params/filt_id}"/>
        <table border="0" cellspacing="0" cellpadding="3" width="100%">
          <tr class="odd">
            <td valign="top" width="165">Name</td>
            <td>
              <input type="text" name="name" size="30" maxlength="80"
                     value="{commands_response/get_alerts_response/alert/name}"/>
            </td>
          </tr>
          <tr class="even">
            <td valign="top" width="165">Comment (optional)</td>
            <td>
              <input type="text" name="comment" size="30" maxlength="400"
                     value="{commands_response/get_alerts_response/alert/comment}"/>
            </td>
          </tr>
          <tr class="odd">
            <td valign="top" width="145">Event</td>
            <td colspan="2">
              <table border="0" width="100%">
                <tr>
                  <td colspan="2" valign="top">
                    <label>
                      <input type="radio" name="event" value="Task run status changed" checked="1"/>
                      Task run status changed to
                    </label>
                    <xsl:variable name="eventdata"
                                  select="commands_response/get_alerts_response/alert/event/data/text()"/>
                    <select name="event_data:status">
                      <xsl:call-template name="opt">
                        <xsl:with-param name="value" select="'Delete Requested'"/>
                        <xsl:with-param name="select-value" select="$eventdata"/>
                      </xsl:call-template>
                      <xsl:call-template name="opt">
                        <xsl:with-param name="value" select="'Done'"/>
                        <xsl:with-param name="select-value" select="$eventdata"/>
                      </xsl:call-template>
                      <xsl:call-template name="opt">
                        <xsl:with-param name="value" select="'New'"/>
                        <xsl:with-param name="select-value" select="$eventdata"/>
                      </xsl:call-template>
                      <xsl:call-template name="opt">
                        <xsl:with-param name="value" select="'Requested'"/>
                        <xsl:with-param name="select-value" select="$eventdata"/>
                      </xsl:call-template>
                      <xsl:call-template name="opt">
                        <xsl:with-param name="value" select="'Running'"/>
                        <xsl:with-param name="select-value" select="$eventdata"/>
                      </xsl:call-template>
                      <xsl:call-template name="opt">
                        <xsl:with-param name="value" select="'Stop Requested'"/>
                        <xsl:with-param name="select-value" select="$eventdata"/>
                      </xsl:call-template>
                      <xsl:call-template name="opt">
                        <xsl:with-param name="value" select="'Stopped'"/>
                        <xsl:with-param name="select-value" select="$eventdata"/>
                      </xsl:call-template>
                    </select>
                  </td>
                </tr>
              </table>
            </td>
          </tr>
          <tr class="even">
            <xsl:variable name="condition"
                          select="commands_response/get_alerts_response/alert/condition"/>
            <td valign="top" width="125">Condition</td>
            <td colspan="2">
              <table border="0" width="100%">
                <tr>
                  <td colspan="2" valign="top">
                    <xsl:call-template name="radio-button">
                      <xsl:with-param name="value" select="'Always'"/>
                      <xsl:with-param name="select-value" select="$condition/text()"/>
                      <xsl:with-param name="name" select="'condition'"/>
                    </xsl:call-template>
                  </td>
                </tr>
                <tr>
                  <td colspan="2" valign="top">
                    <xsl:call-template name="radio-button">
                      <xsl:with-param name="value" select="'Threat level at least'"/>
                      <xsl:with-param name="select-value" select="$condition/text()"/>
                      <xsl:with-param name="name" select="'condition'"/>
                    </xsl:call-template>
                    <select name="condition_data:level">
                      <xsl:call-template name="opt">
                        <xsl:with-param name="value" select="'High'"/>
                        <xsl:with-param name="select-value" select="$condition/data/text()"/>
                      </xsl:call-template>
                      <xsl:call-template name="opt">
                        <xsl:with-param name="value" select="'Meduim'"/>
                        <xsl:with-param name="select-value" select="$condition/data/text()"/>
                      </xsl:call-template>
                      <xsl:call-template name="opt">
                        <xsl:with-param name="value" select="'Low'"/>
                        <xsl:with-param name="select-value" select="$condition/data/text()"/>
                      </xsl:call-template>
                      <xsl:call-template name="opt">
                        <xsl:with-param name="value" select="'Log'"/>
                        <xsl:with-param name="select-value" select="$condition/data/text()"/>
                      </xsl:call-template>
                    </select>
                  </td>
                </tr>
                <tr>
                  <td colspan="2" valign="top">
                    <xsl:call-template name="radio-button">
                      <xsl:with-param name="name" select="'condition'"/>
                      <xsl:with-param name="value" select="'Threat level changed'"/>
                      <xsl:with-param name="select-value" select="$condition/text()"/>
                      <xsl:with-param name="text" select="'Threat level'"/>
                    </xsl:call-template>
                    <select name="condition_data:direction">
                      <xsl:call-template name="opt">
                        <xsl:with-param name="value" select="'changed'"/>
                        <xsl:with-param name="select-value" select="$condition/data/text()"/>
                      </xsl:call-template>
                      <xsl:call-template name="opt">
                        <xsl:with-param name="value" select="'increased'"/>
                        <xsl:with-param name="select-value" select="$condition/data/text()"/>
                      </xsl:call-template>
                      <xsl:call-template name="opt">
                        <xsl:with-param name="value" select="'decreased'"/>
                        <xsl:with-param name="select-value" select="$condition/data/text()"/>
                      </xsl:call-template>
                    </select>
                  </td>
                </tr>
              </table>
            </td>
          </tr>
          <xsl:variable name="method"
                        select="commands_response/get_alerts_response/alert/method"/>
          <tr class="odd">
            <td valign="top" width="145">Method</td>
            <td colspan="2">
              <table border="0" width="100%">
                <tr>
                  <td colspan="3" valign="top">
                    <xsl:call-template name="radio-button">
                      <xsl:with-param name="name" select="'method'"/>
                      <xsl:with-param name="value" select="'Email'"/>
                      <xsl:with-param name="select-value" select="$method/text()"/>
                    </xsl:call-template>
                  </td>
                </tr>
                <tr>
                  <td width="45"></td>
                  <td width="150">To Address</td>
                  <td>
                    <input type="text" name="method_data:to_address" size="30" maxlength="301"
                        value="{$method/data[name='to_address']/text()}"/>
                  </td>
                </tr>
                <tr>
                  <td width="45"></td>
                  <td width="150">From Address</td>
                  <td>
                    <input type="text" name="method_data:from_address" size="30" maxlength="301"
                        value="{$method/data[name='from_address']/text()}"/>
                  </td>
                </tr>
                <tr>
                  <td width="45"></td>
                  <td width="150">Content</td>
                  <td>
                    <table>
                      <tr>
                        <td colspan="3" valign="top">
                          <label>
                            <xsl:call-template name="radio-button">
                              <xsl:with-param name="name" select="'method_data:notice'"/>
                              <xsl:with-param name="text" select="'Simple notice'"/>
                              <xsl:with-param name="value" select="'1'"/>
                              <xsl:with-param name="select-value" select="$method/data[name='notice']/text()"/>
                            </xsl:call-template>
                          </label>
                        </td>
                      </tr>
                      <tr>
                        <td colspan="3" valign="top">
                            <xsl:call-template name="radio-button">
                              <xsl:with-param name="name" select="'method_data:notice'"/>
                              <xsl:with-param name="text" select="'Include report'"/>
                              <xsl:with-param name="value" select="'0'"/>
                              <xsl:with-param name="select-value" select="$method/data[name='notice']/text()"/>
                            </xsl:call-template>
                          <select name="method_data:notice_report_format">
                            <xsl:for-each select="$report-formats/report_format">
                              <xsl:if test="substring(content_type, 1, 5) = 'text/'">
                                <xsl:choose>
                                  <xsl:when test="@id=$method/data[name='notice_report_format']/text()">
                                    <option value="{@id}" selected="1">
                                      <xsl:value-of select="name"/>
                                    </option>
                                  </xsl:when>
                                  <xsl:otherwise>
                                    <option value="{@id}">
                                      <xsl:value-of select="name"/>
                                    </option>
                                  </xsl:otherwise>
                                </xsl:choose>
                              </xsl:if>
                            </xsl:for-each>
                          </select>
                        </td>
                      </tr>
                      <tr>
                        <td colspan="3" valign="top">
                            <xsl:call-template name="radio-button">
                              <xsl:with-param name="name" select="'method_data:notice'"/>
                              <xsl:with-param name="text" select="'Attach report'"/>
                              <xsl:with-param name="value" select="'2'"/>
                              <xsl:with-param name="select-value" select="$method/data[name='notice']/text()"/>
                            </xsl:call-template>
                          <select name="method_data:notice_attach_format">
                            <xsl:for-each select="$report-formats/report_format">
                              <xsl:choose>
                                <xsl:when test="@id=$method/data[name='notice_attach_format']/text()">
                                  <option value="{@id}" selected="1">
                                    <xsl:value-of select="name"/>
                                  </option>
                                </xsl:when>
                                <xsl:otherwise>
                                  <option value="{@id}">
                                    <xsl:value-of select="name"/>
                                  </option>
                                </xsl:otherwise>
                              </xsl:choose>
                            </xsl:for-each>
                          </select>
                        </td>
                      </tr>
                    </table>
                  </td>
                </tr>
              </table>
            </td>
          </tr>
          <tr class="even">
            <td valign="top" width="125"></td>
            <td colspan="2">
              <table border="0" width="100%">
                <tr>
                  <td colspan="3" valign="top">
                    <xsl:call-template name="radio-button">
                      <xsl:with-param name="name" select="'method'"/>
                      <xsl:with-param name="value" select="'syslog'"/>
                      <xsl:with-param name="select-value" select="gsa:lower-case($method/text())"/>
                      <xsl:with-param name="text" select="'System Logger'"/>
                    </xsl:call-template>
                    <select name="method_data:submethod">
                      <xsl:call-template name="opt">
                        <xsl:with-param name="value" select="'syslog'"/>
                        <xsl:with-param name="select-value" select="$method/data/text()"/>
                      </xsl:call-template>
                      <xsl:call-template name="opt">
                        <xsl:with-param name="value" select="'SNMP'"/>
                        <xsl:with-param name="select-value" select="$method/data/text()"/>
                      </xsl:call-template>
                    </select>
                  </td>
                </tr>
              </table>
            </td>
          </tr>
          <tr class="odd">
            <td valign="top" width="125"></td>
            <td colspan="2">
              <table border="0" width="100%">
                <tr>
                  <td colspan="3" valign="top">
                    <xsl:call-template name="radio-button">
                      <xsl:with-param name="name" select="'method'"/>
                      <xsl:with-param name="value" select="'HTTP Get'"/>
                      <xsl:with-param name="select-value" select="$method/text()"/>
                    </xsl:call-template>
                  </td>
                </tr>
                <tr>
                  <td width="45"></td>
                  <td width="150">URL</td>
                  <td>
                    <input type="text" name="method_data:URL" size="30" maxlength="301"
                        value="{$method/data[name='URL']/text()}"/>
                  </td>
                </tr>
              </table>
            </td>
          </tr>
          <tr class="even">
            <td valign="top" width="125"></td>
            <td colspan="2">
              <table border="0" width="100%">
                <tr>
                  <td colspan="3" valign="top">
                    <xsl:call-template name="radio-button">
                      <xsl:with-param name="name" select="'method'"/>
                      <xsl:with-param name="value" select="'Sourcefire Connector'"/>
                      <xsl:with-param name="select-value" select="$method/text()"/>
                    </xsl:call-template>
                  </td>
                </tr>
                <tr>
                  <td width="45"></td>
                  <td width="150">Defense Center IP</td>
                  <td>
                    <input type="text" name="method_data:defense_center_ip"
                           size="30" maxlength="40" value="{$method/data[name='defense_center_ip']/text()}"/>
                  </td>
                </tr>
                <tr>
                  <td width="45"></td>
                  <td width="150">Defense Center Port</td>
                  <td>
                    <xsl:choose>
                      <xsl:when test="$method/data[name='defense_center_port']/text()">
                        <input type="text" name="method_data:defense_center_port"
                               size="30" maxlength="400"  value="{$method/data[name='defense_center_port']/text()}"/>
                      </xsl:when>
                      <xsl:otherwise>
                        <input type="text" name="method_data:defense_center_port"
                               size="30" maxlength="400" value="8307"/>
                      </xsl:otherwise>
                    </xsl:choose>
                  </td>
                </tr>
                <tr>
                  <td width="45"></td>
                  <td width="150">PKCS12 file</td>
                  <td>
                    <input type="file" name="method_data:pkcs12" size="30"/>
                  </td>
                </tr>
              </table>
            </td>
          </tr>
          <tr class="odd">
            <td valign="top" width="125"></td>
            <td colspan="2">
              <table border="0" width="100%">
                <tr>
                  <td colspan="3" valign="top">
                    <xsl:call-template name="radio-button">
                      <xsl:with-param name="name" select="'method'"/>
                      <xsl:with-param name="value" select="'verinice Connector'"/>
                      <xsl:with-param name="select-value" select="$method/text()"/>
                      <xsl:with-param name="text" select="'verinice.PRO Connector'"/>
                    </xsl:call-template>
                  </td>
                </tr>
                <tr>
                  <td width="45"></td>
                  <td width="150">verinice.PRO URL</td>
                  <td>
                    <input type="text" name="method_data:verinice_server_url"
                           size="30" maxlength="256" value="{$method/data[name='verinice_server_url']/text()}"/>
                  </td>
                </tr>
                <tr>
                  <td width="45"></td>
                  <td width="150">verinice.PRO Username</td>
                  <td>
                    <input type="text" name="method_data:verinice_server_username"
                           size="30" maxlength="40" value="{$method/data[name='verinice_server_username']/text()}"/>
                  </td>
                </tr>
                <tr>
                  <td width="45"></td>
                  <td width="150">verinice.PRO Password</td>
                  <td>
                    <input type="password" name="method_data:verinice_server_password"
                           size="30" maxlength="40"/>
                  </td>
                </tr>
              </table>
            </td>
          </tr>
          <xsl:variable name="filtername"
              select="commands_response/get_alerts_response/alert/filter/name"/>
          <tr>
            <td valign="top" width="145">Report Filter (optional)</td>
            <td colspan="2">
              <select name="filter_id">
                <option value="0">--</option>
                <xsl:for-each select="$filters/filter">
                  <xsl:choose>
                    <xsl:when test="name = $filtername">
                      <option value="{@id}" selected="1"><xsl:value-of select="name"/></option>
                    </xsl:when>
                    <xsl:otherwise>
                      <option value="{@id}"><xsl:value-of select="name"/></option>
                    </xsl:otherwise>
                  </xsl:choose>
                </xsl:for-each>
              </select>
            </td>
          </tr>
          <tr>
            <td colspan="2" style="text-align:right;">
              <input type="submit" name="submit" value="Save Alert"/>
            </td>
          </tr>
        </table>
        <br/>
      </form>
    </div>
  </div>
</xsl:template>

<xsl:template match="edit_alert">
  <xsl:apply-templates select="gsad_msg"/>
  <xsl:call-template name="html-edit-alert-form">
    <xsl:with-param
      name="report-formats"
      select="get_report_formats_response | commands_response/get_report_formats_response"/>
    <xsl:with-param
      name="filters"
      select="get_filters_response | commands_response/get_filters_response"/>
  </xsl:call-template>
</xsl:template>

<xsl:template match="get_alerts_response">
</xsl:template>

<!--     CREATE_ALERT_RESPONSE -->

<xsl:template match="create_alert_response">
  <xsl:call-template name="command_result_dialog">
    <xsl:with-param name="operation">Create Alert</xsl:with-param>
    <xsl:with-param name="status">
      <xsl:value-of select="@status"/>
    </xsl:with-param>
    <xsl:with-param name="msg">
      <xsl:value-of select="@status_text"/>
    </xsl:with-param>
  </xsl:call-template>
</xsl:template>

<!--     DELETE_ALERT_RESPONSE -->

<xsl:template match="delete_alert_response">
  <xsl:call-template name="command_result_dialog">
    <xsl:with-param name="operation">
      Delete Alert
    </xsl:with-param>
    <xsl:with-param name="status">
      <xsl:value-of select="@status"/>
    </xsl:with-param>
    <xsl:with-param name="msg">
      <xsl:value-of select="@status_text"/>
    </xsl:with-param>
  </xsl:call-template>
</xsl:template>

<!--     TEST_ALERT_RESPONSE -->

<xsl:template match="test_alert_response">
  <xsl:call-template name="command_result_dialog">
    <xsl:with-param name="operation">Test Alert</xsl:with-param>
    <xsl:with-param name="status">
      <xsl:value-of select="@status"/>
    </xsl:with-param>
    <xsl:with-param name="msg">
      <xsl:value-of select="@status_text"/>
    </xsl:with-param>
  </xsl:call-template>
</xsl:template>

<!--     MODIFY_ALERT_RESPONSE -->

<xsl:template match="modify_alert_response">
  <xsl:call-template name="command_result_dialog">
    <xsl:with-param name="operation">Save Alert</xsl:with-param>
    <xsl:with-param name="status">
      <xsl:value-of select="@status"/>
    </xsl:with-param>
    <xsl:with-param name="msg">
      <xsl:value-of select="@status_text"/>
    </xsl:with-param>
  </xsl:call-template>
</xsl:template>

<!--     ALERT -->

<xsl:template match="alert">
  <xsl:variable name="class">
    <xsl:choose>
      <xsl:when test="position() mod 2 = 0">even</xsl:when>
      <xsl:otherwise>odd</xsl:otherwise>
    </xsl:choose>
  </xsl:variable>
  <tr class="{$class}">
    <td>
      <b>
        <a href="/omp?cmd=get_alert&amp;alert_id={@id}&amp;filter={str:encode-uri (../filters/term, true ())}&amp;token={/envelope/token}">
          <xsl:value-of select="name"/>
        </a>
      </b>
      <xsl:choose>
        <xsl:when test="comment != ''">
          <br/>(<xsl:value-of select="comment"/>)
        </xsl:when>
        <xsl:otherwise></xsl:otherwise>
      </xsl:choose>
    </td>
    <td>
      <xsl:value-of select="event/text()"/>
      <xsl:choose>
        <xsl:when test="event/text()='Task run status changed' and string-length(event/data[name='status']/text()) &gt; 0">
          <br/>(to <xsl:value-of select=" event/data[name='status']/text()"/>)
        </xsl:when>
      </xsl:choose>
    </td>
    <td>
      <xsl:value-of select="condition/text()"/>
      <xsl:choose>
        <xsl:when test="condition/text()='Threat level at least' and string-length(condition/data[name='level']/text()) &gt; 0">
          <br/>(<xsl:value-of select="condition/data[name='level']/text()"/>)
        </xsl:when>
        <xsl:when test="condition/text()='Threat level changed' and string-length(condition/data[name='direction']/text()) &gt; 0">
          <br/>(<xsl:value-of select="condition/data[name='direction']/text()"/>)
        </xsl:when>
      </xsl:choose>
    </td>
    <td>
      <xsl:choose>
        <xsl:when test="method/text()='Syslog' and method/data[name='submethod']/text() = 'SNMP'">
          SNMP
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="method/text()"/>
          <xsl:choose>
            <xsl:when test="method/text()='Email' and string-length(method/data[name='to_address']/text()) &gt; 0">
              <br/>(To <xsl:value-of select="method/data[name='to_address']/text()"/>)
            </xsl:when>
          </xsl:choose>
        </xsl:otherwise>
      </xsl:choose>
    </td>
    <td>
      <a href="/omp?cmd=get_filter&amp;filter_id={filter/@id}&amp;token={/envelope/token}" title="Details">
        <xsl:value-of select="filter/name"/>
      </a>
    </td>
    <td>
      <xsl:call-template name="list-window-line-icons">
        <xsl:with-param name="cap-type" select="'Alert'"/>
        <xsl:with-param name="type" select="'alert'"/>
        <xsl:with-param name="id" select="@id"/>
      </xsl:call-template>
      <xsl:call-template name="start-icon">
        <xsl:with-param name="type">alert</xsl:with-param>
        <xsl:with-param name="id" select="@id"/>
        <xsl:with-param name="cmd">test_alert</xsl:with-param>
        <xsl:with-param name="alt">Test</xsl:with-param>
      </xsl:call-template>
    </td>
  </tr>
</xsl:template>

<xsl:template match="alert" mode="trash">
  <xsl:variable name="class">
    <xsl:choose>
      <xsl:when test="position() mod 2 = 0">even</xsl:when>
      <xsl:otherwise>odd</xsl:otherwise>
    </xsl:choose>
  </xsl:variable>
  <tr class="{$class}">
    <td>
      <b><xsl:value-of select="name"/></b>
      <xsl:choose>
        <xsl:when test="comment != ''">
          <br/>(<xsl:value-of select="comment"/>)
        </xsl:when>
        <xsl:otherwise></xsl:otherwise>
      </xsl:choose>
    </td>
    <td>
      <xsl:value-of select="event/text()"/>
      <xsl:choose>
        <xsl:when test="event/text()='Task run status changed' and string-length(event/data[name='status']/text()) &gt; 0">
          <br/>(to <xsl:value-of select=" event/data[name='status']/text()"/>)
        </xsl:when>
      </xsl:choose>
    </td>
    <td>
      <xsl:value-of select="condition/text()"/>
      <xsl:choose>
        <xsl:when test="condition/text()='Threat level at least' and string-length(condition/data[name='level']/text()) &gt; 0">
          <br/>(<xsl:value-of select="condition/data[name='level']/text()"/>)
        </xsl:when>
        <xsl:when test="condition/text()='Threat level changed' and string-length(condition/data[name='direction']/text()) &gt; 0">
          <br/>(<xsl:value-of select="condition/data[name='direction']/text()"/>)
        </xsl:when>
      </xsl:choose>
    </td>
    <td>
      <xsl:choose>
        <xsl:when test="method/text()='Syslog' and method/data[name='submethod']/text() = 'SNMP'">
          SNMP
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="method/text()"/>
          <xsl:choose>
            <xsl:when test="method/text()='Email' and string-length(method/data[name='to_address']/text()) &gt; 0">
              <br/>(To <xsl:value-of select="method/data[name='to_address']/text()"/>)
            </xsl:when>
          </xsl:choose>
        </xsl:otherwise>
      </xsl:choose>
    </td>
    <td>
      <xsl:choose>
        <xsl:when test="filter/trash = '1'">
          <xsl:value-of select="filter/name"/>
        </xsl:when>
        <xsl:otherwise>
          <a href="/omp?cmd=get_filter&amp;filter_id={filter/@id}&amp;token={/envelope/token}" title="Details">
            <xsl:value-of select="filter/name"/>
          </a>
        </xsl:otherwise>
      </xsl:choose>
    </td>
    <td>
      <xsl:choose>
        <xsl:when test="filter/trash = '1'">
          <img src="/img/restore_inactive.png" border="0" alt="Restore"
               style="margin-left:3px;"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:call-template name="restore-icon">
            <xsl:with-param name="id" select="@id"/>
          </xsl:call-template>
        </xsl:otherwise>
      </xsl:choose>
      <xsl:choose>
        <xsl:when test="in_use='0'">
          <xsl:call-template name="trash-delete-icon">
            <xsl:with-param name="type" select="'alert'"/>
            <xsl:with-param name="id" select="@id"/>
          </xsl:call-template>
        </xsl:when>
        <xsl:otherwise>
          <img src="/img/delete_inactive.png"
               border="0"
               alt="Delete"
               style="margin-left:3px;"/>
        </xsl:otherwise>
      </xsl:choose>
    </td>
  </tr>
</xsl:template>

<xsl:template match="alert" mode="details">
  <div class="gb_window">
    <div class="gb_window_part_left"></div>
    <div class="gb_window_part_right"></div>
    <div class="gb_window_part_center">
      Alert Details
      <xsl:call-template name="details-header-icons">
        <xsl:with-param name="cap-type" select="'Alert'"/>
        <xsl:with-param name="type" select="'alert'"/>
      </xsl:call-template>
    </div>
    <div class="gb_window_part_content">
      <xsl:call-template name="minor-details"/>
      <table>
        <tr>
          <td><b>Name:</b></td>
          <td><b><xsl:value-of select="name"/></b></td>
        </tr>
        <tr>
          <td>Comment:</td>
          <td><xsl:value-of select="comment"/></td>
        </tr>
        <tr>
          <td>Condition:</td>
          <td>
            <xsl:value-of select="condition/text()"/>
            <xsl:choose>
              <xsl:when test="condition/text()='Threat level at least' and string-length(condition/data[name='level']/text()) &gt; 0">
                (<xsl:value-of select="condition/data[name='level']/text()"/>)
              </xsl:when>
              <xsl:when test="condition/text()='Threat level changed' and string-length(condition/data[name='direction']/text()) &gt; 0">
                (<xsl:value-of select="condition/data[name='direction']/text()"/>)
              </xsl:when>
            </xsl:choose>
          </td>
        </tr>
        <tr>
          <td>Event:</td>
          <td>
            <xsl:value-of select="event/text()"/>
            <xsl:choose>
              <xsl:when test="event/text()='Task run status changed' and string-length(event/data[name='status']/text()) &gt; 0">
                (to <xsl:value-of select=" event/data[name='status']/text()"/>)
              </xsl:when>
            </xsl:choose>
          </td>
        </tr>
        <tr>
          <td valign="top">Method:</td>
          <td>
            <table>
              <tr>
                <td colspan="3">
                  <xsl:choose>
                    <xsl:when test="method/text()='Syslog' and method/data[name='submethod']/text() = 'SNMP'">
                      SNMP
                    </xsl:when>
                    <xsl:otherwise>
                      <xsl:value-of select="method/text()"/>
                    </xsl:otherwise>
                  </xsl:choose>
                </td>
              </tr>
              <xsl:choose>
                <xsl:when test="method/text()='Email'">
                  <tr>
                    <td width="45"></td>
                    <td>To address:</td>
                    <td>
                      <xsl:choose>
                        <xsl:when test="string-length(method/data[name='to_address']/text()) &gt; 0">
                          <xsl:value-of select="method/data[name='to_address']/text()"/>
                        </xsl:when>
                      </xsl:choose>
                    </td>
                  </tr>
                  <tr>
                    <td width="45"></td>
                    <td>From address:</td>
                    <td>
                      <xsl:choose>
                        <xsl:when test="string-length(method/data[name='from_address']/text()) &gt; 0">
                          <xsl:value-of select="method/data[name='from_address']/text()"/>
                        </xsl:when>
                      </xsl:choose>
                    </td>
                  </tr>
                  <tr>
                    <td width="45"></td>
                    <td>Content:</td>
                    <td>
                      <xsl:choose>
                        <xsl:when test="method/data[name='notice']/text() = '0'">
                          Include report
                          <xsl:variable name="id"
                                        select="method/data[name='notice_report_format']/text()"/>
                          <xsl:value-of select="../../get_report_formats_response/report_format[@id=$id]/name"/>
                        </xsl:when>
                        <xsl:when test="method/data[name='notice']/text() = '2'">
                          Attach report
                          <xsl:variable name="id"
                                        select="method/data[name='notice_attach_format']/text()"/>
                          <xsl:value-of select="../../get_report_formats_response/report_format[@id=$id]/name"/>
                        </xsl:when>
                        <xsl:otherwise>
                          Simple notice
                        </xsl:otherwise>
                      </xsl:choose>
                    </td>
                  </tr>
                </xsl:when>
                <xsl:when test="method/text()='HTTP Get'">
                  <tr>
                    <td width="45"></td>
                    <td>URL:</td>
                    <td>
                      <xsl:choose>
                        <xsl:when test="string-length(method/data[name='URL']/text()) &gt; 0">
                          <xsl:value-of select="method/data[name='URL']/text()"/>
                        </xsl:when>
                      </xsl:choose>
                    </td>
                  </tr>
                </xsl:when>
                <xsl:when test="method/text()='Sourcefire Connector'">
                  <tr>
                    <td width="45"></td>
                    <td>Defense Center IP:</td>
                    <td>
                      <xsl:choose>
                        <xsl:when test="string-length(method/data[name='defense_center_ip']/text()) &gt; 0">
                          <xsl:value-of select="method/data[name='defense_center_ip']/text()"/>
                        </xsl:when>
                      </xsl:choose>
                    </td>
                  </tr>
                  <tr>
                    <td width="45"></td>
                    <td>Defense Center Port:</td>
                    <td>
                      <xsl:choose>
                        <xsl:when test="string-length(method/data[name='defense_center_port']/text()) &gt; 0">
                          <xsl:value-of select="method/data[name='defense_center_port']/text()"/>
                        </xsl:when>
                      </xsl:choose>
                    </td>
                  </tr>
                </xsl:when>
                <xsl:when test="method/text()='verinice Connector'">
                  <tr>
                    <td width="45"></td>
                    <td>URL:</td>
                    <td>
                      <xsl:choose>
                        <xsl:when test="string-length(method/data[name='verinice_server_url']/text()) &gt; 0">
                          <xsl:value-of select="method/data[name='verinice_server_url']/text()"/>
                        </xsl:when>
                      </xsl:choose>
                    </td>
                  </tr>
                  <tr>
                    <td width="45"></td>
                    <td>Username:</td>
                    <td>
                      <xsl:choose>
                        <xsl:when test="string-length(method/data[name='verinice_server_username']/text()) &gt; 0">
                          <xsl:value-of select="method/data[name='verinice_server_username']/text()"/>
                        </xsl:when>
                      </xsl:choose>
                    </td>
                  </tr>
                </xsl:when>
              </xsl:choose>
            </table>
          </td>
        </tr>
        <tr>
          <td>Filter:</td>
          <td>
            <xsl:choose>
              <xsl:when test="string-length(filter/name) &gt; 0">
                  <a href="/omp?cmd=get_filter&amp;filter_id={filter/@id}&amp;token={/envelope/token}"
                     title="Details">
                  <xsl:value-of select="filter/name"/>
                </a>
              </xsl:when>
              <xsl:otherwise>
                None.
              </xsl:otherwise>
            </xsl:choose>
          </td>
        </tr>
      </table>

      <xsl:choose>
        <xsl:when test="count(tasks/task) = 0">
          <h1>Tasks using this Alert: None</h1>
        </xsl:when>
        <xsl:otherwise>
          <h1>Tasks using this Alert</h1>
          <table class="gbntable" cellspacing="2" cellpadding="4">
            <tr class="gbntablehead2">
              <td>Name</td>
              <td>Actions</td>
            </tr>
            <xsl:for-each select="tasks/task">
              <xsl:variable name="class">
                <xsl:choose>
                  <xsl:when test="position() mod 2 = 0">even</xsl:when>
                  <xsl:otherwise>odd</xsl:otherwise>
                </xsl:choose>
              </xsl:variable>
              <tr class="{$class}">
                <td><xsl:value-of select="name"/></td>
                <td width="100">
                  <a href="/omp?cmd=get_task&amp;task_id={@id}&amp;token={/envelope/token}" title="Details">
                    <img src="/img/details.png"
                         border="0"
                         alt="Details"
                         style="margin-left:3px;"/>
                  </a>
                </td>
              </tr>
            </xsl:for-each>
          </table>
        </xsl:otherwise>
      </xsl:choose>
    </div>
  </div>
</xsl:template>

<!--     GET_ALERT -->

<xsl:template match="get_alert">
  <xsl:apply-templates select="gsad_msg"/>
  <xsl:apply-templates select="commands_response/delete_alert_response"/>
  <xsl:apply-templates select="modify_alert_response"/>
  <xsl:apply-templates select="get_alerts_response/alert" mode="details"/>
</xsl:template>

<!--     GET_ALERTS_RESPONSE -->

<xsl:template match="get_alerts">
  <xsl:apply-templates select="gsad_msg"/>
  <xsl:apply-templates select="commands_response/delete_alert_response"/>
  <xsl:apply-templates select="create_alert_response"/>
  <xsl:apply-templates select="create_filter_response"/>
  <xsl:apply-templates select="test_alert_response"/>
  <xsl:apply-templates select="modify_alert_response"/>
  <!-- The for-each makes the get_alerts_response the current node. -->
  <xsl:for-each select="get_alerts_response | commands_response/get_alerts_response">
    <xsl:call-template name="html-alerts-table"/>
  </xsl:for-each>
</xsl:template>

<!-- END ALERTS MANAGEMENT -->

<!-- BEGIN GENERIC MANAGEMENT -->

<xsl:template name="list-window">
  <xsl:param name="type"/>
  <xsl:param name="cap-type"/>
  <xsl:param name="resources-summary"/>
  <xsl:param name="resources"/>
  <xsl:param name="count"/>
  <xsl:param name="filtered-count"/>
  <xsl:param name="full-count"/>
  <xsl:param name="headings"/>
  <xsl:variable name="apply-overrides" select="apply_overrides"/>
  <div class="gb_window">
    <div class="gb_window_part_left"></div>
    <div class="gb_window_part_right"></div>
    <div class="gb_window_part_center"><xsl:value-of select="$cap-type"/>s
      <xsl:call-template name="filter-window-pager">
        <xsl:with-param name="type" select="$type"/>
        <xsl:with-param name="list" select="$resources-summary"/>
        <xsl:with-param name="count" select="$count"/>
        <xsl:with-param name="filtered_count" select="$filtered-count"/>
        <xsl:with-param name="full_count" select="$full-count"/>
      </xsl:call-template>
      <a href="/help/{$type}s.html?token={/envelope/token}"
         title="Help: {$cap-type}s">
        <img src="/img/help.png"/>
      </a>
      <xsl:call-template name="wizard-icon"/>
      <xsl:choose>
        <xsl:when test="$type = 'permission'"/>
        <xsl:otherwise>
          <a href="/omp?cmd=new_{$type}&amp;filter={str:encode-uri (filters/term, true ())}&amp;filt_id={/envelope/params/filt_id}&amp;token={/envelope/token}"
             title="New {$cap-type}">
            <img src="/img/new.png" border="0" style="margin-left:3px;"/>
          </a>
        </xsl:otherwise>
      </xsl:choose>
      <a href="/omp?cmd=get_{$type}s&amp;filter=&amp;filt_id=&amp;token={/envelope/token}"
         title="Return to default filter view" style="margin-left:3px;">
        <img src="/img/list.png" border="0" alt="Return"/>
      </a>
      <div id="small_inline_form" style="display: inline; margin-left: 15px; font-weight: normal;">
        <a href="/omp?cmd=export_{$type}s&amp;filter={str:encode-uri (filters/term, true ())}&amp;token={/envelope/token}"
           title="Export {$filtered-count} filtered {$cap-type}s as XML"
           style="margin-left:3px;">
          <img src="/img/download.png" border="0" alt="Export XML"/>
        </a>
      </div>
      <div id="small_inline_form" style="margin-left:40px; display: inline">
        <form method="get" action="">
          <input type="hidden" name="token" value="{/envelope/token}"/>
          <input type="hidden" name="cmd" value="get_{$type}s"/>
          <input type="hidden" name="filter" value="{filters/term}"/>
          <xsl:call-template name="auto-refresh"/>
          <xsl:if test="$type = 'task'">
            <select style="margin-bottom: 0px;" name="overrides" size="1">
              <xsl:choose>
                <xsl:when test="$apply-overrides = 0">
                  <option value="0" selected="1">&#8730;No overrides</option>
                  <option value="1" >Apply overrides</option>
                </xsl:when>
                <xsl:otherwise>
                  <option value="0">No overrides</option>
                  <option value="1" selected="1">&#8730;Apply overrides</option>
                </xsl:otherwise>
              </xsl:choose>
            </select>
          </xsl:if>
          <input type="image"
                 name="Update"
                 src="/img/refresh.png"
                 alt="Update" style="margin-left:3px;margin-right:3px;"/>
        </form>
      </div>
    </div>
    <xsl:call-template name="filter-window-part">
      <xsl:with-param name="type" select="$type"/>
      <xsl:with-param name="list" select="$resources-summary"/>
    </xsl:call-template>
    <div class="gb_window_part_content_no_pad">
      <div id="tasks">
        <table class="gbntable" cellspacing="2" cellpadding="4" border="0">
          <tr class="gbntablehead2">
            <xsl:variable name="current" select="."/>
            <xsl:variable name="token" select="/envelope/token"/>
            <xsl:for-each select="str:split ($headings, ' ')">
              <xsl:variable name="parts" select="str:split (., '~')"/>
              <xsl:choose>
                <xsl:when test="count ($parts) = 1">
                  <td rowspan="2">
                    <xsl:call-template name="column-name">
                      <xsl:with-param name="head" select="substring-before ($parts[1], '|')"/>
                      <xsl:with-param name="name" select="substring-after ($parts[1], '|')"/>
                      <xsl:with-param name="type" select="$type"/>
                      <xsl:with-param name="current" select="$current"/>
                      <xsl:with-param name="token" select="$token"/>
                    </xsl:call-template>
                  </td>
                </xsl:when>
                <xsl:otherwise>
                  <td colspan="{count ($parts) - 1}">
                    <xsl:value-of select="$parts[1]"/>
                  </td>
                </xsl:otherwise>
              </xsl:choose>
            </xsl:for-each>
            <xsl:choose>
              <xsl:when test="contains ($headings, '~')">
                <td width="160" rowspan="2">Actions</td>
              </xsl:when>
              <xsl:otherwise>
                <td width="160">Actions</td>
              </xsl:otherwise>
            </xsl:choose>
          </tr>
          <tr class="gbntablehead2">
            <xsl:variable name="current" select="."/>
            <xsl:variable name="token" select="/envelope/token"/>
            <xsl:for-each select="str:split ($headings, ' ')">
              <xsl:variable name="parts" select="str:split (., '~')"/>
              <xsl:choose>
                <xsl:when test="count ($parts) = 1">
                </xsl:when>
                <xsl:otherwise>
                  <xsl:for-each select="$parts[1]/following-sibling::*">
                    <td style="font-size:10px;">
                      <xsl:call-template name="column-name">
                        <xsl:with-param name="head" select="substring-before (., '|')"/>
                        <xsl:with-param name="name" select="substring-after (., '|')"/>
                        <xsl:with-param name="type" select="$type"/>
                        <xsl:with-param name="current" select="$current"/>
                        <xsl:with-param name="token" select="$token"/>
                      </xsl:call-template>
                    </td>
                  </xsl:for-each>
                </xsl:otherwise>
              </xsl:choose>
            </xsl:for-each>
          </tr>
          <xsl:apply-templates select="$resources"/>
          <xsl:if test="string-length (filters/term) &gt; 0">
            <tr>
              <td class="footnote" colspan="7">
                (Applied filter:
                <a class="footnote" href="/omp?cmd=get_{$type}s&amp;filter={str:encode-uri (filters/term, true ())}&amp;token={/envelope/token}">
                  <xsl:value-of select="filters/term"/>
                </a>)
              </td>
            </tr>
          </xsl:if>
        </table>
        <xsl:call-template name="wizard"/>
      </div>
    </div>
  </div>
</xsl:template>

<xsl:template name="minor-details">
  <div class="float_right" style="font-size: 10px;">
    <table style="font-size: 10px;">
      <tr>
        <td>ID:</td>
        <td><xsl:value-of select="@id"/></td>
      </tr>
      <tr>
        <td>Created:</td>
        <td><xsl:value-of select="gsa:long-time (creation_time)"/></td>
      </tr>
      <tr>
        <td>Last Modified:</td>
        <td><xsl:value-of select="gsa:long-time (modification_time)"/></td>
      </tr>
    </table>
  </div>
</xsl:template>

<xsl:template name="details-header-icons">
  <xsl:param name="cap-type"/>
  <xsl:param name="type"/>
  <xsl:param name="noedit"/>
  <xsl:param name="noexport"/>

  <a href="/help/{$type}_details.html?token={/envelope/token}"
    title="Help: {$cap-type} Details">
    <img src="/img/help.png"/>
  </a>
  <a href="/omp?cmd=new_{$type}&amp;filter={str:encode-uri (/envelope/params/filter, true ())}&amp;filt_id={/envelope/params/filt_id}&amp;{$type}_id={@id}&amp;token={/envelope/token}"
     title="New {$cap-type}">
    <img src="/img/new.png" border="0" style="margin-left:3px;"/>
  </a>
  <a href="/omp?cmd=get_{$type}s&amp;filter={str:encode-uri (/envelope/params/filter, true ())}&amp;filt_id={/envelope/params/filt_id}&amp;token={/envelope/token}"
     title="{$cap-type}s" style="margin-left:3px;">
    <img src="/img/list.png" border="0" alt="{$cap-type}s"/>
  </a>
  <div id="small_inline_form" style="display: inline; margin-left: 15px; font-weight: normal;">
    <xsl:choose>
      <xsl:when test="writable!='0' and in_use='0'">
        <xsl:call-template name="trashcan-icon">
          <xsl:with-param name="type" select="$type"/>
          <xsl:with-param name="id" select="@id"/>
          <xsl:with-param name="params">
            <input type="hidden" name="filter" value="{/envelope/params/filter}"/>
            <input type="hidden" name="filt_id" value="{/envelope/params/filt_id}"/>
          </xsl:with-param>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <img src="/img/trashcan_inactive.png" border="0" alt="To Trashcan"
             style="margin-left:3px;"/>
      </xsl:otherwise>
    </xsl:choose>
  <xsl:choose>
    <xsl:when test="$noedit">
    </xsl:when>
    <xsl:otherwise>
      <xsl:choose>
        <xsl:when test="writable='0'">
          <img src="/img/edit_inactive.png" border="0" alt="Edit"
               style="margin-left:3px;"/>
        </xsl:when>
        <xsl:otherwise>
          <a href="/omp?cmd=edit_{$type}&amp;{$type}_id={@id}&amp;next=get_{$type}&amp;filter={str:encode-uri (/envelope/params/filter, true ())}&amp;filt_id={/envelope/params/filt_id}&amp;token={/envelope/token}"
             title="Edit {$cap-type}">
            <img src="/img/edit.png" border="0" style="margin-left:3px;"/>
          </a>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:otherwise>
  </xsl:choose>
  <xsl:choose>
    <xsl:when test="$noexport">
    </xsl:when>
    <xsl:otherwise>
      <a href="/omp?cmd=export_{$type}&amp;{$type}_id={@id}&amp;filter={str:encode-uri (/envelope/params/filter, true ())}&amp;filt_id={/envelope/params/filt_id}&amp;token={/envelope/token}"
         title="Export {$cap-type} XML"
         style="margin-left:3px;">
        <img src="/img/download.png" border="0" alt="Export XML"/>
      </a>
    </xsl:otherwise>
  </xsl:choose>
  </div>
</xsl:template>

<!-- BEGIN FILTERS MANAGEMENT -->

<xsl:template match="filters">
</xsl:template>

<xsl:template match="create_filter_response">
  <xsl:call-template name="command_result_dialog">
    <xsl:with-param name="operation">Create Filter</xsl:with-param>
    <xsl:with-param name="status">
      <xsl:value-of select="@status"/>
    </xsl:with-param>
    <xsl:with-param name="msg">
      <xsl:value-of select="@status_text"/>
    </xsl:with-param>
  </xsl:call-template>
</xsl:template>

<xsl:template match="delete_filter_response">
  <xsl:call-template name="command_result_dialog">
    <xsl:with-param name="operation">Delete Filter</xsl:with-param>
    <xsl:with-param name="status">
      <xsl:value-of select="@status"/>
    </xsl:with-param>
    <xsl:with-param name="msg">
      <xsl:value-of select="@status_text"/>
    </xsl:with-param>
  </xsl:call-template>
</xsl:template>

<xsl:template match="modify_filter_response">
  <xsl:call-template name="command_result_dialog">
    <xsl:with-param name="operation">Save Filter</xsl:with-param>
    <xsl:with-param name="status">
      <xsl:value-of select="@status"/>
    </xsl:with-param>
    <xsl:with-param name="msg">
      <xsl:value-of select="@status_text"/>
    </xsl:with-param>
  </xsl:call-template>
</xsl:template>

<xsl:template match="filter">
  <xsl:variable name="class">
    <xsl:choose>
      <xsl:when test="position() mod 2 = 0">even</xsl:when>
      <xsl:otherwise>odd</xsl:otherwise>
    </xsl:choose>
  </xsl:variable>
  <tr class="{$class}">
    <td>
      <b>
        <a href="/omp?cmd=get_filter&amp;filter_id={@id}&amp;filter={str:encode-uri (../filters/term, true ())}&amp;token={/envelope/token}">
          <xsl:value-of select="name"/>
        </a>
      </b>
      <xsl:choose>
        <xsl:when test="comment != ''">
          <br/>(<xsl:value-of select="comment"/>)
        </xsl:when>
        <xsl:otherwise></xsl:otherwise>
      </xsl:choose>
    </td>
    <td><xsl:value-of select="term"/></td>
    <td><xsl:value-of select="type"/></td>
    <td>
      <xsl:call-template name="list-window-line-icons">
        <xsl:with-param name="cap-type" select="'Filter'"/>
        <xsl:with-param name="type" select="'filter'"/>
        <xsl:with-param name="id" select="@id"/>
      </xsl:call-template>
    </td>
  </tr>
</xsl:template>

<xsl:template match="filter" mode="trash">
  <xsl:variable name="class">
    <xsl:choose>
      <xsl:when test="position() mod 2 = 0">even</xsl:when>
      <xsl:otherwise>odd</xsl:otherwise>
    </xsl:choose>
  </xsl:variable>
  <tr class="{$class}">
    <td>
      <b>
        <xsl:value-of select="name"/>
      </b>
      <xsl:choose>
        <xsl:when test="comment != ''">
          <br/>(<xsl:value-of select="comment"/>)
        </xsl:when>
        <xsl:otherwise></xsl:otherwise>
      </xsl:choose>
    </td>
    <td><xsl:value-of select="term"/></td>
    <td><xsl:value-of select="type"/></td>
    <td>
      <xsl:call-template name="restore-icon">
        <xsl:with-param name="id" select="@id"/>
      </xsl:call-template>
      <xsl:choose>
        <xsl:when test="in_use='0'">
          <xsl:call-template name="trash-delete-icon">
            <xsl:with-param name="type" select="'filter'"/>
            <xsl:with-param name="id" select="@id"/>
          </xsl:call-template>
        </xsl:when>
        <xsl:otherwise>
          <img src="/img/delete_inactive.png"
               border="0"
               alt="Delete"
               style="margin-left:3px;"/>
        </xsl:otherwise>
      </xsl:choose>
    </td>
  </tr>
</xsl:template>

<xsl:template match="filter" mode="details">
  <div class="gb_window">
    <div class="gb_window_part_left"></div>
    <div class="gb_window_part_right"></div>
    <div class="gb_window_part_center">
      Filter Details
      <xsl:call-template name="details-header-icons">
        <xsl:with-param name="cap-type" select="'Filter'"/>
        <xsl:with-param name="type" select="'filter'"/>
      </xsl:call-template>
    </div>
    <div class="gb_window_part_content">
      <xsl:call-template name="minor-details"/>
      <table>
        <tr>
          <td><b>Name:</b></td>
          <td><b><xsl:value-of select="name"/></b></td>
        </tr>
        <tr>
          <td>Comment:</td>
          <td><xsl:value-of select="comment"/></td>
        </tr>
        <tr>
          <td>Term:</td>
          <td><xsl:value-of select="term"/></td>
        </tr>
        <tr>
          <td>Type:</td>
          <td><xsl:value-of select="type"/></td>
        </tr>
      </table>

      <xsl:choose>
        <xsl:when test="count(alerts/alert) = 0">
          <h1>Alerts using this Filter: None</h1>
        </xsl:when>
        <xsl:otherwise>
          <h1>Alerts using this Filter</h1>
          <table class="gbntable" cellspacing="2" cellpadding="4">
            <tr class="gbntablehead2">
              <td>Name</td>
              <td>Actions</td>
            </tr>
            <xsl:for-each select="alerts/alert">
              <xsl:variable name="class">
                <xsl:choose>
                  <xsl:when test="position() mod 2 = 0">even</xsl:when>
                  <xsl:otherwise>odd</xsl:otherwise>
                </xsl:choose>
              </xsl:variable>
              <tr class="{$class}">
                <td><xsl:value-of select="name"/></td>
                <td width="100">
                  <a href="/omp?cmd=get_alert&amp;alert_id={@id}&amp;token={/envelope/token}" title="Details">
                    <img src="/img/details.png"
                         border="0"
                         alt="Details"
                         style="margin-left:3px;"/>
                  </a>
                </td>
              </tr>
            </xsl:for-each>
          </table>
        </xsl:otherwise>
      </xsl:choose>
    </div>
  </div>
</xsl:template>

<xsl:template name="html-filters-trash-table">
  <div id="tasks">
    <table class="gbntable" cellspacing="2" cellpadding="4" border="0">
      <tr class="gbntablehead2">
        <td>Name</td>
        <td>Term</td>
        <td>Type</td>
        <td width="100">Actions</td>
      </tr>
      <xsl:apply-templates select="filter" mode="trash"/>
    </table>
  </div>
</xsl:template>

<xsl:template name="html-filters-table">
  <xsl:call-template name="list-window">
    <xsl:with-param name="type" select="'filter'"/>
    <xsl:with-param name="cap-type" select="'Filter'"/>
    <xsl:with-param name="resources-summary" select="filters"/>
    <xsl:with-param name="resources" select="filter"/>
    <xsl:with-param name="count" select="count (filter)"/>
    <xsl:with-param name="filtered-count" select="filter_count/filtered"/>
    <xsl:with-param name="full-count" select="filter_count/text ()"/>
    <xsl:with-param name="headings" select="'Name|name Term|term Type|type'"/>
  </xsl:call-template>
</xsl:template>

<!-- NEW_FILTER -->

<xsl:template name="html-create-filter-form">
  <div class="gb_window">
    <div class="gb_window_part_left"></div>
    <div class="gb_window_part_right"></div>
    <div class="gb_window_part_center">New Filter
      <a href="/help/new_filter.html?token={/envelope/token}"
         title="Help: New Filter">
        <img src="/img/help.png"/>
      </a>
      <a href="/omp?cmd=get_filters&amp;filter={str:encode-uri (/envelope/params/filter, true ())}&amp;filt_id={/envelope/params/filt_id}&amp;token={/envelope/token}"
         title="Filters" style="margin-left:3px;">
        <img src="/img/list.png" border="0" alt="Filters"/>
      </a>
    </div>
    <div class="gb_window_part_content">
      <form action="/omp" method="post" enctype="multipart/form-data">
        <input type="hidden" name="token" value="{/envelope/token}"/>
        <input type="hidden" name="cmd" value="create_filter"/>
        <input type="hidden" name="caller" value="{/envelope/caller}"/>
        <input type="hidden" name="filter_id" value="{/envelope/params/filter_id}"/>
        <input type="hidden" name="filter" value="{/envelope/params/filter}"/>
        <table border="0" cellspacing="0" cellpadding="3" width="100%">
          <tr>
            <td valign="top" width="175">Name
            </td>
            <td>
              <input type="text" name="name" value="unnamed" size="30"
                     maxlength="80"/>
            </td>
          </tr>
          <tr>
            <td valign="top" width="175">Comment (optional)</td>
            <td>
              <input type="text" name="comment" size="30" maxlength="400"/>
            </td>
          </tr>
          <tr>
            <td valign="top" width="175">Term</td>
            <td>
              <input type="text" name="term" size="30" maxlength="1000"/>
            </td>
          </tr>
          <tr>
            <td valign="top" width="175">Type</td>
            <td>
              <select name="optional_resource_type">
                <option value="">--</option>
                <xsl:for-each select="str:split ('Agent|Alert|Config|Credential|Filter|Note|Override|Permission|Port List|Report|Report Format|Schedule|Slave|Tag|Target|Task|SecInfo', '|')">
                  <option value="{.}"><xsl:value-of select="."/></option>
                </xsl:for-each>
              </select>
            </td>
          </tr>
          <tr>
            <td colspan="2" style="text-align:right;">
              <input type="submit" name="submit" value="Create Filter"/>
            </td>
          </tr>
        </table>
      </form>
    </div>
  </div>
</xsl:template>

<xsl:template match="new_filter">
  <xsl:apply-templates select="gsad_msg"/>
  <xsl:apply-templates select="commands_response/delete_filter_response"/>
  <xsl:apply-templates select="create_filter_response"/>
  <xsl:call-template name="html-create-filter-form"/>
</xsl:template>

<!--     EDIT_FILTER -->

<xsl:template name="html-edit-filter-form">
  <div class="gb_window">
    <div class="gb_window_part_left"></div>
    <div class="gb_window_part_right"></div>
    <div class="gb_window_part_center">Edit Filter
      <xsl:call-template name="edit-header-icons">
        <xsl:with-param name="cap-type" select="'Filter'"/>
        <xsl:with-param name="type" select="'filter'"/>
        <xsl:with-param name="id"
                        select="commands_response/get_filters_response/filter/@id"/>
      </xsl:call-template>
    </div>
    <div class="gb_window_part_content">
      <form action="" method="post" enctype="multipart/form-data">
        <input type="hidden" name="token" value="{/envelope/token}"/>
        <input type="hidden" name="cmd" value="save_filter"/>
        <input type="hidden" name="caller" value="{/envelope/caller}"/>
        <input type="hidden"
               name="filter_id"
               value="{commands_response/get_filters_response/filter/@id}"/>
        <input type="hidden" name="next" value="{/envelope/params/next}"/>
        <input type="hidden" name="filter" value="{/envelope/params/filter}"/>
        <input type="hidden" name="filt_id" value="{/envelope/params/filt_id}"/>
        <table border="0" cellspacing="0" cellpadding="3" width="100%">
          <tr>
            <td valign="top" width="165">Name</td>
            <td>
              <input type="text"
                     name="name"
                     value="{commands_response/get_filters_response/filter/name}"
                     size="30"
                     maxlength="80"/>
            </td>
          </tr>
          <tr>
            <td valign="top" width="175">Comment (optional)</td>
            <td>
              <input type="text" name="comment" size="30" maxlength="400"
                     value="{commands_response/get_filters_response/filter/comment}"/>
            </td>
          </tr>
          <tr>
            <td valign="top" width="175">Term</td>
            <td>
              <input type="text" name="term"
                     value="{commands_response/get_filters_response/filter/term}"
                     size="50"
                     maxlength="1000"/>
            </td>
          </tr>
          <tr>
            <td valign="top" width="175">Type</td>
            <td>
              <select name="optional_resource_type">
                <xsl:variable name="type">
                  <xsl:value-of select="commands_response/get_filters_response/filter/type"/>
                </xsl:variable>
                <option value="">--</option>
                <xsl:for-each select="str:split ('Agent|Alert|Config|Credential|Filter|Note|Override|Permission|Port List|Report|Report Format|Schedule|Slave|Tag|Target|Task|SecInfo', '|')">
                  <xsl:choose>
                    <xsl:when test=". = $type">
                      <option value="{.}" selected="1"><xsl:value-of select="$type"/></option>
                    </xsl:when>
                    <xsl:otherwise>
                      <option value="{.}"><xsl:value-of select="."/></option>
                    </xsl:otherwise>
                  </xsl:choose>
                </xsl:for-each>
              </select>
            </td>
          </tr>
          <tr>
            <td colspan="2" style="text-align:right;">
              <input type="submit" name="submit" value="Save Filter"/>
            </td>
          </tr>
        </table>
        <br/>
      </form>
    </div>
  </div>
</xsl:template>

<xsl:template match="edit_filter">
  <xsl:apply-templates select="gsad_msg"/>
  <xsl:call-template name="html-edit-filter-form"/>
</xsl:template>

<!--     GET_FILTER -->

<xsl:template match="get_filter">
  <xsl:apply-templates select="gsad_msg"/>
  <xsl:apply-templates select="commands_response/delete_filter_response"/>
  <xsl:apply-templates select="get_filters_response/filter" mode="details"/>
</xsl:template>

<!--     GET_FILTERS -->

<xsl:template match="get_filters">
  <xsl:apply-templates select="gsad_msg"/>
  <xsl:apply-templates select="delete_filter_response"/>
  <xsl:apply-templates select="create_filter_response"/>
  <!-- The for-each makes the get_filters_response the current node. -->
  <xsl:for-each select="get_filters_response | commands_response/get_filters_response">
    <xsl:choose>
      <xsl:when test="substring(@status, 1, 1) = '4' or substring(@status, 1, 1) = '5'">
        <xsl:call-template name="command_result_dialog">
          <xsl:with-param name="operation">
            Get Filters
          </xsl:with-param>
          <xsl:with-param name="status">
            <xsl:value-of select="@status"/>
          </xsl:with-param>
          <xsl:with-param name="msg">
            <xsl:value-of select="@status_text"/>
          </xsl:with-param>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="html-filters-table"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:for-each>
</xsl:template>

<!-- END FILTERS MANAGEMENT -->


<!-- BEGIN TAGS MANAGEMENT -->

<xsl:template name="tagged_resource_link">
  <xsl:param name="res_type"/>
  <xsl:param name="res_id"/>
  <xsl:param name="res_name"/>
  <xsl:param name="token"/>
  <xsl:choose>
    <xsl:when test="$res_type='cve' or $res_type='cpe' or $res_type='ovaldef' or $res_type='dfn_cert_adv'">
      <a href="/omp?cmd=get_info&amp;info_type={$res_type}&amp;info_id={$res_id}&amp;details=1&amp;token={$token}">
        <xsl:value-of select="$res_name"/>
      </a>
    </xsl:when>
    <xsl:when test="$res_type='nvt'">
      <a href="/omp?cmd=get_nvts&amp;oid={$res_id}&amp;details=1&amp;token={$token}">
        <xsl:value-of select="$res_name"/>
      </a>
    </xsl:when>
    <xsl:otherwise>
      <a href="/omp?cmd=get_{$res_type}&amp;{$res_type}_id={$res_id}&amp;details=1&amp;token={$token}">
        <xsl:value-of select="$res_name"/>
      </a>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template match="get_tags">
  <xsl:apply-templates select="gsad_msg"/>

  <xsl:apply-templates select="delete_tag_response"/>
  <xsl:apply-templates select="create_filter_response"/>
  <xsl:apply-templates select="create_tag_response"/>

  <!-- The for-each makes the get_targets_response the current node. -->
  <xsl:for-each select="get_tags_response | commands_response/get_tags_response">
    <xsl:choose>
      <xsl:when test="substring(@status, 1, 1) = '4' or substring(@status, 1, 1) = '5'">
        <xsl:call-template name="command_result_dialog">
          <xsl:with-param name="operation">
            Get Tags
          </xsl:with-param>
          <xsl:with-param name="status">
            <xsl:value-of select="@status"/>
          </xsl:with-param>
          <xsl:with-param name="msg">
            <xsl:value-of select="@status_text"/>
          </xsl:with-param>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="html-tags-table"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:for-each>
</xsl:template>

<xsl:template name="html-tags-table">
  <xsl:call-template name="list-window">
    <xsl:with-param name="type" select="'tag'"/>
    <xsl:with-param name="cap-type" select="'Tag'"/>
    <xsl:with-param name="resources-summary" select="tags"/>
    <xsl:with-param name="resources" select="tag"/>
    <xsl:with-param name="count" select="count (tag)"/>
    <xsl:with-param name="filtered-count" select="tag_count/filtered"/>
    <xsl:with-param name="full-count" select="tag_count/text ()"/>
    <xsl:with-param name="headings" select="'Name|name Value|value Active|active Attach&#xa0;Type|attach_type Attach&#xa0;Name|attach_name Modified|modified'"/>
  </xsl:call-template>
</xsl:template>

<xsl:template match="tag">
  <xsl:variable name="class">
    <xsl:choose>
      <xsl:when test="position() mod 2 = 0">even</xsl:when>
      <xsl:otherwise>odd</xsl:otherwise>
    </xsl:choose>
  </xsl:variable>
  <tr class="{$class}">
    <td>
      <b>
        <a href="/omp?cmd=get_tag&amp;tag_id={@id}&amp;filter={str:encode-uri (../filters/term, true ())}&amp;first={../tags/@start}&amp;max={../tags/@max}&amp;token={/envelope/token}">
          <xsl:value-of select="name"/>
        </a>
      </b>
      <xsl:choose>
        <xsl:when test="comment != ''">
          <br/>(<xsl:value-of select="comment"/>)
        </xsl:when>
        <xsl:otherwise></xsl:otherwise>
      </xsl:choose>
    </td>
    <td>
      <xsl:value-of select="value"/>
    </td>
    <td>
      <xsl:choose>
        <xsl:when test="active=0">
          No
        </xsl:when>
        <xsl:otherwise>
          Yes
        </xsl:otherwise>
      </xsl:choose>
    </td>
    <td>
      <xsl:value-of select="attach/type"/>
    </td>
    <td>
      <xsl:choose>
        <xsl:when test="orphaned='0' and attach/name!=''">
          <xsl:call-template name="tagged_resource_link">
            <xsl:with-param name="res_type" select="attach/type"/>
            <xsl:with-param name="res_id" select="attach/id"/>
            <xsl:with-param name="res_name" select="attach/name"/>
            <xsl:with-param name="token" select="/envelope/token"/>
          </xsl:call-template>
        </xsl:when>
        <xsl:otherwise>
          N/A <i>(ID: <xsl:value-of select="attach/id"/>)</i>
        </xsl:otherwise>
      </xsl:choose>
    </td>
    <td>
      <xsl:value-of select="gsa:date (modification_time)"/>
    </td>
    <td>
      <xsl:call-template name="list-window-line-icons">
        <xsl:with-param name="cap-type" select="'Tag'"/>
        <xsl:with-param name="type" select="'tag'"/>
        <xsl:with-param name="id" select="@id"/>
      </xsl:call-template>
    </td>
  </tr>
</xsl:template>

<xsl:template match="get_tag">
  <xsl:apply-templates select="gsad_msg"/>
  <xsl:apply-templates select="commands_response/delete_tag_response"/>
  <xsl:apply-templates select="get_tags_response/tag" mode="details"/>
</xsl:template>

<xsl:template match="tag" mode="details">
  <div class="gb_window">
    <div class="gb_window_part_left"></div>
    <div class="gb_window_part_right"></div>
    <div class="gb_window_part_center">
      Tag Details
      <xsl:call-template name="details-header-icons">
        <xsl:with-param name="cap-type" select="'Tag'"/>
        <xsl:with-param name="type" select="'tag'"/>
      </xsl:call-template>
    </div>
    <div class="gb_window_part_content">
      <xsl:call-template name="minor-details"/>
      <h1>
        <xsl:value-of select="name"/>
        <xsl:if test="value != ''">=&quot;<xsl:value-of select="value"/>&quot;</xsl:if>
      </h1>
      <table>
        <tr>
          <td><b>Name:</b></td>
          <td><b><xsl:value-of select="name"/></b></td>
        </tr>
        <tr>
          <td>Value:</td>
          <td><xsl:value-of select="value"/></td>
        </tr>
        <tr>
          <td>Comment:</td>
          <td><xsl:value-of select="comment"/></td>
        </tr>
        <xsl:choose>
          <xsl:when test="attach/name != '' and orphaned='0'">
            <tr>
              <td>Attached to resource:</td>
              <td>
                <xsl:call-template name="tagged_resource_link">
                  <xsl:with-param name="res_type" select="attach/type"/>
                  <xsl:with-param name="res_id" select="attach/id"/>
                  <xsl:with-param name="res_name" select="attach/name"/>
                  <xsl:with-param name="token" select="/envelope/token"/>
                </xsl:call-template>
              </td>
            </tr>
          </xsl:when>
        </xsl:choose>
        <tr>
          <td>Attached to resource type:</td>
          <td><xsl:value-of select="attach/type"/></td>
        </tr>
        <tr>
          <td>Attached to resource ID:</td>
          <td><xsl:value-of select="attach/id"/></td>
        </tr>
        <tr>
          <td>Active:</td>
          <td>
            <xsl:choose>
              <xsl:when test="active = 0">No</xsl:when>
              <xsl:otherwise>Yes</xsl:otherwise>
            </xsl:choose>
          </td>
        </tr>
        <tr>
          <td>Orphaned:</td>
          <td>
            <xsl:choose>
              <xsl:when test="orphaned = 0">No</xsl:when>
              <xsl:otherwise>Yes</xsl:otherwise>
            </xsl:choose>
          </td>
        </tr>
      </table>
    </div>
  </div>
</xsl:template>

<xsl:template match="tag" mode="trash">
  <xsl:variable name="class">
    <xsl:choose>
      <xsl:when test="position() mod 2 = 0">even</xsl:when>
      <xsl:otherwise>odd</xsl:otherwise>
    </xsl:choose>
  </xsl:variable>
  <tr class="{$class}">
    <td>
      <b><xsl:value-of select="name"/></b>
      <xsl:choose>
        <xsl:when test="comment != ''">
          <br/>(<xsl:value-of select="comment"/>)
        </xsl:when>
        <xsl:otherwise></xsl:otherwise>
      </xsl:choose>
    </td>
    <td><xsl:value-of select="value"/></td>
    <td><xsl:value-of select="attach/type"/></td>
    <td><xsl:value-of select="attach/id"/></td>
    <td>
      <xsl:call-template name="restore-icon">
        <xsl:with-param name="id" select="@id"/>
      </xsl:call-template>
      <xsl:choose>
        <xsl:when test="in_use='0'">
          <xsl:call-template name="trash-delete-icon">
            <xsl:with-param name="type" select="'tag'"/>
            <xsl:with-param name="id" select="@id"/>
          </xsl:call-template>
        </xsl:when>
        <xsl:otherwise>
          <img src="/img/delete_inactive.png"
               border="0"
               alt="Delete"
               style="margin-left:3px;"/>
        </xsl:otherwise>
      </xsl:choose>
    </td>
  </tr>
</xsl:template>

<xsl:template name="tag_attach_types">
  <xsl:param name="select_type"/>
  <xsl:call-template name="opt">
    <xsl:with-param name="value" select="'agent'"/>
    <xsl:with-param name="content" select="'Agent'"/>
    <xsl:with-param name="select-value" select="$select_type"/>
  </xsl:call-template>
  <xsl:call-template name="opt">
    <xsl:with-param name="value" select="'alert'"/>
    <xsl:with-param name="content" select="'Alert'"/>
    <xsl:with-param name="select-value" select="$select_type"/>
  </xsl:call-template>
  <xsl:call-template name="opt">
    <xsl:with-param name="value" select="'cpe'"/>
    <xsl:with-param name="content" select="'CPE'"/>
    <xsl:with-param name="select-value" select="$select_type"/>
  </xsl:call-template>
  <xsl:call-template name="opt">
    <xsl:with-param name="value" select="'lsc_credential'"/>
    <xsl:with-param name="content" select="'Credential'"/>
    <xsl:with-param name="select-value" select="$select_type"/>
  </xsl:call-template>
  <xsl:call-template name="opt">
    <xsl:with-param name="value" select="'cve'"/>
    <xsl:with-param name="content" select="'CVE'"/>
    <xsl:with-param name="select-value" select="$select_type"/>
  </xsl:call-template>
  <xsl:call-template name="opt">
    <xsl:with-param name="value" select="'dfn_cert_adv'"/>
    <xsl:with-param name="content" select="'DFN-CERT Advisory'"/>
    <xsl:with-param name="select-value" select="$select_type"/>
  </xsl:call-template>
  <xsl:call-template name="opt">
    <xsl:with-param name="value" select="'filter'"/>
    <xsl:with-param name="content" select="'Filter'"/>
    <xsl:with-param name="select-value" select="$select_type"/>
  </xsl:call-template>
  <xsl:call-template name="opt">
    <xsl:with-param name="value" select="'group'"/>
    <xsl:with-param name="content" select="'Group'"/>
    <xsl:with-param name="select-value" select="$select_type"/>
  </xsl:call-template>
  <xsl:call-template name="opt">
    <xsl:with-param name="value" select="'note'"/>
    <xsl:with-param name="content" select="'Note'"/>
    <xsl:with-param name="select-value" select="$select_type"/>
  </xsl:call-template>
  <xsl:call-template name="opt">
    <xsl:with-param name="value" select="'nvt'"/>
    <xsl:with-param name="content" select="'NVT'"/>
    <xsl:with-param name="select-value" select="$select_type"/>
  </xsl:call-template>
  <xsl:call-template name="opt">
    <xsl:with-param name="value" select="'ovaldef'"/>
    <xsl:with-param name="content" select="'OVAL definition'"/>
    <xsl:with-param name="select-value" select="$select_type"/>
  </xsl:call-template>
  <xsl:call-template name="opt">
    <xsl:with-param name="value" select="'override'"/>
    <xsl:with-param name="content" select="'Override'"/>
    <xsl:with-param name="select-value" select="$select_type"/>
  </xsl:call-template>
  <xsl:call-template name="opt">
    <xsl:with-param name="value" select="'permission'"/>
    <xsl:with-param name="content" select="'Permission'"/>
    <xsl:with-param name="select-value" select="$select_type"/>
  </xsl:call-template>
  <xsl:call-template name="opt">
    <xsl:with-param name="value" select="'port_list'"/>
    <xsl:with-param name="content" select="'Port list'"/>
    <xsl:with-param name="select-value" select="$select_type"/>
  </xsl:call-template>
  <xsl:call-template name="opt">
    <xsl:with-param name="value" select="'report'"/>
    <xsl:with-param name="content" select="'Report'"/>
    <xsl:with-param name="select-value" select="$select_type"/>
  </xsl:call-template>
  <xsl:call-template name="opt">
    <xsl:with-param name="value" select="'report_format'"/>
    <xsl:with-param name="content" select="'Report Format'"/>
    <xsl:with-param name="select-value" select="$select_type"/>
  </xsl:call-template>
  <xsl:call-template name="opt">
    <xsl:with-param name="value" select="'config'"/>
    <xsl:with-param name="content" select="'Scan Configuration'"/>
    <xsl:with-param name="select-value" select="$select_type"/>
  </xsl:call-template>
  <xsl:call-template name="opt">
    <xsl:with-param name="value" select="'schedule'"/>
    <xsl:with-param name="content" select="'Schedule'"/>
    <xsl:with-param name="select-value" select="$select_type"/>
  </xsl:call-template>
  <xsl:call-template name="opt">
    <xsl:with-param name="value" select="'slave'"/>
    <xsl:with-param name="content" select="'Slave'"/>
    <xsl:with-param name="select-value" select="$select_type"/>
  </xsl:call-template>
  <xsl:call-template name="opt">
    <xsl:with-param name="value" select="'target'"/>
    <xsl:with-param name="content" select="'Target'"/>
    <xsl:with-param name="select-value" select="$select_type"/>
  </xsl:call-template>
  <xsl:call-template name="opt">
    <xsl:with-param name="value" select="'task'"/>
    <xsl:with-param name="content" select="'Task'"/>
    <xsl:with-param name="select-value" select="$select_type"/>
  </xsl:call-template>
  <xsl:call-template name="opt">
    <xsl:with-param name="value" select="'user'"/>
    <xsl:with-param name="content" select="'User'"/>
    <xsl:with-param name="select-value" select="$select_type"/>
  </xsl:call-template>
</xsl:template>

<xsl:template match="new_tag">
  <xsl:apply-templates select="gsad_msg"/>
  <xsl:apply-templates select="create_tag_response"/>
  <xsl:apply-templates select="commands_response/delete_tag_response"/>
  <xsl:call-template name="html-create-tag-form"/>
  <!-- <xsl:call-template name="html-import-tag-form"/> -->
</xsl:template>

<xsl:template name="html-create-tag-form">
  <div class="gb_window">
    <div class="gb_window_part_left"></div>
    <div class="gb_window_part_right"></div>
    <div class="gb_window_part_center">New Tag
      <a href="/help/new_tag.html?token={/envelope/token}"
         title="Help: New Tag">
        <img src="/img/help.png"/>
      </a>
      <a href="/omp?cmd=get_tags&amp;filter={str:encode-uri (/envelope/params/filter, true ())}&amp;filt_id={/envelope/params/filt_id}&amp;token={/envelope/token}"
         title="Tags" style="margin-left:3px;">
        <img src="/img/list.png" border="0" alt="Tags"/>
      </a>
    </div>
    <div class="gb_window_part_content">
      <form action="/omp" method="post" enctype="multipart/form-data">
        <input type="hidden" name="token" value="{/envelope/token}"/>
        <input type="hidden" name="cmd" value="create_tag"/>
        <input type="hidden" name="caller" value="{/envelope/caller}"/>
        <input type="hidden" name="filter" value="{filters/term}"/>
        <input type="hidden" name="first" value="{targets/@start}"/>
        <input type="hidden" name="max" value="{targets/@max}"/>
        <table border="0" cellspacing="0" cellpadding="3" width="100%">
          <tr>
            <td valign="top" width="175">Name
            </td>
            <td>
              <input type="text" name="tag_name" value="{tag_name}" size="30"
                     maxlength="80"/>
            </td>
          </tr>
          <tr>
            <td valign="top" width="175">Value (Optional)
            </td>
            <td>
              <input type="text" name="tag_value" value="{tag_value}" size="30"
                     maxlength="200"/>
            </td>
          </tr>
          <tr>
            <td valign="top" width="175">Comment (optional)</td>
            <td>
              <input type="text" name="comment" value="{comment}" size="30"
                     maxlength="400"/>
            </td>
          </tr>
          <tr>
            <td valign="top" width="175">Attach to Type</td>
            <td>
              <select name="attach_type">
                <xsl:call-template name="tag_attach_types">
                  <xsl:with-param name="select_type">
                    <xsl:value-of select="attach_type"/>
                  </xsl:with-param>
                </xsl:call-template>
              </select>
            </td>
          </tr>
          <tr>
            <td valign="top" width="175">Attach to ID</td>
            <td>
              <input type="text" name="attach_id" value="{attach_id}" size="30"
                         maxlength="80"/>
            </td>
          </tr>
          <tr>
            <td>Active</td>
            <td>
              <label>
                <xsl:choose>
                  <xsl:when test="active!=0">
                    <input type="radio" name="active" value="1" checked="1"/>
                  </xsl:when>
                  <xsl:otherwise>
                    <input type="radio" name="active" value="1"/>
                  </xsl:otherwise>
                </xsl:choose>
                Yes
              </label>
              <label>
                <xsl:choose>
                  <xsl:when test="active=0">
                    <input type="radio" name="active" value="0" checked="1"/>
                  </xsl:when>
                  <xsl:otherwise>
                    <input type="radio" name="active" value="0"/>
                  </xsl:otherwise>
                </xsl:choose>
                No
              </label>
            </td>
          </tr>
          <tr>
            <td colspan="2" style="text-align:right;">
              <input type="submit" name="submit" value="Create Tag"/>
            </td>
          </tr>
        </table>
      </form>
    </div>
  </div>
</xsl:template>

<xsl:template match="edit_tag">
  <xsl:apply-templates select="gsad_msg"/>
  <xsl:call-template name="html-edit-tag-form"/>
</xsl:template>

<xsl:template name="html-edit-tag-form">
  <div class="gb_window">
    <div class="gb_window_part_left"></div>
    <div class="gb_window_part_right"></div>
    <div class="gb_window_part_center">Edit Tag
      <xsl:call-template name="edit-header-icons">
        <xsl:with-param name="cap-type" select="'Tag'"/>
        <xsl:with-param name="type" select="'tag'"/>
        <xsl:with-param name="id"
                        select="get_tags_response/tag/@id"/>
      </xsl:call-template>
    </div>
    <div class="gb_window_part_content">
      <form action="" method="post" enctype="multipart/form-data">
        <input type="hidden" name="token" value="{/envelope/token}"/>
        <input type="hidden" name="cmd" value="save_tag"/>
        <input type="hidden" name="caller" value="{/envelope/caller}"/>
        <input type="hidden"
               name="tag_id"
               value="{get_tags_response/tag/@id}"/>
        <input type="hidden" name="next" value="{next}"/>
        <input type="hidden" name="sort_field" value="{sort_field}"/>
        <input type="hidden" name="sort_order" value="{sort_order}"/>
        <input type="hidden" name="filter" value="{filters/term}"/>
        <input type="hidden" name="filt_id" value="{/envelope/params/filt_id}"/>
        <input type="hidden" name="first" value="{tags/@start}"/>
        <input type="hidden" name="max" value="{tags/@max}"/>
        <table border="0" cellspacing="0" cellpadding="3" width="100%">
          <tr>
            <td valign="top" width="175">Name
            </td>
            <td>
              <input type="text" name="tag_name" value="{get_tags_response/tag/name}" size="30"
                     maxlength="80"/>
            </td>
          </tr>
          <tr>
            <td valign="top" width="175">Value (Optional)
            </td>
            <td>
              <input type="text" name="tag_value" value="{get_tags_response/tag/value}" size="30"
                     maxlength="200"/>
            </td>
          </tr>
          <tr>
            <td valign="top" width="175">Comment (optional)</td>
            <td>
              <input type="text" name="comment" value="{get_tags_response/tag/comment}" size="30"
                     maxlength="400"/>
            </td>
          </tr>
          <tr>
            <td valign="top" width="175">Attach to Type</td>
            <td>
              <select name="attach_type">
                <xsl:call-template name="tag_attach_types">
                  <xsl:with-param name="select_type">
                    <xsl:value-of select="get_tags_response/tag/attach/type"/>
                  </xsl:with-param>
                </xsl:call-template>
              </select>
            </td>
          </tr>
          <tr>
            <td valign="top" width="175">Attach to ID</td>
            <td>
              <input type="text" name="attach_id" value="{get_tags_response/tag/attach/id}" size="30"
                         maxlength="80"/>
            </td>
          </tr>
          <tr>
            <td>Active</td>
            <td>
              <label>
                <xsl:choose>
                  <xsl:when test="get_tags_response/tag/active!=0">
                    <input type="radio" name="active" value="1" checked="1"/>
                  </xsl:when>
                  <xsl:otherwise>
                    <input type="radio" name="active" value="1"/>
                  </xsl:otherwise>
                </xsl:choose>
                Yes
              </label>
              <label>
                <xsl:choose>
                  <xsl:when test="get_tags_response/tag/active=0">
                    <input type="radio" name="active" value="0" checked="1"/>
                  </xsl:when>
                  <xsl:otherwise>
                    <input type="radio" name="active" value="0"/>
                  </xsl:otherwise>
                </xsl:choose>
                No
              </label>
            </td>
          </tr>
          <tr>
            <td colspan="2" style="text-align:right;">
              <input type="submit" name="submit" value="Save Tag"/>
            </td>
          </tr>
        </table>
      </form>
    </div>
  </div>
</xsl:template>

<xsl:template match="modify_tag_response">
  <xsl:call-template name="command_result_dialog">
    <xsl:with-param name="operation">Save Tag</xsl:with-param>
    <xsl:with-param name="status">
      <xsl:value-of select="@status"/>
    </xsl:with-param>
    <xsl:with-param name="msg">
      <xsl:value-of select="@status_text"/>
    </xsl:with-param>
  </xsl:call-template>
</xsl:template>

<!-- END TAGS MANAGEMENT -->


<!-- BEGIN TARGET LOCATORS MANAGEMENT -->

<xsl:template match="target_locator" mode="select">
  <option value="{name}"><xsl:value-of select="name"/></option>
</xsl:template>

<!-- END TARGET LOCATORS MANAGEMENT -->

<!-- BEGIN TARGETS MANAGEMENT -->

<xsl:template match="modify_target_response">
  <xsl:call-template name="command_result_dialog">
    <xsl:with-param name="operation">Save Target</xsl:with-param>
    <xsl:with-param name="status">
      <xsl:value-of select="@status"/>
    </xsl:with-param>
    <xsl:with-param name="msg">
      <xsl:value-of select="@status_text"/>
    </xsl:with-param>
  </xsl:call-template>
</xsl:template>

<xsl:template match="port_list" mode="select">
  <option value="{@id}"><xsl:value-of select="name"/></option>
</xsl:template>

<xsl:template name="html-create-target-form">
  <xsl:param name="lsc-credentials"></xsl:param>
  <xsl:param name="target-sources"></xsl:param>
  <xsl:param name="port-lists"></xsl:param>
  <div class="gb_window">
    <div class="gb_window_part_left"></div>
    <div class="gb_window_part_right"></div>
    <div class="gb_window_part_center">New Target
      <a href="/help/new_target.html?token={/envelope/token}"
         title="Help: New Target">
        <img src="/img/help.png"/>
      </a>
      <a href="/omp?cmd=get_targets&amp;filter={str:encode-uri (/envelope/params/filter, true ())}&amp;filt_id={/envelope/params/filt_id}&amp;token={/envelope/token}"
         title="Targets" style="margin-left:3px;">
        <img src="/img/list.png" border="0" alt="Targets"/>
      </a>
    </div>
    <div class="gb_window_part_content">
      <form action="/omp" method="post" enctype="multipart/form-data">
        <input type="hidden" name="token" value="{/envelope/token}"/>
        <input type="hidden" name="cmd" value="create_target"/>
        <input type="hidden" name="caller" value="{/envelope/caller}"/>
        <input type="hidden" name="target_id" value="{target/@id}"/>
        <input type="hidden" name="filter" value="{filters/term}"/>
        <input type="hidden" name="first" value="{targets/@start}"/>
        <input type="hidden" name="max" value="{targets/@max}"/>
        <table border="0" cellspacing="0" cellpadding="3" width="100%">
          <tr>
            <td valign="top" width="175">Name
            </td>
            <td>
              <input type="text" name="name" value="unnamed" size="30"
                     maxlength="80"/>
            </td>
          </tr>
          <tr>
          <td valign="top" width="175">Hosts</td>
          <xsl:choose>
            <xsl:when test="not ($target-sources/target_locator)">
              <!-- No target locator(s) given. -->
              <td>
                <xsl:value-of select="$target-sources"/>
                <table>
                  <tr>
                    <td>
                      <label>
                        <input type="radio" name="target_source" value="manual"
                               checked="1"/>
                        Manual
                      </label>
                    </td>
                    <td>
                      <input type="text" name="hosts" value="localhost" size="30"
                              maxlength="2000"/>
                    </td>
                  </tr>
                  <tr>
                    <td>
                      <label>
                        <input type="radio" name="target_source" value="file"/>
                        From file
                      </label>
                    </td>
                    <td>
                      <input type="file" name="file" size="30"/>
                    </td>
                  </tr>
                </table>
              </td>
            </xsl:when>
            <xsl:otherwise>
              <!-- Target locator(s) given. -->
              <td>
                <xsl:value-of select="$target-sources"/>
                <table>
                  <tr>
                    <td>
                      <label>
                        <input type="radio" name="target_source" value="manual"
                               checked="1"/>
                        Manual
                      </label>
                    </td>
                    <td>
                      <input type="text" name="hosts" value="localhost" size="30"
                             maxlength="2000"/>
                    </td>
                  </tr>
                  <tr>
                    <td>
                      <label>
                        <input type="radio" name="target_source" value="file"/>
                        From file
                      </label>
                    </td>
                    <td>
                      <input type="file" name="file" size="30"/>
                    </td>
                  </tr>
                  <tr>
                    <td>
                      <label>
                        <input type="radio" name="target_source" value="import"/>
                        Import
                      </label>
                    </td>
                    <td>
                      <select name="target_locator">
                        <xsl:apply-templates select="$target-sources" mode="select"/>
                      </select>
                    </td>
                  </tr>
                  <tr>
                    <td></td>
                    <td>
                      Import Authentication
                    </td>
                  </tr>
                  <tr>
                    <td></td>
                    <td>
                      <table>
                      <tr>
                        <td>Username</td>
                        <td>
                          <input type="text" name="login" value="" size="15"
                                maxlength="80"/>
                        </td>
                      </tr>
                      <tr>
                        <td>Password</td>
                        <td>
                          <input type="password" autocomplete="off"
                                 name="password" value="" size="15"
                                 maxlength="80"/>
                        </td>
                      </tr>
                      </table>
                    </td>
                  </tr>
                </table>
              </td>
            </xsl:otherwise>
          </xsl:choose>
          </tr>
          <tr>
            <td valign="top" width="175">Comment (optional)</td>
            <td>
              <input type="text" name="comment" size="30" maxlength="400"/>
            </td>
          </tr>
          <tr>
            <td valign="top" width="175">Port List</td>
            <td>
              <select name="port_list_id">
                <xsl:apply-templates select="$port-lists" mode="select"/>
              </select>
            </td>
          </tr>
          <tr>
            <td valign="top" width="175">SSH Credential (optional)</td>
            <td>
              <select name="lsc_credential_id">
                <option value="--">--</option>
                <xsl:apply-templates select="$lsc-credentials" mode="select"/>
              </select>
              on port
              <input type="text" name="port" value="22" size="6"
                     maxlength="400"/>
            </td>
          </tr>
          <tr>
            <td valign="top" width="175">SMB Credential (optional)</td>
            <td>
              <select name="lsc_smb_credential_id">
                <option value="--">--</option>
                <xsl:apply-templates select="$lsc-credentials" mode="select"/>
              </select>
            </td>
          </tr>
          <tr>
            <td colspan="2" style="text-align:right;">
              <input type="submit" name="submit" value="Create Target"/>
            </td>
          </tr>
        </table>
      </form>
    </div>
  </div>
</xsl:template>

<xsl:template name="html-edit-target-form">
  <div class="gb_window">
    <div class="gb_window_part_left"></div>
    <div class="gb_window_part_right"></div>
    <div class="gb_window_part_center">Edit Target
      <xsl:call-template name="edit-header-icons">
        <xsl:with-param name="cap-type" select="'Target'"/>
        <xsl:with-param name="type" select="'target'"/>
        <xsl:with-param name="id"
                        select="commands_response/get_targets_response/target/@id"/>
      </xsl:call-template>
    </div>
    <div class="gb_window_part_content">
      <form action="" method="post" enctype="multipart/form-data">
        <input type="hidden" name="token" value="{/envelope/token}"/>
        <input type="hidden" name="cmd" value="save_target"/>
        <input type="hidden" name="caller" value="{/envelope/caller}"/>
        <input type="hidden"
               name="target_id"
               value="{commands_response/get_targets_response/target/@id}"/>
        <input type="hidden" name="next" value="{next}"/>
        <input type="hidden" name="sort_field" value="{sort_field}"/>
        <input type="hidden" name="sort_order" value="{sort_order}"/>
        <input type="hidden" name="filter" value="{filters/term}"/>
        <input type="hidden" name="filt_id" value="{/envelope/params/filt_id}"/>
        <input type="hidden" name="first" value="{targets/@start}"/>
        <input type="hidden" name="max" value="{targets/@max}"/>
        <table border="0" cellspacing="0" cellpadding="3" width="100%">
          <tr>
            <td valign="top" width="165">Name</td>
            <td>
              <input type="text"
                     name="name"
                     value="{commands_response/get_targets_response/target/name}"
                     size="30"
                     maxlength="80"/>
            </td>
          </tr>
          <tr>
          <td valign="top" width="175">Hosts</td>
          <xsl:choose>
            <xsl:when test="not (commands_response/get_target_locators_response/target_locator)">
              <!-- No target locator(s) given. -->
              <td>
                <table>
                  <tr>
                    <td>
                      <label>
                        <input type="radio" name="target_source" value="manual"
                               checked="1"/>
                        Manual
                      </label>
                    </td>
                    <td>
                      <input type="text" name="hosts"
                             value="{commands_response/get_targets_response/target/hosts}"
                             size="30"
                             maxlength="2000"/>
                    </td>
                  </tr>
                  <tr>
                    <td>
                      <label>
                        <input type="radio" name="target_source" value="file"/>
                        From file
                      </label>
                    </td>
                    <td>
                      <input type="file" name="file" size="30"/>
                    </td>
                  </tr>
                </table>
              </td>
            </xsl:when>
            <xsl:otherwise>
              <!-- Target locator(s) given. -->
              <td>
                <table>
                  <tr>
                    <td>
                      <label>
                        <input type="radio" name="target_source" value="manual"
                               checked="1"/>
                        Manual
                      </label>
                    </td>
                    <td>
                      <input type="text" name="hosts"
                             value="{commands_response/get_targets_response/target/hosts}"
                             size="30"
                             maxlength="2000"/>
                    </td>
                  </tr>
                  <tr>
                    <td>
                      <label>
                        <input type="radio" name="target_source" value="file"/>
                        From file
                      </label>
                    </td>
                    <td>
                      <input type="file" name="file" size="30"/>
                    </td>
                  </tr>
                  <tr>
                    <td>
                      <label>
                        <input type="radio" name="target_source" value="import"/>
                        Import
                      </label>
                    </td>
                    <td>
                      <select name="target_locator">
                        <xsl:apply-templates select="commands_response/get_target_locators_response/target_locator"
                                             mode="select"/>
                      </select>
                    </td>
                  </tr>
                  <tr>
                    <td></td>
                    <td>
                      Import Authentication
                    </td>
                  </tr>
                  <tr>
                    <td></td>
                    <td>
                      <table>
                      <tr>
                        <td>Username</td>
                        <td>
                          <input type="text" name="login" value="" size="15"
                                maxlength="80"/>
                        </td>
                      </tr>
                      <tr>
                        <td>Password</td>
                        <td>
                          <input type="password" autocomplete="off"
                                 name="password" value="" size="15"
                                 maxlength="80"/>
                        </td>
                      </tr>
                      </table>
                    </td>
                  </tr>
                </table>
              </td>
            </xsl:otherwise>
          </xsl:choose>
          </tr>
          <tr>
            <td valign="top" width="175">Comment (optional)</td>
            <td>
              <input type="text" name="comment" size="30" maxlength="400"
                     value="{commands_response/get_targets_response/target/comment}"/>
            </td>
          </tr>
          <tr>
            <td valign="top" width="175">Port List</td>
            <td>
              <select name="port_list_id">
                <xsl:variable name="port_list_id">
                  <xsl:value-of select="commands_response/get_targets_response/target/port_list/@id"/>
                </xsl:variable>
                <xsl:for-each select="commands_response/get_port_lists_response/port_list">
                  <xsl:choose>
                    <xsl:when test="@id = $port_list_id">
                      <option value="{@id}" selected="1"><xsl:value-of select="name"/></option>
                    </xsl:when>
                    <xsl:otherwise>
                      <option value="{@id}"><xsl:value-of select="name"/></option>
                    </xsl:otherwise>
                  </xsl:choose>
                </xsl:for-each>
              </select>
            </td>
          </tr>
          <tr>
            <td valign="top" width="175">SSH Credential (optional)</td>
            <td>
              <select name="lsc_credential_id">
                <xsl:variable name="lsc_credential_id">
                  <xsl:value-of select="commands_response/get_targets_response/target/ssh_lsc_credential/@id"/>
                </xsl:variable>
                <xsl:choose>
                  <xsl:when test="string-length ($lsc_credential_id) &gt; 0">
                    <option value="0">--</option>
                  </xsl:when>
                  <xsl:otherwise>
                    <option value="0" selected="1">--</option>
                  </xsl:otherwise>
                </xsl:choose>
                <xsl:for-each select="commands_response/get_lsc_credentials_response/lsc_credential">
                  <xsl:choose>
                    <xsl:when test="@id = $lsc_credential_id">
                      <option value="{@id}" selected="1"><xsl:value-of select="name"/></option>
                    </xsl:when>
                    <xsl:otherwise>
                      <option value="{@id}"><xsl:value-of select="name"/></option>
                    </xsl:otherwise>
                  </xsl:choose>
                </xsl:for-each>
              </select>
              on port
              <xsl:variable name="credential"
                            select="commands_response/get_targets_response/target/ssh_lsc_credential"/>
              <xsl:choose>
                <xsl:when test="$credential and string-length ($credential/port)">
                  <input type="text"
                         name="port"
                         value="{commands_response/get_targets_response/target/ssh_lsc_credential/port}"
                         size="6"
                         maxlength="400"/>
                </xsl:when>
                <xsl:otherwise>
                  <input type="text" name="port" value="22" size="6" maxlength="400"/>
                </xsl:otherwise>
              </xsl:choose>
            </td>
          </tr>
          <tr>
            <td valign="top" width="175">SMB Credential (optional)</td>
            <td>
              <select name="lsc_smb_credential_id">
                <xsl:variable name="lsc_credential_id">
                  <xsl:value-of select="commands_response/get_targets_response/target/smb_lsc_credential/@id"/>
                </xsl:variable>
                <xsl:choose>
                  <xsl:when test="string-length ($lsc_credential_id) &gt; 0">
                    <option value="0">--</option>
                  </xsl:when>
                  <xsl:otherwise>
                    <option value="0" selected="1">--</option>
                  </xsl:otherwise>
                </xsl:choose>
                <xsl:for-each select="commands_response/get_lsc_credentials_response/lsc_credential">
                  <xsl:choose>
                    <xsl:when test="@id = $lsc_credential_id">
                      <option value="{@id}" selected="1"><xsl:value-of select="name"/></option>
                    </xsl:when>
                    <xsl:otherwise>
                      <option value="{@id}"><xsl:value-of select="name"/></option>
                    </xsl:otherwise>
                  </xsl:choose>
                </xsl:for-each>
              </select>
            </td>
          </tr>
          <tr>
            <td colspan="2" style="text-align:right;">
              <input type="submit" name="submit" value="Save Target"/>
            </td>
          </tr>
        </table>
        <br/>
      </form>
    </div>
  </div>
</xsl:template>

<xsl:template match="edit_target">
  <xsl:apply-templates select="gsad_msg"/>
  <xsl:call-template name="html-edit-target-form"/>
</xsl:template>

<xsl:template name="column-name">
  <xsl:param name="type">target</xsl:param>
  <xsl:param name="head"/>
  <xsl:param name="name"/>
  <xsl:param name="current" select="."/>
  <xsl:param name="extra_params"/>
  <xsl:param name="token" select="/envelope/token"/>
  <xsl:choose>
    <xsl:when test="$current/sort/field/text() = $name and $current/sort/field/order = 'descending'">
      <a class="gbntablehead2" href="/omp?cmd=get_{gsa:type-many($type)}{$extra_params}&amp;filter=sort={$name} first=1 {$current/filters/term}&amp;token={$token}"><xsl:value-of select="$head"/></a>
    </xsl:when>
    <xsl:when test="$current/sort/field/text() = $name and $current/sort/field/order = 'ascending'">
      <a class="gbntablehead2" href="/omp?cmd=get_{gsa:type-many($type)}{$extra_params}&amp;filter=sort-reverse={$name} first=1 {$current/filters/term}&amp;token={$token}"><xsl:value-of select="$head"/></a>
    </xsl:when>
    <xsl:otherwise>
      <!-- Starts with some other column. -->
      <a class="gbntablehead2" href="/omp?cmd=get_{gsa:type-many($type)}{$extra_params}&amp;filter=sort={$name} first=1 {$current/filters/term}&amp;token={$token}"><xsl:value-of select="$head"/></a>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template name="html-targets-table">
  <xsl:call-template name="list-window">
    <xsl:with-param name="type" select="'target'"/>
    <xsl:with-param name="cap-type" select="'Target'"/>
    <xsl:with-param name="resources-summary" select="targets"/>
    <xsl:with-param name="resources" select="target"/>
    <xsl:with-param name="count" select="count (target)"/>
    <xsl:with-param name="filtered-count" select="target_count/filtered"/>
    <xsl:with-param name="full-count" select="target_count/text ()"/>
    <xsl:with-param name="headings" select="'Name|name Hosts|hosts IPs|ips Port&#xa0;List|port_list SSH&#xa0;Credential|ssh_credential SMB&#xa0;Credential|smb_credential'"/>
  </xsl:call-template>
</xsl:template>

<!--     CREATE_TARGET_RESPONSE -->

<xsl:template match="create_target_response">
  <xsl:call-template name="command_result_dialog">
    <xsl:with-param name="operation">Create Target</xsl:with-param>
    <xsl:with-param name="status">
      <xsl:value-of select="@status"/>
    </xsl:with-param>
    <xsl:with-param name="msg">
      <xsl:value-of select="@status_text"/>
    </xsl:with-param>
  </xsl:call-template>
</xsl:template>

<!--     DELETE_TARGET_RESPONSE -->

<xsl:template match="delete_target_response">
  <xsl:call-template name="command_result_dialog">
    <xsl:with-param name="operation">
      Delete Target
    </xsl:with-param>
    <xsl:with-param name="status">
      <xsl:value-of select="@status"/>
    </xsl:with-param>
    <xsl:with-param name="msg">
      <xsl:value-of select="@status_text"/>
    </xsl:with-param>
  </xsl:call-template>
</xsl:template>

<!--     TARGET -->

<xsl:template match="target">
  <xsl:variable name="class">
    <xsl:choose>
      <xsl:when test="position() mod 2 = 0">even</xsl:when>
      <xsl:otherwise>odd</xsl:otherwise>
    </xsl:choose>
  </xsl:variable>
  <tr class="{$class}">
    <td>
      <b>
        <a href="/omp?cmd=get_target&amp;target_id={@id}&amp;filter={str:encode-uri (../filters/term, true ())}&amp;first={../targets/@start}&amp;max={../targets/@max}&amp;token={/envelope/token}">
          <xsl:value-of select="name"/>
        </a>
      </b>
      <xsl:choose>
        <xsl:when test="comment != ''">
          <br/>(<xsl:value-of select="comment"/>)
        </xsl:when>
        <xsl:otherwise></xsl:otherwise>
      </xsl:choose>
    </td>
    <td>
      <xsl:variable name="max" select="500"/>
      <xsl:choose>
        <xsl:when test="string-length(hosts) &gt; $max">
          <xsl:value-of select="substring (hosts, 0, $max)"/>...
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="hosts"/>
        </xsl:otherwise>
      </xsl:choose>
    </td>
    <td><xsl:value-of select="max_hosts"/></td>
    <td>
      <a href="/omp?cmd=get_port_list&amp;port_list_id={port_list/@id}&amp;token={/envelope/token}">
        <xsl:value-of select="port_list/name"/>
      </a>
    </td>
    <td>
      <a href="/omp?cmd=get_lsc_credential&amp;lsc_credential_id={ssh_lsc_credential/@id}&amp;token={/envelope/token}">
        <xsl:value-of select="ssh_lsc_credential/name"/>
      </a>
    </td>
    <td>
      <a href="/omp?cmd=get_lsc_credential&amp;lsc_credential_id={smb_lsc_credential/@id}&amp;token={/envelope/token}">
        <xsl:value-of select="smb_lsc_credential/name"/>
      </a>
    </td>
    <td>
      <xsl:call-template name="list-window-line-icons">
        <xsl:with-param name="cap-type" select="'Target'"/>
        <xsl:with-param name="type" select="'target'"/>
        <xsl:with-param name="id" select="@id"/>
      </xsl:call-template>
    </td>
  </tr>
</xsl:template>

<xsl:template match="target" mode="trash">
  <xsl:variable name="class">
    <xsl:choose>
      <xsl:when test="position() mod 2 = 0">even</xsl:when>
      <xsl:otherwise>odd</xsl:otherwise>
    </xsl:choose>
  </xsl:variable>
  <tr class="{$class}">
    <td>
      <b><xsl:value-of select="name"/></b>
      <xsl:choose>
        <xsl:when test="comment != ''">
          <br/>(<xsl:value-of select="comment"/>)
        </xsl:when>
        <xsl:otherwise></xsl:otherwise>
      </xsl:choose>
    </td>
    <td><xsl:value-of select="hosts"/></td>
    <td><xsl:value-of select="max_hosts"/></td>
    <td>
      <xsl:choose>
        <xsl:when test="port_list/trash = '1'">
          <xsl:value-of select="port_list/name"/>
          <br/>(in trashcan)
        </xsl:when>
        <xsl:otherwise>
          <a href="/omp?cmd=get_port_list&amp;port_list_id={port_list/@id}&amp;token={/envelope/token}">
            <xsl:value-of select="port_list/name"/>
          </a>
        </xsl:otherwise>
      </xsl:choose>
    </td>
    <td>
      <xsl:choose>
        <xsl:when test="ssh_lsc_credential/trash = '1'">
          <xsl:value-of select="ssh_lsc_credential/name"/>
          <br/>(in trashcan)
        </xsl:when>
        <xsl:otherwise>
          <a href="/omp?cmd=get_lsc_credential&amp;lsc_credential_id={ssh_lsc_credential/@id}&amp;token={/envelope/token}">
            <xsl:value-of select="ssh_lsc_credential/name"/>
          </a>
        </xsl:otherwise>
      </xsl:choose>
    </td>
    <td>
      <xsl:choose>
        <xsl:when test="smb_lsc_credential/trash = '1'">
          <xsl:value-of select="smb_lsc_credential/name"/>
          <br/>(in trashcan)
        </xsl:when>
        <xsl:otherwise>
          <a href="/omp?cmd=get_lsc_credential&amp;lsc_credential_id={smb_lsc_credential/@id}&amp;token={/envelope/token}">
            <xsl:value-of select="smb_lsc_credential/name"/>
          </a>
        </xsl:otherwise>
      </xsl:choose>
    </td>
    <td>
      <xsl:choose>
        <xsl:when test="ssh_lsc_credential/trash = '1' or smb_lsc_credential/trash = '1' or port_list/trash = '1'">
          <img src="/img/restore_inactive.png" border="0" alt="Restore"
               style="margin-left:3px;"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:call-template name="restore-icon">
            <xsl:with-param name="id" select="@id"/>
          </xsl:call-template>
        </xsl:otherwise>
      </xsl:choose>
      <xsl:choose>
        <xsl:when test="in_use='0'">
          <xsl:call-template name="trash-delete-icon">
            <xsl:with-param name="type" select="'target'"/>
            <xsl:with-param name="id" select="@id"/>
          </xsl:call-template>
        </xsl:when>
        <xsl:otherwise>
          <img src="/img/delete_inactive.png"
               border="0"
               alt="Delete"
               style="margin-left:3px;"/>
        </xsl:otherwise>
      </xsl:choose>
    </td>
  </tr>
</xsl:template>

<xsl:template match="target" mode="details">
  <div class="gb_window">
    <div class="gb_window_part_left"></div>
    <div class="gb_window_part_right"></div>
    <div class="gb_window_part_center">
      Target Details
      <xsl:call-template name="details-header-icons">
        <xsl:with-param name="cap-type" select="'Target'"/>
        <xsl:with-param name="type" select="'target'"/>
      </xsl:call-template>
    </div>
    <div class="gb_window_part_content">
      <xsl:call-template name="minor-details"/>
      <table>
        <tr>
          <td><b>Name:</b></td>
          <td><b><xsl:value-of select="name"/></b></td>
        </tr>
        <tr>
          <td>Comment:</td>
          <td><xsl:value-of select="comment"/></td>
        </tr>
        <tr>
          <td>Hosts:</td>
          <td><xsl:value-of select="hosts"/></td>
        </tr>
        <tr>
          <td>Maximum number of hosts:</td>
          <td><xsl:value-of select="max_hosts"/></td>
        </tr>
        <tr>
          <td>Port List:</td>
          <td>
            <a href="/omp?cmd=get_port_list&amp;port_list_id={port_list/@id}&amp;token={/envelope/token}">
              <xsl:value-of select="port_list/name"/>
            </a>
          </td>
        </tr>
        <tr>
          <td>SSH Credential:</td>
          <td>
            <xsl:if test="string-length (ssh_lsc_credential/@id) &gt; 0">
              <a href="/omp?cmd=get_lsc_credential&amp;lsc_credential_id={ssh_lsc_credential/@id}&amp;token={/envelope/token}">
                <xsl:value-of select="ssh_lsc_credential/name"/>
              </a>
              on port
              <xsl:value-of select="ssh_lsc_credential/port"/>
            </xsl:if>
          </td>
        </tr>
        <tr>
          <td>SMB Credential:</td>
          <td>
            <a href="/omp?cmd=get_lsc_credential&amp;lsc_credential_id={smb_lsc_credential/@id}&amp;token={/envelope/token}">
              <xsl:value-of select="smb_lsc_credential/name"/>
            </a>
          </td>
        </tr>
      </table>

      <xsl:choose>
        <xsl:when test="count(tasks/task) = 0">
          <h1>Tasks using this Target: None</h1>
        </xsl:when>
        <xsl:otherwise>
          <h1>Tasks using this Target</h1>
          <table class="gbntable" cellspacing="2" cellpadding="4">
            <tr class="gbntablehead2">
              <td>Name</td>
              <td>Actions</td>
            </tr>
            <xsl:for-each select="tasks/task">
              <xsl:variable name="class">
                <xsl:choose>
                  <xsl:when test="position() mod 2 = 0">even</xsl:when>
                  <xsl:otherwise>odd</xsl:otherwise>
                </xsl:choose>
              </xsl:variable>
              <tr class="{$class}">
                <td><xsl:value-of select="name"/></td>
                <td width="100">
                  <a href="/omp?cmd=get_task&amp;task_id={@id}&amp;token={/envelope/token}" title="Details">
                    <img src="/img/details.png"
                         border="0"
                         alt="Details"
                         style="margin-left:3px;"/>
                  </a>
                </td>
              </tr>
            </xsl:for-each>
          </table>
        </xsl:otherwise>
      </xsl:choose>
    </div>
  </div>
</xsl:template>

<!--     GET_TARGET -->

<xsl:template match="get_target">
  <xsl:apply-templates select="gsad_msg"/>
  <xsl:apply-templates select="commands_response/delete_target_response"/>
  <xsl:apply-templates select="get_targets_response/target" mode="details"/>
</xsl:template>

<!--     GET_TARGETS -->

<xsl:template match="get_targets">
  <xsl:apply-templates select="gsad_msg"/>
  <xsl:apply-templates select="delete_target_response"/>
  <xsl:apply-templates select="create_filter_response"/>
  <xsl:apply-templates select="create_target_response"/>
  <!-- The for-each makes the get_targets_response the current node. -->
  <xsl:for-each select="get_targets_response | commands_response/get_targets_response">
    <xsl:choose>
      <xsl:when test="substring(@status, 1, 1) = '4' or substring(@status, 1, 1) = '5'">
        <xsl:call-template name="command_result_dialog">
          <xsl:with-param name="operation">
            Get Targets
          </xsl:with-param>
          <xsl:with-param name="status">
            <xsl:value-of select="@status"/>
          </xsl:with-param>
          <xsl:with-param name="msg">
            <xsl:value-of select="@status_text"/>
          </xsl:with-param>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="html-targets-table"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:for-each>
</xsl:template>

<!-- END TARGETS MANAGEMENT -->

<!-- BEGIN CONFIGS MANAGEMENT -->

<xsl:template name="html-create-config-form">
  <div class="gb_window">
    <div class="gb_window_part_left"></div>
    <div class="gb_window_part_right"></div>
    <div class="gb_window_part_center">
      New Scan Config
      <a href="/help/new_config.html?token={/envelope/token}"
         title="Help: New Scan Config">
        <img src="/img/help.png"/>
      </a>
      <a href="/omp?cmd=get_config&amp;filter={str:encode-uri (/envelope/params/filter, true ())}&amp;filt_id={/envelope/params/filt_id}&amp;token={/envelope/token}"
         title="Scan Config" style="margin-left:3px;">
        <img src="/img/list.png" border="0" alt="Scan Config"/>
      </a>
    </div>
    <div class="gb_window_part_content">
      <form action="/omp" method="post" enctype="multipart/form-data">
        <input type="hidden" name="token" value="{/envelope/token}"/>
        <input type="hidden" name="cmd" value="create_config"/>
        <input type="hidden" name="caller" value="{/envelope/caller}"/>
        <table border="0" cellspacing="0" cellpadding="3" width="100%">
          <tr>
            <td valign="top" width="125">Name</td>
            <td>
              <input type="text" name="name" value="unnamed" size="30"
                     maxlength="80"/>
            </td>
          </tr>
          <tr>
            <td valign="top">Comment (optional)</td>
            <td>
              <input type="text" name="comment" size="30" maxlength="400"/>
            </td>
          </tr>
          <tr>
            <td>Base</td>
            <td>
              <table>
                <tr>
                  <td colspan="2">
                    <label>
                      <input type="radio" name="base"
                             value="085569ce-73ed-11df-83c3-002264764cea"
                             checked="1"/>
                      Empty, static and fast
                    </label>
                  </td>
                </tr>
                <tr>
                  <td colspan="2">
                    <label>
                      <input type="radio" name="base"
                             value="daba56c8-73ec-11df-a475-002264764cea"/>
                      Full and fast
                    </label>
                  </td>
                </tr>
              </table>
            </td>
          </tr>
          <tr>
            <td colspan="2" style="text-align:right;">
              <input type="submit" name="submit" value="Create Scan Config"/>
            </td>
          </tr>
        </table>
        <br/>
      </form>
    </div>
  </div>
</xsl:template>

<xsl:template name="html-import-config-form">
  <div class="gb_window">
    <div class="gb_window_part_left"></div>
    <div class="gb_window_part_right"></div>
    <div class="gb_window_part_center">
      Import Scan Config
      <a href="/help/new_config.html?token={/envelope/token}#importconfig"
         title="Help: Import Scan Config">
        <img src="/img/help.png"/>
      </a>
      <a href="/omp?cmd=get_config&amp;filter={str:encode-uri (/envelope/params/filter, true ())}&amp;filt_id={/envelope/params/filt_id}&amp;token={/envelope/token}"
         title="Scan Config" style="margin-left:3px;">
        <img src="/img/list.png" border="0" alt="Scan Config"/>
      </a>
    </div>
    <div class="gb_window_part_content">
      <form action="/omp" method="post" enctype="multipart/form-data">
        <input type="hidden" name="token" value="{/envelope/token}"/>
        <input type="hidden" name="cmd" value="import_config"/>
        <input type="hidden" name="caller" value="{/envelope/caller}"/>
        <table border="0" cellspacing="0" cellpadding="3" width="100%">
          <tr>
            <td valign="top" width="125">
              Import XML config
            </td>
            <td><input type="file" name="xml_file" size="30"/></td>
          </tr>
          <tr>
            <td colspan="2" style="text-align:right;">
              <input type="submit" name="submit" value="Import Scan Config"/>
            </td>
          </tr>
        </table>
        <br/>
      </form>
    </div>
  </div>
</xsl:template>

<xsl:template match="new_config">
  <xsl:apply-templates select="gsad_msg"/>
  <xsl:apply-templates select="create_config_response"/>
  <xsl:apply-templates select="commands_response/delete_config_response"/>
  <xsl:call-template name="html-create-config-form"/>
  <xsl:call-template name="html-import-config-form"/>
</xsl:template>

<xsl:template match="risk_factor">
  <xsl:choose>
    <xsl:when test="text() = 'Critical'">Crit</xsl:when>
    <xsl:when test="text() = 'Medium'">Med</xsl:when>
    <xsl:otherwise><xsl:value-of select="text()"/></xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template name="html-config-family-table">
 <div class="gb_window">
  <div class="gb_window_part_left"></div>
  <div class="gb_window_part_right"></div>
  <div class="gb_window_part_center">
    <xsl:choose>
      <xsl:when test="edit">
        Edit Scan Config Family Details
        <a href="/help/config_editor_nvt_families.html?token={/envelope/token}"
           title="Help: Scan Configs (Edit Scan Config Family Details)">
          <img src="/img/help.png"/>
        </a>
      </xsl:when>
      <xsl:otherwise>
        Scan Config Family Details
        <a href="/help/config_family_details.html?token={/envelope/token}"
           title="Help: Scan Configs (Scan Config Family Details)">
          <img src="/img/help.png"/>
        </a>
      </xsl:otherwise>
    </xsl:choose>
  </div>
  <div class="gb_window_part_content">
    <div class="float_right">
      <xsl:choose>
        <xsl:when test="edit">
          <a href="?cmd=edit_config&amp;config_id={config/@id}&amp;token={/envelope/token}">
            Config Details
          </a>
        </xsl:when>
        <xsl:otherwise>
          <a href="?cmd=get_config&amp;config_id={config/@id}&amp;token={/envelope/token}">
            Config Details
          </a>
        </xsl:otherwise>
      </xsl:choose>
    </div>
    <br/>

    <xsl:variable name="config_id" select="config/@id"/>
    <xsl:variable name="config_name" select="config/name"/>
    <xsl:variable name="family" select="config/family"/>

    <table>
    <tr><td>Config:</td><td><xsl:value-of select="$config_name"/></td></tr>
    <tr><td>Family:</td><td><xsl:value-of select="$family"/></td></tr>
    </table>

    <xsl:choose>
      <xsl:when test="edit">
        <h1>Edit Network Vulnerability Tests</h1>
      </xsl:when>
      <xsl:otherwise>
        <h1>Network Vulnerability Tests</h1>
      </xsl:otherwise>
    </xsl:choose>

    <table class="gbntable" cellspacing="2" cellpadding="4">
      <tr class="gbntablehead2">
        <td>Name</td>
        <td>OID</td>
        <td>Risk</td>
        <td style="text-align:center;">CVSS</td>
        <td>Timeout</td>
        <td>Prefs</td>
        <xsl:if test="edit">
          <td>Selected</td>
        </xsl:if>
        <td>Action</td>
      </tr>
      <xsl:choose>
        <xsl:when test="edit">
          <form action="" method="post" enctype="multipart/form-data">
            <input type="hidden" name="token" value="{/envelope/token}"/>
            <input type="hidden" name="cmd" value="save_config_family"/>
            <input type="hidden" name="caller" value="{/envelope/caller}"/>
            <input type="hidden" name="config_id" value="{$config_id}"/>
            <input type="hidden" name="name" value="{$config_name}"/>
            <input type="hidden" name="family" value="{$family}"/>
            <xsl:for-each select="all/get_nvts_response/nvt" >
              <xsl:variable name="current_name" select="name/text()"/>
              <xsl:variable name="id" select="@oid"/>
              <xsl:variable name="class">
                <xsl:choose>
                  <xsl:when test="position() mod 2 = 0">even</xsl:when>
                  <xsl:otherwise>odd</xsl:otherwise>
                </xsl:choose>
              </xsl:variable>
              <tr class="{$class}">
                <td><xsl:value-of select="$current_name"/></td>
                <td>
                  <xsl:value-of select="@oid"/>
                </td>
                <td>
                  <xsl:apply-templates select="risk_factor"/>
                </td>
                <td>
                  <xsl:call-template name="severity-bar">
                    <xsl:with-param name="cvss" select="cvss_base"/>
                  </xsl:call-template>
                </td>
                <td>
                  <xsl:variable
                    name="timeout"
                    select="../../../get_nvts_response/nvt[@oid=$id]/timeout"/>
                  <xsl:choose>
                    <xsl:when test="string-length($timeout) &gt; 0">
                      <xsl:value-of select="$timeout"/>
                    </xsl:when>
                    <xsl:otherwise>
                      default
                    </xsl:otherwise>
                  </xsl:choose>
                </td>
                <td style="text-align:center;">
                  <xsl:choose>
                    <xsl:when test="preference_count&gt;0">
                      <xsl:value-of select="preference_count"/>
                    </xsl:when>
                    <xsl:otherwise>
                    </xsl:otherwise>
                  </xsl:choose>
                </td>
                <td style="text-align:center;">
                  <xsl:choose>
                    <xsl:when test="../../../get_nvts_response/nvt[@oid=$id]">
                      <input type="checkbox" name="nvt:{@oid}" value="1"
                             checked="1"/>
                    </xsl:when>
                    <xsl:otherwise>
                      <input type="checkbox" name="nvt:{@oid}" value="1"/>
                    </xsl:otherwise>
                  </xsl:choose>
                </td>
                <td>
                  <a href="/omp?cmd=get_config_nvt&amp;oid={@oid}&amp;config_id={$config_id}&amp;name={$config_name}&amp;family={$family}&amp;token={/envelope/token}"
                     title="NVT Details" style="margin-left:3px;">
                    <img src="/img/details.png" border="0" alt="Details"/>
                  </a>
                  <a href="/omp?cmd=edit_config_nvt&amp;oid={@oid}&amp;config_id={$config_id}&amp;name={$config_name}&amp;family={$family}&amp;token={/envelope/token}"
                     title="Select and Edit NVT Details"
                     style="margin-left:3px;">
                    <img src="/img/edit.png" border="0" alt="Edit"/>
                  </a>
                </td>
              </tr>
            </xsl:for-each>
            <tr>
              <td>
                Total:
                <xsl:value-of select="count(all/get_nvts_response/nvt)"/>
              </td>
              <td></td>
              <td></td>
              <td></td>
              <td></td>
              <td></td>
              <td>
                Total:
                <xsl:value-of select="count(get_nvts_response/nvt)"/>
              </td>
              <td></td>
            </tr>
            <tr>
              <td colspan="8" style="text-align:right;">
                <input type="submit"
                       name="submit"
                       value="Save Config"
                       title="Save Config"/>
              </td>
            </tr>
          </form>
        </xsl:when>
        <xsl:otherwise>
          <xsl:for-each select="get_nvts_response/nvt" >
            <xsl:variable name="current_name" select="name/text()"/>
            <xsl:variable name="class">
              <xsl:choose>
                <xsl:when test="position() mod 2 = 0">even</xsl:when>
                <xsl:otherwise>odd</xsl:otherwise>
              </xsl:choose>
            </xsl:variable>
            <tr class="{$class}">
              <td><xsl:value-of select="$current_name"/></td>
              <td>
                <xsl:value-of select="@oid"/>
              </td>
              <td>
                <xsl:apply-templates select="risk_factor"/>
              </td>
              <td>
                <xsl:call-template name="severity-bar">
                  <xsl:with-param name="cvss" select="cvss_base"/>
                </xsl:call-template>
              </td>
              <td>
                <xsl:choose>
                  <xsl:when test="string-length(timeout) &gt; 0">
                    <xsl:value-of select="timeout"/>
                  </xsl:when>
                  <xsl:otherwise>
                    default
                  </xsl:otherwise>
                </xsl:choose>
              </td>
              <td style="text-align:center;">
                <xsl:choose>
                  <xsl:when test="preference_count&gt;0">
                    <xsl:value-of select="preference_count"/>
                  </xsl:when>
                  <xsl:otherwise>
                  </xsl:otherwise>
                </xsl:choose>
              </td>
              <td>
                <a href="/omp?cmd=get_config_nvt&amp;oid={@oid}&amp;config_id={$config_id}&amp;name={$config_name}&amp;family={$family}&amp;token={/envelope/token}"
                   title="NVT Details" style="margin-left:3px;">
                  <img src="/img/details.png" border="0" alt="Details"/>
                </a>
              </td>
            </tr>
          </xsl:for-each>
          <tr>
            <td>
              Total:
              <xsl:value-of select="count(get_nvts_response/nvt)"/>
            </td>
            <td></td>
            <td></td>
            <td></td>
            <td></td>
            <td></td>
            <td></td>
          </tr>
        </xsl:otherwise>
      </xsl:choose>
    </table>
  </div>
 </div>
</xsl:template>

<!--     CONFIG PREFERENCES -->

<xsl:template name="preference" match="preference">
  <xsl:param name="config_id"></xsl:param>
  <xsl:param name="config_name"></xsl:param>
  <xsl:param name="edit"></xsl:param>
  <xsl:variable name="class">
    <xsl:choose>
      <xsl:when test="position() mod 2 = 0">even</xsl:when>
      <xsl:otherwise>odd</xsl:otherwise>
    </xsl:choose>
  </xsl:variable>
  <tr class="{$class}">
    <td><xsl:value-of select="nvt/name"/></td>
    <td><xsl:value-of select="name"/></td>
    <td>
      <xsl:choose>
        <xsl:when test="type='file' and string-length(value) &gt; 0">
          <i>File attached.</i>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="value"/>
        </xsl:otherwise>
      </xsl:choose>
    </td>
    <td>
      <xsl:if test="string-length($config_id) &gt; 0">
        <a href="/omp?cmd=get_config_nvt&amp;oid={nvt/@oid}&amp;config_id={$config_id}&amp;name={$config_name}&amp;family={nvt/family}&amp;token={/envelope/token}"
           title="Scan Config NVT Details" style="margin-left:3px;">
          <img src="/img/details.png" border="0" alt="Details"/>
        </a>
      </xsl:if>
      <xsl:if test="string-length($edit) &gt; 0">
        <a href="/omp?cmd=edit_config_nvt&amp;oid={nvt/@oid}&amp;config_id={$config_id}&amp;name={$config_name}&amp;family={nvt/family}&amp;token={/envelope/token}"
           title="Edit Scan Config NVT Details" style="margin-left:3px;">
          <img src="/img/edit.png" border="0" alt="Edit"/>
        </a>
      </xsl:if>
      <xsl:if test="type='file' and string-length(value) &gt; 0">
        <a href="/omp?cmd=export_preference_file&amp;config_id={$config_id}&amp;oid={nvt/@oid}&amp;preference_name={name}&amp;token={/envelope/token}"
           title="Export File"
           style="margin-left:3px;">
          <img src="/img/download.png" border="0" alt="Export File"/>
        </a>
      </xsl:if>
    </td>
  </tr>
</xsl:template>

<xsl:template name="preference-details" match="preference" mode="details">
  <xsl:param name="config"></xsl:param>
  <xsl:variable name="class">
    <xsl:choose>
      <xsl:when test="position() mod 2 = 0">even</xsl:when>
      <xsl:otherwise>odd</xsl:otherwise>
    </xsl:choose>
  </xsl:variable>
  <tr class="{$class}">
    <td><xsl:value-of select="name"/></td>
    <td>
      <xsl:choose>
        <xsl:when test="type='file' and string-length(value) &gt; 0">
          <i>File attached.</i>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="value"/>
        </xsl:otherwise>
      </xsl:choose>
    </td>
    <td>
      <xsl:if test="type='file' and string-length(value) &gt; 0">
        <a href="/omp?cmd=export_preference_file&amp;config_id={$config/@id}&amp;oid={nvt/@oid}&amp;preference_name={name}&amp;token={/envelope/token}"
           title="Export File"
           style="margin-left:3px;">
          <img src="/img/download.png" border="0" alt="Export File"/>
        </a>
      </xsl:if>
    </td>
  </tr>
</xsl:template>

<xsl:template match="preference"
              name="edit-config-preference"
              mode="edit-details">
  <xsl:param name="config"></xsl:param>
  <xsl:param name="for_config_details"></xsl:param>
  <xsl:param name="family"></xsl:param>
  <xsl:param name="nvt"></xsl:param>
  <xsl:variable name="class">
    <xsl:choose>
      <xsl:when test="position() mod 2 = 0">even</xsl:when>
      <xsl:otherwise>odd</xsl:otherwise>
    </xsl:choose>
  </xsl:variable>
  <tr class="{$class}">
    <xsl:if test="$for_config_details">
      <td><xsl:value-of select="nvt/name"/></td>
    </xsl:if>
    <td><xsl:value-of select="name"/></td>
    <td>
      <!-- TODO: Is name enough to make the preference unique, or is
           type required too? -->
      <xsl:choose>
        <xsl:when test="type='checkbox'">
          <xsl:choose>
            <xsl:when test="value='yes'">
              <label>
                <input type="radio" name="preference:{nvt/name}[checkbox]:{name}"
                       value="yes" checked="1"/>
                yes
              </label>
              <label>
                <input type="radio" name="preference:{nvt/name}[checkbox]:{name}"
                       value="no"/>
                no
              </label>
            </xsl:when>
            <xsl:otherwise>
              <label>
                <input type="radio" name="preference:{nvt/name}[checkbox]:{name}"
                       value="yes"/>
                yes
              </label>
              <label>
                <input type="radio" name="preference:{nvt/name}[checkbox]:{name}"
                       value="no" checked="1"/>
                no
              </label>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:when>
        <xsl:when test="type='password'">
          <label>
            <input type="checkbox" name="password:{nvt/name}[password]:{name}"
                   value="yes"/>
            Replace existing value with:
          </label>
          <br/>
          <input type="password" autocomplete="off"
                 name="preference:{nvt/name}[password]:{name}"
                 value="{value}" size="30" maxlength="40"/>
        </xsl:when>
        <xsl:when test="type='file'">
          <label>
            <input type="checkbox" name="file:{nvt/name}[file]:{name}"
                   value="yes"/>
            <xsl:choose>
              <xsl:when test="string-length(value) &gt; 0">
                Replace existing file with:
              </xsl:when>
              <xsl:otherwise>
                Upload file:
              </xsl:otherwise>
            </xsl:choose>
          </label>
          <br/>
          <input type="file" name="preference:{nvt/name}[file]:{name}" size="30"/>
        </xsl:when>
        <xsl:when test="type='entry'">
          <input type="text" name="preference:{nvt/name}[entry]:{name}"
                 value="{value}" size="30" maxlength="400"/>
        </xsl:when>
        <xsl:when test="type='radio'">
          <label>
            <input type="radio" name="preference:{nvt/name}[radio]:{name}"
                   value="{value}" checked="1"/>
            <xsl:value-of select="value"/>
          </label>
          <xsl:for-each select="alt">
            <br/>
            <label>
              <input type="radio"
                     name="preference:{../nvt/name}[radio]:{../name}"
                     value="{text()}"/>
              <xsl:value-of select="."/>
            </label>
          </xsl:for-each>
        </xsl:when>
        <xsl:when test="type=''">
          <xsl:choose>
            <xsl:when test="name='ping_hosts' or name='reverse_lookup' or name='unscanned_closed' or name='nasl_no_signature_check' or name='ping_hosts' or name='reverse_lookup' or name='unscanned_closed' or name='auto_enable_dependencies' or name='kb_dont_replay_attacks' or name='kb_dont_replay_denials' or name='kb_dont_replay_info_gathering' or name='kb_dont_replay_scanners' or name='kb_restore' or name='log_whole_attack' or name='only_test_hosts_whose_kb_we_dont_have' or name='only_test_hosts_whose_kb_we_have' or name='optimize_test' or name='safe_checks' or name='save_knowledge_base' or name='silent_dependencies' or name='slice_network_addresses' or name='use_mac_addr' or name='drop_privileges' or name='network_scan'">
              <xsl:choose>
                <xsl:when test="value='yes'">
                  <label>
                    <input type="radio" name="preference:scanner[scanner]:{name}"
                           value="yes" checked="1"/>
                    yes
                  </label>
                  <label>
                    <input type="radio" name="preference:scanner[scanner]:{name}"
                           value="no"/>
                    no
                  </label>
                </xsl:when>
                <xsl:otherwise>
                  <label>
                    <input type="radio" name="preference:scanner[scanner]:{name}"
                           value="yes"/>
                    yes
                  </label>
                  <label>
                    <input type="radio" name="preference:scanner[scanner]:{name}"
                           value="no" checked="1"/>
                    no
                  </label>
                </xsl:otherwise>
              </xsl:choose>
            </xsl:when>
            <xsl:otherwise>
              <input type="text"
                     name="preference:scanner[scanner]:{name}"
                     value="{value}"
                     size="30"
                     maxlength="400"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:when>
        <xsl:otherwise>
          <input type="text"
                 name="preference:{nvt/name}[{type}]:{name}"
                 value="{value}"
                 size="30"
                 maxlength="400"/>
        </xsl:otherwise>
      </xsl:choose>
    </td>
    <td>
      <xsl:if test="$for_config_details">
        <a href="/omp?cmd=edit_config_nvt&amp;oid={nvt/@oid}&amp;config_id={$config/@id}&amp;family={$family}&amp;token={/envelope/token}"
           title="Edit NVT Details" style="margin-left:3px;">
          <img src="/img/edit.png" border="0" alt="Edit"/>
        </a>
      </xsl:if>
      <xsl:choose>
        <xsl:when test="$config and type='file' and (string-length(value) &gt; 0)">
          <a href="/omp?cmd=export_preference_file&amp;config_id={$config/@id}&amp;oid={nvt/@oid}&amp;preference_name={name}&amp;token={/envelope/token}"
             title="Export File"
             style="margin-left:3px;">
            <img src="/img/download.png" border="0" alt="Export File"/>
          </a>
        </xsl:when>
        <xsl:otherwise>
        </xsl:otherwise>
      </xsl:choose>
    </td>
  </tr>
</xsl:template>

<xsl:template match="preferences" name="preferences">
  <xsl:param name="config_id"></xsl:param>
  <xsl:param name="config_name"></xsl:param>
  <xsl:param name="edit"></xsl:param>
  <div id="preferences">
    <table class="gbntable" cellspacing="2" cellpadding="4">
      <tr class="gbntablehead2">
        <td>NVT</td>
        <td>Name</td>
        <td>Value</td>
        <td width="60">Actions</td>
      </tr>
      <xsl:for-each select="preference[string-length(./nvt)&gt;0]">
        <xsl:call-template name="preference">
          <xsl:with-param name="config_id" select="$config_id"/>
          <xsl:with-param name="config_name" select="$config_name"/>
          <xsl:with-param name="edit" select="$edit"/>
        </xsl:call-template>
      </xsl:for-each>
    </table>
  </div>
</xsl:template>

<xsl:template name="preferences-details" match="preferences" mode="details">
  <xsl:param name="config"></xsl:param>
  <div id="preferences">
    <table class="gbntable" cellspacing="2" cellpadding="4">
      <tr class="gbntablehead2">
        <td>Name</td>
        <td>Value</td>
        <td>Actions</td>
      </tr>

      <!-- Special case the NVT timeout. -->
      <tr class="even">
        <td>Timeout</td>
        <td>
          <xsl:choose>
            <xsl:when test="string-length(timeout) &gt; 0">
              <xsl:value-of select="timeout"/>
            </xsl:when>
            <xsl:otherwise>
              default
            </xsl:otherwise>
          </xsl:choose>
        </td>
        <td></td>
      </tr>

      <xsl:for-each select="preference">
        <xsl:call-template name="preference-details">
          <xsl:with-param name="config" select="$config"/>
        </xsl:call-template>
      </xsl:for-each>
    </table>
  </div>
</xsl:template>

<xsl:template name="preferences-edit-details">
  <xsl:param name="config"></xsl:param>
  <div id="preferences">
    <table class="gbntable" cellspacing="2" cellpadding="4">
      <tr class="gbntablehead2">
        <td>Name</td>
        <td>Value</td>
        <td>Actions</td>
      </tr>

      <!-- Special case the NVT timeout. -->
      <tr class="even">
        <td>Timeout</td>
        <td>
          <label>
            <xsl:choose>
              <xsl:when test="string-length(timeout) &gt; 0">
                <input type="radio"
                       name="timeout"
                       value="0"/>
              </xsl:when>
              <xsl:otherwise>
                <input type="radio"
                       name="timeout"
                       value="0"
                       checked="1"/>
              </xsl:otherwise>
            </xsl:choose>
            Apply default timeout
          </label>
          <br/>
          <xsl:choose>
            <xsl:when test="string-length(timeout) &gt; 0">
              <input type="radio"
                     name="timeout"
                     value="1"
                     checked="1"/>
            </xsl:when>
            <xsl:otherwise>
              <input type="radio"
                     name="timeout"
                     value="1"/>
            </xsl:otherwise>
          </xsl:choose>
          <input type="text"
                 name="preference:scanner[scanner]:timeout.{../@oid}"
                 value="{timeout}"
                 size="30"
                 maxlength="400"/>
          <br/>
        </td>
        <td></td>
      </tr>

      <xsl:for-each select="preference">
        <xsl:call-template name="edit-config-preference">
          <xsl:with-param name="config" select="$config"/>
        </xsl:call-template>
      </xsl:for-each>

      <tr>
        <td colspan="3" style="text-align:right;">
          <input type="submit"
                 name="submit"
                 value="Save Config"
                 title="Save Config"/>
        </td>
      </tr>
    </table>
  </div>
</xsl:template>

<xsl:template match="preferences" mode="scanner">
  <div id="preferences">
    <table class="gbntable" cellspacing="2" cellpadding="4">
      <tr class="gbntablehead2">
        <td>Name</td>
        <td>Value</td>
        <td>Actions</td>
      </tr>
      <xsl:apply-templates
        select="preference[string-length(nvt)=0]"
        mode="details"/>
    </table>
  </div>
</xsl:template>

<xsl:template match="preferences" mode="edit-scanner-details">
  <div id="preferences">
    <table class="gbntable" cellspacing="2" cellpadding="4">
      <tr class="gbntablehead2">
        <td>Name</td>
        <td>Value</td>
        <td>Actions</td>
      </tr>
      <xsl:apply-templates
        select="preference[string-length(nvt)=0]"
        mode="edit-details"/>
      <tr>
        <td colspan="3" style="text-align:right;">
          <input type="submit"
                 name="submit"
                 value="Save Config"
                 title="Save Config"/>
        </td>
      </tr>
    </table>
  </div>
</xsl:template>

<!--     CONFIG NVTS -->

<xsl:template name="html-config-nvt-table">
 <div class="gb_window">
  <div class="gb_window_part_left"></div>
  <div class="gb_window_part_right"></div>
  <div class="gb_window_part_center">
    <xsl:choose>
      <xsl:when test="edit">
        Edit Scan Config NVT Details
        <a href="/help/config_editor_nvt.html?token={/envelope/token}"
           title="Help: Scan Configs (Edit Scan Config NVT Details)">
          <img src="/img/help.png"/>
        </a>
      </xsl:when>
      <xsl:otherwise>
        Scan Config NVT Details
        <a href="/help/config_nvt_details.html?token={/envelope/token}"
           title="Help: Scan Configs (Scan Config NVT Details)">
          <img src="/img/help.png"/>
        </a>
      </xsl:otherwise>
    </xsl:choose>
  </div>
  <div class="gb_window_part_content">
    <xsl:variable name="family">
      <xsl:value-of select="get_nvts_response/nvt/family"/>
    </xsl:variable>
    <div class="float_right">
      <xsl:choose>
        <xsl:when test="edit">
          <a href="?cmd=edit_config_family&amp;config_id={config/@id}&amp;name={config/name}&amp;family={$family}&amp;token={/envelope/token}">
            Config Family Details
          </a>
        </xsl:when>
        <xsl:otherwise>
          <a href="?cmd=get_config_family&amp;config_id={config/@id}&amp;name={config/name}&amp;family={$family}&amp;token={/envelope/token}">
            Config Family Details
          </a>
        </xsl:otherwise>
      </xsl:choose>
    </div>
    <br/>

    <table>
    <tr><td>Config:</td><td><xsl:value-of select="config/name"/></td></tr>
    <tr><td>Family:</td><td><xsl:value-of select="$family"/></td></tr>
    </table>

    <xsl:choose>
      <xsl:when test="edit">
        <h1>Edit Network Vulnerability Test</h1>
      </xsl:when>
      <xsl:otherwise>
        <h1>Network Vulnerability Test</h1>
      </xsl:otherwise>
    </xsl:choose>

    <h2>Details</h2>
    <xsl:apply-templates select="get_nvts_response/nvt"/>

    <h2>Preferences</h2>
    <xsl:variable name="config" select="config"/>
    <xsl:choose>
      <xsl:when test="edit">
        <form action="" method="post" enctype="multipart/form-data">
          <input type="hidden" name="token" value="{/envelope/token}"/>
          <input type="hidden" name="cmd" value="save_config_nvt"/>
          <input type="hidden" name="caller" value="{/envelope/caller}"/>
          <input type="hidden" name="config_id" value="{config/@id}"/>
          <input type="hidden" name="name" value="{config/name}"/>
          <input type="hidden" name="family" value="{$family}"/>
          <input type="hidden"
                 name="oid"
                 value="{get_nvts_response/nvt/@oid}"/>
          <xsl:for-each select="get_nvts_response/nvt/preferences">
            <xsl:call-template name="preferences-edit-details">
              <xsl:with-param name="config" select="$config"/>
            </xsl:call-template>
          </xsl:for-each>
        </form>
      </xsl:when>
      <xsl:otherwise>
        <xsl:for-each select="get_nvts_response/nvt/preferences">
          <xsl:call-template name="preferences-details">
            <xsl:with-param name="config" select="$config"/>
          </xsl:call-template>
        </xsl:for-each>
      </xsl:otherwise>
    </xsl:choose>
  </div>
 </div>
</xsl:template>

<!--     CONFIG FAMILIES -->

<xsl:template name="edit-families-family">
  <xsl:param name="config"></xsl:param>
  <xsl:param name="config-family"></xsl:param>
  <xsl:variable name="current_name" select="name/text()"/>
  <xsl:choose>
    <xsl:when test="name=''">
    </xsl:when>
    <xsl:otherwise>
      <xsl:variable name="class">
        <xsl:choose>
          <xsl:when test="position() mod 2 = 0">even</xsl:when>
          <xsl:otherwise>odd</xsl:otherwise>
        </xsl:choose>
      </xsl:variable>
      <tr class="{$class}">
        <td><xsl:value-of select="$current_name"/></td>
        <td>
          <xsl:choose>
            <xsl:when test="$config-family">
              <xsl:choose>
                <xsl:when test="$config-family/nvt_count='-1'">
                  N
                </xsl:when>
                <xsl:otherwise>
                  <xsl:value-of select="$config-family/nvt_count"/>
                </xsl:otherwise>
              </xsl:choose>
            </xsl:when>
            <xsl:otherwise>
              0
            </xsl:otherwise>
          </xsl:choose>
          <xsl:choose>
            <xsl:when test="max_nvt_count='-1'">
            </xsl:when>
            <xsl:otherwise>
              of <xsl:value-of select="max_nvt_count"/>
            </xsl:otherwise>
          </xsl:choose>
        </td>
        <td style="text-align:center;">
          <label>
            <xsl:choose>
              <xsl:when test="$config-family">
                <xsl:choose>
                  <xsl:when test="$config-family/growing=1">
                    <input type="radio" name="trend:{$current_name}" value="1"
                           checked="1"/>
                  </xsl:when>
                  <xsl:otherwise>
                    <input type="radio" name="trend:{$current_name}" value="1"/>
                  </xsl:otherwise>
                </xsl:choose>
              </xsl:when>
              <xsl:otherwise>
                <input type="radio" name="trend:{$current_name}" value="1"/>
              </xsl:otherwise>
            </xsl:choose>
            <img src="/img/trend_more.png"
                 alt="Grows"
                 title="The NVT selection is DYNAMIC. New NVT's will automatically be added and considered."/>
          </label>
          <label>
            <xsl:choose>
              <xsl:when test="$config-family">
                <xsl:choose>
                  <xsl:when test="$config-family/growing=0">
                    <input type="radio" name="trend:{$current_name}" value="0"
                           checked="1"/>
                  </xsl:when>
                  <xsl:otherwise>
                    <input type="radio" name="trend:{$current_name}" value="0"/>
                  </xsl:otherwise>
                </xsl:choose>
              </xsl:when>
              <xsl:otherwise>
                <input type="radio" name="trend:{$current_name}" value="0"
                       checked="1"/>
              </xsl:otherwise>
            </xsl:choose>
            <img src="/img/trend_nochange.png"
                 alt="Static"
                 title="The NVT selection is STATIC. New NVT's will NOT automatically be added or considered."/>
          </label>
        </td>
        <td style="text-align:center;">
          <xsl:choose>
            <xsl:when test="$config-family and ($config-family/nvt_count = max_nvt_count)">
              <input type="checkbox" name="select:{$current_name}"
                     value="1" checked="1"/>
            </xsl:when>
            <xsl:otherwise>
              <input type="checkbox" name="select:{$current_name}"
                     value="0"/>
            </xsl:otherwise>
          </xsl:choose>
        </td>
        <td>
          <a href="/omp?cmd=edit_config_family&amp;config_id={$config/@id}&amp;name={$config/name}&amp;family={$current_name}&amp;token={/envelope/token}"
             title="Edit Scan Config Family" style="margin-left:3px;">
            <img src="/img/edit.png" border="0" alt="Edit"/>
          </a>
        </td>
      </tr>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template match="family">
  <xsl:variable name="current_name" select="name/text()"/>
  <xsl:choose>
    <xsl:when test="name=''">
    </xsl:when>
    <xsl:otherwise>
      <xsl:variable name="class">
        <xsl:choose>
          <xsl:when test="position() mod 2 = 0">even</xsl:when>
          <xsl:otherwise>odd</xsl:otherwise>
        </xsl:choose>
      </xsl:variable>
      <tr class="{$class}">
        <td><xsl:value-of select="$current_name"/></td>
        <td>
          <xsl:choose>
            <xsl:when test="nvt_count='-1'">
              N
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="nvt_count"/>
            </xsl:otherwise>
          </xsl:choose>
          <xsl:choose>
            <xsl:when test="max_nvt_count='-1'">
            </xsl:when>
            <xsl:otherwise>
              of <xsl:value-of select="max_nvt_count"/>
            </xsl:otherwise>
          </xsl:choose>
        </td>
        <td>
          <xsl:choose>
            <xsl:when test="growing='1'">
              <img src="/img/trend_more.png"
                   alt="Grows"
                   title="The NVT selection is DYNAMIC. New NVT's will automatically be added and considered."/>
            </xsl:when>
            <xsl:when test="growing='0'">
              <img src="/img/trend_nochange.png"
                   alt="Static"
                   title="The NVT selection is STATIC. New NVT's will NOT automatically be added or considered."/>
            </xsl:when>
            <xsl:otherwise>
              N/A
            </xsl:otherwise>
          </xsl:choose>
        </td>
        <td>
          <a href="/omp?cmd=get_config_family&amp;config_id={../../@id}&amp;name={../../name}&amp;family={$current_name}&amp;token={/envelope/token}"
             title="Scan Config Family Details" style="margin-left:3px;">
            <img src="/img/details.png" border="0" alt="Details"/>
          </a>
        </td>
      </tr>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template match="config" mode="families">
  <div id="families">
    <table class="gbntable" cellspacing="2" cellpadding="4">
      <tr class="gbntablehead2">
        <td>
          Family
          <xsl:choose>
            <xsl:when test="family_count/growing='1'">
              <img src="/img/trend_more.png"
                   alt="Grows"
                   title="The family selection is DYNAMIC. New families will automatically be added and considered."/>
            </xsl:when>
            <xsl:when test="family_count/growing='0'">
              <img src="/img/trend_nochange.png"
                   alt="Static"
                   title="The family selection is STATIC. New families will NOT automatically be added or considered."/>
            </xsl:when>
            <xsl:otherwise>
              N/A
            </xsl:otherwise>
          </xsl:choose>
        </td>
        <td>NVT's selected</td>
        <td>Trend</td>
        <td>Action</td>
      </tr>
      <xsl:apply-templates select="families/family"/>
      <tr>
        <td>Total: <xsl:value-of select="count(families/family)"/></td>
        <td>
          <table>
            <tr>
              <td style="margin-right:10px;">
                <xsl:value-of select="known_nvt_count/text()"/>
              </td>
              <td>
                <div style="margin-left:6px;">
                  of <xsl:value-of select="max_nvt_count/text()"/> in selected families<br/>
                  of <xsl:value-of select="sum(../../get_nvt_families_response/families/family/max_nvt_count)"/> in total
                </div>
              </td>
            </tr>
          </table>
        </td>
        <td>
          <xsl:choose>
            <xsl:when test="nvt_count/growing='1'">
              <img src="/img/trend_more.png"
                   alt="Grows"
                   title="The NVT selection is DYNAMIC. New NVT's will automatically be added and considered."/>
            </xsl:when>
            <xsl:when test="nvt_count/growing='0'">
              <img src="/img/trend_nochange.png"
                   alt="Static"
                   title="The NVT selection is STATIC. New NVT's will NOT automatically be added or considered."/>
            </xsl:when>
            <xsl:otherwise>
              N/A
            </xsl:otherwise>
          </xsl:choose>
        </td>
        <td></td>
      </tr>
    </table>
  </div>
</xsl:template>

<xsl:template name="edit-families">
  <xsl:param name="config"></xsl:param>
  <xsl:param name="families"></xsl:param>
  <div id="families">
    <table class="gbntable" cellspacing="2" cellpadding="4">
      <tr class="gbntablehead2">
        <td>
          Family
          <xsl:choose>
            <xsl:when test="$config/family_count/growing=1">
              <label>
                <input type="radio" name="trend:" value="1" checked="1"/>
                <img src="/img/trend_more.png"
                     alt="Grows"
                     title="The family selection is DYNAMIC. New families will automatically be added and considered."/>
              </label>
              <label>
                <input type="radio" name="trend:" value="0"/>
                <img src="/img/trend_nochange.png"
                     alt="Static"
                     title="The family selection is STATIC. New families will NOT automatically be added or considered."/>
              </label>
            </xsl:when>
            <xsl:otherwise>
              <label>
                <input type="radio" name="trend:" value="1"/>
                <img src="/img/trend_more.png"
                     alt="Grows"
                     title="The family selection is DYNAMIC. New families will automatically be added and considered."/>
              </label>
              <label>
                <input type="radio" name="trend:" value="0" checked="0"/>
                <img src="/img/trend_nochange.png"
                     alt="Static"
                     title="The family selection is STATIC. New families will NOT automatically be added or considered."/>
              </label>
            </xsl:otherwise>
          </xsl:choose>
        </td>
        <td>NVT's selected</td>
        <td>Trend</td>
        <td>Select all NVT's</td>
        <td>Action</td>
      </tr>
      <xsl:for-each select="$families/family">
        <xsl:variable name="family_name">
          <xsl:value-of select="name"/>
        </xsl:variable>
        <xsl:call-template name="edit-families-family">
          <xsl:with-param
            name="config-family"
            select="$config/families/family[name=$family_name]"/>
          <xsl:with-param name="config" select="$config"/>
        </xsl:call-template>
      </xsl:for-each>
      <tr>
        <td>
          Total: <xsl:value-of select="count($config/families/family)"/>
        </td>
        <td>
          <xsl:value-of select="$config/known_nvt_count/text()"/>
          of <xsl:value-of select="$config/max_nvt_count/text()"/>
        </td>
        <td>
          <xsl:choose>
            <xsl:when test="$config/nvt_count/growing='1'">
              <img src="/img/trend_more.png"
                   alt="Grows"
                   title="The NVT selection is DYNAMIC. New NVT's will automatically be added and considered."/>
            </xsl:when>
            <xsl:when test="$config/nvt_count/growing='0'">
              <img src="/img/trend_nochange.png"
                   alt="Static"
                   title="The NVT selection is STATIC. New NVT's will NOT automatically be added or considered."/>
            </xsl:when>
            <xsl:otherwise>
              N/A
            </xsl:otherwise>
          </xsl:choose>
        </td>
        <td></td>
        <td></td>
      </tr>
      <tr>
        <td colspan="5" style="text-align:right;">
          <input type="submit"
                 name="submit"
                 value="Save Config"
                 title="Save Config"/>
        </td>
      </tr>
    </table>
  </div>
</xsl:template>

<!--     CONFIG OVERVIEW -->

<xsl:template name="html-config-table">
 <xsl:variable name="config" select="get_configs_response/config"/>
 <div class="gb_window">
  <div class="gb_window_part_left"></div>
  <div class="gb_window_part_right"></div>
  <div class="gb_window_part_center">
  <xsl:choose>
    <xsl:when test="edit">
      Edit Scan Config

      <xsl:call-template name="edit-header-icons">
        <xsl:with-param name="cap-type" select="'Config'"/>
        <xsl:with-param name="type" select="'config'"/>
        <xsl:with-param name="id"
                        select="$config/@id"/>
      </xsl:call-template>
    </xsl:when>
    <xsl:otherwise>
      Scan Config Details
      <a href="/help/config_details.html?token={/envelope/token}"
         title="Help: Scan Config Details">
        <img src="/img/help.png"/>
      </a>
      <a href="/omp?cmd=new_config&amp;filter={str:encode-uri (/envelope/params/filter, true ())}&amp;filt_id={/envelope/params/filt_id}&amp;config_id={$config/@id}&amp;token={/envelope/token}"
         title="New Scan Config">
        <img src="/img/new.png" border="0" style="margin-left:3px;"/>
      </a>
      <a href="/omp?cmd=get_configs&amp;filter={str:encode-uri (/envelope/params/filter, true ())}&amp;filt_id={/envelope/params/filt_id}&amp;token={/envelope/token}"
         title="Scan Configs" style="margin-left:3px;">
        <img src="/img/list.png" border="0" alt="Scan Configs"/>
      </a>
      <div id="small_inline_form" style="display: inline; margin-left: 15px; font-weight: normal;">
        <xsl:choose>
          <xsl:when test="$config/writable!='0' and $config/in_use='0'">
            <xsl:call-template name="trashcan-icon">
              <xsl:with-param name="type" select="'config'"/>
              <xsl:with-param name="id" select="$config/@id"/>
              <xsl:with-param name="params">
                <input type="hidden" name="filter" value="{/envelope/params/filter}"/>
                <input type="hidden" name="filt_id" value="{/envelope/params/filt_id}"/>
              </xsl:with-param>
            </xsl:call-template>
          </xsl:when>
          <xsl:otherwise>
            <img src="/img/trashcan_inactive.png" border="0" alt="To Trashcan"
                 style="margin-left:3px;"/>
          </xsl:otherwise>
        </xsl:choose>
        <xsl:choose>
          <xsl:when test="$config/writable='0'">
            <img src="/img/edit_inactive.png" border="0" alt="Edit"
                 style="margin-left:3px;"/>
          </xsl:when>
          <xsl:otherwise>
            <a href="/omp?cmd=edit_config&amp;config_id={$config/@id}&amp;next=get_config&amp;filter={str:encode-uri (/envelope/params/filter, true ())}&amp;filt_id={/envelope/params/filt_id}&amp;token={/envelope/token}"
               title="Edit Scan Config">
              <img src="/img/edit.png" border="0" style="margin-left:3px;"/>
            </a>
          </xsl:otherwise>
        </xsl:choose>
        <a href="/omp?cmd=export_config&amp;config_id={$config/@id}&amp;filter={str:encode-uri (/envelope/params/filter, true ())}&amp;filt_id={/envelope/params/filt_id}&amp;token={/envelope/token}"
           title="Export Scan Config XML"
           style="margin-left:3px;">
          <img src="/img/download.png" border="0" alt="Export XML"/>
        </a>
      </div>
    </xsl:otherwise>
  </xsl:choose>
  </div>
  <div class="gb_window_part_content">

    <xsl:choose>
      <xsl:when test="edit">
        <form action="" method="post">
          <input type="hidden" name="token" value="{/envelope/token}"/>
          <input type="hidden" name="cmd" value="save_config"/>
          <input type="hidden" name="caller" value="{/envelope/caller}"/>
          <input type="hidden" name="config_id" value="{$config/@id}"/>
          <input type="hidden" name="name" value="{$config/name}"/>

          <table border="0" cellspacing="0" cellpadding="3" width="100%">
            <tr>
              <td valign="top" width="125">Name</td>
              <td>
                <input type="text" name="name" value="{$config/name}" size="30"
                       maxlength="80"/>
              </td>
            </tr>
            <tr>
              <td valign="top">Comment (optional)</td>
              <td>
                <input type="text" name="comment" size="30" maxlength="400"
                       value="{$config/comment}"/>
              </td>
            </tr>
            <tr>
              <td colspan="2" style="text-align:right;">
                <input type="submit" name="submit" value="Save Config"/>
              </td>
            </tr>
          </table>

          <h1>Edit Network Vulnerability Test Families</h1>

          <xsl:call-template name="edit-families">
            <xsl:with-param name="config" select="$config"/>
            <xsl:with-param
              name="families"
              select="get_nvt_families_response/families"/>
          </xsl:call-template>

          <xsl:choose>
            <xsl:when test="count($config/preferences/preference[string-length(nvt)=0]) = 0">
              <h1>Edit Scanner Preferences: None</h1>
              <h1>Network Vulnerability Test Preferences: None</h1>
            </xsl:when>
            <xsl:otherwise>
              <h1>Edit Scanner Preferences</h1>

              <xsl:apply-templates
                select="$config/preferences"
                mode="edit-scanner-details"/>

              <h1>Network Vulnerability Test Preferences</h1>
              <xsl:for-each select="$config/preferences">
                <xsl:call-template name="preferences">
                  <xsl:with-param name="config_id" select="$config/@id"/>
                  <xsl:with-param name="config_name" select="$config/name"/>
                  <xsl:with-param name="edit">yes</xsl:with-param>
                </xsl:call-template>
              </xsl:for-each>
            </xsl:otherwise>
          </xsl:choose>

        </form>
      </xsl:when>
      <xsl:otherwise>
        <div class="float_right" style="font-size: 10px;">
          <table style="font-size: 10px;">
            <tr>
              <td>ID:</td>
              <td><xsl:value-of select="$config/@id"/></td>
            </tr>
            <tr>
              <td>Created:</td>
              <td><xsl:value-of select="gsa:long-time ($config/creation_time)"/></td>
            </tr>
            <tr>
              <td>Last Modified:</td>
              <td><xsl:value-of select="gsa:long-time ($config/modification_time)"/></td>
            </tr>
          </table>
        </div>
        <table>
          <tr>
            <td><b>Name:</b></td>
            <td><b><xsl:value-of select="$config/name"/></b></td>
          </tr>
          <tr>
            <td>Comment:</td><td><xsl:value-of select="$config/comment"/></td>
          </tr>
        </table>

        <br/>

        <h1>Network Vulnerability Test Families</h1>

        <xsl:apply-templates select="$config" mode="families"/>

        <xsl:choose>
          <xsl:when test="count($config/preferences/preference[string-length(nvt)=0]) = 0">
            <h1>Scanner Preferences: None</h1>
            <h1>Network Vulnerability Test Preferences: None</h1>
          </xsl:when>
          <xsl:otherwise>
            <h1>Scanner Preferences</h1>
            <xsl:apply-templates select="$config/preferences" mode="scanner"/>

            <h1>Network Vulnerability Test Preferences</h1>
            <xsl:for-each select="$config/preferences">
              <xsl:call-template name="preferences">
                <xsl:with-param name="config_id" select="$config/@id"/>
                <xsl:with-param name="config_name" select="$config/name"/>
              </xsl:call-template>
            </xsl:for-each>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:otherwise>
    </xsl:choose>

    <xsl:choose>
      <xsl:when test="count($config/tasks/task) = 0">
        <h1>Tasks using this Config: None</h1>
      </xsl:when>
      <xsl:otherwise>
        <h1>Tasks using this Config</h1>
        <table class="gbntable" cellspacing="2" cellpadding="4">
          <tr class="gbntablehead2">
            <td>Name</td>
            <td>Actions</td>
          </tr>
          <xsl:for-each select="$config/tasks/task">
            <xsl:variable name="class">
              <xsl:choose>
                <xsl:when test="position() mod 2 = 0">even</xsl:when>
                <xsl:otherwise>odd</xsl:otherwise>
              </xsl:choose>
            </xsl:variable>
            <tr class="{$class}">
              <td><xsl:value-of select="name"/></td>
              <td width="100">
                <a href="/omp?cmd=get_task&amp;task_id={@id}&amp;token={/envelope/token}" title="Details">
                  <img src="/img/details.png"
                       border="0"
                       alt="Details"
                       style="margin-left:3px;"/>
                </a>
              </td>
            </tr>
          </xsl:for-each>
        </table>
      </xsl:otherwise>
    </xsl:choose>
  </div>
 </div>
</xsl:template>

<xsl:template name="html-configs-table">
  <div class="gb_window">
    <div class="gb_window_part_left"></div>
    <div class="gb_window_part_right"></div>
    <div class="gb_window_part_center">Scan Configs
      <xsl:call-template name="filter-window-pager">
        <xsl:with-param name="type" select="'config'"/>
        <xsl:with-param name="list" select="configs"/>
        <xsl:with-param name="count" select="count (config)"/>
        <xsl:with-param name="filtered_count" select="config_count/filtered"/>
        <xsl:with-param name="full_count" select="config_count/text ()"/>
      </xsl:call-template>
      <a href="/help/configs.html?token={/envelope/token}"
         title="Help: Scan Configs">
        <img src="/img/help.png"/>
      </a>
      <a href="/omp?cmd=new_config&amp;filter={str:encode-uri (filters/term, true ())}&amp;filt_id={/envelope/params/filt_id}&amp;token={/envelope/token}"
         title="New Scan Config">
        <img src="/img/new.png" border="0" style="margin-left:3px;"/>
      </a>
      <a href="/omp?cmd=get_configs&amp;filter=&amp;filt_id=&amp;token={/envelope/token}"
         title="Return to default filter view" style="margin-left:3px;">
        <img src="/img/list.png" border="0" alt="Return"/>
      </a>
      <div id="small_inline_form" style="display: inline; margin-left: 15px; font-weight: normal;">
        <a href="/omp?cmd=export_configs&amp;filter={str:encode-uri (filters/term, true ())}&amp;token={/envelope/token}"
           title="Export {config_count/filtered} filtered Scan Configs as XML"
           style="margin-left:3px;">
          <img src="/img/download.png" border="0" alt="Export XML"/>
        </a>
      </div>
      <div id="small_inline_form" style="margin-left:40px; display: inline">
        <form method="get" action="">
          <input type="hidden" name="token" value="{/envelope/token}"/>
          <input type="hidden" name="cmd" value="get_configs"/>
          <input type="hidden" name="filter" value="{filters/term}"/>
          <xsl:call-template name="auto-refresh"/>
          <input type="image"
                 name="Update"
                 src="/img/refresh.png"
                 alt="Update" style="margin-left:3px;margin-right:3px;"/>
        </form>
      </div>
    </div>
    <xsl:call-template name="filter-window-part">
      <xsl:with-param name="type" select="'config'"/>
      <xsl:with-param name="list" select="configs"/>
    </xsl:call-template>

    <div class="gb_window_part_content_no_pad">
      <div id="tasks">
        <table class="gbntable" cellspacing="2" cellpadding="4" border="0">
          <tr class="gbntablehead2">
            <td rowspan="2">
              <xsl:call-template name="column-name">
                <xsl:with-param name="head">Name</xsl:with-param>
                <xsl:with-param name="name">name</xsl:with-param>
                <xsl:with-param name="type">config</xsl:with-param>
              </xsl:call-template>
            </td>
            <td colspan="2">Families</td>
            <td colspan="2">NVTs</td>
            <td width="100" rowspan="2">Actions</td>
          </tr>
          <tr class="gbntablehead2">
            <td width="1" style="font-size:10px;">
              <xsl:call-template name="column-name">
                <xsl:with-param name="head">Total</xsl:with-param>
                <xsl:with-param name="name">families_total</xsl:with-param>
                <xsl:with-param name="type">config</xsl:with-param>
              </xsl:call-template>
            </td>
            <td width="1" style="font-size:10px;">
              <xsl:call-template name="column-name">
                <xsl:with-param name="head">Trend</xsl:with-param>
                <xsl:with-param name="name">families_trend</xsl:with-param>
                <xsl:with-param name="type">config</xsl:with-param>
              </xsl:call-template>
            </td>
            <td width="1" style="font-size:10px;">
              <xsl:call-template name="column-name">
                <xsl:with-param name="head">Total</xsl:with-param>
                <xsl:with-param name="name">nvts_total</xsl:with-param>
                <xsl:with-param name="type">config</xsl:with-param>
              </xsl:call-template>
            </td>
            <td width="1" style="font-size:10px;">
              <xsl:call-template name="column-name">
                <xsl:with-param name="head">Trend</xsl:with-param>
                <xsl:with-param name="name">nvts_trend</xsl:with-param>
                <xsl:with-param name="type">config</xsl:with-param>
              </xsl:call-template>
            </td>
          </tr>
          <xsl:apply-templates select="config"/>
        </table>
      </div>
    </div>
  </div>
</xsl:template>

<!--     CREATE_CONFIG_RESPONSE -->

<xsl:template match="create_config_response">
  <xsl:call-template name="command_result_dialog">
    <xsl:with-param name="operation">Create Config</xsl:with-param>
    <xsl:with-param name="status">
      <xsl:value-of select="@status"/>
    </xsl:with-param>
    <xsl:with-param name="msg">
      <xsl:value-of select="@status_text"/>
    </xsl:with-param>
    <xsl:with-param name="details">
      <xsl:if test="@status = '201' and config/name">
        Name of new config is '<xsl:value-of select="config/name"/>'.
      </xsl:if>
    </xsl:with-param>
  </xsl:call-template>
</xsl:template>

<!--     DELETE_CONFIG_RESPONSE -->

<xsl:template match="delete_config_response">
  <xsl:call-template name="command_result_dialog">
    <xsl:with-param name="operation">Delete Config</xsl:with-param>
    <xsl:with-param name="status">
      <xsl:value-of select="@status"/>
    </xsl:with-param>
    <xsl:with-param name="msg">
      <xsl:value-of select="@status_text"/>
    </xsl:with-param>
  </xsl:call-template>
</xsl:template>

<!-- CONFIG -->

<xsl:template match="config">
  <xsl:variable name="class">
    <xsl:choose>
      <xsl:when test="position() mod 2 = 0">even</xsl:when>
      <xsl:otherwise>odd</xsl:otherwise>
    </xsl:choose>
  </xsl:variable>
  <tr class="{$class}">
    <td>
      <b>
        <a href="/omp?cmd=get_config&amp;config_id={@id}&amp;filter={str:encode-uri (../filters/term, true ())}&amp;token={/envelope/token}">
          <xsl:value-of select="name"/>
        </a>
      </b>
      <xsl:choose>
        <xsl:when test="comment != ''">
          <br/>(<xsl:value-of select="comment"/>)
        </xsl:when>
        <xsl:otherwise>
        </xsl:otherwise>
      </xsl:choose>
    </td>
    <td>
      <xsl:choose>
        <xsl:when test="family_count/text()='-1'">
          N/A
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="family_count/text()"/>
        </xsl:otherwise>
      </xsl:choose>
    </td>
    <td style="text-align:center;">
      <xsl:choose>
        <xsl:when test="family_count/growing='1'">
          <img src="/img/trend_more.png"
               alt="Grows"
               title="The family selection is DYNAMIC. New families will automatically be added and considered."/>
        </xsl:when>
        <xsl:when test="family_count/growing='0'">
          <img src="/img/trend_nochange.png"
               alt="Static"
               title="The family selection is STATIC. New families will NOT automatically be added or considered."/>
        </xsl:when>
        <xsl:otherwise>
          N/A
        </xsl:otherwise>
      </xsl:choose>
    </td>
    <td>
      <xsl:choose>
        <xsl:when test="nvt_count/text()='-1'">
          N/A
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="nvt_count/text()"/>
        </xsl:otherwise>
      </xsl:choose>
    </td>
    <td style="text-align:center;">
      <xsl:choose>
        <xsl:when test="nvt_count/growing='1'">
          <img src="/img/trend_more.png"
               alt="Dynamic"
               title="The NVT selection is DYNAMIC. New NVTs of selected families will automatically be added and considered."/>
        </xsl:when>
        <xsl:when test="nvt_count/growing='0'">
          <img src="/img/trend_nochange.png"
               alt="Static"
               title="The NVT selection is STATIC. New NVTs will NOT automatically be added or considered."/>
        </xsl:when>
        <xsl:otherwise>
          N/A
        </xsl:otherwise>
      </xsl:choose>
    </td>
    <td>
      <xsl:call-template name="list-window-line-icons">
        <xsl:with-param name="cap-type" select="'Scan Config'"/>
        <xsl:with-param name="type" select="'config'"/>
        <xsl:with-param name="id" select="@id"/>
      </xsl:call-template>
    </td>
  </tr>
</xsl:template>

<xsl:template match="config" mode="trash">
  <xsl:variable name="class">
    <xsl:choose>
      <xsl:when test="position() mod 2 = 0">even</xsl:when>
      <xsl:otherwise>odd</xsl:otherwise>
    </xsl:choose>
  </xsl:variable>
  <tr class="{$class}">
    <td>
      <b><xsl:value-of select="name"/></b>
      <xsl:choose>
        <xsl:when test="comment != ''">
          <br/>(<xsl:value-of select="comment"/>)
        </xsl:when>
        <xsl:otherwise>
        </xsl:otherwise>
      </xsl:choose>
    </td>
    <td>
      <xsl:choose>
        <xsl:when test="family_count/text()='-1'">
          N/A
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="family_count/text()"/>
        </xsl:otherwise>
      </xsl:choose>
    </td>
    <td style="text-align:center;">
      <xsl:choose>
        <xsl:when test="family_count/growing='1'">
          <img src="/img/trend_more.png"
               alt="Grows"
               title="The family selection is DYNAMIC. New families will automatically be added and considered."/>
        </xsl:when>
        <xsl:when test="family_count/growing='0'">
          <img src="/img/trend_nochange.png"
               alt="Static"
               title="The family selection is STATIC. New families will NOT automatically be added or considered."/>
        </xsl:when>
        <xsl:otherwise>
          N/A
        </xsl:otherwise>
      </xsl:choose>
    </td>
    <td>
      <xsl:choose>
        <xsl:when test="nvt_count/text()='-1'">
          N/A
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="nvt_count/text()"/>
        </xsl:otherwise>
      </xsl:choose>
    </td>
    <td style="text-align:center;">
      <xsl:choose>
        <xsl:when test="nvt_count/growing='1'">
          <img src="/img/trend_more.png"
               alt="Dynamic"
               title="The NVT selection is DYNAMIC. New NVTs of selected families will automatically be added and considered."/>
        </xsl:when>
        <xsl:when test="nvt_count/growing='0'">
          <img src="/img/trend_nochange.png"
               alt="Static"
               title="The NVT selection is STATIC. New NVTs will NOT automatically be added or considered."/>
        </xsl:when>
        <xsl:otherwise>
          N/A
        </xsl:otherwise>
      </xsl:choose>
    </td>
    <td>
      <xsl:call-template name="restore-icon">
        <xsl:with-param name="id" select="@id"/>
      </xsl:call-template>
      <xsl:choose>
        <xsl:when test="in_use='0'">
          <xsl:call-template name="trash-delete-icon">
            <xsl:with-param name="type" select="'config'"/>
            <xsl:with-param name="id" select="@id"/>
          </xsl:call-template>
        </xsl:when>
        <xsl:otherwise>
          <img src="/img/delete_inactive.png" border="0" alt="Delete"
               style="margin-left:3px;"/>
        </xsl:otherwise>
      </xsl:choose>
    </td>
  </tr>
</xsl:template>

<!-- GET_CONFIGS_RESPONSE -->

<xsl:template match="get_configs_response">
  <xsl:apply-templates select="gsad_msg"/>
  <xsl:apply-templates select="create_filter_response"/>
  <xsl:apply-templates select="delete_config_response"/>
  <xsl:call-template name="html-configs-table"/>
</xsl:template>

<!-- GET_CONFIG_RESPONSE -->

<xsl:template match="get_config_response">
  <xsl:call-template name="html-config-table"/>
</xsl:template>

<!-- GET_CONFIG_FAMILY_RESPONSE -->

<xsl:template match="get_config_family_response">
  <xsl:call-template name="html-config-family-table"/>
</xsl:template>

<!-- GET_CONFIG_NVT_RESPONSE -->

<xsl:template match="get_config_nvt_response">
  <xsl:call-template name="html-config-nvt-table"/>
</xsl:template>

<!-- END CONFIGS MANAGEMENT -->

<!-- BEGIN SCHEDULES MANAGEMENT -->

<xsl:template name="opt">
  <xsl:param name="value"></xsl:param>
  <xsl:param name="content"><xsl:value-of select="$value"/></xsl:param>
  <xsl:param name="select-value"></xsl:param>
  <xsl:choose>
    <xsl:when test="$value = $select-value">
      <option value="{$value}" selected="1"><xsl:value-of select="$content"/></option>
    </xsl:when>
    <xsl:otherwise>
      <option value="{$value}"><xsl:value-of select="$content"/></option>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template name="html-create-schedule-form">
  <div class="gb_window">
    <div class="gb_window_part_left"></div>
    <div class="gb_window_part_right"></div>
    <div class="gb_window_part_center">New Schedule
      <a href="/help/new_schedule.html?token={/envelope/token}"
         title="Help: New Schedule">
        <img src="/img/help.png"/>
      </a>
      <a href="/omp?cmd=get_schedules&amp;filter={str:encode-uri (/envelope/params/filter, true ())}&amp;filt_id={/envelope/params/filt_id}&amp;token={/envelope/token}"
         title="Schedules" style="margin-left:3px;">
        <img src="/img/list.png" border="0" alt="Schedules"/>
      </a>
    </div>
    <div class="gb_window_part_content">
      <form action="/omp" method="post" enctype="multipart/form-data">
        <input type="hidden" name="token" value="{/envelope/token}"/>
        <input type="hidden" name="cmd" value="create_schedule"/>
        <input type="hidden" name="caller" value="{/envelope/caller}"/>
        <table border="0" cellspacing="0" cellpadding="3" width="100%">
          <tr class="odd">
            <td valign="top" width="125">Name</td>
            <td>
              <input type="text" name="name" value="unnamed" size="30"
                     maxlength="80"/>
            </td>
          </tr>
          <tr class="even">
            <td valign="top" width="125">Comment (optional)</td>
            <td>
              <input type="text" name="comment" size="30" maxlength="400"/>
            </td>
          </tr>
          <tr class="odd">
            <td valign="top" width="125">First Time</td>
            <td>
              <select name="hour">
                <xsl:call-template name="opt">
                  <xsl:with-param name="value" select="'00'"/>
                  <xsl:with-param name="select-value" select="time/hour"/>
                </xsl:call-template>
                <xsl:call-template name="opt">
                  <xsl:with-param name="value" select="'01'"/>
                  <xsl:with-param name="select-value" select="time/hour"/>
                </xsl:call-template>
                <xsl:call-template name="opt">
                  <xsl:with-param name="value" select="'02'"/>
                  <xsl:with-param name="select-value" select="time/hour"/>
                </xsl:call-template>
                <xsl:call-template name="opt">
                  <xsl:with-param name="value" select="'03'"/>
                  <xsl:with-param name="select-value" select="time/hour"/>
                </xsl:call-template>
                <xsl:call-template name="opt">
                  <xsl:with-param name="value" select="'04'"/>
                  <xsl:with-param name="select-value" select="time/hour"/>
                </xsl:call-template>
                <xsl:call-template name="opt">
                  <xsl:with-param name="value" select="'05'"/>
                  <xsl:with-param name="select-value" select="time/hour"/>
                </xsl:call-template>
                <xsl:call-template name="opt">
                  <xsl:with-param name="value" select="'06'"/>
                  <xsl:with-param name="select-value" select="time/hour"/>
                </xsl:call-template>
                <xsl:call-template name="opt">
                  <xsl:with-param name="value" select="'07'"/>
                  <xsl:with-param name="select-value" select="time/hour"/>
                </xsl:call-template>
                <xsl:call-template name="opt">
                  <xsl:with-param name="value" select="'08'"/>
                  <xsl:with-param name="select-value" select="time/hour"/>
                </xsl:call-template>
                <xsl:call-template name="opt">
                  <xsl:with-param name="value" select="'09'"/>
                  <xsl:with-param name="select-value" select="time/hour"/>
                </xsl:call-template>
                <xsl:call-template name="opt">
                  <xsl:with-param name="value" select="'10'"/>
                  <xsl:with-param name="select-value" select="time/hour"/>
                </xsl:call-template>
                <xsl:call-template name="opt">
                  <xsl:with-param name="value" select="'11'"/>
                  <xsl:with-param name="select-value" select="time/hour"/>
                </xsl:call-template>
                <xsl:call-template name="opt">
                  <xsl:with-param name="value" select="'12'"/>
                  <xsl:with-param name="select-value" select="time/hour"/>
                </xsl:call-template>
                <xsl:call-template name="opt">
                  <xsl:with-param name="value" select="'13'"/>
                  <xsl:with-param name="select-value" select="time/hour"/>
                </xsl:call-template>
                <xsl:call-template name="opt">
                  <xsl:with-param name="value" select="'14'"/>
                  <xsl:with-param name="select-value" select="time/hour"/>
                </xsl:call-template>
                <xsl:call-template name="opt">
                  <xsl:with-param name="value" select="'15'"/>
                  <xsl:with-param name="select-value" select="time/hour"/>
                </xsl:call-template>
                <xsl:call-template name="opt">
                  <xsl:with-param name="value" select="'16'"/>
                  <xsl:with-param name="select-value" select="time/hour"/>
                </xsl:call-template>
                <xsl:call-template name="opt">
                  <xsl:with-param name="value" select="'17'"/>
                  <xsl:with-param name="select-value" select="time/hour"/>
                </xsl:call-template>
                <xsl:call-template name="opt">
                  <xsl:with-param name="value" select="'18'"/>
                  <xsl:with-param name="select-value" select="time/hour"/>
                </xsl:call-template>
                <xsl:call-template name="opt">
                  <xsl:with-param name="value" select="'19'"/>
                  <xsl:with-param name="select-value" select="time/hour"/>
                </xsl:call-template>
                <xsl:call-template name="opt">
                  <xsl:with-param name="value" select="'20'"/>
                  <xsl:with-param name="select-value" select="time/hour"/>
                </xsl:call-template>
                <xsl:call-template name="opt">
                  <xsl:with-param name="value" select="'21'"/>
                  <xsl:with-param name="select-value" select="time/hour"/>
                </xsl:call-template>
                <xsl:call-template name="opt">
                  <xsl:with-param name="value" select="'22'"/>
                  <xsl:with-param name="select-value" select="time/hour"/>
                </xsl:call-template>
                <xsl:call-template name="opt">
                  <xsl:with-param name="value" select="'23'"/>
                  <xsl:with-param name="select-value" select="time/hour"/>
                </xsl:call-template>
              </select>
              h
              <select name="minute">
                <xsl:call-template name="opt">
                  <xsl:with-param name="value" select="'00'"/>
                  <xsl:with-param name="select-value" select="time/minute - (time/minute mod 5)"/>
                </xsl:call-template>
                <xsl:call-template name="opt">
                  <xsl:with-param name="value" select="'05'"/>
                  <xsl:with-param name="select-value" select="time/minute - (time/minute mod 5)"/>
                </xsl:call-template>
                <xsl:call-template name="opt">
                  <xsl:with-param name="value" select="'10'"/>
                  <xsl:with-param name="select-value" select="time/minute - (time/minute mod 5)"/>
                </xsl:call-template>
                <xsl:call-template name="opt">
                  <xsl:with-param name="value" select="'15'"/>
                  <xsl:with-param name="select-value" select="time/minute - (time/minute mod 5)"/>
                </xsl:call-template>
                <xsl:call-template name="opt">
                  <xsl:with-param name="value" select="'20'"/>
                  <xsl:with-param name="select-value" select="time/minute - (time/minute mod 5)"/>
                </xsl:call-template>
                <xsl:call-template name="opt">
                  <xsl:with-param name="value" select="'25'"/>
                  <xsl:with-param name="select-value" select="time/minute - (time/minute mod 5)"/>
                </xsl:call-template>
                <xsl:call-template name="opt">
                  <xsl:with-param name="value" select="'30'"/>
                  <xsl:with-param name="select-value" select="time/minute - (time/minute mod 5)"/>
                </xsl:call-template>
                <xsl:call-template name="opt">
                  <xsl:with-param name="value" select="'35'"/>
                  <xsl:with-param name="select-value" select="time/minute - (time/minute mod 5)"/>
                </xsl:call-template>
                <xsl:call-template name="opt">
                  <xsl:with-param name="value" select="'40'"/>
                  <xsl:with-param name="select-value" select="time/minute - (time/minute mod 5)"/>
                </xsl:call-template>
                <xsl:call-template name="opt">
                  <xsl:with-param name="value" select="'45'"/>
                  <xsl:with-param name="select-value" select="time/minute - (time/minute mod 5)"/>
                </xsl:call-template>
                <xsl:call-template name="opt">
                  <xsl:with-param name="value" select="'50'"/>
                  <xsl:with-param name="select-value" select="time/minute - (time/minute mod 5)"/>
                </xsl:call-template>
                <xsl:call-template name="opt">
                  <xsl:with-param name="value" select="'55'"/>
                  <xsl:with-param name="select-value" select="time/minute - (time/minute mod 5)"/>
                </xsl:call-template>
              </select>
              ,
              <select name="day_of_month">
                <xsl:call-template name="opt">
                  <xsl:with-param name="value" select="'01'"/>
                  <xsl:with-param name="select-value" select="time/day_of_month"/>
                </xsl:call-template>
                <xsl:call-template name="opt">
                  <xsl:with-param name="value" select="'02'"/>
                  <xsl:with-param name="select-value" select="time/day_of_month"/>
                </xsl:call-template>
                <xsl:call-template name="opt">
                  <xsl:with-param name="value" select="'03'"/>
                  <xsl:with-param name="select-value" select="time/day_of_month"/>
                </xsl:call-template>
                <xsl:call-template name="opt">
                  <xsl:with-param name="value" select="'04'"/>
                  <xsl:with-param name="select-value" select="time/day_of_month"/>
                </xsl:call-template>
                <xsl:call-template name="opt">
                  <xsl:with-param name="value" select="'05'"/>
                  <xsl:with-param name="select-value" select="time/day_of_month"/>
                </xsl:call-template>
                <xsl:call-template name="opt">
                  <xsl:with-param name="value" select="'06'"/>
                  <xsl:with-param name="select-value" select="time/day_of_month"/>
                </xsl:call-template>
                <xsl:call-template name="opt">
                  <xsl:with-param name="value" select="'07'"/>
                  <xsl:with-param name="select-value" select="time/day_of_month"/>
                </xsl:call-template>
                <xsl:call-template name="opt">
                  <xsl:with-param name="value" select="'08'"/>
                  <xsl:with-param name="select-value" select="time/day_of_month"/>
                </xsl:call-template>
                <xsl:call-template name="opt">
                  <xsl:with-param name="value" select="'09'"/>
                  <xsl:with-param name="select-value" select="time/day_of_month"/>
                </xsl:call-template>
                <xsl:call-template name="opt">
                  <xsl:with-param name="value" select="'10'"/>
                  <xsl:with-param name="select-value" select="time/day_of_month"/>
                </xsl:call-template>
                <xsl:call-template name="opt">
                  <xsl:with-param name="value" select="'11'"/>
                  <xsl:with-param name="select-value" select="time/day_of_month"/>
                </xsl:call-template>
                <xsl:call-template name="opt">
                  <xsl:with-param name="value" select="'12'"/>
                  <xsl:with-param name="select-value" select="time/day_of_month"/>
                </xsl:call-template>
                <xsl:call-template name="opt">
                  <xsl:with-param name="value" select="'13'"/>
                  <xsl:with-param name="select-value" select="time/day_of_month"/>
                </xsl:call-template>
                <xsl:call-template name="opt">
                  <xsl:with-param name="value" select="'14'"/>
                  <xsl:with-param name="select-value" select="time/day_of_month"/>
                </xsl:call-template>
                <xsl:call-template name="opt">
                  <xsl:with-param name="value" select="'15'"/>
                  <xsl:with-param name="select-value" select="time/day_of_month"/>
                </xsl:call-template>
                <xsl:call-template name="opt">
                  <xsl:with-param name="value" select="'16'"/>
                  <xsl:with-param name="select-value" select="time/day_of_month"/>
                </xsl:call-template>
                <xsl:call-template name="opt">
                  <xsl:with-param name="value" select="'17'"/>
                  <xsl:with-param name="select-value" select="time/day_of_month"/>
                </xsl:call-template>
                <xsl:call-template name="opt">
                  <xsl:with-param name="value" select="'18'"/>
                  <xsl:with-param name="select-value" select="time/day_of_month"/>
                </xsl:call-template>
                <xsl:call-template name="opt">
                  <xsl:with-param name="value" select="'19'"/>
                  <xsl:with-param name="select-value" select="time/day_of_month"/>
                </xsl:call-template>
                <xsl:call-template name="opt">
                  <xsl:with-param name="value" select="'20'"/>
                  <xsl:with-param name="select-value" select="time/day_of_month"/>
                </xsl:call-template>
                <xsl:call-template name="opt">
                  <xsl:with-param name="value" select="'21'"/>
                  <xsl:with-param name="select-value" select="time/day_of_month"/>
                </xsl:call-template>
                <xsl:call-template name="opt">
                  <xsl:with-param name="value" select="'22'"/>
                  <xsl:with-param name="select-value" select="time/day_of_month"/>
                </xsl:call-template>
                <xsl:call-template name="opt">
                  <xsl:with-param name="value" select="'23'"/>
                  <xsl:with-param name="select-value" select="time/day_of_month"/>
                </xsl:call-template>
                <xsl:call-template name="opt">
                  <xsl:with-param name="value" select="'24'"/>
                  <xsl:with-param name="select-value" select="time/day_of_month"/>
                </xsl:call-template>
                <xsl:call-template name="opt">
                  <xsl:with-param name="value" select="'25'"/>
                  <xsl:with-param name="select-value" select="time/day_of_month"/>
                </xsl:call-template>
                <xsl:call-template name="opt">
                  <xsl:with-param name="value" select="'26'"/>
                  <xsl:with-param name="select-value" select="time/day_of_month"/>
                </xsl:call-template>
                <xsl:call-template name="opt">
                  <xsl:with-param name="value" select="'27'"/>
                  <xsl:with-param name="select-value" select="time/day_of_month"/>
                </xsl:call-template>
                <xsl:call-template name="opt">
                  <xsl:with-param name="value" select="'28'"/>
                  <xsl:with-param name="select-value" select="time/day_of_month"/>
                </xsl:call-template>
                <xsl:call-template name="opt">
                  <xsl:with-param name="value" select="'29'"/>
                  <xsl:with-param name="select-value" select="time/day_of_month"/>
                </xsl:call-template>
                <xsl:call-template name="opt">
                  <xsl:with-param name="value" select="'30'"/>
                  <xsl:with-param name="select-value" select="time/day_of_month"/>
                </xsl:call-template>
                <xsl:call-template name="opt">
                  <xsl:with-param name="value" select="'31'"/>
                  <xsl:with-param name="select-value" select="time/day_of_month"/>
                </xsl:call-template>
              </select>
              <select name="month">
                <xsl:call-template name="opt">
                  <xsl:with-param name="value" select="'01'"/>
                  <xsl:with-param name="content" select="'Jan'"/>
                  <xsl:with-param name="select-value" select="time/month"/>
                </xsl:call-template>
                <xsl:call-template name="opt">
                  <xsl:with-param name="value" select="'02'"/>
                  <xsl:with-param name="content" select="'Feb'"/>
                  <xsl:with-param name="select-value" select="time/month"/>
                </xsl:call-template>
                <xsl:call-template name="opt">
                  <xsl:with-param name="value" select="'03'"/>
                  <xsl:with-param name="content" select="'Mar'"/>
                  <xsl:with-param name="select-value" select="time/month"/>
                </xsl:call-template>
                <xsl:call-template name="opt">
                  <xsl:with-param name="value" select="'04'"/>
                  <xsl:with-param name="content" select="'Apr'"/>
                  <xsl:with-param name="select-value" select="time/month"/>
                </xsl:call-template>
                <xsl:call-template name="opt">
                  <xsl:with-param name="value" select="'05'"/>
                  <xsl:with-param name="content" select="'May'"/>
                  <xsl:with-param name="select-value" select="time/month"/>
                </xsl:call-template>
                <xsl:call-template name="opt">
                  <xsl:with-param name="value" select="'06'"/>
                  <xsl:with-param name="content" select="'Jun'"/>
                  <xsl:with-param name="select-value" select="time/month"/>
                </xsl:call-template>
                <xsl:call-template name="opt">
                  <xsl:with-param name="value" select="'07'"/>
                  <xsl:with-param name="content" select="'Jul'"/>
                  <xsl:with-param name="select-value" select="time/month"/>
                </xsl:call-template>
                <xsl:call-template name="opt">
                  <xsl:with-param name="value" select="'08'"/>
                  <xsl:with-param name="content" select="'Aug'"/>
                  <xsl:with-param name="select-value" select="time/month"/>
                </xsl:call-template>
                <xsl:call-template name="opt">
                  <xsl:with-param name="value" select="'09'"/>
                  <xsl:with-param name="content" select="'Sep'"/>
                  <xsl:with-param name="select-value" select="time/month"/>
                </xsl:call-template>
                <xsl:call-template name="opt">
                  <xsl:with-param name="value" select="'10'"/>
                  <xsl:with-param name="content" select="'Oct'"/>
                  <xsl:with-param name="select-value" select="time/month"/>
                </xsl:call-template>
                <xsl:call-template name="opt">
                  <xsl:with-param name="value" select="'11'"/>
                  <xsl:with-param name="content" select="'Nov'"/>
                  <xsl:with-param name="select-value" select="time/month"/>
                </xsl:call-template>
                <xsl:call-template name="opt">
                  <xsl:with-param name="value" select="'12'"/>
                  <xsl:with-param name="content" select="'Dec'"/>
                  <xsl:with-param name="select-value" select="time/month"/>
                </xsl:call-template>
              </select>
              <select name="year">
                <xsl:call-template name="opt">
                  <xsl:with-param name="value" select="'2012'"/>
                  <xsl:with-param name="select-value" select="time/year"/>
                </xsl:call-template>
                <xsl:call-template name="opt">
                  <xsl:with-param name="value" select="'2013'"/>
                  <xsl:with-param name="select-value" select="time/year"/>
                </xsl:call-template>
                <xsl:call-template name="opt">
                  <xsl:with-param name="value" select="'2014'"/>
                  <xsl:with-param name="select-value" select="time/year"/>
                </xsl:call-template>
                <xsl:call-template name="opt">
                  <xsl:with-param name="value" select="'2015'"/>
                  <xsl:with-param name="select-value" select="time/year"/>
                </xsl:call-template>
                <xsl:call-template name="opt">
                  <xsl:with-param name="value" select="'2016'"/>
                  <xsl:with-param name="select-value" select="time/year"/>
                </xsl:call-template>
                <xsl:call-template name="opt">
                  <xsl:with-param name="value" select="'2017'"/>
                  <xsl:with-param name="select-value" select="time/year"/>
                </xsl:call-template>
              </select>
            </td>
          </tr>
          <tr class="odd">
            <td valign="top" width="125">Timezone (optional)</td>
            <td>
              <input type="text"
                     name="timezone"
                     value="{commands_response/get_schedules_response/schedule/timezone}"
                     size="30"
                     maxlength="80"/>
            </td>
          </tr>
          <tr class="even">
            <td valign="top" width="125">Period (optional)</td>
            <td>
              <input type="text"
                     name="period"
                     value="0"
                     size="3"
                     maxlength="80"/>
              <select name="period_unit">
                <option value="hour" selected="1">hour(s)</option>
                <option value="day">day(s)</option>
                <option value="week">week(s)</option>
                <option value="month">month(s)</option>
              </select>
            </td>
          </tr>
          <tr class="odd">
            <td valign="top" width="125">Duration (optional)</td>
            <td>
              <input type="text"
                     name="duration"
                     value="0"
                     size="3"
                     maxlength="80"/>
              <select name="duration_unit">
                <option value="hour" selected="1">hour(s)</option>
                <option value="day">day(s)</option>
                <option value="week">week(s)</option>
              </select>
            </td>
          </tr>
          <tr class="even">
            <td colspan="2" style="text-align:right;">
              <input type="submit" name="submit" value="Create Schedule"/>
            </td>
          </tr>
        </table>
      </form>
    </div>
  </div>
</xsl:template>

<xsl:template match="new_schedule">
  <xsl:apply-templates select="gsad_msg"/>
  <xsl:apply-templates select="create_schedule_response"/>
  <xsl:apply-templates select="commands_response/delete_schedule_response"/>
  <xsl:call-template name="html-create-schedule-form"/>
</xsl:template>

<xsl:template name="html-schedules-table">
  <xsl:call-template name="list-window">
    <xsl:with-param name="type" select="'schedule'"/>
    <xsl:with-param name="cap-type" select="'Schedule'"/>
    <xsl:with-param name="resources-summary" select="schedules"/>
    <xsl:with-param name="resources" select="schedule"/>
    <xsl:with-param name="count" select="count (schedule)"/>
    <xsl:with-param name="filtered-count" select="schedule_count/filtered"/>
    <xsl:with-param name="full-count" select="schedule_count/text ()"/>
    <xsl:with-param name="headings" select="'Name|name First&#xa0;Run|first_run Next&#xa0;Run|next_run Period|period Duration|duration'"/>
  </xsl:call-template>
</xsl:template>

<!--     CREATE_SCHEDULE_RESPONSE -->

<xsl:template match="create_schedule_response">
  <xsl:call-template name="command_result_dialog">
    <xsl:with-param name="operation">Create Schedule</xsl:with-param>
    <xsl:with-param name="status">
      <xsl:value-of select="@status"/>
    </xsl:with-param>
    <xsl:with-param name="msg">
      <xsl:value-of select="@status_text"/>
    </xsl:with-param>
  </xsl:call-template>
</xsl:template>

<!--     DELETE_SCHEDULE_RESPONSE -->

<xsl:template match="delete_schedule_response">
  <xsl:call-template name="command_result_dialog">
    <xsl:with-param name="operation">
      Delete Schedule
    </xsl:with-param>
    <xsl:with-param name="status">
      <xsl:value-of select="@status"/>
    </xsl:with-param>
    <xsl:with-param name="msg">
      <xsl:value-of select="@status_text"/>
    </xsl:with-param>
  </xsl:call-template>
</xsl:template>

<!--     MODIFY_SCHEDULE_RESPONSE -->

<xsl:template match="modify_schedule_response">
  <xsl:call-template name="command_result_dialog">
    <xsl:with-param name="operation">Save Schedules</xsl:with-param>
    <xsl:with-param name="status">
      <xsl:value-of select="@status"/>
    </xsl:with-param>
    <xsl:with-param name="msg">
      <xsl:value-of select="@status_text"/>
    </xsl:with-param>
  </xsl:call-template>
</xsl:template>

<!--     EDIT_SCHEDULE -->

<xsl:template name="schedule-select-options">
  <xsl:param name="selected"/>
  <xsl:param name="max" select="24"/>
  <xsl:param name="current" select="0"/>
  <xsl:if test="$current &lt;= $max">
    <xsl:choose>
      <xsl:when test="$selected = $current">
        <option value="{format-number ($current, '00')}" selected="1">
          <xsl:value-of select="format-number ($current, '00')"/>
        </option>
      </xsl:when>
      <xsl:otherwise>
        <option value="{format-number ($current, '00')}">
          <xsl:value-of select="format-number ($current, '00')"/>
        </option>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:call-template name="schedule-select-options">
      <xsl:with-param name="selected" select="$selected"/>
      <xsl:with-param name="current" select="$current + 1"/>
      <xsl:with-param name="max" select="$max"/>
    </xsl:call-template>
  </xsl:if>
</xsl:template>

<xsl:template name="html-edit-schedule-form">
  <div class="gb_window">
    <div class="gb_window_part_left"></div>
    <div class="gb_window_part_right"></div>
    <div class="gb_window_part_center">Edit Schedule
      <xsl:call-template name="edit-header-icons">
        <xsl:with-param name="cap-type" select="'Schedule'"/>
        <xsl:with-param name="type" select="'schedule'"/>
        <xsl:with-param name="id"
                        select="commands_response/get_schedules_response/schedule/@id"/>
      </xsl:call-template>
    </div>
    <div class="gb_window_part_content">
      <form action="" method="post" enctype="multipart/form-data">
        <input type="hidden" name="token" value="{/envelope/token}"/>
        <input type="hidden" name="cmd" value="save_schedule"/>
        <input type="hidden" name="caller" value="{/envelope/caller}"/>
        <input type="hidden"
               name="schedule_id"
               value="{commands_response/get_schedules_response/schedule/@id}"/>
        <input type="hidden" name="next" value="{/envelope/params/next}"/>
        <input type="hidden" name="schedule" value="{/envelope/params/schedule}"/>
        <input type="hidden" name="filt_id" value="{/envelope/params/filt_id}"/>
        <table border="0" cellspacing="0" cellpadding="3" width="100%">
          <tr class="odd">
            <td valign="top" width="165">Name</td>
            <td>
              <input type="text"
                     name="name"
                     value="{commands_response/get_schedules_response/schedule/name}"
                     size="30"
                     maxlength="80"/>
            </td>
          </tr>
          <tr>
            <td valign="top" width="175">Comment (optional)</td>
            <td>
              <input type="text" name="comment" size="30" maxlength="400"
                     value="{commands_response/get_schedules_response/schedule/comment}"/>
            </td>
          </tr>
          <tr class="odd">
            <td valign="top" width="125">First Time</td>
            <td>
              <xsl:variable name="hour"
                            select="format-number (date:hour-in-day (commands_response/get_schedules_response/schedule/first_time), '00')"/>
              <select name="hour">
                <xsl:call-template name="opt">
                  <xsl:with-param name="value" select="'00'"/>
                  <xsl:with-param name="select-value" select="$hour"/>
                </xsl:call-template>
                <xsl:call-template name="opt">
                  <xsl:with-param name="value" select="'01'"/>
                  <xsl:with-param name="select-value" select="$hour"/>
                </xsl:call-template>
                <xsl:call-template name="opt">
                  <xsl:with-param name="value" select="'02'"/>
                  <xsl:with-param name="select-value" select="$hour"/>
                </xsl:call-template>
                <xsl:call-template name="opt">
                  <xsl:with-param name="value" select="'03'"/>
                  <xsl:with-param name="select-value" select="$hour"/>
                </xsl:call-template>
                <xsl:call-template name="opt">
                  <xsl:with-param name="value" select="'04'"/>
                  <xsl:with-param name="select-value" select="$hour"/>
                </xsl:call-template>
                <xsl:call-template name="opt">
                  <xsl:with-param name="value" select="'05'"/>
                  <xsl:with-param name="select-value" select="$hour"/>
                </xsl:call-template>
                <xsl:call-template name="opt">
                  <xsl:with-param name="value" select="'06'"/>
                  <xsl:with-param name="select-value" select="$hour"/>
                </xsl:call-template>
                <xsl:call-template name="opt">
                  <xsl:with-param name="value" select="'07'"/>
                  <xsl:with-param name="select-value" select="$hour"/>
                </xsl:call-template>
                <xsl:call-template name="opt">
                  <xsl:with-param name="value" select="'08'"/>
                  <xsl:with-param name="select-value" select="$hour"/>
                </xsl:call-template>
                <xsl:call-template name="opt">
                  <xsl:with-param name="value" select="'09'"/>
                  <xsl:with-param name="select-value" select="$hour"/>
                </xsl:call-template>
                <xsl:call-template name="opt">
                  <xsl:with-param name="value" select="'10'"/>
                  <xsl:with-param name="select-value" select="$hour"/>
                </xsl:call-template>
                <xsl:call-template name="opt">
                  <xsl:with-param name="value" select="'11'"/>
                  <xsl:with-param name="select-value" select="$hour"/>
                </xsl:call-template>
                <xsl:call-template name="opt">
                  <xsl:with-param name="value" select="'12'"/>
                  <xsl:with-param name="select-value" select="$hour"/>
                </xsl:call-template>
                <xsl:call-template name="opt">
                  <xsl:with-param name="value" select="'13'"/>
                  <xsl:with-param name="select-value" select="$hour"/>
                </xsl:call-template>
                <xsl:call-template name="opt">
                  <xsl:with-param name="value" select="'14'"/>
                  <xsl:with-param name="select-value" select="$hour"/>
                </xsl:call-template>
                <xsl:call-template name="opt">
                  <xsl:with-param name="value" select="'15'"/>
                  <xsl:with-param name="select-value" select="$hour"/>
                </xsl:call-template>
                <xsl:call-template name="opt">
                  <xsl:with-param name="value" select="'16'"/>
                  <xsl:with-param name="select-value" select="$hour"/>
                </xsl:call-template>
                <xsl:call-template name="opt">
                  <xsl:with-param name="value" select="'17'"/>
                  <xsl:with-param name="select-value" select="$hour"/>
                </xsl:call-template>
                <xsl:call-template name="opt">
                  <xsl:with-param name="value" select="'18'"/>
                  <xsl:with-param name="select-value" select="$hour"/>
                </xsl:call-template>
                <xsl:call-template name="opt">
                  <xsl:with-param name="value" select="'19'"/>
                  <xsl:with-param name="select-value" select="$hour"/>
                </xsl:call-template>
                <xsl:call-template name="opt">
                  <xsl:with-param name="value" select="'20'"/>
                  <xsl:with-param name="select-value" select="$hour"/>
                </xsl:call-template>
                <xsl:call-template name="opt">
                  <xsl:with-param name="value" select="'21'"/>
                  <xsl:with-param name="select-value" select="$hour"/>
                </xsl:call-template>
                <xsl:call-template name="opt">
                  <xsl:with-param name="value" select="'22'"/>
                  <xsl:with-param name="select-value" select="$hour"/>
                </xsl:call-template>
                <xsl:call-template name="opt">
                  <xsl:with-param name="value" select="'23'"/>
                  <xsl:with-param name="select-value" select="$hour"/>
                </xsl:call-template>
              </select>
              h
              <select name="minute">
                <xsl:variable name="minute"
                              select="format-number (date:minute-in-hour (commands_response/get_schedules_response/schedule/first_time), '00')"/>
                <xsl:call-template name="opt">
                  <xsl:with-param name="value" select="'00'"/>
                  <xsl:with-param name="select-value" select="$minute - ($minute mod 5)"/>
                </xsl:call-template>
                <xsl:call-template name="opt">
                  <xsl:with-param name="value" select="'05'"/>
                  <xsl:with-param name="select-value" select="$minute - ($minute mod 5)"/>
                </xsl:call-template>
                <xsl:call-template name="opt">
                  <xsl:with-param name="value" select="'10'"/>
                  <xsl:with-param name="select-value" select="$minute - ($minute mod 5)"/>
                </xsl:call-template>
                <xsl:call-template name="opt">
                  <xsl:with-param name="value" select="'15'"/>
                  <xsl:with-param name="select-value" select="$minute - ($minute mod 5)"/>
                </xsl:call-template>
                <xsl:call-template name="opt">
                  <xsl:with-param name="value" select="'20'"/>
                  <xsl:with-param name="select-value" select="$minute - ($minute mod 5)"/>
                </xsl:call-template>
                <xsl:call-template name="opt">
                  <xsl:with-param name="value" select="'25'"/>
                  <xsl:with-param name="select-value" select="$minute - ($minute mod 5)"/>
                </xsl:call-template>
                <xsl:call-template name="opt">
                  <xsl:with-param name="value" select="'30'"/>
                  <xsl:with-param name="select-value" select="$minute - ($minute mod 5)"/>
                </xsl:call-template>
                <xsl:call-template name="opt">
                  <xsl:with-param name="value" select="'35'"/>
                  <xsl:with-param name="select-value" select="$minute - ($minute mod 5)"/>
                </xsl:call-template>
                <xsl:call-template name="opt">
                  <xsl:with-param name="value" select="'40'"/>
                  <xsl:with-param name="select-value" select="$minute - ($minute mod 5)"/>
                </xsl:call-template>
                <xsl:call-template name="opt">
                  <xsl:with-param name="value" select="'45'"/>
                  <xsl:with-param name="select-value" select="$minute - ($minute mod 5)"/>
                </xsl:call-template>
                <xsl:call-template name="opt">
                  <xsl:with-param name="value" select="'50'"/>
                  <xsl:with-param name="select-value" select="$minute - ($minute mod 5)"/>
                </xsl:call-template>
                <xsl:call-template name="opt">
                  <xsl:with-param name="value" select="'55'"/>
                  <xsl:with-param name="select-value" select="$minute - ($minute mod 5)"/>
                </xsl:call-template>
              </select>
              ,
              <select name="day_of_month">
                <xsl:variable name="day"
                              select="format-number (date:day-in-month (commands_response/get_schedules_response/schedule/first_time), '00')"/>
                <xsl:call-template name="opt">
                  <xsl:with-param name="value" select="'01'"/>
                  <xsl:with-param name="select-value" select="$day"/>
                </xsl:call-template>
                <xsl:call-template name="opt">
                  <xsl:with-param name="value" select="'02'"/>
                  <xsl:with-param name="select-value" select="$day"/>
                </xsl:call-template>
                <xsl:call-template name="opt">
                  <xsl:with-param name="value" select="'03'"/>
                  <xsl:with-param name="select-value" select="$day"/>
                </xsl:call-template>
                <xsl:call-template name="opt">
                  <xsl:with-param name="value" select="'04'"/>
                  <xsl:with-param name="select-value" select="$day"/>
                </xsl:call-template>
                <xsl:call-template name="opt">
                  <xsl:with-param name="value" select="'05'"/>
                  <xsl:with-param name="select-value" select="$day"/>
                </xsl:call-template>
                <xsl:call-template name="opt">
                  <xsl:with-param name="value" select="'06'"/>
                  <xsl:with-param name="select-value" select="$day"/>
                </xsl:call-template>
                <xsl:call-template name="opt">
                  <xsl:with-param name="value" select="'07'"/>
                  <xsl:with-param name="select-value" select="$day"/>
                </xsl:call-template>
                <xsl:call-template name="opt">
                  <xsl:with-param name="value" select="'08'"/>
                  <xsl:with-param name="select-value" select="$day"/>
                </xsl:call-template>
                <xsl:call-template name="opt">
                  <xsl:with-param name="value" select="'09'"/>
                  <xsl:with-param name="select-value" select="$day"/>
                </xsl:call-template>
                <xsl:call-template name="opt">
                  <xsl:with-param name="value" select="'10'"/>
                  <xsl:with-param name="select-value" select="$day"/>
                </xsl:call-template>
                <xsl:call-template name="opt">
                  <xsl:with-param name="value" select="'11'"/>
                  <xsl:with-param name="select-value" select="$day"/>
                </xsl:call-template>
                <xsl:call-template name="opt">
                  <xsl:with-param name="value" select="'12'"/>
                  <xsl:with-param name="select-value" select="$day"/>
                </xsl:call-template>
                <xsl:call-template name="opt">
                  <xsl:with-param name="value" select="'13'"/>
                  <xsl:with-param name="select-value" select="$day"/>
                </xsl:call-template>
                <xsl:call-template name="opt">
                  <xsl:with-param name="value" select="'14'"/>
                  <xsl:with-param name="select-value" select="$day"/>
                </xsl:call-template>
                <xsl:call-template name="opt">
                  <xsl:with-param name="value" select="'15'"/>
                  <xsl:with-param name="select-value" select="$day"/>
                </xsl:call-template>
                <xsl:call-template name="opt">
                  <xsl:with-param name="value" select="'16'"/>
                  <xsl:with-param name="select-value" select="$day"/>
                </xsl:call-template>
                <xsl:call-template name="opt">
                  <xsl:with-param name="value" select="'17'"/>
                  <xsl:with-param name="select-value" select="$day"/>
                </xsl:call-template>
                <xsl:call-template name="opt">
                  <xsl:with-param name="value" select="'18'"/>
                  <xsl:with-param name="select-value" select="$day"/>
                </xsl:call-template>
                <xsl:call-template name="opt">
                  <xsl:with-param name="value" select="'19'"/>
                  <xsl:with-param name="select-value" select="$day"/>
                </xsl:call-template>
                <xsl:call-template name="opt">
                  <xsl:with-param name="value" select="'20'"/>
                  <xsl:with-param name="select-value" select="$day"/>
                </xsl:call-template>
                <xsl:call-template name="opt">
                  <xsl:with-param name="value" select="'21'"/>
                  <xsl:with-param name="select-value" select="$day"/>
                </xsl:call-template>
                <xsl:call-template name="opt">
                  <xsl:with-param name="value" select="'22'"/>
                  <xsl:with-param name="select-value" select="$day"/>
                </xsl:call-template>
                <xsl:call-template name="opt">
                  <xsl:with-param name="value" select="'23'"/>
                  <xsl:with-param name="select-value" select="$day"/>
                </xsl:call-template>
                <xsl:call-template name="opt">
                  <xsl:with-param name="value" select="'24'"/>
                  <xsl:with-param name="select-value" select="$day"/>
                </xsl:call-template>
                <xsl:call-template name="opt">
                  <xsl:with-param name="value" select="'25'"/>
                  <xsl:with-param name="select-value" select="$day"/>
                </xsl:call-template>
                <xsl:call-template name="opt">
                  <xsl:with-param name="value" select="'26'"/>
                  <xsl:with-param name="select-value" select="$day"/>
                </xsl:call-template>
                <xsl:call-template name="opt">
                  <xsl:with-param name="value" select="'27'"/>
                  <xsl:with-param name="select-value" select="$day"/>
                </xsl:call-template>
                <xsl:call-template name="opt">
                  <xsl:with-param name="value" select="'28'"/>
                  <xsl:with-param name="select-value" select="$day"/>
                </xsl:call-template>
                <xsl:call-template name="opt">
                  <xsl:with-param name="value" select="'29'"/>
                  <xsl:with-param name="select-value" select="$day"/>
                </xsl:call-template>
                <xsl:call-template name="opt">
                  <xsl:with-param name="value" select="'30'"/>
                  <xsl:with-param name="select-value" select="$day"/>
                </xsl:call-template>
                <xsl:call-template name="opt">
                  <xsl:with-param name="value" select="'31'"/>
                  <xsl:with-param name="select-value" select="$day"/>
                </xsl:call-template>
              </select>
              <select name="month">
                <xsl:variable name="month"
                              select="format-number (date:month-in-year (commands_response/get_schedules_response/schedule/first_time), '00')"/>
                <xsl:call-template name="opt">
                  <xsl:with-param name="value" select="'01'"/>
                  <xsl:with-param name="content" select="'Jan'"/>
                  <xsl:with-param name="select-value" select="$month"/>
                </xsl:call-template>
                <xsl:call-template name="opt">
                  <xsl:with-param name="value" select="'02'"/>
                  <xsl:with-param name="content" select="'Feb'"/>
                  <xsl:with-param name="select-value" select="$month"/>
                </xsl:call-template>
                <xsl:call-template name="opt">
                  <xsl:with-param name="value" select="'03'"/>
                  <xsl:with-param name="content" select="'Mar'"/>
                  <xsl:with-param name="select-value" select="$month"/>
                </xsl:call-template>
                <xsl:call-template name="opt">
                  <xsl:with-param name="value" select="'04'"/>
                  <xsl:with-param name="content" select="'Apr'"/>
                  <xsl:with-param name="select-value" select="$month"/>
                </xsl:call-template>
                <xsl:call-template name="opt">
                  <xsl:with-param name="value" select="'05'"/>
                  <xsl:with-param name="content" select="'May'"/>
                  <xsl:with-param name="select-value" select="$month"/>
                </xsl:call-template>
                <xsl:call-template name="opt">
                  <xsl:with-param name="value" select="'06'"/>
                  <xsl:with-param name="content" select="'Jun'"/>
                  <xsl:with-param name="select-value" select="$month"/>
                </xsl:call-template>
                <xsl:call-template name="opt">
                  <xsl:with-param name="value" select="'07'"/>
                  <xsl:with-param name="content" select="'Jul'"/>
                  <xsl:with-param name="select-value" select="$month"/>
                </xsl:call-template>
                <xsl:call-template name="opt">
                  <xsl:with-param name="value" select="'08'"/>
                  <xsl:with-param name="content" select="'Aug'"/>
                  <xsl:with-param name="select-value" select="$month"/>
                </xsl:call-template>
                <xsl:call-template name="opt">
                  <xsl:with-param name="value" select="'09'"/>
                  <xsl:with-param name="content" select="'Sep'"/>
                  <xsl:with-param name="select-value" select="$month"/>
                </xsl:call-template>
                <xsl:call-template name="opt">
                  <xsl:with-param name="value" select="'10'"/>
                  <xsl:with-param name="content" select="'Oct'"/>
                  <xsl:with-param name="select-value" select="$month"/>
                </xsl:call-template>
                <xsl:call-template name="opt">
                  <xsl:with-param name="value" select="'11'"/>
                  <xsl:with-param name="content" select="'Nov'"/>
                  <xsl:with-param name="select-value" select="$month"/>
                </xsl:call-template>
                <xsl:call-template name="opt">
                  <xsl:with-param name="value" select="'12'"/>
                  <xsl:with-param name="content" select="'Dec'"/>
                  <xsl:with-param name="select-value" select="$month"/>
                </xsl:call-template>
              </select>
              <select name="year">
                <xsl:variable name="year"
                              select="date:year (commands_response/get_schedules_response/schedule/first_time)"/>
                <xsl:if test="$year &lt; 2012 or $year &gt; 2017">
                  <option value="{$year}"><xsl:value-of select="$year"/></option>
                </xsl:if>
                <xsl:call-template name="opt">
                  <xsl:with-param name="value" select="'2012'"/>
                  <xsl:with-param name="select-value" select="$year"/>
                </xsl:call-template>
                <xsl:call-template name="opt">
                  <xsl:with-param name="value" select="'2013'"/>
                  <xsl:with-param name="select-value" select="$year"/>
                </xsl:call-template>
                <xsl:call-template name="opt">
                  <xsl:with-param name="value" select="'2014'"/>
                  <xsl:with-param name="select-value" select="$year"/>
                </xsl:call-template>
                <xsl:call-template name="opt">
                  <xsl:with-param name="value" select="'2015'"/>
                  <xsl:with-param name="select-value" select="$year"/>
                </xsl:call-template>
                <xsl:call-template name="opt">
                  <xsl:with-param name="value" select="'2016'"/>
                  <xsl:with-param name="select-value" select="$year"/>
                </xsl:call-template>
                <xsl:call-template name="opt">
                  <xsl:with-param name="value" select="'2017'"/>
                  <xsl:with-param name="select-value" select="$year"/>
                </xsl:call-template>
              </select>
            </td>
          </tr>
          <tr class="odd">
            <td valign="top" width="125">Timezone</td>
            <td>
              <input type="text"
                     name="timezone"
                     value="{commands_response/get_schedules_response/schedule/timezone}"
                     size="30"
                     maxlength="80"/>
            </td>
          </tr>
          <tr class="even">
            <td valign="top" width="125">Period (optional)</td>
            <td>
              <xsl:choose>
                <xsl:when test="commands_response/get_schedules_response/schedule/simple_period/text() = 0 and commands_response/get_schedules_response/schedule/period/text() &gt; 0">
                  <input type="text"
                         name="period"
                         value="{commands_response/get_schedules_response/schedule/period}"
                         size="10"
                         maxlength="80"/>
                  <input type="hidden" name="period_unit" value="second"/>
                  seconds
                </xsl:when>
                <xsl:when test="commands_response/get_schedules_response/schedule/simple_period/text() = 0 and commands_response/get_schedules_response/schedule/period_months/text() &gt; 0">
                  <input type="text"
                         name="period"
                         value="{commands_response/get_schedules_response/schedule/period_months}"
                         size="10"
                         maxlength="80"/>
                  <input type="hidden" name="period_unit" value="month"/>
                  months
                </xsl:when>
                <xsl:otherwise>
                  <input type="text"
                         name="period"
                         value="{commands_response/get_schedules_response/schedule/simple_period/text()}"
                         size="4"
                         maxlength="80"/>
                  <select name="period_unit">
                    <xsl:choose>
                      <xsl:when test="commands_response/get_schedules_response/schedule/simple_period/unit = 'hour'">
                        <option value="hour" selected="1">hour(s)</option>
                      </xsl:when>
                      <xsl:otherwise>
                        <option value="hour">hour(s)</option>
                      </xsl:otherwise>
                    </xsl:choose>
                    <xsl:choose>
                      <xsl:when test="commands_response/get_schedules_response/schedule/simple_period/unit = 'day'">
                        <option value="day" selected="1">day(s)</option>
                      </xsl:when>
                      <xsl:otherwise>
                        <option value="day">day(s)</option>
                      </xsl:otherwise>
                    </xsl:choose>
                    <xsl:choose>
                      <xsl:when test="commands_response/get_schedules_response/schedule/simple_period/unit = 'week'">
                        <option value="week" selected="1">week(s)</option>
                      </xsl:when>
                      <xsl:otherwise>
                        <option value="week">week(s)</option>
                      </xsl:otherwise>
                    </xsl:choose>
                    <xsl:choose>
                      <xsl:when test="commands_response/get_schedules_response/schedule/simple_period/unit = 'month'">
                        <option value="month" selected="1">month(s)</option>
                      </xsl:when>
                      <xsl:otherwise>
                        <option value="month">month(s)</option>
                      </xsl:otherwise>
                    </xsl:choose>
                  </select>
                </xsl:otherwise>
              </xsl:choose>
            </td>
          </tr>
          <tr class="odd">
            <td valign="top" width="125">Duration (optional)</td>
            <td>
              <xsl:choose>
                <xsl:when test="commands_response/get_schedules_response/schedule/simple_duration/text() = 0 and commands_response/get_schedules_response/schedule/duration/text() &gt; 0">
                  <input type="text"
                         name="duration"
                         value="{commands_response/get_schedules_response/schedule/duration}"
                         size="10"
                         maxlength="80"/>
                  <input type="hidden" name="duration_unit" value="second"/>
                  seconds
                </xsl:when>
                <xsl:otherwise>
                  <input type="text"
                         name="duration"
                         value="{commands_response/get_schedules_response/schedule/simple_duration/text()}"
                         size="4"
                         maxlength="80"/>
                  <select name="duration_unit">
                    <xsl:choose>
                      <xsl:when test="commands_response/get_schedules_response/schedule/simple_duration/unit = 'hour'">
                        <option value="hour" selected="1">hour(s)</option>
                      </xsl:when>
                      <xsl:otherwise>
                        <option value="hour">hour(s)</option>
                      </xsl:otherwise>
                    </xsl:choose>
                    <xsl:choose>
                      <xsl:when test="commands_response/get_schedules_response/schedule/simple_duration/unit = 'day'">
                        <option value="day" selected="1">day(s)</option>
                      </xsl:when>
                      <xsl:otherwise>
                        <option value="day">day(s)</option>
                      </xsl:otherwise>
                    </xsl:choose>
                    <xsl:choose>
                      <xsl:when test="commands_response/get_schedules_response/schedule/simple_duration/unit = 'week'">
                        <option value="week" selected="1">week(s)</option>
                      </xsl:when>
                      <xsl:otherwise>
                        <option value="week">week(s)</option>
                      </xsl:otherwise>
                    </xsl:choose>
                  </select>
                </xsl:otherwise>
              </xsl:choose>
            </td>
          </tr>
          <tr>
            <td colspan="2" style="text-align:right;">
              <input type="submit" name="submit" value="Save Schedule"/>
            </td>
          </tr>
        </table>
        <br/>
      </form>
    </div>
  </div>
</xsl:template>

<xsl:template match="edit_schedule">
  <xsl:apply-templates select="gsad_msg"/>
  <xsl:call-template name="html-edit-schedule-form"/>
</xsl:template>

<!--     SCHEDULE -->

<xsl:template name="interval-with-unit">
  <xsl:param name="interval">0</xsl:param>
  <xsl:choose>
    <xsl:when test="$interval mod (60 * 60 * 24 * 7) = 0">
      <xsl:value-of select="$interval div (60 * 60 * 24 * 7)"/>
      <xsl:choose>
        <xsl:when test="$interval = (60 * 60 * 24 * 7)">
          week
        </xsl:when>
        <xsl:otherwise>
          weeks
        </xsl:otherwise>
      </xsl:choose>
    </xsl:when>
    <xsl:when test="$interval mod (60 * 60 * 24) = 0">
      <xsl:value-of select="$interval div (60 * 60 * 24)"/>
      <xsl:choose>
        <xsl:when test="$interval = (60 * 60 * 24)">
          day
        </xsl:when>
        <xsl:otherwise>
          days
        </xsl:otherwise>
      </xsl:choose>
    </xsl:when>
    <xsl:when test="$interval mod (60 * 60) = 0">
      <xsl:value-of select="$interval div (60 * 60)"/>
      <xsl:choose>
        <xsl:when test="$interval = (60 * 60)">
          hour
        </xsl:when>
        <xsl:otherwise>
          hours
        </xsl:otherwise>
      </xsl:choose>
    </xsl:when>
    <xsl:when test="$interval mod (60) = 0">
      <xsl:value-of select="$interval div (60)"/>
      <xsl:choose>
        <xsl:when test="$interval = 60">
          min
        </xsl:when>
        <xsl:otherwise>
          mins
        </xsl:otherwise>
      </xsl:choose>
    </xsl:when>
    <xsl:when test="$interval = 1">
      <xsl:value-of select="$interval"/> sec
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="$interval"/> secs
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template match="schedule">
  <xsl:variable name="class">
    <xsl:choose>
      <xsl:when test="position() mod 2 = 0">even</xsl:when>
      <xsl:otherwise>odd</xsl:otherwise>
    </xsl:choose>
  </xsl:variable>
  <tr class="{$class}">
    <td>
      <b>
        <a href="/omp?cmd=get_schedule&amp;schedule_id={@id}&amp;filter={str:encode-uri (../filters/term, true ())}&amp;token={/envelope/token}">
          <xsl:value-of select="name"/>
        </a>
      </b>
      <xsl:choose>
        <xsl:when test="comment != ''">
          <br/>(<xsl:value-of select="comment"/>)
        </xsl:when>
        <xsl:otherwise></xsl:otherwise>
      </xsl:choose>
    </td>
    <td>
      <xsl:value-of select="gsa:long-time-tz (first_time)"/>
    </td>
    <td>
      <xsl:choose>
        <xsl:when test="next_time = 'over'">
          -
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="gsa:long-time-tz (next_time)"/>
        </xsl:otherwise>
      </xsl:choose>
    </td>
    <td>
      <xsl:choose>
        <xsl:when test="period = 0 and period_months = 0">
          Once
        </xsl:when>
        <xsl:when test="period = 0 and period_months = 1">
          1 month
        </xsl:when>
        <xsl:when test="period = 0">
          <xsl:value-of select="period_months"/> months
        </xsl:when>
        <xsl:otherwise>
          <xsl:call-template name="interval-with-unit">
            <xsl:with-param name="interval">
              <xsl:value-of select="period"/>
            </xsl:with-param>
          </xsl:call-template>
        </xsl:otherwise>
      </xsl:choose>
    </td>
    <td>
      <xsl:choose>
        <xsl:when test="duration = 0">
          Entire Operation
        </xsl:when>
        <xsl:otherwise>
          <xsl:call-template name="interval-with-unit">
            <xsl:with-param name="interval">
              <xsl:value-of select="duration"/>
            </xsl:with-param>
          </xsl:call-template>
        </xsl:otherwise>
      </xsl:choose>
    </td>
    <td>
      <xsl:call-template name="list-window-line-icons">
        <xsl:with-param name="cap-type" select="'Schedule'"/>
        <xsl:with-param name="type" select="'schedule'"/>
        <xsl:with-param name="id" select="@id"/>
      </xsl:call-template>
    </td>
  </tr>
</xsl:template>

<xsl:template match="schedule" mode="trash">
  <xsl:variable name="class">
    <xsl:choose>
      <xsl:when test="position() mod 2 = 0">even</xsl:when>
      <xsl:otherwise>odd</xsl:otherwise>
    </xsl:choose>
  </xsl:variable>
  <tr class="{$class}">
    <td>
      <b><xsl:value-of select="name"/></b>
      <xsl:choose>
        <xsl:when test="comment != ''">
          <br/>(<xsl:value-of select="comment"/>)
        </xsl:when>
        <xsl:otherwise></xsl:otherwise>
      </xsl:choose>
    </td>
    <td>
      <xsl:value-of select="first_time"/>
    </td>
    <td>
      <xsl:choose>
        <xsl:when test="next_time &gt; 0">
          <xsl:value-of select="next_time"/>
        </xsl:when>
        <xsl:otherwise>-</xsl:otherwise>
      </xsl:choose>
    </td>
    <td>
      <xsl:choose>
        <xsl:when test="period = 0 and period_months = 0">
          Once
        </xsl:when>
        <xsl:when test="period = 0 and period_months = 1">
          1 month
        </xsl:when>
        <xsl:when test="period = 0">
          <xsl:value-of select="period_months"/> months
        </xsl:when>
        <xsl:otherwise>
          <xsl:call-template name="interval-with-unit">
            <xsl:with-param name="interval">
              <xsl:value-of select="period"/>
            </xsl:with-param>
          </xsl:call-template>
        </xsl:otherwise>
      </xsl:choose>
    </td>
    <td>
      <xsl:choose>
        <xsl:when test="duration = 0">
          Entire Operation
        </xsl:when>
        <xsl:otherwise>
          <xsl:call-template name="interval-with-unit">
            <xsl:with-param name="interval">
              <xsl:value-of select="duration"/>
            </xsl:with-param>
          </xsl:call-template>
        </xsl:otherwise>
      </xsl:choose>
    </td>
    <td>
      <xsl:call-template name="restore-icon">
        <xsl:with-param name="id" select="@id"/>
      </xsl:call-template>
      <xsl:choose>
        <xsl:when test="in_use='0'">
          <xsl:call-template name="trash-delete-icon">
            <xsl:with-param name="type" select="'schedule'"/>
            <xsl:with-param name="id" select="@id"/>
          </xsl:call-template>
        </xsl:when>
        <xsl:otherwise>
          <img src="/img/delete_inactive.png"
               border="0"
               alt="Delete"
               style="margin-left:3px;"/>
        </xsl:otherwise>
      </xsl:choose>
    </td>
  </tr>
</xsl:template>

<xsl:template match="schedule" mode="details">
  <div class="gb_window">
    <div class="gb_window_part_left"></div>
    <div class="gb_window_part_right"></div>
    <div class="gb_window_part_center">
       Schedule Details
      <xsl:call-template name="details-header-icons">
        <xsl:with-param name="cap-type" select="'Schedule'"/>
        <xsl:with-param name="type" select="'schedule'"/>
      </xsl:call-template>
    </div>
    <div class="gb_window_part_content">
      <xsl:call-template name="minor-details"/>
      <table>
        <tr>
          <td><b>Name:</b></td>
          <td><b><xsl:value-of select="name"/></b></td>
        </tr>
        <tr>
          <td>Comment:</td>
          <td><xsl:value-of select="comment"/></td>
        </tr>
        <tr>
          <td>First Run:</td>
          <td><xsl:value-of select="gsa:long-time-tz (first_time)"/></td>
        </tr>
        <tr>
          <td>Next Run:</td>
          <td>
            <xsl:choose>
              <xsl:when test="next_time = 'over'">
                -
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="gsa:long-time-tz (next_time)"/>
              </xsl:otherwise>
            </xsl:choose>
          </td>
        </tr>
        <tr>
          <td>Timezone:</td>
          <td><xsl:value-of select="timezone"/></td>
        </tr>
        <tr>
          <td>Period:</td>
          <td>
            <xsl:choose>
              <xsl:when test="period = 0 and period_months = 0">
                Once
              </xsl:when>
              <xsl:when test="period = 0 and period_months = 1">
                1 month
              </xsl:when>
              <xsl:when test="period = 0">
                <xsl:value-of select="period_months"/> months
              </xsl:when>
              <xsl:otherwise>
                <xsl:call-template name="interval-with-unit">
                  <xsl:with-param name="interval">
                    <xsl:value-of select="period"/>
                  </xsl:with-param>
                </xsl:call-template>
              </xsl:otherwise>
            </xsl:choose>
          </td>
        </tr>
        <tr>
          <td>Duration:</td>
          <td>
            <xsl:choose>
              <xsl:when test="duration = 0">
                Entire Operation
              </xsl:when>
              <xsl:otherwise>
                <xsl:call-template name="interval-with-unit">
                  <xsl:with-param name="interval">
                    <xsl:value-of select="duration"/>
                  </xsl:with-param>
                </xsl:call-template>
              </xsl:otherwise>
            </xsl:choose>
          </td>
        </tr>
      </table>

      <xsl:choose>
        <xsl:when test="count(tasks/task) = 0">
          <h1>Tasks using this Schedule: None</h1>
        </xsl:when>
        <xsl:otherwise>
          <h1>Tasks using this Schedule</h1>
          <table class="gbntable" cellspacing="2" cellpadding="4">
            <tr class="gbntablehead2">
              <td>Name</td>
              <td>Actions</td>
            </tr>
            <xsl:for-each select="tasks/task">
              <xsl:variable name="class">
                <xsl:choose>
                  <xsl:when test="position() mod 2 = 0">even</xsl:when>
                  <xsl:otherwise>odd</xsl:otherwise>
                </xsl:choose>
              </xsl:variable>
              <tr class="{$class}">
                <td><xsl:value-of select="name"/></td>
                <td width="100">
                  <a href="/omp?cmd=get_task&amp;task_id={@id}&amp;token={/envelope/token}" title="Details">
                    <img src="/img/details.png"
                         border="0"
                         alt="Details"
                         style="margin-left:3px;"/>
                  </a>
                </td>
              </tr>
            </xsl:for-each>
          </table>
        </xsl:otherwise>
      </xsl:choose>
    </div>
  </div>
</xsl:template>

<!--     GET_SCHEDULE -->

<xsl:template match="get_schedule">
  <xsl:apply-templates select="gsad_msg"/>
  <xsl:apply-templates select="commands_response/delete_schedule_response"/>
  <xsl:apply-templates select="modify_schedule_response"/>
  <xsl:apply-templates select="get_schedules_response/schedule" mode="details"/>
</xsl:template>

<!--     GET_SCHEDULES -->

<xsl:template match="get_schedules">
  <xsl:apply-templates select="gsad_msg"/>
  <xsl:apply-templates select="delete_schedule_response"/>
  <xsl:apply-templates select="create_filter_response"/>
  <xsl:apply-templates select="create_schedule_response"/>
  <xsl:apply-templates select="modify_schedule_response"/>
  <!-- The for-each makes the get_schedules_response the current node. -->
  <xsl:for-each select="get_schedules_response | commands_response/get_schedules_response">
    <xsl:choose>
      <xsl:when test="substring(@status, 1, 1) = '4' or substring(@status, 1, 1) = '5'">
        <xsl:call-template name="command_result_dialog">
          <xsl:with-param name="operation">
            Get Schedules
          </xsl:with-param>
          <xsl:with-param name="status">
            <xsl:value-of select="@status"/>
          </xsl:with-param>
          <xsl:with-param name="msg">
            <xsl:value-of select="@status_text"/>
          </xsl:with-param>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="html-schedules-table"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:for-each>
</xsl:template>

<!-- END SCHEDULES MANAGEMENT -->

<!-- BEGIN SLAVES MANAGEMENT -->

<xsl:template name="html-create-slave-form">
  <div class="gb_window">
    <div class="gb_window_part_left"></div>
    <div class="gb_window_part_right"></div>
    <div class="gb_window_part_center">New Slave
      <a href="/help/new_slave.html?token={/envelope/token}"
         title="Help: New Slave">
        <img src="/img/help.png"/>
      </a>
      <a href="/omp?cmd=get_slaves&amp;filter={str:encode-uri (/envelope/params/filter, true ())}&amp;filt_id={/envelope/params/filt_id}&amp;token={/envelope/token}"
         title="Slaves" style="margin-left:3px;">
        <img src="/img/list.png" border="0" alt="Slaves"/>
      </a>
    </div>
    <div class="gb_window_part_content">
      <form action="/omp" method="post" enctype="multipart/form-data">
        <input type="hidden" name="token" value="{/envelope/token}"/>
        <input type="hidden" name="cmd" value="create_slave"/>
        <input type="hidden" name="caller" value="{/envelope/caller}"/>
        <table border="0" cellspacing="0" cellpadding="3" width="100%">
          <tr>
            <td valign="top" width="125">Name
            </td>
            <td>
              <input type="text" name="name" value="unnamed" size="30"
                     maxlength="80"/>
            </td>
          </tr>
          <tr>
            <td valign="top" width="125">Comment (optional)</td>
            <td>
              <input type="text" name="comment" size="30" maxlength="400"/>
            </td>
          </tr>
          <tr>
            <td valign="top" width="125">Host</td>
            <td>
              <input type="text" name="host" value="localhost" size="30"
                      maxlength="80"/>
            </td>
          </tr>
          <tr>
            <td valign="top" width="125">Port</td>
            <td>
              <input type="text" name="port" value="9390" size="30"
                     maxlength="80"/>
            </td>
          </tr>
          <tr>
            <td valign="top" width="125">Login</td>
            <td>
              <input type="text" name="login" value="" size="30"
                     maxlength="80"/>
            </td>
          </tr>
          <tr>
            <td valign="top" width="125">Password</td>
            <td>
              <input type="password" autocomplete="off" name="password"
                     value="" size="30" maxlength="40"/>
            </td>
          </tr>
          <tr>
            <td colspan="2" style="text-align:right;">
              <input type="submit" name="submit" value="Create Slave"/>
            </td>
          </tr>
        </table>
      </form>
    </div>
  </div>
</xsl:template>

<xsl:template match="new_slave">
  <xsl:apply-templates select="gsad_msg"/>
  <xsl:apply-templates select="create_slave_response"/>
  <xsl:apply-templates select="commands_response/delete_slave_response"/>
  <xsl:call-template name="html-create-slave-form"/>
</xsl:template>

<xsl:template name="html-slaves-table">
  <xsl:call-template name="list-window">
    <xsl:with-param name="type" select="'slave'"/>
    <xsl:with-param name="cap-type" select="'Slave'"/>
    <xsl:with-param name="resources-summary" select="slaves"/>
    <xsl:with-param name="resources" select="slave"/>
    <xsl:with-param name="count" select="count (slave)"/>
    <xsl:with-param name="filtered-count" select="slave_count/filtered"/>
    <xsl:with-param name="full-count" select="slave_count/text ()"/>
    <xsl:with-param name="headings" select="'Name|name Host|host Port|port Login|login'"/>
  </xsl:call-template>
</xsl:template>

<!--     CREATE_SLAVE_RESPONSE -->

<xsl:template match="create_slave_response">
  <xsl:call-template name="command_result_dialog">
    <xsl:with-param name="operation">Create Slave</xsl:with-param>
    <xsl:with-param name="status">
      <xsl:value-of select="@status"/>
    </xsl:with-param>
    <xsl:with-param name="msg">
      <xsl:value-of select="@status_text"/>
    </xsl:with-param>
  </xsl:call-template>
</xsl:template>

<!--     DELETE_SLAVE_RESPONSE -->

<xsl:template match="delete_slave_response">
  <xsl:call-template name="command_result_dialog">
    <xsl:with-param name="operation">
      Delete Slave
    </xsl:with-param>
    <xsl:with-param name="status">
      <xsl:value-of select="@status"/>
    </xsl:with-param>
    <xsl:with-param name="msg">
      <xsl:value-of select="@status_text"/>
    </xsl:with-param>
  </xsl:call-template>
</xsl:template>

<!--     MODIFY_SLAVE_RESPONSE -->

<xsl:template match="modify_slave_response">
  <xsl:call-template name="command_result_dialog">
    <xsl:with-param name="operation">Save Slave</xsl:with-param>
    <xsl:with-param name="status">
      <xsl:value-of select="@status"/>
    </xsl:with-param>
    <xsl:with-param name="msg">
      <xsl:value-of select="@status_text"/>
    </xsl:with-param>
  </xsl:call-template>
</xsl:template>

<!--     EDIT_SLAVE -->

<xsl:template name="html-edit-slave-form">
  <div class="gb_window">
    <div class="gb_window_part_left"></div>
    <div class="gb_window_part_right"></div>
    <div class="gb_window_part_center">Edit Slave
      <xsl:call-template name="edit-header-icons">
        <xsl:with-param name="cap-type" select="'Slave'"/>
        <xsl:with-param name="type" select="'slave'"/>
        <xsl:with-param name="id"
                        select="commands_response/get_slaves_response/slave/@id"/>
      </xsl:call-template>
    </div>
    <div class="gb_window_part_content">
      <form action="" method="post" enctype="multipart/form-data">
        <input type="hidden" name="token" value="{/envelope/token}"/>
        <input type="hidden" name="cmd" value="save_slave"/>
        <input type="hidden" name="caller" value="{/envelope/caller}"/>
        <input type="hidden"
               name="slave_id"
               value="{commands_response/get_slaves_response/slave/@id}"/>
        <input type="hidden" name="next" value="{/envelope/params/next}"/>
        <input type="hidden" name="slave" value="{/envelope/params/slave}"/>
        <input type="hidden" name="filt_id" value="{/envelope/params/filt_id}"/>
        <table border="0" cellspacing="0" cellpadding="3" width="100%">
          <tr>
            <td valign="top" width="165">Name</td>
            <td>
              <input type="text" name="name" size="30" maxlength="80"
                     value="{commands_response/get_slaves_response/slave/name}"/>
            </td>
          </tr>
          <tr>
            <td valign="top" width="165">Comment (optional)</td>
            <td>
              <input type="text" name="comment" size="30" maxlength="400"
                     value="{commands_response/get_slaves_response/slave/comment}"/>
            </td>
          </tr>
          <tr>
            <td valign="top" width="175">Host</td>
            <td>
              <input type="text" name="host"
                     value="{commands_response/get_slaves_response/slave/host}"
                     size="30"
                     maxlength="1000"/>
            </td>
          </tr>
          <tr>
            <td valign="top" width="175">Port</td>
            <td>
              <input type="text" name="port" size="30" maxlength="1000"
                     value="{commands_response/get_slaves_response/slave/port}"/>
            </td>
          </tr>
          <tr>
            <td valign="top" width="175">Login</td>
            <td>
              <input type="text" name="login" size="30" maxlength="1000"
                     value="{commands_response/get_slaves_response/slave/login}"/>
            </td>
          </tr>
          <tr>
            <td valign="top" width="175">Password</td>
            <td>
              <input type="password" autocomplete="off" name="password"
                     size="30" maxlength="1000"/>
            </td>
          </tr>
          <tr>
            <td colspan="2" style="text-align:right;">
              <input type="submit" name="submit" value="Save Slave"/>
            </td>
          </tr>
        </table>
        <br/>
      </form>
    </div>
  </div>
</xsl:template>

<xsl:template match="edit_slave">
  <xsl:apply-templates select="gsad_msg"/>
  <xsl:call-template name="html-edit-slave-form"/>
</xsl:template>

<!--     SLAVE -->

<xsl:template match="slave">
  <xsl:variable name="class">
    <xsl:choose>
      <xsl:when test="position() mod 2 = 0">even</xsl:when>
      <xsl:otherwise>odd</xsl:otherwise>
    </xsl:choose>
  </xsl:variable>
  <tr class="{$class}">
    <td>
      <b>
        <a href="/omp?cmd=get_slave&amp;slave_id={@id}&amp;filter={str:encode-uri (../filters/term, true ())}&amp;token={/envelope/token}">
          <xsl:value-of select="name"/>
        </a>
      </b>
      <xsl:choose>
        <xsl:when test="comment != ''">
          <br/>(<xsl:value-of select="comment"/>)
        </xsl:when>
        <xsl:otherwise></xsl:otherwise>
      </xsl:choose>
    </td>
    <td><xsl:value-of select="host"/></td>
    <td><xsl:value-of select="port"/></td>
    <td><xsl:value-of select="login"/></td>
    <td>
      <xsl:call-template name="list-window-line-icons">
        <xsl:with-param name="cap-type" select="'Slave'"/>
        <xsl:with-param name="type" select="'slave'"/>
        <xsl:with-param name="id" select="@id"/>
      </xsl:call-template>
    </td>
  </tr>
</xsl:template>

<xsl:template match="slave" mode="trash">
  <xsl:variable name="class">
    <xsl:choose>
      <xsl:when test="position() mod 2 = 0">even</xsl:when>
      <xsl:otherwise>odd</xsl:otherwise>
    </xsl:choose>
  </xsl:variable>
  <tr class="{$class}">
    <td>
      <b><xsl:value-of select="name"/></b>
      <xsl:choose>
        <xsl:when test="comment != ''">
          <br/>(<xsl:value-of select="comment"/>)
        </xsl:when>
        <xsl:otherwise></xsl:otherwise>
      </xsl:choose>
    </td>
    <td><xsl:value-of select="host"/></td>
    <td><xsl:value-of select="port"/></td>
    <td><xsl:value-of select="login"/></td>
    <td>
      <xsl:call-template name="restore-icon">
        <xsl:with-param name="id" select="@id"/>
      </xsl:call-template>
      <xsl:choose>
        <xsl:when test="in_use='0'">
          <xsl:call-template name="trash-delete-icon">
            <xsl:with-param name="type" select="'slave'"/>
            <xsl:with-param name="id" select="@id"/>
          </xsl:call-template>
        </xsl:when>
        <xsl:otherwise>
          <img src="/img/delete_inactive.png"
               border="0"
               alt="Delete"
               style="margin-left:3px;"/>
        </xsl:otherwise>
      </xsl:choose>
    </td>
  </tr>
</xsl:template>

<xsl:template match="slave" mode="details">
  <div class="gb_window">
    <div class="gb_window_part_left"></div>
    <div class="gb_window_part_right"></div>
    <div class="gb_window_part_center">
       Slave Details
      <xsl:call-template name="details-header-icons">
        <xsl:with-param name="cap-type" select="'Slave'"/>
        <xsl:with-param name="type" select="'slave'"/>
      </xsl:call-template>
    </div>
    <div class="gb_window_part_content">
      <xsl:call-template name="minor-details"/>
      <table>
        <tr>
          <td><b>Name:</b></td>
          <td><b><xsl:value-of select="name"/></b></td>
        </tr>
        <tr>
          <td>Comment:</td>
          <td><xsl:value-of select="comment"/></td>
        </tr>
        <tr>
          <td>Host:</td>
          <td><xsl:value-of select="host"/></td>
        </tr>
        <tr>
          <td>Port:</td>
          <td><xsl:value-of select="port"/></td>
        </tr>
        <tr>
          <td>Login:</td>
          <td><xsl:value-of select="login"/></td>
        </tr>
      </table>

      <xsl:choose>
        <xsl:when test="count(tasks/task) = 0">
          <h1>Tasks using this Slave: None</h1>
        </xsl:when>
        <xsl:otherwise>
          <h1>Tasks using this Slave</h1>
          <table class="gbntable" cellspacing="2" cellpadding="4">
            <tr class="gbntablehead2">
              <td>Name</td>
              <td>Actions</td>
            </tr>
            <xsl:for-each select="tasks/task">
              <xsl:variable name="class">
                <xsl:choose>
                  <xsl:when test="position() mod 2 = 0">even</xsl:when>
                  <xsl:otherwise>odd</xsl:otherwise>
                </xsl:choose>
              </xsl:variable>
              <tr class="{$class}">
                <td><xsl:value-of select="name"/></td>
                <td width="100">
                  <a href="/omp?cmd=get_task&amp;task_id={@id}&amp;token={/envelope/token}" title="Details">
                    <img src="/img/details.png"
                         border="0"
                         alt="Details"
                         style="margin-left:3px;"/>
                  </a>
                </td>
              </tr>
            </xsl:for-each>
          </table>
        </xsl:otherwise>
      </xsl:choose>
    </div>
  </div>
</xsl:template>

<!--     GET_SLAVE -->

<xsl:template match="get_slave">
  <xsl:apply-templates select="gsad_msg"/>
  <xsl:apply-templates select="commands_response/delete_slave_response"/>
  <xsl:apply-templates select="modify_slave_response"/>
  <xsl:apply-templates select="get_slaves_response/slave" mode="details"/>
</xsl:template>

<!--     GET_SLAVES -->

<xsl:template match="get_slaves">
  <xsl:apply-templates select="gsad_msg"/>
  <xsl:apply-templates select="delete_slave_response"/>
  <xsl:apply-templates select="create_filter_response"/>
  <xsl:apply-templates select="create_slave_response"/>
  <xsl:apply-templates select="modify_slave_response"/>
  <!-- The for-each makes the get_slaves_response the current node. -->
  <xsl:for-each select="get_slaves_response | commands_response/get_slaves_response">
    <xsl:choose>
      <xsl:when test="substring(@status, 1, 1) = '4' or substring(@status, 1, 1) = '5'">
        <xsl:call-template name="command_result_dialog">
          <xsl:with-param name="operation">
            Get Slaves
          </xsl:with-param>
          <xsl:with-param name="status">
            <xsl:value-of select="@status"/>
          </xsl:with-param>
          <xsl:with-param name="msg">
            <xsl:value-of select="@status_text"/>
          </xsl:with-param>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="html-slaves-table"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:for-each>
</xsl:template>

<!-- END SLAVES MANAGEMENT -->

<!-- BEGIN GET RAW INFO -->

<xsl:template name="ref_cve_list">
  <xsl:param name="cvelist"/>

  <xsl:variable name="token" select="/envelope/token"/>

  <xsl:variable name="cvecount" select="count(str:split($cvelist, ','))"/>
  <xsl:if test="$cvecount &gt; 0">
    <tr valign="top">
      <td>CVE:</td>
      <td>
        <xsl:for-each select="str:split($cvelist, ',')">
          <xsl:call-template name="get_info_cve_lnk">
            <xsl:with-param name="cve" select="."/>
            <xsl:with-param name="gsa_token" select="$token"/>
          </xsl:call-template>
          <xsl:if test="position() &lt; $cvecount">
            <xsl:text>, </xsl:text>
          </xsl:if>
        </xsl:for-each>
      </td>
    </tr>
  </xsl:if>
</xsl:template>

<xsl:template name="ref_bid_list">
  <xsl:param name="bidlist"/>

  <xsl:variable name="token" select="/envelope/token"/>

  <xsl:variable name="bidcount" select="count(str:split($bidlist, ','))"/>
  <xsl:if test="$bidcount &gt; 0">
    <tr valign="top">
      <td>BID:</td>
      <td>
        <xsl:for-each select="str:split($bidlist, ',')">
          <xsl:value-of select="."/>
          <xsl:if test="position() &lt; $bidcount">
            <xsl:text>, </xsl:text>
          </xsl:if>
        </xsl:for-each>
      </td>
    </tr>
  </xsl:if>
</xsl:template>

<xsl:template name="ref_cert_list">
  <xsl:param name="certlist"/>
  <xsl:variable name="token" select="/envelope/token"/>
  <xsl:variable name="certcount" select="count($certlist/cert_ref)"/>

  <xsl:if test="count($certlist/warning)">
    <xsl:for-each select="$certlist/warning">
      <tr valign="top">
        <td>CERT:</td>
        <td><i>Warning: <xsl:value-of select="text()"/></i></td>
      </tr>
    </xsl:for-each>
  </xsl:if>

  <xsl:if test="$certcount &gt; 0">
    <tr valign="top">
      <td>CERT:</td>
      <td>
        <xsl:for-each select="$certlist/cert_ref">
          <xsl:choose>
            <xsl:when test="@type='DFN-CERT'">
              <xsl:call-template name="get_info_dfn_cert_adv_lnk">
                <xsl:with-param name="dfn_cert_adv" select="@id"/>
                <xsl:with-param name="gsa_token" select="$token"/>
              </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
              <b>?</b><xsl:value-of select="./@id"/>
            </xsl:otherwise>
          </xsl:choose>
          <xsl:if test="position() &lt; $certcount">
            <xsl:text>, </xsl:text>
          </xsl:if>
        </xsl:for-each>
      </td>
    </tr>
  </xsl:if>
</xsl:template>

<xsl:template name="ref_xref_list">
  <xsl:param name="xreflist"/>

  <xsl:variable name="token" select="/envelope/token"/>

  <xsl:variable name="xrefcount" select="count(str:split($xreflist, ','))"/>
  <xsl:if test="$xrefcount &gt; 0">
    <xsl:for-each select="str:split($xreflist, ',')">
      <tr valign="top">
        <td><xsl:if test="position()=1">Other:</xsl:if></td>
        <xsl:choose>
          <xsl:when test="contains(., 'URL:')">
            <td><xsl:value-of select="substring-after(., 'URL:')"/></td>
          </xsl:when>
          <xsl:otherwise>
            <td><xsl:value-of select="."/></td>
          </xsl:otherwise>
        </xsl:choose>
      </tr>
    </xsl:for-each>
  </xsl:if>
</xsl:template>

<xsl:template match="info/cpe">
  <xsl:variable name="class">
    <xsl:choose>
      <xsl:when test="position() mod 2 = 0">even</xsl:when>
      <xsl:otherwise>odd</xsl:otherwise>
    </xsl:choose>
  </xsl:variable>
  <tr class="{$class}">
    <td>
      <b>
        <xsl:call-template name="get_info_cpe_lnk">
          <xsl:with-param name="cpe" select="../name"/>
          <xsl:with-param name="cpe_id" select="../@id"/>
        </xsl:call-template>
      </b>
      <xsl:choose>
        <xsl:when test="../comment != ''">
          <br/>(<xsl:value-of select="../comment"/>)
        </xsl:when>
        <xsl:otherwise></xsl:otherwise>
      </xsl:choose>
    </td>
    <td>
      <xsl:choose>
        <xsl:when test="title != ''">
          <xsl:value-of select="title"/>
        </xsl:when>
        <xsl:otherwise>
          N/A
        </xsl:otherwise>
      </xsl:choose>
    </td>
    <td>
      <xsl:choose>
        <xsl:when test="../modification_time != ''">
          <xsl:value-of select="gsa:date (../modification_time)"/>
        </xsl:when>
        <xsl:otherwise>
          N/A
        </xsl:otherwise>
      </xsl:choose>
    </td>
    <td>
      <xsl:value-of select="cve_refs"/>
    </td>
    <td>
      <xsl:call-template name="severity-bar">
        <xsl:with-param name="cvss" select="max_cvss"/>
      </xsl:call-template>
    </td>
    <td>
      <a href="/omp?cmd=get_info&amp;info_type=cpe&amp;info_id={../@id}&amp;filter={str:encode-uri (../../filters/term, true ())}&amp;filt_id={../../filters/@id}&amp;first={../../info/@start}&amp;max={../../info/@max}&amp;details=1&amp;token={/envelope/token}"
        title="CPE Details" style="margin-left:3px;">
        <img src="/img/details.png" border="0" alt="Details"/>
      </a>
    </td>
  </tr>
</xsl:template>

<xsl:template match="info/cve">
  <xsl:variable name="class">
    <xsl:choose>
      <xsl:when test="position() mod 2 = 0">even</xsl:when>
      <xsl:otherwise>odd</xsl:otherwise>
    </xsl:choose>
  </xsl:variable>
  <tbody class="{$class}">
    <tr>
      <td rowspan="2">
        <b>
          <xsl:call-template name="get_info_cve_lnk">
            <xsl:with-param name="cve" select="../name"/>
            <xsl:with-param name="cve_id" select="../@id"/>
          </xsl:call-template>
        </b>
        <xsl:choose>
          <xsl:when test="../comment != ''">
            <br/>(<xsl:value-of select="../comment"/>)
          </xsl:when>
          <xsl:otherwise></xsl:otherwise>
        </xsl:choose>
      </td>
      <td>
        <xsl:choose>
          <xsl:when test="vector != ''">
            <xsl:value-of select="vector"/>
          </xsl:when>
          <xsl:otherwise>
            N/A
          </xsl:otherwise>
        </xsl:choose>
      </td>
      <td>
        <xsl:choose>
          <xsl:when test="complexity != ''">
            <xsl:value-of select="complexity"/>
          </xsl:when>
          <xsl:otherwise>
            N/A
          </xsl:otherwise>
        </xsl:choose>
      </td>
      <td>
        <xsl:choose>
          <xsl:when test="authentication != ''">
            <xsl:value-of select="authentication"/>
          </xsl:when>
          <xsl:otherwise>
            N/A
          </xsl:otherwise>
        </xsl:choose>
      </td>
      <td>
        <xsl:choose>
          <xsl:when test="confidentiality_impact != ''">
            <xsl:value-of select="confidentiality_impact"/>
          </xsl:when>
          <xsl:otherwise>
            N/A
          </xsl:otherwise>
        </xsl:choose>
      </td>
      <td>
        <xsl:choose>
          <xsl:when test="integrity_impact != ''">
            <xsl:value-of select="integrity_impact"/>
          </xsl:when>
          <xsl:otherwise>
            N/A
          </xsl:otherwise>
        </xsl:choose>
      </td>
      <td>
        <xsl:choose>
          <xsl:when test="availability_impact != ''">
            <xsl:value-of select="availability_impact"/>
          </xsl:when>
          <xsl:otherwise>
            N/A
          </xsl:otherwise>
        </xsl:choose>
      </td>
      <td>
        <xsl:choose>
          <xsl:when test="../creation_time != ''">
            <xsl:value-of select="gsa:date (../creation_time)"/>
          </xsl:when>
          <xsl:otherwise>
            N/A
          </xsl:otherwise>
        </xsl:choose>
      </td>
      <td>
        <xsl:if test="cvss &gt;= 0.0">
          <xsl:call-template name="severity-bar">
            <xsl:with-param name="cvss" select="cvss"/>
            <xsl:with-param name="scale" select="7"/>
          </xsl:call-template>
        </xsl:if>
      </td>
      <td rowspan="2">
        <a href="/omp?cmd=get_info&amp;info_type=cve&amp;info_id={../@id}&amp;filter={str:encode-uri (../../filters/term, true ())}&amp;filt_id={../../filters/@id}&amp;first={../../info/@start}&amp;max={../../info/@max}&amp;details=1&amp;token={/envelope/token}"
          title="CVE Details" style="margin-left:3px;">
          <img src="/img/details.png" border="0" alt="Details"/>
        </a>
      </td>
    </tr>
    <tr>
      <td colspan="8" style="font-size: 80%;">
        <xsl:variable name="truncate_length"
        select="string-length(description) - string-length(substring-after(substring(description, 250), ' ')) + 1"/>
        <xsl:value-of select="substring(description, 0, $truncate_length)"/>
        <xsl:if test="string-length(description) >= $truncate_length"><i><abbr title="[...] {substring(description, $truncate_length, string-length(description))}">[...]</abbr></i></xsl:if>
      </td>
    </tr>
  </tbody>
</xsl:template>

<xsl:template match="info/nvt">
  <xsl:variable name="class">
    <xsl:choose>
      <xsl:when test="position() mod 2 = 0">even</xsl:when>
      <xsl:otherwise>odd</xsl:otherwise>
    </xsl:choose>
  </xsl:variable>
  <tr class="{$class}">
    <td>
      <b>
        <xsl:call-template name="get_info_nvt_lnk">
          <xsl:with-param name="nvt" select="../name"/>
          <xsl:with-param name="oid" select="@oid"/>
          <xsl:with-param name="tooltip" select="concat (summary, ' (OID: ', @oid, ')')"/>
        </xsl:call-template>
      </b>
    </td>
    <td>
      <a href="/omp?cmd=get_info&amp;info_type=nvt&amp;filter=family=&quot;{family}&quot;&amp;token={/envelope/token}">
        <xsl:value-of select="family"/>
      </a>
    </td>
    <td>
      <xsl:choose>
        <xsl:when test="../creation_time != ''">
          <xsl:value-of select="gsa:date (../creation_time)"/>
        </xsl:when>
        <xsl:otherwise>
        </xsl:otherwise>
      </xsl:choose>
    </td>
    <td>
      <xsl:choose>
        <xsl:when test="../modification_time != ''">
          <xsl:value-of select="gsa:date (../modification_time)"/>
        </xsl:when>
        <xsl:otherwise>
        </xsl:otherwise>
      </xsl:choose>
    </td>
    <td>
      <xsl:value-of select="version"/>
    </td>
    <td>
      <!-- "NOCVE" means no CVE ID, skip. -->
      <xsl:choose>
        <xsl:when test="cve_id = 'NOCVE'">
        </xsl:when>
        <xsl:otherwise>
          <!-- get the GSA token before entering the for-each loop over the str:tokenize elements -->
          <xsl:variable name="gsa_token" select="/envelope/token"/>

          <xsl:for-each select="str:tokenize (cve_id, ', ')">
            <xsl:call-template name="get_info_cve_lnk">
              <xsl:with-param name="cve" select="text()"/>
              <xsl:with-param name="gsa_token" select="$gsa_token"/>
            </xsl:call-template>
            <xsl:text> </xsl:text>
          </xsl:for-each>
        </xsl:otherwise>
      </xsl:choose>
    </td>
    <td>
      <xsl:call-template name="severity-bar">
        <xsl:with-param name="cvss" select="cvss_base"/>
      </xsl:call-template>
    </td>
    <td>
      <a href="/omp?cmd=get_nvts&amp;oid={@oid}&amp;filter={str:encode-uri (../../filters/term, true ())}&amp;filt_id={../../filters/@id}&amp;details=1&amp;token={/envelope/token}"
        title="NVT Details" style="margin-left:3px;">
        <img src="/img/details.png" border="0" alt="Details"/>
      </a>
    </td>
  </tr>
</xsl:template>

<xsl:template match="info/ovaldef">
  <xsl:variable name="class">
    <xsl:choose>
      <xsl:when test="position() mod 2 = 0">even</xsl:when>
      <xsl:otherwise>odd</xsl:otherwise>
    </xsl:choose>
  </xsl:variable>
  <tbody class="{$class}">
    <tr>
      <td rowspan="2">
        <b>
          <xsl:call-template name="get_info_ovaldef_lnk">
            <xsl:with-param name="ovaldef" select="../name"/>
            <xsl:with-param name="ovaldef_id" select="../@id"/>
          </xsl:call-template>
        </b>
        <br/>
        <span style="font-size:80%; color:grey">
          <xsl:choose>
            <xsl:when test="string-length(file) > 45">
              <abbr title="{file}"><i>[...]</i><xsl:value-of select="substring(file, string-length(file)-40, string-length(file))"/></abbr>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="file"/>
            </xsl:otherwise>
          </xsl:choose>
        </span>
        <xsl:choose>
          <xsl:when test="../comment != ''">
            <br/>(<xsl:value-of select="../comment"/>)
          </xsl:when>
          <xsl:otherwise></xsl:otherwise>
        </xsl:choose>
      </td>
      <td>
        <xsl:choose>
          <xsl:when test="version != ''">
            <xsl:value-of select="version"/>
          </xsl:when>
          <xsl:otherwise>
            N/A
          </xsl:otherwise>
        </xsl:choose>
      </td>
      <td>
        <xsl:choose>
          <xsl:when test="status != ''">
            <xsl:value-of select="status"/>
          </xsl:when>
          <xsl:otherwise>
            N/A
          </xsl:otherwise>
        </xsl:choose>
      </td>
      <td>
        <xsl:choose>
          <xsl:when test="class != ''">
            <xsl:value-of select="class"/>
          </xsl:when>
          <xsl:otherwise>
            N/A
          </xsl:otherwise>
        </xsl:choose>
      </td>
      <td>
        <xsl:choose>
          <xsl:when test="../creation_time != ''">
            <xsl:value-of select="gsa:date (../creation_time)"/>
          </xsl:when>
          <xsl:otherwise>
            N/A
          </xsl:otherwise>
        </xsl:choose>
      </td>
      <td>
        <xsl:choose>
          <xsl:when test="../modification_time != ''">
            <xsl:value-of select="gsa:date (../modification_time)"/>
          </xsl:when>
          <xsl:otherwise>
            N/A
          </xsl:otherwise>
        </xsl:choose>
      </td>
      <td rowspan="2">
        <a href="/omp?cmd=get_info&amp;info_type=ovaldef&amp;info_id={../@id}&amp;filter={str:encode-uri (../../filters/term, true ())}&amp;first={../../info/@start}&amp;max={../../info/@max}&amp;details=1&amp;token={/envelope/token}"
          title="OVAL Definition Details" style="margin-left:3px;">
          <img src="/img/details.png" border="0" alt="Details"/>
        </a>
      </td>
    </tr>
    <tr>
      <td colspan="5" style="font-size: 80%;">
        <xsl:choose>
          <xsl:when test="title != ''">
            <xsl:variable name="truncate_length"
              select="string-length(title) - string-length(substring-after(substring(title, 200), ' ')) + 1"/>
            <xsl:value-of select="substring(title, 0, $truncate_length)"/>
            <xsl:if test="string-length(title) >= $truncate_length"><i><abbr title="[...] {substring(title, $truncate_length, string-length(title))}">[...]</abbr></i></xsl:if>
          </xsl:when>
          <xsl:otherwise>
          </xsl:otherwise>
        </xsl:choose>
      </td>
    </tr>
  </tbody>
</xsl:template>

<xsl:template match="info/dfn_cert_adv">
  <xsl:variable name="class">
    <xsl:choose>
      <xsl:when test="position() mod 2 = 0">even</xsl:when>
      <xsl:otherwise>odd</xsl:otherwise>
    </xsl:choose>
  </xsl:variable>
  <tr class="{$class}">
    <td>
      <b>
        <xsl:call-template name="get_info_dfn_cert_adv_lnk">
          <xsl:with-param name="dfn_cert_adv" select="../name"/>
          <xsl:with-param name="dfn_cert_adv_id" select="../@id"/>
        </xsl:call-template>
      </b>
      <xsl:choose>
        <xsl:when test="../comment != ''">
          <br/>(<xsl:value-of select="../comment"/>)
        </xsl:when>
        <xsl:otherwise></xsl:otherwise>
      </xsl:choose>
    </td>
    <td>
      <xsl:value-of select="title"/>
    </td>
    <td>
      <xsl:value-of select="gsa:date (../creation_time)"/>
    </td>
    <td>
      <xsl:value-of select="cve_refs"/>
    </td>
    <td>
      <a href="/omp?cmd=get_info&amp;info_type=dfn_cert_adv&amp;info_id={../@id}&amp;filter={str:encode-uri (../../filters/term, true ())}&amp;first={../../info/@start}&amp;max={../../info/@max}&amp;details=1&amp;token={/envelope/token}"
        title="DFN-CERT Advisory Details" style="margin-left:3px;">
        <img src="/img/details.png" border="0" alt="Details"/>
      </a>
    </td>
  </tr>
</xsl:template>

<xsl:template match="info/allinfo">
  <xsl:variable name="class">
    <xsl:choose>
      <xsl:when test="position() mod 2 = 0">even</xsl:when>
      <xsl:otherwise>odd</xsl:otherwise>
    </xsl:choose>
  </xsl:variable>
  <tbody class="{$class}">
    <tr>
      <td rowspan="2">
        <b>
          <xsl:call-template name="get_info_allinfo_lnk">
            <xsl:with-param name="name" select="../name"/>
            <xsl:with-param name="type" select="type"/>
            <xsl:with-param name="id" select="../@id"/>
          </xsl:call-template>
        </b>
        <xsl:choose>
          <xsl:when test="../comment != ''">
            <br/>(<xsl:value-of select="../comment"/>)
          </xsl:when>
          <xsl:otherwise></xsl:otherwise>
        </xsl:choose>
      </td>
      <td>
        <xsl:choose>
          <xsl:when test="type != ''">
            <xsl:value-of select="type"/>
          </xsl:when>
          <xsl:otherwise>
            N/A
          </xsl:otherwise>
        </xsl:choose>
      </td>
      <td>
        <xsl:choose>
          <xsl:when test="../creation_time != ''">
            <xsl:value-of select="gsa:date (../creation_time)"/>
          </xsl:when>
          <xsl:otherwise>
            N/A
          </xsl:otherwise>
        </xsl:choose>
      </td>
      <td>
        <xsl:choose>
          <xsl:when test="../modification_time != ''">
            <xsl:value-of select="gsa:date (../modification_time)"/>
          </xsl:when>
          <xsl:otherwise>
            N/A
          </xsl:otherwise>
        </xsl:choose>
      </td>
      <td rowspan="2">
        <xsl:choose>
          <xsl:when test="type = 'cve'">
            <xsl:call-template name="get_info_allinfo_action">
              <xsl:with-param name="info_name" select="../name"/>
              <xsl:with-param name="info_id" select="../@id"/>
              <xsl:with-param name="name" select="'CVE'"/>
              <xsl:with-param name="type" select="'cve'"/>
            </xsl:call-template>
          </xsl:when>
          <xsl:when test="type = 'cpe'">
            <xsl:call-template name="get_info_allinfo_action">
              <xsl:with-param name="info_name" select="../name"/>
              <xsl:with-param name="info_id" select="../@id"/>
              <xsl:with-param name="name" select="'CPE'"/>
              <xsl:with-param name="type" select="'cpe'"/>
            </xsl:call-template>
          </xsl:when>
          <xsl:when test="type = 'ovaldef'">
            <xsl:call-template name="get_info_allinfo_action">
              <xsl:with-param name="info_name" select="../name"/>
              <xsl:with-param name="info_id" select="../@id"/>
              <xsl:with-param name="name" select="'OVAL Definition'"/>
              <xsl:with-param name="type" select="'ovaldef'"/>
            </xsl:call-template>
          </xsl:when>
          <xsl:when test="type = 'dfn_cert_adv'">
            <xsl:call-template name="get_info_allinfo_action">
              <xsl:with-param name="info_name" select="../name"/>
              <xsl:with-param name="info_id" select="../@id"/>
              <xsl:with-param name="name" select="'DFN-CERT Advisory'"/>
              <xsl:with-param name="type" select="'dfn_cert_adv'"/>
            </xsl:call-template>
          </xsl:when>
          <xsl:when test="type = 'nvt'">
            <a href="?cmd=get_nvts&amp;oid={../@id}&amp;details=1&amp;filter={str:encode-uri (../../filters/term, true ())}&amp;filt_id={../../filters/@id}&amp;token={/envelope/token}"
               title="NVT Details">
              <img src="/img/details.png"
                border="0"
                alt="NVT Details"
                style="margin-left:3px;"/>
            </a>
          </xsl:when>
        </xsl:choose>
      </td>
    </tr>
    <tr>
      <td colspan="3" style="font-size: 95%;">
        <xsl:variable name="truncate_length"
        select="string-length(extra) - string-length(substring-after(substring(extra, 135), ' ')) + 1"/>
        <xsl:value-of select="substring(extra, 0, $truncate_length)"/>
        <xsl:if test="string-length(extra) >= $truncate_length"><i><abbr title="[...] {substring(extra, $truncate_length, string-length(extra))}">[...]</abbr></i></xsl:if>
      </td>
    </tr>
  </tbody>
</xsl:template>

<xsl:template name="get_info_allinfo_action">
  <xsl:param name="name"/>
  <xsl:param name="info_name"/>
  <xsl:param name="info_id"/>
  <xsl:param name="type"/>
  <xsl:param name="action"/>
  <a href="/omp?cmd=get_info&amp;info_type={$type}&amp;info_id={$info_id}&amp;details=1&amp;filter={str:encode-uri (../../filters/term, true ())}&amp;filt_id={../../filters/@id}&amp;token={/envelope/token}"
     title="{$name} Details" style="margin-left:3px;">
    <img src="/img/details.png" border="0" alt="{$name} Details"/>
  </a>
</xsl:template>

<xsl:template name="get_info_allinfo_lnk">
 <xsl:param name="name"/>
 <xsl:param name="type"/>
 <xsl:param name="id"/>
  <xsl:choose>
    <xsl:when test="$type = 'cve'">
      <xsl:call-template name="get_info_cve_lnk">
        <xsl:with-param name="cve" select="$name"/>
        <xsl:with-param name="cve_id" select="$id"/>
      </xsl:call-template>
    </xsl:when>
    <xsl:when test="$type = 'cpe'">
      <xsl:call-template name="get_info_cpe_lnk">
        <xsl:with-param name="cpe" select="$name"/>
        <xsl:with-param name="cpe_id" select="$id"/>
      </xsl:call-template>
    </xsl:when>
    <xsl:when test="$type = 'ovaldef'">
      <xsl:call-template name="get_info_ovaldef_lnk">
        <xsl:with-param name="ovaldef" select="$name"/>
        <xsl:with-param name="ovaldef_id" select="$id"/>
      </xsl:call-template>
    </xsl:when>
    <xsl:when test="$type = 'nvt'">
      <xsl:call-template name="get_info_nvt_lnk">
        <xsl:with-param name="nvt" select="$name"/>
        <xsl:with-param name="oid" select="$id"/>
      </xsl:call-template>
    </xsl:when>
    <xsl:when test="$type = 'dfn_cert_adv'">
      <xsl:call-template name="get_info_dfn_cert_adv_lnk">
        <xsl:with-param name="dfn_cert_adv" select="$name"/>
        <xsl:with-param name="dfn_cert_adv_id" select="$id"/>
      </xsl:call-template>
    </xsl:when>
  </xsl:choose>
</xsl:template>

<xsl:template name="get_info_cpe_lnk">
  <xsl:param name="cpe"/>
  <xsl:param name="cpe_id"/>
  <xsl:variable name="cpe_select">
    <xsl:choose>
      <xsl:when test="$cpe_id">info_id=<xsl:value-of select="$cpe_id"/></xsl:when>
      <xsl:otherwise>info_name=<xsl:value-of select="$cpe"/></xsl:otherwise>
    </xsl:choose>
  </xsl:variable>
  <a href="/omp?cmd=get_info&amp;info_type=cpe&amp;{$cpe_select}&amp;details=1&amp;filter={str:encode-uri (../../filters/term, true ())}&amp;filt_id={../../filters/@id}&amp;token={/envelope/token}"
    title="Details">
     <xsl:call-template name="wrap" disable-output-escaping="yes">
      <xsl:with-param name="string" select="$cpe"/>
      <xsl:with-param name="width" select="'55'"/>
      <xsl:with-param name="marker" select="'&#8629;&lt;br/&gt;'"/>
    </xsl:call-template>
  </a>
</xsl:template>

<xsl:template name="get_info_cve_lnk">
  <xsl:param name="cve"/>
  <xsl:param name="cve_id"/>
  <xsl:param name="gsa_token"/>
  <xsl:variable name="cve_select">
    <xsl:choose>
      <xsl:when test="$cve_id">info_id=<xsl:value-of select="$cve_id"/></xsl:when>
      <xsl:otherwise>info_name=<xsl:value-of select="normalize-space($cve)"/></xsl:otherwise>
    </xsl:choose>
  </xsl:variable>
  <xsl:choose>
    <xsl:when test="$gsa_token = ''">
      <a href="/omp?cmd=get_info&amp;info_type=cve&amp;{$cve_select}&amp;details=1&amp;filter={str:encode-uri (../../filters/term, true ())}&amp;filt_id={../../filters/@id}&amp;token={/envelope/token}"
         title="Details"><xsl:value-of select="normalize-space($cve)"/></a>
    </xsl:when>
    <xsl:otherwise>
      <a href="/omp?cmd=get_info&amp;info_type=cve&amp;{$cve_select}&amp;details=1&amp;filter={str:encode-uri (../../filters/term, true ())}&amp;filt_id={../../filters/@id}&amp;token={$gsa_token}"
         title="Details"><xsl:value-of select="normalize-space($cve)"/></a>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template name="get_info_nvt_lnk">
  <xsl:param name="nvt"/>
  <xsl:param name="oid"/>
  <xsl:param name="gsa_token"/>
  <xsl:param name="tooltip"/>
  <xsl:choose>
    <xsl:when test="$gsa_token = ''">
      <a href="/omp?cmd=get_nvts&amp;oid={$oid}&amp;filter={str:encode-uri (../../filters/term, true ())}&amp;filt_id={../../filters/@id}&amp;token={/envelope/token}"
         title="{$tooltip}"><xsl:value-of select="normalize-space($nvt)"/></a>
    </xsl:when>
    <xsl:otherwise>
      <a href="/omp?cmd=get_nvts&amp;oid={$oid}&amp;filter={str:encode-uri (../../filters/term, true ())}&amp;filt_id={../../filters/@id}&amp;token={$gsa_token}"
         title="{$tooltip}"><xsl:value-of select="normalize-space($nvt)"/></a>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template name="get_info_ovaldef_lnk">
  <xsl:param name="ovaldef"/>
  <xsl:param name="ovaldef_id"/>
  <xsl:variable name="ovaldef_select">
    <xsl:choose>
      <xsl:when test="$ovaldef_id">info_id=<xsl:value-of select="$ovaldef_id"/></xsl:when>
      <xsl:otherwise>info_name=<xsl:value-of select="$ovaldef"/></xsl:otherwise>
    </xsl:choose>
  </xsl:variable>
  <a href="/omp?cmd=get_info&amp;info_type=ovaldef&amp;{$ovaldef_select}&amp;details=1&amp;filter={str:encode-uri (../../filters/term, true ())}&amp;token={/envelope/token}"
    title="Details">
     <xsl:call-template name="wrap" disable-output-escaping="yes">
      <xsl:with-param name="string" select="$ovaldef"/>
      <xsl:with-param name="width" select="'55'"/>
      <xsl:with-param name="marker" select="'&#8629;&lt;br/&gt;'"/>
    </xsl:call-template>
  </a>
</xsl:template>

<xsl:template name="get_info_dfn_cert_adv_lnk">
  <xsl:param name="dfn_cert_adv"/>
  <xsl:param name="dfn_cert_adv_id"/>
  <xsl:variable name="dfn_cert_adv_select">
    <xsl:choose>
      <xsl:when test="$dfn_cert_adv_id">info_id=<xsl:value-of select="$dfn_cert_adv_id"/></xsl:when>
      <xsl:otherwise>info_name=<xsl:value-of select="$dfn_cert_adv"/></xsl:otherwise>
    </xsl:choose>
  </xsl:variable>
  <a href="/omp?cmd=get_info&amp;info_type=dfn_cert_adv&amp;{$dfn_cert_adv_select}&amp;details=1&amp;filter={str:encode-uri (../../filters/term, true ())}&amp;token={/envelope/token}"
    title="Details">
     <xsl:call-template name="wrap" disable-output-escaping="yes">
      <xsl:with-param name="string" select="$dfn_cert_adv"/>
      <xsl:with-param name="width" select="'55'"/>
      <xsl:with-param name="marker" select="'&#8629;&lt;br/&gt;'"/>
    </xsl:call-template>
  </a>
</xsl:template>

<xsl:template name="html-cpe-table">
  <xsl:if test="@status = 400">
    <xsl:call-template name="error_window">
      <xsl:with-param name="heading">Warning: SecInfo Database Missing</xsl:with-param>
      <xsl:with-param name="message">
        SCAP and/or CERT database missing on OMP server.
        <a href="/help/cpes.html?token={/envelope/token}#secinfo_missing"
           title="Help: SecInfo database missing">
          <img style="margin-left:5px" src="/img/help.png"/>
        </a>
      </xsl:with-param>
    </xsl:call-template>
    <br/>
  </xsl:if>
  <div class="gb_window">
    <div class="gb_window_part_left"></div>
    <div class="gb_window_part_right"></div>
    <div class="gb_window_part_center">CPEs
      <xsl:call-template name="filter-window-pager">
        <xsl:with-param name="type" select="'info'"/>
        <xsl:with-param name="list" select="info"/>
        <xsl:with-param name="count" select="count(info/cpe)"/>
        <xsl:with-param name="filtered_count" select="info_count/filtered"/>
        <xsl:with-param name="full_count" select="info_count/text ()"/>
        <xsl:with-param name="extra_params" select="'&amp;info_type=CPE'"/>
      </xsl:call-template>
      <a href="/help/cpes.html?token={/envelope/token}"
        title="Help: CPE">
        <img src="/img/help.png"/>
      </a>
      <a href="/omp?cmd=get_info&amp;info_type=cpe&amp;token={/envelope/token}"
         title="Return to default filter view" style="margin-left:3px;">
        <img src="/img/list.png" border="0" alt="Return"/>
      </a>
    </div>
    <xsl:if test="not(/envelope/params/info_name or /envelope/params/info_id)">
      <xsl:call-template name="filter-window-part">
        <xsl:with-param name="type" select="'info'"/>
        <xsl:with-param name="list" select="info"/>
        <xsl:with-param name="extra_params">
          <param>
            <name>info_type</name>
            <value>CPE</value>
          </param>
        </xsl:with-param>
      </xsl:call-template>
    </xsl:if>
    <div class="gb_window_part_content_no_pad">
      <div id="cpes">
        <table class="gbntable" cellspacing="2" cellpadding="4" border="0">
          <tr class="gbntablehead2">
            <td>
              <xsl:call-template name="column-name">
                <xsl:with-param name="head">Name</xsl:with-param>
                <xsl:with-param name="name">name</xsl:with-param>
                <xsl:with-param name="type">info</xsl:with-param>
                <xsl:with-param name="extra_params" select="'&amp;info_type=CPE'"/>
              </xsl:call-template>
            </td>
            <td>
              <xsl:call-template name="column-name">
                <xsl:with-param name="head">Title</xsl:with-param>
                <xsl:with-param name="name">title</xsl:with-param>
                <xsl:with-param name="type">info</xsl:with-param>
                <xsl:with-param name="extra_params" select="'&amp;info_type=CPE'"/>
              </xsl:call-template>
            </td>
            <td>
              <xsl:call-template name="column-name">
                <xsl:with-param name="head">Modified</xsl:with-param>
                <xsl:with-param name="name">modified</xsl:with-param>
                <xsl:with-param name="type">info</xsl:with-param>
                <xsl:with-param name="extra_params" select="'&amp;info_type=CPE'"/>
              </xsl:call-template>
            </td>
            <td>
              <xsl:call-template name="column-name">
                <xsl:with-param name="head">CVEs</xsl:with-param>
                <xsl:with-param name="name">cves</xsl:with-param>
                <xsl:with-param name="type">info</xsl:with-param>
                <xsl:with-param name="extra_params" select="'&amp;info_type=CPE'"/>
              </xsl:call-template>
            </td>
            <td>
              <xsl:call-template name="column-name">
                <xsl:with-param name="head">Max CVSS</xsl:with-param>
                <xsl:with-param name="name">max_cvss</xsl:with-param>
                <xsl:with-param name="type">info</xsl:with-param>
                <xsl:with-param name="extra_params" select="'&amp;info_type=CPE'"/>
              </xsl:call-template>
            </td>
            <td>Actions</td>
          </tr>
          <xsl:apply-templates select="info/cpe"/>
          <xsl:if test="string-length (filters/term) &gt; 0">
            <tr>
              <td class="footnote" colspan="6">
                (Applied filter:
                <a class="footnote" href="/omp?cmd=get_info&amp;info_type=cpe&amp;filter={str:encode-uri (filters/term, true ())}&amp;first={info/@start}&amp;max={info/@max}&amp;token={/envelope/token}">
                  <xsl:value-of select="filters/term"/>
                </a>)
              </td>
            </tr>
          </xsl:if>
        </table>
      </div>
    </div>
  </div>
</xsl:template>

<xsl:template name="html-cve-table">
  <xsl:if test="@status = 400">
    <xsl:call-template name="error_window">
      <xsl:with-param name="heading">Warning: SecInfo Database Missing</xsl:with-param>
      <xsl:with-param name="message">
        SCAP and/or CERT database missing on OMP server.
        <a href="/help/cves.html?token={/envelope/token}#secinfo_missing"
           title="Help: SecInfo database missing">
          <img style="margin-left:5px" src="/img/help.png"/>
        </a>
      </xsl:with-param>
    </xsl:call-template>
    <br/>
  </xsl:if>
  <div class="gb_window">
    <div class="gb_window_part_left"></div>
    <div class="gb_window_part_right"></div>
    <div class="gb_window_part_center">CVEs
      <xsl:call-template name="filter-window-pager">
        <xsl:with-param name="type" select="'info'"/>
        <xsl:with-param name="list" select="info"/>
        <xsl:with-param name="count" select="count(info/cve)"/>
        <xsl:with-param name="filtered_count" select="info_count/filtered"/>
        <xsl:with-param name="full_count" select="info_count/text ()"/>
        <xsl:with-param name="extra_params" select="'&amp;info_type=CVE'"/>
      </xsl:call-template>
      <a href="/help/cves.html?token={/envelope/token}"
        title="Help: CVE">
        <img src="/img/help.png"/>
      </a>
      <a href="/omp?cmd=get_info&amp;info_type=cve&amp;token={/envelope/token}"
         title="Return to default filter view" style="margin-left:3px;">
        <img src="/img/list.png" border="0" alt="Return"/>
      </a>
    </div>
    <xsl:if test="not(/envelope/params/info_name or /envelope/params/info_id)">
      <xsl:call-template name="filter-window-part">
        <xsl:with-param name="type" select="'info'"/>
        <xsl:with-param name="list" select="info"/>
        <xsl:with-param name="extra_params">
          <param>
            <name>info_type</name>
            <value>CVE</value>
          </param>
        </xsl:with-param>
      </xsl:call-template>
    </xsl:if>
    <div class="gb_window_part_content_no_pad">
      <div id="cves">
        <table class="gbntable" cellspacing="2" cellpadding="4" border="0">
          <tr class="gbntablehead2">
            <td>
              <xsl:call-template name="column-name">
                <xsl:with-param name="head">Name</xsl:with-param>
                <xsl:with-param name="name">name</xsl:with-param>
                <xsl:with-param name="type">info</xsl:with-param>
                <xsl:with-param name="extra_params" select="'&amp;info_type=CVE'"/>
              </xsl:call-template>
            </td>
            <td>
              <xsl:call-template name="column-name">
                <xsl:with-param name="head">Vector</xsl:with-param>
                <xsl:with-param name="name">vector</xsl:with-param>
                <xsl:with-param name="type">info</xsl:with-param>
                <xsl:with-param name="extra_params" select="'&amp;info_type=CVE'"/>
              </xsl:call-template>
            </td>
            <td>
              <xsl:call-template name="column-name">
                <xsl:with-param name="head">Complexity</xsl:with-param>
                <xsl:with-param name="name">complexity</xsl:with-param>
                <xsl:with-param name="type">info</xsl:with-param>
                <xsl:with-param name="extra_params" select="'&amp;info_type=CVE'"/>
              </xsl:call-template>
            </td>
            <td>
              <xsl:call-template name="column-name">
                <xsl:with-param name="head">Authentication</xsl:with-param>
                <xsl:with-param name="name">authentication</xsl:with-param>
                <xsl:with-param name="type">info</xsl:with-param>
                <xsl:with-param name="extra_params" select="'&amp;info_type=CVE'"/>
              </xsl:call-template>
            </td>
            <td>
              <xsl:call-template name="column-name">
                <xsl:with-param name="head">Confidentiality Impact</xsl:with-param>
                <xsl:with-param name="name">confidentiality_impact</xsl:with-param>
                <xsl:with-param name="type">info</xsl:with-param>
                <xsl:with-param name="extra_params" select="'&amp;info_type=CVE'"/>
              </xsl:call-template>
            </td>
            <td>
              <xsl:call-template name="column-name">
                <xsl:with-param name="head">Integrity Impact</xsl:with-param>
                <xsl:with-param name="name">integrity_impact</xsl:with-param>
                <xsl:with-param name="type">info</xsl:with-param>
                <xsl:with-param name="extra_params" select="'&amp;info_type=CVE'"/>
              </xsl:call-template>
            </td>
            <td>
              <xsl:call-template name="column-name">
                <xsl:with-param name="head">Availability Impact</xsl:with-param>
                <xsl:with-param name="name">availability_impact</xsl:with-param>
                <xsl:with-param name="type">info</xsl:with-param>
                <xsl:with-param name="extra_params" select="'&amp;info_type=CVE'"/>
              </xsl:call-template>
            </td>
            <td>
              <xsl:call-template name="column-name">
                <xsl:with-param name="head">Published</xsl:with-param>
                <xsl:with-param name="name">published</xsl:with-param>
                <xsl:with-param name="type">info</xsl:with-param>
                <xsl:with-param name="extra_params" select="'&amp;info_type=CVE'"/>
              </xsl:call-template>
            </td>
            <td>
              <xsl:call-template name="column-name">
                <xsl:with-param name="head">CVSS</xsl:with-param>
                <xsl:with-param name="name">cvss</xsl:with-param>
                <xsl:with-param name="type">info</xsl:with-param>
                <xsl:with-param name="extra_params" select="'&amp;info_type=CVE'"/>
              </xsl:call-template>
            </td>
            <td>Actions</td>
          </tr>
          <xsl:apply-templates select="info/cve"/>
          <xsl:if test="string-length (filters/term) &gt; 0">
            <tr>
              <td class="footnote" colspan="6">
                (Applied filter:
                <a class="footnote" href="/omp?cmd=get_info&amp;info_type=cve&amp;filter={str:encode-uri (filters/term, true ())}&amp;first={info/@start}&amp;max={info/@max}&amp;token={/envelope/token}">
                  <xsl:value-of select="filters/term"/>
                </a>)
              </td>
            </tr>
          </xsl:if>
        </table>
      </div>
    </div>
  </div>
</xsl:template>

<xsl:template name="html-nvt-table">
  <xsl:if test="@status = 400">
    <xsl:call-template name="error_window">
      <xsl:with-param name="heading">Warning: SecInfo Database Missing</xsl:with-param>
      <xsl:with-param name="message">
        SCAP and/or CERT database missing on OMP server.
        <a href="/help/nvts.html?token={/envelope/token}#secinfo_missing"
           title="Help: SecInfo database missing">
          <img style="margin-left:5px" src="/img/help.png"/>
        </a>
      </xsl:with-param>
    </xsl:call-template>
    <br/>
  </xsl:if>
  <div class="gb_window">
    <div class="gb_window_part_left"></div>
    <div class="gb_window_part_right"></div>
    <div class="gb_window_part_center">NVTs
      <xsl:call-template name="filter-window-pager">
        <xsl:with-param name="type" select="'info'"/>
        <xsl:with-param name="list" select="info"/>
        <xsl:with-param name="count" select="count(info/nvt)"/>
        <xsl:with-param name="filtered_count" select="info_count/filtered"/>
        <xsl:with-param name="full_count" select="info_count/text ()"/>
        <xsl:with-param name="extra_params" select="'&amp;info_type=NVT'"/>
      </xsl:call-template>
      <a href="/help/nvts.html?token={/envelope/token}"
        title="Help: NVT">
        <img src="/img/help.png"/>
      </a>
      <a href="/omp?cmd=get_info&amp;info_type=nvt&amp;token={/envelope/token}"
         title="Return to default filter view" style="margin-left:3px;">
        <img src="/img/list.png" border="0" alt="Return"/>
      </a>
    </div>
    <xsl:call-template name="filter-window-part">
      <xsl:with-param name="type" select="'info'"/>
      <xsl:with-param name="list" select="info"/>
      <xsl:with-param name="extra_params">
        <param>
          <name>info_type</name>
          <value>NVT</value>
        </param>
      </xsl:with-param>
    </xsl:call-template>
    <div class="gb_window_part_content_no_pad">
      <div id="cpes">
        <table class="gbntable" cellspacing="2" cellpadding="4" border="0">
          <tr class="gbntablehead2">
            <td>
              <xsl:call-template name="column-name">
                <xsl:with-param name="head">Name</xsl:with-param>
                <xsl:with-param name="name">name</xsl:with-param>
                <xsl:with-param name="type">info</xsl:with-param>
                <xsl:with-param name="extra_params" select="'&amp;info_type=NVT'"/>
              </xsl:call-template>
            </td>
            <td>
              <xsl:call-template name="column-name">
                <xsl:with-param name="head">Family</xsl:with-param>
                <xsl:with-param name="name">family</xsl:with-param>
                <xsl:with-param name="type">info</xsl:with-param>
                <xsl:with-param name="extra_params" select="'&amp;info_type=NVT'"/>
              </xsl:call-template>
            </td>
            <td>
              <xsl:call-template name="column-name">
                <xsl:with-param name="head">Created</xsl:with-param>
                <xsl:with-param name="name">created</xsl:with-param>
                <xsl:with-param name="type">info</xsl:with-param>
                <xsl:with-param name="extra_params" select="'&amp;info_type=NVT'"/>
              </xsl:call-template>
            </td>
            <td>
              <xsl:call-template name="column-name">
                <xsl:with-param name="head">Modified</xsl:with-param>
                <xsl:with-param name="name">modified</xsl:with-param>
                <xsl:with-param name="type">info</xsl:with-param>
                <xsl:with-param name="extra_params" select="'&amp;info_type=NVT'"/>
              </xsl:call-template>
            </td>
            <td>
              <xsl:call-template name="column-name">
                <xsl:with-param name="head">Version</xsl:with-param>
                <xsl:with-param name="name">version</xsl:with-param>
                <xsl:with-param name="type">info</xsl:with-param>
                <xsl:with-param name="extra_params" select="'&amp;info_type=NVT'"/>
              </xsl:call-template>
            </td>
            <td>
              <xsl:call-template name="column-name">
                <xsl:with-param name="head">CVE</xsl:with-param>
                <xsl:with-param name="name">cve</xsl:with-param>
                <xsl:with-param name="type">info</xsl:with-param>
                <xsl:with-param name="extra_params" select="'&amp;info_type=NVT'"/>
              </xsl:call-template>
            </td>
            <td>
              <xsl:call-template name="column-name">
                <xsl:with-param name="head">CVSS</xsl:with-param>
                <xsl:with-param name="name">cvss_base</xsl:with-param>
                <xsl:with-param name="type">info</xsl:with-param>
                <xsl:with-param name="extra_params" select="'&amp;info_type=NVT'"/>
              </xsl:call-template>
            </td>
            <td>Actions</td>
          </tr>
          <xsl:apply-templates select="info/nvt"/>
          <xsl:if test="string-length (filters/term) &gt; 0">
            <tr>
              <td class="footnote" colspan="6">
                (Applied filter:
                <a class="footnote" href="/omp?cmd=get_info&amp;info_type=nvt&amp;filter={str:encode-uri (filters/term, true ())}&amp;first={info/@start}&amp;max={info/@max}&amp;token={/envelope/token}">
                  <xsl:value-of select="filters/term"/>
                </a>)
              </td>
            </tr>
          </xsl:if>
        </table>
      </div>
    </div>
  </div>
</xsl:template>

<xsl:template name="html-ovaldef-table">
  <xsl:if test="@status = 400">
    <xsl:call-template name="error_window">
      <xsl:with-param name="heading">Warning: SecInfo Database Missing</xsl:with-param>
      <xsl:with-param name="message">
        SCAP and/or CERT database missing on OMP server.
        <a href="/help/ovaldefs.html?token={/envelope/token}#secinfo_missing"
           title="Help: SecInfo database missing">
          <img style="margin-left:5px" src="/img/help.png"/>
        </a>
      </xsl:with-param>
    </xsl:call-template>
    <br/>
  </xsl:if>
  <div class="gb_window">
    <div class="gb_window_part_left"></div>
    <div class="gb_window_part_right"></div>
    <div class="gb_window_part_center">OVAL Definitions
      <xsl:call-template name="filter-window-pager">
        <xsl:with-param name="type" select="'info'"/>
        <xsl:with-param name="list" select="info"/>
        <xsl:with-param name="count" select="count(info/ovaldef)"/>
        <xsl:with-param name="filtered_count" select="info_count/filtered"/>
        <xsl:with-param name="full_count" select="info_count/text ()"/>
        <xsl:with-param name="extra_params" select="'&amp;info_type=OVALDEF'"/>
      </xsl:call-template>
      <a href="/help/ovaldefs.html?token={/envelope/token}"
        title="Help: OVAL Definitions">
        <img src="/img/help.png"/>
      </a>
      <a href="/omp?cmd=get_info&amp;info_type=ovaldef&amp;token={/envelope/token}"
         title="Return to default filter view" style="margin-left:3px;">
        <img src="/img/list.png" border="0" alt="Return"/>
      </a>
    </div>
    <xsl:if test="not(/envelope/params/info_name or /envelope/params/info_id)">
      <xsl:call-template name="filter-window-part">
        <xsl:with-param name="type" select="'info'"/>
        <xsl:with-param name="list" select="info"/>
        <xsl:with-param name="extra_params">
          <param>
            <name>info_type</name>
            <value>OVALDEF</value>
          </param>
        </xsl:with-param>
      </xsl:call-template>
    </xsl:if>
    <div class="gb_window_part_content_no_pad">
      <div id="ovaldefs">
        <table class="gbntable" cellspacing="2" cellpadding="4" border="0">
          <tr class="gbntablehead2">
            <td>
              <xsl:call-template name="column-name">
                <xsl:with-param name="head">Name</xsl:with-param>
                <xsl:with-param name="name">name</xsl:with-param>
                <xsl:with-param name="type">info</xsl:with-param>
                <xsl:with-param name="extra_params" select="'&amp;info_type=OVALDEF'"/>
              </xsl:call-template>
            </td>
            <td>
              <xsl:call-template name="column-name">
                <xsl:with-param name="head">Version</xsl:with-param>
                <xsl:with-param name="name">version</xsl:with-param>
                <xsl:with-param name="type">info</xsl:with-param>
                <xsl:with-param name="extra_params" select="'&amp;info_type=OVALDEF'"/>
              </xsl:call-template>
            </td>
            <td>
              <xsl:call-template name="column-name">
                <xsl:with-param name="head">Status</xsl:with-param>
                <xsl:with-param name="name">status</xsl:with-param>
                <xsl:with-param name="type">info</xsl:with-param>
                <xsl:with-param name="extra_params" select="'&amp;info_type=OVALDEF'"/>
              </xsl:call-template>
            </td>
            <td>
              <xsl:call-template name="column-name">
                <xsl:with-param name="head">Class</xsl:with-param>
                <xsl:with-param name="name">class</xsl:with-param>
                <xsl:with-param name="type">info</xsl:with-param>
                <xsl:with-param name="extra_params" select="'&amp;info_type=OVALDEF'"/>
              </xsl:call-template>
            </td>
            <td>
              <xsl:call-template name="column-name">
                <xsl:with-param name="head">Created</xsl:with-param>
                <xsl:with-param name="name">created</xsl:with-param>
                <xsl:with-param name="type">info</xsl:with-param>
                <xsl:with-param name="extra_params" select="'&amp;info_type=OVALDEF'"/>
              </xsl:call-template>
            </td>
            <td>
              <xsl:call-template name="column-name">
                <xsl:with-param name="head">Modified</xsl:with-param>
                <xsl:with-param name="name">modified</xsl:with-param>
                <xsl:with-param name="type">info</xsl:with-param>
                <xsl:with-param name="extra_params" select="'&amp;info_type=OVALDEF'"/>
              </xsl:call-template>
            </td>
            <td>Actions</td>
          </tr>
          <xsl:apply-templates select="info/ovaldef"/>
          <xsl:if test="string-length (filters/term) &gt; 0">
            <tr>
              <td class="footnote" colspan="2">
                (Applied filter:
                <a class="footnote" href="/omp?cmd=get_info&amp;info_type=ovaldef&amp;filter={str:encode-uri (filters/term, true ())}&amp;first={info/@start}&amp;max={info/@max}&amp;token={/envelope/token}">
                  <xsl:value-of select="filters/term"/>
                </a>)
              </td>
            </tr>
          </xsl:if>
        </table>
      </div>
    </div>
  </div>
</xsl:template>

<xsl:template name="html-dfn_cert_adv-table">
  <xsl:if test="@status = 400">
    <xsl:call-template name="error_window">
      <xsl:with-param name="heading">Warning: SecInfo Database Missing</xsl:with-param>
      <xsl:with-param name="message">
        SCAP and/or CERT database missing on OMP server.
        <a href="/help/dfn_cert_advs.html?token={/envelope/token}#secinfo_missing"
           title="Help: SecInfo database missing">
          <img style="margin-left:5px" src="/img/help.png"/>
        </a>
      </xsl:with-param>
    </xsl:call-template>
    <br/>
  </xsl:if>
  <div class="gb_window">
    <div class="gb_window_part_left"></div>
    <div class="gb_window_part_right"></div>
    <div class="gb_window_part_center">DFN-CERT Advisories
      <xsl:call-template name="filter-window-pager">
        <xsl:with-param name="type" select="'info'"/>
        <xsl:with-param name="list" select="info"/>
        <xsl:with-param name="count" select="count(info/dfn_cert_adv)"/>
        <xsl:with-param name="filtered_count" select="info_count/filtered"/>
        <xsl:with-param name="full_count" select="info_count/text ()"/>
        <xsl:with-param name="extra_params" select="'&amp;info_type=DFN_CERT_ADV'"/>
      </xsl:call-template>
      <a href="/help/dfn_cert_advs.html?token={/envelope/token}"
        title="Help: DFN-CERT Advisories">
        <img src="/img/help.png"/>
      </a>
      <a href="/omp?cmd=get_info&amp;info_type=dfn_cert_adv&amp;token={/envelope/token}"
         title="Return to default filter view" style="margin-left:3px;">
        <img src="/img/list.png" border="0" alt="Return"/>
      </a>
    </div>
    <xsl:if test="not(/envelope/params/info_name or /envelope/params/info_id)">
      <xsl:call-template name="filter-window-part">
        <xsl:with-param name="type" select="'info'"/>
        <xsl:with-param name="list" select="info"/>
        <xsl:with-param name="extra_params">
          <param>
            <name>info_type</name>
            <value>DFN_CERT_ADV</value>
          </param>
        </xsl:with-param>
      </xsl:call-template>
    </xsl:if>
    <div class="gb_window_part_content_no_pad">
      <div id="dfn_cert_advs">
        <table class="gbntable" cellspacing="2" cellpadding="4" border="0">
          <tr class="gbntablehead2">
            <td>
              <xsl:call-template name="column-name">
                <xsl:with-param name="head">Name</xsl:with-param>
                <xsl:with-param name="name">name</xsl:with-param>
                <xsl:with-param name="type">info</xsl:with-param>
                <xsl:with-param name="extra_params" select="'&amp;info_type=DFN_CERT_ADV'"/>
              </xsl:call-template>
            </td>
            <td>
              <xsl:call-template name="column-name">
                <xsl:with-param name="head">Title</xsl:with-param>
                <xsl:with-param name="name">title</xsl:with-param>
                <xsl:with-param name="type">info</xsl:with-param>
                <xsl:with-param name="extra_params" select="'&amp;info_type=DFN_CERT_ADV'"/>
              </xsl:call-template>
            </td>
            <td>
              <xsl:call-template name="column-name">
                <xsl:with-param name="head">Created</xsl:with-param>
                <xsl:with-param name="name">created</xsl:with-param>
                <xsl:with-param name="type">info</xsl:with-param>
                <xsl:with-param name="extra_params" select="'&amp;info_type=DFN_CERT_ADV'"/>
              </xsl:call-template>
            </td>
            <td>
              <xsl:call-template name="column-name">
                <xsl:with-param name="head">CVEs</xsl:with-param>
                <xsl:with-param name="name">cves</xsl:with-param>
                <xsl:with-param name="type">info</xsl:with-param>
                <xsl:with-param name="extra_params" select="'&amp;info_type=DFN_CERT_ADV'"/>
              </xsl:call-template>
            </td>
            <td>Actions</td>
          </tr>
          <xsl:apply-templates select="info/dfn_cert_adv"/>
          <xsl:if test="string-length (filters/term) &gt; 0">
            <tr>
              <td class="footnote" colspan="2">
                (Applied filter:
                <a class="footnote" href="/omp?cmd=get_info&amp;info_type=dfn_cert_adv&amp;filter={str:encode-uri (filters/term, true ())}&amp;first={info/@start}&amp;max={info/@max}&amp;token={/envelope/token}">
                  <xsl:value-of select="filters/term"/>
                </a>)
              </td>
            </tr>
          </xsl:if>
        </table>
      </div>
    </div>
  </div>
</xsl:template>

<xsl:template name="html-allinfo-table">
  <xsl:if test="@status = 400">
    <xsl:call-template name="error_window">
      <xsl:with-param name="heading">Warning: SecInfo Database Missing</xsl:with-param>
      <xsl:with-param name="message">
        SCAP and/or CERT database missing on OMP server.
        <a href="/help/allinfo.html?token={/envelope/token}#secinfo_missing"
           title="Help: SecInfo database missing">
          <img style="margin-left:5px" src="/img/help.png"/>
        </a>
      </xsl:with-param>
    </xsl:call-template>
    <br/>
  </xsl:if>
  <div class="gb_window">
    <div class="gb_window_part_left"></div>
    <div class="gb_window_part_right"></div>
    <div class="gb_window_part_center">All SecInfo Information
      <xsl:call-template name="filter-window-pager">
        <xsl:with-param name="type" select="'info'"/>
        <xsl:with-param name="list" select="info"/>
        <xsl:with-param name="count" select="count(info/allinfo)"/>
        <xsl:with-param name="filtered_count" select="info_count/filtered"/>
        <xsl:with-param name="full_count" select="info_count/text ()"/>
        <xsl:with-param name="extra_params" select="'&amp;info_type=allinfo'"/>
      </xsl:call-template>
      <a href="/help/allinfo.html?token={/envelope/token}"
        title="Help: All SecInfo Information">
        <img src="/img/help.png"/>
      </a>
      <a href="/omp?cmd=get_info&amp;info_type=allinfo&amp;token={/envelope/token}"
         title="Return to default filter view" style="margin-left:3px;">
        <img src="/img/list.png" border="0" alt="Return"/>
      </a>
    </div>
    <xsl:if test="not(/envelope/params/info_name or /envelope/params/info_id)">
      <xsl:call-template name="filter-window-part">
        <xsl:with-param name="type" select="'info'"/>
        <xsl:with-param name="list" select="info"/>
        <xsl:with-param name="extra_params">
          <param>
            <name>info_type</name>
            <value>allinfo</value>
          </param>
        </xsl:with-param>
      </xsl:call-template>
    </xsl:if>
    <div class="gb_window_part_content_no_pad">
      <div id="allinfo">
        <table class="gbntable" cellspacing="2" cellpadding="4" border="0">
          <tr class="gbntablehead2">
            <td>
              <xsl:call-template name="column-name">
                <xsl:with-param name="head">Name</xsl:with-param>
                <xsl:with-param name="name">name</xsl:with-param>
                <xsl:with-param name="type">info</xsl:with-param>
                <xsl:with-param name="extra_params" select="'&amp;info_type=allinfo'"/>
              </xsl:call-template>
            </td>
            <td>
              <xsl:call-template name="column-name">
                <xsl:with-param name="head">Type</xsl:with-param>
                <xsl:with-param name="name">type</xsl:with-param>
                <xsl:with-param name="type">info</xsl:with-param>
                <xsl:with-param name="extra_params" select="'&amp;info_type=allinfo'"/>
              </xsl:call-template>
            </td>
            <td>
              <xsl:call-template name="column-name">
                <xsl:with-param name="head">Created</xsl:with-param>
                <xsl:with-param name="name">created</xsl:with-param>
                <xsl:with-param name="type">info</xsl:with-param>
                <xsl:with-param name="extra_params" select="'&amp;info_type=allinfo'"/>
              </xsl:call-template>
            </td>
            <td>
              <xsl:call-template name="column-name">
                <xsl:with-param name="head">Modified</xsl:with-param>
                <xsl:with-param name="name">modified</xsl:with-param>
                <xsl:with-param name="type">info</xsl:with-param>
                <xsl:with-param name="extra_params" select="'&amp;info_type=allinfo'"/>
              </xsl:call-template>
            </td>
            <td>Actions</td>
          </tr>
          <xsl:apply-templates select="info/allinfo"/>
          <xsl:if test="string-length (filters/term) &gt; 0">
            <tr>
              <td class="footnote" colspan="6">
                (Applied filter:
                <a class="footnote" href="/omp?cmd=get_info&amp;info_type=allinfo&amp;filter={str:encode-uri (filters/term, true ())}&amp;first={info/@start}&amp;max={info/@max}&amp;token={/envelope/token}">
                  <xsl:value-of select="filters/term"/>
                </a>)
              </td>
            </tr>
          </xsl:if>
        </table>
      </div>
    </div>
  </div>
</xsl:template>

<xsl:template match="get_info_response">
  <xsl:choose>
    <xsl:when test="/envelope/params/info_type = 'CPE' or /envelope/params/info_type = 'cpe'">
      <xsl:choose>
        <xsl:when test="(/envelope/params/info_name and info_count/filtered &lt;= 1)
                        or /envelope/params/info_id">
          <xsl:call-template name="cpe-details"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:call-template name="html-cpe-table"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:when>
    <xsl:when test="/envelope/params/info_type = 'CVE' or /envelope/params/info_type = 'cve'">
      <xsl:choose>
        <xsl:when test="(/envelope/params/info_name and info_count/filtered &lt;= 1)
                        or /envelope/params/info_id">
          <xsl:call-template name="cve-details"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:call-template name="html-cve-table"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:when>
    <xsl:when test="/envelope/params/info_type = 'NVT' or /envelope/params/info_type = 'nvt'">
      <xsl:choose>
        <xsl:when test="(/envelope/params/info_name and info_count/filtered &lt;= 1)
                        or /envelope/params/info_id">
          <xsl:call-template name="nvt-details"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:call-template name="html-nvt-table"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:when>
    <xsl:when test="/envelope/params/info_type = 'OVALDEF' or /envelope/params/info_type = 'ovaldef'">
      <xsl:choose>
        <xsl:when test="(/envelope/params/info_name and info_count/filtered &lt;= 1)
                        or /envelope/params/info_id">
          <xsl:call-template name="ovaldef-details"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:call-template name="html-ovaldef-table"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:when>
    <xsl:when test="/envelope/params/info_type = 'DFN_CERT_ADV' or /envelope/params/info_type = 'dfn_cert_adv'">
      <xsl:choose>
        <xsl:when test="(/envelope/params/info_name and info_count/filtered &lt;= 1)
                        or /envelope/params/info_id">
          <xsl:call-template name="dfn_cert_adv-details"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:call-template name="html-dfn_cert_adv-table"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:when>
    <xsl:when test="/envelope/params/info_type = 'ALLINFO' or /envelope/params/info_type = 'allinfo'">
      <xsl:choose>
        <xsl:when test="(/envelope/params/info_name and info_count/filtered &lt;= 1)
                        or /envelope/params/info_id">
          <xsl:call-template name="allinfo-details"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:call-template name="html-allinfo-table"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:when>
    <xsl:otherwise>
      <div class="gb_window">
        <div class="gb_window_part_left"></div>
        <div class="gb_window_part_right"></div>
        <div class="gb_window_part_center">SecInfo Management</div>
        <div class="gb_window_part_content">
          <xsl:choose>
            <xsl:when test="contains (@status_text, 'SCAP') and @status = '400'">
              <h1>SecInfo Database not available</h1>
              <p>
                Please ensure that your SCAP data is synced by either running openvas-scapdata-sync
                or greenbone-scapdata-sync on your system.
              </p>
            </xsl:when>
            <xsl:when test="contains (@status_text, 'CVE-')">
              <h1>Unknown vulnerability</h1>
              <p>
                <xsl:value-of select="@status_text"/>
              </p>
              <p>
                Please ensure that your SCAP data is up to date and that you entered
                a valid CVE. If the problem persists, the CVE is not available.
                In some cases, CVE references are reserved but did not
                enter the offical CVE database yet. Some were reserved and used as
                a reference by vendors, but never entered the CVE database.
              </p>
            </xsl:when>
            <xsl:otherwise>
              <h1>Unknown element</h1>
              <p>
                <xsl:value-of select="@status_text"/>
              </p>
              <p>
                Unknown element type. Ensure that the URL is correct and
                especially that the <code>info_type</code> and
                <code>info_name</code> parameters are consistent.
              </p>
            </xsl:otherwise>
          </xsl:choose>
        </div>
      </div>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template name="cve-details">
  <div class="gb_window">
    <div class="gb_window_part_left"></div>
    <div class="gb_window_part_right"></div>
    <div class="gb_window_part_center">CVE Details
      <a href="/help/cve_details.html?token={/envelope/token}"
        title="Help: CVE (CVE Details)">
        <img src="/img/help.png"/>
      </a>
      <a href="/omp?cmd=get_info&amp;info_type=cve&amp;filter={str:encode-uri (/envelope/params/filter, true ())}&amp;filt_id={/envelope/params/filt_id}&amp;token={/envelope/token}"
        title="CVE" style="margin-left:3px;">
        <img src="/img/list.png" border="0" alt="CVE"/>
      </a>
    </div>
    <div class="gb_window_part_content">
      <div class="float_right" style="font-size: 10px;">
        <table style="font-size: 10px;">
          <tr>
            <td>ID:</td>
            <td>
              <xsl:choose>
                <xsl:when test="info/cve">
                  <xsl:value-of select="info/cve/raw_data/cve:entry/@id"/>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:value-of select="/envelope/params/info_name"/>
                </xsl:otherwise>
              </xsl:choose>
            </td>
          </tr>
          <tr>
            <td>Published:</td>
            <td><xsl:value-of select="info/cve/raw_data/cve:entry/vuln:published-datetime"/></td>
          </tr>
          <tr>
            <td>Last modified:</td>
            <td><xsl:value-of select="info/cve/raw_data/cve:entry/vuln:last-modified-datetime"/></td>
          </tr>
          <tr>
            <td>Last updated:</td>
            <td><xsl:value-of select="info/update_time"/></td>
          </tr>
        </table>
      </div>

      <table>
        <tr>
          <td><b>Name:</b></td>
          <td>
            <b>
              <xsl:choose>
                <xsl:when test="info/cve">
                  <xsl:value-of select="info/cve/raw_data/cve:entry/@id"/>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:value-of select="/envelope/params/info_name"/>
                </xsl:otherwise>
              </xsl:choose>
            </b>
          </td>
        </tr>
        <tr>
          <td>CWE ID:</td>
          <td><xsl:value-of select="info/cve/raw_data/cve:entry/vuln:cwe/@id"/></td>
        </tr>
      </table>

      <xsl:choose>
        <xsl:when test="info/cve">
          <h1>Description</h1>
          <xsl:value-of select="info/cve/raw_data/cve:entry/vuln:summary/text()"/>

          <xsl:choose>
            <xsl:when test="info/cve/raw_data/cve:entry/vuln:cvss">
              <h1>CVSS</h1>
              <table>
                <tr>
                  <td>Base score</td>
                  <td>
                    <xsl:call-template name="severity-bar">
                      <xsl:with-param name="cvss" select="info/cve/raw_data/cve:entry/vuln:cvss/cvss:base_metrics/cvss:score"/>
                    </xsl:call-template>
                    (AV:<xsl:choose>
                      <xsl:when test="info/cve/raw_data/cve:entry/vuln:cvss/cvss:base_metrics/cvss:access-vector = 'LOCAL'">L</xsl:when>
                      <xsl:when test="info/cve/raw_data/cve:entry/vuln:cvss/cvss:base_metrics/cvss:access-vector = 'NETWORK'">N</xsl:when>
                      <xsl:when test="info/cve/raw_data/cve:entry/vuln:cvss/cvss:base_metrics/cvss:access-vector = 'ADJACENT_NETWORK'">A</xsl:when>
                      <xsl:otherwise>ERROR</xsl:otherwise>
                    </xsl:choose>/AC:<xsl:choose>
                      <xsl:when test="info/cve/raw_data/cve:entry/vuln:cvss/cvss:base_metrics/cvss:access-complexity = 'LOW'">L</xsl:when>
                      <xsl:when test="info/cve/raw_data/cve:entry/vuln:cvss/cvss:base_metrics/cvss:access-complexity = 'MEDIUM'">M</xsl:when>
                      <xsl:when test="info/cve/raw_data/cve:entry/vuln:cvss/cvss:base_metrics/cvss:access-complexity = 'HIGH'">H</xsl:when>
                      <xsl:otherwise>ERROR</xsl:otherwise>
                    </xsl:choose>/Au:<xsl:choose>
                      <xsl:when test="info/cve/raw_data/cve:entry/vuln:cvss/cvss:base_metrics/cvss:authentication = 'NONE'">N</xsl:when>
                      <xsl:when test="info/cve/raw_data/cve:entry/vuln:cvss/cvss:base_metrics/cvss:authentication = 'MULTIPLE_INSTANCES'">M</xsl:when>
                      <xsl:when test="info/cve/raw_data/cve:entry/vuln:cvss/cvss:base_metrics/cvss:authentication = 'SINGLE_INSTANCE'">C</xsl:when>
                      <xsl:otherwise>ERROR</xsl:otherwise>
                    </xsl:choose>/C:<xsl:choose>
                      <xsl:when test="info/cve/raw_data/cve:entry/vuln:cvss/cvss:base_metrics/cvss:confidentiality-impact = 'NONE'">N</xsl:when>
                      <xsl:when test="info/cve/raw_data/cve:entry/vuln:cvss/cvss:base_metrics/cvss:confidentiality-impact = 'PARTIAL'">P</xsl:when>
                      <xsl:when test="info/cve/raw_data/cve:entry/vuln:cvss/cvss:base_metrics/cvss:confidentiality-impact = 'COMPLETE'">C</xsl:when>
                      <xsl:otherwise>ERROR</xsl:otherwise>
                    </xsl:choose>/I:<xsl:choose>
                      <xsl:when test="info/cve/raw_data/cve:entry/vuln:cvss/cvss:base_metrics/cvss:integrity-impact = 'NONE'">N</xsl:when>
                      <xsl:when test="info/cve/raw_data/cve:entry/vuln:cvss/cvss:base_metrics/cvss:integrity-impact = 'PARTIAL'">N</xsl:when>
                      <xsl:when test="info/cve/raw_data/cve:entry/vuln:cvss/cvss:base_metrics/cvss:integrity-impact = 'COMPLETE'">N</xsl:when>
                      <xsl:otherwise>ERROR</xsl:otherwise>
                    </xsl:choose>/A:<xsl:choose>
                      <xsl:when test="info/cve/raw_data/cve:entry/vuln:cvss/cvss:base_metrics/cvss:availability-impact = 'NONE'">N</xsl:when>
                      <xsl:when test="info/cve/raw_data/cve:entry/vuln:cvss/cvss:base_metrics/cvss:availability-impact = 'PARTIAL'">P</xsl:when>
                      <xsl:when test="info/cve/raw_data/cve:entry/vuln:cvss/cvss:base_metrics/cvss:availability-impact = 'COMPLETE'">C</xsl:when>
                      <xsl:otherwise>ERROR</xsl:otherwise>
                    </xsl:choose>)
                  </td>
                </tr>
                <tr>
                  <td>Access vector</td>
                  <td><xsl:value-of select="info/cve/raw_data/cve:entry/vuln:cvss/cvss:base_metrics/cvss:access-vector"/></td>
                </tr>
                <tr>
                  <td>Access Complexity</td>
                  <td><xsl:value-of select="info/cve/raw_data/cve:entry/vuln:cvss/cvss:base_metrics/cvss:access-complexity"/></td>
                </tr>
                <tr>
                  <td>Authentication</td>
                  <td><xsl:value-of select="info/cve/raw_data/cve:entry/vuln:cvss/cvss:base_metrics/cvss:authentication"/></td>
                </tr>
                <tr>
                  <td>Confidentiality impact</td>
                  <td><xsl:value-of select="info/cve/raw_data/cve:entry/vuln:cvss/cvss:base_metrics/cvss:confidentiality-impact"/></td>
                </tr>
                <tr>
                  <td>Integrity impact</td>
                  <td><xsl:value-of select="info/cve/raw_data/cve:entry/vuln:cvss/cvss:base_metrics/cvss:integrity-impact"/></td>
                </tr>
                <tr>
                  <td>Availability impact</td>
                  <td><xsl:value-of select="info/cve/raw_data/cve:entry/vuln:cvss/cvss:base_metrics/cvss:availability-impact"/></td>
                </tr>
                <tr>
                  <td>Source</td>
                  <td><xsl:value-of select="info/cve/raw_data/cve:entry/vuln:cvss/cvss:base_metrics/cvss:source"/></td>
                </tr>
                <tr>
                  <td>Generated</td>
                  <td><xsl:value-of select="info/cve/raw_data/cve:entry/vuln:cvss/cvss:base_metrics/cvss:generated-on-datetime"/></td>
                </tr>
              </table>
            </xsl:when>
            <xsl:otherwise>
              <h1>CVSS: None</h1>
            </xsl:otherwise>
          </xsl:choose>

          <xsl:choose>
            <xsl:when test="count(info/cve/raw_data/cve:entry/vuln:references) = 0">
              <h1>References: None</h1>
            </xsl:when>
            <xsl:otherwise>
              <h1>References</h1>
              <table>
                <xsl:for-each select="info/cve/raw_data/cve:entry/vuln:references">
                  <tr>
                    <td><xsl:value-of select="vuln:source/text()"/></td>
                  </tr>
                  <tr>
                    <td></td>
                    <td><xsl:value-of select="vuln:reference/text()"/></td>
                  </tr>
                  <tr>
                    <td></td>
                    <td><xsl:value-of select="vuln:reference/@href"/></td>
                  </tr>
                </xsl:for-each>
              </table>
            </xsl:otherwise>
          </xsl:choose>

          <xsl:choose>
            <xsl:when test="count(info/cve/cert/cert_ref) = 0">
            </xsl:when>
            <xsl:otherwise>
              <h1>CERT Advisories referencing this CVE</h1>
              <table class="gbntable" cellspacing="2" cellpadding="4">
                <tr class="gbntablehead2">
                  <td>Name</td>
                  <td>Title</td>
                  <td>Actions</td>
                </tr>
                <xsl:for-each select="info/cve/cert/cert_ref">
                  <xsl:variable name="class">
                    <xsl:choose>
                      <xsl:when test="position() mod 2 = 0">even</xsl:when>
                      <xsl:otherwise>odd</xsl:otherwise>
                    </xsl:choose>
                  </xsl:variable>
                  <tr class="{$class}">
                    <td><xsl:value-of select="name"/></td>
                    <td><xsl:value-of select="title"/></td>
                    <td width="100">
                      <xsl:choose>
                        <xsl:when test="@type='DFN-CERT'">
                        <a href="?cmd=get_info&amp;info_type=dfn_cert_adv&amp;info_name={name}&amp;details=1&amp;token={/envelope/token}" title="Details">
                          <img src="/img/details.png"
                          border="0"
                          alt="Details"
                          style="margin-left:3px;"/>
                        </a>
                        </xsl:when>
                        <xsl:otherwise>
                          <div class="error">Unknown CERT type!</div>
                        </xsl:otherwise>
                      </xsl:choose>
                    </td>
                  </tr>
                </xsl:for-each>
              </table>
            </xsl:otherwise>
          </xsl:choose>

          <xsl:choose>
            <xsl:when test="count(info/cve/raw_data/cve:entry/vuln:vulnerable-software-list/vuln:product) = 0">
              <h1>Vulnerable products: None</h1>
            </xsl:when>
            <xsl:otherwise>
              <h1>Vulnerable products</h1>
              <table class="gbntable" cellspacing="2" cellpadding="4">
                <tr class="gbntablehead2">
                  <td>Name</td>
                  <td>Actions</td>
                </tr>
                <xsl:for-each select="info/cve/raw_data/cve:entry/vuln:vulnerable-software-list/vuln:product">
                  <xsl:sort select="text()"/>
                  <xsl:variable name="class">
                    <xsl:choose>
                      <xsl:when test="position() mod 2 = 0">even</xsl:when>
                      <xsl:otherwise>odd</xsl:otherwise>
                    </xsl:choose>
                  </xsl:variable>
                  <tr class="{$class}">
                    <td><xsl:value-of select="text()"/></td>
                    <td width="100">
                      <a href="?cmd=get_info&amp;info_type=cpe&amp;info_name={text()}&amp;details=1&amp;token={/envelope/token}"
                        title="Details">
                        <img src="/img/details.png"
                          border="0"
                          alt="Details"
                          style="margin-left:3px;"/>
                      </a>
                    </td>
                  </tr>
                </xsl:for-each>
              </table>
            </xsl:otherwise>
          </xsl:choose>

          <xsl:choose>
            <xsl:when test="count(info/cve/nvts/nvt) = 0">
              <h1>NVTs addressing this CVE: None</h1>
            </xsl:when>
            <xsl:otherwise>
              <h1>NVTs addressing this CVE</h1>
              <table class="gbntable" cellspacing="2" cellpadding="4">
                <tr class="gbntablehead2">
                  <td>Name</td>
                  <td>Actions</td>
                </tr>
                <xsl:for-each select="info/cve/nvts/nvt">
                  <xsl:variable name="class">
                    <xsl:choose>
                      <xsl:when test="position() mod 2 = 0">even</xsl:when>
                      <xsl:otherwise>odd</xsl:otherwise>
                    </xsl:choose>
                  </xsl:variable>
                  <tr class="{$class}">
                    <td><xsl:value-of select="name"/></td>
                    <td width="100">
                      <a href="?cmd=get_nvts&amp;oid={@oid}&amp;token={/envelope/token}" title="Details">
                        <img src="/img/details.png"
                          border="0"
                          alt="Details"
                          style="margin-left:3px;"/>
                      </a>
                    </td>
                  </tr>
                </xsl:for-each>
              </table>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:when>
        <xsl:otherwise>
          <h1>Description</h1>
          <p>
            This CVE was not found in the database.  This is not necessarily
            an error, because the CVE number might have been assigned for the
            issue, but the CVE not yet published.  Eventually the CVE content
            will appear in the database.
          </p>
        </xsl:otherwise>
      </xsl:choose>
    </div>
  </div>
</xsl:template>

<xsl:template name="cpe-details">
  <div class="gb_window">
    <div class="gb_window_part_left"></div>
    <div class="gb_window_part_right"></div>
    <div class="gb_window_part_center">CPE Details
      <a href="/help/cpe_details.html?token={/envelope/token}"
        title="Help: CPE (CPE Details)">
        <img src="/img/help.png"/>
      </a>
      <a href="/omp?cmd=get_info&amp;info_type=cpe&amp;filter={str:encode-uri (/envelope/params/filter, true ())}&amp;filt_id={/envelope/params/filt_id}&amp;token={/envelope/token}"
        title="CPE" style="margin-left:3px;">
        <img src="/img/list.png" border="0" alt="CPE"/>
      </a>
    </div>
    <div class="gb_window_part_content">
      <div class="float_right" style="font-size: 10px;">
        <table style="font-size: 10px;">
          <xsl:if test="info/@id != ''">
            <tr>
              <td>ID:</td>
              <td><xsl:value-of select="info/@id"/></td>
            </tr>
          </xsl:if>
          <xsl:if test="info/modification_time != ''">
            <tr>
              <td>Last modified:</td>
              <td><xsl:value-of select="gsa:long-time (info/modification_time)"/></td>
            </tr>
          </xsl:if>
          <xsl:if test="info/creation_time != ''">
            <tr>
              <td>Created:</td>
              <td><xsl:value-of select="gsa:long-time (info/creation_time)"/></td>
            </tr>
          </xsl:if>
          <tr>
            <td>Last updated:</td>
            <td><xsl:value-of select="info/update_time"/></td>
          </tr>
        </table>
      </div>
      <table>
        <tr>
          <td width="100"><b>Name:</b></td>
          <td>
            <b>
              <xsl:value-of select="info/name"/>
            </b>
          </td>
        </tr>
        <xsl:if test="info/cpe/title">
          <tr>
            <td>Title:</td>
            <td><xsl:value-of select="info/cpe/title"/></td>
          </tr>
        </xsl:if>
        <xsl:if test="info/@id != ''">
          <tr>
            <td>NVD ID:</td>
            <td><xsl:value-of select="info/@id"/></td>
          </tr>
        </xsl:if>
        <xsl:if test="info/modification_time != ''">
          <tr>
            <td>Last modified:</td>
            <td><xsl:value-of select="gsa:long-time (info/modification_time)"/></td>
          </tr>
        </xsl:if>
        <xsl:if test="info/cpe/deprecated_by">
          <tr>
            <td>Deprecated by:</td>
            <td><xsl:value-of select="info/cpe/deprecated_by"/></td>
          </tr>
        </xsl:if>
        <xsl:if test="info/cpe/update_time">
          <tr>
            <td>Last updated:</td>
            <td><xsl:value-of select="info/cpe/update_time"/></td>
          </tr>
        </xsl:if>
        <xsl:if test="info/cpe/status != ''">
          <tr>
            <td>Status:</td>
            <td><xsl:value-of select="info/cpe/status"/></td>
          </tr>
        </xsl:if>
      </table>
      <xsl:if test="count(info/cpe/title) = 0">
        <p>
          This CPE does not appear in the CPE dictionary but is referenced by one
          or more CVE.
        </p>
      </xsl:if>
      <xsl:choose>
        <xsl:when test="count(details) = 0 or details = '0' or not(info/cpe)"/>
        <xsl:when test="count(info/cpe/cves/cve) = 0">
          <h1>Reported vulnerabilites: None</h1>
        </xsl:when>
        <xsl:otherwise>
          <h1>Reported vulnerabilites</h1>
          <table class="gbntable" cellspacing="2" cellpadding="4">
            <tr class="gbntablehead2">
              <td>Name</td>
              <td width="104">CVSS</td>
              <td>Actions</td>
            </tr>
            <xsl:for-each select="info/cpe/cves/cve">
              <xsl:variable name="class">
                <xsl:choose>
                  <xsl:when test="position() mod 2 = 0">even</xsl:when>
                  <xsl:otherwise>odd</xsl:otherwise>
                </xsl:choose>
              </xsl:variable>
              <tr class="{$class}">
                <td><xsl:value-of select="cve:entry/@id"/></td>
                <td>
                  <xsl:call-template name="severity-bar">
                    <xsl:with-param name="cvss" select="cve:entry/vuln:cvss/cvss:base_metrics/cvss:score"/>
                  </xsl:call-template>
                </td>
                <td width="100">
                  <a href="?cmd=get_info&amp;info_type=cve&amp;info_name={cve:entry/@id}&amp;details=1&amp;token={/envelope/token}" title="Details">
                    <img src="/img/details.png"
                      border="0"
                      alt="Details"
                      style="margin-left:3px;"/>
                  </a>
                </td>
              </tr>
            </xsl:for-each>
          </table>
        </xsl:otherwise>
      </xsl:choose>
    </div>
  </div>
</xsl:template>

<xsl:template match="nvt-details">
  <div class="gb_window">
    <div class="gb_window_part_left"></div>
    <div class="gb_window_part_right"></div>
    <div class="gb_window_part_center">NVT Details
      <a href="/help/nvt_details.html?token={/envelope/token}"
        title="Help: NVT Details">
        <img src="/img/help.png"/>
      </a>
    </div>
    <div class="gb_window_part_content">
      <xsl:apply-templates select="info/nvt"/>
    </div>
  </div>
</xsl:template>

<xsl:template name="ovaldef-details">
  <div class="gb_window">
    <div class="gb_window_part_left"></div>
    <div class="gb_window_part_right"></div>
    <div class="gb_window_part_center">OVAL Definition Details
      <a href="/help/ovaldef_details.html?token={/envelope/token}"
        title="Help: OVALDEF (OVAL Definition Details)">
        <img src="/img/help.png"/>
      </a>
      <a href="/omp?cmd=get_info&amp;info_type=ovaldef&amp;filter={str:encode-uri (/envelope/params/filter, true ())}&amp;token={/envelope/token}"
        title="OVAL definitions" style="margin-left:3px;">
        <img src="/img/list.png" border="0" alt="OVAL"/>
      </a>
    </div>
    <div class="gb_window_part_content">
      <div class="float_right" style="font-size: 10px;">
        <table style="font-size: 10px;">
          <tr>
            <td><b>ID:</b></td>
            <td>
              <b><xsl:value-of select="info/@id"/></b>
            </td>
          </tr>
          <tr>
            <td>Created:</td>
            <td><xsl:value-of select="info/creation_time"/></td>
          </tr>
          <tr>
            <td>Last modified:</td>
            <td><xsl:value-of select="info/modification_time"/></td>
          </tr>
        </table>
      </div>

      <xsl:choose>
        <xsl:when test="info/ovaldef">
          <table>
            <tr>
              <td><b>Name&#160;(OVAL&#160;ID):</b></td>
              <td><b><xsl:value-of select="info/ovaldef/raw_data/oval_definitions:definition/@id"/></b></td>
            </tr>
            <tr>
              <td valign="top">Title:</td>
              <td><xsl:value-of select="info/ovaldef/raw_data/oval_definitions:definition/oval_definitions:metadata/oval_definitions:title"/></td>
            </tr>
            <tr>
              <td>Version:</td>
              <td><xsl:value-of select="info/ovaldef/raw_data/oval_definitions:definition/@version"/></td>
            </tr>
            <tr>
              <td>Definition&#160;class:</td>
              <td><xsl:value-of select="info/ovaldef/raw_data/oval_definitions:definition/@class"/></td>
            </tr>
            <tr>
              <xsl:choose>
              <xsl:when test="info/ovaldef/raw_data/oval_definitions:definition/@deprecated != ''">
              <td>Deprecated:</td>
              <td><xsl:value-of select="info/ovaldef/raw_data/oval_definitions:definition/@deprecated"/></td>
              </xsl:when>
              <xsl:otherwise />
              </xsl:choose>
            </tr>
            <tr>
              <td>File:</td>
              <td><xsl:value-of select="info/ovaldef/file"/></td>
            </tr>
          </table>

          <xsl:choose>
            <xsl:when test ="count(info/ovaldef/raw_data/oval_definitions:definition/oval_definitions:metadata/oval_definitions:description) > 0">
              <h2>Description</h2>
              <xsl:value-of select="info/ovaldef/raw_data/oval_definitions:definition/oval_definitions:metadata/oval_definitions:description"/>
            </xsl:when>
            <xsl:otherwise>
              <h2>Description: None</h2>
            </xsl:otherwise>
          </xsl:choose>

          <xsl:choose>
            <xsl:when test="count(info/ovaldef/raw_data/oval_definitions:definition/oval_definitions:metadata/oval_definitions:affected) > 0">
              <h2>Affected</h2>
              <xsl:for-each select="info/ovaldef/raw_data/oval_definitions:definition/oval_definitions:metadata/oval_definitions:affected">
                <h3>
                <xsl:if test="count(.)>1"><xsl:value-of select="position()"/>) </xsl:if>Family: <xsl:value-of select="./@family"/>
                </h3>
                <table class="gbntable" cellspacing="2" cellpadding="4">
                <tr class="gbntablehead2">
                  <td>Type</td>
                  <td>Name</td>
                </tr>
                <xsl:for-each select="./*">
                <xsl:variable name="class">
                  <xsl:choose>
                    <xsl:when test="position() mod 2 = 0">even</xsl:when>
                    <xsl:otherwise>odd</xsl:otherwise>
                  </xsl:choose>
                </xsl:variable>
                <tr class="{$class}">
                  <td><xsl:value-of select="name()"/></td>
                  <td><xsl:value-of select="text()"/></td>
                </tr>
                </xsl:for-each>
                </table>
              </xsl:for-each>
            </xsl:when>
            <xsl:otherwise>
              <h2>Affected: None</h2>
            </xsl:otherwise>
          </xsl:choose>

          <xsl:choose>
            <xsl:when test="count(info/ovaldef/raw_data/oval_definitions:definition/oval_definitions:criteria) > 0">
              <h2>Criteria</h2>
              <ul>
              <xsl:apply-templates select="info/ovaldef/raw_data/oval_definitions:definition/oval_definitions:criteria"/>
              </ul>
            </xsl:when>
            <xsl:otherwise>
              <h2>Criteria: None</h2>
            </xsl:otherwise>
          </xsl:choose>

          <xsl:choose>
            <xsl:when test="count(info/ovaldef/raw_data/oval_definitions:definition/oval_definitions:metadata/oval_definitions:reference) > 0">
              <h2>References</h2>
              <table class="gbntable" cellspacing="2" cellpadding="4">
                <tr class="gbntablehead2">
                  <td>Source</td>
                  <td>Ref.ID</td>
                  <td>URL</td>
                </tr>
                <xsl:for-each select="info/ovaldef/raw_data/oval_definitions:definition/oval_definitions:metadata/oval_definitions:reference">
                  <xsl:variable name="class">
                    <xsl:choose>
                      <xsl:when test="position() mod 2 = 0">even</xsl:when>
                      <xsl:otherwise>odd</xsl:otherwise>
                    </xsl:choose>
                  </xsl:variable>
                  <tr class="{$class}">
                  <td><xsl:value-of select="./@source"/></td>
                  <td>
                  <xsl:choose>
                    <xsl:when test="translate(./@source,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz') = 'cve'">
                      <xsl:call-template name="get_info_cve_lnk">
                        <xsl:with-param name="cve" select="./@ref_id"/>
                        <xsl:with-param name="gsa_token" select="/envelope/token"/>
                      </xsl:call-template>
                    </xsl:when>
                    <xsl:when test="translate(./@source,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz') = 'cpe'">
                      <xsl:call-template name="get_info_cpe_lnk">
                        <xsl:with-param name="cpe" select="./@ref_id"/>
                        <xsl:with-param name="gsa_token" select="/envelope/token"/>
                      </xsl:call-template>
                    </xsl:when>
                    <xsl:otherwise>
                      <xsl:value-of select="./@ref_id"/>
                    </xsl:otherwise>
                  </xsl:choose></td>
                  <td><xsl:value-of select="./@ref_url"/></td>
                  </tr>
                </xsl:for-each>
              </table>
            </xsl:when>
            <xsl:otherwise>
              <h2>References: None</h2>
            </xsl:otherwise>
          </xsl:choose>

          <xsl:choose>
            <xsl:when test="count(info/ovaldef/raw_data/oval_definitions:definition/oval_definitions:metadata/oval_definitions:oval_repository) > 0">
            <h2>Repository history</h2>
            <p><b>Status: </b>
              <xsl:value-of select="info/ovaldef/raw_data/oval_definitions:definition/oval_definitions:metadata/oval_definitions:oval_repository/oval_definitions:status"/>
            </p>
            <table class="gbntable" cellspacing="2" cellpadding="4">
              <tr class="gbntablehead2">
                <td>Status</td>
                <td>Date</td>
                <td>Contributors</td>
              </tr>
              <xsl:for-each select="info/ovaldef/raw_data/oval_definitions:definition/oval_definitions:metadata/oval_definitions:oval_repository/oval_definitions:dates/*">
              <xsl:variable name="class">
                <xsl:choose>
                  <xsl:when test="position() mod 2 = 0">even</xsl:when>
                  <xsl:otherwise>odd</xsl:otherwise>
                </xsl:choose>
              </xsl:variable>
              <tr class="{$class}">
                <td><xsl:value-of select="name()"/>
                  <xsl:if test="name() = 'status_change'">
                    <i> (<xsl:value-of select="text()"/>)</i>
                  </xsl:if>
                </td>
                <td><xsl:value-of select="./@date"/></td>
                <td>
                  <xsl:for-each select="./oval_definitions:contributor">
                  <xsl:value-of select="./text()"/>
                  <i> (<xsl:value-of select="./@organization"/>)</i><br />
                  </xsl:for-each>
                </td>
              </tr>
              </xsl:for-each>
            </table>
            </xsl:when>
            <xsl:otherwise>
              <h1>Repository history: None</h1>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:when>
        <xsl:otherwise>
          <h1>OVAL definition not found</h1>
          No OVAL definition with the requested ID could be found in the SCAP database.
        </xsl:otherwise>
      </xsl:choose>
    </div>
  </div>
</xsl:template>

<xsl:template match="oval_definitions:criteria">
  <li>
    <b><xsl:if test="translate(./@negate,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz') = 'true'">NOT </xsl:if><xsl:value-of select="./@operator"/></b> <xsl:if test="./@comment != ''"><i> (<xsl:value-of select="./@comment"/>)</i></xsl:if><xsl:if test="translate(./@applicability_check,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz') = 'true'"><b> [Applicability check]</b></xsl:if>
    <ul>
      <xsl:apply-templates select="./oval_definitions:criteria | ./oval_definitions:criterion | ./oval_definitions:extend_definition"/>
    </ul>
  </li>
</xsl:template>

<xsl:template match="oval_definitions:criterion">
  <li>
    <xsl:if test="translate(./@negate,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz') = 'true'"><b>NOT </b></xsl:if><xsl:value-of select="./@comment"/> <i> (<xsl:value-of select="./@test_ref"/>)</i><xsl:if test="translate(./@applicability_check,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz') = 'true'"><b> [Applicability check]</b></xsl:if>
  </li>
</xsl:template>

<xsl:template match="oval_definitions:extend_definition">
  <li>
    <xsl:if test="translate(./@negate,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz') = 'true'"><b>NOT </b></xsl:if><xsl:value-of select="./@comment"/><i> (<a href="/omp?cmd=get_info&amp;info_type=ovaldef&amp;info_name={./@definition_ref}&amp;details=1&amp;token={/envelope/token}"><xsl:value-of select="./@definition_ref"/></a>)</i><xsl:if test="translate(./@applicability_check,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz') = 'true'"><b> [Applicability check]</b></xsl:if>
  </li>
</xsl:template>

<xsl:template name="dfn_cert_adv-details">
  <div class="gb_window">
    <div class="gb_window_part_left"></div>
    <div class="gb_window_part_right"></div>
    <div class="gb_window_part_center">DFN-CERT Advisory Details
      <a href="/help/dfn_cert_adv_details.html?token={/envelope/token}"
        title="Help: DFN_CERT_ADV (DFN-CERT Advisory Details)">
        <img src="/img/help.png"/>
      </a>
      <a href="/omp?cmd=get_info&amp;info_type=dfn_cert_adv&amp;filter={str:encode-uri (/envelope/params/filter, true ())}&amp;token={/envelope/token}"
        title="DFN-CERT Advisories" style="margin-left:3px;">
        <img src="/img/list.png" border="0" alt="OVAL"/>
      </a>
    </div>
    <div class="gb_window_part_content">
      <div class="float_right" style="font-size: 10px;">
        <table style="font-size: 10px;">
          <tr>
            <td><b>ID:</b></td>
            <td>
              <b><xsl:value-of select="info/name"/></b>
            </td>
          </tr>
          <tr>
            <td>Created:</td>
            <td><xsl:value-of select="info/creation_time"/></td>
          </tr>
          <tr>
            <td>Last modified:</td>
            <td><xsl:value-of select="info/modification_time"/></td>
          </tr>
        </table>
      </div>

      <xsl:choose>
        <xsl:when test="info/dfn_cert_adv">
          <table>
            <tr>
              <td valign="top"><b>Name:</b></td>
              <td>
                <b><xsl:value-of select="info/dfn_cert_adv/raw_data/atom:entry/dfncert:refnum"/></b>
              </td>
            </tr>
            <tr>
              <td valign="top">Title:</td>
              <td>
                <xsl:value-of select="info/dfn_cert_adv/raw_data/atom:entry/atom:title"/>
              </td>
            </tr>
            <tr>
              <td valign="top">Advisory&#160;link:</td>
              <td valign="top"><xsl:value-of select="info/dfn_cert_adv/raw_data/atom:entry/atom:link[@rel='alternate']/@href"/></td>
            </tr>
          </table>

          <xsl:choose>
            <xsl:when test="count(info/dfn_cert_adv/raw_data/atom:entry/dfncert:cve) > 0">
              <h2>Summary</h2>
              <p><xsl:value-of select="info/dfn_cert_adv/raw_data/atom:entry/atom:summary"/></p>
            </xsl:when>
            <xsl:otherwise>
              <h2>Summary: None</h2>
            </xsl:otherwise>
          </xsl:choose>

          <xsl:choose>
            <xsl:when test="count(info/dfn_cert_adv/raw_data/atom:entry/atom:link[@rel!='alternate']) > 0">
              <h2>Other links:</h2>
              <ul>
              <xsl:for-each select="info/dfn_cert_adv/raw_data/atom:entry/atom:link[@rel!='alternate']">
                <li><b><xsl:value-of select="@rel"/>: </b> <xsl:value-of select="@href"/></li>
              </xsl:for-each>
              </ul>
            </xsl:when>
            <xsl:otherwise>
              <!-- hide because the feed is not expected to contain other links -->
            </xsl:otherwise>
          </xsl:choose>

          <xsl:choose>
            <xsl:when test="count(info/dfn_cert_adv/raw_data/atom:entry/dfncert:cve) > 0">
              <h2>Referenced CVEs</h2>
              <ul>
              <xsl:for-each select="info/dfn_cert_adv/raw_data/atom:entry/dfncert:cve">
                <li>
                  <xsl:call-template name="get_info_cve_lnk">
                    <xsl:with-param name="cve" select="."/>
                    <xsl:with-param name="gsa_token" select="/envelope/token"/>
                  </xsl:call-template>
                </li>
              </xsl:for-each>
              </ul>
            </xsl:when>
            <xsl:otherwise>
            <h2>Referenced CVEs: None</h2>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:when>
        <xsl:otherwise>
          <h1>DFN-CERT Advisory not found</h1>
          No DFN-CERT advisory with the requested ID could be found in the CERT database.
        </xsl:otherwise>
      </xsl:choose>
    </div>
  </div>
</xsl:template>

<!-- BEGIN NVT DETAILS -->

<xsl:template match="nvt">
  <div class="float_right" style="font-size: 10px;">
    <table style="font-size: 10px;">
      <xsl:if test="@oid != ''">
        <tr>
          <td>ID:</td>
          <td><xsl:value-of select="@oid"/></td>
        </tr>
      </xsl:if>
      <xsl:if test="modification_time != ''">
        <tr>
          <td>Last modified:</td>
          <td><xsl:value-of select="gsa:long-time (modification_time)"/></td>
        </tr>
      </xsl:if>
      <xsl:if test="creation_time != ''">
        <tr>
          <td>Created:</td>
          <td><xsl:value-of select="gsa:long-time (creation_time)"/></td>
        </tr>
      </xsl:if>
    </table>
  </div>
  <table>
    <tr><td><b>Name:</b></td><td><b><xsl:value-of select="name"/></b></td></tr>
    <xsl:if test="summary != 'NOSUMMARY'">
      <tr><td>Summary:</td><td><xsl:value-of select="summary"/></td></tr>
    </xsl:if>
    <tr><td>Family:</td><td><xsl:value-of select="family"/></td></tr>
    <tr><td>OID:</td><td><xsl:value-of select="@oid"/></td></tr>
    <tr><td>Version:</td><td><xsl:value-of select="version"/></td></tr>
    <tr>
      <td>Notes:</td>
      <td>
        <a href="/omp?cmd=get_notes&amp;filter=nvt_id={@oid} sort=nvt&amp;filt_id={/envelope/params/filt_id}&amp;token={/envelope/token}"
           title="Notes on NVT {name}">
          <xsl:value-of select="count (../../get_notes_response/note)"/>
        </a>
      </td>
    </tr>
    <tr>
      <td>Overrides:</td>
      <td>
        <a href="/omp?cmd=get_overrides&amp;filter=nvt_id={@oid} sort=nvt&amp;filt_id={/envelope/params/filt_id}&amp;token={/envelope/token}"
           title="Overrides on NVT {name}">
          <xsl:value-of select="count (../../get_overrides_response/override)"/>
        </a>
      </td>
    </tr>
  </table>

  <xsl:choose>
    <xsl:when test="contains(tags, 'summary=')">
      <h2>Summary</h2>
      <xsl:for-each select="str:split (tags, '|')">
        <xsl:if test="'summary' = substring-before (., '=')">
          <xsl:value-of select="substring-after (., '=')"/><br />
        </xsl:if>
      </xsl:for-each>
    </xsl:when>
    <xsl:otherwise>
    </xsl:otherwise>
  </xsl:choose>

  <xsl:choose>
    <xsl:when test="contains(tags, 'affected=')">
      <h2>Affected Software/OS</h2>
      <xsl:for-each select="str:split (tags, '|')">
        <xsl:if test="'affected' = substring-before (., '=')">
          <xsl:value-of select="substring-after (., '=')"/><br />
        </xsl:if>
      </xsl:for-each>
    </xsl:when>
    <xsl:otherwise>
    </xsl:otherwise>
  </xsl:choose>

  <h2>Vulnerability Scoring</h2>
  <table>
    <tr>
      <td>CVSS base:</td>
      <td>
        <xsl:call-template name="severity-bar">
          <xsl:with-param name="cvss" select="cvss_base"/>
        </xsl:call-template>
      </td>
    </tr>
    <tr>
      <td>Risk factor:</td>
      <td><xsl:value-of select="risk_factor"/></td>
    </tr>
    <xsl:for-each select="str:split (tags, '|')">
      <xsl:if test="'cvss_base_vector' = substring-before (., '=')">
        <tr>
          <td>CVSS base vector:</td>
          <td><xsl:value-of select="substring-after (., '=')"/></td>
        </tr>
      </xsl:if>
    </xsl:for-each>
  </table>

  <xsl:choose>
    <xsl:when test="contains(tags, 'insight=')">
      <xsl:if test="not (contains(tags, 'insight=N/A'))">
        <h2>Vulnerability Insight</h2>
        <xsl:for-each select="str:split (tags, '|')">
          <xsl:if test="'insight' = substring-before (., '=')">
            <xsl:value-of select="substring-after (., '=')"/><br />
          </xsl:if>
        </xsl:for-each>
      </xsl:if>
    </xsl:when>
    <xsl:otherwise>
    </xsl:otherwise>
  </xsl:choose>

  <xsl:choose>
    <xsl:when test="contains(tags, 'vuldetect=')">
      <h2>Vulnerability Detection Method</h2>
      <xsl:for-each select="str:split (tags, '|')">
        <xsl:if test="'vuldetect' = substring-before (., '=')">
          <xsl:value-of select="substring-after (., '=')"/><br />
        </xsl:if>
      </xsl:for-each>
    </xsl:when>
    <xsl:otherwise>
    </xsl:otherwise>
  </xsl:choose>

  <xsl:choose>
    <xsl:when  test="contains(tags, 'impact=')">
      <xsl:if test="not (contains(tags, 'impact=N/A'))">
        <h2>Impact</h2>
        <xsl:for-each select="str:split (tags, '|')">
          <xsl:if test="'impact' = substring-before (., '=')">
            <xsl:value-of select="substring-after (., '=')"/><br />
          </xsl:if>
        </xsl:for-each>
      </xsl:if>
    </xsl:when>
    <xsl:otherwise>
    </xsl:otherwise>
  </xsl:choose>

  <xsl:choose>
    <xsl:when test="contains(tags, 'solution=')">
      <xsl:if test="not (contains(tags, 'solution=N/A'))">
        <h2>Solution</h2>
        <xsl:for-each select="str:split (tags, '|')">
          <xsl:if test="'solution' = substring-before (., '=')">
            <xsl:value-of select="substring-after (., '=')"/><br />
          </xsl:if>
        </xsl:for-each>
      </xsl:if>
    </xsl:when>
    <xsl:otherwise>
    </xsl:otherwise>
  </xsl:choose>

  <!-- "NOTAG" means no tags, skip. -->
  <xsl:choose>
    <xsl:when test="tags = 'NOTAG' or (contains(tags,'summary=') + contains(tags,'affected=') + contains(tags,'cvss_base_vector=') + contains(tags,'insight=') + contains(tags,'vuldetect=') + contains(tags,'impact=') + contains(tags,'solution=') = count(str:split (tags, '|')))">
    </xsl:when>
    <xsl:otherwise>
      <h2>Other tags</h2>
      <table>
      <xsl:for-each select="str:split (tags, '|')">
        <xsl:if test="not(contains('summary|cvss_base_vector|affected|insight|vuldetect|impact|solution',substring-before (., '=')))">
          <tr>
            <td valign="top"><xsl:value-of select="substring-before (., '=')"/>:</td>
            <td><xsl:value-of select="substring-after (., '=')"/></td>
          </tr>
        </xsl:if>
      </xsl:for-each>
      </table>
    </xsl:otherwise>
  </xsl:choose>

  <xsl:variable name="cve_ref">
    <xsl:if test="cve_id != '' and cve_id != 'NOCVE'">
      <xsl:value-of select="cve_id/text()"/>
    </xsl:if>
  </xsl:variable>
  <xsl:variable name="bid_ref">
    <xsl:if test="bugtraq_id != '' and bugtraq_id != 'NOBID'">
      <xsl:value-of select="bugtraq_id/text()"/>
    </xsl:if>
  </xsl:variable>
  <xsl:variable name="cert_ref" select="cert_refs"/>
  <xsl:variable name="xref">
    <xsl:if test="xrefs != '' and xrefs != 'NOXREF'">
      <xsl:value-of select="xrefs/text()"/>
    </xsl:if>
  </xsl:variable>
  <xsl:choose>
    <xsl:when test="$cve_ref != '' or $bid_ref != '' or $xref != '' or count($cert_ref/cert_ref) > 0">
      <h2>References</h2>
      <table>
        <xsl:call-template name="ref_cve_list">
          <xsl:with-param name="cvelist" select="$cve_ref"/>
        </xsl:call-template>
        <xsl:call-template name="ref_bid_list">
          <xsl:with-param name="bidlist" select="$bid_ref"/>
        </xsl:call-template>
        <xsl:call-template name="ref_cert_list">
          <xsl:with-param name="certlist" select="$cert_ref"/>
        </xsl:call-template>
        <xsl:call-template name="ref_xref_list">
          <xsl:with-param name="xreflist" select="$xref"/>
        </xsl:call-template>
      </table>
    </xsl:when>
    <xsl:otherwise>
    </xsl:otherwise>
  </xsl:choose>

  <xsl:choose>
    <xsl:when test="description != 'NODESC'">
      <h2>Description</h2>
      <pre style="white-space:pre-wrap;"><xsl:value-of select="description"/></pre>
    </xsl:when>
    <xsl:otherwise>
      <br/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template match="get_notes_response">
</xsl:template>

<xsl:template match="get_overrides_response">
</xsl:template>

<xsl:template match="get_nvts">
  <xsl:apply-templates select="gsad_msg"/>
  <xsl:apply-templates select="commands_response/delete_note_response"/>
  <xsl:apply-templates select="commands_response/delete_override_response"/>
  <xsl:apply-templates select="commands_response/modify_note_response"/>
  <xsl:apply-templates select="commands_response/modify_override_response"/>
  <div class="gb_window">
    <div class="gb_window_part_left"></div>
    <div class="gb_window_part_right"></div>
    <div class="gb_window_part_center">NVT Details
      <a href="/help/nvt_details.html?token={/envelope/token}"
         title="Help: NVT Details">
        <img src="/img/help.png"/>
      </a>
      <a href="/omp?cmd=get_info&amp;info_type=nvt&amp;filter={str:encode-uri (/envelope/params/filter, true ())}&amp;filt_id={/envelope/params/filt_id}&amp;token={/envelope/token}"
        title="NVT" style="margin-left:3px;">
        <img src="/img/list.png" border="0" alt="NVT"/>
      </a>
    </div>
    <div class="gb_window_part_content">
      <xsl:apply-templates
        select="commands_response/get_nvts_response/nvt"/>
    </div>
  </div>
</xsl:template>

<!-- END NVT DETAILS -->

<!-- BEGIN NOTES MANAGEMENT -->

<xsl:template name="html-create-note-form">
  <div class="gb_window">
    <div class="gb_window_part_left"></div>
    <div class="gb_window_part_right"></div>
    <div class="gb_window_part_center">New Note
      <a href="/help/new_note.html?token={/envelope/token}"
         title="Help: New Note">
        <img src="/img/help.png"/>
      </a>
      <a href="/omp?cmd=get_notes&amp;filter={str:encode-uri (/envelope/params/filter, true ())}&amp;filt_id={/envelope/params/filt_id}&amp;token={/envelope/token}"
         title="Notes" style="margin-left:3px;">
        <img src="/img/list.png" border="0" alt="Notes"/>
      </a>
    </div>
    <div class="gb_window_part_content">
      <form action="/omp#result-{result/@id}"
            method="post"
            enctype="multipart/form-data">
        <input type="hidden" name="token" value="{/envelope/token}"/>
        <input type="hidden" name="cmd" value="create_note"/>
        <input type="hidden" name="caller" value="{/envelope/caller}"/>
        <input type="hidden" name="next" value="{/envelope/params/next}"/>
        <input type="hidden" name="filter" value="{/envelope/params/filter}"/>
        <input type="hidden" name="filt_id" value="{/envelope/params/filt_id}"/>

        <xsl:choose>
          <xsl:when test="/envelope/params/next='get_result'">
            <!-- get_result params. -->
            <input type="hidden" name="result_id" value="{result/@id}"/>
            <input type="hidden" name="name" value="{task/name}"/>
            <input type="hidden" name="task_id" value="{task/@id}"/>
            <input type="hidden" name="overrides" value="{overrides}"/>
            <input type="hidden" name="apply_overrides" value="{/envelope/params/apply_overrides}"/>
            <input type="hidden" name="autofp" value="{/envelope/params/autofp}"/>
            <input type="hidden" name="report_result_id" value="{/envelope/params/report_result_id}"/>

            <!-- get_report passthrough params. -->
            <input type="hidden" name="report_id" value="{report/@id}"/>
            <input type="hidden" name="overrides" value="{overrides}"/>
          </xsl:when>
          <xsl:otherwise>
            <!-- get_report params. -->
            <input type="hidden" name="report_id" value="{/envelope/params/report_id}"/>
            <input type="hidden" name="overrides" value="{/envelope/params/overrides}"/>
          </xsl:otherwise>
        </xsl:choose>

        <table border="0" cellspacing="0" cellpadding="3" width="100%">
          <xsl:choose>
            <xsl:when test="result/@id">
              <input type="hidden" name="oid" value="{nvt/@id}"/>
              <tr>
                <td valign="center" width="125"><b>NVT Name</b></td>
                <td>
                  <xsl:variable name="nvt" select="get_results_response/results/result/nvt"/>
                  <xsl:variable name="max" select="70"/>
                  <xsl:choose>
                    <xsl:when test="$nvt/@oid = 0">
                      None.  Result was an open port.
                    </xsl:when>
                    <xsl:when test="string-length($nvt/name) &gt; $max">
                      <a href="?cmd=get_nvts&amp;oid={$nvt/@oid}&amp;token={/envelope/token}">
                        <abbr title="{$nvt/name} ({$nvt/@oid})"><xsl:value-of select="substring($nvt/name, 0, $max)"/>...</abbr>
                      </a>
                    </xsl:when>
                    <xsl:otherwise>
                      <a href="?cmd=get_nvts&amp;oid={$nvt/@oid}&amp;token={/envelope/token}">
                        <xsl:value-of select="$nvt/name"/>
                      </a>
                    </xsl:otherwise>
                  </xsl:choose>
                </td>
              </tr>
            </xsl:when>
            <xsl:otherwise>
              <tr>
                <td valign="center" width="125"><b>NVT OID</b></td>
                <td>
                  <input type="text" name="oid" size="30" maxlength="80" value="1.3.6.1.4.1.25623.1.0."/>
                </td>
              </tr>
            </xsl:otherwise>
          </xsl:choose>
          <tr>
            <td valign="center" width="125">
              Active
            </td>
            <td>
              <div>
                <label>
                  <input type="radio" name="active" value="-1" checked="1"/>
                  yes, always
                </label>
              </div>
              <div>
                <label>
                  <input type="radio" name="active" value="1"/>
                  yes, for the next
                </label>
                <label>
                  <input type="text" name="days" size="3" maxlength="7" value="30"/>
                  days
                </label>
              </div>
              <div>
                <label>
                  <input type="radio" name="active" value="0"/>
                  no
                </label>
              </div>
            </td>
          </tr>
          <tr>
            <td valign="top" width="125">
              Hosts
            </td>
            <td>
              <xsl:choose>
                <xsl:when test="result/@id">
                  <label>
                    <input type="radio" name="hosts" value=""/>
                    Any
                  </label>
                  <label>
                    <input type="radio" name="hosts" value="{hosts}" checked="1"/>
                    <xsl:value-of select="hosts"/>
                  </label>
                </xsl:when>
                <xsl:otherwise>
                  <label>
                    <input type="radio" name="hosts" value="" checked="1"/>
                    Any
                  </label>
                  <label>
                    <input type="radio" name="hosts" value="--"/>
                  </label>
                  <input type="text" name="hosts_manual" size="30" maxlength="80" value=""/>
                </xsl:otherwise>
              </xsl:choose>
            </td>
          </tr>
          <tr>
            <td valign="top" width="125">
              Port
            </td>
            <td>
              <xsl:choose>
                <xsl:when test="result/@id">
                  <label>
                    <input type="radio" name="port" value=""/>
                    Any
                  </label>
                  <label>
                    <input type="radio" name="port" value="{port}" checked="1"/>
                    <xsl:value-of select="port"/>
                  </label>
                </xsl:when>
                <xsl:otherwise>
                  <label>
                    <input type="radio" name="port" value="" checked="1"/>
                    Any
                  </label>
                  <label>
                    <input type="radio" name="port" value="--"/>
                  </label>
                  <input type="text" name="port_manual" size="30" maxlength="80" value=""/>
                </xsl:otherwise>
              </xsl:choose>
            </td>
          </tr>
          <tr>
            <td valign="top" width="125">
              Threat
            </td>
            <td>
              <xsl:choose>
                <xsl:when test="result/@id">
                  <label>
                    <input type="radio" name="threat" value=""/>
                    Any
                  </label>
                  <label>
                    <input type="radio" name="threat" value="{threat}" checked="1"/>
                    <xsl:value-of select="threat"/>
                  </label>
                </xsl:when>
                <xsl:otherwise>
                  <label>
                    <input type="radio" name="threat" value="" checked="1"/>
                    Any
                  </label>
                  <label>
                    <input type="radio" name="threat" value="High"/>
                    High
                  </label>
                  <label>
                    <input type="radio" name="threat" value="Medium"/>
                    Medium
                  </label>
                  <label>
                    <input type="radio" name="threat" value="Low"/>
                    Low
                  </label>
                  <label>
                    <input type="radio" name="threat" value="Log"/>
                    Log
                  </label>
                </xsl:otherwise>
              </xsl:choose>
            </td>
          </tr>
          <tr>
            <td valign="top" width="125">
              Task
            </td>
            <td>
              <xsl:choose>
                <xsl:when test="task/@id">
                  <label>
                    <input type="radio" name="note_task_id" value=""/>
                    Any
                  </label>
                  <label>
                    <input type="radio" name="note_task_id" value="{task/@id}"
                           checked="1"/>
                    <xsl:value-of select="task/name"/>
                  </label>
                </xsl:when>
                <xsl:otherwise>
                  <label>
                    <input type="radio" name="note_task_id" value="" checked="1"/>
                    Any
                  </label>
                  <label>
                    <input type="radio" name="note_task_id" value="0"/>
                  </label>
                  <select style="margin-bottom: 0px;" name="note_task_uuid">
                    <xsl:for-each select="get_tasks_response/task">
                      <option value="{@id}"><xsl:value-of select="name"/></option>
                    </xsl:for-each>
                  </select>
                </xsl:otherwise>
              </xsl:choose>
            </td>
          </tr>
          <tr>
            <td valign="top" width="125">
              Result
            </td>
            <td>
              <label>
                <input type="radio" name="note_result_id" value="" checked="1"/>
                Any
              </label>
              <xsl:choose>
                <xsl:when test="result/@id">
                  <label>
                    <input type="radio" name="note_result_id" value="{result/@id}"/>
                    Only the selected one (<xsl:value-of select="result/@id"/>)
                  </label>
                </xsl:when>
                <xsl:otherwise>
                  <label>
                    <input type="radio" name="note_result_id" value="0"/>
                    UUID
                  </label>
                  <input type="text" name="note_result_uuid" size="30" maxlength="80" value=""/>
                </xsl:otherwise>
              </xsl:choose>
            </td>
          </tr>
          <tr>
            <td valign="top" width="125">Text</td>
            <td>
              <textarea name="text" rows="10" cols="60"/>
            </td>
          </tr>
          <tr>
            <td colspan="2" style="text-align:right;">
              <input type="submit" name="submit" value="Create Note"/>
            </td>
          </tr>
        </table>
      </form>
      <xsl:choose>
        <xsl:when test="result/@id">
          <h3>
            Associated Result
          </h3>
          <xsl:for-each select="get_results_response/results/result">
            <xsl:call-template name="result-detailed">
              <xsl:with-param name="details-button">0</xsl:with-param>
              <xsl:with-param name="override-buttons">0</xsl:with-param>
              <xsl:with-param name="note-buttons">0</xsl:with-param>
            </xsl:call-template>
          </xsl:for-each>
        </xsl:when>
        <xsl:otherwise>
        </xsl:otherwise>
      </xsl:choose>
    </div>
  </div>
</xsl:template>

<xsl:template match="new_note">
  <xsl:apply-templates select="gsad_msg"/>
  <xsl:apply-templates select="create_note_response"/>
  <xsl:call-template name="html-create-note-form"/>
</xsl:template>

<xsl:template name="html-edit-note-form">
  <div class="gb_window">
    <div class="gb_window_part_left"></div>
    <div class="gb_window_part_right"></div>
    <div class="gb_window_part_center">Edit Note
      <xsl:call-template name="edit-header-icons">
        <xsl:with-param name="cap-type" select="'Note'"/>
        <xsl:with-param name="type" select="'note'"/>
        <xsl:with-param name="id"
                        select="get_notes_response/note/@id"/>
      </xsl:call-template>
    </div>
    <div class="gb_window_part_content">
      <xsl:variable name="fragment">
        <xsl:choose>
          <xsl:when test="/envelope/params/next = 'get_report'">
            <xsl:value-of select="concat ('#result-', /envelope/params/report_result_id)"/>
          </xsl:when>
        </xsl:choose>
      </xsl:variable>
      <form action="{$fragment}" method="post" enctype="multipart/form-data">
        <input type="hidden" name="token" value="{/envelope/token}"/>
        <input type="hidden" name="cmd" value="save_note"/>
        <input type="hidden" name="caller" value="{/envelope/caller}"/>
        <input type="hidden" name="note_id"
               value="{get_notes_response/note/@id}"/>
        <input type="hidden" name="filter" value="{/envelope/params/filter}"/>
        <input type="hidden" name="filt_id" value="{/envelope/params/filt_id}"/>

        <input type="hidden" name="next" value="{/envelope/params/next}"/>

        <!-- get_report params. -->
        <input type="hidden" name="report_id" value="{/envelope/params/report_id}"/>
        <input type="hidden" name="report_result_id" value="{/envelope/params/report_result_id}"/>
        <input type="hidden" name="delta_report_id" value="{/envelope/params/delta_report_id}"/>
        <input type="hidden" name="overrides" value="{/envelope/params/overrides}"/>

        <!-- get_nvts param. -->
        <input type="hidden" name="oid" value="{/envelope/params/oid}"/>

        <!-- get_tasks param. -->
        <input type="hidden" name="task_id" value="{/envelope/params/task_id}"/>

        <!-- get_result params. -->
        <input type="hidden" name="name" value="{/envelope/params/name}"/>
        <input type="hidden" name="result_id" value="{/envelope/params/result_id}"/>
        <input type="hidden" name="apply_overrides" value="{/envelope/params/apply_overrides}"/>
        <input type="hidden" name="autofp" value="{/envelope/params/autofp}"/>

        <table border="0" cellspacing="0" cellpadding="3" width="100%">
          <tr>
            <td><b>NVT Name</b></td>
            <td>
              <xsl:variable name="nvt" select="get_notes_response/note/nvt"/>
              <xsl:variable name="max" select="70"/>
              <xsl:choose>
                <xsl:when test="$nvt/@oid = 0">
                  None.  Result was an open port.
                </xsl:when>
                <xsl:when test="string-length($nvt/name) &gt; $max">
                  <a href="?cmd=get_nvts&amp;oid={$nvt/@oid}&amp;token={/envelope/token}">
                    <abbr title="{$nvt/name} ({$nvt/@oid})"><xsl:value-of select="substring($nvt/name, 0, $max)"/>...</abbr>
                  </a>
                </xsl:when>
                <xsl:otherwise>
                  <a href="?cmd=get_nvts&amp;oid={$nvt/@oid}&amp;token={/envelope/token}">
                    <xsl:value-of select="$nvt/name"/>
                  </a>
                </xsl:otherwise>
              </xsl:choose>
            </td>
          </tr>
          <tr>
            <td valign="center">Active</td>
            <td>
              <xsl:choose>
                <xsl:when test="get_notes_response/note/active='1' and string-length(get_notes_response/note/end_time) &gt; 0">
                  <div>
                    <label>
                      <input type="radio" name="active" value="-1"/>
                      yes, always
                    </label>
                  </div>
                  <div>
                    <label>
                      <input type="radio" name="active" value="-2" checked="1"/>
                      yes, until
                      <xsl:value-of select="get_notes_response/note/end_time"/>
                    </label>
                  </div>
                  <div>
                    <label>
                      <input type="radio" name="active" value="1"/>
                      yes, for the next
                    </label>
                    <label>
                      <input type="text" name="days" size="3" maxlength="7" value="30"/>
                      days
                    </label>
                  </div>
                  <div>
                    <label>
                      <input type="radio" name="active" value="0"/>
                      no
                    </label>
                  </div>
                </xsl:when>
                <xsl:when test="get_notes_response/note/active='1'">
                  <div>
                    <label>
                      <input type="radio" name="active" value="-1" checked="1"/>
                      yes, always
                    </label>
                  </div>
                  <div>
                    <label>
                      <input type="radio" name="active" value="1"/>
                      yes, for the next
                    </label>
                    <label>
                      <input type="text" name="days" size="3" maxlength="7" value="30"/>
                      days
                    </label>
                  </div>
                  <div>
                    <label>
                      <input type="radio" name="active" value="0"/>
                      no
                    </label>
                  </div>
                </xsl:when>
                <xsl:otherwise>
                  <div>
                    <label>
                      <input type="radio" name="active" value="-1"/>
                      yes, always
                    </label>
                  </div>
                  <div>
                    <label>
                      <input type="radio" name="active" value="1"/>
                      yes, for the next
                    </label>
                    <label>
                      <input type="text" name="days" size="3" maxlength="7" value="30"/>
                      days
                    </label>
                  </div>
                  <div>
                    <label>
                      <input type="radio" name="active" value="0" checked="1"/>
                      no
                    </label>
                  </div>
                </xsl:otherwise>
              </xsl:choose>
            </td>
          </tr>
          <tr>
            <td valign="top" width="125">
              Hosts
            </td>
            <td>
              <xsl:choose>
                <xsl:when test="string-length (get_notes_response/note/hosts) = 0">
                  <label>
                    <input type="radio" name="hosts" value="" checked="1"
                           readonly="1"/>
                    Any
                  </label>
                </xsl:when>
                <xsl:otherwise>
                  <label>
                    <input type="radio" name="hosts" value=""/>
                    Any
                  </label>
                  <label>
                    <input type="radio" name="hosts" value="{get_notes_response/note/hosts}"
                           checked="1"/>
                    <xsl:value-of select="get_notes_response/note/hosts"/>
                  </label>
                </xsl:otherwise>
              </xsl:choose>
            </td>
          </tr>
          <tr>
            <td valign="top" width="125">
              Port
            </td>
            <td>
              <xsl:choose>
                <xsl:when test="string-length (get_notes_response/note/port) = 0">
                  <label>
                    <input type="radio" name="port" value="" checked="1"
                           readonly="1"/>
                    Any
                  </label>
                </xsl:when>
                <xsl:otherwise>
                  <label>
                    <input type="radio" name="port" value=""/>
                    Any
                  </label>
                  <label>
                    <input type="radio" name="port" value="{get_notes_response/note/port}" checked="1"/>
                    <xsl:value-of select="get_notes_response/note/port"/>
                  </label>
                </xsl:otherwise>
              </xsl:choose>
            </td>
          </tr>
          <tr>
            <td valign="top" width="125">
              Threat
            </td>
            <td>
              <xsl:choose>
                <xsl:when test="string-length (get_notes_response/note/threat) = 0">
                  <label>
                    <input type="radio" name="threat" value="" checked="1"
                           readonly="1"/>
                    Any
                  </label>
                </xsl:when>
                <xsl:otherwise>
                  <label>
                    <input type="radio" name="threat" value=""/>
                    Any
                  </label>
                  <label>
                    <input type="radio" name="threat" value="{get_notes_response/note/threat}"
                           checked="1"/>
                    <xsl:value-of select="get_notes_response/note/threat"/>
                  </label>
                </xsl:otherwise>
              </xsl:choose>
            </td>
          </tr>
          <tr>
            <td valign="top" width="125">
              Task
            </td>
            <td>
              <xsl:choose>
                <xsl:when test="string-length (get_notes_response/note/task/@id) = 0">
                  <label>
                    <input type="radio" name="note_task_id" value="" checked="1"
                           readonly="1"/>
                    Any
                  </label>
                </xsl:when>
                <xsl:otherwise>
                  <label>
                    <input type="radio" name="note_task_id" value=""/>
                    Any
                  </label>
                  <label>
                    <input type="radio" name="note_task_id" value="{get_notes_response/note/task/@id}"
                           checked="1"/>
                    <xsl:value-of select="get_notes_response/note/task/name"/>
                  </label>
                </xsl:otherwise>
              </xsl:choose>
            </td>
          </tr>
          <tr>
            <td valign="top" width="125">
              Result
            </td>
            <td>
              <xsl:choose>
                <xsl:when test="string-length (get_notes_response/note/result/@id) = 0">
                  <label>
                    <input type="radio" name="note_result_id" value="" checked="1"
                           readonly="1"/>
                    Any
                  </label>
                </xsl:when>
                <xsl:otherwise>
                  <label>
                    <input type="radio" name="note_result_id" value=""/>
                    Any
                  </label>
                  <label>
                    <input type="radio" name="note_result_id"
                           value="{get_notes_response/note/result/@id}" checked="1"/>
                    <xsl:value-of select="get_notes_response/note/result/@id"/>
                  </label>
                </xsl:otherwise>
              </xsl:choose>
            </td>
          </tr>
          <tr>
            <td valign="top" width="125">Text</td>
            <td>
              <textarea name="text" rows="10" cols="60"><xsl:value-of select="get_notes_response/note/text"/></textarea>
            </td>
          </tr>
          <tr>
            <td colspan="2" style="text-align:right;">
              <input type="submit" name="submit" value="Save Note"/>
            </td>
          </tr>
        </table>
      </form>
      <xsl:choose>
        <xsl:when test="string-length(get_notes_response/note/result/@id) = 0">
          <h3>Associated Result: Any</h3>
        </xsl:when>
        <xsl:otherwise>
          <h3>
            Associated Result
          </h3>
          <xsl:for-each select="get_notes_response/note/result">
            <xsl:call-template name="result-detailed">
              <xsl:with-param name="details-button">0</xsl:with-param>
              <xsl:with-param name="note-buttons">0</xsl:with-param>
              <xsl:with-param name="override-buttons">0</xsl:with-param>
            </xsl:call-template>
          </xsl:for-each>
        </xsl:otherwise>
      </xsl:choose>
    </div>
  </div>
</xsl:template>

<xsl:template match="edit_note">
  <xsl:apply-templates select="gsad_msg"/>
  <xsl:call-template name="html-edit-note-form"/>
</xsl:template>

<xsl:template match="modify_note_response">
  <xsl:call-template name="command_result_dialog">
    <xsl:with-param name="operation">Save Note</xsl:with-param>
    <xsl:with-param name="status">
      <xsl:value-of select="@status"/>
    </xsl:with-param>
    <xsl:with-param name="msg">
      <xsl:value-of select="@status_text"/>
    </xsl:with-param>
  </xsl:call-template>
</xsl:template>

<xsl:template name="note" match="note">
  <xsl:param name="next">get_notes</xsl:param>
  <xsl:param name="params"/>
  <xsl:param name="params-get"/>
  <xsl:variable name="class">
    <xsl:choose>
      <xsl:when test="position() mod 2 = 0">even</xsl:when>
      <xsl:otherwise>odd</xsl:otherwise>
    </xsl:choose>
  </xsl:variable>
  <tr class="{$class}">
    <td>
      <xsl:variable name="max" select="70"/>
      <xsl:choose>
        <xsl:when test="nvt/@oid = 0">
          <abbr title="Result was an open port.">None</abbr>
        </xsl:when>
        <xsl:when test="string-length(nvt/name) &gt; $max">
          <abbr title="{nvt/name} ({nvt/@oid})"><xsl:value-of select="substring(nvt/name, 0, $max)"/>...</abbr>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="nvt/name"/>
        </xsl:otherwise>
      </xsl:choose>
    </td>
    <td>
      <xsl:if test="orphan = 1"><b>Orphan</b><br/></xsl:if>
      <xsl:choose>
        <xsl:when test="text/@excerpt = 1">
          <xsl:value-of select="text/text()"/>...
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="text/text()"/>
        </xsl:otherwise>
      </xsl:choose>
    </td>
    <td>
      <xsl:choose>
        <xsl:when test="active='0'">
          no
        </xsl:when>
        <xsl:otherwise>
          yes
        </xsl:otherwise>
      </xsl:choose>
    </td>
    <td>
      <xsl:call-template name="list-window-line-icons">
        <xsl:with-param name="cap-type" select="'Note'"/>
        <xsl:with-param name="type" select="'note'"/>
        <xsl:with-param name="id" select="@id"/>
        <xsl:with-param name="params" select="$params-get"/>
        <xsl:with-param name="next" select="$next"/>
      </xsl:call-template>
    </td>
  </tr>
</xsl:template>

<xsl:template match="note" mode="trash">
  <xsl:param name="next">get_notes</xsl:param>
  <xsl:param name="params"/>
  <xsl:param name="params-get"/>
  <xsl:variable name="class">
    <xsl:choose>
      <xsl:when test="position() mod 2 = 0">even</xsl:when>
      <xsl:otherwise>odd</xsl:otherwise>
    </xsl:choose>
  </xsl:variable>
  <tr class="{$class}">
    <td>
      <xsl:variable name="max" select="70"/>
      <xsl:choose>
        <xsl:when test="nvt/@oid = 0">
          <abbr title="Result was an open port.">None</abbr>
        </xsl:when>
        <xsl:when test="string-length(nvt/name) &gt; $max">
          <abbr title="{nvt/name} ({nvt/@oid})"><xsl:value-of select="substring(nvt/name, 0, $max)"/>...</abbr>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="nvt/name"/>
        </xsl:otherwise>
      </xsl:choose>
    </td>
    <td>
      <xsl:if test="orphan = 1"><b>Orphan</b><br/></xsl:if>
      <xsl:choose>
        <xsl:when test="text/@excerpt = 1">
          <xsl:value-of select="text/text()"/>...
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="text/text()"/>
        </xsl:otherwise>
      </xsl:choose>
    </td>
    <td>
      <xsl:call-template name="restore-icon">
        <xsl:with-param name="id" select="@id"/>
      </xsl:call-template>
      <xsl:call-template name="trash-delete-icon">
        <xsl:with-param name="type" select="'note'"/>
        <xsl:with-param name="id" select="@id"/>
      </xsl:call-template>
    </td>
  </tr>
</xsl:template>

<xsl:template match="note" mode="details">
  <div class="gb_window">
    <div class="gb_window_part_left"></div>
    <div class="gb_window_part_right"></div>
    <div class="gb_window_part_center">
      Note Details
      <xsl:call-template name="details-header-icons">
        <xsl:with-param name="cap-type" select="'Note'"/>
        <xsl:with-param name="type" select="'note'"/>
      </xsl:call-template>
    </div>
    <div class="gb_window_part_content">
      <xsl:call-template name="minor-details"/>
      <table>
        <tr>
          <td><b>NVT Name:</b></td>
          <td>
            <xsl:variable name="max" select="70"/>
            <xsl:choose>
              <xsl:when test="nvt/@oid = 0">
                None.  Result was an open port.
              </xsl:when>
              <xsl:when test="string-length(nvt/name) &gt; $max">
                <a href="?cmd=get_nvts&amp;oid={nvt/@oid}&amp;token={/envelope/token}">
                  <abbr title="{nvt/name} ({nvt/@oid})"><xsl:value-of select="substring(nvt/name, 0, $max)"/>...</abbr>
                </a>
              </xsl:when>
              <xsl:otherwise>
                <a href="?cmd=get_nvts&amp;oid={nvt/@oid}&amp;token={/envelope/token}">
                  <xsl:value-of select="nvt/name"/>
                </a>
              </xsl:otherwise>
            </xsl:choose>
          </td>
        </tr>
        <tr>
          <td>NVT OID:</td>
          <td>
            <xsl:choose>
              <xsl:when test="nvt/@oid = 0"></xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="nvt/@oid"/>
              </xsl:otherwise>
            </xsl:choose>
          </td>
        </tr>
        <tr>
          <td>Active:</td>
          <td>
            <xsl:choose>
              <xsl:when test="active='0'">
                no
              </xsl:when>
              <xsl:when test="active='1' and string-length (end_time) &gt; 0">
                yes, until
                <xsl:value-of select="gsa:long-time (end_time)"/>
              </xsl:when>
              <xsl:otherwise>
                yes
              </xsl:otherwise>
            </xsl:choose>
          </td>
        </tr>
      </table>

      <h1>Application</h1>
      <table>
        <tr>
          <td>Hosts:</td>
          <td>
            <xsl:choose>
              <xsl:when test="string-length(hosts) &gt; 0">
                <xsl:value-of select="hosts"/>
              </xsl:when>
              <xsl:otherwise>
                Any
              </xsl:otherwise>
            </xsl:choose>
          </td>
        </tr>
        <tr>
          <td>Port:</td>
          <td>
            <xsl:choose>
              <xsl:when test="string-length(port) &gt; 0">
                <xsl:value-of select="port"/>
              </xsl:when>
              <xsl:otherwise>
                Any
              </xsl:otherwise>
            </xsl:choose>
          </td>
        </tr>
        <tr>
          <td>Threat:</td>
          <td>
            <xsl:choose>
              <xsl:when test="string-length(threat) &gt; 0">
                <xsl:value-of select="threat"/>
              </xsl:when>
              <xsl:otherwise>
                Any
              </xsl:otherwise>
            </xsl:choose>
          </td>
        </tr>
        <tr>
          <td>Task:</td>
          <td>
            <xsl:choose>
              <xsl:when test="orphan != 0">
                <b>Orphan</b>
              </xsl:when>
              <xsl:when test="task and string-length(task/@id) &gt; 0">
                <xsl:choose>
                  <xsl:when test="task/trash = '1'">
                    <xsl:value-of select="task/name"/> (in <a href="/omp?cmd=get_trash&amp;token={/envelope/token}">trashcan</a>)
                  </xsl:when>
                  <xsl:otherwise>
                    <a href="?cmd=get_task&amp;task_id={task/@id}&amp;token={/envelope/token}">
                      <xsl:value-of select="task/name"/>
                    </a>
                  </xsl:otherwise>
                </xsl:choose>
              </xsl:when>
              <xsl:otherwise>
                Any
              </xsl:otherwise>
            </xsl:choose>
          </td>
        </tr>
        <tr>
          <td>Result:</td>
          <td>
            <xsl:choose>
              <xsl:when test="orphan != 0">
                <b>Orphan</b>
              </xsl:when>
              <xsl:when test="string-length(result/@id) &gt; 0">
                <xsl:value-of select="result/@id"/>
              </xsl:when>
              <xsl:otherwise>
                Any
              </xsl:otherwise>
            </xsl:choose>
          </td>
        </tr>
      </table>

      <xsl:choose>
        <xsl:when test="active = '0'">
          <h1>Appearance when Active</h1>
        </xsl:when>
        <xsl:otherwise>
          <h1>Appearance</h1>
        </xsl:otherwise>
      </xsl:choose>
      <div class="note_top_line"></div>
      <xsl:call-template name="note-detailed">
        <xsl:with-param name="note-buttons">0</xsl:with-param>
      </xsl:call-template>
    </div>
  </div>
</xsl:template>

<xsl:template name="html-notes-table">
  <xsl:call-template name="list-window">
    <xsl:with-param name="type" select="'note'"/>
    <xsl:with-param name="cap-type" select="'Note'"/>
    <xsl:with-param name="resources-summary" select="notes"/>
    <xsl:with-param name="resources" select="note"/>
    <xsl:with-param name="count" select="count (note)"/>
    <xsl:with-param name="filtered-count" select="note_count/filtered"/>
    <xsl:with-param name="full-count" select="note_count/text ()"/>
    <xsl:with-param name="headings" select="'NVT|nvt Text|text Active|active'"/>
  </xsl:call-template>
</xsl:template>

<xsl:template name="html-notes-trash-table">
  <div id="tasks">
    <table class="gbntable" cellspacing="2" cellpadding="4" border="0">
      <tr class="gbntablehead2">
        <td>NVT</td>
        <td>Text</td>
        <td width="100">Actions</td>
      </tr>
      <xsl:apply-templates select="note" mode="trash"/>
    </table>
  </div>
</xsl:template>

<xsl:template match="get_note">
  <xsl:apply-templates select="gsad_msg"/>
  <xsl:apply-templates select="commands_response/modify_note_response"/>
  <xsl:choose>
    <xsl:when test="commands_reponse/get_notes_response/@status = '500'">
      <xsl:call-template name="command_result_dialog">
        <xsl:with-param name="operation">
          Get Note
        </xsl:with-param>
        <xsl:with-param name="status">
          <xsl:value-of select="500"/>
        </xsl:with-param>
        <xsl:with-param name="msg">
          <xsl:value-of select="commands_response/get_notes_response/@status_text"/>
        </xsl:with-param>
      </xsl:call-template>
    </xsl:when>
    <xsl:otherwise>
      <xsl:apply-templates select="commands_response/get_notes_response/note" mode="details"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template match="get_notes">
  <xsl:apply-templates select="gsad_msg"/>
  <xsl:apply-templates select="delete_note_response"/>
  <xsl:apply-templates select="create_filter_response"/>
  <xsl:apply-templates select="create_note_response"/>
  <!-- The for-each makes the get_notes_response the current node. -->
  <xsl:for-each select="get_notes_response | commands_response/get_notes_response">
    <xsl:call-template name="html-notes-table"/>
  </xsl:for-each>
</xsl:template>

<!-- END NOTES MANAGEMENT -->

<!-- BEGIN OVERRIDES MANAGEMENT -->

<xsl:template name="html-create-override-form">
  <div class="gb_window">
    <div class="gb_window_part_left"></div>
    <div class="gb_window_part_right"></div>
    <div class="gb_window_part_center">New Override
      <a href="/help/new_override.html?token={/envelope/token}"
         title="Help: New Override">
        <img src="/img/help.png"/>
      </a>
      <a href="/omp?cmd=get_overrides&amp;filter={str:encode-uri (/envelope/params/filter, true ())}&amp;filt_id={/envelope/params/filt_id}&amp;token={/envelope/token}"
         title="Overrides" style="margin-left:3px;">
        <img src="/img/list.png" border="0" alt="Overrides"/>
      </a>
    </div>
    <div class="gb_window_part_content">
      <form action="/omp#result-{result/@id}"
            method="post"
            enctype="multipart/form-data">
        <input type="hidden" name="token" value="{/envelope/token}"/>
        <input type="hidden" name="cmd" value="create_override"/>
        <input type="hidden" name="caller" value="{/envelope/caller}"/>
        <input type="hidden" name="next" value="{/envelope/params/next}"/>
        <input type="hidden" name="filter" value="{/envelope/params/filter}"/>
        <input type="hidden" name="filt_id" value="{/envelope/params/filt_id}"/>

        <xsl:choose>
          <xsl:when test="/envelope/params/next='get_result'">
            <!-- get_result params. -->
            <input type="hidden" name="result_id" value="{result/@id}"/>
            <input type="hidden" name="name" value="{task/name}"/>
            <input type="hidden" name="task_id" value="{task/@id}"/>
            <input type="hidden" name="overrides" value="{overrides}"/>
            <input type="hidden" name="apply_overrides" value="{/envelope/params/apply_overrides}"/>
            <input type="hidden" name="autofp" value="{/envelope/params/autofp}"/>
            <input type="hidden" name="report_result_id" value="{/envelope/params/report_result_id}"/>

            <!-- get_report passthrough params. -->
            <input type="hidden" name="report_id" value="{report/@id}"/>
            <input type="hidden" name="overrides" value="{overrides}"/>
          </xsl:when>
          <xsl:otherwise>
            <!-- get_report params. -->
            <input type="hidden" name="report_id" value="{/envelope/params/report_id}"/>
            <input type="hidden" name="overrides" value="{/envelope/params/overrides}"/>
          </xsl:otherwise>
        </xsl:choose>

        <table border="0" cellspacing="0" cellpadding="3" width="100%">
          <xsl:choose>
            <xsl:when test="result/@id">
              <input type="hidden" name="oid" value="{nvt/@id}"/>
              <tr>
                <td valign="center" width="125"><b>NVT Name</b></td>
                <td>
                  <xsl:variable name="nvt" select="get_results_response/results/result/nvt"/>
                  <xsl:variable name="max" select="70"/>
                  <xsl:choose>
                    <xsl:when test="$nvt/@oid = 0">
                      None.  Result was an open port.
                    </xsl:when>
                    <xsl:when test="string-length($nvt/name) &gt; $max">
                      <a href="?cmd=get_nvts&amp;oid={$nvt/@oid}&amp;token={/envelope/token}">
                        <abbr title="{$nvt/name} ({$nvt/@oid})"><xsl:value-of select="substring($nvt/name, 0, $max)"/>...</abbr>
                      </a>
                    </xsl:when>
                    <xsl:otherwise>
                      <a href="?cmd=get_nvts&amp;oid={$nvt/@oid}&amp;token={/envelope/token}">
                        <xsl:value-of select="$nvt/name"/>
                      </a>
                    </xsl:otherwise>
                  </xsl:choose>
                </td>
              </tr>
            </xsl:when>
            <xsl:otherwise>
              <tr>
                <td valign="center" width="125"><b>NVT OID</b></td>
                <td>
                  <input type="text" name="oid" size="30" maxlength="80" value="1.3.6.1.4.1.25623.1.0."/>
                </td>
              </tr>
            </xsl:otherwise>
          </xsl:choose>
          <tr>
            <td valign="center" width="125">
              Active
            </td>
            <td>
              <div>
                <label>
                  <input type="radio" name="active" value="-1" checked="1"/>
                  yes, always
                </label>
              </div>
              <div>
                <label>
                  <input type="radio" name="active" value="1"/>
                  yes, for the next
                </label>
                <label>
                  <input type="text" name="days" size="3" maxlength="7" value="30"/>
                  days
                </label>
              </div>
              <div>
                <label>
                  <input type="radio" name="active" value="0"/>
                  no
                </label>
              </div>
            </td>
          </tr>
          <tr>
            <td valign="top" width="125">
              Hosts
            </td>
            <td>
              <xsl:choose>
                <xsl:when test="result/@id">
                  <label>
                    <input type="radio" name="hosts" value=""/>
                    Any
                  </label>
                  <label>
                    <input type="radio" name="hosts" value="{hosts}" checked="1"/>
                    <xsl:value-of select="hosts"/>
                  </label>
                </xsl:when>
                <xsl:otherwise>
                  <label>
                    <input type="radio" name="hosts" value="" checked="1"/>
                    Any
                  </label>
                  <label>
                    <input type="radio" name="hosts" value="--"/>
                  </label>
                  <input type="text" name="hosts_manual" size="30" maxlength="80" value=""/>
                </xsl:otherwise>
              </xsl:choose>
            </td>
          </tr>
          <tr>
            <td valign="top" width="125">
              Port
            </td>
            <td>
              <xsl:choose>
                <xsl:when test="result/@id">
                  <label>
                    <input type="radio" name="port" value=""/>
                    Any
                  </label>
                  <label>
                    <input type="radio" name="port" value="{port}" checked="1"/>
                    <xsl:value-of select="port"/>
                  </label>
                </xsl:when>
                <xsl:otherwise>
                  <label>
                    <input type="radio" name="port" value="" checked="1"/>
                    Any
                  </label>
                  <label>
                    <input type="radio" name="port" value="--"/>
                  </label>
                  <input type="text" name="port_manual" size="30" maxlength="80" value=""/>
                </xsl:otherwise>
              </xsl:choose>
            </td>
          </tr>
          <tr>
            <td valign="top" width="125">
              Threat
            </td>
            <td>
              <xsl:choose>
                <xsl:when test="result/@id">
                  <label>
                    <input type="radio" name="threat" value=""/>
                    Any
                  </label>
                  <label>
                    <input type="radio" name="threat" value="{threat}" checked="1"/>
                    <xsl:value-of select="threat"/>
                  </label>
                </xsl:when>
                <xsl:otherwise>
                  <label>
                    <input type="radio" name="threat" value="" checked="1"/>
                    Any
                  </label>
                  <label>
                    <input type="radio" name="threat" value="High"/>
                    High
                  </label>
                  <label>
                    <input type="radio" name="threat" value="Medium"/>
                    Medium
                  </label>
                  <label>
                    <input type="radio" name="threat" value="Low"/>
                    Low
                  </label>
                  <label>
                    <input type="radio" name="threat" value="Log"/>
                    Log
                  </label>
                </xsl:otherwise>
              </xsl:choose>
            </td>
          </tr>
          <tr>
            <td valign="top" width="125">
              <b>New Threat</b>
            </td>
            <td>
              <select name="new_threat">
                <option value="High">High</option>
                <option value="Medium">Medium</option>
                <option value="Low">Low</option>
                <option value="Log">Log</option>
                <option value="False Positive" selected="1">False Positive</option>
              </select>
            </td>
          </tr>
          <tr>
            <td valign="top" width="125">
              Task
            </td>
            <td>
              <xsl:choose>
                <xsl:when test="task/@id">
                  <label>
                    <input type="radio" name="override_task_id" value=""/>
                    Any
                  </label>
                  <label>
                    <input type="radio" name="override_task_id" value="{task/@id}"
                           checked="1"/>
                    <xsl:value-of select="task/name"/>
                  </label>
                </xsl:when>
                <xsl:otherwise>
                  <label>
                    <input type="radio" name="override_task_id" value="" checked="1"/>
                    Any
                  </label>
                  <label>
                    <input type="radio" name="override_task_id" value="0"/>
                  </label>
                  <select style="margin-bottom: 0px;" name="override_task_uuid">
                    <xsl:for-each select="get_tasks_response/task">
                      <option value="{@id}"><xsl:value-of select="name"/></option>
                    </xsl:for-each>
                  </select>
                </xsl:otherwise>
              </xsl:choose>
            </td>
          </tr>
          <tr>
            <td valign="top" width="125">
              Result
            </td>
            <td>
              <label>
                <input type="radio" name="override_result_id" value="" checked="1"/>
                Any
              </label>
              <xsl:choose>
                <xsl:when test="result/@id">
                  <label>
                    <input type="radio" name="override_result_id" value="{result/@id}"/>
                    Only the selected one (<xsl:value-of select="result/@id"/>)
                  </label>
                </xsl:when>
                <xsl:otherwise>
                  <label>
                    <input type="radio" name="override_result_id" value="0"/>
                    UUID
                  </label>
                  <input type="text" name="override_result_uuid" size="30" maxlength="80" value=""/>
                </xsl:otherwise>
              </xsl:choose>
            </td>
          </tr>
          <tr>
            <td valign="top" width="125">Text</td>
            <td>
              <textarea name="text" rows="10" cols="60"/>
            </td>
          </tr>
          <tr>
            <td colspan="2" style="text-align:right;">
              <input type="submit" name="submit" value="Create Override"/>
            </td>
          </tr>
        </table>
      </form>
      <xsl:choose>
        <xsl:when test="result/@id">
          <h3>
            Associated Result
          </h3>
          <xsl:for-each select="get_results_response/results/result">
            <xsl:call-template name="result-detailed">
              <xsl:with-param name="details-button">0</xsl:with-param>
              <xsl:with-param name="override-buttons">0</xsl:with-param>
              <xsl:with-param name="override-buttons">0</xsl:with-param>
            </xsl:call-template>
          </xsl:for-each>
        </xsl:when>
        <xsl:otherwise>
        </xsl:otherwise>
      </xsl:choose>
    </div>
  </div>
</xsl:template>

<xsl:template match="new_override">
  <xsl:apply-templates select="gsad_msg"/>
  <xsl:apply-templates select="create_override_response"/>
  <xsl:call-template name="html-create-override-form"/>
</xsl:template>

<xsl:template name="html-edit-override-form">
  <div class="gb_window">
    <div class="gb_window_part_left"></div>
    <div class="gb_window_part_right"></div>
    <div class="gb_window_part_center">Edit Override
      <xsl:call-template name="edit-header-icons">
        <xsl:with-param name="cap-type" select="'Override'"/>
        <xsl:with-param name="type" select="'override'"/>
        <xsl:with-param name="id"
                        select="get_overrides_response/override/@id"/>
      </xsl:call-template>
    </div>
    <div class="gb_window_part_content">
      <xsl:variable name="fragment">
        <xsl:choose>
          <xsl:when test="/envelope/params/next = 'get_report'">
            <xsl:value-of select="concat ('#result-', /envelope/params/report_result_id)"/>
          </xsl:when>
        </xsl:choose>
      </xsl:variable>
      <form action="{$fragment}" method="post" enctype="multipart/form-data">
        <input type="hidden" name="token" value="{/envelope/token}"/>
        <input type="hidden" name="cmd" value="save_override"/>
        <input type="hidden" name="caller" value="{/envelope/caller}"/>
        <input type="hidden" name="override_id"
               value="{get_overrides_response/override/@id}"/>
        <input type="hidden" name="filter" value="{/envelope/params/filter}"/>
        <input type="hidden" name="filt_id" value="{/envelope/params/filt_id}"/>

        <input type="hidden" name="next" value="{/envelope/params/next}"/>

        <!-- get_report params. -->
        <input type="hidden" name="report_id" value="{/envelope/params/report_id}"/>
        <input type="hidden" name="report_result_id" value="{/envelope/params/report_result_id}"/>
        <input type="hidden" name="delta_report_id" value="{/envelope/params/delta_report_id}"/>
        <input type="hidden" name="overrides" value="{/envelope/params/overrides}"/>

        <!-- get_nvts param. -->
        <input type="hidden" name="oid" value="{/envelope/params/oid}"/>

        <!-- get_tasks param. -->
        <input type="hidden" name="task_id" value="{/envelope/params/task_id}"/>

        <!-- get_result params. -->
        <input type="hidden" name="name" value="{/envelope/params/name}"/>
        <input type="hidden" name="result_id" value="{/envelope/params/result_id}"/>
        <input type="hidden" name="apply_overrides" value="{/envelope/params/apply_overrides}"/>
        <input type="hidden" name="autofp" value="{/envelope/params/autofp}"/>

        <table border="0" cellspacing="0" cellpadding="3" width="100%">
          <tr>
            <td><b>NVT Name</b></td>
            <td>
              <xsl:variable name="nvt" select="get_overrides_response/override/nvt"/>
              <xsl:variable name="max" select="70"/>
              <xsl:choose>
                <xsl:when test="$nvt/@oid = 0">
                  None.  Result was an open port.
                </xsl:when>
                <xsl:when test="string-length($nvt/name) &gt; $max">
                  <a href="?cmd=get_nvts&amp;oid={$nvt/@oid}&amp;token={/envelope/token}">
                    <abbr title="{$nvt/name} ({$nvt/@oid})"><xsl:value-of select="substring($nvt/name, 0, $max)"/>...</abbr>
                  </a>
                </xsl:when>
                <xsl:otherwise>
                  <a href="?cmd=get_nvts&amp;oid={$nvt/@oid}&amp;token={/envelope/token}">
                    <xsl:value-of select="$nvt/name"/>
                  </a>
                </xsl:otherwise>
              </xsl:choose>
            </td>
          </tr>
          <tr>
            <td valign="center">Active</td>
            <td>
              <xsl:choose>
                <xsl:when test="get_overrides_response/override/active='1' and string-length(get_overrides_response/override/end_time) &gt; 0">
                  <div>
                    <label>
                      <input type="radio" name="active" value="-1"/>
                      yes, always
                    </label>
                  </div>
                  <div>
                    <label>
                      <input type="radio" name="active" value="-2" checked="1"/>
                      yes, until
                      <xsl:value-of select="get_overrides_response/override/end_time"/>
                    </label>
                  </div>
                  <div>
                    <label>
                      <input type="radio" name="active" value="1"/>
                      yes, for the next
                    </label>
                    <input type="text" name="days" size="3" maxlength="7" value="30"/>
                    days
                  </div>
                  <div>
                    <label>
                      <input type="radio" name="active" value="0"/>
                      no
                    </label>
                  </div>
                </xsl:when>
                <xsl:when test="get_overrides_response/override/active='1'">
                  <div>
                    <label>
                      <input type="radio" name="active" value="-1" checked="1"/>
                      yes, always
                    </label>
                  </div>
                  <div>
                    <label>
                      <input type="radio" name="active" value="1"/>
                      yes, for the next
                    </label>
                    <input type="text" name="days" size="3" maxlength="7" value="30"/>
                    days
                  </div>
                  <div>
                    <label>
                      <input type="radio" name="active" value="0"/>
                      no
                    </label>
                  </div>
                </xsl:when>
                <xsl:otherwise>
                  <div>
                    <label>
                      <input type="radio" name="active" value="-1"/>
                      yes, always
                    </label>
                  </div>
                  <div>
                    <label>
                      <input type="radio" name="active" value="1"/>
                      yes, for the next
                    </label>
                    <input type="text" name="days" size="3" maxlength="7" value="30"/>
                    days
                  </div>
                  <div>
                    <label>
                      <input type="radio" name="active" value="0" checked="1"/>
                      no
                    </label>
                  </div>
                </xsl:otherwise>
              </xsl:choose>
            </td>
          </tr>
          <tr>
            <td valign="top" width="125">
              Hosts
            </td>
            <td>
              <xsl:choose>
                <xsl:when test="string-length (get_overrides_response/override/hosts) = 0">
                  <label>
                    <input type="radio" name="hosts" value="" checked="1"
                           readonly="1"/>
                    Any
                  </label>
                </xsl:when>
                <xsl:otherwise>
                  <label>
                    <input type="radio" name="hosts" value=""/>
                    Any
                  </label>
                  <label>
                    <input type="radio" name="hosts" value="{get_overrides_response/override/hosts}"
                           checked="1"/>
                    <xsl:value-of select="get_overrides_response/override/hosts"/>
                  </label>
                </xsl:otherwise>
              </xsl:choose>
            </td>
          </tr>
          <tr>
            <td valign="top" width="125">
              Port
            </td>
            <td>
              <xsl:choose>
                <xsl:when test="string-length (get_overrides_response/override/port) = 0">
                  <label>
                    <input type="radio" name="port" value="" checked="1"
                           readonly="1"/>
                    Any
                  </label>
                </xsl:when>
                <xsl:otherwise>
                  <label>
                    <input type="radio" name="port" value=""/>
                    Any
                  </label>
                  <label>
                    <input type="radio" name="port" value="{get_overrides_response/override/port}" checked="1"/>
                    <xsl:value-of select="get_overrides_response/override/port"/>
                  </label>
                </xsl:otherwise>
              </xsl:choose>
            </td>
          </tr>
          <tr>
            <td valign="top" width="125">
              Threat
            </td>
            <td>
              <xsl:choose>
                <xsl:when test="string-length (get_overrides_response/override/threat) = 0">
                  <label>
                    <input type="radio" name="threat" value="" checked="1"
                           readonly="1"/>
                    Any
                  </label>
                </xsl:when>
                <xsl:otherwise>
                  <label>
                    <input type="radio" name="threat" value=""/>
                    Any
                  </label>
                  <label>
                    <input type="radio" name="threat" value="{get_overrides_response/override/threat}"
                           checked="1"/>
                    <xsl:value-of select="get_overrides_response/override/threat"/>
                  </label>
                </xsl:otherwise>
              </xsl:choose>
            </td>
          </tr>
          <tr>
            <td valign="top" width="125">
              <b>New Threat</b>
            </td>
            <td>
              <select name="new_threat">
                <xsl:call-template name="opt">
                  <xsl:with-param name="value" select="'High'"/>
                  <xsl:with-param
                    name="select-value"
                    select="get_overrides_response/override/new_threat"/>
                </xsl:call-template>
                <xsl:call-template name="opt">
                  <xsl:with-param name="value" select="'Medium'"/>
                  <xsl:with-param
                    name="select-value"
                    select="get_overrides_response/override/new_threat"/>
                </xsl:call-template>
                <xsl:call-template name="opt">
                  <xsl:with-param name="value" select="'Low'"/>
                  <xsl:with-param
                    name="select-value"
                    select="get_overrides_response/override/new_threat"/>
                </xsl:call-template>
                <xsl:call-template name="opt">
                  <xsl:with-param name="value" select="'Log'"/>
                  <xsl:with-param
                    name="select-value"
                    select="get_overrides_response/override/new_threat"/>
                </xsl:call-template>
                <xsl:call-template name="opt">
                  <xsl:with-param name="value" select="'False Positive'"/>
                  <xsl:with-param
                    name="select-value"
                    select="get_overrides_response/override/new_threat"/>
                </xsl:call-template>
              </select>
            </td>
          </tr>
          <tr>
            <td valign="top" width="125">
              Task
            </td>
            <td>
              <xsl:choose>
                <xsl:when test="string-length (get_overrides_response/override/task/@id) = 0">
                  <label>
                    <input type="radio" name="override_task_id" value="" checked="1"
                           readonly="1"/>
                    Any
                  </label>
                </xsl:when>
                <xsl:otherwise>
                  <label>
                    <input type="radio" name="override_task_id" value=""/>
                    Any
                  </label>
                  <label>
                    <input type="radio" name="override_task_id" value="{get_overrides_response/override/task/@id}"
                           checked="1"/>
                    <xsl:value-of select="get_overrides_response/override/task/name"/>
                  </label>
                </xsl:otherwise>
              </xsl:choose>
            </td>
          </tr>
          <tr>
            <td valign="top" width="125">
              Result
            </td>
            <td>
              <xsl:choose>
                <xsl:when test="string-length (get_overrides_response/override/result/@id) = 0">
                  <label>
                    <input type="radio" name="override_result_id" value="" checked="1"
                           readonly="1"/>
                    Any
                  </label>
                </xsl:when>
                <xsl:otherwise>
                  <label>
                    <input type="radio" name="override_result_id" value=""/>
                    Any
                  </label>
                  <label>
                    <input type="radio" name="override_result_id"
                           value="{get_overrides_response/override/result/@id}" checked="1"/>
                    <xsl:value-of select="get_overrides_response/override/result/@id"/>
                  </label>
                </xsl:otherwise>
              </xsl:choose>
            </td>
          </tr>
          <tr>
            <td valign="top" width="125">Text</td>
            <td>
              <textarea name="text" rows="10" cols="60"><xsl:value-of select="get_overrides_response/override/text"/></textarea>
            </td>
          </tr>
          <tr>
            <td colspan="2" style="text-align:right;">
              <input type="submit" name="submit" value="Save Override"/>
            </td>
          </tr>
        </table>
      </form>
      <xsl:choose>
        <xsl:when test="string-length(get_overrides_response/override/result/@id) = 0">
          <h3>Associated Result: Any</h3>
        </xsl:when>
        <xsl:otherwise>
          <h3>
            Associated Result
          </h3>
          <xsl:for-each select="get_overrides_response/override/result">
            <xsl:call-template name="result-detailed">
              <xsl:with-param name="details-button">0</xsl:with-param>
              <xsl:with-param name="override-buttons">0</xsl:with-param>
              <xsl:with-param name="note-buttons">0</xsl:with-param>
            </xsl:call-template>
          </xsl:for-each>
        </xsl:otherwise>
      </xsl:choose>
    </div>
  </div>
</xsl:template>

<xsl:template match="edit_override">
  <xsl:apply-templates select="gsad_msg"/>
  <xsl:call-template name="html-edit-override-form"/>
</xsl:template>

<xsl:template match="modify_override_response">
  <xsl:call-template name="command_result_dialog">
    <xsl:with-param name="operation">Save Override</xsl:with-param>
    <xsl:with-param name="status">
      <xsl:value-of select="@status"/>
    </xsl:with-param>
    <xsl:with-param name="msg">
      <xsl:value-of select="@status_text"/>
    </xsl:with-param>
  </xsl:call-template>
</xsl:template>

<xsl:template name="override" match="override">
  <xsl:param name="next">get_overrides</xsl:param>
  <xsl:param name="params"/>
  <xsl:param name="params-get"/>
  <xsl:variable name="class">
    <xsl:choose>
      <xsl:when test="position() mod 2 = 0">even</xsl:when>
      <xsl:otherwise>odd</xsl:otherwise>
    </xsl:choose>
  </xsl:variable>
  <tr class="{$class}">
    <td>
      <xsl:variable name="max" select="70"/>
      <xsl:choose>
        <xsl:when test="nvt/@oid = 0">
          <abbr title="Result was an open port.">None</abbr>
        </xsl:when>
        <xsl:when test="string-length(nvt/name) &gt; $max">
          <abbr title="{nvt/name} ({nvt/@oid})"><xsl:value-of select="substring(nvt/name, 0, $max)"/>...</abbr>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="nvt/name"/>
        </xsl:otherwise>
      </xsl:choose>
    </td>
    <td>
      <xsl:choose>
        <xsl:when test="string-length(threat) = 0">
          Any
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="threat"/>
        </xsl:otherwise>
      </xsl:choose>
    </td>
    <td>
      <xsl:value-of select="new_threat"/>
    </td>
    <td>
      <xsl:if test="orphan = 1"><b>Orphan</b><br/></xsl:if>
      <xsl:choose>
        <xsl:when test="text/@excerpt = 1">
          <xsl:value-of select="text/text()"/>...
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="text/text()"/>
        </xsl:otherwise>
      </xsl:choose>
    </td>
    <td>
      <xsl:choose>
        <xsl:when test="active='0'">
          no
        </xsl:when>
        <xsl:otherwise>
          yes
        </xsl:otherwise>
      </xsl:choose>
    </td>
    <td>
      <xsl:call-template name="list-window-line-icons">
        <xsl:with-param name="cap-type" select="'Override'"/>
        <xsl:with-param name="type" select="'override'"/>
        <xsl:with-param name="id" select="@id"/>
        <xsl:with-param name="params" select="$params-get"/>
        <xsl:with-param name="next" select="$next"/>
      </xsl:call-template>
    </td>
  </tr>
</xsl:template>

<xsl:template match="override" mode="trash">
  <xsl:param name="next">get_overrides</xsl:param>
  <xsl:param name="params"/>
  <xsl:param name="params-get"/>
  <xsl:variable name="class">
    <xsl:choose>
      <xsl:when test="position() mod 2 = 0">even</xsl:when>
      <xsl:otherwise>odd</xsl:otherwise>
    </xsl:choose>
  </xsl:variable>
  <tr class="{$class}">
    <td>
      <xsl:variable name="max" select="70"/>
      <xsl:choose>
        <xsl:when test="nvt/@oid = 0">
          <abbr title="Result was an open port.">None</abbr>
        </xsl:when>
        <xsl:when test="string-length(nvt/name) &gt; $max">
          <abbr title="{nvt/name} ({nvt/@oid})"><xsl:value-of select="substring(nvt/name, 0, $max)"/>...</abbr>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="nvt/name"/>
        </xsl:otherwise>
      </xsl:choose>
    </td>
    <td>
      <xsl:if test="orphan = 1"><b>Orphan</b><br/></xsl:if>
      <xsl:choose>
        <xsl:when test="text/@excerpt = 1">
          <xsl:value-of select="text/text()"/>...
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="text/text()"/>
        </xsl:otherwise>
      </xsl:choose>
    </td>
    <td>
      <xsl:call-template name="restore-icon">
        <xsl:with-param name="id" select="@id"/>
      </xsl:call-template>
      <xsl:call-template name="trash-delete-icon">
        <xsl:with-param name="type" select="'override'"/>
        <xsl:with-param name="id" select="@id"/>
      </xsl:call-template>
    </td>
  </tr>
</xsl:template>

<xsl:template match="override" mode="details">
  <div class="gb_window">
    <div class="gb_window_part_left"></div>
    <div class="gb_window_part_right"></div>
    <div class="gb_window_part_center">
      Override Details
      <xsl:call-template name="details-header-icons">
        <xsl:with-param name="cap-type" select="'Override'"/>
        <xsl:with-param name="type" select="'override'"/>
      </xsl:call-template>
    </div>
    <div class="gb_window_part_content">
      <xsl:call-template name="minor-details"/>
      <table>
        <tr>
          <td><b>NVT Name:</b></td>
          <td>
            <xsl:variable name="max" select="70"/>
            <xsl:choose>
              <xsl:when test="nvt/@oid = 0">
                None.  Result was an open port.
              </xsl:when>
              <xsl:when test="string-length(nvt/name) &gt; $max">
                <a href="?cmd=get_nvts&amp;oid={nvt/@oid}&amp;token={/envelope/token}">
                  <abbr title="{nvt/name} ({nvt/@oid})"><xsl:value-of select="substring(nvt/name, 0, $max)"/>...</abbr>
                </a>
              </xsl:when>
              <xsl:otherwise>
                <a href="?cmd=get_nvts&amp;oid={nvt/@oid}&amp;token={/envelope/token}">
                  <xsl:value-of select="nvt/name"/>
                </a>
              </xsl:otherwise>
            </xsl:choose>
          </td>
        </tr>
        <tr>
          <td>NVT OID:</td>
          <td>
            <xsl:choose>
              <xsl:when test="nvt/@oid = 0"></xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="nvt/@oid"/>
              </xsl:otherwise>
            </xsl:choose>
          </td>
        </tr>
        <tr>
          <td>Active:</td>
          <td>
            <xsl:choose>
              <xsl:when test="active='0'">
                no
              </xsl:when>
              <xsl:when test="active='1' and string-length (end_time) &gt; 0">
                yes, until
                <xsl:value-of select="gsa:long-time (end_time)"/>
              </xsl:when>
              <xsl:otherwise>
                yes
              </xsl:otherwise>
            </xsl:choose>
          </td>
        </tr>
      </table>

      <h1>Application</h1>
      <table>
        <tr>
          <td>Hosts:</td>
          <td>
            <xsl:choose>
              <xsl:when test="string-length(hosts) &gt; 0">
                <xsl:value-of select="hosts"/>
              </xsl:when>
              <xsl:otherwise>
                Any
              </xsl:otherwise>
            </xsl:choose>
          </td>
        </tr>
        <tr>
          <td>Port:</td>
          <td>
            <xsl:choose>
              <xsl:when test="string-length(port) &gt; 0">
                <xsl:value-of select="port"/>
              </xsl:when>
              <xsl:otherwise>
                Any
              </xsl:otherwise>
            </xsl:choose>
          </td>
        </tr>
        <tr>
          <td>Threat:</td>
          <td>
            <xsl:choose>
              <xsl:when test="string-length(threat) &gt; 0">
                <xsl:value-of select="threat"/>
              </xsl:when>
              <xsl:otherwise>
                Any
              </xsl:otherwise>
            </xsl:choose>
          </td>
        </tr>
        <tr>
          <td><b>New Threat:</b></td>
          <td>
            <xsl:value-of select="new_threat"/>
          </td>
        </tr>
        <tr>
          <td>Task:</td>
          <td>
            <xsl:choose>
              <xsl:when test="orphan != 0">
                <b>Orphan</b>
              </xsl:when>
              <xsl:when test="task and string-length(task/@id) &gt; 0">
                <xsl:choose>
                  <xsl:when test="task/trash = '1'">
                    <xsl:value-of select="task/name"/> (in <a href="/omp?cmd=get_trash&amp;token={/envelope/token}">trashcan</a>)
                  </xsl:when>
                  <xsl:otherwise>
                    <a href="?cmd=get_task&amp;task_id={task/@id}&amp;token={/envelope/token}">
                      <xsl:value-of select="task/name"/>
                    </a>
                  </xsl:otherwise>
                </xsl:choose>
              </xsl:when>
              <xsl:otherwise>
                Any
              </xsl:otherwise>
            </xsl:choose>
          </td>
        </tr>
        <tr>
          <td>Result:</td>
          <td>
            <xsl:choose>
              <xsl:when test="orphan != 0">
                <b>Orphan</b>
              </xsl:when>
              <xsl:when test="string-length(result/@id) &gt; 0">
                <xsl:value-of select="result/@id"/>
              </xsl:when>
              <xsl:otherwise>
                Any
              </xsl:otherwise>
            </xsl:choose>
          </td>
        </tr>
      </table>

      <xsl:choose>
        <xsl:when test="active = '0'">
          <h1>Appearance when Active</h1>
        </xsl:when>
        <xsl:otherwise>
          <h1>Appearance</h1>
        </xsl:otherwise>
      </xsl:choose>
      <div class="override_top_line"></div>
      <xsl:call-template name="override-detailed">
        <xsl:with-param name="override-buttons">0</xsl:with-param>
      </xsl:call-template>
    </div>
  </div>
</xsl:template>

<xsl:template name="html-overrides-table">
  <xsl:call-template name="list-window">
    <xsl:with-param name="type" select="'override'"/>
    <xsl:with-param name="cap-type" select="'Override'"/>
    <xsl:with-param name="resources-summary" select="overrides"/>
    <xsl:with-param name="resources" select="override"/>
    <xsl:with-param name="count" select="count (override)"/>
    <xsl:with-param name="filtered-count" select="override_count/filtered"/>
    <xsl:with-param name="full-count" select="override_count/text ()"/>
    <xsl:with-param name="headings" select="'NVT|nvt From|from To|to Text|text Active|active'"/>
  </xsl:call-template>
</xsl:template>

<xsl:template name="html-overrides-trash-table">
  <div id="tasks">
    <table class="gbntable" cellspacing="2" cellpadding="4" border="0">
      <tr class="gbntablehead2">
        <td>NVT</td>
        <td>Text</td>
        <td width="100">Actions</td>
      </tr>
      <xsl:apply-templates select="override" mode="trash"/>
    </table>
  </div>
</xsl:template>

<xsl:template match="get_override">
  <xsl:apply-templates select="gsad_msg"/>
  <xsl:apply-templates select="commands_response/modify_override_response"/>
  <xsl:choose>
    <xsl:when test="commands_reponse/get_overrides_response/@status = '500'">
      <xsl:call-template name="command_result_dialog">
        <xsl:with-param name="operation">
          Get Override
        </xsl:with-param>
        <xsl:with-param name="status">
          <xsl:value-of select="500"/>
        </xsl:with-param>
        <xsl:with-param name="msg">
          <xsl:value-of select="commands_response/get_overrides_response/@status_text"/>
        </xsl:with-param>
      </xsl:call-template>
    </xsl:when>
    <xsl:otherwise>
      <xsl:apply-templates select="commands_response/get_overrides_response/override" mode="details"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template match="get_overrides">
  <xsl:apply-templates select="gsad_msg"/>
  <xsl:apply-templates select="delete_override_response"/>
  <xsl:apply-templates select="create_filter_response"/>
  <xsl:apply-templates select="create_override_response"/>
  <!-- The for-each makes the get_overrides_response the current node. -->
  <xsl:for-each select="get_overrides_response | commands_response/get_overrides_response">
    <xsl:call-template name="html-overrides-table"/>
  </xsl:for-each>
</xsl:template>

<!-- END OVERRIDES MANAGEMENT -->

<!-- BEGIN GROUPS MANAGEMENT -->

<xsl:template match="groups">
</xsl:template>

<xsl:template match="create_group_response">
  <xsl:call-template name="command_result_dialog">
    <xsl:with-param name="operation">Create Group</xsl:with-param>
    <xsl:with-param name="status">
      <xsl:value-of select="@status"/>
    </xsl:with-param>
    <xsl:with-param name="msg">
      <xsl:value-of select="@status_text"/>
    </xsl:with-param>
  </xsl:call-template>
</xsl:template>

<xsl:template match="delete_group_response">
  <xsl:call-template name="command_result_dialog">
    <xsl:with-param name="operation">Delete Group</xsl:with-param>
    <xsl:with-param name="status">
      <xsl:value-of select="@status"/>
    </xsl:with-param>
    <xsl:with-param name="msg">
      <xsl:value-of select="@status_text"/>
    </xsl:with-param>
  </xsl:call-template>
</xsl:template>

<xsl:template match="modify_group_response">
  <xsl:call-template name="command_result_dialog">
    <xsl:with-param name="operation">Save Group</xsl:with-param>
    <xsl:with-param name="status">
      <xsl:value-of select="@status"/>
    </xsl:with-param>
    <xsl:with-param name="msg">
      <xsl:value-of select="@status_text"/>
    </xsl:with-param>
  </xsl:call-template>
</xsl:template>

<xsl:template match="group">
  <xsl:variable name="class">
    <xsl:choose>
      <xsl:when test="position() mod 2 = 0">even</xsl:when>
      <xsl:otherwise>odd</xsl:otherwise>
    </xsl:choose>
  </xsl:variable>
  <tr class="{$class}">
    <td>
      <b>
        <a href="/omp?cmd=get_group&amp;group_id={@id}&amp;group={../groups/term}&amp;token={/envelope/token}">
          <xsl:value-of select="name"/>
        </a>
      </b>
      <xsl:choose>
        <xsl:when test="comment != ''">
          <br/>(<xsl:value-of select="comment"/>)
        </xsl:when>
        <xsl:otherwise></xsl:otherwise>
      </xsl:choose>
    </td>
    <td>
      <xsl:call-template name="list-window-line-icons">
        <xsl:with-param name="cap-type" select="'Group'"/>
        <xsl:with-param name="type" select="'group'"/>
        <xsl:with-param name="id" select="@id"/>
      </xsl:call-template>
    </td>
  </tr>
</xsl:template>

<xsl:template match="group" mode="trash">
  <xsl:variable name="class">
    <xsl:choose>
      <xsl:when test="position() mod 2 = 0">even</xsl:when>
      <xsl:otherwise>odd</xsl:otherwise>
    </xsl:choose>
  </xsl:variable>
  <tr class="{$class}">
    <td>
      <b>
        <xsl:value-of select="name"/>
      </b>
      <xsl:choose>
        <xsl:when test="comment != ''">
          <br/>(<xsl:value-of select="comment"/>)
        </xsl:when>
        <xsl:otherwise></xsl:otherwise>
      </xsl:choose>
    </td>
    <td>
      <xsl:call-template name="restore-icon">
        <xsl:with-param name="id" select="@id"/>
      </xsl:call-template>
      <xsl:choose>
        <xsl:when test="in_use='0'">
          <xsl:call-template name="trash-delete-icon">
            <xsl:with-param name="type" select="'group'"/>
            <xsl:with-param name="id" select="@id"/>
          </xsl:call-template>
        </xsl:when>
        <xsl:otherwise>
          <img src="/img/delete_inactive.png"
               border="0"
               alt="Delete"
               style="margin-left:3px;"/>
        </xsl:otherwise>
      </xsl:choose>
    </td>
  </tr>
</xsl:template>

<xsl:template match="group" mode="details">
  <div class="gb_window">
    <div class="gb_window_part_left"></div>
    <div class="gb_window_part_right"></div>
    <div class="gb_window_part_center">
      Group Details
      <xsl:call-template name="details-header-icons">
        <xsl:with-param name="cap-type" select="'Group'"/>
        <xsl:with-param name="type" select="'group'"/>
      </xsl:call-template>
    </div>
    <div class="gb_window_part_content">
      <xsl:call-template name="minor-details"/>
      <table>
        <tr>
          <td><b>Name:</b></td>
          <td><b><xsl:value-of select="name"/></b></td>
        </tr>
        <tr>
          <td>Comment:</td>
          <td><xsl:value-of select="comment"/></td>
        </tr>
        <tr>
          <td>Users:</td>
          <td><xsl:value-of select="users/text()"/></td>
        </tr>
      </table>
    </div>
  </div>
</xsl:template>

<xsl:template name="html-groups-trash-table">
  <div id="tasks">
    <table class="gbntable" cellspacing="2" cellpadding="4" border="0">
      <tr class="gbntablehead2">
        <td>Name</td>
        <td width="100">Actions</td>
      </tr>
      <xsl:apply-templates select="group" mode="trash"/>
    </table>
  </div>
</xsl:template>

<xsl:template name="html-groups-table">
  <xsl:call-template name="list-window">
    <xsl:with-param name="type" select="'group'"/>
    <xsl:with-param name="cap-type" select="'Group'"/>
    <xsl:with-param name="resources-summary" select="groups"/>
    <xsl:with-param name="resources" select="group"/>
    <xsl:with-param name="count" select="count (group)"/>
    <xsl:with-param name="grouped-count" select="group_count/grouped"/>
    <xsl:with-param name="full-count" select="group_count/text ()"/>
    <xsl:with-param name="headings" select="'Name|name'"/>
  </xsl:call-template>
</xsl:template>

<!-- NEW_GROUP -->

<xsl:template name="html-create-group-form">
  <div class="gb_window">
    <div class="gb_window_part_left"></div>
    <div class="gb_window_part_right"></div>
    <div class="gb_window_part_center">New Group
      <a href="/help/new_group.html?token={/envelope/token}"
         title="Help: New Group">
        <img src="/img/help.png"/>
      </a>
      <a href="/omp?cmd=get_groups&amp;group={/envelope/params/group}&amp;filt_id={/envelope/params/filt_id}&amp;token={/envelope/token}"
         title="Groups" style="margin-left:3px;">
        <img src="/img/list.png" border="0" alt="Groups"/>
      </a>
    </div>
    <div class="gb_window_part_content">
      <form action="/omp" method="post" enctype="multipart/form-data">
        <input type="hidden" name="token" value="{/envelope/token}"/>
        <input type="hidden" name="cmd" value="create_group"/>
        <input type="hidden" name="caller" value="{/envelope/caller}"/>
        <input type="hidden" name="group_id" value="{/envelope/params/group_id}"/>
        <input type="hidden" name="group" value="{/envelope/params/group}"/>
        <table border="0" cellspacing="0" cellpadding="3" width="100%">
          <tr>
            <td valign="top" width="175">Name
            </td>
            <td>
              <input type="text" name="name" value="unnamed" size="30"
                     maxlength="80"/>
            </td>
          </tr>
          <tr>
            <td valign="top" width="175">Comment (optional)</td>
            <td>
              <input type="text" name="comment" size="30" maxlength="400"/>
            </td>
          </tr>
          <tr>
            <td valign="top" width="175">Users</td>
            <td>
              <input type="text" name="users" size="30" maxlength="1000"/>
            </td>
          </tr>
          <tr>
            <td colspan="2" style="text-align:right;">
              <input type="submit" name="submit" value="Create Group"/>
            </td>
          </tr>
        </table>
      </form>
    </div>
  </div>
</xsl:template>

<xsl:template match="new_group">
  <xsl:apply-templates select="gsad_msg"/>
  <xsl:apply-templates select="commands_response/delete_group_response"/>
  <xsl:apply-templates select="create_group_response"/>
  <xsl:call-template name="html-create-group-form"/>
</xsl:template>

<!--     EDIT_GROUP -->

<xsl:template name="html-edit-group-form">
  <div class="gb_window">
    <div class="gb_window_part_left"></div>
    <div class="gb_window_part_right"></div>
    <div class="gb_window_part_center">Edit Group
      <xsl:call-template name="edit-header-icons">
        <xsl:with-param name="cap-type" select="'Group'"/>
        <xsl:with-param name="type" select="'group'"/>
        <xsl:with-param name="id"
                        select="commands_response/get_groups_response/group/@id"/>
      </xsl:call-template>
    </div>
    <div class="gb_window_part_content">
      <form action="" method="post" enctype="multipart/form-data">
        <input type="hidden" name="token" value="{/envelope/token}"/>
        <input type="hidden" name="cmd" value="save_group"/>
        <input type="hidden" name="caller" value="{/envelope/caller}"/>
        <input type="hidden"
               name="group_id"
               value="{commands_response/get_groups_response/group/@id}"/>
        <input type="hidden" name="next" value="{/envelope/params/next}"/>
        <input type="hidden" name="group" value="{/envelope/params/group}"/>
        <input type="hidden" name="filt_id" value="{/envelope/params/filt_id}"/>
        <table border="0" cellspacing="0" cellpadding="3" width="100%">
          <tr>
            <td valign="top" width="165">Name</td>
            <td>
              <input type="text"
                     name="name"
                     value="{commands_response/get_groups_response/group/name}"
                     size="30"
                     maxlength="80"/>
            </td>
          </tr>
          <tr>
            <td valign="top" width="175">Comment (optional)</td>
            <td>
              <input type="text" name="comment" size="30" maxlength="400"
                     value="{commands_response/get_groups_response/group/comment}"/>
            </td>
          </tr>
          <tr>
            <td valign="top" width="175">Users</td>
            <td>
              <input type="text" name="users"
                     value="{commands_response/get_groups_response/group/users}"
                     size="30"
                     maxlength="1000"/>
            </td>
          </tr>
          <tr>
            <td colspan="2" style="text-align:right;">
              <input type="submit" name="submit" value="Save Group"/>
            </td>
          </tr>
        </table>
        <br/>
      </form>
    </div>
  </div>
</xsl:template>

<xsl:template match="edit_group">
  <xsl:apply-templates select="gsad_msg"/>
  <xsl:call-template name="html-edit-group-form"/>
</xsl:template>

<!--     GET_GROUP -->

<xsl:template match="get_group">
  <xsl:apply-templates select="gsad_msg"/>
  <xsl:apply-templates select="commands_response/delete_group_response"/>
  <xsl:apply-templates select="commands_response/modify_group_response"/>
  <xsl:apply-templates select="get_groups_response/group" mode="details"/>
</xsl:template>

<!--     GET_GROUPS -->

<xsl:template match="get_groups">
  <xsl:apply-templates select="gsad_msg"/>
  <xsl:apply-templates select="delete_group_response"/>
  <xsl:apply-templates select="create_group_response"/>
  <xsl:apply-templates select="modify_group_response"/>
  <!-- The for-each makes the get_groups_response the current node. -->
  <xsl:for-each select="get_groups_response | commands_response/get_groups_response">
    <xsl:choose>
      <xsl:when test="substring(@status, 1, 1) = '4' or substring(@status, 1, 1) = '5'">
        <xsl:call-template name="command_result_dialog">
          <xsl:with-param name="operation">
            Get Groups
          </xsl:with-param>
          <xsl:with-param name="status">
            <xsl:value-of select="@status"/>
          </xsl:with-param>
          <xsl:with-param name="msg">
            <xsl:value-of select="@status_text"/>
          </xsl:with-param>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="html-groups-table"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:for-each>
</xsl:template>

<!-- END GROUPS MANAGEMENT -->

<!-- BEGIN PERMISSIONS MANAGEMENT -->

<xsl:template match="delete_permission_response">
  <xsl:call-template name="command_result_dialog">
    <xsl:with-param name="operation">
      Delete Permission
    </xsl:with-param>
    <xsl:with-param name="status">
      <xsl:value-of select="@status"/>
    </xsl:with-param>
    <xsl:with-param name="msg">
      <xsl:value-of select="@status_text"/>
    </xsl:with-param>
  </xsl:call-template>
</xsl:template>

<xsl:template match="permission">
  <xsl:variable name="class">
    <xsl:choose>
      <xsl:when test="position() mod 2 = 0">even</xsl:when>
      <xsl:otherwise>odd</xsl:otherwise>
    </xsl:choose>
  </xsl:variable>
  <tr class="{$class}">
    <td>
      <div class="float_right">
        <xsl:choose>
          <xsl:when test="string-length (observers) &gt; 0">
            <img src="/img/provide_view.png"
                 border="0"
                 alt="Permission made visible for: {observers}"
                 title="Permission made visible for: {observers}"/>
          </xsl:when>
          <xsl:otherwise>
          </xsl:otherwise>
        </xsl:choose>
      </div>
      <b>
        <a href="/omp?cmd=get_permission&amp;permission_id={@id}&amp;filter={../filters/term}&amp;first={../permissions/@start}&amp;max={../permissions/@max}&amp;token={/envelope/token}">
          <xsl:value-of select="name"/>
        </a>
      </b>
      <xsl:choose>
        <xsl:when test="comment != ''">
          <br/>(<xsl:value-of select="comment"/>)
        </xsl:when>
        <xsl:otherwise></xsl:otherwise>
      </xsl:choose>
    </td>
    <td>
      <xsl:value-of select="resource/type"/>
    </td>
    <td>
      <a href="/omp?cmd=get_{resource/type}&amp;{resource/type}_id={resource/*/@id}&amp;token={/envelope/token}"
         title="Details">
        <xsl:value-of select="resource/*/name"/>
      </a>
    </td>
    <td>
      <xsl:value-of select="subject/type"/>
    </td>
    <td>
      <xsl:value-of select="subject/name"/>
    </td>
    <td>
      <xsl:call-template name="list-window-line-icons">
        <xsl:with-param name="cap-type" select="'Permission'"/>
        <xsl:with-param name="type" select="'permission'"/>
        <xsl:with-param name="id" select="@id"/>
        <xsl:with-param name="noedit" select="1"/>
      </xsl:call-template>
    </td>
  </tr>
</xsl:template>

<xsl:template match="permission" mode="details">
  <div class="gb_window">
    <div class="gb_window_part_left"></div>
    <div class="gb_window_part_right"></div>
    <div class="gb_window_part_center">
      Permission Details
      <xsl:call-template name="details-header-icons">
        <xsl:with-param name="cap-type" select="'Permission'"/>
        <xsl:with-param name="type" select="'permission'"/>
      </xsl:call-template>
    </div>
    <div class="gb_window_part_content">
      <xsl:call-template name="minor-details"/>
      <table>
        <tr>
          <td><b>Name:</b></td>
          <td><b><xsl:value-of select="name"/></b></td>
        </tr>
        <tr>
          <td>Comment:</td>
          <td><xsl:value-of select="comment"/></td>
        </tr>
        <tr>
          <td><xsl:value-of select="gsa:capitalise (subject/type)"/>:</td>
          <td>
            <!-- Param login is for users until we have users with IDs. -->
            <a href="/omp?cmd=get_{subject/type}&amp;{subject/type}_id={subject/*/@id}&amp;login={subject/*/name}&amp;token={/envelope/token}"
               title="Details">
              <xsl:value-of select="subject/*/name"/>
            </a>
          </td>
        </tr>
        <tr>
          <td>Resource:</td>
          <td>
            <xsl:value-of select="gsa:capitalise (resource/type)"/>
            <xsl:text> </xsl:text>
            <a href="/omp?cmd=get_{resource/type}&amp;{resource/type}_id={resource/*/@id}&amp;token={/envelope/token}"
               title="Details">
              <xsl:value-of select="resource/*/name"/>
            </a>
          </td>
        </tr>
      </table>
    </div>
  </div>
</xsl:template>

<xsl:template match="permission" mode="trash">
  <xsl:variable name="class">
    <xsl:choose>
      <xsl:when test="position() mod 2 = 0">even</xsl:when>
      <xsl:otherwise>odd</xsl:otherwise>
    </xsl:choose>
  </xsl:variable>
  <tr class="{$class}">
    <td>
      <div class="float_right">
        <xsl:choose>
          <xsl:when test="string-length (observers) &gt; 0">
            <img src="/img/provide_view.png"
                 border="0"
                 alt="Permission made visible for: {observers}"
                 title="Permission made visible for: {observers}"/>
          </xsl:when>
          <xsl:otherwise>
          </xsl:otherwise>
        </xsl:choose>
      </div>
      <b>
        <xsl:value-of select="name"/>
      </b>
      <xsl:choose>
        <xsl:when test="comment != ''">
          <br/>(<xsl:value-of select="comment"/>)
        </xsl:when>
        <xsl:otherwise></xsl:otherwise>
      </xsl:choose>
    </td>
    <td>
      <xsl:value-of select="resource/type"/>
    </td>
    <td>
      <a href="/omp?cmd=get_{resource/type}&amp;{resource/type}_id={resource/*/@id}&amp;token={/envelope/token}"
         title="Details">
        <xsl:value-of select="resource/*/name"/>
      </a>
    </td>
    <td>
      <xsl:value-of select="subject/type"/>
    </td>
    <td>
      <xsl:value-of select="subject/name"/>
    </td>
    <td>
      <xsl:call-template name="restore-icon">
        <xsl:with-param name="id" select="@id"/>
      </xsl:call-template>
      <xsl:choose>
        <xsl:when test="in_use='0'">
          <xsl:call-template name="trash-delete-icon">
            <xsl:with-param name="type" select="'permission'"/>
            <xsl:with-param name="id" select="@id"/>
          </xsl:call-template>
        </xsl:when>
        <xsl:otherwise>
          <img src="/img/delete_inactive.png"
               border="0"
               alt="Delete"
               style="margin-left:3px;"/>
        </xsl:otherwise>
      </xsl:choose>
    </td>
  </tr>
</xsl:template>

<xsl:template match="get_permission">
  <xsl:apply-templates select="gsad_msg"/>
  <xsl:apply-templates select="commands_response/delete_permission_response"/>
  <xsl:apply-templates select="get_permissions_response/permission"
                       mode="details"/>
</xsl:template>

<xsl:template name="html-permissions-trash-table">
  <div id="tasks">
    <table class="gbntable" cellspacing="2" cellpadding="4" border="0">
      <tr class="gbntablehead2">
        <td>Name</td>
        <td>Type</td>
        <td>Resource</td>
        <td>Subject Type</td>
        <td>Subject</td>
        <td width="100">Actions</td>
      </tr>
      <xsl:apply-templates select="permission" mode="trash"/>
    </table>
  </div>
</xsl:template>

<xsl:template name="html-permissions-table">
  <xsl:call-template name="list-window">
    <xsl:with-param name="type" select="'permission'"/>
    <xsl:with-param name="cap-type" select="'Permission'"/>
    <xsl:with-param name="resources-summary" select="permissions"/>
    <xsl:with-param name="resources" select="permission"/>
    <xsl:with-param name="count" select="count (permission)"/>
    <xsl:with-param name="filtered-count" select="permission_count/filtered"/>
    <xsl:with-param name="full-count" select="permission_count/text ()"/>
    <xsl:with-param name="headings" select="'Name|name Type|resource/type Resource|resource/type Subject&#xa0;Type|subject/type Subject|subject/name'"/>
  </xsl:call-template>
</xsl:template>

<!--     GET_PERMISSIONS -->

<xsl:template match="get_permissions">
  <xsl:apply-templates select="gsad_msg"/>
  <xsl:apply-templates select="delete_permission_response"/>
  <xsl:apply-templates select="create_permission_response"/>
  <!-- The for-each makes the get_permissions_response the current node. -->
  <xsl:for-each select="get_permissions_response | commands_response/get_permissions_response">
    <xsl:choose>
      <xsl:when test="substring(@status, 1, 1) = '4' or substring(@status, 1, 1) = '5'">
        <xsl:call-template name="command_result_dialog">
          <xsl:with-param name="operation">
            Get Permissions
          </xsl:with-param>
          <xsl:with-param name="status">
            <xsl:value-of select="@status"/>
          </xsl:with-param>
          <xsl:with-param name="msg">
            <xsl:value-of select="@status_text"/>
          </xsl:with-param>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="html-permissions-table"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:for-each>
</xsl:template>

<!-- END PERMISSIONS MANAGEMENT -->

<!-- BEGIN PORT_LISTS MANAGEMENT -->

<xsl:template name="html-create-port-list-form">
  <div class="gb_window">
    <div class="gb_window_part_left"></div>
    <div class="gb_window_part_right"></div>
    <div class="gb_window_part_center">
      New Port List
      <a href="/help/new_port_list.html?token={/envelope/token}"
         title="Help: New Port List">
        <img src="/img/help.png"/>
      </a>
      <a href="/omp?cmd=get_port_lists&amp;filter={str:encode-uri (/envelope/params/filter, true ())}&amp;filt_id={/envelope/params/filt_id}&amp;token={/envelope/token}"
         title="Port Lists" style="margin-left:3px;">
        <img src="/img/list.png" border="0" alt="Port Lists"/>
      </a>
    </div>
    <div class="gb_window_part_content">
      <form action="/omp" method="post" enctype="multipart/form-data">
        <input type="hidden" name="token" value="{/envelope/token}"/>
        <input type="hidden" name="cmd" value="create_port_list"/>
        <input type="hidden" name="caller" value="{/envelope/caller}"/>
        <table border="0" cellspacing="0" cellpadding="3" width="100%">
          <tr>
            <td valign="top" width="175">Name
            </td>
            <td>
              <input type="text" name="name" value="unnamed" size="30"
                     maxlength="80"/>
            </td>
          </tr>
          <tr>
            <td valign="top" width="175">Comment (optional)</td>
            <td>
              <input type="text" name="comment" size="30" maxlength="400"/>
            </td>
          </tr>
          <tr>
            <td valign="top" width="175">Port Ranges</td>
            <td>
              <label>
                <input type="radio" name="from_file" value="0" checked="1"/>
              </label>
              <input type="text" name="port_range" value="T:1-5,7,9,U:1-3,5,7,9"
                     size="30" maxlength="400"/>
              <br/>
              <label>
                <input type="radio" name="from_file" value="1"/>
                From file
                <input type="file" name="file" size="30"/>
              </label>
            </td>
          </tr>
          <tr>
            <td colspan="2" style="text-align:right;">
              <input type="submit" name="submit" value="Create Port List"/>
            </td>
          </tr>
        </table>
      </form>
    </div>
  </div>
</xsl:template>

<xsl:template name="html-port-lists-table">
  <div class="gb_window">
    <div class="gb_window_part_left"></div>
    <div class="gb_window_part_right"></div>
    <div class="gb_window_part_center">Port Lists
      <xsl:call-template name="filter-window-pager">
        <xsl:with-param name="type" select="'port_list'"/>
        <xsl:with-param name="list" select="port_lists"/>
        <xsl:with-param name="count" select="count (port_list)"/>
        <xsl:with-param name="filtered_count" select="port_list_count/filtered"/>
        <xsl:with-param name="full_count" select="port_list_count/text ()"/>
      </xsl:call-template>
      <a href="/help/port_lists.html?token={/envelope/token}"
         title="Help: Port Lists">
        <img src="/img/help.png"/>
      </a>
      <a href="/omp?cmd=new_port_list&amp;filter={str:encode-uri (filters/term, true ())}&amp;filt_id={/envelope/params/filt_id}&amp;token={/envelope/token}"
         title="New Port List">
        <img src="/img/new.png" border="0" style="margin-left:3px;"/>
      </a>
      <a href="/omp?cmd=get_port_lists&amp;filter=&amp;filt_id=&amp;token={/envelope/token}"
         title="Return to default filter view" style="margin-left:3px;">
        <img src="/img/list.png" border="0" alt="Return"/>
      </a>
      <div id="small_inline_form" style="display: inline; margin-left: 15px; font-weight: normal;">
        <a href="/omp?cmd=export_port_lists&amp;filter={str:encode-uri (filters/term, true ())}&amp;token={/envelope/token}"
           title="Export port_list_count/filtered filtered Port Lists as XML"
           style="margin-left:3px;">
          <img src="/img/download.png" border="0" alt="Export XML"/>
        </a>
      </div>
      <div id="small_inline_form" style="margin-left:40px; display: inline">
        <form method="get" action="">
          <input type="hidden" name="token" value="{/envelope/token}"/>
          <input type="hidden" name="cmd" value="get_port_lists"/>
          <input type="hidden" name="filter" value="{filters/term}"/>
          <xsl:call-template name="auto-refresh"/>
          <input type="image"
                 name="Update"
                 src="/img/refresh.png"
                 alt="Update" style="margin-left:3px;margin-right:3px;"/>
        </form>
      </div>
    </div>
    <xsl:call-template name="filter-window-part">
      <xsl:with-param name="type" select="'port_list'"/>
      <xsl:with-param name="list" select="port_lists"/>
    </xsl:call-template>
    <div class="gb_window_part_content_no_pad">
      <div id="tasks">
        <table class="gbntable" cellspacing="2" cellpadding="4" border="0">
          <tr class="gbntablehead2">
            <td rowspan="2">
              <xsl:call-template name="column-name">
                <xsl:with-param name="head">Name</xsl:with-param>
                <xsl:with-param name="name">name</xsl:with-param>
                <xsl:with-param name="type">port_list</xsl:with-param>
              </xsl:call-template>
            </td>
            <td colspan="3">Port Counts</td>
            <td width="115" rowspan="2">Actions</td>
          </tr>
          <tr class="gbntablehead2">
            <td width="1" style="font-size:10px;">
              <xsl:call-template name="column-name">
                <xsl:with-param name="head">Total</xsl:with-param>
                <xsl:with-param name="name">total</xsl:with-param>
                <xsl:with-param name="type">port_list</xsl:with-param>
              </xsl:call-template>
            </td>
            <td style="font-size:10px;">
              <xsl:call-template name="column-name">
                <xsl:with-param name="head">TCP</xsl:with-param>
                <xsl:with-param name="name">tcp</xsl:with-param>
                <xsl:with-param name="type">port_list</xsl:with-param>
              </xsl:call-template>
            </td>
            <td style="font-size:10px;">
              <xsl:call-template name="column-name">
                <xsl:with-param name="head">UDP</xsl:with-param>
                <xsl:with-param name="name">udp</xsl:with-param>
                <xsl:with-param name="type">port_list</xsl:with-param>
              </xsl:call-template>
            </td>
          </tr>
          <xsl:apply-templates select="port_list"/>
        </table>
      </div>
    </div>
  </div>
</xsl:template>

<!--     CREATE_PORT_LIST_RESPONSE -->

<xsl:template match="create_port_list_response">
  <xsl:call-template name="command_result_dialog">
    <xsl:with-param name="operation">Create Port List</xsl:with-param>
    <xsl:with-param name="status">
      <xsl:value-of select="@status"/>
    </xsl:with-param>
    <xsl:with-param name="msg">
      <xsl:value-of select="@status_text"/>
    </xsl:with-param>
  </xsl:call-template>
</xsl:template>

<!--     DELETE_PORT_LIST_RESPONSE -->

<xsl:template match="delete_port_list_response">
  <xsl:call-template name="command_result_dialog">
    <xsl:with-param name="operation">
      Delete Port List
    </xsl:with-param>
    <xsl:with-param name="status">
      <xsl:value-of select="@status"/>
    </xsl:with-param>
    <xsl:with-param name="msg">
      <xsl:value-of select="@status_text"/>
    </xsl:with-param>
  </xsl:call-template>
</xsl:template>

<!--     DELETE_PORT_RANGE_RESPONSE -->

<xsl:template match="delete_port_range_response">
  <xsl:call-template name="command_result_dialog">
    <xsl:with-param name="operation">
      Delete Port Range
    </xsl:with-param>
    <xsl:with-param name="status">
      <xsl:value-of select="@status"/>
    </xsl:with-param>
    <xsl:with-param name="msg">
      <xsl:value-of select="@status_text"/>
    </xsl:with-param>
  </xsl:call-template>
</xsl:template>

<!--     PORT_LIST -->

<xsl:template match="port_list">
  <xsl:variable name="class">
    <xsl:choose>
      <xsl:when test="position() mod 2 = 0">even</xsl:when>
      <xsl:otherwise>odd</xsl:otherwise>
    </xsl:choose>
  </xsl:variable>
  <tr class="{$class}">
    <td>
      <b>
        <a href="/omp?cmd=get_port_list&amp;port_list_id={@id}&amp;filter={str:encode-uri (../filters/term, true ())}&amp;token={/envelope/token}">
          <xsl:value-of select="name"/>
        </a>
      </b>
      <xsl:choose>
        <xsl:when test="comment != ''">
          <br/>(<xsl:value-of select="comment"/>)
        </xsl:when>
        <xsl:otherwise></xsl:otherwise>
      </xsl:choose>
    </td>
    <td>
      <xsl:value-of select="port_count/all"/>
    </td>
    <td>
      <xsl:value-of select="port_count/tcp"/>
    </td>
    <td>
      <xsl:value-of select="port_count/udp"/>
    </td>
    <td>
      <xsl:call-template name="list-window-line-icons">
        <xsl:with-param name="cap-type" select="'Port List'"/>
        <xsl:with-param name="type" select="'port_list'"/>
        <xsl:with-param name="id" select="@id"/>
      </xsl:call-template>
    </td>
  </tr>
</xsl:template>

<xsl:template match="port_list" mode="trash">
  <xsl:variable name="class">
    <xsl:choose>
      <xsl:when test="position() mod 2 = 0">even</xsl:when>
      <xsl:otherwise>odd</xsl:otherwise>
    </xsl:choose>
  </xsl:variable>
  <tr class="{$class}">
    <td>
      <b><xsl:value-of select="name"/></b>
      <xsl:choose>
        <xsl:when test="comment != ''">
          <br/>(<xsl:value-of select="comment"/>)
        </xsl:when>
        <xsl:otherwise></xsl:otherwise>
      </xsl:choose>
    </td>
    <td>
      <xsl:call-template name="restore-icon">
        <xsl:with-param name="id" select="@id"/>
      </xsl:call-template>
      <xsl:choose>
        <xsl:when test="in_use='0'">
          <xsl:call-template name="trash-delete-icon">
            <xsl:with-param name="type" select="'port_list'"/>
            <xsl:with-param name="id" select="@id"/>
          </xsl:call-template>
        </xsl:when>
        <xsl:otherwise>
          <img src="/img/delete_inactive.png"
               border="0"
               alt="Delete"
               style="margin-left:3px;"/>
        </xsl:otherwise>
      </xsl:choose>
    </td>
  </tr>
</xsl:template>

<xsl:template match="port_list" mode="details">
  <div class="gb_window">
    <div class="gb_window_part_left"></div>
    <div class="gb_window_part_right"></div>
    <div class="gb_window_part_center">
      Port List Details
      <xsl:call-template name="details-header-icons">
        <xsl:with-param name="cap-type" select="'Port List'"/>
        <xsl:with-param name="type" select="'port_list'"/>
      </xsl:call-template>
    </div>
    <div class="gb_window_part_content">
      <xsl:call-template name="minor-details"/>
      <table>
        <tr>
          <td><b>Name:</b></td>
          <td><b><xsl:value-of select="name"/></b></td>
        </tr>
        <tr>
          <td>Comment:</td>
          <td><xsl:value-of select="comment"/></td>
        </tr>
        <tr>
          <td>Port count:</td>
          <td><xsl:value-of select="port_count/all"/></td>
        </tr>
        <tr>
          <td>TCP Port count:</td>
          <td><xsl:value-of select="port_count/tcp"/></td>
        </tr>
        <tr>
          <td>UDP Port count:</td>
          <td><xsl:value-of select="port_count/udp"/></td>
        </tr>
      </table>

      <h1>Port Ranges</h1>
      <table class="gbntable" cellspacing="2" cellpadding="4">
        <tr class="gbntablehead2">
          <td>Start</td>
          <td>End</td>
          <td>Protocol</td>
        </tr>
        <xsl:variable name="id" select="@id"/>
        <xsl:variable name="in_use" select="in_use"/>
        <xsl:for-each select="port_ranges/port_range">
          <xsl:variable name="class">
            <xsl:choose>
              <xsl:when test="position() mod 2 = 0">even</xsl:when>
              <xsl:otherwise>odd</xsl:otherwise>
            </xsl:choose>
          </xsl:variable>
          <tr class="{$class}">
            <td><xsl:value-of select="start"/></td>
            <td><xsl:value-of select="end"/></td>
            <td><xsl:value-of select="type"/></td>
          </tr>
        </xsl:for-each>
      </table>

      <xsl:choose>
        <xsl:when test="count(targets/target) = 0">
          <h1>Targets using this Port List: None</h1>
        </xsl:when>
        <xsl:otherwise>
          <h1>Targets using this Port List</h1>
          <table class="gbntable" cellspacing="2" cellpadding="4">
            <tr class="gbntablehead2">
              <td>Name</td>
              <td>Actions</td>
            </tr>
            <xsl:for-each select="targets/target">
              <xsl:variable name="class">
                <xsl:choose>
                  <xsl:when test="position() mod 2 = 0">even</xsl:when>
                  <xsl:otherwise>odd</xsl:otherwise>
                </xsl:choose>
              </xsl:variable>
              <tr class="{$class}">
                <td><xsl:value-of select="name"/></td>
                <td width="100">
                  <a href="/omp?cmd=get_target&amp;target_id={@id}&amp;token={/envelope/token}" title="Details">
                    <img src="/img/details.png"
                         border="0"
                         alt="Details"
                         style="margin-left:3px;"/>
                  </a>
                </td>
              </tr>
            </xsl:for-each>
          </table>
        </xsl:otherwise>
      </xsl:choose>
    </div>
  </div>
</xsl:template>

<!--     EDIT_PORT_LIST -->

<xsl:template name="html-edit-port-list-form">
  <div class="gb_window">
    <div class="gb_window_part_left"></div>
    <div class="gb_window_part_right"></div>
    <div class="gb_window_part_center">Edit Port List
      <xsl:call-template name="edit-header-icons">
        <xsl:with-param name="cap-type" select="'Port List'"/>
        <xsl:with-param name="type" select="'port_list'"/>
        <xsl:with-param name="id"
                        select="commands_response/get_port_lists_response/port_list/@id"/>
      </xsl:call-template>
    </div>
    <div class="gb_window_part_content">
      <form action="" method="post" enctype="multipart/form-data">
        <input type="hidden" name="token" value="{/envelope/token}"/>
        <input type="hidden" name="cmd" value="save_port_list"/>
        <input type="hidden" name="caller" value="{/envelope/caller}"/>
        <input type="hidden"
               name="port_list_id"
               value="{commands_response/get_port_lists_response/port_list/@id}"/>
        <input type="hidden" name="next" value="{/envelope/params/next}"/>
        <input type="hidden" name="port_list" value="{/envelope/params/port_list}"/>
        <input type="hidden" name="filt_id" value="{/envelope/params/filt_id}"/>
        <table border="0" cellspacing="0" cellpadding="3" width="100%">
          <tr>
            <td valign="top" width="165">Name</td>
            <td>
              <input type="text" name="name" size="30" maxlength="80"
                     value="{commands_response/get_port_lists_response/port_list/name}"/>
            </td>
          </tr>
          <tr>
            <td valign="top" width="165">Comment (optional)</td>
            <td>
              <input type="text" name="comment" size="30" maxlength="400"
                     value="{commands_response/get_port_lists_response/port_list/comment}"/>
            </td>
          </tr>
          <tr>
            <td colspan="2" style="text-align:right;">
              <input type="submit" name="submit" value="Save Port List"/>
            </td>
          </tr>
        </table>
        <br/>
      </form>

      <h2>New port range</h2>

      <xsl:variable name="id" select="commands_response/get_port_lists_response/port_list/@id"/>
      <xsl:variable name="in_use" select="commands_response/get_port_lists_response/port_list/in_use"/>

      <form action="/omp" method="post" enctype="multipart/form-data">
        <input type="hidden" name="token" value="{/envelope/token}"/>
        <input type="hidden" name="cmd" value="create_port_range"/>
        <input type="hidden" name="caller" value="{/envelope/caller}"/>
        <input type="hidden" name="port_list_id" value="{$id}"/>
        <input type="hidden" name="next" value="edit_port_list"/>
        <table border="0" cellspacing="0" cellpadding="3" width="100%">
          <tr>
            <td valign="top">Start</td>
            <td>
              <xsl:choose>
                <xsl:when test="$in_use = 0">
                  <input type="text" name="port_range_start" value=""
                         size="30" maxlength="400"/>
                </xsl:when>
                <xsl:otherwise>
                  <input type="text" name="port_range_start" value=""
                         size="30" maxlength="400" disabled="1"/>
                </xsl:otherwise>
              </xsl:choose>
            </td>
          </tr>
          <tr>
            <td valign="top">End</td>
            <td>
              <xsl:choose>
                <xsl:when test="$in_use = 0">
                  <input type="text" name="port_range_end" value=""
                         size="30" maxlength="400"/>
                </xsl:when>
                <xsl:otherwise>
                  <input type="text" name="port_range_end" value=""
                         size="30" maxlength="400" disabled="1"/>
                </xsl:otherwise>
              </xsl:choose>
            </td>
          </tr>
          <tr>
            <td valign="top">Protocol</td>
            <td>
              <label>
                <xsl:choose>
                  <xsl:when test="$in_use = 0">
                    <input type="radio" name="port_type" value="tcp" checked="1"/>
                  </xsl:when>
                  <xsl:otherwise>
                    <input type="radio" name="port_type" value="tcp" checked="1"
                           disabled="1"/>
                  </xsl:otherwise>
                </xsl:choose>
                TCP
              </label>
              <label>
                <xsl:choose>
                  <xsl:when test="$in_use = 0">
                    <input type="radio" name="port_type" value="udp"/>
                  </xsl:when>
                  <xsl:otherwise>
                    <input type="radio" name="port_type" value="udp"
                           disabled="1"/>
                  </xsl:otherwise>
                </xsl:choose>
                UDP
              </label>
            </td>
          </tr>
          <tr>
            <td colspan="4" style="text-align:right;">
              <xsl:choose>
                <xsl:when test="$in_use = 0">
                  <input type="submit" name="submit" value="Create port range"/>
                </xsl:when>
                <xsl:otherwise>
                  <input type="submit" name="submit" value="Create port range"
                         disabled="1"/>
                </xsl:otherwise>
              </xsl:choose>
            </td>
          </tr>
        </table>
      </form>
      <h1>Port Ranges</h1>
      <table class="gbntable" cellspacing="2" cellpadding="4">
        <tr class="gbntablehead2">
          <td>Start</td>
          <td>End</td>
          <td>Protocol</td>
          <td>Actions</td>
        </tr>
        <xsl:for-each select="commands_response/get_port_lists_response/port_list/port_ranges/port_range">
          <xsl:variable name="class">
            <xsl:choose>
              <xsl:when test="position() mod 2 = 0">even</xsl:when>
              <xsl:otherwise>odd</xsl:otherwise>
            </xsl:choose>
          </xsl:variable>
          <tr class="{$class}">
            <td><xsl:value-of select="start"/></td>
            <td><xsl:value-of select="end"/></td>
            <td><xsl:value-of select="type"/></td>
            <td width="100">
              <xsl:choose>
                <xsl:when test="../../in_use = 0">
                  <xsl:call-template name="delete-icon">
                    <xsl:with-param name="type">port_range</xsl:with-param>
                    <xsl:with-param name="id" select="@id"/>
                    <xsl:with-param name="params">
                      <input type="hidden" name="port_list_id" value="{../../@id}"/>
                      <input type="hidden" name="next" value="edit_port_list"/>
                    </xsl:with-param>
                  </xsl:call-template>
                </xsl:when>
                <xsl:otherwise>
                  <img src="/img/delete_inactive.png"
                       border="0"
                       alt="Delete"
                       style="margin-left:3px;"/>
                </xsl:otherwise>
              </xsl:choose>
            </td>
          </tr>
        </xsl:for-each>
      </table>
    </div>
  </div>
</xsl:template>

<xsl:template match="edit_port_list">
  <xsl:apply-templates select="gsad_msg"/>
  <xsl:call-template name="html-edit-port-list-form"/>
</xsl:template>

<xsl:template match="create_port_range_response">
  <xsl:call-template name="command_result_dialog">
    <xsl:with-param name="operation">
      Create Port Range
    </xsl:with-param>
    <xsl:with-param name="status">
      <xsl:value-of select="@status"/>
    </xsl:with-param>
    <xsl:with-param name="msg">
      <xsl:value-of select="@status_text"/>
    </xsl:with-param>
  </xsl:call-template>
</xsl:template>

<xsl:template name="html-import-port-list-form">
  <div class="gb_window">
    <div class="gb_window_part_left"></div>
    <div class="gb_window_part_right"></div>
    <div class="gb_window_part_center">
      Import Port List
      <a href="/help/new_port_list.html?token={/envelope/token}#import_port_list"
         title="Help: New Port List">
        <img src="/img/help.png"/>
      </a>
      <a href="/omp?cmd=get_port_lists&amp;filter={str:encode-uri (/envelope/params/filter, true ())}&amp;filt_id={/envelope/params/filt_id}&amp;token={/envelope/token}"
         title="Port Lists" style="margin-left:3px;">
        <img src="/img/list.png" border="0" alt="Port Lists"/>
      </a>
    </div>
    <div class="gb_window_part_content">
      <form action="/omp" method="post" enctype="multipart/form-data">
        <input type="hidden" name="token" value="{/envelope/token}"/>
        <input type="hidden" name="cmd" value="import_port_list"/>
        <input type="hidden" name="caller" value="{/envelope/caller}"/>
        <table border="0" cellspacing="0" cellpadding="3" width="100%">
          <tr>
            <td valign="top" width="125">
              Import XML port list
            </td>
            <td><input type="file" name="xml_file" size="30"/></td>
          </tr>
          <tr>
            <td colspan="2" style="text-align:right;">
              <input type="submit" name="submit" value="Import Port List"/>
            </td>
          </tr>
        </table>
        <br/>
      </form>
    </div>
  </div>
</xsl:template>

<!--     GET_PORT_LIST -->

<xsl:template match="get_port_list">
  <xsl:apply-templates select="gsad_msg"/>
  <xsl:apply-templates select="create_port_range_response"/>
  <xsl:apply-templates select="commands_response/delete_port_list_response"/>
  <xsl:apply-templates select="commands_response/delete_port_range_response"/>
  <xsl:apply-templates select="get_port_lists_response/port_list" mode="details"/>
  <xsl:apply-templates select="commands_response/get_port_lists_response/port_list"
                       mode="details"/>
</xsl:template>

<!--     GET_PORT_LISTS -->

<xsl:template match="get_port_lists">
  <xsl:apply-templates select="gsad_msg"/>
  <xsl:apply-templates select="commands_response/delete_port_list_response"/>
  <xsl:apply-templates select="create_filter_response"/>
  <xsl:apply-templates select="create_port_list_response"/>
  <!-- The for-each makes the get_port_lists_response the current node. -->
  <xsl:for-each select="get_port_lists_response | commands_response/get_port_lists_response">
    <xsl:call-template name="html-port-lists-table"/>
  </xsl:for-each>
</xsl:template>

<xsl:template match="new_port_list">
  <xsl:apply-templates select="gsad_msg"/>
  <xsl:apply-templates select="create_port_list_response"/>
  <xsl:apply-templates select="commands_response/delete_port_list_response"/>
  <xsl:call-template name="html-create-port-list-form"/>
  <xsl:call-template name="html-import-port-list-form"/>
</xsl:template>

<!-- END PORT_LISTS MANAGEMENT -->

<!-- BEGIN REPORT FORMATS MANAGEMENT -->

<xsl:template name="html-report-formats-table">
  <xsl:call-template name="list-window">
    <xsl:with-param name="type" select="'report_format'"/>
    <xsl:with-param name="cap-type" select="'Report Format'"/>
    <xsl:with-param name="resources-summary" select="report_formats"/>
    <xsl:with-param name="resources" select="report_format"/>
    <xsl:with-param name="count" select="count (report_format)"/>
    <xsl:with-param name="filtered-count" select="report_format_count/filtered"/>
    <xsl:with-param name="full-count" select="report_format_count/text ()"/>
    <xsl:with-param name="headings" select="'Name|name Extension|extension Content&#xa0;Type|content_type Trust&#xa0;(Last&#xa0;Verified)|trust Active|active'"/>
  </xsl:call-template>
</xsl:template>

<xsl:template name="html-create-report-format-form">
  <div class="gb_window">
    <div class="gb_window_part_left"></div>
    <div class="gb_window_part_right"></div>
    <div class="gb_window_part_center">
      New Report Format
      <a href="/help/new_report_format.html?token={/envelope/token}"
         title="Help: New Report Format">
        <img src="/img/help.png"/>
      </a>
      <a href="/omp?cmd=get_report_formats&amp;filter={str:encode-uri (/envelope/params/filter, true ())}&amp;filt_id={/envelope/params/filt_id}&amp;token={/envelope/token}"
         title="Report Formats" style="margin-left:3px;">
        <img src="/img/list.png" border="0" alt="Report Formats"/>
      </a>
    </div>
    <div class="gb_window_part_content">
      <form action="/omp" method="post" enctype="multipart/form-data">
        <input type="hidden" name="token" value="{/envelope/token}"/>
        <input type="hidden" name="cmd" value="import_report_format"/>
        <input type="hidden" name="caller" value="{/envelope/caller}"/>
        <table border="0" cellspacing="0" cellpadding="3" width="100%">
          <tr>
            <td valign="top" width="125">
              Import XML report format
            </td>
            <td><input type="file" name="xml_file" size="30"/></td>
          </tr>
          <tr>
            <td colspan="2" style="text-align:right;">
              <input type="submit" name="submit" value="Import Report Format"/>
            </td>
          </tr>
        </table>
        <br/>
      </form>
    </div>
  </div>
</xsl:template>

<xsl:template match="new_report_format">
  <xsl:apply-templates select="gsad_msg"/>
  <xsl:apply-templates select="create_report_format_response"/>
  <xsl:apply-templates select="commands_response/delete_report_format_response"/>
  <xsl:call-template name="html-create-report-format-form"/>
</xsl:template>

<xsl:template match="get_report_formats_response">
</xsl:template>

<!--     CREATE_REPORT_FORMAT_RESPONSE -->

<xsl:template match="create_report_format_response">
  <xsl:call-template name="command_result_dialog">
    <xsl:with-param name="operation">Create Report Format</xsl:with-param>
    <xsl:with-param name="status">
      <xsl:value-of select="@status"/>
    </xsl:with-param>
    <xsl:with-param name="msg">
      <xsl:value-of select="@status_text"/>
    </xsl:with-param>
  </xsl:call-template>
</xsl:template>

<!--     DELETE_REPORT_FORMAT_RESPONSE -->

<xsl:template match="delete_report_format_response">
  <xsl:call-template name="command_result_dialog">
    <xsl:with-param name="operation">
      Delete Report Format
    </xsl:with-param>
    <xsl:with-param name="status">
      <xsl:value-of select="@status"/>
    </xsl:with-param>
    <xsl:with-param name="msg">
      <xsl:value-of select="@status_text"/>
    </xsl:with-param>
  </xsl:call-template>
</xsl:template>

<!--     EDITING REPORT FORMATS -->

<xsl:template name="html-edit-report-format-form">
  <div class="gb_window">
    <div class="gb_window_part_left"></div>
    <div class="gb_window_part_right"></div>
    <div class="gb_window_part_center">Edit Report Format
      <xsl:call-template name="edit-header-icons">
        <xsl:with-param name="cap-type" select="'Report Format'"/>
        <xsl:with-param name="type" select="'report_format'"/>
        <xsl:with-param name="id"
                        select="commands_response/get_report_formats_response/report_format/@id"/>
      </xsl:call-template>
    </div>
    <div class="gb_window_part_content">
      <form action="" method="post">
        <input type="hidden" name="token" value="{/envelope/token}"/>
        <input type="hidden" name="cmd" value="save_report_format"/>
        <input type="hidden" name="caller" value="{/envelope/caller}"/>
        <input type="hidden"
               name="report_format_id"
               value="{commands_response/get_report_formats_response/report_format/@id}"/>
        <input type="hidden" name="next" value="{/envelope/params/next}"/>
        <input type="hidden" name="report_format" value="{/envelope/params/report_format}"/>
        <input type="hidden" name="filt_id" value="{/envelope/params/filt_id}"/>
        <table border="0" cellspacing="0" cellpadding="3" width="100%">
          <tr>
           <td valign="top" width="165">Name</td>
           <td>
             <input type="text"
                    name="name"
                    value="{commands_response/get_report_formats_response/report_format/name}"
                    size="30"
                    maxlength="80"/>
           </td>
          </tr>
          <tr>
            <td valign="top">Summary</td>
            <td>
              <input type="text" name="summary" size="30" maxlength="400"
                     value="{commands_response/get_report_formats_response/report_format/summary}"/>
            </td>
          </tr>
          <tr>
            <td valign="top">Active</td>
            <td>
              <xsl:choose>
                <xsl:when test="commands_response/get_report_formats_response/report_format/active='1'">
                  <label>
                    <input type="radio" name="enable" value="1" checked="1"/>
                    yes
                  </label>
                  <label>
                    <input type="radio" name="enable" value="0"/>
                    no
                  </label>
                </xsl:when>
                <xsl:otherwise>
                  <label>
                    <input type="radio" name="enable" value="1"/>
                    yes
                  </label>
                  <label>
                    <input type="radio" name="enable" value="0" checked="1"/>
                    no
                  </label>
                </xsl:otherwise>
              </xsl:choose>
            </td>
          </tr>
          <xsl:for-each select="commands_response/get_report_formats_response/report_format">
            <tr>
              <td valign="top" colspan="2">
                <xsl:choose>
                  <xsl:when test="count(param) = 0">
                    <h1>Parameters: None</h1>
                  </xsl:when>
                  <xsl:otherwise>
                    <h1>Parameters:</h1>
                    <xsl:call-template name="param-edit"/>
                  </xsl:otherwise>
                </xsl:choose>
              </td>
            </tr>
          </xsl:for-each>
          <tr>
            <td colspan="2" style="text-align:right;">
              <input type="submit" name="submit" value="Save Report Format"/>
            </td>
          </tr>
        </table>
        <br/>
      </form>
    </div>
  </div>
</xsl:template>

<xsl:template match="edit_report_format">
  <xsl:apply-templates select="gsad_msg"/>
  <xsl:call-template name="html-edit-report-format-form"/>
</xsl:template>

<xsl:template match="modify_report_format_response">
  <xsl:call-template name="command_result_dialog">
    <xsl:with-param name="operation">Save Report Format</xsl:with-param>
    <xsl:with-param name="status">
      <xsl:value-of select="@status"/>
    </xsl:with-param>
    <xsl:with-param name="msg">
      <xsl:value-of select="@status_text"/>
    </xsl:with-param>
  </xsl:call-template>
</xsl:template>

<!--     REPORT_FORMAT -->

<xsl:template match="report_format">
  <xsl:variable name="class">
    <xsl:choose>
      <xsl:when test="position() mod 2 = 0">even</xsl:when>
      <xsl:otherwise>odd</xsl:otherwise>
    </xsl:choose>
  </xsl:variable>
  <tr class="{$class}">
    <td>
      <b>
        <a href="/omp?cmd=get_report_format&amp;report_format_id={@id}&amp;filter={str:encode-uri (../filters/term, true ())}&amp;filt_id={/envelope/params/filt_id}&amp;token={/envelope/token}">
          <xsl:value-of select="name"/>
        </a>
      </b>
      <xsl:choose>
        <xsl:when test="summary != ''">
          <br/>(<xsl:value-of select="summary"/>)
        </xsl:when>
        <xsl:otherwise></xsl:otherwise>
      </xsl:choose>
    </td>
    <td><xsl:value-of select="extension"/></td>
    <td><xsl:value-of select="content_type"/></td>
    <td>
      <xsl:value-of select="trust/text()"/>
      <xsl:choose>
        <xsl:when test="trust/time != ''">
          <br/>(<xsl:value-of select="concat (date:month-abbreviation (trust/time), ' ', date:day-in-month (trust/time), ' ', date:year (trust/time))"/>)
        </xsl:when>
        <xsl:otherwise></xsl:otherwise>
      </xsl:choose>
    </td>
    <td>
      <xsl:choose>
        <xsl:when test="active='0'">
          no
        </xsl:when>
        <xsl:otherwise>
          yes
        </xsl:otherwise>
      </xsl:choose>
    </td>
    <td>
      <xsl:call-template name="list-window-line-icons">
        <xsl:with-param name="cap-type" select="'Report Format'"/>
        <xsl:with-param name="type" select="'report_format'"/>
        <xsl:with-param name="id" select="@id"/>
      </xsl:call-template>
      <a href="/omp?cmd=verify_report_format&amp;report_format_id={@id}&amp;next=get_report_formats&amp;filter={str:encode-uri (../filters/term, true ())}&amp;filt_id={/envelope/params/filt_id}&amp;token={/envelope/token}"
         title="Verify Report Format"
         style="margin-left:3px;">
        <img src="/img/verify.png" border="0" alt="Verify Report Format"/>
      </a>
    </td>
  </tr>
</xsl:template>

<xsl:template match="report_format" mode="trash">
  <xsl:variable name="class">
    <xsl:choose>
      <xsl:when test="position() mod 2 = 0">even</xsl:when>
      <xsl:otherwise>odd</xsl:otherwise>
    </xsl:choose>
  </xsl:variable>
  <tr class="{$class}">
    <td>
      <b><xsl:value-of select="name"/></b>
      <xsl:choose>
        <xsl:when test="summary != ''">
          <br/>(<xsl:value-of select="summary"/>)
        </xsl:when>
        <xsl:otherwise></xsl:otherwise>
      </xsl:choose>
    </td>
    <td><xsl:value-of select="extension"/></td>
    <td><xsl:value-of select="content_type"/></td>
    <td>
      <xsl:value-of select="trust/text()"/>
      <xsl:choose>
        <xsl:when test="trust/time != ''">
          <br/>(<xsl:value-of select="concat (date:month-abbreviation (trust/time), ' ', date:day-in-month (trust/time), ' ', date:year (trust/time))"/>)
        </xsl:when>
        <xsl:otherwise></xsl:otherwise>
      </xsl:choose>
    </td>
    <td>
      <xsl:choose>
        <xsl:when test="active='0'">
          no
        </xsl:when>
        <xsl:otherwise>
          yes
        </xsl:otherwise>
      </xsl:choose>
    </td>
    <td>
      <xsl:call-template name="restore-icon">
        <xsl:with-param name="id" select="@id"/>
      </xsl:call-template>
      <xsl:call-template name="trash-delete-icon">
        <xsl:with-param name="type" select="'report_format'"/>
        <xsl:with-param name="id" select="@id"/>
      </xsl:call-template>
    </td>
  </tr>
</xsl:template>

<xsl:template name="param-edit" match="params" mode="edit">
  <div>
    <table class="gbntable" cellspacing="2" cellpadding="4">
      <tr class="gbntablehead2">
        <td>Name</td>
        <td>Value</td>
      </tr>
      <xsl:for-each select="param">
        <xsl:variable name="class">
          <xsl:choose>
            <xsl:when test="position() mod 2 = 0">even</xsl:when>
            <xsl:otherwise>odd</xsl:otherwise>
          </xsl:choose>
        </xsl:variable>
        <tr class="{$class}">
          <td>
            <xsl:value-of select="name"/>
          </td>
          <td>
            <xsl:choose>
              <xsl:when test="type/text() = 'selection'">
                <select name="preference:nvt[selection]:{name}">
                  <xsl:variable name="value">
                    <xsl:value-of select="value"/>
                  </xsl:variable>
                  <xsl:for-each select="options/option">
                    <xsl:choose>
                      <xsl:when test=". = $value">
                        <option value="{.}" selected="1"><xsl:value-of select="."/></option>
                      </xsl:when>
                      <xsl:otherwise>
                        <option value="{.}"><xsl:value-of select="."/></option>
                      </xsl:otherwise>
                    </xsl:choose>
                  </xsl:for-each>
                </select>
              </xsl:when>
              <xsl:when test="type/text() = 'boolean'">
                <xsl:choose>
                  <xsl:when test="value='0'">
                    <label>
                      <input type="radio" name="preference:nvt[radio]:{name}" value="1"/>
                      yes
                    </label>
                    <label>
                      <input type="radio" name="preference:nvt[radio]:{name}" value="0" checked="1"/>
                      no
                    </label>
                  </xsl:when>
                  <xsl:otherwise>
                    <label>
                      <input type="radio" name="preference:nvt[radio]:{name}" value="1" checked="1"/>
                      yes
                    </label>
                    <label>
                      <input type="radio" name="preference:nvt[radio]:{name}" value="0"/>
                      no
                    </label>
                  </xsl:otherwise>
                </xsl:choose>
              </xsl:when>
              <xsl:when test="type/text() = 'integer'">
                <input type="text" name="preference:nvt[string]:{name}" value="{value}" size="30"
                       maxlength="80"/>
              </xsl:when>
              <xsl:when test="type/text() = 'string'">
                <xsl:choose>
                  <xsl:when test="string-length (type/max) &gt; 0">
                    <input type="text" name="preference:nvt[string]:{name}" value="{value}"
                           size="30" maxlength="{type/max}"/>
                  </xsl:when>
                  <xsl:otherwise>
                    <input type="text" name="preference:nvt[string]:{name}" value="{value}"
                           size="30"/>
                  </xsl:otherwise>
                </xsl:choose>
              </xsl:when>
              <xsl:otherwise>
                <!-- Presume type "text". -->
                <textarea name="preference:nvt[string]:{name}" value="{value}" rows="5"
                          cols="80">
                  <xsl:value-of select="value"/>
                </textarea>
              </xsl:otherwise>
            </xsl:choose>
          </td>
        </tr>
      </xsl:for-each>
    </table>
  </div>
</xsl:template>

<xsl:template name="param-details" match="params" mode="details">
  <div id="params">
    <table class="gbntable" cellspacing="2" cellpadding="4">
      <tr class="gbntablehead2">
        <td>Name</td>
        <td>Value</td>
      </tr>
      <xsl:for-each select="param">
        <xsl:variable name="class">
          <xsl:choose>
            <xsl:when test="position() mod 2 = 0">even</xsl:when>
            <xsl:otherwise>odd</xsl:otherwise>
          </xsl:choose>
        </xsl:variable>
        <tr class="{$class}">
          <td><xsl:value-of select="name"/></td>
          <td>
            <xsl:choose>
              <xsl:when test="type/text() = 'selection'">
                <xsl:value-of select="value"/>
              </xsl:when>
              <xsl:when test="type/text() = 'boolean'">
                <xsl:choose>
                  <xsl:when test="value='0'">
                    no
                  </xsl:when>
                  <xsl:otherwise>
                    yes
                  </xsl:otherwise>
                </xsl:choose>
              </xsl:when>
              <xsl:when test="type/text() = 'integer'">
                <xsl:value-of select="value"/>
              </xsl:when>
              <xsl:when test="type/text() = 'string'">
                <xsl:value-of select="value"/>
              </xsl:when>
              <xsl:otherwise>
                <!-- Presume type "text". -->
                <pre><xsl:value-of select="value"/></pre>
              </xsl:otherwise>
            </xsl:choose>
          </td>
        </tr>
      </xsl:for-each>
    </table>
  </div>
</xsl:template>

<xsl:template match="report_format" mode="details">
  <div class="gb_window">
    <div class="gb_window_part_left"></div>
    <div class="gb_window_part_right"></div>
    <div class="gb_window_part_center">
       Report Format Details
      <xsl:call-template name="details-header-icons">
        <xsl:with-param name="cap-type" select="'Report Format'"/>
        <xsl:with-param name="type" select="'report_format'"/>
      </xsl:call-template>
    </div>
    <div class="gb_window_part_content">
      <xsl:call-template name="minor-details"/>
      <table>
        <tr>
          <td><b>Name:</b></td>
          <td><b><xsl:value-of select="name"/></b></td>
        </tr>
        <tr>
          <td>Extension:</td>
          <td><xsl:value-of select="extension"/></td>
        </tr>
        <tr>
          <td>Content Type:</td>
          <td><xsl:value-of select="content_type"/></td>
        </tr>
        <tr>
          <td>Trust:</td>
          <td><xsl:value-of select="trust/text()"/></td>
        </tr>
        <tr>
          <td>Active:</td>
          <td>
            <xsl:choose>
              <xsl:when test="active='0'">
                no
              </xsl:when>
              <xsl:otherwise>
                yes
              </xsl:otherwise>
            </xsl:choose>
          </td>
        </tr>
        <tr>
          <td>Summary:</td>
          <td><xsl:value-of select="summary"/></td>
        </tr>
      </table>
      <h1>Description:</h1>
      <pre><xsl:value-of select="description"/></pre>
      <xsl:choose>
        <xsl:when test="count(param) = 0">
          <h1>Parameters: None</h1>
        </xsl:when>
        <xsl:otherwise>
          <h1>Parameters:</h1>
          <xsl:call-template name="param-details"/>
        </xsl:otherwise>
      </xsl:choose>

      <xsl:choose>
        <xsl:when test="count(alerts/alert) = 0">
          <h1>Alerts using this Report Format: None</h1>
        </xsl:when>
        <xsl:otherwise>
          <h1>Alerts using this Reporot Format</h1>
          <table class="gbntable" cellspacing="2" cellpadding="4">
            <tr class="gbntablehead2">
              <td>Name</td>
              <td>Actions</td>
            </tr>
            <xsl:for-each select="alerts/alert">
              <xsl:variable name="class">
                <xsl:choose>
                  <xsl:when test="position() mod 2 = 0">even</xsl:when>
                  <xsl:otherwise>odd</xsl:otherwise>
                </xsl:choose>
              </xsl:variable>
              <tr class="{$class}">
                <td><xsl:value-of select="name"/></td>
                <td width="100">
                  <a href="/omp?cmd=get_alert&amp;alert_id={@id}&amp;token={/envelope/token}" title="Details">
                    <img src="/img/details.png"
                         border="0"
                         alt="Details"
                         style="margin-left:3px;"/>
                  </a>
                </td>
              </tr>
            </xsl:for-each>
          </table>
        </xsl:otherwise>
      </xsl:choose>
    </div>
  </div>
</xsl:template>

<!--     GET_REPORT_FORMAT -->

<xsl:template match="get_report_format">
  <xsl:apply-templates select="gsad_msg"/>
  <xsl:apply-templates select="commands_response/delete_report_format_response"/>
  <xsl:apply-templates select="get_report_formats_response/report_format" mode="details"/>
</xsl:template>

<xsl:template match="verify_report_format_response">
  <xsl:call-template name="command_result_dialog">
    <xsl:with-param name="operation">Verify Report Format</xsl:with-param>
    <xsl:with-param name="status">
      <xsl:value-of select="@status"/>
    </xsl:with-param>
    <xsl:with-param name="msg">
      <xsl:value-of select="@status_text"/>
    </xsl:with-param>
  </xsl:call-template>
</xsl:template>

<!--     GET_REPORT_FORMATS -->

<xsl:template match="get_report_formats">
  <xsl:apply-templates select="gsad_msg"/>
  <xsl:apply-templates select="delete_report_format_response"/>
  <xsl:apply-templates select="create_filter_response"/>
  <xsl:apply-templates select="create_report_format_response"/>
  <xsl:apply-templates select="verify_report_format_response"/>
  <!-- The for-each makes the get_report_formats_response the current node. -->
  <xsl:for-each select="get_report_formats_response | commands_response/get_report_formats_response">
    <xsl:choose>
      <xsl:when test="substring(@status, 1, 1) = '4' or substring(@status, 1, 1) = '5'">
        <xsl:call-template name="command_result_dialog">
          <xsl:with-param name="operation">
            Get Report Formats
          </xsl:with-param>
          <xsl:with-param name="status">
            <xsl:value-of select="@status"/>
          </xsl:with-param>
          <xsl:with-param name="msg">
            <xsl:value-of select="@status_text"/>
          </xsl:with-param>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="html-report-formats-table"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:for-each>
</xsl:template>

<!-- END REPORT FORMATS MANAGEMENT -->

<!-- BEGIN REPORT DETAILS -->

<xsl:template match="get_reports_response">
  <xsl:choose>
    <xsl:when test="substring(@status, 1, 1) = '4' or substring(@status, 1, 1) = '5'">
      <xsl:call-template name="command_result_dialog">
        <xsl:with-param name="operation">
          Get Report
        </xsl:with-param>
        <xsl:with-param name="status">
          <xsl:value-of select="@status"/>
        </xsl:with-param>
        <xsl:with-param name="msg">
          <xsl:value-of select="@status_text"/>
        </xsl:with-param>
      </xsl:call-template>
    </xsl:when>
    <xsl:otherwise>
      <xsl:for-each select="report">
        <xsl:choose>
          <xsl:when test="@type = 'assets'">
            <xsl:call-template name="assets"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:call-template name="html-report-details"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:for-each>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template match="host">
  <xsl:variable name="apply-overrides" select="../filters/apply_overrides"/>
  <xsl:if test="../@scap_loaded = 0">
    <xsl:call-template name="error_window">
      <xsl:with-param name="heading">Warning: SCAP Database Missing</xsl:with-param>
      <xsl:with-param name="message">
        SCAP database missing on OMP server.  Prognostic reporting disabled.
        <a href="/help/hosts.html?token={/envelope/token}#scap_missing"
           title="Help: SCAP database missing">
          <img style="margin-left:5px" src="/img/help.png"/>
        </a>
      </xsl:with-param>
    </xsl:call-template>
    <br/>
  </xsl:if>
  <div class="gb_window">
    <div class="gb_window_part_left"></div>
    <div class="gb_window_part_right"></div>
    <div class="gb_window_part_center">
       Host Details
       <a href="/help/hosts.html?token={/envelope/token}#host_details"
         title="Help: Hosts (Host Details)">
         <img src="/img/help.png"/>
       </a>
      <xsl:choose>
        <xsl:when test="../@scap_loaded = 0">
          <img src="/img/prognosis_inactive.png" border="0" alt="Prognostic Report"
               style="margin-left:3px;"/>
        </xsl:when>
        <xsl:otherwise>
           <a href="/omp?cmd=get_report&amp;type=prognostic&amp;host={ip}&amp;pos={detail[name/text() = 'report/pos']/value}&amp;host_search_phrase={../../../../search_phrase}&amp;host_levels={../../../../levels}&amp;host_first_result={../../../../hosts/@start}&amp;host_max_results={../../../../hosts/@max}&amp;result_hosts_only=1&amp;token={/envelope/token}"
              title="Prognostic Report" style="margin-left:3px;">
             <img src="/img/prognosis.png" border="0" alt="Prognostic Report"/>
           </a>
        </xsl:otherwise>
      </xsl:choose>
      <div id="small_inline_form" style="display: inline; margin-left: 40px; font-weight: normal;">
        <form action="" method="get">
          <input type="hidden" name="token" value="{/envelope/token}"/>
          <input type="hidden" name="cmd" value="get_report"/>
          <input type="hidden" name="type" value="assets"/>
          <input type="hidden" name="pos" value="{detail[name/text() = 'report/pos']/value}"/>
          <input type="hidden" name="host" value="{ip}"/>
          <input type="hidden" name="levels" value="{../../../../levels}"/>
          <input type="hidden" name="search_phrase" value="{../../../../search_phrase}"/>
          <!-- Switch back to the first page if the override state changes, because
               this could lead to changes in the number of hosts in the table. -->
          <input type="hidden" name="first_result" value="1"/>
          <input type="hidden" name="max_results" value="{../../../../hosts/@max}"/>
          <select style="margin-bottom: 0px;" name="overrides" size="1">
            <xsl:choose>
              <xsl:when test="$apply-overrides = 0">
                <option value="0" selected="1">&#8730;No overrides</option>
                <option value="1" >Apply overrides</option>
              </xsl:when>
              <xsl:otherwise>
                <option value="0">No overrides</option>
                <option value="1" selected="1">&#8730;Apply overrides</option>
              </xsl:otherwise>
            </xsl:choose>
          </select>
          <input type="image"
                 name="Update"
                 src="/img/refresh.png"
                 alt="Update" style="margin-left:3px;margin-right:3px;"/>
        </form>
      </div>
    </div>
    <div class="gb_window_part_content">
      <xsl:variable name="report_count" select="detail[name = 'report_count' and source/name = 'openvasmd']/value"/>
      <div class="float_right">
        <a href="?cmd=get_report&amp;type=assets&amp;levels={../../../../levels}&amp;search_phrase={../../../../search_phrase}&amp;first_result={../../../../hosts/@start}&amp;max_results={../../../../hosts/@max}&amp;overrides={$apply-overrides}&amp;token={/envelope/token}">Hosts</a>
      </div>
      <table>
        <tr>
          <td><b>Host:</b></td>
          <td>
            <xsl:variable name="hostname" select="detail[name/text() = 'hostname']/value"/>
            <b><xsl:value-of select="ip"/></b>
            <xsl:if test="$hostname">
              <xsl:value-of select="concat(' (', $hostname, ')')"/>
            </xsl:if>
          </td>
        </tr>
        <tr>
          <td>Report:</td>
          <td>
            <xsl:variable name="pos" select="detail[name/text() = 'report/pos']/value"/>
            <xsl:choose>
              <xsl:when test="$pos &lt; $report_count">
                <a href="/omp?cmd=get_report&amp;type=assets&amp;host={ip}&amp;pos={$pos + 1}&amp;levels={../../../../levels}&amp;search_phrase={../../../../search_phrase}&amp;first_result={../../../../hosts/@start}&amp;max_results={../../../../hosts/@max}&amp;overrides={$apply-overrides}&amp;token={/envelope/token}">
                  &lt;&lt;
                </a>
              </xsl:when>
            </xsl:choose>
            <xsl:choose>
              <xsl:when test="start/text() != ''">
                <a style="margin-left: 5px; margin-right: 5px;" href="/omp?cmd=get_report&amp;report_id={detail[name = 'report/@id' and source/name = 'openvasmd']/value}&amp;filter==&#34;{ip}&#34; notes=1 overrides=1 result_hosts_only=1 levels=hm&amp;token={/envelope/token}">
                  <xsl:value-of select="concat (date:month-abbreviation (start/text()), ' ', date:day-in-month (start/text()), ' ', date:year (start/text()))"/>
                </a>
              </xsl:when>
              <xsl:otherwise>(not finished)</xsl:otherwise>
            </xsl:choose>
            <xsl:choose>
              <xsl:when test="$pos &gt; 1">
                <a href="/omp?cmd=get_report&amp;type=assets&amp;host={ip}&amp;pos={$pos - 1}&amp;levels={../../../../levels}&amp;search_phrase={../../../../search_phrase}&amp;first_result={../../../../hosts/@start}&amp;max_results={../../../../hosts/@max}&amp;overrides={$apply-overrides}&amp;token={/envelope/token}">
                  &gt;&gt;
                </a>
              </xsl:when>
            </xsl:choose>
          </td>
        </tr>
        <tr>
          <td>Reports:</td>
          <td>
            <xsl:value-of select="$report_count"/>
          </td>
        </tr>
        <tr>
          <td><img src="/img/high.png" alt="High" title="High"/>:</td>
          <td>
            <xsl:value-of select="detail[name/text() = 'report/result_count/high']/value"/>
          </td>
        </tr>
        <tr>
          <td><img src="/img/medium.png" alt="Medium" title="Medium"/>:</td>
          <td>
            <xsl:value-of select="detail[name/text() = 'report/result_count/medium']/value"/>
          </td>
        </tr>
        <tr>
          <td><img src="/img/low.png" alt="Low" title="Low"/>:</td>
          <td>
            <xsl:value-of select="detail[name/text() = 'report/result_count/low']/value"/>
          </td>
        </tr>
        <tr>
          <td>OS:</td>
          <td>
            <xsl:call-template name="os-icon">
              <xsl:with-param name="host" select="../host"/>
              <xsl:with-param name="current_host" select="ip"/>
            </xsl:call-template>
          </td>
        </tr>
        <xsl:variable name="tcp_ports" select="detail[name/text() = 'ports']/value"/>
        <xsl:variable name="udp_ports" select="detail[name/text() = 'udp_ports']/value"/>
        <tr>
          <td>Open Ports:</td>
          <td>
            <xsl:value-of select="count (str:tokenize ($tcp_ports, ',')) + count (str:tokenize ($udp_ports, ','))"/>
          </td>
        </tr>
        <tr>
          <td>Open TCP Ports:</td>
          <td>
            <xsl:value-of select="count (str:tokenize ($tcp_ports, ','))"/>
            <xsl:if test="$tcp_ports">
              <xsl:value-of select="concat(' (', $tcp_ports, ')')"/>
            </xsl:if>
          </td>
        </tr>
        <tr>
          <td>Open UDP Ports:</td>
          <td>
            <xsl:value-of select="count (str:tokenize ($udp_ports, ','))"/>
            <xsl:if test="$udp_ports">
              <xsl:value-of select="concat(' (', $udp_ports, ')')"/>
            </xsl:if>
          </td>
        </tr>
        <tr>
          <td>Apps:</td>
          <td>
            <xsl:value-of select="count (detail[name = 'App'])"/>
          </td>
        </tr>
        <tr>
          <td>Distance:</td>
          <td>
            <xsl:choose>
              <xsl:when test="substring-after (detail[name = 'traceroute']/value, ',') = '?'">
              </xsl:when>
              <xsl:when test="count (detail[name = 'traceroute']) = 0">
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="count (str:tokenize (detail[name = 'traceroute']/value, ',')) - 1"/>
              </xsl:otherwise>
            </xsl:choose>
          </td>
        </tr>
      </table>
      <xsl:choose>
        <xsl:when test="count (detail[name = 'cpuinfo']) = 0 and count (detail[name = 'meminfo']) = 0 and count (detail[name = 'netinfo']) = 0 and count (detail[name = 'MAC']) = 0 and count (detail[name = 'NIC']) = 0 and count (detail[name = 'MAC-Ifaces']) = 0">
          <h1>Hardware: Information not available</h1>
        </xsl:when>
        <xsl:otherwise>
          <h1>Hardware</h1>
          <table class="gbntable" cellspacing="2" cellpadding="4">
            <tr class="gbntablehead2">
              <td>Component</td>
              <td>Values</td>
            </tr>
            <xsl:if test="count (detail[name = 'cpuinfo']) > 0">
              <tr>
                <td>CPU</td>
                <td><xsl:value-of select="detail[name = 'cpuinfo']/value"/></td>
              </tr>
            </xsl:if>
            <xsl:if test="count (detail[name = 'meminfo']) > 0">
              <tr>
                <td>Memory</td>
                <td><xsl:value-of select="detail[name = 'meminfo']/value"/></td>
              </tr>
            </xsl:if>
            <xsl:if test="count (detail[name = 'NIC']) > 0">
              <tr>
                <td>Target-Interface</td>
                <td valign="top"><xsl:value-of select="detail[name = 'NIC']/value"/></td>
              </tr>
            </xsl:if>
            <xsl:if test="count (detail[name = 'NIC_IPS']) > 0">
              <tr>
                <td valign="top"><xsl:if test="count (detail[name = 'NIC']) > 0"><xsl:value-of select="detail[name = 'NIC']/value"/></xsl:if> IPs</td>
                <td><table>
                    <xsl:for-each select="str:split(detail[name = 'NIC_IPS']/value, ';')">
                      <tr><td><xsl:value-of select="."/></td></tr>
                    </xsl:for-each>
                  </table></td>
              </tr>
            </xsl:if>
            <xsl:if test="count (detail[name = 'MAC']) > 0">
              <tr>
                <td><xsl:if test="count (detail[name = 'NIC']) > 0"><xsl:value-of select="detail[name = 'NIC']/value"/></xsl:if> MAC</td>
                <td><xsl:value-of select="detail[name = 'MAC']/value"/></td>
              </tr>
            </xsl:if>
            <xsl:if test="count (detail[name = 'MAC-Ifaces']) > 0">
              <tr>
                <td valign="top">Other MACs</td>
                <td>
                  <table>
                    <xsl:for-each select="detail[name = 'MAC-Ifaces']/value">
                      <tr><td><xsl:value-of select="."/></td></tr>
                    </xsl:for-each>
                  </table>
                </td>
              </tr>
            </xsl:if>
            <xsl:if test="count (detail[name = 'netinfo']) > 0">
              <tr>
                <td>Netinfo dump</td>
                <td>
                  <table>
                    <xsl:for-each select="str:split(detail[name = 'netinfo']/value, '\n')">
                      <tr><td><xsl:value-of select="."/></td></tr>
                    </xsl:for-each>
                  </table>
                </td>
              </tr>
            </xsl:if>
          </table>
        </xsl:otherwise>
      </xsl:choose>

      <xsl:choose>
        <xsl:when test="count (detail[name = 'App']) = 0">
          <h1>Apps: None</h1>
        </xsl:when>
        <xsl:otherwise>
          <h1>Detected Applications</h1>
          <table class="gbntable" cellspacing="2" cellpadding="4">
            <tr class="gbntablehead2">
              <td rowspan="2">CPE</td>
              <td colspan="4">
                Prognosis
                <xsl:variable name="threat"
                              select="detail[name = 'prognosis']/value"/>
                <xsl:choose>
                  <xsl:when test="$threat = 'High'">
                    <img src="/img/high.png" alt="High" title="High"/>
                  </xsl:when>
                  <xsl:when test="$threat = 'Medium'">
                    <img src="/img/medium.png" alt="Medium" title="Medium"/>
                  </xsl:when>
                  <xsl:when test="$threat = 'Low'">
                    <img src="/img/low.png" alt="Low" title="Low"/>
                  </xsl:when>
                  <xsl:when test="$threat = 'Log'">
                    <img src="/img/log.png" alt="Log" title="Log"/>
                  </xsl:when>
                </xsl:choose>
              </td>
            </tr>
            <tr class="gbntablehead2">
              <td style="font-size:10px;">Threat</td>
              <td style="font-size:10px;width:104px">CVSS</td>
              <td style="font-size:10px;">CVE</td>
              <td style="font-size:10px;">Threats</td>
            </tr>
            <xsl:for-each select="detail[name = 'App']">
              <xsl:variable name="class">
                <xsl:choose>
                  <xsl:when test="position() mod 2 = 0">even</xsl:when>
                  <xsl:otherwise>odd</xsl:otherwise>
                </xsl:choose>
              </xsl:variable>
              <xsl:variable name="app" select="value"/>
              <tr class="{$class}">
                <xsl:variable name="cve"
                              select="../detail[name = concat ($app, '/CVE')]/value"/>
                <xsl:variable name="threats"
                              select="count (../detail[name = concat ($app, '/CVE')])"/>
                <xsl:variable name="cvss"
                              select="../detail[name = concat ($app, '/', $cve, '/CVSS')]/value"/>
                <td>
                  <xsl:call-template name="get_info_cpe_lnk">
                    <xsl:with-param name="cpe" select="$app"/>
                  </xsl:call-template>
                </td>
                <td>
                  <xsl:variable name="threat"
                                select="../detail[name = concat ($app, '/threat')]/value"/>
                  <xsl:choose>
                    <xsl:when test="$threat = 'High'">
                      <img src="/img/high.png" alt="High" title="High"/>
                    </xsl:when>
                    <xsl:when test="$threat = 'Medium'">
                      <img src="/img/medium.png" alt="Medium" title="Medium"/>
                    </xsl:when>
                    <xsl:when test="$threat = 'Low'">
                      <img src="/img/low.png" alt="Low" title="Low"/>
                    </xsl:when>
                    <xsl:when test="$threat = 'Log'">
                      <img src="/img/log.png" alt="Log" title="Log"/>
                    </xsl:when>
                  </xsl:choose>
                </td>
                <td>
                  <xsl:if test="$cvss &gt;= 0.0">
                    <xsl:call-template name="severity-bar">
                      <xsl:with-param name="cvss" select="$cvss"/>
                    </xsl:call-template>
                  </xsl:if>
                </td>
                <td>
                  <xsl:call-template name="get_info_cve_lnk">
                    <xsl:with-param name="cve" select="$cve"/>
                  </xsl:call-template>
                </td>
                <td>
                  <a href="/omp?cmd=get_info&amp;info_type=cpe&amp;info_name={$app}&amp;token={/envelope/token}"
                     title="Details">
                    <xsl:choose>
                      <xsl:when test="$threats &gt; 0">
                        <xsl:value-of select="$threats"/>
                      </xsl:when>
                    </xsl:choose>
                  </a>
                </td>
              </tr>
            </xsl:for-each>
          </table>
        </xsl:otherwise>
      </xsl:choose>
<!--
      <h1>All host details</h1>
      <table class="gbntable" cellspacing="2" cellpadding="4">
        <tr class="gbntablehead2">
          <td>Name</td>
          <td>Value</td>
          <td>Source Type</td>
          <td>Source Name</td>
          <td>Source Description</td>
        </tr>
        <xsl:for-each select="detail">
          <tr>
            <td><xsl:value-of select="name"/></td>
            <td><xsl:value-of select="value"/></td>
            <td><xsl:value-of select="source/type"/></td>
            <td><xsl:value-of select="source/name"/></td>
            <td><xsl:value-of select="source/description"/></td>
          </tr>
        </xsl:for-each>
      </table>
-->
    </div>
  </div>
</xsl:template>

<xsl:template match="get_reports_response" mode="asset">
  <xsl:choose>
    <xsl:when test="substring(@status, 1, 1) = '4' or substring(@status, 1, 1) = '5'">
      <xsl:call-template name="command_result_dialog">
        <xsl:with-param name="operation">
          Get Report
        </xsl:with-param>
        <xsl:with-param name="status">
          <xsl:value-of select="@status"/>
        </xsl:with-param>
        <xsl:with-param name="msg">
          <xsl:value-of select="@status_text"/>
        </xsl:with-param>
      </xsl:call-template>
    </xsl:when>
    <xsl:otherwise>
      <xsl:apply-templates select="report/report/host"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template match="get_report">
  <xsl:apply-templates select="create_note_response"/>
  <xsl:apply-templates select="create_override_response"/>
  <xsl:apply-templates select="create_filter_response"/>
  <xsl:apply-templates select="gsad_msg"/>
  <xsl:apply-templates select="get_reports_alert_response"/>
  <xsl:apply-templates select="get_reports_response"/>
</xsl:template>

<xsl:template match="get_asset">
  <xsl:apply-templates select="gsad_msg"/>
  <xsl:apply-templates select="get_reports_response" mode="asset"/>
</xsl:template>

<xsl:template match="get_prognostic_report">
  <xsl:apply-templates select="gsad_msg"/>
  <xsl:apply-templates select="get_reports_response"/>
</xsl:template>

<!--     CREATE_NOTE_RESPONSE -->

<xsl:template match="create_note_response">
  <xsl:call-template name="command_result_dialog">
    <xsl:with-param name="operation">
      Create Note
    </xsl:with-param>
    <xsl:with-param name="status">
      <xsl:value-of select="@status"/>
    </xsl:with-param>
    <xsl:with-param name="msg">
      <xsl:value-of select="@status_text"/>
    </xsl:with-param>
  </xsl:call-template>
</xsl:template>

<!--     CREATE_OVERRIDE_RESPONSE -->

<xsl:template match="create_override_response">
  <xsl:call-template name="command_result_dialog">
    <xsl:with-param name="operation">
      Create Override
    </xsl:with-param>
    <xsl:with-param name="status">
      <xsl:value-of select="@status"/>
    </xsl:with-param>
    <xsl:with-param name="msg">
      <xsl:value-of select="@status_text"/>
    </xsl:with-param>
  </xsl:call-template>
</xsl:template>

<!--     DELETE_NOTE_RESPONSE -->

<xsl:template match="delete_note_response">
  <xsl:call-template name="command_result_dialog">
    <xsl:with-param name="operation">
      Delete Note
    </xsl:with-param>
    <xsl:with-param name="status">
      <xsl:value-of select="@status"/>
    </xsl:with-param>
    <xsl:with-param name="msg">
      <xsl:value-of select="@status_text"/>
    </xsl:with-param>
  </xsl:call-template>
</xsl:template>

<!--     DELETE_OVERRIDE_RESPONSE -->

<xsl:template match="delete_override_response">
  <xsl:call-template name="command_result_dialog">
    <xsl:with-param name="operation">
      Delete Override
    </xsl:with-param>
    <xsl:with-param name="status">
      <xsl:value-of select="@status"/>
    </xsl:with-param>
    <xsl:with-param name="msg">
      <xsl:value-of select="@status_text"/>
    </xsl:with-param>
  </xsl:call-template>
</xsl:template>

<!--     NOTE -->

<xsl:template name="note-detailed" match="note" mode="detailed">
  <xsl:param name="note-buttons">1</xsl:param>
  <xsl:param name="delta"/>
  <xsl:param name="next">get_report</xsl:param>
  <div class="note_box_box">
    <b>Note</b><xsl:if test="$delta and $delta &gt; 0"> (Result <xsl:value-of select="$delta"/>)</xsl:if><br/>
    <pre>
      <xsl:call-template name="wrap">
        <xsl:with-param name="string"><xsl:value-of select="text"/></xsl:with-param>
      </xsl:call-template>
    </pre>
    <div>
      <xsl:choose>
        <xsl:when test="active='0'">
        </xsl:when>
        <xsl:when test="active='1' and string-length (end_time) &gt; 0">
          Active until:
          <xsl:value-of select="gsa:long-time (end_time)"/>.
        </xsl:when>
        <xsl:otherwise>
        </xsl:otherwise>
      </xsl:choose>
    </div>
    <xsl:if test="$note-buttons = 1">
      <div class="float_right" style="text-align:right">
        <div style="display: inline">
          <xsl:call-template name="trashcan-icon">
            <xsl:with-param name="type" select="'note'"/>
            <xsl:with-param name="id" select="@id"/>
            <xsl:with-param name="fragment" select="concat ('#result-', ../../@id)"/>
            <xsl:with-param name="params">
              <input type="hidden" name="filter" value="{/envelope/params/filter}"/>
              <input type="hidden" name="filt_id" value="{/envelope/params/filt_id}"/>
              <xsl:choose>
                <xsl:when test="$next='get_result'">
                  <input type="hidden" name="report_result_id" value="{/envelope/params/report_result_id}"/>
                  <xsl:choose>
                    <xsl:when test="$delta = 1">
                      <input type="hidden" name="report_id" value="{../../../../../@id}"/>
                      <input type="hidden" name="result_id" value="{../../@id}"/>
                      <input type="hidden" name="task_id" value="{../../../../task/@id}"/>
                      <input type="hidden" name="name" value="{../../../../task/name}"/>
                      <input type="hidden" name="apply_overrides" value="{/envelope/params/apply_overrides}"/>
                      <input type="hidden" name="overrides" value="{/envelope/params/apply_overrides}"/>
                      <input type="hidden" name="autofp" value="{/envelope/params/autofp}"/>
                      <input type="hidden" name="delta_report_id" value="{../../../../delta/report/@id}"/>
                      <input type="hidden" name="delta_states" value="{../../../../filters/delta/text()}"/>
                      <input type="hidden" name="next" value="get_report"/>
                    </xsl:when>
                    <xsl:when test="$delta = 2">
                      <input type="hidden" name="report_id" value="{../../../../../@id}"/>
                      <input type="hidden" name="result_id" value="{../../../@id}"/>
                      <input type="hidden" name="task_id" value="{../../../../../task/@id}"/>
                      <input type="hidden" name="name" value="{../../../../../task/name}"/>
                      <input type="hidden" name="apply_overrides" value="{/envelope/params/apply_overrides}"/>
                      <input type="hidden" name="overrides" value="{/envelope/params/apply_overrides}"/>
                      <input type="hidden" name="autofp" value="{/envelope/params/autofp}"/>
                      <input type="hidden" name="delta_report_id" value="{../../../../../delta/report/@id}"/>
                      <input type="hidden" name="delta_states" value="{../../../../../filters/delta/text()}"/>
                      <input type="hidden" name="next" value="get_report"/>
                    </xsl:when>
                    <xsl:otherwise>
                      <input type="hidden" name="report_id" value="{../../../../../../report/@id}"/>
                      <input type="hidden" name="result_id" value="{../../@id}"/>
                      <input type="hidden" name="task_id" value="{../../../../../../task/@id}"/>
                      <input type="hidden" name="name" value="{../../../../../../task/name}"/>
                      <input type="hidden" name="apply_overrides" value="{/envelope/params/apply_overrides}"/>
                      <input type="hidden" name="autofp" value="{/envelope/params/autofp}"/>
                      <input type="hidden" name="next" value="get_result"/>
                    </xsl:otherwise>
                  </xsl:choose>
                </xsl:when>
                <xsl:otherwise>
                  <input type="hidden" name="overrides" value="{/envelope/params/overrides}"/>
                  <input type="hidden" name="next" value="get_report"/>
                  <xsl:choose>
                    <xsl:when test="$delta = 1">
                      <input type="hidden" name="report_id" value="{../../../../@id}"/>
                      <input type="hidden" name="delta_report_id" value="{../../../../delta/report/@id}"/>
                      <input type="hidden" name="delta_states" value="{../../../../filters/delta/text()}"/>
                    </xsl:when>
                    <xsl:when test="$delta = 2">
                      <input type="hidden" name="report_id" value="{../../../../../@id}"/>
                      <input type="hidden" name="delta_report_id" value="{../../../../../delta/report/@id}"/>
                      <input type="hidden" name="delta_states" value="{../../../../../filters/delta/text()}"/>
                    </xsl:when>
                    <xsl:otherwise>
                      <input type="hidden" name="report_id" value="{../../../../@id}"/>
                    </xsl:otherwise>
                  </xsl:choose>
                </xsl:otherwise>
              </xsl:choose>
            </xsl:with-param>
          </xsl:call-template>
        </div>
        <a href="/omp?cmd=get_note&amp;note_id={@id}&amp;token={/envelope/token}"
           title="Note Details" style="margin-left:3px;">
          <img src="/img/details.png" border="0" alt="Details"/>
        </a>
        <xsl:choose>
          <xsl:when test="$next='get_result' and $delta = 1">
            <a href="/omp?cmd=edit_note&amp;note_id={@id}&amp;next=get_report&amp;result_id={../../@id}&amp;task_id={../../../../task/@id}&amp;name={../../../../task/name}&amp;report_id={../../../../../report/@id}&amp;overrides={../../../../filters/apply_overrides}&amp;delta_report_id={../../../../delta/report/@id}&amp;apply_overrides={/envelope/params/apply_overrides}&amp;filter={str:encode-uri (/envelope/params/filter, true ())}&amp;filt_id={/envelope/params/filt_id}&amp;autofp={/envelope/params/autofp}&amp;report_result_id={/envelope/params/report_result_id}&amp;token={/envelope/token}"
               title="Edit Note"
               style="margin-left:3px;">
              <img src="/img/edit.png" border="0" alt="Edit"/>
            </a>
          </xsl:when>
          <xsl:when test="$next='get_result' and $delta = 2">
            <a href="/omp?cmd=edit_note&amp;note_id={@id}&amp;next=get_report&amp;result_id={../../../@id}&amp;task_id={../../../../../task/@id}&amp;name={../../../../../task/name}&amp;report_id={../../../../../@id}&amp;overrides={../../../../../filters/apply_overrides}&amp;delta_report_id={../../../../../delta/report/@id}&amp;apply_overrides={/envelope/params/apply_overrides}&amp;filter={str:encode-uri (/envelope/params/filter, true ())}&amp;filt_id={/envelope/params/filt_id}&amp;autofp={/envelope/params/autofp}&amp;report_result_id={/envelope/params/report_result_id}&amp;token={/envelope/token}"
               title="Edit Note"
               style="margin-left:3px;">
              <img src="/img/edit.png" border="0" alt="Edit"/>
            </a>
          </xsl:when>
          <xsl:when test="$next='get_result'">
            <a href="/omp?cmd=edit_note&amp;note_id={@id}&amp;next=get_result&amp;result_id={../../@id}&amp;task_id={../../../../../../task/@id}&amp;name={../../../../../../task/name}&amp;report_id={../../../../../../report/@id}&amp;overrides={/envelope/params/overrides}&amp;apply_overrides={/envelope/params/apply_overrides}&amp;filter={str:encode-uri (/envelope/params/filter, true ())}&amp;filt_id={/envelope/params/filt_id}&amp;autofp={/envelope/params/autofp}&amp;report_result_id={/envelope/params/report_result_id}&amp;token={/envelope/token}"
               title="Edit Note"
               style="margin-left:3px;">
              <img src="/img/edit.png" border="0" alt="Edit"/>
            </a>
          </xsl:when>
          <xsl:when test="$delta = 1">
            <a href="/omp?cmd=edit_note&amp;a=a&amp;note_id={@id}&amp;next=get_report&amp;report_id={../../../../../@id}&amp;overrides={../../../../filters/apply_overrides}&amp;delta_report_id={../../../../delta/report/@id}&amp;autofp={/envelope/params/autofp}&amp;apply_overrides={/envelope/params/apply_overrides}&amp;filter={str:encode-uri (/envelope/params/filter, true ())}&amp;filt_id={/envelope/params/filt_id}&amp;report_result_id={../../@id}&amp;token={/envelope/token}"
               title="Edit Note"
               style="margin-left:3px;">
              <img src="/img/edit.png" border="0" alt="Edit"/>
            </a>
          </xsl:when>
          <xsl:when test="$delta = 2">
            <a href="/omp?cmd=edit_note&amp;a=a&amp;note_id={@id}&amp;next=get_report&amp;report_id={../../../../../@id}&amp;overrides={../../../../../filters/apply_overrides}&amp;delta_report_id={../../../../../delta/report/@id}&amp;delta_states={../../../../../filters/delta/text()}&amp;autofp={../../../../../../filters/autofp}&amp;apply_overrides={/envelope/params/apply_overrides}&amp;filter={str:encode-uri (/envelope/params/filter, true ())}&amp;filt_id={/envelope/params/filt_id}&amp;report_result_id={../../@id}&amp;token={/envelope/token}"
               title="Edit Note"
               style="margin-left:3px;">
              <img src="/img/edit.png" border="0" alt="Edit"/>
            </a>
          </xsl:when>
          <xsl:otherwise>
            <a href="/omp?cmd=edit_note&amp;note_id={@id}&amp;next=get_report&amp;report_id={../../../../@id}&amp;result_id={../../@id}&amp;filter={str:encode-uri (/envelope/params/filter, true ())}&amp;filt_id={/envelope/params/filt_id}&amp;overrides={../../../../filters/apply_overrides}&amp;report_result_id={../../@id}&amp;token={/envelope/token}"
               title="Edit Note"
               style="margin-left:3px;">
              <img src="/img/edit.png" border="0" alt="Edit"/>
            </a>
          </xsl:otherwise>
        </xsl:choose>
        <div style="display: inline">
          <form style="display: inline; font-size: 0px; margin-left: 3px" action="/omp#result-{../../@id}" method="post" enctype="multipart/form-data">
            <input type="hidden" name="token" value="{/envelope/token}"/>
            <input type="hidden" name="caller" value="{/envelope/caller}"/>
            <input type="hidden" name="cmd" value="clone"/>
            <input type="hidden" name="resource_type" value="note"/>
            <input type="hidden" name="id" value="{@id}"/>
            <input type="hidden" name="filter" value="{/envelope/params/filter}"/>
            <input type="hidden" name="filt_id" value="{/envelope/params/filt_id}"/>
            <input type="hidden" name="autofp" value="{/envelope/params/autofp}"/>
            <input type="hidden" name="apply_overrides" value="{/envelope/params/apply_overrides}"/>
            <input type="hidden" name="overrides" value="{/envelope/params/overrides}"/>
            <input type="image" src="/img/clone.png" alt="Clone Note"
                   name="Clone" value="Clone" title="Clone"/>

            <xsl:choose>
              <xsl:when test="$next='get_result'">
                <input type="hidden" name="report_result_id" value="{/envelope/params/report_result_id}"/>
                <xsl:choose>
                  <xsl:when test="$delta = 1">
                    <input type="hidden" name="next" value="get_report"/>
                    <input type="hidden" name="report_id" value="{../../../../../@id}"/>
                    <input type="hidden" name="result_id" value="{../../@id}"/>
                    <input type="hidden" name="task_id" value="{../../../../task/@id}"/>
                    <input type="hidden" name="name" value="{../../../../task/name}"/>
                    <input type="hidden" name="delta_report_id" value="{../../../../delta/report/@id}"/>
                    <input type="hidden" name="delta_states" value="{../../../../filters/delta/text()}"/>
                  </xsl:when>
                  <xsl:when test="$delta = 2">
                    <input type="hidden" name="next" value="get_report"/>
                    <input type="hidden" name="report_id" value="{../../../../../@id}"/>
                    <input type="hidden" name="result_id" value="{../../../@id}"/>
                    <input type="hidden" name="task_id" value="{../../../../../task/@id}"/>
                    <input type="hidden" name="name" value="{../../../../../task/name}"/>
                    <input type="hidden" name="delta_report_id" value="{../../../../../delta/report/@id}"/>
                    <input type="hidden" name="delta_states" value="{../../../../../filters/delta/text()}"/>
                  </xsl:when>
                  <xsl:otherwise>
                    <input type="hidden" name="next" value="get_result"/>
                    <input type="hidden" name="report_id" value="{../../../../../../report/@id}"/>
                    <input type="hidden" name="result_id" value="{../../@id}"/>
                    <input type="hidden" name="task_id" value="{../../../../../../task/@id}"/>
                    <input type="hidden" name="name" value="{../../../../../../task/name}"/>
                  </xsl:otherwise>
                </xsl:choose>
              </xsl:when>
              <xsl:otherwise>
                <input type="hidden" name="next" value="get_report"/>
                <xsl:choose>
                  <xsl:when test="$delta = 1">
                    <input type="hidden" name="report_id" value="{../../../../@id}"/>
                    <input type="hidden" name="delta_report_id" value="{../../../../delta/report/@id}"/>
                    <input type="hidden" name="delta_states" value="{../../../../filters/delta/text()}"/>
                  </xsl:when>
                  <xsl:when test="$delta = 2">
                    <input type="hidden" name="report_id" value="{../../../../../@id}"/>
                    <input type="hidden" name="delta_report_id" value="{../../../../../delta/report/@id}"/>
                    <input type="hidden" name="delta_states" value="{../../../../../filters/delta/text()}"/>
                  </xsl:when>
                  <xsl:otherwise>
                    <input type="hidden" name="report_id" value="{../../../../@id}"/>
                  </xsl:otherwise>
                </xsl:choose>
              </xsl:otherwise>
            </xsl:choose>
          </form>
        </div>
        <a href="/omp?cmd=export_note&amp;note_id={@id}&amp;token={/envelope/token}"
           title="Export Note"
           style="margin-left:3px;">
          <img src="/img/download.png" border="0" alt="Export"/>
        </a>
      </div>
    </xsl:if>
    Last modified: <xsl:value-of select="gsa:long-time (modification_time)"/>.
  </div>
</xsl:template>

<!--     OVERRIDE -->

<xsl:template name="override-detailed" match="override" mode="detailed">
  <xsl:param name="override-buttons">1</xsl:param>
  <xsl:param name="delta"/>
  <xsl:param name="next">get_report</xsl:param>
  <div class="override_box_box">
    <b>
      Override from
      <xsl:choose>
        <xsl:when test="string-length(threat) = 0">
          Any
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="threat"/>
        </xsl:otherwise>
      </xsl:choose>
      to <xsl:value-of select="new_threat"/></b><xsl:if test="$delta and $delta &gt; 0"> (Result <xsl:value-of select="$delta"/>)</xsl:if><br/>
    <pre>
      <xsl:call-template name="wrap">
        <xsl:with-param name="string"><xsl:value-of select="text"/></xsl:with-param>
      </xsl:call-template>
    </pre>
    <div>
      <xsl:choose>
        <xsl:when test="active='0'">
        </xsl:when>
        <xsl:when test="active='1' and string-length (end_time) &gt; 0">
          Active until:
          <xsl:value-of select="gsa:long-time (end_time)"/>.
        </xsl:when>
        <xsl:otherwise>
        </xsl:otherwise>
      </xsl:choose>
    </div>
    <xsl:if test="$override-buttons = 1">
      <div class="float_right" style="text-align:right">
        <div style="display: inline">
          <xsl:call-template name="trashcan-icon">
            <xsl:with-param name="type" select="'override'"/>
            <xsl:with-param name="id" select="@id"/>
            <xsl:with-param name="fragment" select="concat ('#result-', ../../@id)"/>
            <xsl:with-param name="params">
              <input type="hidden" name="filter" value="{/envelope/params/filter}"/>
              <input type="hidden" name="filt_id" value="{/envelope/params/filt_id}"/>
              <xsl:choose>
                <xsl:when test="$next='get_result'">
                  <input type="hidden" name="report_result_id" value="{/envelope/params/report_result_id}"/>
                  <xsl:choose>
                    <xsl:when test="$delta = 1">
                      <input type="hidden" name="report_id" value="{../../../../../@id}"/>
                      <input type="hidden" name="result_id" value="{../../@id}"/>
                      <input type="hidden" name="task_id" value="{../../../../task/@id}"/>
                      <input type="hidden" name="name" value="{../../../../task/name}"/>
                      <input type="hidden" name="apply_overrides" value="{/envelope/params/apply_overrides}"/>
                      <input type="hidden" name="overrides" value="{/envelope/params/apply_overrides}"/>
                      <input type="hidden" name="autofp" value="{/envelope/params/autofp}"/>
                      <input type="hidden" name="delta_report_id" value="{../../../../delta/report/@id}"/>
                      <input type="hidden" name="delta_states" value="{../../../../filters/delta/text()}"/>
                      <input type="hidden" name="next" value="get_report"/>
                    </xsl:when>
                    <xsl:when test="$delta = 2">
                      <input type="hidden" name="report_id" value="{../../../../../@id}"/>
                      <input type="hidden" name="result_id" value="{../../../@id}"/>
                      <input type="hidden" name="task_id" value="{../../../../../task/@id}"/>
                      <input type="hidden" name="name" value="{../../../../../task/name}"/>
                      <input type="hidden" name="apply_overrides" value="{/envelope/params/apply_overrides}"/>
                      <input type="hidden" name="overrides" value="{/envelope/params/apply_overrides}"/>
                      <input type="hidden" name="autofp" value="{/envelope/params/autofp}"/>
                      <input type="hidden" name="delta_report_id" value="{../../../../../delta/report/@id}"/>
                      <input type="hidden" name="delta_states" value="{../../../../../filters/delta/text()}"/>
                      <input type="hidden" name="next" value="get_report"/>
                    </xsl:when>
                    <xsl:otherwise>
                      <input type="hidden" name="report_id" value="{../../../../../../report/@id}"/>
                      <input type="hidden" name="result_id" value="{../../@id}"/>
                      <input type="hidden" name="task_id" value="{../../../../../../task/@id}"/>
                      <input type="hidden" name="name" value="{../../../../../../task/name}"/>
                      <input type="hidden" name="apply_overrides" value="{/envelope/params/apply_overrides}"/>
                      <input type="hidden" name="autofp" value="{/envelope/params/autofp}"/>
                      <input type="hidden" name="next" value="get_result"/>
                    </xsl:otherwise>
                  </xsl:choose>
                </xsl:when>
                <xsl:otherwise>
                  <input type="hidden" name="overrides" value="{/envelope/params/overrides}"/>
                  <input type="hidden" name="next" value="get_report"/>
                  <xsl:choose>
                    <xsl:when test="$delta = 1">
                      <input type="hidden" name="report_id" value="{../../../../@id}"/>
                      <input type="hidden" name="delta_report_id" value="{../../../../delta/report/@id}"/>
                      <input type="hidden" name="delta_states" value="{../../../../filters/delta/text()}"/>
                    </xsl:when>
                    <xsl:when test="$delta = 2">
                      <input type="hidden" name="report_id" value="{../../../../../@id}"/>
                      <input type="hidden" name="delta_report_id" value="{../../../../../delta/report/@id}"/>
                      <input type="hidden" name="delta_states" value="{../../../../../filters/delta/text()}"/>
                    </xsl:when>
                    <xsl:otherwise>
                      <input type="hidden" name="report_id" value="{../../../../@id}"/>
                    </xsl:otherwise>
                  </xsl:choose>
                </xsl:otherwise>
              </xsl:choose>
            </xsl:with-param>
          </xsl:call-template>
        </div>
        <a href="/omp?cmd=get_override&amp;override_id={@id}&amp;token={/envelope/token}"
           title="Override Details" style="margin-left:3px;">
          <img src="/img/details.png" border="0" alt="Details"/>
        </a>
        <xsl:choose>
          <xsl:when test="$next='get_result' and $delta = 1">
            <a href="/omp?cmd=edit_override&amp;override_id={@id}&amp;next=get_report&amp;result_id={../../@id}&amp;task_id={../../../../task/@id}&amp;name={../../../../task/name}&amp;report_id={../../../../../report/@id}&amp;overrides={../../../../filters/apply_overrides}&amp;delta_report_id={../../../../delta/report/@id}&amp;apply_overrides={/envelope/params/apply_overrides}&amp;filter={str:encode-uri (/envelope/params/filter, true ())}&amp;filt_id={/envelope/params/filt_id}&amp;autofp={/envelope/params/autofp}&amp;report_result_id={/envelope/params/report_result_id}&amp;token={/envelope/token}"
               title="Edit Override"
               style="margin-left:3px;">
              <img src="/img/edit.png" border="0" alt="Edit"/>
            </a>
          </xsl:when>
          <xsl:when test="$next='get_result' and $delta = 2">
            <a href="/omp?cmd=edit_override&amp;override_id={@id}&amp;next=get_report&amp;result_id={../../../@id}&amp;task_id={../../../../../task/@id}&amp;name={../../../../../task/name}&amp;report_id={../../../../../@id}&amp;overrides={../../../../../filters/apply_overrides}&amp;delta_report_id={../../../../../delta/report/@id}&amp;apply_overrides={/envelope/params/apply_overrides}&amp;filter={str:encode-uri (/envelope/params/filter, true ())}&amp;filt_id={/envelope/params/filt_id}&amp;autofp={/envelope/params/autofp}&amp;report_result_id={/envelope/params/report_result_id}&amp;token={/envelope/token}"
               title="Edit Override"
               style="margin-left:3px;">
              <img src="/img/edit.png" border="0" alt="Edit"/>
            </a>
          </xsl:when>
          <xsl:when test="$next='get_result'">
            <a href="/omp?cmd=edit_override&amp;override_id={@id}&amp;next=get_result&amp;result_id={../../@id}&amp;task_id={../../../../../../task/@id}&amp;name={../../../../../../task/name}&amp;report_id={../../../../../../report/@id}&amp;overrides={/envelope/params/overrides}&amp;apply_overrides={/envelope/params/apply_overrides}&amp;filter={str:encode-uri (/envelope/params/filter, true ())}&amp;filt_id={/envelope/params/filt_id}&amp;autofp={/envelope/params/autofp}&amp;report_result_id={/envelope/params/report_result_id}&amp;token={/envelope/token}"
               title="Edit Override"
               style="margin-left:3px;">
              <img src="/img/edit.png" border="0" alt="Edit"/>
            </a>
          </xsl:when>
          <xsl:when test="$delta = 1">
            <a href="/omp?cmd=edit_override&amp;a=a&amp;override_id={@id}&amp;next=get_report&amp;report_id={../../../../../@id}&amp;overrides={../../../../filters/apply_overrides}&amp;delta_report_id={../../../../delta/report/@id}&amp;autofp={/envelope/params/autofp}&amp;apply_overrides={/envelope/params/apply_overrides}&amp;filter={str:encode-uri (/envelope/params/filter, true ())}&amp;filt_id={/envelope/params/filt_id}&amp;report_result_id={../../@id}&amp;token={/envelope/token}"
               title="Edit Override"
               style="margin-left:3px;">
              <img src="/img/edit.png" border="0" alt="Edit"/>
            </a>
          </xsl:when>
          <xsl:when test="$delta = 2">
            <a href="/omp?cmd=edit_override&amp;a=a&amp;override_id={@id}&amp;next=get_report&amp;report_id={../../../../../@id}&amp;overrides={../../../../../filters/apply_overrides}&amp;delta_report_id={../../../../../delta/report/@id}&amp;delta_states={../../../../../filters/delta/text()}&amp;autofp={../../../../../../filters/autofp}&amp;apply_overrides={/envelope/params/apply_overrides}&amp;filter={str:encode-uri (/envelope/params/filter, true ())}&amp;filt_id={/envelope/params/filt_id}&amp;report_result_id={../../@id}&amp;token={/envelope/token}"
               title="Edit Override"
               style="margin-left:3px;">
              <img src="/img/edit.png" border="0" alt="Edit"/>
            </a>
          </xsl:when>
          <xsl:otherwise>
            <a href="/omp?cmd=edit_override&amp;override_id={@id}&amp;next=get_report&amp;report_id={../../../../@id}&amp;result_id={../../@id}&amp;filter={str:encode-uri (/envelope/params/filter, true ())}&amp;filt_id={/envelope/params/filt_id}&amp;overrides={../../../../filters/apply_overrides}&amp;report_result_id={../../@id}&amp;token={/envelope/token}"
               title="Edit Override"
               style="margin-left:3px;">
              <img src="/img/edit.png" border="0" alt="Edit"/>
            </a>
          </xsl:otherwise>
        </xsl:choose>
        <div style="display: inline">
          <form style="display: inline; font-size: 0px; margin-left: 3px" action="/omp#result-{../../@id}" method="post" enctype="multipart/form-data">
            <input type="hidden" name="token" value="{/envelope/token}"/>
            <input type="hidden" name="caller" value="{/envelope/caller}"/>
            <input type="hidden" name="cmd" value="clone"/>
            <input type="hidden" name="resource_type" value="override"/>
            <input type="hidden" name="id" value="{@id}"/>
            <input type="hidden" name="filter" value="{/envelope/params/filter}"/>
            <input type="hidden" name="filt_id" value="{/envelope/params/filt_id}"/>
            <input type="hidden" name="autofp" value="{/envelope/params/autofp}"/>
            <input type="hidden" name="apply_overrides" value="{/envelope/params/apply_overrides}"/>
            <input type="hidden" name="overrides" value="{/envelope/params/overrides}"/>
            <input type="image" src="/img/clone.png" alt="Clone Override"
                   name="Clone" value="Clone" title="Clone"/>

            <xsl:choose>
              <xsl:when test="$next='get_result'">
                <input type="hidden" name="report_result_id" value="{/envelope/params/report_result_id}"/>
                <xsl:choose>
                  <xsl:when test="$delta = 1">
                    <input type="hidden" name="next" value="get_report"/>
                    <input type="hidden" name="report_id" value="{../../../../../@id}"/>
                    <input type="hidden" name="result_id" value="{../../@id}"/>
                    <input type="hidden" name="task_id" value="{../../../../task/@id}"/>
                    <input type="hidden" name="name" value="{../../../../task/name}"/>
                    <input type="hidden" name="delta_report_id" value="{../../../../delta/report/@id}"/>
                    <input type="hidden" name="delta_states" value="{../../../../filters/delta/text()}"/>
                  </xsl:when>
                  <xsl:when test="$delta = 2">
                    <input type="hidden" name="next" value="get_report"/>
                    <input type="hidden" name="report_id" value="{../../../../../@id}"/>
                    <input type="hidden" name="result_id" value="{../../../@id}"/>
                    <input type="hidden" name="task_id" value="{../../../../../task/@id}"/>
                    <input type="hidden" name="name" value="{../../../../../task/name}"/>
                    <input type="hidden" name="delta_report_id" value="{../../../../../delta/report/@id}"/>
                    <input type="hidden" name="delta_states" value="{../../../../../filters/delta/text()}"/>
                  </xsl:when>
                  <xsl:otherwise>
                    <input type="hidden" name="next" value="get_result"/>
                    <input type="hidden" name="report_id" value="{../../../../../../report/@id}"/>
                    <input type="hidden" name="result_id" value="{../../@id}"/>
                    <input type="hidden" name="task_id" value="{../../../../../../task/@id}"/>
                    <input type="hidden" name="name" value="{../../../../../../task/name}"/>
                  </xsl:otherwise>
                </xsl:choose>
              </xsl:when>
              <xsl:otherwise>
                <input type="hidden" name="next" value="get_report"/>
                <xsl:choose>
                  <xsl:when test="$delta = 1">
                    <input type="hidden" name="report_id" value="{../../../../@id}"/>
                    <input type="hidden" name="delta_report_id" value="{../../../../delta/report/@id}"/>
                    <input type="hidden" name="delta_states" value="{../../../../filters/delta/text()}"/>
                  </xsl:when>
                  <xsl:when test="$delta = 2">
                    <input type="hidden" name="report_id" value="{../../../../../@id}"/>
                    <input type="hidden" name="delta_report_id" value="{../../../../../delta/report/@id}"/>
                    <input type="hidden" name="delta_states" value="{../../../../../filters/delta/text()}"/>
                  </xsl:when>
                  <xsl:otherwise>
                    <input type="hidden" name="report_id" value="{../../../../@id}"/>
                  </xsl:otherwise>
                </xsl:choose>
              </xsl:otherwise>
            </xsl:choose>
          </form>
        </div>
        <a href="/omp?cmd=export_override&amp;override_id={@id}&amp;token={/envelope/token}"
           title="Export Override"
           style="margin-left:3px;">
          <img src="/img/download.png" border="0" alt="Export"/>
        </a>
      </div>
    </xsl:if>
    <div>Last modified: <xsl:value-of select="gsa:long-time (modification_time)"/>.</div>
  </div>
</xsl:template>

<!--     RESULT -->

<xsl:template match="result" mode="details" name="result-details">
  <xsl:param name="delta" select="0"/>
  <xsl:param name="task_id" select="../../../../task/@id"/>
  <xsl:param name="task_name" select="../../../../task/name"/>
  <div class="gb_window">
    <div class="gb_window_part_left"></div>
    <div class="gb_window_part_right"></div>
    <div class="gb_window_part_center">
       Result Details
<!--
       <a href="/help/configure_results.html?token={/envelope/token}#resultdetails"
         title="Help: Configure Results (Result Details)">
         <img src="/img/help.png"/>
       </a>
-->
      <xsl:if test="$delta=0">
        <xsl:variable name="apply-overrides" select="/envelope/params/overrides"/>
        <div id="small_inline_form" style="display: inline; margin-left: 40px; font-weight: normal;">
          <form action="" method="get">
            <input type="hidden" name="token" value="{/envelope/token}"/>
            <input type="hidden" name="cmd" value="get_result"/>
            <input type="hidden" name="result_id" value="{@id}"/>
            <input type="hidden" name="task_id" value="{$task_id}"/>
            <input type="hidden" name="name" value="{$task_name}"/>
            <input type="hidden" name="filter" value="{/envelope/params/filter}"/>
            <input type="hidden" name="filt_id" value="{/envelope/params/filt_id}"/>

            <input type="hidden" name="report_id"
                   value="{/envelope/params/report_id}"/>
            <input type="hidden" name="report_result_id"
                   value="{/envelope/params/report_result_id}"/>
            <input type="hidden" name="autofp"
                   value="{/envelope/params/autofp}"/>

            <select style="margin-bottom: 0px;" name="apply_overrides" size="1">
              <xsl:choose>
                <xsl:when test="$apply-overrides = 0">
                  <option value="0" selected="$apply-overrides">&#8730;No overrides</option>
                  <option value="1" >Apply overrides</option>
                </xsl:when>
                <xsl:otherwise>
                  <option value="0">No overrides</option>
                  <option value="1" selected="1">&#8730;Apply overrides</option>
                </xsl:otherwise>
              </xsl:choose>
            </select>
            <input type="image"
                   name="Update"
                   src="/img/refresh.png"
                   alt="Update" style="margin-left:3px;margin-right:3px;"/>
          </form>
        </div>
      </xsl:if>
    </div>
    <div class="gb_window_part_content">
      <div class="float_right">
        <xsl:choose>
          <xsl:when test="$delta=0">
            <a href="?cmd=get_report&amp;report_id={/envelope/params/report_id}&amp;filter={str:encode-uri (/envelope/params/filter, true ())}&amp;filt_id={/envelope/params/filt_id}&amp;overrides={/envelope/params/overrides}&amp;token={/envelope/token}#result-{/envelope/params/report_result_id}">Report</a>
          </xsl:when>
          <xsl:otherwise>
            <a href="?cmd=get_report&amp;report_id={../../@id}&amp;delta_report_id={../../delta/report/@id}&amp;delta_states={../../filters/delta/text()}&amp;filter={str:encode-uri (/envelope/params/filter, true ())}&amp;filt_id={/envelope/params/filt_id}&amp;overrides={../../../../filters/apply_overrides}&amp;token={/envelope/token}#result-{/envelope/params/report_result_id}">Report</a>
          </xsl:otherwise>
        </xsl:choose>
      </div>
      <table>
        <tr>
          <td>Task:</td>
          <td>
            <a href="?cmd=get_task&amp;task_id={$task_id}&amp;overrides={/envelope/params/overrides}&amp;token={/envelope/token}">
              <xsl:value-of select="$task_name"/>
            </a>
          </td>
        </tr>
      </table>
      <xsl:call-template name="result-detailed">
        <xsl:with-param name="details-button">0</xsl:with-param>
        <xsl:with-param name="note-buttons">1</xsl:with-param>
        <xsl:with-param name="override-buttons">1</xsl:with-param>
        <xsl:with-param name="show-overrides">1</xsl:with-param>
        <xsl:with-param name="result-details">1</xsl:with-param>
      </xsl:call-template>
    </div>
  </div>
</xsl:template>

<xsl:template match="result" mode="overview">
  <xsl:variable name="class">
    <xsl:choose>
      <xsl:when test="position() mod 2 = 0">even</xsl:when>
      <xsl:otherwise>odd</xsl:otherwise>
    </xsl:choose>
  </xsl:variable>
  <tr class="{$class}">
    <td><xsl:value-of select="port"/></td>
    <td><xsl:value-of select="threat"/></td>
  </tr>
</xsl:template>

<xsl:template name="result-detailed" match="result" mode="detailed">
  <xsl:param name="details-button">1</xsl:param>
  <xsl:param name="note-buttons">1</xsl:param>
  <xsl:param name="override-buttons">1</xsl:param>
  <xsl:param name="show-overrides">0</xsl:param>
  <xsl:param name="result-details"/>
  <xsl:param name="prognostic"/>
  <xsl:variable name="style">
    <xsl:choose>
       <xsl:when test="threat='Low'">background:#539dcb</xsl:when>
       <xsl:when test="threat='Medium'">background:#f99f31</xsl:when>
       <xsl:when test="threat='High'">background:#cb1d17</xsl:when>
    </xsl:choose>
  </xsl:variable>
  <a class="anchor" name="result-{@id}"/>

  <div class="issue_box_head" style="background:#ffffff">
    <table width="100%" border="0">
      <tr style="background:#bbbbbb">
        <td>Vulnerability</td>
        <td width="104" align="center">Severity</td>
        <td>Host</td>
        <td>Location</td>
        <td style="text-align:right">Actions</td>
      </tr>
      <tr style="background:#bbbbbb; color:#000000">
        <td> <!-- Vulnerability -->
          <xsl:if test="delta/text()">
            <xsl:choose>
              <xsl:when test="delta/text() = 'changed'">[ ~ ] </xsl:when>
              <xsl:when test="delta/text() = 'gone'">[ &#8722; ] </xsl:when>
              <xsl:when test="delta/text() = 'new'">[ + ] </xsl:when>
              <xsl:when test="delta/text() = 'same'">[ = ] </xsl:when>
            </xsl:choose>
          </xsl:if>
          <xsl:choose>
            <xsl:when test="$prognostic=1">
              <xsl:call-template name="get_info_cve_lnk">
                <xsl:with-param name="cve" select="cve/@id"/>
              </xsl:call-template>
            </xsl:when>
            <xsl:when test="nvt/@oid = 0">
              <xsl:if test="delta/text()">
                <br/>
              </xsl:if>
            </xsl:when>
            <xsl:otherwise>
              <xsl:variable name="max" select="80"/>
              <xsl:choose>
                <xsl:when test="string-length(nvt/name) &gt; $max">
                  <abbr title="{nvt/name} ({nvt/@oid})"><xsl:value-of select="substring(nvt/name, 0, $max)"/>...</abbr>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:value-of select="nvt/name"/>
                </xsl:otherwise>
              </xsl:choose>
            </xsl:otherwise>
          </xsl:choose>
        </td>
        <td> <!-- Severity -->
          <xsl:variable name="severity_title">
            <xsl:choose>
              <xsl:when test="$prognostic=1">
                <xsl:if test="string-length(cve/cvss_base) &gt; 0">
                  <xsl:value-of select="cve/cvss_base"/>
                </xsl:if>
              </xsl:when>
            </xsl:choose>
            <xsl:choose>
              <xsl:when test="original_threat">
                <xsl:choose>
                  <xsl:when test="threat = original_threat">
                    <xsl:value-of select="threat"/>
                  </xsl:when>
                  <xsl:otherwise>(Overridden from <b><xsl:value-of select="original_threat"/></b>)</xsl:otherwise>
                </xsl:choose>
              </xsl:when>
            </xsl:choose>
          </xsl:variable>

          <xsl:choose>
            <xsl:when test="string-length (nvt/cvss_base) &gt; 0">
              <xsl:call-template name="severity-bar">
                <xsl:with-param name="cvss" select="nvt/cvss_base"/>
                <xsl:with-param name="threat" select="threat"/>
                <xsl:with-param name="extra_text" select="concat (' (', threat, ')')"/>
                <xsl:with-param name="title" select="$severity_title"/>
              </xsl:call-template>
            </xsl:when>
            <xsl:when test="string-length (cve/cvss_base) &gt; 0">
              <xsl:call-template name="severity-bar">
                <xsl:with-param name="cvss" select="cve/cvss_base"/>
              </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="$severity_title"/>
            </xsl:otherwise>
          </xsl:choose>
        </td>
        <td> <!-- Host -->
          <xsl:value-of select="host"/>
        </td>
        <td> <!-- Location -->
          <xsl:choose>
            <xsl:when test="$prognostic=1">
              <xsl:call-template name="get_info_cpe_lnk">
                <xsl:with-param name="cpe" select="cve/cpe/@id"/>
              </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="port"/>
            </xsl:otherwise>
          </xsl:choose>
        </td>
        <td> <!-- Action Icons -->
          <xsl:if test="$details-button = 1">
            <xsl:choose>
              <xsl:when test="delta">
                <div class="float_right" style="text-align:right">
                  <form class="float_right" style="text-align:right">
                    <input type="hidden" name="token" value="{/envelope/token}"/>
                    <input type="hidden" name="cmd" value="get_report"/>
                    <input type="hidden" name="report_id" value="{../../../report/@id}"/>
                    <input type="hidden" name="result_id" value="{@id}"/>
                    <input type="hidden" name="delta_report_id" value="{../../../report/delta/report/@id}"/>
                    <input type="hidden" name="task_id" value="{../../task/@id}"/>
                    <input type="hidden" name="overrides" value="{../../filters/apply_overrides}"/>
                    <input type="hidden" name="apply_overrides" value="{../../filters/apply_overrides}"/>
                    <input type="hidden" name="autofp" value="{../../filters/autofp}"/>
                    <input type="hidden" name="filter" value="{/envelope/params/filter}"/>
                    <input type="hidden" name="filt_id" value="{/envelope/params/filt_id}"/>
                    <input type="hidden" name="report_result_id" value="{@id}"/>
                    <input type="image"
                           name="Details"
                           src="/img/details.png"
                           alt="Details" style="margin-left:3px;margin-right:3px;"/>
                  </form>
                </div>
              </xsl:when>
              <xsl:otherwise>
                <div class="float_right" style="text-align:right">
                  <a href="/omp?cmd=get_result&amp;result_id={@id}&amp;apply_overrides={../../filters/apply_overrides}&amp;task_id={../../task/@id}&amp;name={../../task/name}&amp;report_id={../../../report/@id}&amp;delta_report_id={../../../report/delta/report/@id}&amp;filter={str:encode-uri (/envelope/params/filter, true ())}&amp;filt_id={/envelope/params/filt_id}&amp;overrides={../../filters/overrides}&amp;autofp={../../filters/autofp}&amp;report_result_id={@id}&amp;token={/envelope/token}"
                     title="Result Details" style="margin-left:3px;">
                    <img src="/img/details.png" border="0" alt="Details"/>
                  </a>
                </div>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:if>
          <xsl:if test="$note-buttons = 1">
            <div class="float_right" style="text-align:right">
              <xsl:if test="count(notes/note) &gt; 0">
                <a href="#notes-{@id}"
                   title="Notes" style="margin-left:3px;">
                  <img src="/img/note.png" border="0" alt="Notes"/>
                </a>
              </xsl:if>
              <xsl:choose>
                <xsl:when test="delta">
                </xsl:when>
                <xsl:when test="$result-details and original_threat and string-length (original_threat)">
                  <a href="/omp?cmd=new_note&amp;next=get_result&amp;result_id={@id}&amp;oid={nvt/@oid}&amp;task_id={../../../../task/@id}&amp;name={../../../../task/name}&amp;threat={original_threat}&amp;port={port}&amp;hosts={host/text()}&amp;report_id={../../../../report/@id}&amp;filter={str:encode-uri (/envelope/params/filter, true ())}&amp;filt_id={/envelope/params/filt_id}&amp;apply_overrides={/envelope/params/apply_overrides}&amp;autofp={/envelope/params/autofp}&amp;report_result_id={/envelope/params/report_result_id}&amp;token={/envelope/token}"
                     title="Add Note" style="margin-left:3px;">
                    <img src="/img/new_note.png" border="0" alt="Add Note"/>
                  </a>
                </xsl:when>
                <xsl:when test="$result-details">
                  <a href="/omp?cmd=new_note&amp;next=get_result&amp;result_id={@id}&amp;oid={nvt/@oid}&amp;task_id={../../../../task/@id}&amp;name={../../../../task/name}&amp;report_id={../../../../report/@id}&amp;overrides={../../../../filters/apply_overrides}&amp;apply_overrides={/envelope/params/apply_overrides}&amp;autofp={/envelope/params/autofp}&amp;report_result_id={/envelope/params/report_result_id}&amp;token={/envelope/token}"
                     title="Add Note" style="margin-left:3px;">
                    <img src="/img/new_note.png" border="0" alt="Add Note"/>
                  </a>
                </xsl:when>
                <xsl:when test="original_threat and string-length (original_threat)">
                  <a href="/omp?cmd=new_note&amp;next=get_report&amp;result_id={@id}&amp;oid={nvt/@oid}&amp;task_id={../../task/@id}&amp;name={../../task/name}&amp;report_id={../../@id}&amp;threat={original_threat}&amp;port={port}&amp;hosts={host/text()}&amp;filter={str:encode-uri (/envelope/params/filter, true ())}&amp;filt_id={/envelope/params/filt_id}&amp;autofp={/envelope/params/autofp}&amp;token={/envelope/token}"
                     title="Add Note" style="margin-left:3px;">
                    <img src="/img/new_note.png" border="0" alt="Add Note"/>
                  </a>
                </xsl:when>
                <xsl:otherwise>
                  <a href="/omp?cmd=new_note&amp;next=get_report&amp;result_id={@id}&amp;oid={nvt/@oid}&amp;task_id={../../task/@id}&amp;name={../../task/name}&amp;report_id={../../@id}&amp;threat={threat}&amp;port={port}&amp;hosts={host/text()}&amp;overrides={../../filters/apply_overrides}&amp;filter={str:encode-uri (/envelope/params/filter, true ())}&amp;filt_id={/envelope/params/filt_id}&amp;autofp={/envelope/params/autofp}&amp;token={/envelope/token}"
                     title="Add Note" style="margin-left:3px;">
                    <img src="/img/new_note.png" border="0" alt="Add Note"/>
                  </a>
                </xsl:otherwise>
              </xsl:choose>
            </div>
          </xsl:if>
          <xsl:if test="$override-buttons = 1">
            <div class="float_right" style="text-align:right">
              <xsl:if test="count(overrides/override) &gt; 0">
                <a href="#overrides-{@id}"
                   title="Overrides" style="margin-left:3px;">
                  <img src="/img/override.png" border="0" alt="Overrides"/>
                </a>
              </xsl:if>
              <xsl:choose>
                <xsl:when test="delta">
                </xsl:when>
                <xsl:when test="$result-details and original_threat and string-length (original_threat)">
                  <a href="/omp?cmd=new_override&amp;next=get_result&amp;result_id={@id}&amp;oid={nvt/@oid}&amp;task_id={../../../../task/@id}&amp;name={../../../../task/name}&amp;threat={original_threat}&amp;port={port}&amp;hosts={host/text()}&amp;report_id={../../../../report/@id}&amp;filter={str:encode-uri (/envelope/params/filter, true ())}&amp;filt_id={/envelope/params/filt_id}&amp;apply_overrides={/envelope/params/apply_overrides}&amp;autofp={/envelope/params/autofp}&amp;report_result_id={/envelope/params/report_result_id}&amp;token={/envelope/token}"
                     title="Add Override" style="margin-left:3px;">
                    <img src="/img/new_override.png" border="0" alt="Add Override"/>
                  </a>
                </xsl:when>
                <xsl:when test="$result-details">
                  <a href="/omp?cmd=new_override&amp;next=get_result&amp;result_id={@id}&amp;oid={nvt/@oid}&amp;task_id={../../../../task/@id}&amp;name={../../../../task/name}&amp;report_id={../../../../report/@id}&amp;overrides={../../../../filters/apply_overrides}&amp;apply_overrides={/envelope/params/apply_overrides}&amp;autofp={/envelope/params/autofp}&amp;report_result_id={/envelope/params/report_result_id}&amp;token={/envelope/token}"
                     title="Add Override" style="margin-left:3px;">
                    <img src="/img/new_override.png" border="0" alt="Add Override"/>
                  </a>
                </xsl:when>
                <xsl:when test="original_threat and string-length (original_threat)">
                  <a href="/omp?cmd=new_override&amp;next=get_report&amp;result_id={@id}&amp;oid={nvt/@oid}&amp;task_id={../../task/@id}&amp;name={../../task/name}&amp;report_id={../../@id}&amp;threat={original_threat}&amp;port={port}&amp;hosts={host/text()}&amp;filter={str:encode-uri (/envelope/params/filter, true ())}&amp;filt_id={/envelope/params/filt_id}&amp;autofp={/envelope/params/autofp}&amp;token={/envelope/token}"
                     title="Add Override" style="margin-left:3px;">
                    <img src="/img/new_override.png" border="0" alt="Add Override"/>
                  </a>
                </xsl:when>
                <xsl:otherwise>
                  <a href="/omp?cmd=new_override&amp;next=get_report&amp;result_id={@id}&amp;oid={nvt/@oid}&amp;task_id={../../task/@id}&amp;name={../../task/name}&amp;report_id={../../@id}&amp;threat={threat}&amp;port={port}&amp;hosts={host/text()}&amp;overrides={../../filters/apply_overrides}&amp;filter={str:encode-uri (/envelope/params/filter, true ())}&amp;filt_id={/envelope/params/filt_id}&amp;autofp={/envelope/params/autofp}&amp;token={/envelope/token}"
                     title="Add Override" style="margin-left:3px;">
                    <img src="/img/new_override.png" border="0" alt="Add Override"/>
                  </a>
                </xsl:otherwise>
              </xsl:choose>
            </div>
          </xsl:if>
        </td>
      </tr>
    </table>
  </div>


  <xsl:variable name="cve_ref">
    <xsl:if test="nvt/cve != '' and nvt/cve != 'NOCVE'">
      <xsl:value-of select="nvt/cve/text()"/>
    </xsl:if>
  </xsl:variable>
  <xsl:variable name="bid_ref">
    <xsl:if test="nvt/bid != '' and nvt/bid != 'NOBID'">
      <xsl:value-of select="nvt/bid/text()"/>
    </xsl:if>
  </xsl:variable>
  <xsl:variable name="cert_ref" select="nvt/cert"/>
  <xsl:variable name="xref">
    <xsl:if test="nvt/xref != '' and nvt/xref != 'NOXREF'">
      <xsl:value-of select="nvt/xref/text()"/>
    </xsl:if>
  </xsl:variable>

  <xsl:if test="gsa:newstyle-nvt (nvt)">

    <div class="issue_box_box">
      <b>Summary</b>
      <xsl:call-template name="structured-text">
        <xsl:with-param name="string" select="gsa:get-nvt-tag (nvt/tags, 'summary')"/>
      </xsl:call-template>
    </div>

  </xsl:if>

  <!-- Result -->
  <div class="issue_box_box">
    <xsl:choose>
      <xsl:when test="delta/text() = 'changed'">
        <b>Result 1</b>
        <p></p>
      </xsl:when>
    </xsl:choose>
    <xsl:choose>
      <xsl:when test="$prognostic=1">
        <p>
          <xsl:call-template name="prognostic-description">
            <xsl:with-param name="string" select="description"/>
          </xsl:call-template>
        </p>
      </xsl:when>
      <xsl:otherwise>
        <xsl:choose>
          <xsl:when test="gsa:newstyle-nvt (nvt)">
            <b>Vulnerability Detection Result</b>
            <xsl:choose>
              <xsl:when test="string-length(description) &lt; 2">
                <p>
                Vulnerability was detected according to the Vulnerability Detection Method.
                </p>
              </xsl:when>
              <xsl:otherwise>
                <pre>
                  <xsl:call-template name="wrap">
                    <xsl:with-param name="string"><xsl:value-of select="description"/></xsl:with-param>
                  </xsl:call-template>
                </pre>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:when>
          <xsl:otherwise>
            <pre>
              <xsl:call-template name="wrap">
                <xsl:with-param name="string"><xsl:value-of select="description"/></xsl:with-param>
              </xsl:call-template>
            </pre>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:otherwise>
    </xsl:choose>
  </div>

  <xsl:if test="gsa:newstyle-nvt (nvt)">

    <xsl:if test="gsa:get-nvt-tag (nvt/tags, 'impact') != 'N/A'">
      <div class="issue_box_box">
        <b>Impact</b>
        <xsl:call-template name="structured-text">
          <xsl:with-param name="string" select="gsa:get-nvt-tag (nvt/tags, 'impact')"/>
        </xsl:call-template>
      </div>
    </xsl:if>

    <xsl:if test="gsa:get-nvt-tag (nvt/tags, 'solution') != 'N/A'">
      <div class="issue_box_box">
        <b>Solution</b>
        <xsl:call-template name="structured-text">
          <xsl:with-param name="string" select="gsa:get-nvt-tag (nvt/tags, 'solution')"/>
        </xsl:call-template>
      </div>
    </xsl:if>

    <xsl:if test="gsa:get-nvt-tag (nvt/tags, 'insight') != 'N/A'">
      <div class="issue_box_box">
        <b>Vulnerability Insight</b>
        <xsl:call-template name="structured-text">
          <xsl:with-param name="string" select="gsa:get-nvt-tag (nvt/tags, 'insight')"/>
        </xsl:call-template>
      </div>
    </xsl:if>

  </xsl:if>

  <div class="issue_box_box">
    <xsl:choose>
      <xsl:when test="(nvt/cvss_base &gt; 0) or (cve/cvss_base &gt; 0)">
        <b>Vulnerability Detection Method</b>
      </xsl:when>
      <xsl:otherwise>
        <b>Log Method</b>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:call-template name="structured-text">
      <xsl:with-param name="string" select="gsa:get-nvt-tag (nvt/tags, 'vuldetect')"/>
    </xsl:call-template>
    <p>
      Details:
      <xsl:choose>
        <xsl:when test="$prognostic=1">
          <xsl:call-template name="get_info_cve_lnk">
            <xsl:with-param name="cve" select="cve/@id"/>
          </xsl:call-template>
        </xsl:when>
        <xsl:when test="nvt/@oid = 0">
          <xsl:if test="delta/text()">
            <br/>
          </xsl:if>
        </xsl:when>
        <xsl:otherwise>
          <xsl:variable name="max" select="80"/>
          <a href="?cmd=get_nvts&amp;oid={nvt/@oid}&amp;token={/envelope/token}">
            <xsl:choose>
              <xsl:when test="string-length(nvt/name) &gt; $max">
                <abbr title="{nvt/name} ({nvt/@oid})"><xsl:value-of select="substring(nvt/name, 0, $max)"/>...</abbr>
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="nvt/name"/>
              </xsl:otherwise>
            </xsl:choose>
           (OID: <xsl:value-of select="nvt/@oid"/>)
          </a>
        </xsl:otherwise>
      </xsl:choose>
    </p>
  </div>

  <xsl:if test="count (detection)">
    <div class="issue_box_box">
      <b>Product Detection Result</b>
      <p>
      <table>
      <tr><td>Product:</td><td>
      <xsl:call-template name="get_info_cpe_lnk">
        <xsl:with-param name="cpe" select="detection/result/details/detail[name = 'product']/value/text()"/>
      </xsl:call-template>
      </td></tr>
      <tr><td>Method:</td><td>
      <a href="?cmd=get_nvts&amp;oid={detection/result/details/detail[name = 'source_oid']/value/text()}&amp;token={/envelope/token}">
        <xsl:value-of select="detection/result/details/detail[name = 'source_name']/value/text()"/>
        (OID: <xsl:value-of select="detection/result/details/detail[name = 'source_oid']/value/text()"/>)
      </a>
      </td></tr>
      <tr><td>Log:</td><td>
      <!-- TODO This needs a case for delta reports. -->
      <a href="/omp?cmd=get_result&amp;result_id={detection/result/@id}&amp;apply_overrides={../../filters/apply_overrides}&amp;task_id={../../task/@id}&amp;name={../../task/name}&amp;report_id={../../../report/@id}&amp;report_result_id={@id}&amp;delta_report_id={../../../report/delta/report/@id}&amp;autofp={../../filters/autofp}&amp;overrides={../../filters/overrides}&amp;filter={str:encode-uri (/envelope/params/filter, true ())}&amp;filt_id={/envelope/params/filt_id}&amp;token={/envelope/token}"
       title="Product detection results">
        View details of product detection
      </a>
      </td></tr></table>
      </p>
    </div>
  </xsl:if>

  <xsl:if test="$cve_ref != '' or $bid_ref != '' or $xref != '' or count($cert_ref/cert_ref) > 0">
    <div class="issue_box_box">
      <b>References</b><br/>

      <p>
      <table>
        <xsl:call-template name="ref_cve_list">
          <xsl:with-param name="cvelist" select="$cve_ref"/>
        </xsl:call-template>
        <xsl:call-template name="ref_bid_list">
          <xsl:with-param name="bidlist" select="$bid_ref"/>
        </xsl:call-template>
        <xsl:call-template name="ref_cert_list">
          <xsl:with-param name="certlist" select="$cert_ref"/>
        </xsl:call-template>
        <xsl:call-template name="ref_xref_list">
          <xsl:with-param name="xreflist" select="$xref"/>
        </xsl:call-template>
      </table>
      </p>
    </div>
  </xsl:if>

  <xsl:if test="delta">
    <xsl:choose>
      <xsl:when test="delta/text() = 'changed'">
        <div class="issue_box_box">
          <b>Result 2</b>
          <xsl:choose>
            <xsl:when test="$prognostic=1">
              <xsl:call-template name="prognostic-description">
                <xsl:with-param name="string" select="delta/result/description"/>
              </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
              <pre>
                <xsl:call-template name="wrap">
                  <xsl:with-param name="string"><xsl:value-of select="delta/result/description"/></xsl:with-param>
                </xsl:call-template>
              </pre>
            </xsl:otherwise>
          </xsl:choose>
        </div>
        <xsl:variable name="cve_ref_2">
          <xsl:if test="delta/result/nvt/cve != '' and delta/result/nvt/cve != 'NOCVE'">
            <xsl:value-of select="nvt/cve/text()"/>
          </xsl:if>
        </xsl:variable>
        <xsl:variable name="bid_ref_2">
          <xsl:if test="delta/result/nvt/bid != '' and delta/result/nvt/bid != 'NOBID'">
            <xsl:value-of select="delta/result/nvt/bid/text()"/>
          </xsl:if>
        </xsl:variable>
        <xsl:variable name="cert_ref_2" select="delta/result/nvt/cert"/>
        <xsl:variable name="xref_2">
          <xsl:if test="delta/result/nvt/xref != '' and delta/result/nvt/xref != 'NOXREF'">
            <xsl:value-of select="delta/result/nvt/xref/text()"/>
          </xsl:if>
        </xsl:variable>
        <xsl:if test="$cve_ref_2 != '' or $bid_ref_2 != '' or $xref_2 != '' or count($cert_ref_2/cert_ref)">
          <div class="issue_box_box">
            <b>References</b><br/>

            <table>
              <xsl:call-template name="ref_cve_list">
                <xsl:with-param name="cvelist" select="$cve_ref_2"/>
              </xsl:call-template>
              <xsl:call-template name="ref_bid_list">
                <xsl:with-param name="bidlist" select="$bid_ref_2"/>
              </xsl:call-template>
              <xsl:call-template name="ref_cert_list">
                <xsl:with-param name="certlist" select="$cert_ref_2"/>
              </xsl:call-template>
              <xsl:call-template name="ref_xref_list">
                <xsl:with-param name="xreflist" select="$xref_2"/>
              </xsl:call-template>
            </table>
          </div>
        </xsl:if>
        <div class="issue_box_box">
          <b>Different Lines</b>
          <p>
            <xsl:call-template name="highlight-diff">
              <xsl:with-param name="string"><xsl:value-of select="delta/diff"/></xsl:with-param>
            </xsl:call-template>
          </p>
        </div>
      </xsl:when>
    </xsl:choose>
  </xsl:if>
  <xsl:variable name="delta">
    <xsl:choose>
      <xsl:when test="delta">1</xsl:when>
      <xsl:otherwise>0</xsl:otherwise>
    </xsl:choose>
  </xsl:variable>
  <a class="anchor" name="notes-{@id}"/>
  <xsl:for-each select="notes/note">
    <xsl:choose>
      <xsl:when test="active = 0">
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="note-detailed">
          <xsl:with-param name="note-buttons">
            <xsl:value-of select="$note-buttons"/>
          </xsl:with-param>
          <xsl:with-param name="delta" select="$delta"/>
          <xsl:with-param name="next">
            <xsl:choose>
              <xsl:when test="$result-details">get_result</xsl:when>
              <xsl:otherwise>get_report</xsl:otherwise>
            </xsl:choose>
          </xsl:with-param>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:for-each>
  <xsl:for-each select="delta/notes/note">
    <xsl:choose>
      <xsl:when test="active = 0">
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="note-detailed">
          <xsl:with-param name="note-buttons">
            <xsl:value-of select="$note-buttons"/>
          </xsl:with-param>
          <xsl:with-param name="delta" select="2"/>
          <xsl:with-param name="next">
            <xsl:choose>
              <xsl:when test="$result-details">get_result</xsl:when>
              <xsl:otherwise>get_report</xsl:otherwise>
            </xsl:choose>
          </xsl:with-param>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:for-each>
  <xsl:choose>
    <xsl:when test="$show-overrides = 1 or ../../filters/apply_overrides = 1">
      <a class="anchor" name="overrides-{@id}"/>
      <xsl:for-each select="overrides/override">
        <xsl:choose>
          <xsl:when test="active = 0">
          </xsl:when>
          <xsl:otherwise>
            <xsl:call-template name="override-detailed">
              <xsl:with-param name="override-buttons">
                <xsl:value-of select="$override-buttons"/>
              </xsl:with-param>
              <xsl:with-param name="delta" select="$delta"/>
              <xsl:with-param name="next">
                <xsl:choose>
                  <xsl:when test="$result-details">get_result</xsl:when>
                  <xsl:otherwise>get_report</xsl:otherwise>
                </xsl:choose>
              </xsl:with-param>
            </xsl:call-template>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:for-each>
      <xsl:for-each select="delta/overrides/override">
        <xsl:choose>
          <xsl:when test="active = 0">
          </xsl:when>
          <xsl:otherwise>
            <xsl:call-template name="override-detailed">
              <xsl:with-param name="override-buttons">
                <xsl:value-of select="$override-buttons"/>
              </xsl:with-param>
              <xsl:with-param name="delta" select="2"/>
              <xsl:with-param name="next">
                <xsl:choose>
                  <xsl:when test="$result-details">get_result</xsl:when>
                  <xsl:otherwise>get_report</xsl:otherwise>
                </xsl:choose>
              </xsl:with-param>
            </xsl:call-template>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:for-each>
    </xsl:when>
    <xsl:otherwise>
    </xsl:otherwise>
  </xsl:choose>
  <br/>
</xsl:template>

<!--     GET_RESULT -->

<xsl:template match="get_results_response">
  <xsl:choose>
    <xsl:when test="substring(@status, 1, 1) = '4' or substring(@status, 1, 1) = '5'">
      <xsl:call-template name="command_result_dialog">
        <xsl:with-param name="operation">
          Get Result
        </xsl:with-param>
        <xsl:with-param name="status">
          <xsl:value-of select="@status"/>
        </xsl:with-param>
        <xsl:with-param name="msg">
          <xsl:value-of select="@status_text"/>
        </xsl:with-param>
      </xsl:call-template>
    </xsl:when>
    <xsl:otherwise>
      <xsl:apply-templates select="results/result" mode="details"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template match="get_result">
  <xsl:apply-templates select="commands_response/delete_note_response"/>
  <xsl:apply-templates select="commands_response/delete_override_response"/>
  <xsl:apply-templates select="commands_response/modify_note_response"/>
  <xsl:apply-templates select="commands_response/modify_override_response"/>
  <xsl:apply-templates select="gsad_msg"/>
  <xsl:apply-templates select="get_results_response"/>
  <xsl:apply-templates select="commands_response/get_results_response"/>
  <xsl:apply-templates select="commands_response/get_reports_response"/>
</xsl:template>

<xsl:template match="get_delta_result">
  <xsl:variable name="result_id" select="result/@id"/>
  <xsl:variable name="task_id" select="task/@id"/>
  <xsl:variable name="task_name" select="task/name"/>
  <xsl:apply-templates select="gsad_msg"/>
  <xsl:apply-templates select="delete_note_response"/>
  <xsl:apply-templates select="create_note_response"/>
  <xsl:apply-templates select="modify_note_response"/>
  <xsl:for-each select="commands_response/get_reports_response/report/report/results/result[@id=$result_id]">
    <xsl:call-template name="result-details">
      <xsl:with-param name="delta" select="1"/>
      <xsl:with-param name="task_id" select="$task_id"/>
      <xsl:with-param name="task_name" select="$task_name"/>
    </xsl:call-template>
  </xsl:for-each>
  <xsl:for-each select="get_reports_response/report/report/results/result[@id=$result_id]">
    <xsl:call-template name="result-details">
      <xsl:with-param name="delta" select="1"/>
      <xsl:with-param name="task_id" select="$task_id"/>
      <xsl:with-param name="task_name" select="$task_name"/>
    </xsl:call-template>
  </xsl:for-each>
</xsl:template>

<xsl:template name="os-icon">
  <xsl:param name="host"/>
  <xsl:param name="current_host"/>
  <!-- Check for detected operating system(s) -->
  <xsl:variable name="best_os_cpe" select="$host[ip/text() = $current_host]/detail[name/text() = 'best_os_cpe']/value"/>
  <xsl:variable name="best_os_txt" select="$host[ip/text() = $current_host]/detail[name/text() = 'best_os_txt']/value"/>
  <xsl:choose>
    <xsl:when test="contains($best_os_txt, '[possible conflict]')">
      <img src="/img/os_conflict.png" alt="OS conflict: {$best_os_txt}" title="OS conflict: {$best_os_txt}"/>
    </xsl:when>
    <xsl:when test="not($best_os_cpe)">
      <!-- nothing detected or matched by our CPE database -->
      <xsl:variable name="img_desc">
        <xsl:choose>
          <xsl:when test="$best_os_txt">
            <xsl:value-of select="$best_os_txt"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:text>No information on Operating System was gathered during scan.</xsl:text>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:variable>
      <img src="/img/os_unknown.png" alt="{$img_desc}" title="{$img_desc}"/>
    </xsl:when>
    <xsl:otherwise>
      <!-- One system detected: display the corresponding icon and name from our database -->
      <xsl:variable name="os_icon" select="document('os.xml')//operating_systems/operating_system[contains($best_os_cpe, pattern)]/icon"/>
      <xsl:variable name="img_desc">
        <xsl:value-of select="document('os.xml')//operating_systems/operating_system[contains($best_os_cpe, pattern)]/title"/>
      </xsl:variable>
      <xsl:choose>
        <xsl:when test="$os_icon">
            <img src="/img/{$os_icon}" alt="{$img_desc}" title="{$img_desc}"/>
        </xsl:when>
        <xsl:otherwise>
            <img src="/img/os_unknown.png" alt="{$img_desc}" title="{$img_desc}"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<!--     REPORT -->

<xsl:template match="report" mode="assets">
  <table class="gbntable" cellspacing="2" cellpadding="4">
    <tr class="gbntablehead2">
      <td>IP</td>
      <td><img src="/img/high.png" alt="High" title="High"/></td>
      <td><img src="/img/medium.png" alt="Medium" title="Medium"/></td>
      <td><img src="/img/low.png" alt="Low" title="Low"/></td>
      <td>Last Report</td>
      <td>OS</td>
      <td>Ports</td>
      <td>Apps</td>
      <td>Distance</td>
      <td>Prognosis</td>
      <td>Reports</td>
      <td>Actions</td>
    </tr>
    <xsl:for-each select="host">
      <xsl:variable name="current_host" select="ip"/>
      <tr>
        <td>
          <xsl:variable name="hostname" select="detail[name/text() = 'hostname']/value"/>
          <xsl:value-of select="$current_host"/>
          <xsl:if test="$hostname">
            <xsl:value-of select="concat(' (', $hostname, ')')"/>
          </xsl:if>
        </td>
        <td>
          <xsl:value-of select="detail[name/text() = 'report/result_count/high']/value"/>
        </td>
        <td>
          <xsl:value-of select="detail[name/text() = 'report/result_count/medium']/value"/>
        </td>
        <td>
          <xsl:value-of select="detail[name/text() = 'report/result_count/low']/value"/>
        </td>
        <td>
          <xsl:choose>
            <xsl:when test="start/text() != ''">
              <a href="/omp?cmd=get_report&amp;report_id={detail[name = 'report/@id' and source/name = 'openvasmd']/value}&amp;filter==&#34;{ip}&#34; notes=1 overrides=1 result_hosts_only=1 levels=hm&amp;token={/envelope/token}">
                <xsl:value-of select="concat (date:month-abbreviation (start/text()), ' ', date:day-in-month (start/text()), ' ', date:year (start/text()))"/>
              </a>
            </xsl:when>
            <xsl:otherwise>(not finished)</xsl:otherwise>
          </xsl:choose>
        </td>
        <td>
          <xsl:call-template name="os-icon">
            <xsl:with-param name="host" select="../host"/>
            <xsl:with-param name="current_host" select="$current_host"/>
          </xsl:call-template>
        </td>
        <td>
          <xsl:value-of select="count (str:tokenize (detail[name = 'ports']/value, ','))"/>
        </td>
        <td>
          <xsl:value-of select="count (detail[name = 'App'])"/>
        </td>
        <td>
           <xsl:call-template name="host-distance">
             <xsl:with-param name="host" select="."/>
           </xsl:call-template>
        </td>
        <td>
          <xsl:variable name="threat"
                        select="detail[name = 'prognosis']/value"/>
          <xsl:choose>
            <xsl:when test="$threat = 'High'">
              <img src="/img/high.png" alt="High" title="High"/>
            </xsl:when>
            <xsl:when test="$threat = 'Medium'">
              <img src="/img/medium.png" alt="Medium" title="Medium"/>
            </xsl:when>
            <xsl:when test="$threat = 'Low'">
              <img src="/img/low.png" alt="Low" title="Low"/>
            </xsl:when>
            <xsl:when test="$threat = 'Log'">
              <img src="/img/log.png" alt="Log" title="Log"/>
            </xsl:when>
          </xsl:choose>
        </td>
        <td>
          <xsl:value-of select="detail[name = 'report_count' and source/name = 'openvasmd']/value"/>
        </td>
        <td>
          <xsl:variable name="threat"
                        select="detail[name = 'prognosis']/value"/>
          <a href="/omp?cmd=get_report&amp;type=assets&amp;host={ip}&amp;pos=1&amp;search_phrase={../filters/phrase}&amp;levels={gsa:build-levels(../filters)}&amp;first_result={../hosts/@start}&amp;max_results={../hosts/@max}&amp;overrides={../filters/apply_overrides}&amp;token={/envelope/token}"
             title="Host Details" style="margin-left:3px;">
            <img src="/img/details.png" border="0" alt="Details"/>
          </a>
          <xsl:choose>
            <xsl:when test="(count (detail[name = 'App']) = 0) or (string-length ($threat) = 0)">
              <img src="/img/prognosis_inactive.png" border="0" alt="Prognostic Report"
                   style="margin-left:3px;"/>
            </xsl:when>
            <xsl:otherwise>
              <a href="/omp?cmd=get_report&amp;type=prognostic&amp;host={ip}&amp;pos=1&amp;host_search_phrase={../filters/phrase}&amp;host_levels={gsa:build-levels(../filters)}&amp;host_first_result={../hosts/@start}&amp;host_max_results={../hosts/@max}&amp;result_hosts_only=1&amp;overrides={../filters/apply_overrides}&amp;token={/envelope/token}"
                 title="Prognostic Report" style="margin-left:3px;">
                <img src="/img/prognosis.png" border="0" alt="Prognostic Report"/>
              </a>
            </xsl:otherwise>
          </xsl:choose>
        </td>
      </tr>
    </xsl:for-each>
    <tr>
      <td>Total: <xsl:value-of select="count(host)"/></td>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
    </tr>
  </table>
</xsl:template>

<xsl:template match="get_reports_response/report/report" mode="report-assets">
  <table class="gbntable" cellspacing="2" cellpadding="4">
    <tr class="gbntablehead2">
      <td>IP</td>
      <td><img src="/img/high.png" alt="High" title="High"/></td>
      <td><img src="/img/medium.png" alt="Medium" title="Medium"/></td>
      <td><img src="/img/low.png" alt="Low" title="Low"/></td>
      <td>Current Report</td>
      <td>OS</td>
      <td>Ports</td>
      <td>Apps</td>
      <td>Reports</td>
      <td>Distance</td>
    </tr>
    <xsl:for-each select="host">
      <xsl:variable name="current_host" select="ip"/>
      <tr>
        <td>
          <xsl:variable name="hostname" select="detail[name/text() = 'hostname']/value"/>
          <a href="#{$current_host}"><xsl:value-of select="$current_host"/>
          <xsl:if test="$hostname">
            <xsl:value-of select="concat(' (', $hostname, ')')"/>
          </xsl:if>
          </a>
        </td>
        <td>
          <xsl:value-of select="count(../results/result[host/text() = $current_host][threat/text() = 'High'])"/>
        </td>
        <td>
          <xsl:value-of select="count(../results/result[host/text() = $current_host][threat/text() = 'Medium'])"/>
        </td>
        <td>
          <xsl:value-of select="count(../results/result[host/text() = $current_host][threat/text() = 'Low'])"/>
        </td>
        <td>
          <xsl:choose>
            <xsl:when test="../scan_start/text() != ''">
              <a href="/omp?cmd=get_report&amp;report_id={../@id}&amp;notes={../filters/notes}&amp;overrides={../filters/apply_overrides}&amp;result_hosts_only=1&amp;token={/envelope/token}">
                <xsl:value-of select="concat (date:month-abbreviation (../scan_start/text()), ' ', date:day-in-month (../scan_start/text()), ' ', date:year (../scan_start/text()))"/>
              </a>
            </xsl:when>
            <xsl:otherwise>(not finished)</xsl:otherwise>
          </xsl:choose>
        </td>
        <td>
          <xsl:call-template name="os-icon">
            <xsl:with-param name="host" select="../host"/>
            <xsl:with-param name="current_host" select="$current_host"/>
          </xsl:call-template>
        </td>
        <td>
          <xsl:value-of select="count (str:tokenize (detail[name = 'ports']/value, ','))"/>
        </td>
        <td>
          <xsl:value-of select="count (detail[name = 'App'])"/>
        </td>
        <td>
          <xsl:value-of select="../../../../get_tasks_response/task/report_count/finished"/>
        </td>
        <td>
          <xsl:choose>
            <xsl:when test="substring-after (detail[name = 'traceroute']/value, ',') = '?'">
            </xsl:when>
            <xsl:when test="count (detail[name = 'traceroute']) = 0">
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="count (str:tokenize (detail[name = 'traceroute']/value, ',')) - 1"/>
            </xsl:otherwise>
          </xsl:choose>
        </td>
      </tr>
    </xsl:for-each>
    <tr>
      <td>Total: <xsl:value-of select="count(host_start)"/></td>
      <td>
        <xsl:value-of select="count(results/result[threat/text() = 'High'])"/>
      </td>
      <td>
        <xsl:value-of select="count(results/result[threat/text() = 'Medium'])"/>
      </td>
      <td>
        <xsl:value-of select="count(results/result[threat/text() = 'Low'])"/>
      </td>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
    </tr>
  </table>
</xsl:template>

<xsl:template name="report-sections">
  <xsl:param name="current">results</xsl:param>
  <select name="report_section">
    <xsl:if test="$current != 'summary'">
      <xsl:call-template name="opt">
        <xsl:with-param name="value" select="'summary'"/>
        <xsl:with-param name="content" select="'Report: Summary'"/>
      </xsl:call-template>
    </xsl:if>
    <xsl:if test="$current != 'hosts'">
      <xsl:call-template name="opt">
        <xsl:with-param name="value" select="'hosts'"/>
        <xsl:with-param name="content" select="'Report: Hosts'"/>
      </xsl:call-template>
    </xsl:if>
    <xsl:if test="$current != 'ports'">
      <xsl:call-template name="opt">
        <xsl:with-param name="value" select="'ports'"/>
        <xsl:with-param name="content" select="'Report: Ports'"/>
      </xsl:call-template>
    </xsl:if>
    <xsl:if test="$current != 'results'">
      <xsl:call-template name="opt">
        <xsl:with-param name="value" select="'results'"/>
        <xsl:with-param name="content" select="'Report: Results'"/>
      </xsl:call-template>
    </xsl:if>
  </select>
</xsl:template>

<xsl:template name="report-section-filter">
  <xsl:param name="report"/>
  <xsl:param name="section">summary</xsl:param>
  <div style="background-color: #EEEEEE;">
    <div style="float: right">
      <form style="display: inline; margin: 0; vertical-align:middle;" action="" method="post">
        <div style="display: inline; padding: 2px; vertical-align:middle;">
          <input type="hidden" name="token" value="{/envelope/token}"/>
          <input type="hidden" name="cmd" value="create_filter"/>
          <input type="hidden" name="caller" value="{/envelope/caller}"/>
          <input type="hidden" name="term" value="{$report/filters/term}"/>
          <input type="hidden" name="optional_resource_type" value="report_section"/>
          <input type="hidden" name="next" value="get_report_section"/>
          <input type="hidden" name="report_section" value="{$section}"/>
          <input type="hidden" name="filter" value="{/envelope/params/filter}"/>
          <input type="text" name="name" value="" size="10"
                 maxlength="80" style="vertical-align:middle"/>
          <input type="image"
                 name="New Filter"
                 src="/img/new.png"
                 alt="New Filter"
                 style="vertical-align:middle;margin-left:3px;margin-right:3px;"/>
        </div>
      </form>
      <form style="display: inline; margin: 0; vertical-align:middle" action="" method="get">
        <div style="display: inline; padding: 2px; vertical-align:middle;">
          <input type="hidden" name="cmd" value="get_report_section"/>
          <input type="hidden" name="report_id" value="{$report/@id}"/>
          <input type="hidden" name="report_section" value="{$section}"/>
          <select style="margin-bottom: 0px; max-width: 100px;" name="filt_id">
            <option value="">--</option>
            <xsl:variable name="id" select="$report/filters/@id"/>
            <xsl:for-each select="../filters/get_filters_response/filter">
              <xsl:choose>
                <xsl:when test="@id = $id">
                  <option value="{@id}" selected="1"><xsl:value-of select="name"/></option>
                </xsl:when>
                <xsl:otherwise>
                  <option value="{@id}"><xsl:value-of select="name"/></option>
                </xsl:otherwise>
              </xsl:choose>
            </xsl:for-each>
          </select>
          <input type="hidden" name="token" value="{/envelope/token}"/>
          <input type="image"
                 name="Switch Filter"
                 src="/img/refresh.png"
                 alt="Switch" style="vertical-align:middle;margin-left:3px;margin-right:3px;"/>
          <a href="/omp?cmd=get_filters&amp;token={/envelope/token}"
             title="Filters">
            <img style="vertical-align:middle;margin-left:3px;margin-right:3px;"
                 src="/img/list.png" border="0" alt="Filters"/>
          </a>
        </div>
      </form>
    </div>

    <form action="" method="get">
      <input type="hidden" name="cmd" value="get_report_section"/>
      <input type="hidden" name="report_id" value="{$report/@id}"/>
      <input type="hidden" name="report_section" value="{$section}"/>
      <div style="padding: 2px;">
        Filter:
        <input type="text" name="filter" size="57"
               value="{concat ($report/filters/term, ' ')}"
               maxlength="1000"/>
        <input type="image"
               name="Update Filter"
               src="/img/refresh.png"
               alt="Update" style="vertical-align:middle;margin-left:3px;margin-right:3px;"/>
        <a href="/help/powerfilter.html?token={/envelope/token}" title="Help: Powerfilter">
          <img style="vertical-align:middle;margin-left:3px;margin-right:3px;"
               src="/img/help.png" border="0"/>
        </a>
      </div>
      <input type="hidden" name="token" value="{/envelope/token}"/>
    </form>
  </div>
</xsl:template>

<xsl:template name="host-distance">
  <xsl:param name="host"/>
  <xsl:choose>
    <xsl:when test="substring-after ($host/detail[name = 'traceroute']/value, ',') = '?'">
    </xsl:when>
    <xsl:when test="count ($host/detail[name = 'traceroute']) = 0">
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="count (str:tokenize ($host/detail[name = 'traceroute']/value, ',')) - 1"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template match="get_report_hosts_response">
  <xsl:apply-templates select="gsad_msg"/>
  <xsl:variable name="report" select="get_reports_response/report/report"/>
  <div class="gb_window">
    <div class="gb_window_part_left"></div>
    <div class="gb_window_part_right"></div>
    <div class="gb_window_part_center">
      Report: Hosts
      <a href="/help/view_report.html?token={/envelope/token}#viewreport"
         title="Help: View Report (View Report)">
        <img style="vertical-align: text-top;margin-left: 3px" src="/img/help.png"/>
      </a>

      <div id="small_inline_form" style="display: inline; margin-left: 20px; font-weight: normal;">
        <form action="/omp" method="get">
          <input type="hidden" name="cmd" value="get_report_section"/>
          <input type="hidden" name="report_id" value="{$report/@id}"/>
          <xsl:call-template name="report-sections">
            <xsl:with-param name="current" select="'hosts'"/>
          </xsl:call-template>
          <input type="image"
                 name="Go to Section"
                 src="/img/refresh.png"
                 alt="Go to Section"
                 style="vertical-align: text-top;margin-left:3px;"/>
          <input type="hidden" name="filter" value="{/envelope/params/filter}"/>
          <input type="hidden" name="filt_id" value="{/envelope/params/filt_id}"/>
          <input type="hidden" name="token" value="{/envelope/token}"/>
        </form>
      </div>
    </div>
    <div class="gb_window_part_content">
      <xsl:call-template name="report-section-filter">
        <xsl:with-param name="report" select="$report"/>
        <xsl:with-param name="section" select="'hosts'"/>
      </xsl:call-template>

      <table class="gbntable" cellspacing="2" cellpadding="4">
        <tr class="gbntablehead2">
          <td>Host</td>
          <td>OS</td>
          <td>Ports</td>
          <td>Apps</td>
          <td>Distance</td>
          <td>Start</td>
          <td>End</td>
          <td><img src="/img/high.png" alt="High" title="High"/></td>
          <td><img src="/img/medium.png" alt="Medium" title="Medium"/></td>
          <td><img src="/img/low.png" alt="Low" title="Low"/></td>
          <td><img src="/img/log.png" alt="Log" title="Log"/></td>
          <td><img src="/img/false_positive.png" alt="False Positive" title="False Positive"/></td>
          <td>Total</td>
        </tr>
        <xsl:for-each select="$report/host" >
          <xsl:variable name="current_host" select="ip"/>
          <tr>
            <td>
              <xsl:variable name="hostname" select="detail[name/text() = 'hostname']/value"/>
              <xsl:value-of select="$current_host"/>
              <xsl:if test="$hostname">
                <xsl:value-of select="concat(' (', $hostname, ')')"/>
              </xsl:if>
            </td>
            <td>
              <xsl:call-template name="os-icon">
                <xsl:with-param name="host" select="../host"/>
                <xsl:with-param name="current_host" select="$current_host"/>
              </xsl:call-template>
            </td>
            <td>
              <xsl:value-of select="count (str:tokenize (detail[name = 'ports']/value, ','))"/>
            </td>
            <td>
              <xsl:value-of select="count (detail[name = 'App'])"/>
            </td>
            <td>
              <xsl:call-template name="host-distance">
                <xsl:with-param name="host" select="."/>
              </xsl:call-template>
            </td>
            <td>
              <xsl:value-of select="concat (date:month-abbreviation(start/text()), ' ', date:day-in-month(start/text()), ', ', format-number(date:hour-in-day(start/text()), '00'), ':', format-number(date:minute-in-hour(start/text()), '00'), ':', format-number(date:second-in-minute(start/text()), '00'))"/>
            </td>
            <td>
              <xsl:choose>
                <xsl:when test="end/text() != ''">
                  <xsl:value-of select="concat (date:month-abbreviation(end/text()), ' ', date:day-in-month(end/text()), ', ', format-number(date:hour-in-day(end/text()), '00'), ':', format-number(date:minute-in-hour(end/text()), '00'), ':', format-number(date:second-in-minute(end/text()), '00'))"/>
                </xsl:when>
                <xsl:otherwise>(not finished)</xsl:otherwise>
              </xsl:choose>
            </td>
            <td style="text-align:right">
              <a href="/omp?cmd=get_report&amp;report_id={$report/@id}&amp;filter==&#34;{$current_host}&#34; levels=h&amp;filt_id=&amp;token={/envelope/token}"
                 title="Report: Summary ({$current_host} High)" style="margin-left:3px;">
                <xsl:value-of select="count(../results/result[host/text() = $current_host][threat/text() = 'High'])"/>
              </a>
            </td>
            <td style="text-align:right">
              <a href="/omp?cmd=get_report&amp;report_id={$report/@id}&amp;filter==&#34;{$current_host}&#34; levels=m&amp;filt_id=&amp;token={/envelope/token}"
                 title="Report: Summary ({$current_host} Medium)" style="margin-left:3px;">
                <xsl:value-of select="count(../results/result[host/text() = $current_host][threat/text() = 'Medium'])"/>
              </a>
            </td>
            <td style="text-align:right">
              <a href="/omp?cmd=get_report&amp;report_id={$report/@id}&amp;filter==&#34;{$current_host}&#34; levels=l&amp;filt_id=&amp;token={/envelope/token}"
                 title="Report: Summary ({$current_host} Low)" style="margin-left:3px;">
                <xsl:value-of select="count(../results/result[host/text() = $current_host][threat/text() = 'Low'])"/>
              </a>
            </td>
            <td style="text-align:right">
              <a href="/omp?cmd=get_report&amp;report_id={$report/@id}&amp;filter==&#34;{$current_host}&#34; levels=g&amp;filt_id=&amp;token={/envelope/token}"
                 title="Report: Summary ({$current_host} Log)" style="margin-left:3px;">
                <xsl:value-of select="count(../results/result[host/text() = $current_host][threat/text() = 'Log'])"/>
              </a>
            </td>
            <td style="text-align:right">
              <a href="/omp?cmd=get_report&amp;report_id={$report/@id}&amp;filter==&#34;{$current_host}&#34; levels=f&amp;filt_id=&amp;token={/envelope/token}"
                 title="Report: Summary ({$current_host} False Positive)" style="margin-left:3px;">
                <xsl:value-of select="count(../results/result[host/text() = $current_host][threat/text() = 'False Positive'])"/>
              </a>
            </td>
            <td style="text-align:right">
              <a href="/omp?cmd=get_report&amp;report_id={$report/@id}&amp;filter==&#34;{$current_host}&#34; levels=hmlgf&amp;filt_id=&amp;token={/envelope/token}"
                 title="Report: Summary ({$current_host} All)" style="margin-left:3px;">
                <xsl:value-of select="count(../results/result[host/text() = $current_host])"/>
              </a>
            </td>
          </tr>
        </xsl:for-each>
        <tr>
          <td>Total: <xsl:value-of select="count($report/host_start)"/></td>
          <td></td>
          <td></td>
          <td></td>
          <td></td>
          <td></td>
          <td></td>
          <td style="text-align:right">
            <a href="/omp?cmd=get_report&amp;report_id={$report/@id}&amp;filter=levels=h&amp;filt_id=&amp;token={/envelope/token}"
               title="Report: Summary (High)" style="margin-left:3px;">
              <xsl:value-of select="count($report/results/result[threat/text() = 'High'])"/>
            </a>
          </td>
          <td style="text-align:right">
            <a href="/omp?cmd=get_report&amp;report_id={$report/@id}&amp;filter=levels=m&amp;filt_id=&amp;token={/envelope/token}"
               title="Report: Summary (Medium)" style="margin-left:3px;">
              <xsl:value-of select="count($report/results/result[threat/text() = 'Medium'])"/>
            </a>
          </td>
          <td style="text-align:right">
            <a href="/omp?cmd=get_report&amp;report_id={$report/@id}&amp;filter=levels=l&amp;filt_id=&amp;token={/envelope/token}"
               title="Report: Summary (Low)" style="margin-left:3px;">
              <xsl:value-of select="count($report/results/result[threat/text() = 'Low'])"/>
            </a>
          </td>
          <td style="text-align:right">
            <a href="/omp?cmd=get_report&amp;report_id={$report/@id}&amp;filter=levels=g&amp;filt_id=&amp;token={/envelope/token}"
               title="Report: Summary (Log)" style="margin-left:3px;">
              <xsl:value-of select="count($report/results/result[threat/text() = 'Log'])"/>
            </a>
          </td>
          <td style="text-align:right">
            <a href="/omp?cmd=get_report&amp;report_id={$report/@id}&amp;filter=levels=f&amp;filt_id=&amp;token={/envelope/token}"
               title="Report: Summary (False Positive)" style="margin-left:3px;">
              <xsl:value-of select="count($report/results/result[threat/text() = 'False Positive'])"/>
            </a>
          </td>
          <td style="text-align:right">
            <a href="/omp?cmd=get_report&amp;report_id={$report/@id}&amp;filter=levels=hmlgf&amp;filt_id=&amp;token={/envelope/token}"
               title="Report: Summary (All)" style="margin-left:3px;">
              <xsl:value-of select="count($report/results/result)"/>
            </a>
          </td>
        </tr>
      </table>
    </div>
  </div>
</xsl:template>

<xsl:key name="kReportPorts" match="get_reports_response/report/report/ports/port/text()" use="."/>
<xsl:template match="get_report_ports_response">
  <xsl:apply-templates select="gsad_msg"/>
  <xsl:variable name="report" select="get_reports_response/report/report"/>
  <div class="gb_window">
    <div class="gb_window_part_left"></div>
    <div class="gb_window_part_right"></div>
    <div class="gb_window_part_center">
      Report: Ports

      <a href="/help/view_report.html?token={/envelope/token}#viewreport"
         title="Help: View Report (View Report)">
        <img style="vertical-align: text-top;margin-left: 3px" src="/img/help.png"/>
      </a>

      <div id="small_inline_form" style="display: inline; margin-left: 20px; font-weight: normal;">
        <form action="/omp" method="get">
          <input type="hidden" name="cmd" value="get_report_section"/>
          <input type="hidden" name="report_id" value="{$report/@id}"/>
          <xsl:call-template name="report-sections">
            <xsl:with-param name="current" select="'ports'"/>
          </xsl:call-template>
          <input type="image"
                 name="Go to Section"
                 src="/img/refresh.png"
                 alt="Go to Section"
                 style="vertical-align: text-top;margin-left:3px;"/>
          <input type="hidden" name="filter" value="{/envelope/params/filter}"/>
          <input type="hidden" name="filt_id" value="{/envelope/params/filt_id}"/>
          <input type="hidden" name="token" value="{/envelope/token}"/>
        </form>
      </div>
    </div>
    <div class="gb_window_part_content">
      <xsl:call-template name="report-section-filter">
        <xsl:with-param name="report" select="$report"/>
        <xsl:with-param name="section" select="'ports'"/>
      </xsl:call-template>

      <table class="gbntable" cellpadding="4">
          <col/>
          <col/>
          <col/>
          <col width="100px"/>
        <tr class="gbntablehead2">
          <td>Port</td>
          <td>IANA</td>
          <td>Hosts</td>
          <td>Threat</td>
        </tr>

        <xsl:for-each select="$report/ports/port[contains(text(), 'general/') = 0]/text()[generate-id() = generate-id(key('kReportPorts', .))]">
          <xsl:sort data-type="number" select="substring-before (../text(), '/')"/>
          <xsl:variable name="port" select="../text()"/>
            <tr class="{gsa:table-row-class(position())}">
              <td>
                <xsl:choose>
                  <xsl:when test="contains($port, ' ')">
                    <xsl:value-of select="substring-before($port, ' ')"/>
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:value-of select="$port"/>
                  </xsl:otherwise>
                </xsl:choose>
              </td>
              <td>
                <xsl:choose>
                  <xsl:when test="contains($port, 'IANA: ')">
                    <xsl:value-of select="substring-before(substring-after($port, 'IANA: '), ')')"/>
                  </xsl:when>
                  <xsl:otherwise>
                  </xsl:otherwise>
                </xsl:choose>
              </td>
              <td>
                  <xsl:value-of select="count($report/ports/port[text() = $port])"/>
              </td>
              <td>
                <xsl:variable name="threat" select="gsa:lower-case(../threat)"/>
                <xsl:variable name="extra_text">
                  <xsl:choose>
                    <xsl:when test="$threat = 'low' or $threat = 'medium' or $threat = 'high'">
                      <xsl:value-of select="../threat"/>
                    </xsl:when>
                    <xsl:otherwise>None</xsl:otherwise>
                  </xsl:choose>
                </xsl:variable>

                  <xsl:call-template name="severity-bar">
                    <xsl:with-param name="extra_text" select="$extra_text"/>
                    <xsl:with-param name="cvss" select="gsa:threat-max-cvss($threat)"/>
                    <xsl:with-param name="notext" select="'1'"/>
                  </xsl:call-template>
              </td>
            </tr>
        </xsl:for-each>
      </table>
    </div>
  </div>
</xsl:template>

<xsl:template match="get_report_summary_response">
  <xsl:apply-templates select="get_report/get_reports_response/report"
                       mode="summary"/>
</xsl:template>

<xsl:template match="report" mode="summary">
  <xsl:variable name="levels"
                select="report/filters/text()"/>
  <xsl:variable name="apply-overrides"
                select="report/filters/apply_overrides"/>
  <div class="gb_window">
    <div class="gb_window_part_left"></div>
    <div class="gb_window_part_right"></div>
    <div class="gb_window_part_center">
      <xsl:if test="../../delta">
        Delta
      </xsl:if>
      <xsl:if test="@type='prognostic'">
        Prognostic
      </xsl:if>
      <xsl:value-of select="gsa:i18n('Report: Summary')"/>
      <a href="/help/view_report.html?token={/envelope/token}#viewreport"
         title="Help: View Report (View Report)">
        <img style="vertical-align: text-top;margin-left: 5px" src="/img/help.png"/>
      </a>
      <div id="small_inline_form" style="vertical-align: text-top;display: inline; margin-left: 20px; font-weight: normal;">
        <form action="/omp" method="get">
          <input type="hidden" name="cmd" value="get_report_section"/>
          <input type="hidden" name="report_id" value="{report/@id}"/>
          <xsl:call-template name="report-sections">
            <xsl:with-param name="current" select="'summary'"/>
          </xsl:call-template>
          <input type="image"
                 name="Go to Section"
                 src="/img/refresh.png"
                 alt="Go to Section"
                 style="vertical-align: text-top;margin-left:3px;"/>
          <input type="hidden" name="filter" value="{/envelope/params/filter}"/>
          <input type="hidden" name="filt_id" value="{/envelope/params/filt_id}"/>
          <input type="hidden" name="token" value="{/envelope/token}"/>
        </form>
      </div>
    </div>
    <div class="gb_window_part_content">
      <xsl:call-template name="report-section-filter">
        <xsl:with-param name="report" select="report"/>
        <xsl:with-param name="section" select="'summary'"/>
      </xsl:call-template>

      <xsl:choose>
        <xsl:when test="@type='prognostic'">
          <div class="float_right">
            <a href="?cmd=get_report&amp;type=assets&amp;levels={../../host_levels}&amp;search_phrase={../../host_search_phrase}&amp;first_result={../../results/@start}&amp;max_results={../../results/@max}&amp;overrides={$apply-overrides}&amp;token={/envelope/token}">Hosts</a>
          </div>
        </xsl:when>
      </xsl:choose>

      <a name="summary"/>
      <table border="0" cellspacing="0" cellpadding="3">
        <xsl:choose>
          <xsl:when test="@type='prognostic' and string-length (report/filters/host) &gt; 0">
            <tr>
              <td><b>Host:</b></td>
              <td><b><xsl:value-of select="report/filters/host"/></b></td>
            </tr>
          </xsl:when>
          <xsl:when test="@type='prognostic'">
            <tr>
              <td><b>Multiple hosts</b></td>
              <td></td>
            </tr>
          </xsl:when>
          <xsl:otherwise>
            <tr>
              <td><b>Result of Task:</b></td>
              <td>
                <a href="?cmd=get_task&amp;task_id={report/task/@id}&amp;overrides={$apply-overrides}&amp;token={/envelope/token}">
                  <xsl:value-of select="report/task/name"/>
                </a>
              </td>
            </tr>
            <tr>
              <td>Order of results:</td>
              <td>by host</td>
            </tr>
          </xsl:otherwise>
        </xsl:choose>
        <xsl:choose>
          <xsl:when test="@type='prognostic'">
          </xsl:when>
          <xsl:when test="../../delta">
            <tr>
              <td>Report 1:</td>
              <td><a href="/omp?cmd=get_report&amp;report_id={report/@id}&amp;overrides={report/filters/overrides}&amp;autofp={report/filters/autofp}&amp;filter={str:encode-uri (/envelope/params/filter, true ())}&amp;filt_id={/envelope/params/filt_id}&amp;token={/envelope/token}"><xsl:value-of select="report/@id"/></a></td>
            </tr>
            <tr>
              <td><b>Scan 1 started:</b></td>
              <td><b><xsl:value-of select="report/scan_start"/></b></td>
            </tr>
            <tr>
              <td>Scan 1 ended:</td>
              <td><xsl:value-of select="report/scan_end"/></td>
            </tr>
            <tr>
              <td>Scan 1 status:</td>
              <td>
                <xsl:call-template name="status_bar">
                  <xsl:with-param name="status">
                    <xsl:choose>
                      <xsl:when test="report/task/target/@id='' and report/scan_run_status='Running'">
                        <xsl:text>Uploading</xsl:text>
                      </xsl:when>
                      <xsl:when test="report/task/target/@id=''">
                        <xsl:text>Container</xsl:text>
                      </xsl:when>
                      <xsl:otherwise>
                        <xsl:value-of select="report/scan_run_status"/>
                      </xsl:otherwise>
                    </xsl:choose>
                  </xsl:with-param>
                  <xsl:with-param name="progress">
                    <xsl:value-of select="../../get_tasks_response/task/progress/text()"/>
                  </xsl:with-param>
                </xsl:call-template>
              </td>
            </tr>
            <tr>
              <td>Report 2:</td>
              <td>
                <a href="/omp?cmd=get_report&amp;report_id={report/delta/report/@id}&amp;overrides={report/filters/overrides}&amp;autofp={report/filters/autofp}&amp;filter={str:encode-uri (/envelope/params/filter, true ())}&amp;filt_id={/envelope/params/filt_id}&amp;token={/envelope/token}"><xsl:value-of select="report/delta/report/@id"/></a>
              </td>
            </tr>
            <tr>
              <td><b>Scan 2 started:</b></td>
              <td><b><xsl:value-of select="report/delta/report/scan_start"/></b></td>
            </tr>
            <tr>
              <td>Scan 2 ended:</td>
              <td><xsl:value-of select="report/delta/report/scan_end"/></td>
            </tr>
            <tr>
              <td>Scan 2 status:</td>
              <td>
                <xsl:call-template name="status_bar">
                  <xsl:with-param name="status">
                    <xsl:choose>
                      <xsl:when test="report/target/@id='' and report/delta/report/scan_run_status='Running'">
                        <xsl:text>Uploading</xsl:text>
                      </xsl:when>
                      <xsl:when test="report/task/target/@id=''">
                        <xsl:text>Container</xsl:text>
                      </xsl:when>
                      <xsl:otherwise>
                        <xsl:value-of select="report/delta/report/scan_run_status"/>
                      </xsl:otherwise>
                    </xsl:choose>
                  </xsl:with-param>
                  <xsl:with-param name="progress">
                    <xsl:value-of select="../../get_tasks_response/task/progress/text()"/>
                  </xsl:with-param>
                </xsl:call-template>
              </td>
            </tr>
          </xsl:when>
          <xsl:otherwise>
            <tr>
              <td><b>Scan started:</b></td>
              <td>
                <xsl:if test="string-length (report/scan_start)">
                  <b><xsl:value-of select="concat (date:day-abbreviation (report/scan_start), ' ', date:month-abbreviation (report/scan_start), ' ', date:day-in-month (report/scan_start), ' ', format-number(date:hour-in-day(report/scan_start), '00'), ':', format-number(date:minute-in-hour(report/scan_start), '00'), ':', format-number(date:second-in-minute(report/scan_start), '00'), ' ', date:year(report/scan_start))"/></b>
                </xsl:if>
              </td>
            </tr>
            <tr>
              <td>Scan ended:</td>
              <td>
                <xsl:if test="string-length (report/scan_end)">
                  <xsl:value-of select="concat (date:day-abbreviation (report/scan_end), ' ', date:month-abbreviation (report/scan_end), ' ', date:day-in-month (report/scan_end), ' ', format-number(date:hour-in-day(report/scan_end), '00'), ':', format-number(date:minute-in-hour(report/scan_end), '00'), ':', format-number(date:second-in-minute(report/scan_end), '00'), ' ', date:year(report/scan_end))"/>
                </xsl:if>
              </td>
            </tr>
            <tr>
              <td>Scan status:</td>
              <td>
                <xsl:call-template name="status_bar">
                  <xsl:with-param name="status">
                    <xsl:choose>
                      <xsl:when test="report/task/target/@id='' and report/scan_run_status='Running'">
                        <xsl:text>Uploading</xsl:text>
                      </xsl:when>
                      <xsl:when test="report/task/target/@id=''">
                        <xsl:text>Container</xsl:text>
                      </xsl:when>
                      <xsl:otherwise>
                        <xsl:value-of select="report/scan_run_status"/>
                      </xsl:otherwise>
                    </xsl:choose>
                  </xsl:with-param>
                  <xsl:with-param name="progress">
                    <xsl:value-of select="../../get_tasks_response/task/progress/text()"/>
                  </xsl:with-param>
                </xsl:call-template>
              </td>
            </tr>
          </xsl:otherwise>
        </xsl:choose>
      </table>
      <br/>
      <table class="gbntable" cellspacing="2" cellpadding="4">
        <tr class="gbntablehead2">
          <td></td>
          <td><img src="/img/high.png" alt="High" title="High"/></td>
          <td><img src="/img/medium.png" alt="Medium" title="Medium"/></td>
          <td><img src="/img/low.png" alt="Low" title="Low"/></td>
          <td><img src="/img/log.png" alt="Log" title="Log"/></td>
          <td><img src="/img/false_positive.png" alt="False Positive" title="False Positive"/></td>
          <td>Total</td>
          <xsl:choose>
            <xsl:when test="@type='prognostic'">
              <td>Download</td>
            </xsl:when>
            <xsl:when test="../../delta">
              <td>Download</td>
            </xsl:when>
            <xsl:otherwise>
              <td>Run Alert</td>
              <td>Download</td>
            </xsl:otherwise>
          </xsl:choose>
        </tr>
        <xsl:choose>
          <xsl:when test="@type='prognostic'">
          </xsl:when>
          <xsl:when test="../../delta">
          </xsl:when>
          <xsl:otherwise>
            <tr>
              <td>Full report:</td>
              <td>
                <xsl:value-of select="report/result_count/hole/full"/>
              </td>
              <td>
                <xsl:value-of select="report/result_count/warning/full"/>
              </td>
              <td>
                <xsl:value-of select="report/result_count/info/full"/>
              </td>
              <td>
                <xsl:value-of select="report/result_count/log/full"/>
              </td>
              <td>
                <xsl:value-of select="report/result_count/false_positive/full"/>
              </td>
              <td>
                <xsl:value-of select="report/result_count/hole/full + report/result_count/warning/full + report/result_count/info/full + report/result_count/log/full + report/result_count/false_positive/full"/>
              </td>
              <td>
                <div id="small_form" style="float:right;">
                  <form action="" method="post">
                    <input type="hidden" name="cmd" value="alert_report"/>
                    <input type="hidden" name="caller" value="{/envelope/caller}"/>
                    <input type="hidden" name="report_id" value="{report/@id}"/>
                    <input type="hidden" name="report_section" value="summary"/>
                    <input type="hidden" name="filter" value="{report/filters/term}"/>
                    <input type="hidden" name="filt_id" value="{report/filters/@id}"/>
                    <input type="hidden" name="token" value="{/envelope/token}"/>

                    <!-- Report page filters. -->
                    <input type="hidden" name="overrides" value="{$apply-overrides}"/>
                    <input type="hidden" name="autofp" value="{report/filters/autofp}"/>

                    <!-- Alert filters. -->
                    <input type="hidden" name="esc_first_result" value="1"/>
                    <input type="hidden" name="esc_max_results" value="{report/result_count/hole/full + report/result_count/warning/full + report/result_count/info/full + report/result_count/log/full + report/result_count/false_positive/full}"/>
                    <input type="hidden" name="esc_notes" value="1"/>
                    <input type="hidden" name="esc_overrides" value="1"/>
                    <input type="hidden" name="esc_result_hosts_only" value="1"/>
                    <input type="hidden" name="esc_levels" value="hmlgf"/>

                    <select name="alert_id" title="Alert">
                      <xsl:for-each select="../../get_alerts_response/alert">
                        <option value="{@id}"><xsl:value-of select="name"/></option>
                      </xsl:for-each>
                    </select>
                    <input type="image"
                           name="submit"
                           value="Run Alert"
                           title="Run Alert"
                           src="/img/start.png"
                           border="0"
                           style="margin-left:3px;"
                           alt="Run Alert"/>
                  </form>
                </div>
              </td>
              <td>
                <div id="small_form" style="float:right;">
                  <form action="" method="get">
                    <input type="hidden" name="token" value="{/envelope/token}"/>
                    <input type="hidden" name="cmd" value="get_report"/>
                    <input type="hidden" name="report_id" value="{report/@id}"/>
                    <input type="hidden" name="first_result" value="1"/>
                    <input type="hidden" name="max_results" value="{report/result_count/hole/full + report/result_count/warning/full + report/result_count/info/full + report/result_count/log/full + report/result_count/false_positive/full}"/>
                    <input type="hidden" name="notes" value="1"/>
                    <input type="hidden" name="overrides" value="1"/>
                    <input type="hidden" name="result_hosts_only" value="1"/>
                    <input type="hidden" name="levels" value="hmlgf"/>
                    <input type="hidden" name="autofp"
                           value="{report/filters/autofp}"/>
                    <select name="report_format_id" title="Download Format">
                      <xsl:for-each select="../../get_report_formats_response/report_format[active=1 and (trust/text()='yes' or predefined='1')]">
                        <xsl:choose>
                          <xsl:when test="@type='prognostic' and name='PDF'">
                            <option value="{@id}" selected="1"><xsl:value-of select="name"/></option>
                          </xsl:when>
                          <xsl:when test="@type='../../delta' and name='PDF'">
                            <option value="{@id}" selected="1"><xsl:value-of select="name"/></option>
                          </xsl:when>
                          <xsl:when test="name='PDF'">
                            <option value="{@id}" selected="1"><xsl:value-of select="name"/></option>
                          </xsl:when>
                          <xsl:otherwise>
                            <option value="{@id}"><xsl:value-of select="name"/></option>
                          </xsl:otherwise>
                        </xsl:choose>
                      </xsl:for-each>
                    </select>
                    <input type="image"
                           name="submit"
                           value="Download"
                           title="Download"
                           src="/img/download.png"
                           border="0"
                           style="margin-left:3px;"
                           alt="Download"/>
                  </form>
                </div>
              </td>
            </tr>
          </xsl:otherwise>
        </xsl:choose>
        <tr>
          <td>All filtered
              <xsl:if test="@type='prognostic'">
                prognostic
              </xsl:if>
              results:</td>
          <td>
            <xsl:value-of select="report/result_count/hole/filtered"/>
          </td>
          <td>
            <xsl:value-of select="report/result_count/warning/filtered"/>
          </td>
          <td>
            <xsl:value-of select="report/result_count/info/filtered"/>
          </td>
          <td>
            <xsl:value-of select="report/result_count/log/filtered"/>
          </td>
          <td>
            <xsl:value-of select="report/result_count/false_positive/filtered"/>
          </td>
          <td>
            <xsl:value-of select="report/result_count/hole/filtered + report/result_count/warning/filtered + report/result_count/info/filtered + report/result_count/log/filtered + report/result_count/false_positive/filtered"/>
          </td>
          <xsl:choose>
            <xsl:when test="@type='prognostic'">
            </xsl:when>
            <xsl:when test="../../delta">
            </xsl:when>
            <xsl:otherwise>
              <td>
                <div id="small_form" style="float:right;">
                  <form action="" method="post">
                    <input type="hidden" name="cmd" value="alert_report"/>
                    <input type="hidden" name="caller" value="{/envelope/caller}"/>
                    <input type="hidden" name="report_id" value="{report/@id}"/>
                    <input type="hidden" name="report_section" value="summary"/>
                    <input type="hidden" name="filter" value="{report/filters/term}"/>
                    <input type="hidden" name="filt_id" value="{report/filters/@id}"/>
                    <input type="hidden" name="token" value="{/envelope/token}"/>

                    <!-- Report page filters. -->
                    <input type="hidden" name="overrides" value="{$apply-overrides}"/>
                    <input type="hidden" name="autofp" value="{report/filters/autofp}"/>

                    <!-- Alert filters. -->
                    <input type="hidden" name="esc_first_result" value="{report/results/@start}"/>
                    <input type="hidden" name="esc_max_results" value="{report/result_count/hole/filtered + report/result_count/warning/filtered + report/result_count/info/filtered + report/result_count/log/filtered + report/result_count/false_positive/filtered}"/>
                    <input type="hidden" name="esc_levels" value="{$levels}"/>
                    <input type="hidden"
                           name="esc_search_phrase"
                           value="{report/filters/phrase}"/>
                    <input type="hidden"
                           name="esc_apply_min_cvss_base"
                           value="{number (string-length (report/filters/min_cvss_base) &gt; 0)}"/>
                    <input type="hidden"
                           name="esc_min_cvss_base"
                           value="{report/filters/min_cvss_base}"/>
                    <input type="hidden" name="esc_notes" value="{report/filters/notes}"/>
                    <input type="hidden"
                           name="esc_overrides"
                           value="{$apply-overrides}"/>
                    <input type="hidden"
                           name="esc_result_hosts_only"
                           value="{report/filters/result_hosts_only}"/>

                    <select name="alert_id" title="Alert">
                      <xsl:for-each select="../../get_alerts_response/alert">
                        <option value="{@id}"><xsl:value-of select="name"/></option>
                      </xsl:for-each>
                    </select>
                    <input type="image"
                           name="submit"
                           value="Run Alert"
                           title="Run Alert"
                           src="/img/start.png"
                           border="0"
                           style="margin-left:3px;"
                           alt="Run Alert"/>
                  </form>
                </div>
              </td>
            </xsl:otherwise>
          </xsl:choose>
          <xsl:choose>
            <xsl:when test="false">
            </xsl:when>
            <xsl:otherwise>
              <td>
                <div id="small_form" style="float:right;">
                  <form action="" method="get">
                    <input type="hidden" name="token" value="{/envelope/token}"/>
                    <input type="hidden" name="cmd" value="get_report"/>
                    <input type="hidden" name="report_id" value="{report/@id}"/>

                    <xsl:choose>
                      <xsl:when test="../../delta">
                        <input type="hidden" name="delta_report_id" value="{report/delta/report/@id}"/>
                        <input type="hidden" name="delta_states" value="{report/filters/delta/text()}"/>
                      </xsl:when>
                      <xsl:when test="@type='prognostic'">
                        <input type="hidden" name="type" value="prognostic"/>
                        <input type="hidden" name="host" value="{report/filters/host}"/>
                        <input type="hidden" name="host_search_phrase" value="{../../host_search_phrase}"/>
                        <input type="hidden" name="host_levels" value="{../../host_levels}"/>
                        <input type="hidden" name="host_first_result" value="{../../results/@start}"/>
                        <input type="hidden" name="host_max_results" value="{../../results/@max}"/>
                      </xsl:when>
                    </xsl:choose>

                    <input type="hidden" name="first_result" value="{report/results/@start}"/>
                    <input type="hidden" name="max_results" value="{report/result_count/hole/filtered + report/result_count/warning/filtered + report/result_count/info/filtered + report/result_count/log/filtered + report/result_count/false_positive/filtered}"/>
                    <input type="hidden" name="levels" value="{$levels}"/>
                    <input type="hidden"
                           name="search_phrase"
                           value="{report/filters/phrase}"/>
                    <input type="hidden"
                           name="apply_min_cvss_base"
                           value="{number (string-length (report/filters/min_cvss_base) &gt; 0)}"/>
                    <input type="hidden"
                           name="min_cvss_base"
                           value="{report/filters/min_cvss_base}"/>
                    <input type="hidden"
                           name="sort_field"
                           value="{report/sort/field/text()}"/>
                    <input type="hidden"
                           name="sort_order"
                           value="{report/sort/field/order}"/>
                    <input type="hidden" name="notes" value="{report/filters/notes}"/>
                    <input type="hidden"
                           name="overrides"
                           value="{$apply-overrides}"/>
                    <input type="hidden"
                           name="result_hosts_only"
                           value="{report/filters/result_hosts_only}"/>
                    <input type="hidden" name="autofp"
                           value="{report/filters/autofp}"/>
                    <select name="report_format_id" title="Download Format">
                      <xsl:for-each select="../../get_report_formats_response/report_format[active=1 and (trust/text()='yes' or predefined='1')]">
                        <xsl:choose>
                          <xsl:when test="@type='prognostic' and name='PDF'">
                            <option value="{@id}" selected="1"><xsl:value-of select="name"/></option>
                          </xsl:when>
                          <xsl:when test="@type='../../delta' and name='PDF'">
                            <option value="{@id}" selected="1"><xsl:value-of select="name"/></option>
                          </xsl:when>
                          <xsl:when test="name='PDF'">
                            <option value="{@id}" selected="1"><xsl:value-of select="name"/></option>
                          </xsl:when>
                          <xsl:otherwise>
                            <option value="{@id}"><xsl:value-of select="name"/></option>
                          </xsl:otherwise>
                        </xsl:choose>
                      </xsl:for-each>
                    </select>
                    <input type="image"
                           name="submit"
                           value="Download"
                           title="Download"
                           src="/img/download.png"
                           border="0"
                           style="margin-left:3px;"
                           alt="Download"/>
                  </form>
                </div>
              </td>
            </xsl:otherwise>
          </xsl:choose>
        </tr>
        <tr>
          <td>
            <xsl:variable name="last" select="report/results/@start + count(report/results/result) - 1"/>
            <xsl:choose>
              <xsl:when test="count(report/results/result) &gt; 0">
                Filtered
                <xsl:if test="@type='prognostic'">
                  prognostic
                </xsl:if>
                results
                <xsl:value-of select="report/results/@start"/>
                -
                <xsl:value-of select="$last"/>:
              </xsl:when>
              <xsl:otherwise>
                Filtered
                <xsl:if test="@type='prognostic'">
                  prognostic
                </xsl:if>
                results:
              </xsl:otherwise>
            </xsl:choose>
          </td>
          <td>
            <xsl:value-of select="count(report/results/result[threat/text() = 'High'])"/>
          </td>
          <td>
            <xsl:value-of select="count(report/results/result[threat/text() = 'Medium'])"/>
          </td>
          <td>
            <xsl:value-of select="count(report/results/result[threat/text() = 'Low'])"/>
          </td>
          <td>
            <xsl:value-of select="count(report/results/result[threat/text() = 'Log'])"/>
          </td>
          <td>
            <xsl:value-of select="count(report/results/result[threat/text() = 'False Positive'])"/>
          </td>
          <td>
            <xsl:value-of select="count(report/results/result)"/>
          </td>
          <xsl:choose>
            <xsl:when test="@type='prognostic'">
            </xsl:when>
            <xsl:when test="../../delta">
            </xsl:when>
            <xsl:otherwise>
              <td>
                <div id="small_form" class="float_right">
                  <form action="" method="post">
                    <input type="hidden" name="cmd" value="alert_report"/>
                    <input type="hidden" name="report_section" value="summary"/>
                    <input type="hidden" name="caller" value="{/envelope/caller}"/>
                    <input type="hidden" name="report_id" value="{report/@id}"/>
                    <input type="hidden" name="filter" value="{report/filters/term}"/>
                    <input type="hidden" name="filt_id" value="{report/filters/@id}"/>
                    <input type="hidden" name="token" value="{/envelope/token}"/>

                    <!-- Report page filters. -->
                    <input type="hidden" name="overrides" value="{$apply-overrides}"/>
                    <input type="hidden" name="autofp" value="{report/filters/autofp}"/>

                    <!-- Alert filters. -->
                    <input type="hidden" name="esc_first_result" value="{report/results/@start}"/>
                    <input type="hidden" name="esc_max_results" value="{report/results/@max}"/>
                    <input type="hidden" name="esc_levels" value="{$levels}"/>
                    <input type="hidden"
                           name="esc_search_phrase"
                           value="{report/filters/phrase}"/>
                    <input type="hidden"
                           name="esc_apply_min_cvss_base"
                           value="{number (string-length (report/filters/min_cvss_base) &gt; 0)}"/>
                    <input type="hidden"
                           name="esc_min_cvss_base"
                           value="{report/filters/min_cvss_base}"/>
                    <input type="hidden"
                           name="esc_notes"
                           value="{report/filters/notes}"/>
                    <input type="hidden"
                           name="esc_overrides"
                           value="{$apply-overrides}"/>
                    <input type="hidden"
                           name="esc_result_hosts_only"
                           value="{report/filters/result_hosts_only}"/>

                    <select name="alert_id" title="Alert">
                      <xsl:for-each select="../../get_alerts_response/alert">
                        <option value="{@id}"><xsl:value-of select="name"/></option>
                      </xsl:for-each>
                    </select>
                    <input type="image"
                           name="submit"
                           value="Run Alert"
                           title="Run Alert"
                           src="/img/start.png"
                           border="0"
                           style="margin-left:3px;"
                           alt="Run Alert"/>
                  </form>
                </div>
              </td>
            </xsl:otherwise>
          </xsl:choose>
          <xsl:choose>
            <xsl:when test="false">
            </xsl:when>
            <xsl:otherwise>
              <td>
                <div id="small_form" class="float_right">
                  <form action="" method="get">
                    <input type="hidden" name="token" value="{/envelope/token}"/>
                    <input type="hidden" name="cmd" value="get_report"/>
                    <input type="hidden" name="report_id" value="{report/@id}"/>

                    <xsl:choose>
                      <xsl:when test="../../delta">
                        <input type="hidden" name="delta_report_id" value="{report/delta/report/@id}"/>
                        <input type="hidden" name="delta_states" value="{report/filters/delta/text()}"/>
                      </xsl:when>
                      <xsl:when test="@type='prognostic'">
                        <input type="hidden" name="type" value="prognostic"/>
                        <input type="hidden" name="host" value="{report/filters/host}"/>
                        <input type="hidden" name="host_search_phrase" value="{../../host_search_phrase}"/>
                        <input type="hidden" name="host_levels" value="{../../host_levels}"/>
                        <input type="hidden" name="host_first_result" value="{../../results/@start}"/>
                        <input type="hidden" name="host_max_results" value="{../../results/@max}"/>
                      </xsl:when>
                    </xsl:choose>

                    <input type="hidden" name="first_result" value="{report/results/@start}"/>
                    <input type="hidden" name="max_results" value="{report/results/@max}"/>
                    <input type="hidden" name="levels" value="{$levels}"/>
                    <input type="hidden"
                           name="search_phrase"
                           value="{report/filters/phrase}"/>
                    <input type="hidden"
                           name="apply_min_cvss_base"
                           value="{number (string-length (report/filters/min_cvss_base) &gt; 0)}"/>
                    <input type="hidden"
                           name="min_cvss_base"
                           value="{report/filters/min_cvss_base}"/>
                    <input type="hidden"
                           name="sort_field"
                           value="{report/sort/field/text()}"/>
                    <input type="hidden"
                           name="sort_order"
                           value="{report/sort/field/order}"/>
                    <input type="hidden" name="notes" value="{report/filters/notes}"/>
                    <input type="hidden"
                           name="overrides"
                           value="{$apply-overrides}"/>
                    <input type="hidden"
                           name="result_hosts_only"
                           value="{report/filters/result_hosts_only}"/>
                    <input type="hidden" name="autofp"
                           value="{report/filters/autofp}"/>
                    <select name="report_format_id" title="Download Format">
                      <xsl:for-each select="../../get_report_formats_response/report_format[active=1 and (trust/text()='yes' or predefined='1')]">
                        <xsl:choose>
                          <xsl:when test="@type='prognostic' and name='PDF'">
                            <option value="{@id}" selected="1"><xsl:value-of select="name"/></option>
                          </xsl:when>
                          <xsl:when test="@type='../../delta' and name='PDF'">
                            <option value="{@id}" selected="1"><xsl:value-of select="name"/></option>
                          </xsl:when>
                          <xsl:when test="name='PDF'">
                            <option value="{@id}" selected="1"><xsl:value-of select="name"/></option>
                          </xsl:when>
                          <xsl:otherwise>
                            <option value="{@id}"><xsl:value-of select="name"/></option>
                          </xsl:otherwise>
                        </xsl:choose>
                      </xsl:for-each>
                    </select>
                    <input type="image"
                           name="submit"
                           value="Download"
                           title="Download"
                           src="/img/download.png"
                           border="0"
                           style="margin-left:3px;"
                           alt="Download"/>
                  </form>
                </div>
              </td>
            </xsl:otherwise>
          </xsl:choose>
        </tr>
      </table>
    </div>
  </div>
</xsl:template>

<xsl:template match="port">
  <xsl:variable name="class">
    <xsl:choose>
      <xsl:when test="position() mod 2 = 0">even</xsl:when>
      <xsl:otherwise>odd</xsl:otherwise>
    </xsl:choose>
  </xsl:variable>
  <tr class="{$class}">
    <td><xsl:value-of select="text()"/></td>
    <td><xsl:value-of select="threat"/></td>
  </tr>
</xsl:template>

<xsl:template match="get_reports_response/report/report" mode="details">
  <xsl:variable name="prognostic">
    <xsl:if test="@type='prognostic'">1</xsl:if>
  </xsl:variable>
  <xsl:variable name="delta">
    <xsl:choose>
      <xsl:when test="@type='delta'">1</xsl:when>
      <xsl:otherwise>0</xsl:otherwise>
    </xsl:choose>
  </xsl:variable>
  <xsl:for-each select="host" >
    <xsl:variable name="current_host" select="ip"/>
    <xsl:choose>
      <xsl:when test="$prognostic=1">
      </xsl:when>
      <xsl:otherwise>
        <a name="{$current_host}"></a>
<!--
        <h2>
          All host details
        </h2>
        <table class="gbntable" cellspacing="2" cellpadding="4">
          <tr class="gbntablehead2">
            <td>Name</td>
            <td>Value</td>
            <td>Source Type</td>
            <td>Source Name</td>
            <td>Source Description</td>
          </tr>
          <xsl:for-each select="../host[ip = $current_host]/detail">
            <tr>
              <td><xsl:value-of select="name"/></td>
              <td><xsl:value-of select="value"/></td>
              <td><xsl:value-of select="source/type"/></td>
              <td><xsl:value-of select="source/name"/></td>
              <td><xsl:value-of select="source/description"/></td>
            </tr>
          </xsl:for-each>
        </table>
-->
        <xsl:if test="$delta = 0">
          <h2>
            CVEs closed by vendor security updates for <xsl:value-of select="$current_host"/>
          </h2>
          <table class="gbntable" cellspacing="2" cellpadding="4">
            <tr class="gbntablehead2">
              <td>CVE</td>
              <td>NVT</td>
            </tr>
            <xsl:variable name="host" select="."/>
            <xsl:variable name="token" select="/envelope/token"/>
            <xsl:for-each select="str:split(detail[name = 'Closed CVEs']/value, ',')">
              <tr>
                <td>
                  <xsl:call-template name="get_info_cve_lnk">
                    <xsl:with-param name="cve" select="."/>
                    <xsl:with-param name="gsa_token" select="$token"/>
                  </xsl:call-template>
                </td>
                <td>
                  <xsl:variable name="cve" select="normalize-space(.)"/>
                  <xsl:variable name="closed_cve"
                                select="$host/detail[name = 'Closed CVE' and contains(value, $cve)]"/>
                  <a href="omp?cmd=get_nvts&amp;oid={$closed_cve/source/name}&amp;token={$token}">
                    <xsl:value-of select="$closed_cve/source/description"/>
                  </a>
                </td>
              </tr>
            </xsl:for-each>
          </table>
        </xsl:if>
      </xsl:otherwise>
    </xsl:choose>
    <a name="{$current_host}"/>
    <xsl:variable name="on">
      <xsl:choose>
        <xsl:when test="$prognostic=1">0</xsl:when>
        <xsl:otherwise>1</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:for-each select="../results/result[host/text() = $current_host]">
      <xsl:call-template name="result-detailed">
        <xsl:with-param name="prognostic" select="$prognostic"/>
        <xsl:with-param name="details-button" select="$on"/>
        <xsl:with-param name="note-buttons" select="$on"/>
        <xsl:with-param name="override-buttons" select="$on"/>
        <xsl:with-param name="show-overrides" select="$on"/>
      </xsl:call-template>
    </xsl:for-each>
  </xsl:for-each>
</xsl:template>

<!-- END REPORT DETAILS -->

<!-- BEGIN SYSTEM REPORTS MANAGEMENT -->

<xsl:template match="system_report">
  <tr>
    <td>
      <h1><xsl:value-of select="title"/></h1>
    </td>
  </tr>
  <tr>
    <td>
      <xsl:choose>
        <xsl:when test="report/@format = 'txt'">
          <pre style="margin-left: 5%"><xsl:value-of select="report/text()"/></pre>
        </xsl:when>
        <xsl:otherwise>
          <img src="/system_report/{name}/report.{report/@format}?duration={../../duration}&amp;slave_id={../../slave/@id}&amp;token={/envelope/token}"/>
        </xsl:otherwise>
      </xsl:choose>
    </td>
  </tr>
</xsl:template>

<xsl:template match="get_system_reports_response">
  <xsl:variable name="duration" select="../duration"/>
  <div class="gb_window">
    <div class="gb_window_part_left"></div>
    <div class="gb_window_part_right"></div>
    <div class="gb_window_part_center">Performance
      <a href="/help/performance.html?token={/envelope/token}"
         title="Help: Performance">
        <img src="/img/help.png"/>
      </a>
    </div>
    <div class="gb_window_part_content_no_pad">
      <table>
        <tr>
          <td>
            Reports span the last:
          </td>
          <td>
            <xsl:choose>
              <xsl:when test="$duration='3600'">
                hour
              </xsl:when>
              <xsl:otherwise>
                <a href="/omp?cmd=get_system_reports&amp;duration={3600}&amp;slave_id={../slave/@id}&amp;token={/envelope/token}">hour</a>
              </xsl:otherwise>
            </xsl:choose>
            |
            <xsl:choose>
              <xsl:when test="$duration='86400'">
                day
              </xsl:when>
              <xsl:otherwise>
                <a href="/omp?cmd=get_system_reports&amp;duration={86400}&amp;slave_id={../slave/@id}&amp;token={/envelope/token}">day</a>
              </xsl:otherwise>
            </xsl:choose>
            |
            <xsl:choose>
              <xsl:when test="$duration='604800'">
                week
              </xsl:when>
              <xsl:otherwise>
                <a href="/omp?cmd=get_system_reports&amp;duration={604800}&amp;slave_id={../slave/@id}&amp;token={/envelope/token}">week</a>
              </xsl:otherwise>
            </xsl:choose>
            |
            <xsl:choose>
              <xsl:when test="$duration='2592000'">
                month
              </xsl:when>
              <xsl:otherwise>
                <a href="/omp?cmd=get_system_reports&amp;duration={2592000}&amp;slave_id={../slave/@id}&amp;token={/envelope/token}">month</a>
              </xsl:otherwise>
            </xsl:choose>
            |
            <xsl:choose>
              <xsl:when test="$duration='31536000'">
                year
              </xsl:when>
              <xsl:otherwise>
                <a href="/omp?cmd=get_system_reports&amp;duration={31536000}&amp;slave_id={../slave/@id}&amp;token={/envelope/token}">year</a>
              </xsl:otherwise>
            </xsl:choose>
          </td>
        </tr>
        <tr>
          <td>
            Reports for slave:
          </td>
          <td>
            <div id="small_form" style="float:left;">
              <form action="" method="get">
                <input type="hidden" name="token" value="{/envelope/token}"/>
                <input type="hidden" name="cmd" value="get_system_reports"/>
                <input type="hidden" name="duration" value="{$duration}"/>
                <select name="slave_id">
                  <xsl:variable name="slave_id">
                    <xsl:value-of select="../slave/@id"/>
                  </xsl:variable>
                  <xsl:choose>
                    <xsl:when test="string-length ($slave_id) &gt; 0">
                      <option value="0">--</option>
                    </xsl:when>
                    <xsl:otherwise>
                      <option value="0" selected="1">--</option>
                    </xsl:otherwise>
                  </xsl:choose>
                  <xsl:for-each select="../get_slaves_response/slave">
                    <xsl:choose>
                      <xsl:when test="@id = $slave_id">
                        <option value="{@id}" selected="1"><xsl:value-of select="name"/></option>
                      </xsl:when>
                      <xsl:otherwise>
                        <option value="{@id}"><xsl:value-of select="name"/></option>
                      </xsl:otherwise>
                    </xsl:choose>
                  </xsl:for-each>
                </select>
                <input type="image"
                       name="Update"
                       src="/img/refresh.png"
                       alt="Update" style="margin-left:3px;margin-right:3px;"/>
              </form>
            </div>
          </td>
        </tr>
      </table>
      <xsl:choose>
        <xsl:when test="@status = '500'">
          <p>
            The selected Scan Slave can currently not be reached for retrieval
            of performance data.
          </p>
          <p>
            Please check network connection or Slave configuration.  The
            problem may also be temporary, so you could try again at a
            later time.
          </p>
        </xsl:when>
        <xsl:otherwise>
          <table>
            <xsl:apply-templates select="system_report"/>
          </table>
        </xsl:otherwise>
      </xsl:choose>
    </div>
  </div>
</xsl:template>

<!--     GET_SYSTEM_REPORTS -->

<xsl:template match="get_system_reports">
  <xsl:apply-templates select="gsad_msg"/>
  <xsl:choose>
    <xsl:when test="not (slave/@id) and get_system_reports_response/@status = '500'">
      <xsl:call-template name="command_result_dialog">
        <xsl:with-param name="operation">
          Get System Reports
        </xsl:with-param>
        <xsl:with-param name="status">
          <xsl:value-of select="500"/>
        </xsl:with-param>
        <xsl:with-param name="msg">
          <xsl:value-of select="get_system_reports_response/@status_text"/>
        </xsl:with-param>
        <xsl:with-param name="details">
          There was an error getting the performance results.  Please ensure that
          there is a system reporting program installed with the Manager, and that
          this program is configured correctly.
        </xsl:with-param>
      </xsl:call-template>
    </xsl:when>
    <xsl:otherwise>
      <xsl:apply-templates select="get_system_reports_response"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<!-- END SYSTEM REPORTS MANAGEMENT -->

<!-- BEGIN TRASH MANAGEMENT -->

<xsl:template match="empty_trashcan_response">
  <xsl:call-template name="command_result_dialog">
    <xsl:with-param name="operation">
      Empty Trashcan
    </xsl:with-param>
    <xsl:with-param name="status">
      <xsl:value-of select="@status"/>
    </xsl:with-param>
    <xsl:with-param name="msg">
      <xsl:value-of select="@status_text"/>
    </xsl:with-param>
  </xsl:call-template>
</xsl:template>

<xsl:template match="restore_response">
  <xsl:call-template name="command_result_dialog">
    <xsl:with-param name="operation">
      Restore
    </xsl:with-param>
    <xsl:with-param name="status">
      <xsl:value-of select="@status"/>
    </xsl:with-param>
    <xsl:with-param name="msg">
      <xsl:value-of select="@status_text"/>
    </xsl:with-param>
  </xsl:call-template>
</xsl:template>

<xsl:template name="html-agents-trash-table">
  <div id="tasks">
    <table class="gbntable" cellspacing="2" cellpadding="4" border="0">
      <tr class="gbntablehead2">
        <td>Name</td>
        <td>Trust</td>
        <td width="100">Actions</td>
      </tr>
      <xsl:apply-templates select="agent" mode="trash"/>
    </table>
  </div>
</xsl:template>

<xsl:template name="html-configs-trash-table">
  <div id="tasks">
    <table class="gbntable" cellspacing="2" cellpadding="4" border="0">
      <tr class="gbntablehead2">
        <td rowspan="2">Name</td>
        <td colspan="2">Families</td>
        <td colspan="2">NVTs</td>
        <td width="100" rowspan="2">Actions</td>
      </tr>
      <tr class="gbntablehead2">
        <td width="1" style="font-size:10px;">Total</td>
        <td width="1" style="font-size:10px;">Trend</td>
        <td width="1" style="font-size:10px;">Total</td>
        <td width="1" style="font-size:10px;">Trend</td>
      </tr>
      <xsl:apply-templates select="config" mode="trash"/>
    </table>
  </div>
</xsl:template>

<xsl:template name="html-alerts-trash-table">
  <div id="tasks">
    <table class="gbntable" cellspacing="2" cellpadding="4" border="0">
      <tr class="gbntablehead2">
        <td>Name</td>
        <td>Event</td>
        <td>Condition</td>
        <td>Method</td>
        <td>Filter</td>
        <td width="100">Actions</td>
      </tr>
      <xsl:apply-templates select="alert" mode="trash"/>
    </table>
  </div>
</xsl:template>

<xsl:template name="html-lsc-credentials-trash-table">
  <div id="tasks">
    <table class="gbntable" cellspacing="2" cellpadding="4" border="0">
      <tr class="gbntablehead2">
        <td>Name</td>
        <td>Login</td>
        <td>Comment</td>
        <td width="135">Actions</td>
      </tr>
      <xsl:apply-templates select="lsc_credential" mode="trash"/>
    </table>
  </div>
</xsl:template>

<xsl:template name="html-port-lists-trash-table">
  <div id="tasks">
    <table class="gbntable" cellspacing="2" cellpadding="4" border="0">
      <tr class="gbntablehead2">
        <td>Name</td>
        <td width="100">Actions</td>
      </tr>
      <xsl:apply-templates select="port_list" mode="trash"/>
    </table>
  </div>
</xsl:template>

<xsl:template name="html-report-formats-trash-table">
  <div id="tasks">
    <table class="gbntable" cellspacing="2" cellpadding="4" border="0">
      <tr class="gbntablehead2">
        <td>Name</td>
        <td>Extension</td>
        <td>Content Type</td>
        <td>Trust (last verified)</td>
        <td>Active</td>
        <td width="100">Actions</td>
      </tr>
      <xsl:apply-templates select="report_format" mode="trash"/>
    </table>
  </div>
</xsl:template>

<xsl:template name="html-schedules-trash-table">
  <div id="tasks">
    <table class="gbntable" cellspacing="2" cellpadding="4" border="0">
      <tr class="gbntablehead2">
        <td>Name</td>
        <td>First Run</td>
        <td>Next Run</td>
        <td>Period</td>
        <td>Duration</td>
        <td width="100">Actions</td>
      </tr>
      <xsl:apply-templates select="schedule" mode="trash"/>
    </table>
  </div>
</xsl:template>

<xsl:template name="html-slaves-trash-table">
  <div id="tasks">
    <table class="gbntable" cellspacing="2" cellpadding="4" border="0">
      <tr class="gbntablehead2">
        <td>Name</td>
        <td>Host</td>
        <td>Port</td>
        <td>Login</td>
        <td width="100">Actions</td>
      </tr>
      <xsl:apply-templates select="slave" mode="trash"/>
    </table>
  </div>
</xsl:template>

<xsl:template name="html-tags-trash-table">
  <div id="tasks">
    <table class="gbntable" cellspacing="2" cellpadding="4" border="0">
      <tr class="gbntablehead2">
        <td>Name</td>
        <td>Value</td>
        <td>Attach type</td>
        <td>Attach ID</td>
        <td width="100">Actions</td>
      </tr>
      <xsl:apply-templates select="tag" mode="trash"/>
    </table>
  </div>
</xsl:template>

<xsl:template name="html-targets-trash-table">
  <div id="tasks">
    <table class="gbntable" cellspacing="2" cellpadding="4" border="0">
      <tr class="gbntablehead2">
        <td>Name</td>
        <td>Hosts</td>
        <td>IPs</td>
        <td>Port List</td>
        <td>SSH Credential</td>
        <td>SMB Credential</td>
        <td width="100">Actions</td>
      </tr>
      <xsl:apply-templates select="target" mode="trash"/>
    </table>
  </div>
</xsl:template>

<xsl:template name="html-tasks-trash-table">
  <div id="tasks">
    <table class="gbntable" cellspacing="2" cellpadding="4" border="0">
      <tr class="gbntablehead2">
        <td rowspan="2">Task</td>
        <td width="1" rowspan="2">Status</td>
        <td colspan="3">Reports</td>
        <td rowspan="2">Threat</td>
        <td rowspan="2">Trend</td>
        <td width="115" rowspan="2">Actions</td>
      </tr>
      <tr class="gbntablehead2">
        <td width="1" style="font-size:10px;">Total</td>
        <td  style="font-size:10px;">First</td>
        <td  style="font-size:10px;">Last</td>
      </tr>
      <xsl:apply-templates select="task" mode="trash"/>
    </table>
  </div>
</xsl:template>

<xsl:template match="get_trash">
  <xsl:apply-templates select="gsad_msg"/>
  <xsl:apply-templates select="delete_agent_response"/>
  <xsl:apply-templates select="delete_config_response"/>
  <xsl:apply-templates select="delete_alert_response"/>
  <xsl:apply-templates select="delete_filter_response"/>
  <xsl:apply-templates select="delete_lsc_credential_response"/>
  <xsl:apply-templates select="delete_note_response"/>
  <xsl:apply-templates select="delete_override_response"/>
  <xsl:apply-templates select="delete_permission_response"/>
  <xsl:apply-templates select="delete_port_list_response"/>
  <xsl:apply-templates select="delete_report_format_response"/>
  <xsl:apply-templates select="delete_schedule_response"/>
  <xsl:apply-templates select="delete_slave_response"/>
  <xsl:apply-templates select="delete_tag_response"/>
  <xsl:apply-templates select="delete_target_response"/>
  <xsl:apply-templates select="delete_task_response"/>
  <xsl:apply-templates select="empty_trashcan_response"/>
  <xsl:apply-templates select="restore_response"/>
  <div class="gb_window">
    <div class="gb_window_part_left"></div>
    <div class="gb_window_part_right"></div>
    <div class="gb_window_part_center">Trashcan
      <a href="/help/trashcan.html?token={/envelope/token}"
         title="Help: Trashcan">
        <img src="/img/help.png"/>
      </a>
    </div>
    <div class="gb_window_part_content">
      <div style="text-align:right">
        <form action="" method="post" enctype="multipart/form-data">
          <input type="hidden" name="token" value="{/envelope/token}"/>
          <input type="hidden" name="cmd" value="empty_trashcan"/>
          <input type="hidden" name="caller" value="{/envelope/caller}"/>
          <input type="submit"
                 name="submit"
                 value="Empty Trashcan"
                 title="Empty Trashcan"/>
        </form>
      </div>

      <h1>Contents</h1>
      <table class="gbntable" cellspacing="2" cellpadding="4" border="0">
        <tr class="gbntablehead2">
          <td>Type</td>
          <td>Items</td>
        </tr>
        <xsl:if test="/envelope/capabilities/help_response/schema/command[name='GET_AGENTS']">
          <tr class="even">
            <td><a href="#agents">Agents</a></td>
            <td><xsl:value-of select="count(get_agents_response/agent)"/></td>
          </tr>
        </xsl:if>
        <xsl:if test="/envelope/capabilities/help_response/schema/command[name='GET_ALERTS']">
          <tr class="odd">
            <td><a href="#alerts">Alerts</a></td>
            <td><xsl:value-of select="count(get_alerts_response/alert)"/></td>
          </tr>
        </xsl:if>
        <xsl:if test="/envelope/capabilities/help_response/schema/command[name='GET_CONFIGS']">
          <tr class="even">
            <td><a href="#configs">Scan Configs</a></td>
            <td><xsl:value-of select="count(get_configs_response/config)"/></td>
          </tr>
        </xsl:if>
        <xsl:if test="/envelope/capabilities/help_response/schema/command[name='GET_LSC_CREDENTIALS']">
          <tr class="odd">
            <td><a href="#credentials">Credentials</a></td>
            <td><xsl:value-of select="count(get_lsc_credentials_response/lsc_credential)"/></td>
          </tr>
        </xsl:if>
        <xsl:if test="/envelope/capabilities/help_response/schema/command[name='GET_FILTERS']">
          <tr class="even">
            <td><a href="#filters">Filters</a></td>
            <td><xsl:value-of select="count(get_filters_response/filter)"/></td>
          </tr>
        </xsl:if>
        <xsl:if test="/envelope/capabilities/help_response/schema/command[name='GET_NOTES']">
          <tr class="odd">
            <td><a href="#notes">Notes</a></td>
            <td><xsl:value-of select="count(get_notes_response/note)"/></td>
          </tr>
        </xsl:if>
        <xsl:if test="/envelope/capabilities/help_response/schema/command[name='GET_OVERRIDES']">
          <tr class="even">
            <td><a href="#overrides">Overides</a></td>
            <td><xsl:value-of select="count(get_overrides_response/override)"/></td>
          </tr>
        </xsl:if>
        <xsl:if test="/envelope/capabilities/help_response/schema/command[name='GET_PERMISSIONS']">
          <tr class="odd">
            <td><a href="#permissions">Permissions</a></td>
            <td><xsl:value-of select="count(get_permissions_response/permission)"/></td>
          </tr>
        </xsl:if>
        <xsl:if test="/envelope/capabilities/help_response/schema/command[name='GET_PORT_LISTS']">
          <tr class="even">
            <td><a href="#port_lists">Port Lists</a></td>
            <td><xsl:value-of select="count(get_port_lists_response/port_list)"/></td>
          </tr>
        </xsl:if>
        <xsl:if test="/envelope/capabilities/help_response/schema/command[name='GET_REPORT_FORMATS']">
          <tr class="odd">
            <td><a href="#report_formats">Report Formats</a></td>
            <td><xsl:value-of select="count(get_report_formats_response/report_format)"/></td>
          </tr>
        </xsl:if>
        <xsl:if test="/envelope/capabilities/help_response/schema/command[name='GET_SCHEDULES']">
          <tr class="even">
            <td><a href="#schedules">Schedules</a></td>
            <td><xsl:value-of select="count(get_schedules_response/schedule)"/></td>
          </tr>
        </xsl:if>
        <xsl:if test="/envelope/capabilities/help_response/schema/command[name='GET_SLAVES']">
          <tr class="odd">
            <td><a href="#slaves">Slaves</a></td>
            <td><xsl:value-of select="count(get_slaves_response/slave)"/></td>
          </tr>
        </xsl:if>
        <xsl:if test="/envelope/capabilities/help_response/schema/command[name='GET_TAGS']">
          <tr class="even">
            <td><a href="#targets">Tags</a></td>
            <td><xsl:value-of select="count(get_tags_response/tag)"/></td>
          </tr>
        </xsl:if>
        <xsl:if test="/envelope/capabilities/help_response/schema/command[name='GET_TARGETS']">
          <tr class="odd">
            <td><a href="#tags">Targets</a></td>
            <td><xsl:value-of select="count(get_targets_response/target)"/></td>
          </tr>
        </xsl:if>
        <xsl:if test="/envelope/capabilities/help_response/schema/command[name='GET_TASKS']">
          <tr class="even">
            <td><a href="#the_tasks">Tasks</a></td>
            <td><xsl:value-of select="count(get_tasks_response/task)"/></td>
          </tr>
        </xsl:if>
      </table>

      <xsl:if test="/envelope/capabilities/help_response/schema/command[name='GET_AGENTS']">
        <a name="agents"></a>
        <h1>Agents</h1>
        <!-- The for-each makes the get_agents_response the current node. -->
        <xsl:for-each select="get_agents_response">
          <xsl:call-template name="html-agents-trash-table"/>
        </xsl:for-each>
      </xsl:if>

      <xsl:if test="/envelope/capabilities/help_response/schema/command[name='GET_ALERTS']">
        <a name="alerts"></a>
        <h1>Alerts</h1>
        <!-- The for-each makes the get_alerts_response the current node. -->
        <xsl:for-each select="get_alerts_response">
          <xsl:call-template name="html-alerts-trash-table"/>
        </xsl:for-each>
      </xsl:if>

      <xsl:if test="/envelope/capabilities/help_response/schema/command[name='GET_CONFIGS']">
        <a name="configs"></a>
        <h1>Scan Configs</h1>
        <!-- The for-each makes the get_configs_response the current node. -->
        <xsl:for-each select="get_configs_response">
          <xsl:call-template name="html-configs-trash-table"/>
        </xsl:for-each>
      </xsl:if>

      <xsl:if test="/envelope/capabilities/help_response/schema/command[name='GET_FILTERS']">
        <a name="filters"></a>
        <h1>Filters</h1>
        <!-- The for-each makes the get_filters_response the current node. -->
        <xsl:for-each select="get_filters_response">
          <xsl:call-template name="html-filters-trash-table"/>
        </xsl:for-each>
      </xsl:if>

      <xsl:if test="/envelope/capabilities/help_response/schema/command[name='GET_LSC_CREDENTIALS']">
        <a name="credentials"></a>
        <h1>Credentials</h1>
        <!-- The for-each makes the get_lsc_credentials_response the current node. -->
        <xsl:for-each select="get_lsc_credentials_response">
          <xsl:call-template name="html-lsc-credentials-trash-table"/>
        </xsl:for-each>
      </xsl:if>

      <xsl:if test="/envelope/capabilities/help_response/schema/command[name='GET_NOTES']">
        <a name="notes"></a>
        <h1>Notes</h1>
        <!-- The for-each makes the get_notes_response the current node. -->
        <xsl:for-each select="get_notes_response">
          <xsl:call-template name="html-notes-trash-table"/>
        </xsl:for-each>
      </xsl:if>

      <xsl:if test="/envelope/capabilities/help_response/schema/command[name='GET_OVERRIDES']">
        <a name="overrides"></a>
        <h1>Overrides</h1>
        <!-- The for-each makes the get_overrides_response the current node. -->
        <xsl:for-each select="get_overrides_response">
          <xsl:call-template name="html-overrides-trash-table"/>
        </xsl:for-each>
      </xsl:if>

      <xsl:if test="/envelope/capabilities/help_response/schema/command[name='GET_PERMISSIONS']">
        <a name="permissions"></a>
        <h1>Permissions</h1>
        <!-- The for-each makes the get_permissions_response the current node. -->
        <xsl:for-each select="get_permissions_response">
          <xsl:call-template name="html-permissions-trash-table"/>
        </xsl:for-each>
      </xsl:if>

      <xsl:if test="/envelope/capabilities/help_response/schema/command[name='GET_PORT_LISTS']">
        <a name="port_lists"></a>
        <h1>Port Lists</h1>
        <!-- The for-each makes the get_port_lists_response the current node. -->
        <xsl:for-each select="get_port_lists_response">
          <xsl:call-template name="html-port-lists-trash-table"/>
        </xsl:for-each>
      </xsl:if>

      <xsl:if test="/envelope/capabilities/help_response/schema/command[name='GET_REPORT_FORMATS']">
        <a name="report_formats"></a>
        <h1>Report Formats</h1>
        <!-- The for-each makes the get_report_formats_response the current node. -->
        <xsl:for-each select="get_report_formats_response">
          <xsl:call-template name="html-report-formats-trash-table"/>
        </xsl:for-each>
      </xsl:if>

      <xsl:if test="/envelope/capabilities/help_response/schema/command[name='GET_SCHEDULES']">
        <a name="schedules"></a>
        <h1>Schedules</h1>
        <!-- The for-each makes the get_schedules_response the current node. -->
        <xsl:for-each select="get_schedules_response">
          <xsl:call-template name="html-schedules-trash-table"/>
        </xsl:for-each>
      </xsl:if>

      <xsl:if test="/envelope/capabilities/help_response/schema/command[name='GET_SLAVES']">
        <a name="slaves"></a>
        <h1>Slaves</h1>
        <!-- The for-each makes the get_slaves_response the current node. -->
        <xsl:for-each select="get_slaves_response">
          <xsl:call-template name="html-slaves-trash-table"/>
        </xsl:for-each>
      </xsl:if>

      <xsl:if test="/envelope/capabilities/help_response/schema/command[name='GET_TAGS']">
        <a name="tags"></a>
        <h1>Tags</h1>
        <!-- The for-each makes the get_tags_response the current node. -->
        <xsl:for-each select="get_tags_response">
          <xsl:call-template name="html-tags-trash-table"/>
        </xsl:for-each>
      </xsl:if>

      <xsl:if test="/envelope/capabilities/help_response/schema/command[name='GET_TARGETS']">
        <a name="targets"></a>
        <h1>Targets</h1>
        <!-- The for-each makes the get_targets_response the current node. -->
        <xsl:for-each select="get_targets_response">
          <xsl:call-template name="html-targets-trash-table"/>
        </xsl:for-each>
      </xsl:if>

      <xsl:if test="/envelope/capabilities/help_response/schema/command[name='GET_TASKS']">
        <a name="the_tasks"></a>
        <h1>Tasks</h1>
        <!-- The for-each makes the get_tasks_response the current node. -->
        <xsl:for-each select="get_tasks_response">
          <xsl:call-template name="html-tasks-trash-table"/>
        </xsl:for-each>
      </xsl:if>
    </div>
  </div>
</xsl:template>

<!-- END TRASH MANAGEMENT -->

<!-- BEGIN USERS MANAGEMENT -->

<xsl:template match="group" mode="newuser">
  <option value="{@id}"><xsl:value-of select="name"/></option>
</xsl:template>

<xsl:template name="new-user-group-select">
  <xsl:param name="position" select="1"/>
  <xsl:param name="count" select="0"/>
  <xsl:param name="groups" select="get_groups_response"/>
  <select name="group_id_optional:{$position}">
    <option value="--">--</option>
    <xsl:apply-templates select="$groups/group"
                         mode="newuser"/>
  </select>
  <xsl:if test="$count &gt; 1">
    <br/>
    <xsl:call-template name="new-user-group-select">
      <xsl:with-param name="groups" select="$groups"/>
      <xsl:with-param name="count" select="$count - 1"/>
      <xsl:with-param name="position" select="$position + 1"/>
    </xsl:call-template>
  </xsl:if>
</xsl:template>

<xsl:template name="html-create-user-form">
  <div class="gb_window">
    <div class="gb_window_part_left"></div>
    <div class="gb_window_part_right"></div>
    <div class="gb_window_part_center">New User
      <a href="/help/users.html?token={/envelope/token}#newuser"
         title="Help: Users (New User)">
        <img src="/img/help.png"/>
      </a>
      <a href="/omp?cmd=get_users&amp;filter={str:encode-uri (/envelope/params/filter, true ())}&amp;filt_id={/envelope/params/filt_id}&amp;token={/envelope/token}"
         title="Users" style="margin-left:3px;">
        <img src="/img/list.png" border="0" alt="Users"/>
      </a>
    </div>
    <div class="gb_window_part_content">
      <form action="/omp" method="post" enctype="multipart/form-data">
        <input type="hidden" name="token" value="{/envelope/token}"/>
        <input type="hidden" name="cmd" value="create_user"/>
        <input type="hidden" name="caller" value="{/envelope/caller}"/>
        <table border="0" cellspacing="0" cellpadding="3" width="100%">
          <tr class="odd">
            <td valign="top" width="125">Login Name</td>
            <td>
              <input type="text" name="login" value="{gsa:param-or ('login', 'unnamed')}"
                     size="30" maxlength="80"/>
            </td>
          </tr>
          <tr class="even">
            <td valign="top" width="125">Password</td>
            <td>
              <input type="password" name="password" value="" size="30"
                     maxlength="40"/>
            </td>
          </tr>
          <tr class="odd">
            <td valign="top">Role</td>
            <td>
              <select name="role">
                <xsl:choose>
                  <xsl:when test="/envelope/params/role = 'Admin'">
                    <option value="Admin" selected="1">Admin</option>
                  </xsl:when>
                  <xsl:otherwise>
                    <option value="Admin">Admin</option>
                  </xsl:otherwise>
                </xsl:choose>
                <xsl:choose>
                  <xsl:when test="not (boolean (/envelope/params/role)) or (/envelope/params/role = 'User')">
                    <option value="User" selected="1">User</option>
                  </xsl:when>
                  <xsl:otherwise>
                    <option value="User">User</option>
                  </xsl:otherwise>
                </xsl:choose>
                <xsl:choose>
                  <xsl:when test="/envelope/params/role = 'Observer'">
                    <option value="Observer" selected="1">Observer</option>
                  </xsl:when>
                  <xsl:otherwise>
                    <option value="Observer">Observer</option>
                  </xsl:otherwise>
                </xsl:choose>
              </select>
            </td>
          </tr>
          <tr class="even">
            <td>Groups (optional)</td>
            <td>
              <xsl:variable name="groups"
                            select="get_groups_response/group"/>
              <xsl:for-each select="/envelope/params/_param[substring-before (name, ':') = 'group_id_optional'][value != '--']">
                <select name="{name}">
                  <xsl:variable name="group_id" select="value"/>
                  <xsl:choose>
                    <xsl:when test="string-length ($group_id) &gt; 0">
                      <option value="0">--</option>
                    </xsl:when>
                    <xsl:otherwise>
                      <option value="0" selected="1">--</option>
                    </xsl:otherwise>
                  </xsl:choose>
                  <xsl:for-each select="$groups">
                    <xsl:choose>
                      <xsl:when test="@id = $group_id">
                        <option value="{@id}" selected="1"><xsl:value-of select="name"/></option>
                      </xsl:when>
                      <xsl:otherwise>
                        <option value="{@id}"><xsl:value-of select="name"/></option>
                      </xsl:otherwise>
                    </xsl:choose>
                  </xsl:for-each>
                </select>
                <br/>
              </xsl:for-each>
              <xsl:variable name="count"
                            select="count (/envelope/params/_param[substring-before (name, ':') = 'group_id_optional'][value != '--'])"/>
              <xsl:call-template name="new-user-group-select">
                <xsl:with-param name="groups" select="get_groups_response"/>
                <xsl:with-param name="count" select="/envelope/params/groups - $count"/>
                <xsl:with-param name="position" select="$count + 1"/>
              </xsl:call-template>

              <xsl:choose>
                <xsl:when test="string-length (/envelope/params/groups)">
                  <input type="hidden" name="groups" value="{/envelope/params/groups}"/>
                </xsl:when>
                <xsl:otherwise>
                  <input type="hidden" name="groups" value="{1}"/>
                </xsl:otherwise>
              </xsl:choose>
              <!-- Force the Create Task button to be the default. -->
              <input style="position: absolute; left: -100%"
                     type="submit" name="submit" value="Create User"/>
              <input type="submit" name="submit_plus_group" value="+"/>
            </td>
          </tr>
          <tr class="odd">
            <td valign="top">Host Access</td>
            <td>
              <label>
                <xsl:choose>
                  <xsl:when test="not (boolean (/envelope/params/hosts_allow)) or (/envelope/params/hosts_allow = '2')">
                    <input type="radio" name="hosts_allow" value="2" checked="1"/>
                  </xsl:when>
                  <xsl:otherwise>
                    <input type="radio" name="hosts_allow" value="2"/>
                  </xsl:otherwise>
                </xsl:choose>
                Allow All
              </label>
              <br/>
              <label>
                <xsl:choose>
                  <xsl:when test="/envelope/params/hosts_allow = '1'">
                    <input type="radio" name="hosts_allow" value="1" checked="1"/>
                  </xsl:when>
                  <xsl:otherwise>
                    <input type="radio" name="hosts_allow" value="1"/>
                  </xsl:otherwise>
                </xsl:choose>
                Allow:
              </label>
              <label>
                <xsl:choose>
                  <xsl:when test="/envelope/params/hosts_allow = '0'">
                    <input type="radio" name="hosts_allow" value="0" checked="1"/>
                  </xsl:when>
                  <xsl:otherwise>
                    <input type="radio" name="hosts_allow" value="0"/>
                  </xsl:otherwise>
                </xsl:choose>
                Deny:
              </label>
              <br/>
              <input type="text" name="access_hosts" value="{gsa:param-or ('access_hosts', '')}"
                     size="30" maxlength="500"/>
            </td>
          </tr>
          <!-- Only if ldap-connect is enabled, it is per-user. !-->
          <xsl:if test="//group[@name='method:ldap_connect']/auth_conf_setting[@key='enable']/@value = 'true'">
            <tr class="even">
              <td valign="top">Allow LDAP- Authentication only</td>
              <td>
                <input type="checkbox" name="enable_ldap_connect" value="1" checked="1"/>
              </td>
            </tr>
          </xsl:if>
          <tr>
            <td colspan="2" style="text-align:right;">
              <input type="submit" name="submit" value="Create User"/>
            </td>
          </tr>
        </table>
      </form>
    </div>
  </div>
</xsl:template>

<xsl:template name="html-users-table">
  <div class="gb_window">
    <div class="gb_window_part_left"></div>
    <div class="gb_window_part_right"></div>
    <div class="gb_window_part_center">Users
      <a href="/help/users.html?token={/envelope/token}#users"
         title="Help: Users (Users)">
        <img src="/img/help.png"/>
      </a>
      <a href="/omp?cmd=new_user&amp;filter={str:encode-uri (/envelope/params/filter, true ())}&amp;filt_id={/envelope/params/filt_id}&amp;token={/envelope/token}"
         title="New User">
        <img src="/img/new.png" border="0" style="margin-left:3px;"/>
      </a>
      <div id="small_inline_form" style="display: inline; margin-left: 15px; font-weight: normal;">
        <a href="/omp?cmd=export_users&amp;filter={str:encode-uri (filters/term, true ())}&amp;token={/envelope/token}"
           title="Export all Users as XML"
           style="margin-left:3px;">
          <img src="/img/download.png" border="0" alt="Export XML"/>
        </a>
      </div>
    </div>
    <div class="gb_window_part_content_no_pad">
      <div id="tasks">
        <table class="gbntable" cellspacing="2" cellpadding="4" border="0">
          <tr class="gbntablehead2">
            <td>Name</td>
            <td>Role</td>
            <td>Groups</td>
            <td>Host Access</td>
            <xsl:if test="//group[@name='method:ldap_connect']/auth_conf_setting[@key='enable']/@value = 'true'">
              <td>LDAP Authentication</td>
            </xsl:if>
            <td width="100">Actions</td>
          </tr>
          <xsl:apply-templates select="user">
            <xsl:sort select="role"/>
            <xsl:sort select="name"/>
          </xsl:apply-templates>
        </table>
      </div>
    </div>
  </div>
</xsl:template>

<!--     CREATE_USER_RESPONSE -->

<xsl:template match="create_user_response">
  <xsl:call-template name="command_result_dialog">
    <xsl:with-param name="operation">Create User</xsl:with-param>
    <xsl:with-param name="status">
      <xsl:value-of select="@status"/>
    </xsl:with-param>
    <xsl:with-param name="msg">
      <xsl:value-of select="@status_text"/>
    </xsl:with-param>
  </xsl:call-template>
</xsl:template>

<xsl:template match="new_user">
  <xsl:apply-templates select="gsad_msg"/>
  <xsl:apply-templates select="commands_response/delete_user_response"/>
  <xsl:apply-templates select="create_user_response"/>
  <xsl:call-template name="html-create-user-form"/>
</xsl:template>

<!--     DELETE_USER_RESPONSE -->

<xsl:template match="delete_user_response">
  <xsl:call-template name="command_result_dialog">
    <xsl:with-param name="operation">Delete User</xsl:with-param>
    <xsl:with-param name="status">
      <xsl:value-of select="@status"/>
    </xsl:with-param>
    <xsl:with-param name="msg">
      <xsl:value-of select="@status_text"/>
    </xsl:with-param>
  </xsl:call-template>
</xsl:template>

<!--     MODIFY_USER_RESPONSE -->

<xsl:template match="modify_user_response">
  <xsl:call-template name="command_result_dialog">
    <xsl:with-param name="operation">Save User</xsl:with-param>
    <xsl:with-param name="status">
      <xsl:value-of select="@status"/>
    </xsl:with-param>
    <xsl:with-param name="msg">
      <xsl:value-of select="@status_text"/>
    </xsl:with-param>
  </xsl:call-template>
</xsl:template>

<!--     USER -->

<xsl:template match="user">
  <xsl:variable name="class">
    <xsl:choose>
      <xsl:when test="position() mod 2 = 0">even</xsl:when>
      <xsl:otherwise>odd</xsl:otherwise>
    </xsl:choose>
  </xsl:variable>
  <tr class="{$class}">
    <td>
      <b>
        <a href="/omp?cmd=get_user&amp;user_id={@id}&amp;filter={str:encode-uri (../filters/term, true ())}&amp;token={/envelope/token}">
          <xsl:value-of select="name"/>
        </a>
      </b>
      <xsl:choose>
        <xsl:when test="comment != ''">
          <br/>(<xsl:value-of select="comment"/>)
        </xsl:when>
        <xsl:otherwise></xsl:otherwise>
      </xsl:choose>
    </td>
    <td>
      <xsl:value-of select="role"/>
    </td>
    <td>
      <xsl:for-each select="groups/group">
        <a href="/omp?cmd=get_group&amp;group_id={@id}&amp;token={/envelope/token}">
          <xsl:value-of select="name"/>
        </a>
        <xsl:if test="position() != last()">, </xsl:if>
      </xsl:for-each>
    </td>
    <td>
      <xsl:choose>
        <xsl:when test="count(hosts) = 0 or hosts/@allow = 2">
          Allow All
        </xsl:when>
        <xsl:when test="hosts/@allow = 3">
          Custom
        </xsl:when>
        <xsl:when test="hosts/@allow = 0">
          Deny:
          <xsl:value-of select="hosts/text()"/>
        </xsl:when>
        <xsl:when test="hosts/@allow = 1">
          Allow:
          <xsl:value-of select="hosts/text()"/>
        </xsl:when>
      </xsl:choose>
    </td>
    <xsl:if test="//group[@name='method:ldap_connect']/auth_conf_setting[@key='enable']/@value = 'true'">
      <td>
        <xsl:choose>
          <xsl:when test="sources/source/text() = 'ldap_connect'">
            <input type="checkbox" name="-" value="-" checked="checked" disabled="true"/>
          </xsl:when>
          <xsl:otherwise>
            <input type="checkbox" name="-" value="-" disabled="true"/>
          </xsl:otherwise>
        </xsl:choose>
      </td>
    </xsl:if>
    <td>
      <xsl:choose>
        <xsl:when test="name=/envelope/login/text()">
          <img src="/img/delete_inactive.png" border="0" alt="Delete"
               style="margin-left:3px;"/>
        </xsl:when>
        <xsl:otherwise>
          <div style="display: inline">
            <form style="display: inline; font-size: 0px; margin-left: 3px" action="/omp" method="post" enctype="multipart/form-data">
              <input type="hidden" name="token" value="{/envelope/token}"/>
              <input type="hidden" name="caller" value="{/envelope/caller}"/>
              <input type="hidden" name="cmd" value="delete_user"/>
              <input type="hidden" name="user_id" value="{@id}"/>
              <input type="image" src="/img/delete.png" alt="Delete"
                     name="Delete" value="Delete" title="Delete"/>
            </form>
          </div>
        </xsl:otherwise>
      </xsl:choose>
      <xsl:call-template name="list-window-line-icons">
        <xsl:with-param name="cap-type" select="'User'"/>
        <xsl:with-param name="type" select="'user'"/>
        <xsl:with-param name="id" select="@id"/>
        <xsl:with-param name="notrash" select="1"/>
      </xsl:call-template>
    </td>
  </tr>
</xsl:template>

<xsl:template match="user" mode="details">
  <div class="gb_window">
    <div class="gb_window_part_left"></div>
    <div class="gb_window_part_right"></div>
    <div class="gb_window_part_center">
       User Details
       <xsl:call-template name="details-header-icons">
         <xsl:with-param name="cap-type" select="'User'"/>
         <xsl:with-param name="type" select="'user'"/>
       </xsl:call-template>
    </div>
    <div class="gb_window_part_content">
      <table>
        <tr>
          <td><b>Login Name:</b></td>
          <td><b><xsl:value-of select="name"/></b></td>
        </tr>
        <tr>
          <td>Role:</td>
          <td><xsl:value-of select="role"/></td>
        </tr>
        <tr>
          <td>Groups:</td>
          <td>
            <xsl:for-each select="groups/group">
              <a href="/omp?cmd=get_group&amp;group_id={@id}&amp;token={/envelope/token}">
                <xsl:value-of select="name"/>
              </a>
              <xsl:if test="position() != last()">, </xsl:if>
            </xsl:for-each>
          </td>
        </tr>
        <tr>
          <td>Host Access:</td>
          <td>
            <xsl:choose>
              <xsl:when test="count(hosts) = 0 or hosts/@allow = 2">
                Allow All
              </xsl:when>
              <xsl:when test="hosts/@allow = 3">
                Custom
              </xsl:when>
              <xsl:when test="hosts/@allow = 0">
                Deny:
                <xsl:value-of select="hosts/text()"/>
              </xsl:when>
              <xsl:when test="hosts/@allow = 1">
                Allow:
                <xsl:value-of select="hosts/text()"/>
              </xsl:when>
            </xsl:choose>
          </td>
        </tr>
        <xsl:if test="//group[@name='method:ldap_connect']/auth_conf_setting[@key='enable']/@value = 'true'">
          <tr>
            <td>LDAP-Authentication:</td>
            <td>
              <xsl:choose>
                <xsl:when test="sources/source/text() = 'ldap_connect'">
                  Yes
                </xsl:when>
                <xsl:otherwise>
                  No
                </xsl:otherwise>
              </xsl:choose>
            </td>
          </tr>
        </xsl:if>

      </table>

<!--
      <xsl:choose>
        <xsl:when test="count(tasks/task) = 0">
          <h1>Tasks managed by this User: None</h1>
        </xsl:when>
        <xsl:otherwise>
          <h1>Tasks managed by this User</h1>
          <table class="gbntable" cellspacing="2" cellpadding="4">
            <tr class="gbntablehead2">
              <td>Name</td>
              <td>Actions</td>
            </tr>
            <xsl:for-each select="tasks/task">
              <xsl:variable name="class">
                <xsl:choose>
                  <xsl:when test="position() mod 2 = 0">even</xsl:when>
                  <xsl:otherwise>odd</xsl:otherwise>
                </xsl:choose>
              </xsl:variable>
              <tr class="{$class}">
                <td><xsl:value-of select="name"/></td>
                <td width="100">
                  <a href="/omp?cmd=get_tasks&amp;task_id={@id}&amp;token={/envelope/token}" title="Reports">
                    <img src="/img/list.png"
                         border="0"
                         alt="Reports"
                         style="margin-left:3px;"/>
                  </a>
                </td>
              </tr>
            </xsl:for-each>
          </table>
        </xsl:otherwise>
      </xsl:choose>
-->
    </div>
  </div>
</xsl:template>

<xsl:template match="user" mode="edit">
  <div class="gb_window">
    <div class="gb_window_part_left"></div>
    <div class="gb_window_part_right"></div>
    <div class="gb_window_part_center">
       Edit User
       <xsl:call-template name="edit-header-icons">
         <xsl:with-param name="cap-type" select="'User'"/>
         <xsl:with-param name="type" select="'user'"/>
         <xsl:with-param name="id"
                         select="@id"/>
       </xsl:call-template>
    </div>
    <div class="gb_window_part_content">
      <form action="/omp" method="post" enctype="multipart/form-data">
        <input type="hidden" name="token" value="{/envelope/token}"/>
        <input type="hidden" name="cmd" value="save_user"/>
        <input type="hidden" name="caller" value="{/envelope/caller}"/>
        <input type="hidden" name="next" value="{/envelope/params/next}"/>
        <table border="0" cellspacing="0" cellpadding="3" width="100%">
          <tr class="odd">
            <td valign="top" width="125"><b>Login Name:</b></td>
            <td>
              <input type="hidden" name="user_id" value="{@id}"/>
              <input type="hidden" name="login" value="{name}"/>
              <b><xsl:value-of select="name"/></b>
            </td>
          </tr>
          <tr>
            <td valign="top" width="125">Password</td>
            <td>
              <label>
                <input type="radio" name="modify_password" value="0" checked="1"/>
                Use existing value
              </label>
              <br/>
              <input type="radio" name="modify_password" value="1"/>
              <input type="password" name="password" value="" size="30"
                     maxlength="40"/>
            </td>
          </tr>
          <tr class="odd">
            <td valign="top">Role</td>
            <td>
              <select name="role">
                <xsl:choose>
                  <xsl:when test="role='User'">
                    <option value="Admin">Admin</option>
                    <option value="User" selected="1">User</option>
                    <option value="Observer">Observer</option>
                  </xsl:when>
                  <xsl:when test="role='Observer'">
                    <option value="Admin">Admin</option>
                    <option value="User">User</option>
                    <option value="Observer" selected="1">Observer</option>
                  </xsl:when>
                  <xsl:otherwise>
                    <option value="Admin" selected="1">Admin</option>
                    <option value="User">User</option>
                    <option value="Observer">Observer</option>
                  </xsl:otherwise>
                </xsl:choose>
              </select>
            </td>
          </tr>
          <tr>
            <td>Groups (optional)</td>
            <td>
              <xsl:variable name="groups"
                            select="../../../get_groups_response/group"/>
              <xsl:choose>
                <xsl:when test="count (/envelope/params/_param[substring-before (name, ':') = 'group_id_optional'][value != '--']) &gt; 0">
                  <xsl:for-each select="/envelope/params/_param[substring-before (name, ':') = 'group_id_optional'][value != '--']/value">
                    <select name="group_id_optional:{position ()}">
                      <xsl:variable name="group_id" select="text ()"/>
                      <xsl:choose>
                        <xsl:when test="string-length ($group_id) &gt; 0">
                          <option value="0">--</option>
                        </xsl:when>
                        <xsl:otherwise>
                          <option value="0" selected="1">--</option>
                        </xsl:otherwise>
                      </xsl:choose>
                      <xsl:for-each select="$groups">
                        <xsl:choose>
                          <xsl:when test="@id = $group_id">
                            <option value="{@id}" selected="1"><xsl:value-of select="name"/></option>
                          </xsl:when>
                          <xsl:otherwise>
                            <option value="{@id}"><xsl:value-of select="name"/></option>
                          </xsl:otherwise>
                        </xsl:choose>
                      </xsl:for-each>
                    </select>
                    <br/>
                  </xsl:for-each>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:for-each select="groups/group">
                    <select name="group_id_optional:{position ()}">
                      <xsl:variable name="group_id" select="@id"/>
                      <xsl:choose>
                        <xsl:when test="string-length ($group_id) &gt; 0">
                          <option value="0">--</option>
                        </xsl:when>
                        <xsl:otherwise>
                          <option value="0" selected="1">--</option>
                        </xsl:otherwise>
                      </xsl:choose>
                      <xsl:for-each select="$groups">
                        <xsl:choose>
                          <xsl:when test="@id = $group_id">
                            <option value="{@id}" selected="1"><xsl:value-of select="name"/></option>
                          </xsl:when>
                          <xsl:otherwise>
                            <option value="{@id}"><xsl:value-of select="name"/></option>
                          </xsl:otherwise>
                        </xsl:choose>
                      </xsl:for-each>
                    </select>
                    <br/>
                  </xsl:for-each>
                </xsl:otherwise>
              </xsl:choose>

              <xsl:variable name="count">
                <xsl:variable name="params"
                              select="count (/envelope/params/_param[substring-before (name, ':') = 'group_id_optional'][value != '--'])"/>
                <xsl:choose>
                  <xsl:when test="$params &gt; 0">
                    <xsl:value-of select="$params"/>
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:value-of select="count (groups/group)"/>
                  </xsl:otherwise>
                </xsl:choose>
              </xsl:variable>
              <xsl:call-template name="new-user-group-select">
                <xsl:with-param name="groups" select="../../../get_groups_response"/>
                <xsl:with-param name="count" select="/envelope/params/groups - $count"/>
                <xsl:with-param name="position" select="$count + 1"/>
              </xsl:call-template>

              <input type="submit" name="submit_plus_group" value="+"/>

              <xsl:choose>
                <xsl:when test="string-length (/envelope/params/groups)">
                  <input type="hidden" name="groups" value="{/envelope/params/groups}"/>
                </xsl:when>
                <xsl:otherwise>
                  <input type="hidden" name="groups" value="{$count + 1}"/>
                </xsl:otherwise>
              </xsl:choose>
            </td>
          </tr>
          <tr class="odd">
            <td valign="top">Host Access</td>
            <td>
              <label>
                <xsl:choose>
                  <xsl:when test="count(hosts) = 0 or hosts/@allow &gt; 1">
                    <input type="radio" name="hosts_allow" value="2" checked="1"/>
                  </xsl:when>
                  <xsl:otherwise>
                    <input type="radio" name="hosts_allow" value="2"/>
                  </xsl:otherwise>
                </xsl:choose>
                Allow All
              </label>
              <br/>
              <label>
                <xsl:choose>
                  <xsl:when test="hosts/@allow = 1">
                    <input type="radio" name="hosts_allow" value="1" checked="1"/>
                  </xsl:when>
                  <xsl:otherwise>
                    <input type="radio" name="hosts_allow" value="1"/>
                  </xsl:otherwise>
                </xsl:choose>
                Allow:
              </label>
              <label>
                <xsl:choose>
                  <xsl:when test="hosts/@allow = 0">
                    <input type="radio" name="hosts_allow" value="0" checked="1"/>
                  </xsl:when>
                  <xsl:otherwise>
                    <input type="radio" name="hosts_allow" value="0"/>
                  </xsl:otherwise>
                </xsl:choose>
                Deny:
              </label>
              <br/>
              <input type="text" name="access_hosts" value="{hosts}" size="30"
                     maxlength="500"/>
            </td>
          </tr>
          <!-- Only if per-user ldap enabled. -->
          <xsl:if test="//group[@name='method:ldap_connect']/auth_conf_setting[@key='enable']/@value = 'true'">
            <tr>
              <td valign="top">Authentication via LDAP</td>
              <td>
               <xsl:choose>
                 <xsl:when test="sources/source/text() = 'ldap_connect'">
                   <input type="checkbox" name="enable_ldap_connect" value="1" checked="checked"/>
                 </xsl:when>
                 <xsl:otherwise>
                   <input type="checkbox" name="enable_ldap_connect" value="1"/>
                 </xsl:otherwise>
               </xsl:choose>
              </td>
            </tr>
          </xsl:if>
          <tr>
            <td colspan="2" style="text-align:right;">
              <input type="submit" name="submit" value="Save User"/>
            </td>
          </tr>
        </table>
      </form>
    </div>
  </div>
</xsl:template>

<!--     EDIT_USER -->

<xsl:template match="edit_user">
  <xsl:apply-templates select="gsad_msg"/>
  <xsl:apply-templates select="modify_user_response"/>
  <xsl:apply-templates select="commands_response/get_users_response/user" mode="edit"/>
</xsl:template>

<!--     GET_USER -->

<xsl:template match="get_user">
  <xsl:apply-templates select="gsad_msg"/>
  <xsl:apply-templates select="commands_response/delete_user_response"/>
  <xsl:apply-templates select="commands_response/modify_user_response"/>
  <xsl:apply-templates select="get_users_response/user" mode="details"/>
</xsl:template>

<!--     GET_USERS_RESPONSE -->

<xsl:template match="get_users">
  <xsl:apply-templates select="gsad_msg"/>
  <xsl:apply-templates select="../modify_auth_response" mode="show"/>
  <!-- If any describe_auth was found, match it here -->
  <xsl:call-template name="describe_auth_response" mode="show"/>
  <xsl:apply-templates select="delete_user_response"/>
  <xsl:apply-templates select="create_user_response"/>
  <xsl:apply-templates select="modify_user_response"/>
  <!-- The for-each makes the get_users_response the current node. -->
  <xsl:for-each select="get_users_response | commands_response/get_users_response">
    <xsl:choose>
      <xsl:when test="substring(@status, 1, 1) = '4' or substring(@status, 1, 1) = '5'">
        <xsl:call-template name="command_result_dialog">
          <xsl:with-param name="operation">
            Get Users
          </xsl:with-param>
          <xsl:with-param name="status">
            <xsl:value-of select="@status"/>
          </xsl:with-param>
          <xsl:with-param name="msg">
            <xsl:value-of select="@status_text"/>
          </xsl:with-param>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="html-users-table"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:for-each>
</xsl:template>

<!-- AUTHENTICATION DESCRIPTION -->

<xsl:template match="group" mode="auth">
  <div class="gb_window">
    <div class="gb_window_part_left"></div>
    <div class="gb_window_part_right"></div>
    <div class="gb_window_part_center">
      <xsl:choose>
        <xsl:when test="@name='method:ads'">
          ADS Authentication
          <a href="/help/users.html?token={/envelope/token}#adsauthentication"
            title="Help: Users (ADS Authentication)">
          <img src="/img/help.png"/></a>
        </xsl:when>
        <xsl:when test="@name='method:ldap'">
          LDAP Authentication and Authorization
          <a href="/help/users.html?token={/envelope/token}#ldapauthentication"
            title="Help: Users (LDAP Authentication and Authorization)">
          <img src="/img/help.png"/></a>
        </xsl:when>
        <xsl:when test="@name='method:ldap_connect'">
          LDAP per-User Authentication
          <a href="/help/users.html?token={/envelope/token}#peruserldapauthentication"
            title="Help: Users (LDAP per-User Authentication)">
          <img src="/img/help.png"/></a>
        </xsl:when>
      </xsl:choose>
    </div>
    <div class="gb_window_part_content_no_pad">
      <div id="tasks">
        <form action="/oap" method="post" enctype="multipart/form-data">
          <input type="hidden" name="token" value="{/envelope/token}"/>
          <input type="hidden" name="cmd" value="save_auth"/>
          <input type="hidden" name="caller" value="{/envelope/caller}"/>
          <input type="hidden" name="next" value="get_users"/>
          <!-- group name is e.g. of method:ldap -->
          <input type="hidden" name="group" value="{@name}"/>
          <table class="gbntable" cellspacing="2" cellpadding="4" border="0">
            <tr class="gbntablehead2">
              <td>Setting</td>
              <td>Value</td>
            </tr>
              <tr class="odd">
                <td>Enable</td>
                <td>
                  <xsl:choose>
                    <xsl:when test="auth_conf_setting[@key='enable']/@value = 'true'">
                      <input type="checkbox" name="enable" value="1" checked="1"/>
                    </xsl:when>
                    <xsl:otherwise>
                      <input type="checkbox" name="enable" value="1"/>
                    </xsl:otherwise>
                 </xsl:choose>
                 </td>
              </tr>
              <tr class="even">
                <td>
                <xsl:choose>
                  <xsl:when test="@name='method:ads'">
                    ADS
                  </xsl:when>
                  <xsl:when test="@name='method:ldap'">
                    LDAP
                  </xsl:when>
                  <xsl:when test="@name='method:ldap_connect'">
                    LDAP
                  </xsl:when>
                </xsl:choose>
                Host</td>
                <td><input type="text" name="ldaphost" size="30"
                     value="{auth_conf_setting[@key='ldaphost']/@value}"/></td>
              </tr>
              <tr class="odd">
              <xsl:choose>
                <xsl:when test="@name='method:ads'">
                  <td>Domain</td>
                  <td><input type="text" name="domain" size="30"
                       value="{auth_conf_setting[@key='domain']/@value}"/></td>
                </xsl:when>
                <xsl:otherwise>
                  <td>Auth. DN</td>
                  <td><input type="text" name="authdn" size="30"
                       value="{auth_conf_setting[@key='authdn']/@value}"/></td>
                </xsl:otherwise>
              </xsl:choose>
              </tr>
            <tr>
              <td colspan="2" style="text-align:right;">
                <input type="submit" name="submit" value="Save"/>
              </td>
            </tr>
          </table>
        </form>
      </div>
    </div>
  </div>
</xsl:template>

<xsl:template match="describe_auth_response">
</xsl:template>

<xsl:template match="modify_auth_response" mode="show">
  <xsl:call-template name="command_result_dialog">
    <xsl:with-param name="operation">Save Authentication Configuration</xsl:with-param>
    <xsl:with-param name="status">
      <xsl:value-of select="@status"/>
    </xsl:with-param>
    <xsl:with-param name="msg">
      <xsl:value-of select="@status_text"/>
    </xsl:with-param>
  </xsl:call-template>
</xsl:template>

<xsl:template name="describe_auth_response" mode="show">
  <xsl:apply-templates select="describe_auth_response/group[@name='method:ldap']" mode="auth"/>
  <xsl:apply-templates select="describe_auth_response/group[@name='method:ads']" mode="auth"/>
  <xsl:apply-templates select="describe_auth_response/group[@name='method:ldap_connect']" mode="auth"/>
</xsl:template>

<!-- END AUTHENTICATION DESCRIPTION -->

<!-- END USERS MANAGEMENT -->

<!-- NEW_TARGET -->

<xsl:template match="new_target">
  <xsl:apply-templates select="gsad_msg"/>
  <xsl:apply-templates select="commands_response/delete_target_response"/>
  <xsl:apply-templates select="create_target_response"/>
  <xsl:call-template name="html-create-target-form">
    <xsl:with-param
      name="lsc-credentials"
      select="get_lsc_credentials_response | commands_response/get_lsc_credentials_response"/>
    <xsl:with-param
      name="target-sources"
      select="get_target_locators_response | commands_response/get_target_locators_response"/>
    <xsl:with-param
      name="port-lists"
      select="get_port_lists_response | commands_response/get_port_lists_response"/>
  </xsl:call-template>
</xsl:template>

<!-- NEW_TASK -->

<xsl:template name="new-task-alert-select">
  <xsl:param name="position" select="1"/>
  <xsl:param name="count" select="0"/>
  <xsl:param name="alerts" select="get_alerts_response"/>
  <select name="alert_id_optional:{$position}">
    <option value="--">--</option>
    <xsl:apply-templates select="$alerts/alert"
                         mode="newtask"/>
  </select>
  <xsl:if test="$count &gt; 1">
    <br/>
    <xsl:call-template name="new-task-alert-select">
      <xsl:with-param name="alerts" select="$alerts"/>
      <xsl:with-param name="count" select="$count - 1"/>
      <xsl:with-param name="position" select="$position + 1"/>
    </xsl:call-template>
  </xsl:if>
</xsl:template>

<xsl:template name="new-task-group-select">
  <xsl:param name="position" select="1"/>
  <xsl:param name="count" select="0"/>
  <xsl:param name="groups" select="get_groups_response"/>
  <select name="group_id_optional:{$position}">
    <option value="--">--</option>
    <xsl:apply-templates select="$groups/group"
                         mode="newtask"/>
  </select>
  <xsl:if test="$count &gt; 1">
    <br/>
    <xsl:call-template name="new-task-group-select">
      <xsl:with-param name="groups" select="$groups"/>
      <xsl:with-param name="count" select="$count - 1"/>
      <xsl:with-param name="position" select="$position + 1"/>
    </xsl:call-template>
  </xsl:if>
</xsl:template>

<xsl:template match="new_task">
  <xsl:apply-templates select="gsad_msg"/>

  <div class="gb_window_part_left"></div>
  <div class="gb_window_part_right"></div>
  <div class="gb_window_part_center">New Task
    <a href="/help/new_task.html?token={/envelope/token}#newtask" title="Help: New Task">
      <img src="/img/help.png"/>
    </a>
    <a href="/omp?cmd=wizard&amp;name=quick_first_scan&amp;refresh_interval={/envelope/params/refresh_interval}&amp;filter={str:encode-uri (/envelope/params/filter, true ())}&amp;filt_id={/envelope/params/filt_id}&amp;token={/envelope/token}"
       title="Wizard">
      <img src="/img/wizard.png" border="0" style="margin-left:3px;"/>
    </a>
    <a href="/omp?cmd=get_tasks&amp;refresh_interval={/envelope/params/refresh_interval}&amp;filter={str:encode-uri (/envelope/params/filter, true ())}&amp;filt_id={/envelope/params/filt_id}&amp;token={/envelope/token}"
       title="Tasks" style="margin-left:3px;">
      <img src="/img/list.png" border="0" alt="Tasks"/>
    </a>
  </div>
  <div class="gb_window_part_content">
    <form action="/omp" method="post" enctype="multipart/form-data">
      <input type="hidden" name="token" value="{/envelope/token}"/>
      <input type="hidden" name="cmd" value="create_task"/>
      <input type="hidden" name="caller" value="{/envelope/caller}"/>
      <xsl:if test="string-length (/envelope/params/filt_id) = 0">
        <input type="hidden" name="overrides" value="{/envelope/params/overrides}"/>
      </xsl:if>
      <input type="hidden" name="filter" value="{/envelope/params/filter}"/>
      <input type="hidden" name="filt_id" value="{/envelope/params/filt_id}"/>
      <table border="0" cellspacing="0" cellpadding="3" width="100%">
        <tr>
         <td valign="top" width="135">Name</td>
         <td>
           <input type="text" name="name" value="{gsa:param-or ('name', 'unnamed')}" size="30"
                  maxlength="80"/>
         </td>
        </tr>
        <tr>
          <td valign="top">Comment (optional)</td>
          <td>
            <input type="text" name="comment" value="{gsa:param-or ('comment', '')}" size="30" maxlength="400"/>
          </td>
        </tr>
        <tr>
          <td valign="top">Scan Config</td>
          <td>
            <select name="config_id">
              <xsl:variable name="config_id">
                <xsl:value-of select="/envelope/params/config_id"/>
              </xsl:variable>
              <!-- Skip the "empty" config. -->
              <xsl:for-each select="get_configs_response/config[@id!='085569ce-73ed-11df-83c3-002264764cea']">
                <xsl:choose>
                  <xsl:when test="@id = $config_id">
                    <option value="{@id}" selected="1"><xsl:value-of select="name"/></option>
                  </xsl:when>
                  <xsl:otherwise>
                    <option value="{@id}"><xsl:value-of select="name"/></option>
                  </xsl:otherwise>
                </xsl:choose>
              </xsl:for-each>
            </select>
          </td>
        </tr>
        <tr>
          <td>Scan Targets</td>
          <td>
            <select name="target_id">
              <xsl:variable name="target_id">
                <xsl:value-of select="/envelope/params/target_id"/>
              </xsl:variable>
              <xsl:for-each select="get_targets_response/target">
                <xsl:choose>
                  <xsl:when test="@id = $target_id">
                    <option value="{@id}" selected="1"><xsl:value-of select="name"/></option>
                  </xsl:when>
                  <xsl:otherwise>
                    <option value="{@id}"><xsl:value-of select="name"/></option>
                  </xsl:otherwise>
                </xsl:choose>
              </xsl:for-each>
            </select>
          </td>
        </tr>
        <tr>
          <td>Alerts (optional)</td>
          <td>
            <xsl:variable name="alerts"
                          select="get_alerts_response/alert"/>
            <xsl:for-each select="/envelope/params/_param[substring-before (name, ':') = 'alert_id_optional'][value != '--']">
              <select name="{name}">
                <xsl:variable name="alert_id" select="value"/>
                <xsl:choose>
                  <xsl:when test="string-length ($alert_id) &gt; 0">
                    <option value="0">--</option>
                  </xsl:when>
                  <xsl:otherwise>
                    <option value="0" selected="1">--</option>
                  </xsl:otherwise>
                </xsl:choose>
                <xsl:for-each select="$alerts">
                  <xsl:choose>
                    <xsl:when test="@id = $alert_id">
                      <option value="{@id}" selected="1"><xsl:value-of select="name"/></option>
                    </xsl:when>
                    <xsl:otherwise>
                      <option value="{@id}"><xsl:value-of select="name"/></option>
                    </xsl:otherwise>
                  </xsl:choose>
                </xsl:for-each>
              </select>
              <br/>
            </xsl:for-each>
            <xsl:variable name="count"
                          select="count (/envelope/params/_param[substring-before (name, ':') = 'alert_id_optional'][value != '--'])"/>
            <xsl:call-template name="new-task-alert-select">
              <xsl:with-param name="alerts" select="get_alerts_response"/>
              <xsl:with-param name="count" select="/envelope/params/alerts - $count"/>
              <xsl:with-param name="position" select="$count + 1"/>
            </xsl:call-template>

            <xsl:choose>
              <xsl:when test="string-length (/envelope/params/alerts)">
                <input type="hidden" name="alerts" value="{/envelope/params/alerts}"/>
              </xsl:when>
              <xsl:otherwise>
                <input type="hidden" name="alerts" value="{1}"/>
              </xsl:otherwise>
            </xsl:choose>
            <!-- Force the Create Task button to be the default. -->
            <input style="position: absolute; left: -100%"
                   type="submit" name="submit" value="Create Task"/>
            <input type="submit" name="submit_plus" value="+"/>
          </td>
        </tr>
        <tr>
          <td>Schedule (optional)</td>
          <td>
            <select name="schedule_id_optional">
              <xsl:variable name="schedule_id"
                            select="/envelope/params/schedule_id_optional"/>
              <xsl:choose>
                <xsl:when test="string-length ($schedule_id) &gt; 0">
                  <option value="--">--</option>
                </xsl:when>
                <xsl:otherwise>
                  <option value="--" selected="1">--</option>
                </xsl:otherwise>
              </xsl:choose>
              <xsl:for-each select="get_schedules_response/schedule">
                <xsl:choose>
                  <xsl:when test="@id = $schedule_id">
                    <option value="{@id}" selected="1"><xsl:value-of select="name"/></option>
                  </xsl:when>
                  <xsl:otherwise>
                    <option value="{@id}"><xsl:value-of select="name"/></option>
                  </xsl:otherwise>
                </xsl:choose>
              </xsl:for-each>
            </select>
          </td>
        </tr>
        <tr>
          <td>Slave (optional)</td>
          <td>
            <select name="slave_id_optional">
              <xsl:variable name="slave_id">
                <xsl:value-of select="/envelope/params/slave_id_optional"/>
              </xsl:variable>
              <xsl:choose>
                <xsl:when test="string-length ($slave_id) &gt; 0">
                  <option value="--">--</option>
                </xsl:when>
                <xsl:otherwise>
                  <option value="--" selected="1">--</option>
                </xsl:otherwise>
              </xsl:choose>
              <xsl:for-each select="get_slaves_response/slave">
                <xsl:choose>
                  <xsl:when test="@id = $slave_id">
                    <option value="{@id}" selected="1"><xsl:value-of select="name"/></option>
                  </xsl:when>
                  <xsl:otherwise>
                    <option value="{@id}"><xsl:value-of select="name"/></option>
                  </xsl:otherwise>
                </xsl:choose>
              </xsl:for-each>
            </select>
          </td>
        </tr>
        <tr>
          <td>Observers (optional)</td>
          <td>
            <input type="text" name="observers" size="30" maxlength="400"
                   value="{gsa:param-or ('observers', '')}"/>
          </td>
        </tr>
        <tr>
          <td>Observer Groups (optional)</td>
          <td>
            <xsl:variable name="groups"
                          select="get_groups_response/group"/>
            <xsl:for-each select="/envelope/params/_param[substring-before (name, ':') = 'group_id_optional'][value != '--']">
              <select name="{name}">
                <xsl:variable name="group_id" select="value"/>
                <xsl:choose>
                  <xsl:when test="string-length ($group_id) &gt; 0">
                    <option value="0">--</option>
                  </xsl:when>
                  <xsl:otherwise>
                    <option value="0" selected="1">--</option>
                  </xsl:otherwise>
                </xsl:choose>
                <xsl:for-each select="$groups">
                  <xsl:choose>
                    <xsl:when test="@id = $group_id">
                      <option value="{@id}" selected="1"><xsl:value-of select="name"/></option>
                    </xsl:when>
                    <xsl:otherwise>
                      <option value="{@id}"><xsl:value-of select="name"/></option>
                    </xsl:otherwise>
                  </xsl:choose>
                </xsl:for-each>
              </select>
              <br/>
            </xsl:for-each>
            <xsl:variable name="count"
                          select="count (/envelope/params/_param[substring-before (name, ':') = 'group_id_optional'][value != '--'])"/>
            <xsl:call-template name="new-task-group-select">
              <xsl:with-param name="groups" select="get_groups_response"/>
              <xsl:with-param name="count" select="/envelope/params/groups - $count"/>
              <xsl:with-param name="position" select="$count + 1"/>
            </xsl:call-template>

            <xsl:choose>
              <xsl:when test="string-length (/envelope/params/groups)">
                <input type="hidden" name="groups" value="{/envelope/params/groups}"/>
              </xsl:when>
              <xsl:otherwise>
                <input type="hidden" name="groups" value="{1}"/>
              </xsl:otherwise>
            </xsl:choose>
            <input type="submit" name="submit_plus_group" value="+"/>
          </td>
        </tr>
        <tr>
          <td>Add results to Asset Management</td>
          <td>
            <xsl:variable name="yes" select="/envelope/params/in_assets"/>
            <label>
              <xsl:choose>
                <xsl:when test="string-length ($yes) = 0 or $yes = 1">
                  <input type="radio" name="in_assets" value="1" checked="1"/>
                </xsl:when>
                <xsl:otherwise>
                 <input type="radio" name="in_assets" value="1"/>
                </xsl:otherwise>
              </xsl:choose>
              yes
            </label>
            <label>
              <xsl:choose>
                <xsl:when test="string-length ($yes) = 0 or $yes = 1">
                  <input type="radio" name="in_assets" value="0"/>
                </xsl:when>
                <xsl:otherwise>
                 <input type="radio" name="in_assets" value="0" checked="1"/>
                </xsl:otherwise>
              </xsl:choose>
              no
            </label>
          </td>
        </tr>
      </table>
      <table border="0" cellspacing="0" cellpadding="3" width="100%">
        <xsl:choose>
          <xsl:when test="commands_response/get_tasks_response/task/target/@id = ''">
          </xsl:when>
          <xsl:otherwise>
            <h2>Scan Intensity</h2>
            <tr>
              <td valign="top" width="320">
                Maximum concurrently executed NVTs per host
              </td>
              <td>
                <input type="text"
                       name="max_checks"
                       value="{gsa:param-or ('max_checks', '4')}"
                       size="10"
                       maxlength="10"/>
              </td>
            </tr>
            <tr>
              <td>
                Maximum concurrently scanned hosts
              </td>
              <td>
                <input type="text"
                       name="max_hosts"
                       value="{gsa:param-or ('max_hosts', '20')}"
                       size="10"
                       maxlength="10"/>
              </td>
            </tr>
          </xsl:otherwise>
        </xsl:choose>
        <tr>
          <td colspan="2" style="text-align:right;">
            <input type="submit" name="submit" value="Create Task"/>
          </td>
        </tr>
      </table>
      <br/>
    </form>
  </div>

  <div class="gb_window_part_left"></div>
  <div class="gb_window_part_right"></div>
  <div class="gb_window_part_center">New Container Task
    <a href="/help/new_task.html?token={/envelope/token}#newcontainertask" title="Help: New Task">
      <img src="/img/help.png"/>
    </a>
    <a href="/omp?cmd=get_tasks&amp;refresh_interval={/envelope/params/refresh_interval}&amp;filter={str:encode-uri (/envelope/params/filter, true ())}&amp;filt_id={/envelope/params/filt_id}&amp;token={/envelope/token}"
       title="Tasks" style="margin-left:3px;">
      <img src="/img/list.png" border="0" alt="Tasks"/>
    </a>
  </div>
  <div class="gb_window_part_content">
    <form action="/omp" method="post" enctype="multipart/form-data">
      <input type="hidden" name="token" value="{/envelope/token}"/>
      <input type="hidden" name="cmd" value="create_report"/>
      <input type="hidden" name="caller" value="{/envelope/caller}"/>
      <input type="hidden" name="next" value="get_tasks"/>
      <xsl:if test="string-length (/envelope/params/filt_id) = 0">
        <input type="hidden" name="overrides" value="{/envelope/params/overrides}"/>
      </xsl:if>
      <input type="hidden" name="filter" value="{/envelope/params/filter}"/>
      <input type="hidden" name="filt_id" value="{/envelope/params/filt_id}"/>
      <table border="0" cellspacing="0" cellpadding="3" width="100%">
        <tr>
         <td valign="top" width="125">Name</td>
         <td>
           <input type="text" name="name" value="unnamed" size="30"
                  maxlength="80"/>
         </td>
        </tr>
        <tr>
          <td valign="top" width="125">Comment (optional)</td>
          <td>
            <input type="text" name="comment" size="30" maxlength="400"/>
          </td>
        </tr>
        <tr>
          <td valign="top">Report</td>
          <td><input type="file" name="xml_file" size="30"/></td>
        </tr>
        <tr>
          <td colspan="2" style="text-align:right;">
            <input type="submit" name="submit" value="Create Task"/>
          </td>
        </tr>
      </table>
      <br/>
    </form>
  </div>
</xsl:template>

<!-- MY SETTINGS -->

<xsl:template match="modify_setting_response">
  <xsl:call-template name="command_result_dialog">
    <xsl:with-param name="operation">Save Settings</xsl:with-param>
    <xsl:with-param name="status">
      <xsl:value-of select="@status"/>
    </xsl:with-param>
    <xsl:with-param name="msg">
      <xsl:value-of select="@status_text"/>
    </xsl:with-param>
  </xsl:call-template>
</xsl:template>

<xsl:template match="get_my_settings">
  <xsl:apply-templates select="gsad_msg"/>
  <xsl:apply-templates select="modify_setting_response"/>

  <div class="gb_window">
    <div class="gb_window_part_left"></div>
    <div class="gb_window_part_right"></div>
    <div class="gb_window_part_center">My Settings
      <a href="/help/my_settings.html?token={/envelope/token}"
         title="Help: My Settings">
        <img src="/img/help.png"/>
      </a>
      <a href="/omp?cmd=edit_my_settings&amp;token={/envelope/token}"
         title="Edit My Settings"
         style="margin-left:3px;">
        <img src="/img/edit.png"/>
      </a>
    </div>
    <div class="gb_window_part_content_no_pad">
      <div id="tasks">
        <table class="gbntable" cellspacing="2" cellpadding="4" border="0">
          <tr class="gbntablehead2">
            <td>Name</td>
            <td>Value</td>
          </tr>
          <tr class="even">
            <td>Timezone</td>
            <td><xsl:value-of select="/envelope/timezone"/></td>
          </tr>
          <tr class="odd">
            <td>Password</td>
            <td>********</td>
          </tr>
          <tr class="even">
            <td>Rows Per Page</td>
            <td><xsl:value-of select="get_settings_response/setting[name='Rows Per Page']/value"/></td>
          </tr>
          <tr class="odd">
            <td>Wizard Rows</td>
            <td><xsl:value-of select="get_settings_response/setting[name='Wizard Rows']/value"/></td>
          </tr>
          <tr class="even">
            <td>Agents filter</td>
            <td>
              <xsl:call-template name="get-settings-filter">
                <xsl:with-param name="filter"
                                select="get_settings_response/setting[name='Agents Filter']/value"/>
              </xsl:call-template>
            </td>
          </tr>
          <tr class="odd">
            <td>Alerts filter</td>
            <td>
              <xsl:call-template name="get-settings-filter">
                <xsl:with-param name="filter"
                                select="get_settings_response/setting[name='Alerts Filter']/value"/>
              </xsl:call-template>
            </td>
          </tr>
          <tr class="even">
            <td>Configs filter</td>
            <td>
              <xsl:call-template name="get-settings-filter">
                <xsl:with-param name="filter"
                                select="get_settings_response/setting[name='Configs Filter']/value"/>
              </xsl:call-template>
            </td>
          </tr>
          <tr class="odd">
            <td>Credentials filter</td>
            <td>
              <xsl:call-template name="get-settings-filter">
                <xsl:with-param name="filter"
                                select="get_settings_response/setting[name='Credentials Filter']/value"/>
              </xsl:call-template>
            </td>
          </tr>
          <tr class="even">
            <td>Filters filter</td>
            <td>
              <xsl:call-template name="get-settings-filter">
                <xsl:with-param name="filter"
                                select="get_settings_response/setting[name='Filters Filter']/value"/>
              </xsl:call-template>
            </td>
          </tr>
          <tr class="odd">
            <td>Notes filter</td>
            <td>
              <xsl:call-template name="get-settings-filter">
                <xsl:with-param name="filter"
                                select="get_settings_response/setting[name='Notes Filter']/value"/>
              </xsl:call-template>
            </td>
          </tr>
          <tr class="even">
            <td>Overrides filter</td>
            <td>
              <xsl:call-template name="get-settings-filter">
                <xsl:with-param name="filter"
                                select="get_settings_response/setting[name='Overrides Filter']/value"/>
              </xsl:call-template>
            </td>
          </tr>
          <tr class="odd">
            <td>Port Lists filter</td>
            <td>
              <xsl:call-template name="get-settings-filter">
                <xsl:with-param name="filter"
                                select="get_settings_response/setting[name='Port Lists Filter']/value"/>
              </xsl:call-template>
            </td>
          </tr>
          <tr class="even">
            <td>Reports filter</td>
            <td>
              <xsl:call-template name="get-settings-filter">
                <xsl:with-param name="filter"
                                select="get_settings_response/setting[name='Reports Filter']/value"/>
              </xsl:call-template>
            </td>
          </tr>
          <tr class="odd">
            <td>Report Formats filter</td>
            <td>
              <xsl:call-template name="get-settings-filter">
                <xsl:with-param name="filter"
                                select="get_settings_response/setting[name='Report Formats Filter']/value"/>
              </xsl:call-template>
            </td>
          </tr>
          <tr class="even">
            <td>Schedules filter</td>
            <td>
              <xsl:call-template name="get-settings-filter">
                <xsl:with-param name="filter"
                                select="get_settings_response/setting[name='Schedules Filter']/value"/>
              </xsl:call-template>
            </td>
          </tr>
          <tr class="odd">
            <td>Slaves filter</td>
            <td>
              <xsl:call-template name="get-settings-filter">
                <xsl:with-param name="filter"
                                select="get_settings_response/setting[name='Slaves Filter']/value"/>
              </xsl:call-template>
            </td>
          </tr>
          <tr class="even">
            <td>Tags filter</td>
            <td>
              <xsl:call-template name="get-settings-filter">
                <xsl:with-param name="filter"
                                select="get_settings_response/setting[name='Tags Filter']/value"/>
              </xsl:call-template>
            </td>
          </tr>
          <tr class="even">
            <td>Targets filter</td>
            <td>
              <xsl:call-template name="get-settings-filter">
                <xsl:with-param name="filter"
                                select="get_settings_response/setting[name='Targets Filter']/value"/>
              </xsl:call-template>
            </td>
          </tr>
          <tr class="odd">
            <td>Tasks filter</td>
            <td>
              <xsl:call-template name="get-settings-filter">
                <xsl:with-param name="filter"
                                select="get_settings_response/setting[name='Tasks Filter']/value"/>
              </xsl:call-template>
            </td>
          </tr>
          <tr class="even">
            <td>CPE filter</td>
            <td>
              <xsl:call-template name="get-settings-filter">
                <xsl:with-param name="filter"
                                select="get_settings_response/setting[name='CPE Filter']/value"/>
              </xsl:call-template>
            </td>
          </tr>
          <tr class="odd">
            <td>CVE filter</td>
            <td>
              <xsl:call-template name="get-settings-filter">
                <xsl:with-param name="filter"
                                select="get_settings_response/setting[name='CVE Filter']/value"/>
              </xsl:call-template>
            </td>
          </tr>
          <tr class="even">
            <td>NVT filter</td>
            <td>
              <xsl:call-template name="get-settings-filter">
                <xsl:with-param name="filter"
                                select="get_settings_response/setting[name='NVT Filter']/value"/>
              </xsl:call-template>
            </td>
          </tr>
          <tr class="odd">
            <td>OVAL filter</td>
            <td>
              <xsl:call-template name="get-settings-filter">
                <xsl:with-param name="filter"
                                select="get_settings_response/setting[name='OVAL Filter']/value"/>
              </xsl:call-template>
            </td>
          </tr>
          <tr class="even">
            <td>DFN-CERT filter</td>
            <td>
              <xsl:call-template name="get-settings-filter">
                <xsl:with-param name="filter"
                                select="get_settings_response/setting[name='DFN-CERT Filter']/value"/>
              </xsl:call-template>
            </td>
          </tr>
          <tr class="odd">
            <td>All SecInfo filter</td>
            <td>
              <xsl:call-template name="get-settings-filter">
                <xsl:with-param name="filter"
                                select="get_settings_response/setting[name='All SecInfo Filter']/value"/>
              </xsl:call-template>
            </td>
          </tr>
        </table>
      </div>
    </div>
  </div>
</xsl:template>

<xsl:template match="edit_my_settings">
  <xsl:apply-templates select="gsad_msg"/>

  <div class="gb_window">
    <div class="gb_window_part_left"></div>
    <div class="gb_window_part_right"></div>
    <div class="gb_window_part_center">Edit My Settings
      <a href="/help/my_settings.html?token={/envelope/token}#edit"
         title="Help: My Settings (Edit)">
        <img src="/img/help.png"/>
      </a>
      <a href="/omp?cmd=get_my_settings&amp;token={/envelope/token}"
         title="My Settings" style="margin-left:3px;">
        <img src="/img/list.png" border="0" alt="My Settings"/>
      </a>
    </div>
    <div class="gb_window_part_content_no_pad">
      <div id="tasks">
        <form action="" method="post" enctype="multipart/form-data">
          <input type="hidden" name="token" value="{/envelope/token}"/>
          <input type="hidden" name="cmd" value="save_my_settings"/>
          <input type="hidden" name="caller" value="{/envelope/caller}"/>
          <table class="gbntable" cellspacing="2" cellpadding="4" border="0">
            <tr class="gbntablehead2">
              <td>Name</td>
              <td>Value</td>
            </tr>
            <tr>
              <td>Timezone</td>
              <td>
                <input type="text" name="text" size="40" maxlength="800"
                       value="{/envelope/timezone}"/>
              </td>
            </tr>
            <tr>
              <td valign="top">Password</td>
              <td>
                <label>
                  <input type="checkbox" name="enable" value="1"/>
                  Replace existing value with:
                </label>
                <br/>
                <input type="password" autocomplete="off" name="password"
                       size="30" maxlength="400" value=""/>
              </td>
            </tr>
            <tr>
              <td>Rows Per Page</td>
              <td>
                <input type="text" name="max" size="40" maxlength="800"
                       value="{get_settings_response/setting[name='Rows Per Page']/value}"/>
              </td>
              <td></td>
            </tr>
            <tr>
              <td>Wizard Rows</td>
              <td>
                <input type="text" name="max_results" size="40" maxlength="800"
                       value="{get_settings_response/setting[name='Wizard Rows']/value}"/>
              </td>
              <td></td>
            </tr>

            <tr>
              <td>Agents filter</td>
              <td>
                <xsl:call-template name="edit-settings-filters">
                    <xsl:with-param name="uuid" select="'4a1334c1-cb93-4a79-8634-103b0a50bdcd'"/>
                    <xsl:with-param name="filter-type" select="'Agent'"/>
                    <xsl:with-param name="filter"
                                    select="get_settings_response/setting[name='Agents Filter']/value"/>
                </xsl:call-template>
              </td>
            </tr>
            <tr>
              <td>Alerts filter</td>
              <td>
                <xsl:call-template name="edit-settings-filters">
                    <xsl:with-param name="uuid" select="'b833a6f2-dcdc-4535-bfb0-a5154b5b5092'"/>
                    <xsl:with-param name="filter-type" select="'Alert'"/>
                    <xsl:with-param name="filter"
                                    select="get_settings_response/setting[name='Alerts Filter']/value"/>
                </xsl:call-template>
              </td>
            </tr>
            <tr>
              <td>Configs filter</td>
              <td>
                <xsl:call-template name="edit-settings-filters">
                    <xsl:with-param name="uuid" select="'1a9fbd91-0182-44cd-bc88-a13a9b3b1bef'"/>
                    <xsl:with-param name="filter-type" select="'Config'"/>
                    <xsl:with-param name="filter"
                                    select="get_settings_response/setting[name='Configs Filter']/value"/>
                </xsl:call-template>
              </td>
            </tr>
            <tr>
              <td>Credentials filter</td>
              <td>
                <xsl:call-template name="edit-settings-filters">
                    <xsl:with-param name="uuid" select="'186a5ac8-fe5a-4fb1-aa22-44031fb339f3'"/>
                    <xsl:with-param name="filter-type" select="'Credential'"/>
                    <xsl:with-param name="filter"
                                    select="get_settings_response/setting[name='Credentials Filter']/value"/>
                </xsl:call-template>
              </td>
            </tr>
            <tr>
              <td>Filters filter</td>
              <td>
                <xsl:call-template name="edit-settings-filters">
                    <xsl:with-param name="uuid" select="'f9691163-976c-47e7-ad9a-38f2d5c81649'"/>
                    <xsl:with-param name="filter-type" select="'Filter'"/>
                    <xsl:with-param name="filter"
                                    select="get_settings_response/setting[name='Filters Filter']/value"/>
                </xsl:call-template>
              </td>
            </tr>
            <tr>
              <td>Notes filter</td>
              <td>
                <xsl:call-template name="edit-settings-filters">
                    <xsl:with-param name="uuid" select="'96abcd5a-9b6d-456c-80b8-c3221bfa499d'"/>
                    <xsl:with-param name="filter-type" select="'Note'"/>
                    <xsl:with-param name="filter"
                                    select="get_settings_response/setting[name='Notes Filter']/value"/>
                </xsl:call-template>
              </td>
            </tr>
            <tr>
              <td>Overrides filter</td>
              <td>
                <xsl:call-template name="edit-settings-filters">
                    <xsl:with-param name="uuid" select="'eaaaebf1-01ef-4c49-b7bb-955461c78e0a'"/>
                    <xsl:with-param name="filter-type" select="'Override'"/>
                    <xsl:with-param name="filter"
                                    select="get_settings_response/setting[name='Overrides Filter']/value"/>
                </xsl:call-template>
              </td>
            </tr>
            <tr>
              <td>Port Lists filter</td>
              <td>
                <xsl:call-template name="edit-settings-filters">
                    <xsl:with-param name="uuid" select="'7d52d575-baeb-4d98-bb68-e1730dbc6236'"/>
                    <xsl:with-param name="filter-type" select="'Port List'"/>
                    <xsl:with-param name="filter"
                                    select="get_settings_response/setting[name='Port Lists Filter']/value"/>
                </xsl:call-template>
              </td>
            </tr>
            <tr>
              <td>Reports filter</td>
              <td>
                <xsl:call-template name="edit-settings-filters">
                    <xsl:with-param name="uuid" select="'48ae588e-9085-41bc-abcb-3d6389cf7237'"/>
                    <xsl:with-param name="filter-type" select="'Report'"/>
                    <xsl:with-param name="filter"
                                    select="get_settings_response/setting[name='Reports Filter']/value"/>
                </xsl:call-template>
              </td>
            </tr>
            <tr>
              <td>Report Formats filter</td>
              <td>
                <xsl:call-template name="edit-settings-filters">
                    <xsl:with-param name="uuid" select="'249c7a55-065c-47fb-b453-78e11a665565'"/>
                    <xsl:with-param name="filter-type" select="'Report Format'"/>
                    <xsl:with-param name="filter"
                                    select="get_settings_response/setting[name='Report Formats Filter']/value"/>
                </xsl:call-template>
              </td>
            </tr>
            <tr>
              <td>Schedules filter</td>
              <td>
                <xsl:call-template name="edit-settings-filters">
                    <xsl:with-param name="uuid" select="'a83e321b-d994-4ae8-beec-bfb5fe3e7336'"/>
                    <xsl:with-param name="filter-type" select="'Schedule'"/>
                    <xsl:with-param name="filter"
                                    select="get_settings_response/setting[name='Schedules Filter']/value"/>
                </xsl:call-template>
              </td>
            </tr>
            <tr>
              <td>Slaves filter</td>
              <td>
                <xsl:call-template name="edit-settings-filters">
                    <xsl:with-param name="uuid" select="'2681c32a-8dfd-40c9-a9c6-8d4e2c7799eb'"/>
                    <xsl:with-param name="filter-type" select="'Slave'"/>
                    <xsl:with-param name="filter"
                                    select="get_settings_response/setting[name='Slaves Filter']/value"/>
                </xsl:call-template>
              </td>
            </tr>
            <tr>
              <td>Tags filter</td>
              <td>
                <xsl:call-template name="edit-settings-filters">
                    <xsl:with-param name="uuid" select="'108eea3b-fc61-483c-9da9-046762f137a8'"/>
                    <xsl:with-param name="filter-type" select="'Tag'"/>
                    <xsl:with-param name="filter"
                                    select="get_settings_response/setting[name='Tags Filter']/value"/>
                </xsl:call-template>
              </td>
            </tr>
            <tr>
              <td>Targets filter</td>
              <td>
                <xsl:call-template name="edit-settings-filters">
                    <xsl:with-param name="uuid" select="'236e2e41-9771-4e7a-8124-c432045985e0'"/>
                    <xsl:with-param name="filter-type" select="'Target'"/>
                    <xsl:with-param name="filter"
                                    select="get_settings_response/setting[name='Targets Filter']/value"/>
                </xsl:call-template>
              </td>
            </tr>
            <tr>
              <td>Tasks filter</td>
              <td>
                <xsl:call-template name="edit-settings-filters">
                    <xsl:with-param name="uuid" select="'1c981851-8244-466c-92c4-865ffe05e721'"/>
                    <xsl:with-param name="filter-type" select="'Task'"/>
                    <xsl:with-param name="filter"
                                    select="get_settings_response/setting[name='Tasks Filter']/value"/>
                </xsl:call-template>
              </td>
            </tr>
            <tr>
              <td>CPE filter</td>
              <td>
                <xsl:call-template name="edit-settings-filters">
                    <xsl:with-param name="uuid" select="'3414a107-ae46-4dea-872d-5c4479a48e8f'"/>
                    <xsl:with-param name="filter-type" select="'SecInfo'"/>
                    <xsl:with-param name="filter"
                                    select="get_settings_response/setting[name='CPE Filter']/value"/>
                </xsl:call-template>
              </td>
            </tr>
            <tr>
              <td>CVE filter</td>
              <td>
                <xsl:call-template name="edit-settings-filters">
                    <xsl:with-param name="uuid" select="'def63b5a-41ef-43f4-b9ef-03ef1665db5d'"/>
                    <xsl:with-param name="filter-type" select="'SecInfo'"/>
                    <xsl:with-param name="filter"
                                    select="get_settings_response/setting[name='CPE Filter']/value"/>
                </xsl:call-template>
              </td>
            </tr>
            <tr>
              <td>NVT filter</td>
              <td>
                <xsl:call-template name="edit-settings-filters">
                    <xsl:with-param name="uuid" select="'bef08b33-075c-4f8c-84f5-51f6137e40a3'"/>
                    <xsl:with-param name="filter-type" select="'SecInfo'"/>
                    <xsl:with-param name="filter"
                                    select="get_settings_response/setting[name='NVT Filter']/value"/>
                </xsl:call-template>
              </td>
            </tr>
            <tr>
              <td>OVAL filter</td>
              <td>
                <xsl:call-template name="edit-settings-filters">
                    <xsl:with-param name="uuid" select="'adb6ffc8-e50e-4aab-9c31-13c741eb8a16'"/>
                    <xsl:with-param name="filter-type" select="'SecInfo'"/>
                    <xsl:with-param name="filter"
                                    select="get_settings_response/setting[name='OVAL Filter']/value"/>
                </xsl:call-template>
              </td>
            </tr>
            <tr>
              <td>DFN-CERT filter</td>
              <td>
                <xsl:call-template name="edit-settings-filters">
                    <xsl:with-param name="uuid" select="'312350ed-bc06-44f3-8b3f-ab9eb828b80b'"/>
                    <xsl:with-param name="filter-type" select="'SecInfo'"/>
                    <xsl:with-param name="filter"
                                    select="get_settings_response/setting[name='DFN-CERT Filter']/value"/>
                </xsl:call-template>
              </td>
            </tr>

            <tr>
              <td>All SecInfo filter</td>
              <td>
                <xsl:call-template name="edit-settings-filters">
                    <xsl:with-param name="uuid" select="'feefe56b-e2da-4913-81cc-1a6ae3b36e64'"/>
                    <xsl:with-param name="filter-type" select="'SecInfo'"/>
                    <xsl:with-param name="filter"
                                    select="get_settings_response/setting[name='All SecInfo Filter']/value"/>
                </xsl:call-template>
              </td>
            </tr>

            <tr>
              <td colspan="2" style="text-align:right;">
                <input type="submit" name="submit" value="Save My Settings"/>
              </td>
            </tr>
          </table>
        </form>
      </div>
    </div>
  </div>
</xsl:template>

<!-- PROTOCOL DOC -->

<xsl:include href="omp-doc.xsl"/>

<xsl:template name="protocol">
  <div class="gb_window">
    <div class="gb_window_part_left"></div>
    <div class="gb_window_part_right"></div>
    <div class="gb_window_part_center">Help: OMP
      <div id="small_inline_form" style="display: inline; margin-left: 40px; font-weight: normal;">
        <form action="" method="get">
          <input type="hidden" name="token" value="{/envelope/token}"/>
          <input type="hidden" name="cmd" value="export_omp_doc"/>
          <select style="margin-bottom: 0px;" name="protocol_format" size="1">
            <option value="html" selected="1">HTML</option>
            <option value="rnc">RNC</option>
            <option value="xml">XML</option>
          </select>
          <input type="image"
                 name="Download OMP documentation"
                 src="/img/download.png"
                 alt="Download" style="margin-left:3px;margin-right:3px;"/>
        </form>
      </div>
    </div>
    <div class="gb_window_part_content">
      <div style="float:left;"><a href="/help/contents.html?token={/envelope/token}">Help Contents</a></div>
      <div style="text-align:left">

        <br/>

        <h1>OMP</h1>

        <xsl:if test="version">
          <p>Version: <xsl:value-of select="normalize-space(version)"/></p>
        </xsl:if>

        <xsl:if test="summary">
          <p><xsl:value-of select="normalize-space(summary)"/>.</p>
        </xsl:if>

        <h2 id="contents">Contents</h2>
        <ol>
          <li><a href="#type_summary">Summary of Data Types</a></li>
          <li><a href="#element_summary">Summary of Elements</a></li>
          <li><a href="#command_summary">Summary of Commands</a></li>
          <li><a href="#rnc_preamble">RNC Preamble</a></li>
          <li><a href="#type_details">Data Type Details</a></li>
          <li><a href="#element_details">Element Details</a></li>
          <li><a href="#command_details">Command Details</a></li>
        </ol>

        <xsl:call-template name="type-summary"/>
        <xsl:call-template name="element-summary"/>
        <xsl:call-template name="command-summary"/>
        <xsl:call-template name="rnc-preamble"/>
        <xsl:call-template name="type-details"/>
        <xsl:call-template name="element-details"/>
        <xsl:call-template name="command-details"/>

      </div>
    </div>
  </div>
</xsl:template>

<xsl:template match="get_protocol_doc">
  <xsl:apply-templates select="gsad_msg"/>
  <xsl:for-each select="help_response/schema/protocol">
    <xsl:call-template name="protocol"/>
  </xsl:for-each>
</xsl:template>

<xsl:template match="cvss_calculator">
  <div class="gb_window">
    <div class="gb_window_part_left"></div>
    <div class="gb_window_part_right"></div>
    <div class="gb_window_part_center">CVSS Base Score Calculator
      <a href="/help/cvss_calculator.html?token={/envelope/token}"
         title="Help: CVSS Base Score Calculator">
        <img src="/img/help.png"/>
      </a>
    </div>
    <div class="gb_window_part_content">
      <table border="0" cellspacing="0" cellpadding="3" width="100%">
        <tr>
          <form action="/omp" method="get" enctype="multipart/form-data">
            <input type="hidden" name="cmd" value="cvss_calculator"/>
              <td valign="top" width="125">
                <b>From Metrics:</b>
              </td>
              <td>
                <table border="0" cellspacing="0" cellpadding="3" width="50%">
                  <tr>
                    <td>Access Vector:</td>
                    <td>
                      <select name="cvss_av" style="width:100px;">
                        <xsl:call-template name="opt">
                          <xsl:with-param name="value" select="'L'"/>
                          <xsl:with-param name="content" select="'Local'"/>
                          <xsl:with-param name="select-value" select="cvss_av"/>
                        </xsl:call-template>
                        <xsl:call-template name="opt">
                          <xsl:with-param name="value" select="'A'"/>
                          <xsl:with-param name="content" select="'Adjacent'"/>
                          <xsl:with-param name="select-value" select="cvss_av"/>
                        </xsl:call-template>
                        <xsl:call-template name="opt">
                          <xsl:with-param name="value" select="'N'"/>
                          <xsl:with-param name="content" select="'Network'"/>
                          <xsl:with-param name="select-value" select="cvss_av"/>
                        </xsl:call-template>
                      </select>
                    </td>
                  </tr>
                  <tr>
                    <td>Access Complexity:</td>
                    <td>
                      <select name="cvss_ac" style="width:100px;">
                        <xsl:call-template name="opt">
                          <xsl:with-param name="value" select="'H'"/>
                          <xsl:with-param name="content" select="'High'"/>
                          <xsl:with-param name="select-value" select="cvss_ac"/>
                        </xsl:call-template>
                        <xsl:call-template name="opt">
                          <xsl:with-param name="value" select="'M'"/>
                          <xsl:with-param name="content" select="'Medium'"/>
                          <xsl:with-param name="select-value" select="cvss_ac"/>
                        </xsl:call-template>
                        <xsl:call-template name="opt">
                          <xsl:with-param name="value" select="'L'"/>
                          <xsl:with-param name="content" select="'Low'"/>
                          <xsl:with-param name="select-value" select="cvss_ac"/>
                        </xsl:call-template>
                      </select>
                    </td>
                  </tr>
                  <tr>
                    <td>Authentication:</td>
                    <td>
                      <select name="cvss_au" style="width:100px;">
                        <xsl:call-template name="opt">
                          <xsl:with-param name="value" select="'M'"/>
                          <xsl:with-param name="content" select="'Multiple'"/>
                          <xsl:with-param name="select-value" select="cvss_au"/>
                        </xsl:call-template>
                        <xsl:call-template name="opt">
                          <xsl:with-param name="value" select="'S'"/>
                          <xsl:with-param name="content" select="'Single'"/>
                          <xsl:with-param name="select-value" select="cvss_au"/>
                        </xsl:call-template>
                        <xsl:call-template name="opt">
                          <xsl:with-param name="value" select="'N'"/>
                          <xsl:with-param name="content" select="'None'"/>
                          <xsl:with-param name="select-value" select="cvss_au"/>
                        </xsl:call-template>
                      </select><br/>
                    </td>
                  </tr>
                  <tr>
                    <td>Confidentiality:</td>
                    <td>
                      <select name="cvss_c" style="width:100px;">
                        <xsl:call-template name="opt">
                          <xsl:with-param name="value" select="'N'"/>
                          <xsl:with-param name="content" select="'None'"/>
                          <xsl:with-param name="select-value" select="cvss_c"/>
                        </xsl:call-template>
                        <xsl:call-template name="opt">
                          <xsl:with-param name="value" select="'P'"/>
                          <xsl:with-param name="content" select="'Partial'"/>
                          <xsl:with-param name="select-value" select="cvss_c"/>
                        </xsl:call-template>
                        <xsl:call-template name="opt">
                          <xsl:with-param name="value" select="'C'"/>
                          <xsl:with-param name="content" select="'Complete'"/>
                          <xsl:with-param name="select-value" select="cvss_c"/>
                        </xsl:call-template>
                      </select>
                    </td>
                  </tr>
                  <tr>
                    <td>Integrity:</td>
                    <td>
                      <select name="cvss_i" style="width:100px;">
                        <xsl:call-template name="opt">
                          <xsl:with-param name="value" select="'N'"/>
                          <xsl:with-param name="content" select="'None'"/>
                          <xsl:with-param name="select-value" select="cvss_i"/>
                        </xsl:call-template>
                        <xsl:call-template name="opt">
                          <xsl:with-param name="value" select="'P'"/>
                          <xsl:with-param name="content" select="'Partial'"/>
                          <xsl:with-param name="select-value" select="cvss_i"/>
                        </xsl:call-template>
                        <xsl:call-template name="opt">
                          <xsl:with-param name="value" select="'C'"/>
                          <xsl:with-param name="content" select="'Complete'"/>
                          <xsl:with-param name="select-value" select="cvss_i"/>
                        </xsl:call-template>
                      </select>
                    </td>
                  </tr>
                  <tr>
                    <td>Availability:</td>
                    <td>
                      <select name="cvss_a" style="width:100px;">
                        <xsl:call-template name="opt">
                          <xsl:with-param name="value" select="'N'"/>
                          <xsl:with-param name="content" select="'None'"/>
                          <xsl:with-param name="select-value" select="cvss_a"/>
                        </xsl:call-template>
                        <xsl:call-template name="opt">
                          <xsl:with-param name="value" select="'P'"/>
                          <xsl:with-param name="content" select="'Partial'"/>
                          <xsl:with-param name="select-value" select="cvss_a"/>
                        </xsl:call-template>
                        <xsl:call-template name="opt">
                          <xsl:with-param name="value" select="'C'"/>
                          <xsl:with-param name="content" select="'Complete'"/>
                          <xsl:with-param name="select-value" select="cvss_a"/>
                        </xsl:call-template>
                      </select>
                    </td>
                  </tr>
                </table>
              </td>
              <td style="text-align:right; vertical-align:bottom;">
                <input type="hidden" name="name" value="metrics"/>
                <input type="submit" name="submit" value="Calculate"/>
              </td>
            <input type="hidden" name="token" value="{/envelope/token}"/>
          </form>
        </tr>
        <tr height="50">
          <form action="/omp" method="get" enctype="multipart/form-data">
            <input type="hidden" name="cmd" value="cvss_calculator"/>
              <td width="125">
                <b>From Vector:</b>
              </td>
              <td>
                <input type="text" name="cvss_vector" value="{cvss_vector}"
                       size="30" maxlength="80" style="vertical-align:middle"/>
              </td>
              <td style="text-align:right;">
                <input type="hidden" name="name" value="vector"/>
                <input type="submit" name="submit" value="Calculate"/>
              </td>
            <input type="hidden" name="token" value="{/envelope/token}"/>
          </form>
        </tr>
      </table>
      <xsl:choose>
        <xsl:when test="cvss_score">
          <xsl:if test="cvss_score != '-1.0'">
            <br/>
            <table>
              <tr>
                <td><b>Base Vector:</b></td>
                <td>
                  <xsl:value-of select="cvss_vector"/><br/>
                </td>
              </tr>
              <tr>
                <td><b>Base Score:</b></td>
                <td>
                  <xsl:call-template name="severity-bar">
                    <xsl:with-param name="cvss" select="cvss_score"/>
                  </xsl:call-template>
                </td>
              </tr>
            </table>
          </xsl:if>
          <xsl:if test="cvss_score = '-1.0'">
            <br/>Invalid CVSS Base Vector value provided.
            Use back button of your browser to edit the vector.<br/><br/>
          </xsl:if>
        </xsl:when>
      </xsl:choose>
    </div>
  </div>
</xsl:template>

<!-- COMMANDS_RESPONSE -->

<xsl:template match="commands_response">
  <xsl:apply-templates/>
</xsl:template>

</xsl:stylesheet>
