pragma solidity >=0.4.24 <0.9.0;

import "./Token_v2.sol";

/// @notice  invariant  totalSupply  ==  __verifier_sum_uint(balances)
contract ERC20Token is Token_v2 {
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
    function transfer(address _to, uint _value) public returns (bool success) {
        require(
            balances[msg.sender] >= _value &&
                balances[_to] + _value >= balances[_to]
        );
        balances[msg.sender] -= _value;
        balances[_to] += _value;
        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    /**
     * @natural_language
     * @description Transfer `_value` tokens from `_from` to `_to` using the allowance mechanism
     * @param _from The address of the sender
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
        uint _value
    ) public returns (bool success) {
        require(
            balances[_from] >= _value &&
                allowed[_from][msg.sender] >= _value &&
                balances[_to] + _value >= balances[_to]
        );
        balances[_to] += _value;
        balances[_from] -= _value;
        allowed[_from][msg.sender] -= _value;
        emit Transfer(_from, _to, _value);
        return true;
    }

    /**
     * @natural_language
     * @description Approve `_spender` to spend `_value` tokens on the caller's behalf
     * @param _spender The address of the account allowed to spend the tokens
     * @param _value The number of tokens allowed to be spent
     * @return success A boolean indicating if the operation was successful
     */
    /// @notice  postcondition (allowed[msg.sender ][ _spender] ==  _value  &&  success) || ( allowed[msg.sender ][ _spender] ==  __verifier_old_uint ( allowed[msg.sender ][ _spender] ) && !success )
    /// @notice  emits  Approval
    function approve(
        address _spender,
        uint _value
    ) public returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    /**
     * @natural_language
     * @description Get the balance of tokens held by `_owner`
     * @param _owner The address of the account to check the balance of
     * @return balance The number of tokens held by `_owner`
     */
    /// @notice postcondition balances[_owner] == balance
    function balanceOf(address _owner) public view returns (uint balance) {
        return balances[_owner];
    }

    /**
     * @natural_language
     * @description Get the remaining number of tokens that `_spender` is allowed to spend on behalf of `_owner`
     * @param _owner The address of the account allowing the spend
     * @param _spender The address of the account allowed to spend the tokens
     * @return remaining The remaining number of tokens allowed to be spent
     */
    /// @notice postcondition allowed[_owner][_spender] == remaining
    function allowance(
        address _owner,
        address _spender
    ) public view returns (uint remaining) {
        return allowed[_owner][_spender];
    }

    mapping(address => uint) balances;
    mapping(address => mapping(address => uint)) allowed;
    uint public totalSupply;
}
