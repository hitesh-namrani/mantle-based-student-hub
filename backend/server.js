const express = require('express');
const cors = require('cors');
const path = require('path'); 
const app = express();
const port = 3000;

app.use(cors({ origin: '*' }));
app.use(express.json());

// Serve Frontend
app.use(express.static(path.join(__dirname, '../frontend')));

// --- ADMIN AUTHENTICATION ---
app.post('/api/verify-admin', (req, res) => {
    const { password } = req.body;
    const ADMIN_PASSWORD = "admin123"; 
    if (password === ADMIN_PASSWORD) {
        res.json({ success: true });
    } else {
        res.status(401).json({ success: false, message: "Invalid Password" });
    }
});

// --- Updated for Mantle Sepolia ---
const DEPLOYED_CONTRACT_DATA = {
    Events: {
        address: "0xc0C8855A41f74F996f30cc528d9187998940aC5b", 
        abi: [
            { "inputs": [], "name": "admin", "outputs": [{ "internalType": "address", "name": "", "type": "address" }], "stateMutability": "view", "type": "function" },
            // UPDATED: Removed _deadline to match DCH_events.sol 
            { "inputs": [ { "internalType": "string", "name": "_title", "type": "string" }, { "internalType": "string", "name": "_link", "type": "string" }, { "internalType": "uint256", "name": "_eventDate", "type": "uint256" } ], "name": "addEvent", "outputs": [], "stateMutability": "nonpayable", "type": "function" },
            { "inputs": [ { "internalType": "string", "name": "_message", "type": "string" } ], "name": "addFeed", "outputs": [], "stateMutability": "nonpayable", "type": "function" },
            { "inputs": [ { "internalType": "string", "name": "_title", "type": "string" }, { "internalType": "string", "name": "_description", "type": "string" } ], "name": "addNotice", "outputs": [], "stateMutability": "nonpayable", "type": "function" },
            { "inputs": [], "name": "getEvents", "outputs": [ { "components": [ { "internalType": "uint256", "name": "id", "type": "uint256" }, { "internalType": "string", "name": "title", "type": "string" }, { "internalType": "string", "name": "link", "type": "string" }, { "internalType": "uint256", "name": "eventDate", "type": "uint256" } ], "internalType": "struct DCHEvents.EventData[]", "name": "", "type": "tuple[]" } ], "stateMutability": "view", "type": "function" },
            { "inputs": [], "name": "getFeeds", "outputs": [ { "components": [ { "internalType": "uint256", "name": "id", "type": "uint256" }, { "internalType": "string", "name": "message", "type": "string" }, { "internalType": "uint256", "name": "timestamp", "type": "uint256" } ], "internalType": "struct DCHEvents.FeedItem[]", "name": "", "type": "tuple[]" } ], "stateMutability": "view", "type": "function" },
            { "inputs": [], "name": "getNotices", "outputs": [ { "components": [ { "internalType": "uint256", "name": "id", "type": "uint256" }, { "internalType": "string", "name": "title", "type": "string" }, { "internalType": "string", "name": "description", "type": "string" }, { "internalType": "uint256", "name": "timestamp", "type": "uint256" } ], "internalType": "struct DCHEvents.Notice[]", "name": "", "type": "tuple[]" } ], "stateMutability": "view", "type": "function" }
        ]
    },
    Governance: {
        address: "0xd911DB2c6E21054Dcc6Db741f9429b85f651DF4f",
        abi: [
            { "inputs": [ { "internalType": "string", "name": "_description", "type": "string" }, { "internalType": "uint256", "name": "_days", "type": "uint256" } ], "name": "createProposal", "outputs": [ { "internalType": "uint256", "name": "", "type": "uint256" } ], "stateMutability": "nonpayable", "type": "function" },
            { "inputs": [ { "internalType": "uint256", "name": "_id", "type": "uint256" }, { "internalType": "bool", "name": "_support", "type": "bool" } ], "name": "vote", "outputs": [], "stateMutability": "nonpayable", "type": "function" },
            { "inputs": [], "name": "proposalCount", "outputs": [{ "internalType": "uint256", "name": "", "type": "uint256" }], "stateMutability": "view", "type": "function" },
            // Updated outputs to match the DCHGovernance Proposal struct (no mapping)
            { "inputs": [{ "internalType": "uint256", "name": "", "type": "uint256" }], "name": "proposals", "outputs": [{ "internalType": "uint256", "name": "id", "type": "uint256" }, { "internalType": "string", "name": "description", "type": "string" }, { "internalType": "uint256", "name": "deadline", "type": "uint256" }, { "internalType": "uint256", "name": "votesFor", "type": "uint256" }, { "internalType": "uint256", "name": "votesAgainst", "type": "uint256" }, { "internalType": "bool", "name": "executed", "type": "bool" }], "stateMutability": "view", "type": "function" },
            // CHANGED: Last param is 'weight' to match your .sol file exactly
            { "anonymous": false, "inputs": [ { "indexed": true, "internalType": "uint256", "name": "id", "type": "uint256" }, { "indexed": true, "internalType": "address", "name": "voter", "type": "address" }, { "indexed": false, "internalType": "bool", "name": "support", "type": "bool" }, { "indexed": false, "internalType": "uint256", "name": "weight", "type": "uint256" } ], "name": "VoteCast", "type": "event" }
        ]
    },
    Token: {
        address: "0xAfBBA52783dF148F7AF25d14c4D514Be0D2E3925", 
        abi: [
            { "inputs": [ { "internalType": "address", "name": "to", "type": "address" }, { "internalType": "uint256", "name": "amount", "type": "uint256" } ], "name": "mint", "outputs": [], "stateMutability": "nonpayable", "type": "function" },
            { "inputs": [], "name": "claimTokens", "outputs": [], "stateMutability": "nonpayable", "type": "function" },
            { "inputs": [{ "internalType": "address", "name": "account", "type": "address" }], "name": "balanceOf", "outputs": [{ "internalType": "uint256", "name": "", "type": "uint256" }], "stateMutability": "view", "type": "function" }
        ]
    }
};

app.get('/api/contracts', (req, res) => res.json(DEPLOYED_CONTRACT_DATA));

app.get('*', (req, res) => {
    res.sendFile(path.join(__dirname, '../frontend/index.html'));
});

app.listen(port, () => {
    console.log(`Student Hub is LIVE at http://localhost:${port}`);

});