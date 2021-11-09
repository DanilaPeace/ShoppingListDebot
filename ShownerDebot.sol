pragma ton-solidity >=0.35.0;
pragma AbiHeader expire;
pragma AbiHeader time;
pragma AbiHeader pubkey;

// Our contracts and debots
import "AbstractDebot.sol";

// This debot can add, remove purchases to the shopping list and show information about the existing list 
contract ShownerDebot is AbstractDebot {

    function _menu() virtual override internal {}

    // These methods show the existing shopping list
    function showMyShopList(uint8 index) public view {
        optional(uint) none;

        IShoppingList(m_address).getPurchases{
            abiVer: 2,
            extMsg: true,
            sign: false,
            pubkey: none,
            time: uint64(now),
            expire: 0,
            callbackId: tvm.functionId(printMyShopList),
            onErrorId: 0
        }();
    }

    function printMyShopList(Purchase[] myPurchases) public {
        if(!myPurchases.empty()) {
            Terminal.print(0, "Your shopping list:");
            for((Purchase purchase) : myPurchases) {
                string paid;
                if (purchase.isPaid) {
                    paid = ' ✓ ';
                } else {
                    paid = '___';
                }
                Terminal.print(0, format("{} {}  \"{}\" how many: {}", purchase.id, paid, purchase.name, purchase.amount));
            }
        } else {
            Terminal.print(0, "Your shopping list is empty");
        }
        _menu();
    }
}