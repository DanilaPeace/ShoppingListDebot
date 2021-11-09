pragma ton-solidity >=0.35.0;
pragma AbiHeader expire;
pragma AbiHeader time;
pragma AbiHeader pubkey;

// Our contracts and debots
import "AbsDebot.sol";

// This debot makes purchses
contract DoShoppingDebot is AbsDebot {
    uint32 m_purchaseId; // Money for making of purchase

    function _menu() virtual override internal {}

    // This methods for making purchases
    function makePurchase() public {
        if(m_summary.unpaidPurchases > 0) {
            Terminal.input(tvm.functionId(setPurchaseId), "Enter purchase id you want to buy", false);
        } else {
            Terminal.print(0, "You paid all the purchases");
            _menu();
        }
    }

    function setPurchaseId(string value) public {
        (uint purchaseId, bool status) = stoi(value);

        if(status) {
            m_purchaseId = uint32(purchaseId);
            Terminal.input(tvm.functionId(callBuyPurchase), "Enter how mach money you spent", false);

        } else {
            Terminal.print(0, "Ooops! Sorry, Id must be integer!");
            makePurchase();
        }
    }

    function callBuyPurchase(string value) public {
        (uint money, bool status) = stoi(value);

        if(status) {
            optional(uint) pubkey = 0;
            IShoppingList(m_address).buyPurchase{
                abiVer: 2,
                extMsg: true,
                sign: true,
                pubkey: pubkey,
                time: uint64(now),
                expire: 0,
                callbackId: tvm.functionId(onSuccess),
                onErrorId: tvm.functionId(onError)
            }(m_purchaseId, uint64(money));
        } else {
            Terminal.print(0, "Ooops! Sorry, money must be integer!");
            makePurchase();
        }
    }
}