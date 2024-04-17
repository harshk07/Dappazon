// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

contract Dappazon {
    address public owner;

    constructor() {
        owner = msg.sender;
    }

    struct Item {
        uint256 id;
        string name;
        string category;
        string image;
        uint256 cost;
        uint256 rating;
        uint256 stock;
    }

    struct Order {
        uint256 time;
        Item item;
    }

    mapping(uint256 => Item) public items;
    mapping(address => uint256) public orderCount; //counts total orders of a wallet address/user
    mapping(address => mapping(uint256 => Order)) public orders; //maps the order number with orders which ultimately maps the order of a single user/wallet address.

    event List(string name, uint256 cost, uint256 quantity);
    event Buy(address buyer, uint256 orderId, uint256 quantity);

    modifier onlyOnwer() {
        require(msg.sender == owner);
        _;
    }

    //List the products

    function list(
        uint256 _id,
        string memory _name,
        string memory _categroy,
        string memory _image,
        uint256 _cost,
        uint256 _rating,
        uint256 _stock
    ) public onlyOnwer {
        //Create item struct
        Item memory item = Item(
            _id,
            _name,
            _categroy,
            _image,
            _cost,
            _rating,
            _stock
        );

        //save the item to the blockchain

        items[_id] = item;

        //emit an event
        emit List(_name, _cost, _stock);

        //buy item
    }

    function buy(uint256 _id) public payable {
        //Recieve crypto

        //Fetch items
        Item memory item = items[_id];
        //Create an order
        require(msg.value >= item.cost);

        require(item.stock >= 0, "Item out of stock");

        Order memory order = Order(block.timestamp, item);

        //Add order for user
        orderCount[msg.sender]++;
        orders[msg.sender][orderCount[msg.sender]] = order; //for example - orderCount[msg.sender] become 1 from 0 after++
        // then this become - orders[msg.sender][1] = order

        //Substract the stock
        items[_id].stock = item.stock - 1;

        //Emit event
        emit Buy(msg.sender, orderCount[msg.sender], item.id);
    }

    function withdraw() public onlyOnwer {
        (bool success, ) = owner.call{value: address(this).balance}("");
        require(success);
    }
}
