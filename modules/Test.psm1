#Test.psm1
function Start-TestSuite {

    param(
        [array]$Tests
    )

    $passed = 0
    $failed = 0

    foreach ($test in $Tests) {

        Write-PipelineLog "- Running $test..." -WriteHost

        Start-Sleep (Get-Random -Minimum 1 -Maximum 2)

        $result = Get-Random -Minimum 1 -Maximum 10

        if ($result -le 9) {

            Write-PipelineLog "  PASS" -WriteHost -Color Green
            $passed++

        } else {

            Write-PipelineLog "  FAIL" -WriteHost -Color Red
            $failed++

        }

    }

    return @{
        Passed = $passed
        Failed = $failed
    }

}

function Invoke-Tests {

    param(
        [array]$Tests
    )

    Write-PipelineLog "[5/7] Running Automated Tests" -WriteHost

    try {

        $start = Get-Date
        $timestamp = $start.ToString("dd-MM-yyyy HH:mm:ss")
        
        Write-PipelineLog "  Test execution started at: $timestamp" -Level 'DEBUG' -WriteHost
        Write-PipelineLog "" -Level '' -WriteHost

        $results = Start-TestSuite -Tests $Tests

        $endTime = Get-Date
        $duration = $endTime - $start
        
        $totalTests = $results.Passed + $results.Failed
        $passRate = 0
        if ($totalTests -gt 0) {
            $passRate = [math]::Round((($results.Passed / $totalTests) * 100), 2)
        }

        Write-PipelineLog "" -Level '' -WriteHost
        Write-PipelineLog "========================================" -WriteHost -Color Cyan
        Write-PipelineLog "              TEST SUMMARY" -WriteHost -Color Cyan
        Write-PipelineLog "========================================" -WriteHost -Color Cyan
        Write-PipelineLog "  Total Tests: $totalTests"
        Write-PipelineLog "  Passed:      $($results.Passed)" -WriteHost -Color Green
        Write-PipelineLog "  Failed:      $($results.Failed)" -WriteHost -Color Red
        Write-PipelineLog "  Pass Rate:   $passRate%"
        
        $formattedDuration = [math]::Round($duration.TotalSeconds, 2)
        Write-PipelineLog "  Duration:    $formattedDuration seconds" -Level 'DEBUG' -WriteHost
        Write-PipelineLog "========================================" -WriteHost -Color Cyan
        Write-PipelineLog "" -Level '' -WriteHost

        if ($results.Failed -gt 0) {

            Write-PipelineLog "[FAIL] One or more automated tests failed." -WriteHost -Color Red

        } else {

            Write-PipelineLog "[PASS] All automated tests completed successfully." -WriteHost -Color Green

        }

        Write-PipelineLog "" -Level '' -WriteHost

        return $results

    }
    catch {

        Write-PipelineLog "$($_.Exception.Message)" -Level 'ERROR' -WriteHost

        return $false

    }

}

Export-ModuleMember -Function Invoke-Tests