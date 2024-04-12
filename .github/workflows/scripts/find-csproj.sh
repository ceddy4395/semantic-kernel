csproj_files=()
exclude_files=("Planners.Core.csproj" "Planners.Core.UnitTests.csproj" "Experimental.Orchestration.Flow.csproj" "Experimental.Orchestration.Flow.UnitTests.csproj" "Experimental.Orchestration.Flow.IntegrationTests.csproj")  
if [[ ${{ steps.changed-files.outcome }} == 'success' ]]; then
for file in ${{ steps.changed-files.outputs.added_modified }}; do
    echo "$file was changed"
    dir="./$file"
    while [[ $dir != "." && $dir != "/" && $dir != $GITHUB_WORKSPACE ]]; do
    if find "$dir" -maxdepth 1 -name "*.csproj" -print -quit | grep -q .; then
        csproj_path="$(find "$dir" -maxdepth 1 -name "*.csproj" -print -quit)"
        if [[ ! "${exclude_files[@]}" =~ "${csproj_path##*/}" ]]; then
        csproj_files+=("$csproj_path")
        fi
        break
    fi

    dir=$(echo ${dir%/*})
    done
done
else
# if the changed-files step failed, run dotnet on the whole sln instead of specific projects
csproj_files=$(find ./ -type f -name "*.sln" | tr '\n' ' ');
fi
csproj_files=($(printf "%s\n" "${csproj_files[@]}" | sort -u))
echo "Found ${#csproj_files[@]} unique csproj/sln files: ${csproj_files[*]}"
echo "::set-output name=csproj_files::${csproj_files[*]}"