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
     * @description Transfer `_value` tokens from the caller's account to account `_to`
     * @param _to The address of the recipient
     * @param _value The number of tokens to transfer
     * @return success A boolean indicating if the operation was successful
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
     * @description Transfer `_value` tokens from `_from` account to account `_to`, with the approval of the `_from` account's owner
     * @param _from The address of the account from which tokens will be transferred
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
     * @description Approve `_spender` to transfer `_value` tokens from the caller's account
     * @param _spender The address of the account allowed to transfer tokens
     * @param _value The number of tokens to approve for transfer
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
     * @description Get the total supply of tokens
     * @return supply The total supply of tokens
     */
    /// @notice postcondition supply == _totalSupply
    function totalSupply() external view returns (uint256 supply) {}

    /**
     * @natural_language
     * @description Get the token balance of `_owner`
     * @param _owner The address of the owner
     * @return balance The token balance of `_owner`
     */
    /// @notice postcondition balances[_owner] == balance
    function balanceOf(
        address _owner
    ) external view returns (uint256 balance) {}

    /**
     * @natural_language
     * @description Get the remaining tokens that `_spender` is allowed to withdraw from `_owner`
     * @param _owner The address of the owner
     * @param _spender The address of the spender
     * @return remaining The remaining tokens that `_spender` is allowed to withdraw from `_owner`
     */
    /// @notice postcondition allowed[_owner][_spender] == remaining
    function allowance(
        address _owner,
        address _spender
    ) external view returns (uint256 remaining) {}
}
