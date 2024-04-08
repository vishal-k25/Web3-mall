// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

contract Web3mall {
    // State variables
    string public name; // Name of the contract
    address public owner; // Address of the contract owner

    struct Item {
        uint256 id; // Unique identifier for the item
        string name; // Name of the item
        string category; // Category of the item
        string image; // URL or IPFS hash of the item image
        uint256 cost; // Cost of the item in ether
        uint256 rating; // Rating of the item
        uint256 stock; // Available stock of the item
    }

    struct Order {
        uint256 time; // Timestamp of when the order was placed
        Item item; // The ordered item
    }

    // Mappings
    mapping(uint => Item) public items; // Mapping of item ID to Item struct
    mapping(address => uint256) public orderCount; // Mapping of buyer address to the number of orders placed
    mapping(address => mapping(uint256 => Order)) public orders; // Mapping of buyer address and order ID to Order struct

    // Events
    event Buy(address buyer, uint256 orderId, uint256 itemId); // Event emitted when an item is bought
    event List(string name, uint256 cost, uint256 quantity); // Event emitted when an item is listed for sale

    // Modifier to restrict access to the contract owner
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    // Constructor to set the contract owner
    constructor() {
        owner = msg.sender;
    }

    // Function to list a new item for sale
    function list(
        uint256 _id,
        string memory _name,
        string memory _category,
        string memory _image,
        uint256 _cost,
        uint256 _rating,
        uint256 _stock
    ) public onlyOwner {
        //Create Item struct
        Item memory item = Item(
            _id,
            _name,
            _category,
            _image,
            _cost,
            _rating,
            _stock
        );

        //Save to blockchain
        items[_id] = item;

        //Emit an event
        emit List(_name, _cost, _stock);
    }

    // Buy Products
    function buy(uint256 _id) public payable {
        //Fetch item
        Item memory item = items[_id];

        //require enough ether to nuy item
        require(msg.value >= item.cost);

        //require item is in stock
        require(item.stock > 0);

        //Create an order
        Order memory order = Order(block.timestamp, item);

        //Add order to chain
        orderCount[msg.sender]++;
        orders[msg.sender][orderCount[msg.sender]] = order;

        //Subtract stock
        items[_id].stock = item.stock - 1;

        //emit event
        emit Buy(msg.sender, orderCount[msg.sender], item.id);
    }

    //Withdraw funds
    function withdraw() public onlyOwner {
        (bool success, ) = owner.call{value: address(this).balance}("");
        require(success);
    }
}
