# Deletes up to the last 100 workflow runs from the UI history
for RUN_ID in $(gh run list --limit 100 --json databaseId -q '.[].databaseId'); do 
  echo "Deleting Run History: $RUN_ID"
  gh run delete $RUN_ID
done
