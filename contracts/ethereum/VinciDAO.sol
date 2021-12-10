// SPDX-License-Identifier: MIT
pragma solidity 0.6.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract VinciDAO is ERC20 {

    // Address of the contract creator
    address creator; 
    // Address of the contract admin
    mapping(address => bool) admins;
    // the uid of the mandate
    uint256 mandate;

    // Addresses of the contract's participants
    mapping(address => bool) participants;
    // Addresses of the contract's participants that already minted tokens
    mapping(address => bool) minted;
    // Addresses of the contract's acceptances votes
    mapping(address => address[]) votes;
    // Participants of the current mandate
    mapping(address => uint256) mandates;

    // Number of votes
    struct Proposal {
        address proposer;
        address[] approve;
        address[] reject;
        uint256 blockNumber;
        uint256 length;
        uint256 mandate; // the uid of the mandate (0 for all mandates)
    }
    mapping(string => address[]) proposalsVoting; // string corresponds to the proposal's hash (includes a block timestamp)
    // Event for new proposal creation
    event NewProposal(address proposer, string proposal, string proposalHash, uint256 blockNumber, uint256 length, uint256 mandate);

    // Supply of tokens for each mandate
    mapping(uint256 => uint256) mandateSupply;

    // Event that accepts a new participant
    event NewParticipant(address participant);

    constructor(address admin1, address admin2, address admin3) ERC20("VinciDAO", "vDAO") {
        creator = msg.sender;
        // initialize mandate
        mandate = 1;
        // initialize admins
        admins[admin1] = true;
        admins[admin2] = true;
        admins[admin3] = true;
        // Add admins to current participants
        _finalizeIncludeInClass(admin1);
        _finalizeIncludeInClass(admin2);
        _finalizeIncludeInClass(admin3);
    }

    function enterClass() public  onlyParticipants {
        require(!minted[msg.sender], "You have already entered this class");
        minted[msg.sender] = true;
        _mint(msg.sender, amount);
    }

    function includeInClass(address _participant) public onlyAdmins {
        require(!participants[_participant], "Participant already included in the class");
        // Requires that this admin didn't already voted for this participant
        require(!addressListIncludes(votes[_participant], msg.sender), "You already voted for this participant");
        if (votes[_participant].length == 2) {
            _finalizeIncludeInClass(_participant);
        } else {
            votes[_participant].push(msg.sender);
        }
    }

    function _afterTokenTransfer(address _from, address _to, uint256 _value) internal override {
        if (_from == address(0)) {
            mandates[_to] += _value;
        }
        else if (mandates[_from] != mandates[_to]) {
            mandateSupply[_from] -= _value;
            mandateSupply[_to] += _value;
        }
    }

    function _finalizeIncludeInClass(address _participant) internal onlyAdmins {
        require(!isParticipant(_participant), "Participant already included in the class");
        participants[_participant] = true;
        mandates[_participant] = mandate;
        emit NewParticipant(_participant);
    }

    // Voting system
    function createProposal(string calldata proposal, uint256 _mandate) external onlyParticipants {
        uint256 current_height = block.number;
        string memory proposalHash = sha256(proposal);
        // TODO : finnish this
    }

    function isAdmin(address _admin) public view returns (bool) {
        return admins[_admin];
    }

    function isParticipant(address _participant) public view returns (bool) {
        return participants[_participant];
    }

    function currentMandate() public view returns (uint256) {
        return mandate;
    }

    modifier onlyAdmins {
        require(isAdmin(msg.sender);, "Only admin can call this function");
        _;
    }

    modifier onlyParticipants {
        require(isParticipant(msg.sender), "Only participants can call this function");
        _;
    }

    function addressListIncludes(address[] _list, address _address) public view returns (bool) {
        for (uint i = 0; i < _list.length; i++) {
            if (_list[i] == _address) {
                return true;
            }
        }
        return false;
    }
}