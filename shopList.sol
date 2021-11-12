pragma ton-solidity >=0.35.0;
pragma AbiHeader expire;
pragma AbiHeader pubkey;

import "InterfacesAndStructs.sol";

// This debot implements the business logic
contract ShoppingList is IShoppingList{
    uint256 m_ownerPubkey;
    uint32 public m_purchasesCount;
    
    mapping (uint32 => Purchase) public m_shoppingList;

    constructor(uint256 pubkey) public {
        require(pubkey != 0, 101);
        tvm.accept();
        m_ownerPubkey = pubkey;
    }

    modifier onlyOwner() {
        require(msg.pubkey() == m_ownerPubkey, 102);
        tvm.accept();
        _;
    }

    modifier checkPurchaseExistense(uint32 id) {
        require(m_shoppingList.exists(id), 103);
        _;
    }

    function pushPurchase(string purchaseName, uint32 amount) public onlyOwner override{
        m_purchasesCount++;
        m_shoppingList[m_purchasesCount] = Purchase(m_purchasesCount, purchaseName, amount, now, false, 0);
    }

    function deletePurchase(uint32 purchaseId) public checkPurchaseExistense(purchaseId) onlyOwner override{
        delete m_shoppingList[purchaseId];

        uint32 newPurchaseCount = 0;
        mapping (uint32 => Purchase) newShoppingList;

        for((, Purchase currentPurchase) : m_shoppingList) {
            newPurchaseCount++;
            // Create new shopping list
            newShoppingList[newPurchaseCount] = Purchase(
                newPurchaseCount,
                currentPurchase.name,
                currentPurchase.amount,
                currentPurchase.time,
                currentPurchase.isPaid,
                currentPurchase.price
            );
        }

        m_shoppingList = newShoppingList;
        m_purchasesCount--;
    }

    function buyPurchase(uint32 purchaseId, uint64 fullPrice) public checkPurchaseExistense(purchaseId) onlyOwner override{
        m_shoppingList[purchaseId].isPaid = true;
        m_shoppingList[purchaseId].price = fullPrice;
    }

    // Get methods
    function getPurchases() public view override returns (Purchase[] myPurchases) {
        for ((uint id, Purchase purchase) : m_shoppingList) {
            myPurchases.push(purchase);
        }
    }
    
    function getSummary() external override returns (PurchasesSummary summary) {
        for((uint id, Purchase purchase) : m_shoppingList) {
            if(purchase.isPaid) {
                summary.paidPurchases += purchase.amount;
                summary.spandMoney += purchase.price;
            } else {
                summary.unpaidPurchases += purchase.amount;
            }
        }
    }
}