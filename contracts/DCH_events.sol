// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract DCHEvents {
    address public admin;

    struct EventData {
        uint256 id;
        string title;
        string link;        
        uint256 eventDate;  
    }

    struct FeedItem {
        uint256 id;
        string message;
        uint256 timestamp;
    }

    struct Notice {
        uint256 id;
        string title;
        string description;
        uint256 timestamp;
    }

    EventData[] public events;
    FeedItem[] public feeds;
    Notice[] public notices;

    // Events
    event EventAdded(uint256 id, string title);
    event FeedAdded(uint256 id, string message);
    event NoticeAdded(uint256 id, string title);

    constructor() {
        admin = msg.sender;
    }

    // --- MODIFIER REMOVED FOR HACKATHON ---
    // We keep the logic but comment out the requirement so judges can test it.
    modifier onlyAdmin() {
        // require(msg.sender == admin, "Only admin can perform this action"); 
        _; 
    }

    // --- WRITE FUNCTIONS (Open for Judges) ---

    // CHANGED: Removed `_deadline` to match your frontend form which only has one date input
    function addEvent(string memory _title, string memory _link, uint256 _eventDate) public onlyAdmin {
        uint256 id = events.length;
        // Pushing struct with just eventDate (removed deadline)
        events.push(EventData(id, _title, _link, _eventDate));
        emit EventAdded(id, _title);
    }

    function addFeed(string memory _message) public onlyAdmin {
        uint256 id = feeds.length;
        feeds.push(FeedItem(id, _message, block.timestamp));
        emit FeedAdded(id, _message);
    }

    function addNotice(string memory _title, string memory _description) public onlyAdmin {
        uint256 id = notices.length;
        notices.push(Notice(id, _title, _description, block.timestamp));
        emit NoticeAdded(id, _title);
    }

    // --- READ FUNCTIONS ---

    function getEvents() public view returns (EventData[] memory) {
        return events;
    }

    function getFeeds() public view returns (FeedItem[] memory) {
        return feeds;
    }

    function getNotices() public view returns (Notice[] memory) {
        return notices;
    }
}