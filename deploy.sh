az deployment sub create --template-file ./main.bicep --location northeurope  --parameters @demo.parameters.json --name d_$(date +%Y-%m-%d_%H-%M-%S)
