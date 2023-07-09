// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

contract RealEstateApp {
    enum PropertyCategory { Residential, Commercial }

    struct Property {
        uint256 property_id;
        address payable owner;
        string title;
        string description;
        PropertyCategory category;
        uint256 price;
        uint256 area;
        bool is_sold;
        bytes32[] property_images;
        Ownership[] past_owners;
    }

    struct Ownership {
        address owner;
        uint256 duration;
    }

    struct UserProfile {
        string full_name;
        string phone_number;
        string email;
    }

    mapping(uint256 => Property) public properties;
    mapping(address => UserProfile) public user_profiles;
    uint256 public property_id;
    address public contract_owner;

    event PropertyListed(uint256 indexed property_id, address indexed owner, string title, PropertyCategory category, uint256 price);
    event PropertySold(uint256 indexed property_id, address indexed buyer);

    constructor() {
        property_id = 1;
        contract_owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == contract_owner, "Only contract owner can perform this action");
        _;
    }

    function listProperty(string memory _title, string memory _description, PropertyCategory _category, uint256 _price, uint256 _area, bytes32[] memory _images) external {
        properties[property_id] = Property(property_id, payable(msg.sender), _title, _description, _category, _price, _area, false, _images, new Ownership[](0));
        emit PropertyListed(property_id, msg.sender, _title, _category, _price);
        property_id++;
    }

    function buyProperty(uint256 _property_id) external payable {
        Property storage property = properties[_property_id];
        require(!property.is_sold, "Property is already sold");
        require(msg.value >= property.price, "Insufficient payment");

        payable(property.owner).transfer(property.price);
        property.owner = payable(msg.sender);
        property.is_sold = true;
        property.past_owners.push(Ownership(msg.sender, block.timestamp));

        emit PropertySold(_property_id, msg.sender);
    }

    function getProperty(uint256 _property_id) external view returns (Property memory) {
        return properties[_property_id];
    }

    function getUserProfile(address _userAddress) external view returns (UserProfile memory) {
        return user_profiles[_userAddress];
    }

    function addImages(uint256 _property_id, bytes32[] memory _images) external {
        Property storage property = properties[_property_id];
        property.property_images = _images;
    }

    function getOwnerDetails(uint256 _property_id) external view returns (address, uint256, Ownership[] memory) {
        Property storage property = properties[_property_id];
        address current_owner = property.owner;
        Ownership[] memory past_owners = property.past_owners;
        return (current_owner, property.area, past_owners);
    }

    function updateUserProfile(string memory _phone_number, string memory _email) external {
        UserProfile storage user_profile = user_profiles[msg.sender];
        user_profile.phone_number = _phone_number;
        user_profile.email = _email;
    }

    function getUnsoldProperties() external view returns (Property[] memory) {
        uint256 unsoldCount = 0;
        for (uint256 i = 1; i < property_id; i++) {
            if (!properties[i].is_sold) {
                unsoldCount++;
            }
        }

        Property[] memory unsoldProperties = new Property[](unsoldCount);
        uint256 currentIndex = 0;

        for (uint256 i = 1; i < property_id; i++) {
            if (!properties[i].is_sold) {
                unsoldProperties[currentIndex] = properties[i];
                currentIndex++;
            }
        }

        return unsoldProperties;
    }

    function getPropertiesByOwner(address _userAddress) external view returns (Property[] memory) {
    uint256 propertyCount = 0;
    for (uint256 i = 1; i < property_id; i++) {
        if (properties[i].owner == _userAddress) {
            propertyCount++;
        }
    }

    Property[] memory userProperties = new Property[](propertyCount);
    uint256 currentIndex = 0;

    for (uint256 i = 1; i < property_id; i++) {
        if (properties[i].owner == _userAddress) {
            userProperties[currentIndex] = properties[i];
            currentIndex++;
        }
    }

    return userProperties;
}

}
