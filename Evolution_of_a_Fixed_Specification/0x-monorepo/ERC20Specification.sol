// SPDX-License-Identifier: MIT
pragma solidity >=0.4.24 <0.9.0;

/// @notice  invariant  _totalSupply  ==  __verifier_sum_uint(balances)
contract ERC20Specification {
    mapping(address => uint256) internal balances;
    mapping(address => mapping(address => uint256)) internal allowed;

    uint256 internal _totalSupply;

    event Transfer(address indexed _from, address indexed _to, uint _value);
    event Approval(
        address indexed _owner,
        address indexed _spender,
        uint _value
    );

    /**
     * @natural_language
     * @description If the transfer is successful, the balance of the sender (msg.sender) decreases by the transferred value (_value) if the sender and receiver (_to) are different, or remains the same if the sender and receiver are the same. The balance of the recipient increases by the transferred value if the sender and receiver are different, or remains the same if the sender and receiver are the same. If the transfer is not successful, there is no change in the balances. A Transfer event is emitted upon successful transfer.
     * @param _to The address of the recipient
     * @param _value The number of tokens to transfer
     * @return success A boolean indicating if the operation was successful
     * @event Transfer Emitted when the transfer operation is executed
     */
    /// @notice  postcondition ( ( balances[msg.sender] ==  __verifier_old_uint (balances[msg.sender] ) - _value  && msg.sender  != _to ) || ( balances[msg.sender] ==  __verifier_old_uint ( balances[msg.sender]) && msg.sender  == _to ) &&  success ) || !success
    /// @notice  postcondition ( ( balances[_to] ==  __verifier_old_uint ( balances[_to] ) + _value  && msg.sender  != _to ) || ( balances[_to] ==  __verifier_old_uint ( balances[_to] ) && msg.sender  == _to ) &&  success ) || !success
    /// @notice  emits Transfer
    function transfer(
        address _to,
        uint256 _value
    ) external returns (bool success) {}

    /**
     * @natural_language
     * @description When the transferFrom is successful, the balance of the specified sender (_from) decreases by the transferred value if the sender and receiver (_to) are different, or remains the same if the sender and receiver are the same. If the transferFrom is not successful, there is no change in the balances. In addition, the balance of the specified receiver (_to) increases by the transferred value if the sender and receiver are different, or remains the same if the sender and receiver are the same. The allowance for the msg.sender decreases by the transferred value, or remains the same if the transferFrom is not successful. The new allowance for msg.sender is less than or equal to the old allowance, or the sender is the same as the msg.sender.
     * @param _from The address of the token holder transferring the tokens
     * @param _to The address of the recipient
     * @param _value The number of tokens to transfer
     * @return success A boolean indicating if the operation was successful
     */
    /// @notice  postcondition ( ( balances[_from] ==  __verifier_old_uint (balances[_from] ) - _value  &&  _from  != _to ) || ( balances[_from] ==  __verifier_old_uint ( balances[_from] ) &&  _from == _to ) &&  success ) || !success
    /// @notice  postcondition ( ( balances[_to] ==  __verifier_old_uint ( balances[_to] ) + _value  &&  _from  != _to ) || ( balances[_to] ==  __verifier_old_uint ( balances[_to] ) &&  _from  == _to ) &&  success ) || !success
    /// @notice  postcondition ( allowed[_from ][msg.sender] ==  __verifier_old_uint (allowed[_from ][msg.sender] ) - _value ) || ( allowed[_from ][msg.sender] ==  __verifier_old_uint (allowed[_from ][msg.sender] ) && !success) ||  _from  == msg.sender
    /// @notice  postcondition  allowed[_from ][msg.sender]  <= __verifier_old_uint (allowed[_from ][msg.sender] ) ||  _from  == msg.sender
    /// @notice  emits  Transfer
    function transferFrom(
        address _from,
        address _to,
        uint256 _value
    ) external returns (bool success) {}

    /**
     * @natural_language
     * @description If the approval is successful, the allowance of the spender for the sender is set to the specified value. If the approval is not successful, the allowance remains unchanged.
     * @param _spender The address of the spender
     * @param _value The number of tokens to be allowed
     * @return success A boolean indicating if the operation was successful
     */
    /// @notice  postcondition (allowed[msg.sender ][ _spender] ==  _value  &&  success) || ( allowed[msg.sender ][ _spender] ==  __verifier_old_uint ( allowed[msg.sender ][ _spender] ) && !success )
    /// @notice  emits  Approval
    function approve(
        address _spender,
        uint256 _value
    ) external returns (bool success) {}

    /**
     * @natural_language
     * @description The total supply of tokens (supply) is set to be equal to the specified total supply value (_totalSupply).
     * @param _totalSupply The total number of tokens (supply) in circulation
     */
    /// @notice postcondition supply == _totalSupply
    function totalSupply() external view returns (uint256 supply) {}

    /**
     * @natural_language
     * @description The balance of the specified owner (_owner) is equal to the returned balance value (balance).
     * @param _owner The address of the token holder whose balance is being checked
     * @return balance The token balance of the specified owner
     */
    /// @notice postcondition balances[_owner] == balance
    function balanceOf(
        address _owner
    ) external view returns (uint256 balance) {}

    /**
     * @natural_language
     * @description The remaining allowance for the specified spender (_spender) from the owner's (_owner) balance is equal to the returned remaining value (remaining).
     * @param _owner The address of the token holder who granted the allowance
     * @param _spender The address of the spender whose remaining allowance is being checked
     * @return remaining The remaining token allowance of the spender from the owner's balance
     */
    /// @notice postcondition allowed[_owner][_spender] == remaining
    function allowance(
        address _owner,
        address _spender
    ) external view returns (uint256 remaining) {}
}
