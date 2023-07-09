// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

contract RealEstateApp {
    enum PropertyType { Residential, Commercial }

    struct Property {
        uint256 property_id;
        address payable owner; 
        string title;
        string description;
        PropertyType property_type;
        uint256 price;
        bool is_sold;
    }

    mapping(uint256 => Property) public properties;
    uint256 public property_id;

    event PropertyListed(uint256 indexed property_id, address indexed owner, string title, PropertyType property_type, uint256 price);
    event PropertySold(uint256 indexed property_id, address indexed buyer);

    constructor() {
        property_id = 1;
    }

    function listProperty(string memory _title, string memory _description, PropertyType _property_type, uint256 _price) external {
        properties[property_id] = Property(property_id, payable(msg.sender), _title, _description, _property_type, _price, false); 
        emit PropertyListed(property_id, msg.sender, _title, _property_type, _price);
        property_id++;
    }

    function buyProperty(uint256 _property_id) external payable {
        Property storage property = properties[_property_id];
        require(!property.is_sold, "Property is already sold");
        require(msg.value >= property.price, "Insufficient payment");

        property.owner.transfer(property.price);
        property.owner = payable(msg.sender); 
        property.is_sold = true;

        emit PropertySold(_property_id, msg.sender);
    }

    function getProperty(uint256 _property_id) external view returns (Property memory) {
        return properties[_property_id];
    }
}


/*
// contract MyContract {
//     constructor() {}
// }
*/