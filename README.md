# Follow the next steps to create your debot. Run the following commands 

## First you need to prepare some files.
This command returns you `ShopListDebot.abi.json` file in hex format. We'll need it when calliing the setABI function. It's mandatory.
```shell 
cat ShopListDebot.abi.json | xxd -ps -c 20000
```
Put the output of this function in the `dabi.json` file. And make the following json format `{"dabi":"output of the previous command"}`

---
This command returns the information about your `shopList.sol` contract wich needed for creating the initial state your shopping list
```shell 
tonos decode stateinit shopList.tvc --tvc 
```
Put the output of this function in the `code.json` file.

---
## Automatic way with bash script
1. You need to prepare the `code.file` as above
2. Just run the `localDebot.sh` bash script

## Commands for deploying and running debot manually
1. 
```
tonos genaddr ShopListDebot.tvc --genkey debot.keys.json ShopListDebot.abi.json > log.log
``` 
This command generates key pair for your debot to the `debot.keys.json` file and puts information about it to the `log.log` file.

2. 
```
tonos -u http://localhost call 0:b5e9240fc2d2f1ff8cbb1d1dee7fb7cae155e5f6320e585fcc685698994a19a5 --abi giver.abi.json --sign giver.keys.json sendTransaction '{"dest":"<address>","value":10000000000,"bounce":false}'
``` 
This command sends tokens to address <address> from the `log.log` file in the `Raw address: 0:...` field.
3. 
```
tonos -u http://localhost deploy ShopListDebot.tvc "{}" --sign debot.keys.json --abi ShopListDebot.abi.json
```
This command just deploys your debot.
4. 
```
tonos -u http://localhost call <address> setABI dabi.json --abi ShopListDebot.abi.json --sign debot.keys.json
```
This function calls the required `setABI` function for debot.
5. 
```
tonos -u http://localhost call <address> setCode code.json --abi ShopListDebot.abi.json --sign debot.keys.json
```
This command sets initial state for your debot.

## Run debot
```
tonos -u http://localhost debot fetch <address>
```