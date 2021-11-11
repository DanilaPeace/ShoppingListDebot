pragma ton-solidity >=0.35.0;
pragma AbiHeader expire;
pragma AbiHeader time;
pragma AbiHeader pubkey;

// Our contracts and debots
import "AbstractDebot.sol";

// This debot can add, remove purchases to the shopping list and show information about the existing list 
contract ModifierDebot is AbstractDebot {
    string m_purchaseName;

    function _menu() virtual override internal {}

    // This methods add purchases to the shopping list
    function addPurchase(uint32 index) public{
        Terminal.input(tvm.functionId(setPurchaseName), "Enter purchase name: ", false);
    }

    function setPurchaseName(string value) public{
        m_purchaseName = value;

        Terminal.input(tvm.functionId(setPurchaseAmount), "Enter purchase amount: ", false);
    }

    function setPurchaseAmount(string value) public {
        (uint purchaseAmount, bool status) = stoi(value);

        if(status) {
            callAddPurchase(uint32(purchaseAmount));
        } else {
            Terminal.print(0, "Ooops! Sorry, amount must be integer!");
            addPurchase(1);
        }

    }

    function callAddPurchase(uint32 purchaseAmount) public view {
        optional(uint256) pubkey = 0;

        IShoppingList(m_address).pushPurchase{
                abiVer: 2,
                extMsg: true,
                sign: true,
                pubkey: pubkey,
                time: uint64(now),
                expire: 0,
                callbackId: tvm.functionId(onSuccess),
                onErrorId: tvm.functionId(onError)
        }(m_purchaseName, purchaseAmount);
    }

    // These methods remove some purchase
    function deleteSomePurchase() public {
        if (m_summary.unpaidPurchases + m_summary.paidPurchases > 0) {
            Terminal.input(tvm.functionId(deleteSomePurchase_), "Enter purchase id you want to delete: ", false);
        } else {
            Terminal.print(0, "Sorry, you deleted all the purchases or your shopping list is empty");
            _menu();
        }
    }

    function deleteSomePurchase_(string value) public{
        (uint id, bool status) = stoi(value);

        if(status) {
            optional(uint256) pubkey = 0;
            IShoppingList(m_address).deletePurchase{
                abiVer: 2,
                extMsg: true,
                sign: true,
                pubkey: pubkey,
                time: uint64(now),
                expire: 0, 
                callbackId: tvm.functionId(onSuccess),
                onErrorId: tvm.functionId(onError)
            }(uint32(id));
        } else {
            Terminal.print(0, "Ooops! Sorry, id must be integer!");
            deleteSomePurchase();
        }
    }
}