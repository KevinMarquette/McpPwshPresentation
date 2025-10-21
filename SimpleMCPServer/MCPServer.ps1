[CmdletBinding()]
param(
    [switch]$Start
)

$ErrorActionPreference = "Stop"
. $PSScriptRoot/tools.ps1

function Out-Log {
    [CmdletBinding()]
    param(
        [string]$Message
    )
    $logFile = "$PSScriptRoot\MCPServer.log"
    Add-Content -Path $logFile -Value "$(Get-Date -Format o) $Message"
}

function Start-McpServer {
    <#
    .SYNOPSIS
        Starts the MCP Server to handle JSON-RPC requests over stdin/stdout.
    #>
    [CmdletBinding()]
    param()
    try{
        Out-Log "MCP Server Started"
        # Main loop to read from stdin and write to stdout
        while($true) {
            $inputLine = [Console]::In.ReadLine()
            Out-Log "Received|$inputLine"
            if( $inputLine -eq "exit" ) { break }

            $response = Invoke-JsonRpcRequest -RequestJson $inputLine
            if( $null -eq $response ) { continue }
            Out-Log "Sending|$response"
            [Console]::Out.WriteLine($response)
        }
    } catch {
        Out-Log "Error|$(Get-Error)"
    }
}
function Invoke-JsonRpcRequest {
    [CmdletBinding()]
    param(
        [string]$RequestJson
    )
    if([string]::IsNullOrWhiteSpace($RequestJson)) {
        return
    }
    $request = $RequestJson | ConvertFrom-Json -Depth 10 -AsHashtable
    try {
        $result = switch ($request.method) {
            "ping" {
                @{}
            }
            "initialize" {
                Get-Content -Path "$PSScriptRoot\initialize.json" -Raw | ConvertFrom-Json -AsHashtable
            }
            "tools/list" {
                Get-Content -Path "$PSScriptRoot\toolslist.json" -Raw | ConvertFrom-Json -AsHashtable
            }
            "tools/call" {
                $splat = @{
                    ToolName  = $request.params.name
                    Arguments = $request.params.arguments
                }
                Write-Verbose "Invoking ToolName: $($splat.ToolName) with Arguments: $($splat.Arguments | Out-String)"
                Invoke-Tool @splat
            }
            {$PSItem -match '^notifications'} {return}
            default {
               throw [System.NotImplementedException]::new("Method [$($request.method)] is not implemented.")
            }
        }
        $resultJson = @{
            jsonrpc = "2.0"
            id      = $request.id
            result  = $result
        } | ConvertTo-Json -Depth 10 -Compress
        return $resultJson
     } catch {
        $errorResponse = @{
            jsonrpc = "2.0"
            id      = $request.id
            error   = @{
                code    = -32603
                message = $_.Exception.Message
            }
        } | ConvertTo-Json -Depth 10 -Compress
        return $errorResponse
     }
}

function Invoke-Tool {
    [CmdletBinding()]
    param(
        [string]$ToolName,
        [hashtable]$Arguments = @{}
    )

    $output = switch ($ToolName) {
        "Get-Weather" {
            Get-Weather @Arguments
        }
        default {
            throw [System.NotImplementedException]::new("Tool [$ToolName] is not implemented.")
        }
    }
    return @{
        content = @(@{
            type = "text"
            text = $output | ConvertTo-Json -Depth 10 -Compress
        })
    }
}

if ($Start) {
    Start-McpServer
}