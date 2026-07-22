param(
    [string]$InputPath = "docs/CLEANING_PLAN_v1.md",
    [string]$OutputPath = "docs/CLEANING_PLAN_v1.docx"
)

Add-Type -AssemblyName System.IO.Compression
Add-Type -AssemblyName System.IO.Compression.FileSystem

function Escape-Xml([string]$Value) {
    return [System.Security.SecurityElement]::Escape($Value)
}

function Paragraph-Xml([string]$Text, [string]$Style = "") {
    $styleXml = if ($Style) { "<w:pPr><w:pStyle w:val='$Style'/></w:pPr>" } else { "" }
    $text = Escape-Xml($Text -replace '\*\*', '' -replace '`', '')
    return "<w:p>$styleXml<w:r><w:t xml:space='preserve'>$text</w:t></w:r></w:p>"
}

function Cell-Xml([string]$Text, [bool]$Header = $false) {
    $cellStyle = if ($Header) { "<w:rPr><w:b/><w:color w:val='FFFFFF'/><w:sz w:val='17'/></w:rPr>" } else { "<w:rPr><w:sz w:val='17'/></w:rPr>" }
    $cellProperties = if ($Header) { "<w:tcPr><w:tcW w:w='2500' w:type='dxa'/><w:shd w:val='clear' w:fill='1F4E78'/><w:vAlign w:val='top'/></w:tcPr>" } else { "<w:tcPr><w:tcW w:w='2500' w:type='dxa'/><w:vAlign w:val='top'/></w:tcPr>" }
    $text = Escape-Xml($Text -replace '\*\*', '' -replace '`', '')
    return "<w:tc>$cellProperties<w:p><w:r>$cellStyle<w:t xml:space='preserve'>$text</w:t></w:r></w:p></w:tc>"
}

function Table-Xml([object[]]$Rows) {
    $rowsXml = for ($rowIndex = 0; $rowIndex -lt $Rows.Count; $rowIndex++) {
        $cells = foreach ($value in $Rows[$rowIndex]) { Cell-Xml $value ($rowIndex -eq 0) }
        $rowProperties = if ($rowIndex -eq 0) { "<w:trPr><w:tblHeader/></w:trPr>" } else { "<w:trPr><w:cantSplit/></w:trPr>" }
        "<w:tr>$rowProperties$($cells -join '')</w:tr>"
    }
    return "<w:tbl><w:tblPr><w:tblW w:w='0' w:type='auto'/><w:tblLayout w:type='autofit'/><w:tblCellMar><w:top w:w='80' w:type='dxa'/><w:left w:w='80' w:type='dxa'/><w:bottom w:w='80' w:type='dxa'/><w:right w:w='80' w:type='dxa'/></w:tblCellMar><w:tblBorders><w:top w:val='single' w:sz='4' w:color='9EADBA'/><w:left w:val='single' w:sz='4' w:color='9EADBA'/><w:bottom w:val='single' w:sz='4' w:color='9EADBA'/><w:right w:val='single' w:sz='4' w:color='9EADBA'/><w:insideH w:val='single' w:sz='4' w:color='D9E2F3'/><w:insideV w:val='single' w:sz='4' w:color='D9E2F3'/></w:tblBorders></w:tblPr>$($rowsXml -join '')</w:tbl>"
}

$lines = Get-Content -LiteralPath $InputPath
$body = New-Object System.Collections.Generic.List[string]
for ($i = 0; $i -lt $lines.Count; $i++) {
    $line = $lines[$i]
    if ($line -match '^\|') {
        $tableLines = New-Object System.Collections.Generic.List[string]
        while ($i -lt $lines.Count -and $lines[$i] -match '^\|') {
            $tableLines.Add($lines[$i])
            $i++
        }
        $i--
        $rows = New-Object System.Collections.Generic.List[object]
        foreach ($tableLine in $tableLines) {
            if ($tableLine -match '^\|[\s\-|:]+\|$') { continue }
            $cells = @($tableLine.Trim().Trim('|').Split('|') | ForEach-Object { $_.Trim() })
            $rows.Add($cells)
        }
        $body.Add((Table-Xml $rows))
    } elseif ($line -match '^# (.+)$') {
        $body.Add((Paragraph-Xml $Matches[1] 'Title'))
    } elseif ($line -match '^## (.+)$') {
        $body.Add((Paragraph-Xml $Matches[1] 'Heading1'))
    } elseif ($line -match '^### (.+)$') {
        $body.Add((Paragraph-Xml $Matches[1] 'Heading2'))
    } elseif ($line -match '^[-*] (.+)$') {
        $body.Add((Paragraph-Xml "• $($Matches[1])"))
    } elseif ($line -match '^\d+\. (.+)$') {
        $body.Add((Paragraph-Xml $line))
    } elseif ($line -match '^---$') {
        continue
    } else {
        $body.Add((Paragraph-Xml $line))
    }
}

$documentXml = @"
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<w:document xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"><w:body>$($body -join "`n")<w:sectPr><w:pgSz w:w="15840" w:h="12240" w:orient="landscape"/><w:pgMar w:top="900" w:right="720" w:bottom="900" w:left="720"/></w:sectPr></w:body></w:document>
"@
$contentTypes = @"
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types"><Default Extension="rels" ContentType="application/vnd.openxmlformats-package.relationships+xml"/><Default Extension="xml" ContentType="application/xml"/><Override PartName="/word/document.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.document.main+xml"/><Override PartName="/word/styles.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.styles+xml"/></Types>
"@
$rootRels = @"
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships"><Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument" Target="word/document.xml"/></Relationships>
"@
$styles = @"
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<w:styles xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"><w:style w:type="paragraph" w:default="1" w:styleId="Normal"><w:name w:val="Normal"/><w:rPr><w:sz w:val="20"/></w:rPr></w:style><w:style w:type="paragraph" w:styleId="Title"><w:name w:val="Title"/><w:rPr><w:b/><w:color w:val="1F4E78"/><w:sz w:val="36"/></w:rPr></w:style><w:style w:type="paragraph" w:styleId="Heading1"><w:name w:val="heading 1"/><w:rPr><w:b/><w:color w:val="1F4E78"/><w:sz w:val="28"/></w:rPr></w:style><w:style w:type="paragraph" w:styleId="Heading2"><w:name w:val="heading 2"/><w:rPr><w:b/><w:color w:val="2F75B5"/><w:sz w:val="24"/></w:rPr></w:style></w:styles>
"@

$outputFullPath = Join-Path (Get-Location) $OutputPath
if (Test-Path -LiteralPath $outputFullPath) { Remove-Item -LiteralPath $outputFullPath -Force }
$archive = [System.IO.Compression.ZipFile]::Open($outputFullPath, [System.IO.Compression.ZipArchiveMode]::Create)
try {
    foreach ($part in @{
        '[Content_Types].xml' = $contentTypes
        '_rels/.rels' = $rootRels
        'word/document.xml' = $documentXml
        'word/styles.xml' = $styles
    }.GetEnumerator()) {
        $entry = $archive.CreateEntry($part.Key)
        $writer = New-Object System.IO.StreamWriter($entry.Open(), [System.Text.UTF8Encoding]::new($false))
        try { $writer.Write($part.Value) } finally { $writer.Dispose() }
    }
} finally { if ($archive) { $archive.Dispose() } }

Write-Output "Created $outputFullPath"
