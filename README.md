# MCP PowerShell Presentation

Beyond the Prompt: Leveraging MCP and PowerShell for Custom LLM Actions Presentation Materials

## Simple MCP Server Example

The SimpleMCPServer folder is a minimal implementation of a working MCP server (all in one). You can configure it in most clients like this (Might need full path to the script.)

``` json
    "weather": {
      "disabled": false,
      "timeout": 60,
      "type": "stdio",
      "command": "pwsh",
      "args": [
        "-Command",
        "SimpleMCPServer\\MCPServer.ps1",
        "-Start"
      ]
    }
```
