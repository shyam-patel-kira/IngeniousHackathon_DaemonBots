pragma solidity ^0.5.16; 

import "./SimpleValueTokens.sol";

/* enables the farmers to publish thier products and provides kind of e-commerce functionality */
contract SalesContract {
    /* item being sold will be published by the Farmer */
    struct Item{
        address producer;
        string dateAvailable;
        string productHash;
        uint unitPrice;
    }

    /* Once any consumer places the order */
    struct Order {
        string orderHash; 
        /* All the items on the we are selling thorugh this contracts */         
        mapping(uint => Item) items;
        uint totItems;
        string orderDate;
        uint total;
        string status;
        string shipDate;
    }  
    
    // current order this cntract handles
    Order curOrder ;   

    // just cretaes and initializes the order structure
    function createOrder(string memory orderHash, string memory orderDate, string memory shipDate, uint total) public {
        curOrder.orderDate = orderDate;
        curOrder.orderHash = orderHash;
        curOrder.shipDate = shipDate;
        curOrder.status = "created";
        curOrder.total = total;
        curOrder.totItems = 0;
    }

    // Updates the order info, even delete order uses the same method with status "deleted"
    function updateOrder(string memory orderHash, string memory orderDate, string memory shipDate, string memory status, uint total) public returns (bool){
        // check whether any order exist with given input
        if(keccak256(abi.encodePacked(curOrder.orderHash)) == keccak256(abi.encodePacked(orderHash))) return false; 
        // if the order insitialized exists
        curOrder.orderDate = orderDate;
        curOrder.orderHash = orderHash;
        curOrder.shipDate = shipDate;
        curOrder.status = status; 
        curOrder.total = total;
        return true;
    }

    /* Adds an item to the sales section  */
    function addItem(address producer, string memory dateAvailable, string memory productHash, uint unitPrice) public returns (bool) {
        Item memory strcItem;
        strcItem.producer = producer;
        strcItem.dateAvailable = dateAvailable;
        strcItem.productHash = productHash;
        strcItem.unitPrice = unitPrice;
        curOrder.items[curOrder.totItems++] = strcItem;
        curOrder.total += unitPrice;
        return true;
    }

    // update an item in the order
    function updateItem(address producer, string memory dateAvailable, string memory productHash, uint unitPrice) public returns (bool){
        for (uint i=0; i<curOrder.totItems; i ++) {
            if (keccak256(abi.encodePacked(curOrder.items[i].productHash)) == keccak256(abi.encodePacked(productHash))) {
                curOrder.items[i].producer = producer;
                curOrder.items[i].dateAvailable = dateAvailable;
                curOrder.items[i].productHash = productHash;
                curOrder.total -= curOrder.items[i].unitPrice;
                curOrder.items[i].unitPrice = unitPrice;
                curOrder.total += unitPrice;
                return true;
            }
        }
        return false;
    }

    // deletes an item from the order
    function deleteItem(string memory productHash) public returns (bool) {
         for (uint i=0; i<curOrder.totItems; i++) {
            if (keccak256(abi.encodePacked(curOrder.items[i].productHash)) == keccak256(abi.encodePacked(productHash))) {
                uint itemPrice = curOrder.items[i].unitPrice;
                delete curOrder.items[i]; 
                curOrder.total -= itemPrice;
                return true;
            }
        }
        return false;
    }

    // places the order and momve the tokens to an excrow until consumer receives goods
    function placeOrder(address tokenContractAddress, address receiver, address escrowAcc) public returns (bool) {
        // places the order via an escrow
        SimpleValueTokens tokens = SimpleValueTokens(tokenContractAddress);
		tokens.PayTokens(escrowAcc, curOrder.total);
        return true;
    }

    function confirmShipment (address tokenContractAddress, string memory orderHash, string memory status, address receiver) public returns (bool) {
        if (keccak256(abi.encodePacked(status)) == keccak256 (abi.encodePacked("shipped"))) {
            //TODO Move tokens from escrow to end user
            SimpleValueTokens tokens = SimpleValueTokens(tokenContractAddress);
            tokens.PayTokens(receiver, curOrder.total);
            return true;
        }
        return false;
    }

}
