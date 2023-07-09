// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

contract RealEstateApp {
    enum PropertyCategory { Residential, Commercial }

    struct Property {
        uint256 propertyId;
        address payable owner;
        string title;
        string description;
        PropertyCategory category;
        uint256 price;
        bool isSold;
        bool isVerified;
        bytes32[] propertyDocuments;
        bytes32[] propertyImages;
        address[] pastOwners;
    }

    struct UserProfile {
        string fullName;
        bytes32 idDocument;
        bool isVerified;
    }

    mapping(uint256 => Property) public properties;
    mapping(address => UserProfile) public userProfiles;
    uint256 public propertyId;

    event PropertyListed(uint256 indexed propertyId, address indexed owner, string title, PropertyCategory category, uint256 price);
    event PropertySold(uint256 indexed propertyId, address indexed buyer);
    event PropertyVerified(uint256 indexed propertyId, bool isVerified);
    event UserVerified(address indexed user, bool isVerified);
    event UserDocumentAdded(address indexed user, bytes32 document);
    event PropertyDocumentAdded(uint256 indexed propertyId, bytes32 document);

    constructor() {
        propertyId = 1;
    }

    function listProperty(string memory _title, string memory _description, PropertyCategory _category, uint256 _price, bytes32[] memory _images) external {
        properties[propertyId] = Property(propertyId, payable(msg.sender), _title, _description, _category, _price, false, false, new bytes32[](0), _images, new address[](0));
        emit PropertyListed(propertyId, msg.sender, _title, _category, _price);
        propertyId++;
    }

    function buyProperty(uint256 _propertyId) external payable {
        Property storage property = properties[_propertyId];
        require(!property.isSold, "Property is already sold");
        require(msg.value >= property.price, "Insufficient payment");

        payable(property.owner).transfer(property.price);
        property.owner = payable(msg.sender);
        property.isSold = true;
        property.pastOwners.push(msg.sender);

        emit PropertySold(_propertyId, msg.sender);
    }

    function verifyProperty(uint256 _propertyId, bool _isVerified) external {
        Property storage property = properties[_propertyId];
        property.isVerified = _isVerified;
        emit PropertyVerified(_propertyId, _isVerified);
    }

    function verifyUser(address _userAddress, bool _isVerified) external {
        UserProfile storage userProfile = userProfiles[_userAddress];
        userProfile.isVerified = _isVerified;
        emit UserVerified(_userAddress, _isVerified);
    }

    function addUserDocument(bytes32 _document) external {
        userProfiles[msg.sender].idDocument = _document;
        emit UserDocumentAdded(msg.sender, _document);
    }

    function addPropertyDocument(uint256 _propertyId, bytes32 _document) external {
        properties[_propertyId].propertyDocuments.push(_document);
        emit PropertyDocumentAdded(_propertyId, _document);
    }

    function getProperty(uint256 _propertyId) external view returns (Property memory) {
        return properties[_propertyId];
    }

    function getUserProfile(address _userAddress) external view returns (UserProfile memory) {
        return userProfiles[_userAddress];
    }

    function addImages(uint256 _propertyId, bytes32[] memory _images) external {
        Property storage property = properties[_propertyId];
        property.propertyImages = _images;
    }

    function getOwnerDetails(uint256 _propertyId) external view returns (address, UserProfile memory) {
        Property storage property = properties[_propertyId];
        address currentOwner = property.owner;
        UserProfile memory ownerProfile = userProfiles[currentOwner];
        return (currentOwner, ownerProfile);
    }
}
