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
        bool is_sold;
        bool is_verified;
        bytes32[] property_documents;
        bytes32[] property_images;
        address[] past_owners;
    }

    struct UserProfile {
        string full_name;
        bytes32 id_document;
        bool is_verified;
    }

    mapping(uint256 => Property) public properties;
    mapping(address => UserProfile) public user_profiles;
    uint256 public property_id;
    address public contract_owner;

    event PropertyListed(uint256 indexed property_id, address indexed owner, string title, PropertyCategory category, uint256 price);
    event PropertySold(uint256 indexed property_id, address indexed buyer);
    event PropertyVerified(uint256 indexed property_id, bool is_verified);
    event UserVerified(address indexed user, bool is_verified);
    event UserDocumentAdded(address indexed user, bytes32 document);
    event PropertyDocumentAdded(uint256 indexed property_id, bytes32 document);

    constructor() {
        property_id = 1;
        contract_owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == contract_owner, "Only contract owner can perform this action");
        _;
    }

    function listProperty(string memory _title, string memory _description, PropertyCategory _category, uint256 _price, bytes32[] memory _images) external {
        properties[property_id] = Property(property_id, payable(msg.sender), _title, _description, _category, _price, false, false, new bytes32[](0), _images, new address[](0));
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
        property.past_owners.push(msg.sender);

        emit PropertySold(_property_id, msg.sender);
    }

    function verifyProperty(uint256 _property_id, bool _is_verified) external onlyOwner {
        Property storage property = properties[_property_id];
        property.is_verified = _is_verified;
        emit PropertyVerified(_property_id, _is_verified);
    }

    function verifyUser(address _userAddress, bool _is_verified) external onlyOwner {
        UserProfile storage user_profile = user_profiles[_userAddress];
        user_profile.is_verified = _is_verified;
        emit UserVerified(_userAddress, _is_verified);
    }

    function addUserDocument(bytes32 _document) external {
        user_profiles[msg.sender].id_document = _document;
        emit UserDocumentAdded(msg.sender, _document);
    }

    function addPropertyDocument(uint256 _property_id, bytes32 _document) external onlyOwner {
        properties[_property_id].property_documents.push(_document);
        emit PropertyDocumentAdded(_property_id, _document);
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

    function getOwnerDetails(uint256 _property_id) external view returns (address, UserProfile memory) {
        Property storage property = properties[_property_id];
        address current_owner = property.owner;
        UserProfile memory owner_profile = user_profiles[current_owner];
        return (current_owner, owner_profile);
    }
}
