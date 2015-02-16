## Parameters
#   platform: WindowsStore | WindowsPhone | WindowsUniversal
#   projectPath: in relation to the script path
#   outputPath: in relation to the project path
#   unityPath: absolute path to Unity.exe

[string]$platform=$args[0]
[string]$projectPath="$PSScriptRoot\"+$args[1]
[string]$outputPath=$args[2]
[string]$unityPath=$args[3]


if(Test-Path $projectPath\logs)
{
 rmdir $projectPath\logs -Force -Recurse | Out-Null
}
mkdir $projectPath\logs | Out-Null

Try 
{

if(!(Test-Path "$unityPath"))
{
   throw "Unity executable was not found at $unityPath"
}

$methodName = "Assets.Editor.MarkerMetro.MarkerMetroBuilder."

Switch ($platform)
{
	"WindowsStore" 
	{
		$methodName += "BuildMetro"
		$displayName = "Windows Store"
		$buildTarget = "Metro"
	}
	
	"WindowsPhone"
	{
		$methodName += "BuildWP8"
		$displayName = "Windows Phone"
		$buildTarget = "WP8"
	}
	
	"WindowsUniversal"
	{
		$methodName += "BuildUniversal"
		$displayName = "Windows Universal 8.1"	
		$buildTarget = "Metro"			
	}
}

& "$unityPath" -buildTarget $buildTarget -projectPath $projectPath -batchmode -quit -logFile $projectPath\logs\$methodName.log -executeMethod $methodName -CustomArgs:outputPath=$outputPath | Out-Null

$result = $?

Get-Content $projectPath\logs\$methodName.log | Out-Default

if(!((Get-Content $projectPath\logs\$methodName.log -Tail 10).Contains("Exiting batchmode successfully now!"))){
	throw "Batch Mode did not complete successfully"
}

if(!$result){
  Write-Host "##teamcity[message text='$displayName Player build failed' errorDetails='The process exited with a non-zero exit code. Check the logs for details' status='FAILURE']"
}

if(!$result){
  throw "$displayName Player Build Failed"
}
}
Finally {
Write-Host "##teamcity[blockClosed name='Building $displayName Player Build']"
}