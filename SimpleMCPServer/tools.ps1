function Get-Weather {
    [CmdletBinding()]
    param(
        [string]$Location
    )

    # Mock weather data for demonstration purposes (API Call would go here)
    $weatherData = @{
        Location = $Location
        TemperatureCelsius = Get-Random -Minimum 15 -Maximum 30
        Condition = "Partly Cloudy, with a chance of meatballs"
        HumidityPercent = Get-Random -Minimum 40 -Maximum 80
    }

    return $weatherData
}
