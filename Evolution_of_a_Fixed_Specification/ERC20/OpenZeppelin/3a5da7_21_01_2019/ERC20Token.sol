// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0;
// pragma solidity ^0.5.2;

import "./IERC20.sol";
import "./SafeMath.sol";

/// @notice  invariant  _totalSupply  ==  __verifier_sum_uint(_balances)
contract ERC20 is IERC20 {
    using SafeMath for uint256;

    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowed;

    uint256 private _totalSupply;

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

    /**
     * @natural_language
     * @description the resulting total supply of tokens should be equal to the total supply of tokens
     */
    /// @notice postcondition supply == _totalSupply
    function totalSupply() public view returns (uint256 supply) {
        return _totalSupply;
    }

    /**
     * @natural_language
     * @description the resulting balance of the specified address should be equal to the balance of the specified address
     * @param owner the address to query the balance of
     * @return balance the balance of the specified address
     */
    /// @notice postcondition _balances[owner] == balance
    function balanceOf(address owner) public view returns (uint256 balance) {
        return _balances[owner];
    }

    /**
     * @natural_language
     * @description the resulting allowance of the specified address should be equal to the allowance of the specified address
     * @param owner the address to receive the transferred tokens
     * @param spender the amount of tokens to transfer
     * @return remaining a boolean value indicating whether the transfer was successful
     */
    /// @notice postcondition _allowed[owner][spender] == remaining
    function allowance(
        address owner,
        address spender
    ) public view returns (uint256 remaining) {
        return _allowed[owner][spender];
    }

    /**
     * @natural_language
     * @description If the sender's address is not equal to the recipient's address, then the sender's new balance should be equal to their old balance minus the transferred value. If this condition holds true, and the transfer is successful, then the entire expression evaluates to true
     * @description If the sender's address is equal to the recipient's address, then the sender's new balance should be equal to their old balance. If this condition holds true, and the transfer is successful, then the entire expression evaluates to true
     * @description the sender's new balance should be equal to their old balance if the sender's address is equal to the recipient's address and the transfer is successful
     * @description the sender's new balance should be equal to their old balance minus the transferred value if the sender's address is not equal to the recipient's address and the transfer is successful
     * @param to The address to receive the transferred tokens
     * @param value The amount of tokens allowed to be spent
     * @return success A boolean value indicating whether the approval was successful
     */
    /// @notice postcondition ( ( _balances[msg.sender] ==  __verifier_old_uint (_balances[msg.sender] ) - value  && msg.sender  != to ) ||   ( _balances[msg.sender] ==  __verifier_old_uint ( _balances[msg.sender]) && msg.sender  == to ) &&  success )   || !success
    /// @notice postcondition ( ( _balances[to] ==  __verifier_old_uint ( _balances[to] ) + value  && msg.sender  != to ) ||   ( _balances[to] ==  __verifier_old_uint ( _balances[to] ) && msg.sender  == to ) &&  success )   || !success
    /// @notice  emits  Transfer
    function transfer(address to, uint256 value) public returns (bool success) {
        _transfer(msg.sender, to, value);
        return true;
    }

    /**
     * @natural_language
     * @description When the approval is successful, the allowance of the specified spender (spender) for the sender (msg.sender) in _allowed is set to the specified value (value). If the approval is not successful, the allowance remains unchanged. An Approval event is emitted in both cases.
     * @param spender The address of the spender
     * @param value The number of tokens to be allowed
     * @return success A boolean indicating if the operation was successful
     */
    /// @notice postcondition (_allowed[msg.sender ][ spender] ==  value  &&  success) || ( _allowed[msg.sender ][ spender] ==  __verifier_old_uint ( _allowed[msg.sender ][ spender] ) && !success )
    /// @notice  emits  Approval
    function approve(
        address spender,
        uint256 value
    ) public returns (bool success) {
        _approve(msg.sender, spender, value);
        return true;
    }

    /**
     * @natural_language
     * @description When the transferFrom is successful, the balance of the specified sender (_from) decreases by the transferred value if the sender and receiver (_to) are different, or remains the same if the sender and receiver are the same. If the transferFrom is not successful, there is no change in the balances. In addition, the balance of the specified receiver (_to) increases by the transferred value if the sender and receiver are different, or remains the same if the sender and receiver are the same. The allowance for the msg.sender decreases by the transferred value, or remains the same if the transferFrom is not successful. The new allowance for msg.sender is less than or equal to the old allowance, or the sender is the same as the msg.sender.
     * @param from The address of the token holder transferring the tokens
     * @param to The address of the recipient
     * @param value The number of tokens to transfer
     * @return success A boolean indicating if the operation was successful
     */
    /// @notice postcondition ( ( _balances[from] ==  __verifier_old_uint (_balances[from] ) - value  &&  from  != to ) ||   ( _balances[from] ==  __verifier_old_uint ( _balances[from] ) &&  from== to ) &&  success )   || !success
    /// @notice postcondition ( ( _balances[to] ==  __verifier_old_uint ( _balances[to] ) + value  &&  from  != to ) ||   ( _balances[to] ==  __verifier_old_uint ( _balances[to] ) &&  from  ==to ) &&  success )   || !success
    /// @notice  postcondition  (_allowed[from ][msg.sender] ==  __verifier_old_uint (_allowed[from ][msg.sender] ) - value && success) || (_allowed[from ][msg.sender] ==  __verifier_old_uint (_allowed[from ][msg.sender] ) && !success) || from  == msg.sender
    /// @notice postcondition  _allowed[from ][msg.sender]  <= __verifier_old_uint (_allowed[from ][msg.sender] ) ||  from  == msg.sender
    /// @notice emits  Transfer
    /// @notice emits  Approval
    function transferFrom(
        address from,
        address to,
        uint256 value
    ) public returns (bool success) {
        _transfer(from, to, value);
        _approve(from, msg.sender, _allowed[from][msg.sender].sub(value));
        return true;
    }

    /**
     * @natural_language
     * Postconditions:
     * - If the allowance increase is successful, the allowance granted by the msg.sender to the spender will be updated by adding the addedValue specified.
     * - The function emits an Approval event.
     */
    /// @notice  emits  Approval
    function increaseAllowance(
        address spender,
        uint256 addedValue
    ) public returns (bool) {
        _approve(
            msg.sender,
            spender,
            _allowed[msg.sender][spender].add(addedValue)
        );
        return true;
    }

    /**
     * @natural_language The decreaseAllowance() function should decrease the allowance
     * of spender for the msg.sender account by subtractedValue and emit an Approval
     * event. The function should return true. The function should not modify any other
     * state variables except for the allowance of spender for msg.sender.
     */
    /// @notice  emits  Approval
    function decreaseAllowance(
        address spender,
        uint256 subtractedValue
    ) public returns (bool) {
        _approve(
            msg.sender,
            spender,
            _allowed[msg.sender][spender].sub(subtractedValue)
        );
        return true;
    }

    /**
     * @natural_language The _transfer() function transfers tokens from one account to
     * another, emits a Transfer event, and requires the recipient account to be a
     * non-zero address. The function modifies the _balances mapping to reflect the
     * token transfer and is internal, meaning it can only be called from within
     * the contract.
     */
    /// @notice  emits  Transfer
    function _transfer(address from, address to, uint256 value) internal {
        require(to != address(0));

        _balances[from] = _balances[from].sub(value);
        _balances[to] = _balances[to].add(value);
        emit Transfer(from, to, value);
    }

    /**
     * @natural_language The _mint() function should mint value amount of tokens and
     * add them to the account balance, and emit a Transfer event. The function should
     * require that the account is not the zero address. The function should modify
     * the _totalSupply and _balances mappings to reflect the minting of tokens to
     * account. The function should be internal, meaning it cannot be called from
     * outside the contract.
     */
    /// @notice  emits  Transfer
    function _mint(address account, uint256 value) internal {
        require(account != address(0));

        _totalSupply = _totalSupply.add(value);
        _balances[account] = _balances[account].add(value);
        emit Transfer(address(0), account, value);
    }

    /**
     * @natural_language The _burn() function should burn value amount of tokens
     * from the account balance and emit a Transfer event. The function should require
     * that the account is not the zero address. The function should modify the
     * _totalSupply and _balances mappings to reflect the burning of tokens from
     * account. The function should be internal, meaning it cannot be called from
     * outside the contract.
     */
    /// @notice  emits  Transfer
    function _burn(address account, uint256 value) internal {
        require(account != address(0));

        _totalSupply = _totalSupply.sub(value);
        _balances[account] = _balances[account].sub(value);
        emit Transfer(account, address(0), value);
    }

    /**
     * @natural_language The _approve() function should set the allowance of spender
     * for the owner account to value and emit an Approval event. The function should
     * require that the owner and spender are not the zero address. The function
     * should be internal, meaning it cannot be called from outside the contract.
     */
    /// @notice  emits  Approval
    function _approve(address owner, address spender, uint256 value) internal {
        require(spender != address(0));
        require(owner != address(0));

        _allowed[owner][spender] = value;
        emit Approval(owner, spender, value);
    }

    /**
     * @natural_language The function _burnFrom burns a specified amount of
     * tokens from the given account, and emits an Approval event for the
     * allowance decrease and a Transfer event for the token burn. It also
     * updates the approved allowance for the spender.
     */
    /// @notice  emits  Approval
    /// @notice  emits  Transfer
    function _burnFrom(address account, uint256 value) internal {
        _burn(account, value);
        _approve(account, msg.sender, _allowed[account][msg.sender].sub(value));
    }
}
