pragma solidity >=0.5.0;
// pragma solidity ^0.5.0;
pragma experimental ABIEncoderV2;

import "./IERC165.sol";
import "./SafeMath.sol";
import "./IERC1155TokenReceiver.sol";
import "./IERC1155.sol";

/**
 * @dev Implementation of Multi-Token Standard contract.
 */
contract ERC1155 is IERC165 {
    using SafeMath for uint256;

    /***********************************|
  |        Variables and Events       |
  |__________________________________*/

    // onReceive function signatures
    bytes4 public constant ERC1155_RECEIVED_VALUE = 0xf23a6e61;
    bytes4 public constant ERC1155_BATCH_RECEIVED_VALUE = 0xbc197c81;

    // Objects balances
    mapping(address => mapping(uint256 => uint256)) internal balances;

    // Operator Functions
    mapping(address => mapping(address => bool)) internal operators;

    // Events
    event TransferSingle(
        address indexed _operator,
        address indexed _from,
        address indexed _to,
        uint256 _id,
        uint256 _value
    );
    event TransferBatch(
        address indexed _operator,
        address indexed _from,
        address indexed _to,
        uint256[] _ids,
        uint256[] _values
    );
    event ApprovalForAll(
        address indexed _owner,
        address indexed _operator,
        bool _approved
    );

    /***********************************|
  |     Public Transfer Functions     |
  |__________________________________*/

    /**
     * @dev Allow _from or an operator to transfer tokens from one address to another
     * @param _from The address which you want to send tokens from
     * @param _to The address which you want to transfer to
     * @param _id Token id to update balance of - For this implementation, via `uint256(tokenAddress)`.
     * @param _value The amount of tokens of provided token ID to be transferred
     * @param _data Data to pass to onERC1155Received() function if recipient is contract
     */
    /**
     * @natural_language
     * @description After the safeTransferFrom operation, the recipient address (_to) is not the zero address. The msg.sender is an approved operator for the token holder (_from) or the token holder is the same as the msg.sender. The balance of the specified token (_id) for the sender (_from) is greater than or equal to the transferred value (_value). The balance of the specified token for the sender decreases by the transferred value, and the balance of the specified token for the recipient increases by the transferred value. A TransferSingle event is emitted upon successful transfer.
     * @param _from The address of the token holder transferring the tokens
     * @param _to The address of the recipient
     * @param _id The ID of the token being transferred
     * @param _value The number of tokens to transfer
     * @param _data Additional data passed with the transfer
     * @event TransferSingle Emitted when the safeTransferFrom operation is executed
     */
    /// @notice postcondition _to != address(0)
    /// @notice postcondition operators[_from][msg.sender] || _from == msg.sender
    /// @notice postcondition __verifier_old_uint ( balances[_from][_id] ) >= _value
    /// @notice postcondition balances[_from][_id] == __verifier_old_uint ( balances[_from][_id] ) - _value
    /// @notice postcondition balances[_to][_id] == __verifier_old_uint ( balances[_to][_id] ) + _value
    /// @notice emits TransferSingle
    function safeTransferFrom(
        address _from,
        address _to,
        uint256 _id,
        uint256 _value,
        bytes memory _data
    ) public {
        require(
            (msg.sender == _from) || operators[_from][msg.sender],
            "INVALID_OPERATOR"
        );
        require(_to != address(0), "INVALID_RECIPIENT");
        // require(_value >= balances[_from][_id]) is not necessary since checked with safemath operations

        _safeTransferFrom(_from, _to, _id, _value, _data);
    }

    /**
     * @dev transfer objects from different ids to specified address
     * @param _from The address to batchTransfer objects from.
     * @param _to The address to batchTransfer objects to.
     * @param _ids Array of ids to update balance of - For this implementation, via `uint256(tokenAddress)`
     * @param _values Array of amount of object per id to be transferred.
     * @param _data Data to pass to onERC1155Received() function if recipient is contract
     */
    /**
     * @natural_language
     * @description After the safeBatchTransferFrom operation, the recipient address (_to) is not the zero address. The msg.sender is an approved operator for the token holder (_from) or the token holder is the same as the msg.sender. A TransferBatch event is emitted upon successful batch transfer.
     * @param _from The address of the token holder transferring the tokens
     * @param _to The address of the recipient
     * @param _ids An array of token IDs being transferred
     * @param _values An array of the number of tokens to transfer for each corresponding token ID
     * @param _data Additional data passed with the batch transfer
     * @event TransferBatch Emitted when the safeBatchTransferFrom operation is executed
     */
    /// @notice postcondition _to != address(0)
    /// @notice postcondition operators[_from][msg.sender] || _from == msg.sender
    /// @notice emits TransferBatch
    function safeBatchTransferFrom(
        address _from,
        address _to,
        uint256[] memory _ids,
        uint256[] memory _values,
        bytes memory _data
    ) public {
        // Requirements
        require(
            (msg.sender == _from) || operators[_from][msg.sender],
            "INVALID_OPERATOR"
        );
        require(_to != address(0), "INVALID_RECIPIENT");

        _safeBatchTransferFrom(_from, _to, _ids, _values, _data);
    }

    /***********************************|
  |    Internal Transfer Functions    |
  |__________________________________*/

    /**
     * @dev Allow _from or an operator to transfer tokens from one address to another
     * @param _from The address which you want to send tokens from
     * @param _to The address which you want to transfer to
     * @param _id Token id to update balance of - For this implementation, via `uint256(tokenAddress)`.
     * @param _value The amount of tokens of provided token ID to be transferred
     * @param _data Data to pass to onERC1155Received() function if recipient is contract
     */
    /// @notice emits TransferSingle
    function _safeTransferFrom(
        address _from,
        address _to,
        uint256 _id,
        uint256 _value,
        bytes memory _data
    ) internal {
        // Update balances
        balances[_from][_id] = balances[_from][_id].sub(_value); // Subtract value
        balances[_to][_id] = balances[_to][_id].add(_value); // Add value

        // Check if recipient is contract
        // if (_to.isContract()) {
        //   bytes4 retval = IERC1155TokenReceiver(_to).onERC1155Received(msg.sender, _from, _id, _value, _data);
        //   require(retval == ERC1155_RECEIVED_VALUE, "ERC1155#_safeTransferFrom: INVALID_ON_RECEIVE_MESSAGE");
        // }

        // Emit event
        emit TransferSingle(msg.sender, _from, _to, _id, _value);
    }

    /**
     * @dev transfer objects from different ids to specified address
     * @param _from The address to batchTransfer objects from.
     * @param _to The address to batchTransfer objects to.
     * @param _ids Array of ids to update balance of - For this implementation, via `uint256(tokenAddress)`
     * @param _values Array of amount of object per id to be transferred.
     * @param _data Data to pass to onERC1155Received() function if recipient is contract
     */
    /// @notice emits TransferBatch
    function _safeBatchTransferFrom(
        address _from,
        address _to,
        uint256[] memory _ids,
        uint256[] memory _values,
        bytes memory _data
    ) internal {
        require(_ids.length == _values.length, "INVALID_ARRAYS_LENGTH");

        // Number of transfer to execute
        uint256 nTransfer = _ids.length;

        // Executing all transfers
        for (uint256 i = 0; i < nTransfer; i++) {
            // Update storage balance of previous bin
            balances[_from][_ids[i]] = balances[_from][_ids[i]].sub(_values[i]);
            balances[_to][_ids[i]] = balances[_to][_ids[i]].add(_values[i]);
        }

        // Pass data if recipient is contract
        // if (_to.isContract()) {
        //   bytes4 retval = IERC1155TokenReceiver(_to).onERC1155BatchReceived(msg.sender, _from, _ids, _values, _data);
        //   require(retval == ERC1155_BATCH_RECEIVED_VALUE, "ERC1155#_safeBatchTransferFrom: INVALID_ON_RECEIVE_MESSAGE");
        // }

        emit TransferBatch(msg.sender, _from, _to, _ids, _values);
    }

    /***********************************|
  |         Operator Functions        |
  |__________________________________*/

    /**
     * @dev Will set _operator operator status to true or false
     * @param _operator Address to changes operator status.
     * @param _approved  _operator"s new operator status (true or false)
     */
    /// @notice  postcondition operators[msg.sender][_operator] ==  _approved
    /// @notice  emits  ApprovalForAll
    function setApprovalForAll(address _operator, bool _approved) external {
        // Update operator status
        operators[msg.sender][_operator] = _approved;
        emit ApprovalForAll(msg.sender, _operator, _approved);
    }

    /**
     * @dev Function that verifies whether _operator is an authorized operator of _tokenHolder.
     * @param _operator The address of the operator to query status of
     * @param _owner Address of the tokenHolder
     * @return A uint256 specifying the amount of tokens still available for the spender.
     */
    /// @notice postcondition operators[_owner][_operator] == isOperator
    function isApprovedForAll(
        address _owner,
        address _operator
    ) external view returns (bool isOperator) {
        return operators[_owner][_operator];
    }

    /***********************************|
  |         Balance Functions         |
  |__________________________________*/

    /**
     * @dev return the _id id" balance of _address
     * @param _address Address to query balance of
     * @param _id id to query balance of
     * @return Amount of objects of a given id ID
     */
    /// @notice postcondition balances[_address][_id] == balance
    function balanceOf(
        address _address,
        uint256 _id
    ) external view returns (uint256 balance) {
        return balances[_address][_id];
    }

    /**
     * @dev Get the balance of multiple account/token pairs
     * @param _owners The addresses of the token holders
     * @param _ids    ID of the Tokens
     * @return        The _owner's balance of the Token types requested
     */
    /**
     * @natural_language
     * @description Retrieve the balances of multiple tokens with various `_ids` for a list of `_owners`.
     * @param _owners An array of addresses representing the token owners
     * @param _ids An array of token IDs for which to retrieve the balances
     * @return batchBalances An array of token balances, corresponding to the token IDs and owners provided in `_ids` and `_owners`
     */
    /// @notice postcondition batchBalances.length == _ids.length
    /// @notice postcondition batchBalances.length == _owners.length
    /// @notice postcondition forall (uint x) !( 0 <= x &&  x < batchBalances.length ) || batchBalances[x] == balances[_owners[x]][_ids[x]]
    function balanceOfBatch(
        address[] memory _owners,
        uint256[] memory _ids
    ) public view returns (uint256[] memory batchBalances) {
        require(_owners.length == _ids.length, "INVALID_ARRAY_LENGTH");

        // Variables
        batchBalances = new uint256[](_owners.length);

        /// @notice invariant (batchBalances.length == _ids.length && batchBalances.length == _owners.length)
        /// @notice invariant (0 <= i && i <= _owners.length)
        /// @notice invariant (0 <= i && i <= batchBalances.length)
        /// @notice invariant forall(uint k)  _ids[k] == __verifier_old_uint(_ids[k])
        /// @notice invariant forall (uint j) !(0 <= j && j < i && j < _owners.length ) || batchBalances[j] == balances[_owners[j]][_ids[j]]
        for (uint256 i = 0; i < _owners.length; i++) {
            batchBalances[i] = balances[_owners[i]][_ids[i]];
        }

        return batchBalances;
    }

    /***********************************|
  |          ERC165 Functions         |
  |__________________________________*/

    /**
     * INTERFACE_SIGNATURE_ERC165 = bytes4(keccak256("supportsInterface(bytes4)"));
     */
    bytes4 private constant INTERFACE_SIGNATURE_ERC165 = 0x01ffc9a7;

    /**
     * INTERFACE_SIGNATURE_ERC1155 =
     *   bytes4(keccak256("safeTransferFrom(address,address,uint256,uint256,bytes)")) ^
     *   bytes4(keccak256("safeBatchTransferFrom(address,address,uint256[],uint256[],bytes)")) ^
     *   bytes4(keccak256("balanceOf(address,uint256)")) ^
     *   bytes4(keccak256("setApprovalForAll(address,bool)")) ^
     *   bytes4(keccak256("isApprovedForAll(address,address)"));
     */
    bytes4 private constant INTERFACE_SIGNATURE_ERC1155 = 0x97a409d2;

    /**
     * @dev Query if a contract implements an interface
     * @param _interfaceID The interface identifier, as specified in ERC-165
     * @return `true` if the contract implements `_interfaceID` and
     */
    function supportsInterface(
        bytes4 _interfaceID
    ) external view returns (bool) {
        if (
            _interfaceID == INTERFACE_SIGNATURE_ERC165 ||
            _interfaceID == INTERFACE_SIGNATURE_ERC1155
        ) {
            return true;
        }
        return false;
    }
}
