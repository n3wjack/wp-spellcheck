# todo
# - list words found

[CmdletBinding()]
param (
    $WpExportFile
    )

function Run-SpellCheck ($WpExportFile)
{
    [xml]$xml = get-content $WpExportFile
    $posts = $xml.rss.channel.GetElementsByTagName("item") | select -first 100
    
    if ($posts -eq $null)
    {
        Write-Error "No posts to process."
    }

    if ($posts.Count -eq $null)
    {
       Write-Verbose "Only 1 post found to process."
       $totalCount = 1
    }
    else
    {
        $totalCount = $posts.Count
    }

    $results = $posts `
        | SpellCheckPost `
        | ProgressUpdate $totalCount 'Spell checking' `
        | AggregateResults $totalCount

    Write-Verbose "Sorting results by page count..."
    $results = $results | Sort -Property PageCount -Descending
    Write-Verbose "Done sorting."
    
    # Write result as JSON.
    $s = "spellcheckdata = " + (ConvertTo-Json -inputobject $results -depth 3)

    $s | set-content .\spellcheckdata.js

    # Launch the html page to see the data.
    ii .\results.html
}

function ProgressUpdate ($totalCount, $statusMessage)
{
    begin
    {
        $count = 0
    }

    process
    {
        $count++
        $percent = ($count / $totalCount) * 100
        Write-Progress -activity "Spellchecking posts..." -status $statusMessage -PercentComplete $percent
        # Pass the object through the pipeline.
        $_
    }
}

function SpellCheckPost
# Spell check a single post.
{
    param (
        [Parameter(ValueFromPipelineByPropertyName=$true)]
        [Alias("post_id")]
        $postId,
        [Parameter(ValueFromPipelineByPropertyName=$true)]
        $link,
        [Parameter(ValueFromPipelineByPropertyName=$true)]
        $encoded
    )
    
    process 
    {
        Write-Verbose "Spell checking post with Id $postId ($link)"
        $content = $encoded."#cdata-section"
        $words = Hunspell -Text $content -SpellCheck

        # Avoid passing null values through the pipeline as this breaks things.
        if ($words -eq $null)
        {
            $words = @()
        }

        write-verbose "Misspelled words: $words"

        $result = @{ Id = $postId; Link = $link; Words = $words}
        # Return the hash table as an object.
        New-Object PSObject -Property $result
    }
}

function AggregateResults
{
    param (
        [Parameter(ValueFromPipelineByPropertyName=$true)]
        $Id,
        [Parameter(ValueFromPipelineByPropertyName=$true)]
        $Words
    )

    begin 
    {
        $result = @{}
    }

    process 
    {
        foreach ($word in $Words)
        {
            # Check if this word is already in the results.
            $wordCount = $result[$word]
            if ($wordCount -eq $null)
            {
                # Create a new word result object.
                $wordCount = `
                    New-Object PSObject -Property `
                    @{ Word = $word; PageCount = 0; Pages = @(); Suggestions = @()}
                
                $result[$word] = $wordCount
            }

            $wordCount.Pages += $_
            $wordCount.PageCount++
            $wordCount.Suggestions = Hunspell -Text $wordCount.Word -Suggestions
            write-verbose "Aggregation for word: $word : count = $($wordCount.PageCount)"
        }
    }

    end 
    {
        $result.Keys | % { $result[$_] }
    }
}

function Hunspell
{
    param (
        $Text,
        [Switch]
        $SpellCheck=$true,
        [Switch]
        $Suggestions
    )

    $hunspell = "c:\tools\hunspell\bin\hunspell.exe"
    if ($SpellCheck)
    {
        $words = $text | & $hunspell -H -l -d en_US | select -unique
    }
    
    if ($Suggestions)
    {
        #Write-Verbose "Suggesting for $text."

        $words = `
            $text | & $hunspell -a `
            | select-string "& $text" `
            | % { $_.Line.Split(":")[1].Split(",") } `
            | % { $_.Trim() }

        #Write-Verbose "Result: $words"
    }

    $words
}

Run-SpellCheck $WpExportFile

