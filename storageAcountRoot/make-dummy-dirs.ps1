# Define the root folder where everything will be created
$rootFolder = ""

# Define the number of top-level folders to create
$topLevelCount = 5

# Define the number of subfolders per top-level folder
$subFolderCount = 3

# Define the number of files to create in each subfolder
$filesPerSubFolder = 2

# Create the root folder if it doesn't exist
if (-not (Test-Path -Path $rootFolder)) {
    New-Item -Path $rootFolder -ItemType Directory
}

# Loop to create top-level folders
for ($i = 1; $i -le $topLevelCount; $i++) {
    # Create a top-level folder
    $topFolder = Join-Path -Path $rootFolder -ChildPath "Folder$i"
    if (-not (Test-Path -Path $topFolder)) {
        New-Item -Path $topFolder -ItemType Directory
    }

    # Loop to create subfolders in the top-level folder
    for ($j = 1; $j -le $subFolderCount; $j++) {
        # Create a subfolder
        $subFolder = Join-Path -Path $topFolder -ChildPath "SubFolder$j"
        if (-not (Test-Path -Path $subFolder)) {
            New-Item -Path $subFolder -ItemType Directory
        }

        # Loop to create {counter}.txt files in the subfolder
        for ($k = 1; $k -le $filesPerSubFolder; $k++) {
            # Create a .txt file with the {counter}.txt format
            $fileName = "$k.txt"
            $filePath = Join-Path -Path $subFolder -ChildPath $fileName
            if (-not (Test-Path -Path $filePath)) {
                New-Item -Path $filePath -ItemType File
            }
        }
    }
}

Write-Host "Folders and files have been created successfully."
