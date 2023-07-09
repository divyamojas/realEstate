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
        string property_images;
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

    function listProperty(string memory _title, string memory _description, PropertyCategory _category, uint256 _price, uint256 _area, string memory _images) external {
        properties[property_id] = Property(property_id, payable(msg.sender), _title, _description, _category, _price, _area, false, _images);
        emit PropertyListed(property_id, msg.sender, _title, _category, _price);
        property_id++;
    }

    function buyProperty(uint256 _property_id) external payable {
        Property storage property = properties[_property_id];
        require(!property.is_sold, "Property is already sold");
        require(msg.value >= property.price, "Insufficient payment");

        property.owner.transfer(property.price);  // Transfer the payment to the property owner
        property.owner = payable(msg.sender);
        property.is_sold = true;

        emit PropertySold(_property_id, msg.sender);
    }


    function getProperty(uint256 _property_id) external view returns (Property memory) {
        return properties[_property_id];
    }

    function getUserProfile(address _userAddress) external view returns (UserProfile memory) {
        return user_profiles[_userAddress];
    }

    function addImages(uint256 _property_id, string memory _images) external {
        Property storage property = properties[_property_id];
        property.property_images = _images;
    }

    function getOwnerDetails(uint256 _property_id) external view returns (address, uint256) {
        Property storage property = properties[_property_id];
        address current_owner = property.owner;
        return (current_owner, property.area);
    }

    function updateUserProfile(string memory _phone_number, string memory _email) external {
        UserProfile storage user_profile = user_profiles[msg.sender];
        user_profile.phone_number = _phone_number;
        user_profile.email = _email;
    }

    function getPropertiesByOwner(address _userAddress) external view returns (Property[] memory, Property[] memory, Property[] memory) {
        uint256 unsoldCount = 0;
        uint256 soldCount = 0;
        uint256 boughtCount = 0;

        for (uint256 i = 1; i < property_id; i++) {
            Property storage property = properties[i];
            if (property.owner == _userAddress) {
                if (!property.is_sold) {
                    unsoldCount++;
                } else {
                    soldCount++;
                }
            }
            if (msg.sender == property.owner && property.is_sold) {
                boughtCount++;
            }
        }

        Property[] memory unsoldProperties = new Property[](unsoldCount);
        Property[] memory soldProperties = new Property[](soldCount);
        Property[] memory boughtProperties = new Property[](boughtCount);

        uint256 unsoldIndex = 0;
        uint256 soldIndex = 0;
        uint256 boughtIndex = 0;

        for (uint256 i = 1; i < property_id; i++) {
            Property storage property = properties[i];
            if (property.owner == _userAddress) {
                if (!property.is_sold) {
                    unsoldProperties[unsoldIndex] = property;
                    unsoldIndex++;
                } else {
                    soldProperties[soldIndex] = property;
                    soldIndex++;
                }
            }
            if (msg.sender == property.owner && property.is_sold) {
                boughtProperties[boughtIndex] = property;
                boughtIndex++;
            }
        }

        return (unsoldProperties, soldProperties, boughtProperties);
    }

    function getUnsoldPropertiesExceptCurrentUser() external view returns (Property[] memory) {
        uint256 unsoldCount = 0;
        address currentUser = msg.sender;

        for (uint256 i = 1; i < property_id; i++) {
            if (!properties[i].is_sold && properties[i].owner != currentUser) {
                unsoldCount++;
            }
        }

        Property[] memory unsoldProperties = new Property[](unsoldCount);
        uint256 currentIndex = 0;

        for (uint256 i = 1; i < property_id; i++) {
            if (!properties[i].is_sold && properties[i].owner != currentUser) {
                unsoldProperties[currentIndex] = properties[i];
                currentIndex++;
            }   
        }   

        return unsoldProperties;
    }

    function withdrawFunds() external onlyOwner {
        uint256 contractBalance = address(this).balance;
        payable(contract_owner).transfer(contractBalance);
    }

}
