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
     * @natural_language The totalSupply() function should return the same value as
     * the _totalSupply state variable, ensuring that the function does not modify
     * the state of the contract. The postcondition is that the returned value (supply)
     * must be equal to _totalSupply.
     */
    //
    /// @notice postcondition supply == _totalSupply
    function totalSupply() public view returns (uint256 supply) {
        return _totalSupply;
    }

    /**
     * @natural_language The balanceOf() function should return the same value as the
     * balance of the specified owner account held in the internal _balances mapping,
     * ensuring that the function does not modify the state of the contract.
     * The postcondition isthat the returned value (balance) must be equal to the
     * balance of the specified account.
     */
    /// @notice postcondition _balances[owner] == balance
    function balanceOf(address owner) public view returns (uint256 balance) {
        return _balances[owner];
    }

    /**
     * @natural_language The allowance() function should return the same value as the
     * amount of tokens that spender is allowed to spend from the owner account held
     * in the internal _allowed mapping. The postcondition is that the returned value
     * (remaining) must be equal to the allowance stored in _allowed[owner][spender].
     * The function should not modify the state of the contract and should only
     * retrieve the allowance and return it as the output of the function.
     */
    /// @notice postcondition _allowed[owner][spender] == remaining
    function allowance(
        address owner,
        address spender
    ) public view returns (uint256 remaining) {
        return _allowed[owner][spender];
    }

    /**
     * @natural_language The transfer() function should transfer the specified amount
     * of tokens from the sender's account to the specified recipient account. The
     * function should not modify the state of the contract and should only transfer
     * the specified amount of tokens from the sender's account to the recipient's
     * account. The postcondition is that the sender's balance must be reduced by
     * the specified amount of tokens and the recipient's balance must be increased
     * by the specified amount of tokens. The function should revert if the sender's
     * account does not have enough tokens to transfer.
     */
    /// @notice postcondition ( ( _balances[msg.sender] ==  __verifier_old_uint (_balances[msg.sender] ) - value  && msg.sender  != to ) ||   ( _balances[msg.sender] ==  __verifier_old_uint ( _balances[msg.sender]) && msg.sender  == to ) &&  success )   || !success
    /// @notice postcondition ( ( _balances[to] ==  __verifier_old_uint ( _balances[to] ) + value  && msg.sender  != to ) ||   ( _balances[to] ==  __verifier_old_uint ( _balances[to] ) && msg.sender  == to ) &&  success )   || !success
    /// @notice  emits  Transfer
    function transfer(address to, uint256 value) public returns (bool success) {
        _transfer(msg.sender, to, value);
        return true;
    }

    /**
     * @natural_language The approve() function should set the allowance for spender
     * to value for the msg.sender account, emit an Approval event, and return true.
     * The postcondition is that either the allowance of spender for msg.sender is
     * set to value and the function returns true, or the allowance is not modified
     * and the function returns false. The function should not modify any other
     * state variables except for the allowance of spender for msg.sender.
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
     * @natural_language The transferFrom() function should transfer value amount
     * of tokens from from to to using the allowance of msg.sender. The
     * postconditions are:
     * The balance of from should be decreased by value if from and to are different
     * accounts, or should remain the same if from and to are the same account.
     * The balance of to should be increased by value if from and to are different
     * accounts, or should remain the same if from and to are the same account.
     * The allowance of msg.sender for from should be decreased by value.
     * The allowance of msg.sender for from should be less than or equal to the original
     * allowance or should be equal to the original allowance if the transfer fails.
     * The function should emit a Transfer event and an Approval event.
     * The function should return true if the transfer succeeds or false if it fails.
     * The function should not modify any other state variables except for the balances
     * and allowances of the specified accounts.
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
     * @natural_language The increaseAllowance() function should increase the allowance
     * of spender for the msg.sender account by addedValue and emit an Approval event.
     * The function should return true. The function should not modify any other state
     * variables except for the allowance of spender for msg.sender.
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
