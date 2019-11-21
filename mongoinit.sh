    envarray=( production qa)
for ((i=0;i<${#envarray[@]};i++)); do
    export env="${envarray[i]}"
    helm install stable/mongodb  --namespace $env --name mongodb-$env --set persistence.enabled=false
done
