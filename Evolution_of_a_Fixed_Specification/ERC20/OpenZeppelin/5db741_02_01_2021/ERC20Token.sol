// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0;
// pragma solidity ^0.8.0;

import "./Context.sol";
import "./IERC20.sol";

/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 * For a generic mechanism see {ERC20PresetMinterPauser}.
 *
 * TIP: For a detailed writeup see our guide
 * https://forum.zeppelin.solutions/t/how-to-implement-erc20-supply-mechanisms/226[How
 * to implement supply mechanisms].
 *
 * We have followed general OpenZeppelin guidelines: functions revert instead
 * of returning `false` on failure. This behavior is nonetheless conventional
 * and does not conflict with the expectations of ERC20 applications.
 *
 * Additionally, an {Approval} event is emitted on calls to {transferFrom}.
 * This allows applications to reconstruct the allowance for all accounts just
 * by listening to said events. Other implementations of the EIP may not emit
 * these events, as it isn't required by the specification.
 *
 * Finally, the non-standard {decreaseAllowance} and {increaseAllowance}
 * functions have been added to mitigate the well-known issues around setting
 * allowances. See {IERC20-approve}.
 */
/// @notice  invariant  _totalSupply  ==  __verifier_sum_uint(_balances)
contract ERC20 is Context, IERC20 {
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

    /**
     * @dev Sets the values for {name} and {symbol}, initializes {decimals} with
     * a default value of 18.
     *
     * To select a different value for {decimals}, use {_setupDecimals}.
     *
     * All three of these values are immutable: they can only be set once during
     * construction.
     */
    constructor(string memory name_, string memory symbol_) public {
        _name = name_;
        _symbol = symbol_;
        _decimals = 18;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5,05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the value {ERC20} uses, unless {_setupDecimals} is
     * called.
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view returns (uint8) {
        return _decimals;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    /**
     * @natural_language The totalSupply() function should return the same value
     * as the _totalSupply state variable, ensuring that the function does not modify
     * the state of the contract. The postcondition is that the returned value (supply)
     * must be equal to _totalSupply.
     */
    /// @notice postcondition supply == _totalSupply
    function totalSupply() public view returns (uint256 supply) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    // @natural_language The balanceOf() function should return the same value as the _balances state variable, ensuring that the function does not modify the state of the contract. The postcondition is that the returned value (balance) must be equal to _balances[account].
    /// @notice postcondition _balances[account] == balance
    function balanceOf(address account) public view returns (uint256 balance) {
        return _balances[account];
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `recipient` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    /**
     * @natural_language
     * Postconditions:
     * - If the transfer is successful, the balances of the sender and recipient will be updated as follows:
     * - If the sender is not the recipient, the sender's balance will be decreased by the amount transferred and the recipient's balance will be increased by the same amount.
     * - If the sender is also the recipient, neither balance will change.
     * - If the transfer is unsuccessful, the balances will not change.
     * - The function emits a Transfer event.
     */
    /// @notice  postcondition ( ( _balances[msg.sender] ==  __verifier_old_uint (_balances[msg.sender] ) - amount  && msg.sender  != recipient ) ||   ( _balances[msg.sender] ==  __verifier_old_uint ( _balances[msg.sender]) && msg.sender  == recipient ) &&  success )   || !success
    /// @notice  postcondition ( ( _balances[recipient] ==  __verifier_old_uint ( _balances[recipient] ) + amount  && msg.sender  != recipient ) ||   ( _balances[recipient] ==  __verifier_old_uint ( _balances[recipient] ) && msg.sender  == recipient ) &&  success )   || !success
    /// @notice  emits  Transfer
    function transfer(
        address recipient,
        uint256 amount
    ) public returns (bool success) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    /// @notice postcondition _allowances[owner][spender] == remaining
    function allowance(
        address owner,
        address spender
    ) public view returns (uint256 remaining) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    /**
     * @natural_language
     * Postconditions:
     * - If the approval is successful, the allowance granted by the sender to the spender will be updated to the amount specified.
     * - If the approval is unsuccessful, the allowance will not change.
     * - The function emits an Approval event.
     */
    /// @notice postcondition (_allowances[msg.sender ][ spender] ==  amount  &&  success) || ( _allowances[msg.sender ][ spender] ==  __verifier_old_uint ( _allowances[msg.sender ][ spender] ) && !success )
    /// @notice emits Approval
    function approve(
        address spender,
        uint256 amount
    ) public returns (bool success) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * Requirements:
     *
     * - `sender` and `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     * - the caller must have allowance for ``sender``'s tokens of at least
     * `amount`.
     */
    /**
     * @natural_language
     * Postconditions:
     * -The balance of the sender address is either reduced by amount if sender
     * is not equal to recipient, or remains the same if sender is equal to
     * recipient, and success is true. Otherwise, success is false.
     * -The balance of the recipient address is either increased by amount if
     * sender is not equal to recipient, or remains the same if sender is equal
     * to recipient, and success is true. Otherwise, success is false.
     * -The allowance of sender for the msg.sender is reduced by amount and success
     * is true. If success is false, the allowance remains the same. If sender is
     * equal to msg.sender, the allowance may remain the same or be reduced by amount.
     * -The allowance of sender for msg.sender is less than or equal to its previous
     * value before the function call, or remains the same if sender is equal to
     * msg.sender.
     * -The function emits a Transfer event indicating the transfer of amount
     * from sender to recipient.
     * -The function emits an Approval event indicating the updated allowance
     * of sender for msg.sender.
     */

    /// @notice  postcondition ( ( _balances[sender] ==  __verifier_old_uint (_balances[sender] ) - amount  &&  sender  != recipient ) ||   ( _balances[sender] ==  __verifier_old_uint ( _balances[sender] ) &&  sender== recipient ) &&  success )   || !success
    /// @notice  postcondition ( ( _balances[recipient] ==  __verifier_old_uint ( _balances[recipient] ) + amount  &&  sender  != recipient ) ||   ( _balances[recipient] ==  __verifier_old_uint ( _balances[recipient] ) &&  sender  ==recipient ) &&  success )   || !success
    /// @notice  postcondition  (_allowances[sender ][msg.sender] ==  __verifier_old_uint (_allowances[sender ][msg.sender] ) - amount && success) || (_allowances[sender ][msg.sender] ==  __verifier_old_uint (_allowances[sender ][msg.sender] ) && !success) ||  sender  == msg.sender
    /// @notice  postcondition  _allowances[sender ][msg.sender]  <= __verifier_old_uint (_allowances[sender ][msg.sender] ) ||  sender  == msg.sender
    /// @notice  emits  Transfer
    /// @notice emits Approval
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public returns (bool success) {
        _transfer(sender, recipient, amount);

        require(
            _allowances[sender][_msgSender()] >= amount,
            "ERC20: transfer amount exceeds allowance"
        );
        _approve(
            sender,
            _msgSender(),
            _allowances[sender][_msgSender()] - amount
        );

        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    ///@notice emits Approval
    function increaseAllowance(
        address spender,
        uint256 addedValue
    ) public returns (bool) {
        _approve(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender] + addedValue
        );
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    ///@notice emits Approval
    function decreaseAllowance(
        address spender,
        uint256 subtractedValue
    ) public returns (bool) {
        require(
            _allowances[_msgSender()][spender] >= subtractedValue,
            "ERC20: decreased allowance below zero"
        );
        _approve(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender] - subtractedValue
        );

        return true;
    }

    /**
     * @dev Moves tokens `amount` from `sender` to `recipient`.
     *
     * This is internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `sender` cannot be the zero address.
     * - `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     */
    /// @notice  emits  Transfer
    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        require(
            _balances[sender] >= amount,
            "ERC20: transfer amount exceeds balance"
        );
        _balances[sender] -= amount;
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     */
    /// @notice  emits  Transfer
    function _mint(address account, uint256 amount) internal {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    /// @notice  emits  Transfer
    function _burn(address account, uint256 amount) internal {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        require(
            _balances[account] >= amount,
            "ERC20: burn amount exceeds balance"
        );
        _balances[account] -= amount;
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner` s tokens.
     *
     * This internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    /// @notice  emits  Approval
    function _approve(address owner, address spender, uint256 amount) internal {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @dev Sets {decimals} to a value other than the default one of 18.
     *
     * WARNING: This function should only be called from the constructor. Most
     * applications that interact with token contracts will not expect
     * {decimals} to ever change, and may work incorrectly if it does.
     */
    function _setupDecimals(uint8 decimals_) internal {
        _decimals = decimals_;
    }

    /**
     * @dev Hook that is called before any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * will be to transferred to `to`.
     * - when `from` is zero, `amount` tokens will be minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal {}
}
