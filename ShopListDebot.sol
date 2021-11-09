pragma ton-solidity >=0.35.0;
pragma AbiHeader expire;
pragma AbiHeader time;
pragma AbiHeader pubkey;

// Our contracts and debots
import "ModifierDebot.sol";
import "BuyerDebot.sol";
import "ShownerDebot.sol";

// This is the main debot for user itneraction
contract ShopListDebot is ModifierDebot, BuyerDebot, ShownerDebot{
    // =================================================================================
    function _menu() override(ModifierDebot, BuyerDebot, ShownerDebot) internal{
        string sep = '----------------------------------------';
        Menu.select(
            format(
                "You have {}/{} (paid/unpaid) purchases and you spent {} money",
                    m_summary.paidPurchases,
                    m_summary.unpaidPurchases,
                    m_summary.spandMoney
            ),
            sep,
            [
                MenuItem("Add new purchase","",tvm.functionId(addPurchase)),
                MenuItem("Show all my purchases","",tvm.functionId(showMyShopList)),
                MenuItem("Delete some purchase","",tvm.functionId(deleteSomePurchase)),
                MenuItem("Make purchase","",tvm.functionId(makePurchase))
            ]
        );
    }
}